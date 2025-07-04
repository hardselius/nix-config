{ pkgs }:

with pkgs; [
  # A
  age # File encryption tool
  age-plugin-yubikey # YubiKey plugin for age encryption
  alejandra
  asciidoctor
  aspell # Spell checker
  aspellDicts.en
  aws-vault
  awscli2 # AWS CLI v2

  # B
  bash-completion # Bash completion scripts
  bat # cat clone with syntax highlighting

  # C
  cachix
  coreutils # GNU core utilites
  curl # 

  # D
  dejavu_fonts
  devbox # Development environment manager
  docker # Docker
  docker-compose

  # F
  fd # Fast find alternative
  ffmpeg # Multimedia framework
  findutils # GNU find utils
  font-awesome

  # G
  gh # GitHub CLI tool
  gnumake # GNU make
  gnupg # GNU Privacy Guard
  gpgme # GnuPG made easy
  graphviz # graph visualization tools

  # H
  hack-font
  htop # Interactive process viewer
  hunspell # Spell checker

  # I
  iftop # Network bandwidth monitor

  # J
  jetbrains-mono
  jq # command line json processor
  jsonnet-language-server # Jsonnet language server
  just # save and run project specific commands

  # K
  killall # Kill processes

  # L
  less # more advanced file pager than `more`
  libfido2 # FIDO2 library
  llama-cpp # LLM stuff

  # M
  meld # Diff tool
  meslo-lgs-nf

  # N
  neofetch # System information tool
  nil # nix language server
  nixpkgs-fmt # Nix file formatter
  nmap # Network scanner
  nodePackages.bash-language-server # Bash language server
  nodePackages.npm # globally install npm
  nodePackages.prettier # Code formatter
  nodePackages.typescript-language-server # TypeScript language server
  nodePackages.vim-language-server # Vim language server
  nodejs # JavaScript runtime
  noto-fonts
  noto-fonts-emoji

  # O
  ollama # LLM stuff
  openssh # SSH client
  openssl # OpenSSL

  # P
  pass # Password manager
  podman # Docker replacement
  pqrs # Cli too to inspect parquet files
  pure-prompt # ZSH prompt
  pwgen # Password generator

  python3 # Python 3


  # Q
  qemu # Virtual machine

  # R
  renameutils # Rename files in a directory
  ripgrep # Fast grep alternative
  rsync # Incremental file transfer util
  rustup # Rust toolchain manager

  # S
  shellcheck # Shell script linter
  shfmt # Shell parser and formatter
  sqlite # SQL database engine
  svelte-language-server # Svelte language server

  # T
  tenv # Version manager for OpenTofu, Terraform and Terragrunt
  tgswitch
  tmux # Terminal multiplexer
  tree # Directory tree viewer

  # U
  universal-ctags # maintained ctags implementation
  unrar
  unzip

  # V
  vim # Vim text editor
  virtualenv
  vue-language-server # Vue language server

  # W
  watch
  wget # File downloader

  # X
  xan # CSV processing tool
  xkcdpass # Password generator
  xmlstarlet # Command line XML processor

  # Y
  yubikey-manager # configure yubikeys

  # Z
  zip # ZIP file archiver
]
