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
        JScroll
        
        
        
        JTableH
        
        JHScroll
        HContainer
        
       
        
        
        LabelComp
        LabelCont
        
%         RunBatchJButtonHComp
%         RunBatchJButtonHCont
        
        AddBatchJButtonHComp
        AddBatchJButtonHCont
        
        RemoveBatchJButtonHComp
        RemoveBatchJButtonHCont
        
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
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Batch&nbsp;Run</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[ 1 , panelPos(4) - 17 , panelPos(3) , 16 ], obj.Container );
            
            
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
            addBatchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            addBatchJButton.setText('New');        
            addBatchJButtonH = handle(addBatchJButton,'CallbackProperties');
            set(addBatchJButtonH, 'ActionPerformedCallback',@obj.newBatch)
            myIcon = fullfile(icon_dir,'New_16.png');
            addBatchJButton.setIcon(javax.swing.ImageIcon(myIcon));
            addBatchJButton.setToolTipText('Create a New Empty Batch');
            addBatchJButton.setFlyOverAppearance(true);
            addBatchJButton.setBorder([]);
            addBatchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            addBatchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            addBatchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            [obj.AddBatchJButtonHComp,obj.AddBatchJButtonHCont] = javacomponent(addBatchJButton, [], obj.Container);  
            
            %%% Remove Batch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            removeBatchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            removeBatchJButton.setText('Remove');        
            removeBatchJButtonH = handle(removeBatchJButton,'CallbackProperties');
            set(removeBatchJButtonH, 'ActionPerformedCallback',@obj.removeBatch)
            myIcon = fullfile(icon_dir,'StopX_16.png');
            removeBatchJButton.setIcon(javax.swing.ImageIcon(myIcon));
            removeBatchJButton.setToolTipText('Remove');
            removeBatchJButton.setFlyOverAppearance(true);
            removeBatchJButton.setBorder([]);
            removeBatchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            removeBatchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            removeBatchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            [obj.RemoveBatchJButtonHComp,obj.RemoveBatchJButtonHCont] = javacomponent(removeBatchJButton, [], obj.Container);  


                 

            obj.TableContainer= uicontainer('Parent',obj.Container,...
               'Units','Pixels',...
               'Position',[2,2,panelPos(3)-7,panelPos(4)-116]);
            
           % obj.updateTable;
            obj.updateTreeTable;
 

            update(obj);
            resize( obj , [] , [] );

        end % selectionView
        
        function updateTreeTable( obj )
            if ~usejava('swing')
                error('TreeTable:NeedSwing','Java tables require Java Swing.');
            end
            import javax.swing.*

            delete(obj.HContainer);
            % Create a sortable uitable within the container
            try
              % Use JideTable if available on this system
              com.mathworks.mwswing.MJUtilities.initJIDE;

              % Prepare the tree-table with the requested data & headers
              %model = javax.swing.table.DefaultTableModel(paramsStruct.data, paramsStruct.headers);

              try
                  model = MultiClassTableModel(obj.TableData,obj.TableHeader);  %(model)
              catch
                  % Revert to the default table model
                  % (which has problematic numeric sorting since it does not recognize numeric data columns)
                  warning('Reverting to Default table model');
                  model = javax.swing.table.DefaultTableModel(obj.TableData,obj.TableHeader);
              end
               
             
              obj.JTable = javaObjectEDT('com.jidesoft.grid.GroupTable',model);
              %jtable = eval('com.jidesoft.grid.GroupTable(model);');  % prevent JIDE alert by run-time (not load-time) evaluation
              obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');
              obj.JTable.setRowAutoResizes(true);
              obj.JTable.setColumnAutoResizable(true);
              obj.JTable.setColumnResizable(true);
              obj.JTable.setShowGrid(false);
                obj.JTable.getTableHeader().setReorderingAllowed(false);
                obj.JTable.getTableHeader().setShowSortArrow(false);
                obj.JTable.setAutoCreateRowSorter(false);
              % Wrap the standard model in a JIDE GroupTableModel
              %model = obj.JTable.getModel;
              model = com.jidesoft.grid.DefaultGroupTableModel(model);
              %model = StyledGroupTableModel(obj.JTable.getModel);
              model.addGroupColumn(0);
              model.groupAndRefresh;
              % Try and set the expansion state
              try
                model.setExpansionState(obj.ExpansionState);    
              end
              obj.JTable.setModel(model);

              % Enable multi-column sorting
              obj.JTable.setSortable(true);

              % Automatically resize all columns - this can be extremely SLOW for >1K rows!
              %jideTableUtils = eval('com.jidesoft.grid.TableUtils;');  % prevent JIDE alert by run-time (not load-time) evaluation
              %jideTableUtils.autoResizeAllColumns(obj.JTable);

              % Set default cell renderers/editors based on the requested column types
              obj.setColumnRenderersEditors();
              obj.JTable.setSelectionBackground(java.awt.Color(0.9608*.8,0.9608*.8, 0.9608));  % light-blue
                obj.JTable.setGridColor(java.awt.Color.lightGray);
              % Modify the group style (doesn't work on new Matlab releases)
              %{
              try
                  iconPath = paramsStruct.iconfilenames{2};
                  groupStyle = model.getGroupStyle;
                  groupStyle.setBackground(java.awt.Color(.7,.7,.7));  % light-gray
                  if ~isempty(iconPath)
                      icon = javax.swing.ImageIcon(iconPath);
                      groupStyle.setIcon(icon);
                  end
              catch
                  %fprintf(2, 'Invalid group icon: %s (%s)\n', char(iconPath), lasterr);
                  a=1;   % never mind - probably an invalid icon
              end
              %}
              try
                  obj.JTable.setExpandedIcon (javax.swing.ImageIcon(checkedIcon));
                  obj.JTable.setCollapsedIcon(javax.swing.ImageIcon(uncheckedIcon));
              catch
                  %fprintf(2, 'Invalid group icon: %s (%s)\n', char(iconPath), lasterr);
                  a=1;   % never mind - probably an invalid icon
              end

% %               % Attach a GroupTableHeader so that we can use Outlook-style interactive grouping
% %               try
% %                   obj.JTableHeader = javaObjectEDT('com.jidesoft.grid.GroupTableHeader',obj.JTable);
% %                   obj.JTable.setTableHeader(jTableHeader);
% %                   if paramsStruct.interactivegrouping
% %                       jTableHeader.setGroupHeaderEnabled(true);
% %                   end
% %               catch
% %                   warning('TtreeTable:InteractiveGrouping','InteractiveGrouping is not supported - try using a newer Matlab release');
% %               end

              % Present the tree-table within a scrollable viewport on-screen
              obj.JScroll = javaObjectEDT(JScrollPane(obj.JTable));
              try
                  % HG2 sometimes needs double(), sometimes not, so try both of them...
                  [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], double(obj.TableContainer));
              catch
                  [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], obj.TableContainer);
              end
              set(obj.HContainer,'units','normalized','pos',[0,0,1,1]);  % this will resize the table whenever its container is resized
              pause(0.05);
            catch
              err = lasterror;
              obj.HContainer = [];
            end
            
