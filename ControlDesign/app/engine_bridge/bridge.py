"""Abstractions for talking to the MATLAB Engine."""
from __future__ import annotations

import logging
import threading
import time
from dataclasses import dataclass
from typing import Any, Dict, Optional

logger = logging.getLogger(__name__)


@dataclass
class BridgeConfig:
    """Configuration controlling how MATLAB is launched."""

    start_shared: bool = False
    visible: bool = False


class MatlabBridge:
    """Wrapper around the MATLAB Engine with a mock fallback."""

    def __init__(self, config: Optional[BridgeConfig] = None, mock: bool = False) -> None:
        self._config = config or BridgeConfig()
        self._mock = mock
        self._engine: Any = None
        self._matlab_engine_module: Any = None
        self._lock = threading.Lock()
        self._started = False
        self._last_model: Optional[str] = None
        self._mock_status = "stopped"
        self._mock_workspace: Dict[str, Any] = {}

    # ------------------------------------------------------------------
    # public API
    def start(self) -> str:
        """Start the MATLAB engine or the mock replacement."""

        if self._mock:
            with self._lock:
                logger.debug("Starting MATLAB bridge in mock mode")
                self._started = True
            time.sleep(0.05)
            return "OK"

        if self._started and self._engine is not None:
            logger.debug("MATLAB engine already running")
            return "OK"

        try:
            if self._matlab_engine_module is None:
                import matlab.engine as matlab_engine  # type: ignore[import]

                self._matlab_engine_module = matlab_engine
        except ImportError as exc:
            logger.exception("Unable to import matlab.engine")
            return f"ERROR: {exc}"

        try:
            logger.debug("Starting MATLAB engine with config %s", self._config)
            start_options = self._start_options()
            if self._config.start_shared:
                names = self._matlab_engine_module.find_matlab()
                if names:
                    self._engine = self._matlab_engine_module.connect_matlab(names[0])
                else:
                    self._engine = self._matlab_engine_module.start_matlab(*start_options)
            else:
                self._engine = self._matlab_engine_module.start_matlab(*start_options)
            self._started = True
            logger.info("MATLAB engine session initialised")
            return "OK"
        except Exception as exc:  # pragma: no cover - defensive logging
            logger.exception("Failed to start MATLAB engine")
            self._engine = None
            self._started = False
            return f"ERROR: {exc}"

    def stop(self) -> str:
        """Terminate the MATLAB session."""

        if self._mock:
            with self._lock:
                self._started = False
                self._mock_status = "stopped"
                self._mock_workspace.clear()
            return "OK"

        if self._engine is None:
            return "OK"

        try:
            self._engine.quit()
            logger.info("MATLAB engine session terminated")
            return "OK"
        except Exception as exc:  # pragma: no cover - defensive logging
            logger.exception("Failed to stop MATLAB engine")
            return f"ERROR: {exc}"
        finally:
            self._engine = None
            self._started = False

    def eval(self, code: str, nargout: int = 0) -> Any:
        """Evaluate MATLAB code."""

        if self._mock:
            logger.debug("Mock eval: %s", code)
            return None

        engine = self._require_engine()
        return engine.eval(code, nargout=nargout)

    def feval(self, func: str, *args: Any, nargout: int = 1) -> Any:
        """Call a MATLAB function."""

        if self._mock:
            logger.debug("Mock feval: %s", func)
            return None

        engine = self._require_engine()
        return engine.feval(func, *args, nargout=nargout)

    def open_model(self, mdl: str) -> None:
        """Load a Simulink model."""

        if self._mock:
            with self._lock:
                self._last_model = mdl
            logger.debug("Mock open model: %s", mdl)
            time.sleep(0.05)
            return

        engine = self._require_engine()
        engine.load_system(mdl, nargout=0)
        self._last_model = mdl

    def set_params(self, mdl: str, **kwargs: Any) -> None:
        """Set multiple parameters on a model."""

        if not kwargs:
            return

        if self._mock:
            with self._lock:
                self._mock_workspace.setdefault("params", {})
                self._mock_workspace["params"].update(kwargs)
            logger.debug("Mock set_params for %s: %s", mdl, kwargs)
            return

        engine = self._require_engine()
        args = []
        for key, value in kwargs.items():
            args.extend([key, value])
        engine.set_param(mdl, *args, nargout=0)

    def get_status(self, mdl: Optional[str] = None) -> str:
        """Return the current simulation status."""

        mdl = mdl or self._last_model
        if mdl is None:
            raise RuntimeError("No model has been opened yet")

        if self._mock:
            with self._lock:
                status = self._mock_status
            logger.debug("Mock get_status(%s) -> %s", mdl, status)
            return status

        engine = self._require_engine()
        status = engine.get_param(mdl, "SimulationStatus")
        return str(status)

    def run_sim(self, mdl: str, stop_time: str = "10", wait: bool = True) -> Dict[str, Any]:
        """Run a simulation and return collected outputs."""

        if self._mock:
            return self._run_sim_mock(mdl, stop_time, wait)

        engine = self._require_engine()
        self.open_model(mdl)
        self.set_params(mdl, StopTime=stop_time)
        engine.set_param(mdl, "SimulationCommand", "start", nargout=0)
        logger.info("Simulation started for %s", mdl)

        if wait:
            status = self._wait_for_completion(mdl)
        else:
            status = self.get_status(mdl)

        result: Dict[str, Any] = {
            "model": mdl,
            "stop_time": stop_time,
            "status": status,
        }

        try:
            workspace = engine.workspace
            value = workspace["y"]
            result["y"] = self._convert_workspace_value(value)
        except KeyError:
            logger.debug("Workspace does not contain 'y'")
            result["y"] = None
        except Exception as exc:  # pragma: no cover - defensive logging
            logger.warning("Failed to read 'y' from workspace: %s", exc)
            result["y"] = None

        return result

    # ------------------------------------------------------------------
    # internals
    def _start_options(self) -> tuple[str, ...]:
        if self._config.visible:
            return ("-desktop",)
        return ("-automation",)

    def _require_engine(self) -> Any:
        if not self._started or self._engine is None:
            raise RuntimeError("MATLAB engine has not been started")
        return self._engine

    def _wait_for_completion(self, mdl: str) -> str:
        status = self.get_status(mdl)
        # Poll until MATLAB reports that the simulation has stopped
        while status.lower() in {"initializing", "running", "busy"}:
            time.sleep(0.25)
            status = self.get_status(mdl)
        logger.info("Simulation completed for %s with status %s", mdl, status)
        return status

    def _convert_workspace_value(self, value: Any) -> Any:
        """Convert MATLAB workspace values into native Python types."""

        try:
            import numpy as np  # type: ignore
        except Exception:  # pragma: no cover - optional dependency
            np = None  # type: ignore

        if hasattr(value, "_data") and hasattr(value, "size"):
            data = list(value)
            if len(data) == 1:
                return data[0]
            return data

        if np is not None:
            try:
                return np.array(value).tolist()
            except Exception:  # pragma: no cover - best effort
                pass

        return value

    def _run_sim_mock(self, mdl: str, stop_time: str, wait: bool) -> Dict[str, Any]:
        with self._lock:
            self._last_model = mdl
            self._mock_status = "running"
        logger.debug("Mock simulation started for %s", mdl)
        time.sleep(0.1)
        if wait:
            time.sleep(0.2)
        with self._lock:
            self._mock_status = "stopped"
        result = {
            "model": mdl,
            "stop_time": stop_time,
            "status": "stopped",
            "y": [0.0, 0.5, 1.0],
        }
        logger.debug("Mock simulation completed for %s", mdl)
        return result
