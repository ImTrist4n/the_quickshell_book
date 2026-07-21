---
title: "Window System"
description: "How Quickshell creates, configures, and manages Wayland surfaces"
---

<ChapterMeta reading-time="14 min" :difficulty="4" :prerequisites="['Core types', 'Wayland protocols']" you-will-learn="The window creation and lifecycle in Quickshell" />

## The Wayland Surface Lifecycle

Every window in Quickshell is a Wayland surface with a layer-shell role. Understanding the lifecycle helps debug window issues (not appearing, wrong position, not receiving input).

## Lifecycle Diagram

```mermaid
graph TD
    QML[QML Component<br/>PanelWindow / PopupWindow]
    BASE[C++: WindowInterface<br/>abstract base]
    PROXY[C++: ProxyWindowBase<br/>reloadable proxy]
    CS[createSurface<br/>wl_surface]
    GLS[get_layer_surface<br/>requests layer role]
    WC[wl_surface.commit<br/>initial empty commit]
    CFG[configure event received<br/>compositor says OK]
    ACK[ack_configure(serial)<br/>+ attach buffer<br/>+ wl_surface.commit]
    VIS[Window Visible<br/>on screen]

    QML --> PROXY
    PROXY --> BASE
    BASE --> CS
    CS --> GLS
    GLS --> WC
    WC --> CFG
    CFG --> ACK
    ACK --> VIS
```

## PanelWindow in Detail

`PanelWindow` (C++ class: `PanelWindowInterface`) inherits from `WindowInterface` and adds anchor-based positioning and layer exclusion zones.

**C++ class:** `src/window/panelinterface.hpp`
**Concrete backend:** `src/window/panelinterface.cpp`

### Anchors Value Type

Anchors are defined as a Q_GADGET value type, not individual Q_PROPERTYs:

```cpp
// panelinterface.hpp — Anchors value type
class Anchors {
  Q_GADGET;
  Q_PROPERTY(bool left MEMBER mLeft);
  Q_PROPERTY(bool right MEMBER mRight);
  Q_PROPERTY(bool top MEMBER mTop);
  Q_PROPERTY(bool bottom MEMBER mBottom);
  QML_VALUE_TYPE(panelAnchors);
  QML_STRUCTURED_VALUE;

public:
  [[nodiscard]] Qt::Edge exclusionEdge() const noexcept;
  bool mLeft = false;
  bool mRight = false;
  bool mTop = false;
  bool mBottom = false;
};
```

When you set QML anchors:

```qml
anchors { top: true; left: true; right: true }
```

The Wayland backend translates these to layer-surface anchor flags in `src/window/panelinterface.cpp`:

```cpp
uint32_t zwlrAnchors = 0;
if (anchors.mTop) zwlrAnchors |= ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP;
if (anchors.mBottom) zwlrAnchors |= ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM;
if (anchors.mLeft) zwlrAnchors |= ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT;
if (anchors.mRight) zwlrAnchors |= ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT;
zwlr_layer_surface_v1_set_anchor(m_layerSurface, zwlrAnchors);
```

### Exclusion Modes

`PanelWindow` provides `exclusionMode` (an enum) in addition to `exclusiveZone`:

| Mode | Value | Behavior |
|---|---|---|
| `Normal` | 0 | Respect other layers' zones; set one via `exclusiveZone` |
| `Ignore` | 1 | Ignore other layers' zones; cannot set one |
| `Auto` | 2 | Derive zone from window dimensions + anchors (default) |

```qml
PanelWindow {
  anchors { top: true }
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 36  // Reserve 36px at top
}
```

This prevents maximized windows from covering your panel.

## PopupWindow

`PopupWindow` (C++ class: `ProxyPopupWindow`) creates a separate `wl_surface` that positions relative to a parent window.

**C++ class:** `src/window/popupwindow.hpp`

### Anchoring Logic

```qml
PopupWindow {
  anchor.window: toplevel
  anchor.rect.x: parentWindow.width / 2 - width / 2
  anchor.rect.y: parentWindow.height
  width: 500
  height: 500
}
```

Internally, `ProxyPopupWindow` tracks the parent window's position via the `anchor` property (using the `PopupAnchor` type from `src/core/popupanchor.hpp`) and updates its own position when the parent moves or resizes.

### Dismiss on Click Outside

PopupWindows can be set to dismiss when the user clicks outside their surface region by listening to Wayland seat pointer events.

## FloatingWindow

`FloatingWindow` (C++ class: `ProxyFloatingWindow`) creates a standard xdg-shell toplevel surface — a regular desktop window with title bar and decorations (managed by the compositor).

**C++ class:** `src/window/floatingwindow.hpp`

It is the simplest window type but provides the least control over positioning.

## ProxyWindowBase

All window types extend `ProxyWindowBase` (in `src/window/proxywindow.hpp`), which provides the reload mechanism. During a soft reload, Quickshell can transfer window state from the old to the new instance. During a hard reload, windows are fully recreated.

## Window Layering

The layer-shell protocol defines four layers (bottom to top):

| Layer | Z-order | Typical Use |
|---|---|---|
| Background | 0 | Wallpaper |
| Bottom | 1 | Dock-like panels |
| Top | 2 | Taskbars, panels |
| Overlay | 3 | Popups, lock screens, OSD |

Quickshell's `PanelWindow` defaults to the `Top` layer via `aboveWindows: true`. Set `aboveWindows: false` to place it in the Bottom layer.

## Exercises

<ExerciseBlock :difficulty="1">
Read `src/window/panelinterface.hpp` and find the `Anchors` value type. Add a `center` anchor mode — when set to true, the panel is centered on screen regardless of individual anchors.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Trace the PopupWindow dismiss path in `src/window/popupwindow.hpp` and its backend implementation. Find how `visible = false` is propagated and whether keyboard grabs are released. Add logging to verify the sequence.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a custom window type `CornerWindow` that snaps to screen corners (top-left, top-right, bottom-left, bottom-right) with configurable size. Follow the pattern of `PanelWindowInterface` and register it as a new QML type via `QML_NAMED_ELEMENT`.
</ExerciseBlock>

<Recap :points="['Each window type maps to a Wayland surface with a specific role', 'PanelWindow anchors are a Q_GADGET value type translated to layer-surface flags', 'Exclusion modes (Normal, Ignore, Auto) control screen space reservation', 'ProxyWindowBase provides reload support across all window types']" next-chapter="/part-13-source-tour/service-ecosystem" />

<!--
Sources verified for this chapter:
- https://github.com/quickshell-mirror/quickshell/tree/master/src/window — Window source
- https://wayland.app/protocols/wlr-layer-shell-unstable-v1 — wlr-layer-shell
- https://wayland.app/protocols/xdg-shell — xdg-shell protocol
-->
