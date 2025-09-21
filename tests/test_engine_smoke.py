from __future__ import annotations

import asyncio

import pytest

from pyapp.qml_bridge.services.EngineManager import EngineManager


@pytest.mark.asyncio
async def test_engine_manager_uses_mock(monkeypatch) -> None:
    monkeypatch.setenv("ANALYSIS_USE_MOCK", "1")
    manager = EngineManager()
    engine = await manager.ensure_started()
    assert hasattr(engine, "sim")

    result = await asyncio.to_thread(engine.sim, "mock_model")
    assert result["success"] is True
    await manager.stop()
