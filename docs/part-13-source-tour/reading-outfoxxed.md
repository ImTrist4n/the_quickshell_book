---
title: "Reading outfoxxed's Quickshell"
description: "Examining outfoxxed's own development shell and Quickshell internals"
---

<ChapterMeta reading-time="12 min" :difficulty="4" :prerequisites="['C++ basics', 'QML Extensions']" you-will-learn="How outfoxxed's personal shell uses Quickshell internals and C++ extensions" />

## Overview

Outfoxxed is the creator and primary maintainer of Quickshell. Their personal shell is the testbed for new features and a reference for best practices. Unlike Caelestia (which is a demo/showcase config), outfoxxed's personal shell is optimized for daily use by the developer.

## Architecture

```
outfoxxed-shell/
  shell.qml
  modules/            — C++ QML modules
    system-stats/     — Custom hardware monitoring plugin
    quick-widgets/    — Reusable widget library
  services/           — Singleton services
    secrets.qml       — Password/keyring integration
    vpn.qml           — VPN connection management
    containers.qml    — Docker/Podman container status
  experiments/        — Experimental features (may break)
    blur-test.qml
    shader-demo.qml
    vr-shell.qml      — Experimental VR desktop
```

## Key Features

### 1. C++ QML Extensions

Outfoxxed's shell uses custom C++ modules not available in standard Quickshell:

```cpp
// modules/system-stats/nvidia-stats.h
class NvidiaStats : public QObject {
  Q_OBJECT
  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
  Q_PROPERTY(double utilization READ utilization NOTIFY utilizationChanged)

public:
  double temperature() const { return m_temperature; }
  double utilization() const { return m_utilization; }

signals:
  void temperatureChanged();
  void utilizationChanged();

private:
  void queryNvidiaSMI();
  double m_temperature = 0;
  double m_utilization = 0;
};
```

Registered as a QML type:

```cpp
qmlRegisterType<NvidiaStats>("org.outfoxxed.hardware", 1, 0, "NvidiaStats");
```

Used in shell:

```qml
import org.outfoxxed.hardware 1.0

NvidiaStats {
  onTemperatureChanged: console.log("GPU temp:", temperature)
}
```

### 2. Experimental Features

Outfoxxed implements bleeding-edge features in the `experiments/` directory:

```qml
// experiments/shader-demo.qml — Custom OpenGL shader overlay
ShaderEffect {
  fragmentShader: "
    varying vec2 qt_TexCoord0;
    uniform float time;
    void main() {
      vec2 p = qt_TexCoord0;
      gl_FragColor = vec4(
        sin(p.x * 10.0 + time),
        cos(p.y * 10.0 + time * 0.5),
        sin((p.x + p.y) * 5.0 + time * 0.3),
        1.0
      );
    }
  "
  property real time: 0
  NumberAnimation on time { from: 0; to: 6.2832; duration: 5000; loops: Animation.Infinite }
}
```

### 3. Advanced Service Interaction

```qml
// services/vpn.qml — WireGuard management
QtObject {
  id: vpn

  property var connections: []
  property bool anyActive: false

  function listConnections() {
    Qt.process(["bash", "-c", "nmcli connection show --active | grep wireguard"])
      .onStdout.connect(function(data) {
        connections = data.trim().split("\n").filter(function(l) { return l })
        anyActive = connections.length > 0
      })
  }

  function toggle(name) {
    if (anyActive) {
      Qt.process(["nmcli", "connection", "down", name])
    } else {
      Qt.process(["nmcli", "connection", "up", name])
    }
    listConnections()
  }

  Timer { interval: 30000; running: true; repeat: true; onTriggered: vpn.listConnections() }
}
```

## Design Philosophy

Outfoxxed's shell demonstrates:

1. **Eat your own dogfood** — Quickshell features are tested in the author's daily driver
2. **C++ for performance** — CPU-intensive operations are delegated to C++ modules
3. **Experimentation** — New ideas are prototyped in `experiments/` before being promoted to core
4. **Minimal dependencies** — Shell works without external tools where possible

## Lessons for Your Shell

| Lesson | Implementation |
|--------|----------------|
| C++ for hot paths | Write QML extensions for monitoring, file I/O, network |
| Experiment directory | Keep a `experiments/` folder for prototypes |
| Early adoption | Track Quickshell `main` branch for new features |
| Performance testing | Profile C++ extensions vs equivalent QML |

## Exercises

<ExerciseBlock :difficulty="1">
Build a C++ QML extension that monitors CPU temperature. Read from `/sys/class/thermal/thermal_zone*/temp`. Register the type and display temperature in your shell's bar.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Study outfoxxed's commit history on the Quickshell repository. Identify 3 features that were first prototyped in their personal shell before being added to Quickshell core. Describe the migration path.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement the VR desktop experiment as a standalone project. Create a 3D window layout rendered in a WebGL canvas. The user navigates between windows using head movement or keyboard. Write a report on the feasibility of VR desktops with Quickshell.
</ExerciseBlock>

<Recap :points="['Outfoxxed\'s shell uses custom C++ QML extensions for hardware monitoring', 'Experimental features are tested in experiments/ before core inclusion', 'Advanced service management (VPN, containers, secrets)', 'C++ for performance-critical operations, QML for UI']" next-chapter="/appendix/migration-guide" />

<!--
Sources verified for this chapter:
- https://github.com/outfoxxed/quickshell — Quickshell source
- https://github.com/outfoxxed — outfoxxed's GitHub profile
- https://doc.qt.io/qt-6/qtqml-cppintegration-overview.html — QML C++ Integration
-->
