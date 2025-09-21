from __future__ import annotations

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from pyapp.main import configure_app, default_qml_path


def test_qml_boot(monkeypatch) -> None:
    monkeypatch.setenv("QT_QPA_PLATFORM", "offscreen")
    monkeypatch.setenv("ANALYSIS_USE_MOCK", "1")

    app = QGuiApplication.instance() or QGuiApplication([])
    engine = QQmlApplicationEngine()
    configure_app(engine)
    engine.load(QUrl.fromLocalFile(str(default_qml_path())))
    assert engine.rootObjects()
    engine.clearComponentCache()
    app.quit()
