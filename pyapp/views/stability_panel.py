"""Main stability control panel translated from the MATLAB UI."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from PySide6 import QtCore, QtWidgets

from ..models.constant_table import ConstantParameter, ConstantTableModel
from ..widgets.matplotlib_widget import MatplotlibWidget


@dataclass(slots=True)
class TrimSettings:
    """Container representing the trim configuration."""

    flap: str
    landing_gear: str
    use_existing_trim: bool
    use_all_combinations: bool


class StabilityPanel(QtWidgets.QWidget):
    """Composite widget that mirrors the MATLAB Stability Control main view."""

    runRequested = QtCore.Signal(str)
    runAndSaveRequested = QtCore.Signal(str)
    cancelRequested = QtCore.Signal()
    generateReportRequested = QtCore.Signal(str)
    trimSettingsChanged = QtCore.Signal(dict)
    constantsEdited = QtCore.Signal(list)

    def __init__(self, parent: QtWidgets.QWidget | None = None) -> None:
        super().__init__(parent)
        self._analysis_name = "Analysis 1"
        self._trim_settings = TrimSettings("Clean", "Up", False, True)
        self._constants_model = ConstantTableModel(self._default_parameters(), self)
        self._build_ui()

    # ------------------------------------------------------------------
    # UI setup
    # ------------------------------------------------------------------
    def _build_ui(self) -> None:
        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(6, 6, 6, 6)

        self._tab_widget = QtWidgets.QTabWidget(self)
        layout.addWidget(self._tab_widget)

        manual_tab = QtWidgets.QWidget()
        manual_layout = QtWidgets.QVBoxLayout(manual_tab)
        manual_layout.setSpacing(10)

        manual_layout.addWidget(self._build_trim_group())
        manual_layout.addWidget(self._build_run_controls())
        manual_layout.addWidget(self._build_operating_condition_table())
        manual_layout.addWidget(self._build_plot_group())
        manual_layout.addStretch()

        self._tab_widget.addTab(manual_tab, "Manual")

        constants_tab = QtWidgets.QWidget()
        constants_layout = QtWidgets.QVBoxLayout(constants_tab)
        constants_layout.addWidget(self._build_constants_table())
        self._tab_widget.addTab(constants_tab, "Parameters")

    def _build_trim_group(self) -> QtWidgets.QGroupBox:
        group = QtWidgets.QGroupBox("Trim Settings", self)
        form = QtWidgets.QFormLayout(group)

        self._flap_combo = QtWidgets.QComboBox(group)
        self._flap_combo.addItems(["Clean", "Approach", "Landing"])
        self._flap_combo.currentTextChanged.connect(self._on_trim_changed)
        form.addRow("Flap Configuration", self._flap_combo)

        self._gear_combo = QtWidgets.QComboBox(group)
        self._gear_combo.addItems(["Up", "Down"])
        self._gear_combo.currentTextChanged.connect(self._on_trim_changed)
        form.addRow("Landing Gear", self._gear_combo)

        self._use_existing_check = QtWidgets.QCheckBox("Use existing trim results", group)
        self._use_existing_check.stateChanged.connect(self._on_trim_changed)
        form.addRow(self._use_existing_check)

        self._use_all_check = QtWidgets.QCheckBox("Use all control combinations", group)
        self._use_all_check.setChecked(True)
        self._use_all_check.stateChanged.connect(self._on_trim_changed)
        form.addRow(self._use_all_check)

        return group

    def _build_run_controls(self) -> QtWidgets.QWidget:
        container = QtWidgets.QWidget(self)
        layout = QtWidgets.QHBoxLayout(container)
        layout.addStretch()

        self._run_button = QtWidgets.QPushButton("Run Analysis", container)
        self._run_button.clicked.connect(self._emit_run)
        layout.addWidget(self._run_button)

        self._run_and_save_button = QtWidgets.QPushButton("Run && Save", container)
        self._run_and_save_button.clicked.connect(self._emit_run_and_save)
        layout.addWidget(self._run_and_save_button)

        self._cancel_button = QtWidgets.QPushButton("Cancel", container)
        self._cancel_button.clicked.connect(self.cancelRequested)
        layout.addWidget(self._cancel_button)

        self._report_button = QtWidgets.QPushButton("Generate Report", container)
        self._report_button.clicked.connect(self._emit_report)
        layout.addWidget(self._report_button)

        return container

    def _build_operating_condition_table(self) -> QtWidgets.QGroupBox:
        group = QtWidgets.QGroupBox("Operating Conditions", self)
        layout = QtWidgets.QVBoxLayout(group)

        self._operating_table = QtWidgets.QTableWidget(0, 3, group)
        self._operating_table.setHorizontalHeaderLabels(["Name", "Successful", "Mass (lb)"])
        self._operating_table.horizontalHeader().setStretchLastSection(True)
        self._operating_table.setSelectionBehavior(QtWidgets.QAbstractItemView.SelectRows)
        layout.addWidget(self._operating_table)
        return group

    def _build_plot_group(self) -> QtWidgets.QGroupBox:
        group = QtWidgets.QGroupBox("Result Preview", self)
        layout = QtWidgets.QVBoxLayout(group)
        self._plot_widget = MatplotlibWidget(group)
        layout.addWidget(self._plot_widget)
        self._plot_widget.plot_placeholder()
        return group

    def _build_constants_table(self) -> QtWidgets.QWidget:
        container = QtWidgets.QWidget(self)
        layout = QtWidgets.QVBoxLayout(container)

        self._constants_table = QtWidgets.QTableView(container)
        self._constants_table.setModel(self._constants_model)
        self._constants_table.horizontalHeader().setStretchLastSection(True)
        layout.addWidget(self._constants_table)

        button_row = QtWidgets.QHBoxLayout()
        self._add_constant_button = QtWidgets.QPushButton("Add Parameter", container)
        self._add_constant_button.clicked.connect(self._on_add_constant)
        button_row.addWidget(self._add_constant_button)

        self._remove_constant_button = QtWidgets.QPushButton("Remove Selected", container)
        self._remove_constant_button.clicked.connect(self._on_remove_constant)
        button_row.addWidget(self._remove_constant_button)

        button_row.addStretch()
        layout.addLayout(button_row)

        return container

    # ------------------------------------------------------------------
    # Signals and state updates
    # ------------------------------------------------------------------
    def set_analysis_name(self, name: str) -> None:
        self._analysis_name = name

    def _emit_run(self) -> None:
        self.runRequested.emit(self._analysis_name)

    def _emit_run_and_save(self) -> None:
        self.runAndSaveRequested.emit(self._analysis_name)

    def _emit_report(self) -> None:
        self.generateReportRequested.emit(self._analysis_name)

    def _on_trim_changed(self) -> None:
        self._trim_settings = TrimSettings(
            self._flap_combo.currentText(),
            self._gear_combo.currentText(),
            self._use_existing_check.isChecked(),
            self._use_all_check.isChecked(),
        )
        self.trimSettingsChanged.emit(
            {
                "flap": self._trim_settings.flap,
                "landing_gear": self._trim_settings.landing_gear,
                "use_existing_trim": self._trim_settings.use_existing_trim,
                "use_all_combinations": self._trim_settings.use_all_combinations,
            }
        )

    def _on_add_constant(self) -> None:
        new_param = ConstantParameter("NewParam", 0.0, "unit", "")
        self._constants_model.append(new_param)
        self.constantsEdited.emit(self._constants_model.parameters())

    def _on_remove_constant(self) -> None:
        selection = self._constants_table.selectionModel()
        if not selection.hasSelection():
            return
        rows = sorted({index.row() for index in selection.selectedIndexes()}, reverse=True)
        if not rows:
            return
        self._constants_model.remove_rows(rows)
        self.constantsEdited.emit(self._constants_model.parameters())

    def trigger_run(self) -> None:
        self._emit_run()

    def trigger_run_and_save(self) -> None:
        self._emit_run_and_save()

    def trigger_report(self) -> None:
        self._emit_report()

    # ------------------------------------------------------------------
    # External updates
    # ------------------------------------------------------------------
    def set_operating_conditions(self, conditions: Sequence[dict[str, object]]) -> None:
        self._operating_table.setRowCount(len(conditions))
        for row, condition in enumerate(conditions):
            name_item = QtWidgets.QTableWidgetItem(str(condition.get("name", "")))
            success_item = QtWidgets.QTableWidgetItem("Yes" if condition.get("success") else "No")
            mass_item = QtWidgets.QTableWidgetItem(str(condition.get("mass", "")))
            self._operating_table.setItem(row, 0, name_item)
            self._operating_table.setItem(row, 1, success_item)
            self._operating_table.setItem(row, 2, mass_item)

    def update_plot(self) -> None:
        self._plot_widget.plot_placeholder()

    @staticmethod
    def _default_parameters() -> Sequence[ConstantParameter]:
        return [
            ConstantParameter("mass", 12345, "lb", "Vehicle mass"),
            ConstantParameter("altitude", 10000, "ft", "Initial altitude"),
            ConstantParameter("velocity", 250, "kts", "Initial airspeed"),
        ]


__all__ = ["StabilityPanel", "TrimSettings"]
