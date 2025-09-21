from __future__ import annotations

"""Path utilities for locating project resources."""

from pathlib import Path


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def qml_root() -> Path:
    return project_root() / "pyapp" / "qml"


def resource_path(*parts: str) -> Path:
    return project_root().joinpath(*parts)
