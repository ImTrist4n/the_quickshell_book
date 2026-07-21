---
title: "Testing"
description: "Automated testing strategies for your Quickshell configuration"
---

<ChapterMeta reading-time="12 min" :difficulty="3" :prerequisites="['JavaScript utilities', 'Custom services']" you-will-learn="How to write and run tests for your shell components" />

## The Problem

As your shell grows, changes to one component can break another. A refactored `config.qml` might return wrong colors. A changed `format.js` function might break clock display. Without tests, you discover these breaks by noticing a wrong color in the panel — hours after the change.

## The Naive Approach

Manual testing only:

```bash
quickshell --config ~/my-shell/
# Stare at the panel and see if things look right
```

Manual testing is slow, incomplete, and never repeated. You can't manually test every widget on every change.

<MentalModel>

Think of tests like a safety net for a trapeze artist. The net (tests) catches you when you fall (introduce a bug). Without a net, every swing (change) risks catastrophic failure. With a net, you can practice new moves (refactor) fearlessly.

</MentalModel>

## What to Test

| Layer | What to Test | How |
|---|---|---|
| Utilities | Pure functions with known inputs/outputs | Assertion-based unit tests |
| Services | Data transformation and caching | Mocked data sources |
| Components | Rendering with different property values | Visual regression or snapshot |
| Configuration | All properties have valid defaults | Startup-time validation |

## Testing Utilities (JavaScript)

JavaScript utilities are pure functions — they're the easiest to test:

```js
// tests/test-format.js
.pragma library

function run() {
  var failures = 0

  // Test bytesToHuman
  var result = Format.bytesToHuman(0)
  if (result !== "0.0 B") { console.log("FAIL: bytesToHuman(0) = " + result); failures++ }

  result = Format.bytesToHuman(1024)
  if (result !== "1.0 KB") { console.log("FAIL: bytesToHuman(1024) = " + result); failures++ }

  result = Format.bytesToHuman(1048576)
  if (result !== "1.0 MB") { console.log("FAIL: bytesToHuman(1048576) = " + result); failures++ }

  result = Format.bytesToHuman(1073741824)
  if (result !== "1.0 GB") { console.log("FAIL: bytesToHuman(1073741824) = " + result); failures++ }

  // Test clamp
  result = Format.clamp(5, 0, 10)
  if (result !== 5) { console.log("FAIL: clamp(5, 0, 10) = " + result); failures++ }

  result = Format.clamp(-1, 0, 10)
  if (result !== 0) { console.log("FAIL: clamp(-1, 0, 10) = " + result); failures++ }

  result = Format.clamp(15, 0, 10)
  if (result !== 10) { console.log("FAIL: clamp(15, 0, 10) = " + result); failures++ }

  if (failures === 0) {
    console.log("PASS: All format tests passed")
  } else {
    console.log("FAIL: " + failures + " test(s) failed")
    Qt.quit(1)
  }
}
```

Run the test in a headless QML environment:

```qml
// test-runner.qml
import Quickshell
import "tests/test-format.js" as TestFormat
import "tests/test-config.js" as TestConfig

QtObject {
  Component.onCompleted: {
    TestFormat.run()
    TestConfig.run()
    Qt.quit(0)
  }
}
```

```bash
quickshell --path test-runner.qml
```

## Testing Services

Test services by creating a test instance with mock data:

```qml
// tests/test-weather-service.qml
QtObject {
  Component.onCompleted: {
    var mockData = JSON.stringify({
      current_condition: [{
        temp_C: "22",
        weatherDesc: [{ value: "Sunny" }],
        humidity: "45",
        windspeedKmph: "15"
      }]
    })

    // Verify parsing logic
    var parsed = JSON.parse(mockData)
    var temp = parseFloat(parsed.current_condition[0].temp_C)
    var condition = parsed.current_condition[0].weatherDesc[0].value

    if (temp !== 22) console.log("FAIL: expected 22, got " + temp)
    if (condition !== "Sunny") console.log("FAIL: expected Sunny, got " + condition)
  }
}
```

## Testing Configuration

Validate your config at startup:

```qml
// tests/test-config.qml
.pragma library

function run() {
  // Each config property should have a valid type
  if (typeof Config.panelHeight !== "number") console.log("FAIL: panelHeight must be number")
  if (Config.panelHeight <= 0) console.log("FAIL: panelHeight must be positive")
  if (typeof Config.clockFormat !== "string") console.log("FAIL: clockFormat must be string")
  if (Config.clockFormat.length === 0) console.log("FAIL: clockFormat must not be empty")

  // Theme colors should be valid
  if (typeof Config.bgColor === "undefined") console.log("FAIL: bgColor is undefined")
  if (typeof Config.fgColor === "undefined") console.log("FAIL: fgColor is undefined")
}
```

## Test Automation

Run all tests with a script:

```bash
# test-all.sh
for test in tests/test-*.qml; do
  echo "Running $test..."
  quickshell --path "$test" && echo "PASS" || echo "FAIL"
done
```

## Exercises

<ExerciseBlock :difficulty="1">
Write unit tests for every function in your `util/` directory. Test edge cases: empty strings, negative numbers, very large numbers, null inputs.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a "config validator" that runs on startup and checks that all required config properties exist and have the correct types. If validation fails, show a popup with the specific error instead of crashing.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Set up a CI pipeline (GitHub Actions or GitLab CI) that runs your QML tests on every pull request. Use a headless Quickshell runner or `qmllint` for basic syntax checking.
</ExerciseBlock>

<Recap :points="['Test pure JavaScript utilities with assertion-based unit tests', 'Test services by providing mock data and verifying output', 'Validate configuration at startup for type safety', 'Automate tests with a test runner script and CI integration']" next-chapter="/part-12-advanced/debugging" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-testing.html — Qt Quick Test
- https://doc.qt.io/qt-6/qml-qtqml-qtobject.html — QtObject
- https://quickshell.org/docs/guide/qml-language — QML Language
-->
