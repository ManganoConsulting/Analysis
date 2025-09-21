"""Helpers for converting between MATLAB and Python data types."""

from __future__ import annotations

from typing import Any, Dict, Mapping

try:  # pragma: no cover - optional dependency
    import matlab
except Exception:  # pragma: no cover - fallback when engine missing
    matlab = None  # type: ignore[assignment]

try:  # pragma: no cover - optional dependency
    import numpy as np
except Exception:  # pragma: no cover
    np = None  # type: ignore[assignment]


def python_to_matlab(value: Any) -> Any:
    """Best-effort conversion of Python values to MATLAB friendly types."""

    if matlab is None:
        return value

    if np is not None and isinstance(value, np.ndarray):
        return matlab.double(value.tolist())
    if isinstance(value, (list, tuple)):
        return matlab.double([[float(x) for x in value]])
    if isinstance(value, Mapping):
        struct = matlab.struct()
        for key, val in value.items():
            setattr(struct, key, python_to_matlab(val))
        return struct
    return value


def matlab_to_python(value: Any) -> Any:
    """Best-effort conversion of MATLAB values to native Python types."""

    if matlab is None:
        return value

    if isinstance(value, matlab.double):
        return [list(row) for row in value]
    if isinstance(value, matlab.uint8):  # pragma: no cover - depends on engine
        return bytes(value)
    if isinstance(value, matlab.struct):
        result: Dict[str, Any] = {}
        for key in value._fieldnames:
            result[key] = matlab_to_python(getattr(value, key))
        return result
    return value
