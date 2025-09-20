"""Filesystem helpers for the PySide6 stability control application."""

from __future__ import annotations

from pathlib import Path


def repo_root() -> Path:
    """Return the repository root directory."""
    return Path(__file__).resolve().parents[2]


def app_root() -> Path:
    """Return the directory that contains the Python application package."""
    return Path(__file__).resolve().parents[1]


def resources_path(*parts: str) -> Path:
    """Return an absolute path inside the packaged resources directory."""
    return app_root() / "resources" / Path(*parts)


def ensure_app_data_dir() -> Path:
    """Ensure that the user-specific application data directory exists."""
    base_dir = Path.home() / ".analysis_stability"
    base_dir.mkdir(parents=True, exist_ok=True)
    return base_dir


__all__ = [
    "repo_root",
    "app_root",
    "resources_path",
    "ensure_app_data_dir",
]
