classdef GainCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties ( Transient = true )  
        Parent
        Container
        GainTable
        Label
        LabelLarge
        ContainerLarge
        GainTableLarge
        ParentLarge
        LargeViewButton
%         JavaGainTable
%         JavaGainTableLarge
    end % Public properties
  
    %% Public properties - Data Storage
    properties   
        %GainTableData = {[],[]}
        %Gains UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
        Title
    end % Public properties
    
    %% Private properties
    properties
        GainTableData
        PrivatePosition
        PrivateUnits 
        PrivateVisible
        ShowValue
        PrivateEnable
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private) 
        Gains UserInterface.ControlDesign.Parameter
    end
    
    %% Dependant properties
    properties ( Dependent = true )
        Units
        Position  
        Visible
        Enable
    end % Dependant properties
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        EnlargeGainCollection
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = GainCollection(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            %obj.Parent = options.Parent; 
            
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;

            createView( obj , options.Parent );

        end % GainCollection
        
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
        
        function y = get.Gains( obj )
            y = UserInterface.ControlDesign.Parameter.empty;
            for i = 1:size(obj.GainTableData,1)
                if isempty(obj.GainTableData{i,3})
                    modifiedStr = obj.GainTableData{i,2};
                else
                    % This code handles the case when the variable is used
                    % within its own expression
                    possibleSymVars = symvar(obj.GainTableData{i,3});
                    lArray = strcmp(obj.GainTableData{i,1},possibleSymVars);
                    if any(lArray)
                        modifiedStr = strrep(obj.GainTableData{i,3}, obj.GainTableData{i,1}, obj.GainTableData{i,2});
                    else
                        modifiedStr = obj.GainTableData{i,3};
                    end
                end
                y(i) = UserInterface.ControlDesign.Parameter('Name',obj.GainTableData{i,1},'String',modifiedStr);
                %y(i) = UserInterface.ControlDesign.Parameter('Name',obj.GainTableData{i,1},'String',obj.GainTableData{i,2});
            end
        end % Parameters - Get
        
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
        
        function set.Enable(obj,value)
            obj.PrivateEnable = value;
            enablePanel( obj , value );          
        end % Enable - Set
        
        function y = get.Enable(obj)
            y = obj.PrivateVisible;          
        end % Enable - Get
        
    end % Property access methods

    %% Methods - View
    methods     
        
        function createView( obj , parent )
            if nargin == 1
                obj.Parent = figure();
            else 
                obj.Parent = parent;
            end
            % Create GUI 
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units',obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            
            panelPos = getpixelposition(obj.Container);

            obj.Label = uilabel('Parent',obj.Container,...
                'Text','Gains',...
                'FontName','Courier New',...
                'FontColor',[1 1 1],...
                'BackgroundColor',[55 96 146]/255,...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'Position',[ 1 , panelPos(4) - 16 , panelPos(3) , 16 ]);
  
            obj.GainTable = uitable('Parent',obj.Container,...
                'ColumnName',{'Gain','Value','Expression'},...
                'RowName',[],...
                'ColumnEditable', [false,false,true],...
                'ColumnFormat',{'char','numeric','char'},...
                'ColumnWidth',{80,95,105},...
                'Data',obj.GainTableData,...
                'CellEditCallback', @obj.gainTable_ce_CB,...
                'CellSelectionCallback', @obj.gainTable_cs_CB);    
            
            obj.LargeViewButton = uicontrol(...
                'Parent',obj.Container,...
                'Style','push',...
                'String','Edit',...
                'Callback',@obj.enlargeGainColl); 
            
%             obj.JavaGainTable = javaObjectEDT(Utilities.findjobj(obj.GainTable)); 
            
            % Force resize
            obj.reSize();
        end % createView
        
        function createExpandedView( obj  )
            if ~isempty(obj.ParentLarge) && isvalid(obj.ParentLarge)
                figure(obj.ParentLarge);
                return;
            end

            obj.ParentLarge = figure( ...
                    'Name', 'Gain Collection', ...
                    'NumberTitle', 'off',...
                    'MenuBar','none',...
                    'Visible','on',...
                    'Position',[323, 344, 1124, 457],...
                    'CloseRequestFcn', @obj.closeFigure_CB);  
       
            figPos = getpixelposition(obj.ParentLarge);
            % Create GUI 
            obj.ContainerLarge = uicontainer('Parent',obj.ParentLarge,...
                'Units','Normal',...
                'Position',[0, 0, 1, 1]);
%                 'Units','Pixels',...
%                 'Position',[1,1,figPos(3),figPos(4)]);
            set(obj.ContainerLarge ,'ResizeFcn',@obj.reSizeLarge);
            
            panelPos = getpixelposition(obj.ContainerLarge);
            
            labelStr = 'Gains';
            obj.LabelLarge = uilabel('Parent',obj.ContainerLarge,...
                'Text',labelStr,...
                'FontName','Courier New',...
                'FontColor',[1 1 1],...
                'BackgroundColor',[55 96 146]/255,...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'Position',[ 1 , panelPos(4) - 16 , panelPos(3) , 16 ]);
            
            obj.GainTableLarge = uitable('Parent',obj.ContainerLarge,...
                'ColumnName',{'Gain','Value','Expression'},...
                'RowName',[],...
                'ColumnEditable', [false,false,true],...
                'ColumnFormat',{'char','numeric','char'},...%'ColumnWidth',{80,95,205},...
                'ColumnWidth',{200,150,720},...
                'Data',obj.GainTableData,...
                'FontSize',12,...
                'CellEditCallback', @obj.gainTable_ce_CB,...
                'CellSelectionCallback', @obj.gainTable_cs_CB,...
                'Position',[1, 1, panelPos(3), panelPos(4) - 16]);
            
