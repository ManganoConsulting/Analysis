% Auto-add shared library to MATLAB path (submodule)
try
    repoRoot = fileparts(mfilename('fullpath'));
    libPath = fullfile(repoRoot, 'external', 'library-matlab', 'src');
    if exist(libPath, 'dir')
        addpath(genpath(libPath));
    end
catch ME
    warning('startup:libraryPath', 'Failed to add library-matlab to path: %s', ME.message);
end
