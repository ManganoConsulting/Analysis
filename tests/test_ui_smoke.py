"""Qt smoke test for the ported UI."""

from __future__ import annotations

import os

import pytest
from PySide6 import QtWidgets

from pyapp.mainwindow import MainWindow


@pytest.fixture
def qt_app(qtbot):
    os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
    app = QtWidgets.QApplication.instance()
    if app is None:
        app = QtWidgets.QApplication([])
    return app


def test_main_window_launch(qtbot, qt_app):
    window = MainWindow()
    qtbot.addWidget(window)
    window.show()
    qtbot.waitExposed(window)
    assert window.isVisible()
    window.close()
