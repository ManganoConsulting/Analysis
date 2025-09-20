classdef OCCStabControl < lacm.OperatingConditionCollection
    
    %% Public Properties
    properties
%         OperCondTable
        OperCondRowFilterObj
        OperCondColumnFilterObj
        OperCondStructure
        
        
        ShowDataRow logical
        ShowDataColumn logical
        
        Data
        OperatingConditionStructureIsDefined = false
        
        SimViewerSettings = SimViewer.Main.emptyPlotSettings()
        SimViewerProject = SimViewer.Main.emptyProjectSettings()
        
    end % Public properties
    
    %% Private Properties
    properties ( Access = private ) 
%         DisplayTabSelected
        
        PrivateTableColumnNames = {'Type','Name','Units'};
        SelectedRows
        FirstSelectedRow
        SecondSelectedRow
        TrimDisplay = 1
    end % Private properties

    %% Public properties - Graphics Handles
    properties (Transient = true)
        TablePanel
        DisplayTabPanel
        TabTable
        TableTabContainer
        TableContainer
        TabPlots
        TabSimPlots
        TabPostSimPlots
        VarSelectPanel
        VarFilterPanel
        ResultsPanel
        Container
        AxisColl
        SimAxisColl
        PostSimAxisColl
        FilterContainer
        FiltertLabelComp matlab.ui.control.Label = matlab.ui.control.Label.empty
        FilterLabelCont matlab.ui.control.Label = matlab.ui.control.Label.empty
       
        RibbonCardPanel
    end % Public properties
    
    %% Table View Properties - Object Handles
    properties (Transient = true)      
        JScroll
        JTable
        JTableH
        JHScroll
        HContainer       
        FixColTbl
        TableModel   
    end
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
%         Data % Full table data from all OperCond regardless of filter
        TableData % Table data with filter applied
        RowTableData % Table data with only row filter applied
        NumericTableData
        TableColumnNames
        ValidTrimDisplay
    end % Dependant properties
    
    %% Constant Properties
    properties (Constant)
        TableFormatString        = '%6.3e\n'
    end   
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        function obj = OCCStabControl( parent , toolribbonH )
            switch nargin
                case 1
                    obj.Parent = parent;
                    createView(obj);
                case 2    
                    createView(obj, parent , false , toolribbonH);
                case 3         
            end
            
        end % OCCStabControl
    end % Constructor

    %% Methods - Property Access
    methods

        function y = get.NumericTableData(obj)
            % only call get function once
            data = obj.TableData;
            if size(data,2) > 3
                % tempData is used to remove any non-numeric values and set
                % them temporarily to zero for plotting purposes.
                tempData = data(:,4:end);
                logArray = cellfun(@isnumeric,tempData);
                tempData(~logArray) = {0};
                y = cell2mat(tempData);
            else
                y = [];
            end
            
        end % NumericTableData 
        
        function y = get.ValidTrimDisplay(obj)
           if isempty(obj.OperatingCondition)
                y = [];
            else
                y = [obj.OperatingCondition.SuccessfulTrim]';  
%                 y = y(obj.ShowDataColumn);
           end
        end % ValidTrimDisplay
        
        function y = get.TableData(obj)
            data = obj.Data;
            if isempty(data)
                y = [];
                obj.PrivateTableColumnNames = {};
            else
                sz = size(data);
                if isempty(obj.ShowDataColumn) || isempty(obj.ShowDataRow)
                    error('TABLE:FilterOutofSync:Empty','Filter logical values do not match the table data values');
                elseif length(obj.ShowDataColumn) ~= sz(2)
                    error('TABLE:FilterOutofSync:Column','Filter logical values do not match the table data values');
                elseif length(obj.ShowDataRow) ~= sz(1)
                    error('TABLE:FilterOutofSync:Row','Filter logical values do not match the table data values');
                end
                y = data(obj.ShowDataRow,obj.ShowDataColumn);       
                % Set the Column Names
                numStr = cellfun(@(x) num2str(x),num2cell( 1:(size(y,2) - 3) ),'UniformOutput',false);
                obj.PrivateTableColumnNames = [{'Type','Name','Units'},numStr];
            end
        end % TableData
        
        function y = get.RowTableData(obj)
            data = obj.Data;
            if isempty(data)
                y = [];
%                 obj.PrivateTableColumnNames = {};
            else
                sz = size(data);
                if isempty(obj.ShowDataRow)
                    error('TABLE:FilterOutofSync:Empty','Filter logical values do not match the table data values');
                elseif length(obj.ShowDataRow) ~= sz(1)
                    error('TABLE:FilterOutofSync:Row','Filter logical values do not match the table data values');
                end
                y = data(obj.ShowDataRow,:);       
                % Set the Column Names
