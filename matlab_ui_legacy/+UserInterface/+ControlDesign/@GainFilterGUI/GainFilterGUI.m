classdef GainFilterGUI < UserInterface.Collection
    
    %% Public properties - Object Handles
    properties (Transient = true)             
        JTable
        JScroll
        JTableH
        JHScroll
        HContainer
        SearchVar1_pm
        SearchVar2_pm      
        SearchVar3_pm
        SearchVar4_pm
        HCompSearchValue1_pm
        HContSearchValue1_pm
        HCompSearchValue2_pm
        HContSearchValue2_pm
        HCompSearchValue3_pm
        HContSearchValue3_pm
        HCompSearchValue4_pm
        HContSearchValue4_pm      
        ScatterGainFilterLabelComp
        ScatterGainFilterLabelCont
    end % Public properties
  
    %% Public properties - Data Storage
    properties 
        JCBListArraySearchValue1
        JCBListArraySearchValue2
        JCBListArraySearchValue3
        JCBListArraySearchValue4
        JCBListSelectedStringSearchValue1
    	JCBListSelectedStringSearchValue2
    	JCBListSelectedStringSearchValue3
    	JCBListSelectedStringSearchValue4   
    end % Public properties
    
    %% Read Only properties - Data Storage
    properties ( SetAccess = private )  
        FilteredGainColl ScatteredGain.GainCollection = ScatteredGain.GainCollection.empty
        ScatteredGainFileObj ScatteredGain.GainFile = ScatteredGain.GainFile.empty
    end % Public properties
    
    %% Private properties
    properties ( Access = private )      
        SearchVar1   = struct('selStr',{''},'strList',{{''}},'selVal',1)
        SearchVar2   = struct('selStr',{''},'strList',{{''}},'selVal',1)      
        SearchVar3   = struct('selStr',{''},'strList',{{''}},'selVal',1)
        SearchVar4   = struct('selStr',{''},'strList',{{''}},'selVal',1)
        PrivateTableHeader = {'A','','','','','D',' '}   
    end % Private properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )
        ParentFigure
        
        SelectedFilterFields       
        TableData
        TableHeader
        ScatteredGainsColl
    end % Dependant properties
    
    %% Constant Properties
    properties (Constant)
        Colors = constantColors();  
    end   
    
    %% Events
    events
        FilteredGainsUpdated
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods             
        function obj = GainFilterGUI(varargin)      
