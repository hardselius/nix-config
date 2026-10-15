# Standalone home-manager on a non-NixOS distribution. The host owns Nix
# itself (/etc/nix/nix.conf), the login shell, and system daemons such as
# pcscd and docker; see "Non-NixOS Linux" in the README.
{ lib, ... }:

{
  imports = [
    ../../modules/linux/home-manager.nix
  ];

  # Sets XDG_DATA_DIRS, locale archive, and terminfo paths for a foreign distro.
  targets.genericLinux = {
    enable = true;
    # Headless by default; the desktop variant turns GPU drivers back on.
    gpu.enable = lib.mkDefault false;
  };

  # Lets fontconfig find fonts installed through home.packages.
  fonts.fontconfig.enable = true;

  # Lets home-manager install and manage its own CLI.
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