%                 numStr = cellfun(@(x) num2str(x),num2cell( 1:(size(y,2) - 3) ),'UniformOutput',false);
%                 obj.PrivateTableColumnNames = [{'Type','Name','Units'},numStr];
            end
        end % RowTableData       
        
        function header = get.TableColumnNames(obj)
            header = obj.PrivateTableColumnNames;
        end % TableColumnNames
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
       
        
        function setData(obj)
            if isempty(obj.OperatingCondition)
                y = [];
            else
                y = [obj.OperatingCondition(1).getHeaderData,obj.OperatingCondition.getTableData]; 
%                 switch obj.TrimDisplay
%                     case 0
%                         y = [obj.OperatingCondition(1).getHeaderData,obj.OperatingCondition.getTableData];     
%                     case 1
%                         y = [obj.OperatingCondition(1).getHeaderData,obj.OperatingCondition([obj.OperatingCondition.SuccessfulTrim]).getTableData];  
%                     otherwise
%                         y = [obj.OperatingCondition(1).getHeaderData,obj.OperatingCondition(~[obj.OperatingCondition.SuccessfulTrim]).getTableData];  
%                 end
            end
            obj.Data = y;
        end % setData        
        
        function add( obj , newOperCond )
            
            
            % If the number of model inputs change we need to reset the
            % filters
            y = [newOperCond(1).getHeaderData,newOperCond.getTableData]; 
%             switch obj.TrimDisplay
%                 case 0
%                     y = [newOperCond(1).getHeaderData,newOperCond.getTableData];     
%                 case 1
%                     y = [newOperCond(1).getHeaderData,newOperCond([newOperCond.SuccessfulTrim]).getTableData];  
%                 otherwise
%                     y = [newOperCond(1).getHeaderData,newOperCond(~[newOperCond.SuccessfulTrim]).getTableData];  
%             end
                
            % Check to see if the size of the operating condition
            % properties has changes, ex - states, inputs, outputs, etc
            %if length(obj.ShowDataColumn) ~= size(y,2) || length(obj.ShowDataRow) ~= size(y,1)  
            if length(obj.ShowDataRow) ~= size(y,1)          
                obj.OperatingConditionStructureIsDefined = false;
            end
            
            % If the operating condition structure has not been defined get
            % the definition and update the filters
            if ~obj.OperatingConditionStructureIsDefined
                obj.OperatingCondition = newOperCond;
                obj.OperCondStructure = getHeaderStructureData( obj.OperatingCondition(1) );
                % Set the initial Data to local variable to avoid multiple
                % calls to dependant property
                setData(obj);
                data = obj.Data;
                
                % Initialize all the table and filters to default
                initialize( obj ); %Resets the ShowColumnData and ShowRowData logical vectors to the default size of the operating condition data
                initialize( obj.OperCondRowFilterObj ,   obj.OperCondStructure ); % Calls the initialize method in the RowFilter Class
                initialize( obj.OperCondColumnFilterObj , obj.OperCondStructure );% Calls the initialize method in the ColumnFilter Class
                obj.OperCondColumnFilterObj.DisplayData = data;
                obj.OperCondColumnFilterObj.Data        = data;
                updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , obj.TableData , data);
                % Set OperatingConditionStructureIsDefined so this is not called again
                obj.OperatingConditionStructureIsDefined = true;
                setShowColumn_Validity(obj);
                createTable( obj );
            else
                obj.OperatingCondition = newOperCond;
                setData(obj);
                
% %                 applyFilter2NewOperCond( obj.OperCondColumnFilterObj , obj.RowTableData , obj.Data );
%                 updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , obj.TableData , obj.Data);
%                 obj.ShowDataColumn = obj.OperCondColumnFilterObj.ColumnLogicArray;
                obj.ShowDataColumn = true(length(newOperCond)+3, 1);
                setShowColumn_Validity(obj);
                createTable( obj );
            end 
                      
        end % add   
        
        function updateValidTrimDisplay( obj , status )
            obj.TrimDisplay = status;
