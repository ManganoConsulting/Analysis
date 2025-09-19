# ControlDesign Qt Application

This repository packages the Control Design tools with a cross-platform Qt for Python
frontend that delegates simulation work to MATLAB/Simulink through the MATLAB Engine
for Python. The original MATLAB GUI sources have been archived under
`matlab_ui_legacy/` for reference, while algorithms and models remain under
`matlab_core/` unchanged.

## Repository layout

```
ControlDesign/
├─ app/                    # PySide6 application code
│  ├─ app.py               # Entry point
│  ├─ engine_bridge/       # MATLAB Engine wrapper
│  └─ ui/                  # Main window, task runner, dockable panels
├─ matlab_core/            # MATLAB/Simulink logic that remains active
├─ matlab_ui_legacy/       # Archived legacy MATLAB UI implementation
├─ tests/                  # Python unit tests
├─ requirements.txt        # Python dependencies
└─ README.md
```

## Requirements

* Python 3.10 or newer (matching the MATLAB Engine support matrix)
* [MATLAB](https://www.mathworks.com/products/matlab.html) with Simulink (optional in MOCK mode)
* PySide6 (installed via `requirements.txt`)

## Python environment setup

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## MATLAB Engine installation

Install the MATLAB Engine for Python that matches your active Python interpreter.

### Windows PowerShell

```powershell
cd "$env:MATLABROOT\extern\engines\python"
python -m pip install .
```

### macOS / Linux

```bash
cd "$MATLABROOT/extern/engines/python"
python -m pip install .
```

> Replace `MATLABROOT` with the path reported by the MATLAB command `matlabroot`.

## Running the application

### MOCK mode (no MATLAB required)

```bash
export CONTROL_UI_MOCK=1        # Windows PowerShell: set CONTROL_UI_MOCK=1
python app/app.py
```

Mock mode exercises the full UI without touching MATLAB. Simulation requests return
plausible dummy data immediately.

### Connected to MATLAB/Simulink

Ensure MATLAB Engine is installed, then run:

```bash
python app/app.py
```

Use **File → Open Model…** or the ribbon **Open** button to load a Simulink model,
set the stop time in the Simulation dock, and click **Run Simulation**. The log pane
reports MATLAB Engine progress, and results populate the Simulation dock.

## Packaging with PyInstaller

```bash
pip install pyinstaller
pyinstaller --noconfirm --windowed app/app.py
```

Bundle MATLAB runtime files as required by your deployment scenario. Large data
transfers between MATLAB and Python should prefer MAT-file or CSV exchanges to avoid
expensive cross-process copies.

## Testing

```bash
export QT_QPA_PLATFORM=offscreen
python -m pytest
```

`test_bridge_mock.py` verifies mock MATLAB interactions and `test_layout_smoke.py`
constructs the Qt interface to catch regressions.

## Notes

* MATLAB UI assets are preserved in `matlab_ui_legacy/` for future reference.
* Non-UI MATLAB code resides in `matlab_core/` and can be invoked by the Python app
  through the engine bridge or directly from MATLAB.
* The PySide6 UI keeps the interface responsive by routing MATLAB calls through a
  thread pool (`TaskRunner`).
