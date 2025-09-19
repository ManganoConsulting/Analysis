classdef Collection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        Container
    end % Public properties
    
    %% Public properties - Data Storage
    properties   
        Title
        BorderType
    end % Public properties
    
    %% Private properties
    properties ( Access = private )  
        PrivatePosition
        PrivateUnits
    end % Private properties
       
    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        
        function obj = Collection(varargin) 
%             if nargin == 0
%                return; 
%             end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'BorderType','none');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;


            obj.Parent = options.Parent;
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;
            obj.BorderType      = options.BorderType;

            if any(strcmp(p.UsingDefaults,'Parent'))
               obj.Parent.MenuBar = 'None';
               obj.Parent.NumberTitle = 'off';
            end

        end % Collection
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function set.Position( obj , pos )
            set(obj.Container,'Position',pos);
            obj.PrivatePosition = pos;
        end % Position - Set
        
        function y = get.Position( obj )
            y = obj.PrivatePosition;
        end % Position - Get
        
        function set.Units( obj , units )
            set(obj.Container,'Units',units);
            obj.PrivateUnits = units;
        end % Units -Set
        
        function y = get.Units( obj )
            y = obj.PrivateUnits;
        end % Units -Get
              
    end % Property access methods
     

    
end


