classdef ParameterCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        Container
        MainLayout
        ButtonContainer

 
        FullViewButton
        
    
        SelectedTable

        ReInitButton
        
        CurrentSelectedParamter UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter.empty
        
    end % Public properties
    
    %% Public properties - Object Handles Full View
    properties (Transient = true)  
        Frame
        FullTable
        AddButton
        RemoveButton
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
            obj.Container = uipanel('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);

            obj.MainLayout = uigridlayout(obj.Container,[2 1]);
            obj.MainLayout.RowHeight = {'1x','fit'};
            obj.MainLayout.ColumnWidth = {'1x'};
            obj.MainLayout.RowSpacing = 5;
            obj.MainLayout.ColumnSpacing = 5;
            obj.MainLayout.Padding = [5 5 5 25];

            updateSelectedTable( obj )

            % Button Container
            obj.ButtonContainer = uigridlayout(obj.MainLayout,[1 2]);
            obj.ButtonContainer.Layout.Row = 2;
            obj.ButtonContainer.Layout.Column = 1;
            obj.ButtonContainer.RowHeight = {'fit'};
            obj.ButtonContainer.ColumnWidth = {'1x','1x'};
            obj.ButtonContainer.RowSpacing = 0;
            obj.ButtonContainer.ColumnSpacing = 5;
            obj.ButtonContainer.Padding = [0 0 0 0];
            obj.FullViewButton = uibutton(...
                obj.ButtonContainer,...
                'Text','Edit',...
                'ButtonPushedFcn',@obj.launchFullView_CB);
            obj.FullViewButton.Layout.Row = 1;
            obj.FullViewButton.Layout.Column = 1;
            obj.ReInitButton = uibutton(...
                obj.ButtonContainer,...
                'Text','Re-Initialize Parameters',...
                'Enable',obj.ReInitBtnEnable,...
                'ButtonPushedFcn',@obj.reInit_CB);
            obj.ReInitButton.Layout.Row = 1;
            obj.ReInitButton.Layout.Column = 2;

        end % createView

        function updateSelectedTable( obj )

            % Remove existing table
            if ~isempty(obj.SelectedTable) && isvalid(obj.SelectedTable)
                delete(obj.SelectedTable);
            end

            if isempty(obj.MainLayout) || ~isvalid(obj.MainLayout)
                return;
            end

            obj.SelectedTable = uitable('Parent',obj.MainLayout,...
                'Data',obj.SubParameterTableData,...
                'ColumnName',{'Parameter','Value'},...
                'ColumnEditable',[false true],...
                'CellSelectionCallback',@obj.mousePressedInSelectedTable,...
                'CellEditCallback',@obj.dataUpdatedInSelectedTable);

            obj.SelectedTable.Layout.Row = 1;
            obj.SelectedTable.Layout.Column = 1;

            obj.SelectedTable.ColumnWidth = {115,150};
            obj.SelectedTable.RowName = {};
        end % updateSelectedTable
        
    end 
    
    %% Methods - Selected Parameter Callbacks
    methods   
      
        function dataUpdatedInSelectedTable(obj , ~ , event )
            if isempty(event.Indices)
                return;
            end
            rowInd = event.Indices(1);
            colInd = event.Indices(2);
            switch colInd
                case 2 % Value change
                    hSelParam = obj.SelectDisplayParameters(rowInd);
                    hSelParam.ValueString = num2str(event.EditData);
                    if hSelParam.Global
                        notify(obj,'GlobalIdentified',UserInterface.UserInterfaceEventData(hSelParam));
                    end
            end
        end % dataUpdatedInSelectedTable

        function mousePressedInSelectedTable( obj , ~ , event )

            if ~isempty(event.Indices)
                rowSelected = event.Indices(1);
                if ~isempty(obj.SelectDisplayParameters)
                    obj.CurrentSelectedParamter = obj.SelectDisplayParameters(rowSelected);
                end
            end
        end % mousePressedInSelectedTable
        
        function launchFullView_CB( obj , ~ , ~ )
%             notify(obj,'EditButtonPressed');
            
            createFullView( obj );
        end % launchFullView_CB 
        
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

            if ~isempty(obj.Frame) && isvalid(obj.Frame)
                return;
            end

            obj.Frame = uifigure('Name',obj.Title,...
                                  'Position',[100 100 300 465],...
                                  'CloseRequestFcn',@obj.closeFullView);

            obj.ContextPane = uigridlayout(obj.Frame,[2 1]);
            obj.ContextPane.RowHeight = {'1x','fit'};
            obj.ContextPane.ColumnWidth = {'1x'};

            updateFullViewTable( obj );

            buttonLayout = uigridlayout(obj.ContextPane,[1 2]);
            buttonLayout.Layout.Row = 2;
            buttonLayout.Layout.Column = 1;

            obj.AddButton = uibutton(buttonLayout,'Text','New',...
                'ButtonPushedFcn',@obj.addParameter);
            obj.RemoveButton = uibutton(buttonLayout,'Text','Remove',...
                'ButtonPushedFcn',@obj.removeParameter);
            obj.RemoveButton.Visible = 'off';

        end % createFullView
        
        function updateFullViewTable( obj )

            if ~isempty(obj.FullTable) && isvalid(obj.FullTable)
                delete(obj.FullTable);
            end

            obj.FullTable = uitable(obj.ContextPane,...
                'Data',obj.FullParameterTableData,...
                'ColumnName',obj.FullParameterTableHeader,...
                'ColumnEditable',[true false true true],...
                'ColumnFormat',{'logical','char','char','logical'},...
                'CellSelectionCallback',@obj.mousePressedInFullTable,...
                'CellEditCallback',@obj.dataUpdatedInFullTable);

            obj.FullTable.Layout.Row = 1;
            obj.FullTable.Layout.Column = 1;
            obj.FullTable.RowName = {};
            obj.FullTable.ColumnWidth = {20,100,120,60};

        end % updateFullViewTable
        
    end 
    
    %% Methods - Full Parameter Callbacks
    methods  
        
        function mousePressedInFullTable( obj , ~ , event )
            if ~isempty(event.Indices)
                rowSelected = event.Indices(1);
                obj.RowSelectedInFull = rowSelected;

                if obj.AvaliableParameterSelection(obj.RowSelectedInFull).UserDefined
                    obj.RemoveButton.Visible = 'on';
                else
                    obj.RemoveButton.Visible = 'off';
                end
            end
        end % mousePressedInFullTable

        function dataUpdatedInFullTable( obj , ~ , event )

            if isempty(event.Indices)
                return;
            end
            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);

            initState = obj.AvaliableParameterSelection(modifiedRow).Global;

            switch modifiedCol
                case 1
                    obj.AvaliableParameterSelection(modifiedRow).Displayed   = logical(event.EditData);
                case 3
                    obj.AvaliableParameterSelection(modifiedRow).ValueString = event.EditData;
                case 4
                    obj.AvaliableParameterSelection(modifiedRow).Global = logical(event.EditData);
            end

            if obj.AvaliableParameterSelection(modifiedRow).Global || initState
                notify(obj,'GlobalIdentified',UserInterface.UserInterfaceEventData(obj.AvaliableParameterSelection(modifiedRow)));

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
                obj.RemoveButton.Visible = 'off';
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
                obj.SelectedTable.ColumnEditable = [false true];
            else
                set(obj.FullViewButton,'Enable','off');
                obj.SelectedTable.ColumnEditable = [false false];
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
            try, delete(obj.SelectedTable); end
            try, delete(obj.FullTable); end
            try, delete(obj.AddButton); end
            try, delete(obj.RemoveButton); end
            try, delete(obj.ContextPane); end
            try, delete(obj.MainLayout); end
            try, delete(obj.ButtonContainer); end
            try, delete(obj.FullViewButton); delete(obj.ReInitButton); end
            try, delete(obj.Frame); end
            try, delete(obj.Container); end
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



