classdef OperatingConditionCollection < matlab.mixin.Copyable & UserInterface.GraphicsObject
    
    %% Public Properties
    properties (SetObservable) 
        OperatingCondition lacm.OperatingCondition
    end % Public properties
    
    %% Private Properties
    properties ( Access = private ) 
        
    end % Private properties
    
    %% Public properties - Graphics Handles
    properties (Transient = true)
        %Parent

    end % Public properties
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        %Figure
    end % Dependant properties
    
    %% Constant Properties
    properties (Constant)
 
    end   
    
    %% Methods - Constructor
    methods      
        function obj = OperatingConditionCollection(parent)
            switch nargin
                case 1
                    obj.Parent = parent;  
            end

        end % OperatingConditionCollection
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods 

    end % Ordinary Methods
    
    %% Methods - View
    methods 
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update(gui)

        end % update
   
        function resize( obj , ~ , ~ )

        end % resize
        
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the OperatingCondition object
            cpObj.OperatingCondition = copy(obj.OperatingCondition);
        end
    end
   
end