%             obj.JavaGainTableLarge = javaObjectEDT(Utilities.findjobj(obj.GainTableLarge)); 
            
            % Force resize
            obj.reSizeLarge();
        end % createExpandedView
        
    end
    
    %% Methods - Ordinary
    methods 
        
        function enlargeGainColl( obj , ~ , eventData )
            notify(obj,'EnlargeGainCollection');
        end % enlargeGainColl 
        
        function clearExpression( obj , gains )

            obj.update();
        end % clearExpression
        
        function setGains( obj , gains )
            if isempty(obj.GainTableData)
                obj.GainTableData = cell(length(gains),3);
            end
            oldGains = obj.GainTableData;
            obj.GainTableData = cell(length(gains),3);
            for i = 1:length(gains)
                
                logArray = strcmp(gains(i).Name,oldGains(:,1));

                % Initialize to last values
                if any(logArray) %logArray~=0
                    obj.GainTableData(i,:) = oldGains(logArray,:);
                end
                    
                % Update to new values
                obj.GainTableData{i,1} = gains(i).Name;
                obj.GainTableData{i,2} = gains(i).ValueString;

            end
            obj.ShowValue = true(1,length(gains));
            updateTable(obj);
            obj.update();
        end % setGains
        
        function gainTable_ce_CB( obj , ~ , eventData )
            gainIndex = eventData.Indices(1);
            obj.ShowValue(gainIndex) = false;
            obj.GainTableData{gainIndex,3} = eventData.EditData; 
            obj.update();
        end % gainTable_ce_CB

        function gainTable_cs_CB( obj , ~ , ~ )
   

        end % gainTable_cs_CB
        
        function reSize( obj , ~ , ~ )
            panelPos = getpixelposition(obj.Container); 

            obj.Label.Position = [ 1 , panelPos(4) - 16 , panelPos(3) , 16 ];

            set(obj.GainTable,'Position',[ 1 , 40 , panelPos(3) - 5 , panelPos(4) - 60 ] );

            set(obj.LargeViewButton,'Position',[ 1 , 5 , panelPos(3) - 5 , 26 ] );
        end       
        
        function reSizeLarge( obj , ~ , ~ )
            panelPos = getpixelposition(obj.ParentLarge); 

            obj.LabelLarge.Position = [ 1 , panelPos(4) - 16 , panelPos(3) , 16 ];

            set(obj.GainTableLarge,'Position',[ 1 , 1 , panelPos(3) , panelPos(4) - 16 ] );
        end % reSizeLarge    
        
        function closeFigure_CB( obj , ~ , ~ )
            updateTable(obj);
            drawnow();pause(0.1);
            delete(obj.ParentLarge);
        end % closeFigure_CB    
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)  
       
        function update(obj)
   
        end
        
        function updateTable(obj)
%             obj.GainTableData(~obj.ShowValue,2) = {'-'};
            set(obj.GainTable,'Data',obj.GainTableData);
            if ishandle(obj.GainTableLarge)
                set(obj.GainTableLarge,'Data',obj.GainTableData);
            end
        end % updateTable
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Gains object
            cpObj.Gains = copy(obj.Gains);
        end % copyElement
        
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function enablePanel( obj , value )
            if value
                set(obj.GainTable,'Enable','on');

            else
              	set(obj.GainTable,'Enable','off');

            end
            
        end % enablePanel
        
    end
    
end

function outHtml = colorText(text, inColor)
    % return a HTML string with colored font
    outHtml = ['<html><font color="', ...
    'rgb(',num2str(inColor(1)),',',num2str(inColor(2)),',',num2str(inColor(3)),')', ...
    '">', ...
    text, ...
    '</font></html>'];
end % colText

function text = parseSelMdlName(inText)
    if iscell(inText)
        text   = {};
        for i = 1:length(inText)
            [c,~] = regexp(inText{i}, '<html><font color="rgb\((.*))">(.*)</font></html>','tokens','split');
            text{i}   = c{1}{2};
        end
    end

    if ischar(inText)
        text   = '';
        [c,~] = regexp(inText, '<html><font color="rgb\((.*))">(.*)</font></html>','tokens','split');
        text   = c{1}{2};
    end
end % parseSelMdlName
