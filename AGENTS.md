# AGENTS.md

## Stack

- Nix flakes (`flake.nix`) — macOS and NixOS configurations from one repo
- nix-darwin 0.1 (macOS system config)
- home-manager (user environment, unstable branch)
- nix-homebrew + homebrew-bundle/core/cask (macOS casks)
- disko (NixOS disk layout)
- just (task runner, delegates to `nix run .#<app>`)

## Commands

- `just build` — build without activating
- `just build-switch` — build and activate (requires `sudo`)
- `just fmt` — format all Nix files (`nix fmt`)
- `just rollback` — interactive; NEVER run non-interactively
- `nix flake check` — evaluate all outputs
- `nix run nixpkgs#statix -- check .` — lint (matches CI)
- `nix flake update` — update the input lock

## Conventions

- Platform-specific config lives in `modules/darwin` or `modules/nixos`; anything shared goes in `modules/shared`
- `just` recipes are thin wrappers — real logic belongs in `apps/<system>/` scripts
- The username is the `user` let-binding in `flake.nix`; NEVER hardcode it elsewhere
- Prefer nixpkgs packages over homebrew casks; use casks only for GUI apps unavailable in nixpkgs
- Format Nix with `just fmt` — nixfmt is also nil's built-in formatter, so it matches editor format-on-save; NEVER use alejandra or nixpkgs-fmt
- When nix-darwin takes over a file an installer owned, diff the old file against the generated one and port every setting before switching

## Boundaries

- NEVER commit without explicit instruction
- NEVER force-push
- NEVER modify `.github/workflows/` without asking
- Ask before adding or removing flake inputs

## Gotchas

- `builtins.pathExists` on an absolute path is always `false` under flake (pure) eval — NEVER guard config on it; the branch silently becomes dead code
- nix-darwin's `nix.*` settings are silently ignored unless `nix.enable = true`
- ALWAYS pass `--hidden` to `rg` for repo-wide audits — `.github/` is skipped by default

## Self-Improvement Meta-Rules

Update this file when you discover conventions, receive corrections, or spot recurring patterns.

### When to add a rule

- Corrected for the same kind of mistake twice
- A convention exists in the repo but isn't documented here
- An ambiguity could lead a future session astray

### When NOT to add a rule

- Inferable from `flake.nix`, `justfile`, or the directory layout
- Already enforced by statix or CI
- Specific to a single task rather than a recurring pattern

### How to write rules

- One bullet per rule; no paragraphs
- NEVER/ALWAYS for hard constraints, "Prefer X over Y" for soft preferences
- Lead with the action; include the actual command or pattern
- Place in an existing section; create a new one only if none fits

### Anti-bloat

- Don't expand a one-line rule "for clarity"
- Describe capabilities, not file paths
- If this file exceeds 150 rules, propose removals before additions
