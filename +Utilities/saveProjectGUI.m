classdef saveProjectGUI < handle
    %saveProjectGUI Modal dialog that prompts to save the current project.
    %   This lightweight UI is used throughout the application to confirm
    %   whether the active project should be saved, optionally persisting
    %   any generated plots.  The class stores a reference to each control
    %   so the UI can be driven programmatically by matlab.uitest.TestCase.

    properties
        Figure matlab.ui.Figure
        PRJresponse char = ''
        PLTresponse logical = true
    end

    properties (SetAccess = private)
        MessageLabel matlab.ui.control.Label
        YesButton matlab.ui.control.Button
        NoButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
        SavePlotsCheckbox matlab.ui.control.CheckBox
    end

    methods
        function obj = saveProjectGUI
            % Create a figure window:
            obj.Figure = uifigure('Name', 'Save Project?', ...
                'Position', [707 507 350 100]);

            obj.MessageLabel = uilabel(obj.Figure, ...
                'Text', 'Would you like to save the project?', ...
                'Position', [10 70 191 20], ...
                'Tag', 'SaveProjectMessageLabel');

            obj.YesButton = uibutton(obj.Figure, 'text', 'Yes', ...
                'Position', [10 40 91 20], ...
                'ButtonPushedFcn', @obj.bBoxChanged, ...
                'Tag', 'SaveProjectYesButton');

            obj.NoButton = uibutton(obj.Figure, 'text', 'No', ...
                'Position', [120 40 91 20], ...
                'ButtonPushedFcn', @obj.bBoxChanged, ...
                'Tag', 'SaveProjectNoButton');

            obj.CancelButton = uibutton(obj.Figure, 'text', 'Cancel', ...
                'Position', [230 40 91 20], ...
                'ButtonPushedFcn', @obj.bBoxChanged, ...
                'Tag', 'SaveProjectCancelButton');

            % Create a check box:
            obj.SavePlotsCheckbox = uicheckbox(obj.Figure, ...
                'Text', 'Save Plots?', ...
                'Position', [10 10 102 15], ...
                'Value', obj.PLTresponse, ...
                'ValueChangedFcn', @obj.cBoxChanged, ...
                'Tag', 'SaveProjectSavePlotsCheckbox');
        end
    end

    methods
        function cBoxChanged(obj, hobj, ~)
            obj.PLTresponse = hobj.Value;
        end

        function bBoxChanged(obj, hobj, ~)
            obj.PRJresponse = hobj.Text;
            if ~isempty(obj.Figure) && isvalid(obj.Figure)
                delete(obj.Figure);
            end
        end
    end
end
