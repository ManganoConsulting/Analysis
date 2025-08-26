classdef DesignParameter < matlab.mixin.Copyable
    
    %% Public properties
    properties   
        Name
    end % Public properties
  
    %% Private properties
    properties ( Access = private )  

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
    
    %% Methods - Constructor
    methods      
        
        function obj = DesignParameter( name , value ) 
%           % Support no argument case
%              if nargin == 0
%                 data = double(0);
%              % If image data is not uint8, convert to uint8
%              elseif ~strcmp('double',class(data))
%                 switch class(data)
%                    case 'struct'
%                        obj = UserInterface.ControlDesign.DesignParameter(data.);
%                       t = double(data)/65535;
%                       data = uint8(round(t*255));
%                    otherwise
%                       error('Not a supported image class')
%                 end
%              end
%              % assign data to superclass part of object
%              obj = obj@double(data);
        end % Parameter
        
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
end


