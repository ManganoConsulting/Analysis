"""Application settings helpers."""

from __future__ import annotations

from typing import Any

from PySide6 import QtCore, QtGui, QtWidgets


ORGANISATION_NAME = "ManganoConsulting"
APPLICATION_NAME = "StabilityControl"


class SettingsManager:
    """Convenience wrapper around :class:`QSettings`."""

    def __init__(self) -> None:
        self._settings = QtCore.QSettings(ORGANISATION_NAME, APPLICATION_NAME)

    def value(self, key: str, default: Any | None = None) -> Any | None:
        """Read a value from the persistent store."""
        return self._settings.value(key, default)

    def set_value(self, key: str, value: Any) -> None:
        """Persist a value to the store."""
        self._settings.setValue(key, value)

    def save_geometry(self, window: QtWidgets.QWidget) -> None:
        """Persist the geometry for *window*."""
        self._settings.setValue("window/geometry", window.saveGeometry())

    def restore_geometry(self, window: QtWidgets.QWidget) -> None:
        """Restore the geometry for *window* if available."""
        geometry = self._settings.value("window/geometry")
        if geometry is not None:
            window.restoreGeometry(geometry)

    def save_state(self, window: QtWidgets.QMainWindow) -> None:
        """Persist the dock/toolbar state for a main window."""
        self._settings.setValue("window/state", window.saveState())

    def restore_state(self, window: QtWidgets.QMainWindow) -> None:
        """Restore the dock/toolbar state for a main window if available."""
        state = self._settings.value("window/state")
        if state is not None:
            window.restoreState(state)


def apply_high_dpi_settings() -> None:
    """Enable high DPI defaults for the QApplication."""
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_EnableHighDpiScaling, True)
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_UseHighDpiPixmaps, True)
    QtGui.QGuiApplication.setHighDpiScaleFactorRoundingPolicy(
        QtCore.Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
    )


__all__ = [
    "SettingsManager",
    "apply_high_dpi_settings",
]
