classdef LinMdlEditor < UserInterface.ObjectEditor.Editor
    %% Public properties - Graphics Handles
    properties (Transient = true)
        LabelText
        LabelEditBox
        NumOfTrimText
        NumOfTrimComboBox
        
        TablePanel
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
        
        AlgInputsText
        AlgInputsTable
        AddStateDerivsPushButton1
        RemoveStateDerivsPushButton1
        
        AlgOutputsText
        AlgOutputsTable

        
        ModelText
        ModelEditBox
        ModelPushButton
    end % Public properties
  
    %% Public properties - Data Storage
    properties
        LinMdlLabelString = char.empty
        NumOfTrimSelectionString = {'1','2'}
        NumOfTrimSelectionValue  = 1
        
        Input1TableData
        Output1TableData
        State1TableData
        StateDerivs1TableData
        
        
        ModelName
        
        %StartDirectory = mfilename('fullpath')
        
        Inputs = UserInterface.ObjectEditor.LinMdlRow.empty
        Outputs = UserInterface.ObjectEditor.LinMdlRow.empty
        States = UserInterface.ObjectEditor.LinMdlRow.empty
        AlgebraicInputs = UserInterface.ObjectEditor.LinMdlRow.empty
        AlgebraicOutputs = UserInterface.ObjectEditor.LinMdlRow.empty
        
        SelectedLinMdlDef
        

    end % Public properties
    
    %% Private properties
    properties ( Access = private )
        BrowseStartDir = mfilename('fullpath')
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  

    %% Events
    events

    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = LinMdlEditor(varargin)  
            obj@UserInterface.ObjectEditor.Editor(varargin{:}); 
            createView( obj , obj.Parent );
        end % LinMdlEditor
    end % TrimEditor

    %% Methods - Property Access
    methods

    end % Property access methods
    
    %% Methods - View
    methods
        
        function createView( obj , parent )  
            createView@UserInterface.ObjectEditor.Editor( obj , parent );
            
            fig = ancestor(parent,'figure','toplevel') ;
            fig.MenuBar = 'None';
            fig.NumberTitle = 'off';
            position = fig.Position;
            fig.Position = [ position(1) , position(2) - 200 , 544 , 643 ];
            
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
                'String','Linear Model Label:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.LabelEditBox = uicontrol('Parent',obj.MainPanel,...
                'Style','edit',...
                'FontSize',10,...
                'String',obj.LinMdlLabelString,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left',...
                'Callback',@obj.labelTextEditBox_CB);
                        
            
            obj.TablePanel = uipanel('Parent',obj.MainPanel);

            createPanel( obj , obj.TablePanel ); 
                   
            reSize( obj );
            update(obj);
        end % createView
        
        function createPanel( obj , parent )
            
            
            
            
            obj.InputsText1 = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Inputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Input1Table = uitable(parent,...
                'ColumnName',{'Variable',''},...
                'RowName',[],...
                'ColumnEditable', [ false  , true ],...
                'ColumnFormat',{'Char','Logical'},...
                'ColumnWidth',{120,20},...
                'Data',[],...
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
                'String','Outputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.Output1Table = uitable(parent,...
                'ColumnName',{'Variable',''},...
                'RowName',[],...
                'ColumnEditable', [ false  , true ],...
                'ColumnFormat',{'Char','Logical'},...
                'ColumnWidth',{120,20},...
                'Data',[],...
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
                'String','States',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.State1Table = uitable(parent,...
                'ColumnName',{'Variable',''},...
                'RowName',[],...
                'ColumnEditable', [ false  , true ],...
                'ColumnFormat',{'Char','Logical'},...
                'ColumnWidth',{120,20},...
                'Data',[],...
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
            obj.AlgInputsText = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Algebraic Inputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.AlgInputsTable = uitable(parent,...
                'ColumnName',{'Variable',''},...
                'RowName',[],...
                'ColumnEditable', [ false  , true ],...
                'ColumnFormat',{'Char','Logical'},...
                'ColumnWidth',{120,20},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.algInputsTable1_ce_CB,...
                'CellSelectionCallback', @obj.algInputsTable1_cs_CB); 

            
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
                          

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AlgOutputsText = uicontrol('Parent',parent,...
                'Style','text',...
                'FontSize',10,...
                'String','Algebraic Outputs',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left'); 
            
            obj.AlgOutputsTable = uitable(parent,...
                'ColumnName',{'Variable',''},...
                'RowName',[],...
                'ColumnEditable', [ false  , true ],...
                'ColumnFormat',{'Char','Logical'},...
                'ColumnWidth',{120,20},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.algOutputsTable1_ce_CB,...
                'CellSelectionCallback', @obj.algOutputsTable1_cs_CB); 

            
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

            

        end % createPanel
        
        
    end
   
    %% Methods - Ordinary
    methods 
        
        function loadExisting( obj , loadedLinMdlObj , filename )
            
            if ~isa(loadedLinMdlObj,'lacm.LinearModel')
                error('Selected File must be of class "lacm.LinearModel"');
            end  

            obj.LinMdlLabelString = loadedLinMdlObj.Label;
            obj.SelectedLinMdlDef = loadedLinMdlObj;
            obj.ModelName = loadedLinMdlObj.SimulinkModelName; 
            createDefault( obj , loadedLinMdlObj );           
        
            obj.FileName = filename;
            obj.Saved = true;
            update( obj );
        end % loadExisting        
        
        function linMdlObj = createLinearModelObj( obj )
            
            linMdlObj = lacm.LinearModel(...
                        'States',obj.States.getSelectedNames(),...
                        'Inputs',obj.Inputs.getSelectedNames(),...
                        'Outputs',obj.Outputs.getSelectedNames(),...
                        'AlgebraicInput',obj.AlgebraicInputs.getSelectedNames(),...
                        'AlgebraicOutput',obj.AlgebraicOutputs.getSelectedNames(),...
                    	'Label',obj.LinMdlLabelString);
           linMdlObj.SimulinkModelName = obj.ModelName;

        end
        
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
            
            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            
            
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
                
            obj.CurrentReqObj = varStruct.(varNames{1});
            createView (obj.CurrentReqObj , obj.MainPanel );
            
%             obj.CurrentObjFullName = fullfile(pathname,filename);
%             obj.CurrentReqObj.FileName = filename;
            obj.Saved = true;
            update( obj );
            
            %notify(obj,'OpenButtonPressed',UserInterface.UserInterfaceEventData(hobj));
%             update(obj);
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
                obj.CurrentReqObj.OutputSelector.Tree.saveTreeState
            end
            save(fullfile(pathname,filename),'Requirement');
        end % export_CB
                
        function popUpMenuCancelled( obj , ~ , ~ )

            obj.SaveSelJButton.setFlyOverAppearance(true);
            %obj.SaveSelJButton.setContentAreaFilled(true);

        end % popUpMenuCancelled
        

    end
    
    %% Methods - Callbacks
    methods (Access = protected) 
        
%         function newButton_CB( obj , ~ , ~ )
%             if ~obj.Saved
%                 choice = questdlg('The object not saved.  Would you like to continue?', ...
%                     '', ...
%                     'Yes','No','No');
%                 % Handle response
%                 switch choice
%                     case 'No'
%                         return;
%                 end
%             end
%             
%             if ~isempty(obj.ModelName)
%                 choice = questdlg('Keep Simulink Model?', ...
%                     '', ...
%                     'Yes','No','No');
%             else
%                 choice = 'No';
%             end
%             % Handle response
%             switch choice
%                 case 'Yes'
%                     obj.LinMdlLabelString = [];
%                     createDefault( obj );
%                 case 'No'
%                     obj.Inputs = UserInterface.ObjectEditor.LinMdlRow.empty;
%                     obj.Outputs = UserInterface.ObjectEditor.LinMdlRow.empty;
%                     obj.States = UserInterface.ObjectEditor.LinMdlRow.empty;
%                     obj.AlgebraicInputs = UserInterface.ObjectEditor.LinMdlRow.empty;
%                     obj.AlgebraicOutputs = UserInterface.ObjectEditor.LinMdlRow.empty;
%                     obj.LinMdlLabelString = [];
%                     obj.ModelName = [];
%             end
%             update( obj );
%             
%         end % newButton_CB
% 
%         function openButton_CB( obj , ~ , ~ )
%             [filename, pathname] = uigetfile({'*.mat'},'Select Linear Model File:',obj.BrowseStartDir,'MultiSelect', 'on');
%               drawnow();pause(0.5);
%             if isequal(filename,0)
%                 return;
%             end
%             obj.BrowseStartDir = pathname;
%             if ~iscell(filename)
%                 filename = {filename};
%             end
%             counter = 1;
%             
%             for k = 1:length(filename)
%                 varStruct = load(fullfile(pathname,filename{k}));
%                 varNames = fieldnames(varStruct);
%                 linMdlEditObj = UserInterface.ObjectEditor.LinMdlEditor.empty;
%                 for i = 1:length(varNames)  
%                     if counter == 1
%                         obj.LinMdlLabelString = varStruct.(varNames{i}).Label;
%                         obj.SelectedLinMdlDef = varStruct.(varNames{i});
%                         obj.ModelName = varStruct.(varNames{i}).SimulinkModelName;
%                         createDefault( obj , varStruct.(varNames{i}) );
%                         obj.FileName = filename{k};
%                     else
%                         f=figure;
%                         linMdlEditObj( end + 1 ) = UserInterface.ObjectEditor.LinMdlEditor('Parent',f);
%                         loadExisting( linMdlEditObj( end ) , varStruct.(varNames{i}) , filename{k} );
%                         % stagger multiple selections
%                         position = f.Position;
%                         f.Position = [ position(1) + (10*counter) , position(2) - (10*counter) , position(3) , position(4) ]; 
%                     end
%                     counter = counter + 1;
%                 end
%             end
%             update(obj);
%         end % openButton_CB
%         
%         function saveButton_CB( obj , ~ , ~ )
%             
%             linMdlObj = createLinearModelObj( obj );
%             
%             if isempty(linMdlObj)
%                 return;
%             end
%             
%             if isempty(obj.LinMdlLabelString)
%                 label = 'LinearModel';
%             else
%                 %label = obj.LinMdlLabelString;
%                 label = 'LinearModel';
%             end
%             
%             var.(label) = linMdlObj; %#ok<STRNU>
%             [filename, pathname] = uiputfile({'*.mat'},'Save Linear Model Object',label);
%             if isequal(filename,0)
%                 return;
%             end
%             save(fullfile(pathname,filename),'-struct','var');
% 
%             obj.Saved = true;
%             update(obj);
%         end % saveButton_CB  
        
        function labelTextEditBox_CB( obj , hobj , ~ )
            obj.LinMdlLabelString       = hobj.String;
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
                update(obj)
            
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
            switch eventData.Indices(2)
                case 2
                    obj.Inputs(eventData.Indices(1)).Selected = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % inputTable1_ce_CB

        function inputTable1_cs_CB( obj , ~ , ~ )
   

        end % inputTable1_cs_CB
        
        function outputTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.Outputs(eventData.Indices(1)).Selected = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % outputTable1_ce_CB

        function outputTable1_cs_CB( obj , ~ , ~ )
  

        end % outputTable1_cs_CB
        
        function stateTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.States(eventData.Indices(1)).Selected = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % stateTable1_ce_CB

        function stateTable1_cs_CB( obj , ~ , ~ )
  

        end % stateTable1_cs_CB 
        
        function algInputsTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.AlgebraicInputs(eventData.Indices(1)).Selected = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % algInputsTable1_ce_CB

        function algInputsTable1_cs_CB( obj , ~ , ~ )
  

        end % algInputsTable1_cs_CB 
        
        function algOutputsTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    obj.AlgebraicOutputs(eventData.Indices(1)).Selected = eventData.EditData;
            end
            obj.Saved = false;
            obj.update();
        end % algOutputsTable1_ce_CB

        function algOutputsTable1_cs_CB( obj , ~ , ~ )
  

        end % algOutputsTable1_cs_CB 
   
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ ) 
            obj.LabelEditBox.String = obj.LinMdlLabelString;
            
            obj.ModelEditBox.String = obj.ModelName;
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
            
            set(obj.LabelText,'Units','Pixels',...
                'Position',[10 , position(4) - 20 , 200 , 17]);  
            set(obj.LabelEditBox,'Units','Pixels',...
                'Position',[10 , position(4) - 45 , 200 , 25]); 
            set(obj.NumOfTrimText,'Units','Pixels',...
                'Position',[220 , position(4) - 20 , 100 , 17]);  
            set(obj.NumOfTrimComboBox,'Units','Pixels',...
                'Position',[220 , position(4) - 45 , 70 , 25]);  
            
            set(obj.TablePanel,'Units','Pixels',...
                'Position',[10 , 2 , position(3)-20 , position(4) - 100 ]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            positionTab = getpixelposition(obj.TablePanel);
            tableHeight = (positionTab(4) - 180)/2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.InputsText1.Units = 'Pixels';
            obj.InputsText1.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Input1Table.Units = 'Pixels';
            obj.Input1Table.Position = [ 10 , tableHeight + 105, 160 , tableHeight ];
            
%             obj.AddInputsPushButton1.Units = 'Pixels';
%             obj.AddInputsPushButton1.Position = [ 10 , tableHeight + 75 , 90 , 25 ];          
%   
%             obj.RemoveInputsPushButton1.Units = 'Pixels';
%             obj.RemoveInputsPushButton1.Position = [ 100 , tableHeight + 75 , 90 , 25 ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.OutputsText1.Units = 'Pixels';
            obj.OutputsText1.Position = [ 180 , 2*tableHeight + 105 , 180 , 20 ];
            obj.Output1Table.Units = 'Pixels';
            obj.Output1Table.Position = [ 180 , tableHeight + 105, 160 , tableHeight ];
            
%             obj.AddOutputsPushButton1.Units = 'Pixels';
%             obj.AddOutputsPushButton1.Position = [ 200 , tableHeight + 75 , 90 , 25 ];          
%   
%             obj.RemoveOutputsPushButton1.Units = 'Pixels';
%             obj.RemoveOutputsPushButton1.Position = [ 290 , tableHeight + 75 , 90 , 25 ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.StatesText1.Units = 'Pixels';
            obj.StatesText1.Position = [ 350 , 2*tableHeight + 105 , 180 , 20 ];
            obj.State1Table.Units = 'Pixels';
            obj.State1Table.Position = [ 350 , tableHeight + 105, 160 , tableHeight ];
            
%             obj.AddStatesPushButton1.Units = 'Pixels';
%             obj.AddStatesPushButton1.Position = [ 10 , 10 , 90 , 25 ];          
%   
%             obj.RemoveStatesPushButton1.Units = 'Pixels';
%             obj.RemoveStatesPushButton1.Position = [ 100 , 10 , 90 , 25 ];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AlgInputsText.Units = 'Pixels';
            obj.AlgInputsText.Position = [ 10 , tableHeight + 35 , 180 , 20 ];
            obj.AlgInputsTable.Units = 'Pixels';
            obj.AlgInputsTable.Position = [ 10 , 35 , 160 , tableHeight ];
            
%             obj.AddStateDerivsPushButton1.Units = 'Pixels';
%             obj.AddStateDerivsPushButton1.Position = [ 200 , 10 , 90 , 25 ];          
%   
%             obj.RemoveStateDerivsPushButton1.Units = 'Pixels';
%             obj.RemoveStateDerivsPushButton1.Position = [ 290 , 10 , 90 , 25 ];  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.AlgOutputsText.Units = 'Pixels';
            obj.AlgOutputsText.Position = [ 220 , tableHeight + 35 , 220 , 20 ];
            obj.AlgOutputsTable.Units = 'Pixels';
            obj.AlgOutputsTable.Position = [ 180 , 35 , 160 , tableHeight ];
            
%             obj.AddStateDerivsPushButton1.Units = 'Pixels';
%             obj.AddStateDerivsPushButton1.Position = [ 200 , 10 , 90 , 25 ];          
%   
%             obj.RemoveStateDerivsPushButton1.Units = 'Pixels';
%             obj.RemoveStateDerivsPushButton1.Position = [ 290 , 10 , 90 , 25 ];  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        end % reSize
        
        function updateTable( obj )
            
            if ~isempty(obj.Inputs)
                obj.Input1Table.Data        = obj.Inputs.getAsTableData();
            else
                obj.Input1Table.Data       = [];
            end
            
            if ~isempty(obj.Outputs)
                obj.Output1Table.Data       = obj.Outputs.getAsTableData();
            else
                obj.Output1Table.Data       = [];
            end
            
            if ~isempty(obj.States)
                obj.State1Table.Data        = obj.States.getAsTableData();
            else
                obj.State1Table.Data       = [];
            end
            
            if ~isempty(obj.AlgebraicInputs)
                obj.AlgInputsTable.Data     = obj.AlgebraicInputs.getAsTableData();
            else
                obj.AlgInputsTable.Data       = [];
            end
            
            if ~isempty(obj.AlgebraicOutputs)
                obj.AlgOutputsTable.Data    = obj.AlgebraicOutputs.getAsTableData();
            else
                obj.AlgOutputsTable.Data       = [];
            end
              
        end
           
    end
    
    %% Methods - Private
    methods % (Access = private) 
        
        function createDefault( obj , linMdlObj )
            
            if nargin == 2
                mdl = linMdlObj.SimulinkModelName;
                obj.ModelName = mdl;
            else
                mdl = obj.ModelName;
                if isempty(mdl)
                    error('A Simulink Model must be avaliable');
                end
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

            for i = 1:length(inNames)
                obj.Inputs(i)          = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , false );
                obj.AlgebraicInputs(i) = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , false );
            end

            for i = 1:length(outNames)
                obj.Outputs(i)          = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , false );
                obj.AlgebraicOutputs(i) = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , false );
            end  

            for i = 1:length(stateNames)
                obj.States(i) = UserInterface.ObjectEditor.LinMdlRow( stateNames{i} , false );
            end
            
            if nargin == 2

                for i = 1:length(linMdlObj.Inputs)
                    inLogArray = strcmp(linMdlObj.Inputs{i},{obj.Inputs.Name});
                    obj.Inputs(inLogArray).Selected = true;
                end

                for i = 1:length(linMdlObj.Outputs)
                    outLogArray = strcmp(linMdlObj.Outputs{i},{obj.Outputs.Name});
                    obj.Outputs(outLogArray).Selected = true;
                end  

                for i = 1:length(linMdlObj.States)
                    stateLogArray = strcmp(linMdlObj.States{i},{obj.States.Name});
                    obj.States(stateLogArray).Selected = true;
                end
                
                for i = 1:length(linMdlObj.AlgebraicInput)
                    algInputLogArray = strcmp(linMdlObj.AlgebraicInput{i},{obj.AlgebraicInputs.Name});
                    obj.AlgebraicInputs(algInputLogArray).Selected = true;
                end

                for i = 1:length(linMdlObj.AlgebraicOutput)
                    inLogArray = strcmp(linMdlObj.AlgebraicOutput{i},{obj.AlgebraicOutputs.Name});
                    obj.AlgebraicOutputs(inLogArray).Selected = true;
                end     
  
            end
            
        end % createDefault

    end
    
    
    %% Method - Static
    methods ( Static )
        
        
    end
        
end

