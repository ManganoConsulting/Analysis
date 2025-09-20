"""Helpers for converting data between MATLAB and Python."""

from __future__ import annotations

from typing import Any, Mapping

import numpy as np
import pandas as pd

try:  # pragma: no cover - optional dependency
    import matlab  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    matlab = None  # type: ignore


def to_matlab_numeric(data: Any) -> Any:
    """Convert *data* into a ``matlab.double`` array.

    Parameters
    ----------
    data:
        Numeric value or array-like structure.
    """

    if matlab is None:
        raise RuntimeError("matlab package is not available.")

    array = np.asarray(data, dtype=float)
    return matlab.double(array.tolist())


def from_matlab_array(array: Any) -> np.ndarray:
    """Convert a MATLAB numeric array to :class:`numpy.ndarray`."""

    return np.asarray(array, dtype=float)


def dataframe_to_matlab_table(frame: pd.DataFrame) -> Any:
    """Convert a pandas DataFrame into a MATLAB table struct."""

    if matlab is None:
        raise RuntimeError("matlab package is not available.")

    data = {col: to_matlab_numeric(frame[col].to_numpy()) for col in frame.columns}
    return matlab.struct(**data)  # type: ignore[attr-defined]


def matlab_struct_to_dict(struct: Any) -> dict[str, Any]:
    """Convert a MATLAB struct into a Python dictionary."""

    result: dict[str, Any] = {}
    if struct is None:
        return result
    for key in struct._fieldnames:  # type: ignore[attr-defined]
        value = getattr(struct, key)
        if hasattr(value, "_fieldnames"):
            result[key] = matlab_struct_to_dict(value)
        else:
            result[key] = value
    return result


def dict_to_matlab_struct(data: Mapping[str, Any]) -> Any:
    """Convert a nested mapping into a MATLAB struct."""

    if matlab is None:
        raise RuntimeError("matlab package is not available.")

    converted: dict[str, Any] = {}
    for key, value in data.items():
        if isinstance(value, Mapping):
            converted[key] = dict_to_matlab_struct(value)
        elif isinstance(value, (list, tuple, set)):
            converted[key] = matlab.cell(list(value))  # type: ignore[attr-defined]
        else:
            converted[key] = value
    return matlab.struct(**converted)  # type: ignore[attr-defined]


__all__ = [
    "to_matlab_numeric",
    "from_matlab_array",
    "dataframe_to_matlab_table",
    "matlab_struct_to_dict",
    "dict_to_matlab_struct",
]
