[![Build](https://github.com/hardselius/nix-config/actions/workflows/build.yml/badge.svg)](https://github.com/hardselius/nix-config/actions/workflows/build.yml)

# nix-config

_This is my nix config. There are many like it, but this one is mine._

This config is based on https://github.com/dustinlyons/nixos-config. It
replaces my previous config https://github.com/hardselius/dotfiles which was
much more of a patchwork of stuff I'd found and figured out on my own.

## Nix implementation

This config targets [Lix](https://lix.systems), installed with the
[Lix installer](https://install.lix.systems):

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

`nix.package` is pinned to `pkgs.lix`, and nix-darwin owns `/etc/nix/nix.conf`
and the `nix-daemon` launchd job — so all Nix settings are declared in
`hosts/darwin/default.nix` rather than edited by hand. That includes
`ssl-cert-file`, which points at the installer-generated
`/etc/nix/macos-keychain.crt` so that TLS works through the corporate proxy.

It previously ran on [Determinate
Nix](https://github.com/DeterminateSystems/nix-installer), where
`determinate-nixd` owned Nix configuration and `nix.enable` had to be `false`.
If you're coming from that setup, see
[Migrating from Determinate Nix](#migrating-from-determinate-nix).

## Usage

```sh
just build         # build without activating
just build-switch  # build and activate (requires sudo)
just fmt           # format all Nix files
just rollback      # roll back to a previous generation
nix flake check    # evaluate all outputs
nix flake update   # update the input lock
```

## Gotchas

### Nix traffic is TLS-intercepted

A TLS-inspecting corporate proxy re-signs HTTPS, so the public Mozilla trust
store is not enough. `nix.settings.ssl-cert-file` points at
`/etc/nix/macos-keychain.crt` — the keychain export written by the Lix
installer, which carries the proxy's root CA.

Symptom when it goes missing:

```text
error: unable to download 'https://cache.nixos.org/...':
SSL certificate ... self-signed certificate in certificate chain (19)
```

Check what is actually signing the chain:

```sh
openssl s_client -connect cache.nixos.org:443 -servername cache.nixos.org \
  -showcerts </dev/null 2>/dev/null | grep -E '^ *[0-9]+ s:|^ *i:'
```

Caveats: the file is a static snapshot from install time and is never
refreshed (the proxy root expires 2026-11-28); it is not a superset of the
Mozilla bundle, lacking ~50 public roots; and it covers Nix only — `git` and
`curl` still use nix-darwin's bundle.

### nixbld GID mismatch on a fresh install

nix-darwin defaults `ids.gids.nixbld` to 30000 while `system.stateVersion < 5`,
but modern installers create the group with the Sequoia-era GID 350, so
activation aborts with `Build user group has mismatching GID`. Pinned to 350 in
`hosts/darwin/default.nix`. Check the real values with:

```sh
dscl . -read /Groups/nixbld PrimaryGroupID   # group
dscl . -read /Users/_nixbld1 UniqueID        # must be ids.uids.nixbld + 1
```

### nix-darwin silently ignores `nix.*` when `nix.enable = false`

That setting exists for installers that own Nix configuration themselves (as
Determinate did). With it set, the entire `nix.settings` tree evaluates but is
never written to `/etc/nix/nix.conf` — no error, no warning.

## Migrating from Determinate Nix

1. Uninstall Determinate Nix (`/nix/nix-installer uninstall`) and install Lix
   with the command above.
2. Because nix-darwin now manages `/etc/nix/nix.conf`, move the
   installer-generated file aside before the first switch — activation aborts
   rather than clobbering a file it doesn't recognise:

   ```sh
   sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
   ```

3. That file was also the only thing enabling `nix-command` and `flakes`, so
   the first build has to re-supply them — `just build-switch` will fail until
   the new generation is active:

   ```sh
   nix --extra-experimental-features 'nix-command flakes' run --impure .#build-switch
   ```

   Behind the TLS-inspecting proxy, append
   `-- --option ssl-cert-file /etc/nix/macos-keychain.crt` as well, since the
   old `ssl-cert-file` went away with the old `nix.conf`.
4. Clean up Determinate leftovers that nothing references any more, e.g.
   `/etc/nix/sentry-endpoint` and `/etc/nix/nix.custom.conf`.
