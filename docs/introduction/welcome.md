---
title: "Welcome"
description: "Welcome to The Quickshell Book — your guide to building desktop shells with Quickshell and QML"
---

<ChapterMeta reading-time="3 min" :difficulty="1" />

## The Problem

You sit down at your Linux machine every day and interact with a desktop environment — GNOME, KDE, something else entirely. It mostly works, but it doesn't feel like *yours*. The panel is too tall. The app launcher doesn't have the features you want. The control center buries the toggles you use most. You could switch to a different distro, switch to a different DE, but none of them are exactly what you want either.

What if you could build your own desktop shell? Not just change the wallpaper or install a theme, but design every pixel of the bar, the dock, the lock screen, the notification center — everything the user sees and touches?

That's what this book teaches.

## What This Book Is

This is a project-based guide to building desktop shells with **Quickshell**, a modern framework that combines the power of Qt 6 with the simplicity of QML. Think of it as *The Rust Programming Language* but for desktop shell development — you'll start with the absolute basics, write real code in every chapter, and end with a complete, functional desktop shell running on Wayland.

## What You'll Build

Along the way you'll build:

- A top panel with clock, system tray, and widgets
- An application launcher
- A notification center
- A lock screen
- A control center with toggles
- A complete workspace switcher for Hyprland
- A full desktop shell combining everything above

Every piece of code you write is yours to keep, remix, and ship.

## What You Should Know Already

You should be comfortable using a terminal, editing text files, and installing packages on a Linux distribution. No prior experience with QML, Qt, or desktop shell development is required — Part 0 and Part I will teach you everything from scratch.

If you've written any kind of event-driven UI code before (even a web page with JavaScript event handlers), some concepts will feel familiar, but nothing is assumed.

## How The Book Is Structured

The book is divided into thirteen parts plus appendices:

- **Part 0** covers desktop fundamentals — the concepts you need to understand before writing any code
- **Part I** teaches QML from the ground up, with no Quickshell-specific content
- **Parts II–III** introduce Quickshell itself and the windowing system
- **Parts IV–V** cover built-in widgets and data services
- **Parts VI–VII** integrate with Linux services and the Hyprland compositor
- **Parts VIII–IX** discuss design systems and full applications
- **Parts X–XI** scale up to architecture patterns and a complete shell
- **Parts XII–XIII** cover advanced topics and real-world configs
- **Appendices** provide reference material

Each chapter teaches exactly one idea, uses only concepts from earlier chapters, and ends with a runnable example you can launch on your desktop.

## What You Need

To follow along you'll need:

- A Linux distribution running a Wayland compositor (Hyprland, Sway, River, or similar)
- Qt 6.7+ development libraries installed
- Quickshell installed (instructions in "Installing Qt & Quickshell")
- A text editor or IDE (VS Code, Neovim, or any editor you like)
- A willingness to experiment and break things

Let's get started.

<Recap :points="['This book teaches desktop shell development with Quickshell and QML', 'You start from zero knowledge and build up to a complete shell', 'Every chapter has a runnable example you can launch', 'You need a Wayland-capable Linux system with Qt and Quickshell installed']" next-chapter="/introduction/who-this-book-is-for" />

<!--
Sources verified for this chapter:
- No Quickshell-specific APIs referenced
-->
