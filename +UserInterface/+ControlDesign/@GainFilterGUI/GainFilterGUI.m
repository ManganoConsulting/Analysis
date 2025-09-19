classdef GainFilterGUI < UserInterface.Collection
    
    %% Public properties - Object Handles
    properties (Transient = true)
        UITable               % MATLAB table replacing javax.swing.JTable
        SearchVar1_pm         % Dropdown for first search variable
        SearchVar2_pm         % Dropdown for second search variable
        SearchVar3_pm         % Dropdown for third search variable
        SearchVar4_pm         % Dropdown for fourth search variable
        SearchValue1_lb       % List box for first search value
        SearchValue2_lb       % List box for second search value
        SearchValue3_lb       % List box for third search value
        SearchValue4_lb       % List box for fourth search value
        ScatterGainFilterLabel% Label at top of panel
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
        
        function dataUpdatedInTable( obj , src , event )
            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);
            modifiedOC = obj.FilteredGainColl(modifiedRow);
            switch modifiedCol
                case 1 % selection checkbox
                    modifiedOC.Selected = event.NewData;
                    notify(obj,'FilteredGainsUpdated',UserInterface.UserInterfaceEventData(obj.FilteredGainColl([obj.FilteredGainColl.Selected])));
                case 6 % color selection
                    newColor = uisetcolor(modifiedOC.Color/255);
                    if numel(newColor) == 3
                        modifiedOC.Color = round(newColor*255);
                        obj.TableData{modifiedRow,6} = sprintf('%d,%d,%d',modifiedOC.Color);
                        obj.UITable.Data = obj.TableData;
                    end
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

            obj.ScatterGainFilterLabel.Position = [ 1 , panelPos(4) - 18 , panelPos(3)-2 , 16 ];

            % Position search variable drop downs
            obj.SearchVar1_pm.Position  = [ 5 , panelPos(4) - 55 , 75 , 25 ];
            obj.SearchValue1_lb.Position = [ 85 , panelPos(4) - 55 , 75 , 25 ];
            obj.SearchVar2_pm.Position  = [ panelPos(3) - 163 , panelPos(4) - 55 , 75 , 25 ];
            obj.SearchValue2_lb.Position = [ panelPos(3) - 83 , panelPos(4) - 55 , 75 , 25 ];

            obj.SearchVar3_pm.Position  = [ 5 , panelPos(4) - 90 , 75 , 25 ];
            obj.SearchValue3_lb.Position = [ 85 , panelPos(4) - 90 , 75 , 25 ];
            obj.SearchVar4_pm.Position  = [ panelPos(3) - 163 , panelPos(4) - 90 , 75 , 25 ];
            obj.SearchValue4_lb.Position = [ panelPos(3) - 83 , panelPos(4) - 90 , 75 , 25 ];

            obj.UITable.Position = [2,2,panelPos(3)-7,panelPos(4)-100];
            
            
        end % resize
         
    end
    
    %% Methods - Protected(Update)
    methods (Access = protected)       
   
        function update(obj)
            
            set(obj.SearchVar1_pm,'string',obj.SearchVar1.strList);
            set(obj.SearchVar1_pm,'value', obj.SearchVar1.selVal );



            if isempty(obj.JCBListArraySearchValue1)
                obj.SearchValue1_lb.Items = {};
                obj.SearchValue1_lb.Value = {};
            else
                obj.SearchValue1_lb.Items = obj.JCBListArraySearchValue1;
                if isempty(obj.JCBListSelectedStringSearchValue1)
                    obj.SearchValue1_lb.Value = {};
                else
                    obj.SearchValue1_lb.Value = cellstr(obj.JCBListSelectedStringSearchValue1);
                end
            end


            set(obj.SearchVar2_pm,'string',obj.SearchVar2.strList);
            set(obj.SearchVar2_pm,'value', obj.SearchVar2.selVal );

            if isempty(obj.JCBListArraySearchValue2)
                obj.SearchValue2_lb.Items = {};
                obj.SearchValue2_lb.Value = {};
            else
                obj.SearchValue2_lb.Items = obj.JCBListArraySearchValue2;
                if isempty(obj.JCBListSelectedStringSearchValue2)
                    obj.SearchValue2_lb.Value = {};
                else
                    obj.SearchValue2_lb.Value = cellstr(obj.JCBListSelectedStringSearchValue2);
                end
            end

            set(obj.SearchVar3_pm,'string',obj.SearchVar3.strList);
            set(obj.SearchVar3_pm,'value', obj.SearchVar3.selVal );

            if isempty(obj.JCBListArraySearchValue3)
                obj.SearchValue3_lb.Items = {};
                obj.SearchValue3_lb.Value = {};
            else
                obj.SearchValue3_lb.Items = obj.JCBListArraySearchValue3;
                if isempty(obj.JCBListSelectedStringSearchValue3)
                    obj.SearchValue3_lb.Value = {};
                else
                    obj.SearchValue3_lb.Value = cellstr(obj.JCBListSelectedStringSearchValue3);
                end
            end

            set(obj.SearchVar4_pm,'string',obj.SearchVar4.strList);
            set(obj.SearchVar4_pm,'value', obj.SearchVar4.selVal );

            if isempty(obj.JCBListArraySearchValue4)
                obj.SearchValue4_lb.Items = {};
                obj.SearchValue4_lb.Value = {};
            else
                obj.SearchValue4_lb.Items = obj.JCBListArraySearchValue4;
                if isempty(obj.JCBListSelectedStringSearchValue4)
                    obj.SearchValue4_lb.Value = {};
                else
                    obj.SearchValue4_lb.Value = cellstr(obj.JCBListSelectedStringSearchValue4);
                end
            end
            
            if isempty( obj.JCBListSelectedStringSearchValue1 )
                SelectedStringSearchValue1 = [];
            else
                SelectedStringSearchValue1 = cellstr( obj.JCBListSelectedStringSearchValue1 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue2 )
                SelectedStringSearchValue2 = [];
            else
                SelectedStringSearchValue2 = cellstr( obj.JCBListSelectedStringSearchValue2 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue3 )
                SelectedStringSearchValue3 = [];
            else
                SelectedStringSearchValue3 = cellstr( obj.JCBListSelectedStringSearchValue3 );
            end
            if isempty( obj.JCBListSelectedStringSearchValue4 )
                SelectedStringSearchValue4 = [];
            else
                SelectedStringSearchValue4 = cellstr( obj.JCBListSelectedStringSearchValue4 );
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

            obj.UITable.Data = obj.TableData;
            obj.UITable.ColumnName = obj.TableHeader;
            obj.UITable.ColumnEditable = [true false false false false true];
            obj.UITable.ColumnFormat = {'logical','char','char','char','char','char'};

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
            
            obj.ScatterGainFilterLabel = uilabel(obj.Container,...
                'Text',' Scattered Gain Filter',...
                'BackgroundColor',[55 96 146]/255,...
                'FontColor',[1 1 1],...
                'HorizontalAlignment','left',...
                'FontName','Courier New');

            obj.SearchVar1_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar1_pm_CB);

            obj.SearchValue1_lb = uilistbox(obj.Container,...
                'Items',{},...
                'Multiselect','on',...
                'ValueChangedFcn',@obj.searchValue1_pm_CB);

            obj.SearchVar2_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar2_pm_CB);

            obj.SearchValue2_lb = uilistbox(obj.Container,...
                'Items',{},...
                'Multiselect','on',...
                'ValueChangedFcn',@obj.searchValue2_pm_CB);

            obj.SearchVar3_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar3_pm_CB);

            obj.SearchValue3_lb = uilistbox(obj.Container,...
                'Items',{},...
                'Multiselect','on',...
                'ValueChangedFcn',@obj.searchValue3_pm_CB);

            obj.SearchVar4_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.searchVar4_pm_CB);

            obj.SearchValue4_lb = uilistbox(obj.Container,...
                'Items',{},...
                'Multiselect','on',...
                'ValueChangedFcn',@obj.searchValue4_pm_CB);

            createTable(obj);

            update(obj);

            updateTable( obj );
            resize( obj , [] , [] );

        end % createView
        
        function createTable(obj)
            obj.UITable = uitable('Parent',obj.Container,...
                'Data',obj.TableData,...
                'ColumnName',obj.TableHeader,...
                'ColumnEditable',[true false false false false true],...
                'ColumnFormat',{'logical','char','char','char','char','char'},...
                'CellEditCallback',@obj.dataUpdatedInTable);
        end % createTable
        
    end
    
    %% Methods - Filter Callbacks
    methods
        
        function searchValue1_pm_CB( obj , ~ , ~ )

            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            val = obj.SearchValue1_lb.Value;
            if ischar(val)
                obj.JCBListSelectedStringSearchValue1 = {val};
            else
                obj.JCBListSelectedStringSearchValue1 = val;
            end

            if isempty(obj.JCBListSelectedStringSearchValue1)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
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
            
            val = obj.SearchValue2_lb.Value;
            if ischar(val)
                obj.JCBListSelectedStringSearchValue2 = {val};
            else
                obj.JCBListSelectedStringSearchValue2 = val;
            end

            if isempty(obj.JCBListSelectedStringSearchValue2)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
                obj.SearchVar2.selStr, obj.JCBListSelectedStringSearchValue2,...
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
            
            val = obj.SearchValue3_lb.Value;
            if ischar(val)
                obj.JCBListSelectedStringSearchValue3 = {val};
            else
                obj.JCBListSelectedStringSearchValue3 = val;
            end

            if isempty(obj.JCBListSelectedStringSearchValue3)
                drawnow();
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            [filteredGainColl,~] =...
                searchScatteredGainsDesignCond(obj.ScatteredGainsColl,...
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
                obj.SearchVar2.selStr, obj.JCBListSelectedStringSearchValue2,...
                obj.SearchVar3.selStr, obj.JCBListSelectedStringSearchValue3,...
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
            
            val = obj.SearchValue4_lb.Value;
            if ischar(val)
                obj.JCBListSelectedStringSearchValue4 = {val};
            else
                obj.JCBListSelectedStringSearchValue4 = val;
            end

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
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
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
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
                obj.SearchVar2.selStr, obj.JCBListSelectedStringSearchValue2,...
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
                obj.SearchVar1.selStr, obj.JCBListSelectedStringSearchValue1,...
                obj.SearchVar2.selStr, obj.JCBListSelectedStringSearchValue2,...
                obj.SearchVar3.selStr, obj.JCBListSelectedStringSearchValue3,...
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
            % Clear MATLAB UI component handles
            obj.UITable = [];
            obj.SearchVar1_pm = [];
            obj.SearchVar2_pm = [];
            obj.SearchVar3_pm = [];
            obj.SearchVar4_pm = [];
            obj.SearchValue1_lb = [];
            obj.SearchValue2_lb = [];
            obj.SearchValue3_lb = [];
            obj.SearchValue4_lb = [];
            obj.ScatterGainFilterLabel = [];

            % User Defined Objects
            try %#ok<*TRYNC>
                delete(obj.FilteredGainColl);
            end
            try %#ok<*TRYNC>
                delete(obj.ScatteredGainFileObj);
            end

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

