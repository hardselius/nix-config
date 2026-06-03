# Agent Instructions

## Building

This is a Nix flake managing macOS (nix-darwin) and NixOS configurations.

### Common commands

- `just build` — build the configuration without activating it
- `just build-switch` — build and switch to the new generation (requires `sudo`)
- `just rollback` — interactively roll back to a previous generation

### Important notes

- All `just` recipes delegate to `nix run .#<app>`, which runs scripts in `apps/<system>/`.
- `build-switch` requires `sudo` for `darwin-rebuild switch`.
- `rollback` is interactive (prompts for a generation number) — do not run it non-interactively.
- The flake input lock can be updated with `nix flake update`.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues on `hardselius/nix-config`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (labels match role names). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
