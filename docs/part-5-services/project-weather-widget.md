---
title: "Project: Build a Weather Widget"
description: "Build a complete weather widget using HTTP APIs, JSON parsing, and caching"
---

# Project: Build a Weather Widget

## The Problem

You have learned about processes, JSON parsing, HTTP requests, caching, and timers. Now it is time to combine them into a polished, production-ready component: a weather widget that fetches current conditions, displays them in a panel, and works offline.

A complete weather widget must:

- Fetch current temperature, condition, and icon from a weather API.
- Parse JSON responses safely with fallback defaults.
- Cache the last known data so it works offline.
- Update on a configurable interval (respecting rate limits).
- Display the data with appropriate icons and colors.
- Handle errors gracefully (network down, invalid API key, malformed response).

## The Naive Approach

A single-file widget with hardcoded intervals, no caching, and no error handling:

```qml
Text {
  property var data: ({})
  Timer {
    interval: 600000
    running: true
    repeat: true
    onTriggered: {
      var xhr = new XMLHttpRequest()
      xhr.open("GET", "https://api.weatherapi.com/v1/current.json?key=KEY&q=London")
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) data = JSON.parse(xhr.responseText)
      }
      xhr.send()
    }
  }
  // Crashes if JSON.parse fails or data is empty
}
```

This crashes on network errors, shows nothing while loading, and cannot serve stale data offline.

<MentalModel>

A weather widget is like a newspaper stand. The API is the printing press (expensive, limited runs). The cache is your stack of newspapers (instant access, possibly stale). The display is the front page (always visible, always formatted). When the press stops (offline), you still sell yesterday's papers.

</MentalModel>

## The Idea

Build a modular weather widget with three layers:

1. **Fetcher** — makes HTTP requests at configurable intervals, emits parsed data.
2. **Cache** — persists responses to disk via `TextFile`, serves stale data when offline.
3. **Display** — renders temperature, condition, and icon from the current data, with loading and error states.

## Let's Build It

<BuildIt>

```qml
// WeatherWidget.qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  // ── Configuration ──
  property string apiKey: ""
  property string location: "London"
  property int refreshInterval: 600000 // 10 minutes
  property string cacheFile: "~/.cache/quickshell/weather.json"

  // ── State ──
  property var rawData: ({})
  property bool loading: true
  property bool error: false
  property string errorMessage: ""

  // ── Parsed data ──
  property int temperature: parseData()?.current?.temp_c ?? 0
  property string condition: parseData()?.current?.condition?.text ?? "Unknown"
  property string iconUrl: parseData()?.current?.condition?.icon ?? ""
  property string locationName: parseData()?.location?.name ?? "Unknown"
  property string locCountry: parseData()?.location?.country ?? ""

  function parseData() {
    try {
      return rawData && typeof rawData === "object" ? rawData : null
    } catch (e) {
      return null
    }
  }

  // ── Cache ──
  TextFile {
    id: cacheFileReader
    path: root.cacheFile
    onContentChanged: {
      if (content.length > 0) {
        try {
          var cached = JSON.parse(content)
          if (cached && cached.data) {
            root.rawData = cached.data
            root.loading = false
          }
        } catch (e) {
          console.warn("Cache parse failed:", e)
        }
      }
    }
  }

  // ── Fetcher ──
  Process {
    id: fetcher
    property string url: ""

    command: ["sh", "-c", "curl -s '" + url + "'"]

    onStdout: (data) => {
      try {
        var parsed = JSON.parse(data)
        if (parsed.error) {
          root.error = true
          root.errorMessage = parsed.error.message ?? "API error"
          root.loading = false
          return
        }
        root.rawData = parsed
        root.error = false
        root.loading = false
        root.saveCache(parsed)
      } catch (e) {
        root.error = true
        root.errorMessage = "Failed to parse response"
        root.loading = false
      }
    }

    onFinished: (code) => {
      if (code !== 0 && root.loading) {
        root.error = true
        root.errorMessage = "Network error (code " + code + ")"
        root.loading = false
      }
    }
  }

  function saveCache(data) {
    var entry = JSON.stringify({ data: data, ts: Date.now() })
    var escaped = "'" + entry.replace(/'/g, "'\\''") + "'"
    var proc = processComponent.createObject(null, {
      command: ["sh", "-c", "echo " + escaped + " > " + root.cacheFile]
    })
  }

  function buildUrl() {
    return "https://api.weatherapi.com/v1/current.json?key=" +
           root.apiKey + "&q=" + encodeURIComponent(root.location)
  }

  function refresh() {
    root.loading = true
    root.error = false
    fetcher.url = buildUrl()
    fetcher.running = true
  }

  Component.onCompleted: refresh()

  Timer {
    interval: root.refreshInterval
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  // ── Display ──
  implicitWidth: displayRow.implicitWidth
  implicitHeight: displayRow.implicitHeight

  RowLayout {
    id: displayRow
    spacing: 6
    visible: !root.loading

    // Weather icon
    Text {
      text: conditionToIcon(root.condition)
      font.pixelSize: 22
      color: "#c0caf5"
    }

    ColumnLayout {
      spacing: 0
      Text {
        text: root.temperature + "°C"
        color: "#c0caf5"
        font.pixelSize: 16
        font.bold: true
      }
      Text {
        text: root.condition
        color: "#a9b1d6"
        font.pixelSize: 11
        visible: root.condition !== "Unknown"
      }
    }
  }

  // Loading indicator
  Text {
    anchors.centerIn: parent
    text: "⏳"
    font.pixelSize: 20
    visible: root.loading && !root.error
  }

  // Error indicator
  Text {
    text: "⚠"
    font.pixelSize: 20
    color: "#f7768e"
    visible: root.error
  }

  function conditionToIcon(cond) {
    var c = cond.toLowerCase()
    if (c.includes("sun") || c.includes("clear")) return "\u2600"
    if (c.includes("cloud")) return "\u2601"
    if (c.includes("rain") || c.includes("drizzle")) return "\u2614"
    if (c.includes("snow") || c.includes("sleet")) return "\u2744"
    if (c.includes("fog") || c.includes("mist") || c.includes("haze")) return "\u2601"
    if (c.includes("thunder") || c.includes("storm")) return "\u26A1"
    return "\u2601"
  }
}
```

