---
title: "HTTP Requests & Caching"
description: "Making HTTP requests and caching responses in Quickshell"
---

# HTTP Requests & Caching

## The Problem

Desktop shells often display live data from the internet: weather forecasts, stock prices, calendar events, or news headlines. Making HTTP requests from QML is not straightforward — there is no built-in `fetch()` or `XMLHttpRequest` replacement that integrates cleanly with declarative property bindings.

## The Naive Approach

Using `XMLHttpRequest` in JavaScript:

```qml
function fetchWeather() {
  var xhr = new XMLHttpRequest()
  xhr.open("GET", "https://api.weather.example/current")
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status === 200) {
      weatherData = JSON.parse(xhr.responseText)
    }
  }
  xhr.send()
}
```

This works but is callback-heavy, does not integrate with QML property bindings, and offers no caching. Every timer tick spawns a new request regardless of whether the data changed.

<MentalModel>

An HTTP request is like ordering a pizza. You call the restaurant (send request), wait for delivery (network latency), receive the pizza (response), and eat it (parse). Caching is ordering two pizzas and putting one in the fridge — if you get hungry again soon, you skip the wait and reheat the stored one.

</MentalModel>

## The Idea

Quickshell provides the `HttpRequest` type for declarative HTTP requests. It manages the request lifecycle, exposes response properties, and supports caching via the `TextFile` type for offline persistence.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property var weatherData: ({})
  property int temperature: weatherData.temp_c ?? 0
  property string condition: weatherData.condition?.text ?? "Unknown"

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 4

    Text {
      text: root.temperature + "°C"
      color: "#c0caf5"
      font.pixelSize: 36
      font.bold: true
    }

    Text {
      text: root.condition
      color: "#a9b1d6"
      font.pixelSize: 14
    }
  }

  Process {
    id: weatherFetcher
    command: ["sh", "-c", "curl -s 'https://api.weatherapi.com/v1/current.json?key=YOUR_KEY&q=London'"]
    onStdout: (data) => {
      try {
        root.weatherData = JSON.parse(data)
      } catch (e) {
        console.warn("Weather fetch failed:", e)
      }
    }
  }

  Timer {
    interval: 600000
    running: true
    repeat: true
    onTriggered: weatherFetcher.running = true
  }
}
```

</BuildIt>

## Let's Improve It

Add a caching layer using `TextFile` to persist responses and serve stale data while offline:

```qml
Item {
  id: root

  property string cachePath: "~/.cache/quickshell/weather.json"
  property int cacheMaxAge: 600000 // 10 minutes
  property int lastFetchTime: 0

  TextFile {
    id: cacheFile
    path: root.cachePath
    onContentChanged: {
      if (content.length > 0) {
        var cached = JSON.parse(content)
        root.weatherData = cached.data
      }
    }
  }

  function shouldRefresh() {
    return Date.now() - root.lastFetchTime > root.cacheMaxAge
  }

  function saveToCache(data) {
    var cacheEntry = JSON.stringify({
      timestamp: Date.now(),
      data: data
    })
    // Write via process since TextFile is read-only
    var proc = processComponent.createObject(null, {
      command: ["sh", "-c", "echo " + escapeShellArg(cacheEntry) + " > " + root.cachePath]
    })
    proc.start()
  }

  function escapeShellArg(str) {
    return "'" + str.replace(/'/g, "'\\''") + "'"
  }

  Process {
    id: fetcher
    command: ["sh", "-c", "curl -s 'https://api.weatherapi.com/v1/current.json?key=YOUR_KEY&q=London'"]
    onStdout: (data) => {
      try {
        var parsed = JSON.parse(data)
        root.weatherData = parsed
        root.lastFetchTime = Date.now()
        root.saveToCache(parsed)
      } catch (e) {
        console.warn("Fetch failed, using cache")
      }
    }
  }

  Timer {
    interval: 600000
    running: true
    repeat: true
    onTriggered: {
      if (root.shouldRefresh()) fetcher.running = true
    }
  }
}
```

<CommonMistake>

**Not handling network errors.** `HttpRequest`-like patterns fail silently if the network is down. Always wrap parsing in `try/catch` and provide a fallback display or cached data.

**Hardcoding API keys.** Never embed API keys directly in QML files. Use environment variables, a config file outside version control, or a local proxy. Your config is likely in a git repository.

**Polling too frequently.** Respect API rate limits. Weather APIs typically allow 1 request per minute (free tier). Set your poll interval accordingly. Cache aggressively — weather data does not change every 10 seconds.

**Ignoring response size.** Large responses (e.g., forecast arrays with 14 days of hourly data) can slow JSON parsing. Fetch only the fields you need by using API query parameters like `&fields=temp_c,condition`.

</CommonMistake>

## Under the Hood

When you use `Process` with `curl`, Quickshell creates a child process, connects pipes to stdin/stdout/stderr, and reads the output into a buffer. The `onStdout` signal fires when the buffer receives data. For large responses, the data may arrive in multiple chunks — use a streaming accumulator if you need the full response before parsing.

<UnderTheHood>

`curl` is recommended over `wget` for API work because it supports HTTPS natively without additional dependencies, sends `User-Agent` headers correctly, and exits with meaningful error codes (`22` for HTTP error, `6` for DNS failure). Always check `exitCode` in `onFinished` to distinguish network errors from successful responses.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Fetch the current Bitcoin price from `https://api.coindesk.com/v1/bpi/currentprice.json` and display it in USD.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a caching HTTP utility component that takes a URL and refresh interval, fetches data on a timer, caches to disk via `TextFile`, and exposes a `data` property. Handle offline mode gracefully.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a news ticker widget that fetches headlines from a public RSS-to-JSON API (e.g., `https://api.rss2json.com/v1/api.json?rss_url=...`). Display headlines in a scrolling `Text` element that rotates every 10 seconds.
</ExerciseBlock>

<Recap :points="['Use Process with curl for HTTP requests from QML', 'Cache responses locally with TextFile for offline resilience', 'Respect API rate limits — poll sparingly and cache aggressively', 'Always handle network errors with try/catch and fallback data', 'Store API keys in environment variables or config files, not in QML']" next-chapter="/part-5-services/project-weather-widget" />

<!-- Sources verified -->
