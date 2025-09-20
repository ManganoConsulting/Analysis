"""Tree model used for the project browser."""

from __future__ import annotations

from typing import Sequence

from PySide6 import QtGui


class AnalysisTreeModel(QtGui.QStandardItemModel):
    """Qt item model representing the project/analysis tree."""

    def __init__(self, parent: QtGui.QObject | None = None) -> None:
        super().__init__(parent)
        self.setHorizontalHeaderLabels(["Project Browser"])
        self.populate_default()

    # ------------------------------------------------------------------
    # Population helpers
    # ------------------------------------------------------------------
    def populate_default(self) -> None:
        """Populate the tree with placeholder structure."""

        self.clear()
        self.setHorizontalHeaderLabels(["Project Browser"])
        project_item = QtGui.QStandardItem("Current Project")
        project_item.setEditable(False)

        analysis_root = QtGui.QStandardItem("Analyses")
        analysis_root.setEditable(False)

        tasks_root = QtGui.QStandardItem("Trim Tasks")
        tasks_root.setEditable(False)

        project_item.appendRow(analysis_root)
        project_item.appendRow(tasks_root)
        self.appendRow(project_item)
        self.invisibleRootItem().setChild(0, 0, project_item)

    def set_analyses(self, analyses: Sequence[str]) -> None:
        """Replace the current analysis children with *analyses*."""

        project_item = self.item(0, 0)
        if project_item is None:
            self.populate_default()
            project_item = self.item(0, 0)
        analysis_root = project_item.child(0)
        analysis_root.removeRows(0, analysis_root.rowCount())
        for analysis in analyses:
            item = QtGui.QStandardItem(analysis)
            item.setEditable(False)
            analysis_root.appendRow(item)

    def add_analysis(self, name: str) -> None:
        """Append a single analysis node."""

        project_item = self.item(0, 0)
        if project_item is None:
            self.populate_default()
            project_item = self.item(0, 0)
        analysis_root = project_item.child(0)
        analysis_root.appendRow(QtGui.QStandardItem(name))


__all__ = ["AnalysisTreeModel"]
