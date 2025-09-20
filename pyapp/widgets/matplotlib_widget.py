"""Matplotlib canvas wrapper used by the UI."""

from __future__ import annotations


from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg
from matplotlib.figure import Figure
from PySide6 import QtWidgets


class MatplotlibWidget(QtWidgets.QWidget):
    """Simple matplotlib canvas embedded in a Qt widget."""

    def __init__(self, parent: QtWidgets.QWidget | None = None) -> None:
        super().__init__(parent)
        self.figure = Figure(figsize=(5, 3))
        self.canvas = FigureCanvasQTAgg(self.figure)

        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.canvas)

    def plot_placeholder(self) -> None:
        """Render a placeholder plot to indicate the area."""

        self.figure.clear()
        ax = self.figure.add_subplot(111)
        ax.plot([0, 1, 2, 3], [0, 1, 0, 1], marker="o")
        ax.set_xlabel("Time (s)")
        ax.set_ylabel("Response")
        ax.set_title("Simulation Output")
        self.canvas.draw_idle()


__all__ = ["MatplotlibWidget"]