%             if nargin == 0
%                return; 
%             end  
            obj@UserInterface.Collection(varargin{:}); 
            createView( obj , obj.Parent );
        end % GainFilterGUI
        
    end % Constructor

    %% Methods - Property Access
    methods
               
        function y = get.ParentFigure( obj )
            y = ancestor(obj.Container,'Figure','toplevel');
        end % ParentFigure
        
        function data = get.TableData(obj)
            selFields = {'All','All','All','All'}; 
            data = cell(length(obj.FilteredGainColl),6);
            for i = 1:length(obj.FilteredGainColl)
                data{i,1} = obj.FilteredGainColl(i).Selected;
                [ data(i,2:5) , selFields ] = getDisplayData(obj.FilteredGainColl(i).DesignOperatingCondition,obj.SelectedFilterFields{:});
                data{i,6} = [int2str(obj.FilteredGainColl(i).Color(1)),',',int2str(obj.FilteredGainColl(i).Color(2)),',',int2str(obj.FilteredGainColl(i).Color(3))];
                
            end
            obj.PrivateTableHeader = [' ',selFields,' '];
        end % TableData
        
        function header = get.TableHeader(obj)
            header = obj.PrivateTableHeader;
        end % TableHeader
        
        function y = get.SelectedFilterFields(obj)
            fc1 = obj.SearchVar1.selStr;
            fc2 = obj.SearchVar2.selStr;
            ic  = obj.SearchVar3.selStr;
            wc  = obj.SearchVar4.selStr;
            y = {fc1,fc2,ic,wc};
        end % SelectedFilterFields
        
        function y = get.ScatteredGainsColl( obj )
            if isempty(obj.ScatteredGainFileObj)
                y = ScatteredGain.GainCollection.empty;
            else
                y = obj.ScatteredGainFileObj.ScatteredGainCollection;
            end
        end % ScatteredGainsColl  
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
        function addScatteredGainColl(obj, newScattGainColl)
            obj.ScatteredGainsColl = [obj.ScatteredGainsColl,newScattGainColl];
            if ~isempty(obj.ScatteredGainsColl)
                updateAvaliableSelections(obj);
                enablePopUps( obj , 'on' );
            end
        end % addScatteredGainColl    
        
        function selectedScatteredGainCollUpdated(obj, newScattGainColl)
            obj.ScatteredGainFileObj = newScattGainColl;
            resetFilter( obj );
            enablePopUps( obj , 'on' );
        end % selectedScatteredGainCollUpdated   
        
        function resetFilter( obj )
            obj.FilteredGainColl = obj.ScatteredGainsColl;
            initializeFilteredGains(obj);
            updateAvaliableSelections(obj);
            
            searchVar1_pm_CB( obj , obj.SearchVar1_pm , [] );%update(obj);
        end % resetFilter
        
    end % Ordinary Methods
    
    %% Method - Callbacks
    methods (Access = protected)
        
        function mousePressedInTable( obj , hModel , hEvent )

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
            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            modifiedOC = obj.FilteredGainColl(modifiedRow + 1);
            newData = hModel.getValueAt(modifiedRow,modifiedCol);
            switch modifiedCol
                case 0
                    modifiedOC.Selected = newData;
                    
                    notify(obj,'FilteredGainsUpdated',UserInterface.UserInterfaceEventData(obj.FilteredGainColl([obj.FilteredGainColl.Selected])));
                case 5
                    color = double([ newData.getRed , newData.getGreen , newData.getBlue ]);
                    modifiedOC.Color = color;
            end
        end % dataUpdatedInTable
        
        function popUpMenuCancelled( obj , hModel , hEvent )
            %disp('pop');
        end % popUpMenuCancelled   
        
        function ComponentAddedCallback( obj , hModel , hEvent )
           % disp('comp');
        end % ComponentAddedCallback 
        
        function ItemStateChangedCallback( obj , hModel , hEvent )
          %  disp('item');
        end % ItemStateChangedCallback 
        
        function PopupMenuWillBecomeInvisibleCallback( obj , hModel , hEvent )

        end % PopupMenuWillBecomeInvisibleCallback 

        function write2MFile( obj , hModel , hEvent , ind )
            
            file = Utilities.writeScattGainObj2mfile(obj.FilteredGainColl(ind + 1 ) , true , obj.TableHeader(2:5) , obj.TableData(:,2:5) ); 
            for i = 1:length(file)
                open(file{i});
            end
        end % write2MFile 
    end

    %% Methods - Protected(ReSize)
    methods (Access = protected)       

        function resize( obj , ~ , ~ )
            panelPos = getpixelposition(obj.Container);

            obj.ScatterGainFilterLabelCont.Position = [ 1 , panelPos(4) - 18 , panelPos(4) , 16 ]; 
            
            % - searchMdlRow1HBox ------------------------------------

            % - searchMdlRow2HBox ------------------------------------
            set(obj.SearchVar1_pm,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 55 , 75 , 25 ]);
            set(obj.HContSearchValue1_pm,...
                'Units','Pixels',...
                'Position',[ 85 , panelPos(4) - 55 , 75 , 25 ]);
            set(obj.SearchVar2_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 163 , panelPos(4) - 55 , 75 , 25 ]);
            set(obj.HContSearchValue2_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 83 , panelPos(4) - 55 , 75 , 25 ]);
            % - searchMdlRow3HBox ------------------------------------
           set(obj.SearchVar3_pm,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 90 , 75 , 25 ]);
            set(obj.HContSearchValue3_pm,...
                'Units','Pixels',...
                'Position',[ 85 , panelPos(4) - 90 , 75 , 25 ]);
            set(obj.SearchVar4_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 163 , panelPos(4) - 90 , 75 , 25 ]);
            set(obj.HContSearchValue4_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 83 , panelPos(4) - 90 , 75 , 25 ]); 
            set(obj.HContainer,'units', 'pixels','position',[2,2,panelPos(3)-7,panelPos(4)-100]); 
            
            
        end % resize
         
    end
    
    %% Methods - Protected(Update)
    methods (Access = protected)       
   
        function update(obj)
            
            set(obj.SearchVar1_pm,'string',obj.SearchVar1.strList);
            set(obj.SearchVar1_pm,'value', obj.SearchVar1.selVal );



            if isempty(obj.JCBListArraySearchValue1)
                model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                obj.HCompSearchValue1_pm.setModel(model);      
            else
                model = javaObjectEDT('javax.swing.DefaultComboBoxModel',obj.JCBListArraySearchValue1 );
                obj.HCompSearchValue1_pm.setModel(model);
                obj.HCompSearchValue1_pm.setSelectedItem( obj.JCBListSelectedStringSearchValue1 );
            end

    
            set(obj.SearchVar2_pm,'string',obj.SearchVar2.strList);
            set(obj.SearchVar2_pm,'value', obj.SearchVar2.selVal );
   
            if isempty(obj.JCBListArraySearchValue2)
                model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                obj.HCompSearchValue2_pm.setModel(model);
            else
                model = javaObjectEDT('javax.swing.DefaultComboBoxModel',obj.JCBListArraySearchValue2 );
                obj.HCompSearchValue2_pm.setModel(model);
                obj.HCompSearchValue2_pm.setSelectedItem( obj.JCBListSelectedStringSearchValue2 );
            end

            set(obj.SearchVar3_pm,'string',obj.SearchVar3.strList);
            set(obj.SearchVar3_pm,'value', obj.SearchVar3.selVal );

            if isempty(obj.JCBListArraySearchValue3)
                model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                obj.HCompSearchValue3_pm.setModel(model);
            else
                model = javaObjectEDT('javax.swing.DefaultComboBoxModel',obj.JCBListArraySearchValue3 );
                obj.HCompSearchValue3_pm.setModel(model);
                obj.HCompSearchValue3_pm.setSelectedItem( obj.JCBListSelectedStringSearchValue3 );
            end

            set(obj.SearchVar4_pm,'string',obj.SearchVar4.strList);
            set(obj.SearchVar4_pm,'value', obj.SearchVar4.selVal );
            
            if isempty(obj.JCBListArraySearchValue4)
                model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                obj.HCompSearchValue4_pm.setModel(model);
            else
                model = javaObjectEDT('javax.swing.DefaultComboBoxModel',obj.JCBListArraySearchValue4 );
                obj.HCompSearchValue4_pm.setModel(model);
                obj.HCompSearchValue4_pm.setSelectedItem( obj.JCBListSelectedStringSearchValue4 );
            end
            
            if isempty( obj.JCBListSelectedStringSearchValue1 )
                SelectedStringSearchValue1 = [];
            else
                SelectedStringSearchValue1 = cell( obj.JCBListSelectedStringSearchValue1 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue2 )
                SelectedStringSearchValue2 = [];
            else
                SelectedStringSearchValue2 = cell( obj.JCBListSelectedStringSearchValue2 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue3 )
                SelectedStringSearchValue3 = [];
            else
                SelectedStringSearchValue3 = cell( obj.JCBListSelectedStringSearchValue3 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue4 )
                SelectedStringSearchValue4 = [];
            else
                SelectedStringSearchValue4 = cell( obj.JCBListSelectedStringSearchValue4 );
            end
            
            [obj.FilteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, SelectedStringSearchValue1 ,...
                obj.SearchVar2.selStr, SelectedStringSearchValue2 ,...
                obj.SearchVar3.selStr, SelectedStringSearchValue3 ,...
                obj.SearchVar4.selStr, SelectedStringSearchValue4 ,...
                1e-4); 
            updateTable( obj );
        end % update   
        
        function updateTable( obj , selected )%updateTable(obj)

            switch nargin
                case 1
                    selected = true(1,length(obj.FilteredGainColl));
                case 2
                    if ~islogical(selected) || length(selected) ~= length(obj.FilteredGainColl)
                        selected = true(1,length(obj.FilteredGainColl));
                    end    
            end
            for i = 1:length(obj.FilteredGainColl)
                obj.FilteredGainColl(i).Selected = selected(i);
            end

            obj.JTable.setVisible(false)
            obj.JTable.setModel(javaObjectEDT('javax.swing.table.DefaultTableModel',obj.TableData,obj.TableHeader)); 
            
            obj.JTable.getColumnModel.getColumn(5).setCellRenderer(ColorCellRenderer); 
            obj.JTable.getColumnModel.getColumn(5).setCellEditor(ColorCellEditor);     

            checkBoxCR = javaObjectEDT('com.jidesoft.grid.BooleanCheckBoxCellRenderer');
            checkBoxCE = javaObjectEDT('com.jidesoft.grid.BooleanCheckBoxCellEditor');
            
            nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.

            obj.JTable.getColumnModel.getColumn(0).setCellRenderer(checkBoxCR); 
            obj.JTable.getColumnModel.getColumn(0).setCellEditor(checkBoxCE); 

            obj.JTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR);
            obj.JTable.getColumnModel.getColumn(2).setCellEditor(nonEditCR);
            obj.JTable.getColumnModel.getColumn(3).setCellEditor(nonEditCR);
            obj.JTable.getColumnModel.getColumn(4).setCellEditor(nonEditCR);
            
