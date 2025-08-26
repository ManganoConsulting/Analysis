classdef TrimEditor < UserInterface.ObjectEditor.Editor
    %% Public properties - Graphics Handles
    properties (Transient = true)
        LabelText
        LabelEditBox
        NumOfTrimText
        NumOfTrimComboBox
        
        TabPanel
        Tab1
        Tab2

        
        InputsText1
        Input1Table
        AddInputsPushButton1
        RemoveInputsPushButton1
        
        OutputsText1
        Output1Table
        AddOutputsPushButton1
        RemoveOutputsPushButton1
        
        StatesText1
        State1Table
        AddStatesPushButton1
        RemoveStatesPushButton1
        
        StateDerivsText1
        StateDerivs1Table
        AddStateDerivsPushButton1
        RemoveStateDerivsPushButton1
        
        InputsText2
        Input2Table
        AddInputsPushButton2
        RemoveInputsPushButton2
        
        OutputsText2
        Output2Table
        AddOutputsPushButton2
        RemoveOutputsPushButton2
        
        StatesText2
        State2Table
        AddStatesPushButton2
        RemoveStatesPushButton2
        
        StateDerivsText2
        StateDerivs2Table
        AddStateDerivsPushButton2
        RemoveStateDerivsPushButton2
        
        ModelText
        ModelEditBox
        ModelPushButton
        
        GearVarText
        GearVarComboBox
        FlapVarText
        FlapVarComboBox
    end % Public properties
  
    %% Public properties - Data Storage
    properties
        TrimLabelString = char.empty
        NumOfTrimSelectionString = {'1','2'}
        NumOfTrimSelectionValue  = 1
        
        Input1TableData
        Output1TableData
        State1TableData
        StateDerivs1TableData
        
        Input2TableData
        Output2TableData
        State2TableData
        StateDerivs2TableData
        
        ModelName
        
        %StartDirectory = pwd;%mfilename('fullpath')
        
        InputConditions = lacm.Condition.empty
        OutputConditions = lacm.Condition.empty
        StateConditions = lacm.Condition.empty
        StateDerivConditions = lacm.Condition.empty
        
        SelectedTrimDef
        
        
        GearVariableSelectionString = {''}
        GearVariableSelectionValue = 1
        FlapVariableSelectionString = {''}
        FlapVariableSelectionValue = 1
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        NumOfTrims
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  
    
    %% Events
    events

    end % Events
    
    %% Methods - Constructor
    methods      
        
        function obj = TrimEditor(varargin)  
            obj@UserInterface.ObjectEditor.Editor(varargin{:}); 
            %createView( obj , obj.Parent );
        end % TrimEditor
    end % TrimEditor
    
    %% Methods - Property Access
    methods
        function y = get.NumOfTrims( obj )
            y = str2double(obj.NumOfTrimSelectionString{obj.NumOfTrimSelectionValue});
        end % NumOfTrims
    end % Property access methods
    
    %% Methods - View
    methods
        
        function createView( obj , parent )  
            createView@UserInterface.ObjectEditor.Editor( obj , parent );
            
            fig = ancestor(parent,'figure','toplevel') ;
            fig.MenuBar = 'None';
            fig.NumberTitle = 'off';
            position = fig.Position;
            fig.Position = [ position(1) , position(2) - 200 , 487 , 615 ];
            
            obj.ModelText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Simulink Model:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.ModelEditBox = uicontrol('Parent',obj.MainPanel,...
                'Style','edit',...
                'FontSize',10,...
                'String',obj.ModelName,...
                'ForegroundColor',[0 0 0],...
                'Enable','Inactive',...
                'HorizontalAlignment','Left');  
            obj.ModelPushButton = uicontrol('Parent',obj.MainPanel,...
                'Style','push',...
                'FontSize',10,...
                'String','Browse',...
                'ForegroundColor',[0 0 0],...
                'Callback',@obj.browseModel);  
            
            obj.LabelText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Trim Label:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.LabelEditBox = uicontrol('Parent',obj.MainPanel,...
                'Style','edit',...
                'FontSize',10,...
                'String',obj.TrimLabelString,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left',...
                'Callback',@obj.labelTextEditBox_CB);
            
            obj.NumOfTrimText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','# of Trims:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.NumOfTrimComboBox = uicontrol('Parent',obj.MainPanel,...
                'Style','popup',...
                'FontSize',10,...
                'String',obj.NumOfTrimSelectionString,...
                'Value',obj.NumOfTrimSelectionValue,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','center',...
                'Callback',@obj.numOfTrimComboBox_CB);    
            
            obj.GearVarText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Select Gear Variable:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.GearVarComboBox = uicontrol('Parent',obj.MainPanel,...
                'Style','popup',...
                'FontSize',10,...
                'String',obj.GearVariableSelectionString,...
                'Value',obj.GearVariableSelectionValue,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','center',...
                'Callback',@obj.gearVarComboBox_CB);         
            
            obj.FlapVarText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Select Flap Variable:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.FlapVarComboBox = uicontrol('Parent',obj.MainPanel,...
                'Style','popup',...
                'FontSize',10,...
                'String',obj.FlapVariableSelectionString,...
                'Value',obj.FlapVariableSelectionValue,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','center',...
                'Callback',@obj.flapVarComboBox_CB);    
            
            
            obj.TabPanel = uitabgroup('Parent',obj.MainPanel);
