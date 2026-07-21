---
title: "Settings App"
description: "A settings application for configuring your desktop shell"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Configuration', 'PopupWindow']" you-will-build="A full settings panel with theme, widget, and behavior configuration" />

## The Problem

Users need a graphical way to configure their shell — change themes, enable/disable widgets, adjust panel height, rebind shortcuts. Editing QML files directly is intimidating for non-developers.

## The Naive Approach

Edit config files in a text editor:

```bash
vim ~/.config/quickshell/config.qml
```

Every typo breaks the shell. Users must know QML syntax just to change a color.

<MentalModel>

Think of the settings app as the control panel for your shell's engine. Instead of opening the hood and tweaking components directly, you have a dashboard with knobs and switches. Each knob has a label and range, so you can't accidentally break the engine.

</MentalModel>

## The Idea

Create a `FloatingWindow` or `PopupWindow` that reads/writes a JSON config file. Each setting is a form control: toggle switches for booleans, sliders for numbers, color pickers for colors, dropdowns for choices.

## Let's Build It

```qml
// SettingsApp.qml
FloatingWindow {
  id: settings
  title: "Shell Settings"
  width: 500; height: 600
  visible: false

  property var config: ({})
  property bool dirty: false

  function loadConfig() {
    var f = Qt.open(Quickshell.configPath("settings.json"), "r")
    if (f.valid) {
      try { config = JSON.parse(f.readAll()) } catch (e) { config = {} }
    }
  }

  function saveConfig() {
    Qt.writeFile(Quickshell.configPath("settings.json"), JSON.stringify(config, null, 2))
    dirty = false
  }

  function setSetting(key, value) {
    config[key] = value
    dirty = true
  }

  Component.onCompleted: loadConfig()

  Rectangle {
    anchors.fill: parent; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 16 }; spacing: 16

      Text { text: "Shell Settings"; font.pixelSize: 18; font.bold: true; color: "#cdd6f4" }

      // Theme selector
      SettingsSection {
        label: "Theme"
        Row {
          spacing: 8
          Repeater {
            model: ["catppuccin", "dracula", "nord"]
            delegate: Rectangle {
              required property string modelData
              width: 80; height: 28; radius: 4
              color: config["theme"] === modelData ? "#89b4fa" : "#313244"
              Text { anchors.centerIn: parent; text: modelData; color: "white"; font.pixelSize: 11 }
              MouseArea {
                anchors.fill: parent
                onClicked: setSetting("theme", modelData)
              }
            }
          }
        }
      }

      // Panel height
      SettingsSection {
        label: "Panel Height"
        Row {
          spacing: 12
          Slider {
            id: heightSlider
            width: 200
            from: 24; to: 64; stepSize: 2
            value: config["panelHeight"] || 36
            onValueChanged: config["panelHeight"] = value
          }
          Text {
            text: Math.round(heightSlider.value) + "px"
            color: "#a6adc8"; font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }

      // Panel position
      SettingsSection {
        label: "Panel Position"
        Row {
          spacing: 8
          Repeater {
            model: ["top", "bottom"]
            delegate: Rectangle {
              required property string modelData
              width: 80; height: 28; radius: 4
              color: config["panelPosition"] === modelData ? "#89b4fa" : "#313244"
              Text { anchors.centerIn: parent; text: modelData; color: "white"; font.pixelSize: 11 }
              MouseArea {
                anchors.fill: parent
                onClicked: setSetting("panelPosition", modelData)
              }
            }
          }
        }
      }

      // Widget toggles
      SettingsSection {
        label: "Widgets"
        Column {
          spacing: 4
          Repeater {
            model: ["Clock", "CPU", "RAM", "Battery", "Network", "Volume", "Weather", "System Tray"]
            delegate: Rectangle {
              required property string modelData
              width: 200; height: 28; radius: 4; color: config["show" + modelData.replace(" ", "")] !== false ? "#313244" : "#45475a"
              Row {
                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }; spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                  width: 14; height: 14; radius: 3
                  color: config["show" + modelData.replace(" ", "")] !== false ? "#a6e3a1" : "#f38ba8"
                  anchors.verticalCenter: parent.verticalCenter
                }
                Text { text: modelData; color: "#cdd6f4"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
              }
              MouseArea {
                anchors.fill: parent
                onClicked: {
                  var key = "show" + modelData.replace(" ", "")
                  config[key] = config[key] !== false ? false : true
                }
              }
            }
          }
        }
      }

      // Save / Cancel
      Row {
        width: parent.width; spacing: 8; anchors.horizontalCenter: parent.horizontalCenter
        Rectangle {
          width: 100; height: 36; radius: 6; color: "#89b4fa"
          Text { anchors.centerIn: parent; text: "Apply"; color: "white"; font.pixelSize: 13; font.bold: true }
          MouseArea { anchors.fill: parent; onClicked: { saveConfig(); Quickshell.reload() } }
        }
        Rectangle {
          width: 100; height: 36; radius: 6; color: "#313244"
          Text { anchors.centerIn: parent; text: "Cancel"; color: "#cdd6f4"; font.pixelSize: 13 }
          MouseArea { anchors.fill: parent; onClicked: settings.visible = false }
        }
      }
    }
  }
}
```

