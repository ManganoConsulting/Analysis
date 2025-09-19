"""Smoke tests for the Qt layout."""
from __future__ import annotations

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PySide6.QtWidgets import QApplication

from app.ui.main_window import MainWindow
from app.ui.panels import SimViewer


def test_main_window_initialises() -> None:
    app = QApplication.instance() or QApplication([])
    window = MainWindow(mock_mode=True)
    window.show()
    app.processEvents()

    assert "Control Design" in window.windowTitle()
    assert window.findChild(SimViewer) is not None

    window.close()
    app.processEvents()
