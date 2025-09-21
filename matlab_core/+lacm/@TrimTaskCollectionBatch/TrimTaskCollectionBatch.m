classdef TrimTaskCollectionBatch < dynamicprops & matlab.mixin.Copyable & UserInterface.GraphicsObject  
    %% Public properties - Data Storage
    properties 
        TrimTaskCollObj lacm.TrimTaskCollection = lacm.TrimTaskCollection.empty
    end % Public properties
    
    %% Private properties
    properties (Access = private)  
      
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
     
    end % Dependant properties
    
    %% View Properties
    properties( Hidden = true , Transient = true )
   
    end

    %% Data Storage Properties
    properties( Hidden = true )

    end

    %% Constant properties
    properties (Constant) 
 
    end % Constant properties  
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end

    %% Methods - Constructor
    methods      
        function obj = TrimTaskCollectionBatch(trimTaskColl)
            switch nargin
                case 0
                case 1
                    obj.TrimTaskCollObj = trimTaskColl;
                otherwise

            end
            
        end % TrimTaskCollectionBatch
    end % Constructor

    %% Methods - Property Access
    methods
  
    end % Property access methods
    
    %% Methods - View 
    methods 
        
    
    end % Protected View Methods
    
    %% Methods - Callbacks
    methods 
                
   

    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
    
    end % Ordinary Methods
    
    %% Methods - Private
    methods (Access = private)    
        
      
        
    end    
    
    %% Methods - Protected
    methods% (Access = protected) 
        
                          
    end
    
    %% Method - Static
    methods ( Static )


        
    end
        
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the TrimTask object
            cpObj.TrimTaskCollObj = copy(obj.TrimTaskCollObj);

            
            
            
        end
    end
    
end


