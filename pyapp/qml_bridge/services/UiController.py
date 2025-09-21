"""Controller that coordinates QML interactions with the MATLAB API."""

from __future__ import annotations

import logging
from typing import List

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtQml import QmlElement

from ...util import settings
from ...util.paths import project_root
from ..models import StabilityItem, StabilityItemsModel
from .MatlabApi import MatlabApi

LOG = logging.getLogger(__name__)

QML_IMPORT_NAME = "Analysis"
QML_IMPORT_MAJOR_VERSION = 1


class UiController(QObject):
    """Acts as the ViewModel between QML and MATLAB services."""

    themeChanged = Signal(str)
    messageEmitted = Signal(str)
    errorEmitted = Signal(str)
    progressChanged = Signal(float)
    simulationDataReady = Signal(object)
    busyChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._matlab = MatlabApi()
        self._stability_model = StabilityItemsModel()
        self._current_result: object | None = None

        self._matlab.statusMessage.connect(self.messageEmitted)
        self._matlab.simulationFinished.connect(self._handle_sim_finished)
        self._matlab.simulationFailed.connect(self.errorEmitted)
        self._matlab.progressChanged.connect(self.progressChanged)
        self._matlab.busyChanged.connect(self.busyChanged)

        self._load_default_items()

    # ------------------------------------------------------------------ properties
    @Property(QObject, constant=True)
    def stabilityModel(self) -> QObject:
        return self._stability_model

    @Property(QObject, constant=True)
    def matlab(self) -> QObject:
        return self._matlab

    @Slot(result=int)
    def taskCount(self) -> int:
        return self._stability_model.rowCount()

    @Property(str, notify=themeChanged)
    def theme(self) -> str:
        return settings.theme()

    @Slot(str)
    def setTheme(self, value: str) -> None:
        settings.set_theme(value)
        self.themeChanged.emit(value)

    @Slot()
    def toggleTheme(self) -> None:
        next_theme = "dark" if settings.theme() == "light" else "light"
        self.setTheme(next_theme)

    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return bool(self._matlab.busy)

    # -------------------------------------------------------------------- actions
    @Slot(str)
    def openModel(self, path: str) -> None:
        if path:
            LOG.info("Opening model via MATLAB API: %s", path)
            self._matlab.openModel(path)

    @Slot(str)
    def openProjectFolder(self, subfolder: str = "") -> None:
        root = project_root()
        target = root / subfolder if subfolder else root
        self.messageEmitted.emit(str(target))

    @Slot(str, float)
    def runSimulation(self, model: str, stop_time: float = 10.0) -> None:
        if not model:
            self.errorEmitted.emit("Model path is required")
            return
        self._matlab.runSimulation(model, stop_time)

    @Slot()
    def cancelSimulation(self) -> None:
        self._matlab.cancelSimulation()

    @Slot(str, str, object)
    def setParameter(self, block: str, name: str, value: object) -> None:
        self._matlab.setParameter(block, name, value)

    @Slot(str, str)
    def getParameter(self, block: str, name: str) -> None:
        self._matlab.getParameter(block, name)

    # ----------------------------------------------------------------- callbacks
    def _load_default_items(self) -> None:
        # TODO: Replace placeholder tasks with dynamic data from matlab_core.
        examples: List[StabilityItem] = [
            StabilityItem("Trim", "Equilibrium trim calculation"),
            StabilityItem("Linearize", "Linear model extraction"),
            StabilityItem("Gust", "Gust response analysis"),
            StabilityItem("Control", "Control surface sweep"),
        ]
        self._stability_model.update_items(examples)

    def _handle_sim_finished(self, result: object) -> None:
        self._current_result = result
        LOG.info("Simulation completed with result: %s", result)
        self.simulationDataReady.emit(result)


QmlElement(UiController)