Helper component:

```qml
// SettingsSection.qml
Column {
  property string label: ""
  spacing: 8
  Text { text: label; font.pixelSize: 13; font.bold: true; color: "#cdd6f4" }
  // Children go here
}
```

<BuildIt>

The settings app reads/writes `settings.json`. It provides toggles for each widget, sliders for panel height, and theme selection. Changes are applied on "Apply" which triggers `Quickshell.reload()`.

</BuildIt>

## Let's Improve It

Add a color picker for accent colors and a keyboard shortcut rebinding interface:

```qml
Rectangle {
  width: 200; height: 28; radius: 4; color: config["accentColor"] || "#89b4fa"
  MouseArea {
    anchors.fill: parent
    onClicked: {
      // Open a color picker popup that updates config["accentColor"]
    }
  }
}
```

<CommonMistake>

**Not validating input.** A slider that allows negative panel height breaks the shell. Always use `from`, `to`, and `stepSize` on `Slider`. For text input, parse and validate before saving.

**Triggering reload unnecessarily.** Only call `Quickshell.reload()` when settings that require it change. Theme, panel height, and widget visibility need a reload. OSD timeout, for example, can be applied dynamically without a reload.

**Not providing defaults.** The settings app should fall back to hardcoded defaults for any key not present in `settings.json`. Use `config[key] || defaultConfig[key]` in your shell components.

</CommonMistake>

## Under the Hood

The settings app reads configuration from a JSON file. JSON was chosen over QML for user-facing config because it's easier to edit programmatically (no QML syntax) and safer (can't inject malicious code). The `Quickshell.reload()` method re-evaluates your `shell.qml`, preserving state paths but re-creating all QML objects.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "keyboard shortcuts" page to the settings app. List all registered shortcuts from `ShortcutManager`. Allow users to click a shortcut and press a new key combination. Save to `settings.json` as a `shortcuts` object.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a "theme preview" that shows a small mockup of the shell with the selected theme colors. Update the preview live as the user changes theme settings (without applying/reloading).
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a "profile" system — named sets of settings (e.g., "Work", "Gaming", "Presentation"). Users can save/load/delete profiles. Each profile is a separate JSON file in `profiles/` directory. Show a profile switcher in the top bar.
</ExerciseBlock>

<Recap :points="['Settings app provides graphical control over shell configuration', 'Read/write JSON settings file — easy to parse, safe to modify', 'Apply triggers Quickshell.reload() for reloadable settings', 'Use form controls: sliders, toggles, dropdowns, color pickers']" next-chapter="/part-11-complete-shell/wallpaper-manager" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.reload()
- https://quickshell.org/docs/v0.3.0/types/Quickshell/FloatingWindow — FloatingWindow
- https://doc.qt.io/qt-6/qml-qtquick-controls-slider.html — Slider
-->
