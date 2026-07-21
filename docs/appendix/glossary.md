---
title: "Glossary"
description: "Definitions of key terms used throughout the book"
---

# Glossary

## A

**Anchor**
A property that attaches a `PanelWindow` to one or more edges of the screen. Anchors determine window placement and sizing. At least two opposite anchors are needed for a visible panel.

**Attached Property**
A QML mechanism that allows objects to access properties from a related type. For example, `Keys.onPressed` is an attached property from the `Keys` type.

## B

**Binding**
A QML expression that automatically updates a property when its dependencies change. Bindings are the core reactive mechanism in QML.

**BlueZ**
The Linux Bluetooth protocol stack. Exposes a D-Bus API for Bluetooth adapter and device management.

## C

**Component**
In QML, a reusable unit defined in a `.qml` file. In architecture, a visual element that renders UI and reads data from services.

**Compositor**
A Wayland compositor (e.g., Hyprland, Sway, KWin) that manages windows, input, and rendering on a Wayland display.

## D

**D-Bus**
An inter-process communication (IPC) system for the Linux desktop. Applications expose services, methods, and signals for other applications to call.

**Desktop Entry**
A `.desktop` file following the freedesktop specification that describes an application: its name, icon, executable path, and categories.

## E

**Exclusion Zone**
Screen space reserved by a `PanelWindow` so that maximized windows don't overlap it. Defined by the panel's geometry and anchor configuration.

**ext-session-lock**
A Wayland protocol for secure session locking. Used by lock screens to prevent input from reaching other windows.

## F

**FloatingWindow**
A Quickshell window type that creates a standard desktop window with decorations. Less control over positioning than PanelWindow.

## I

**Import**
A QML statement that makes types from another module or file available in the current document.

## L

**Layer Shell**
A Wayland protocol (`wlr-layer-shell`) for creating surfaces in desktop layers. Used by panels, popups, wallpapers, and lock screens.

**ListModel**
A QML type that stores a list of items with named properties, typically used as the model for a `ListView`.

**Loader**
A QML type that dynamically creates a component on demand. Useful for lazy-loading non-essential UI.

## M

**MPRIS**
Media Player Remote Interfacing Specification. A D-Bus interface for controlling media players (play, pause, next, previous, metadata).

## P

**PanelWindow**
A Quickshell window type for bars and panels. Attached to screen edges via anchors. The most commonly used window type.

**PopupWindow**
A Quickshell window type for popups and dialogs. Positioned relative to a parent window, with optional auto-dismiss on outside click.

**Property**
A named attribute of a QML object that can hold a value. Properties can be static or bound to expressions.

## Q

**QML**
Qt Modeling Language — a declarative language for designing user interfaces. Used by Quickshell for configuration.

**qs Import**
Quickshell's module import system (v0.2.0+). `import qs.widgets` imports all QML files in the `widgets/` directory.

**Quickshell**
A toolkit for building Wayland shell components using Qt Quick and QML.

## S

**Service**
A non-visual singleton that manages data, state, and side effects. Components read from services; services never render UI.

**ShellRoot**
The invisible root element of every Quickshell configuration. Manages screen enumeration and relaod lifecycle.

**Signal**
A QML mechanism for emitting events. Components connect to signals to react to changes.

**Singleton**
A class that can have at most one instance. In QML, declared with `pragma Singleton`. Used for shared state and services.

**Surface**
A Wayland drawing area. Each Quickshell window creates a `wl_surface` that the compositor renders.

## T

**Timer**
A QML type that fires an `onTriggered` signal at a specified interval. Used for periodic updates and delayed execution.

## U

**Utility**
A pure JavaScript function or constant defined in a `.js` file with `.pragma library`. Stateless, side-effect-free helpers.

## V

**Variants**
A Quickshell type that creates multiple instances of a delegate component — one per item in a model (typically one per screen).

## W

**Wayland**
A display server protocol for Linux. The modern replacement for X11. Quickshell requires a Wayland compositor.

**wlr-layer-shell**
A Wayland protocol for placing surfaces in z-ordered layers (background, bottom, top, overlay). Used by all Quickshell window types.

## X

**XDG**
Cross-Desktop Group (formerly freedesktop.org). Defines standards for the Linux desktop: base directory paths, autostart, notifications, and more.

<Recap :points="['PanelWindow, PopupWindow, and FloatingWindow are the three window types', 'Services are non-visual singletons; components render UI', 'Layer-shell protocol enables shell surface layering and anchoring', 'D-Bus connects your shell to the broader Linux desktop ecosystem']" next-chapter="/" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/qml-language — QML Language
- https://wayland.app/protocols/wlr-layer-shell-unstable-v1 — layer-shell
- https://specifications.freedesktop.org/ — freedesktop specs
-->
