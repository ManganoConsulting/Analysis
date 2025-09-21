"""Optional QWidget bridge for Matplotlib based plots."""

from __future__ import annotations

from typing import Optional

from PySide6.QtWidgets import QVBoxLayout, QWidget

try:  # pragma: no cover - Matplotlib may be unavailable
    from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg
    from matplotlib.figure import Figure
except Exception:  # pragma: no cover - gracefully degrade when missing
    FigureCanvasQTAgg = None  # type: ignore[assignment]
    Figure = None  # type: ignore[assignment]


class MatplotlibView(QWidget):
    """Embed a Matplotlib figure inside Qt when available."""

    def __init__(self, parent: Optional[QWidget] = None) -> None:
        super().__init__(parent)

        if FigureCanvasQTAgg is None or Figure is None:
            raise RuntimeError("Matplotlib is not installed.")

        self._figure = Figure(figsize=(4, 3))
        self._canvas = FigureCanvasQTAgg(self._figure)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self._canvas)

    def figure(self) -> Figure:
        return self._figure

    def canvas(self) -> FigureCanvasQTAgg:
        return self._canvas
