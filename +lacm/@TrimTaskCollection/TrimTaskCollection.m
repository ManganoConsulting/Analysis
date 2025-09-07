classdef TrimTaskCollection < dynamicprops & matlab.mixin.Copyable %& UserInterface.GraphicsObject   
    %% Public properties - Data Storage
    properties 
        %TrimTask lacm.TrimSettings %lacm.TrimTask
        Label
        SelectedMassProperties = lacm.MassProperties.empty
        SelectedTrimDef = lacm.TrimSettings.empty
        SelectedLinMdlDef = lacm.LinearModel.empty
        SelectedSimulinkModel
        SelectedConstantsFile
        
        FlapSettingString
        
        SelectedLandingDown logical = false

        
        NumberTrimEqTableTrim1Data
        NumberTrimEqTableTrim2Data
        LonVarText1
        LatVarText1
        LonVarText2
        LatVarText2
        TrimEq_text
        
        TrimEq_text1
        TrimEq_text2
        
        BasicTableMassPropHeaderData = {' '}
        BasicTableMassPropColumnWidth = {20}
        BasicTableMassPropColumnEditable = true
        BasicTableMassPropColumnFormat = {'Logical'}
        BasicTableMassPropRowName = []
        BasicTableRowSelectedLA = false
        
        MassPropertiesObjects
        
        FlapText = 'Flap'
        GearText = 'Landing Gear'
        
        UUID
    end % Public properties
    
    %% View Properties
    properties( Hidden = true , Transient = true )
        Container
        
        NumberTrimEqTableTrim1
        NumberTrimEqTableTrim2
        NumberTrimEqTableTrimBasic1
        NumberTrimEqTableTrimBasic2
        BasicTrimPanel
        AdvancedTrimPanel
        TrimInputTypeTabPanel
        Flap_text
        ACconfig_text

        FCLabel
        FC1_pm
        FC1_eb
        FC2_pm
        FC2_eb
        SetName_text
        SetName_eb

        
  
        
        Input1Table
        Output1Table
        State1Table
        StateDerivs1Table
        
        Input2Table
        Output2Table
        State2Table
        StateDerivs2Table
        

        OverWriteInputVar_text

        TabPanel1
        TabInputs1
        TabOutputs1
        TabStates1
        TabStatesDerivs1
        
        TabPanel2
        TabInputs2
        TabOutputs2
        TabStates2
        TabStatesDerivs2
        
        TabPanelTrim
        TabTrim1
        TabTrim2
        Flap_eb
        
        CongButtonGroup
        CongfigUP
        CongfigDN
        
        BasicTableLon1
        BasicTableLat1
        
        BasicTableLon2
        BasicTableLat2
        FC1_units
        FC2_units
        
        BasicTableMassProp
        MassProp_text
        

        
        BasicTabPanelTrim
        BasicTabTrim1
        BasicTabTrim2
    end
    
    %% Private properties
    properties (Access = private)  
        BasicTableMassPropData =  {}
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        %Figure
        
        ScalarParameterInput1
        ScalarParameterOutput1
        ScalarParameterState1
        ScalarParameterStateDerivs1
        
        ScalarParameterInput2
        ScalarParameterOutput2
        ScalarParameterState2
        ScalarParameterStateDerivs2
        
        VectorParameterInput1
        VectorParameterOutput1
        VectorParameterState1
        VectorParameterStateDerivs1
        
        VectorParameterInput2
        VectorParameterOutput2
        VectorParameterState2
        VectorParameterStateDerivs2
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        OverwriteVariablesInput1
        OverwriteVariablesOutput1
        OverwriteVariablesState1
        OverwriteVariablesStateDerivs1
        
        TargetVariablesInput1
        TargetVariablesOutput1
        TargetVariablesState1
        TargetVariablesStateDerivs1
        
        OverwriteVariablesInput2
        OverwriteVariablesOutput2
        OverwriteVariablesState2
        OverwriteVariablesStateDerivs2
        
        TargetVariablesInput2
        TargetVariablesOutput2
        TargetVariablesState2
        TargetVariablesStateDerivs2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        WC_EB_String
        
        Input1TableData
        Output1TableData
        State1TableData
        StateDerivs1TableData
        
        Input2TableData
        Output2TableData
        State2TableData
        StateDerivs2TableData
        
        EnableTrimTwo
        EnableGear
        EnableFlap
        
        FC1_Units
        FC2_Units
        
        SelectedMassPropArray 
        BasicTableDisplayData
    end % Dependant properties

    %% Data Storage Properties
    properties( Hidden = true )
        FC1_PM_String = {'KCAS','Alt','Mach','Qbar','KEAS'};
        FC1_PM_SelValue = 3
        FC2_PM_String = {'KCAS','Alt','Mach','Qbar','KEAS'};
        FC2_PM_SelValue = 2
        
        FC1_EB_String
        FC2_EB_String

        FC_IndexMatch logical = false

        UnitsSystem = 1 % 1 = english , 2 = metric
        
        SetName_String
        
        InputAllNames = {}
        OutputAllNames = {}
        StatesAllNames = {}
        StatesDerivsAllNames = {}
        
        Input1InitialCondition
        Output1InitialCondition
        State1InitialCondition
        StateDerivs1InitialCondition
        
        Inputs1Fixed
        Outputs1Fixed
        States1Fixed
        StatesDerivs1Fixed
        
        Input2InitialCondition
        Output2InitialCondition
        State2InitialCondition
        StateDerivs2InitialCondition
        
        Inputs2Fixed
        Outputs2Fixed
        States2Fixed
        StatesDerivs2Fixed
        
        
    end

    %% Constant properties
    properties (Constant) 
 
    end % Constant properties  
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        Add2Batch
        LabelUpdated
    end

    %% Methods - Constructor
    methods      
        function obj = TrimTaskCollection(varargin)
            switch nargin
                case 0
                case 1

                case 2
                    % Create for View
                    parent = varargin{1};
                    weightcodes = varargin{2};
                    obj = lacm.TrimTaskCollection(); 
                    createView( obj , weightcodes , parent );
                case 3
                    % Create for View
                    parent = varargin{1};
                    weightcodes = varargin{2};
                    obj = lacm.TrimTaskCollection(); 
                    createView( obj , weightcodes , parent );
                    obj.SetName_String = varargin{3};
                otherwise

            end
            
        end % TrimTaskCollection
    end % Constructor

    %% Methods - Property Access  
    methods
        
        function y = get.BasicTableDisplayData( obj )
            
            y = obj.BasicTableMassPropData;
            y(:,1) = num2cell(obj.BasicTableRowSelectedLA);

        end % BasicTableMassPropHeaderData
        
        function y = get.SelectedMassPropArray( obj )
            data = obj.BasicTableMassProp.Data(:,1);
            y = cell2mat(data);
        end % SelectedMassPropArray
        
        function y = get.FC1_Units( obj )
            switch obj.UnitsSystem
                case 1
                    switch obj.FC1_PM_SelValue
                        case 1
                            y = 'knots';
                        case 2
                            y = 'ft';
                        case 3
                            y = '-';
                        case 4
                            y = 'psf';
                        case 5
                            y = 'knots';
                    end
                case 2
                    switch obj.FC1_PM_SelValue
                        case 1
                            y = 'knots';
                        case 2
                            y = 'm';
                        case 3
                            y = '-';
                        case 4
                            y = 'Pa';
                        case 5
                            y = 'knots';
                    end
            end
        end % FC1_Units
        
        function y = get.FC2_Units( obj )
            switch obj.UnitsSystem
                case 1
                    switch obj.FC2_PM_SelValue
                        case 1
                            y = 'knots';
                        case 2
                            y = 'ft';
                        case 3
                            y = '-';
                        case 4
                            y = 'psf';
                        case 5
                            y = 'knots';
                    end
                case 2
                    switch obj.FC2_PM_SelValue
                        case 1
                            y = 'knots';
                        case 2
                            y = 'm';
                        case 3
                            y = '-';
                        case 4
                            y = 'Pa';
                        case 5
                            y = 'knots';
                    end
            end
        end % FC2_Units
        
        function y = get.ScalarParameterInput1( obj )
            tableData = obj.Input1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterInput1

        function y = get.ScalarParameterOutput1( obj )
            tableData = obj.Output1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterOutput1
        
        function y = get.ScalarParameterState1( obj )
            tableData = obj.State1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterState1
        
        function y = get.ScalarParameterStateDerivs1( obj )
            tableData = obj.StateDerivs1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterStateDerivs1
        
        function y = get.ScalarParameterInput2( obj )
            tableData = obj.Input2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterInput2

        function y = get.ScalarParameterOutput2( obj )
            tableData = obj.Output2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterOutput2
        
        function y = get.ScalarParameterState2( obj )
            tableData = obj.State2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterState2
        
        function y = get.ScalarParameterStateDerivs2( obj )
            tableData = obj.StateDerivs2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) 
                    y(end+1) = lacm.Condition( tableData{i,1} , str2double(tableData{i,2}) , [] , tableData{i,3} , false );
                elseif ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        isempty(str2num(tableData{i,2}))
                    y(end+1) = lacm.Condition( tableData{i,1} , [] , [] , tableData{i,3} , true );
                end
            
            end
        end % ScalarParameterStateDerivs2
        
        function y = get.VectorParameterInput1( obj )
            tableData = obj.Input1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterInput1

        function y = get.VectorParameterOutput1( obj )
            tableData = obj.Output1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterOutput1
        
        function y = get.VectorParameterState1( obj )
            tableData = obj.State1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterState1
        
        function y = get.VectorParameterStateDerivs1( obj )
            tableData = obj.StateDerivs1TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterStateDerivs1
        
        function y = get.VectorParameterInput2( obj )
            tableData = obj.Input2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterInput2

        function y = get.VectorParameterOutput2( obj )
            tableData = obj.Output2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterOutput2
        
        function y = get.VectorParameterState2( obj )
            tableData = obj.State2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterState2
        
        function y = get.VectorParameterStateDerivs2( obj )
            tableData = obj.StateDerivs2TableData;
            y = lacm.Condition.empty;
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM> 
                    y(end+1) = lacm.Condition( tableData{i,1} , tableData{i,2} , [] , tableData{i,3});
                end
            
            end
        end % VectorParameterStateDerivs2      
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

        function y = get.EnableTrimTwo( obj )
            if isempty(obj.SelectedTrimDef)
                y = 'on';
            else
                if isempty(obj.SelectedTrimDef.InitialTrim)
                    y = 'off';
                else
                    y = 'on';
                end
            end
        end % EnableTrimTwo
        
        function y = get.EnableGear( obj )
            if isempty(obj.SelectedTrimDef)
                y = 'on';
            else
                if isempty(obj.SelectedTrimDef.LandingGearSimulinkName)
                    y = 'off';
                else
                    y = 'on';
                end
            end
        end % EnableGear
        
        function y = get.EnableFlap( obj )
            if isempty(obj.SelectedTrimDef)
                y = 'on';
            else
                if isempty(obj.SelectedTrimDef.FlapSimulinkName)
                    y = 'off';
                else
                    y = 'on';
                end
            end
        end % EnableFlap
        
        function y = get.WC_EB_String( obj )
            if isempty(obj.SelectedMassProperties)
                y = [];
            else
                y = strjoin({obj.SelectedMassProperties.WeightCode},',');
            end
        end                  
        
        function y = get.OverwriteVariablesInput1( obj )
            tableData = obj.Input1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesInput1

        function y = get.OverwriteVariablesOutput1( obj )
            tableData = obj.Output1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesOutput1
        
        function y = get.OverwriteVariablesState1( obj )
            tableData = obj.State1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesState1
        
        function y = get.OverwriteVariablesStateDerivs1( obj )
            tableData = obj.StateDerivs1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesStateDerivs1
        
        function y = get.TargetVariablesInput1( obj )
            tableData = obj.Input1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesInput1

        function y = get.TargetVariablesOutput1( obj )
            tableData = obj.Output1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesOutput1
        
        function y = get.TargetVariablesState1( obj )
            tableData = obj.State1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesState1
        
        function y = get.TargetVariablesStateDerivs1( obj )
            tableData = obj.StateDerivs1TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesStateDerivs1
        
        function y = get.Input1TableData( obj )
            y  = [ obj.InputAllNames , obj.Input1InitialCondition ,  num2cell(obj.Inputs1Fixed ) ];
        end % Input1TableData
    
        function y = get.Output1TableData( obj )
            y  = [ obj.OutputAllNames , obj.Output1InitialCondition ,  num2cell(obj.Outputs1Fixed) ];
        end % Output1TableData
        
        function y = get.State1TableData( obj )
            y  = [ obj.StatesAllNames , obj.State1InitialCondition ,  num2cell(obj.States1Fixed) ];
        end % State1TableData  
        
        function y = get.StateDerivs1TableData( obj )
            y  = [ obj.StatesDerivsAllNames , obj.StateDerivs1InitialCondition ,  num2cell(obj.StatesDerivs1Fixed) ];
        end % State1TableData
        
        function y = get.OverwriteVariablesInput2( obj )
            tableData = obj.Input2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesInput2

        function y = get.OverwriteVariablesOutput2( obj )
            tableData = obj.Output2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesOutput2
        
        function y = get.OverwriteVariablesState2( obj )
            tableData = obj.State2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesState2
        
        function y = get.OverwriteVariablesStateDerivs2( obj )
            tableData = obj.StateDerivs2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        isscalar(str2num(tableData{i,2})) &&...
                        str2num(tableData{i,2}) ~= 0%#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % OverwriteVariablesStateDerivs2
        
        function y = get.TargetVariablesInput2( obj )
            tableData = obj.Input2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesInput2

        function y = get.TargetVariablesOutput2( obj )
            tableData = obj.Output2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesOutput2
        
        function y = get.TargetVariablesState2( obj )
            tableData = obj.State2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesState2
        
        function y = get.TargetVariablesStateDerivs2( obj )
            tableData = obj.StateDerivs2TableData;
            y = struct('Name',{},'Value',{});
            for i = 1:size(tableData,1)
                if ~isempty(tableData{i,1}) &&...
                        ~isempty(tableData{i,2}) &&...
                        ~isempty(str2num(tableData{i,2})) &&...
                        length(str2num(tableData{i,2})) > 1 %#ok<*ST2NM>
                    y(end+1) = struct('Name',tableData{i,1},'Value',tableData{i,2});
                end
            
            end
        end % TargetVariablesStateDerivs2
        
        function y = get.Input2TableData( obj )
            y  = [ obj.InputAllNames , obj.Input2InitialCondition ,  num2cell(obj.Inputs2Fixed ) ];
        end % Input2TableData
    
        function y = get.Output2TableData( obj )
            y  = [ obj.OutputAllNames , obj.Output2InitialCondition ,  num2cell(obj.Outputs2Fixed) ];
        end % Output2TableData
        
        function y = get.State2TableData( obj )
            y  = [ obj.StatesAllNames , obj.State2InitialCondition ,  num2cell(obj.States2Fixed) ];
        end % State2TableData  
        
        function y = get.StateDerivs2TableData( obj )
            y  = [ obj.StatesDerivsAllNames , obj.StateDerivs2InitialCondition ,  num2cell(obj.StatesDerivs2Fixed) ];
        end % StateDerivs2TableData  
        
    end % Property access methods
    
    %% Methods - View
    methods 
        
        function createView(obj,weightCodes,parent)
            if nargin == 2
                parent = figure('Name','',...
                                'units','normalized',...
                                'Menubar','none',...   
                                'Toolbar','none',...
                                'NumberTitle','off',...
                                'HandleVisibility', 'on',...
                                'Visible','on');
                
            end 
            obj.Container = uicontainer('Parent',parent,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ]);
            set(obj.Container,'ResizeFcn',@obj.createTaskViewResize);
            % get figure position
            parentPos = getpixelposition(obj.Container);

            % Row 1
            obj.FCLabel = uicontrol(...
                'Parent',obj.Container,...
                'Style','text',...
                'String', 'Flight Condition:',...
                'FontSize',9,...
                'FontWeight','normal',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 20 , parentPos(3) - 10 , 20 ]);
            % Row 2
            obj.FC1_pm = uicontrol(...
                'Parent',obj.Container,...
                'FontSize',9,...
                'Style','popupmenu',...
                'String', {'KCAS','Alt','Mach','Qbar','KTAS','KEAS'},...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 42 , 80 , 42 ],...
                'Callback',@obj.fc1_CB);
            obj.FC1_eb = uicontrol(...
                'Parent',obj.Container,...
                'FontSize',9,...
                'Style','edit',...
                'String', '',...
                'Units','Pixels',...
                'Position',[ 95 , parentPos(4) - 42 , 70 , 42 ],...
                'BackgroundColor', [1 1 1],...
                'Callback',@obj.fc1Value_CB);
            obj.FC1_units = uicontrol(...
                'Parent',obj.Container,...
                'FontSize',9,...
                'Style','text',...
                'String', obj.FC1_Units,...
                'Units','Pixels',...
                'Position',[ 170 , parentPos(4) - 42 , 30 , 42 ]);
            
            % Row 3
            obj.FC2_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',9,...
                'String', {'KCAS','Alt','Mach','Qbar','KTAS','KEAS'},...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 66 , 80 , 22 ],...
                'Callback',@obj.fc2_CB);
            obj.FC2_eb = uicontrol(...
                'Parent',obj.Container,...
                'Style','edit',...
                'FontSize',9,...
                'String', '',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 95 , parentPos(4) - 66 , 70 , 22 ],...
                'Callback',@obj.fc2Value_CB);
            obj.FC2_units = uicontrol(...
                'Parent',obj.Container,...
                'Style','text',...
                'FontSize',9,...
                'String', obj.FC2_Units,...
                'Units','Pixels',...
                'Position',[ 170 , parentPos(4) - 66 , 30 , 22 ]);
            
            
            
           obj.TrimInputTypeTabPanel = uitabgroup('Parent',obj.Container);
           obj.TrimInputTypeTabPanel.TabLocation = 'Bottom';
                obj.BasicTrimPanel   = uitab('Parent',obj.TrimInputTypeTabPanel);
                obj.BasicTrimPanel.Title = 'Basic';

                obj.AdvancedTrimPanel   = uitab('Parent',obj.TrimInputTypeTabPanel);
                obj.AdvancedTrimPanel.Title = 'Advanced';
