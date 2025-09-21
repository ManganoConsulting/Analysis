"""Model representing stability analysis tasks."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable, List

from PySide6.QtCore import QAbstractTableModel, QModelIndex, Qt
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Analysis"
QML_IMPORT_MAJOR_VERSION = 1


@dataclass
class StabilityItem:
    """Container for a single row in the stability table."""

    name: str
    description: str
    selected: bool = False
    status: str = "Idle"


class StabilityItemsModel(QAbstractTableModel):
    """Qt model exposing the MATLAB trim/analysis tasks to QML."""

    NameRole = Qt.UserRole + 1
    DescriptionRole = Qt.UserRole + 2
    SelectedRole = Qt.UserRole + 3
    StatusRole = Qt.UserRole + 4

    _role_names = {
        NameRole: b"name",
        DescriptionRole: b"description",
        SelectedRole: b"selected",
        StatusRole: b"status",
    }

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._items: List[StabilityItem] = []

    def rowCount(self, parent: QModelIndex | None = None) -> int:  # type: ignore[override]
        if parent is not None and parent.isValid():
            return 0
        return len(self._items)

    def columnCount(self, parent: QModelIndex | None = None) -> int:  # type: ignore[override]
        return 4

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole) -> Any:  # type: ignore[override]
        if not index.isValid() or not (0 <= index.row() < len(self._items)):
            return None

        item = self._items[index.row()]

        if role in (Qt.DisplayRole, self.NameRole):
            return item.name
        if role == self.DescriptionRole:
            return item.description
        if role == self.SelectedRole:
            return item.selected
        if role == self.StatusRole:
            return item.status
        return None

    def roleNames(self) -> dict[int, bytes]:  # type: ignore[override]
        return dict(self._role_names)

    def flags(self, index: QModelIndex) -> Qt.ItemFlags:  # type: ignore[override]
        if not index.isValid():
            return Qt.ItemIsEnabled
        return Qt.ItemIsEnabled | Qt.ItemIsSelectable | Qt.ItemIsEditable

    def setData(self, index: QModelIndex, value: Any, role: int = Qt.EditRole) -> bool:  # type: ignore[override]
        if not index.isValid() or not (0 <= index.row() < len(self._items)):
            return False

        item = self._items[index.row()]
        changed = False

        if role in (Qt.EditRole, Qt.DisplayRole, self.NameRole):
            item.name = str(value)
            changed = True
        elif role == self.DescriptionRole:
            item.description = str(value)
            changed = True
        elif role == self.SelectedRole:
            item.selected = bool(value)
            changed = True
        elif role == self.StatusRole:
            item.status = str(value)
            changed = True

        if changed:
            self.dataChanged.emit(index, index, [role])
        return changed

    def update_items(self, items: Iterable[StabilityItem]) -> None:
        """Replace the contents of the model with ``items``."""

        new_items = list(items)
        self.beginResetModel()
        self._items = new_items
        self.endResetModel()

    def to_dicts(self) -> list[dict[str, Any]]:
        """Return the model data as a list of dictionaries."""

        return [
            {
                "name": item.name,
                "description": item.description,
                "selected": item.selected,
                "status": item.status,
            }
            for item in self._items
        ]


# Register with QML using the module level constants above.
QmlElement(StabilityItemsModel)