%             cr = ColoredFieldCellRenderer;
%             cr.setFgColor( java.awt.Color.black )
%             obj.JTable.getColumnModel.getColumn(1).setCellRenderer(cr);
%             for i = 0:2:double(obj.JTable.getRowCount)
%                 cr.setCellBgColor( i,1,java.awt.Color.white ); 
%             end
%             obj.JTable.getColumnModel.getColumn(2).setCellRenderer(cr);
%             for i = 0:2:double(obj.JTable.getRowCount)
%                 cr.setCellBgColor( i,2,java.awt.Color.white ); 
%             end
%             obj.JTable.getColumnModel.getColumn(3).setCellRenderer(cr);
%             for i = 0:2:double(obj.JTable.getRowCount)
%                 cr.setCellBgColor( i,3,java.awt.Color.white ); 
%             end  
%             obj.JTable.getColumnModel.getColumn(4).setCellRenderer(cr);
%             for i = 0:2:double(obj.JTable.getRowCount)
%                 cr.setCellBgColor( i,4,java.awt.Color.white ); 
%             end  

            column0 = obj.JTable.getColumnModel().getColumn(0);column0.setPreferredWidth(20);column0.setMinWidth(20);%column0.setMaxWidth(20);
            column1 = obj.JTable.getColumnModel().getColumn(1);column1.setPreferredWidth(66);column1.setMinWidth(66);%column1.setMaxWidth(66);
            column2 = obj.JTable.getColumnModel().getColumn(2);column2.setPreferredWidth(66);column2.setMinWidth(66);%column2.setMaxWidth(66);
            column3 = obj.JTable.getColumnModel().getColumn(3);column3.setPreferredWidth(66);column3.setMinWidth(66);%column3.setMaxWidth(66);
            column4 = obj.JTable.getColumnModel().getColumn(4);column4.setPreferredWidth(66);column4.setMinWidth(66);%column4.setMaxWidth(66);
            column5 = obj.JTable.getColumnModel().getColumn(5);column5.setPreferredWidth(20);column5.setMinWidth(20);%column5.setMaxWidth(20);
            
           
            obj.JTable.setGridColor(java.awt.Color.lightGray);

            set(handle(obj.JTable.getModel, 'CallbackProperties'),  'TableChangedCallback', {@obj.dataUpdatedInTable,obj.JTable});
            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.JTable. repaint;
            obj.JTable.setVisible(true);
            enablePopUps( obj , 'on' );

            
            if ~isempty(obj.FilteredGainColl)
                notify(obj,'FilteredGainsUpdated',UserInterface.UserInterfaceEventData(obj.FilteredGainColl));
            end
        end % updateTable
        
    end
    
    %% Methods - Protected
    methods ( Access = protected )
        function cpObj = copyElement(obj)   
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end % copyElement  
    end
    
    %% Methods - Private
    methods (Access = private) 
        
        function initializeFilteredGains(obj)
            
            for i = 1:length(obj.FilteredGainColl)
                obj.FilteredGainColl(i).Selected = true;
                obj.FilteredGainColl(i).Color = obj.Colors{i};
            end
        end % initializeFilteredGains        
        
        function updateAvaliableSelections(obj)
            if isempty(obj.ScatteredGainsColl)
                % update fc popupmenu string
                obj.SearchVar1.strList = {''}; 
                obj.SearchVar1.selVal = 1;
                obj.SearchVar1.selStr = '';

                obj.SearchVar2.strList = {''}; 
                obj.SearchVar2.selVal = 1; 
                obj.SearchVar2.selStr = '';

                obj.SearchVar3.strList = {''}; 
                obj.SearchVar3.selVal = 1; 
                obj.SearchVar3.selStr = '';

                obj.SearchVar4.strList = {''}; 
                obj.SearchVar4.selVal = 1; 
                obj.SearchVar4.selStr = '';
                
                obj.JCBListArraySearchValue1 = {};
                obj.JCBListSelectedStringSearchValue1 = [];

                obj.JCBListArraySearchValue2 = {};
                obj.JCBListSelectedStringSearchValue2 = [];

                obj.JCBListArraySearchValue3 = {};
                obj.JCBListSelectedStringSearchValue3 = [];

                obj.JCBListArraySearchValue4 = {};
                obj.JCBListSelectedStringSearchValue4 = []; 
            else
                % update fc popupmenu string
                obj.SearchVar1.strList = {'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                obj.SearchVar1.selVal = 1;
                obj.SearchVar1.selStr = obj.SearchVar1.strList{obj.SearchVar1.selVal};

                obj.SearchVar2.strList = {'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                obj.SearchVar2.selVal = 2; 
                obj.SearchVar2.selStr = obj.SearchVar2.strList{obj.SearchVar2.selVal};

                obj.SearchVar3.strList = [{obj.ScatteredGainsColl(1).DesignOperatingCondition.Inputs.Name}';{obj.ScatteredGainsColl(1).DesignOperatingCondition.Outputs.Name}'];
                obj.SearchVar3.selVal = 1; 
                obj.SearchVar3.selStr = obj.SearchVar3.strList{obj.SearchVar3.selVal};

                obj.SearchVar4.strList = ['Label';'WeightCode';{obj.ScatteredGainsColl(1).DesignOperatingCondition.MassProperties.Parameter.Name}'];
                obj.SearchVar4.selVal = 1; 
                obj.SearchVar4.selStr = obj.SearchVar4.strList{obj.SearchVar4.selVal};    
                
                SelectedStringSearchValue1 = [];  
                SelectedStringSearchValue2 = [];
                SelectedStringSearchValue3 = [];
                SelectedStringSearchValue4 = [];
 
                obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( obj.ScatteredGainsColl , obj.SearchVar1.selStr );%obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar1.selStr );
                obj.JCBListSelectedStringSearchValue1 = SelectedStringSearchValue1;%obj.JCBListSelectedStringSearchValue1 = obj.JCBListArraySearchValue1;


                obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( obj.ScatteredGainsColl , obj.SearchVar2.selStr );%obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
                obj.JCBListSelectedStringSearchValue2 = SelectedStringSearchValue2;%obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


                obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( obj.ScatteredGainsColl , obj.SearchVar3.selStr );%obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
                obj.JCBListSelectedStringSearchValue3 = SelectedStringSearchValue3;%obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


                obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( obj.ScatteredGainsColl , obj.SearchVar4.selStr );%obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
                obj.JCBListSelectedStringSearchValue4 = SelectedStringSearchValue4;%obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;
  
            end
            
            obj.update();
        end % updateAvaliableSelections   
        
        function y = getAvaliableSelectionsFC( obj ,  GainColl , selStr )
            if ~strcmp(selStr,'All')
                sl1 = zeros(size(GainColl));
                for i = 1:length(GainColl)
                    sl1(i) = GainColl(i).DesignOperatingCondition.FlightCondition.(selStr);
                end
                sl1Unique = sort(unique(sl1)).';
                y = strtrim(cellstr(num2str(sl1Unique(:))));
            else
                y = {};
            end
        end % getAvaliableSelectionsFC

        function y = getAvaliableSelectionsIC( obj , GainColl , selStr )
            if ~strcmp(selStr,'All')
                sl1 = zeros(size(GainColl));
                for i = 1:length(GainColl)
                    try
                        sl1(i) = GainColl(i).DesignOperatingCondition.Inputs.get(selStr).Value;
                    catch
                        sl1(i) = GainColl(i).DesignOperatingCondition.Outputs.get(selStr).Value;
                    end
                end
                
                sl1Unique = sort(unique(sl1)).';
                y = strtrim(cellstr(num2str(sl1Unique(:))));
            else
                y = {};
            end
        end % getAvaliableSelectionsIC

        function y = getAvaliableSelectionsWC( obj , GainColl , selStr )
            if ~strcmp(selStr,'All')
                sl4 = cell(size(GainColl));%sl4 = zeros(size(FilteredGainColl4));
                for i = 1:length(GainColl)
                    sl4{i} = num2str(GainColl(i).DesignOperatingCondition.MassProperties.get(selStr));
                end
                y = strtrim(sort(unique(sl4)));
            else
                y = {};
            end
        end % getAvaliableSelectionsWC
        
        function enablePopUps( obj , val )
%             set(obj.SearchVar1_pm,  'Enable',val);
%             %set(obj.SearchValue1_pm,'Enable',val);
%             set(obj.SearchVar2_pm,  'Enable',val);
%             %set(obj.SearchValue2_pm,'Enable',val);                            
%             set(obj.SearchVar3_pm,  'Enable',val);
%             %set(obj.SearchValue3_pm,'Enable',val);
%             set(obj.SearchVar4_pm,  'Enable',val);
%             %set(obj.SearchValue4_pm,'Enable',val); 
        end % enablePopUps
        
    end  
    
    %% Methods - View - Gain Filter
    methods 
        
        function createView( obj , parent )
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );  
            
            obj.Parent = parent;

            obj.Container = uipanel('Parent',obj.Parent,...
                'Title',obj.Title,...
                'BorderType',obj.BorderType,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Parent,'ResizeFcn',@obj.resize);
            
            if ~isempty(parent)
                obj.Parent = parent;
            end
            obj.Container = uipanel('Parent',obj.Parent,...
                'BorderType',obj.BorderType,...
                'Title',obj.Title,...
                'Units', obj.Units,...
                'Position',obj.Position,...
                'Visible','on');
            set(obj.Container,'ResizeFcn',@obj.resize);         


            try
                bkColor = get(obj.Container,'BackgroundColor');
            catch
               bkColor = get(obj.Container,'Color'); 
            end
            popupFtSize = 8;
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Scattered Gain Filter</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ScatterGainFilterLabelComp,obj.ScatterGainFilterLabelCont] = javacomponent(jLabelview, [] , obj.Container );
            
     
            obj.SearchVar1_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar1_pm_CB);   
            
            SearchValue1Button = javaObjectEDT('com.jidesoft.combobox.CheckBoxListComboBox');
            SearchValue1ButtonH = handle(SearchValue1Button,'CallbackProperties');
            SearchValue1ButtonH.PopupMenuWillBecomeInvisibleCallback = @obj.searchValue1_pm_CB;
       
            
            SearchValue1Button.setToolTipText('Select the Name');
            SearchValue1Button.setEditable(false);
            [obj.HCompSearchValue1_pm,obj.HContSearchValue1_pm] = javacomponent( SearchValue1Button , [] , obj.Container ); 
            model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
            obj.HCompSearchValue1_pm.setModel(model);

            
            obj.SearchVar2_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar2_pm_CB);
            
            SearchValue2Button = javaObjectEDT('com.jidesoft.combobox.CheckBoxListComboBox');
            SearchValue2ButtonH = handle(SearchValue2Button,'CallbackProperties');
            SearchValue2ButtonH.PopupMenuWillBecomeInvisibleCallback = @obj.searchValue2_pm_CB;
            SearchValue2ButtonH.PopupMenuCanceledCallback = @obj.popUpMenuCancelled;
            SearchValue2Button.setToolTipText('Select the Name');
            SearchValue2Button.setEditable(false);
            [obj.HCompSearchValue2_pm,obj.HContSearchValue2_pm] = javacomponent( SearchValue2Button , [] , obj.Container ); 
            model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
            obj.HCompSearchValue2_pm.setModel(model);
            

           obj.SearchVar3_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar3_pm_CB);
            
            SearchValue3Button = javaObjectEDT('com.jidesoft.combobox.CheckBoxListComboBox');
            SearchValue3ButtonH = handle(SearchValue3Button,'CallbackProperties');
            SearchValue3ButtonH.PopupMenuWillBecomeInvisibleCallback = @obj.searchValue3_pm_CB;
            SearchValue3ButtonH.PopupMenuCanceledCallback = @obj.popUpMenuCancelled;
            SearchValue3Button.setToolTipText('Select the Name');
            SearchValue3Button.setEditable(false);
            [obj.HCompSearchValue3_pm,obj.HContSearchValue3_pm] = javacomponent( SearchValue3Button , [] , obj.Container ); 
            model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
            obj.HCompSearchValue3_pm.setModel(model);
            

            obj.SearchVar4_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar4_pm_CB);
            SearchValue4Button = javaObjectEDT('com.jidesoft.combobox.CheckBoxListComboBox');
            SearchValue4ButtonH = handle(SearchValue4Button,'CallbackProperties');
            SearchValue4ButtonH.PopupMenuWillBecomeInvisibleCallback = @obj.searchValue4_pm_CB;
            SearchValue4ButtonH.PopupMenuCanceledCallback = @obj.popUpMenuCancelled;
            SearchValue4Button.setToolTipText('Select the Name');
            SearchValue4Button.setEditable(false);
            [obj.HCompSearchValue4_pm,obj.HContSearchValue4_pm] = javacomponent( SearchValue4Button , [] , obj.Container ); 
            model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
            obj.HCompSearchValue4_pm.setModel(model);
            
            
