---
title: "Weather"
description: "A weather widget showing current conditions and forecasts"
---

## The Problem

A weather widget fetches data from a remote API, parses the response, and displays current conditions (temperature, humidity, wind) and optionally a forecast. You need an API key, handle HTTP requests, parse JSON, and cache responses to avoid rate limits.

## The Naive Approach

Use a raw `XMLHttpRequest` from QML JavaScript to call OpenWeatherMap or WeatherAPI every few minutes. Parse the JSON response manually and bind it to UI elements. No caching, no error handling for network failures.

```qml
Timer {
  interval: 600000
  onTriggered: {
    var xhr = new XMLHttpRequest()
    xhr.open("GET", "https://api.openweathermap.org/data/2.5/weather?q=...")
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        var data = JSON.parse(xhr.responseText)
        // Update UI with temperature, etc.
      }
    }
    xhr.send()
  }
}
```

<MentalModel>

Weather data is like a newspaper's weather section. The information is printed once every few hours (the API call). You read it (parse JSON), and it stays valid until the next edition. Checking every minute is like running to the newsstand every 60 seconds — wasteful.

</MentalModel>

## The Idea

Use `XMLHttpRequest` from QML to fetch weather JSON, parse it, and display the results. Cache the response and only re-fetch when the cache is older than a threshold (10-30 minutes). Choose a free API like OpenWeatherMap or WeatherAPI.

## Let's Build It

A weather widget with current conditions using OpenWeatherMap:

<BuildIt>

```qml
import Quickshell
import QtQuick

Column {
  spacing: 2

  property string apiKey: "YOUR_API_KEY"
  property string city: "London"
  property var weatherData: ({})
  property var lastFetch: 0

  function fetchWeather() {
    var now = Date.now()
    if (now - lastFetch < 600000) return // 10 min cache
    lastFetch = now

    var xhr = new XMLHttpRequest()
    var url = "https://api.openweathermap.org/data/2.5/weather?q=" +
              city + "&appid=" + apiKey + "&units=metric"
    xhr.open("GET", url)
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          weatherData = JSON.parse(xhr.responseText)
        } else {
          print("Weather API error:", xhr.status, xhr.statusText)
        }
      }
    }
    xhr.send()
  }

  function weatherIcon(code) {
    if (code >= 200 && code < 300) return "⛈"
    if (code >= 300 && code < 400) return "🌦"
    if (code >= 500 && code < 600) return "🌧"
    if (code >= 600 && code < 700) return "❄"
    if (code >= 700 && code < 800) return "🌫"
    if (code === 800) return "☀"
    if (code > 800 && code < 900) return "☁"
    return "❓"
  }

  Timer {
    interval: 600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: fetchWeather()
  }

  Row {
    spacing: 6
    Text {
      text: weatherIcon(weatherData.weather ? weatherData.weather[0].id : 0)
      font.pixelSize: 22
    }
    Column {
      Text {
        text: weatherData.main ? Math.round(weatherData.main.temp) + "°C" : "--"
        font.pixelSize: 16
        color: "#cdd6f4"
      }
      Text {
        text: weatherData.weather ? weatherData.weather[0].description : ""
        font.pixelSize: 11
        color: "#585b70"
      }
    }
  }

  Text {
    text: {
      if (!weatherData.main) return ""
      return "H:" + Math.round(weatherData.main.temp_max) +
             "° L:" + Math.round(weatherData.main.temp_min) + "°"
    }
    font.pixelSize: 11
    color: "#585b70"
  }
}
```

</BuildIt>

## Let's Improve It

Add a 5-day forecast and location detection:

```qml
// 5-day forecast endpoint (separate call)
function fetchForecast() {
  var xhr = new XMLHttpRequest()
  var url = "https://api.openweathermap.org/data/2.5/forecast?q=" +
            city + "&appid=" + apiKey + "&units=metric&cnt=5"
  xhr.open("GET", url)
  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
      forecastData = JSON.parse(xhr.responseText)
    }
  }
  xhr.send()
}
```

<CommonMistake>

**Storing API keys in the source code.** Anyone who reads your config has your API key. Use an environment variable or a separate config file that's `.gitignore`d. Access it via a QML property from a `Quickshell.Config` value.

**Not caching aggressively.** OpenWeatherMap free tier allows 60 calls/minute, but calling on every shell reload is wasteful. Cache for 10-30 minutes. Also cache the parsed JSON so the widget shows immediately on reload even before the first fetch.

**Ignoring error states.** Network failures, invalid API keys, and city-not-found errors all return different status codes. Show a clear error indicator (faded icon or "—") instead of a blank widget.

</CommonMistake>

## Under the Hood

`XMLHttpRequest` in QML uses Qt's `QNetworkAccessManager` internally. It's asynchronous — the `onreadystatechange` callback fires on the main thread when the network response arrives. The JSON is parsed with JavaScript's `JSON.parse()`, which is fast for typical weather responses (a few KB).

<UnderTheHood>

The 10-minute cache is implemented with a simple time check. On shell reload, `lastFetch` is 0, so the first fetch runs immediately. Subsequent calls within the cache window are skipped. For persistence across restarts, save the weather data to a file using `writeFile()`.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Display the "feels like" temperature alongside the actual temperature. Add a wind speed indicator in km/h with a compass direction arrow.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Detect the user's location automatically using the `Geoclue` D-Bus service or by IP geolocation via a free API. Fall back to a configured default city.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a full weather popup with a 7-day forecast, hourly breakdown, and animated weather icons. Use `ListView` for the forecast rows and `Canvas` for temperature trend sparklines.
</ExerciseBlock>

<Recap :points="['XMLHttpRequest fetches weather JSON asynchronously', 'Cache responses for 10-30 minutes to avoid rate limits', 'Map weather condition codes to emoji icons', 'Handle errors gracefully — empty data is better than crash', 'Store API keys outside the config file']" next-chapter="/part-4-widgets/system-tray" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

