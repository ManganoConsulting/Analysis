classdef GraphicsObject < handle  

    %% Public properties - Object Handles
    properties (Transient = true) 
        Parent
    end

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        Figure
    end % Dependant properties 
    
    %% Methods - Property Access
    methods              
        function y = get.Figure(obj)
            if ~isempty(obj.Parent)
                y = ancestor(obj.Parent,'figure','toplevel');
            else
                y = [];
            end
        end % Figure   
    end % Property access methods
    
%% Method - Delete
    methods
        function deleteObjects(obj)            
            % Delete all graphics
            for i = 1:length(obj)
                if ~isempty(obj(i)) && ~isempty(obj(i).Parent) && isgraphics(obj(i).Parent)
                    allGraph = allchild(obj(i).Parent);
                    delete(allGraph);
                end
            end
        end % delete
    end
    
end