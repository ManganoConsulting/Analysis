classdef SavedData
    
    %% Public properties
    properties   
        NumPanels
        NumPerPanel
        AxisData
    end % Public properties
  
    %% Private properties
    properties ( Access = private )      
        
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private, Hidden = true )

        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)

    end % Dependant properties   
    
    %% Methods - Constructor
    methods      
        function obj = SavedData(NumPanels, NumPerPanel , AxisData) 
            if nargin == 0
               return; 
            end  

            obj.NumPanels   = NumPanels;
            obj.NumPerPanel = NumPerPanel;
            obj.AxisData    = AxisData;
            
        end % SavedData
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods    
      

    end % Ordinary Methods
    
    %% Methods - Delete
    methods

    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        
    end
    
    %% Methods - Private
    methods (Access = private)
        

        
    end
end
