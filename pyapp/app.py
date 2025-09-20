"""Command line entry point that launches the PySide6 application."""

from __future__ import annotations

import argparse
import logging
import os
import sys
import os
from pathlib import Path # Add pathlib for cleaner path manipulation
from typing import Sequence

from PySide6 import QtCore, QtGui, QtWidgets

# Add the parent directory of pyapp to sys.path
# This allows running app.py directly while treating pyapp as a package
# and allows for absolute imports like `from pyapp.module import ...`
script_dir = Path(__file__).parent
package_root_dir = script_dir.parent
if str(package_root_dir) not in sys.path:
    sys.path.insert(0, str(package_root_dir))

# Now, absolute imports from 'pyapp' should work
from pyapp.mainwindow import MainWindow
from pyapp.util.settings import apply_high_dpi_settings


LOG = logging.getLogger(__name__)


def _parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Launch the Stability Control UI")
    parser.add_argument(
        "--offscreen",
        action="store_true",
        help="Force Qt to use the offscreen platform plugin (useful for tests).",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Configure the Python log level.",
    )
    return parser.parse_args(argv)


def _configure_logging(level: str) -> None:
    logging.basicConfig(
        level=getattr(logging, level),
        format="%(asctime)s %(levelname)8s %(name)s | %(message)s",
    )


def main(argv: Sequence[str] | None = None) -> int:
    """Entry point used by ``python -m pyapp.app``."""
    args = _parse_args(argv)
    _configure_logging(args.log_level)

    if args.offscreen:
        os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
        QtCore.QCoreApplication.setAttribute(QtCore.Qt.AA_DisableHighDpiScaling, True)
        QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_Use96Dpi, True)
        QtCore.QCoreApplication.setAttribute(QtCore.Qt.AA_ShareOpenGLContexts, True)
        QtGui.QGuiApplication.setHighDpiScaleFactorRoundingPolicy(
            QtCore.Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
        )
        QtWidgets.QApplication.setDesktopSettingsAware(False)
        LOG.info("Launching in offscreen mode")
    else:
        apply_high_dpi_settings()

    app = QtWidgets.QApplication(list(sys.argv))
    app.setOrganizationName("Mangano Consulting")
    app.setOrganizationDomain("manganoconsulting.com")
    app.setApplicationName("Stability Control")
    app.setStyle("Fusion")

    window = MainWindow()
    window.show()
    LOG.debug("Application started")

    return app.exec()


if __name__ == "__main__":  # pragma: no cover - delegated to ``main``
    sys.exit(main())
