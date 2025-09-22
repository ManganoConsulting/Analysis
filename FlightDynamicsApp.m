classdef FlightDynamicsApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure matlab.ui.Figure
    end

    properties (Access = private)
        DynamicsMain
        IsShuttingDown logical = false
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = matlab.ui.Figure.empty;
        end

        function startupFcn(app)
            % Application.removeInstallsFromMPath();
            rootFolder = fileparts(fileparts(which('app.FlightDynamicsApp')));
            if ~isempty(rootFolder)
                addpath(rootFolder);
            end

            app.DynamicsMain = DYNMain();
            if isempty(app.DynamicsMain)
                return;
            end

            app.UIFigure = app.DynamicsMain.Figure;
        end

        function onFigureClose(app, src, event)
            if isempty(app.DynamicsMain) || ~isvalid(app.DynamicsMain)
                delete(app);
                return;
            end

            app.DynamicsMain.closeFigure_CB(src, event);

            if ~isvalid(src)
                app.IsShuttingDown = true;
                app.cleanupMain();
                if isvalid(app)
                    delete(app);
                end
            end
        end

        function cleanupMain(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end

            if ~isempty(app.DynamicsMain)
                try
                    if isvalid(app.DynamicsMain)
                        delete(app.DynamicsMain);
                    end
                catch %#ok<CTCH>
                end
            end

            app.DynamicsMain = [];
            app.UIFigure = matlab.ui.Figure.empty;
        end
    end

    methods (Access = public)
        function delete(app)
            if app.IsShuttingDown
                return;
            end

            app.IsShuttingDown = true;

            if ~isempty(app.DynamicsMain) && isvalid(app.DynamicsMain)
                fig = [];
                if isprop(app.DynamicsMain, 'Figure')
                    fig = app.DynamicsMain.Figure;
                end

                if ~isempty(fig) && isvalid(fig)
                    try
                        app.DynamicsMain.closeFigure(fig, []);
                    catch %#ok<CTCH>
                        try
                            delete(fig);
                        catch %#ok<CTCH>
                        end
                    end
                else
                    try
                        app.DynamicsMain.closeFigure(fig, []);
                    catch %#ok<CTCH>
                    end
                end
            end

            app.cleanupMain();
        end

        function app = FlightDynamicsApp
            createComponents(app);
            startupFcn(app);
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                try
                    registerApp(app, app.UIFigure);
                catch %#ok<CTCH>
                end
                app.UIFigure.CloseRequestFcn = @(src, event) app.onFigureClose(src, event);
            end

            if nargout == 0 && ~isempty(app) && isvalid(app)
                clear app;
            end
        end
    end
end
