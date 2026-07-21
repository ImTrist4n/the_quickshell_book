---
title: "Wallpaper Manager"
description: "A wallpaper manager that sets and cycles desktop backgrounds"
---

<ChapterMeta reading-time="12 min" :difficulty="2" prerequisites="['Qt.process', 'Timer']" you-will-build="A wallpaper manager with slideshow and per-monitor support" />

## The Problem

A desktop without a wallpaper feels bare. Users want to set custom images, rotate through a collection, and have different wallpapers on different monitors.

## The Naive Approach

Use a static wallpaper set by the compositor:

```bash
hyprctl hyprpaper wallpaper ", ~/Pictures/wallpaper.png"
```

No slideshow, no per-monitor images, no dynamic switching based on time of day.

<MentalModel>

Think of the wallpaper manager as a gallery curator. The curator selects which artworks (images) hang on which walls (monitors) and changes them periodically (slideshow). Some galleries rotate every month, others change daily.

</MentalModel>

## The Idea

Create a `WallpaperService` that manages a wallpaper directory. A `Timer` cycles through images at a configurable interval. Per-monitor support allows different images on each screen.

## Let's Build It

```qml
// WallpaperService.qml
pragma Singleton
import Quickshell

QtObject {
  id: wm

  property string wallpaperDir: Quickshell.configPath("wallpapers")
  property var wallpapers: []
  property int currentIndex: 0
  property int slideshowInterval: 3600000  // 1 hour
  property bool slideshowEnabled: true

  function loadWallpapers() {
    Qt.process(["bash", "-c", "ls " + wallpaperDir + "/*.{jpg,png,jpeg,webp} 2>/dev/null"])
      .onStdout.connect(function(data) {
        wallpapers = data.trim().split("\n").filter(function(f) { return f })
        if (wallpapers.length > 0) setWallpaper(wallpapers[0])
      })
  }

  function setWallpaper(path) {
    // Set via compositor wallpaper utility
    if (Qt.process(["which", "swww"]).stdout) {
      Qt.process(["swww", "img", path, "--transition-type", "fade", "--transition-duration", "2"])
    } else if (Qt.process(["which", "hyprpaper"]).stdout) {
      Qt.process(["hyprctl", "hyprpaper", "wallpaper", ", " + path])
    } else {
      // Fallback: set root window background (X11)
      Qt.process(["feh", "--bg-scale", path])
    }
    currentWallpaper = path
  }

  function nextWallpaper() {
    if (wallpapers.length === 0) return
    currentIndex = (currentIndex + 1) % wallpapers.length
    setWallpaper(wallpapers[currentIndex])
  }

  function previousWallpaper() {
    if (wallpapers.length === 0) return
    currentIndex = (currentIndex - 1 + wallpapers.length) % wallpapers.length
    setWallpaper(wallpapers[currentIndex])
  }

  property string currentWallpaper: ""
  signal wallpaperChanged(string path)

  Timer {
    interval: wm.slideshowInterval
    running: wm.slideshowEnabled && wm.wallpapers.length > 1
    repeat: true
    onTriggered: wm.nextWallpaper()
  }

  Component.onCompleted: loadWallpapers()
}
```

Wallpaper picker popup:

```qml
// WallpaperPicker.qml
PopupWindow {
  width: 500; height: 400
  anchor.window: topBar

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      Text { text: "Wallpaper"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }

      GridView {
        width: parent.width; height: parent.height - 80
        model: WallpaperService.wallpapers
        cellWidth: 150; cellHeight: 100

        delegate: Rectangle {
          required property string modelData
          required property int index
          width: 140; height: 90; radius: 6; clip: true
          border.color: modelData === WallpaperService.currentWallpaper ? "#89b4fa" : "transparent"
          border.width: 2

          Image {
            source: "file://" + modelData
            anchors.fill: parent; fillMode: Image.PreserveAspectCrop
            asynchronous: true
          }

          Text {
            anchors { bottom: parent.bottom; left: parent.left; margins: 4 }
            text: modelData.split("/").pop()
            color: "white"; font.pixelSize: 9
            style: Text.Raised; styleColor: "black"
          }

          MouseArea {
            anchors.fill: parent
            onClicked: WallpaperService.setWallpaper(modelData)
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }

      // Slideshow controls
      Row {
        spacing: 8
        Text { text: "Slideshow"; color: "#cdd6f4"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
        Rectangle {
          width: 40; height: 22; radius: 11
          color: WallpaperService.slideshowEnabled ? "#a6e3a1" : "#45475a"
          MouseArea { anchors.fill: parent; onClicked: WallpaperService.slideshowEnabled = !WallpaperService.slideshowEnabled }
        }
        Text { text: "Every " + (WallpaperService.slideshowInterval / 3600000).toFixed(0) + "h"; color: "#6c7086"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
      }
    }
  }
}
```

<BuildIt>

The wallpaper manager scans a config directory for images. A slideshow timer cycles through them. The picker shows a `GridView` of wallpapers with thumbnails. Supports multiple compositor wallpaper tools (swww, hyprpaper, feh).

</BuildIt>

## Let's Improve It

Add per-monitor wallpapers:

```qml
property var monitorWallpapers: ({})

function setMonitorWallpaper(monitor, path) {
  monitorWallpapers[monitor] = path
  if (Qt.process(["which", "swww"]).stdout) {
    Qt.process(["swww", "img", path, "--outputs", monitor])
  }
}
```

<CommonMistake>

**Not handling compositor-specific wallpaper tools.** `hyprpaper` requires preloading images. `swww` uses animations. `feh` only works on X11. Detect available tools at startup and use the appropriate one.

**Loading large images synchronously.** Wallpaper images can be 4K+ resolution. Load thumbnails at reduced resolution for the picker. Use `asynchronous: true` on `Image` elements.

**Forgetting the fallback.** If no wallpaper tool is installed, the wallpaper manager should still work. Provide a solid color fallback that can be set via compositor color.

</CommonMistake>

## Under the Hood

Wallpaper setting on Wayland uses compositor-specific protocols. `swww` is a standalone wallpaper daemon that works with any compositor via its own protocol. `hyprpaper` is Hyprland-specific. Both create a surface at the `background` layer that renders the image. The wallpaper manager detects which tool is available and delegates to it.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "dynamic wallpaper" that changes based on time of day — a bright wallpaper during the day, a darker version at night. Store two versions and switch at sunrise/sunset times.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a "recent wallpapers" history. Track the last 10 wallpapers displayed. Add undo (Ctrl+Z) to go back to the previous wallpaper.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a wallpaper downloader integration. Connect to Unsplash or Wallhaven API. Show a "Discover" tab in the picker with trending wallpapers. Download selected wallpaper and apply it immediately.
</ExerciseBlock>

<Recap :points="['Wallpaper manager scans a directory and sets via compositor tools', 'Detect swww, hyprpaper, or feh at startup', 'GridView of thumbnails with selection highlight', 'Slideshow timer with configurable interval']" next-chapter="/part-11-complete-shell/dashboard" />

<!--
Sources verified for this chapter:
- https://github.com/Horus645/swww — swww wallpaper daemon
- https://wiki.hyprland.org/Useful-Utilities/Hyprpaper/ — hyprpaper
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.configPath()
-->
