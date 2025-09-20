"""Table model for constant parameters."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Sequence

from PySide6 import QtCore


@dataclass(slots=True)
class ConstantParameter:
    """Container describing a constant parameter entry."""

    name: str
    value: Any
    units: str | None = None
    description: str | None = None


class ConstantTableModel(QtCore.QAbstractTableModel):
    """Editable model backing the constants table."""

    headers = ("Name", "Value", "Units", "Description")

    def __init__(self, parameters: Sequence[ConstantParameter] | None = None, parent: QtCore.QObject | None = None) -> None:
        super().__init__(parent)
        self._parameters: list[ConstantParameter] = list(parameters) if parameters else []

    # ------------------------------------------------------------------
    # Qt model overrides
    # ------------------------------------------------------------------
    def rowCount(self, parent: QtCore.QModelIndex | None = None) -> int:  # type: ignore[override]
        if parent and parent.isValid():
            return 0
        return len(self._parameters)

    def columnCount(self, parent: QtCore.QModelIndex | None = None) -> int:  # type: ignore[override]
        return len(self.headers)

    def data(self, index: QtCore.QModelIndex, role: int = QtCore.Qt.DisplayRole) -> Any:  # type: ignore[override]
        if not index.isValid():
            return None
        param = self._parameters[index.row()]
        column = index.column()
        if role in (QtCore.Qt.DisplayRole, QtCore.Qt.EditRole):
            if column == 0:
                return param.name
            if column == 1:
                return param.value
            if column == 2:
                return param.units
            if column == 3:
                return param.description
        return None

    def setData(self, index: QtCore.QModelIndex, value: Any, role: int = QtCore.Qt.EditRole) -> bool:  # type: ignore[override]
        if role != QtCore.Qt.EditRole or not index.isValid():
            return False
        param = self._parameters[index.row()]
        column = index.column()
        if column == 1:
            param.value = value
        elif column == 2:
            param.units = value
        elif column == 3:
            param.description = value
        else:
            return False
        self.dataChanged.emit(index, index, [QtCore.Qt.DisplayRole, QtCore.Qt.EditRole])
        return True

    def flags(self, index: QtCore.QModelIndex) -> QtCore.Qt.ItemFlags:  # type: ignore[override]
        if not index.isValid():
            return QtCore.Qt.NoItemFlags
        base = QtCore.Qt.ItemIsSelectable | QtCore.Qt.ItemIsEnabled
        if index.column() in (1, 2, 3):
            base |= QtCore.Qt.ItemIsEditable
        return base

    def headerData(
        self,
        section: int,
        orientation: QtCore.Qt.Orientation,
        role: int = QtCore.Qt.DisplayRole,
    ) -> Any:  # type: ignore[override]
        if orientation == QtCore.Qt.Horizontal and role == QtCore.Qt.DisplayRole:
            return self.headers[section]
        return super().headerData(section, orientation, role)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def set_parameters(self, parameters: Sequence[ConstantParameter]) -> None:
        self.beginResetModel()
        self._parameters = list(parameters)
        self.endResetModel()

    def parameters(self) -> list[ConstantParameter]:
        return list(self._parameters)

    def append(self, parameter: ConstantParameter) -> None:
        self.beginInsertRows(QtCore.QModelIndex(), len(self._parameters), len(self._parameters))
        self._parameters.append(parameter)
        self.endInsertRows()

    def remove_rows(self, rows: Sequence[int]) -> None:
        for row in sorted(rows, reverse=True):
            self.beginRemoveRows(QtCore.QModelIndex(), row, row)
            del self._parameters[row]
            self.endRemoveRows()


__all__ = ["ConstantTableModel", "ConstantParameter"]
