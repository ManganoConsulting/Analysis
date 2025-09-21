classdef Table < matlab.mixin.Copyable & UserInterface.GraphicsObject
    
    %% Public properties - Object Handles
    properties (Transient = true)      
        TableContainer
        JScroll
        JTable
        JTableH
        JHScroll
        HContainer       
        FixColTbl
        TableModel      
    end
    
    %% Public properties - Data Storage
    properties  
        Data = cell(50,50)
        ShowDataRow logical = true(50,1)
        ShowDataColumn logical = true(50,1);
        RowNames
        ValidTrimArray      
    end % Public properties
    
    %% Private properties - Data Storage
    properties  ( Access = private )
        PrivateTableColumnNames = {'Type','Name','Units'};
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        SelectedRows
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        TableData
        NumericTableData
        TableColumnNames
    end % Dependant properties

    %% Constant properties
    properties (Constant) 
        JavaImage_checked        = checkedIcon();
        JavaImage_partialchecked = partialCheckIcon();
        JavaImage_unchecked      = uncheckedIcon();
        JavaImage_folderopen     = folderOpenIcon();
        JavaImage_folder         = folderIcon();
        JavaImage_structure      = structureIcon();
        JavaImage_model          = modelIcon();
        JavaImage_localVar       = localVarIcon(); 
        JavaImage_config         = configIcon(); 
        TableFormatString        = '%6.3e\n'
    end % Constant properties  
    
    %% Events
    events
        TableDataChangedEvent
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = Table(parent,data)
            switch nargin
                case 0                    
                case 1
                    obj.Parent = parent;
                case 2
                    obj.Parent = parent;
                    obj.Data = data;
            end
            createView(obj);
        end % Condition
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
        
        function data = get.TableData(obj) 
            data = obj.Data(obj.ShowDataRow,obj.ShowDataColumn);       
            % Set the Column Names
            numStr = cellfun(@(x) num2str(x),num2cell( 1:(size(data,2) - 3) ),'UniformOutput',false);
            obj.PrivateTableColumnNames = [{'Type','Name','Units'},numStr];            
        end % TableData
        
        function header = get.TableColumnNames(obj)
            header = obj.PrivateTableColumnNames;
        end % TableColumnNames
        
        function set.ShowDataRow( obj , x )
            obj.ShowDataRow = x;
        end % ShowDataRow
        
        function set.ShowDataColumn( obj , x )
            obj.ShowDataColumn = x;
        end % ShowDataColumn
              
    end % Property access methods
   
    %% Methods - Public Creation Methods
    methods 

    end
    
    %% Methods - Protected -  View
    methods %(Access = protected)
        
        function createView(obj,parent)
            if nargin == 2
                obj.Parent = parent;
            end
            obj.TableContainer = uipanel('Parent',obj.Parent,...
                'Title',[],...
                'BorderType','none',...
                'Units', 'Normal',...
                'Position',[ 0 , 0 , 1 , 1 ]);
            set(obj.TableContainer,'ResizeFcn',@obj.reSizeTable);
                                     
            update(obj);
        end % createView
        
    end
    
   %% Methods - Ordinary
    methods 

        
    end % Ordinary Methods
    
    %% Methods - Table Callbacks Protected
    methods (Access = protected)   
     
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
                elseif length(obj.SelectedRows) == 2
                        % Ask the user to plot the selected Rows
                        clickX = eventdata.getX;
                        clickY = eventdata.getY;
                        jtable = eventdata.getSource;
                        jmenu = javax.swing.JPopupMenu;
                        menuItem1 = javax.swing.JMenuItem('<html><b>Plot');
                        menuItem1h = handle(menuItem1,'CallbackProperties');
                        set(menuItem1h,'ActionPerformedCallback',@obj.plotRowVsRow_CB); 
                        jmenu.add(menuItem1); 
                        jmenu.show(jtable, clickX, clickY);
                        jmenu.repaint; 
                else
                     obj.SelectedRows = [];
                    disp('Need to reset') 
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
        
        function saveOperatingCondition2File( ~ , ~ , ~ , hobj )
            operConds = hobj.handle.UserData; %#ok<NASGU>
            uisave('operConds','OperatingConditions');
        end % saveOperatingCondition2File          
        
        function writeOperCond2MFile( obj , ~ , ~ )
            disp('Write2M-file: This function needs to be completed.') 
        end% writeOperCond2MFile
              
    end
    
    %% Methods - Resize Methods
    methods   
   
        function reSizeTable( obj , ~ , ~ )
