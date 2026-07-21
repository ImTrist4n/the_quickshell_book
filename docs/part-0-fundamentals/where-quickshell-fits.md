---
title: "Where Quickshell Fits"
description: "Where Quickshell sits in the Linux desktop stack"
---

<ChapterMeta reading-time="4 min" :difficulty="1" />

## The Problem

There are a lot of tools for building desktop components on Linux. Waybar, eww, ags, polybar, tint2, conky. Each occupies a slightly different niche. Where does Quickshell fit in that landscape, and why would you choose it over the alternatives?

## The Naive Approach

You could build your desktop shell with shell scripts and a bar program like Waybar. Configure a JSON or CSS file, run some scripts to update the bar content, and call it done. This works for simple setups — a clock, a workspace indicator, a few status icons. But the moment you want something custom — a launcher with fuzzy search, a notification center with history, a dock with drag-and-drop reordering — the configuration-based approach breaks down.

<MentalModel>

Waybar and similar tools are like an Ikea desk: you assemble pre-cut pieces in predefined arrangements. Quickshell is like a woodworking shop: you measure, cut, and join material however you want. The Ikea desk is faster to set up, but the woodworking shop lets you build anything.

</MentalModel>

## The Idea

Quickshell occupies a specific niche in the desktop component ecosystem:

**Below full desktop environments, above status bars.** GNOME and KDE are full DEs with their own shell implementations, settings daemons, and application suites. Waybar and polybar are single-purpose status bars configured through files. Quickshell is a *framework* — you write code to create exactly the shell you want, from a simple bar to a complete desktop experience.

**QML-native, not CSS-native.** Eww and ags use CSS-like styling with GTK or web technologies under the hood. Quickshell uses QML, which means you get Qt's rendering engine, property binding, animation framework, and C++ performance. If you've ever fought CSS to make a custom dropdown or smooth animation, you'll appreciate the difference.

**Wayland-native, not X11-with-extensions.** Some tools originated on X11 and have bolted on Wayland support. Quickshell was designed for Wayland from the ground up, using the Layer Shell protocol directly rather than through compatibility layers.

## Comparison

| | Waybar | Eww | AGS | Quickshell |
|---|---|---|---|---|
| Language | CSS/JSON | Yuck/SCSS | TypeScript | QML |
| Toolkit | GTK3 | GTK3 | GTK4 | Qt 6 |
| Wayland | wlr-layer-shell | wlr-layer-shell | wlr-layer-shell | wlr-layer-shell |
| Custom widgets | Limited | Moderate | Full | Full |
| Animations | None | Basic | Via code | Built-in framework |
| Hot reload | No | Yes | No | Yes |
| Performance | Good | Moderate | Moderate | Excellent |

## What Quickshell Does Well

- **Complex shell UIs** — panels with multiple sections, nested menus, popup windows
- **Data-driven widgets** — weather displays, system monitors, calendar widgets that fetch and update data
- **Animation-heavy interfaces** — smooth transitions, animated launchers, motion-rich control centers
- **Multi-window shells** — separate windows for bar, dock, lockscreen, OSD, each managed independently
- **Compositor integration** — deep Hyprland features like workspace tracking, scratchpads, IPC events

## What Quickshell Isn't

- **A compositor** — you still need Hyprland, Sway, or another compositor
- **A full desktop environment** — no file manager, settings panel, or terminal included
- **A beginner-friendly "install and forget" solution** — you're expected to write QML code
- **An application framework** — Qt already handles that; Quickshell handles shell-specific features

<Recap :points="['Quickshell is a framework, not a pre-built shell — you write QML to build your shell', 'It uses QML and Qt 6, not CSS-based styling like Waybar or Eww', 'It\'s Wayland-native and uses wlr-layer-shell directly', 'Best suited for complex, multi-window, animated shell UIs with deep compositor integration']" next-chapter="/part-0-fundamentals/why-qml-instead-of-css" />

<!--
Sources verified for this chapter:
- https://quickshell.org/about/ — Quickshell overview
- https://quickshell.org/docs/guide/introduction/ — introduction guide
-->
