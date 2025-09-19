classdef FilterCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        Container
        FilterContainer
        ButtonContainer
        FilterParameterContainer

        AddButton
        RemoveButton
        PlotButton
        ExportButton

        FiltTable
        FiltParamTable
        FiltMapTable

        FiltParamTabPanel
        ParamTab
        MapTab
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        Title
        CurrentSelectedFilterRow
        CurrentSelectedFiltParamRow
        
        RowSelectedFiltParam
        RowSelectedFiltMap

        Filters UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        SelectedParameter
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

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
        CurrentSelectedFilter UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        FilterCollTableData
        FilterParamTableData
        FilterMapTableData
        
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        FilterTypes = {'Lead/Lag - 1st Order',...
                        'Lead/Lag - 2nd Order',...
                        'Notch',...
                        'Complimentary 2nd Order Type 1',...
                        'Complimentary 2nd Order Type 2',...
                        'Complimentary 3rd Order Type 1',...
                        'Complimentary 3rd Order Type 2',...
                        'Complimentary 4th Order Type 1',...
                        'Complimentary 4th Order Type 2',...
                        'Complimentary 4th Order Type 3'};
    end % Constant properties  
    
    %% Events
    events
        UpdateSlider
        ParameterUpdated
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = FilterCollection(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','Filter');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;

            createView( obj , options.Parent );

        end % FilterCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
             
        function y = get.CurrentSelectedFilter( obj ) 
            if isempty(obj.Filters)
                y = UserInterface.ControlDesign.Filter.empty;
            else
                if length(obj.CurrentSelectedFilterRow) == 1
                    y = obj.Filters(obj.CurrentSelectedFilterRow);
                else
                    y = UserInterface.ControlDesign.Filter.empty;
                end
            end
        end % CurrentSelectedFilter - Get
        
        function y = get.FilterCollTableData( obj ) 
            
            if isempty(obj.Filters)
                y = {};
            else
                y = [obj.Filters.displayInRow]'; 
            end
        end % FilterCollTableData - Get
        
        function y = get.FilterParamTableData( obj ) 
            selFil = obj.CurrentSelectedFilter;
            if isempty(selFil)
                y = {};
            else
                y = selFil.displayParamsInTable; 
            end
        end % FilterParamTableData - Get
        
        function y = get.FilterMapTableData( obj ) 
            selFil = obj.CurrentSelectedFilter;
            if isempty(selFil)
                y = {};
            else
                y = selFil.displayMapInTable; 
            end; 
        
        end % FilterMapTableData - Get
                
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
       
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Container,'Visible','on');
                set(obj.FilterContainer,'Visible','on');
                set(obj.FilterParameterContainer,'Visible','on');
            else
                set(obj.Container,'Visible','off');
                set(obj.FilterContainer,'Visible','off');
                set(obj.FilterParameterContainer,'Visible','off');
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
    
    %% Methods - View
    methods     
        function createView( obj , parent )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );

            if nargin == 1
                obj.Parent = uifigure();
            else
                obj.Parent = parent;
            end

            % Main Container
            obj.Container = uipanel('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);

            mainLayout = uigridlayout(obj.Container,[3 1],...
                'RowHeight',{'1x',25,'fit'},...
                'ColumnWidth',{'1x'},...
                'RowSpacing',3,...
                'Padding',[5 0 5 5]);

                % Filter Container
                obj.FilterContainer = uipanel(mainLayout);
                obj.FilterContainer.Layout.Row = 1;
                obj.FilterContainer.Layout.Column = 1;
                updateFilterTable( obj );

                % Button Container
                obj.ButtonContainer = uipanel(mainLayout);
                obj.ButtonContainer.Layout.Row = 2;
                obj.ButtonContainer.Layout.Column = 1;

                buttonLayout = uigridlayout(obj.ButtonContainer,[1 5],...
                    'ColumnWidth',{'fit','fit','fit','fit','1x'},...
                    'RowHeight',{'fit'},...
                    'ColumnSpacing',5,...
                    'RowSpacing',0,...
                    'Padding',[0 0 0 0]);

                    % Add Button
                    obj.AddButton = uibutton(buttonLayout,'Text','New',...
                        'Icon',fullfile(icon_dir,'New_16.png'),...
                        'Tooltip','Add New Filter',...
                        'ButtonPushedFcn',@obj.addFilter);
                    obj.AddButton.Layout.Row = 1;
                    obj.AddButton.Layout.Column = 1;

                    % Remove Button
                    obj.RemoveButton = uibutton(buttonLayout,'Text','Remove',...
                        'Icon',fullfile(icon_dir,'StopX_16.png'),...
                        'Tooltip','Remove Filter',...
                        'ButtonPushedFcn',@obj.removeFilter);
                    obj.RemoveButton.Layout.Row = 1;
                    obj.RemoveButton.Layout.Column = 2;

                    % Plot Button
                    obj.PlotButton = uibutton(buttonLayout,'Text','Plot',...
                        'Icon',fullfile(icon_dir,'Figure_16.png'),...
                        'Tooltip','Plot Filter',...
                        'ButtonPushedFcn',@obj.plotFilter);
                    obj.PlotButton.Layout.Row = 1;
                    obj.PlotButton.Layout.Column = 3;

                    % Export Button
                    obj.ExportButton = uibutton(buttonLayout,'Text','Export',...
                        'Icon',fullfile(icon_dir,'Export_16.png'),...
                        'Tooltip','Export Filters',...
                        'ButtonPushedFcn',@obj.exportFilter);
                    obj.ExportButton.Layout.Row = 1;
                    obj.ExportButton.Layout.Column = 4;

                % Filter Param Container
                obj.FilterParameterContainer = uipanel(mainLayout);
                obj.FilterParameterContainer.Layout.Row = 3;
                obj.FilterParameterContainer.Layout.Column = 1;
                obj.FiltParamTabPanel = uitabgroup('Parent',obj.FilterParameterContainer);
                set(obj.FiltParamTabPanel,'Units','normalized','Position',[0 0 1 1]);
                    obj.ParamTab  = uitab('Parent',obj.FiltParamTabPanel,'Title','Parameters');

                    obj.MapTab  = uitab('Parent',obj.FiltParamTabPanel,'Title','Mapping');

                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );

        end % createView

        function updateFilterTable( obj )

            if ~isempty(obj.FiltTable) && isvalid(obj.FiltTable)
                delete(obj.FiltTable);
            end

            obj.FiltTable = uitable('Parent',obj.FilterContainer,...
                'Data',obj.FilterCollTableData,...
                'ColumnName',{'Name','Type'},...
                'ColumnEditable',[true true],...
                'ColumnFormat',{'char',obj.FilterTypes},...
                'CellSelectionCallback',@obj.mousePressedInFilterTable,...
                'CellEditCallback',@obj.dataUpdatedInFilterTable);
            set(obj.FiltTable,'Units','normalized','Position',[0 0 1 1]);

        end % updateFilterTable
        
        function updateFiltParamTable( obj )

            if ~isempty(obj.FiltParamTable) && isvalid(obj.FiltParamTable)
                delete(obj.FiltParamTable);
            end

            if ~isempty(obj.CurrentSelectedFilter)
                selFilName = obj.CurrentSelectedFilter.Name;
            else
                selFilName = ' ';
            end

            obj.FiltParamTable = uitable('Parent',obj.ParamTab,...
                'Data',obj.FilterParamTableData,...
                'ColumnName',{selFilName,'Value'},...
                'ColumnEditable',[false true],...
                'CellSelectionCallback',@obj.mousePressedInFiltParamTable,...
                'CellEditCallback',@obj.dataUpdatedInFiltParamTable);

            set(obj.FiltParamTable,'Units','normalized','Position',[0 0 1 1]);

        end % updateFiltParamTable
        
        function updateFiltMapTable( obj )

            if ~isempty(obj.FiltMapTable) && isvalid(obj.FiltMapTable)
                delete(obj.FiltMapTable);
            end

            if ~isempty(obj.CurrentSelectedFilter)
                selFilName = obj.CurrentSelectedFilter.Name;
            else
                selFilName = ' ';
            end

            obj.FiltMapTable = uitable('Parent',obj.MapTab,...
                'Data',obj.FilterMapTableData,...
                'ColumnName',{selFilName,'Value'},...
                'ColumnEditable',[false true],...
                'CellSelectionCallback',@obj.mousePressedInFiltMapTable,...
                'CellEditCallback',@obj.dataUpdatedInFiltMapTable);

            set(obj.FiltMapTable,'Units','normalized','Position',[0 0 1 1]);

        end % updateFiltMapTable
        
    end
    
    %% Methods - Filter Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFilterTable( obj , ~ , event )
            if ~isempty(event.Indices)
                rowSelected = event.Indices(1);
                obj.CurrentSelectedFilterRow = rowSelected;

                updateFiltParamTable( obj );
                updateFiltMapTable( obj );
            end
        end % mousePressedInFilterTable

        function dataUpdatedInFilterTable( obj , src , event ) %#ok<INUSD>

            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);

            switch modifiedCol
                case 1
                    obj.Filters(modifiedRow).Name   = event.EditData;
                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );
                case 2
                    obj.Filters(modifiedRow).DisplayString = event.EditData;
                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );
            end


        end % dataUpdatedInFilterTable
    
    end
    
    %% Methods - Button Protected Callbacks
    methods (Access = protected) 
        
        function addFilter( obj , ~ , ~ )
            prompt = {'Name:'};
            dlg_title = 'New Filter';
            num_lines = 1;
            defaultans = {'filter'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,struct('WindowStyle','modal'));
            drawnow();pause(0.5);
            if ~isempty(answer)
                obj.Filters(end+1) = UserInterface.ControlDesign.Filter('Name',answer{1});           
                obj.CurrentSelectedFilterRow = length(obj.Filters);          
                updateFilterTable(obj);
                updateFiltParamTable(obj);
                updateFiltMapTable( obj );
            end
            
        end % addFilter
        
        function removeFilter( obj , ~ , ~ )
            obj.Filters(obj.CurrentSelectedFilterRow) = [];
            obj.CurrentSelectedFilterRow = 1;
            updateFilterTable(obj);
            updateFiltParamTable(obj);
            updateFiltMapTable( obj );
        end % removeFilter
        
        function plotFilter( obj , ~ , ~ )
            try
                obj.Filters(obj.CurrentSelectedFilterRow).plot(); 
            catch Mexc
               switch Mexc.identifier
                   case 'Filter:Plot:MissingValues'
                       notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('The filter you are trying to plot has empty values or empty mapping variables.' ,'error'));
                   otherwise
                       rethrow(Mexc);
               end
            end
        end % plotFilter
        
        function exportFilter( obj , ~ , ~ )
            %selectedFilter = obj.Filters(obj.CurrentSelectedFilterRow);
            
            if ~isempty(obj.Filters)
                exportFilter(obj.Filters);
            end
            
            
        end % exportFilter
        
    end
    
    %% Methods - Filter Parameter Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFiltParamTable( obj , ~ , event )
            if ~isempty(event.Indices)
                rowSelected = event.Indices(1);
                obj.RowSelectedFiltParam = rowSelected;

                selFilter = obj.CurrentSelectedFilter;
                if isempty(selFilter)
                    selFilter.CurrentPropertySelected = [];
                else
                    selFilter.CurrentPropertySelected = rowSelected;
                end

                name  = selFilter.CurrentPropertySelected;
                value = num2str(selFilter.(selFilter.CurrentPropertySelected));

                obj.SelectedParameter = UserInterface.ControlDesign.Parameter('Name',name,'String',value);

                notify(obj,'ParameterUpdated',UserInterface.UserInterfaceEventData(obj.SelectedParameter));

            end
        end % mousePressedInFiltParamTable

        function dataUpdatedInFiltParamTable( obj , src , event ) %#ok<INUSD>

            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);

            switch modifiedCol
                case 2
                    selFilter = obj.CurrentSelectedFilter;
                    valueStr = event.EditData;
                    value = str2double(valueStr);
                    if ~isnan(value)
                        selFilter.(selFilter.CurrentPropertySelected) = value;
                    else
                        selFilter.(selFilter.CurrentPropertySelected) = [];
                    end
            end


        end % dataUpdatedInFiltParamTable
        
    end
    
    %% Methods - Filter Map Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFiltMapTable( obj , ~ , event )
            if ~isempty(event.Indices)
                rowSelected = event.Indices(1);
                obj.RowSelectedFiltMap = rowSelected;
            end
        end % mousePressedInFiltMapTable

        function dataUpdatedInFiltMapTable( obj , src , event ) %#ok<INUSD>

            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);

            switch modifiedCol
                case 2
                    selFilter = obj.CurrentSelectedFilter;
                    valueStr = event.EditData;
                    setMappingProperty( selFilter , modifiedRow , valueStr );

            end


        end % dataUpdatedInFiltMapTable
        
    end
    
    %% Methods - Resize Ordinary Methods
    methods     
                                       
        function reSize( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            FiltParamHeight = 155;
            set(obj.FilterContainer,'Units','Pixels','Position',[ 5 , FiltParamHeight + 30 , panelPos(3) - 10 , (panelPos(4) - (FiltParamHeight + 30)) ] );  
            set(obj.ButtonContainer,'Units','Pixels','Position',[ 5 , FiltParamHeight , panelPos(3) - 10 , 30 ] ); 
            set(obj.FilterParameterContainer,'Units','Pixels','Position',[ 5 , 1 , panelPos(3) - 10 , FiltParamHeight ] ); 
%             set(obj.FilterContainer,'Units','Pixels','Position',[ 5 , ((panelPos(4)/2) + 15) , panelPos(3) - 10 , ((panelPos(4)/2) - 15) ] );  
%             set(obj.ButtonContainer,'Units','Pixels','Position',[ 5 , ((panelPos(4)/2) - 15) , panelPos(3) - 10 , 30 ] ); 
%             set(obj.FilterParameterContainer,'Units','Pixels','Position',[ 5 , 1 , panelPos(3) - 10 , ((panelPos(4)/2) - 15)] ); 
        end %reSize
        
        function reSizeFilterC( obj , ~ , ~ )
            panelPos = getpixelposition(obj.FilterContainer);
            set(obj.FiltTable,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4)] );
        end %reSizeFilterC

        function reSizeButtonC( obj , ~ , ~ )
            set(obj.AddButton,'Units','Pixels','Position',[ 1 , 7 , 70 , 20 ] );
            set(obj.RemoveButton,'Units','Pixels','Position',[ 70 , 7 , 70 , 20 ] );
            set(obj.PlotButton,'Units','Pixels','Position',[ 140 , 7 , 65 , 20 ] );
            set(obj.ExportButton,'Units','Pixels','Position',[ 205 , 7 , 65 , 20 ] );
        end %reSizeButtonC
        
        function reSizeFiltParamC( obj , ~ , ~ )
            panelPos = getpixelposition(obj.FilterParameterContainer); 
            %set(obj.FiltParamTabPanel,'Units','Pixels','Position',[ panelPos(1) , panelPos(2) , panelPos(3) - 5 , panelPos(4) ] ); 
            set(obj.FiltParamTabPanel,'Units','Pixels','Position',[ 0 , 0 , panelPos(3) , panelPos(4) ] ); 
