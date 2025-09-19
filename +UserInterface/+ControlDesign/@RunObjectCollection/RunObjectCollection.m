classdef RunObjectCollection < hgsetget 
    
    %% Public Properties
    properties 

        RunObjects = UserInterface.ControlDesign.RunObject.empty
    end % Public properties
    
    %% Private Properties
    properties ( Access = private ) 

        
        
        PrivatePosition
        PrivateUnits
        
        PrivateTableHeader = {' ',' '}
      
        CallBackReEntered = false
        
        ExpansionState
        
    end % Private properties
    
    %% Hidden Properties
    properties ( Hidden = true ) 
        
    end % Private properties
    
    %% Public properties - Graphics Handles
    properties (Transient = true)
        Parent
        Container
        TableContainer

        JTable

        LabelComp
        LabelCont

        AddBatchButton
        RemoveBatchButton

        SelectedRows
    end % Public properties
    
    properties ( Dependent = true )
        Position
        Units
    end % Dependant properties
    
    %% Dependant properties - Private SetAccess
    properties (Dependent = true, SetAccess = private)  
        
        TableData
        
        
        ParentFigure
        
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true)
        
        TableHeader
    end % Dependant properties 
    
    %% Constant Properties
    properties (Constant)
        
    end   
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        NewBatch
        RunBatch
        ShowBatchPlots
        UpdateBatchView
        ClearPlots
        RemoveBatch
    end
    
    %% Methods - Constructor
    methods      
        function obj = RunObjectCollection(varargin)
            
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Parent          = options.Parent;
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;

            selectionView( obj , [] ); 
            
        end % RunObjectCollection
    end % Constructor

    %% Methods - Property Access
    methods
        
        function y = get.ParentFigure( obj )
            y = ancestor(obj.Container,'Figure','toplevel');
        end % ParentFigure
        
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
        
        function data = get.TableData(obj)
            data = {};%cell(length(obj.RunObjects),4);
            k = 0;
            for i = 1:length(obj.RunObjects)
                for j = 1:length(obj.RunObjects(i).AnalysisOperCond)
                    k = k + 1;
                    data{k,1} = obj.RunObjects(i).Title;

                    data{k,2} = num2str(round2(obj.RunObjects(i).AnalysisOperCond(j).FlightCondition.(obj.PrivateTableHeader{2})));
                    
                    data{k,3} = num2str(round2(obj.RunObjects(i).AnalysisOperCond(j).FlightCondition.(obj.PrivateTableHeader{3})));
                    
                    try
                        data{k,4} = num2str(obj.RunObjects(i).AnalysisOperCond(j).Inputs.get(obj.PrivateTableHeader{4}).Value);
                    catch
                        data{k,4} = num2str(obj.RunObjects(i).AnalysisOperCond(j).Outputs.get(obj.PrivateTableHeader{4}).Value);
                    end
                    
                    try
                        data{k,5} = num2str(obj.RunObjects(i).AnalysisOperCond(j).MassProperties.get(obj.PrivateTableHeader{5}));
                    catch
                        data{k,5} = obj.RunObjects(i).AnalysisOperCond(j).MassProperties.get(obj.PrivateTableHeader{5});
                    end
                end
            end

        end % TableData
        
        function header = get.TableHeader(obj)
            header = obj.PrivateTableHeader;
        end % TableHeader
        
        function set.TableHeader(obj , x )
            obj.PrivateTableHeader = ['Title',x];
        end % TableHeader   
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
               
        function addRunObject(obj, newRunObj)

            obj.RunObjects(end + 1) = newRunObj;
            updateTreeTable( obj );
            
            if ~isempty(obj.RunObjects)
                logArray = [obj.RunObjects.IsActive];
                if ~any(logArray) && ~isempty(logArray)
                    logArray(end) = true; % if no batch objects are active set the last added one to active
                end
            else
                logArray = [];
            end
            notify(obj,'UpdateBatchView',GeneralEventData(obj.RunObjects(logArray)));
            
        end % addRunObject     
           
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
        function selectionView(obj,parent)
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            if ~isempty(parent)
                obj.Parent = parent;
            end
            obj.Container = uipanel('Parent',obj.Parent,...
                'BorderType','None',...
                'Units', obj.Units,...
                'Position',obj.Position,...
                'Visible','on');
            set(obj.Container,'ResizeFcn',@obj.resize);         

            % get parent position
            %panelPos = getpixelposition(obj.Container);
            try
                bkColor = get(obj.Container,'BackgroundColor');
            catch
               bkColor = get(obj.Container,'Color'); 
            end
            popupFtSize = 8;
            
            
            panelPos = getpixelposition(obj.Container);

            obj.LabelComp = uilabel('Parent',obj.Container,...
                'Text',' Batch Run',...
                'FontName','Courier New',...
                'FontColor',[1 1 1],...
                'BackgroundColor',[55 96 146]/255,...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'Position',[ 1 , panelPos(4) - 17 , panelPos(3) , 16 ]);
            obj.LabelCont = obj.LabelComp;
            
            
