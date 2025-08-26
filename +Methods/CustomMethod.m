classdef CustomMethod < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties       
        Name
        Function
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
    
    %% Dependant properties
    properties (Dependent = true)
        
    end % Dependant properties
    
    %% Private Properties
    properties (Access = private)

    end % Hidden properties
    
    %% Methods - Constructor
    methods      
        function obj = CustomMethod(name,fun)
            switch nargin
                case 0                    
                case 1
                    obj.Name = name;
                case 2
                    obj.Name = name;
                    obj.Function = fun;

            end

        end % CustomMethod
    end % Constructor

    %% Methods - Property Access
    methods
        
         
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
   

        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       


    end
    
end
