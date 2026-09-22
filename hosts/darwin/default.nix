{ pkgs, user, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  # The Lix installer creates the nixbld group with the Sequoia-era GID 350,
  # but nix-darwin defaults to 30000 while system.stateVersion < 5. The UIDs
  # already match (ids.uids.nixbld defaults to 350 -> _nixbld1 = 351), so only
  # the GID needs pinning. Prefer this over bumping stateVersion, which records
  # when nix-darwin was installed rather than how Nix was installed.
  ids.gids.nixbld = 350;

  nix = {
    # Lix is installed via install.lix.systems, but nix-darwin owns
    # /etc/nix/nix.conf and the nix-daemon so the settings below actually apply.
    package = pkgs.lix;

    # Replaces the installer's `extra-nix-path`.
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      always-allow-substitutes = true;
      bash-prompt-prefix = "(nix:$name)\\040";
      # HTTPS to substituters is re-signed by a TLS-inspecting corporate proxy,
      # whose root CA ships only in this keychain export (written by the Lix
      # installer), not in the Mozilla bundle nix-darwin generates. The
      # installer used to set this in its own /etc/nix/nix.conf; nix-darwin owns
      # that file now, so it has to be declared here. An explicit setting beats
      # the NIX_SSL_CERT_FILE nix-darwin puts in the nix-daemon plist, so this
      # covers client and daemon. See "Gotchas" in the README.
      ssl-cert-file = "/etc/nix/macos-keychain.crt";

      trusted-users = [
        "@admin"
        "${user}"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-substituters = [
        "https://pi.cachix.org"
        "https://cache.lix.systems"
      ];
      extra-trusted-public-keys = [
        "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
  };

  environment = {
    systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };
  };

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 25; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };

      dock = {
        autohide = true;
        launchanim = true;
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        showhidden = true;
        tilesize = 32;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}