%%%%%%%%%%%% Basic Trim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
            obj.Flap_text = uicontrol(...
                'Parent',obj.BasicTrimPanel,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'String', obj.FlapText,...
                'FontSize',9,...
                'FontWeight','normal');  
            obj.Flap_eb = uicontrol(...
                'Parent',obj.BasicTrimPanel,...
                'FontSize',9,...
                'Style','edit',...
                'String', '',...
                'BackgroundColor', [1 1 1],...
                'Callback',@obj.flapSetting_CB);
            
            obj.ACconfig_text = uicontrol(...
                'Parent',obj.BasicTrimPanel,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'String', obj.GearText,...
                'FontSize',9,...
                'FontWeight','normal');   
            
            obj.CongButtonGroup = uibuttongroup('Parent',obj.BasicTrimPanel,...
                    'Visible','off',...
                    'BorderType','line',...
                    'SelectionChangedFcn',@obj.landingGear_CB);

            % Create three radio buttons in the button group.
            obj.CongfigUP = uicontrol('Parent',obj.CongButtonGroup,...
                              'Style',...
                              'radiobutton',...
                              'String','Gear Up',...
                              'HandleVisibility','off',...
                              'UserData',false);

            obj.CongfigDN = uicontrol('Parent',obj.CongButtonGroup,...
                              'Style','radiobutton',...
                              'String','Gear Down',...
                              'Position',[10 250 100 30],...
                              'HandleVisibility','off',...
                              'UserData',true);


            % Make the uibuttongroup visible after creating child objects. 
            obj.CongButtonGroup.Visible = 'on';
            
            % Mass Properties Table
            obj.BasicTableMassProp = uitable('Parent',obj.BasicTrimPanel,...
                'ColumnName',obj.BasicTableMassPropHeaderData,...
                'RowName',obj.BasicTableMassPropRowName,...
                'ColumnEditable', obj.BasicTableMassPropColumnEditable,...
                'ColumnFormat',obj.BasicTableMassPropColumnFormat,...
                'ColumnWidth',obj.BasicTableMassPropColumnWidth,...
                'Data',obj.BasicTableDisplayData,...
                'CellEditCallback', @obj.basicTableMP_ce_CB,...
                'CellSelectionCallback', @obj.basicTableMP_cs_CB);   
            
           %%%%% Basic Trim Panels %%%%%%%%%%%%%%%%%%%%%
           obj.BasicTabPanelTrim = uitabgroup('Parent',obj.BasicTrimPanel);
           obj.BasicTabPanelTrim.TabLocation = 'Bottom';
                obj.BasicTabTrim1   = uitab('Parent',obj.BasicTabPanelTrim);
                obj.BasicTabTrim1.Title = 'Trim 1';

                obj.BasicTabTrim2   = uitab('Parent',obj.BasicTabPanelTrim);
                obj.BasicTabTrim2.Title = 'Trim 2'; 
            %%%% Basic Trim 1 %%%
            obj.LonVarText1 =uicontrol(...
                'Parent',obj.BasicTabTrim1,...
                'Style','text',...
                'String', 'Longitudinal:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            obj.BasicTableLon1 = uitable('Parent',obj.BasicTabTrim1,...
                'ColumnName',{'Variable','Value','Fix','Type'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , false ],...
                'ColumnFormat',{'Char','Char','Logical','Char'},...
                'ColumnWidth',{110,80,20,80},...
                'Data',[],...
                'CellEditCallback', @obj.basicTable_ce_CB,...
                'CellSelectionCallback', @obj.basicTable_cs_CB);  
            obj.LatVarText1 = uicontrol(...
                'Parent',obj.BasicTabTrim1,...
                'Style','text',...
                'String', 'Lateral Directional:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            obj.BasicTableLat1 = uitable('Parent',obj.BasicTabTrim1,...
                'ColumnName',{'Variable','Value','Fix','Type'},...
                'RowName',[],...
                'ColumnEditable', [ false , true  , true , false ],...
                'ColumnFormat',{'Char','Char','Logical','Char'},...
                'ColumnWidth',{110,80,20,80},...
                'Data',[],...
                'CellEditCallback', @obj.basicTable_ce_CB,...
                'CellSelectionCallback', @obj.basicTable_cs_CB); 
            obj.NumberTrimEqTableTrimBasic1 = uitable('Parent',obj.BasicTabTrim1,...
                'ColumnName',{'Trim Variables','Trim Equations'},...
                'RowName',[],...
                'ColumnEditable', [ false , false ],...
                'ColumnFormat',{'Char','Char'},...
                'ColumnWidth',{140,140},...
                'Data',obj.NumberTrimEqTableTrim2Data,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ]); 
            
            %%% Basic Trim 2 %%%%
            obj.LonVarText2 =uicontrol(...
                'Parent',obj.BasicTabTrim2,...
                'Style','text',...
                'String', 'Longitudinal:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            obj.BasicTableLon2 = uitable('Parent',obj.BasicTabTrim2,...
                'ColumnName',{'Variable','Value','Fix','Type'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , false ],...
                'ColumnFormat',{'Char','Char','Logical','Char'},...
                'ColumnWidth',{110,80,20,80},...
                'Data',[],...
                'CellEditCallback', @obj.basicTable_ce_CB,...
                'CellSelectionCallback', @obj.basicTable_cs_CB);  
            obj.LatVarText2 = uicontrol(...
                'Parent',obj.BasicTabTrim2,...
                'Style','text',...
                'String', 'Lateral Directional:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            obj.BasicTableLat2 = uitable('Parent',obj.BasicTabTrim2,...
                'ColumnName',{'Variable','Value','Fix','Type'},...
                'RowName',[],...
                'ColumnEditable', [ false , true  , true , false ],...
                'ColumnFormat',{'Char','Char','Logical','Char'},...
                'ColumnWidth',{110,80,20,80},...
                'Data',[],...
                'CellEditCallback', @obj.basicTable_ce_CB,...
                'CellSelectionCallback', @obj.basicTable_cs_CB); 
            obj.NumberTrimEqTableTrimBasic2 = uitable('Parent',obj.BasicTabTrim2,...
                'ColumnName',{'Trim Variables','Trim Equations'},...
                'RowName',[],...
                'ColumnEditable', [ false , false ],...
                'ColumnFormat',{'Char','Char'},...
                'ColumnWidth',{140,140},...
                'Data',obj.NumberTrimEqTableTrim2Data,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ]);  

            
            
            
            

            obj.MassProp_text = uicontrol(...
                'Parent',obj.BasicTrimPanel,...
                'Style','text',...
                'String', 'Mass Properties:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');     