%             cellRenderer = getDefaultCellRenderer();
%             icon = javax.swing.ImageIcon(checkedIcon);
%             cellRenderer.setIcon(icon);
%             obj.JTable.getColumnModel.getColumn(0).setCellRenderer(cellRenderer);

            % Fix for JTable focus bug : see http://bugs.sun.com/bugdatabase/view_bug.do;:WuuT?bug_id=4709394
            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);

            % Enable multiple row selection, auto-column resize, and auto-scrollbars
            %obj.JScroll = mtable.TableScrollPane;
            obj.JScroll.setVerticalScrollBarPolicy(obj.JScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.JScroll.setHorizontalScrollBarPolicy(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            obj.JTable.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);

            % Comment the following line in order to prevent column resize-to-fit
%             obj.JTableH.setAutoResizeMode(obj.JTable.java.AUTO_RESIZE_SUBSEQUENT_COLUMNS)
            %obj.JTable.setAutoResizeMode(obj.JTable.java.AUTO_RESIZE_OFF)


            % Move the selection to first table cell (if any data available)
            if (obj.JTable.getRowCount > 0)
              obj.JTable.changeSelection(0,0,false,false);
            end

            % Set default editing & selection callbacks
            % {
            try
                % Set Callbacks
                obj.JTableH.MousePressedCallback = @obj.mousePressedInTable;
                obj.JTableH.KeyReleasedCallback  = @obj.keyReleasedInTable; 
                obj.JTableH.FocusGainedCallback  = @obj.focusGainedInTable;
                obj.JTableH.KeyPressedCallback   = @obj.keyPressedInTable;
                obj.JTableH.KeyTypedCallback     = @obj.keyTypedInTable;
                JModelH = handle(obj.JTable.getModel, 'CallbackProperties');
                JModelH.TableChangedCallback     = {@obj.dataUpdatedInTable,obj.JTable};
                set(handle(obj.JTable.getModel, 'CallbackProperties'),  'TableChangedCallback', {@obj.dataUpdatedInTable,obj.JTable});   
                
%               oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty');
%               %set(handle(getOriginalModel(obj.JTable),'CallbackProperties'), 'TableChangedCallback', {@tableChangedCallback, obj.JTable});
%               set(handle(obj.JTable.getSelectionModel,'CallbackProperties'), 'ValueChangedCallback', {@selectionCallback,    obj.JTable});
%               warning(oldWarnState);
            catch

            end
           
%             % Set expandedState
%             obj.CallBackReEntered
%             
%                         
%             multiClassTblMdl = obj.JTable.getModel.getActualModel.getActualModel;
%             defGroupTblMdl = obj.JTable.getModel.getActualModel;
%             model = obj.JTable.getModel;
%             
%             title = hModel.getValueAt(modifiedRow,0);  
%             selectedValue = title.isExpanded;
%            obj.JTable.repaint;
            try
                
%                 obj.RunObjects([obj.RunObjects.IsActive]).Title
%                  obj.JTable.setRowSelectionInterval(3, 3)
%                 obj.CallBackReEntered = true;
%                 model.setExpansionState(obj.ExpansionState);
%                 obj.CallBackReEntered = false;
            catch
    
            end
        end % updateTreeTable

        function setColumnRenderersEditors(obj)

            import javax.swing.*

            % Set the column's cellRenderer and editor based on the declared ColumnTypes

            cellRenderer = getDefaultCellRenderer();  % default cellRenderer = label

                for colIdx = 0:3
                    try
                        jtf = JTextField;
                        jtf.setEditable(false);
                        jte = DefaultCellEditor(jtf);
                        jte.setClickCountToStart(intmax);
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellEditor(jte);
                    catch
                    end
                obj.JTable.getColumnModel.getColumn(0).setCellRenderer(cellRenderer);
                end

        end  % setColumnRenderersEditors

    end % Ordinary Methods
    
    %% Methods FilterCallbacks
    methods        
        
        function newBatch( obj , ~ , ~ )
            notify(obj,'NewBatch');
        end % newBatch

        function removeBatch( obj , ~ , ~ , selRows)
                       
           % Removes Rows from Table
            multiClassTblMdl = obj.JTable.getModel.getActualModel.getActualModel;
            defGroupTblMdl = obj.JTable.getModel.getActualModel;
            model = obj.JTable.getModel;
            
            if nargin == 3
                selRows = obj.JTable.getSelectedRows;
            end
            
            
            %*** Remove all operating conditions from selected Batches *** 
            rows2Remove = [];
            batch2Remove = {};
            for j = 1:length(selRows)
                row = model.getRowAt(selRows(j));
                if isa(row,'com.jidesoft.grid.DefaultGroupRow')
                    title = char(row.toString);
                    batch2Remove{end+1} = strtrim(title(9:end));
                    
                    indRows = row.getChildren;
                    for  i = 1:indRows.size
                        indRow = indRows.get(i-1);
                        rows2Remove(end+1) = indRow.getRowIndex; %#ok<*AGROW>
                    end   
                elseif isa(row,'com.jidesoft.grid.IndexReferenceRow')
                    rows2Remove(end+1) = row.getRowIndex;
                else
                    error('Unknown Row in Batch Table');
                end
            end

            rows2Remove = unique(rows2Remove + 1);
            
            % Get actual table as a cell array
            for k = 0:multiClassTblMdl.getRowCount() - 1
                for j = 0:multiClassTblMdl.getColumnCount() - 1
                    actualTableData{k + 1,j + 1} = (multiClassTblMdl.getValueAt(k, j));
                end
            end
            
            %runNames = unique(actualTableData(:,1);
            runNames = {obj.RunObjects.Title};
            for i = 1:length(runNames)
                logArray = strcmp(actualTableData(:,1),runNames{i});
                indPerRunObj = find(logArray);
                oc2Remove = ismember( indPerRunObj , rows2Remove );    
                if all(oc2Remove)
                    obj.RunObjects(i).AnalysisOperCond = lacm.OperatingCondition.empty;
                else
                    obj.RunObjects(i).AnalysisOperCond(oc2Remove) = []; 
                end    
            end   
                    
            % Remove Batch if the batch header was selected
            logArray = ismember({obj.RunObjects.Title},batch2Remove);
            if any(logArray) % Skip if there are no batches to remove
                if any(obj.RunObjects(logArray).IsActive)
                    notify(obj,'ClearPlots')
                end
                %notify(obj,'RemoveBatch',GeneralEventData({obj.RunObjects(logArray).Title}));
                if all(logArray)
                    obj.RunObjects = UserInterface.ControlDesign.RunObject.empty; 
                else
                    obj.RunObjects(logArray) = [];
                end
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
            
%             % Call super class method
%             resize@lacm.OperatingConditionCollection(obj,[],[]);
            
            panelPos = getpixelposition(obj.Container);
            
            obj.LabelCont.Units = 'Pixels';
            obj.LabelCont.Position = [ 1 , panelPos(4) - 17 , panelPos(3) , 16 ];




            set(obj.AddBatchJButtonHCont,...
                'Units','Pixels',...
                'Position',[ 15 , panelPos(4) - 60 , 75 , 25 ]);


           set(obj.RemoveBatchJButtonHCont,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 90 , panelPos(4) - 60 , 75 , 25 ]);

            set(obj.TableContainer,'units', 'pixels','position',[2,5,panelPos(3)-5,panelPos(4)-86]); 
            
%             set(obj.RunBatchJButtonHCont,...
%                 'Units','Pixels',...
%                 'Position',[ 5 , 5 , 75 , 25 ]);

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
        
        function mousePressedInTable( obj , hModel , hEvent )

            defGroupTblMdl = obj.JTable.getModel.getActualModel;
            model = obj.JTable.getModel;
            selRows = obj.JTable.getSelectedRows;
            
            if hEvent.isMetaDown
                %this_dir = fileparts( mfilename( 'fullpath' ) );
                %icon_dir = fullfile( this_dir,'..','..','Resources' );

                jmenu = javaObjectEDT('javax.swing.JPopupMenu');

                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem2h.ActionPerformedCallback = @obj.selectAll;


                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>DeSelect All');
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem3h.ActionPerformedCallback = @obj.deselectAll;

                jmenu.add(menuItem2);
                jmenu.add(menuItem3);
                if ~isempty(selRows)
                    
                    menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove');
                    menuItem4h = handle(menuItem4,'CallbackProperties');
                    menuItem4h.ActionPerformedCallback = {@obj.removeBatch,selRows};


                    menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
                    menuItem5h = handle(menuItem5,'CallbackProperties');
                    menuItem5h.ActionPerformedCallback = @obj.removeAll;
                    
                    jmenu.addSeparator();               
                    jmenu.add(menuItem4);
                    jmenu.add(menuItem5);
                end
                jmenu.show(obj.JTable, 35 , 60 );
                jmenu.repaint;
            else

%                 defGroupTblMdl = obj.JTable.getModel.getActualModel;
%                 model = obj.JTable.getModel;
% 
%                 selRows = obj.JTable.getSelectedRows;
                if length(selRows) ~= 1
                    return;
                end
                actRow = defGroupTblMdl.getActualRowAt(selRows);
                if actRow ~= -1
                    return;
                end
                title = model.getValueAt(selRows,0);
                title=char(title);
                logArray = strcmp({obj.RunObjects.Title},strtrim(title(8:end)));
                % Clear IsActive
                [obj.RunObjects(true(length(obj.RunObjects),1)).IsActive] = deal(false);
                % Set current IsActive
                obj.RunObjects(logArray).IsActive = true;
                notify(obj,'UpdateBatchView',GeneralEventData(obj.RunObjects(logArray)));


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
            obj.CallBackReEntered = true;
            obj.JTable.expandAll;
            pause(0.01);
            obj.CallBackReEntered = false;
            
            [obj.RunObjects.Selected] = deal(true);

        end % selectAll 
        
        function deselectAll( obj , ~ , ~ )
            obj.CallBackReEntered = true;
            obj.JTable.collapseAll;
            pause(0.01);
            obj.CallBackReEntered = false;
            
            [obj.RunObjects.Selected] = deal(false);
            
        end % deselectAll
        
        function updateColumnJTable( obj , columnNum , value )
            for i=1:double(obj.JTable.getRowCount)
                obj.JTable.setValueAt(value(i), (i - 1) ,columnNum);
            end
        end % updateColumnJTable
        
    end    
    
    %% Methods - Delete
    methods
        
        function delete( obj )
            % Java Components 
            obj.JTable = [];
            obj.JScroll = [];
            obj.JTableH = [];
            obj.JHScroll = [];
            obj.LabelComp = [];
            
            % Javawrappers
            % Check if container is already being deleted
            if ishandle(obj.HContainer) && strcmp(get(obj.HContainer, 'BeingDeleted'), 'off')
                delete(obj.HContainer);
            end
            if ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont, 'BeingDeleted'), 'off')
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


