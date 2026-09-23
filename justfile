@default:
    just --list

# Build and switch to new configuration.
[group('nix')]
@build-switch:
    nix run .#build-switch

# Build configuration.
[group('nix')]
@build:
    nix run .#build

# Rollback configuration.
[group('nix')]
@rollback:
    nix run .#rollback

# Format all Nix files.
[group('nix')]
@fmt:
    nix fmt
