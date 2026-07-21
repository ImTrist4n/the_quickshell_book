---
title: "Who This Book Is For"
description: "Who this book is intended for — Linux users, QML beginners, and aspiring shell developers"
---

<ChapterMeta reading-time="2 min" :difficulty="1" />

## The Problem

Most documentation for desktop shell development assumes you already know the ecosystem. You find a neat config on GitHub, try to understand it, and hit a wall of unfamiliar syntax, unfamiliar concepts, and no explanation of *why* things are structured the way they are.

You're not alone — and this book is written for exactly that situation.

## You Are The Target Reader

This book is for three kinds of people:

**Linux users who want their desktop to feel personal.** You've used GNOME, KDE, or a tiling WM long enough to know what you like and what you'd change. You've customized config files but never built a UI from scratch. You want to create something that's unmistakably yours.

**Developers curious about QML and Qt.** You might be a web developer who's heard about QML's declarative syntax and wants to try something outside the browser. Or a systems programmer who wants to build a graphical interface without the overhead of Electron. You'll find QML's property binding and signal system familiar if you've used React or Vue, but with a much tighter integration to the native desktop.

**Aspiring desktop environment contributors.** You want to contribute to projects like KDE, COSMIC, or a community Quickshell config, but the codebase looks impenetrable. This book teaches the foundational patterns that those projects are built on — components, services, theming, state management — so you can read and modify real shell code with confidence.

## What This Book Is Not

This is not a Qt C++ reference. You won't learn how to subclass `QQuickItem` or write custom OpenGL renderers. Quickshell is designed to be used primarily through QML, and this book stays at that level.

This is not a comprehensive reference for every Quickshell type. The Appendix includes a "Every Quickshell Type" reference, but the main body of the book teaches concepts through building things, not through cataloging APIs.

This is not a CSS tutorial. QML and CSS look superficially similar (colon-separated property-value pairs) but they work fundamentally differently. We'll cover that difference in Part 0.

## Prerequisites

The hard prerequisites are minimal:

- A Linux machine running a Wayland compositor
- Ability to install software packages
- Basic terminal familiarity (navigation, editing files, running commands)

Everything else — QML, JavaScript, desktop shell concepts, Quickshell specifics — is taught in the book.

<Recap :points="['This book is for Linux users, developers curious about QML, and aspiring DE contributors', 'It is not a Qt C++ reference or a comprehensive API catalog', 'Only prerequisites are a Wayland Linux system, terminal familiarity, and willingness to learn']" next-chapter="/introduction/how-to-read-this-book" />

<!--
Sources verified for this chapter:
- No Quickshell-specific APIs referenced
-->
