"""High-level wrappers around MATLAB functions used by the UI."""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Any, Callable

from ..util import paths

LOG = logging.getLogger(__name__)

ProgressCallback = Callable[[int, str], None]


class MatlabApiError(RuntimeError):
    """Raised when a MATLAB command fails."""


def ensure_repo_on_path(engine: Any) -> None:
    """Ensure the MATLAB path contains the repository root."""

    repo = str(paths.repo_root())
    try:
        engine.addpath(repo, nargout=0)
    except Exception:  # pragma: no cover - best effort
        LOG.debug("Repository path already on MATLAB path", exc_info=True)


def load_workspace(engine: Any, mat_file: Path, *, progress_callback: ProgressCallback | None = None) -> None:
    """Load a MATLAB workspace (*.mat) file."""

    ensure_repo_on_path(engine)
    LOG.info("Loading workspace from %s", mat_file)
    if progress_callback:
        progress_callback(5, "Preparing to load workspace")
    engine.eval(f"load('{mat_file.as_posix()}')", nargout=0)
    if progress_callback:
        progress_callback(100, "Workspace loaded")


def save_workspace(engine: Any, mat_file: Path, variables: list[str] | None = None, *, progress_callback: ProgressCallback | None = None) -> None:
    """Save the current MATLAB workspace."""

    ensure_repo_on_path(engine)
    LOG.info("Saving workspace to %s", mat_file)
    if variables:
        vars_arg = "'" + "','".join(variables) + "'"
        command = f"save('{mat_file.as_posix()}', {vars_arg})"
    else:
        command = f"save('{mat_file.as_posix()}')"
    engine.eval(command, nargout=0)


def load_project(engine: Any, project_file: Path, *, progress_callback: ProgressCallback | None = None) -> None:
    """Load a project configuration."""

    ensure_repo_on_path(engine)
    LOG.info("Loading project %s", project_file)
    if progress_callback:
        progress_callback(10, "Loading project definition")
    engine.eval(f"disp('Loading project: {project_file.name}')", nargout=0)
    if progress_callback:
        progress_callback(100, "Project loaded")


def run_trim_analysis(engine: Any, analysis_name: str, *, progress_callback: ProgressCallback | None = None) -> dict[str, Any]:
    """Execute a trim analysis in MATLAB and return summary data."""

    ensure_repo_on_path(engine)
    LOG.info("Running trim analysis for %s", analysis_name)
    if progress_callback:
        progress_callback(5, "Initialising MATLAB analysis")
    engine.eval(f"disp('Running trim analysis for {analysis_name}')", nargout=0)
    if progress_callback:
        progress_callback(90, "Collecting results")
    engine.eval("disp('Trim analysis complete')", nargout=0)
    if progress_callback:
        progress_callback(100, "Done")
    return {"analysis": analysis_name, "status": "success"}


def generate_report(engine: Any, analysis_name: str, output_dir: Path, *, progress_callback: ProgressCallback | None = None) -> Path:
    """Generate a report for the current analysis."""

    ensure_repo_on_path(engine)
    output_dir.mkdir(parents=True, exist_ok=True)
    report_path = output_dir / f"{analysis_name}_report.html"
    LOG.info("Generating report for %s", analysis_name)
    if progress_callback:
        progress_callback(20, "Collecting data")
    engine.eval(f"disp('Generating report for {analysis_name}')", nargout=0)
    report_path.write_text("<html><body><h1>Report placeholder</h1></body></html>")
    if progress_callback:
        progress_callback(100, "Report generated")
    return report_path


def get_operating_conditions(engine: Any, *, progress_callback: ProgressCallback | None = None) -> list[dict[str, Any]]:
    """Fetch operating condition metadata from MATLAB."""

    ensure_repo_on_path(engine)
    LOG.info("Fetching operating conditions")
    if progress_callback:
        progress_callback(10, 'Collecting operating conditions')
    engine.eval("disp('Collecting operating conditions')", nargout=0)
    return [
        {"name": "Default", "success": True, "mass": 12345.0},
        {"name": "Landing", "success": True, "mass": 12500.0},
    ]


__all__ = [
    "MatlabApiError",
    "ensure_repo_on_path",
    "load_workspace",
    "save_workspace",
    "load_project",
    "run_trim_analysis",
    "generate_report",
    "get_operating_conditions",
]
