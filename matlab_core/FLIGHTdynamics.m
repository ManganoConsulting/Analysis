function figH = FLIGHTdynamics ()
%FLIGHT This is a wrapper for starting the tool
    persistent obj
    Application.removeInstallsFromMPath();
    addpath(fileparts(mfilename('fullpath')));
    obj = DYNMain;
    figH = obj.Figure;
end