%             obj.TabPanel.SelectionChangedFcn = @obj.tabPanel_CB;
%             
%             jTabGroup = getappdata(handle(obj.TabPanel),'JTabbedPane');
            
            %drawnow;

            obj.Tab1       = uitab('Parent',obj.TabPanel);
            obj.Tab1.Title = 'Trim 1';
            obj.Tab2       = uitab('Parent',obj.TabPanel);
            obj.Tab2.Title = 'Trim 2';
                   
            

            createTab1( obj , obj.Tab1 ); 
            
            createTab2( obj , obj.Tab2 ); 
                             
            reSize( obj );
            update(obj);
        end % createView
        
        function createTab1( obj , parent )
            
            
            
            
            obj.InputsText1 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Inputs (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Input1Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.Input1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.inputTable1_ce_CB,...
                'CellSelectionCallback', @obj.inputTable1_cs_CB); 
            
%             obj.AddInputsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'Input1TableData'}); 
%             
%             obj.RemoveInputsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'Input1TableData'});  
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText1 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Outputs (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Output1Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.Output1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.outputTable1_ce_CB,...
                'CellSelectionCallback', @obj.outputTable1_cs_CB);           
            
%             obj.AddOutputsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'Output1TableData'}); 
%             
%             obj.RemoveOutputsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'Output1TableData'});
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText1 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','States (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.State1Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.State1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateTable1_ce_CB,...
                'CellSelectionCallback', @obj.stateTable1_cs_CB);            

            
%             obj.AddStatesPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'State1TableData'}); 
%             
%             obj.RemoveStatesPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'State1TableData'}); 
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText1 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','State Derivatives (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.StateDerivs1Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.StateDerivs1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateDerivsTable1_ce_CB,...
                'CellSelectionCallback', @obj.stateDerivsTable1_cs_CB); 

            
%             obj.AddStateDerivsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'StateDerivs1TableData'}); 
%             
%             obj.RemoveStateDerivsPushButton1 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'StateDerivs1TableData'});   

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          



            

        end % createTab1
        
        function createTab2( obj , parent )
            
            
            
            
            obj.InputsText2 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Inputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Input2Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.Input2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.inputTable2_ce_CB,...
                'CellSelectionCallback', @obj.inputTable2_cs_CB); 
            
%             obj.AddInputsPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'Input2TableData'}); 
%             
%             obj.RemoveInputsPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'Input2TableData'});  
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText2 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Outputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Output2Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.Output2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.outputTable2_ce_CB,...
                'CellSelectionCallback', @obj.outputTable2_cs_CB);           
            
%             obj.AddOutputsPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'Output2TableData'}); 
%             
%             obj.RemoveOutputsPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'Output2TableData'});
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText2 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','States',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.State2Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.State2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateTable2_ce_CB,...
                'CellSelectionCallback', @obj.stateTable2_cs_CB);            

            
