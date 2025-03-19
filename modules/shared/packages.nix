{ pkgs }:

with pkgs; [
  # General packages for development and system management
  aspell # spell checker for many languages
  aspellDicts.en
  bash-completion
  coreutils # GNU core utilites
  curl
  devbox
  fd # fancy `find`
  findutils # GNU find utils
  gh # github cli tool
  gnumake
  just # save and run project specific commands
  killall
  less # more advanced file pager than `more`
  meld
  neofetch
  openssh
  rsync # incremental file transfer util
  sqlite
  tenv # version manager for OpenTofu, Terraform and Terragrunt
  vim
  wget
  zip
  pwgen

  # code tools
  jsonnet-language-server
  nodePackages.bash-language-server
  nodePackages.prettier # code formatter
  nodePackages.typescript-language-server
  nodePackages.vim-language-server
  podman # docker replacement
  pqrs # cli too to inspect parquet files
  python39Packages.sqlparse
  nil # nix language server
  rustup
  shellcheck
  shfmt # shell parser and formatter
  tgswitch
  universal-ctags # maintained ctags implementation

  # nix tools
  alejandra
  cachix
  nixpkgs-fmt
  nodePackages.node2nix

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  gpgme # make gnupg easier
  granted
  libfido2
  pass # "password manager"
  xkcdpass # generate passwords
  yubikey-manager # configure yubikeys

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs

  # Text and terminal utilities
  asciidoctor
  bat
  chatgpt-cli
  graphviz # graph visualization tools
  htop # fancy `top`
  hunspell
  iftop
  jetbrains-mono
  jq # command line json processor
  nmap
  openssl
  pure-prompt
  qemu
  renameutils
  ripgrep # fancy `grep`
  tmux
  tree # depth indented directory listing
  unrar
  unzip
  watch

  # Python packages
  python3
  virtualenv

  # Cloud stuff
  aws-vault
  awscli2
]
