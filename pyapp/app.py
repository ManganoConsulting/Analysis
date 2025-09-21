"""CLI entry point for the Qt Quick application."""

from __future__ import annotations

import argparse
import asyncio
import logging
import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import qasync

from .main import configure_app, default_qml_path


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the Analysis Qt Quick application.")
    parser.add_argument(
        "--mock",
        action="store_true",
        help=(
            "Use the mock MATLAB engine implementation regardless of the "
            "ANALYSIS_USE_MOCK environment variable."
        ),
    )
    parser.add_argument(
        "--qml",
        type=Path,
        help="Optional path to an alternate QML entry point.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    """Application entry point used by ``python -m pyapp.app``."""

    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.mock:
        os.environ["ANALYSIS_USE_MOCK"] = "1"

    logging.basicConfig(level=logging.INFO)
    logging.getLogger(__name__).debug("Starting QApplication")

    app = QGuiApplication(sys.argv)
    loop = qasync.QEventLoop(app)
    asyncio.set_event_loop(loop)

    engine = QQmlApplicationEngine()
    configure_app(engine)

    qml_path = args.qml or default_qml_path()
    engine.load(QUrl.fromLocalFile(str(qml_path)))

    if not engine.rootObjects():
        raise SystemExit(f"Failed to load QML from {qml_path}")

    app.aboutToQuit.connect(loop.stop)

    with loop:
        loop.run_forever()

    return 0


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    raise SystemExit(main())
