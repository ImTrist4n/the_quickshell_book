---
title: "Architecture Diagrams"
description: "Visual reference for Quickshell architecture and component relationships"
---

# Architecture Diagrams

This appendix provides visual diagrams of Quickshell's architecture, component relationships, and data flow patterns.

## High-Level Architecture

```mermaid
graph BT
    subgraph "User Shell (.qml)"
        TB[Top Bar]
        LN[Launcher]
        PP[Popups]
        PN[Panels]
    end
    subgraph "QML Engine (QtQuick)"
        QE[QML Runtime]
    end
    subgraph "C++ Backend (Quickshell)"
        HW[Hardware]
        AU[Audio]
        NW[Network]
        MP[MPRIS]
    end
    subgraph "Wayland Compositor"
        WC[Hyprland / Sway / River / KWin]
        LS[layer-shell]
        SC[screencopy]
        IM[input-method]
    end
    TB --> QE
    LN --> QE
    PP --> QE
    PN --> QE
    QE --> HW
    QE --> AU
    QE --> NW
    QE --> MP
    HW --> WC
    AU --> WC
    NW --> WC
    MP --> WC
    WC --> LS
    WC --> SC
    WC --> IM
```

## Service Architecture

```mermaid
graph TD
    subgraph "Service Singleton"
        PROPS[Public Properties<br/>- volume<br/>- muted<br/>- defaultSink]
        SIGS[Signal Definitions<br/>- volumeChanged<br/>- muteToggled<br/>- sinkChanged]
        STATE[Internal State Management]
        DBUS[DBus IPC]
        PROC[Process]
        FW[File Watch]
        EXT[External Backend<br/>PipeWire / BlueZ<br/>NetworkManager / MPRIS]
    end
    PROPS --> STATE
    SIGS --> STATE
    STATE --> DBUS
    STATE --> PROC
    STATE --> FW
    DBUS --> EXT
    PROC --> EXT
    FW --> EXT
```

## Data Flow: UI Component

```mermaid
sequenceDiagram
    participant U as User Action (click/tap)
    participant H as Handler
    participant UI as UI Component (Text, Rectangle)
    participant S as Service Method
    participant E as External Backend

    U->>H: event
    H->>S: call
    S->>E: request
    E-->>S: response
    S-->>UI: signal (propertyChanged)
    Note over UI: Property Binding triggers re-render
```

## State Management Flow

```mermaid
sequenceDiagram
    participant U as User Input (volume slider)
    participant Q as QML Binding (onMoved)
    participant S as Service Update (setVolume(75))
    participant E as External Action (PipeWire call)
    participant UI as UI Updates (bar width anim)

    U->>Q: slide
    Q->>S: onMoved
    S->>E: PipeWire call
    E-->>S: success
    S-->>UI: signal volumeChanged(75)
```

## Process Lifecycle

```mermaid
graph LR
    subgraph "1. Startup"
        PA[Parse Args]
        IE[Initialize QML Engine]
        LS[Load shell.qml]
        CW[Create Windows]
    end
    subgraph "2. Running"
        EL[Event Loop (Qt)]
        SC[Service Callbacks]
        TT[Timer Triggers]
    end
    subgraph "3. Shutdown"
        SA[Save State]
        DS[Disconnect Services]
        DW[Destroy Windows]
        CM[Cleanup Memory]
    end
    PA --> IE --> LS --> CW
    CW --> EL
    EL --> SC
    EL --> TT
    TT --> SA
    SC --> DS
    DS --> DW --> CM
```

## Component Hierarchy (Example Shell)

```mermaid
graph TD
    SH[Shell]
    SH --> TB[TopBar]
    TB --> WS[Workspaces]
    WS --> WB[WorkspaceButton x5]
    TB --> CK[Clock]
    TB --> VL[Volume]
    VL --> VS[VolumeSlider Popup]
    TB --> ST[SystemTray]
    TB --> QS[QuickSettings Popup]
    QS --> WT[WiFiToggle]
    QS --> BT[BluetoothToggle]
    QS --> PP[PowerProfile]
    SH --> LN[Launcher PopupWindow]
    LN --> SB[SearchBar]
    LN --> RL[ResultsList]
    RL --> AD[AppDelegate x20]
    SH --> NC[NotificationCenter PopupWindow]
    NC --> NH[NotificationHeader]
    NC --> NL[NotificationList]
    NL --> NI[NotificationItem x10]
    SH --> WM[WallpaperManager Background]
    SH --> DB[Dashboard PopupWindow]
    DB --> SS[SystemStats]
    DB --> CL[Calendar]
    DB --> WE[Weather]
    DB --> QA[QuickActions]
```

## Network Architecture (DBus)

```mermaid
graph LR
    QML[QML Code]
    QS[Quickshell Service (C++)]
    EXT[External Service Daemon<br/>pipewire, etc]

    QML -->|DBus signal| QS
    QS -->|DBus call| EXT
    EXT -->|DBus response| QS
    QS -->|propertyChanged| QML
```

## Exercises

<ExerciseBlock :difficulty="1">
Draw an architecture diagram for your specific shell. Include all services, components, and popups. Identify the data flow for each user interaction (click, keypress, timer).
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a sequence diagram for the "user adjusts volume" flow. Show: MouseArea click → VolumeSlider → AudioService.setVolume() → PipeWire → volumeChanged → UI update.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Diagram your shell's startup sequence. Time each phase with console.log. Optimize the slowest phase by applying lazy loading or caching techniques from the optimization chapters.
</ExerciseBlock>

<Recap :points="['Quickshell has a 4-layer architecture: UI, QML Engine, C++ Services, Compositor', 'Services are singletons that bridge QML to external backends via DBus/process', 'Data flows bidirectionally: UI -> Service -> Backend -> signal -> UI', 'Component hierarchy starts from a single shell.qml entry point']" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/ — Quickshell documentation
- https://en.wikipedia.org/wiki/Sequence_diagram — Sequence diagrams
-->
