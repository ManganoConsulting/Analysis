classdef saveProjectGUI < handle
    properties
        Figure
        PRJresponse = ''
        PLTresponse = true      
    end

    methods
        function obj = saveProjectGUI
            % Create a figure window:
            obj.Figure = uifigure('Name','Save Project?', 'Position',[707 507 350 100]);


            label1 = uilabel(obj.Figure, 'Text','Would you like to save the project?', 'Position',[10 70 191 20]);

            by = uibutton(obj.Figure, 'text', 'Yes', 'Position', [10 40 91 20],...
                'ButtonPushedFcn',@obj.bBoxChanged);

            bn = uibutton(obj.Figure, 'text', 'No', 'Position', [120 40 91 20],...
                'ButtonPushedFcn',@obj.bBoxChanged);

            bc = uibutton(obj.Figure, 'text', 'Cancel', 'Position', [230 40 91 20],...
                'ButtonPushedFcn',@obj.bBoxChanged);

            % Create a check box:
            cbx = uicheckbox(obj.Figure, 'text', 'Save Plots?', 'Position',[10 10 102 15],...
                'Value',obj.PLTresponse,'ValueChangedFcn',@obj.cBoxChanged);
        end
    end
    
    methods
        function cBoxChanged(obj,hobj,~)
            obj.PLTresponse = hobj.Value;
        end

        function bBoxChanged(obj,hobj,~)
            obj.PRJresponse = hobj.Text;
            delete(obj.Figure);
        end
    end
end