%             javaaddpath(fileparts(mfilename('fullpath')));  % add the Java class file to the dynamic java class-path
                  
            createTable(obj);


            update(obj);
            
            updateTable( obj );
            resize( obj , [] , [] );
            
            
        end % createView 
        
        function createTable(obj)

            model = javaObjectEDT('javax.swing.table.DefaultTableModel',obj.TableData,obj.TableHeader);
            obj.JTable = javaObjectEDT('javax.swing.JTable',model);
            obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');  % ensure that we're using EDT
            % Present the tree-table within a scrollable viewport on-screen
            obj.JScroll = javaObjectEDT('javax.swing.JScrollPane',obj.JTable);
            [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], obj.Container);
            
            % Set Callbacks
            obj.JTableH.MousePressedCallback = @obj.mousePressedInTable;
            obj.JTableH.KeyReleasedCallback  = @obj.keyReleasedInTable; 
            obj.JTableH.FocusGainedCallback  = @obj.focusGainedInTable;
            obj.JTableH.KeyPressedCallback   = @obj.keyPressedInTable;
            obj.JTableH.KeyTypedCallback     = @obj.keyTypedInTable;
            JModelH = handle(obj.JTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = {@obj.dataUpdatedInTable,obj.JTable};
            %set(handle(obj.JTable.getModel, 'CallbackProperties'),  'TableChangedCallback', {@obj.dataUpdatedInTable,obj.JTable});
            
            
    
            drawnow();pause(0.1);    
            %obj.updateTable;

        end % createTable
        
    end
    
    %% Methods - Filter Callbacks
    methods
        
        function searchValue1_pm_CB( obj , ~ , ~ )

            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            obj.JCBListSelectedStringSearchValue1 = obj.HCompSearchValue1_pm.getSelectedItem;

            if isempty(obj.JCBListSelectedStringSearchValue1)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr, [],...
                obj.SearchVar3.selStr, [],...
                obj.SearchVar4.selStr, [],...
                1e-4); 



            obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
            obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;



            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            
            
        end % searchValue1_pm_CB

        function searchValue2_pm_CB( obj , ~ , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            obj.JCBListSelectedStringSearchValue2 = obj.HCompSearchValue2_pm.getSelectedItem;

            if isempty(obj.JCBListSelectedStringSearchValue2)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr, cell( obj.JCBListSelectedStringSearchValue2 ),...
                obj.SearchVar3.selStr, [],...
                obj.SearchVar4.selStr, [],...
                1e-4); 




            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;



            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchValue2_pm_CB

        function searchValue3_pm_CB( obj , ~ , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            obj.JCBListSelectedStringSearchValue3 = obj.HCompSearchValue3_pm.getSelectedItem;

            if isempty(obj.JCBListSelectedStringSearchValue3)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr, cell( obj.JCBListSelectedStringSearchValue2 ),...
                obj.SearchVar3.selStr, cell( obj.JCBListSelectedStringSearchValue3 ),...
                obj.SearchVar4.selStr, [],...
                1e-4); 




            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;



            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchValue3_pm_CB

        function searchValue4_pm_CB( obj , ~ , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            obj.JCBListSelectedStringSearchValue4 = obj.HCompSearchValue4_pm.getSelectedItem;

            if isempty(obj.JCBListSelectedStringSearchValue4)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end   
            
            update( obj );

            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchValue4_pm_CB

        function searchVar1_pm_CB( obj , hobj , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            if isempty(obj.SearchVar1.selStr)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end



            obj.JCBListSelectedStringSearchValue1 = [];
            obj.JCBListSelectedStringSearchValue2 = [];
            obj.JCBListSelectedStringSearchValue3 = [];
            obj.JCBListSelectedStringSearchValue4 = [];

            avalParam             = get(hobj,'string');
            obj.SearchVar1.selVal = get(hobj,'value');
            obj.SearchVar1.selStr = avalParam{obj.SearchVar1.selVal};

            obj.SearchVar2.selVal = 2; 
            obj.SearchVar2.selStr = obj.SearchVar2.strList{obj.SearchVar2.selVal};

            obj.SearchVar3.selVal = 1; 
            obj.SearchVar3.selStr = obj.SearchVar3.strList{obj.SearchVar3.selVal};

            obj.SearchVar4.selVal = 1; 
            obj.SearchVar4.selStr = obj.SearchVar4.strList{obj.SearchVar4.selVal};    

            [filteredGainColl,~] = searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
                obj.SearchVar2.selStr, obj.JCBListSelectedStringSearchValue2,...
                obj.SearchVar3.selStr, obj.JCBListSelectedStringSearchValue3,...
                obj.SearchVar4.selStr, obj.JCBListSelectedStringSearchValue4,...
                1e-4);

            obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar1.selStr );
            obj.JCBListSelectedStringSearchValue1 = obj.JCBListArraySearchValue1;


            obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
            obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;


            update( obj );

            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchVar1_CB

        function searchVar2_pm_CB( obj , hobj , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            if isempty(obj.SearchVar2.selStr)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end

            obj.JCBListSelectedStringSearchValue2 = [];
            obj.JCBListSelectedStringSearchValue3 = [];
            obj.JCBListSelectedStringSearchValue4 = [];

            avalParam             = get(hobj,'string');
            obj.SearchVar2.selVal = get(hobj,'value');
            obj.SearchVar2.selStr = avalParam{obj.SearchVar2.selVal};

            obj.SearchVar3.selVal = 1; 
            obj.SearchVar3.selStr = obj.SearchVar3.strList{obj.SearchVar3.selVal};

            obj.SearchVar4.selVal = 1; 
            obj.SearchVar4.selStr = obj.SearchVar4.strList{obj.SearchVar4.selVal};    

            [filteredGainColl,~] = searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr,     ( obj.JCBListSelectedStringSearchValue2 ),...
                obj.SearchVar3.selStr,     ( obj.JCBListSelectedStringSearchValue3 ),...
                obj.SearchVar4.selStr,     ( obj.JCBListSelectedStringSearchValue4 ),...
                1e-4);

            obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar1.selStr );
            obj.JCBListSelectedStringSearchValue1 = obj.JCBListArraySearchValue1;


            obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
            obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;


            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchVar2_pm_CB

        function searchVar3_pm_CB( obj , hobj , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            if isempty(obj.SearchVar3.selStr)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end

            obj.JCBListSelectedStringSearchValue3 = [];
            obj.JCBListSelectedStringSearchValue4 = [];

            avalParam             = get(hobj,'string');
            obj.SearchVar3.selVal = get(hobj,'value');
            obj.SearchVar3.selStr = avalParam{obj.SearchVar3.selVal};

            obj.SearchVar4.selVal = 1; 
            obj.SearchVar4.selStr = obj.SearchVar4.strList{obj.SearchVar4.selVal};    

            [filteredGainColl,~] = searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr, cell( obj.JCBListSelectedStringSearchValue2 ),...
                obj.SearchVar3.selStr,     ( obj.JCBListSelectedStringSearchValue3 ),...
                obj.SearchVar4.selStr,     ( obj.JCBListSelectedStringSearchValue4 ),...
                1e-4);

            obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar1.selStr );
            obj.JCBListSelectedStringSearchValue1 = obj.JCBListArraySearchValue1;


            obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
            obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;


            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchVar3_pm_CB

        function searchVar4_pm_CB( obj , hobj , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            if isempty(obj.SearchVar4.selStr)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end


            obj.JCBListSelectedStringSearchValue4 = [];

            avalParam             = get(hobj,'string');
            obj.SearchVar4.selVal = get(hobj,'value');
            obj.SearchVar4.selStr = avalParam{obj.SearchVar4.selVal};


            [filteredGainColl,~] = searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, cell( obj.JCBListSelectedStringSearchValue1 ),...
                obj.SearchVar2.selStr, cell( obj.JCBListSelectedStringSearchValue2 ),...
                obj.SearchVar3.selStr, cell( obj.JCBListSelectedStringSearchValue3 ),...
                obj.SearchVar4.selStr,     ( obj.JCBListSelectedStringSearchValue4 ),...
                1e-4);

            obj.JCBListArraySearchValue1 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar1.selStr );
            obj.JCBListSelectedStringSearchValue1 = obj.JCBListArraySearchValue1;


            obj.JCBListArraySearchValue2 = obj.getAvaliableSelectionsFC( filteredGainColl , obj.SearchVar2.selStr );
            obj.JCBListSelectedStringSearchValue2 = obj.JCBListArraySearchValue2;


            obj.JCBListArraySearchValue3 = obj.getAvaliableSelectionsIC( filteredGainColl , obj.SearchVar3.selStr );
            obj.JCBListSelectedStringSearchValue3 = obj.JCBListArraySearchValue3;


            obj.JCBListArraySearchValue4 = obj.getAvaliableSelectionsWC( filteredGainColl , obj.SearchVar4.selStr );
            obj.JCBListSelectedStringSearchValue4 = obj.JCBListArraySearchValue4;


            update( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % searchVar4_pm_CB

    end
    
    %% Method - Static
    methods ( Static )
        
        
    end
    
    %% Methods - Delete
    methods
        function delete( obj )
            % Java Components 
            obj.JTable = [];
            obj.JScroll = [];
            obj.JTableH = [];
            obj.JHScroll = [];
            obj.HCompSearchValue1_pm = [];
            obj.HCompSearchValue2_pm = [];
            obj.HCompSearchValue3_pm = [];
            obj.HCompSearchValue4_pm = [];
            obj.ScatterGainFilterLabelComp = [];
            
            
            
            
            % Javawrappers 
            % Check if container is already being deleted
            if ishandle(obj.HContainer) && strcmp(get(obj.HContainer, 'BeingDeleted'), 'off')
                delete(obj.HContainer)
            end
            if ishandle(obj.HContSearchValue1_pm) && strcmp(get(obj.HContSearchValue1_pm, 'BeingDeleted'), 'off')
                delete(obj.HContSearchValue1_pm)
            end
            if ishandle(obj.HContSearchValue2_pm) && strcmp(get(obj.HContSearchValue2_pm, 'BeingDeleted'), 'off')
                delete(obj.HContSearchValue2_pm)
            end
            if ishandle(obj.HContSearchValue3_pm) && strcmp(get(obj.HContSearchValue3_pm, 'BeingDeleted'), 'off')
                delete(obj.HContSearchValue3_pm)
            end
            if ishandle(obj.HContSearchValue4_pm) && strcmp(get(obj.HContSearchValue4_pm, 'BeingDeleted'), 'off')
                delete(obj.HContSearchValue4_pm)
            end
            if ishandle(obj.ScatterGainFilterLabelCont) && strcmp(get(obj.ScatterGainFilterLabelCont, 'BeingDeleted'), 'off')
                delete(obj.ScatterGainFilterLabelCont)
            end


            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.FilteredGainColl);
            end
            try %#ok<*TRYNC>             
                delete(obj.ScatteredGainFileObj);
            end


    %          % Matlab Components

            
