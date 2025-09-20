# Stability Control PySide6 Port

This repository extends the existing MATLAB-based Analysis project with a
cross-platform PySide6 front-end that mirrors the Stability Control UI. The
Python interface delegates all numeric and Simulink work to MATLAB by way of the
MATLAB Engine for Python while providing a modern, responsive desktop
experience on Windows, macOS, and Linux.

## Original MATLAB UI overview

The MATLAB entry point at `+UserInterface/+StabilityControl/@Main/Main.m`
constructs a top-level figure containing several coordinated widgets:

* **Ribbon toolbar** – exposes project/workspace commands (`NewProject`,
  `LoadProject`, `SaveWorkspace`, `Run`, `RunSave`, reporting toggles, etc.) via a
  `ToolRibbon` object that emits events consumed by the main controller.
* **Project browser (left panel)** – a `StabTree` Java tree embedded inside a
  browser panel that lists projects, analyses, trim definitions, Simulink models,
  and batch runs. Selection events synchronize the rest of the UI.
* **Analysis tab group (right panel)** – each analysis gets a tab composed of:
  * A **manual/parameters tab group** hosting `TrimTaskCollection` views,
    constants parameter tables, and batch run card panels.
  * An **operating condition collection** (`OCCStabControl`) that manages
    operating-condition tables, plotting axes, SimViewer launchers, and
    reporting toggles.
  * Numerous listeners responding to tree updates, task edits, trim settings,
    report generation, and simulation progress.
* **Status/labels** – project labels and a project-level settings label rendered
  with Java Swing components.

The PySide6 port reproduces this layout with a `QMainWindow`, toolbar, project
browser dock, tabbed analysis views, constants table, operating-condition table,
log dock, and matplotlib preview panel. All command handlers have placeholders
for the original MATLAB callbacks and route their work through the engine
bridge.

## Project layout

```
pyapp/
  app.py                 # CLI entry point for launching the Qt app
  mainwindow.py          # Main window with menus, toolbars, docks, status bar
  views/
    stability_panel.py   # Manual/parameters tab contents and plot preview
  models/
    analysis_tree.py     # Tree model mirroring StabTree structure
    constant_table.py    # Editable model used by the constants table
  widgets/
    matplotlib_widget.py # Matplotlib canvas widget for result previews
  matlab_bridge/
    engine_manager.py    # Singleton-like MATLAB engine lifecycle manager
    matlab_async.py      # QThread-based async runner with progress/cancel hooks
    converters.py        # NumPy/pandas ↔ MATLAB conversion helpers
    api.py               # High-level wrappers for MATLAB commands/tasks
  util/
    paths.py             # Path helpers
    settings.py          # QSettings wrapper & High-DPI setup helpers
resources/
  icons/, qss/           # Placeholders for future assets

tests/
  test_engine_smoke.py   # Optional MATLAB engine smoke test
  test_ui_smoke.py       # Offscreen Qt instantiation smoke test
```

## Installation

1. **Create and activate a Python environment (3.10+ recommended)**

   ```bash
   python -m venv .venv
   source .venv/bin/activate  # (Windows) .venv\\Scripts\\activate
   ```

2. **Install Python dependencies**

   ```bash
   python -m pip install --upgrade pip
   python -m pip install -e .
   ```

3. **Install the MATLAB Engine for Python** (must match your MATLAB version)

   ```bash
   cd <MATLABROOT>/extern/engines/python
   python -m pip install .
   ```

   *MATLABROOT* is the output of `matlabroot` inside MATLAB. On Linux/macOS you
   may also need to export `LD_LIBRARY_PATH`/`DYLD_LIBRARY_PATH` so that the
   engine can locate MATLAB libraries when launched from Python.

4. **Optional:** add the project root to the MATLAB path if MATLAB is launched
   separately. The Python bridge automatically calls `addpath` on demand.

## Running the application

```bash
python -m pyapp.app
```

Command-line options:

* `--offscreen` – Forces the offscreen Qt backend (useful on CI or headless
  servers).
* `--log-level {DEBUG,INFO,...}` – Adjust Python logging verbosity.

The main window exposes familiar commands through menus, toolbars, and docked
widgets. MATLAB actions (project load, trim runs, report generation) are
executed asynchronously through `MatlabAsyncRunner`, which keeps the UI
responsive and streams progress to the status bar. Cancelling a job requests
cancellation from the worker thread and resets the progress bar.

## Testing

The automated tests use `pytest` + `pytest-qt`:

```bash
pytest -q
```

* `tests/test_ui_smoke.py` runs offscreen to confirm that `MainWindow` builds
  without errors.
* `tests/test_engine_smoke.py` is marked as an optional smoke test and is
  automatically skipped when the MATLAB Engine for Python is unavailable.

## MATLAB integration strategy

* `EngineManager` lazily starts a shared MATLAB session (`matlab.engine`) and
  exposes synchronous/asynchronous start helpers plus graceful shutdown.
* `MatlabAsyncRunner` wraps engine calls inside `QThread` workers and emits
  `started`, `progress`, `finished`, `error`, and `cancelled` signals that the
  UI uses to update the status bar and enable/disable controls.
* `api.py` contains the high-level functions invoked by the UI. The provided
  implementations call into MATLAB via `eng.eval`/`eng.addpath` and return
  placeholder data; replace these bodies with calls into the existing MATLAB
  classes (`UserInterface.StabilityControl.*`, `lacm.*`, etc.) as integration
  proceeds.
* `converters.py` centralises conversions between numpy/pandas structures and
  MATLAB matrices/structs, including safe handling of nested data.

## Migration notes & next steps

* **Wire actual MATLAB workflows:** `api.py` currently logs and returns mock
  data. Substitute real calls to the appropriate MATLAB functions (`Main`,
  `TrimTaskCollection`, Simulink simulations, report generation) and adjust the
  parameter passing/conversion helpers as needed.
* **Populate the tree and tabs with real data:** `AnalysisTreeModel` and
  `StabilityPanel` expose hooks for feeding the project hierarchy, trim
  configurations, constants, and operating conditions from MATLAB objects.
* **Plot synchronisation:** the matplotlib preview currently renders a static
  placeholder. Connect it to MATLAB simulation outputs (or streamed log signals)
  through the engine bridge.
* **SimViewer and axis docks:** the MATLAB UI launches SimViewer/axis panels via
  `OperCondCollObj` and `SimAxisColl`. Add corresponding Qt docks/widgets that
  interact with MATLAB/Simulink when those features are migrated.
* **Ribbon parity:** the MATLAB ribbon defines additional commands (batch
  management, logging toggles, report options) that are stubbed in the PySide6
  toolbar. Implement their logic and expose the required settings in the UI.
* **Error handling & cancellation:** MATLAB operations that support cancellation
  (e.g., `sim`, `parsim`) should receive cooperative cancellation hooks so that
  the `Cancel` button can stop long-running analyses.
* **Packaging:** for distribution, consider adding a PyInstaller/Briefcase
  recipe. Remember to bundle the MATLAB Runtime or require a local MATLAB
  installation.

## License

See `LICENSE` for licensing details; the new Python sources follow the same
terms as the original MATLAB project.
