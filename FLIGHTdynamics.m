function figH = FLIGHTdynamics()
%FLIGHT This is a wrapper for starting the tool
    persistent appInstance

    if isempty(appInstance) || ~isvalid(appInstance)
        Application.removeInstallsFromMPath();
        addpath(fileparts(mfilename('fullpath')));
        appInstance = app.FlightDynamicsApp();
    end

    if nargout > 0
        if ~isempty(appInstance) && isvalid(appInstance) && ...
                ~isempty(appInstance.UIFigure) && isvalid(appInstance.UIFigure)
            figH = appInstance.UIFigure;
        else
            figH = [];
        end
    end
end
