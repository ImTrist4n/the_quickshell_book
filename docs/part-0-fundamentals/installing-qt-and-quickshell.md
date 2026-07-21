---
title: "Installing Qt & Quickshell"
description: "How to install Qt 6 and Quickshell on various Linux distributions"
---

<ChapterMeta reading-time="5 min" :difficulty="1" />

## The Problem

Before you can build anything, you need Quickshell installed. The installation steps vary by distribution, and there are some additional Qt packages you'll want for the best experience.

## Installing Quickshell

Quickshell v0.3.0 is packaged for most major distributions. Choose your distro below.

### Arch Linux

```bash
sudo pacman -S quickshell
```

For the latest development version:

```bash
yay -S quickshell-git
```

### Fedora

```bash
sudo dnf install quickshell
```

### Debian / Ubuntu

```bash
sudo apt install quickshell
```

Ubuntu users can also install from the DankLinux PPA for newer releases:

```bash
sudo add-apt-repository ppa:avengemedia/danklinux
sudo apt update
sudo apt install quickshell
```

### NixOS

```bash
nix shell nixpkgs#quickshell
```

Or add `quickshell` to your `environment.systemPackages`.

### Gentoo

```bash
emerge gui-apps/quickshell
```

### Guix

```bash
guix install quickshell
```

## Additional Qt Packages

Quickshell depends on Qt 6.6+. Most distro packages handle base dependencies automatically, but you'll want these optional packages for full functionality:

```bash
# Debian/Ubuntu
sudo apt install qml6-module-qt-labs-platform qml6-module-qt-labs-settings qml6-module-qt5compat-graphicaleffects qml6-module-qtquick-effects qt6-image-formats-plugins

# Arch
sudo pacman -S qt6-svg qt6-imageformats qt6-multimedia qt6-5compat

# Fedora
sudo dnf install qt6-qt5compat qt6-qtimageformats qt6-qtmultimedia qt6-qtsvg
```

## Verifying the Installation

Once installed, verify Quickshell is available:

```bash
quickshell --version
```

You should see output like `Quickshell 0.3.0`.

## Installing QML Language Support

For editor support, install the QML Language Server (`qmlls`). It comes bundled with Qt's development packages:

**Arch:** `sudo pacman -S qt6-tools`  
**Debian/Ubuntu:** `sudo apt install qt6-tools-dev`  
**Fedora:** `sudo dnf install qt6-qtdeclarative-devel`

To enable LSP for your Quickshell config, create an empty `.qmlls.ini` file next to your `shell.qml`. Quickshell will populate it with the correct configuration.

## Next Steps

With Quickshell installed, the next chapter covers setting up your development environment — editor, syntax highlighting, and tools for productive QML development.

<Recap :points="['Install Quickshell from your distro package manager', 'Optional Qt packages add SVG, image format, and visual effect support', 'Verify with quickshell --version', 'Install qmlls for LSP support in your editor', 'Create an empty .qmlls.ini file next to shell.qml to enable LSP']" next-chapter="/part-0-fundamentals/your-development-environment" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/guide/install-setup — Quickshell 0.3.0 installation instructions
-->