%             parentPos = getpixelposition(obj.TableContainer);
%             set(obj.HContainer,'Units','Pixels');
%             set(obj.HContainer,'Position',[ parentPos(1) , parentPos(2) , parentPos(3) , parentPos(4) ]);
        end % reSizeTable
        
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
            ylabel(ah,strrep(obj.TableData{obj.SelectedRows(1),2},'_','\_'));
            set(ah,'xtick',x);
            
        end % plotSelectedRow
        
        function plotRowVsRow_CB( obj , ~ , ~ )

            y = obj.NumericTableData(obj.SelectedRows(2),:);
            x = obj.NumericTableData(obj.SelectedRows(1),:);
            
            fh = figure;
            ah=axes('Parent',fh);
            grid(ah);
            line(x,y,'Parent',ah,'Marker','o','MarkerFaceColor','b');
            xlabel(ah,strrep(obj.TableData{obj.SelectedRows(1),2},'_','\_'))
            ylabel(ah,strrep(obj.TableData{obj.SelectedRows(2),2},'_','\_'));
            
             
        end % plotSelectedRow   
        
    end
    
    %% Methods - Public Update Methods
    methods 
        
        function initialize( obj )
            obj.ShowDataColumn = true(size(obj.Data,2),1);
            obj.ShowDataRow    = true(size(obj.Data,1),1);
            update(obj);
        end % initialize
        
        function updateTableData( obj , data , validTrimArray , sizeNew ) 
            obj.Data = data;
            if nargin == 3
                obj.ValidTrimArray = validTrimArray;
            else
                obj.ValidTrimArray = [];
            end
            
            obj.ShowDataColumn = [obj.ShowDataColumn;true(sizeNew,1)];
            update(obj);  
        end % updateTableData
                    
    end
        
    %% Methods -  Update Methods
    methods
        
        function update( obj )
            import UserInterface.StabilityControl.*
            tblData = obj.TableData;
            
            %%%%% Very slow %%%%%%%%
            frmt = cell(size(tblData));
            frmt(:) = {obj.TableFormatString};
            tblData = cellfun(@num2str, tblData, frmt , 'UniformOutput', false);
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.TableModel = javax.swing.table.DefaultTableModel(tblData,obj.TableColumnNames);
            obj.JTable = javaObjectEDT(javax.swing.JTable(obj.TableModel));
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
            
            
            cr = ColoredFieldCellRenderer;
            cr.setFgColor( java.awt.Color.black )
  
            for j = 0:obj.JTable.getColumnCount-1            
                obj.JTable.getColumnModel.getColumn(j).setCellRenderer(cr);
                for i = 0:2:double(obj.JTable.getRowCount)
                    cr.setCellBgColor( i,j,java.awt.Color.white ); 
                end
                column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(70);column0.setMinWidth(70);column0.setMaxWidth(70);   
            end     
            obj.JTable.setGridColor(java.awt.Color.lightGray);    
            
            for j = 0:obj.JTable.getColumnCount-1            
                obj.JTable.getColumnModel.getColumn(j).setCellRenderer(cr);
                for i = 1:2:double(obj.JTable.getRowCount)
                    cr.setCellBgColor( i,j,java.awt.Color( 246/255 , 243/255 , 237/255 )  ); 
                end
                column0 = obj.JTable.getColumnModel().getColumn(j);column0.setPreferredWidth(70);column0.setMinWidth(70);column0.setMaxWidth(70);   
            end          
            
            %set fg color for invalid trims Needs Work
%             for j = 0:obj.JTable.getColumnCount-1            
%                 for i = 0:1:double(obj.JTable.getRowCount)
%                     cr.setCellFgColor( i,j,java.awt.Color.red ); 
%                 end
%             end      
            
         obj.FixColTbl= javaObjectEDT(FixedColumnTable(3, obj.JScroll)); 
         fixColTbl = obj.FixColTbl.getFixedTable();
         fixColTbl.setGridColor(java.awt.Color.black); 
            

%             % Taken from: http://xtargets.com/snippets/posts/show/37
%             obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
%             
%             obj.JTable. repaint;
%             obj.JTable.setVisible(true);
%obj.JTable.setAutoCreateRowSorter(true);
%obj.FixColTbl.setAutoCreateRowSorter(true);
            % Notify that the Table Data has changed
            notify(obj,'TableDataChangedEvent',TableDataChangedEventData( tblData , obj.Data ));

        end % update                   
                     
    end
    
    %% Methods - Protected -  Copy
    methods (Access = protected)            
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the xxxx object
%             cpObj.xxxx = copy(obj.xxxx);
            
        end
        
    end
    
end

function childNodes = findDirectChildrenInNode(root)
    childNodes = cell(1,length(root.getChildCount));
    for i = 0:root.getChildCount - 1
        childNodes{i+1} = root.getChildAt(i);
    end

end % findDirectChildrenInNode
