{
  config,
  pkgs,
  lib,
  ...
}:

let
  name = "Martin Hardselius";
  user = "mch";
  email = "martin@hardselius.dev";
  githubUser = "hardselius";
  masterKey = "3F35E4CACBF42DE12E9053E503A6E6F786936619";
in
{
  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  dircolors = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  granted = {
    enable = true;
    enableZshIntegration = true;
  };

  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
      {
        name = "pure";
        src = pkgs.pure-prompt;
      }
    ];

    enableCompletion = true;
    completionInit = ''
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit
      compinit
    '';
    cdpath = [
      "."
      "~"
    ];
    defaultKeymap = "viins";
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      size = 50000;
      save = 500000;
      ignoreDups = true;
      share = true;
    };

    initContent = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH
      export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
      gpg-connect-agent updatestartuptty /bye > /dev/null

      # Vim is my editor
      export ALTERNATE_EDITOR=""
      export EDITOR="vim"

      export PAGER="less"
      export CLICOLOR=1

      export EMAIL="${email}"

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'

      export KEYTIMEOUT=1

      vi-search-fix() {
        zle vi-cmd-mode
        zle .vi-history-search-backward
      }
      autoload vi-search-fix
      zle -N vi-search-fix
      bindkey -M viins '\e/' vi-search-fix

      bindkey "^?" backward-delete-char

      resume() {
        fg
        zle push-input
        BUFFER=""
        zle accept-line
      }
      zle -N resume
      bindkey "^Z" resume

      autoload -U promptinit; promptinit

      # Configure pure-promt
      prompt pure
      zstyle :prompt:pure:prompt:success color green
    '';
  };

  git = {
    enable = true;
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
        trustctime = false;
        logAllRefUpdates = true;
        precomposeunicode = true;
        whitespace = "trailing-space,space-before-tab";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      branch.autosetupmerge = true;
      color.ui = "auto";
      commit.verbose = true;
      diff.submodule = "log";
      diff.tool = "vimdiff";
      difftool.prompt = false;
      http.sslCAinfo = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      http.sslverify = true;
      hub.protocol = "${pkgs.openssh}/bin/ssh";
      merge.tool = "vimdiff";
      mergetool.keepBackup = true;
      push.default = "tracking";
      rebase.autosquash = true;
      rerere.enabled = true;
      status.submoduleSummary = true;
      github.user = githubUser;
    };
    aliases = {
      authors = "!${pkgs.git}/bin/git log --pretty=format:%aN | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/uniq -c | ${pkgs.coreutils}/bin/sort -rn";
      b = "branch --color -v";
      changes = "diff --name-status -r";
      clone = "clone --recursive";
      ctags = "!.git/hooks/ctags";
      root = "!pwd";
      spull = "!${pkgs.git}/bin/git stash && ${pkgs.git}/bin/git pull && ${pkgs.git}/bin/git stash pop";
      su = "submodule update --init --recursive";
      undo = "reset --soft HEAD^";
      w = "status -sb";
      wdiff = "diff --color-words";
      l = "log --graph --abbrev-commit --date=relative --pretty=format:'%C(yellow)%h%C(reset) %C(bold red)%d%C(reset) %s %C(bold cyan)[%(trailers:key=Issue,valueonly=true,separator=%x2C )]%C(reset) %C(green)(%cr)%C(reset) %C(bold blue)<%an>%C(reset)'";
    };
    ignores = [
      "[._]*.s[a-v][a-z]"
      "[._]*.sw[a-p]"
      "[._]s[a-rt-v][a-z]"
      "[._]ss[a-gi-z]"
      "[._]sw[a-p]"
      "Session.vim"
      "Sessionx.vim"
      ".netrwhist"
      "*~"
      "tags"
      "[._]*.un~"
      "**/.idea/"
      "**/*.iml"
      "**/*.ipr"
      "**/*.iws"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
      ".envrc"
      "shell.nix"
      ".direnv/"
    ];
  };

  vim.enable = false;

  wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ./config/wezterm/wezterm.lua;
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/config_external")
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/config_external")
    ];
    matchBlocks = {
      "*" = {
        controlMaster = "auto";
        controlPath = "/tmp/ssh-%u-%r@%h:%p";
        controlPersist = "60";
        forwardAgent = true;
        hashKnownHosts = true;
        serverAliveInterval = 60;
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/id_github")
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/id_github")
        ];
      };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "screen-256color";
    prefix = "C-x";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      # Unbind default keys
      unbind C-b
      unbind '"'
      unbind %

      # Split panes, vertical or horizontal
      bind-key x split-window -v
      bind-key v split-window -h

      # Move around panes with vim-like bindings (h,j,k,l)
      bind-key -n M-k select-pane -U
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-l select-pane -R

      # Smart pane switching with awareness of Vim splits.
      # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };

  gpg = {
    enable = true;
    settings = {
      default-key = masterKey;
      auto-key-locate = "keyserver";
      keyserver = "pgp.mit.edu";
      keyserver-options = "no-honor-keyserver-url include-revoked auto-key-retrieve";

      # Use AES256, 192, or 128 as cipher
      personal-cipher-preferences = "AES256 AES192 AES";
      # Use SHA512, 384, or 256 as digest
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      # Use ZLIB, BZIP2, ZIP, or no compression
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      # Default preferences for new keys
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      # SHA512 as digest to sign keys
      cert-digest-algo = "SHA512";
      # SHA512 as digest for symmetric ops
      s2k-digest-algo = "SHA512";
      # AES256 as cipher for symmetric ops
      s2k-cipher-algo = "AES256";
      # UTF-8 support for compatibility
      charset = "utf-8";
      # Show Unix timestamps
      fixed-list-mode = true;
      # No comments in signature
      no-comments = true;
      # No version in output
      no-emit-version = true;
      # Disable banner
      no-greeting = true;
      # Long hexidecimal key format
      keyid-format = "0xlong";
      # Display UID validity
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      # Display all keys and their fingerprints
      with-fingerprint = true;
      # Cross-certify subkeys are present and valid
      require-cross-certification = true;
      # Disable caching of passphrase for symmetrical ops
      no-symkey-cache = true;
      # Enable smartcard
      use-agent = true;
      # Disable recipient key ID in messages
      throw-keyids = true;
    };
    scdaemonSettings = {
      disable-ccid = true;
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      reader-port = ''"Yubico YubiKey OTP+FIDO+CCID"'';
    };
  };
}
