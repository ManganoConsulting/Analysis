function startup_project()
    %----------------------------------------------------------------------
    % startup.m  
    %
    % Runs automatically when MATLAB starts.
    %   1. Closes all open files in the MATLAB Editor.
    %   2. Opens the Stability Control Main.m file.
    %----------------------------------------------------------------------

    % Step 1: Close all open files (no save prompts)
    try
        closeNoPrompt(matlab.desktop.editor.getAll);
    catch ME
        warning('Could not close editor files: %s', 'All', ME.message);
    end

    % Step 2: Define your project root
    projectRoot = 'C:\ACD_GITPrjs\FlightDynamics';

    % Step 3: Define list of files to open (relative to projectRoot)
    filesToOpen = { ...
        fullfile(projectRoot, '+UserInterface', '+StabilityControl', '@Main', 'Main.m'), ...
        fullfile(projectRoot, 'utils', 'helperFunctions.m'), ...
        fullfile(projectRoot, 'tests', 'runAllTests.m') ...
    };

    % Step 4: Loop and open each file if it exists
    for k = 1:numel(filesToOpen)
        thisFile = filesToOpen{k};
        if exist(thisFile, 'file') == 2
            try
                matlab.desktop.editor.openDocument(thisFile);
                fprintf('Opened: %s\n', thisFile);
            catch ME
                warning('Could not open file %s: %s', thisFile, ME.message);
            end
        else
            warning('File not found: %s', thisFile);
        end
    end

    % Done
    disp('Startup complete.');
end