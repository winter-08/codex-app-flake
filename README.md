# codex-app-flake

Linux-only Nix flake for the desktop app released from
[am-will/codex-app](https://github.com/am-will/codex-app).

The package wraps the upstream x86_64 Linux AppImage with Nix's AppImage
support.

## Usage

```sh
nix run github:winter-08/codex-app-flake
```

For local development:

```sh
nix flake check
nix run .#update-codex-app
```

## Updates

`.github/workflows/update-codex-app.yml` checks the latest upstream release on a
daily schedule, updates `pkgs/codex-app/package.nix`, runs `nix flake check` and
`nix build .#codex-app`, opens a PR, and enables squash auto-merge for that PR.

If branch protection requires CI to run on bot-authored PRs, set a repository
secret named `CODEX_APP_UPDATE_TOKEN` with permissions to create PRs and merge
them. Without that secret, the workflow falls back to `GITHUB_TOKEN`.