%%%%%%%%%%%% Advanced Trim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            obj.OverWriteInputVar_text = uicontrol(...
                'Parent',obj.AdvancedTrimPanel,...
                'Style','text',...
                'HorizontalAlignment','left',...
                'String', 'Set Trim Conditions:',...
                'FontSize',8,...
                'FontWeight','normal',...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 132 , parentPos(3) - 10 , 22 ]);
    
           obj.TabPanelTrim = uitabgroup('Parent',obj.AdvancedTrimPanel);
           obj.TabPanelTrim.TabLocation = 'Bottom';
                obj.TabTrim1   = uitab('Parent',obj.TabPanelTrim);
                obj.TabTrim1.Title = 'Trim 1';

                obj.TabTrim2   = uitab('Parent',obj.TabPanelTrim);
                obj.TabTrim2.Title = 'Trim 2';
                
            
            
           obj.TabPanel1 = uitabgroup('Parent',obj.TabTrim1);
                obj.TabInputs1   = uitab('Parent',obj.TabPanel1);
                obj.TabInputs1.Title = ' Inputs';

                obj.TabOutputs1   = uitab('Parent',obj.TabPanel1);
                obj.TabOutputs1.Title = 'Outputs';
                
                obj.TabStates1   = uitab('Parent',obj.TabPanel1);
                obj.TabStates1.Title = 'States';
                
                obj.TabStatesDerivs1   = uitab('Parent',obj.TabPanel1);
                obj.TabStatesDerivs1.Title = 'State Derivs';
                
            % Row 7
            obj.Input1Table = uitable('Parent',obj.TabInputs1,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.Input1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.inputTable1_ce_CB,...
                'CellSelectionCallback', @obj.inputTable1_cs_CB);   

            obj.Output1Table = uitable('Parent',obj.TabOutputs1,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.Output1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.outputTable1_ce_CB,...
                'CellSelectionCallback', @obj.outputTable1_cs_CB); 
            obj.State1Table = uitable('Parent',obj.TabStates1,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.State1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateTable1_ce_CB,...
                'CellSelectionCallback', @obj.stateTable1_cs_CB); 
            
            obj.StateDerivs1Table = uitable('Parent',obj.TabStatesDerivs1,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.StateDerivs1TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateDerivsTable1_ce_CB,...
                'CellSelectionCallback', @obj.stateDerivsTable1_cs_CB); 
            
           obj.TabPanel2 = uitabgroup('Parent',obj.TabTrim2);
                obj.TabInputs2   = uitab('Parent',obj.TabPanel2);
                obj.TabInputs2.Title = ' Inputs';

                obj.TabOutputs2   = uitab('Parent',obj.TabPanel2);
                obj.TabOutputs2.Title = 'Outputs';
                
                obj.TabStates2   = uitab('Parent',obj.TabPanel2);
                obj.TabStates2.Title = 'States';
                
                obj.TabStatesDerivs2   = uitab('Parent',obj.TabPanel2);
                obj.TabStatesDerivs2.Title = 'State Derivs';
                
                
            % Row 7
            obj.Input2Table = uitable('Parent',obj.TabInputs2,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.Input2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.inputTable2_ce_CB,...
                'CellSelectionCallback', @obj.inputTable2_cs_CB);   

            obj.Output2Table = uitable('Parent',obj.TabOutputs2,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.Output2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.outputTable2_ce_CB,...
                'CellSelectionCallback', @obj.outputTable2_cs_CB); 
            obj.State2Table = uitable('Parent',obj.TabStates2,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.State2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateTable2_ce_CB,...
                'CellSelectionCallback', @obj.stateTable2_cs_CB); 
            
            obj.StateDerivs2Table = uitable('Parent',obj.TabStatesDerivs2,...
                'ColumnName',{'Variable','Value','Fix','Basic'},...
                'RowName',[],...
                'ColumnEditable', [ false , true , true , true ],...
                'ColumnFormat',{'Char','Char','Logical',{'None','Longitudinal','LateralDirectional'}},...
                'ColumnWidth',{80,80,20,100},...
                'Data',obj.StateDerivs2TableData,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateDerivsTable2_ce_CB,...
                'CellSelectionCallback', @obj.stateDerivsTable2_cs_CB); 
            
            
            
            
            

            
        
            obj.TrimEq_text1 = uicontrol(...
                'Parent',obj.TabTrim1,...
                'Style','text',...
                'String', 'Trim Variables/Equations:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            obj.TrimEq_text2 = uicontrol(...
                'Parent',obj.TabTrim2,...
                'Style','text',...
                'String', 'Trim Variables/Equations:',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left');
            
            
            
            % Row 9
            obj.SetName_text = uicontrol(...
                'Parent',obj.Container,...
                'Style','text',...
                'String', 'Label',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 244 , parentPos(3) - 10 , 20 ],...
                'Callback','');
            
            %Row 10
            obj.SetName_eb = uicontrol(...
                'Parent',obj.Container,...
                'Style','edit',...
                'String', '',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 10 , parentPos(4) - 266 , 205 , 22 ],...
                'Callback',@obj.setName_CB);
 

        
        
            obj.NumberTrimEqTableTrim1 = uitable('Parent',obj.TabTrim1,...
                'ColumnName',{'Trim Variables','Trim Equations'},...
                'RowName',[],...
                'ColumnEditable', [ false , false ],...
                'ColumnFormat',{'Char','Char'},...
                'ColumnWidth',{140,140},...
                'Data',obj.NumberTrimEqTableTrim1Data,...
                'Units','Pixels',...
                'Position',[ 0 , 0 , 1 , 1 ]);  
            
            obj.NumberTrimEqTableTrim2 = uitable('Parent',obj.TabTrim2,...
                'ColumnName',{'Trim Variables','Trim Equations'},...
                'RowName',[],...
                'ColumnEditable', [ false , false ],...
                'ColumnFormat',{'Char','Char'},...
                'ColumnWidth',{140,140},...
                'Data',obj.NumberTrimEqTableTrim2Data,...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ]); 
            
 
            createTaskViewResize( obj , [] , [] );
            updateDisplay(obj);
        end % createView
 
    end % Protected View Methods
    
    %% Methods - Callbacks
    methods 
                
        function basicTableMP_ce_CB(obj , hobj , eventData )      
            selRow = eventData.Indices(1);
            selCol = eventData.Indices(2);
           
            switch selCol
                case 1
                    obj.BasicTableRowSelectedLA(selRow) = eventData.NewData;
                case 2
                    obj.MassPropertiesObjects(selRow).WeightCode = eventData.NewData;
                case 3
                    obj.MassPropertiesObjects(selRow).Label = eventData.NewData;
                otherwise
                    obj.MassPropertiesObjects(selRow).Parameter.get(obj.BasicTableMassProp.ColumnName(selCol)).Value = eventData.NewData;                           
            end
            
        end % basicTableMP_ce_CB

        function basicTableMP_cs_CB( obj , ~ , ~ )
   

        end % basicTableMP_cs_CB        
  
        function basicTable_ce_CB(obj , hobj , eventData )
            trimdef = obj.SelectedTrimDef;
            
            selRow = eventData.Indices(1);
            selCol = eventData.Indices(2);
            
            simPortName = hobj.Data{selRow,1};
            simPortType = hobj.Data{selRow,4};
            
            index = trimdef.(simPortType).find(simPortName);
            
            
            switch eventData.Indices(2)
                case 2
                    trimdef.(simPortType)(index).Value = eventData.EditData;
                case 3
                    trimdef.(simPortType)(index).Fix = eventData.EditData;
            end
            obj.updateDisplay(9);
        end % basicTable_ce_CB

        function basicTable_cs_CB( obj , ~ , ~ )
   

        end % basicTable_cs_CB
        
        function landingGear_CB( obj , h , ~ )
            trimdef = obj.SelectedTrimDef;
            if isempty(trimdef)
                updateDisplay(obj);
                return;
            end
            
            hobj = get(h,'SelectedObject');
            obj.SelectedLandingDown   = hobj.UserData;
            
            simPortName = trimdef.LandingGearSimulinkName;
            simPortType = 'Inputs';            
            index = trimdef.(simPortType).find(simPortName);
            
            
            if obj.SelectedLandingDown  %strcmp(obj.SelectedLandingDown.String,'Gear Down')
                trimdef.(simPortType)(index).Value = 1;
            else%if strcmp(obj.SelectedLandingDown.String,'Gear Up')
                trimdef.(simPortType)(index).Value = 0;
            end
            
            trimdef.(simPortType)(index).Fix   = true;
            
            updateDisplay(obj);
        end % landingGear_CB  
        
        function flapSetting_CB( obj , h , ~ )
