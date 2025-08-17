{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "mch";
  xdg_configHome = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };

  polybar-user_modules = builtins.readFile (
    pkgs.replaceVars {
      src = ./config/polybar/user_modules.ini;
      packages = "${xdg_configHome}/polybar/bin/check-nixos-updates.sh";
      searchpkgs = "${xdg_configHome}/polybar/bin/search-nixos-updates.sh";
      launcher = "${xdg_configHome}/polybar/bin/launcher.sh";
      powermenu = "${xdg_configHome}/rofi/bin/powermenu.sh";
      calendar = "${xdg_configHome}/polybar/bin/popup-calendar.sh";
    }
  );

  polybar-config = pkgs.replaceVars {
    src = ./config/polybar/config.ini;
    font0 = "DejaVu Sans:size=12;3";
    font1 = "feather:size=12;3"; # from overlay
  };

  polybar-modules = builtins.readFile ./config/polybar/modules.ini;
  polybar-bars = builtins.readFile ./config/polybar/bars.ini;
  polybar-colors = builtins.readFile ./config/polybar/colors.ini;

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files // import ./files.nix { inherit user; };
    stateVersion = "21.05";
    shellAliases = {
      tf = "terraform";
      switch-yubikey = "gpg-connect-agent \"scd serialno\" \"learn --force\" /bye";

      # Get public ip directly from a DNS server instead of from some hip
      # whatsmyip HTTP service. https://unix.stackexchange.com/a/81699
      wanip = "dig @resolver4.opendns.com myip.opendns.com +short";
      wanip4 = "dig @resolver4.opendns.com myip.opendns.com +short -4";
      wanip6 = "dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6";
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };

  # Use a dark theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Screen lock
  services = {
    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
    };

    # Auto mount devices
    udiskie.enable = true;

    polybar = {
      enable = true;
      config = polybar-config;
      extraConfig = polybar-bars + polybar-colors + polybar-modules + polybar-user_modules;
      package = pkgs.polybarFull;
      script = "polybar main &";
    };

    dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          border = 0;
          height = 400;
          width = 320;
          offset = "33x65";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 0;
          sort = "no";
          idle_threshold = 120;
          font = "Noto Sans";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          transparency = 10;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "left";
          icon_theme = "Adwaita-dark";
          sticky_history = "yes";
          history_length = 20;
          history = "ctrl+grave";
          browser = "google-chrome-stable";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          max_icon_size = 64;
        };
      };
    };
  };

  programs = shared-programs // { };

}
