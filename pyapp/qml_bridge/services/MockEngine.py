"""Simple deterministic mock of the MATLAB Engine API."""

from __future__ import annotations

import random
import time
from typing import Any, Callable, Dict


class MockEngine:
    """Minimal mock that emulates a subset of the MATLAB Engine API."""

    def __init__(self) -> None:
        self._params: Dict[str, Any] = {}
        self._loaded_models: set[str] = set()

    # Standard MATLAB engine interface -------------------------------------------------
    def quit(self) -> None:  # pragma: no cover - trivial
        self._loaded_models.clear()
        self._params.clear()

    def load_system(self, model: str, nargout: int = 0) -> None:
        self._loaded_models.add(model)

    def sim(self, model: str, *args: Any, progress: Callable[[float], None] | None = None, **kwargs: Any) -> dict[str, Any]:
        if model not in self._loaded_models:
            self.load_system(model)

        for step in range(5):
            time.sleep(0.05)
            if progress is not None:
                progress((step + 1) / 5)

        return {
            "model": model,
            "success": True,
            "yout": [random.random() for _ in range(3)],
            "tout": [0.0, 0.5, 1.0],
        }

    def get_param(self, path: str, name: str) -> Any:
        return self._params.get((path, name), "")

    def set_param(self, path: str, name: str, value: Any) -> None:
        self._params[(path, name)] = value

    def eval(self, expression: str, nargout: int = 0) -> Any:  # pragma: no cover - deterministic
        if nargout == 0:
            return None
        return expression

    def feval(self, func: str, *args: Any, nargout: int = 1, **kwargs: Any) -> Any:
        if func == "exist":
            return 2  # mimic MATLAB returning >0 when something exists
        return {"func": func, "args": args, "kwargs": kwargs}
