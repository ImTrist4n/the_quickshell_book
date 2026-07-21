import QtQml

// Shared Theme singleton for the complete desktop shell.
// Provides colors, spacing, and font definitions consumed by all widgets.
QtObject {
    // --- Catppuccin Mocha palette ---
    readonly property color base:   "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust:  "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay1: "#7f849c"
    readonly property color subtext0: "#a6adc8"
    readonly property color subtext1: "#bac2de"
    readonly property color text:    "#cdd6f4"
    readonly property color accent:  "#89b4fa"
    readonly property color green:   "#a6e3a1"
    readonly property color red:     "#f38ba8"
    readonly property color yellow:  "#f9e2af"
    readonly property color purple:  "#cba6f7"
    readonly property color teal:    "#94e2d5"
    readonly property color pink:    "#f5c2e7"

    // --- Dimensions ---
    readonly property int topBarHeight:    48
    readonly property int dockHeight:      64
    readonly property int iconSize:        48
    readonly property int spacingSmall:    4
    readonly property int spacingMedium:   8
    readonly property int spacingLarge:    12
    readonly property int radiusSmall:     4
    readonly property int radiusMedium:    8
    readonly property int radiusLarge:     12

    // --- Typography ---
    readonly property string fontFamily:    "sans-serif"
    readonly property int fontSizeSmall:    12
    readonly property int fontSizeMedium:   14
    readonly property int fontSizeLarge:    18
}
