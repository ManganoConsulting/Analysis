classdef TrimSettings < matlab.mixin.Copyable
    
    %% Public Observable properties
    properties  (SetObservable) 

        Title                       % title 
    end % Public properties
    
    %% Public properties - Data Storage
    properties       
        Label char
        InitialTrim lacm.TrimSettings
        
        StateDerivatives lacm.Condition
        Outputs lacm.Condition
        States lacm.Condition
        Inputs lacm.Condition
        CStateID
        
        SimulinkModelName
        SimulinkInports
        SimulinkOutports
        SimulinkStates
        
        
        FlapSimulinkName
        FlapSimulinkVal = 1
        LandingGearSimulinkName
        LandingGearSimulinkVal = 1

        CombinationMode char = 'all'  % 'all' or 'specified'


    end % Public properties
        
    %% Read-only properties
    properties ( Hidden = true , GetAccess = public, SetAccess = private )
        Node
    end % Read-only properties
    
    %% View Public properties - Graphics Handles
    properties (Transient = true , Hidden = true)
        Parent
        MainPanel
        LabelText
        LabelEditBox
        NumOfTrimText
        NumOfTrimComboBox
        CombinationModeText
        CombinationModeComboBox

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
        
        TabPanelTrim1
            
        Trim1InputsTab

        Trim1OutputsTab

        Trim1StatesTab

        Trim1StateDerivTab

        TabPanelTrim2

        Trim2InputsTab

        Trim2OutputsTab

        Trim2StatesTab

        Trim2StateDerivTab
    end % Public properties
  
    %% View Public properties - Data Storage
    properties ( Hidden = true)
        StartDirectory = pwd
        TrimLabelString = char.empty
        NumOfTrimSelectionString = {'1','2'}
        NumOfTrimSelectionValue  = 1
        CombinationModeSelectionString = {'All combinations','Specified values'}
        CombinationModeSelectionValue  = 1

        Input1TableData
        Output1TableData
        State1TableData
        StateDerivs1TableData
        
        Input2TableData
        Output2TableData
        State2TableData
        StateDerivs2TableData
        
        ModelName
        
        
        InputConditions = lacm.Condition.empty
        OutputConditions = lacm.Condition.empty
        StateConditions = lacm.Condition.empty
        StateDerivConditions = lacm.Condition.empty
           
        
        GearVariableSelectionString = {''}
        GearVariableSelectionValue = 1
        FlapVariableSelectionString = {''}
        FlapVariableSelectionValue = 1
    end % Public properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
%         Selected
    end % Dependant properties
    
    %% Constant properties
    properties (Hidden = true, Constant) 
%         JavaImage_checked        = UserInterface.Icons.checkedIcon();
%         JavaImage_unchecked      = UserInterface.Icons.uncheckedIcon();
    end % Constant properties 
    
    %% Methods - Constructor
    methods      
        function obj = TrimSettings(varargin)
            switch nargin
                case 0
                case 1
            end
            
        end % TrimSettings
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        function [y,ind] = getID(obj,x)
            y = lacm.TrimSettings.empty;
            ind = [];
            lArray = [obj.TrimID] == x;
            if any(lArray)
                y = obj(lArray);
                ind = find(lArray);
            end
        end % getID
        
        function data = getAsTableData( obj , prop )
            if isempty(obj) || isempty(obj.(prop))
                data = [];
            else
                for i = 1:length(obj.(prop))
                    if isempty(obj.(prop)(i).UsePrevious) || ~obj.(prop)(i).UsePrevious 
                        data(i,:) = {obj.(prop)(i).Name , obj.(prop)(i).StringValue , obj.(prop)(i).Fix , obj.(prop)(i).BasicMode };
                    else
                        data(i,:) = {obj.(prop)(i).Name , 'Trim 1' , obj.(prop)(i).Fix , obj.(prop)(i).BasicMode };
                    end
                end
            end
        end % getAsTableData
        
        function data = getAsBasicTableData( obj , prop )
            if isempty(obj) 
                data = [];
            else
                conds = lacm.Condition.empty;
                type = cell.empty;
                logArraySD = strcmp(prop,{obj.StateDerivatives.BasicMode});
                conds = [conds,obj.StateDerivatives(logArraySD)];
                for i = 1:sum(logArraySD)
                    type{end+1} = 'StateDerivatives'; %#ok<AGROW>
                end
                
                logArrayS = strcmp(prop,{obj.States.BasicMode});
                conds = [conds,obj.States(logArrayS)];
                for i = 1:sum(logArrayS)
                    type{end+1} = 'States'; %#ok<AGROW>
                end
                
                logArrayIn = strcmp(prop,{obj.Inputs.BasicMode});
                conds = [conds,obj.Inputs(logArrayIn)];
                for i = 1:sum(logArrayIn)
                    type{end+1} = 'Inputs'; %#ok<AGROW>
                end
                
                logArrayOut = strcmp(prop,{obj.Outputs.BasicMode});
                conds = [conds,obj.Outputs(logArrayOut)];
                for i = 1:sum(logArrayOut)
                    type{end+1} = 'Outputs'; %#ok<AGROW>
                end
                
                if isempty(conds)
                    data = [];
                else

                    for i = 1:length(conds)
                        if isempty(conds(i).UsePrevious) || ~conds(i).UsePrevious 
                            data(i,:) = {conds(i).Name , conds(i).StringValue , conds(i).Fix , type{i} };
                        else
                            data(i,:) = {conds(i).Name , 'Trim 1' , conds(i).Fix , type{i} };
                        end
                    end
                end
            end
        end % getAsBasicTableData
        
        function data = getAsTableDataEditor( obj , prop )
            if isempty(obj) || isempty(obj.(prop))
                data = [];
            else
                for i = 1:length(obj.(prop))
                    if isempty(obj.(prop)(i).UsePrevious) || ~obj.(prop)(i).UsePrevious 
                        data(i,:) = {obj.(prop)(i).Name , obj.(prop)(i).StringValue , obj.(prop)(i).Fix , obj.(prop)(i).BasicMode }; %#ok<AGROW>
                    else
                        data(i,:) = {obj.(prop)(i).Name , 'Trim 1' , obj.(prop)(i).Fix , obj.(prop)(i).BasicMode}; %#ok<AGROW>
                    end
                end
            end
        end % getAsTableDataEditor
        
        function [ scalarObjs , vectorObjs ] = filterTrimSettings( obj , prop )
            
            logArray = cellfun(@isscalar,{obj.(prop).Value});
            scalarObjs = copy(obj.(prop)(logArray));
            vectorObjs = copy(obj.(prop)(~logArray));
            
        end % filterTrimSettings
        
        function y = getNames( obj , prop )
            
            y = {obj.(prop).Name};

            
        end % getNames
        
        function valid = validTrimEquation( obj )
            
            numStateDerivFixed = sum([obj.StateDerivatives.Fix]);
            numOutputsFixed    = sum([obj.Outputs.Fix]);
            numStatesFree     = sum(~[obj.States.Fix]);
            numInputsFree     = sum(~[obj.Inputs.Fix]);
            if (numInputsFree + numStatesFree) == ( numStateDerivFixed + numOutputsFixed )
                valid.Status = true;
            else
                valid.Status = false;
            end
            valid.NumberInputsFree      = numInputsFree;
            valid.NumberOutputsFixed     = numOutputsFixed;
            valid.NumberStatesFree      = numStatesFree;
            valid.NumberStateDerivsFixed = numStateDerivFixed;
            
        end % validTrimEquation
        
        function [ data , color ] = validTrimEquationTableData( obj )
            
            valid = validTrimEquation( obj );
            
            data = { valid.NumberInputsFree + valid.NumberStatesFree , valid.NumberOutputsFixed  + valid.NumberStateDerivsFixed};
            
            if valid.Status
                color = [ 0 , 0.56 , 0 ];
            else
                color = [ 1 , 0 , 0 ];
            end
            
        end % validTrimEquationTableData 
        
    end % Ordinary Methods
    
    %% Methods - View Methods
    methods 
        
        function createView( obj , parent )  
            %createView@UserInterface.ObjectEditor.Editor( obj , parent );
            obj.Parent = parent;