%             trimdef = obj.SelectedTrimDef;
            if isempty(obj.SelectedTrimDef)
                updateDisplay(obj);
                return;
            end
            
            if ~isempty(obj.SelectedTrimDef.InitialTrim)
                trimdef = obj.SelectedTrimDef.InitialTrim;
            else
                trimdef = obj.SelectedTrimDef;
            end
            
            flapSettingStr   = get(h,'String');
            flapSetting  = str2num(flapSettingStr);
            
            if ~isempty(flapSetting)
                obj.FlapSettingString   = flapSettingStr;
            end
            
            
            simPortName = trimdef.FlapSimulinkName;
            simPortType = 'Inputs';            
            index = trimdef.(simPortType).find(simPortName);
            trimdef.(simPortType)(index).Value = flapSetting;
            trimdef.(simPortType)(index).Fix   = true;
            updateDisplay(obj);
        end % flapSetting_CB  
        
        function fc1_CB( obj , h , ~ )
            
            fC1_PM_String   = get(h,'String');
            fC1_PM_SelValue = get(h,'Value'); 
            
            status = checkFlightCondition(fC1_PM_SelValue, obj.FC2_PM_SelValue);
            
            if status == 0
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Incorrect combination of flight conditions.','error'));
            else
                obj.FC1_PM_String   = fC1_PM_String;
                obj.FC1_PM_SelValue = fC1_PM_SelValue;   
            end
            updateDisplay(obj);
        end % fc1_CB
        
        function fc1Value_CB( obj , h , ~ )
            % Only allow strings that can be converted to a scalar number
            tempStr = get(h,'String');
            if isempty(str2num(tempStr))  || any(isnan(str2num(tempStr)))
                obj.FC1_EB_String = '';
            else
                obj.FC1_EB_String = tempStr;
            end
            updateDisplay(obj);
        end % fc1Value_CB

        function fc2_CB( obj , h , ~ )
            
            fC2_PM_String   = get(h,'String');
            fC2_PM_SelValue = get(h,'Value'); 
            
            status = checkFlightCondition(fC2_PM_SelValue, obj.FC1_PM_SelValue);
            
            if status == 0
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Incorrect combination of flight conditions.','error'));
            else
                obj.FC2_PM_String   = fC2_PM_String;
                obj.FC2_PM_SelValue = fC2_PM_SelValue; 
            end
            updateDisplay(obj);
        end % fc2_CB
        
        function fc2Value_CB( obj , h , ~ )
            % Only allow strings that can be converted to a scalar number
            tempStr = get(h,'String');
            if isempty(str2num(tempStr))  || any(isnan(str2num(tempStr)))
                obj.FC2_EB_String = '';
            else
                obj.FC2_EB_String = tempStr;
            end 
            updateDisplay(obj);
        end % fc2Value_CB  
        
        function weightCode_CB( obj , hobj , ~ )
            obj.WC_PM_String   = get(hobj,'String');
            obj.WC_PM_SelValue = get(hobj,'Value'); 
            updateDisplay(obj);
        end % weightCode_CB
        
        function setName_CB( obj , h , ~ )
            obj.SetName_String = get(h,'String');
            updateDisplay(obj);
