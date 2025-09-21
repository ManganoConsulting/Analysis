"""Manage the lifecycle of the MATLAB Engine for Python."""

from __future__ import annotations

import asyncio
import logging
import os
from typing import Any

from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtQml import QmlElement

from .MockEngine import MockEngine

LOG = logging.getLogger(__name__)

QML_IMPORT_NAME = "Analysis"
QML_IMPORT_MAJOR_VERSION = 1


try:  # pragma: no cover - optional dependency during CI
    import matlab.engine
except Exception:  # pragma: no cover - handled gracefully at runtime
    matlab = None
else:  # pragma: no cover
    matlab = matlab  # type: ignore[assignment]


class EngineManager(QObject):
    """Singleton-style wrapper that exposes the MATLAB engine to QML."""

    engineChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._engine: Any | None = None
        self._lock = asyncio.Lock()

    @property
    def use_mock(self) -> bool:
        return os.getenv("ANALYSIS_USE_MOCK", "0") == "1"

    @Slot(result=bool)
    def is_running(self) -> bool:
        return self._engine is not None

    async def _start_real_engine(self) -> Any:
        assert matlab is not None
        loop = asyncio.get_running_loop()
        LOG.info("Starting MATLAB engine in background thread")
        return await loop.run_in_executor(None, matlab.engine.start_matlab)

    async def ensure_started(self) -> Any:
        """Ensure an engine instance exists and return it."""

        if self._engine is not None:
            return self._engine

        async with self._lock:
            if self._engine is not None:
                return self._engine

            if self.use_mock or matlab is None:
                LOG.info("Using mock MATLAB engine")
                self._engine = MockEngine()
            else:
                self._engine = await self._start_real_engine()

            self.engineChanged.emit()
            return self._engine

    async def stop(self) -> None:
        """Stop the MATLAB engine if running."""

        async with self._lock:
            if self._engine is None:
                return

            engine, self._engine = self._engine, None

        if hasattr(engine, "quit"):
            loop = asyncio.get_running_loop()
            await loop.run_in_executor(None, engine.quit)  # type: ignore[arg-type]

        self.engineChanged.emit()

    def engine(self) -> Any | None:
        """Return the current engine (may be ``None``)."""

        return self._engine


# Register with QML
QmlElement(EngineManager)
