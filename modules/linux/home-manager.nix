# Home-manager config for any Linux user environment, NixOS or not. Nothing
# here may assume NixOS paths, services, or a graphical session.
{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  shared-programs = import ../shared/home-manager.nix {
    inherit
      config
      pkgs
      lib
      user
      ;
  };
  shared-files = import ../shared/files.nix { inherit config pkgs; };
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files;
    shellAliases = {
      tf = "terraform";
      switch-yubikey = "gpg-connect-agent \"scd serialno\" \"learn --force\" /bye";

      # Get public ip directly from a DNS server instead of from some hip
      # whatsmyip HTTP service. https://unix.stackexchange.com/a/81699
      wanip = "dig @resolver4.opendns.com myip.opendns.com +short";
      wanip4 = "dig @resolver4.opendns.com myip.opendns.com +short -4";
      wanip6 = "dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6";
      # vi = "nvim";
      # vim = "nvim";
      # vimdiff = "nvim -d";
    };
  };

  programs = shared-programs;

  xdg = {
    enable = true;
  };
}
