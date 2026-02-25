# -- [ Aliases ] ---------------------------------------------------------------
#
alias ls='ls --color=tty'
alias diff='difft'

# cdspell If set, minor errors in the spelling of a directory component in a cd
# command will be corrected.
shopt -s cdspell

# Bind ^l to `clear -x` to preserve buffer history (only in interactive shells)
[[ $- == *i* ]] && bind -x $'"\C-l":clear -x;'

# -- [ Environment Variables ] -------------------------------------------------
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
# LS_COLORS (refer to: https://is.gd/6MzI27)
#   mi - completion options color
#   so - completion matching-prefix color
export LS_COLORS="no=00:fi=00:di=38;5;111:ln=38;5;117:pi=38;5;43:bd=38;5;212:\
cd=38;5;219:or=30;48;5;203:ow=38;5;75:so=38;5;252;48;5;0:su=38;5;168:\
ex=38;5;156:mi=38;5;115:\
*.avi=38;2;175;215;175:*.mpg=38;2;175;215;175:*.mp4=38;2;244;180;180:\
*.epub=38;2;200;200;246:*.dsf=38;2;255;175;215:*.conf=38;2;95;215;175:\
*.md=38;2;213;218;180:*README=38;2;213;218;180:\
*.pdf=38;2;218;218;218"
export PAGER=less
export MANPAGER='nvim +Man!'

# What platform are we running on.
# shellcheck disable=SC2155
export OS=$(uname)

# -- [ Functions ] -------------------------------------------------------------
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

nix() {
	if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
	fi

	# Make sure Nix is using the certificate bundle from the macos keychain.
	if [[ $OS == "Darwin" ]]; then
		export NIX_SSL_CERT_FILE=/etc/nix/macos-keychain.crt
	fi
}

history_truncate() {
	# Details: https://is.gd/HPAtE5
	echo "Before: $(du -shL "$HISTFILE")"
	# Remove previous truncation leftovers.
	command rm -f /tmp/history
	# First, remove duplicates.
	tac "$HISTFILE" | awk '!x[$0]++' | tac >/tmp/history
	# Second, remove certain basic commands.
	sed -e '/^cd/d' -e '/^cp/d' -e '/^dr/d' -e '/^fd/d' -e '/^ll/d' \
		-e '/^ls/d' -e '/^mc/d' \
		-e '/^mk/d' -e '/^mv/d' -e '/^open/d' \
		-e '/^qmv/d' -e '/^rg/d' -e '/^rm/d' -e '/^un/d' -e '/^v /d' \
		-e '/^you/d' -e '/^yt/d' -e '/^z/d' -i /tmp/history
	# Use 'cp' instead of 'mv' to deal with symlinked ~/.history. Use
	# 'command' to bypass aliases.
	command cp /tmp/history "$HISTFILE" && command rm /tmp/history
	echo "After: $(du -shL "$HISTFILE")"
	history -c && history -r
}

# shellcheck disable=SC2034,1090
prompt() {
	# bash-seafly-prompt (https://github.com/bluz71/bash-seafly-prompt)
	#
	# Install the package if it does not exist.
	if ! [[ -d ~/.bash-packages/bash-seafly-prompt ]]; then
		git clone --depth 1 https://github.com/bluz71/bash-seafly-prompt ~/.bash-packages/bash-seafly-prompt
	fi

	SEAFLY_SUCCESS_COLOR=$(echo -ne '\e[38;5;4m')
	SEAFLY_PROMPT_SYMBOL="❯"
	SEAFLY_GIT_STASH="≡"
	SEAFLY_GIT_DIRTY="✖"
	SEAFLY_GIT_STAGED="✔"
	SEAFLY_PREFIX_COLOR="$(tput setaf 13)"
	SEAFLY_SUCCESS_COLOR="$(tput setaf 2)"
	SEAFLY_ALERT_COLOR="$(tput setaf 9)"
	SEAFLY_HOST_COLOR="$(tput setaf 7)"
	SEAFLY_GIT_COLOR="$(tput setaf 242)"
	SEAFLY_PATH_COLOR="$(tput setaf 12)"
	seafly_pre_command_hook="seafly_pre_command"
	seafly_prompt_prefix_hook="seafly_prompt_prefix"
	# Custom colors for prompt prefix; for performance reasons calculate the
	# colors outside the 'seafly_prompt_prefix' function.
	. ~/.bash-packages/bash-seafly-prompt/command_prompt.bash
}

shell_config() {
	# First, make sure ~/.history has not been truncated.
	if [[ $(wc -l ~/.history | awk '{print $1}') -lt 1000 ]]; then
		echo 'Note: ~/.history appears to be have been truncated.'
	fi

	# History settings.
	HISTCONTROL=ignoreboth:erasedups # Ignore and erase duplicates
	HISTFILE=$HOME/.history          # Custom history file
	HISTFILESIZE=99999               # Max size of history file
	HISTIGNORE="?:??"                # Ignore one and two letter commands
	HISTSIZE=99999                   # Amount of history to preserve
	# Note, to immediately append to history file refer to the 'prompt'
	# function.

	# Disable /etc/bashrc_Apple_Terminal Bash sessions on Mac, it does not play
	# nice with normal bash history. Also, create a ~/.bash_sessions_disable
	# file to be double sure to disable Bash sessions.
	export SHELL_SESSION_HISTORY=0

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

seafly_pre_command() {
	if [[ -n $HOMEBREW_PREFIX ]]; then
		history -a
		__zoxide_hook
	else
		history -a
	fi
}

seafly_prompt_prefix() {
	if jobs -p | grep -q .; then
		echo "\e[38;5;9m✦"
	fi
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

nix
user_paths
prompt
dev_config
gpg_config
shell_config