%         SearchVar1_pm
%         SearchVar2_pm      
%         SearchVar3_pm
%         SearchVar4_pm

    %         % Data
%         JCBListArraySearchValue1 
%         JCBListArraySearchValue2
%         JCBListArraySearchValue3
%         JCBListArraySearchValue4
%         JCBListSelectedStringSearchValue1
%     	JCBListSelectedStringSearchValue2
%     	JCBListSelectedStringSearchValue3
%     	JCBListSelectedStringSearchValue4  

        end % delete
    end
    
end



function defaultColors = constantColors()
%% Colors 
%defaultColors = cell(1,808);
% defaultColors{1}     = [0,255,0];     %lime
% defaultColors{end+1} = [255,0,0];     %red
% defaultColors{end+1} = [255,255,0];   %
% defaultColors{end+1} = [255,0,255];   %magenta
% defaultColors{end+1} = [0,255,255];   %aqua
% defaultColors{end+1} = [0,127,127];   %
% defaultColors{end+1} = [127,127,127]; %
% defaultColors{end+1} = [127,255,127]; %
% 
% for i=1:100
%     defaultColors{end+1} = defaultColors{1}; %#ok<*AGROW>
%     defaultColors{end+1} = defaultColors{2};
%     defaultColors{end+1} = defaultColors{3};
%     defaultColors{end+1} = defaultColors{4};
%     defaultColors{end+1} = defaultColors{5};
%     defaultColors{end+1} = defaultColors{6};
%     defaultColors{end+1} = defaultColors{7};
%     defaultColors{end+1} = defaultColors{8};
% 
% end

    defaultColors{1}     = [ 0 , 114.4320 , 189.6960 ];         % blue
    defaultColors{end+1} = [ 217.6000 ,  83.2000 , 25.0880 ];   % red
    defaultColors{end+1} = [ 237.8240 , 177.6640 , 32.0000 ];   % lime [255 , 255 , 0];   % yellow
    defaultColors{end+1} = [ 126.4640 , 47.1040 , 142.3360 ];   % magenta
    defaultColors{end+1} = [ 119.2960 , 172.5440 , 48.1280 ];   % aqua
    defaultColors{end+1} = [ 77.0560 , 190.7200 , 238.8480 ];   %
    defaultColors{end+1} = [ 162.5600 , 19.9680 , 47.1040 ];    %

    for i=1:20000
        defaultColors{end+1} = [rand(1) , rand(1) , rand(1)] * 255 ; %#ok<*AGROW>
    end
        
