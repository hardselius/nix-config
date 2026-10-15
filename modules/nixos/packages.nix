{ pkgs }:

# Tools the bspwm session (sxhkd bindings, polybar, rofi scripts) calls; the
# rest of the Linux packages come from modules/linux.
with pkgs;
[
  # App and package management
  home-manager

  # Testing and development tools
  rofi
  rofi-calc

  # Text and terminal utilities
  feh # Manage wallpapers
  screenkey
  xorg.xwininfo # Provides a cursor to click and learn about windows
  xorg.xrandr

  # File and system utilities
  i3lock-fancy-rapid
  pcmanfm # File browser

  # Other utilities
  yad # yad-calendar is used with polybar
  xdotool
]
