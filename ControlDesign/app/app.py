"""Entry point for the ControlDesign PySide6 application."""
from __future__ import annotations

import os
import sys
from typing import Sequence

from PySide6.QtWidgets import QApplication

from .ui.main_window import MainWindow


def _is_mock_mode(env_value: str | None) -> bool:
    if env_value is None:
        return False
    value = env_value.strip().lower()
    return value in {"1", "true", "yes", "on"}


def main(argv: Sequence[str] | None = None) -> int:
    """Run the Qt application."""

    argv = list(argv or sys.argv)
    app = QApplication.instance() or QApplication(argv)
    mock_mode = _is_mock_mode(os.getenv("CONTROL_UI_MOCK"))
    window = MainWindow(mock_mode=mock_mode)
    window.show()
    return app.exec()


if __name__ == "__main__":  # pragma: no cover - manual invocation
    raise SystemExit(main())
