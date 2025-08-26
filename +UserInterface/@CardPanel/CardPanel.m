classdef CardPanel < hgsetget
    
    %% Public properties - Object Handles
    properties   
        Parent
        Panel
        Container
        
    end % Public properties
  
    %% Public properties - Data Storage
    properties       
         
    end % Public properties
    
    %% Private properties - Data Storage
    properties (Access = private)  
        PrivateSelectedPanel
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        SelectedPanel
        Position
        Units
        Visible
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        
        function obj = CardPanel(num,varargin) 
            if nargin == 0
               return; 
            end  

            
            p = inputParser;
            addRequired(p,'NumOfCards',@isnumeric);
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normal',@ischar);
            addParameter(p,'Position',[0,0,1,1],@isnumeric);
            addParameter(p,'SelectedPanel',1);
            p.KeepUnmatched = true;
            parse(p,num,varargin{:});
            options = p.Results;
            
            obj.Parent = options.Parent;
            obj.Container = uipanel('Parent',obj.Parent,'Units', options.Units,'Position',options.Position,'BorderType','none');
            %set(obj.Container,'ResizeFcn',@obj.reSize);
            
            for i = 1:num   
                obj.Panel(i) = uicontainer('Parent',obj.Container ,...
                    'Units','Normal',...
                    'Position',[ 0, 0, 1, 1 ]);  
                if options.SelectedPanel == i
                    set(obj.Panel(i),'Visible','on');
                else
                    set(obj.Panel(i),'Visible','off');
                end
            end      
            obj.SelectedPanel = options.SelectedPanel;
            
        end % cardpanel
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function set.SelectedPanel(obj,value)
            if any(value == 1:length(obj.Panel))
                obj.PrivateSelectedPanel = value;
                obj.update();
            end   
        end
        
        function value = get.SelectedPanel(obj)
            value = obj.PrivateSelectedPanel;   
        end
        
        function set.Position(obj,pos)
            set(obj.Container,'Position',pos);
        end % Position - Set
        
        function y = get.Position(obj)
            y = get(obj.Container,'Position');
        end % Position - Get
        
        function set.Units(obj,units)
            set(obj.Container,'Units',units);
        end % Units -Set
        
        function y = get.Units(obj)
            y = get(obj.Container,'Units');
        end % Units -Get
        
        function set.Visible(obj,vis)
            set(obj.Container,'Visible',vis);
        end % Visible -Set
        
        function y = get.Visible(obj)
            y = get(obj.Container,'Visible');
        end % Visible -Get
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods
        
        function delete(obj)
            try  %#ok<TRYNC>
                for i = 1:length(obj.Panel) 
                    if ishandle(obj.Panel(i)) && strcmp(get(obj.Panel(i), 'BeingDeleted'), 'off')
                        delete(obj.Panel(i));
                    end
                end 
            end
            
            try  %#ok<TRYNC>
                delete(obj.Container);
            end
        end % delete
        
        function y = get(obj,str)
            if strcmpi(str,'Children')
                y = obj.Panel;
            end
        end % get
       
        
        function eraseChildren(obj,panelNum)
            if nargin == 1
                for i = 1:length(obj.Panel)
                    children= get(obj.Panel(i),'Children');         
                    delete(children);
                end
            elseif nargin == 2
                children= get(obj.Panel(panelNum),'Children');         
                delete(children);
            end
                
        end
        
        function pos = getpixelposition( obj )
            %getpixelposition  get the absolute pixel position
            %
            %   POS = GETPIXELPOSITION(C) gets the absolute position of the container C
            %   within its parent window. The returned position is in pixels.
            pos = getpixelposition( obj.Container );
        end % getpixelposition
        
        function panel = addPanel( obj, numPanels, userdata )
            if nargin == 1
                numPanels = 1;
            elseif nargin < 3
                userdata = {};
            elseif nargin == 3
                if numPanels == 1
                    userdata = {userdata};
                end
            else
                error('Incorrect number of inputs');
            end
            
            
            for i = 1:numPanels     
                panel(i) = uicontainer('Parent',obj.Container ,...
                    'Units','Normal',...
                    'Position',[ 0, 0, 1, 1 ]);%#ok<AGROW> 
%                     'Visible','off');   %#ok<AGROW>
                if ~isempty(userdata) || length(userdata) >= i
                    set(panel(i),'UserData', userdata{i});
                end
            end 
            
            
            obj.Panel = [obj.Panel,panel];
            obj.PrivateSelectedPanel = length(obj.Panel);
            update(obj)
            
        end % addPanel
        
        function panel = addPanelKeepSelected( obj , numPanels )
            if nargin == 1
                numPanels = 1;
            end
            for i = 1:numPanels     
                panel(i) = uicontainer('Parent',obj.Container ,...
                    'Units','Normal',...
                    'Position',[ 0, 0, 1, 1 ]);%#ok<AGROW> 
%                     'Visible','off');   %#ok<AGROW>
            end 
            obj.Panel = [obj.Panel,panel];
            update(obj)
            
        end % addPanelKeepSelected
       
        function deletePanel( obj , panelNum )
    
            delete(obj.Panel(panelNum ));
            obj.Panel(panelNum) = []; 
            obj.SelectedPanel = 1;
       
        end % deletePanel
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       
        function update(obj)
            for i = 1:length(obj.Panel)
                if i == obj.PrivateSelectedPanel
                    set(obj.Panel(i),'Visible','on'); 
                else
                    set(obj.Panel(i),'Visible','off'); 
                end
            end
        end
    end
    
end
