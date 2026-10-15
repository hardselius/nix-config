{
  description = "Configuration for MacOS, NixOS, and other Linux";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Homebrew taps, pinned as plain sources so `mutableTaps = false` has
    # something fixed to point at.
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # NixOS
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Overlays consumed by modules/shared
    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      disko,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      user = "mch";

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
      ];

      forLinuxSystems = lib.genAttrs linuxSystems;
      forDarwinSystems = lib.genAttrs darwinSystems;
      forAllSystems = lib.genAttrs (linuxSystems ++ darwinSystems);

      pkgsFor = system: nixpkgs.legacyPackages.${system};

      # Every flake input is visible to modules, plus the account this
      # configuration is built for.
      specialArgs = inputs // {
        inherit user;
      };

      ## Apps -------------------------------------------------------------
      # Names of the scripts under apps/<dir>/ exposed as `nix run .#<name>`.
      # On Linux the unprefixed names drive standalone home-manager, which
      # works on any distribution; NixOS apps carry a `nixos-` prefix.
      linuxAppNames = [
        "build"
        "build-switch"
        "rollback"
      ];
      nixosAppNames = [
        "apply"
        "build-switch"
      ];
      darwinAppNames = [
        "apply"
        "build"
        "build-switch"
        "rollback"
        "check-keys"
        "copy-keys"
        "create-keys"
      ];

      mkApp =
        dir: system: scriptName:
        let
          pkgs = pkgsFor system;
          script = self + "/apps/${dir}/${scriptName}";
          # Pinned by this flake, so the first switch on a fresh host needs no
          # home-manager install of its own.
          path = [ pkgs.git ] ++ lib.optional (dir == "linux") home-manager.packages.${system}.home-manager;
        in
        # `script` is a store path here, so pathExists is meaningful under pure
        # eval and catches a name declared below without a matching file.
        assert lib.assertMsg (builtins.pathExists script)
          "app '${scriptName}' is declared for ${system} but ${toString script} does not exist";
        {
          type = "app";
          program = "${(pkgs.writeScriptBin scriptName ''
            #!/usr/bin/env bash
            PATH=${lib.makeBinPath path}:$PATH
            exec env SYSTEM_TYPE=${system} ${script} "$@"
          '')}/bin/${scriptName}";
        };

      mkApps =
        dir: names: system:
        lib.genAttrs names (mkApp dir system);

      ## Dev shell --------------------------------------------------------
      mkDevShells =
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              bashInteractive
              git
              curl
            ];
            shellHook = ''
              export EDITOR=vim
            '';
          };
        };
    in
    {
      devShells = forAllSystems mkDevShells;

      # nixfmt-tree wraps nixfmt, which is also nil's built-in formatter, so
      # `nix fmt` and editor format-on-save produce identical output.
      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      apps =
        forLinuxSystems (
          system:
          mkApps "linux" linuxAppNames system
          // lib.mapAttrs' (name: lib.nameValuePair "nixos-${name}") (mkApps "nixos" nixosAppNames system)
        )
        // forDarwinSystems (mkApps "darwin" darwinAppNames);

      darwinConfigurations = forDarwinSystems (
        system:
        darwin.lib.darwinSystem {
          inherit system specialArgs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );

      # Standalone home-manager for Linux distributions other than NixOS:
      # `<system>` is headless, `<system>-desktop` adds GUI apps and GPU drivers.
      homeConfigurations =
        let
          mkHome =
            system: host:
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs (
                { inherit system; } // import ./modules/shared/nixpkgs.nix { inherit (inputs) pi; }
              );
              extraSpecialArgs = { inherit user; };
              modules = [ host ];
            };
        in
        lib.foldl' (
          acc: system:
          acc
          // {
            ${system} = mkHome system ./hosts/linux;
            "${system}-desktop" = mkHome system ./hosts/linux/desktop.nix;
          }
        ) { } linuxSystems;

      nixosConfigurations = forLinuxSystems (
        system:
        lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit user;
                };
                users.${user} = import ./modules/nixos/home-manager.nix;
              };
            }
            ./hosts/nixos
          ];
        }
      );
    };
}
