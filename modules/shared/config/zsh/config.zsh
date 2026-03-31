# -- [ ZSH-SPECIFIC OPTIONS ] --------------------------------------------------
export KEYTIMEOUT=1  # Vi mode escape delay

# -- [ ALIASES ] ---------------------------------------------------------------
alias ls='ls --color=auto'
alias diff='difft'

# -- [ ENVIRONMENT VARIABLES ] -------------------------------------------------
export EDITOR=nvim
export ALTERNATE_EDITOR=vim
export PAGER=less
export CLICOLOR=1
export HISTIGNORE="pwd:ls:cd"

# -- [ FUNCTIONS ] -------------------------------------------------------------

dev_config() {
	# Add development tool paths (only if they exist)
	if [[ -x ~/.pnpm-packages/bin ]]; then
		PATH=$PATH:~/.pnpm-packages/bin
	fi
	if [[ -x ~/.npm-packages/bin ]]; then
		PATH=$PATH:~/.npm-packages/bin
	fi
	if [[ -x ~/.cargo/bin ]]; then
		PATH=$PATH:~/.cargo/bin
	fi

	# Additional user paths
	export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/share/bin:$PATH
}

gpg_config() {
	local gpg_tty="$(tty)"
	local gpg_auth_sock=$(gpgconf --list-dirs agent-ssh-socket)
	export GPG_TTY=$gpg_tty
	export SSH_AUTH_SOCK=$gpg_auth_sock
	gpgconf --launch gpg-agent
	gpg-connect-agent updatestartuptty /bye > /dev/null
}

nix_config() {
	if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
	fi

	# Make sure Nix is using the certificate bundle from the macos keychain
	if [[ $(uname) == "Darwin" ]]; then
		export NIX_SSL_CERT_FILE=/etc/nix/macos-keychain.crt
	fi
}

# Nix shell shortcut
shell() {
	nix-shell '<nixpkgs>' -A "$1"
}

# -- [ ZSH-SPECIFIC KEYBINDINGS ] ----------------------------------------------

# Toggle suspended jobs with CTRL+Z (preserve/clear input buffer)
resume() {
	fg
	zle push-input
	BUFFER=""
	zle accept-line
}
zle -N resume
bindkey "^Z" resume

# Vi mode search fix
vi-search-fix() {
	zle vi-cmd-mode
	zle .vi-history-search-backward
}
autoload vi-search-fix
zle -N vi-search-fix
bindkey -M viins '\e/' vi-search-fix

# Delete key behavior
bindkey "^?" backward-delete-char

# -- [ INITIALIZATION ] --------------------------------------------------------
nix_config
dev_config
gpg_config
