classdef Gain < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties       
        Name
        Value
        Expression
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        %ExludeFromFit = false

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = Gain(name,value)
            switch nargin
                case 0                    
                case 1
                    if isempty(name)
                        obj = ScatteredGain.Gain.empty;
                    elseif isstruct(name)
                        obj(length(name)) = ScatteredGain.Gain;
                        for i = 1:length(name)
                            obj(i).Name  = name(i).Name;
                            obj(i).Value = name(i).Value;
                        end
                    elseif isa(name,'ScatteredGain.Parameter')
                        obj(length(name)) = ScatteredGain.Gain;
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
            end

        end % Gain
    end % Constructor

    %% Methods - Property Access
    methods
        
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
   
        function newObj = get(obj,name)
            newObj = ScatteredGain.Gain.empty;
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
            end   
        end % get
        
        function ind = find(obj,name)
            ind = find(strcmp(name,{obj.Name}));
        end % find
        
        function y = getValue(obj,name)
            y = [];
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
                y = [newObj.Value];
            end   
        end % getValue
        
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
