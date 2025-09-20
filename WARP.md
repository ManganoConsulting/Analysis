# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is the FLIGHT toolbox - a MATLAB-based flight dynamics and control design application. The repository contains a comprehensive suite of tools for aerospace analysis including:

- **FLIGHT Dynamics**: Main dynamics analysis module (`DYNMain.m`, `FLIGHTdynamics.m`)
- **FLIGHT Control**: Control design and analysis module (`Main.m`)
- **Filter Design**: Digital filter design tools (`+FilterDesign/`)
- **Requirements Management**: Simulation requirements and analysis (`+Requirements/`)
- **User Interface**: Comprehensive GUI framework (`+UserInterface/`)
- **Analysis Tools**: Linear models, trim analysis, mass properties (`+lacm/`)

## Common Development Commands

### Starting the Application
```matlab
% Start FLIGHT Dynamics (main application)
FLIGHTdynamics

% Alternative - create Main object directly
dynMain = DYNMain();

% Start Control Design module
controlMain = Main();
```

### Working with MATLAB Projects
```matlab
% Open the project
openProject('FlightDynamics.prj')

% Add paths (done automatically by Application class)
addpath(fileparts(mfilename('fullpath')));
```

### Running Individual Modules
```matlab
% Filter design
FilterDesign.main()

% Utilities functions are accessed via package syntax
Utilities.createShortcut(path, 'FLIGHTdynamics', 'Dynamics', version, build)
```

### Testing and Validation
```matlab
% No formal test suite - validation is done through:
% 1. Manual GUI testing
% 2. Model simulation validation
% 3. Analysis result verification

% Example validation workflow:
load_system('your_model.slx');
% Run analysis through GUI or programmatically
```

## Architecture Overview

### Package Structure
The codebase follows MATLAB's package system with `+PackageName` directories:

- **+lacm**: Linear Analysis and Control Methods - core analysis engine
  - `@LinearModel`: Linear model definitions and linearization
  - `@AnalysisTask`: Analysis task management
  - `@MassProperties`: Aircraft mass properties handling
  - `@TrimTask*`: Trim analysis and task management

- **+UserInterface**: Complete GUI framework
  - `+ControlDesign`: Control design GUI components
  - `+StabilityControl`: Stability and control analysis GUI
  - Custom UI components and utilities

- **+Requirements**: Requirements management system
  - `@RequirementTypeOne`: Base requirement definitions
  - `@Simulation`: Simulation-based requirements
  - `@SimulationCollection`: Collections of simulation requirements

- **+Utilities**: Common utilities and helper functions
  - File I/O utilities (`cell2csv.m`, `GetFullPath.m`)
  - GUI utilities (`createGUI.m`, `findjobj.m`)
  - Java integration helpers

- **+FilterDesign**: Digital filter design and analysis tools
- **+SimViewer**: Simulation results visualization
- **+ScatteredGain** / **+ScheduledGain**: Gain scheduling tools

### Entry Points and Main Classes

1. **`FLIGHTdynamics.m`**: Primary wrapper function that creates `DYNMain` object
2. **`DYNMain`**: Main dynamics application controller with:
   - Application licensing and validation
   - Project management (load/save/close)
   - GUI lifecycle management
   - Simulink model integration

3. **`Main`**: Control design application with similar structure

4. **`@Application`**: Core application class handling:
   - MATLAB version compatibility
   - Java classpath management  
   - License validation
   - Version control

### Key Architectural Patterns

**Handle Classes**: Most major classes inherit from `handle` and `matlab.mixin.Copyable` for object-oriented behavior.

**Event-Driven Architecture**: Extensive use of MATLAB events and listeners for GUI communication:
```matlab
addlistener(obj.ToolObj,'LoadProject',@obj.loadProject);
addlistener(obj.ToolObj,'SaveProject',@obj.saveProject);
```

**Java Integration**: Heavy use of Java Swing components for advanced GUI features, with automatic classpath management.

**Package-Based Modularity**: Clear separation of concerns through MATLAB packages.

## Working with the Codebase

### Creating New Analysis Types
1. Create new class in `+lacm/` package inheriting from appropriate base class
2. Implement required interface methods (`run`, `get`, etc.)
3. Add GUI components in `+UserInterface/` if needed
4. Register with main application controller

### Extending GUI Components
1. Follow existing patterns in `+UserInterface/` packages
2. Use `UserInterface.GraphicsObject` base class for graphics components
3. Implement standard resize and callback methods
4. Use Java components for advanced functionality

### Adding Utilities
1. Add functions to `+Utilities/` package
2. Follow naming conventions (camelCase for functions)
3. Include proper error handling and input validation

## Development Environment Setup

The application automatically manages:
- Java classpath setup in `javaclasspath.txt`
- Required library paths
- MATLAB path configuration

On first run, the application will prompt for MATLAB restart to complete setup.

### Required MATLAB Toolboxes
- Control System Toolbox
- Simulink
- MATLAB Compiler (for deployment)

### Version Compatibility
- Requires MATLAB R2015a or later (enforced by `Application` class)
- Uses both legacy and modern graphics systems
- Handles JavaFrame deprecation gracefully

## Simulink Model Integration

The toolbox integrates deeply with Simulink for:
- **Model linearization**: Automatic extraction of linear models at trim points
- **Trim analysis**: Finding equilibrium operating conditions  
- **Parameter extraction**: Automatic discovery of model states, inputs, outputs
- **Batch analysis**: Running multiple analysis cases

Key integration points:
- `Utilities.getNamesFromModel()`: Extract model interface information
- `jj_lin()`: Core linearization routine
- Model loading and path management through `load_system()`

## Common Development Patterns

### Error Handling
```matlab
try
    % Operation
catch Mexc
    switch Mexc.identifier
        case 'MATLAB:specificError'
            % Handle specific error
        otherwise
            rethrow(Mexc);
    end
end
```

### GUI Resize Patterns
```matlab
function resizeFcn(obj, ~, ~)
    position = getpixelposition(obj.Container);
    % Update component positions based on container size
end
```

### Event Communication
```matlab
notify(obj, 'EventName', CustomEventData(data));
```