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
            
            
%             obj.Label_TB = uicontrol(...
%                 'Parent',obj.Container,...
%                 'Style','text',...
%                 'String','Status Window',...
%                 'BackgroundColor', [ 0 , 0 , 102/255 ],...
%                 'ForegroundColor', [ 1 , 1, 1 ],...
%                 'Units','Pixels',...
%                 'FontSize',8,...
%                 'FontName','Courier New',...
%                 'Position',[ 6 , pos(4) - 15 , pos(3) , 15 ]);
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Status Window</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[ 1 , pos(4) - 18 , pos(3) , 18 ], obj.Container );


            obj.LogTextComp = javaObjectEDT('javax.swing.JTextPane');
            obj.LogTextComp.setEditable(false);
            set(obj.LogTextComp,'HyperlinkUpdateCallback',@obj.linkLogCallbackFcn);
            %logTextCBProp = handle(obj.LogTextComp,'CallbackProperties');
                
%             [obj.LogTextScrollComp,obj.LogTextScrollCont] = javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.LogTextComp)),[ 1 , 1 , pos(3) , pos(4) ], obj.Container  );
            [obj.LogTextScrollComp,obj.LogTextScrollCont] = javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.LogTextComp)),[ 1 , 1 , pos(3) , pos(4) - 18 ], obj.Container  );
%             obj.LogTextScrollCont.Units = 'Normal';
%             obj.LogTextScrollCont.Position = [ 0 , 0 , 1 , 1 ];
        end % createView
    end
    
    %% Methods - Ordinary
    methods 
        
        function logMessage( obj , text , severity )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            %fullfile(icon_dir,'New_24.png');
            % Ensure we have an HTML-ready editbox
            HTMLclassname = 'javax.swing.text.html.HTMLEditorKit';
            if ~isa(obj.LogTextComp.getEditorKit,HTMLclassname)
              obj.LogTextComp.setContentType('text/html');
            end

            % Parse the severity and prepare the HTML message segment
            if nargin<3,  severity='info';  end
            switch lower(severity(1))
              case 'i',  icon = 'info_16.gif'; color='gray';
              case 'w',  icon = 'warning.gif';       color='black';
              case 'e',  icon = 'stop_32.png';       color='red';
              otherwise, icon = 'demoicon.gif';        color='red';
            end
            %icon = fullfile(matlabroot,'toolbox/matlab/icons',icon);
            icon = fullfile(icon_dir,icon);
            iconTxt =['<img src="file:///',icon,'" height=16 width=16>'];
            msgTxt = ['&nbsp;<font color=',color,'>',text,'</font>'];
            if obj.ShowDateTime == 1
                newText =  [iconTxt ,'&nbsp;', datestr(now,'HH:MM:SS') , ' - ' ,msgTxt ];
            elseif obj.ShowDateTime == 2
                newText =  [iconTxt ,'&nbsp;', char(datetime) , ' - ' ,msgTxt ];
            else
            newText =  [iconTxt ,'&nbsp;', char(datetime) , ' - ' ,msgTxt ];
            end

% 
%                endPosition = obj.LogTextComp.getDocument.getLength;
%             if endPosition>0, newText=['<br/>' newText];  end
% 
%                % Place the HTML message segment at the bottom of the editbox
%                currentHTML = char(obj.LogTextComp.getText);
%                obj.LogTextComp.setText(strrep(currentHTML,'</body>',newText));
%                endPosition = obj.LogTextComp.getDocument.getLength;
%                obj.LogTextComp.setCaretPosition(endPosition); % end of content

            % Place the HTML message segment at the bottom of the editbox
            Doc = obj.LogTextComp.getDocument();
            obj.LogTextComp.getEditorKit().read(java.io.StringReader(newText), Doc, Doc.getLength());
            obj.LogTextComp.setCaretPosition(Doc.getLength());
        end % logMessage      

        function clearLog( obj )
            obj.LogTextComp.setText('</body>');
        end % clearLog
        
        function toFile( obj , filename )
            
            currentHTML = char(obj.LogTextComp.getText);
            modifiedStr = strrep(currentHTML, '<img', '<br/><img');
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

            obj.LogTextScrollCont.Units = 'Pixels';
            obj.LogTextScrollCont.Position = [ 1 , 1 , pos(3) , pos(4) - 18 ];
            
            obj.LabelCont.Units = 'Pixels';
            obj.LabelCont.Position = [ 1 , pos(4) - 18 , pos(3) , 18 ];
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
            
            
            
            % Remove references to the java objects
            obj.Parent = [];
            obj.LogTextComp = [];
            obj.LogTextScrollComp = [];
            obj.Label_TB = [];
            obj.LabelComp = [];
            drawnow() % force repaint
        end % delete
    end  
    
    
    
end