function jImage = checkedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0;
     2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1;
     2,2,2,2,2,2,2,2,2,2,2,2,0,2,3,1;
     2,2,1,1,1,1,1,1,1,1,1,0,2,2,3,1;
     2,2,1,1,1,1,1,1,1,1,0,1,2,2,3,1;
     2,2,1,1,1,1,1,1,1,0,1,1,2,2,3,1;
     2,2,1,1,1,1,1,1,0,0,1,1,2,2,3,1;
     2,2,1,0,0,1,1,0,0,1,1,1,2,2,3,1;
     2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
     2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
     2,2,1,1,1,0,0,1,1,1,1,1,2,2,3,1;
     2,2,1,1,1,0,1,1,1,1,1,1,2,2,3,1;
     2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
     2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
     2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
     1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
 map = [0.023529,0.4902,0;
        1,1,1;
        0,0,0;
        0.50196,0.50196,0.50196;
        0.50196,0.50196,0.50196;
        0,0,0;
        0,0,0;
        0,0,0];
    
    warning('off','MATLAB:im2java:functionToBeRemoved');
    jImage = im2java(I,map);
end

function jImage = uncheckedIcon()
 I = uint8(...
   [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
 map = ...
  [0.023529,0.4902,0;
   1,1,1;
   0,0,0;
   0.50196,0.50196,0.50196;
   0.50196,0.50196,0.50196;
   0,0,0;
   0,0,0;
   0,0,0];

 warning('off','MATLAB:im2java:functionToBeRemoved');
    jImage = im2java(I,map);
end

function jImage = partialCheckIcon()
I = uint8(...
    [    0   16   32   48   64   80   96  112  128  144  160  176  192  208  224  240;
    1   17   33   49   65   81   97  113  129  145  161  177  193  209  225  241;
    2   18   34   50   66   82   98  114  130  146  162  178  194  210  226  242;
    3   19   35   51   67   83   99  115  131  147  163  179  195  211  227  243;
    4   20   36   52   68   84  100  116  132  148  164  180  196  212  228  244;
    5   21   37   53   69   85  101  117  133  149  165  181  197  213  229  245;
    6   22   38   54   70   86  102  118  134  150  166  182  198  214  230  246;
    7   23   39   55   71   87  103  119  135  151  167  183  199  215  231  247;
    8   24   40   56   72   88  104  120  136  152  168  184  200  216  232  248;
    9   25   41   57   73   89  105  121  137  153  169  185  201  217  233  249;
   10   26   42   58   74   90  106  122  138  154  170  186  202  218  234  250;
   11   27   43   59   75   91  107  123  139  155  171  187  203  219  235  251;
   12   28   44   60   76   92  108  124  140  156  172  188  204  220  236  252;
   13   29   45   61   77   93  109  125  141  157  173  189  205  221  237  253;
   14   30   46   62   78   94  110  126  142  158  174  190  206  222  238  254;
   15   31   47   63   79   95  111  127  143  159  175  191  207  223  239  255]);
 map = [    0.9961    0.9412    1.0000;
    0.0941         0    0.0510;
    0.0392         0    0.0275;
    0.0039         0    0.0196;
         0    0.0431    0.0275;
         0    0.0275         0;
         0    0.0275         0;
    0.0078    0.0353    0.0078;
    0.0392    0.0196    0.0078;
    0.0784         0    0.0078;
    0.0706         0         0;
    0.1176    0.0118    0.0471;
    0.0588         0    0.0196;
    0.0235         0    0.0078;
    0.0157    0.0157    0.0471;
    0.9490    0.9765    1.0000;
    1.0000    1.0000    1.0000;
    0.1059         0    0.0745;
    0.0706    0.0196    0.0588;
    0.0118    0.0078    0.0275;
         0    0.0157         0;
    0.0039    0.0706    0.0314;
         0    0.0353         0;
         0    0.0157         0;
         0    0.0078         0;
    0.0235         0         0;
    0.0745    0.0196    0.0157;
    0.0745    0.0196    0.0196;
    0.0314         0         0;
    0.0196    0.0039    0.0078;
    0.0196    0.0157    0.0392;
    0.5098    0.5216    0.5490;
    1.0000    0.9725    1.0000;
    0.0235         0    0.0235;
    0.0549    0.0353    0.0588;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    0.9922;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    0.0196    0.0196    0.0118;
    0.0039         0    0.0196;
    0.5294    0.5216    0.5412;
    0.9686    0.9804    1.0000;
    0.0078    0.0118    0.0196;
         0         0         0;
    1.0000    1.0000    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3686    0.1451;
    0.1294    0.3647    0.1529;
    0.1333    0.3686    0.1569;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1255    0.3725    0.1569;
    1.0000    1.0000    1.0000;
    0.0471    0.0667    0.0392;
    0.0157         0         0;
    0.5216    0.4745    0.4902;
    0.9569    1.0000    1.0000;
         0    0.0471    0.0471;
         0    0.0078         0;
    1.0000    1.0000    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1216    0.3686    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
         0    0.0196         0;
    0.0510    0.0196    0.0078;
    0.5569    0.4824    0.4902;
    0.9451    1.0000    1.0000;
         0    0.0157    0.0196;
         0    0.0353    0.0157;
    1.0000    0.9961    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1333    0.3647    0.1529;
    0.1333    0.3725    0.1490;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
         0    0.0275         0;
    0.0314    0.0118         0;
    0.5922    0.5176    0.5255;
    0.9686    1.0000    1.0000;
         0    0.0118    0.0235;
    0.0118    0.0353    0.0275;
    1.0000    1.0000    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.9961    1.0000    1.0000;
         0    0.0392    0.0039;
    0.0118    0.0078         0;
    0.4941    0.4471    0.4549;
    0.9608    0.9529    1.0000;
    0.0549    0.0510    0.0824;
         0    0.0039    0.0118;
    1.0000    1.0000    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
         0    0.0157         0;
    0.0039    0.0039    0.0039;
    0.5490    0.5216    0.5490;
    1.0000    0.9725    1.0000;
    0.0275         0    0.0275;
    0.0627    0.0627    0.0706;
    1.0000    1.0000    1.0000;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1216    0.3686    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
    0.0745    0.0980    0.0902;
         0    0.0039    0.0196;
    0.4863    0.4863    0.5176;
    1.0000    0.9608    0.9961;
    0.0431         0    0.0235;
         0         0    0.0078;
    1.0000    1.0000    1.0000;
    0.1333    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
         0         0    0.0157;
         0    0.0039    0.0235;
    0.5412    0.5725    0.6157;
    1.0000    0.9490    0.9882;
    0.0431    0.0039    0.0078;
    0.0118    0.0314    0.0157;
    1.0000    1.0000    1.0000;
    0.1255    0.3608    0.1490;
    0.1216    0.3686    0.1451;
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1608;
    0.1176    0.3647    0.1490;
    0.1294    0.3647    0.1608
    0.1294    0.3647    0.1529;
    0.1294    0.3647    0.1529;
    1.0000    1.0000    1.0000;
         0         0    0.0157;
    0.0196    0.0471    0.0784;
    0.4000    0.4510    0.4824
    1.0000    0.9765    0.9647;
    0.0471    0.0353    0.0078;
         0    0.0157         0;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    0.0118         0    0.0275;
         0    0.0039    0.0235;
    0.4667    0.5098    0.5255;
    0.9882    1.0000    0.9647;
         0    0.0431         0;
         0    0.0431    0.0275;
         0    0.0941         0;
    0.0078    0.0353    0.0039;
    0.0078    0.0627    0.0118;
    0.0078    0.0588    0.0235;
         0    0.0078    0.0039;
    0.0392    0.0196    0.0353;
    0.0745    0.0118    0.0510;
    0.0431         0    0.0157;
    0.0431         0    0.0157;
    0.1020    0.0510    0.0902;
    0.0078         0    0.0118;
    0.0275    0.0314    0.0471;
    0.5098    0.5412    0.5490;
    1.0000    1.0000    1.0000;
    0.0039    0.0471    0.0314;
         0    0.0549         0;
         0    0.0863    0.0039;
         0    0.0275         0;
    0.0314    0.0549         0;
    0.0039    0.0039    0.0118;
    0.0314    0.0118    0.0275;
    0.0196         0    0.0157;
    0.0235    0.0039    0.0275;
    0.0196         0    0.0275;
    0.0314    0.0039    0.0353;
    0.0196         0    0.0235;
    0.0196         0    0.0157;
    0.0392    0.0235    0.0275;
    0.5020    0.4863    0.4824;
    1.0000    1.0000    1.0000;
    0.4588    0.4784    0.4902;
    0.4588    0.4784    0.4902;
    0.4588    0.4784    0.4902;
    0.4902    0.5059    0.4392;
    0.5412    0.5137    0.4745;
    0.5255    0.4784    0.4784;
    0.5333    0.4902    0.5137;
    0.5451    0.5176    0.5490;
    0.5333    0.5333    0.5647;
    0.5294    0.5490    0.5647;
    0.4588    0.4784    0.4902;
    0.4863    0.4941    0.4902;
    0.5098    0.5059    0.4980;
    0.4863    0.4549    0.4431;
    0.5255    0.4824    0.4667;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    0.9922;
    1.0000    0.9961    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    1.0000    0.9961    0.9882;
    1.0000    1.0000    1.0000;
    1.0000    0.9804    1.0000;
    1.0000    0.9922    1.0000;
    0.9529    0.9843    0.9961;
    0.9686    1.0000    1.0000;
    0.9412    0.9961    0.9961;
    0.9765    1.0000    1.0000;
    0.9608    0.9569    0.9412;
    0.9961    0.9922    0.9725;
    1.0000    0.9725    0.9490];
    
 warning('off','MATLAB:im2java:functionToBeRemoved');
    jImage = im2java(I,map);
end

function cr = getDefaultCellRenderer()
    try
        % Custom cell renderer (striping, cell FG/BG color, cell tooltip)
        cr = CustomizableCellRenderer;
        cr.setRowStriping(false);
    catch
        % Use the standard JTable cell renderer
        %cr = [];
        cr = javax.swing.table.DefaultTableCellRenderer;
    end
end  % getDefaultCellRenderer