%             notify( obj , 'LabelUpdated' );
            notify( obj , 'LabelUpdated' , UserInterface.UserInterfaceEventData(obj.SetName_String) );
        end % setName_CB
        
        function batchAdd_CB( obj , ~ , ~ )
            notify(obj,'Add2Batch');

        end % batchAdd_CB
                
        function inputTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.Input1InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.Inputs1Fixed(eventData.Indices(1)) = eventData.NewData;
            end
            
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
            
            if strcmp(trimdef.FlapSimulinkName,trimdef.Inputs(eventData.Indices(1)).Name)
                obj.FlapSettingString = num2str(trimdef.Inputs(eventData.Indices(1)).Value);
            elseif strcmp(trimdef.LandingGearSimulinkName,trimdef.Inputs(eventData.Indices(1)).Name)
   
                if trimdef.Inputs(eventData.Indices(1)).Value == 0
                     obj.SelectedLandingDown = false; %obj.CongfigUP;
                else
                    obj.SelectedLandingDown = true; %obj.CongfigDN;
                end
            end
            
            obj.updateDisplay(1);
        end % inputTable1_ce_CB

        function inputTable1_cs_CB( obj , ~ , ~ )
   

        end % inputTable1_cs_CB
        
        function outputTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.Output1InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.Outputs1Fixed(eventData.Indices(1)) = eventData.NewData;
            end
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
            obj.updateDisplay(2);
        end % outputTable1_ce_CB

        function outputTable1_cs_CB( obj , ~ , ~ )
  

        end % outputTable1_cs_CB
        
        function stateTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.State1InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.States1Fixed(eventData.Indices(1)) = eventData.NewData;
            end
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
            obj.updateDisplay(3);
        end % stateTable1_ce_CB

        function stateTable1_cs_CB( obj , ~ , ~ )
  

        end % stateTable1_cs_CB 
        
        function stateDerivsTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.StateDerivs1InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.StatesDerivs1Fixed(eventData.Indices(1)) = eventData.NewData;
            end
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
            obj.updateDisplay(4);
        end % stateDerivsTable1_ce_CB

        function stateDerivsTable1_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable1_cs_CB 
        
        function inputTable2_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.Input2InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.Inputs2Fixed(eventData.Indices(1)) = eventData.NewData;
            end
            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.Inputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.updateDisplay(5);
        end % inputTable2_ce_CB

        function inputTable2_cs_CB( obj , ~ , ~ )
   

        end % inputTable2_cs_CB
        
        function outputTable2_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.Output2InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.Outputs2Fixed(eventData.Indices(1)) = eventData.NewData;
            end
            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.Outputs(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.updateDisplay(6);
        end % outputTable2_ce_CB

        function outputTable2_cs_CB( obj , ~ , ~ )
  

        end % outputTable2_cs_CB
        
        function stateTable2_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.State2InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.States2Fixed(eventData.Indices(1)) = eventData.NewData;
            end
            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.States(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.States(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.States(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.updateDisplay(7);
        end % stateTable2_ce_CB

        function stateTable2_cs_CB( obj , ~ , ~ )
  

        end % stateTable2_cs_CB 
        
        function stateDerivsTable2_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.StateDerivs2InitialCondition{eventData.Indices(1)} = eventData.NewData;
                case 3
                    obj.StatesDerivs2Fixed(eventData.Indices(1)) = eventData.NewData;
            end
            switch eventData.Indices(2)
                case 2
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).Value = eventData.EditData;
                case 3
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).Fix = eventData.EditData;
                case 4
                    obj.SelectedTrimDef.StateDerivatives(eventData.Indices(1)).BasicMode = eventData.EditData;
            end
            obj.updateDisplay(8);
        end % stateDerivsTable2_ce_CB

        function stateDerivsTable2_cs_CB( obj , ~ , ~ )
  

        end % stateDerivsTable2_cs_CB    
        
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function modelUpdated( obj , inName , outNames , stateNames )
            obj.InputAllNames = inName;
            obj.OutputAllNames = outNames;
            obj.StatesAllNames = stateNames;
            obj.StatesDerivsAllNames = cellfun(@(x) [x,'dot'],stateNames,'UniformOutput',false);
            
            if isempty(obj.SelectedTrimDef)
                
                obj.Input1InitialCondition  = cellstr(num2str(zeros(length(obj.InputAllNames),1)));
                obj.Output1InitialCondition = cellstr(num2str(zeros(length(obj.OutputAllNames),1)));
                obj.State1InitialCondition  = cellstr(num2str(zeros(length(obj.StatesAllNames),1)));
                obj.StateDerivs1InitialCondition  = cellstr(num2str(zeros(length(obj.StatesDerivsAllNames),1)));
                
                obj.Inputs1Fixed  = true(length(obj.InputAllNames),1);
                obj.Outputs1Fixed = false(length(obj.OutputAllNames),1);
                obj.States1Fixed  = true(length(obj.StatesAllNames),1);
                obj.StatesDerivs1Fixed  = false(length(obj.StatesDerivsAllNames),1);
                
                obj.Input2InitialCondition  = cellstr(num2str(zeros(length(obj.InputAllNames),1)));
                obj.Output2InitialCondition = cellstr(num2str(zeros(length(obj.OutputAllNames),1)));
                obj.State2InitialCondition  = cellstr(num2str(zeros(length(obj.StatesAllNames),1)));
                obj.StateDerivs2InitialCondition  = cellstr(num2str(zeros(length(obj.StatesDerivsAllNames),1)));
                
                obj.Inputs2Fixed  = true(length(obj.InputAllNames),1);
                obj.Outputs2Fixed = false(length(obj.OutputAllNames),1);
                obj.States2Fixed  = true(length(obj.StatesAllNames),1);
                obj.StatesDerivs2Fixed  = false(length(obj.StatesDerivsAllNames),1);
                
                
            end
            updateDisplay(obj);
        end % modelUpdated
        
        function updateSelectedConfiguration(obj, selectableObj )      
            if isa(selectableObj,'lacm.TrimSettings') 
%                 obj.SelectedTrimDef = copy(selectableObj);
                   obj.SelectedTrimDef = selectableObj;          
                updateDisplay(obj);

            end
            
        end % updateSelectedConfiguration
        
        function tempTrimTask = createTaskObjManual( obj , mdl , constFile , selTrimDef , selLinMdlDef , selMassProp, useIndexBasedComb)
            import Utilities.*

            assert(~isempty(obj.FC1_EB_String),         'FCOND:EMPTY','Flight Conditions must be specified');
            assert(~isempty(str2num(obj.FC1_EB_String)),'FCOND:FORMAT','Flight Conditions must in numeric format');
            assert(~isempty(obj.FC2_EB_String),         'FCOND:EMPTY','Flight Conditions must be specified');
            assert(~isempty(str2num(obj.FC2_EB_String)),'FCOND:FORMAT','Flight Conditions must in numeric format');    
            assert(~isempty(mdl),         'SIM:MISSING','Simulation must be loaded');  
            assert(~isempty(selTrimDef),  'TRIMDEF:NOTSELECTED',  'Trim Definintion must be selected'); 
            assert(~isempty(selMassProp), 'MASSPROP:NOTSELECTED', 'At least 1 Mass Property must be selected'); 
            assert(~isempty(obj.SetName_String), 'SETNAME:MISSING', 'Label is not specified');             
            
            if isempty(selMassProp)
                wc_string = [];
            else
                wc_string = strjoin({selMassProp.WeightCode},',');
            end

            obj.FC_IndexMatch = ~useIndexBasedComb;

            tempTrimTask = createTaskTrim( mdl , constFile , selTrimDef , selLinMdlDef , selMassProp ,...
                obj.FC1_EB_String , obj.FC2_EB_String , obj.FC1_PM_String{obj.FC1_PM_SelValue} , obj.FC2_PM_String{obj.FC2_PM_SelValue} , obj.SetName_String , wc_string , [] , obj.FC_IndexMatch );

        end % createTaskObjManual
        
        function trimTaskObj = createTaskObjBatch( obj , mdl , constFile , trimDefObjs , linMdlDefObjs , massPropObjs , batchTaskObjs )
            import Utilities.*
            
            trimTaskObj = lacm.TrimTask.empty;

            for i = 1:length(batchTaskObjs)
                
                if strcmpi(batchTaskObjs(i).LINMODEL,'Y')
                    tempLinMdlDefObjs = linMdlDefObjs;
                else
                    tempLinMdlDefObjs = lacm.LinearModel.empty;
                end
                
                logArrayTT = strcmp(batchTaskObjs(i).TRIMID,{trimDefObjs.Label});
                selTrimDef = copy(trimDefObjs(logArrayTT)); 
                
                
                % Overwrite Variables 
                
                stateCondOW = selTrimDef.States.get(batchTaskObjs(i).TARGETVAR);     
                if ~isempty(stateCondOW)
                    stateCondOW.Value = batchTaskObjs(i).TARGETVAL; 
                end
                stateDerCondOW = selTrimDef.StateDerivatives.get(batchTaskObjs(i).TARGETVAR);     
                if ~isempty(stateDerCondOW)
                    stateDerCondOW.Value = batchTaskObjs(i).TARGETVAL; 
                end       
                inputCondOW = selTrimDef.Inputs.get(batchTaskObjs(i).TARGETVAR);     
                if ~isempty(inputCondOW)
                    inputCondOW.Value = batchTaskObjs(i).TARGETVAL; 
                end  
                outCondOW = selTrimDef.Outputs.get(batchTaskObjs(i).TARGETVAR);     
                if ~isempty(outCondOW)
                    outCondOW.Value = batchTaskObjs(i).TARGETVAL; 
                end
                
                for m = 1:length(batchTaskObjs(i).VARIABLES)
                    stateCondOW = selTrimDef.States.get(batchTaskObjs(i).VARIABLES(m).Name);     
                    if ~isempty(stateCondOW)
                        stateCondOW.Value = batchTaskObjs(i).VARIABLES(m).Value; 
                    end
                    stateDerCondOW = selTrimDef.StateDerivatives.get(batchTaskObjs(i).VARIABLES(m).Name);     
                    if ~isempty(stateDerCondOW)
                        stateDerCondOW.Value = batchTaskObjs(i).VARIABLES(m).Value; 
                    end       
                    inputCondOW = selTrimDef.Inputs.get(batchTaskObjs(i).VARIABLES(m).Name);     
                    if ~isempty(inputCondOW)
                        inputCondOW.Value = batchTaskObjs(i).VARIABLES(m).Value; 
                    end  
                    outCondOW = selTrimDef.Outputs.get(batchTaskObjs(i).VARIABLES(m).Name);     
                    if ~isempty(outCondOW)
                        outCondOW.Value = batchTaskObjs(i).VARIABLES(m).Value; 
                    end
                end

                 tempTrimTask = createTaskTrim( mdl , constFile , selTrimDef , tempLinMdlDefObjs , massPropObjs ,...
                    batchTaskObjs(i).FLIGHTCONDITION1{2} , batchTaskObjs(i).FLIGHTCONDITION2{2} , batchTaskObjs(i).FLIGHTCONDITION1{1}, batchTaskObjs(i).FLIGHTCONDITION2{1} , batchTaskObjs(i).LABEL , batchTaskObjs(i).WEIGHTCODE ,...
                    batchTaskObjs(i).VARIABLES , obj.FC_IndexMatch);
                


                trimTaskObj = [ trimTaskObj , tempTrimTask ]; %#ok<AGROW>
                
            end


        end % createTaskObjManual  
        
        function updateMassProps( obj , massProp )
            
            if isempty(massProp)
                obj.BasicTableMassPropData = {};
                obj.BasicTableMassPropHeaderData = {' '};
                obj.BasicTableMassPropColumnWidth = {20};
                obj.BasicTableMassPropColumnEditable = true;
                obj.BasicTableMassPropColumnFormat = {'Logical'};
                obj.BasicTableMassPropRowName = [];
                obj.BasicTableRowSelectedLA = false;
        
                obj.BasicTableMassProp.Data = obj.BasicTableMassPropData;
                obj.BasicTableMassProp.ColumnName = obj.BasicTableMassPropHeaderData; 
                obj.BasicTableMassProp.ColumnFormat = obj.BasicTableMassPropColumnFormat;
                obj.BasicTableMassProp.ColumnEditable = obj.BasicTableMassPropColumnEditable;
                obj.BasicTableMassProp.RowName = obj.BasicTableMassPropRowName;
                obj.BasicTableMassProp.ColumnWidth = obj.BasicTableMassPropColumnWidth;

                obj.BasicTableRowSelectedLA = false(length(massProp),1);
            else

                obj.MassPropertiesObjects = copy(massProp);

                obj.BasicTableMassPropColumnFormat = cell(1,length(massProp(1).Parameter));

                obj.BasicTableMassPropHeaderData{1} = [];
                obj.BasicTableMassPropColumnFormat{1} = 'logical';
                obj.BasicTableMassPropColumnWidth{1} = 20;

                obj.BasicTableMassPropHeaderData{2} = 'Weight Code';
                obj.BasicTableMassPropColumnFormat{2} = 'char';
                obj.BasicTableMassPropColumnWidth{2} = 80;

                obj.BasicTableMassPropHeaderData{3} = 'Label';
                obj.BasicTableMassPropColumnFormat{3} = 'char';
                obj.BasicTableMassPropColumnWidth{3} = 80;

                for j = 1:length(massProp(1).Parameter)
                    obj.BasicTableMassPropHeaderData{3 + j} = massProp(1).Parameter(j).Name;
                    obj.BasicTableMassPropColumnFormat{3 + j} = 'char';
                    obj.BasicTableMassPropColumnWidth{3 + j} = 80;
                end


                obj.BasicTableMassPropData = {};
                for i = 1:length(massProp)
                    obj.BasicTableMassPropData{i,1} = false;
                    obj.BasicTableMassPropData{i,2} = massProp(i).WeightCode;
                    obj.BasicTableMassPropData{i,3} = massProp(i).Label;
                    for j = 1:length(massProp(i).Parameter)
                        obj.BasicTableMassPropData{ i , 3 + j } = massProp(i).Parameter(j).StringValue;
                    end
                end

                obj.BasicTableMassPropColumnEditable = [true,true(1,length(obj.BasicTableMassPropColumnFormat)-1)];

                obj.BasicTableMassProp.Data = obj.BasicTableMassPropData;
                obj.BasicTableMassProp.ColumnName = obj.BasicTableMassPropHeaderData; 
                obj.BasicTableMassProp.ColumnFormat = obj.BasicTableMassPropColumnFormat;
                obj.BasicTableMassProp.ColumnEditable = obj.BasicTableMassPropColumnEditable;
                obj.BasicTableMassProp.RowName = obj.BasicTableMassPropRowName;
                obj.BasicTableMassProp.ColumnWidth = obj.BasicTableMassPropColumnWidth;

                obj.BasicTableRowSelectedLA = false(length(massProp),1);
            end

        end % updateMassProps
        
    end % Ordinary Methods
    
    %% Methods - Private
    methods (Access = private)    
        
      
        
    end    
    
    %% Methods - Update and Resize
    methods
                
        function updateDisplay(obj, currTableNum)
            
            if nargin == 1
                currTableNum = 0;
            end
            
            set(obj.FC1_pm,'String',obj.FC1_PM_String);
            set(obj.FC1_pm,'Value', obj.FC1_PM_SelValue);
            set(obj.FC2_pm,'String',obj.FC2_PM_String);
            set(obj.FC2_pm,'Value', obj.FC2_PM_SelValue);
            
            set(obj.FC1_eb,'String', obj.FC1_EB_String);
            set(obj.FC2_eb,'String', obj.FC2_EB_String);
            
            set(obj.FC1_units,'String', obj.FC1_Units);
            set(obj.FC2_units,'String', obj.FC2_Units);

            
            set(obj.SetName_eb,'String', obj.SetName_String);
            
            set(obj.Flap_eb,'String', obj.FlapSettingString);
            if ~isempty(obj.SelectedLandingDown)
                if obj.SelectedLandingDown %strcmp(obj.SelectedLandingDown.String,'Gear Up')
                    set(obj.CongButtonGroup,'SelectedObject',obj.CongfigDN);
                else
                    set(obj.CongButtonGroup,'SelectedObject',obj.CongfigUP);
                end
            end
            
            %Set Enabled State
            set(obj.Input2Table,'Enable',obj.EnableTrimTwo);
            set(obj.Output2Table,'Enable',obj.EnableTrimTwo);
            set(obj.State2Table,'Enable',obj.EnableTrimTwo);
            set(obj.StateDerivs2Table,'Enable',obj.EnableTrimTwo);
            set(obj.CongfigUP,'Enable',obj.EnableGear);
            set(obj.CongfigDN,'Enable',obj.EnableGear);
            set(obj.Flap_eb,'Enable',obj.EnableFlap);
            
            if ~isempty(obj.SelectedTrimDef)
%                 obj.Input1Table.Data       = obj.SelectedTrimDef.getAsTableData('Inputs');
%                 obj.Output1Table.Data      = obj.SelectedTrimDef.getAsTableData('Outputs');
%                 obj.State1Table.Data       = obj.SelectedTrimDef.getAsTableData('States');
%                 obj.StateDerivs1Table.Data = obj.SelectedTrimDef.getAsTableData('StateDerivatives');

                if ~isempty(obj.SelectedTrimDef.InitialTrim)
                    if currTableNum ~= 1
                    obj.Input1Table.Data       = obj.SelectedTrimDef.InitialTrim.getAsTableData('Inputs');
                    end
                    if currTableNum ~= 2
                    obj.Output1Table.Data      = obj.SelectedTrimDef.InitialTrim.getAsTableData('Outputs');
                    end
                    if currTableNum ~= 3
                    obj.State1Table.Data       = obj.SelectedTrimDef.InitialTrim.getAsTableData('States');
                    end
                    if currTableNum ~= 4
                    obj.StateDerivs1Table.Data = obj.SelectedTrimDef.InitialTrim.getAsTableData('StateDerivatives');
                    end
                    
                    if currTableNum ~= 5
                    obj.Input2Table.Data       = obj.SelectedTrimDef.getAsTableData('Inputs');
                    end
                    if currTableNum ~= 6
                    obj.Output2Table.Data      = obj.SelectedTrimDef.getAsTableData('Outputs');
                    end
                    if currTableNum ~= 7
                    obj.State2Table.Data       = obj.SelectedTrimDef.getAsTableData('States');
                    end
                    if currTableNum ~= 8
                    obj.StateDerivs2Table.Data = obj.SelectedTrimDef.getAsTableData('StateDerivatives');
                    end
                    
                    [numEq1,color1] = obj.SelectedTrimDef.InitialTrim.validTrimEquationTableData;
                    [numEq2,color2] = obj.SelectedTrimDef.validTrimEquationTableData;
                    obj.NumberTrimEqTableTrim1.Data = numEq1;
                    obj.NumberTrimEqTableTrim2.Data = numEq2;    
                    obj.NumberTrimEqTableTrim1.ForegroundColor = color1;
                    obj.NumberTrimEqTableTrim2.ForegroundColor = color2; 
                    
                    obj.NumberTrimEqTableTrimBasic1.Data = numEq1;
                    obj.NumberTrimEqTableTrimBasic2.Data = numEq2;    
                    obj.NumberTrimEqTableTrimBasic1.ForegroundColor = color1;
                    obj.NumberTrimEqTableTrimBasic2.ForegroundColor = color2; 
                            
        

                    if currTableNum ~= 9
                    obj.BasicTableLon1.Data       = obj.SelectedTrimDef.InitialTrim.getAsBasicTableData('Longitudinal'); 
                    obj.BasicTableLat1.Data       = obj.SelectedTrimDef.InitialTrim.getAsBasicTableData('LateralDirectional'); 
                    obj.BasicTableLon2.Data       = obj.SelectedTrimDef.getAsBasicTableData('Longitudinal'); 
                    obj.BasicTableLat2.Data       = obj.SelectedTrimDef.getAsBasicTableData('LateralDirectional');   
                    end
                else
                    if currTableNum ~= 1
                    obj.Input1Table.Data       = obj.SelectedTrimDef.getAsTableData('Inputs');
                    end
                    if currTableNum ~= 2
                    obj.Output1Table.Data      = obj.SelectedTrimDef.getAsTableData('Outputs');
                    end
                    if currTableNum ~= 3
                    obj.State1Table.Data       = obj.SelectedTrimDef.getAsTableData('States');
                    end
                    if currTableNum ~= 4
                    obj.StateDerivs1Table.Data = obj.SelectedTrimDef.getAsTableData('StateDerivatives');
                    end
                    obj.Input2Table.Data       = [];
                    obj.Output2Table.Data      = [];
                    obj.State2Table.Data       = [];
                    obj.StateDerivs2Table.Data = []; 
                    

                    [numEq1,color1] = obj.SelectedTrimDef.validTrimEquationTableData;
                    obj.NumberTrimEqTableTrim1.Data = numEq1;
                    obj.NumberTrimEqTableTrim1.ForegroundColor = color1;
                    obj.NumberTrimEqTableTrim2.Data = []; 
                    obj.NumberTrimEqTableTrimBasic1.Data = numEq1;
                    obj.NumberTrimEqTableTrimBasic1.ForegroundColor = color1;
                    obj.NumberTrimEqTableTrimBasic2.Data = []; 
                    
                    if currTableNum ~= 9
                    obj.BasicTableLon1.Data       = obj.SelectedTrimDef.getAsBasicTableData('Longitudinal'); 
                    obj.BasicTableLat1.Data       = obj.SelectedTrimDef.getAsBasicTableData('LateralDirectional');
                    obj.BasicTableLon2.Data       = []; 
                    obj.BasicTableLat2.Data       = [];
                    end
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
                obj.BasicTableLon2.Data     = []; 
                obj.BasicTableLat2.Data     = []; 
                obj.NumberTrimEqTableTrim1.Data = [];
                obj.NumberTrimEqTableTrim2.Data = [];
                obj.NumberTrimEqTableTrimBasic2.Data = [];
            end
             
        end % updateDisplay
       
        function createTaskViewResize( obj , ~ , ~ )
%             
            % get figure position
            parentPos = getpixelposition(obj.Container);
            tableHeight = (parentPos(4) - 165)/2;

%             % Row 1
            set(obj.FCLabel,'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 10 , 150 + 2*tableHeight , parentPos(3) - 10 , 15 ]);
%             % Row 2
            set(obj.FC1_pm,'Units','Pixels',...
                'Position',[ 10 , 130 + 2*tableHeight , 80 , 20 ]);
            set(obj.FC1_eb,'Units','Pixels',...
                'Position',[ 95 , 130 + 2*tableHeight , parentPos(3) - 145 , 20 ]);
            set(obj.FC1_units,'Units','Pixels',...
                'Position',[ parentPos(3) - 145 + 95 , 130 + 2*tableHeight , 40 , 20 ]);
            % Row 3
            set(obj.FC2_pm,'Units','Pixels',...
                'Position',[ 10 , 107 + 2*tableHeight , 80 , 20 ]);
            set(obj.FC2_eb,'Units','Pixels',...
                'Position',[ 95 , 107 + 2*tableHeight , parentPos(3) - 145 , 20 ]);
            set(obj.FC2_units,'Units','Pixels',...
                'Position',[ parentPos(3) - 145 + 95 , 107 + 2*tableHeight , 40 , 20 ]);





            set(obj.TrimInputTypeTabPanel,'Units','Pixels',...
                'Position',[ 6 , 25 , parentPos(3) - 12 , 2*tableHeight + 82 ]);
            
            tTTPanelPos = getpixelposition(obj.TrimInputTypeTabPanel);
            
            
            basicPanelPos = getpixelposition(obj.TrimInputTypeTabPanel);
            set(obj.Flap_text,'Units','Pixels',...
                'Position',[ 6 , basicPanelPos(4) - 53 , 80 , 17 ]);   
            set(obj.Flap_eb,'Units','Pixels',...
                'Position',[ 88 , basicPanelPos(4) - 53 , parentPos(3) - 105 , 20 ]);   
            
            set(obj.ACconfig_text,'Units','Pixels',...
                'Position',[ 6 , basicPanelPos(4) - 78 , 80 , 17 ]);  
            
            set(obj.CongButtonGroup,'Units','Pixels',...
                'Position',[ 88 , basicPanelPos(4) - 78 , parentPos(3) - 105 , 20 ]);  
            set(obj.CongfigUP,'Units','Pixels',...
                'Position',[ 1 , 1 , 70 , 20 ]); 
            set(obj.CongfigDN,'Units','Pixels',...
                'Position',[ 80 , 1 , 80 , 20 ]);
            
            tblH = ((basicPanelPos(4) - 85 ) / 3) - 42;
            diff = 40;  % Factor for sizing the mass prop table in relation to the lon/lat tables
            
            set(obj.MassProp_text,'Units','Pixels',...
                'Position',[ 6 , 3*tblH + 111 , parentPos(3) - 6 , 15 ]);
            set(obj.BasicTableMassProp,'Units','Pixels',...
                'Position',[ 6 , 2*tblH + 98 - 2*diff , basicPanelPos(3) - 12 , tblH + 10 + 2*diff]);  
            
            
            %%%%%%%%%%%% Basic Trim Panel Resize %%%%%%%%%%%%%%%%%%%%%%%%%%
            set(obj.BasicTabPanelTrim,'Units','Pixels',...
                'Position',[ 6 , 1 , basicPanelPos(3) - 12 , 2*(tblH - diff) + 90  ]);
 
            
            bTPPos = getpixelposition(obj.BasicTabPanelTrim);
            btHeight = bTPPos(4)/2 - 50;
            
            
            %%% Trim 1 Resize %%%%
            set(obj.LonVarText1,'Units','Pixels',...
                'Position',[ 1 , 2*btHeight + 57 , bTPPos(3) - 5 , 15 ]);
            set(obj.BasicTableLon1,'Units','Pixels',...
                'Position',[ 1 , btHeight + 60 , bTPPos(3) - 5 , btHeight - 3]);  
            set(obj.LatVarText1,'Units','Pixels',...
                'Position',[ 1 , btHeight + 42 , bTPPos(3) - 5 , 15 ]);
            set(obj.BasicTableLat1,'Units','Pixels',...
                'Position',[ 1 , 42 , bTPPos(3) - 5 , btHeight ]);   
            set(obj.NumberTrimEqTableTrimBasic1,'Units','Pixels',...
                'Position',[ 1 , 1 , bTPPos(3) - 5 , 40 ]); 
            %%% Trim 2 Resize %%%%
            set(obj.LonVarText2,'Units','Pixels',...
                'Position',[ 1 , 2*btHeight + 57 , bTPPos(3) - 5 , 15 ]);
            set(obj.BasicTableLon2,'Units','Pixels',...
                'Position',[ 1 , btHeight + 60 , bTPPos(3) - 5 , btHeight]);  
            set(obj.LatVarText2,'Units','Pixels',...
                'Position',[ 1 , btHeight + 42 , bTPPos(3) - 5 , 15 ]);
            set(obj.BasicTableLat2,'Units','Pixels',...
                'Position',[ 1 , 42 , bTPPos(3) - 5 , btHeight ]);   
            set(obj.NumberTrimEqTableTrimBasic2,'Units','Pixels',...
                'Position',[ 1 , 1 , bTPPos(3) - 5 , 40 ]);      




            %%%%%%%%%%%% Advanced Trim Panel Resize %%%%%%%%%%%%%%%%%%%%%%%
            set(obj.TabPanelTrim,'Units','Pixels',...
                'Position',[ 1 , 1 , basicPanelPos(3) , basicPanelPos(4) - 30 ]);
            set(obj.TabPanel1,'Units','Pixels',...
                'Position',[ 1 , 70 , basicPanelPos(3) , basicPanelPos(4) - 130 ]);
            set(obj.TabPanel2,'Units','Pixels',...
                'Position',[ 1 , 70 , basicPanelPos(3) , basicPanelPos(4) - 130 ]);
            
            set(obj.TrimEq_text1,'Units','Pixels',...
                'Position',[ 1 , 50 , parentPos(3) , 20 ]);
            set(obj.NumberTrimEqTableTrim1,'Units','Pixels',...
                'Position',[ 1 , 1 , basicPanelPos(3) , 50 ]);
            set(obj.TrimEq_text2,'Units','Pixels',...
                'Position',[ 1 , 50 , parentPos(3) , 20 ]);
            set(obj.NumberTrimEqTableTrim2,'Units','Pixels',...
                'Position',[ 1 , 1 , basicPanelPos(3) , 50 ]);
            
            
            
            set(obj.Input1Table, 'ColumnWidth',{115,135,20,120});
            set(obj.Output1Table, 'ColumnWidth',{115,135,20,120});
            set(obj.State1Table, 'ColumnWidth',{115,135,20,120});
            set(obj.StateDerivs1Table, 'ColumnWidth',{115,135,20,120});
            
            set(obj.Input2Table, 'ColumnWidth',{115,135,20,120});
            set(obj.Output2Table, 'ColumnWidth',{115,135,20,120});
            set(obj.State2Table, 'ColumnWidth',{115,135,20,120});
            set(obj.StateDerivs2Table, 'ColumnWidth',{115,135,20,120});

            % Row 9
            set(obj.SetName_text,'Units','Pixels',...
                'Position',[ 10 , 5 , 50 , 15 ]);
            
            %Row 10
            set(obj.SetName_eb,'Units','Pixels',...
                'Position',[ 60 , 5 , parentPos(3) - 105 , 20 ]);
            
            
        end % createTaskViewResize        
                          
    end
    
    %% Method - Delete
    methods
        function delete(obj)

            % Java Components 


            % Javawrappers
            % Check if container is already being deleted


            % User Defined Objects
%             try %#ok<*TRYNC>             
%                 delete(obj.SelectedMassProperties);
%             end
%             try %#ok<*TRYNC>
%                 delete(obj.SelectedTrimDef);
%             end
%             try %#ok<*TRYNC>
%                 delete(obj.SelectedLinMdlDef);
%             end
%             try %#ok<*TRYNC>
%                 delete(obj.MassPropertiesObjects);
%             end
            
            delete(obj.Container);
            
        end % delete
    end 
    
    %% Method - Static
    methods ( Static )

        function obj = loadobj(s)
            
            try
                if length(s.FC1_PM_String) == 4                
                    s.FC1_PM_String = {'KCAS','Alt','Mach','Qbar','KEAS'};
                    s.FC2_PM_String = {'KCAS','Alt','Mach','Qbar','KEAS'};
                end
                obj = s;
            catch
                obj = s;
            end
        end % loadobj
        
    end
        
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the TrimTask object
%             cpObj.TrimTask = copy(obj.TrimTask);
            % Make a deep copy of the SelectedTrimDef object
            cpObj.SelectedTrimDef = copy(obj.SelectedTrimDef);
            % Make a deep copy of the SelectedLinMdlDef object
            cpObj.SelectedLinMdlDef = copy(obj.SelectedLinMdlDef);
            % Make a deep copy of the SelectedMassProperties object
            cpObj.SelectedMassProperties = copy(obj.SelectedMassProperties); 
            
            
            
        end
    end
    
end

        
                
function status = checkFlightCondition(a, b)
    status = true;
    if a == b || (a == 4 && b==5) || (a == 5 && b==4)
        status = false;
    end


end % checkFlightCondition     

function tempTrimTask = createTaskTrim( mdl , constFile , selTrimDef , selLinMdlDef , selMassProp , fc1ValueString , fc2ValueString , fc1TypeString , fc2TypeString ,setName , wcString , batchVariables , fcIndexMatch )
    import Utilities.*

    tempTrimTask = lacm.TrimTask.empty;

    fc1Vals = num2cell(str2num(fc1ValueString));
    fc2Vals = num2cell(str2num(fc2ValueString));

    if nargin < 13 || isempty(fcIndexMatch)
        fcIndexMatch = false;
    end

    % When matching by index, all value arrays are synchronized in length
    % later in the function.  Size checks are handled after assembling all
    % arrays, so no early error is required here.

    if selMassProp(1).DummyMode
        startingColIndex = 3;
    else
        startingColIndex = 4;
    end
    % Update Simulink model conditions
    saveFormat = getSaveFormat(mdl);
    % updateMdlConditions( selTrimDef , mdl );  No need to update model
    resetSaveFormat( saveFormat );
    
    % Store all names
    inputOrderedNames      = getNames( selTrimDef, 'Inputs' );
    outputOrderedNames     = getNames( selTrimDef, 'Outputs' );
    stateOrderedNames      = getNames( selTrimDef, 'States' );
    stateDerivOrderedNames = getNames( selTrimDef, 'StateDerivatives' );
    
    [ scalarInputObjs , vectorInputObjs ] = filterTrimSettings( selTrimDef , 'Inputs' );
    [ scalarOutputObjs , vectorOutputObjs ] = filterTrimSettings( selTrimDef , 'Outputs' );
    [ scalarStateObjs , vectorStateObjs ] = filterTrimSettings( selTrimDef , 'States' );
    [ scalarStateDerivObjs , vectorStateDerivObjs ] = filterTrimSettings( selTrimDef , 'StateDerivatives' );

    [ inputhdr , inputVal ] = getHeaderValueArray( vectorInputObjs );
    [ outputhdr , outputVal ] = getHeaderValueArray( vectorOutputObjs );
    [ stateshdr , statesVal ] = getHeaderValueArray( vectorStateObjs );
    [ statesDerivhdr , statesDerivVal ] = getHeaderValueArray( vectorStateDerivObjs );

    if fcIndexMatch
        % Match all value arrays by index.  Determine the maximum length
        % among non-scalar arrays and replicate scalar entries to that
        % length so that each row in the table corresponds to a single
        % index across all variables.

        % Gather all value arrays and their identifying names
        valueArrays = {fc1Vals , fc2Vals};
        valueNames  = {'Flight Condition 1' , 'Flight Condition 2'};

        if selMassProp(1).DummyMode
            massPropVals = {};
        else
            massPropVals = strsplit(wcString,',');
            valueArrays{end+1} = massPropVals;
            valueNames{end+1}  = 'Mass Properties';
        end

        for ii = 1:length(inputVal)
            valueArrays{end+1} = inputVal{ii};
            valueNames{end+1}  = ['Input ' inputhdr{ii}];
        end
        for ii = 1:length(outputVal)
            valueArrays{end+1} = outputVal{ii};
            valueNames{end+1}  = ['Output ' outputhdr{ii}];
        end
        for ii = 1:length(statesVal)
            valueArrays{end+1} = statesVal{ii};
            valueNames{end+1}  = ['State ' stateshdr{ii}];
        end
        for ii = 1:length(statesDerivVal)
            valueArrays{end+1} = statesDerivVal{ii};
            valueNames{end+1}  = ['State Derivative ' statesDerivhdr{ii}];
        end

        % Compute lengths and determine maximum non-scalar length
        valueLengths = cellfun(@numel, valueArrays);
        nonScalarIdx = find(valueLengths > 1);
        if isempty(nonScalarIdx)
            maxLen = 1;
        else
            maxLen = max(valueLengths(nonScalarIdx));
            mismatchIdx = nonScalarIdx(valueLengths(nonScalarIdx) ~= maxLen);
            if ~isempty(mismatchIdx)
                error('FCOND:SIZE', 'All array sizes must match.');
            end
        end

        % Replicate scalar arrays to match the maximum length
        for ii = 1:numel(valueArrays)
            if numel(valueArrays{ii}) == 1 && maxLen > 1
                valueArrays{ii} = repmat(valueArrays{ii}, 1, maxLen);
            end
        end

        % Assign expanded arrays back to original variables
        idx = 1;
        fc1Vals = valueArrays{idx}; idx = idx + 1;
        fc2Vals = valueArrays{idx}; idx = idx + 1;
        if ~selMassProp(1).DummyMode
            massPropVals = valueArrays{idx}; idx = idx + 1;
        end
        for ii = 1:length(inputVal)
            inputVal{ii} = valueArrays{idx}; idx = idx + 1;
        end
        for ii = 1:length(outputVal)
            outputVal{ii} = valueArrays{idx}; idx = idx + 1;
        end
        for ii = 1:length(statesVal)
            statesVal{ii} = valueArrays{idx}; idx = idx + 1;
        end
        for ii = 1:length(statesDerivVal)
            statesDerivVal{ii} = valueArrays{idx}; idx = idx + 1;
        end

        % Construct table data by index across all arrays
        nRows = maxLen;
        nCols = 2 + (~selMassProp(1).DummyMode) + length(inputVal) + ...
                length(outputVal) + length(statesVal) + length(statesDerivVal);
        tabledata = cell(nRows, nCols);
        for ii = 1:nRows
            tabledata{ii,1} = fc1Vals{ii};
            tabledata{ii,2} = fc2Vals{ii};
            col = 3;
            if ~selMassProp(1).DummyMode
                tabledata{ii,col} = massPropVals{ii};
                col = col + 1;
            end
            for jj = 1:length(inputVal)
                tabledata{ii,col} = inputVal{jj}{ii};
                col = col + 1;
            end
            for jj = 1:length(outputVal)
                tabledata{ii,col} = outputVal{jj}{ii};
                col = col + 1;
            end
            for jj = 1:length(statesVal)
                tabledata{ii,col} = statesVal{jj}{ii};
                col = col + 1;
            end
            for jj = 1:length(statesDerivVal)
                tabledata{ii,col} = statesDerivVal{jj}{ii};
                col = col + 1;
            end
        end

    else
        if selMassProp(1).DummyMode
            cols = {fc1Vals, fc2Vals};
        else
            cols = {fc1Vals, fc2Vals, strsplit(wcString,',')};
        end
        cols = [cols , inputVal , outputVal , statesVal , statesDerivVal];
        tabledata = allcomb(cols{:});
    end


    tempTrimTask(size(tabledata,1)) = lacm.TrimTask;    
    for j = 1:size(tabledata,1)

        tempTrimTask(j) = lacm.TrimTask();
        tempTrimTask(j).Label = setName; 
        fltCond = lacm.FlightCondition( fc1TypeString ,...
                                        tabledata{j,1} ,...
                                        fc2TypeString ,...
                                        tabledata{j,2} );
        tempTrimTask(j).FlightCondition = fltCond;
        

        if selMassProp(1).DummyMode
            massProp = copy(selMassProp(1));
%             massProp = lacm.MassProperties;
%                 temp =  java.util.UUID.randomUUID;
%                 y = char(temp.toString);
%             massProp.WeightCode = y;
        else
            logarrayMP = strcmp(tabledata{j,3},{selMassProp.WeightCode});
            massProp = copy(selMassProp(logarrayMP));
        end
        
        
        tempTrimTask(j).MassPropObj   = massProp;
        tempTrimTask(j).TrimDefObj    = selTrimDef;
        tempTrimTask(j).LinMdlObj     = copy(selLinMdlDef);
        tempTrimTask(j).Simulation    = mdl;
        tempTrimTask(j).ConstantsFile = constFile;

        colIndex = startingColIndex;
        tgtIC = lacm.Condition.empty;
        for i = 1:length(vectorInputObjs) 
            tgtIC(i) = lacm.Condition( inputhdr{i} , tabledata{j,colIndex} , [] , vectorInputObjs(i).Fix );
            colIndex = colIndex + 1;
        end

        colIndex = length(vectorInputObjs) + startingColIndex;
        tgtOC = lacm.Condition.empty;
        for i = 1:length(vectorOutputObjs) 
            tgtOC(i) = lacm.Condition( outputhdr{i} , tabledata{j,colIndex} , [] , vectorOutputObjs(i).Fix );
            colIndex = colIndex + 1;
        end

        colIndex = length(vectorInputObjs) + length(vectorOutputObjs) + startingColIndex;
        tgtSC = lacm.Condition.empty;
        for i = 1:length(vectorStateObjs)
            tgtSC(i) = lacm.Condition( stateshdr{i} , tabledata{j,colIndex} , [] , vectorStateObjs(i).Fix );
            colIndex = colIndex + 1;
        end 

        colIndex = length(vectorInputObjs) + length(vectorOutputObjs) + length(vectorStateObjs) + startingColIndex;
        tgtSDC = lacm.Condition.empty;
        for i = 1:length(vectorStateDerivObjs)
            tgtSDC(i) = lacm.Condition( statesDerivhdr{i} , tabledata{j,colIndex} , [] , vectorStateDerivObjs(i).Fix );
            colIndex = colIndex + 1;
        end 

        tempTrimTask(j).InputConditions  = [ scalarInputObjs , tgtIC ];
        tempTrimTask(j).OutputConditions = [ scalarOutputObjs , tgtOC ];
        tempTrimTask(j).StateConditions  = [ scalarStateObjs , tgtSC ];
        tempTrimTask(j).StateDerivativeConditions  = [ scalarStateDerivObjs , tgtSDC ];
        
        
        % order the conditions correctly
        tempInputNames = {tempTrimTask(j).InputConditions.Name};
        [~, ia] = ismember(inputOrderedNames, tempInputNames);
        tempTrimTask(j).InputConditions = tempTrimTask(j).InputConditions(ia);
        
        tempOutputNames = {tempTrimTask(j).OutputConditions.Name};
        [~, ia] = ismember(outputOrderedNames, tempOutputNames);
        tempTrimTask(j).OutputConditions = tempTrimTask(j).OutputConditions(ia);
        
        tempStateNames = {tempTrimTask(j).StateConditions.Name};
        [~, ia] = ismember(stateOrderedNames, tempStateNames);
        tempTrimTask(j).StateConditions = tempTrimTask(j).StateConditions(ia);
        
        tempStateDerivNames = {tempTrimTask(j).StateDerivativeConditions.Name};
        [~, ia] = ismember(stateDerivOrderedNames, tempStateDerivNames);
        tempTrimTask(j).StateDerivativeConditions = tempTrimTask(j).StateDerivativeConditions(ia);
        
        % Update Mass Properties Object
        if ~isempty(tempTrimTask(j).MassPropObj)
            massPropParamNames = {tempTrimTask(j).MassPropObj.Parameter.Name};
            for ind = 1:length(batchVariables)

                logArray = strcmp(batchVariables(ind).Name,massPropParamNames);
                if any(logArray)
                    tempTrimTask(j).MassPropObj.Parameter(logArray).Value = batchVariables(ind).Value;
                end
            end
        end

        if ~isempty(selTrimDef.InitialTrim)
            % Create Initial TrimSettings Object        
            [ scalarInputObjsInit , vectorInputObjsInit ] = filterTrimSettings( selTrimDef.InitialTrim , 'Inputs' );
            [ scalarOutputObjsInit , vectorOutputObjsInit ] = filterTrimSettings( selTrimDef.InitialTrim , 'Outputs' );
            [ scalarStateObjsInit , vectorStateObjsInit ] = filterTrimSettings( selTrimDef.InitialTrim , 'States' );
            [ scalarStateDerivObjsInit , vectorStateDerivObjsInit ] = filterTrimSettings( selTrimDef.InitialTrim , 'StateDerivatives' );        
            if ~isempty( vectorInputObjsInit ) ||  ~isempty( vectorOutputObjsInit ) ||  ~isempty( vectorStateObjsInit ) ||  ~isempty( vectorStateDerivObjsInit )  
                error('Arrays of conditions are not allowed in the initial trim.');
            end
            initialTrimTask = lacm.TrimTask();
            initialTrimTask.Label = setName; 
            initialTrimTask.FlightCondition  = fltCond;
            initialTrimTask.MassPropObj      = massProp;
            initialTrimTask.TrimDefObj       = selTrimDef;
            initialTrimTask.LinMdlObj        = selLinMdlDef;
            initialTrimTask.Simulation       = mdl;
            initialTrimTask.ConstantsFile    = constFile;  
            initialTrimTask.InputConditions  = scalarInputObjsInit;
            initialTrimTask.OutputConditions = scalarOutputObjsInit;
            initialTrimTask.StateConditions  = scalarStateObjsInit;
            initialTrimTask.StateDerivativeConditions  = scalarStateDerivObjsInit;   

            tempTrimTask(j).InitialTrimTask = initialTrimTask;
        end  
    end

end % createTaskTrim

function [ hdr , val ] = getHeaderValueArray( vars )
    hdr = cell(1,length(vars));
    val = cell(1,length(vars));
    for i = 1:length(vars)       
        hdr{i} = vars(i).Name;
        val{i} = num2cell(vars(i).Value);
    end
end % getHeaderValueArray

function resetSaveFormat( saveFormat )
    for i = 1:length(saveFormat)
        % Reset Array Format
        try
            set_param(saveFormat(i).ModelName,'SaveFormat',saveFormat(i).Format);
        catch
            try
                % Get the Configuration Set
                cref = getActiveConfigSet(saveFormat(i).ModelName);
                if isa(cref,'Simulink.ConfigSetRef')
                    cset = cref.getRefConfigSet;
                else
                    cset = cref;
                end
                set_param(cset,'SaveFormat',saveFormat(i).Format);
            catch
                error('SIMULINK:GETSTATENAMESDATASAVEFORMAT','Unable to set the data save format to ''array''. This is neccessary to use the command ''getInitialState''.');  
            end
        end
    end
end % resetSaveFormat

function saveFormat = getSaveFormat(mdl)
    saveFormat = struct('ModelName',mdl,'Format',[]);

    % Load System
    try
        load_system(mdl);
    catch
        error('FLIGHTDynamics:SimulationNotFoundInPath',['The model "',mdl,'" is not on the path or was created in a newer version of Matlab']);
    end

    try
        saveFormat.Format = get_param(mdl,'SaveFormat');
    catch
        try
            % Get the Configuration Set
            cref = getActiveConfigSet(mdl);
            if isa(cref,'Simulink.ConfigSetRef')
                cset = cref.getRefConfigSet;
            else
                cset = cref;
            end
            saveFormat.Format = get_param(cset,'SaveFormat');
        catch
            error('SIMULINK:GETSTATENAMESDATASAVEFORMAT','Unable to set the data save format to ''array''. This is neccessary to use the command ''getInitialState''.');
        end
    end

end % getSaveFormat
