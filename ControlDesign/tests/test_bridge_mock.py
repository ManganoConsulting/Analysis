"""Tests for the mock MATLAB bridge implementation."""
from __future__ import annotations

from app.engine_bridge import MatlabBridge


def test_mock_bridge_runs_simulation() -> None:
    bridge = MatlabBridge(mock=True)
    assert bridge.start() == "OK"

    bridge.open_model("vdp")
    bridge.set_params("vdp", StopTime="5")

    status = bridge.get_status()
    assert status == "stopped"

    result = bridge.run_sim("vdp", stop_time="3", wait=True)
    assert result["model"] == "vdp"
    assert result["status"] == "stopped"
    assert result["y"] is not None

    assert bridge.stop() == "OK"
