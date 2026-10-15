# Arguments for importing nixpkgs, shared by the system configurations (as
# the `nixpkgs` option) and standalone home-manager (as `import nixpkgs`),
# which has no system module to inherit them from.
{ pi }:

{
  config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  overlays =
    # Apply each overlay found in the /overlays directory
    let
      path = ../../overlays;
    in
    with builtins;
    map (n: import (path + ("/" + n))) (
      filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
        attrNames (readDir path)
      )
    )

    ++ [ pi.overlays.default ];
}
