# Local Testing Guide

How to build and test a release package locally before merging to master.

## 1. Bump the version

Edit `metadata.json` and update `KPlugin.Version`:

```json
"Version": "1.2.0"
```

Update `CHANGELOG.md`: rename `[Unreleased]` to `[1.2.0] - YYYY-MM-DD`.

## 2. Build the package

```bash
./scripts/package-up.sh
```

This compiles translations (`translate.sh all`) then creates `../K-Ollama-<version>.plasmoid`
one directory above the project. Requires `gettext` tools (`sudo apt install gettext`).

## 3. Install locally

Use `--upgrade` to preserve your existing settings:

```bash
kpackagetool6 --type Plasma/Applet --upgrade ../K-Ollama-1.2.0.plasmoid
```

> **Note:** Using `--remove` + `--install` wipes saved configuration. If you do that,
> re-enable any non-default settings (e.g. Markdown rendering) before testing.

Restart Plasma to pick up the changes:

```bash
plasmashell --replace &
```

## 4. Release

Once happy with local testing, merge `develop` into `master` and push a version tag.
GitHub Actions will build and attach the `.plasmoid` to the release automatically.

```bash
git checkout master
git merge develop
git push origin master
git tag v1.2.0
git push origin v1.2.0
```
