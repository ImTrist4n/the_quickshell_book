---
title: "Workspace Indicator"
description: "Building a workspace indicator that shows virtual desktop state"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['PanelWindow', 'ListView']" you-will-build="A workspace indicator for your panel" />

## The Problem

Virtual desktops (workspaces) let users organize windows into groups. An indicator shows which workspace is active, which have windows, and allows switching with a click or scroll.

## The Naive Approach

Read from `wmctrl`:

```qml
Timer {
  interval: 500; running: true; repeat: true
  onTriggered: {
    var out = Qt.process(["wmctrl", "-d"]).stdout
    // parse workspace list
  }
}
```

`wmctrl` works on X11 but not Wayland. On Wayland, you must query the compositor directly.

<MentalModel>

Think of workspace indicators like elevator floor buttons. Each button represents a floor (workspace). Lit buttons show floors with activity (windows open). The button for the current floor is highlighted. Pressing any button sends the elevator there.

</MentalModel>

## The Idea

Query your compositor for workspace information. The approach depends on your compositor: Hyprland uses `hyprctl` (JSON), Sway uses `swaymsg -t get_workspaces` (JSON), KWin uses D-Bus. Parse the JSON and display workspaces as numbered buttons.

## Let's Build It

```qml
// WorkspaceService.qml
pragma Singleton
import Quickshell

QtObject {
  id: ws

  property var workspaces: []
  property int activeWorkspace: -1

  function switchTo(number) {
    Qt.process(["hyprctl", "dispatch", "workspace", String(number)])
  }

  function refresh() {
    Qt.process(["hyprctl", "workspaces", "-j"])
      .onStdout.connect(function(data) {
        try {
          var parsed = JSON.parse(data)
          workspaces = parsed.sort(function(a, b) { return a.id - b.id })
          var active = parsed.filter(function(w) { return w.active })
          if (active.length > 0) activeWorkspace = active[0].id
        } catch (e) {}
      })
  }

  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: ws.refresh()
  }
}
```

Workspace indicator widget:

```qml
// WorkspaceIndicator.qml
Item {
  property int maxWorkspaces: 10

  Row {
    spacing: 4
    Repeater {
      model: maxWorkspaces

      delegate: Rectangle {
        required property int index
        readonly property int wsNumber: index + 1
        readonly property var wsData: findWorkspace(wsNumber)

        function findWorkspace(num) {
          for (var i = 0; i < WorkspaceService.workspaces.length; i++) {
            if (WorkspaceService.workspaces[i].id === num)
              return WorkspaceService.workspaces[i]
          }
          return null
        }

        width: 28; height: 22; radius: 4
        color: wsNumber === WorkspaceService.activeWorkspace ? "#89b4fa" :
               wsData && wsData.windows > 0 ? "#585b70" : "#313244"

        Text {
          text: wsNumber
          anchors.centerIn: parent
          color: "white"
          font.pixelSize: 12
          font.bold: wsNumber === WorkspaceService.activeWorkspace
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: WorkspaceService.switchTo(wsNumber)
        }

        // Scroll to switch workspaces
        onWheel: function(wheel) {
          if (wheel.angleDelta.y > 0)
            WorkspaceService.switchTo(WorkspaceService.activeWorkspace - 1)
          else
            WorkspaceService.switchTo(WorkspaceService.activeWorkspace + 1)
        }
      }
    }
  }
}
```

<BuildIt>

The workspace indicator queries `hyprctl workspaces -j` for JSON data. Each workspace is rendered as a numbered button. The active workspace is brightly colored, workspaces with windows are dimly lit, and empty workspaces are dark. Click switches, scroll cycles.

</BuildIt>

## Compositor-Specific Commands

| Compositor | Command | Output |
|---|---|---|
| Hyprland | `hyprctl workspaces -j` | JSON array with id, name, windows, active |
| Sway | `swaymsg -t get_workspaces` | JSON array with num, name, focused |
| River | `riverctl get-outputs` | Custom protocol; use `status` command |
| KWin | D-Bus `org.kde.KWin.VirtualDesktopManager` | D-Bus object list |

## Let's Improve It

Show window icons/titles on hover:

```qml
ToolTip {
  visible: ma.containsMouse
  text: getWindowsOnWorkspace(wsNumber).join("\n")
}
```

<CommonMistake>

**Using fixed workspace counts.** Not every user uses 10 workspaces. Some use 4, some use dynamic workspaces. Support configuration: `config.maxWorkspaces` or detect from compositor output.

**Not handling compositor-specific formats.** The JSON output format differs between Hyprland, Sway, and others. Abstract compositor interaction into a compositor-agnostic service interface.

**Forgetting scroll wrapping.** When scrolling past the last workspace, some users expect wrapping to the first. Others expect no-op. Make it configurable.

</CommonMistake>

## Under the Hood

Workspace management on Wayland uses compositor-specific protocols. Hyprland uses its custom IPC (Unix socket at `/tmp/hypr/*/.socket.sock`). Sway uses `swaymsg` over the Wayland protocol itself (wlr-foreign-toplevel-management). The communications method differs, but all expose: workspace ID, name, active state, and window count.

## Exercises

<ExerciseBlock :difficulty="1">
Add workspace rename support. Double-click a workspace number to enter a custom name (e.g., "WWW", "Terminal"). Pass the name via `hyprctl dispatch renameworkspace`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement drag-and-drop window movement between workspaces. When a workspace indicator receives a dragged window (from a window switcher), move that window to the target workspace.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a workspace overview (like macOS Mission Control). A popup shows all workspaces as thumbnails. Each thumbnail contains miniature representations of open windows. Click a thumbnail to switch to that workspace.
</ExerciseBlock>

<Recap :points="['Query compositor via hyprctl/swaymsg for workspace JSON data', 'Show numbered buttons with active/highlighted/inactive state', 'Support click to switch and scroll to cycle', 'Abstract compositor-specific commands for portability']" next-chapter="/part-11-complete-shell/window-switcher" />

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC
- https://github.com/swaywm/sway/wiki — Sway wiki
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.process()
-->
