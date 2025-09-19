classdef (Sealed, Hidden) SplashScreenController < handle
    %SPLASHSCREENCONTROLLER Manage lifetime of the Control Design splash screen.
    %   This helper deletes the splash screen figure and restores the parent
    %   figure's visibility when the splash screen is dismissed.

    properties (Access = private)
        SplashFigure matlab.ui.Figure
        ParentFigure
        ParentVisibilityOnClose char
    end

    methods
        function obj = SplashScreenController(splashFigure, parentInfo)
            obj.SplashFigure = splashFigure;
            obj.ParentFigure = parentInfo.Figure;
            obj.ParentVisibilityOnClose = parentInfo.VisibilityOnClose;
        end

        function delete(obj)
            if ~isempty(obj.SplashFigure) && isvalid(obj.SplashFigure)
                delete(obj.SplashFigure);
            end

            if ~isempty(obj.ParentFigure) && isvalid(obj.ParentFigure)
                try
                    obj.ParentFigure.Visible = obj.ParentVisibilityOnClose;
                catch
                    set(obj.ParentFigure, 'Visible', obj.ParentVisibilityOnClose);
                end
                drawnow();
            end
        end
    end
end
