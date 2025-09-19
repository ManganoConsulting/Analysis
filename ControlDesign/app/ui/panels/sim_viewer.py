"""Simulation control panel."""
from __future__ import annotations

from typing import Any, Callable

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QTextEdit,
    QVBoxLayout,
    QWidget,
)

from ...engine_bridge import MatlabBridge
from ..common import TaskRunner


class SimViewer(QWidget):
    """Panel that manages Simulink simulations."""

    simulationCompleted = Signal(dict)

    def __init__(self, bridge: MatlabBridge, task_runner: TaskRunner, log_callback: Callable[[str], None], parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._bridge = bridge
        self._task_runner = task_runner
        self._log = log_callback
        self._current_model: str = ""
        self._build_ui()

    # ------------------------------------------------------------------
    def _build_ui(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)
        layout.setSpacing(6)

        title = QLabel("Simulation Control", self)
        title.setProperty("heading", True)
        title.setAlignment(Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter)
        layout.addWidget(title)

        form = QFormLayout()
        form.setContentsMargins(0, 0, 0, 0)
        form.setSpacing(6)

        self.model_input = QLineEdit(self)
        self.model_input.setPlaceholderText("Model name or full path")
        form.addRow("Model:", self.model_input)

        self.stop_time_input = QLineEdit(self)
        self.stop_time_input.setText("10")
        form.addRow("Stop time:", self.stop_time_input)

        layout.addLayout(form)

        button_row = QHBoxLayout()
        self.run_button = QPushButton("Run Simulation", self)
        button_row.addWidget(self.run_button)
        button_row.addStretch(1)
        layout.addLayout(button_row)

        self.output_view = QTextEdit(self)
        self.output_view.setReadOnly(True)
        self.output_view.setPlaceholderText("Simulation results will appear here.")
        layout.addWidget(self.output_view, 1)

        self.run_button.clicked.connect(self.run_simulation)

    # ------------------------------------------------------------------
    def run_simulation(self) -> None:
        """Start a simulation run via the thread pool."""

        model = self.model_input.text().strip()
        if not model:
            self._log("Please enter a Simulink model name before running a simulation.")
            return

        stop_time = self.stop_time_input.text().strip() or "10"

        self._log(f"Running simulation for '{model}' with stop time {stop_time}...")
        self.run_button.setEnabled(False)
        self.output_view.clear()

        signals = self._task_runner.run(self._bridge.run_sim, model, stop_time, True)

        signals.started.connect(lambda: None)
        signals.result.connect(self._handle_result)
        signals.error.connect(self._handle_error)
        signals.finished.connect(lambda: self.run_button.setEnabled(True))

    # ------------------------------------------------------------------
    def set_model(self, model: str) -> None:
        self._current_model = model
        self.model_input.setText(model)

    def _handle_result(self, result: dict[str, Any]) -> None:
        lines = ["Simulation finished:"]
        for key, value in result.items():
            lines.append(f"  {key}: {value}")
        text = "\n".join(lines)
        self.output_view.setPlainText(text)
        self._log("Simulation completed.")
        if result.get("y") is not None:
            self._log("Received output 'y' from MATLAB workspace.")
        self.simulationCompleted.emit(result)

    def _handle_error(self, message: str) -> None:
        self.output_view.setPlainText(f"Simulation failed: {message}")
        self._log(f"Simulation error: {message}")

    # Convenience for ribbon integration
    def trigger_run(self) -> None:
        self.run_simulation()
