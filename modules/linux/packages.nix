{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [

  # Security and authentication
  yubikey-agent

  # App and package management
  gnumake
  cmake

  # Productivity tools
  bc # old school calculator

  # Testing and development tools
  direnv
  postgresql
  libtool # for Emacs vterm

  # Text and terminal utilities
  tree
  unixtools.ifconfig
  unixtools.netstat

  # File and system utilities
  inotify-tools # inotifywait, inotifywatch - For file system events
  sqlite
]
