export EDITOR=nvim
export PAGER=less
export MANPAGER='nvim +Man!'

nix() {
	if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
	fi
}

packages() {
	# bash-seafly-prompt (https://github.com/bluz71/bash-seafly-prompt)
	#
	# Install the package if it does not exist.
	if ! [[ -d ~/.bash-packages/bash-seafly-prompt ]]; then
		git clone --depth 1 https://github.com/bluz71/bash-seafly-prompt ~/.bash-packages/bash-seafly-prompt
	fi
	SEAFLY_SUCCESS_COLOR=$(echo -ne '\e[38;5;4m')
	SEAFLY_PROMPT_SYMBOL="❮b❯"
	seafly_pre_command_hook="seafly_pre_command"
	seafly_prompt_prefix_hook="seafly_prompt_prefix"
	# Custom colors for prompt prefix; for performance reasons calculate the
	# colors outside the 'seafly_prompt_prefix' function.
	. ~/.bash-packages/bash-seafly-prompt/command_prompt.bash
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
	if [[ -f Gemfile ]]; then
		echo "\e[38;5;1m◢"
	elif [[ -f package.json ]]; then
		echo "\e[38;5;79m⬢"
	elif [[ -f Cargo.toml ]]; then
		echo "\e[38;5;208m●"
	elif [[ -f pubspec.yaml ]]; then
		echo "\e[38;5;12m◀"
	fi
}

user_paths() {
	PATH=/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin
	PATH=~/binaries:~/scripts:~/.local/share/bin:$PATH
	MANPATH=/usr/local/man:/usr/local/share/man:/usr/man:/usr/share/man
}

nix
user_paths
packages
shell_config
