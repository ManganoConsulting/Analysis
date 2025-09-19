classdef OperCondFilterSettings < matlab.mixin.Copyable
    
    %% Public properties - Data Strorage
    properties   

        Parameter1_FC1_Str = ''
        Parameter2_FC2_Str = ''
        Parameter3_IOC_Str = ''
        Parameter4_WC_Str = ''
        
        Parameter1_FC1_Value = ''
        Parameter2_FC2_Value = ''
        Parameter3_IOC_Value = ''
        Parameter4_WC_Value = ''

    end % Public properties
    
    %% Notch properties
    properties   


    end % Public properties
    
    %% Properties - Observable AbortSet
    properties( SetObservable , AbortSet )
        
    end
  
    %% Private properties
    properties ( Access = private )  

    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties% (Hidden = true)

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = OperCondFilterSettings(fc1_Str, fc2_Str, ic_Str, wc_Str, fc1_Val, fc2_Val, ic_Val, wc_Val) 
            if nargin == 0
               return; 
            end  
            
             obj.Parameter1_FC1_Str = fc1_Str;
             obj.Parameter2_FC2_Str = fc2_Str;
             obj.Parameter3_IOC_Str = ic_Str;
             obj.Parameter4_WC_Str = wc_Str;
             obj.Parameter1_FC1_Value = fc1_Val;
             obj.Parameter2_FC2_Value = fc2_Val;
             obj.Parameter3_IOC_Value = ic_Val;
             obj.Parameter4_WC_Value = wc_Val;

        end % Filter
        
    end % Constructor

    %% Methods - Property Access
    methods
      
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)     
        
        function update(obj)

        end

        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            %cpObj.Tree = copy(obj.Tree);
        end
        
    end


    %% Methods - Static
    methods(Static)
    end % Methods - Static
end % Filter

