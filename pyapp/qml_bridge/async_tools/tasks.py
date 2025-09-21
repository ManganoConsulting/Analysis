"""Utilities for running cancellable background tasks."""

from __future__ import annotations

import asyncio
from typing import Awaitable, Callable, TypeVar

from PySide6.QtCore import QObject, Signal

T = TypeVar("T")


class TaskHandle(QObject):
    """Wrap an :class:`asyncio.Task` and expose Qt signals."""

    completed = Signal(object)
    failed = Signal(str)
    cancelled = Signal()

    def __init__(self, task: asyncio.Task[T]) -> None:
        super().__init__()
        self._task: asyncio.Task[T] = task
        self._task.add_done_callback(self._on_done)

    def cancel(self) -> None:
        self._task.cancel()

    def task(self) -> asyncio.Task[T]:
        return self._task

    # Internal API -----------------------------------------------------------------
    def _on_done(self, task: asyncio.Future) -> None:
        if task.cancelled():
            self.cancelled.emit()
            return

        try:
            result = task.result()
        except Exception as exc:  # pragma: no cover - exercised in tests
            self.failed.emit(str(exc))
        else:
            self.completed.emit(result)


def run_cancellable(factory: Callable[[], Awaitable[T]]) -> TaskHandle:
    """Create and run a cancellable task using ``factory``."""

    task = asyncio.create_task(factory())
    return TaskHandle(task)
