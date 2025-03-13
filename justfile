@default:
    just --list


# Build and switch to new configuration.
[group('nix')]
@build-switch:
    nix run .#build-switch
