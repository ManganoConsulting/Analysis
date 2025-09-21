"""Application bootstrap helpers."""

from __future__ import annotations

import logging
import os
from pathlib import Path

from PySide6.QtCore import QCoreApplication
from PySide6.QtQml import QQmlApplicationEngine

LOG = logging.getLogger(__name__)


def _qml_directory() -> Path:
    return Path(__file__).resolve().parent / "qml"


def default_qml_path() -> Path:
    """Return the path to the ``Main.qml`` entry point."""

    return _qml_directory() / "Main.qml"


def configure_app(engine: QQmlApplicationEngine) -> None:
    """Configure QML import paths and register Python types."""

    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Material")
    QCoreApplication.setOrganizationName("ManganoConsulting")
    QCoreApplication.setApplicationName("Analysis")
    engine.addImportPath(str(_qml_directory()))

    # Import modules for side effects so ``@QmlElement`` classes register.
    from .qml_bridge import models  # noqa: F401
    from .qml_bridge import services  # noqa: F401

    LOG.debug("QML import path configured: %s", _qml_directory())