%             % Reset the column filters
            obj.ShowDataColumn = true(size(obj.Data,2),1);
            updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , obj.TableData , obj.Data);
            
            setShowColumn_Validity(obj);
            
            createTable( obj );
        end % updateValidTrimDisplay
        
        function setShowColumn_Validity(obj)
            validTrims = obj.ValidTrimDisplay;
            switch obj.TrimDisplay
                case 0
                    obj.ShowDataColumn = obj.ShowDataColumn & [true(3,1); ones(length(validTrims), 1)];
                case 1
                    obj.ShowDataColumn = obj.ShowDataColumn & [true(3,1); validTrims];
                otherwise
                    obj.ShowDataColumn = obj.ShowDataColumn & [true(3,1); ~validTrims];
            end
        end % setShowColumn_Validity
        
        function clear( obj )
            setWaitPtr(obj);
            obj.OperatingCondition = lacm.OperatingCondition.empty;
            setData(obj);
            obj.createTable();
            obj.OperCondColumnFilterObj.Filter1ColumnLogicalArray = true(3,1);
            obj.OperCondColumnFilterObj.Filter2ColumnLogicalArray = true(3,1);
            obj.OperCondColumnFilterObj.Filter3ColumnLogicalArray = true(3,1);
            obj.OperCondColumnFilterObj.Filter4ColumnLogicalArray = true(3,1);
                        
            obj.OperatingConditionStructureIsDefined = false;
            releaseWaitPtr(obj);
        end % clear 
        
        function saveOperCond( obj )
            saveOperatingCondition( obj.OperCondTable );     
        end
        
        function setWaitPtr(obj)
            figH = ancestor(obj.Parent,'figure','toplevel');
            set(figH, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            figH = ancestor(obj.Parent,'figure','toplevel');
            set(figH, 'pointer', 'arrow'); 
        end % releaseWaitPtr
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
        function createView( obj , parent , loadingWrkspc , toolribbonH )
            
            % Init inputs for project loading
            if nargin > 1
                obj.Parent = parent;   
            end
            if nargin < 3
                loadingWrkspc = false;
            end
            
            % Create top container
            obj.Container = uicontainer('Parent',obj.Parent,'Units','normal','Position',[0,0,1,1]);
            % Create Tab Group Inside Container
            obj.DisplayTabPanel = uitabgroup('Parent',obj.Container,'Units','normal','Position',[0,0,1,1],'SelectionChangedFcn',@obj.displayTabChanged);
            obj.DisplayTabPanel.TabLocation = 'Bottom';

                % Table Tab
                obj.TabTable   = uitab('Parent',obj.DisplayTabPanel);
                obj.TabTable.Title = '            Table          ';
                obj.TableTabContainer = uicontainer('Parent',obj.TabTable,'Units','Normal','Position',[0,0,1,1]); % Create container inside the tab
                set(obj.TableTabContainer,'ResizeFcn',@obj.displayPanelResize); % set the resize funtion, will be same size as the tab
                obj.TableContainer = uicontainer('Parent',obj.TableTabContainer); % container for the Operating Condition Table
                obj.FilterContainer = uicontainer('Parent',obj.TableTabContainer);   % container for the Operating Condition Filter
                set(obj.FilterContainer,'ResizeFcn',@obj.filterPanelResize);         % set resize function for filter container

                % Plots Tab
                obj.TabPlots   = uitab('Parent',obj.DisplayTabPanel);
                obj.TabPlots.Title = '           Plots          ';   

                % Sim Tab
                obj.TabSimPlots   = uitab('Parent',obj.DisplayTabPanel);
                obj.TabSimPlots.Title = '       Simulation         '; 
                
                % Post - Sim Tab
                obj.TabPostSimPlots   = uitab('Parent',obj.DisplayTabPanel);
                obj.TabPostSimPlots.Title = '    Post-Simulation       '; 
                
                
                % Add Card Panel to tool ribbion 
                if nargin > 3
                    obj.RibbonCardPanel = UserInterface.CardPanel(4,'Parent',toolribbonH,...
                        'Units','Normal',...
                        'Position',[ 0 , 0 , 1 , 1 ]);
                end
                
            % Add panels to the tabs
            % Table Tab
            createTable( obj );

            %Filter Label
            obj.FiltertLabelComp = uilabel(obj.FilterContainer, ...
                'Text',' Variable Selection', ...
                'FontName','Courier New', ...
                'FontColor',[1 1 1], ...
                'BackgroundColor',[55 96 146]/255, ...
                'HorizontalAlignment','left', ...
                'VerticalAlignment','bottom', ...
                'Position',[1 1 100 16]);
            obj.FilterLabelCont = obj.FiltertLabelComp;
            
            % Create Row Selection Object
            obj.VarSelectPanel = uicontainer('Parent',obj.FilterContainer);
            if loadingWrkspc
                obj.OperCondRowFilterObj.restoreTree(obj.VarSelectPanel);
            else
                obj.OperCondRowFilterObj = UserInterface.StabilityControl.RowFilter(obj.VarSelectPanel);
            end

            addlistener(obj.OperCondRowFilterObj,'ShowData','PostSet',@obj.rowFilteredEvent);
            addlistener(obj.OperCondRowFilterObj,'ShowDataEvent',@obj.rowFilteredEvent);
            addlistener(obj.OperCondRowFilterObj,'ShowLogMessage',@obj.showLogMessage_CB);
            % Create Column Selection Object
            obj.VarFilterPanel = uicontainer('Parent',obj.FilterContainer);    
            obj.OperCondColumnFilterObj = UserInterface.StabilityControl.ColumnFilter(obj.VarFilterPanel);
            addlistener(obj.OperCondColumnFilterObj,'ColumnSelectedEvent',@obj.columnFilteredEvent);
            addlistener(obj.OperCondColumnFilterObj,'ShowLogMessage',@obj.showLogMessage_CB);
            
            % Requirements Plots Tab
            obj.AxisColl = UserInterface.AxisPanelCollection('Parent',obj.TabPlots,'NumOfPages',4); 

            % Simulation Requirements Plots Tab
            %obj.SimAxisColl = SimViewer.Main('Parent',obj.TabSimPlots,'RibbonParent',obj.RibbonCardPanel.Panel(3)); 
            obj.SimAxisColl = SimViewer.Main('Parent',obj.TabSimPlots,'RibbonParent',obj.RibbonCardPanel.Panel(3)); 
            % Try and Load SimViewer Settings if they exist
            %loadSimViewerSettings( obj );
            loadSimViewerProject( obj );
            
            % Post Simulation Requirements Plots Tab
            obj.PostSimAxisColl = UserInterface.AxisPanelCollection('Parent',obj.TabPostSimPlots,'NumOfPages',4); 
            %obj.PostSimAxisColl = UserInterface.AxisPanelCollection('Parent',obj.TabPostSimPlots,'NumOfPages',4); 

            if loadingWrkspc && ~isempty(obj.Data)
                updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , obj.TableData , obj.Data);
            end
        end % createView
     
        function createTable( obj )
            import UserInterface.StabilityControl.*
            tblData = obj.TableData;
            
            delete(obj.HContainer);
            if ~isempty(tblData) % if empty do not create the table | else could create a dummy empty table for looks only
                %%%%% Very slow %%%%%%%%
                %                 frmt = cell(size(tblData));
                %                 frmt(:) = {obj.TableFormatString};
                %                 tblData = cellfun(@num2str, tblData, frmt , 'UniformOutput', false);
                %%%%%%%%%%%%%%%%%%%%%%%%

                %                 defaults = javax.swing.UIManager.getLookAndFeelDefaults;
                %                 if isempty(defaults.get('Table.alternateRowColor'))
                %                     defaults.put('Table.alternateRowColor', java.awt.Color( 246/255 , 243/255 , 237/255 ));
                %                 end

                obj.TableModel = javax.swing.table.DefaultTableModel(tblData,obj.TableColumnNames);
                obj.JTable = javaObjectEDT(javax.swing.JTable(obj.TableModel));
                obj.JTable.setGridColor(java.awt.Color.lightGray); 
                obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');  % ensure that we're using EDT
                % Present the tree-table within a scrollable viewport on-screen
                obj.JScroll = javaObjectEDT(javax.swing.JScrollPane(obj.JTable));
                [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], obj.TableContainer);
                set(obj.HContainer,'Units','Normal');
                set(obj.HContainer,'Position',[ 0 , 0 , 1 , 1 ]);

                obj.JScroll.setVerticalScrollBarPolicy(obj.JScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
                obj.JScroll.setHorizontalScrollBarPolicy(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
                obj.JTable.setAutoResizeMode( obj.JTable.AUTO_RESIZE_OFF );

                % Set Callbacks
                obj.JTableH.MousePressedCallback = @obj.mousePressedCallback;
                obj.JTableH.KeyReleasedCallback  = @obj.keyReleasedCallback; 
                obj.JTableH.KeyPressedCallback   = @obj.keyPressedCallback;
                obj.JTableH.KeyTypedCallback     = @obj.keyTypedCallback;


% % %                 cr = ColoredFieldCellRenderer;
% % %                 cr.setFgColor( java.awt.Color.black )
% % % 
% % %                 for j = 0:obj.JTable.getColumnCount-1            
% % %                     obj.JTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% % %                     for i = 0:2:double(obj.JTable.getRowCount)
% % %                         cr.setCellBgColor( i,j,java.awt.Color.white ); 
% % %                     end
% % %                     column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(70);column0.setMinWidth(70);column0.setMaxWidth(70);   
% % %                 end     
% % %                 obj.JTable.setGridColor(java.awt.Color.black);    
% % % 
% % %                 for j = 0:obj.JTable.getColumnCount-1            
% % %                     obj.JTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% % %                     for i = 1:2:double(obj.JTable.getRowCount)
% % %                         cr.setCellBgColor( i,j,java.awt.Color( 246/255 , 243/255 , 237/255 )  ); 
% % %                     end
% % %                     column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(70);column0.setMinWidth(70);column0.setMaxWidth(70);   
% % %                 end          

                %set fg color for invalid trims Needs Work
                %             for j = 0:obj.JTable.getColumnCount-1            
                %                 for i = 0:1:double(obj.JTable.getRowCount)
                %                     cr.setCellFgColor( i,j,java.awt.Color.red ); 
                %                 end
                %             end      


                % Set Column Width
                for j = 0:2    
                    column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(100);%column0.setMinWidth(130);column0.setMaxWidth(130);
                end
                for j = 3:obj.JTable.getColumnCount-1     
                    column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(140);%column0.setMinWidth(130);column0.setMaxWidth(130);
                end

                obj.FixColTbl= javaObjectEDT(FixedColumnTable(3, obj.JScroll)); 
                fixColTbl = obj.FixColTbl.getFixedTable();
                FixJTableH = handle(javaObjectEDT(fixColTbl), 'CallbackProperties');

                fixColTbl.setGridColor(java.awt.Color.lightGray); 

                FixJTableH.MousePressedCallback = @obj.mousePressedCallback;

                obj.JTable. repaint;
                %             defaults.put('Table.alternateRowColor', []);

                %             % Taken from: http://xtargets.com/snippets/posts/show/37
                %             obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
                %             
                %             obj.JTable. repaint;
                %             obj.JTable.setVisible(true);
                %obj.JTable.setAutoCreateRowSorter(true);
                %obj.FixColTbl.setAutoCreateRowSorter(true);
                % Notify that the Table Data has changed
                %             notify(obj,'TableDataChangedEvent',TableDataChangedEventData( tblData , obj.Data ));
            end
        end % createTable  
        
        function displayTabChanged( obj , hobj , eventdata )
            % Get the index of the selected tab
            ind = find(eventdata.Source.get('Children') == eventdata.Source.get('SelectedTab'));
            obj.RibbonCardPanel.SelectedPanel = ind;
        end % displayTabChanged
        
        function saveSimViewerSettings( obj )
            obj.SimViewerSettings = obj.SimAxisColl.getPlotSettings;
        end % saveSimViewerSettings
        
        function saveSimViewerProject( obj )
            obj.SimViewerProject = obj.SimAxisColl.getSavedProject();
        end % saveSimViewerProject
        
        function loadSimViewerProject( obj )
            if ~isempty(obj.SimViewerProject)
                obj.SimAxisColl.loadProject( obj.SimViewerProject )
            end
        end % loadSimViewerProject
        
        function loadSimViewerSettings( obj )
            if ~isempty(obj.SimViewerSettings)
                obj.SimAxisColl.restorePlotSettings( obj.SimViewerSettings );
                obj.SimAxisColl.updateAllPlots();
            end   
        end % loadSimViewerSettings
            
    end % Ordinary Methods
    
    %% Methods - View Table Callbacks
    methods
        
        function mousePressedCallback( obj , hobj , eventdata )
            if eventdata.isMetaDown % right-click
                % Preserve the order of the selected Rows
                obj.SelectedRows = hobj.getSelectedRows +1;
                if length(obj.SelectedRows) == 1
                        % Ask the user to plot the selected Rows
                        clickX = eventdata.getX;
                        clickY = eventdata.getY;
                        jtable = eventdata.getSource;
                        jmenu = javax.swing.JPopupMenu;
                        menuItem1 = javax.swing.JMenuItem('<html><b>Plot');
                        menuItem1h = handle(menuItem1,'CallbackProperties');
                        set(menuItem1h,'ActionPerformedCallback',@obj.plotSelectedRow_CB); 
                        jmenu.add(menuItem1); 
                        
                        menuItem2 = javax.swing.JMenuItem('<html><b>Export to m-file');
                        menuItem2h = handle(menuItem2,'CallbackProperties');
                        set(menuItem2h,'ActionPerformedCallback',@obj.writeOperCond2MFile); 
                        jmenu.add(menuItem2); 
                        
                        jmenu.show(jtable, clickX, clickY);
                        jmenu.repaint; 
                elseif length(obj.SelectedRows) > 1
                        % Ask the user to plot the selected Rows
                        clickX = eventdata.getX;
                        clickY = eventdata.getY;
                        jtable = eventdata.getSource;
                        jmenu = javax.swing.JPopupMenu;
                        menuItem1 = javax.swing.JMenuItem('<html><b>Plot');
                        menuItem1h = handle(menuItem1,'CallbackProperties');
                        set(menuItem1h,'ActionPerformedCallback',@obj.plotRowVsRow_CB); 
                        jmenu.add(menuItem1); 
                        if length(obj.SelectedRows) == 3
                            menuItem2 = javax.swing.JMenuItem('<html><b>Carpet Plot');
                            menuItem2h = handle(menuItem2,'CallbackProperties');
                            set(menuItem2h,'ActionPerformedCallback',@obj.carpetPlot_CB); 
                            jmenu.add(menuItem2); 
                        end
                        jmenu.show(jtable, clickX, clickY);
                        jmenu.repaint; 
                else
                     obj.SelectedRows = [];
                    disp('Need to reset') 
                end
                
            else
                selRows = hobj.getSelectedRows + 1;
                if length(selRows) == 1
                    obj.FirstSelectedRow = selRows; 
                elseif length(selRows) == 2
                    la = obj.FirstSelectedRow == selRows;
                    obj.SecondSelectedRow = selRows(~la); 
                end
            end
            
        end % mousePressedCallback
        
        function dataUpdatedCallback( obj , hobj , eventdata )
            
        end % dataUpdatedCallback
        
        function keyReleasedCallback( obj , hobj , eventdata )
            
        end % keyReleasedCallback
        
        function keyPressedCallback( obj , hobj , eventdata )
            
        end % keyPressedCallback
                
        function keyTypedCallback( obj , hobj , eventdata )
            
        end % keyTypedCallback     
    end
    
    %% Methods - Export Methods
    methods   
        
        function writeOperCond2MFile( obj , ~ , ~ )
            disp('Write2M-file: This function needs to be completed.') 
        end% writeOperCond2MFile
              
    end
    
    %% Methods - Protected - Event Callbacks
    methods (Access = protected)
        
        function showLogMessage_CB( obj , ~ , eventdata )
            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(eventdata.Message,eventdata.Severity));
        end % showLogMessage_CB
        
        function rowFilteredEvent( obj , hobj , eventdata )    
            setWaitPtr(obj);
%             obj.ShowDataRow = logical(eventdata.AffectedObject.ShowData);
            obj.ShowDataRow = logical(eventdata.Object);
%             createTable(obj);
            data = obj.Data;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(data)
                tableData = [];
                obj.PrivateTableColumnNames = {};
            else
                sz = size(data);
                if isempty(obj.ShowDataColumn) || isempty(obj.ShowDataRow)
                    error('TABLE:FilterOutofSync:Empty','Filter logical values do not match the table data values');
                elseif length(obj.ShowDataColumn) ~= sz(2)
                    error('TABLE:FilterOutofSync:Column','Filter logical values do not match the table data values');
                elseif length(obj.ShowDataRow) ~= sz(1)
                    error('TABLE:FilterOutofSync:Row','Filter logical values do not match the table data values');
                end
                tableData = data(obj.ShowDataRow,obj.ShowDataColumn);       
                % Set the Column Names
                numStr = cellfun(@(x) num2str(x),num2cell( 1:(size(tableData,2) - 3) ),'UniformOutput',false);
                obj.PrivateTableColumnNames = [{'Type','Name','Units'},numStr];
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This resets the column filters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.ShowDataColumn = true(size(data,2),1);
            updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , tableData , data );    
            
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            

            releaseWaitPtr(obj);
        end % rowFilteredEvent
        
        function columnFilteredEvent( obj , ~ , eventdata ) 
            %setWaitPtr(obj);
            
            
            columnLogicArray = logical(eventdata.Index);
            obj.ShowDataColumn = columnLogicArray;
            
            
            
            
            
