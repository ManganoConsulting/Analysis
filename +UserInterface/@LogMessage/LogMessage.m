classdef LogMessage < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)
        Parent
        Container
        LogTextComp
        LogTextScrollComp
        LogTextScrollCont
        Label_TB
        LabelComp
        LabelCont
    end % Public properties
    
    %% Public properties - Data Storage
    properties   
        Title
        Editable = false
        ShowDateTime = 1 % 0 - No date/time stamp ; 1 - Time only stamp ; 2 - Time and Date stamp
        ShowDebug = true
    end % Public properties
    
    %% Properties - Observable
    properties (SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )
        PrivatePosition
        PrivateUnits
        PrivateVisible
        LogHTML = ''
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
        Visible
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = LogMessage(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'Editable',false);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            %obj.Parent = options.Parent;
            
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;
            obj.Editable        = options.Editable;

            createView( obj , options.Parent );

        end % ParameterCollection
        
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
        
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Container,'Visible','on');
            else
                set(obj.Container,'Visible','off');
            end            
        end % Visible - Set
        
        function y = get.Visible(obj)
            y = obj.PrivateVisible;          
        end % Visible - Get
        
    end % Property access methods
    
    %% Methods - View
    methods     
        function createView( obj , parent )
            if nargin == 1
                obj.Parent = figure();
            else 
                obj.Parent = parent;
            end
            obj.Container = uipanel('Parent',obj.Parent,...
                'Title',obj.Title,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            pos = getpixelposition(obj.Container);

            % Create label at top of panel
            labelColor = [55 96 146] / 255;
            obj.LabelComp = uilabel('Parent',obj.Container,...
                'Text','Status Window',...
                'BackgroundColor',labelColor,...
                'FontColor',[1 1 1],...
                'FontName','Courier New',...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'Position',[1, pos(4) - 18, pos(3), 18]);
            obj.LabelCont = obj.LabelComp;
            obj.Label_TB = obj.LabelComp;

            % Create html component for log messages
            this_dir = fileparts( mfilename( 'fullpath' ) );
            html_file = fullfile(this_dir,'logview.html');
            obj.LogTextComp = uihtml('Parent',obj.Container,...
                'HTMLSource',html_file,...
                'Position',[1, 1, pos(3), pos(4) - 18]);
            obj.LogTextScrollComp = [];
            obj.LogTextScrollCont = obj.LogTextComp;
        end % createView
    end
    
    %% Methods - Ordinary
    methods 
        
        function logMessage( obj , text , severity )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );

            if nargin<3,  severity='info';  end
            switch lower(severity(1))
              case 'i',  icon = 'info_16.gif'; color='gray';
              case 'w',  icon = 'warning.gif';       color='black';
              case 'e',  icon = 'stop_32.png';       color='red';
              otherwise, icon = 'demoicon.gif';        color='red';
            end
            icon = fullfile(icon_dir,icon);
            iconTxt =['<img src="file:///',icon,'" height=16 width=16>'];
            msgTxt = ['&nbsp;<span style="color:',color,'">',text,'</span>'];

            if obj.ShowDateTime == 1
                timeStr = datestr(now,'HH:MM:SS');
                newText =  ['<div>',iconTxt ,'&nbsp;', timeStr , ' - ' ,msgTxt ,'</div>'];
            elseif obj.ShowDateTime == 2
                timeStr = char(datetime);
                newText =  ['<div>',iconTxt ,'&nbsp;', timeStr , ' - ' ,msgTxt ,'</div>'];
            else
                newText =  ['<div>',iconTxt ,'&nbsp;', msgTxt ,'</div>'];
            end

            obj.LogHTML = [obj.LogHTML, newText];
            obj.LogTextComp.Data = struct('type','add','message',newText);
        end % logMessage

        function clearLog( obj )
            obj.LogHTML = '';
            obj.LogTextComp.Data = struct('type','clear');
        end % clearLog

        function toFile( obj , filename )

            modifiedStr = strrep(obj.LogHTML, '<img', '<br/><img');
            fileID = fopen(filename,'wt');
            fprintf(fileID,'%s\n',modifiedStr);
            fclose(fileID);

        end % toFile
    end % Ordinary Methods

    %% Methods - Protected Callbacks
    methods (Access = protected) 

        function linkLogCallbackFcn( obj , hobj , eventdata )
%             disp('debug');
           % eventdata
        end % linkLogCallbackFcn

    end

    %% Methods - Protected
    methods (Access = protected)  

        function update(obj)
        end % update

        function reSize( obj , ~ , ~ ) 
            set(obj.Container,'Units',obj.Units,'Position',obj.Position );
            pos = getpixelposition(obj.Container);

            obj.LogTextComp.Position = [ 1 , 1 , pos(3) , pos(4) - 18 ];
            obj.LabelComp.Position = [ 1 , pos(4) - 18 , pos(3) , 18 ];
        end %reSize
          
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the AvaliableParameterSelection object
            cpObj.AvaliableParameterSelection = copy(obj.AvaliableParameterSelection);
        end
        
    end
    
    %% Method - Delete
    methods
        function delete( obj ) 
       
            % Check if container is already being deleted
            if ishandle(obj.Container) && strcmp(get(obj.Container, 'BeingDeleted'), 'off')
                delete(obj.Container)
            end
            % Check if container is already being deleted
            if ishandle(obj.LogTextScrollCont) && strcmp(get(obj.LogTextScrollCont, 'BeingDeleted'), 'off')
                delete(obj.LogTextScrollCont)
            end
            % Check if container is already being deleted
            if ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont, 'BeingDeleted'), 'off')
                delete(obj.LabelCont)
            end

            % Remove references to the ui objects
            obj.Parent = [];
            obj.LogTextComp = [];
            obj.LogTextScrollComp = [];
            obj.LogTextScrollCont = [];
            obj.Label_TB = [];
            obj.LabelComp = [];
            obj.LabelCont = [];
            drawnow() % force repaint
        end % delete
    end
    
    
    
end


