# The Quickshell Book

A comprehensive guide to building Wayland desktop shells with Quickshell and QML.

## Quick Start

```sh
git clone https://github.com/programmersd21/the_quickshell_book.git
cd the_quickshell_book
npm install
npm run dev
```

Open `http://localhost:5173` in your browser.

## Examples

Each chapter comes with runnable QML examples in the [`examples/`](./examples) directory:

| Directory | Topic | Run With |
|---|---|---|
| `001-hello-world/` | First QML app | `qml6 hello.qml` |
| `002-objects/` through `008-models-delegates/` | QML fundamentals | `qml6 *.qml` |
| `009-calculator/` | Project: Calculator | `qml6 calculator.qml` |
| `010-first-shell/` through `012-config-structure/` | Quickshell basics | `quickshell ./` |
| `020-panel-window/` through `026-transparency-blur/` | Window types | `quickshell ./` |
| `030-top-panel/` | Project: Top Panel | `quickshell ./` |
| `040-widgets/` | Reusable widget components | Import into shell |
| `090-app-launcher/` through `098-network-menu/` | App projects | `quickshell ./` |
| `111-top-bar/` through `113-launcher/` | Shell components | `quickshell ./` |
| `900-complete-shell/` | Complete desktop shell | `quickshell ./` |

## Prerequisites

- [Quickshell](https://quickshell.org/) (for most examples)
- Qt6 (for `qml6` standalone examples)
- Node.js >= 24.0.0 and npm (for the book site only)

## Development

```sh
npm install
npm run dev     # dev server at http://localhost:5173
npm run build   # static output to docs/.vitepress/dist
```

## Project Structure

```
docs/              # Book content (Markdown)
  .vitepress/      # VitePress configuration and custom theme
  public/          # Static assets (images, favicon)
examples/          # Runnable QML examples by chapter
scripts/           # Utility scripts
public/            # Source assets (favicon, banner)
```

## License

MIT