%             obj.AddStatesPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Add',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.addRow , 'State2TableData'}); 
%             
%             obj.RemoveStatesPushButton2 = uicontrol('Parent',parent,...
%                 'Style','push',...
%                 'FontSize',10,...
%                 'String','Remove',...
%                 'ForegroundColor',[0 0 0],...
%                 'Callback',{@obj.removeRow , 'State2TableData'}); 
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText2 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','State Derivatives',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.StateDerivs2Table = uitable(parent,...
                'ColumnName',{'Variable','Value','Fix','BasicMode'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,80},...
                'Data',obj.StateDerivs2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateDerivsTable2_ce_CB,...
                'CellSelectionCallback', @obj.stateDerivsTable2_cs_CB); 
          
        end % createTab2
        
    end
   
    %% Methods - Ordinary
    methods 
        
        function loadExisting( obj , loadedTrim , filename )
            
            if ~isa(loadedTrim,'lacm.TrimSettings')
                error('Selected File must be of class "lacm.TrimSettings"');
            end  

            obj.TrimLabelString = loadedTrim.Label;
            obj.SelectedTrimDef = loadedTrim;
            obj.ModelName = loadedTrim.SimulinkModelName;
            if isempty(obj.SelectedTrimDef.InitialTrim)
                obj.NumOfTrimSelectionValue = 1;
            else
                obj.NumOfTrimSelectionValue = 2;
            end
            obj.FileName = filename;
            obj.Saved = true;
            update( obj );
        end % loadExisting        
        
        function updateModelName( obj )
            update(obj);
        end % updateModelName
              
    end % Ordinary Methods
    
    %% Methods - Overloaded Callbacks
    methods (Access = protected) 
        
        function newButton_CB( obj , hobj , ~ )

            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            switch class(obj.CurrentReqObj)
                case 'Requirements.Stability'
                    obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
                case 'Requirements.FrequencyResponse'
                    obj.CurrentReqObj = Requirements.FrequencyResponse();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.FrequencyResponse);
                case 'Requirements.HandlingQualities'
                    obj.CurrentReqObj = Requirements.HandlingQualities();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.HandlingQualities);
                case 'Requirements.Aeroservoelasticity'
                    obj.CurrentReqObj = Requirements.Aeroservoelasticity();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Aeroservoelasticity);
                case 'Requirements.SimulationCollection'
                    obj.CurrentReqObj = Requirements.SimulationCollection();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.SimulationCollection);
                case 'Requirements.Synthesis'
                    obj.CurrentReqObj = Requirements.Synthesis();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Synthesis);
                otherwise
                    obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
            end
            createView (obj.CurrentReqObj , obj.MainPanel );
            obj.Saved = true; 
            notify(obj,'NewButtonPressed',UserInterface.UserInterfaceEventData(hobj));
            update(obj);
        end % newButton_CB

        function openButton_CB( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Requirement Object File:',obj.CurrentObjDirectory);
            drawnow();pause(0.5);
            if isequal(filename,0)
                return;
            end
            obj.StartDirectory = pathname;
            drawnow();pause(0.1);
            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            
            
            varStruct = load(fullfile(pathname,filename));
            drawnow();pause(0.1);
            varNames = fieldnames(varStruct);
                
            obj.CurrentReqObj = varStruct.(varNames{1});
            createView (obj.CurrentReqObj , obj.MainPanel );

            obj.Saved = true;
            update( obj );
            
        end % openButton_CB
               
        function load_CB( obj , ~  , ~ )
            if obj.EditInProject
                notify(obj,'ObjectLoaded',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            else
                notify(obj,'ObjectCreated',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            end
            obj.Saved = true;
            update(obj);
        end % load_CB
        
        function export_CB( obj , ~ , ~ )
            Requirement = obj.SelectedTrimDef; %#ok<NASGU>
            [filename, pathname] = uiputfile({'*.mat'},'Export Requirement',pwd);
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end
            if isa(obj.CurrentReqObj,'Requirements.SimulationCollection')
                obj.CurrentReqObj.OutputSelector.saveTreeState
            end
            drawnow();pause(0.1);
            save(fullfile(pathname,filename),'Requirement');
        end % export_CB
                
        function popUpMenuCancelled( obj , ~ , ~ )

            obj.SaveSelJButton.setFlyOverAppearance(true);
            %obj.SaveSelJButton.setContentAreaFilled(true);

        end % popUpMenuCancelled
        

    end
    
    %% Methods - Callbacks
    methods (Access = protected) 
      
        function labelTextEditBox_CB( obj , hobj , ~ )
            obj.TrimLabelString       = hobj.String;
            obj.Saved = false;
            update( obj )
        end % labelTextEditBox_CB
        
        function browseModel( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:',obj.StartDirectory);
            drawnow();pause(0.5);
            % load and assign objects
            if ~isequal(filename,0)
                obj.StartDirectory = pathname;
                [ ~ , mdl ] = fileparts(filename);
                obj.ModelName = mdl;
                createDefault( obj );
                obj.Saved = false;  
                update(obj);
                drawnow();pause(0.1);
            
            end
        end % browseModel
        
        function tabPanel_CB( obj , ~ , ~ )
            
        end % tabPanel_CB
        
        function addRow( obj , ~ , ~ , dataName )
            switch dataName
                case {'Input1TableData'}
                    obj.Input1TableData = [obj.Input1TableData; { [] , [] , false } ];
                case {'Output1TableData'}
                    obj.Output1TableData = [obj.Output1TableData; { [] , [] , false } ];
                case {'State1TableData'}
                    obj.State1TableData = [obj.State1TableData; { [] , [] , false } ];         
                case {'StateDerivs1TableData'}
                    obj.StateDerivs1TableData = [obj.StateDerivs1TableData; { [] , [] , false } ];    
            end
            
            update( obj );
        end % addRow
        
        function removeRow( obj , ~ , ~ )
            
        end % removeRow
        
        function inputTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.SelectedTrimDef.InitialTrim)
                trimdef = obj.SelectedTrimDef;
            else
                trimdef = obj.SelectedTrimDef.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.Inputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.Inputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.Inputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % inputTable1_ce_CB

        function inputTable1_cs_CB( obj , ~ , ~ )
   

        end % inputTable1_cs_CB
        
        function outputTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.SelectedTrimDef.InitialTrim)
                trimdef = obj.SelectedTrimDef;
            else
                trimdef = obj.SelectedTrimDef.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.Outputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.Outputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.Outputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % outputTable1_ce_CB

        function outputTable1_cs_CB( obj , ~ , ~ )
  

        end % outputTable1_cs_CB
        
        function stateTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.SelectedTrimDef.InitialTrim)
                trimdef = obj.SelectedTrimDef;
            else
                trimdef = obj.SelectedTrimDef.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.States(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.States(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.States(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % stateTable1_ce_CB

        function stateTable1_cs_CB( obj , ~ , ~ )
  

        end % stateTable1_cs_CB 
        
        function stateDerivsTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.SelectedTrimDef.InitialTrim)
                trimdef = obj.SelectedTrimDef;
            else
                trimdef = obj.SelectedTrimDef.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.StateDerivatives(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.StateDerivatives(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.StateDerivatives(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % stateDerivsTable1_ce_CB

        function stateDerivsTable1_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable1_cs_CB 
        
        function inputTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % inputTable2_ce_CB

        function inputTable2_cs_CB( obj , ~ , ~ )
   

        end % inputTable2_cs_CB
        
        function outputTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % outputTable2_ce_CB

        function outputTable2_cs_CB( obj , ~ , ~ )
  

        end % outputTable2_cs_CB
        
        function stateTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.States(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.States(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.States(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % stateTable2_ce_CB

        function stateTable2_cs_CB( obj , ~ , ~ )
  

        end % stateTable2_cs_CB 
        
        function stateDerivsTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % stateDerivsTable2_ce_CB

        function stateDerivsTable2_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable2_cs_CB  
   
        function numOfTrimComboBox_CB( obj , hobj , ~ )
  
            obj.NumOfTrimSelectionValue = obj.NumOfTrimComboBox.Value;

        end % numOfTrimComboBox_CB 
        
        function gearVarComboBox_CB( obj , hobj , ~ )
  
            obj.GearVariableSelectionValue = obj.GearVarComboBox.Value;
            obj.SelectedTrimDef.LandingGearSimulinkVal = obj.GearVariableSelectionValue;
            obj.SelectedTrimDef.LandingGearSimulinkName= obj.GearVarComboBox.String{obj.GearVariableSelectionValue};
            
        end % gearVarComboBox_CB 
        
        function flapVarComboBox_CB( obj , hobj , ~ )
  
            obj.FlapVariableSelectionValue = obj.FlapVarComboBox.Value;
            obj.SelectedTrimDef.FlapSimulinkVal = obj.FlapVariableSelectionValue;
            obj.SelectedTrimDef.FlapSimulinkName= obj.FlapVarComboBox.String{obj.FlapVariableSelectionValue};
        end % flapVarComboBox_CB
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ )
            obj.LabelEditBox.String = obj.TrimLabelString;
            
            obj.NumOfTrimComboBox.String = obj.NumOfTrimSelectionString;
            obj.NumOfTrimComboBox.Value = obj.NumOfTrimSelectionValue;
            
            obj.GearVarComboBox.String = obj.GearVariableSelectionString;
            obj.GearVarComboBox.Value = obj.GearVariableSelectionValue;
            
            obj.FlapVarComboBox.String = obj.FlapVariableSelectionString;
            obj.FlapVarComboBox.Value = obj.FlapVariableSelectionValue;
            
            obj.ModelEditBox.String = obj.ModelName;
            if ~isempty(obj.SelectedTrimDef)
                obj.SelectedTrimDef.Label = obj.TrimLabelString;
                
                obj.GearVarComboBox.String = [{''};obj.SelectedTrimDef.SimulinkInports];
                obj.GearVarComboBox.Value =  obj.SelectedTrimDef.LandingGearSimulinkVal;
                
                obj.FlapVarComboBox.String =  [{''};obj.SelectedTrimDef.SimulinkInports];
                obj.FlapVarComboBox.Value = obj.SelectedTrimDef.FlapSimulinkVal;

                %                 obj.SelectedTrimDef.FlapSimulinkName           = obj.FlapVariableSelectionString{obj.FlapVariableSelectionValue};
%                 obj.SelectedTrimDef.LandingGearSimulinkName    = obj.GearVariableSelectionString{obj.GearVariableSelectionValue};
                if ~isempty(obj.SelectedTrimDef.InitialTrim)
                    obj.SelectedTrimDef.InitialTrim.FlapSimulinkName           = obj.SelectedTrimDef.FlapSimulinkName;
                    obj.SelectedTrimDef.InitialTrim.LandingGearSimulinkName    = obj.SelectedTrimDef.LandingGearSimulinkName;
                end
            end
            setFileTitle( obj );
            updateTable( obj );
        end % update
         
        function reSize( obj , ~ , ~ )
            reSize@UserInterface.ObjectEditor.Editor( obj );              
            % get figure position
            position = getpixelposition(obj.MainPanel);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            set(obj.ModelText,'Units','Pixels',...
                'Position',[10 , position(4) - 70 , 200 , 17]); 
            set(obj.ModelEditBox,'Units','Pixels',...
                'Position',[10 , position(4) - 95 , 200 , 25]);  
            set(obj.ModelPushButton,'Units','Pixels',...
                'Position',[220 , position(4) - 95 , 70 , 25]);  
            set(obj.FlapVarText,'Units','Pixels',...
                'Position',[330 , position(4) - 70 , 130 , 17]);  
            set(obj.FlapVarComboBox,'Units','Pixels',...
                'Position',[330 , position(4) - 95 , 70 , 25]);  
            
            
            set(obj.LabelText,'Units','Pixels',...
                'Position',[10 , position(4) - 20 , 200 , 17]);  
            set(obj.LabelEditBox,'Units','Pixels',...
                'Position',[10 , position(4) - 45 , 200 , 25]); 
            set(obj.NumOfTrimText,'Units','Pixels',...
                'Position',[220 , position(4) - 20 , 100 , 17]);  
            set(obj.NumOfTrimComboBox,'Units','Pixels',...
                'Position',[220 , position(4) - 45 , 70 , 25]);  
            set(obj.GearVarText,'Units','Pixels',...
                'Position',[330 , position(4) - 20 , 130 , 17]);  
            set(obj.GearVarComboBox,'Units','Pixels',...
                'Position',[330 , position(4) - 45 , 70 , 25]);  
            
            
            set(obj.TabPanel,'Units','Pixels',...
                'Position',[10 , 2 , position(3)-20 , position(4) - 100 ]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            positionTab = getpixelposition(obj.TabPanel);
            tableHeight = (positionTab(4) - 180)/2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.InputsText1.Units = 'Pixels';
            obj.InputsText1.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Input1Table.Units = 'Pixels';
            obj.Input1Table.Position = [ 10 , tableHeight + 105, 200 , tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText1.Units = 'Pixels';
            obj.OutputsText1.Position = [ 220 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Output1Table.Units = 'Pixels';
            obj.Output1Table.Position = [ 220 , tableHeight + 105, 200 , tableHeight ];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText1.Units = 'Pixels';
            obj.StatesText1.Position = [ 10 , tableHeight + 35 , 180 , 20 ];
            obj.State1Table.Units = 'Pixels';
            obj.State1Table.Position = [ 10 , 35 , 200 , tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText1.Units = 'Pixels';
            obj.StateDerivsText1.Position = [ 220 , tableHeight + 35 , 220 , 20 ];
            obj.StateDerivs1Table.Units = 'Pixels';
            obj.StateDerivs1Table.Position = [ 220 , 35 , 200 , tableHeight ];
             
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.InputsText2.Units = 'Pixels';
            obj.InputsText2.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Input2Table.Units = 'Pixels';
            obj.Input2Table.Position = [ 10 , tableHeight + 105, 200 , tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText2.Units = 'Pixels';
            obj.OutputsText2.Position = [ 220 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Output2Table.Units = 'Pixels';
            obj.Output2Table.Position = [ 220 , tableHeight + 105, 200 , tableHeight ];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText2.Units = 'Pixels';
            obj.StatesText2.Position = [ 10 , tableHeight + 35 , 180 , 20 ];
            obj.State2Table.Units = 'Pixels';
            obj.State2Table.Position = [ 10 , 35 , 200 , tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText2.Units = 'Pixels';
            obj.StateDerivsText2.Position = [ 220 , tableHeight + 35 , 220 , 20 ];
            obj.StateDerivs2Table.Units = 'Pixels';
            obj.StateDerivs2Table.Position = [ 220 , 35 , 200 , tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        end % reSize
        
        function updateTable( obj )
            if ~isempty(obj.SelectedTrimDef)
                obj.Input1Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('Inputs');
                obj.Output1Table.Data      = obj.SelectedTrimDef.getAsTableDataEditor('Outputs');
                obj.State1Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('States');
                obj.StateDerivs1Table.Data = obj.SelectedTrimDef.getAsTableDataEditor('StateDerivatives');

                if ~isempty(obj.SelectedTrimDef.InitialTrim)
                    obj.Input1Table.Data       = obj.SelectedTrimDef.InitialTrim.getAsTableDataEditor('Inputs');
                    obj.Output1Table.Data      = obj.SelectedTrimDef.InitialTrim.getAsTableDataEditor('Outputs');
                    obj.State1Table.Data       = obj.SelectedTrimDef.InitialTrim.getAsTableDataEditor('States');
                    obj.StateDerivs1Table.Data = obj.SelectedTrimDef.InitialTrim.getAsTableDataEditor('StateDerivatives');
                    
                    obj.Input2Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('Inputs');
                    obj.Output2Table.Data      = obj.SelectedTrimDef.getAsTableDataEditor('Outputs');
                    obj.State2Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('States');
                    obj.StateDerivs2Table.Data = obj.SelectedTrimDef.getAsTableDataEditor('StateDerivatives');
                else
                    obj.Input1Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('Inputs');
                    obj.Output1Table.Data      = obj.SelectedTrimDef.getAsTableDataEditor('Outputs');
                    obj.State1Table.Data       = obj.SelectedTrimDef.getAsTableDataEditor('States');
                    obj.StateDerivs1Table.Data = obj.SelectedTrimDef.getAsTableDataEditor('StateDerivatives');
                    obj.Input2Table.Data       = [];
                    obj.Output2Table.Data      = [];
                    obj.State2Table.Data       = [];
                    obj.StateDerivs2Table.Data = []; 
                end
            
            else
                obj.Input1Table.Data       = [];
                obj.Output1Table.Data      = [];
                obj.State1Table.Data       = [];
                obj.StateDerivs1Table.Data = [];
                obj.Input2Table.Data       = [];
                obj.Output2Table.Data      = [];
                obj.State2Table.Data       = [];
                obj.StateDerivs2Table.Data = []; 
                
            end  
        end
           
    end
    
    %% Methods - Private
    methods %(Access = private) 
        
        function createDefault( obj )
            
            mdl = obj.ModelName;
            if isempty(mdl)
                error('A Simulink Model must be avaliable');
            end
              
            
            load_system(mdl);
            inH  = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Inport' );
            [ ~ , inNames ] = cellfun( @fileparts , inH , 'UniformOutput' , false );

            outH = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Outport' );
            [ ~ , outNames ] = cellfun( @fileparts , outH , 'UniformOutput' , false );
            
            try
                [~,~,x0]=eval([mdl '([],[],[],0)']);
                [ ~ , stateNames ] = cellfun( @fileparts , x0 , 'UniformOutput' , false );
            catch
                return;
            end
                
            stateDerivNames = cellfun(@(x) [x,'dot'],stateNames,'UniformOutput',false);
            
            inputConditions = lacm.Condition.empty;
            for i = 1:length(inNames)
                inputConditions(i)      = lacm.Condition( inNames{i}, 0 , [] , true );
            end
            outputConditions = lacm.Condition.empty;
            for i = 1:length(outNames)
                outputConditions(i)     = lacm.Condition( outNames{i}, 0 , [] , false );
            end  
            stateConditions = lacm.Condition.empty;
            for i = 1:length(stateNames)
                stateConditions(i)      = lacm.Condition( stateNames{i}, 0 , [] , true );
            end
            stateDerivConditions = lacm.Condition.empty;
            for i = 1:length(stateDerivNames)
                stateDerivConditions(i) = lacm.Condition( stateDerivNames{i}, 0 , [] , false );
            end  
            
            if obj.NumOfTrimComboBox.Value == 1
                trimSettings = lacm.TrimSettings();
                trimSettings.StateDerivatives = stateDerivConditions;
                trimSettings.Outputs          = outputConditions;
                trimSettings.States           = stateConditions;
                trimSettings.Inputs           = inputConditions;
            elseif obj.NumOfTrimComboBox.Value == 2
                secondTrimSettings = lacm.TrimSettings();
                secondTrimSettings.StateDerivatives = stateDerivConditions;
                secondTrimSettings.Outputs          = outputConditions;
                secondTrimSettings.States           = stateConditions;
                secondTrimSettings.Inputs           = inputConditions; 
                
                inputConditions2 = lacm.Condition.empty;
                for i = 1:length(inNames)
                    inputConditions2(i)      = lacm.Condition( inNames{i}, 0 , [] , true , true );
                end
                outputConditions2 = lacm.Condition.empty;
                for i = 1:length(outNames)
                    outputConditions2(i)     = lacm.Condition( outNames{i}, 0 , [] , false , false );
                end  
                stateConditions2 = lacm.Condition.empty;
                for i = 1:length(stateNames)
                    stateConditions2(i)      = lacm.Condition( stateNames{i}, 0 , [] , true , true );
                end
                stateDerivConditions2 = lacm.Condition.empty;
                for i = 1:length(stateDerivNames)
                    stateDerivConditions2(i) = lacm.Condition( stateDerivNames{i}, 0 , [] , false , false );
                end  
                
                
                trimSettings = lacm.TrimSettings();
                trimSettings.StateDerivatives = stateDerivConditions2;
                trimSettings.Outputs          = outputConditions2;
                trimSettings.States           = stateConditions2;
                trimSettings.Inputs           = inputConditions2;
                trimSettings.InitialTrim = secondTrimSettings;
            end
            trimSettings.Label = obj.TrimLabelString;
            trimSettings.SimulinkModelName = obj.ModelName;
            trimSettings.SimulinkInports   = inNames;
            trimSettings.SimulinkOutports  = outNames;
            trimSettings.SimulinkStates    = stateNames;
            
            obj.FlapVariableSelectionString = [{''};inNames];
            obj.GearVariableSelectionString = [{''};inNames];
            
            trimSettings.FlapSimulinkName = obj.FlapVariableSelectionString{obj.FlapVariableSelectionValue};
            trimSettings.LandingGearSimulinkName =  obj.GearVariableSelectionString{obj.GearVariableSelectionValue};
            
            trimSettings.FlapSimulinkVal = obj.FlapVariableSelectionValue;
            trimSettings.LandingGearSimulinkVal = obj.GearVariableSelectionValue;
            
            obj.SelectedTrimDef = trimSettings;
            
        end % createDefault

    end
        
    %% Method - Static
    methods ( Static )
        
        
    end
        
end


