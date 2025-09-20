"""Qt main window replicating the MATLAB Stability Control UI."""

from __future__ import annotations

import logging
from pathlib import Path

from PySide6 import QtCore, QtGui, QtWidgets

from .matlab_bridge import api
from .matlab_bridge.engine_manager import EngineManager
from .matlab_bridge.matlab_async import MatlabAsyncRunner, MatlabJob
from .models.analysis_tree import AnalysisTreeModel
from .util import paths
from .util.settings import SettingsManager
from .views.stability_panel import StabilityPanel

LOG = logging.getLogger(__name__)


class MainWindow(QtWidgets.QMainWindow):
    """Main application window."""

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("Stability Control Analysis")
        self.resize(1400, 900)

        self._settings = SettingsManager()
        self._engine_manager = EngineManager()
        self._runner = MatlabAsyncRunner(self._engine_manager, self)
        self._current_job: MatlabJob | None = None

        self._create_actions()
        self._create_menus()
        self._create_toolbars()
        self._create_status_bar()
        self._create_central_widgets()

        self._runner.job_started.connect(self._on_job_started)
        self._runner.job_finished.connect(self._on_job_finished)

        self._settings.restore_geometry(self)
        self._settings.restore_state(self)

        QtCore.QTimer.singleShot(200, self._load_initial_data)

    # ------------------------------------------------------------------
    # UI Construction
    # ------------------------------------------------------------------
    def _create_actions(self) -> None:
        self._action_new_project = QtGui.QAction("New Project", self)
        self._action_new_project.triggered.connect(self._on_new_project)

        self._action_load_project = QtGui.QAction("Load Project…", self)
        self._action_load_project.triggered.connect(self._on_load_project)

        self._action_close_project = QtGui.QAction("Close Project", self)
        self._action_close_project.triggered.connect(self._on_close_project)

        self._action_save_workspace = QtGui.QAction("Save Workspace…", self)
        self._action_save_workspace.triggered.connect(self._on_save_workspace)

        self._action_load_workspace = QtGui.QAction("Load Workspace…", self)
        self._action_load_workspace.triggered.connect(self._on_load_workspace)

        self._action_run = QtGui.QAction("Run Analysis", self)
        self._action_run.triggered.connect(self._trigger_run_current_tab)

        self._action_run_and_save = QtGui.QAction("Run && Save", self)
        self._action_run_and_save.triggered.connect(self._trigger_run_and_save_current_tab)

        self._action_generate_report = QtGui.QAction("Generate Report", self)
        self._action_generate_report.triggered.connect(self._trigger_report_current_tab)

        self._action_toggle_dark = QtGui.QAction("Dark Theme", self)
        self._action_toggle_dark.setCheckable(True)
        self._action_toggle_dark.toggled.connect(self._apply_dark_theme)

        self._action_exit = QtGui.QAction("Exit", self)
        self._action_exit.triggered.connect(self.close)

    def _create_menus(self) -> None:
        file_menu = self.menuBar().addMenu("&File")
        file_menu.addAction(self._action_new_project)
        file_menu.addAction(self._action_load_project)
        file_menu.addAction(self._action_close_project)
        file_menu.addSeparator()
        file_menu.addAction(self._action_save_workspace)
        file_menu.addAction(self._action_load_workspace)
        file_menu.addSeparator()
        file_menu.addAction(self._action_exit)

        analysis_menu = self.menuBar().addMenu("&Analysis")
        analysis_menu.addAction(self._action_run)
        analysis_menu.addAction(self._action_run_and_save)
        analysis_menu.addAction(self._action_generate_report)

        view_menu = self.menuBar().addMenu("&View")
        view_menu.addAction(self._action_toggle_dark)

    def _create_toolbars(self) -> None:
        self._toolbar = self.addToolBar("Ribbon")
        self._toolbar.setMovable(False)
        self._toolbar.addAction(self._action_new_project)
        self._toolbar.addAction(self._action_load_project)
        self._toolbar.addAction(self._action_save_workspace)
        self._toolbar.addSeparator()
        self._toolbar.addAction(self._action_run)
        self._toolbar.addAction(self._action_run_and_save)
        self._toolbar.addAction(self._action_generate_report)

    def _create_status_bar(self) -> None:
        status = self.statusBar()
        self._progress = QtWidgets.QProgressBar(status)
        self._progress.setRange(0, 100)
        self._progress.setVisible(False)
        status.addPermanentWidget(self._progress)

    def _create_central_widgets(self) -> None:
        self._tree_model = AnalysisTreeModel(self)
        self._tree_view = QtWidgets.QTreeView(self)
        self._tree_view.setModel(self._tree_model)
        self._tree_view.expandAll()
        self._tree_view.selectionModel().selectionChanged.connect(self._on_tree_selection)

        tree_dock = QtWidgets.QDockWidget("Project Browser", self)
        tree_dock.setWidget(self._tree_view)
        self.addDockWidget(QtCore.Qt.LeftDockWidgetArea, tree_dock)

        self._analysis_tab_widget = QtWidgets.QTabWidget(self)
        self._analysis_tab_widget.setTabsClosable(True)
        self._analysis_tab_widget.tabCloseRequested.connect(self._remove_analysis_tab)
        self._analysis_tab_widget.currentChanged.connect(self._on_tab_changed)
        self.setCentralWidget(self._analysis_tab_widget)

        self._log_dock = QtWidgets.QDockWidget("Log", self)
        self._log_view = QtWidgets.QPlainTextEdit(self._log_dock)
        self._log_view.setReadOnly(True)
        self._log_dock.setWidget(self._log_view)
        self.addDockWidget(QtCore.Qt.BottomDockWidgetArea, self._log_dock)

        self._add_analysis_tab("Analysis 1")

    # ------------------------------------------------------------------
    # Analysis tab helpers
    # ------------------------------------------------------------------
    def _add_analysis_tab(self, title: str) -> None:
        panel = StabilityPanel(self)
        panel.set_analysis_name(title)
        panel.runRequested.connect(self._on_run_requested)
        panel.runAndSaveRequested.connect(self._on_run_and_save_requested)
        panel.generateReportRequested.connect(self._on_generate_report_requested)
        panel.cancelRequested.connect(self._on_cancel_requested)
        panel.trimSettingsChanged.connect(self._log_trim_update)
        panel.constantsEdited.connect(self._log_constants_update)

        index = self._analysis_tab_widget.addTab(panel, title)
        self._analysis_tab_widget.setCurrentIndex(index)

    def _remove_analysis_tab(self, index: int) -> None:
        widget = self._analysis_tab_widget.widget(index)
        if widget:
            widget.deleteLater()
        self._analysis_tab_widget.removeTab(index)

    # ------------------------------------------------------------------
    # Actions triggered from toolbar/menu
    # ------------------------------------------------------------------
    def _on_new_project(self) -> None:
        name, ok = QtWidgets.QInputDialog.getText(self, "New Project", "Project name")
        if not ok or not name:
            return
        self._tree_model.populate_default()
        self._tree_model.set_analyses(["Analysis 1"])
        self._log(f"Created project {name}")

    def _on_load_project(self) -> None:
        file_path, _ = QtWidgets.QFileDialog.getOpenFileName(self, "Load Project", str(paths.repo_root()), "Project (*.mat *.m)")
        if not file_path:
            return
        self._start_job("Load Project", api.load_project, Path(file_path))

    def _on_close_project(self) -> None:
        self._tree_model.populate_default()
        self._analysis_tab_widget.clear()
        self._add_analysis_tab("Analysis 1")
        self._log("Project closed")

    def _on_save_workspace(self) -> None:
        file_path, _ = QtWidgets.QFileDialog.getSaveFileName(self, "Save Workspace", str(paths.repo_root()), "MAT-files (*.mat)")
        if not file_path:
            return
        self._start_job("Save Workspace", api.save_workspace, Path(file_path))

    def _on_load_workspace(self) -> None:
        file_path, _ = QtWidgets.QFileDialog.getOpenFileName(self, "Load Workspace", str(paths.repo_root()), "MAT-files (*.mat)")
        if not file_path:
            return
        self._start_job("Load Workspace", api.load_workspace, Path(file_path))

    # ------------------------------------------------------------------
    # Tab interactions
    # ------------------------------------------------------------------
    def _trigger_run_current_tab(self) -> None:
        panel = self._current_panel()
        if panel:
            panel.trigger_run()

    def _trigger_run_and_save_current_tab(self) -> None:
        panel = self._current_panel()
        if panel:
            panel.trigger_run_and_save()

    def _trigger_report_current_tab(self) -> None:
        panel = self._current_panel()
        if panel:
            panel.trigger_report()

    def _current_panel(self) -> StabilityPanel | None:
        index = self._analysis_tab_widget.currentIndex()
        widget = self._analysis_tab_widget.widget(index)
        if isinstance(widget, StabilityPanel):
            return widget
        return None

    # ------------------------------------------------------------------
    # Stability panel callbacks
    # ------------------------------------------------------------------
    def _on_run_requested(self, analysis_name: str) -> None:
        self._start_job(f"Run {analysis_name}", api.run_trim_analysis, analysis_name)

    def _on_run_and_save_requested(self, analysis_name: str) -> None:
        self._start_job(f"Run and save {analysis_name}", api.run_trim_analysis, analysis_name)

    def _on_generate_report_requested(self, analysis_name: str) -> None:
        output_dir = paths.ensure_app_data_dir() / "reports"
        self._start_job("Generate Report", api.generate_report, analysis_name, output_dir=output_dir)

    def _on_cancel_requested(self) -> None:
        if self._current_job:
            self._current_job.cancel()
            self._log("Cancellation requested")

    # ------------------------------------------------------------------
    # Tree / tab updates
    # ------------------------------------------------------------------
    def _on_tree_selection(self, selected: QtCore.QItemSelection, _deselected: QtCore.QItemSelection) -> None:
        if not selected.indexes():
            return
        index = selected.indexes()[0]
        title = index.data()
        panel = self._current_panel()
        if panel:
            panel.set_analysis_name(str(title))
            self._analysis_tab_widget.setTabText(self._analysis_tab_widget.currentIndex(), str(title))

    def _on_tab_changed(self, index: int) -> None:
        panel = self._analysis_tab_widget.widget(index)
        if isinstance(panel, StabilityPanel):
            panel.update_plot()

    # ------------------------------------------------------------------
    # MATLAB job orchestration
    # ------------------------------------------------------------------
    def _start_job(self, description: str, func, *args, **kwargs) -> None:
        if not self._engine_manager.engine_available():
            QtWidgets.QMessageBox.critical(self, "MATLAB Engine", "MATLAB Engine for Python is not available.")
            return
        if self._current_job is not None:
            QtWidgets.QMessageBox.warning(self, "MATLAB busy", "A MATLAB task is already running.")
            return
        job = self._runner.run_task(description, func, *args, **kwargs)
        job.progress.connect(self._on_job_progress)
        job.finished.connect(lambda result: self._on_job_result(description, result))
        job.error.connect(lambda message: self._on_job_error(description, message))
        job.cancelled.connect(lambda: self._on_job_cancelled(description))
        self._current_job = job
        self._progress.setVisible(True)
        self._progress.setValue(0)

    def _on_job_progress(self, percent: int, message: str) -> None:
        self._progress.setValue(percent)
        if message:
            self.statusBar().showMessage(message)

    def _on_job_result(self, description: str, result) -> None:
        self._log(f"{description} finished: {result}")
        self._finalise_job()
        if description.startswith("Run"):
            panel = self._current_panel()
            if panel:
                panel.set_operating_conditions(api.get_operating_conditions(self._engine_manager.get_engine()))

    def _on_job_cancelled(self, description: str) -> None:
        self._log(f"{description} cancelled")
        self._finalise_job()

    def _on_job_error(self, description: str, message: str) -> None:
        QtWidgets.QMessageBox.critical(self, "MATLAB Error", message)
        self._log(f"{description} failed: {message}")
        self._finalise_job()

    def _on_job_started(self, description: str) -> None:
        self._log(f"Started {description}")
        self.statusBar().showMessage(description)

    def _on_job_finished(self, description: str) -> None:
        self._log(f"Completed {description}")
        self.statusBar().clearMessage()

    def _finalise_job(self) -> None:
        self._current_job = None
        self._progress.setVisible(False)
        self._progress.setValue(0)

    # ------------------------------------------------------------------
    # Logging / theming helpers
    # ------------------------------------------------------------------
    def _log_trim_update(self, payload: dict) -> None:
        self._log(f"Trim settings updated: {payload}")

    def _log_constants_update(self, constants) -> None:
        self._log(f"Constants edited ({len(constants)})")

    def _log(self, message: str) -> None:
        LOG.info(message)
        self._log_view.appendPlainText(message)

    def _apply_dark_theme(self, enabled: bool) -> None:
        palette = QtGui.QPalette()
        if enabled:
            palette.setColor(QtGui.QPalette.Window, QtGui.QColor(45, 45, 45))
            palette.setColor(QtGui.QPalette.WindowText, QtGui.QColor(220, 220, 220))
            palette.setColor(QtGui.QPalette.Base, QtGui.QColor(35, 35, 35))
            palette.setColor(QtGui.QPalette.AlternateBase, QtGui.QColor(45, 45, 45))
            palette.setColor(QtGui.QPalette.Text, QtGui.QColor(220, 220, 220))
            palette.setColor(QtGui.QPalette.Button, QtGui.QColor(60, 60, 60))
            palette.setColor(QtGui.QPalette.ButtonText, QtGui.QColor(220, 220, 220))
            palette.setColor(QtGui.QPalette.Highlight, QtGui.QColor(42, 130, 218))
            palette.setColor(QtGui.QPalette.HighlightedText, QtGui.QColor(255, 255, 255))
        else:
            palette = self.style().standardPalette()
        self.setPalette(palette)

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------
    def closeEvent(self, event: QtGui.QCloseEvent) -> None:  # type: ignore[override]
        self._settings.save_geometry(self)
        self._settings.save_state(self)
        super().closeEvent(event)

    # ------------------------------------------------------------------
    # Initial data load
    # ------------------------------------------------------------------
    def _load_initial_data(self) -> None:
        panel = self._current_panel()
        if panel is None:
            return
        panel.set_operating_conditions([
            {"name": "Default", "success": True, "mass": 12345},
            {"name": "Alternate", "success": False, "mass": 12000},
        ])


__all__ = ["MainWindow"]
