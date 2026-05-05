set -o vi

# -- [ ALIASES ] ---------------------------------------------------------------
#
alias ls='ls --color=tty'
alias diff='difft'

# cdspell If set, minor errors in the spelling of a directory component in a cd
# command will be corrected.
shopt -s cdspell

# Bind ^l to `clear -x` to preserve buffer history (only in interactive shells)
[[ $- == *i* ]] && bind -x $'"\C-l":clear -x;'

# -- [ ENVIRONMENT VARIABLES ] -------------------------------------------------
#
export EDITOR=nvim
export LESS='-F -Q -M -R -X -i -g -s -x4'
export TERM='xterm-256color'
export LESS_TERMCAP_md=$'\e[00;34m'    # bold mode     - blue
export LESS_TERMCAP_us=$'\e[00;32m'    # underline     - green
export LESS_TERMCAP_so=$'\e[00;40;33m' # standout      - yellow on grey
export LESS_TERMCAP_me=$'\e[0m'        # end bold      - reset
export LESS_TERMCAP_ue=$'\e[0m'        # end underline - reset
export LESS_TERMCAP_se=$'\e[0m'        # end standout  - reset
export LESSHISTFILE=-

export PAGER=less
export MANPAGER='nvim +Man!'

# What platform are we running on.
# shellcheck disable=SC2155
export OS=$(uname)

# -- [ FUNCTIONS ] -------------------------------------------------------------
#

dev_config() {
	if [[ -x ~/.pnpm-packages/bin ]]; then
		PATH=$PATH:~/.pnpm-packages/bin
	fi
	if [[ -x ~/.npm-packages/bin ]]; then
		PATH=$PATH:~/.pnpm-packages/bin
	fi
	if [[ -x ~/.cargo/bin ]]; then
		PATH=$PATH:~/.cargo/bin
	fi
	if [[ -d ~/projects/go ]]; then
		export GOPATH=~/projects/go
		PATH=$PATH:$GOPATH/bin
	fi
}

gpg_config() {
	gpg_tty="$(tty)"
	gpg_auth_sock=$(gpgconf --list-dirs agent-ssh-socket)
	export GPG_TTY=$gpg_tty
	export SSH_AUTH_SOCK=$gpg_auth_sock
	gpgconf --launch gpg-agent
	gpg-connect-agent updatestartuptty /bye >/dev/null
}

nix_config() {
	if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
	fi

	# Make sure Nix is using the certificate bundle from the macos keychain.
	if [[ $OS == "Darwin" ]]; then
		export NIX_SSL_CERT_FILE=/etc/nix/macos-keychain.crt
	fi
}

# Nix shell shortcut
shell() {
	nix-shell '<nixpkgs>' -A "$1"
}

shell_config() {
	# Enable useful shell options:
	#  - autocd - change directory without no need to type 'cd' when changing directory
	#  - cdspell - automatically fix directory typos when changing directory
	#  - direxpand - automatically expand directory globs when completing
	#  - dirspell - automatically fix directory typos when completing
	#  - globstar - ** recursive glob
	#  - histappend - append to history, don't overwrite
	#  - histverify - expand, but don't automatically execute, history expansions
	#  - nocaseglob - case-insensitive globbing
	#  - no_empty_cmd_completion - do not TAB expand empty lines
	shopt -s autocd cdspell direxpand dirspell globstar histappend histverify \
		nocaseglob no_empty_cmd_completion

	# Prevent file overwrite on stdout redirection.
	# Use `>|` to force redirection to an existing file.
	set -o noclobber

	# Only logout if 'Control-d' is executed two consecutive times.
	export IGNOREEOF=1

	# Set preferred umask.
	umask 002
}

user_paths() {
	if [[ $OS == "Linux" ]]; then
		# Note, in Linux /bin and /sbin now are symlinks to /usr equivalents.
		export PATH=~/.local/bin:~/scripts:/usr/local/bin:/usr/bin:/usr/sbin:$PATH
	elif [[ $OS == "Darwin" ]]; then
		# However, in macOS /bin and /sbin are still distint.
		export PATH=~/.local/bin:~/scripts:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
	fi
	export MANPATH=/usr/local/man:/usr/local/share/man:/usr/man:/usr/share/man:$MANPATH
}

nix_config
user_paths
dev_config
gpg_config
shell_config
