"""Smoke tests for the MATLAB engine bridge."""

from __future__ import annotations

import pytest

pytest.importorskip("matlab.engine", reason="MATLAB Engine for Python is not installed")

from pyapp.matlab_bridge.engine_manager import EngineManager


@pytest.mark.engine
def test_engine_starts_and_evaluates():
    manager = EngineManager()
    engine = manager.start()
    try:
        result = engine.eval("1+1", nargout=1)
        assert float(result) == 2.0
    finally:
        manager.stop()