end

function z = round2(x,y)

if nargin == 1
    y = 1e-10;
end

z = round(x/y)*y;
z = round(z,5,'significant');
end % round2

function [data,dataNames] = searchScatteredGainsDesignCond(data, fc1, fc1Val, fc2, fc2Val, ic, icVal, wc, wcStr, err)

operConds = [data.DesignOperatingCondition];
if isempty(fc1Val)
    fc1LogInd = true(size(operConds));
else
    fc1Val = str2double(fc1Val);
    fc1LogInd = false(size(operConds));
    for ind = 1:length(fc1Val)
        fc1LogCell{ind} = arrayfun(@(x)all(round2(x.FlightCondition.(fc1),err)==round2(fc1Val(ind),err)),operConds);
        fc1LogInd = or(fc1LogInd,fc1LogCell{ind});
    end
end

if isempty(fc2Val)
    fc2LogInd = true(size(operConds));
else
    fc2Val = str2double(fc2Val);
    fc2LogInd = false(size(operConds));
    for ind = 1:length(fc2Val)
        fc2LogCell{ind} = arrayfun(@(x)all(round2(x.FlightCondition.(fc2),err)==round2(fc2Val(ind),err)),operConds);
        fc2LogInd = or(fc2LogInd,fc2LogCell{ind});
    end
