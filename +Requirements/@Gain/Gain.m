classdef Gain
    
    properties
        Name
        Value = 0
    end

    
    %% Methods - Constructor
    methods
        function s = Gain(name,value)
            switch nargin
                case 1
                    if iscell(name) && length(name) == 2
                        s.Name = name{1};
                        s.Value = name{2};
                    elseif iscell(name) && length(name) == 1
                        s.Name = name{1};
                    else
                        s.Name = name;
                    end
                case 2
                    s.Name = name;
                    s.Value = value;
            end
        end % Gain
    end  
    
    %% Methods - Ordinary
    methods 
%         function vars = getAsMdlVars(obj)
%             for i = 1:length(obj)
%                 vars(i) = controldesign.mdlvars(obj(i).Name,obj(i).Value); %#ok<AGROW>
%             end
%         end % getAsMdlVars
    end
    
    
end