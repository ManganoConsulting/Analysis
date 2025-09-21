classdef ParameterCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        Container
        ButtonContainer

 
        FullViewButton
        
    
        SelectedTableModel
        SelectedJTable
        SelectedJTableH
        SelectedJScroll
        SelectedJHScroll
        SelectedHContainer
        
        ReInitButton
        
        CurrentSelectedParamter UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
        
    end % Public properties
    
    %% Public properties - Object Handles Full View
    properties (Transient = true)  
        Frame  
        TableModel
        JTable
        JTableH
        JScroll
        AddJButton
        RemoveJButton
        FullParameterTableHeader = {'D','Name','Value','G'}  
        ContextPane
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        Title
        RowSelectedInFull
        AvaliableParameterSelection UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
        ReInitBtnEnable = 'on'
    end % Public properties
    
    %% Properties - Observable
    properties%(SetObservable)
%        CurrentSelectedParamter@UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
%        SelectedParameter@UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
    end
    
    %% Private properties
    properties ( Access = private )       
        PrivatePosition
        PrivateUnits
        PrivateVisible
        PrivateEnable
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
        Enable
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )
        Parameters UserInterface.ControlDesign.Parameter
        ParameterTableFormat
        SelectDisplayParameters
        FullParameterTableData
        SubParameterTableData
    end % Dependant properties
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        GlobalIdentified
        EditButtonPressed
        ReInitButtonPressed
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = ParameterCollection(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','Parameters');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;

            createView( obj , options.Parent );

        end % ParameterCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
               
        function y = get.SelectDisplayParameters( obj ) 
            if isempty(obj.AvaliableParameterSelection)
                y = UserInterface.ControlDesign.Parameter.empty;
            else
                logArray = [obj.AvaliableParameterSelection.Displayed];
                y = obj.AvaliableParameterSelection(logArray);
            end
        end % SelectDisplayParameters - Get
        
        function y = get.FullParameterTableData( obj ) 
            if isempty(obj.AvaliableParameterSelection)
                y = {};%y = {'','','',''};
            else
                y = [num2cell([obj.AvaliableParameterSelection.Displayed])',{obj.AvaliableParameterSelection.Name}',{obj.AvaliableParameterSelection.DisplayString}',num2cell([obj.AvaliableParameterSelection.Global])']; 
            end
        end % FullParameterTableData - Get
        
        function y = get.SubParameterTableData( obj ) 
            if isempty(obj.AvaliableParameterSelection)
                y = {};%y = {'',''};
            else
                selectDisplayParameters = obj.SelectDisplayParameters;
                y = [{selectDisplayParameters.DisplayName}',{selectDisplayParameters.DisplayString}']; 
            end
        end % SubParameterTableData - Get
        
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
        
        function y = get.Parameters( obj )
            y = obj.AvaliableParameterSelection;
        end % Parameters - Get
        
        function y = get.ParameterTableFormat( obj )  
            y = {'char','char'};
        end % ParameterTableFormat - Get
        
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
    
    %% Methods - Selected Parameter View
    methods   
      
        function createView( obj , parent )
            if nargin == 1
                obj.Parent = figure();
            else 
                obj.Parent = parent;
            end
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            updateSelectedTable( obj )
            % Button Container
            obj.ButtonContainer = uicontainer('Parent',obj.Container);
            set(obj.ButtonContainer,'ResizeFcn',@obj.reSizeButtonC);
            obj.FullViewButton = uicontrol(...
                'Parent',obj.ButtonContainer,...
                'Style','push',...
                'String','Edit',...
                'Callback',@obj.launchFullView_CB); 
            obj.ReInitButton = uicontrol(...
                'Parent',obj.ButtonContainer,...
                'Style','push',...
                'String','Re-Initialize Parameters',...
                'Enable',obj.ReInitBtnEnable,...
                'Callback',@obj.reInit_CB); 
            
            % Force resize
            obj.reSize();
            
        end % createView
        
        function updateSelectedTable( obj )

            % Remove Table
            try
                delete(obj.SelectedHContainer);
                drawnow();
            end
            
            obj.SelectedTableModel = javaObjectEDT('javax.swing.table.DefaultTableModel',obj.SubParameterTableData,{'Parameter','Value'});
            obj.SelectedJTable = javaObjectEDT('javax.swing.JTable',obj.SelectedTableModel);
            obj.SelectedJTableH = handle(javaObjectEDT(obj.SelectedJTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.SelectedJScroll = javaObjectEDT('javax.swing.JScrollPane',obj.SelectedJTable);
            [obj.SelectedJHScroll,obj.SelectedHContainer] = javacomponent(obj.SelectedJScroll, [], obj.Container);

            obj.SelectedJScroll.setVerticalScrollBarPolicy(obj.SelectedJScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.SelectedJScroll.setHorizontalScrollBarPolicy(obj.SelectedJScroll.HORIZONTAL_SCROLLBAR_NEVER);%(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            %obj.SelectedJTable.setAutoResizeMode( obj.SelectedJTable.AUTO_RESIZE_OFF );
            obj.SelectedJTable.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
            
            % Set Callbacks

            obj.SelectedJTableH.MousePressedCallback = @obj.mousePressedInSelectedTable;
            SelectedJModelH = handle(obj.SelectedJTable.getModel, 'CallbackProperties');
            SelectedJModelH.TableChangedCallback     = @obj.dataUpdatedInSelectedTable;       


            w1 = 115; column0 = obj.SelectedJTable.getColumnModel().getColumn(0);column0.setPreferredWidth(w1);column0.setMinWidth(w1);%column0.setMaxWidth(w1); 
            w2 = 150;column1 = obj.SelectedJTable.getColumnModel().getColumn(1);column1.setPreferredWidth(w2);column1.setMinWidth(w2);%column1.setMaxWidth(w2); 
            
            nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.
            obj.SelectedJTable.getColumnModel.getColumn(0).setCellEditor(nonEditCR); 
            
            obj.SelectedJTable.setGridColor(java.awt.Color.lightGray);

            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.SelectedJTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.SelectedJTable.repaint;
            obj.SelectedJTable.setVisible(true);

            panelPos = getpixelposition(obj.Container); 
            if ~isempty(obj.Container)
                set(obj.SelectedHContainer,'Units','Pixels','Position',[ 1 , 26 , panelPos(3) - 5 , panelPos(4) - 47 ] ); 
            end
            drawnow();pause(0.1);
            %reSize( obj );
        end % updateSelectedTable
        
    end 
    
    %% Methods - Selected Parameter Callbacks
    methods   
      
        function dataUpdatedInSelectedTable(obj , hModel , hEvent )
            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            switch modifiedCol
               
                case 1 % Value change
                    rowInd = modifiedRow;
                    hSelParam = obj.SelectDisplayParameters(rowInd + 1);
                    hSelParam.ValueString = num2str(hModel.getValueAt(modifiedRow,1));
                    if hSelParam.Global
                        notify(obj,'GlobalIdentified',UserInterface.UserInterfaceEventData(hSelParam));
                    end
            end
        end % dataUpdatedInSelectedTable

        function mousePressedInSelectedTable( obj , hModel , hEvent )

            if ~hEvent.isMetaDown
                rowSelected = hModel.getSelectedRow + 1;

%                     obj.CurrentSelectedRow = rowSelected;

                    if ~isempty(obj.SelectDisplayParameters)
                        obj.CurrentSelectedParamter = obj.SelectDisplayParameters(rowSelected);
                        
                        
%                         obj.CurrentSelectedParamter = obj.SelectDisplayParameters(obj.CurrentSelectedRow);

%                         notify(obj,'ParameterUpdated',UserInterface.UserInterfaceEventData(obj.CurrentSelectedParamter));
% %                         if ~strcmpi(obj.CurrentSelectedParamter.Name,'none')
% %                             notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Slider Parameter changed to: ''',obj.CurrentSelectedParamter.Name,'''.'],'info'));
% %                         else
% %                             notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Slider Not Available.','info'));
% %                         end
                    end
            end
        end % mousePressedInSelectedTable
        
        function launchFullView_CB( obj , ~ , ~ )
%             notify(obj,'EditButtonPressed');
            
            createFullView( obj );
        end % launchFullView_CB 
        
        function reSize( obj , ~ , ~ ) 
            try 
                panelPos = getpixelposition(obj.Container); 
                set(obj.ButtonContainer,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) - 5 , 25 ] );  
                set(obj.SelectedHContainer,'Units','Pixels','Position',[ 1 , 26 , panelPos(3) - 5 , panelPos(4) - 60 ] ); 
            end
        end %reSize
        
        function reSizeButtonC( obj , ~ , ~ )
            try
                panelPos = getpixelposition(obj.ButtonContainer); 
                set(obj.FullViewButton,'Units','Pixels','Position',[ 1 , 1 , panelPos(3)/2 , panelPos(4) ] ); 
                set(obj.ReInitButton,'Units','Pixels','Position',[ panelPos(3)/2 , 1 , panelPos(3)/2 , panelPos(4) ] ); 
            end
        end %reSizeButtonC
        
        function reInit_CB( obj , ~ , ~ )
            notify(obj,'ReInitButtonPressed');%,UserInterface.UserInterfaceEventData(obj.Title));
%             obj.ReInit = hobj.Value;
        end % reInit_CB 
        
    end 
    
    %% Methods - Shared Callbacks
    methods   
        
    end 
    
    %% Methods - Full Parameter View
    methods   

        function createFullView( obj )
         
            import javax.swing.*;
            %import java.awt.BorderLayout.*;
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );  
              
            if ~isempty(obj.Frame) && isvalid(obj.Frame)
                return;
            end
            
            obj.Frame  = figure('Name',obj.Title,...
                                    'units','pixels',...
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...%'WindowStyle','modal',...'Resize','off',...
                                    'CloseRequestFcn', @obj.closeFullView);
                                
            obj.ContextPane = javaObjectEDT('javax.swing.JPanel');
            obj.ContextPane.setLayout(java.awt.GridBagLayout);%obj.ContextPane.setLayout([]);
            pane = obj.ContextPane;
            %pane.setComponentOrientation(java.awt.ComponentOrientation.RIGHT_TO_LEFT);
	
%             GBagC = java.awt.GridBagConstraints();
    
            % Add title h
            labelStr = ['<html><font color="white" face="Courier New">&nbsp;',obj.Title,' Parameters</html>'];
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            %pane.add(jLabelview , java.awt.BorderLayout.PAGE_START);%pane.add(jLabelview);
            %jLabelview.setBounds(0,0,330,16);
            
            GBagC = java.awt.GridBagConstraints();
            GBagC.fill = java.awt.GridBagConstraints.HORIZONTAL;
            GBagC.ipadx = 0; 
            GBagC.ipady = 0;  
            GBagC.weightx = 0.0;   
            GBagC.weighty = 0.0;   
            GBagC.anchor = java.awt.GridBagConstraints.PAGE_START; 
        % 	GBagC.insets = java.awt.Insets(10,0,0,0); 
            GBagC.gridx = 0;  
            GBagC.gridy = 0; 
            GBagC.gridheight = 1;   
            GBagC.gridwidth = 2;  	  
            pane.add(jLabelview, GBagC);
            
            
                        
            % Create Parameter Table
            updateFullViewTable( obj )
            
            
            % Add Button             
            addJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            addJButton.setText('New');        
            addJButtonH = handle(addJButton,'CallbackProperties');
            set(addJButtonH, 'ActionPerformedCallback',@obj.addParameter)
            myIcon = fullfile(icon_dir,'New_24.png');
            addJButton.setIcon(javax.swing.ImageIcon(myIcon));
            addJButton.setToolTipText('Add New Item');
            addJButton.setFlyOverAppearance(true);
            addJButton.setBorder([]);
            addJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            addJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            addJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            %addJButton.setPreferredSize(java.awt.Dimension(10, 125));
            %pane.add(addJButton);
            %addJButton.setBounds(10,385,125,30);
            obj.AddJButton = addJButton;
            
            GBagC = java.awt.GridBagConstraints();
            GBagC.fill = java.awt.GridBagConstraints.BOTH;
            GBagC.ipadx = 0; 
            GBagC.ipady = 0;  
            GBagC.weightx = 1.0;   
            GBagC.weighty = 0.001;   
        % 	GBagC.anchor = java.awt.GridBagConstraints.PAGE_END; 
        % 	GBagC.insets = java.awt.Insets(10,0,0,0); 
            GBagC.gridx = 0;  
            GBagC.gridy = 2; 
            GBagC.gridheight = 1;   
            GBagC.gridwidth = 1;  	  
            pane.add(addJButton, GBagC);
            
            
            % Remove Button             
            removeJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            removeJButton.setText('Remove');        
            removeJButtonH = handle(removeJButton,'CallbackProperties');
            set(removeJButtonH, 'ActionPerformedCallback',@obj.removeParameter)
            myIcon = fullfile(icon_dir,'StopX_24.png');
            removeJButton.setIcon(javax.swing.ImageIcon(myIcon));
            removeJButton.setToolTipText('Add New Item');
            removeJButton.setFlyOverAppearance(true);
            removeJButton.setBorder([]);
            %removeJButton.setVisible(false);
            removeJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            removeJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            removeJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            %pane.add(removeJButton);
            %removeJButton.setBounds(150,385,125,30);
            obj.RemoveJButton = removeJButton;
             
            GBagC = java.awt.GridBagConstraints();
            GBagC.fill = java.awt.GridBagConstraints.BOTH;
            GBagC.ipadx = 0; 
            GBagC.ipady = 0;  
            GBagC.weightx = 1.0;   
            GBagC.weighty = 0.001;   
        % 	GBagC.anchor = java.awt.GridBagConstraints.PAGE_END; 
        % 	GBagC.insets = java.awt.Insets(10,0,0,0); 
            GBagC.gridx = 1;  
            GBagC.gridy = 2; 
            GBagC.gridheight = 1;   
            GBagC.gridwidth = 1;  	  
            pane.add(removeJButton, GBagC);
                       
            % Resize and reposition the window
            width = 300;
            height = 465;
            pos = getpixelposition(obj.Frame);
            obj.Frame.Position = [ pos(1) , pos(2) , width , height ];
            [CPComp,CPCont] = javacomponent(obj.ContextPane,[ 0 , 0 , width , height ], obj.Frame );
            set(CPCont,'Units','Normal');
            set(CPCont,'Position',[0,0,1,1]);
            obj.ContextPane.setVisible(true);

        end % createFullView
        
        function updateFullViewTable( obj )

            % Remove Table
            if ~isempty(obj.JScroll)
                obj.ContextPane.remove(obj.JScroll); %remove component from your jpanel in this case i used jpanel 
                obj.ContextPane.revalidate(); 
                obj.ContextPane.repaint();%repaint a JFrame jframe in this case 
            end

            
            obj.TableModel = javaObjectEDT('javax.swing.table.DefaultTableModel',obj.FullParameterTableData,obj.FullParameterTableHeader);
            obj.JTable = javaObjectEDT('javax.swing.JTable',obj.TableModel);
            obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.JScroll = javaObjectEDT('javax.swing.JScrollPane',obj.JTable);
            %obj.JScroll.setPreferredSize(java.awt.Dimension(25, 10));
            %obj.ContextPane.add(obj.JScroll);
            %obj.JScroll.setBounds(10,25,280,350);

            GBagC = java.awt.GridBagConstraints();
            GBagC.fill = java.awt.GridBagConstraints.BOTH;
            GBagC.ipadx = 0; 
            GBagC.ipady = 0;  
            GBagC.weightx = 1.0;   
            GBagC.weighty = 1.0;   
            %GBagC.anchor = java.awt.GridBagConstraints.PAGE_START; 
            GBagC.insets = java.awt.Insets(10,0,0,0); 
            GBagC.gridx = 0;  
            GBagC.gridy = 1; 
            GBagC.gridheight = 1;   
            GBagC.gridwidth = 2;  	  
            obj.ContextPane.add(obj.JScroll, GBagC);
            
            
            
            obj.JScroll.setVerticalScrollBarPolicy(obj.JScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.JScroll.setHorizontalScrollBarPolicy(obj.JScroll.HORIZONTAL_SCROLLBAR_NEVER);
            %obj.JTable.setAutoResizeMode( obj.JTable.AUTO_RESIZE_OFF );
            obj.JTable.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
            
            % Set Callbacks
            obj.JTableH.MousePressedCallback = @obj.mousePressedInFullTable;
            JModelH = handle(obj.JTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = @obj.dataUpdatedInFullTable; 
            

            w1 = 20; column0 = obj.JTable.getColumnModel().getColumn(0);column0.setPreferredWidth(w1);column0.setMinWidth(w1);column0.setMaxWidth(w1); 
            w2 = 100;column1 = obj.JTable.getColumnModel().getColumn(1);column1.setPreferredWidth(w2);column1.setMinWidth(w2);%column1.setMaxWidth(w2); 
            w3 = 120;column2 = obj.JTable.getColumnModel().getColumn(2);column2.setPreferredWidth(w3);column2.setMinWidth(w3);%column2.setMaxWidth(w3); 
            w4 = 60; column3 = obj.JTable.getColumnModel().getColumn(3);column3.setPreferredWidth(20);column3.setMinWidth(20);column3.setMaxWidth(60); 

            % Set Cell Renderer
            obj.JTable.getColumnModel.getColumn(0).setCellRenderer(com.jidesoft.grid.BooleanCheckBoxCellRenderer); 
            obj.JTable.getColumnModel.getColumn(0).setCellEditor(com.jidesoft.grid.BooleanCheckBoxCellEditor); 
            
            nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.
            obj.JTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR); 

            obj.JTable.getColumnModel.getColumn(3).setCellRenderer(com.jidesoft.grid.BooleanCheckBoxCellRenderer); 
            obj.JTable.getColumnModel.getColumn(3).setCellEditor(com.jidesoft.grid.BooleanCheckBoxCellEditor); 
             

            
            obj.JTable.setGridColor(java.awt.Color.lightGray);    

            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.JTable.repaint;
            obj.JTable.setVisible(true);
            obj.ContextPane.repaint;
            obj.ContextPane.revalidate();
            drawnow();pause(0.1);

        end % updateFullViewTable
        
    end 
    
    %% Methods - Full Parameter Callbacks
    methods  
        
        function mousePressedInFullTable( obj , hModel , hEvent )
            if ~hEvent.isMetaDown
                rowSelected = hModel.getSelectedRow + 1;
                obj.RowSelectedInFull = rowSelected;

                if obj.AvaliableParameterSelection(obj.RowSelectedInFull).UserDefined
                    obj.RemoveJButton.setVisible(true);
                else
                    obj.RemoveJButton.setVisible(false);
                end
            end
        end % mousePressedInFullTable
        
        function dataUpdatedInFullTable( obj , hModel , hEvent ) 

            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            
            initState = obj.AvaliableParameterSelection(modifiedRow + 1).Global;
            
            switch modifiedCol
                case 0 
                    obj.AvaliableParameterSelection(modifiedRow + 1).Displayed   = hModel.getValueAt(modifiedRow,modifiedCol);
                case 2
                    obj.AvaliableParameterSelection(modifiedRow + 1).ValueString = hModel.getValueAt(modifiedRow,modifiedCol);
                case 3
                    obj.AvaliableParameterSelection(modifiedRow + 1).Global = hModel.getValueAt(modifiedRow,modifiedCol);
            end
            
            if obj.AvaliableParameterSelection(modifiedRow + 1).Global || initState
                notify(obj,'GlobalIdentified',UserInterface.UserInterfaceEventData(obj.AvaliableParameterSelection(modifiedRow + 1)));
            
            end
        end % dataUpdatedInFullTable
        
        function addParameter( obj , ~ , ~ )
            prompt = {'Name:','Default Value:'};
            dlg_title = 'Input';
            num_lines = 1;
            defaultans = {'parameter','1'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,struct('WindowStyle','modal'));
            drawnow();pause(0.5);
            
            if ~isempty(answer)
                if any(strcmp(answer{1},{obj.AvaliableParameterSelection.Name}))
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['A parameter named ''',answer{1},''' already exists. Choose a unique name.'],'warn'));
                    return;
                end
                obj.AvaliableParameterSelection( end + 1 , 1 ) = UserInterface.ControlDesign.Parameter('Name',answer{1},'String',answer{2},'UserDefined',true);
                obj.AvaliableParameterSelection = sort(obj.AvaliableParameterSelection);
            end
            
            updateFullViewTable(obj);
        end % addParameter
        
        function removeParameter( obj , ~ , ~ )
            if ~isempty(obj.RowSelectedInFull)
                if length(obj.AvaliableParameterSelection) > 1
                    obj.AvaliableParameterSelection(obj.RowSelectedInFull) = [];
                elseif length(obj.AvaliableParameterSelection) == 1 && obj.RowSelectedInFull == 1
                    obj.AvaliableParameterSelection = UserInterface.ControlDesign.Parameter.empty;
                end
                obj.RemoveJButton.setVisible(false);
                updateFullViewTable(obj);
            end
            
        end % removeParameter
        
        function closeFullView( obj , ~ , ~ )
%             % Remove Java Object refs
%             obj.TableModel = [];
%             obj.JTable = [];
%             obj.JTableH = [];
%             obj.JScroll = [];
%             obj.AddJButton = [];
%             obj.RemoveJButton = [];
%             obj.ContextPane = [];
            
            
            
            
            delete(obj.Frame);%obj.Frame.dispose();
            obj.RowSelectedInFull = [];
            updateSelectedTable( obj );
        end % closeFullView 
        
    end
    
    %% Methods - Ordinary
    methods     

        function globalParamModified( obj , newGlobal )
            % This function is called when a global parameter changes in a
            % different ParameterCollection object.
                for i = 1:length(newGlobal)
                    logArray = strcmp(newGlobal(i).Name , {obj.AvaliableParameterSelection.Name});
                    if newGlobal(i).Global
                        obj.AvaliableParameterSelection(logArray) = [];
                        obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;newGlobal(i)]);
                    else
                        obj.AvaliableParameterSelection(logArray) = [];
                    end 
                end
            updateSelectedTable( obj );
            
        end % globalParamModified
                    
        function add2AvaliableParameters( obj , parameters )       
            [~,~,ib] = setxor({obj.AvaliableParameterSelection.Name},{parameters.Name});
       
            if iscolumn(parameters(ib))
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)]);
            else
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)']);
            end
            if isempty(parameters(ib))
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('No new parameters added.','info'));
            else
                params = parameters(ib);
                for i = 1:length(params)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Adding Parameter - ',parameters(i).Name],'info'));
                end
            end
            updateSelectedTable( obj );
        end % add2AvaliableParameters
        
        function updateDefaultParameters( obj , parameters, reInit )  
            
            if nargin == 2
                reInit = false;
            end
            

            
            % parameters - parmeters found in constant file
            
            % Do not add user defined
            defParamsAdd = obj.AvaliableParameterSelection(~([obj.AvaliableParameterSelection.UserDefined]));
        
            userParams = obj.AvaliableParameterSelection(([obj.AvaliableParameterSelection.UserDefined]));
            
            
            
            
            if reInit
                userDef_la = [obj.AvaliableParameterSelection.UserDefined];
                keep_params = userDef_la;
                if all(~keep_params) % if all are removed
                    obj.AvaliableParameterSelection = UserInterface.ControlDesign.Parameter.empty;
                else
                    obj.AvaliableParameterSelection(~keep_params) = [];
                end
            end
            
            
            
            
            
            A = {defParamsAdd.Name};
            B = {parameters.Name};
            [~,~,ib] = setxor(A,B); 

            % Add new parameters if they now exist in the constants file          
            if iscolumn(parameters(ib))
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)]);
            else
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)']);
            end
            if isempty(parameters(ib))
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('No new parameters added.','info'));
            else
                params = parameters(ib);
                for i = 1:length(params)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Adding Parameter - ',parameters(i).Name],'info'));
                end
            end
            
            
            
            % Do not remove user defined or global parameters
            defParamsRem = obj.AvaliableParameterSelection(~([obj.AvaliableParameterSelection.UserDefined] | [obj.AvaliableParameterSelection.Global]));
            A = {defParamsRem.Name};
            B = {parameters.Name};
            [~,ia,~] = setxor(A,B);
            
            paramNotRemoved = obj.AvaliableParameterSelection((~[obj.AvaliableParameterSelection.UserDefined] & [obj.AvaliableParameterSelection.Global]));
            for i = 1:length(paramNotRemoved)
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData([paramNotRemoved(i).Name,' - is Global and will not be removed.'],'info'));    
            end 
            
            % Remove parameters if they have been deleted from the
            % constants file
            % Add new parameters if they now exist in the constants file 
            
            [~,~,irem] = intersect({defParamsRem(ia).Name},{obj.AvaliableParameterSelection.Name});
            
            removeParam = obj.AvaliableParameterSelection(irem);
            
            obj.AvaliableParameterSelection(irem) = [];
            for i = 1:length(removeParam)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Removing Parameter - ',removeParam(i).Name],'info'));    
            end  


            % Removing duplicates that are not user defined
            isUserDefined = [obj.AvaliableParameterSelection.UserDefined];
            
            [uniqueNames,~,X] = unique({obj.AvaliableParameterSelection.Name});
            Y = histc(X,unique(X));
            isDup = Y>1;
            
            y = zeros(1,length(obj.AvaliableParameterSelection));
            for i = 1:length(obj.AvaliableParameterSelection)
                m = find(ismember( uniqueNames, obj.AvaliableParameterSelection(i).Name));
                if isDup(m)
                    y(i) = 1;
                end
            end
            
            % is userdefined and a duplicate
            remLarray = y & isUserDefined;
            obj.AvaliableParameterSelection(remLarray) = [];
            
            % Update table
            updateSelectedTable( obj );
        end % updateDefaultParameters
        
        function updateSelectedParameter2Default( obj , parameters )  
            
            if isempty(obj.CurrentSelectedParamter)
                return;
            end
            
            
            paramUpdated = obj.CurrentSelectedParamter.Name;
            
            
            defaultParamLA = strcmp(paramUpdated,{parameters.Name});
            
            defaultParam = parameters(defaultParamLA);
            if length(defaultParam) > 1
                defaultParam = defaultParam(1);
            end
            
            
            obj.CurrentSelectedParamter.Value = defaultParam.Value;
            
            updateSelectedTable(obj);
            
        end % updateSelectedParameter2Default
        
        function updateSelectedParameter2DefaultGlobal( obj , parameters, selParam )  
            
            if isempty(selParam)
                return;
            end
            
            currentParamLA = strcmp(selParam.Name,{obj.AvaliableParameterSelection.Name});
            currentParam = obj.AvaliableParameterSelection(currentParamLA);
            if length(currentParam) > 1
                currentParam = currentParam(1);
            end
          
            
            defaultParamLA = strcmp(currentParam.Name,{parameters.Name}); 
            defaultParam = parameters(defaultParamLA);
            if length(defaultParam) > 1
                defaultParam = defaultParam(1);
            end
            
            if ~ischar(defaultParam.Value)
                currentParam.Value = defaultParam.Value;
            else
                currentParam.Value = defaultParam.ValueString;
            end
            
%             updateSelectedTable(obj);
            
        end % updateSelectedParameter2DefaultGlobal
        
        function updateDefaultParametersBatch( obj , parameters )  
            
            % Do not add user defined
            defParamsAdd = obj.AvaliableParameterSelection(~([obj.AvaliableParameterSelection.UserDefined]));
        
            
            A = {defParamsAdd.Name};
            B = {parameters.Name};
            [~,~,ib] = setxor(A,B); 

            % Add new parameters if they now exist in the constants file          
            if iscolumn(parameters(ib))
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)]);
            else
                obj.AvaliableParameterSelection = sort([obj.AvaliableParameterSelection;parameters(ib)']);
            end
            if isempty(parameters(ib))
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('No new parameters added.','info'));
            else
                params = parameters(ib);
                for i = 1:length(params)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Adding Parameter - ',parameters(i).Name],'info'));
                end
            end
            
            
            % Do not remove user defined or global parameters
            defParamsRem = obj.AvaliableParameterSelection(~([obj.AvaliableParameterSelection.UserDefined] | [obj.AvaliableParameterSelection.Global]));
            A = {defParamsRem.Name};
            B = {parameters.Name};
            [~,ia,~] = setxor(A,B);
            
            paramNotRemoved = obj.AvaliableParameterSelection((~[obj.AvaliableParameterSelection.UserDefined] & [obj.AvaliableParameterSelection.Global]));
            for i = 1:length(paramNotRemoved)
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData([paramNotRemoved(i).Name,' - is Global and will not be removed.'],'info'));    
            end 
            
            % Remove parameters if they have been deleted from the
            % constants file
            % Add new parameters if they now exist in the constants file 
            
            [~,~,irem] = intersect({defParamsRem(ia).Name},{obj.AvaliableParameterSelection.Name});
            
            removeParam = obj.AvaliableParameterSelection(irem);
            
            obj.AvaliableParameterSelection(irem) = [];
            for i = 1:length(removeParam)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Removing Parameter - ',removeParam(i).Name],'info'));    
            end        
            
        end % updateDefaultParametersBatch
                  
        function y = getValue( obj , name )
            ind = strcmp(name,{obj.AvaliableParameterSelection.Name});
            if any(ind)
                y = obj.AvaliableParameterSelection(ind).Value;
            else 
                y = [];
            end
        end % getValue
        
        function reInitParams( obj ) 
            
%             choice = questdlg('Are you sure you want to Re-Initialize the parameters?', ...
%                     'ReInitialize Parameters...', ...
%                     'Yes','No','Cancel','Cancel');
%                 drawnow();pause(0.5);
%                  % Handle response
%                 switch choice
%                     case 'Yes'
%                         userDef_la = [obj.AvaliableParameterSelection.UserDefined];
%                         keep_params = userDef_la;
%                         if all(~keep_params) % if all are removed
%                             obj.AvaliableParameterSelection = UserInterface.ControlDesign.Parameter.empty;
%                         else
%                             obj.AvaliableParameterSelection(~keep_params) = [];
%                         end
%                     case 'No'
%                         % Do nothing
%                     otherwise
%                         % Do nothing
%                 end
        end % reInitParams

    end % Ordinary Methods
    
    %% Methods - Slider
    methods   
        
        function updateCurrentSelectedParameter( obj , value )
%             if ~isempty(obj.CurrentSelectedParamter)
%                 % is passed as a handle to the slider so the value gets
%                 % updated outside of this function
%                 obj.SelectDisplayParameters(obj.CurrentSelectedRow) = obj.CurrentSelectedParamter;
%                 updateSelectedTable( obj );
%             end
        end % updateCurrentSelectedParameter 
       
        function defaultMinMax( obj )
%             testNum = str2double(obj.CurrentSelectedParamter.ValueString);
%             if isnan(testNum)
%                 obj.CurrentSelectedParamter.Max = 1;
%                 obj.CurrentSelectedParamter.Min = 0;     
%             else
%                 value = obj.CurrentSelectedParamter.Value;
%                 if value == 0  
%                     obj.CurrentSelectedParamter.Max = 1;
%                     obj.CurrentSelectedParamter.Min = -1;  
%                 else
%                     obj.CurrentSelectedParamter.Max = value + (abs(value) * 0.5);
%                     obj.CurrentSelectedParamter.Min = value - (abs(value) * 0.5);   
%                 end
%             end
%             
        end % defaultMinMax 
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function enablePanel( obj , value )
            if value
                set(obj.FullViewButton,'Enable','on');
%                 set(obj.ReInitButton,'Enable','on');
                editCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
                obj.SelectedJTable.getColumnModel.getColumn(1).setCellEditor(editCR);
                obj.SelectedJTable.repaint;  

            else
              	set(obj.FullViewButton,'Enable','off');
%                 set(obj.ReInitButton,'Enable','off');
                nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
                nonEditCR.setClickCountToStart(intmax); % =never.
                obj.SelectedJTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR);
                obj.SelectedJTable.repaint;
                
                
      
                
            end
            
        end % enablePanel
    end
    
    %% Methods - Protected
    methods (Access = protected)  
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the AvaliableParameterSelection object
            cpObj.AvaliableParameterSelection = copy(obj.AvaliableParameterSelection);
        end % copyElement
  
    end
    
    %% Methods - Delete
    methods
        function delete_GUI_Only( obj )
            % Java Components 
            try
            obj.SelectedTableModel = [];
            obj.SelectedJTable = [];
            obj.SelectedJTableH = [];
            obj.SelectedJScroll = [];
            obj.SelectedJHScroll = [];
            end
            
            try
            obj.TableModel = [];
            obj.JTable = [];
            obj.JTableH = [];
            obj.JScroll = [];
            end
            try
            obj.AddJButton = [];
            obj.RemoveJButton = [];
            end
            try
            obj.ContextPane = [];
            end


            % Javawrappers
            try
                % Check if container is already being deleted
                if ~isempty(obj.SelectedHContainer) && ishandle(obj.SelectedHContainer) && strcmp(get(obj.SelectedHContainer, 'BeingDeleted'), 'off')
                    delete(obj.SelectedHContainer)
                end
            end


            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.ButtonContainer);
            end


    %          % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.ButtonContainer);
            end
            try %#ok<*TRYNC>             
                delete(obj.FullViewButton);
                delete(obj.ReInitButton);
            end
            try %#ok<*TRYNC>             
                delete(obj.Frame);
            end
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
 
  
        end % delete_GUI_Only
    end
    
%     %% Methods - Delete
%     methods
%         function delete( obj )
%             % Java Components 
%             obj.SelectedTableModel = [];
%             obj.SelectedJTable = [];
%             obj.SelectedJTableH = [];
%             obj.SelectedJScroll = [];
%             obj.SelectedJHScroll = [];
%             obj.TableModel = [];
%             obj.JTable = [];
%             obj.JTableH = [];
%             obj.JScroll = [];
%             obj.AddJButton = [];
%             obj.RemoveJButton = [];
%             obj.ContextPane = [];
% 
% 
%             % Javawrappers
%             % Check if container is already being deleted
%             if ~isempty(obj.SelectedHContainer) && ishandle(obj.SelectedHContainer) && strcmp(get(obj.SelectedHContainer, 'BeingDeleted'), 'off')
%                 delete(obj.SelectedHContainer)
%             end
% 
% 
% 
%             % User Defined Objects
%             try %#ok<*TRYNC>             
%                 delete(obj.ButtonContainer);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.AvaliableParameterSelection);
%             end
% 
% 
%     %          % Matlab Components
%             try %#ok<*TRYNC>             
%                 delete(obj.ButtonContainer);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.FullViewButton);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.Frame);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.Container);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.Parent);
%             end      
% 
%     %         % Data
%     %         obj.FullParameterTableHeader
%     %         obj.Title
%     %         obj.RowSelectedInFull
%     %         obj.PrivatePosition
%     %         obj.PrivateUnits
%     %         obj.PrivateVisible
%   
%         end % delete
%     end
    
end



