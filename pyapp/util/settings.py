"""Application settings backed by :class:`QSettings`."""

from __future__ import annotations

from PySide6.QtCore import QCoreApplication, QSettings

ORGANIZATION = "ManganoConsulting"
APPLICATION = "Analysis"


def _settings() -> QSettings:
    if not QCoreApplication.organizationName():
        QCoreApplication.setOrganizationName(ORGANIZATION)
    if not QCoreApplication.applicationName():
        QCoreApplication.setApplicationName(APPLICATION)
    return QSettings()


def theme(default: str = "light") -> str:
    return str(_settings().value("ui/theme", default))


def set_theme(value: str) -> None:
    s = _settings()
    s.setValue("ui/theme", value)
    s.sync()
