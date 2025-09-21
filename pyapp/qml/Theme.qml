pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme

    property string palette: "light"

    property var lightColors: ({
        window: "#f5f6fa",
        text: "#1f2933",
        accent: "#2d7ff9",
        accentText: "#ffffff",
        border: "#d0d5dd",
        surface: "#ffffff",
        surfaceAlt: "#eef1f8",
        danger: "#d64550"
    })

    property var darkColors: ({
        window: "#121212",
        text: "#f0f3ff",
        accent: "#82b1ff",
        accentText: "#0b0d17",
        border: "#2c3a47",
        surface: "#1e1e1e",
        surfaceAlt: "#232d3b",
        danger: "#ff6b6b"
    })

    property real radiusSmall: 4
    property real radiusMedium: 8
    property real radiusLarge: 16

    property int spacingSmall: 6
    property int spacingMedium: 12
    property int spacingLarge: 24

    property string fontFamily: "Segoe UI"
    property int fontSizeSmall: 12
    property int fontSizeBody: 14
    property int fontSizeTitle: 20

    function colors() {
        return palette === "dark" ? darkColors : lightColors
    }

    function color(name) {
        return colors()[name] || "white"
    }
}
