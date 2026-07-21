---
title: "Packaging and Distribution"
description: "Package your Quickshell shell for distribution across Linux distributions"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Custom Modules', 'Shell Configuration']" you-will-learn="How to package and distribute your Quickshell configuration" />

## The Problem

You've built a beautiful shell. Your friends want it. But copying QML files doesn't include dependencies, fonts, icons, and configuration. A proper package ensures everything works out of the box.

## The Naive Approach

Zip up the config directory:

```bash
zip -r my-shell.zip ~/.config/quickshell/
```

The recipient has to manually install Quickshell, unzip to the right place, and figure out missing dependencies. This approach fails for non-technical users.

<MentalModel>

Think of packaging like meal kit delivery. Instead of sending the customer a grocery list and recipe (manual install), you send a box with pre-portioned ingredients and step-by-step pictures (package). The meal kit ensures consistent results.

</MentalModel>

## Package Structure

```
my-shell/
  quickshell/
    shell.qml
    config.json
    components/
    services/
    fonts/
  README.md
  LICENSE
  setup.sh
```

## Distribution Methods

### 1. Manual Installation Script

```bash
#!/bin/bash
# setup.sh
set -euo pipefail

# Check dependencies
command -v quickshell >/dev/null 2>&1 || { echo "Quickshell not installed. Install it first."; exit 1; }

# Create config directory
mkdir -p "$HOME/.config/quickshell"

# Copy configuration
cp -r quickshell/* "$HOME/.config/quickshell/"

# Install fonts
if [ -d "fonts" ]; then
  mkdir -p "$HOME/.local/share/fonts"
  cp fonts/* "$HOME/.local/share/fonts/"
  fc-cache -f
fi

# Copy desktop entry for display managers
mkdir -p "$HOME/.local/share/wayland-sessions"
cp quickshell.desktop "$HOME/.local/share/wayland-sessions/"

echo "Installation complete! Select 'MyShell' from your display manager."
```

### 2. Desktop Entry (Display Manager Integration)

```ini
# my-shell.desktop
[Desktop Entry]
Name=My Shell
Comment=A custom Quickshell desktop environment
Exec=quickshell -c ~/.config/quickshell/shell.qml
Type=Application
DesktopNames=quickshell
```

### 3. Arch Linux (AUR Package)

```bash
# PKGBUILD
pkgname=quickshell-my-shell
pkgver=1.0.0
pkgrel=1
arch=('any')
depends=('quickshell')
source=("https://github.com/user/my-shell/archive/v$pkgver.tar.gz")

package() {
  install -Dm644 quickshell/shell.qml "$pkgdir/usr/share/quickshell-shells/my-shell/shell.qml"
  install -Dm644 quickshell.desktop "$pkgdir/usr/share/wayland-sessions/my-shell.desktop"
  install -Dm644 README.md "$pkgdir/usr/share/doc/my-shell/README.md"
}
```

### 4. Nix Flake

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    quickshell.url = "github.com/outfoxxed/quickshell";
  };

  outputs = { self, nixpkgs, quickshell }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.my-shell = pkgs.stdenv.mkDerivation {
      name = "my-shell";
      src = ./.;
      installPhase = ''
        mkdir -p $out/share/quickshell-shells/my-shell
        cp -r quickshell/* $out/share/quickshell-shells/my-shell/
        mkdir -p $out/share/wayland-sessions
        cp my-shell.desktop $out/share/wayland-sessions/
      '';
    };
  };
}
```

## Dependency Management

Declare dependencies clearly:

```json
// metadata.json
{
  "name": "my-shell",
  "version": "1.0.0",
  "quickshell": ">=0.3.0",
  "dependencies": {
    "system": ["swww", "pipewire", "bluez"],
    "fonts": ["JetBrainsMono Nerd Font", "Font Awesome 6"],
    "qt": ["qt6-base", "qt6-wayland", "qt6-svg"]
  }
}
```

## Versioning

Follow semver for your shell:

- **Patch**: Bug fixes, minor styling changes
- **Minor**: New features, new panels, backward compatible
- **Major**: Breaking changes, config format changes

```bash
git tag v1.2.3
git push origin v1.2.3
```

## Exercises

<ExerciseBlock :difficulty="1">
Create a `setup.sh` script for your shell. Test it on a fresh install. Ensure all dependencies are checked before copying files.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Package your shell for the AUR. Create a `PKGBUILD` that installs to `/usr/share/quickshell-shells/`. Submit to the AUR.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a Nix flake for your shell. Ensure it builds with `nix build`. Add an overlay so users can install with `nix profile install`.
</ExerciseBlock>

<Recap :points="['Provide a setup.sh script that checks dependencies and copies files', 'Create a .desktop entry for display manager integration', 'Package for distribution-specific formats (AUR, Nix)', 'Declare dependencies in metadata.json with version constraints']" next-chapter="/part-12-advanced/testing-and-debugging" />

<!--
Sources verified for this chapter:
- https://wiki.archlinux.org/title/Arch_User_Repository — AUR
- https://nixos.wiki/wiki/Flakes — Nix Flakes
- https://specifications.freedesktop.org/desktop-entry-spec/latest/ — Desktop Entry Spec
-->
