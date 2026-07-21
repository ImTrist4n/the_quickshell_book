---
title: "Other Community Shells"
description: "A survey of community-built Quickshell configurations to learn from"
---

<ChapterMeta reading-time="10 min" :difficulty="1" :prerequisites="['Shell Architecture']" you-will-learn="How different community shells are structured and what you can learn from each" />

## The Problem

You want to build a Quickshell configuration but don't know where to start. Other people's shells show different approaches to the same problems. Studying them is the fastest way to learn best practices.

## The Naive Approach

Start from scratch with no reference:

```qml
// shell.qml — blank file
```

Without reference implementations, you might make architectural decisions you later regret. Learning from others avoids common pitfalls.

<MentalModel>

Think of community shells as recipe books. You could invent cake from first principles, but looking at 10 cake recipes shows you common patterns (flour, sugar, eggs, butter) and variations (chocolate, vanilla, gluten-free). Same with shells.

</MentalModel>

## Notable Community Shells

### 1. Caelestia

The most popular Quickshell configuration, built by outfoxxed.

**Architecture**: Single-file shell with heavily modularized components. Uses a centralized `config.json` for all settings. Services are separate singleton files.

**Key Features**:
- Fluid animations with custom easing curves
- Integrated notification daemon
- Bottom bar with workspaces, clock, system tray
- Launcher with fuzzy search
- Music controls via MPRIS

**What to Learn**: How to structure a modular shell with clear separation between UI, services, and configuration.

### 2. Illogical-impulse

A minimal, keyboard-driven shell by ayfri.

**Architecture**: Fewer dependencies, simpler layout. Prioritizes keyboard navigation over mouse interaction.

**Key Features**:
- Minimal top bar with essential info
- Application launcher with text search
- No notification center (leverages system notification daemon)
- Configurable keybinds in `keys.json`

**What to Learn**: How to build a minimal shell that does one thing well. Sometimes less is more.

### 3. Other Shells on GitHub

Search for `quickshell config` on GitHub to find more:

- `sakura-shell` — Anime-themed shell with custom gradients
- `tide-shell` — macOS-inspired dock and menu bar
- `zen-shell` — Monochrome theme with focus on readability
- `breeze-quickshell` — KDE Breeze-inspired shell

## Common Patterns

| Pattern | Caelestia | Illogical-impulse | Recommendation |
|---------|-----------|-------------------|----------------|
| Config format | JSON | JSON | JSON (portable) |
| Panel location | Bottom | Top | User preference |
| Window manager | Hyprland | Hyprland, Sway | Hyprland (most supported) |
| Notification daemon | Built-in | External | Built-in for consistency |
| Bar style | Single bar | Single bar | Start with single bar |
| Service pattern | Singleton | Singleton | Singleton (proven) |

## Exercises

<ExerciseBlock :difficulty="1">
Clone Caelestia and Illogical-impulse. Compare their `services/` directories. List the services each implements. Identify which services your shell needs that neither provides.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Choose 3 community shells. Extract their color schemes. Create a `themes.json` that includes all 3 schemes. Add a theme switcher to your shell.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Contribute to a community shell. Find an open issue (bug, feature request) on GitHub. Submit a pull request. Document your contribution process.
</ExerciseBlock>

<Recap :points="['Caelestia: feature-rich reference shell with fluid animations and modular services', 'Illogical-impulse: minimal keyboard-driven shell with clean architecture', 'Study multiple shells to identify common patterns and make informed decisions', 'Contribute back to the community by filing issues or submitting PRs']" next-chapter="/part-13-source-tour/reading-caelestia" />

<!--
Sources verified for this chapter:
- https://github.com/outfoxxed/caelestia — Caelestia
- https://github.com/ayfri/illogical-impulse — Illogical-impulse
- https://github.com/outfoxxed/quickshell — Quickshell
-->
