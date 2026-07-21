---
title: "Processes & Shell Commands"
description: "Running shell commands and parsing their output in Quickshell"
---

<ChapterMeta reading-time="10 min" :difficulty="3" :prerequisites="['QML basics', 'Timers', 'Property bindings']" you-will-build="A system info widget that runs shell commands and displays live output" />

# Processes & Shell Commands

## The Problem

A desktop shell needs to interact with the system: check CPU usage, get the list of connected monitors, read network statistics, or launch applications. These tasks require running external processes. You cannot do them from pure QML.

## The Naive Approach

QML does not have a built-in way to run shell commands. Some developers attempt to use JavaScript's `XMLHttpRequest` with `file://` URLs or try to embed a C++ plugin. Neither works well for simple system calls.

```qml
// This does NOT run shell commands:
function getCpuUsage() {
  // XMLHttpRequest cannot execute binaries
  return "N/A"
}
```

<MentalModel>

A process is like a phone call. You dial a number (the command), speak (stdin), listen (stdout), and hang up when done. Quickshell's `Process` type manages this call for you — it handles the dialing, captures the response, and tells you when the call ends.

</MentalModel>

## The Idea

Quickshell provides the `Process` type from the `Quickshell` import. It runs a child process, captures stdout/stderr, and emits signals when data arrives or the process exits. You can run one-shot commands (`run("cmd")`) or spawn long-lived processes with streaming output.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
  height: 36
  anchors { top: true; left: true; right: true }
  exclusiveZone: height

  RowLayout {
    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }

    Text {
      id: cpuText
      text: "CPU: --"
      color: "#c0caf5"
      font.pixelSize: 13
    }

    Item { Layout.fillWidth: true }

    Text {
      id: memText
      text: "MEM: --"
      color: "#a9b1d6"
      font.pixelSize: 13
    }
  }

  Process {
    id: cpuProcess
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'"]
    onStdout: (data) => {
      cpuText.text = "CPU: " + data.trim() + "%"
    }
    onFinished: (exitCode) => {
      if (exitCode === 0 && running) running = true
    }
  }

  Process {
    id: memProcess
    command: ["sh", "-c", "free -m | awk '/Mem:/ {print $3 \"M / \" $2 \"M\"}'"]
    onStdout: (data) => {
      memText.text = "MEM: " + data.trim()
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
      cpuProcess.running = true
      memProcess.running = true
    }
  }
}
```

</BuildIt>

## Let's Improve It

Running a shell pipeline via `["sh", "-c", "..."]` every 5 seconds is wasteful. For frequently read values, use a persistent process with streaming output:

```qml
Process {
  id: topProcess
  command: ["sh", "-c", "top -bn1 -w512 | grep --line-buffered 'Cpu(s)'"]
  onStdout: (data) => {
    var match = data.match(/(\d+\.?\d*)\s*id/)
    if (match) {
      var idle = parseFloat(match[1])
      cpuUsage = Math.round(100 - idle)
    }
  }
}
```

For reliable parsing, pipe through a dedicated formatter:

```qml
Process {
  command: ["sh", "-c", "cat /proc/stat | head -1"]
  onStdout: (data) => {
    var parts = data.trim().split(/\s+/)
    total = parts.slice(1).reduce((a, b) => a + parseInt(b), 0)
    idle = parseInt(parts[4])
  }
}
```

<CommonMistake>

**Forgetting to set `readableChannel`.** By default, `Process` captures all channels. If your command produces binary output on stderr, set `readableChannel: ProcessChannel.Stdout` to avoid buffering noise.

**Not shell-escaping arguments.** Do not build command strings with string concatenation. Always pass arguments as separate array elements: `command: ["sh", "-c", "echo $HOME"]` instead of `command: "echo $HOME"`.

**Letting processes accumulate.** A `Process` with `running: true` that never exits will leak system resources. Always set a timeout or ensure the process terminates.

</CommonMistake>

## Under the Hood

`Process` wraps `QProcess` from Qt Core. When you set `running: true`, Quickshell calls `QProcess::start()` with the provided command and arguments. Output is read asynchronously via `readyReadStandardOutput` and emitted through the `onStdout` signal. The process runs in a separate OS process — if your shell crashes, child processes may become orphaned unless they have `prctl(PR_SET_PDEATHSIG)` or equivalent.

<UnderTheHood>

The `command` property accepts a list of strings. Quickshell converts this to `QProcess::setProgram()` and `QProcess::setArguments()`. For shell pipelines, you must explicitly invoke `sh -c "pipeline"` because `QProcess` does not parse shell syntax — it calls `execvp()` directly.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Create a `Process` that runs `uname -a` and displays the kernel version in a `Text` element.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a panel widget that shows the current Wi-Fi SSID by running `iwgetid -r` every 10 seconds.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Write a process-based disk usage indicator. Run `df -h /` in a `Timer` every 60 seconds, parse the output, and display used/total in a progress bar.
</ExerciseBlock>

<Recap :points="['Process runs external commands asynchronously', 'Use onStdout to capture output line-by-line', 'onFinished fires when the process exits with the exit code', 'Always pass command arguments as a string list, not concatenated strings', 'Use sh -c for shell pipelines', 'Set running: true to start, false to stop']" next-chapter="/part-5-services/parsing-json" />

<!-- Sources verified -->