%             set(obj.FiltParamTableCont,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4) ]);
%             set(obj.FiltMapTableCont,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4) ]);
%             set(obj.FiltParamTableCont,'Units','Normal','Position',[ 0,0,1,1 ]);
%             set(obj.FiltMapTableCont,'Units','Normal','Position',[0,0,1,1 ]);
        end %reSizeFiltParamC
                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods  
        
        function updateCurrentSelectedParameter( obj , value )
%             if ~isempty(obj.CurrentSelectedParamter)
                % is passed as a handle to the slider so the value gets
                % updated outside of this function
%                 obj.SelectDisplayParameters(obj.CurrentSelectedRow) = obj.CurrentSelectedParamter;
                updateFiltParamTable(obj);
%             end
        end % updateCurrentSelectedParameter
                                                       
%         function  y = getValue( obj , name )
%             ind = strcmp(name,{obj.AvaliableParameterSelection.Name});
%             if any(ind)
%                 y = obj.AvaliableParameterSelection(ind).Value;
%             else 
%                 y = [];
%             end
%         end % getValue
            
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        
        function update(obj)

            updateSelectedTable( obj );
            notify(obj,'UpdateTable');

            
            if ~isempty(obj.CurrentSelectedRow)

                if ~strcmpi(obj.CurrentSelectedParamter.Name,'none')
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Slider Parameter changed to: ''',obj.CurrentSelectedParamter.Name,'''.'],'info'));
                else
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Slider Not Available.','info'));
                end
            end
        end % update
    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Filters object
            cpObj.Filters = copy(obj.Filters);
            
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function defaultMinMax( obj )
            
            testNum = str2double(obj.CurrentSelectedParamter.ValueString);
            if isnan(testNum)
                obj.CurrentSelectedParamter.Max = 1;
                obj.CurrentSelectedParamter.Min = 0;     
            else
                value = obj.CurrentSelectedParamter.Value;
                if value == 0  
                    obj.CurrentSelectedParamter.Max = 1;
                    obj.CurrentSelectedParamter.Min = -1;  
                else
                    obj.CurrentSelectedParamter.Max = value + (abs(value) * 0.5);
                    obj.CurrentSelectedParamter.Min = value - (abs(value) * 0.5);   
                end
            end
            
        end % defaultMinMax
        
        function enablePanel( obj , value )
            if value
                obj.AddButton.Enable = 'on';
                obj.RemoveButton.Enable = 'on';
                obj.PlotButton.Enable = 'on';
                obj.ExportButton.Enable = 'on';
                if ~isempty(obj.FiltParamTable)
                    set(obj.FiltParamTable,'ColumnEditable',[false true]);
                end
                if ~isempty(obj.FiltMapTable)
                    set(obj.FiltMapTable,'ColumnEditable',[false true]);
                end
                if ~isempty(obj.FiltTable)
                    set(obj.FiltTable,'ColumnEditable',[true true]);
                end
            else
                obj.AddButton.Enable = 'off';
                obj.RemoveButton.Enable = 'off';
                obj.PlotButton.Enable = 'off';
                obj.ExportButton.Enable = 'off';
                if ~isempty(obj.FiltParamTable)
                    set(obj.FiltParamTable,'ColumnEditable',[false false]);
                end
                if ~isempty(obj.FiltMapTable)
                    set(obj.FiltMapTable,'ColumnEditable',[false false]);
                end
                if ~isempty(obj.FiltTable)
                    set(obj.FiltTable,'ColumnEditable',[false false]);
                end
            end

        end % enablePanel
        
    end
    
    %% Methods - Delete
    methods
        function delete_GUI_Only( obj )
            try, delete(obj.AddButton); end
            try, delete(obj.RemoveButton); end
            try, delete(obj.PlotButton); end
            try, delete(obj.ExportButton); end
            try, delete(obj.FiltTable); end
            try, delete(obj.FiltParamTable); end
            try, delete(obj.FiltMapTable); end

            try, delete(obj.ButtonContainer); end
            try, delete(obj.FilterContainer); end
            try, delete(obj.FilterParameterContainer); end
            try, delete(obj.FiltParamTabPanel); end
            try, delete(obj.ParamTab); end
            try, delete(obj.MapTab); end
        end % delete_GUI_Only
    end
    

    
end

function exportFilter(selectedFilter)
    import FilterDesign.*


    if ~isempty(selectedFilter)

        selFilter    = selectedFilter;
        nFilter      = length(selFilter);

        % Specify filelocation
        [FILENAME, PATHNAME,FILTERINDEX] = uiputfile({'*.m'}, 'Specify *.m file');
        

        if FILTERINDEX
            varNams = cell(1,nFilter);
            for i=1:nFilter
                
                Namei = strtrim(strrep(selFilter(i).Name,' ','_'));
                
                eval([Namei '.Type = ''' selFilter(i).FilterTypesDisplay{selFilter(i).Type} ''';']);
                eval([Namei '.Type = ''' selFilter(i).FilterTypesDisplay{selFilter(i).Type} ''';']);
                
                filtParams = selFilter(i).getFilterParameterValues;
                for j = 1:length(filtParams)
                    
                    eval([Namei '.(filtParams(j).Name) = filtParams(j).Value;']);
                end
                
                varNams{i} = Namei;
                
            end
               matlab.io.saveVariablesToScript(fullfile(PATHNAME,FILENAME),varNams);

        end
    end
end
