"""High level API wrapping MATLAB Engine calls for QML."""

from __future__ import annotations

import asyncio
import logging
from typing import Any

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtQml import QmlElement

from ..async_tools import TaskHandle, run_cancellable
from .Converters import matlab_to_python, python_to_matlab
from .EngineManager import EngineManager

LOG = logging.getLogger(__name__)

QML_IMPORT_NAME = "Analysis"
QML_IMPORT_MAJOR_VERSION = 1


_shared_manager: EngineManager | None = None


class MatlabApi(QObject):
    """Expose asynchronous MATLAB operations to QML."""

    busyChanged = Signal()
    progressChanged = Signal(float)
    statusMessage = Signal(str)
    simulationFinished = Signal(object)
    simulationFailed = Signal(str)
    parameterFetched = Signal(str, str, object)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        global _shared_manager
        if _shared_manager is None:
            _shared_manager = EngineManager()
        self._engine_manager = _shared_manager
        self._current_task: TaskHandle | None = None
        self._busy = False

    # ------------------------------------------------------------------ properties
    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._busy

    def _set_busy(self, value: bool) -> None:
        if self._busy != value:
            self._busy = value
            self.busyChanged.emit()

    # --------------------------------------------------------------------- slots
    @Slot(str, result=bool)
    def openModel(self, model_path: str) -> bool:
        asyncio.create_task(self._open_model(model_path))
        return True

    async def _open_model(self, model_path: str) -> None:
        engine = await self._engine_manager.ensure_started()
        loop = asyncio.get_running_loop()
        self.statusMessage.emit(f"Loading model: {model_path}")
        try:
            await loop.run_in_executor(None, engine.load_system, model_path, 0)
        except Exception as exc:  # pragma: no cover - depends on MATLAB API
            LOG.exception("Failed to load model %s", model_path)
            self.statusMessage.emit(f"Failed to load model: {exc}")
            self.simulationFailed.emit(str(exc))
        else:
            self.statusMessage.emit(f"Model '{model_path}' loaded")

    @Slot(str, float, result=bool)
    def runSimulation(self, model: str, stop_time: float = 10.0) -> bool:
        if self._current_task is not None:
            self.statusMessage.emit("Simulation already running")
            return False

        self.statusMessage.emit(f"Running simulation: {model}")
        self._set_busy(True)
        self.progressChanged.emit(0.0)

        handle = run_cancellable(lambda: self._simulate(model, stop_time))
        handle.completed.connect(self._on_simulation_completed)
        handle.failed.connect(self._on_simulation_failed)
        handle.cancelled.connect(self._on_simulation_cancelled)
        self._current_task = handle
        return True

    async def _simulate(self, model: str, stop_time: float) -> Any:
        engine = await self._engine_manager.ensure_started()
        loop = asyncio.get_running_loop()

        def progress(value: float) -> None:
            loop.call_soon_threadsafe(self.progressChanged.emit, float(value))

        def blocking_call() -> Any:
            try:
                return engine.sim(model, "StopTime", str(stop_time), progress=progress)
            except TypeError:
                return engine.sim(model, "StopTime", str(stop_time))

        result = await asyncio.to_thread(blocking_call)
        return matlab_to_python(result)

    def _clear_task(self) -> None:
        self._current_task = None
        self._set_busy(False)

    def _on_simulation_completed(self, data: Any) -> None:
        self.statusMessage.emit("Simulation completed")
        self.simulationFinished.emit(data)
        self._clear_task()

    def _on_simulation_failed(self, message: str) -> None:
        LOG.exception("Simulation failed: %s", message)
        self.simulationFailed.emit(message)
        self._clear_task()

    def _on_simulation_cancelled(self) -> None:
        self.statusMessage.emit("Simulation cancelled")
        self._clear_task()

    @Slot()
    def cancelSimulation(self) -> None:
        if self._current_task is not None:
            self._current_task.cancel()

    @Slot(str, str, object)
    def setParameter(self, block_path: str, param: str, value: Any) -> None:
        asyncio.create_task(self._set_parameter(block_path, param, value))

    async def _set_parameter(self, block_path: str, param: str, value: Any) -> None:
        engine = await self._engine_manager.ensure_started()
        matlab_value = python_to_matlab(value)
        loop = asyncio.get_running_loop()
        await loop.run_in_executor(None, engine.set_param, block_path, param, matlab_value)
        self.statusMessage.emit(f"Parameter {param} updated")

    @Slot(str, str)
    def getParameter(self, block_path: str, param: str) -> None:
        asyncio.create_task(self._get_parameter(block_path, param))

    async def _get_parameter(self, block_path: str, param: str) -> None:
        engine = await self._engine_manager.ensure_started()
        loop = asyncio.get_running_loop()
        value = await loop.run_in_executor(None, engine.get_param, block_path, param)
        self.parameterFetched.emit(block_path, param, matlab_to_python(value))


QmlElement(MatlabApi)
