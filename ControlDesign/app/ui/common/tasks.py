"""Generic task runner built on top of :class:`QThreadPool`."""
from __future__ import annotations

import logging
from typing import Any, Callable

from PySide6.QtCore import QObject, QRunnable, QThreadPool, Signal, Slot, QTimer

logger = logging.getLogger(__name__)


class TaskSignals(QObject):
    """Signals exposed by background tasks."""

    started = Signal()
    progress = Signal(int)
    result = Signal(object)
    error = Signal(str)
    finished = Signal()


class _TaskRunnable(QRunnable):
    """Internal runnable that executes work on a global thread pool."""

    def __init__(self, fn: Callable[..., Any], args: tuple[Any, ...], kwargs: dict[str, Any], signals: TaskSignals) -> None:
        super().__init__()
        self._fn = fn
        self._args = args
        self._kwargs = kwargs
        self._signals = signals
        self.setAutoDelete(True)

    @Slot()
    def run(self) -> None:  # pragma: no cover - exercised via TaskRunner
        self._signals.started.emit()
        try:
            result = self._fn(*self._args, **self._kwargs)
        except Exception as exc:  # pragma: no cover - log for visibility
            logger.exception("Task raised an exception")
            self._signals.error.emit(str(exc))
        else:
            self._signals.result.emit(result)
        finally:
            self._signals.finished.emit()


class TaskRunner(QObject):
    """Convenience wrapper to submit background jobs."""

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._pool = QThreadPool.globalInstance()

    def run(self, fn: Callable[..., Any], *args: Any, **kwargs: Any) -> TaskSignals:
        """Schedule ``fn`` for execution and return its signals."""

        signals = TaskSignals()
        # If the caller provided a progress callback hook, forward the signal
        if "progress_callback" in kwargs:
            progress_callback = kwargs["progress_callback"]
            if progress_callback is None:
                kwargs["progress_callback"] = signals.progress.emit
        runnable = _TaskRunnable(fn, args, kwargs, signals)

        def _start():
            self._pool.start(runnable)

        QTimer.singleShot(0, _start)
        return signals
