"""Helpers for running MATLAB work in Qt threads."""

from __future__ import annotations

import inspect
import logging
from typing import Any, Callable

from PySide6 import QtCore

from .engine_manager import EngineManager

LOG = logging.getLogger(__name__)

ProgressCallback = Callable[[int, str], None]
MatlabCallable = Callable[[Any, ProgressCallback | None], Any]


class _MatlabWorker(QtCore.QObject):
    """Internal QObject that runs MATLAB work in a dedicated thread."""

    started = QtCore.Signal()
    progress = QtCore.Signal(int, str)
    finished = QtCore.Signal(object)
    error = QtCore.Signal(str)
    cancelled = QtCore.Signal()

    def __init__(
        self,
        engine_manager: EngineManager,
        func: Callable[..., Any],
        args: tuple[Any, ...],
        kwargs: dict[str, Any],
    ) -> None:
        super().__init__()
        self._engine_manager = engine_manager
        self._func = func
        self._args = args
        self._kwargs = kwargs
        self._cancelled = False

    @QtCore.Slot()
    def run(self) -> None:
        self.started.emit()
        if self._cancelled:
            LOG.debug("MATLAB task cancelled before start")
            self.cancelled.emit()
            return
        try:
            engine = self._engine_manager.get_engine()
            result = self._invoke(engine)
        except Exception as exc:  # pragma: no cover - integration only
            LOG.exception("MATLAB task raised an exception")
            self.error.emit(str(exc))
        else:
            if self._cancelled:
                self.cancelled.emit()
            else:
                self.finished.emit(result)

    def _progress(self, percent: int, message: str = "") -> None:
        if self._cancelled:
            return
        self.progress.emit(percent, message)

    def _invoke(self, engine: Any) -> Any:
        try:
            signature = inspect.signature(self._func)
        except (TypeError, ValueError):
            signature = None
        if signature and "progress_callback" in signature.parameters:
            kwargs = dict(self._kwargs)
            kwargs.setdefault("progress_callback", self._progress)
            return self._func(engine, *self._args, **kwargs)
        return self._func(engine, self._progress, *self._args, **self._kwargs)

    @QtCore.Slot()
    def request_cancel(self) -> None:
        LOG.debug("Cancellation requested for MATLAB task")
        self._cancelled = True


class MatlabJob(QtCore.QObject):
    """Represents a running MATLAB background task."""

    started = QtCore.Signal()
    progress = QtCore.Signal(int, str)
    finished = QtCore.Signal(object)
    error = QtCore.Signal(str)
    cancelled = QtCore.Signal()

    def __init__(self, description: str, worker: _MatlabWorker, thread: QtCore.QThread) -> None:
        super().__init__()
        self.description = description
        self._worker = worker
        self._thread = thread
        self._wire_signals()

    def _wire_signals(self) -> None:
        self._worker.started.connect(self.started)
        self._worker.progress.connect(self.progress)
        self._worker.finished.connect(self.finished)
        self._worker.error.connect(self.error)
        self._worker.cancelled.connect(self.cancelled)

    def cancel(self) -> None:
        self._worker.request_cancel()


class MatlabAsyncRunner(QtCore.QObject):
    """Factory for running MATLAB work without blocking the UI."""

    job_started = QtCore.Signal(str)
    job_finished = QtCore.Signal(str)
    job_failed = QtCore.Signal(str, str)

    def __init__(self, engine_manager: EngineManager, parent: QtCore.QObject | None = None) -> None:
        super().__init__(parent)
        self._engine_manager = engine_manager

    def run_task(self, description: str, func: Callable[..., Any], *args: Any, **kwargs: Any) -> MatlabJob:
        thread = QtCore.QThread(self)
        worker = _MatlabWorker(self._engine_manager, func, args, kwargs)
        worker.moveToThread(thread)

        job = MatlabJob(description, worker, thread)

        thread.started.connect(worker.run)
        worker.finished.connect(thread.quit)
        worker.error.connect(thread.quit)
        worker.cancelled.connect(thread.quit)
        thread.finished.connect(worker.deleteLater)
        thread.finished.connect(thread.deleteLater)

        job.started.connect(lambda: self.job_started.emit(description))
        job.finished.connect(lambda _res: self.job_finished.emit(description))
        job.error.connect(lambda message: self.job_failed.emit(description, message))

        thread.start()
        return job


__all__ = ["MatlabAsyncRunner", "MatlabJob"]
