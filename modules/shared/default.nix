{
  pi,
  ...
}:
{
  nixpkgs = import ./nixpkgs.nix { inherit pi; };
}
