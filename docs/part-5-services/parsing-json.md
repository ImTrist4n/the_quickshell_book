---
title: "Parsing JSON"
description: "Parsing JSON data from APIs and command output in QML"
---

# Parsing JSON

## The Problem

External data sources — REST APIs, system commands, configuration files — often return JSON. Your shell needs to parse this data and bind it to UI properties. QML does not natively understand JSON objects as declarative data sources.

## The Naive Approach

JavaScript's `JSON.parse()` works inside QML bindings, but it is verbose and error-prone when chained with property bindings:

```qml
property string rawJson: '{"temp": 22, "humidity": 60}'
property var data: JSON.parse(rawJson)
property int temperature: data ? data.temp : 0
```

This breaks if `rawJson` is empty, malformed, or updates asynchronously.

<MentalModel>

Parsing JSON is like unpacking a suitcase. The `JSON.parse()` function is your hands opening the latches. Once open, you can reach in and grab individual items (properties). But if the suitcase is locked (invalid JSON) or empty, your hands grab nothing — you need guard rails.

</MentalModel>

## The Idea

Use `JSON.parse()` wrapped in a safe utility function, then bind your properties to the resulting object. Combine `Process` or `TextFile` with JSON parsing to create a reactive data pipeline: fetch raw text → parse to object → bind UI properties.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property string rawApiData: "{}"

  // Safe JSON parser
  function parseJSON(text) {
    try {
      return JSON.parse(text)
    } catch (e) {
      console.warn("JSON parse error:", e)
      return ({})
    }
  }

  property var apiData: parseJSON(rawApiData)
  property int temperature: apiData.temp ?? 0
  property int humidity: apiData.humidity ?? 0

  ColumnLayout {
    anchors.centerIn: parent

    Text {
      text: "Temperature: " + root.temperature + "°C"
      color: "#c0caf5"
      font.pixelSize: 16
    }

    Text {
      text: "Humidity: " + root.humidity + "%"
      color: "#a9b1d6"
      font.pixelSize: 16
    }
  }

  Process {
    id: fetcher
    command: ["sh", "-c", "curl -s 'https://api.weather.example/current'"]
    onStdout: (data) => {
      root.rawApiData = data
    }
  }

  Timer {
    interval: 300000
    running: true
    repeat: true
    onTriggered: fetcher.running = true
  }
}
```

</BuildIt>

## Let's Improve It

Real-world JSON often has nested objects and arrays. Parse deeply and provide defaults at every level:

```qml
function parseNestedJSON(text) {
  try {
    return JSON.parse(text)
  } catch (e) {
    return {}
  }
}

property var weather: parseNestedJSON(rawJson)
property int currentTemp: weather.current?.temp_c ?? 0
property string condition: weather.current?.condition?.text ?? "Unknown"
property var forecast: weather.forecast?.forecastday ?? []
```

For array data, bind the parsed array to a model:

```qml
property var forecastDays: forecast

Repeater {
  model: forecastDays
  delegate: Text {
    text: modelData.date + ": " + modelData.day.avgtemp_c + "°C"
    color: "#c0caf5"
  }
}
```

<CommonMistake>

**Not handling malformed JSON.** An API might return `500 Internal Server Error` instead of JSON. Always wrap `JSON.parse()` in `try/catch` and provide fallback defaults.

**Binding to undefined properties.** Accessing `data.nested.field` when `nested` is undefined throws. Use optional chaining (`data.nested?.field`) or guard with defaults.

**Parsing on every property change.** If you parse JSON inside a property binding, it re-runs every time any dependency changes. Parse once in `onStdout` and store the result, then bind to the parsed object.

</CommonMistake>

## Under the Hood

`JSON.parse()` is the standard JavaScript JSON parser, available in QML's JavaScript engine (V4 or QuickJS). It uses a recursive descent parser internally, producing a JavaScript object tree. Property access on the resulting object is fast — it is just hash table lookup. For large JSON payloads (100KB+), parsing may take a few milliseconds; consider offloading to a `WorkerScript` if you notice frame drops.

<UnderTheHood>

QML's JavaScript engine does not support `JSON.parse()` revivers for type coercion. If your API returns numeric strings like `"22"` for temperature, use `parseFloat(data.temp)` or `Number(data.temp)` to convert. Boolean coercion works similarly with `Boolean(data.active)`.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Parse the output of `curl -s wttr.in?format=j1` and display the current temperature and weather condition text.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a widget that parses `/proc/cpuinfo` (read as text via `TextFile`), extracts the model name using a regex+JSON approach, and displays it.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a reusable `JSONSource` component that takes a `command` string, runs it as a process, parses the JSON output, and exposes a `data` property. Add `autoRefresh` interval support.
</ExerciseBlock>

<Recap :points="['Use JSON.parse() wrapped in try/catch for safe parsing', 'Optional chaining (?.) and nullish coalescing (??) prevent binding crashes', 'Parse once on data arrival, not in property bindings', 'Bind parsed arrays directly to Repeater/ListView models', 'Always provide fallback defaults for every accessed field']" next-chapter="/part-5-services/reading-and-watching-files" />

<!-- Sources verified -->
