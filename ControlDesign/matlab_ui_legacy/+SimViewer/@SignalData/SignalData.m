classdef SignalData
    
    %% Public properties
    properties   
        Name
        BlockPath
        BusPath
        Run
        SimulationOutputName
        LineProps
        XOperation
        YOperation
    end % Public properties
  
    %% Private properties
    properties ( Access = private )      
        
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private, Hidden = true )

        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        IncludeRunInName = true
    
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        DisplayName
        BasicDisplayName
    end % Dependant properties   
    
    %% Methods - Constructor
    methods      
        function obj = SignalData(varargin) 
            if nargin == 0
               return; 
            end  
            
            p = inputParser;
            addParameter(p,'Name','');
            addParameter(p,'BlockPath',Simulink.BlockPath.empty);
            addParameter(p,'BusPath',{});
            addParameter(p,'Run','');
            addParameter(p,'SimulationOutputName','');
            addParameter(p,'LineProps',SimViewer.LineProps.empty);
            addParameter(p,'XOperation','');
            addParameter(p,'YOperation','');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            
            obj.Name                    = options.Name;
            obj.BlockPath               = options.BlockPath;
            obj.BusPath                 = options.BusPath;
            obj.Run                     = options.Run;
            obj.SimulationOutputName    = options.SimulationOutputName;
            obj.LineProps               = options.LineProps;
            obj.XOperation              = options.XOperation;
            obj.YOperation              = options.YOperation;
        end % SignalData
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.DisplayName(obj)
            
            if isempty(obj.BusPath)
                name = obj.Name;
            else
                name = obj.BusPath{end};
            end
            
            if obj.IncludeRunInName
                y = [name,' ( ',obj.Run{1},' )'];
                %y = [name,' | ',obj.Run{1}];
            else
                y = name;
            end
        end % DisplayName
        
        function y = get.BasicDisplayName(obj)
            
            if isempty(obj.BusPath)
                name = obj.Name;
            else
                name = obj.BusPath{end};
            end
            y = name;

        end % BasicDisplayName
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
