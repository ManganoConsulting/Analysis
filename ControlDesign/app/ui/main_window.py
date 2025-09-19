"""Main application window for the ControlDesign tool."""
from __future__ import annotations

import datetime as _dt
import logging
import os
from pathlib import Path
from typing import Callable

from PySide6.QtCore import Qt, QSize
from PySide6.QtGui import QAction, QColor, QIcon
from PySide6.QtWidgets import (
    QApplication,
    QCheckBox,
    QComboBox,
    QDockWidget,
    QFileDialog,
    QFrame,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QStyle,
    QTextEdit,
    QToolButton,
    QVBoxLayout,
    QWidget,
)

from ..engine_bridge import BridgeConfig, MatlabBridge
from .common import TaskRunner
from .panels import SimViewer

logger = logging.getLogger(__name__)


class MainWindow(QMainWindow):
    """Top-level Qt window that replaces the MATLAB GUI."""

    def __init__(self, mock_mode: bool = False, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._mock_mode = mock_mode
        self._engine_ready = False
        self._bridge = MatlabBridge(BridgeConfig(), mock=mock_mode)
        self._task_runner = TaskRunner(self)
        self._ribbon_buttons: dict[str, QToolButton] = {}

        self.setWindowTitle("FLIGHT Control Design Studio")
        self.resize(1280, 820)

        self._build_ui()
        self._create_menus()
        self._start_engine_async()

        if self._mock_mode:
            self.log_message("Application started in MOCK mode - MATLAB is not required.")

    # ------------------------------------------------------------------
    def _build_ui(self) -> None:
        central = QWidget(self)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        ribbon = self._create_ribbon()
        layout.addWidget(ribbon)

        self.log_view = QTextEdit(self)
        self.log_view.setReadOnly(True)
        self.log_view.setLineWrapMode(QTextEdit.LineWrapMode.NoWrap)
        layout.addWidget(self.log_view, 1)

        self.setCentralWidget(central)

        self.sim_viewer = SimViewer(self._bridge, self._task_runner, self.log_message, self)
        dock = QDockWidget("Simulation", self)
        dock.setWidget(self.sim_viewer)
        dock.setObjectName("SimulationDock")
        dock.setFeatures(QDockWidget.DockWidgetFeature.DockWidgetClosable | QDockWidget.DockWidgetFeature.DockWidgetMovable)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, dock)

    # ------------------------------------------------------------------
    def _create_menus(self) -> None:
        file_menu = self.menuBar().addMenu("&File")
        open_action = QAction("Open Model...", self)
        open_action.triggered.connect(self._choose_model)
        file_menu.addAction(open_action)

        exit_action = QAction("Exit", self)
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)

        sim_menu = self.menuBar().addMenu("&Simulation")
        run_action = QAction("Run Simulation", self)
        run_action.triggered.connect(self.sim_viewer.trigger_run)
        sim_menu.addAction(run_action)

        help_menu = self.menuBar().addMenu("&Help")
        about_action = QAction("About", self)
        about_action.triggered.connect(self._show_about)
        help_menu.addAction(about_action)

    # ------------------------------------------------------------------
    def _create_ribbon(self) -> QWidget:
        frame = QFrame(self)
        frame.setAutoFillBackground(True)
        palette = frame.palette()
        palette.setColor(frame.backgroundRole(), QColor(210, 210, 210))
        frame.setPalette(palette)

        layout = QHBoxLayout(frame)
        layout.setContentsMargins(12, 6, 12, 6)
        layout.setSpacing(12)

        layout.addWidget(self._create_button_group(
            "FILE",
            [
                ("New", self._on_new_project, self.style().standardIcon(QStyle.SP_FileDialogNewFolder), "Create a new project"),
                ("Open", self._choose_model, self.style().standardIcon(QStyle.SP_DialogOpenButton), "Open a Simulink model"),
                ("Load", self._on_load_workspace, self.style().standardIcon(QStyle.SP_DialogOpenButton), "Load saved workspace"),
                ("Save", self._on_save_workspace, self.style().standardIcon(QStyle.SP_DialogSaveButton), "Save current workspace"),
            ],
        ))

        layout.addWidget(self._create_button_group(
            "SIMULATION",
            [
                ("Run", self.sim_viewer.trigger_run, self.style().standardIcon(QStyle.SP_MediaPlay), "Run active simulation"),
                ("Run Sel.", self._on_run_selection, self.style().standardIcon(QStyle.SP_ArrowRight), "Run selected case"),
                ("Clear", self._on_clear_table, self.style().standardIcon(QStyle.SP_DialogResetButton), "Clear selections"),
            ],
        ))

        layout.addWidget(self._create_button_group(
            "TOOLS",
            [
                ("Main", lambda: self._log_placeholder("Main panel"), self.style().standardIcon(QStyle.SP_DesktopIcon), "Show main panel"),
                ("Trim", lambda: self._log_placeholder("Trim editor"), self.style().standardIcon(QStyle.SP_ComputerIcon), "Open trim editor"),
                ("Model", lambda: self._log_placeholder("Model editor"), self.style().standardIcon(QStyle.SP_DriveHDIcon), "Open model editor"),
                ("Requirements", lambda: self._log_placeholder("Requirements"), self.style().standardIcon(QStyle.SP_FileDialogListView), "Open requirements"),
                ("Analysis", lambda: self._log_placeholder("Analysis"), self.style().standardIcon(QStyle.SP_ComputerIcon), "Open analysis tools"),
            ],
            extra_widget=self._create_units_combo(),
        ))

        layout.addWidget(self._create_options_group())

        layout.addWidget(self._create_button_group(
            "OUTPUT",
            [
                ("Plot", lambda: self._log_placeholder("Plot results"), self.style().standardIcon(QStyle.SP_ComputerIcon), "Generate plots"),
                ("Report", lambda: self._log_placeholder("Generate report"), self.style().standardIcon(QStyle.SP_FileDialogDetailedView), "Generate report"),
            ],
        ))

        layout.addStretch(1)
        return frame

    def _create_button_group(
        self,
        title: str,
        buttons: list[tuple[str, Callable[[], None], QIcon, str]],
        extra_widget: QWidget | None = None,
    ) -> QWidget:
        frame = QFrame(self)
        frame.setFrameShape(QFrame.StyledPanel)
        frame.setObjectName(f"group_{title.lower()}")
        frame_layout = QVBoxLayout(frame)
        frame_layout.setContentsMargins(6, 6, 6, 2)
        frame_layout.setSpacing(4)

        button_row = QHBoxLayout()
        button_row.setSpacing(4)
        for text, callback, icon, tooltip in buttons:
            button = QToolButton(frame)
            button.setText(text)
            button.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonTextUnderIcon)
            button.setIcon(icon)
            button.setIconSize(QSize(36, 36))
            button.setToolTip(tooltip)
            button.setMinimumWidth(70)
            button.clicked.connect(callback)
            button_row.addWidget(button)
            self._ribbon_buttons[text] = button
        if extra_widget is not None:
            button_row.addWidget(extra_widget)
        button_row.addStretch(1)
        frame_layout.addLayout(button_row)

        label = QLabel(title, frame)
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setStyleSheet("QLabel { color: gray; font-weight: bold; }")
        frame_layout.addWidget(label)
        return frame

    def _create_units_combo(self) -> QWidget:
        container = QFrame(self)
        layout = QVBoxLayout(container)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(2)
        combo = QComboBox(container)
        combo.addItems(["US Customary", "Metric"])
        combo.currentTextChanged.connect(lambda text: self._log_placeholder(f"Units changed to {text}"))
        layout.addWidget(combo)
        units_label = QLabel("Units", container)
        units_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        units_label.setStyleSheet("QLabel { color: gray; font-weight: bold; }")
        layout.addWidget(units_label)
        return container

    def _create_options_group(self) -> QWidget:
        frame = QFrame(self)
        frame.setFrameShape(QFrame.StyledPanel)
        layout = QVBoxLayout(frame)
        layout.setContentsMargins(6, 6, 6, 2)
        layout.setSpacing(2)

        self._chk_invalid_trim = QCheckBox("Show invalid trim", frame)
        self._chk_invalid_trim.setChecked(True)
        self._chk_invalid_trim.toggled.connect(lambda checked: self._log_placeholder(f"Show invalid trim: {checked}"))

        self._chk_log_signals = QCheckBox("Show log signals", frame)
        self._chk_log_signals.toggled.connect(lambda checked: self._log_placeholder(f"Show log signals: {checked}"))

        self._chk_all_combos = QCheckBox("Use all combinations", frame)
        self._chk_all_combos.setChecked(True)
        self._chk_all_combos.toggled.connect(lambda checked: self._log_placeholder(f"Use all combinations: {checked}"))

        layout.addWidget(self._chk_invalid_trim)
        layout.addWidget(self._chk_log_signals)
        layout.addWidget(self._chk_all_combos)

        label = QLabel("OPTIONS", frame)
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setStyleSheet("QLabel { color: gray; font-weight: bold; }")
        layout.addWidget(label)
        return frame

    # ------------------------------------------------------------------
    def _start_engine_async(self) -> None:
        signals = self._task_runner.run(self._bridge.start)
        signals.started.connect(lambda: self.log_message("Starting MATLAB Engine..."))
        signals.result.connect(self._handle_engine_start_result)
        signals.error.connect(lambda err: self.log_message(f"MATLAB Engine failed: {err}"))

    def _handle_engine_start_result(self, result: str) -> None:
        if result.startswith("ERROR"):
            self.log_message(result)
            QMessageBox.critical(self, "MATLAB Engine", result)
            return
        self._engine_ready = True
        self.log_message("MATLAB Engine ready.")

    # ------------------------------------------------------------------
    def _choose_model(self) -> None:
        if not self._engine_ready and not self._mock_mode:
            self.log_message("MATLAB Engine is not ready yet.")
            return

        start_dir = os.getenv("CONTROL_DESIGN_MODELS", str(Path.home()))
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Open Simulink Model",
            start_dir,
            "Simulink Models (*.slx *.mdl);;All Files (*)",
        )
        if not file_path:
            return

        model_identifier = self._model_identifier(file_path)
        self.sim_viewer.set_model(model_identifier)
        self.log_message(f"Loading model '{model_identifier}' ...")

        signals = self._task_runner.run(self._bridge.open_model, model_identifier)
        signals.result.connect(lambda _: self.log_message("Model loaded."))
        signals.error.connect(lambda err: self.log_message(f"Failed to load model: {err}"))

    # ------------------------------------------------------------------
    def _show_about(self) -> None:
        QMessageBox.information(
            self,
            "About",
            "<b>FLIGHT Control Design Studio</b><br/>"
            "Qt-based frontend that orchestrates MATLAB/Simulink through the MATLAB Engine.",
        )

    def _on_new_project(self) -> None:
        self._log_placeholder("New project")

    def _on_load_workspace(self) -> None:
        self._log_placeholder("Load workspace")

    def _on_save_workspace(self) -> None:
        self._log_placeholder("Save workspace")

    def _on_run_selection(self) -> None:
        self._log_placeholder("Run selection")

    def _on_clear_table(self) -> None:
        self._log_placeholder("Clear table")

    def _log_placeholder(self, action: str) -> None:
        self.log_message(f"TODO: {action} action is not yet implemented.")

    # ------------------------------------------------------------------
    def log_message(self, message: str) -> None:
        timestamp = _dt.datetime.now().strftime("%H:%M:%S")
        self.log_view.append(f"[{timestamp}] {message}")
        logger.info(message)

    def _model_identifier(self, path: str) -> str:
        """Return a MATLAB-friendly model identifier."""

        model_path = Path(path)
        if model_path.suffix in {".slx", ".mdl"}:
            return str(model_path)
        return model_path.stem

    def closeEvent(self, event) -> None:  # type: ignore[override]
        try:
            result = self._bridge.stop()
            if result.startswith("ERROR"):
                logger.warning("Failed to stop MATLAB engine cleanly: %s", result)
        finally:
            super().closeEvent(event)


def build_app(mock_mode: bool = False) -> QApplication:
    """Utility for tests to create an application instance."""

    app = QApplication.instance() or QApplication([])
    window = MainWindow(mock_mode=mock_mode)
    window.show()
    return app