% %             %%% Run Batch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %             runBatchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
% %             runBatchJButton.setText('Run');        
% %             runBatchJButtonH = handle(runBatchJButton,'CallbackProperties');
% %             set(runBatchJButtonH, 'ActionPerformedCallback',@obj.runBatch)
% %             myIcon = fullfile(icon_dir,'Run_16.png');
% %             runBatchJButton.setIcon(javax.swing.ImageIcon(myIcon));
% %             runBatchJButton.setToolTipText('Run');
% %             runBatchJButton.setFlyOverAppearance(true);
% %             runBatchJButton.setBorder([]);
% %             runBatchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
% %             runBatchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
% %             runBatchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
% %             [obj.RunBatchJButtonHComp,obj.RunBatchJButtonHCont] = javacomponent(runBatchJButton, [], obj.Container);   
            

            %%% Add Batch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            addIcon = fullfile(icon_dir,'New_16.png');
            obj.AddBatchButton = uibutton(obj.Container,'Text','New',...
                'Icon',addIcon,...
                'Tooltip','Create a New Empty Batch',...
                'ButtonPushedFcn',@obj.newBatch);

            %%% Remove Batch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            removeIcon = fullfile(icon_dir,'StopX_16.png');
            obj.RemoveBatchButton = uibutton(obj.Container,'Text','Remove',...
                'Icon',removeIcon,...
                'Tooltip','Remove',...
                'ButtonPushedFcn',@obj.removeBatch);



            obj.TableContainer= uipanel('Parent',obj.Container,...
               'BorderType','none',...
               'Units','Pixels',...
               'Position',[2,2,panelPos(3)-7,panelPos(4)-116]);

           % obj.updateTable;
            obj.updateTreeTable;
 

            update(obj);
            resize( obj , [] , [] );

        end % selectionView
        
        function updateTreeTable( obj )
            data = obj.TableData;
            headers = obj.TableHeader;
            if isempty(obj.JTable) || ~isvalid(obj.JTable)
                obj.JTable = uitable('Parent',obj.TableContainer,...
                    'Data',data,...
                    'ColumnName',headers,...
                    'Units','normalized',...
                    'Position',[0 0 1 1],...
                    'CellSelectionCallback',@obj.mousePressedInTable);

                cm = uicontextmenu(obj.ParentFigure);
                obj.JTable.ContextMenu = cm;
                uimenu(cm,'Text','Select All',...
                    'MenuSelectedFcn',@obj.selectAll,'Callback',@obj.selectAll);
                uimenu(cm,'Text','DeSelect All',...
                    'MenuSelectedFcn',@obj.deselectAll,'Callback',@obj.deselectAll);
                uimenu(cm,'Separator','on','Text','Remove',...
                    'MenuSelectedFcn',@(src,evt)obj.removeBatch(src,evt,obj.SelectedRows),...
                    'Callback',@(src,evt)obj.removeBatch(src,evt,obj.SelectedRows));
                uimenu(cm,'Text','Remove All',...
                    'MenuSelectedFcn',@obj.removeAll,'Callback',@obj.removeAll);
            else
                obj.JTable.Data = data;
                obj.JTable.ColumnName = headers;
            end
        end % updateTreeTable

        function setColumnRenderersEditors(~)
            % No custom renderers needed for MATLAB uitable implementation
        end  % setColumnRenderersEditors

    end % Ordinary Methods
    
    %% Methods FilterCallbacks
    methods        
        
        function newBatch( obj , ~ , ~ )
            notify(obj,'NewBatch');
        end % newBatch

        function removeBatch( obj , ~ , ~ , selRows)

            % Removes selected rows from the table and underlying data
            if nargin < 4 || isempty(selRows)
                selRows = obj.SelectedRows;
            end
            if isempty(selRows)
                return;
            end

            rows2Remove = unique(selRows);
            k = 0;
            runsToRemove = false(1,numel(obj.RunObjects));
            for i = 1:numel(obj.RunObjects)
                ocIdx = [];
                for j = 1:numel(obj.RunObjects(i).AnalysisOperCond)
                    k = k + 1;
                    if ismember(k,rows2Remove)
                        ocIdx(end+1) = j; %#ok<AGROW>
                    end
                end
                if ~isempty(ocIdx)
                    if numel(ocIdx) == numel(obj.RunObjects(i).AnalysisOperCond)
                        runsToRemove(i) = true;
                    else
                        obj.RunObjects(i).AnalysisOperCond(ocIdx) = [];
                    end
                end
            end

            if any(runsToRemove)
                if any([obj.RunObjects(runsToRemove).IsActive])
                    notify(obj,'ClearPlots');
                end
                obj.RunObjects(runsToRemove) = [];
            end

            updateTreeTable(obj);

            if ~isempty(obj.RunObjects)
                logArrayAct = [obj.RunObjects.IsActive];
            else
                logArrayAct = [];
            end
            notify(obj,'UpdateBatchView',GeneralEventData(obj.RunObjects(logArrayAct)));

        end % removeBatch
        
        function removeAll( obj , ~ , ~ ) 
            obj.RunObjects = UserInterface.ControlDesign.RunObject.empty;
            updateTreeTable(obj);
            notify(obj,'UpdateBatchView',GeneralEventData([]));
        end % removeAll
  
    end

    %% Methods
    methods 
        
        
    end
    
    %% Methods - Update
    methods (Access = protected) 
        
        function update(obj)

            
        end % update   
        
        function resize( obj , ~ , ~ )
            panelPos = getpixelposition(obj.Container);

            obj.LabelCont.Position = [ 1 , panelPos(4) - 17 , panelPos(3) , 16 ];

            obj.AddBatchButton.Position = [ 15 , panelPos(4) - 60 , 75 , 25 ];

            obj.RemoveBatchButton.Position = [ panelPos(3) - 90 , panelPos(4) - 60 , 75 , 25 ];

            obj.TableContainer.Position = [2,5,panelPos(3)-5,panelPos(4)-86];
        end % resize
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the RunObjects object
            cpObj.RunObjects = copy(obj.RunObjects);
            
        end
                
    end

    %% Method - Callbacks
    methods (Access = protected)
        
        function mousePressedInTable( obj , ~ , hEvent )
            if isempty(hEvent.Indices)
                obj.SelectedRows = [];
                return;
            end
            selRows = unique(hEvent.Indices(:,1));
            obj.SelectedRows = selRows;

            % determine active run based on first selected row
            k = 0;
            runIndex = [];
            for i = 1:numel(obj.RunObjects)
                for j = 1:numel(obj.RunObjects(i).AnalysisOperCond)
                    k = k + 1;
                    if ismember(k,selRows)
                        runIndex = i;
                        break;
                    end
                end
                if ~isempty(runIndex)
                    break;
                end
            end
            if ~isempty(runIndex)
                [obj.RunObjects.IsActive] = deal(false);
                obj.RunObjects(runIndex).IsActive = true;
                notify(obj,'UpdateBatchView',GeneralEventData(obj.RunObjects(runIndex)));
            end
        end % mousePressedInTable

        function keyReleasedInTable( obj , hModel , hEvent )

        end % keyReleasedInTable      
        
        function focusGainedInTable( obj , hModel , hEvent )
        end % focusGainedInTable      
        
        function keyPressedInTable( obj , hModel , hEvent )

        end % keyPressedInTable      
        
        function keyTypedInTable( obj , hModel , hEvent )

        end % keyTypedInTable   
        
        function dataUpdatedInTable( obj , hModel , hEvent , jtable )
            if ~obj.CallBackReEntered
                try
                    e=hEvent.getEvents;
                    modifiedRow = e(2).getFirstRow;


                    title = hModel.getValueAt(modifiedRow,0);  
                    selectedValue = title.isExpanded;

                    title=char(title);
                    logArray = strcmp({obj.RunObjects.Title},strtrim(title(8:end)));
                    obj.RunObjects(logArray).Title;
                    obj.RunObjects(logArray).Selected = selectedValue;

                    obj.ExpansionState = hModel.getActualModel.getExpansionState;
                end
            
            end

        end % dataUpdatedInTable
        
        function selectAll( obj , ~ , ~ )
            [obj.RunObjects.Selected] = deal(true);
            if ~isempty(obj.JTable)
                obj.SelectedRows = (1:size(obj.JTable.Data,1))';
            end
        end % selectAll

        function deselectAll( obj , ~ , ~ )
            [obj.RunObjects.Selected] = deal(false);
            obj.SelectedRows = [];
        end % deselectAll
        
        function updateColumnJTable( obj , columnNum , value )
            if isempty(obj.JTable)
                return;
            end
            data = obj.JTable.Data;
            n = min(size(data,1), numel(value));
            data(1:n, columnNum+1) = num2cell(value(1:n));
            obj.JTable.Data = data;
        end % updateColumnJTable
        
    end    
    
    %% Methods - Delete
    methods
        
        function delete( obj )
            obj.JTable = [];
            obj.LabelComp = [];

            if ishandle(obj.TableContainer) && strcmp(get(obj.TableContainer,'BeingDeleted'),'off')
                delete(obj.TableContainer);
            end
            if ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont,'BeingDeleted'),'off')
                delete(obj.LabelCont);
            end

            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.RunObjects);
            end




    %          % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
            try %#ok<*TRYNC>             
                delete(obj.TableContainer);
            end
            
            
        end % delete
        
    end
    
end

function z = round2(x)

y = 1e-10;
z = round(x/y)*y;
z = round(z,5,'significant');
end % round2


