---
title: "Distribution"
description: "Packaging and sharing your Quickshell configuration with others"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['Folder structure', 'Configuration']" you-will-learn="How to package your shell for distribution" />

## The Problem

You've built an amazing shell. Friends, colleagues, and the internet want to use it. But copying files manually breaks paths, misses dependencies, and leaves users without a way to update.

## The Naive Approach

Zip the directory and email it:

```bash
zip -r my-shell.zip ~/.config/quickshell/
```

The user unzips, overwrites their config, and gets errors because paths hardcoded to your home directory. Updates require another zip file.

<MentalModel>

Think of distribution like publishing a cookbook. You don't hand people loose recipe cards (raw files). You bind them into a book (package) with a table of contents (documentation), an index (README), and a binding that keeps pages in order (dependency management).

</MentalModel>

## The Approach

Create a Git repository with a proper structure, README, and installation script.

### Project Structure

```
quickshell-dotfiles/
  README.md
  LICENSE
  install.sh
  uninstall.sh
  src/
    shell.qml
    config.qml
    Theme.qml
    bar/
    popups/
    widgets/
    services/
    util/
    assets/
```

### Installation Script

```bash
#!/bin/bash
# install.sh

QUICKSHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
BACKUP_DIR="${QUICKSHELL_DIR}.backup.$(date +%Y%m%d-%H%M%S)"

echo "Installing Quickshell dotfiles..."

# Backup existing config
if [ -d "$QUICKSHELL_DIR" ]; then
  echo "Backing up existing config to $BACKUP_DIR"
  cp -r "$QUICKSHELL_DIR" "$BACKUP_DIR"
fi

# Install new config
mkdir -p "$QUICKSHELL_DIR"
cp -r src/* "$QUICKSHELL_DIR/"

# Check for required dependencies
echo "Checking dependencies..."
DEPS=("quickshell" "pactl" "hyprctl" "powerprofilesctl" "systemctl")
for dep in "${DEPS[@]}"; do
  if ! command -v "$dep" &> /dev/null; then
    echo "WARNING: $dep not found — some features may not work"
  fi
done

echo "Installation complete!"
echo "Launch with: quickshell"
echo ""
echo "To restore your previous config:"
echo "  rm -rf $QUICKSHELL_DIR && mv $BACKUP_DIR $QUICKSHELL_DIR"
```

### README Template

```markdown
# My Quickshell Configuration

A modern, customizable shell for Wayland compositors.

## Features

- Application launcher with fuzzy search
- Notification center with history
- Audio and Bluetooth controls
- Power profile switching
- Multi-monitor support
- Catppuccin, Dracula, and Nord themes

## Dependencies

- [Quickshell](https://quickshell.org) (v0.3.0+)
- PipeWire or PulseAudio (for audio)
- Hyprland, Sway, or wlroots-based compositor
- power-profiles-daemon (optional, for power management)

## Installation

```bash
git clone https://github.com/yourname/quickshell-dotfiles.git
cd quickshell-dotfiles
./install.sh
```

## Configuration

Edit `~/.config/quickshell/config.qml` to customize:
- Colors (switch theme)
- Panel height and position
- Enabled/disabled widgets
- Keyboard shortcuts

## Updating

```bash
cd quickshell-dotfiles
git pull
./install.sh
```

## Publishing

Share your configuration on:

- **GitHub/GitLab** — full repository with README and screenshots
- **r/unixporn** — Reddit community for Linux customization
- **Arch Linux AUR** — package as `quickshell-{name}-config` for Arch users
- **Nixpkgs** — contribute a Nix derivation

## Packaging for Package Managers

### AUR (Arch Linux)

`PKGBUILD`:
```bash
pkgname=quickshell-catppuccin-config
pkgver=1.0.0
pkgrel=1
arch=('any')
depends=('quickshell')
source=("$pkgname-$pkgver.tar.gz::https://github.com/yourname/quickshell-dotfiles/archive/v$pkgver.tar.gz")
package() {
  mkdir -p "$pkgdir/usr/share/quickshell/configs/$pkgname"
  cp -r src/* "$pkgdir/usr/share/quickshell/configs/$pkgname/"
}
```

## Exercises

<ExerciseBlock :difficulty="1">
Create a GitHub repository for your shell config. Add a README with screenshots, feature list, and installation instructions. Include a `screenshot.png` showing your shell in action.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Write an AUR PKGBUILD for your config. Test the install on a fresh Arch Linux VM or container. Fix any path or dependency issues discovered during testing.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a "config wizard" script (`quickshell-wizard`) that asks users questions (theme, panel position, enabled widgets) and generates a customized `config.qml`. Ship this as a separate tool alongside your config.
</ExerciseBlock>

<Recap :points="['Use Git for version control and collaboration', 'Provide an install script that backs up existing config', 'Include README with features, dependencies, and installation steps', 'Support package managers (AUR, Nix) for distribution']" next-chapter="/part-12-advanced/contributing" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/install-setup — Quickshell installation
- https://wiki.archlinux.org/title/Arch_package_guidelines — AUR packaging
- https://docs.github.com/en/repositories — GitHub repositories
-->