end

if isempty(icVal)
    icLogInd = true(size(operConds));
else
    icVal = str2double(icVal);
    icLogInd = false(size(operConds));
    
    
     if ~isempty(operConds) && ~isempty(operConds(1).Inputs.get(ic)) 
        for ind = 1:length(icVal)
            icLogCell{ind} = arrayfun(@(x)all(round2(x.Inputs.get(ic).Value,err)==round2(icVal(ind),err)),operConds);
            icLogInd = or(icLogInd,icLogCell{ind});
        end
     else
        for ind = 1:length(icVal)
            icLogCell{ind} = arrayfun(@(x)all(round2(x.Outputs.get(ic).Value,err)==round2(icVal(ind),err)),operConds);
            icLogInd = or(icLogInd,icLogCell{ind});
        end
     end
end

if isempty(wcStr) || (iscell(wcStr) && length(wcStr) == 1 && isempty(wcStr{1}))
    wcLogInd = true(size(operConds));
else
    if ischar(wcStr);wcStr = {wcStr};end;
    wcVal = str2double(wcStr);
    wcLogInd = false(size(operConds));
    for ind = 1:length(wcVal)
        if strcmp(wc,'Label') && isnan(wcVal(ind))
            wcLogCell{ind} = arrayfun(@(x)all(strcmp(x.MassProperties.get(wc),wcStr{ind})),operConds);
        elseif strcmp(wc,'Label') && ~isnan(wcVal(ind))
            %wcLogCell{ind} = arrayfun(@(x)all(round2(x.MassProperties.get(wc),err)==round2(wcVal(ind),err)),operConds);
            wcLogCell{ind} = arrayfun(@(x)all(round2(x.MassProperties.get(wc),err)==round2(wcStr{ind},err)),operConds);
        elseif ~isnan(wcVal(ind))
            wcLogCell{ind} = arrayfun(@(x)all(round2(x.MassProperties.get(wc),err)==round2(wcVal(ind),err)),operConds);
            %wcLogInd  =     arrayfun(@(x)all(round2(x.MassProperties.get(wc),err)==round2(wcVal,err)),operConds);
        else
            wcLogCell{ind} = arrayfun(@(x)all(strcmp(x.MassProperties.get(wc),wcStr{ind})),operConds);
            %wcLogInd  =     arrayfun(@(x)all(strcmp(x.MassProperties.get(wc),wcStr)),operConds);
        end 
        wcLogInd = or(wcLogInd,wcLogCell{ind});  
    end
end



matchLogInd = fc1LogInd & fc2LogInd & icLogInd & wcLogInd;
% set data struct to only matching indexes
%data1 = copy(data);

data = data(matchLogInd);

dataNames = [];  


end % searchLinearModels

% function z = round2(x,y)
% 
% % narginchk(2,2)
% % nargoutchk(0,1)
% % if numel(y)>1
% %   error('Y must be scalar')
% % end
% 
% 
% z = round(x/y)*y;
% end