%             end
            % Main Container
            obj.MainPanel = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);%,...
            
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

            obj.CombinationModeText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Combination Mode:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.CombinationModeComboBox = uicontrol('Parent',obj.MainPanel,...
                'Style','popup',...
                'FontSize',10,...
                'String',obj.CombinationModeSelectionString,...
                'Value',obj.CombinationModeSelectionValue,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','center',...
                'Callback',@obj.combinationModeComboBox_CB);
            
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
            
            if ~isempty(obj.ModelName)
                updateMdlConditions( obj );
            end
            
            update(obj);
            updateTable( obj );
        end % createView
        
        function createTab1( obj , parent )
            
            obj.TabPanelTrim1 = uitabgroup('Parent',parent);
            obj.TabPanelTrim1.TabLocation = 'Bottom';
            
            obj.Trim1InputsTab       = uitab('Parent',obj.TabPanelTrim1);
            obj.Trim1InputsTab.Title = 'Inputs';
  
            obj.Trim1OutputsTab       = uitab('Parent',obj.TabPanelTrim1);
            obj.Trim1OutputsTab.Title = 'Outputs';
            
            obj.Trim1StatesTab       = uitab('Parent',obj.TabPanelTrim1);
            obj.Trim1StatesTab.Title = 'States';
            
            obj.Trim1StateDerivTab  = uitab('Parent',obj.TabPanelTrim1);
            obj.Trim1StateDerivTab.Title = 'State Derivatives';
            

            
            obj.InputsText1 = uicontrol('Parent',obj.Trim1InputsTab,...
                'Style','text',...
                'FontSize',10,...
                'String','Inputs (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Input1Table = uitable(obj.Trim1InputsTab,...
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
            

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText1 = uicontrol('Parent',obj.Trim1OutputsTab,...
                'Style','text',...
                'FontSize',10,...
                'String','Outputs (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Output1Table = uitable(obj.Trim1OutputsTab,...
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
            

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText1 = uicontrol('Parent',obj.Trim1StatesTab,...
                'Style','text',...
                'FontSize',10,...
                'String','States (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.State1Table = uitable(obj.Trim1StatesTab,...
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

            

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText1 = uicontrol('Parent',obj.Trim1StateDerivTab,...
                'Style','text',...
                'FontSize',10,...
                'String','State Derivatives (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.StateDerivs1Table = uitable(obj.Trim1StateDerivTab,...
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

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          



            

        end % createTab1
        
        function createTab2( obj , parent )
            
            obj.TabPanelTrim2 = uitabgroup('Parent',parent);
            obj.TabPanelTrim2.TabLocation = 'Bottom';
            
            obj.Trim2InputsTab       = uitab('Parent',obj.TabPanelTrim2);
            obj.Trim2InputsTab.Title = 'Inputs';
  
            obj.Trim2OutputsTab       = uitab('Parent',obj.TabPanelTrim2);
            obj.Trim2OutputsTab.Title = 'Outputs';
            
            obj.Trim2StatesTab       = uitab('Parent',obj.TabPanelTrim2);
            obj.Trim2StatesTab.Title = 'States';
            
            obj.Trim2StateDerivTab  = uitab('Parent',obj.TabPanelTrim2);
            obj.Trim2StateDerivTab.Title = 'State Derivatives';
            
            
            obj.InputsText2 = uicontrol('Parent',obj.Trim2InputsTab ,...
                'Style','text',...
                'FontSize',10,...
                'String','Inputs (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Input2Table = uitable(obj.Trim2InputsTab ,...
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
             
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText2 = uicontrol('Parent',obj.Trim2OutputsTab,...
                'Style','text',...
                'FontSize',10,...
                'String','Outputs (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Output2Table = uitable(obj.Trim2OutputsTab,...
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
            
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText2 = uicontrol('Parent',obj.Trim2StatesTab,...
                'Style','text',...
                'FontSize',10,...
                'String','States (Default = Fixed)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.State2Table = uitable(obj.Trim2StatesTab,...
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

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText2 = uicontrol('Parent',obj.Trim2StateDerivTab,...
                'Style','text',...
                'FontSize',10,...
                'String','State Derivatives (Default = Free)',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.StateDerivs2Table = uitable(obj.Trim2StateDerivTab,...
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

            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          



            

        end % createTab2
        
    end
        
    %% Methods - View Callback Methods
    methods
                
        function labelTextEditBox_CB( obj , hobj , ~ )
            obj.Label = hobj.String; 
%             obj.TrimLabelString       = hobj.String;
%             obj.Saved = false;
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
                update(obj)
            
            end
        end % browseModel
        
        function tabPanel_CB( obj , ~ , ~ )
            
        end % tabPanel_CB
                      
        function inputTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.InitialTrim)
                trimdef = obj;
            else
                trimdef = obj.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.Inputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.Inputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.Inputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % inputTable1_ce_CB

        function inputTable1_cs_CB( obj , ~ , ~ )
   

        end % inputTable1_cs_CB
        
        function outputTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.InitialTrim)
                trimdef = obj;
            else
                trimdef = obj.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.Outputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.Outputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.Outputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % outputTable1_ce_CB

        function outputTable1_cs_CB( obj , ~ , ~ )
  

        end % outputTable1_cs_CB
        
        function stateTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.InitialTrim)
                trimdef = obj;
            else
                trimdef = obj.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.States(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.States(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.States(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % stateTable1_ce_CB

        function stateTable1_cs_CB( obj , ~ , ~ )
  

        end % stateTable1_cs_CB 
        
        function stateDerivsTable1_ce_CB(obj , ~ , eventData )
            if isempty(obj.InitialTrim)
                trimdef = obj;
            else
                trimdef = obj.InitialTrim;
            end
            switch eventData.Indices(2)
                case 2
                    trimdef.StateDerivatives(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    trimdef.StateDerivatives(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    trimdef.StateDerivatives(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % stateDerivsTable1_ce_CB

        function stateDerivsTable1_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable1_cs_CB 
        
        function inputTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.Inputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.Inputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.Inputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % inputTable2_ce_CB

        function inputTable2_cs_CB( obj , ~ , ~ )
   

        end % inputTable2_cs_CB
        
        function outputTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.Outputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.Outputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.Outputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % outputTable2_ce_CB

        function outputTable2_cs_CB( obj , ~ , ~ )
  

        end % outputTable2_cs_CB
        
        function stateTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.States(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.States(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.States(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % stateTable2_ce_CB

        function stateTable2_cs_CB( obj , ~ , ~ )
  

        end % stateTable2_cs_CB 
        
        function stateDerivsTable2_ce_CB(obj , ~ , eventData )

            switch eventData.Indices(2)
                case 2
                    obj.StateDerivatives(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.StateDerivatives(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.StateDerivatives(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
%             obj.Saved = false;
            obj.update();
        end % stateDerivsTable2_ce_CB

        function stateDerivsTable2_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable2_cs_CB  
   
        function numOfTrimComboBox_CB( obj , hobj , ~ )
            if obj.NumOfTrimSelectionValue ~= obj.NumOfTrimComboBox.Value
                choice = questdlg('Changing the number of trims will reset the current selections.  Proceed?', ...
                    'Change Number of Trims?', ...
                    'Yes','No','No');
                switch choice
                    case 'Yes'
                        obj.NumOfTrimSelectionValue = obj.NumOfTrimComboBox.Value;
                        createDefault( obj );
                    otherwise
                        update(obj);
                        updateTable( obj );
                end
            end
        end % numOfTrimComboBox_CB 
        
        function gearVarComboBox_CB( obj , hobj , ~ )
  
            obj.GearVariableSelectionValue = obj.GearVarComboBox.Value;
            obj.LandingGearSimulinkVal = obj.GearVariableSelectionValue;
            obj.LandingGearSimulinkName= obj.GearVarComboBox.String{obj.GearVariableSelectionValue};
            
        end % gearVarComboBox_CB 
        
        function flapVarComboBox_CB( obj , hobj , ~ )

            obj.FlapVariableSelectionValue = obj.FlapVarComboBox.Value;
            obj.FlapSimulinkVal = obj.FlapVariableSelectionValue;
            obj.FlapSimulinkName= obj.FlapVarComboBox.String{obj.FlapVariableSelectionValue};
        end % flapVarComboBox_CB

        function combinationModeComboBox_CB( obj , hobj , ~ )
            obj.CombinationModeSelectionValue = obj.CombinationModeComboBox.Value;
            if obj.CombinationModeComboBox.Value == 1
                obj.CombinationMode = 'all';
            else
                obj.CombinationMode = 'specified';
            end
        end % combinationModeComboBox_CB

    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ )
            obj.LabelEditBox.String = obj.Label; %obj.LabelEditBox.String = obj.TrimLabelString;
            
%             obj.NumOfTrimComboBox.String = obj.NumOfTrimSelectionString;
%             obj.NumOfTrimComboBox.Value = obj.NumOfTrimSelectionValue;
            if isempty(obj.InitialTrim)  
                obj.NumOfTrimComboBox.Value = 1;
            else
                obj.NumOfTrimComboBox.Value = 2; 
            end
            
            obj.GearVarComboBox.String = obj.GearVariableSelectionString;
            obj.GearVarComboBox.Value = obj.GearVariableSelectionValue;

            obj.FlapVarComboBox.String = obj.FlapVariableSelectionString;
            obj.FlapVarComboBox.Value = obj.FlapVariableSelectionValue;

            obj.CombinationModeComboBox.String = obj.CombinationModeSelectionString;
            if strcmpi(obj.CombinationMode,'specified')
                obj.CombinationModeComboBox.Value = 2;
            else
                obj.CombinationModeComboBox.Value = 1;
            end

            obj.ModelEditBox.String = obj.ModelName;
            if ~isempty(obj)
                %obj.Label = obj.TrimLabelString;
                
                obj.GearVarComboBox.String = [{''};obj.SimulinkInports];
                obj.GearVarComboBox.Value =  obj.LandingGearSimulinkVal;
                
                obj.FlapVarComboBox.String =  [{''};obj.SimulinkInports];
                obj.FlapVarComboBox.Value = obj.FlapSimulinkVal;

                if ~isempty(obj.InitialTrim)
                    obj.InitialTrim.FlapSimulinkName           = obj.FlapSimulinkName;
                    obj.InitialTrim.LandingGearSimulinkName    = obj.LandingGearSimulinkName;
                end
            end

%             updateTable( obj );
        end % update
         
        function reSize( obj , ~ , ~ )
%             reSize@UserInterface.ObjectEditor.Editor( obj );              
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
            set(obj.CombinationModeText,'Units','Pixels',...
                'Position',[440 , position(4) - 20 , 150 , 17]);
            set(obj.CombinationModeComboBox,'Units','Pixels',...
                'Position',[440 , position(4) - 45 , 110 , 25]);
            
            
            set(obj.TabPanel,'Units','Pixels',...
                'Position',[10 , 2 , position(3)-20 , position(4) - 100 ]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            positionTab = getpixelposition(obj.TabPanel);
            tableHeight = (positionTab(4) - 180)/2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.InputsText1.Units = 'Pixels';
            obj.InputsText1.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.Input1Table.Units = 'Pixels';
            obj.Input1Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.InputsText1.Units = 'Pixels';
%             obj.InputsText1.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
%             obj.Input1Table.Units = 'Pixels';
%             obj.Input1Table.Position = [ 10 , tableHeight + 105, 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText1.Units = 'Pixels';
            obj.OutputsText1.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.Output1Table.Units = 'Pixels';
            obj.Output1Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.OutputsText1.Units = 'Pixels';
%             obj.OutputsText1.Position = [ 220 , 2*tableHeight + 105 , 180 , 20 ];
%             obj.Output1Table.Units = 'Pixels';
%             obj.Output1Table.Position = [ 220 , tableHeight + 105, 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText1.Units = 'Pixels';
            obj.StatesText1.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.State1Table.Units = 'Pixels';
            obj.State1Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.StatesText1.Units = 'Pixels';
%             obj.StatesText1.Position = [ 10 , tableHeight + 35 , 180 , 20 ];
%             obj.State1Table.Units = 'Pixels';
%             obj.State1Table.Position = [ 10 , 35 , 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText1.Units = 'Pixels';
            obj.StateDerivsText1.Position = [ 10 , positionTab(4) - 90 , 250 , 20 ];
            obj.StateDerivs1Table.Units = 'Pixels';
            obj.StateDerivs1Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.StateDerivsText1.Units = 'Pixels';
%             obj.StateDerivsText1.Position = [ 220 , tableHeight + 35 , 220 , 20 ];
%             obj.StateDerivs1Table.Units = 'Pixels';
%             obj.StateDerivs1Table.Position = [ 220 , 35 , 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.InputsText2.Units = 'Pixels';
            obj.InputsText2.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.Input2Table.Units = 'Pixels';
            obj.Input2Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.InputsText2.Units = 'Pixels';
%             obj.InputsText2.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
%             obj.Input2Table.Units = 'Pixels';
%             obj.Input2Table.Position = [ 10 , tableHeight + 105, 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText2.Units = 'Pixels';
            obj.OutputsText2.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.Output2Table.Units = 'Pixels';
            obj.Output2Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.OutputsText2.Units = 'Pixels';
%             obj.OutputsText2.Position = [ 220 , 2*tableHeight + 105 , 180 , 20 ];
%             obj.Output2Table.Units = 'Pixels';
%             obj.Output2Table.Position = [ 220 , tableHeight + 105, 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText2.Units = 'Pixels';
            obj.StatesText2.Position = [ 10 , positionTab(4) - 90 , 180 , 20 ];
            obj.State2Table.Units = 'Pixels';
            obj.State2Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.StatesText2.Units = 'Pixels';
%             obj.StatesText2.Position = [ 10 , tableHeight + 35 , 180 , 20 ];
%             obj.State2Table.Units = 'Pixels';
%             obj.State2Table.Position = [ 10 , 35 , 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StateDerivsText2.Units = 'Pixels';
            obj.StateDerivsText2.Position = [ 10 , positionTab(4) - 90 , 250 , 20 ];
            obj.StateDerivs2Table.Units = 'Pixels';
            obj.StateDerivs2Table.Position = [ 10 , 10 , positionTab(3) - 30 , positionTab(4) - 110 ];
            
%             obj.StateDerivsText2.Units = 'Pixels';
%             obj.StateDerivsText2.Position = [ 220 , tableHeight + 35 , 220 , 20 ];
%             obj.StateDerivs2Table.Units = 'Pixels';
%             obj.StateDerivs2Table.Position = [ 220 , 35 , 200 , tableHeight ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        end % reSize
        
        function updateTable( obj )
            if ~isempty(obj)
                obj.Input1Table.Data       = obj.getAsTableDataEditor('Inputs');
                obj.Output1Table.Data      = obj.getAsTableDataEditor('Outputs');
                obj.State1Table.Data       = obj.getAsTableDataEditor('States');
                obj.StateDerivs1Table.Data = obj.getAsTableDataEditor('StateDerivatives');

                if ~isempty(obj.InitialTrim)
                    obj.Input1Table.Data       = obj.InitialTrim.getAsTableDataEditor('Inputs');
                    obj.Output1Table.Data      = obj.InitialTrim.getAsTableDataEditor('Outputs');
                    obj.State1Table.Data       = obj.InitialTrim.getAsTableDataEditor('States');
                    obj.StateDerivs1Table.Data = obj.InitialTrim.getAsTableDataEditor('StateDerivatives');
                    
                    obj.Input2Table.Data       = obj.getAsTableDataEditor('Inputs');
                    obj.Output2Table.Data      = obj.getAsTableDataEditor('Outputs');
                    obj.State2Table.Data       = obj.getAsTableDataEditor('States');
                    obj.StateDerivs2Table.Data = obj.getAsTableDataEditor('StateDerivatives');
                else
                    obj.Input1Table.Data       = obj.getAsTableDataEditor('Inputs');
                    obj.Output1Table.Data      = obj.getAsTableDataEditor('Outputs');
                    obj.State1Table.Data       = obj.getAsTableDataEditor('States');
                    obj.StateDerivs1Table.Data = obj.getAsTableDataEditor('StateDerivatives');
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
    
    %% Methods - Private Create 
    methods (Access = private) 
        
        function [inC,outC,stC,stdC,cStateIDC,obj] = privateUpdateMdlCond( obj ,inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, cStateID)
            
            % Check if length, order, and names are identical
            inputNamesOrderSame = isequal(inNames,{obj.Inputs.Name});
            outputNamesOrderSame= isequal(outNames,{obj.Outputs.Name});
            stateNamesOrderSame = isequal(stateNames,{obj.States.Name});
            
            if inputNamesOrderSame && outputNamesOrderSame && stateNamesOrderSame
                inC = obj.Inputs;
                outC= obj.Outputs;
                stC = obj.States;
                stdC= obj.StateDerivatives;
                cStateIDC = obj.CStateID;
                return;
            end
            
            % Check if the length is the same
            inputNamesLengthSame = length(inNames)==length({obj.Inputs.Name});
            outputNamesLengthSame = length(outNames)==length({obj.Outputs.Name});
            stateNamesLengthSame = length(stateNames)==length({obj.States.Name});
           
            if ~inputNamesLengthSame || ~outputNamesLengthSame || ~stateNamesLengthSame
                MessageBoxStr = {};
                if ~inputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of input ports have changed.';
                end
                
                if ~outputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of output ports have changed.';
                end
                
                if ~stateNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of states have changed.';
                end
                
                if ~isempty(MessageBoxStr)
                    MessageBoxStr{end+1} = 'Do you want to update the trim definition to match the Simulink model?';
                    choice =  questdlg(MessageBoxStr,'Trim Definition Editor','Yes','No','No');
                    
                    switch choice
                        case 'Yes'
                            [~,iai] = setdiff(inNames,{obj.Inputs.Name});
                            [~,iao] = setdiff(outNames,{obj.Outputs.Name});
                            [~,ias] = setdiff(stateNames,{obj.States.Name});
                            % Update input,outputs, states, and state derivatives
                            [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                            cStateIDC = cStateID;
                        case 'No'
                            inC = obj.Inputs;
                            outC= obj.Outputs;
                            stC = obj.States;
                            stdC= obj.StateDerivatives;
                            cStateIDC = obj.CStateID;
                    end
                end
                
                
            else 
                MessageBoxStr = {};
                % Check if the names have changed (but length is the same)
                [~,iai] = setdiff(inNames,{obj.Inputs.Name});
                if ~isempty(iai)
                    MessageBoxStr{end+1} = 'The number of inputs is the same but some names have changed in the model.';
                else
                    if ~inputNamesOrderSame
                         MessageBoxStr{end+1} = 'The number of inputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,iao] = setdiff(outNames,{obj.Outputs.Name});
                if ~isempty(iao)
                    MessageBoxStr{end+1} = 'The number of outputs is the same but some names have changed in the model.';
                else
                    if ~outputNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of outputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,ias] = setdiff(stateNames,{obj.States.Name});
                if ~isempty(ias)
                    MessageBoxStr{end+1} = 'The number of states is the same but some names have changed in the model.';
                else
                    if ~stateNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of states and names are identical but the order has changed.';
                    end
                end
                
                if isempty(iai) && isempty(iao) && isempty(ias)
                     % Update input,outputs, states, and state derivatives
                     [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                     cStateIDC = cStateID;
                     MessageBoxStr{end+1} = 'Trim definition is automatically updated.';
                     MessageBoxStr{end+1} = 'Please Save updated Trim Definition.';
                     msgbox(MessageBoxStr,'Trim Definition Editor');
                else
                    if ~isempty(MessageBoxStr)
                        MessageBoxStr{end+1} = 'Do you want to update the trim definition to match the Simulink model?';
                        choice =  questdlg(MessageBoxStr,'Trim Definition Editor','Yes','No','No');
                        
                        switch choice
                            case 'Yes'
                                [~,iai] = setdiff(inNames,{obj.Inputs.Name});
                                [~,iao] = setdiff(outNames,{obj.Outputs.Name});
                                [~,ias] = setdiff(stateNames,{obj.States.Name});
                                
                                % Update input,outputs, states, and state derivatives
                                [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                                cStateIDC = cStateID;
                            case 'No'
                                inC = obj.Inputs;
                                outC= obj.Outputs;
                                stC = obj.States;
                                stdC= obj.StateDerivatives;
                                cStateIDC = obj.CStateID;
                        end
                    end
                end
            end
            
           
        end % privateUpdateMdlCond
        
        function [inC,outC,stC,stdC,cStateIDC,obj] = privateUpdateMdlCondIC( obj ,inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, cStateID)
            
            % Check if length, order, and names are identical
            inputNamesOrderSame = isequal(inNames,{obj.InitialTrim.Inputs.Name});
            outputNamesOrderSame= isequal(outNames,{obj.InitialTrim.Outputs.Name});
            stateNamesOrderSame = isequal(stateNames,{obj.InitialTrim.States.Name});
            
            if inputNamesOrderSame && outputNamesOrderSame && stateNamesOrderSame
                inC = obj.InitialTrim.Inputs;
                outC= obj.InitialTrim.Outputs;
                stC = obj.InitialTrim.States;
                stdC= obj.InitialTrim.StateDerivatives;
                cStateIDC = obj.InitialTrim.CStateID;
                return;
            end
            
            % Check if the length is the same
            inputNamesLengthSame = length(inNames)==length({obj.InitialTrim.Inputs.Name});
            outputNamesLengthSame = length(outNames)==length({obj.InitialTrim.Outputs.Name});
            stateNamesLengthSame = length(stateNames)==length({obj.InitialTrim.States.Name});
           
            if ~inputNamesLengthSame || ~outputNamesLengthSame || ~stateNamesLengthSame
                MessageBoxStr = {};
                if ~inputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of input ports have changed.';
                end
                
                if ~outputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of output ports have changed.';
                end
                
                if ~stateNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of states have changed.';
                end
                
                if ~isempty(MessageBoxStr)
                    MessageBoxStr{end+1} = 'Do you want to update the trim definition to match the Simulink model?';
                    choice =  questdlg(MessageBoxStr,'Trim Definition Editor','Yes','No','No');
                    
                    switch choice
                        case 'Yes'
                            [~,iai] = setdiff(inNames,{obj.InitialTrim.Inputs.Name});
                            [~,iao] = setdiff(outNames,{obj.InitialTrim.Outputs.Name});
                            [~,ias] = setdiff(stateNames,{obj.InitialTrim.States.Name});
                            % Update input,outputs, states, and state derivatives
                            [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSubIC( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                            cStateIDC = cStateID;
                        case 'No'
                            inC = obj.InitialTrim.Inputs;
                            outC= obj.InitialTrim.Outputs;
                            stC = obj.InitialTrim.States;
                            stdC= obj.InitialTrim.StateDerivatives;
                            cStateIDC = obj.InitialTrim.CStateID;
                    end
                end
                
                
            else 
                MessageBoxStr = {};
                % Check if the names have changed (but length is the same)
                [~,iai] = setdiff(inNames,{obj.InitialTrim.Inputs.Name});
                if ~isempty(iai)
                    MessageBoxStr{end+1} = 'The number of inputs is the same but some names have changed in the model.';
                else
                    if ~inputNamesOrderSame
                         MessageBoxStr{end+1} = 'The number of inputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,iao] = setdiff(outNames,{obj.InitialTrim.Outputs.Name});
                if ~isempty(iao)
                    MessageBoxStr{end+1} = 'The number of outputs is the same but some names have changed in the model.';
                else
                    if ~outputNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of outputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,ias] = setdiff(stateNames,{obj.InitialTrim.States.Name});
                if ~isempty(ias)
                    MessageBoxStr{end+1} = 'The number of states is the same but some names have changed in the model.';
                else
                    if ~stateNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of states and names are identical but the order has changed.';
                    end
                end
                
                if isempty(iai) && isempty(iao) && isempty(ias)
                     % Update input,outputs, states, and state derivatives
                     [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSubIC( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                     cStateIDC = cStateID;
                     MessageBoxStr{end+1} = 'Trim definition is automatically updated.';
                     MessageBoxStr{end+1} = 'Please Save updated Trim Definition.';
                     msgbox(MessageBoxStr,'Trim Definition Editor');
                else
                    if ~isempty(MessageBoxStr)
                        MessageBoxStr{end+1} = 'Do you want to update the trim definition to match the Simulink model?';
                        choice =  questdlg(MessageBoxStr,'Trim Definition Editor','Yes','No','No');
                        
                        switch choice
                            case 'Yes'
                                [~,iai] = setdiff(inNames,{obj.InitialTrim.Inputs.Name});
                                [~,iao] = setdiff(outNames,{obj.InitialTrim.Outputs.Name});
                                [~,ias] = setdiff(stateNames,{obj.InitialTrim.States.Name});
                                
                                % Update input,outputs, states, and state derivatives
                                [inC, outC, stC, stdC,obj] = privateUpdateMdlCondSubIC( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias);
                                cStateIDC = cStateID;
                            case 'No'
                                inC = obj.InitialTrim.Inputs;
                                outC= obj.InitialTrim.Outputs;
                                stC = obj.InitialTrim.States;
                                stdC= obj.InitialTrim.StateDerivatives;
                                cStateIDC = obj.InitialTrim.CStateID;
                        end
                    end
                end
            end
            
           
        end % privateUpdateMdlCond
        
        function [inC,outC,stC,stdC,obj] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias)
            
            % Input update
            inC = lacm.Condition.empty;
            for i = 1:length(inNames)
                if any(i == iai)
                    inC(i) = lacm.Condition( inNames{i}, 0 , inputUnits{i} , true );
                else
                    logArray = strcmp(inNames{i},{obj.Inputs.Name});
                    inC(i) = obj.Inputs(find(logArray,1));
                end
            end
            
            
            % Output update
            outC = lacm.Condition.empty;
            for i = 1:length(outNames)
                if any(i == iao)
                    outC(i) = lacm.Condition( outNames{i}, 0 , outputUnits{i} , false );
                else
                    logArray = strcmp(outNames{i},{obj.Outputs.Name});
                    outC(i) = obj.Outputs(find(logArray,1));
                end
            end
            
            % State update
            stC = lacm.Condition.empty;
            stdC= lacm.Condition.empty;
            for i = 1:length(stateNames)
                if any(i == ias)
                    stC(i) = lacm.Condition( stateNames{i}, 0 , stateUnit{i} , true );
                    stdC(i) = lacm.Condition( [stateNames{i},'_dot'], 0 , [stateUnit{i}, '/s'] , true );
                else
                    logArray = strcmp(stateNames{i},{obj.States.Name});
                    stC(i) = obj.States(find(logArray,1));
                    stdC(i) = obj.StateDerivatives(find(logArray,1));
                end
            end
            
            % Check if flap and gear exist in inport names
            obj.FlapVariableSelectionString = [{''};inNames'];
            obj.GearVariableSelectionString = [{''};inNames'];
            
            if ~isempty(obj.FlapSimulinkName)
%                 if ~strcmp(obj.FlapSimulinkName,obj.FlapVariableSelectionString(obj.FlapSimulinkVal+1))
                    jFlap = find(strcmp(obj.FlapSimulinkName,inNames));
                    if ~isempty(jFlap)
                        obj.FlapSimulinkVal = jFlap+1;
                        obj.FlapVariableSelectionValue = jFlap+1;
                    else
                        obj.FlapSimulinkName= '';
                        obj.FlapSimulinkVal = 1;
                        obj.FlapVariableSelectionValue = 1;   
                        
                    end
%                 end
            end
            
            if ~isempty(obj.LandingGearSimulinkName)
%                 if ~strcmp(obj.LandingGearSimulinkName,obj.GearVariableSelectionString(obj.LandingGearSimulinkVal+1))
                    jLG = find(strcmp(obj.LandingGearSimulinkName,inNames));
                    if ~isempty(jLG)
                        obj.LandingGearSimulinkVal = jLG+1;
                        obj.GearVariableSelectionValue = jLG+1;
                    else
                        obj.LandingGearSimulinkName= '';
                        obj.LandingGearSimulinkVal = 1;
                        obj.GearVariableSelectionValue = 1;
                    end
%                 end
            end
            
            obj.SimulinkInports   = inNames';
            obj.SimulinkOutports  = outNames';
            obj.SimulinkStates    = stateNames;

        end % privateUpdateMdlCondSub
        
        function [inC,outC,stC,stdC,obj] = privateUpdateMdlCondSubIC( obj, inNames , outNames , stateNames , inputUnits , outputUnits , stateUnit, iai, iao, ias)
            
            % Input update
            inC = lacm.Condition.empty;
            for i = 1:length(inNames)
                if any(i == iai)
                    inC(i) = lacm.Condition( inNames{i}, 0 , inputUnits{i} , true );
                else
                    logArray = strcmp(inNames{i},{obj.InitialTrim.Inputs.Name});
                    inC(i) = obj.InitialTrim.Inputs(find(logArray,1));
                end
            end
            
            
            % Output update
            outC = lacm.Condition.empty;
            for i = 1:length(outNames)
                if any(i == iao)
                    outC(i) = lacm.Condition( outNames{i}, 0 , outputUnits{i} , false );
                else
                    logArray = strcmp(outNames{i},{obj.InitialTrim.Outputs.Name});
                    outC(i) = obj.InitialTrim.Outputs(find(logArray,1));
                end
            end
            
            % State update
            stC = lacm.Condition.empty;
            stdC= lacm.Condition.empty;
            for i = 1:length(stateNames)
                if any(i == ias)
                    stC(i) = lacm.Condition( stateNames{i}, 0 , stateUnit{i} , true );
                    stdC(i) = lacm.Condition( [stateNames{i},'_dot'], 0 , [stateUnit{i}, '/s'] , true );
                else
                    logArray = strcmp(stateNames{i},{obj.InitialTrim.States.Name});
                    stC(i) = obj.InitialTrim.States(find(logArray,1));
                    stdC(i) = obj.InitialTrim.StateDerivatives(find(logArray,1));
                end
            end
            

        end % privateUpdateMdlCondSub_InitialTrim
        
    end
    
    %% Methods - Create 
    methods
        
        function createDefault( obj , simMdlName )
            
            if nargin == 2
               obj.ModelName = simMdlName; 
            end
            
            mdl = obj.ModelName;
            if isempty(mdl)
                error('A Simulink Model must be avaliable');
            end
              
            [inNames , outNames , stateNames , stateDerivNames , inputUnits , outputUnits , stateUnit , stateDotUnit, cStateID] = Utilities.getNamesFromModel( mdl );
     
            inputConditions = lacm.Condition.empty;
            for i = 1:length(inNames)
                inputConditions(i)      = lacm.Condition( inNames{i}, 0 , inputUnits{i} , true );
            end
            outputConditions = lacm.Condition.empty;
            for i = 1:length(outNames)
                outputConditions(i)     = lacm.Condition( outNames{i}, 0 , outputUnits{i} , false );
            end  
            stateConditions = lacm.Condition.empty;
            for i = 1:length(stateNames)
                stateConditions(i)      = lacm.Condition( stateNames{i}, 0 , stateUnit{i} , true );
            end
            stateDerivConditions = lacm.Condition.empty;
            for i = 1:length(stateDerivNames)
                stateDerivConditions(i) = lacm.Condition( stateDerivNames{i}, 0 , stateDotUnit{i} , false );
            end
            
            % Get the continous state ids of the model
            obj.CStateID = cStateID;
            
            if obj.NumOfTrimComboBox.Value == 1
                %trimSettings = lacm.TrimSettings();
                obj.StateDerivatives = stateDerivConditions;
                obj.Outputs          = outputConditions;
                obj.States           = stateConditions;
                obj.Inputs           = inputConditions;
                obj.InitialTrim = lacm.TrimSettings.empty;
            elseif obj.NumOfTrimComboBox.Value == 2
                secondTrimSettings = lacm.TrimSettings();
                secondTrimSettings.StateDerivatives = stateDerivConditions;
                secondTrimSettings.Outputs          = outputConditions;
                secondTrimSettings.States           = stateConditions;
                secondTrimSettings.Inputs           = inputConditions; 
                
                inputConditions2 = lacm.Condition.empty;
                for i = 1:length(inNames)
                    inputConditions2(i)      = lacm.Condition( inNames{i}, 0 , inputUnits{i} , true , true );
                end
                outputConditions2 = lacm.Condition.empty;
                for i = 1:length(outNames)
                    outputConditions2(i)     = lacm.Condition( outNames{i}, 0 , outputUnits{i} , false , false );
                end  
                stateConditions2 = lacm.Condition.empty;
                for i = 1:length(stateNames)
                    stateConditions2(i)      = lacm.Condition( stateNames{i}, 0 , stateUnit{i} , true , true );
                end
                stateDerivConditions2 = lacm.Condition.empty;
                for i = 1:length(stateDerivNames)
                    stateDerivConditions2(i) = lacm.Condition( stateDerivNames{i}, 0 , stateDotUnit{i} , false , false );
                end  
                
                obj.StateDerivatives = stateDerivConditions2;
                obj.Outputs          = outputConditions2;
                obj.States           = stateConditions2;
                obj.Inputs           = inputConditions2;
                obj.InitialTrim = secondTrimSettings;
            end
            obj.Label = obj.TrimLabelString;
            obj.SimulinkModelName = obj.ModelName;
            obj.SimulinkInports   = inNames;
            obj.SimulinkOutports  = outNames;
            obj.SimulinkStates    = stateNames;
            
            obj.FlapVariableSelectionString = [{''};inNames];
            obj.GearVariableSelectionString = [{''};inNames];
            
            obj.FlapSimulinkName = obj.FlapVariableSelectionString{obj.FlapVariableSelectionValue};
            obj.LandingGearSimulinkName =  obj.GearVariableSelectionString{obj.GearVariableSelectionValue};
            
            obj.FlapSimulinkVal = obj.FlapVariableSelectionValue;
            obj.LandingGearSimulinkVal = obj.GearVariableSelectionValue;
            
            %obj = trimSettings;
            
            update(obj);
            updateTable( obj );
        end % createDefault
        
        function updateMdlConditions( obj , simMdlName )
            
            if nargin == 2
               obj.ModelName = simMdlName; 
            end
            
            mdl = obj.ModelName;
            if isempty(mdl)
                error('A Simulink Model must be avaliable');
            end
            
              
            [inNames , outNames , stateNames , stateDerivNames , inputUnits , outputUnits , stateUnit , stateDotUnit, cStateID] = Utilities.getNamesFromModel( mdl );
            
            [inC,outC,stC,stdC,cStateIDC,obj] = privateUpdateMdlCond( obj ,inNames' , outNames' , stateNames , inputUnits , outputUnits , stateUnit, cStateID);
            obj.StateDerivatives = stdC;
            obj.Outputs          = outC;
            obj.States           = stC;
            obj.Inputs           = inC;
            obj.CStateID         = cStateIDC;

            if ~isempty(obj.InitialTrim)
                [inCInit,outCInit,stCInit,stdCInit,cStateIDInit,obj] = privateUpdateMdlCondIC( obj, inNames' , outNames' , stateNames , inputUnits , outputUnits , stateUnit, cStateID);
                obj.InitialTrim.StateDerivatives = stdCInit;
                obj.InitialTrim.Outputs          = outCInit;
                obj.InitialTrim.States           = stCInit;
                obj.InitialTrim.Inputs           = inCInit;
                obj.InitialTrim.CStateID         = cStateIDInit;
            end
            
           
        end % updateMdlConditions

    end
      
    %% Methods - Protected
    methods (Access = protected)  
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the InitialTrim object
            cpObj.InitialTrim = copy(obj.InitialTrim);         
            % Make a deep copy of the StateDerivatives object
            cpObj.StateDerivatives = copy(obj.StateDerivatives); 
            % Make a deep copy of the Outputs object
            cpObj.Outputs = copy(obj.Outputs);
            % Make a deep copy of the States object
            cpObj.States = copy(obj.States);
            % Make a deep copy of the Inputs object
            cpObj.Inputs = copy(obj.Inputs);
            
        end % copyElement
        
    end
end
