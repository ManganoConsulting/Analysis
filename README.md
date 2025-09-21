# Analysis Qt Quick Migration

This repository now provides a cross-platform Python + Qt Quick (QML) user interface
that replaces the original MATLAB UI defined in
`+UserInterface/+StabilityControl/@Main/Main.m`.
The MATLAB algorithms, Simulink models, and data-processing code remain available
unchanged under `matlab_core/`, while the legacy MATLAB user interface has been
archived under `matlab_ui_legacy/` for reference.

## Project Layout

```
matlab_core/           # Original MATLAB analysis and Simulink assets
matlab_ui_legacy/      # Archived MATLAB UI code (read-only)
pyapp/                 # New Python application (PySide6 + QML)
  app.py               # CLI entry point
  main.py              # Bootstrap and QML import registration
  qml/                 # Qt Quick UI
  qml_bridge/          # Python <-> QML bridge, MATLAB Engine access
  util/                # Shared helpers (paths, settings)
  widgets/             # Optional QWidget bridge (Matplotlib stub)
tests/                 # Pytest based smoke tests for engine, QML, and async flows
README.md              # This guide
pyproject.toml         # Python project metadata & dependencies
LICENSE                # Licensing placeholder – refer to original repo guidance
```

## UI Map (MATLAB → QML)

| MATLAB Control                                    | Qt Quick Equivalent                                                   |
|---------------------------------------------------|-----------------------------------------------------------------------|
| Ribbon toolbar (load/save workspace, run trims)   | `ApplicationWindow.header` → `ToolBar` with `ToolButton` actions      |
| Tree of stability analysis tasks                  | `ListView` with checkable delegates showing name + description        |
| Manual analysis / constants / settings tabs       | `TabView` with `Tab` pages (Manual Analysis, Constants, Settings)     |
| Constant parameter table                          | `DataTable` (TableView) bound to `StabilityItemsModel`                |
| Simulation result log                             | `TextArea` updated with JSON-formatted MATLAB results                 |
| Modal progress dialog                             | `ProgressDialog` component displaying async progress & cancel option  |
| Status bar                                        | `ApplicationWindow.footer` → `ToolBar` with reactive status message   |

The QML layout mirrors the MATLAB UX structure while embracing modern Qt Quick
styling and responsive design tokens defined in `Theme.qml`.

## Requirements

* Python 3.10 or newer
* [MATLAB Engine for Python](https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html)
  (optional – required for real MATLAB/Simulink integration)
* Recommended Python dependencies (automatically installed via `pip`):
  * PySide6
  * qasync
  * numpy / scipy (used by MATLAB converters)
  * pytest (for tests)

## Installation

```bash
python -m venv .venv
source .venv/bin/activate       # On Windows use: .venv\Scripts\activate
pip install -U pip
pip install -e .
```

### MATLAB Engine Setup

1. Locate your MATLAB installation (e.g. `/usr/local/MATLAB/R2023b`).
2. Follow MathWorks instructions to install the engine bindings:
   ```bash
   cd /usr/local/MATLAB/R2023b/extern/engines/python
   python setup.py install
   ```
3. Ensure `matlab` is on your system `PATH` if you plan to launch MATLAB from
   the command line.

### Mock Mode (no MATLAB required)

The Python UI can run entirely without MATLAB using a deterministic mock engine
that mimics the subset of the MATLAB Engine API leveraged by the UI.

Enable mock mode via either:

```bash
# Environment variable
export ANALYSIS_USE_MOCK=1

# or CLI flag (preferred during development)
python -m pyapp.app --mock
```

Mock simulations emit progress ticks, produce repeatable fake data, and keep the
UI fully interactive for demonstrations or CI environments.

## Running the Application

```bash
# With active virtual environment
python -m pyapp.app            # Auto-loads pyapp/qml/Main.qml

# Force mock engine
python -m pyapp.app --mock

# Use an alternate QML entry point (for experiments)
python -m pyapp.app --qml path/to/OtherMain.qml
```

The main window opens with a ribbon-like toolbar, task browser, and tabs that
replicate the MATLAB interface. Simulation requests are dispatched asynchronously;
progress appears in a modal dialog that can be cancelled without freezing the UI.

## Testing

```bash
pytest
```

The test suite provides:

* `test_engine_smoke.py` – verifies the `EngineManager` mock fallback works.
* `test_qml_boot.py` – loads `Main.qml` headlessly (uses `QT_QPA_PLATFORM=offscreen`).
* `test_async_flow.py` – exercises the async MATLAB API and signal propagation.

## QML & Async Patterns

* `Theme.qml` defines design tokens (colors, spacing, radii, typography) with light
  and dark palettes. `UiController` synchronises the runtime theme with `QSettings`.
* QML components (`ProgressDialog.qml`, `DataTable.qml`, `Controls.qml`) centralise
  shared UI patterns for consistency across tabs.
* `MatlabApi` exposes high-level async slots to QML. Blocking MATLAB operations
  are offloaded to background threads via `asyncio.to_thread`, with progress updates
  forwarded to QML using Qt signals.
* `EngineManager` lazily starts (or mocks) the MATLAB engine and ensures a single
  shared instance per process.
* `MockEngine` enables full UI exploration without a MATLAB install, emitting
  predictable results for demos and automated tests.

## MATLAB Code

* All non-UI MATLAB functionality now resides in `matlab_core/` with its original
  folder structure.
* The former MATLAB UI is preserved untouched in `matlab_ui_legacy/` for reference
  and parity checks during further migration work.

## Known Gaps & TODOs

* Detailed mapping of every MATLAB ribbon command still requires domain expertise.
  TODO markers are left where exact MATLAB callbacks should be wired into the
  Python/QML layer.
* Plotting currently relies on textual JSON output; integrate Qt Charts or a
  QQuickWidget-wrapped Matplotlib view when high-fidelity plots are required.
* Additional MATLAB parameter editing (constants tab) should be connected to real
  MATLAB data structures via `MatlabApi.getParameter` / `setParameter` once the
  corresponding MATLAB APIs are identified.

## License

See `LICENSE` for licensing guidance. Consult the original `License Instructions.docx`
in `matlab_core/` for authoritative terms.
