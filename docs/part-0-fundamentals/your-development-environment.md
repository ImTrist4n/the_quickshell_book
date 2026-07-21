---
title: "Your Development Environment"
description: "Setting up a development environment for Quickshell and QML development"
---

<ChapterMeta reading-time="4 min" :difficulty="1" />

## The Problem

You have Quickshell installed. Now you need to write QML code. Unlike some languages where you need a full IDE, QML development can be done in any text editor — but some tools make it dramatically better.

## The Minimum Setup

At minimum, you need:

1. **A text editor** — VS Code, Neovim, Helix, Emacs, or any editor you're comfortable with
2. **A terminal** — for running Quickshell and viewing output
3. **Quickshell** — installed from the previous chapter

That's enough to write and run QML files. The feedback loop is:

```bash
# Edit your shell.qml
vim ~/.config/quickshell/my-shell/shell.qml

# Run it
quickshell ~/.config/quickshell/my-shell/
```

## With Hot Reload

Quickshell's hot reload feature means you can edit QML files and see changes instantly without restarting. When you save a file, Quickshell detects the change and reloads only the modified components. This shaves seconds off every iteration and makes tuning visuals feel immediate.

There's nothing to enable — it works out of the box. Just run `quickshell` on your config directory and edit files.

## Recommended Tools

### VS Code

Install the official [Qt QML Support](https://marketplace.visualstudio.com/items?itemName=TheQtCompany.qt-qml) extension for syntax highlighting and `qmlls` integration.

Enable the `qt-qml.qmlls.useQmlImportPathEnvVar` setting for correct module resolution.

### Neovim

Neovim has built-in QML syntax highlighting. For better highlighting, install the `qmljs` tree-sitter grammar:

```vim
:TSInstall qmljs
```

For LSP support, configure `qmlls`:

```lua
require("lspconfig").qmlls.setup {}
```

### Helix

Helix has built-in QML syntax highlighting and `qmlls` support. No configuration needed beyond ensuring `qmlls` is on your `PATH`.

### Emacs

Install `tree-sitter-qmljs` grammar and the `qml-ts-mode` Emacs mode. Use `lsp-mode` or `eglot` for LSP.

## The .qmlls.ini File

To enable QML language server features (completions, diagnostics), create an empty file named `.qmlls.ini` in the root of your config directory (next to `shell.qml`). Quickshell will automatically fill it with the correct settings on next launch.

Add `.qmlls.ini` to your `.gitignore` — its contents are machine-specific.

## Terminal Setup for Quickshell

When running Quickshell from a terminal, you'll see QML warnings and errors printed to stdout/stderr. Keep a terminal visible while developing:

```bash
quickshell ./my-config/
```

Errors from invalid QML syntax or missing imports will appear here as you work.

## Project Structure

As you follow along with this book, you'll create files in two locations:

- **`~/.config/quickshell/`** — where your actual shell configs live
- **`examples/`** — inside the book's repository, one folder per chapter

For now, create a sandbox directory to experiment with:

```bash
mkdir -p ~/quickshell-playground
cd ~/quickshell-playground
```

This is where you'll write the examples from Part I.

<Recap :points="['Any text editor works for QML development', 'Hot reload is built in — save files to see changes instantly', 'Install qmlls and configure your editor for syntax checking', 'Keep a terminal visible for runtime errors and warnings', 'Create a sandbox directory for Part I examples']" next-chapter="/part-0-fundamentals/first-launch" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/guide/install-setup — editor configuration and .qmlls.ini instructions
-->
