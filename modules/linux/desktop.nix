# Graphical apps for a Linux desktop session, whatever window manager or
# desktop environment provides it.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Security and authentication
    keepassxc

    # App and package management
    appimage-run

    # Media and design tools
    vlc
    fontconfig
    font-manager

    # Productivity tools
    galculator

    # Audio tools
    pavucontrol # Pulse audio controls

    # Screenshot and recording tools
    flameshot

    # Text and terminal utilities
    xclip # For the org-download package in Emacs

    # File and system utilities
    libnotify
    xdg-utils

    # Web browser
    google-chrome

    # PDF viewer
    zathura

    # Music and entertainment
    spotify
  ];
}
