---
title: "Custom Services"
description: "Building reusable, maintainable services with Quickshell's singleton pattern"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Singletons', 'State management', 'QtObject']" you-will-learn="Architecture patterns for creating production-quality services" />

## The Problem

Built-in services cover CPU, memory, and time, but every shell needs custom services: weather, wallpaper rotation, calendar events, package updates, cryptocurrency prices. Without a consistent pattern, each service ends up with different conventions for initialization, error handling, and data exposure.

## The Naive Approach

Inline everything in the component:

```qml
// WeatherWidget.qml — does everything itself
Timer {
  interval: 600000; running: true; repeat: true
  onTriggered: {
    Qt.process(["curl", "wttr.in/London?format=%t"])
      .onStdout.connect(function(data) {
        temperature = data.trim()
      })
  }
}
```

The weather fetching logic is trapped inside the widget. No other component (clock, dashboard, lock screen) can reuse it. Every widget that needs weather reinvents the wheel.

<MentalModel>

Think of a service as a newspaper printing press. It receives raw news (API data), processes it (parsing, transformation), and delivers finished newspapers (clean properties) to newsstands (components). The newsstand doesn't need to know how the press works — it just displays the paper.

</MentalModel>

## The Service Contract

Every service should follow this contract:

1. **Single responsibility** — one service does one thing (weather, not weather+calendar)
2. **No visual output** — services inherit `QtObject`, never `Rectangle` or `Text`
3. **Read-only properties** — components read, never write service properties
4. **Error signal** — emit `errorOccurred(string message)` for failures
5. **Ready signal** — emit `ready()` when initial data is loaded
6. **Refresh method** — provide `refresh()` for manual reload

## Let's Build It

```qml
// WeatherService.qml
pragma Singleton
import Quickshell

QtObject {
  id: service

  // Config
  property string city: "London"
  property string apiKey: ""  // For paid APIs

  // State
  property double temperature: 0
  property string condition: ""
  property string icon: ""
  property int humidity: 0
  property double windSpeed: 0
  property string lastUpdated: ""

  // Status
  property bool loading: false
  property string lastError: ""
  readonly property bool hasError: lastError !== ""
  readonly property bool isReady: lastUpdated !== ""

  // Signals
  signal ready()
  signal errorOccurred(string message)
  signal refreshed()

  // Refresh timer
  property Timer refreshTimer: Timer {
    interval: 600000  // 10 minutes
    running: true
    repeat: true
    onTriggered: service.refresh()
  }

  function refresh() {
    if (loading) return
    loading = true
    lastError = ""

    var url = "https://wttr.in/" + encodeURIComponent(city) + "?format=j1"
    Qt.process(["curl", "-s", url])
      .onStdout.connect(function(data) {
        try {
          var json = JSON.parse(data)
          var current = json.current_condition[0]
          temperature = parseFloat(current.temp_C)
          condition = current.weatherDesc[0].value
          icon = current.weatherIconUrl[0].value
          humidity = parseInt(current.humidity)
          windSpeed = parseFloat(current.windspeedKmph)
          lastUpdated = new Date().toISOString()
          loading = false
          if (!service.isReady) service.ready()
          service.refreshed()
        } catch (e) {
          loading = false
          lastError = "Failed to parse weather data"
          errorOccurred(lastError)
        }
      })
      .onStderr.connect(function(err) {
        loading = false
        lastError = "Network error: " + err
        errorOccurred(lastError)
      })
  }

  Component.onCompleted: refresh()
}
```

Components consume the service:

```qml
// WeatherWidget.qml
Item {
  Text { text: WeatherService.temperature.toFixed(0) + "°C"; font.pixelSize: 14; color: "#cdd6f4" }
  Text { text: WeatherService.condition; font.pixelSize: 11; color: "#a6adc8" }

  WeatherService.onErrorOccurred: function(msg) {
    errorLabel.text = msg
    errorLabel.visible = true
  }
}
```

<BuildIt>

The `WeatherService` singleton follows the full service contract: it exposes read-only properties (`temperature`, `condition`), loading/error state, `ready()`/`errorOccurred()` signals, and a configurable refresh interval. Components simply bind to the properties.

</BuildIt>

## Caching and Offline Support

```qml
function saveCache() {
  var cache = {
    temperature: temperature,
    condition: condition,
    lastUpdated: lastUpdated
  }
  Qt.writeFile(Quickshell.cachePath("weather.json"), JSON.stringify(cache))
}

function loadCache() {
  try {
    var file = Qt.open(Quickshell.cachePath("weather.json"), "r")
    if (file.valid) {
      var data = JSON.parse(file.readAll())
      temperature = data.temperature
      condition = data.condition
      lastUpdated = data.lastUpdated
    }
  } catch (e) {}
}
```

## Service Checklist

| Feature | Required? | Why |
|---|---|---|
| `readonly` properties | Yes | Prevents accidental mutation |
| `loading` state | Yes | Components show spinner |
| `lastError` + signal | Yes | Components show error |
| `refresh()` method | Yes | Manual reload on demand |
| Configurable interval | Recommended | Different data needs different rates |
| Cache | Recommended | Offline support |
| Rate limiting | Recommended | Don't hammer APIs |

## Exercises

<ExerciseBlock :difficulty="1">
Convert an existing inline polling pattern in your shell to a proper service. Extract the logic, add error handling, and replace the timer in the component with bindings to the service.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a `CryptoTickerService` that fetches prices from CoinGecko's free API (`api.coingecko.com/api/v3/simple/price`). Support multiple coins (bitcoin, ethereum, monero). Expose `prices` as a list and `getPrice(coin)` as a method.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a "Service Monitor" popup that lists all running services, their loading state, error count, last refresh time, and memory usage. Allow restarting individual services from the monitor.
</ExerciseBlock>

<Recap :points="['Services are non-visual singletons with readonly properties and signals', 'Follow the contract: single responsibility, error handling, ready signal, refresh method', 'Cache data for offline support and faster startup', 'Expose loading and error state so components can respond appropriately']" next-chapter="/part-12-advanced/dbus-integration" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Singleton — Singleton type
- https://doc.qt.io/qt-6/qml-qtqml-qtobject.html — QtObject
- https://www.wttr.in/ — wttr.in weather API
-->