%%%%%%%%%%%%%%%%%%%%% NEW
% Reset the column filters
%             obj.ShowDataColumn = true(size(obj.Data,2),1);
%             updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj , obj.TableData , obj.Data);
            
            setShowColumn_Validity(obj);
            
            obj.ShowDataColumn = obj.ShowDataColumn & columnLogicArray;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            createTable(obj);
            
            
            if obj.TrimDisplay == 0
                operCond = obj.OperatingCondition;     
            else
                operCond = obj.OperatingCondition([obj.OperatingCondition.SuccessfulTrim]);
            end
            % Update the requirement plots
            for i = 1:length(operCond)
                if columnLogicArray(i + 3)
                    set(obj.OperatingCondition(i).FlightDynLineH,'Visible','on');
                else
                    set(obj.OperatingCondition(i).FlightDynLineH,'Visible','off');
                end  
            end        
            %releaseWaitPtr(obj);
        end % columnFilteredEvent
        
        function updateColumnFilterData( obj , ~ , eventdata )
            obj.OperCondColumnFilterObj.DisplayData = eventdata.DisplayData;
            obj.OperCondColumnFilterObj.Data = eventdata.AllData;
            %updateAllSelectableFilterStrings( obj.OperCondColumnFilterObj );
        end % updateColumnFilterData
        
    end
    
    %% Methods -Update 
    methods
        
        function initialize( obj )
            obj.ShowDataColumn = true(size(obj.Data,2),1);
            obj.ShowDataRow    = true(size(obj.Data,1),1);
            update(obj);
        end % initialize
        
    end
    
    %% Methods -Resize 
    methods (Access = protected) 
        
        function resize( obj , ~ , ~ )

        end % resize

        function displayPanelResize( obj , ~ , ~ )  
            
            parentPos = getpixelposition(obj.TableTabContainer);
            set(obj.TableContainer,'Units','pixels','Position',[ 1 , 1 , parentPos(3) - 200 , parentPos(4) - 1 ]);
            set(obj.FilterContainer,'Units','pixels','Position',[ parentPos(3) - 200 , 1 , 200 , parentPos(4) - 1 ]);
            
        end % displayPanelResize   

        function filterPanelResize( obj , ~ , ~ ) 
            
            filterParentPos = getpixelposition(obj.FilterContainer);
            if ~isempty(obj.FilterLabelCont) && all(isvalid(obj.FilterLabelCont))
                obj.FilterLabelCont.Units = 'Pixels';
                obj.FilterLabelCont.Position = [ 1 , filterParentPos(4) - 16 , filterParentPos(3) , 16 ];
            end
            set(obj.VarSelectPanel,'Units','pixels','Position',[ 1 , 316 , filterParentPos(3) - 1 , filterParentPos(4) - 333 ]);
                
            set(obj.VarFilterPanel,'Units','pixels','Position',[ 1 , 1 , filterParentPos(3) - 1 , 315 ]);   
            
        end % filterPanelResize 
    end
    
    %% Methods - Plot Methods
    methods    
    
        function plotSelectedRow_CB( obj , ~ , ~ )
            y = obj.NumericTableData(obj.SelectedRows,:);
            x = 1:length(y);
            
            fh = figure;
            ah=axes('Parent',fh);
            grid(ah);
            line(x,y,'Parent',ah,'Marker','o','MarkerFaceColor','b');
            xlabel(ah,'Run #')
            
            yUnits = obj.TableData{obj.SelectedRows(1),3};
            ylabel(ah,[strrep(obj.TableData{obj.SelectedRows(1),2},'_','\_'),', ' yUnits]);
            set(ah,'xtick',x);
            
        end % plotSelectedRow
        
        function plotRowVsRow_CB( obj , ~ , ~ )
            
            if isempty(obj.FirstSelectedRow)
                return;
            end

            x = obj.NumericTableData(obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),:);

            yRows = find(obj.FirstSelectedRow ~= obj.SelectedRows);
            
            fh = figure;
            ah=axes('Parent',fh);
            grid(ah);
            if length(yRows) == 1
                y = obj.NumericTableData(obj.SelectedRows(yRows),:);
                line(x,y,'Parent',ah,'Marker','o','MarkerFaceColor','b');
                
                xUnits = obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),3};
                xlabel(ah,[strrep(obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),2},'_','\_'),', ' xUnits])
                
                yUnits = obj.TableData{obj.SelectedRows(yRows),3};
                ylabel(ah,[strrep(obj.TableData{obj.SelectedRows(yRows),2},'_','\_'),', ' yUnits]);
                %ylabel(ah,strrep(obj.TableData{obj.SelectedRows(yRows),2},'_','\_'));   
            else
                for i = 1:length(yRows)
                    y = obj.NumericTableData(obj.SelectedRows(yRows(i)),:);
                    color = getColor(i);
                    lineH(i) = line(x,y,'Parent',ah,'Marker','o','MarkerFaceColor',color,'Color',color);
                    
                    xUnits = obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),3};
                    xlabel(ah,[strrep(obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),2},'_','\_'),', ' xUnits])
                    
                    yUnits = obj.TableData{obj.SelectedRows(yRows(i)),3};
                    labels{i} = [strrep(obj.TableData{obj.SelectedRows(yRows(i)),2},'_','\_'),', ' yUnits];    
                end
                lHdl= legend(ah,labels,'Location','best');
            end
        end % plotSelectedRow   
        
        function carpetPlot_CB( obj , ~ , ~ )
            % X component
            x_cell = obj.TableData(obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),4:end);
            logArray = cellfun(@isnumeric,x_cell);
            if all(logArray)
                x = cell2mat(x_cell);
            else
                msgbox('X component must be numeric.');
                return;
            end
            xUnits = obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),3};
            xName = strrep(obj.TableData{obj.SelectedRows(obj.FirstSelectedRow == obj.SelectedRows),2},'_','\_');
            
            % Y component
            y_cell = obj.TableData(obj.SelectedRows(obj.SecondSelectedRow == obj.SelectedRows),4:end);
            logArray = cellfun(@isnumeric,y_cell);
            if all(logArray)
                y = cell2mat(y_cell);
            else
                msgbox('Y component must be numeric.');
                return;
            end
            yUnits = obj.TableData{obj.SelectedRows(obj.SecondSelectedRow == obj.SelectedRows),3};
            yName = strrep(obj.TableData{obj.SelectedRows(obj.SecondSelectedRow == obj.SelectedRows),2},'_','\_');
            
            % Z component
            zRows = obj.FirstSelectedRow ~= obj.SelectedRows & obj.SecondSelectedRow ~= obj.SelectedRows;
            z_cell = obj.TableData(obj.SelectedRows(zRows),4:end);
            logArray = cellfun(@isnumeric,z_cell);
            if all(logArray)
                z = cell2mat(z_cell);
                z = round(z*1e7)/1e7; % to fix close to zero issue
                z = round(z,4,'significant'); 
            else
                z = z_cell;
            end
            zUnits = obj.TableData{obj.SelectedRows(zRows),3};
            zName = strrep(obj.TableData{obj.SelectedRows(zRows),2},'_','\_');
            
            [C,~,ic] = unique(z);
            len = length(C);
            X = cell(len,1);
            Y = cell(len,1);
            legLabel = cell(len,1);
            for i = 1:len;
                la = ic == i;
                X{i} = x(la);
                Y{i} = y(la);
                if isnumeric(C(i))
                    legLabel{i} = num2str(C(i));
                else
                    legLabel(i) = C(i);
                end
            end
            
            figH = figure;
            axH = axes('Parent',figH);
            for i = 1:len   
                [X_Sort,I] = sort(X{i});
                Y_Sort = Y{i}(I);

                color = getColor(i);
                sym = getSymbol(i);
                lineH(i) = line(...
                        'XData',X_Sort,...
                        'YData',Y_Sort,...
                        'Parent',axH,...
                        'Color',color,...
                        'Marker',sym,...
                        'MarkerFaceColor',color,...
                        'LineStyle','-',... 
                        'DisplayName',[zName,' = ',legLabel{i},' ' zUnits]);
            end
            grid(axH,'on');
            
            legObjH = legend(axH,lineH,'Location','best');
            xlabel(axH,[xName,', ' xUnits]);
            ylabel(axH,[yName,', ' yUnits]);      
            
  
      
        end % surfacePlot_CB
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            cpObj = copyElement@lacm.OperatingConditionCollection(obj);
            
            % Make a deep copy of the OperCondTable object
            cpObj.OperCondTable = copy(obj.OperCondTable);
            % Make a deep copy of the OperCondRowFilterObj object
            cpObj.OperCondRowFilterObj = copy(obj.OperCondRowFilterObj);
            % Make a deep copy of the OperCondColumnFilterObj object
            cpObj.OperCondColumnFilterObj = copy(obj.OperCondColumnFilterObj);
                    
        
        end
        
    end
    
    %% Method - Delete
    methods
        
        function deleteObjects(obj)
            try %#ok<*TRYNC>
                delete(obj.OperCondTable);
            end
            try %#ok<*TRYNC>
                delete(obj.OperCondRowFilterObj);
            end
            try %#ok<*TRYNC>
                delete(obj.OperCondColumnFilterObj);
            end
        end % delete
        
    end 
   
end

        
function y = getColor(ind)
color = {'b','r','g','k','m','c',[0.5,0.5,0]};
if ind <= 7
    y = color{ind};
else
    y = [rand(1),rand(1),rand(1)];
end

end % getColor 

function y = getSymbol(ind)

sym = {'o','s','d','+','*','x','.','^','v','>','<','p','h'};

indWrap = mod(ind - 1 , length(sym) ) + 1;

y = sym{indWrap};

end % getSymbol
        