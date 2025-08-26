function figH = FLIGHTcontrol ()
%FLIGHT This is a wrapper for starting the t
    persistent obj
    Application.removeInstallsFromMPath();
    addpath(fileparts(mfilename('fullpath')));
    obj = CTRLMain; 
    figH = obj.Figure;
end