</BuildIt>

## Let's Improve It

### Add Location Autodetection

Use a process call to determine the user's location via IP geolocation:

```qml
Process {
  id: geoFetcher
  command: ["sh", "-c", "curl -s 'https://ipapi.co/json/'"]
  onStdout: (data) => {
    try {
      var geo = JSON.parse(data)
      root.location = geo.city + "," + geo.country_code
      root.refresh()
    } catch (e) {
      console.warn("Geo detection failed, using default location")
    }
  }
}
```

### Add Forecast Data

Fetch and display a 3-day forecast from the API:

```qml
Process {
  id: forecastFetcher
  command: ["sh", "-c", "curl -s 'https://api.weatherapi.com/v1/forecast.json?key=" +
    root.apiKey + "&q=" + encodeURIComponent(root.location) + "&days=3'"]
  onStdout: (data) => {
    try {
      var parsed = JSON.parse(data)
      root.forecastData = parsed.forecast?.forecastday ?? []
    } catch (e) {
      console.warn("Forecast fetch failed")
    }
  }
}
```

### Keyboard-Accessible Refresh

Add a `MouseArea` and `Keys` handler so the widget can be refreshed manually:

```qml
MouseArea {
  anchors.fill: parent
  acceptedButtons: Qt.LeftButton
  onClicked: root.refresh()
  Keys.onSpacePressed: root.refresh()
}
```

<CommonMistake>

**Not validating API responses.** APIs can return `200 OK` with an error object inside. Always check for `response.error` field before parsing data.

**Over-fetching on visibility change.** Do not restart the refresh timer in `onVisibleChanged` unless the widget was hidden for longer than the refresh interval. Keep a `lastRefreshTimestamp` to decide.

**Ignoring unicode fallbacks.** Weather icon fonts are not universal. Use Nerd Font symbols for best results, but provide text fallbacks for systems without them. The condition text already serves as a fallback.

</CommonMistake>

## Under the Hood

The weather widget demonstrates a layered architecture pattern:

- **Data layer** (`Process`, `TextFile`) — raw HTTP and file I/O.
- **Parsing layer** (`JSON.parse`, `try/catch`) — transforms raw text to structured objects.
- **State layer** (`rawData`, `loading`, `error`) — tracks widget lifecycle.
- **Presentation layer** (bindings to temperature, condition, icons) — derived properties drive the UI.

This separation ensures each layer can be tested, replaced, or extended independently. For example, you could swap `Process`+`curl` for a native `HttpRequest` type without touching the display code.

<UnderTheHood>

The `TextFile` cache works because `TextFile` watches for file changes via `inotify`. When the fetch process writes the cache file, `TextFile` detects the change and emits `onContentChanged`, which updates the `rawData` property, which cascades through all dependent bindings. This reactive chain is the core pattern of Quickshell programming.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Last updated" timestamp display that shows when the data was last successfully fetched. Format it as a relative time ("2 minutes ago").
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Modify the widget to display a 3-day forecast in a `PopupWindow` when clicked. Each day should show the high/low temperature and weather icon.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a `WeatherService` singleton that multiple widgets can share. Use `QtObject` or a QML singleton to store the weather data, fetch logic, and cache. All panel widgets bind to the same service instance so only one HTTP request runs at a time.
</ExerciseBlock>

<Recap :points="['Combine Process, TextFile, Timer, and JSON.parse into a cohesive data pipeline', 'Cache API responses locally for offline resilience', 'Track loading and error states explicitly in the UI', 'Use a layered architecture: data → parse → state → display', 'Respect API rate limits with conservative refresh intervals']" next-chapter="/part-6-linux-integration/upower-and-power-profiles" />

<!-- Sources verified -->
