classdef LineProps
    
    %% Public properties
    properties   
        LineStyle
        LineWidth
        LineColor
        MarkerStyle
        MarkerSize
        MarkerFaceColor
        MarkerEdgeColor
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
        function obj = LineProps(varargin) 
            if nargin == 0
               return; 
            end  
            
            p = inputParser;
            addParameter(p,'LineStyle','-');
            addParameter(p,'LineWidth',0.5,@isnumeric);
            addParameter(p,'LineColor',[0,0,1]);
            addParameter(p,'MarkerStyle','none');
            addParameter(p,'MarkerSize',6,@isnumeric);
            addParameter(p,'MarkerFaceColor',[0,0,1]);
            addParameter(p,'MarkerEdgeColor',[0,0,1]);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            
            obj.LineStyle        = options.LineStyle;
            obj.LineWidth        = options.LineWidth;
            obj.LineColor        = options.LineColor;
            obj.MarkerStyle      = options.MarkerStyle;
            obj.MarkerSize       = options.MarkerSize;
            obj.MarkerFaceColor  = options.MarkerFaceColor;
            obj.MarkerEdgeColor  = options.MarkerEdgeColor;
            
            
        end % LineProps
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods    
      
        function update(obj, lineH)
            
            lineH.LineStyle         = obj.LineStyle;
            lineH.LineWidth         = obj.LineWidth;
            lineH.Color             = obj.LineColor;
            lineH.Marker            = obj.MarkerStyle;
            lineH.MarkerSize        = obj.MarkerSize;
            lineH.MarkerFaceColor   = obj.MarkerFaceColor;
            lineH.MarkerEdgeColor   = obj.MarkerEdgeColor;
            
            drawnow;pause(0.01);
        end % update
        
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
