classdef Parameter < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties       
        Name
        Value
        ValueString
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = Parameter(name,value,string)
            switch nargin
                case 0                    
                case 1
                    if isempty(name)
                        obj = ScatteredGain.Parameter.empty;
                    elseif isstruct(name)
                        obj(length(name)) = ScatteredGain.Parameter;
                        for i = 1:length(name)
                            obj(i).Name  = name(i).Name;
                            obj(i).Value = name(i).Value;
                        end
                    else
                        obj.Name = name;
                    end
                case 2
                    obj.Name = name;
                    obj.Value = value;
                case 3
                    obj.Name   = name;
                    obj.Value  = value;
                    obj.ValueString = string;
            end

        end % Parameter
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.Value(obj)
            y = double(obj.Value);
        end
        
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
   
        function newObj = get(obj,name)
            newObj = ScatteredGain.Parameter.empty;
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
            end   
        end % get
        
        function ind = find(obj,name)
            ind = find(strcmp(name,{obj.Name}));
        end % find
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Gains object
            %cpObj.Gains = copy(obj.Gains);
        end
    end
    
end
