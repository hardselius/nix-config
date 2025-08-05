{ config, pkgs, ... }:

let user = "mch"; in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  nix = {
    package = pkgs.nix;
    # This will allow you to use nix-darwin with Determinate. Some nix-darwin
    # functionality that relies on managing the Nix installation, like the
    # `nix.*` options to adjust Nix settings or configure a Linux builder, will
    # be unavailable.
    enable = false;

    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    # gc = {
    #   automatic = true;
    #   interval = { Weekday = 0; Hour = 2; Minute = 0; };
    #   options = "--delete-older-than 30d";
    # };

    # extraOptions = ''
    #   experimental-features = nix-command flakes
    # '';
  };


  environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 25; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };

      dock = {
        autohide = true;
        launchanim = true;
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        showhidden = true;
        tilesize = 32;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}
