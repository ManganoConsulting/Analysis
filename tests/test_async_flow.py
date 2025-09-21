from __future__ import annotations

import asyncio

import pytest
from PySide6.QtCore import QCoreApplication

from pyapp.qml_bridge.services.MatlabApi import MatlabApi


@pytest.mark.asyncio
async def test_async_simulation_flow(monkeypatch) -> None:
    monkeypatch.setenv("ANALYSIS_USE_MOCK", "1")

    app = QCoreApplication.instance() or QCoreApplication([])
    api = MatlabApi()

    finished = asyncio.Event()
    result_holder: dict[str, object] = {}

    def on_finished(data: object) -> None:
        result_holder["data"] = data
        finished.set()

    api.simulationFinished.connect(on_finished)

    assert api.runSimulation("mock_model", 1.0)

    await asyncio.wait_for(finished.wait(), timeout=10)

    assert result_holder["data"]["success"] is True
    app.quit()
