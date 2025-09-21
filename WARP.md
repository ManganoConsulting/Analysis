# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project overview
- This repo replaces a legacy MATLAB GUI with a cross-platform Python + Qt Quick (QML) front-end while keeping the original MATLAB/Simulink analysis code under matlab_core/.
- The new UI lives under pyapp/ (PySide6 + qasync) and mirrors the MATLAB UX: task list, tabs (Manual Analysis, Constants, Settings), progress dialog, and status bar. The old MATLAB UI is referenced in README as archived under matlab_ui_legacy/.

Core commands (Windows PowerShell examples)
- Create a virtual environment and install the project (with dev extras for tests/optional plotting):
  - py -3.10 -m venv .venv
  - .venv\Scripts\Activate.ps1
  - python -m pip install -U pip
  - python -m pip install -e .[dev]

- Run the application (default QML entry point):
  - python -m pyapp.app

- Force mock MATLAB engine (no MATLAB required):
  - python -m pyapp.app --mock
  - or set: $env:ANALYSIS_USE_MOCK = '1'

- Use an alternate QML entry point:
  - python -m pyapp.app --qml C:\\path\\to\\OtherMain.qml

- Run tests headlessly (QML offscreen, mock engine):
  - $env:QT_QPA_PLATFORM = 'offscreen'
  - $env:ANALYSIS_USE_MOCK = '1'
  - pytest -q

- Run a single test or test case:
  - pytest -q tests\test_engine_smoke.py::test_engine_manager_uses_mock
  - pytest -q -k async

- Lint/format: none configured in this repo.

MATLAB Engine (optional)
- For real MATLAB/Simulink integration, install the MATLAB Engine for Python per MathWorks docs, then ensure matlab is on PATH. If not installed, the app and tests can run in mock mode as above.

High-level architecture
- Entry and bootstrap
  - pyapp/app.py: CLI entry point. Sets ANALYSIS_USE_MOCK when --mock is passed, initializes QGuiApplication, integrates asyncio via qasync, and loads QML (from pyapp/qml/Main.qml by default).
  - pyapp/main.py: configure_app() sets QML import path, application metadata, and imports qml_bridge modules for their QmlElement registrations.

- QML bridge (registered with QML via @QmlElement)
  - EngineManager: lazily starts a single MATLAB engine instance; selects MockEngine when ANALYSIS_USE_MOCK=1 or engine is unavailable. Exposes engineChanged and async ensure_started()/stop().
  - MatlabApi: high-level async API for QML. Methods openModel, runSimulation (with cancel via TaskHandle), setParameter/getParameter. Emits busy/progress/status and simulationFinished/simulationFailed.
  - UiController: ViewModel used directly by QML. Owns MatlabApi and StabilityItemsModel, wires signals, exposes theme persistence, and provides convenience slots (openModel, runSimulation, toggleTheme, etc.).
  - StabilityItemsModel: Qt table model exposing a small set of placeholder analysis tasks to the UI; supports checkable items and status.
  - Converters: best-effort conversion between Python types and MATLAB types (handles numpy arrays when available, matlab.struct to dict, etc.).

- Async pattern
  - qml_bridge/async_tools/tasks.py provides TaskHandle (Qt signals: completed/failed/cancelled) and run_cancellable() to run cancellable background tasks that interop cleanly with the Qt event loop.
  - MatlabApi uses asyncio.to_thread or an executor to call blocking MATLAB operations; progress callbacks marshal updates back to the Qt thread via signals.

- UI structure (QML)
  - Main.qml defines the ApplicationWindow with a header toolbar (Open, Run, Cancel, theme toggle), menu bar, a left task ListView bound to StabilityItemsModel, and a TabView (Manual Analysis, Constants, Settings). A modal ProgressDialog reflects MatlabApi.busy/progress.
  - Theme.qml is a singleton providing design tokens (colors, radii, spacing, font sizes) with light/dark palettes.

- MATLAB code
  - matlab_core/ retains the original MATLAB analysis and Simulink assets, unaffected by the Python UI. The Python app interacts through EngineManager/MatlabApi; in CI/demo scenarios, MockEngine provides deterministic behavior without MATLAB installed.

Testing
- tests/test_engine_smoke.py ensures EngineManager uses the mock and that sim() returns success.
- tests/test_qml_boot.py boots Main.qml headlessly (QT_QPA_PLATFORM=offscreen) and asserts a root object is created.
- tests/test_async_flow.py exercises the full runSimulation async lifecycle using the mock engine.

Notes for agents
- Python: requires 3.10+.
- Running UI tests headlessly requires $env:QT_QPA_PLATFORM = 'offscreen'.
- Prefer mock mode for CI or when MATLAB is unavailable: set $env:ANALYSIS_USE_MOCK = '1' or use --mock.
