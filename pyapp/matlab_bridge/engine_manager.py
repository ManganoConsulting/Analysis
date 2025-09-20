"""MATLAB Engine lifecycle management."""

from __future__ import annotations

import threading
from dataclasses import dataclass
from typing import Any

try:  # pragma: no cover - optional dependency
    import matlab.engine  # type: ignore[attr-defined]
except ImportError:  # pragma: no cover - optional dependency
    matlab = None  # type: ignore[assignment]
else:  # pragma: no cover - runtime only
    matlab = matlab.engine  # type: ignore[assignment]


@dataclass(slots=True)
class EngineStatus:
    """Status information returned by :class:`EngineManager`."""

    started: bool
    matlab_version: str | None


class EngineManager:
    """Manage a shared MATLAB Engine instance."""

    def __init__(self) -> None:
        self._engine: Any | None = None
        self._lock = threading.RLock()

    # ------------------------------------------------------------------
    # Capability helpers
    # ------------------------------------------------------------------
    @staticmethod
    def engine_available() -> bool:
        """Return ``True`` if the MATLAB Engine for Python can be imported."""
        return matlab is not None

    # ------------------------------------------------------------------
    # Engine lifecycle
    # ------------------------------------------------------------------
    def start(self, **kwargs: Any) -> Any:
        """Start (or return) the cached MATLAB engine instance."""
        if not self.engine_available():
            raise RuntimeError(
                "matlab.engine is not available. Install the MATLAB Engine for Python first."
            )

        with self._lock:
            if self._engine is None:
                self._engine = matlab.start_matlab(**kwargs)  # type: ignore[operator]
        return self._engine

    def start_async(self, **kwargs: Any) -> Any:
        """Start MATLAB asynchronously, returning the future object."""
        if not self.engine_available():
            raise RuntimeError(
                "matlab.engine is not available. Install the MATLAB Engine for Python first."
            )
        future = matlab.start_matlab(async_=True, **kwargs)  # type: ignore[operator]
        return future

    def get_engine(self) -> Any:
        """Return the active engine, starting it if necessary."""
        return self.start()

    def stop(self) -> None:
        """Shut down the shared engine."""
        with self._lock:
            if self._engine is not None:
                try:
                    self._engine.quit()
                finally:
                    self._engine = None

    # ------------------------------------------------------------------
    # Diagnostics
    # ------------------------------------------------------------------
    def status(self) -> EngineStatus:
        """Return a lightweight status dataclass."""
        if self._engine is None:
            return EngineStatus(False, None)
        version = None
        try:
            version = str(self._engine.eval("version", nargout=1))
        except Exception:  # pragma: no cover - best effort only
            version = None
        return EngineStatus(True, version)


__all__ = ["EngineManager", "EngineStatus"]
