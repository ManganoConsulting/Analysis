classdef OCCControlDesign < hgsetget %< lacm.OperatingConditionCollection & hgsetget
    
    %% Public Properties
    properties 
        %OperatingCondition = lacm.OperatingCondition.empty
        
        FilteredOperConds = lacm.OperatingCondition.empty
    end % Public properties
    
    %% Private Properties
    properties %( Access = private ) 

        
        SearchVar1   = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchValue1 = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchVar2   = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchValue2 = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)       
        SearchVar3   = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchValue3 = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchVar4   = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)
        SearchValue4 = struct('selStr',{'All'},'strList',{{'All'}},'selVal',1)

        %CheckAllValue = false
        
       
        
        BorderType
        Title
        
        PrivatePosition
        PrivateUnits
        
        PrivateTableHeader = {'A','All','All','All','All','D',' '}
        
        OperatingConditionCell = {}
    end % Private properties
    
    %% Hidden Properties
    properties ( Hidden = true ) 
        ScatteredGainSourceSelected = false
        GainSource% 1=Synthesis,2=Schedule,3=model 
        
        LastSelectedDesignCond
        LastSelectedAnaylysisCond
    end % Private properties
    
    %% Public properties - Graphics Handles
    properties (Transient = true)
        Parent
        Container
        TableContainer
        
        JTable
        JScroll
        
        
        
        JTableH
        
        JHScroll
        HContainer
        
       
        
        Text1
        Text2
        Text3
        Text4

        
        SearchVar1_pm
        SearchValue1_pm
        SearchVar2_pm
        SearchValue2_pm       
        SearchVar3_pm
        SearchValue3_pm
        SearchVar4_pm
        SearchValue4_pm
        
        
        LabelComp
    end % Public properties
    
    properties ( Dependent = true )
        Position
        Units
    end % Dependant properties
    
    %% Dependant properties - Private SetAccess
    properties (Dependent = true, SetAccess = private)
        DisplayData
        SelectedDisplayData
        DesignOCDisplayText
        SelDesignOperCond
        SelAnalysisOperCond 
        TableModel 
        SelectedFilterFields
        
        TableData
        TableHeader
        
        ParentFigure
        
        FilterSettings
        
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true)
        OperatingCondition
        
    end % Dependant properties 
    
    %% Constant Properties
    properties (Constant)
        Colors = constantColors(); 
    end   
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        MousePressedInTable
        OperCondTableUpdated
    end
    
    %% Methods - Constructor
    methods      
        function obj = OCCControlDesign(varargin)
            
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'BorderType','None');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Parent          = options.Parent;
            obj.BorderType      = options.BorderType;
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;

            selectionView( obj , [] ); 
            
        end % OCCControlDesign
    end % Constructor

    %% Methods - Property Access
    methods
        
        function y = get.OperatingCondition(obj)
            if isempty(obj.OperatingConditionCell)
                y = lacm.OperatingCondition.empty;
            else
                y = [obj.OperatingConditionCell{:}];
            end
        end % OperatingCondition
        
        function set.OperatingCondition(obj , x)
            if isa(x,'lacm.OperatingCondition')
                obj.OperatingConditionCell = {x};
            else
                warning('The property OperatingCondition could not be set in OCCControlDesign.m');
            end
            
        end % OperatingCondition
        
        function y = get.ParentFigure( obj )
            y = ancestor(obj.Container,'Figure','toplevel');
        end % ParentFigure
        
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
        
        function y = get.FilterSettings(obj)
            fc1_Str = obj.SearchVar1.selStr;
            fc2_Str = obj.SearchVar2.selStr;
            ic_Str  = obj.SearchVar3.selStr;
            wc_Str  = obj.SearchVar4.selStr;
            
            
            designOC = obj.FilteredOperConds([obj.FilteredOperConds.SelectedforDesign]);
            
            if isempty(designOC)      
                designOC = obj.FilteredOperConds(1);
            end
            
            valsStrCellArray = getUnformattedDisplayText(designOC, fc1_Str, fc2_Str, ic_Str, wc_Str);
% 
%             
%             fc1_Val = valsStrCellArray{1};
%             fc2_Val = valsStrCellArray{2};
%             ic_Val  = valsStrCellArray{3};
%             wc_Val  = valsStrCellArray{4};
%             
%             y = UserInterface.ControlDesign.OperCondFilterSettings(fc1_Str, fc2_Str, ic_Str, wc_Str, fc1_Val, fc2_Val, ic_Val, wc_Val);
            y = UserInterface.ControlDesign.OperCondFilterSettings(fc1_Str, fc2_Str, ic_Str, wc_Str, valsStrCellArray{:});
            
        end % FilterSettings
        
        function y = get.DisplayData(obj)
            fc1 = obj.SearchVar1.selStr;
            fc2 = obj.SearchVar2.selStr;
            ic  = obj.SearchVar3.selStr;
            wc  = obj.SearchVar4.selStr;
            y = cell(length(obj.FilteredOperConds),2);
            for i = 1:length(obj.FilteredOperConds)
                % get the display text for the operCond
                y{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;
                y{i,2} = getDisplayText(obj.FilteredOperConds(i),fc1,fc2,ic,wc);
            end
        end % DisplayData
        
        function y = get.SelectedDisplayData(obj)
            fc1 = obj.SearchVar1.selStr;
            fc2 = obj.SearchVar2.selStr;
            ic  = obj.SearchVar3.selStr;
            wc  = obj.SearchVar4.selStr;
            y = cell(length(obj.FilteredOperConds),2);
            for i = 1:length(obj.FilteredOperConds)
                % get the display text for the operCond
                y{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;
                y{i,2} = getSelectedDisplayText(obj.FilteredOperConds(i),fc1,fc2,ic,wc);
            end
        end % SelectedDisplayData
        
        function data = get.TableData(obj)
            selFields = {'All','All','All','All'}; 
            data = cell(length(obj.FilteredOperConds),7);
            for i = 1:length(obj.FilteredOperConds)
                data{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;%true;
                [ data(i,2:5) , selFields ] = getDisplayData(obj.FilteredOperConds(i),obj.SelectedFilterFields{:});
                data{i,6} = obj.FilteredOperConds(i).SelectedforDesign;%false;%
                data{i,7} = [int2str(obj.FilteredOperConds(i).Color(1)),',',int2str(obj.FilteredOperConds(i).Color(2)),',',int2str(obj.FilteredOperConds(i).Color(3))];
            end
            obj.PrivateTableHeader = ['A',selFields,'D',' '];
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
        
        function ocObj = get.SelDesignOperCond(obj)
            logArray = [obj.FilteredOperConds.SelectedforDesign];
            ocObj = obj.FilteredOperConds(logArray);
        end % SelDesignOperCond
        
        function ocObj = get.SelAnalysisOperCond(obj)
            logArray = [obj.FilteredOperConds.SelectedforAnalysis];
            ocObj = obj.FilteredOperConds(logArray);
        end % SelAnalysisOperCond
        
        function text = get.DesignOCDisplayText(obj)
            if ~isempty(obj.SelDesignOperCond)
                text = getDisplayText(obj.SelDesignOperCond,obj.SearchVar1.selStr,obj.SearchVar2.selStr,obj.SearchVar3.selStr,obj.SearchVar4.selStr);
            else
                text = '<html><font color="rgb(0,0,255)">Design Model Not Selected</font></html>'; 
            end
            
        end % DesignOCDisplayText
        
        function model = get.TableModel(obj)
            selFields = cell(1,4); 
            data = cell(length(obj.FilteredOperConds),6);
            for i = 1:length(obj.FilteredOperConds)
                data{i,1} = java.lang.Boolean(false);
                [ data(i,2:5) , selFields ] = getDisplayData(obj.FilteredOperConds(i),obj.SelectedFilterFields{:});
                data{i,6} = java.lang.Boolean(false);
            end
            colNames = ['A',selFields,'D'];

            model = javaObjectEDT('javax.swing.table.DefaultTableModel',data,colNames);
            
           
        end % TableModel
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 

        function setFilteredOCAllSelected(obj)
            
            for i = 1:length(obj.FilteredOperConds)
                if obj.FilteredOperConds(i).SelectedforDesign == false
                    obj.FilteredOperConds(i).SelectedforAnalysis = true;
                    obj.FilteredOperConds(i).Color = obj.Colors{i}; % needs updating to not skip color
                else
                    obj.FilteredOperConds(i).Color = [0 0 255];
                end
            end
            update(obj);
        end % setFilteredOCAllSelected  
        
        function initializeFilteredOC(obj)
            
            for i = 1:length(obj.FilteredOperConds)
                obj.FilteredOperConds(i).SelectedforAnalysis = true;
                obj.FilteredOperConds(i).Color = obj.Colors{i};
            end
        end % initializeFilteredOC  
               
        function addOperCond(obj, newOperCond)
            
            obj.OperatingConditionCell{end + 1} = newOperCond;
            updateAvaliableSelections(obj);
            
%             obj.OperatingCondition = [obj.OperatingCondition,newOperCond];
%             updateAvaliableSelections(obj);
        end % addOperCond     
        
        function removeOperCond( obj , x )
            if ischar(x) || length(obj.OperatingConditionCell) < 2
                obj.OperatingConditionCell = {};
            else
                obj.OperatingConditionCell(x) = [];
            end
            updateAvaliableSelections(obj);
        end % removeOperCond

            
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
        function selectionView(obj,parent)
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

            % get parent position
            %panelPos = getpixelposition(obj.Container);
            try
                bkColor = get(obj.Container,'BackgroundColor');
            catch
               bkColor = get(obj.Container,'Color'); 
            end
            popupFtSize = 8;
            
            
            panelPos = getpixelposition(obj.Container);
            
            obj.LabelComp = uilabel('Parent',obj.Container,...
                'Text','Operating Conditons',...
                'FontName','Courier New',...
                'FontColor',[1 1 1],...
                'BackgroundColor',[55 96 146]/255,...
                'HorizontalAlignment','left',...
                'VerticalAlignment','bottom',...
                'Position',[1 , panelPos(4) - 17 , panelPos(3) , 16]);
            
            
            
            
            % - searchMdlRow1HBox ------------------------------------
            obj.Text1 = uicontrol('Parent',obj.Container,...
                'Style','text',...
                'String','Parameter #1(FC):',...
                'FontSize',10,...
                'HorizontalAlignment','Center',...
                'Visible','on',...
                'BackgroundColor', bkColor);
            obj.Text2 = uicontrol('Parent',obj.Container,...
                'Style','text',...
                'String','Parameter #2(FC):',...
                'FontSize',10,...
                'HorizontalAlignment','Center',...
                'Visible','on',...
                'BackgroundColor', bkColor);
            % - searchMdlRow2HBox ------------------------------------
            obj.SearchVar1_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchVar1_pm_CB);
            obj.SearchValue1_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchValue1_pm_CB);
            obj.SearchVar2_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchVar2_pm_CB);
            obj.SearchValue2_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchValue2_pm_CB);                            
            % - searchMdlRow3HBox ------------------------------------
            obj.Text3 = uicontrol('Parent',obj.Container,...
                'Style','text',...
                'String','Parameter #3(IC):',...
                'FontSize',10,...
                'HorizontalAlignment','Center',...
                'Visible','on',...
                'BackgroundColor', bkColor);
            obj.Text4 = uicontrol('Parent',obj.Container,...
                'Style','text',...
                'String','Parameter #4(WC):',...
                'FontSize',10,...
                'HorizontalAlignment','Center',...
                'Visible','on',...
                'BackgroundColor', bkColor);
            % - searchMdlRow4HBox ------------------------------------
           obj.SearchVar3_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchVar3_pm_CB);
            obj.SearchValue3_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'String', {'All'},...
                'FontSize',popupFtSize,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchValue3_pm_CB);
            obj.SearchVar4_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchVar4_pm_CB);
            obj.SearchValue4_pm = uicontrol(...
                'Parent',obj.Container,...
                'Style','popupmenu',...
                'FontSize',popupFtSize,...
                'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Callback',@obj.linModels_searchValue4_pm_CB);                    

            obj.TableContainer= uicontainer('Parent',obj.Container,...
               'Units','Pixels',...
               'Position',[2,2,panelPos(3)-7,panelPos(4)-116]);
%             lacm.OperatingCondition;
            
            obj.updateTable;
%             createMTable(obj);  

            update(obj);
            resize( obj , [] , [] );

        end % selectionView
        
        function updateTable( obj , designSelBool , analysisCheckBool , gainSourceScattered )
            
            switch nargin
                case 1
                    if length(obj.LastSelectedAnaylysisCond) == length(obj.FilteredOperConds)
                        analysisCheckBool = obj.LastSelectedAnaylysisCond;
                    else  
                        analysisCheckBool = true(1,length(obj.FilteredOperConds));
                    end
                    if obj.ScatteredGainSourceSelected
                        filteredOCSelected = [obj.FilteredOperConds.HasSavedGain];
                        if sum(filteredOCSelected) <= 1
                            designSelBool = filteredOCSelected;
                        else
                            designSelBool = false(1,length(obj.FilteredOperConds));
                        end
                    else
                        if length(obj.LastSelectedDesignCond) == length(obj.FilteredOperConds)
                            designSelBool = obj.LastSelectedDesignCond;
                        else
                            designSelBool = false(1,length(obj.FilteredOperConds));
                        end
                    end
                case 2
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperConds)
                        designSelBool     = false(1,length(obj.FilteredOperConds));
                    end
                    analysisCheckBool = true(1,length(obj.FilteredOperConds));
                case 3
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperConds)
                        designSelBool     = false(1,length(obj.FilteredOperConds));
                    end
                    if ~islogical(analysisCheckBool) || length(analysisCheckBool) ~= length(obj.FilteredOperConds)
                        analysisCheckBool = true(1,length(obj.FilteredOperConds));
                    end  
                case 4
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperConds)
                        designSelBool     = false(1,length(obj.FilteredOperConds));
                    end
                    if ~islogical(analysisCheckBool) || length(analysisCheckBool) ~= length(obj.FilteredOperConds)
                        analysisCheckBool = true(1,length(obj.FilteredOperConds));
                    end  
                    obj.ScatteredGainSourceSelected = gainSourceScattered;
            end
            
            
            for i = 1:length(obj.FilteredOperConds)
                obj.FilteredOperConds(i).SelectedforDesign   = designSelBool(i); 
                obj.FilteredOperConds(i).SelectedforAnalysis = analysisCheckBool(i);
            end
            
            delete(obj.HContainer);

            %------------------------------------------------------------------
            % Create MATLAB uitable instead of java JTable
            %------------------------------------------------------------------
            data   = obj.TableData;
            obj.JTable = uitable('Parent',obj.TableContainer, ...
                'Data',data, ...
                'ColumnName',obj.TableHeader, ...
                'ColumnEditable',[true false false false false true true], ...
                'Units','normalized', ...
                'Position',[0 0 1 1], ...
                'RowName',[], ...
                'CellEditCallback',@(src,event)obj.dataUpdatedInTable(src,event), ...
                'CellSelectionCallback',@(src,event)obj.mousePressedInTable(src,event));
            obj.HContainer = obj.JTable;

            % Configure column widths similar to previous java implementation
            obj.JTable.ColumnWidth = {20,60,60,60,60,20,20};

            % Apply existing callback stubs for key press/release if supported
            if isprop(obj.JTable,'KeyPressFcn')
                obj.JTable.KeyPressFcn = @obj.keyPressedInTable;
            end
            if isprop(obj.JTable,'KeyReleaseFcn')
                obj.JTable.KeyReleaseFcn = @obj.keyReleasedInTable;
            end

            % Apply background color style for color column
            for r = 1:size(data,1)
                c = sscanf(data{r,7},'%d,%d,%d')';
                if numel(c)==3
                    s = uistyle('BackgroundColor',c/255);
                    addStyle(obj.JTable,s,'cell',[r 7]);
                end
            end

            notify(obj,'OperCondTableUpdated');
            
        end % updateTable
       
    end % Ordinary Methods
    
    %% Methods FilterCallbacks
    methods 
        
        function linModels_searchValue1_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchValue1_pm" popup menu
        %----------------------------------------------------------------------
            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchValue1.selStr = avalParam{selVal};
            gui.SearchValue1.selVal = selVal;

            gui.searchLinMdlHelper();

        end % linModels_searchValue1_pm_CB 
        
        function linModels_searchValue2_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchValue2_pm" popup menu
        %----------------------------------------------------------------------
            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchValue2.selStr = avalParam{selVal};
            gui.SearchValue2.selVal = selVal;
            gui.searchLinMdlHelper();

        end % linModels_searchValue2_pm_CB
        
        function linModels_searchValue3_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchValue3_pm" popup menu
        %----------------------------------------------------------------------   
            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchValue3.selStr = avalParam{selVal};
            gui.SearchValue3.selVal = selVal;

            gui.searchLinMdlHelper();

        end % linModels_searchValue3_pm_CB
        
        function linModels_searchValue4_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchValue4_pm" popup menu
        %----------------------------------------------------------------------

            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchValue4.selStr = avalParam{selVal};
            gui.SearchValue4.selVal = selVal;

            gui.searchLinMdlHelper();

        end % linModels_searchValue4_pm_CB
        
        function linModels_searchVar1_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchVar1_pm" popup menu
        %----------------------------------------------------------------------

            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchVar1.selStr = avalParam{selVal};
            gui.SearchVar1.selVal = selVal;

            % set value field to 'All'
            gui.SearchValue1.strList = {'All'};
            gui.SearchValue1.selVal = 1;
            gui.SearchValue1.selStr = 'All';
            gui.SearchValue2.strList = {'All'};
            gui.SearchValue2.selVal = 1;
            gui.SearchValue2.selStr = 'All';
            gui.SearchValue3.strList = {'All'};
            gui.SearchValue3.selVal = 1;
            gui.SearchValue3.selStr = 'All';
            gui.SearchValue4.strList = {'All'};
            gui.SearchValue4.selVal = 1;
            gui.SearchValue4.selStr = 'All';

            gui.searchLinMdlHelper(); 

        end % linModels_searchVar1_CB

        function linModels_searchVar2_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchVar2_pm" popup menu
        %----------------------------------------------------------------------

            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchVar2.selStr = avalParam{selVal};
            gui.SearchVar2.selVal = selVal;
            % set value field to 'All'
            gui.SearchValue2.strList = {'All'};
            gui.SearchValue2.selVal = 1;
            gui.SearchValue2.selStr = 'All';

            gui.searchLinMdlHelper();

        end % linModels_searchVar2_pm_CB

        function linModels_searchVar3_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchVar3_pm" popup menu
        %----------------------------------------------------------------------

            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchVar3.selStr = avalParam{selVal};
            gui.SearchVar3.selVal = selVal;

            % set value field to 'All'
            gui.SearchValue3.strList = {'All'};
            gui.SearchValue3.selVal = 1;
            gui.SearchValue3.selStr = 'All';

            gui.searchLinMdlHelper();

        end % linModels_searchVar3_pm_CB       
        
        function linModels_searchVar4_pm_CB( gui , hobj , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.mainLayout.searchVar4_pm" popup menu
        %----------------------------------------------------------------------

            avalParam = get(hobj,'string');
            selVal    = get(hobj,'value');
            gui.SearchVar4.selStr = avalParam{selVal};
            gui.SearchVar4.selVal = selVal;

            % set value field to 'All'
            gui.SearchValue4.strList = {'All'};
            gui.SearchValue4.selVal = 1;
            gui.SearchValue4.selStr = 'All';

            gui.searchLinMdlHelper();

        end % linModels_searchVar4_pm_CB

        function searchLinMdlHelper(obj)
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, false);


            [obj.FilteredOperConds,~] =...
                UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperatingCondition,...
                obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                obj.SearchVar4.selStr, obj.SearchValue4.selStr); 

            if ~strcmp(obj.SearchVar1.selStr,'All')

                [FilteredOperConds1,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperatingCondition,...
                    obj.SearchVar1.selStr, 'All',...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl1 = zeros(size(FilteredOperConds1));
                for i = 1:length(FilteredOperConds1)
                    sl1(i) = FilteredOperConds1(i).FlightCondition.(obj.SearchVar1.selStr);
                end
                obj.SearchValue1.strList = ['All';cellstr(num2str(sort(unique(sl1)).'))];
            end
            if ~strcmp(obj.SearchVar2.selStr,'All')

                [FilteredOperConds2,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperatingCondition,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, 'All',...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl2 = zeros(size(FilteredOperConds2));
                for i = 1:length(FilteredOperConds2)
                    sl2(i) = FilteredOperConds2(i).FlightCondition.(obj.SearchVar2.selStr);
                end
                obj.SearchValue2.strList = ['All';cellstr(num2str(sort(unique(sl2)).'))];
            end
            if ~strcmp(obj.SearchVar3.selStr,'All')

                [FilteredOperConds3,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperatingCondition,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, 'All',...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl3 = zeros(size(FilteredOperConds3));
                for i = 1:length(FilteredOperConds3)
                    try % This will take input values with the same name first
                        sl3(i) = FilteredOperConds3(i).Inputs.get(obj.SearchVar3.selStr).Value;
                    catch
                        sl3(i) = FilteredOperConds3(i).Outputs.get(obj.SearchVar3.selStr).Value;
                    end
                end
                
                
                sl3 = round2(sl3);
                obj.SearchValue3.strList = ['All';cellstr(num2str(sort(unique(sl3)).'))];
            end
            if ~strcmp(obj.SearchVar4.selStr,'All')

                [FilteredOperConds4,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperatingCondition,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, 'All'); 
                sl4 = cell(size(FilteredOperConds4));
                for i = 1:length(FilteredOperConds4)
                    sl4{i} = num2str(FilteredOperConds4(i).MassProperties.get(obj.SearchVar4.selStr));
                end
                obj.SearchValue4.strList = ['All',sort(unique(sl4))]; 
            end        

            obj.SearchValue1.selVal = find(strcmp(strtrim(obj.SearchValue1.selStr),strtrim(obj.SearchValue1.strList)));
            obj.SearchValue2.selVal = find(strcmp(strtrim(obj.SearchValue2.selStr),strtrim(obj.SearchValue2.strList)));
            obj.SearchValue3.selVal = find(strcmp(strtrim(obj.SearchValue3.selStr),strtrim(obj.SearchValue3.strList)));
            obj.SearchValue4.selVal = find(strcmp(strtrim(obj.SearchValue4.selStr),strtrim(obj.SearchValue4.strList)));

            initializeFilteredOC(obj);
            obj.update();
            updateTable(obj);

            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, true);
        end %searchLinMdlHelper        
    end

    %% Methods
    methods 
        
        function updateAvaliableSelections(obj,icNames,massPropNames)
            % update fc popupmenu string          
            obj.SearchVar1.selVal = 1;
            obj.SearchVar1.selStr = 'All';
            obj.SearchVar2.selVal = 1;
            obj.SearchVar2.selStr = 'All';      
            obj.SearchVar3.selVal = 1;
            obj.SearchVar3.selStr = 'All';
            obj.SearchVar4.selVal = 1;
            obj.SearchVar4.selStr = 'All';            


            obj.SearchValue1.strList = {'All'};
            obj.SearchValue1.selVal = 1;
            obj.SearchValue1.selStr = 'All';
            obj.SearchValue2.strList = {'All'};
            obj.SearchValue2.selVal = 1;
            obj.SearchValue2.selStr = 'All';
            obj.SearchValue3.strList = {'All'};
            obj.SearchValue3.selVal = 1;
            obj.SearchValue3.selStr = 'All';
            obj.SearchValue4.strList = {'All'};
            obj.SearchValue4.selVal = 1;
            obj.SearchValue4.selStr = 'All';


            if isempty(obj.OperatingCondition)
                obj.SearchVar1.strList = {'All'};
                obj.SearchVar2.strList = {'All'};
                obj.SearchVar3.strList = {'All'};
                obj.SearchVar4.strList = {'All'};
            else
                obj.SearchVar1.strList = {'All';'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                obj.SearchVar2.strList = {'All';'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                obj.SearchVar3.strList = ['All';{obj.OperatingCondition(1).Inputs.Name}';{obj.OperatingCondition(1).Outputs.Name}'];
                obj.SearchVar4.strList = ['All';'Label';'WeightCode';{obj.OperatingCondition(1).MassProperties.Parameter.Name}'];
            end
% %             
% %             obj.SearchVar3.selVal = 1; 
% %             obj.SearchValue3.selVal = 1;
% % 
% %             obj.SearchVar4.selVal = 1; 
% %             obj.SearchValue4.selVal = 1;
            
            obj.update();
            obj.searchLinMdlHelper();
        end % updateAvaliableSelections
        
    end
    
    %% Methods - Update
    methods (Access = protected) 
        
        function update(obj)
%             % Call super class method
%             update@lacm.OperatingConditionCollection(obj);
            
            obj.SearchVar1_pm.String = obj.SearchVar1.strList;
            obj.SearchVar1_pm.Value =  obj.SearchVar1.selVal;

            obj.SearchValue1_pm.String = obj.SearchValue1.strList;
            obj.SearchValue1_pm.Value =  obj.SearchValue1.selVal;

            obj.SearchVar2_pm.String = obj.SearchVar2.strList;
            obj.SearchVar2_pm.Value =  obj.SearchVar2.selVal;

            obj.SearchValue2_pm.String = obj.SearchValue2.strList;
            obj.SearchValue2_pm.Value =  obj.SearchValue2.selVal;

            obj.SearchVar3_pm.String = obj.SearchVar3.strList;
            obj.SearchVar3_pm.Value =  obj.SearchVar3.selVal ;

            obj.SearchValue3_pm.String = obj.SearchValue3.strList;
            obj.SearchValue3_pm.Value =  obj.SearchValue3.selVal;

            obj.SearchVar4_pm.String = obj.SearchVar4.strList;
            obj.SearchVar4_pm.Value =  obj.SearchVar4.selVal ;

            obj.SearchValue4_pm.String = obj.SearchValue4.strList;
            obj.SearchValue4_pm.Value =  obj.SearchValue4.selVal;
            
        end % update   
        
        function resize( obj , ~ , ~ )
            
%             % Call super class method
%             resize@lacm.OperatingConditionCollection(obj,[],[]);
            
            panelPos = getpixelposition(obj.Container);
            
            % uilabel components always use pixel units, so only set Position
            obj.LabelComp.Position = [ 1 , panelPos(4) - 17 , panelPos(3) , 16 ];

            % - searchMdlRow1HBox ------------------------------------
            set(obj.Text1,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 41 , 155 , 20 ]);
            set(obj.Text2,...
                'Units','Pixels',...
                'Position',[ panelPos(3)-160 , panelPos(4) - 41 , 155 , 20 ]);
            % - searchMdlRow2HBox ------------------------------------
            set(obj.SearchVar1_pm,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 61 , 75 , 25 ]);
            set(obj.SearchValue1_pm,...
                'Units','Pixels',...
                'Position',[ 85 , panelPos(4) - 61 , 75 , 25 ]);
            set(obj.SearchVar2_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 163 , panelPos(4) - 61 , 75 , 25 ]);
            set(obj.SearchValue2_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 83 , panelPos(4) - 61 , 75 , 25 ]);                            
            % - searchMdlRow3HBox ------------------------------------
            set(obj.Text3,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 86 , 155 , 20 ]);
            set(obj.Text4,...
                'Units','Pixels',...
                'Position',[ panelPos(3)-160 , panelPos(4) - 86 , 155 , 20 ]);
           set(obj.SearchVar3_pm,...
                'Units','Pixels',...
                'Position',[ 5 , panelPos(4) - 106 , 75 , 25 ]);
            set(obj.SearchValue3_pm,...
                'Units','Pixels',...
                'Position',[ 85 , panelPos(4) - 106 , 75 , 25 ]);
            set(obj.SearchVar4_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 163 , panelPos(4) - 106 , 75 , 25 ]);
            set(obj.SearchValue4_pm,...
                'Units','Pixels',...
                'Position',[ panelPos(3) - 83 , panelPos(4) - 106 , 75 , 25 ]);                    

%             set(obj.Text5,...
%                 'Units','Pixels',...
%                 'Position',[1,panelPos(4)-113,panelPos(3)-45,20]);
%             set(obj.DesignMdlTxtContainer,...
%                 'Units','Pixels',...
%                 'Position',[1,panelPos(4)-124,panelPos(3)-45,20]);  
            %set(obj.MTable,'units', 'pixels','pos',[10,10,panelPos(3)-10,panelPos(4)-100]); 
            set(obj.TableContainer,'units', 'pixels','position',[2,2,panelPos(3)-7,panelPos(4)-116]); 
            %set(obj.SearchResultsDisplay_tb,'Units','Pixels','Position',[2,2,panelPos(3)-7,panelPos(4)-100]); 

        end % resize
        
        function enablePopUps( obj , val )
%             set(obj.SearchVar1_pm,  'Enable',val);
%             set(obj.SearchValue1_pm,'Enable',val);
%             set(obj.SearchVar2_pm,  'Enable',val);
%             set(obj.SearchValue2_pm,'Enable',val);                            
%             set(obj.SearchVar3_pm,  'Enable',val);
%             set(obj.SearchValue3_pm,'Enable',val);
%             set(obj.SearchVar4_pm,  'Enable',val);
%             set(obj.SearchValue4_pm,'Enable',val); 
        end % enablePopUps
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function cpObj = copyElement(obj)
%             % Call super class method
%             copyElement@lacm.OperatingConditionCollection(obj);
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the FilteredOperConds object
            cpObj.FilteredOperConds = copy(obj.FilteredOperConds);
            % Make a deep copy of the OperatingCondition object
            cpObj.OperatingCondition = copy(obj.OperatingCondition); 
            % Make a deep copy of the OperatingConditionCell object
            cpObj.OperatingConditionCell = copy(obj.OperatingConditionCell); 
            
        end
                
    end

    %% Method - Callbacks
    methods %(Access = protected)
        
        function mousePressedInTable( obj , hModel , hEvent )
            notify(obj,'MousePressedInTable',GeneralEventData({hModel,hEvent}));
%             
%             if hEvent.isMetaDown
%                 this_dir = fileparts( mfilename( 'fullpath' ) );
%                 icon_dir = fullfile( this_dir,'..','..','Resources' );
%                 icon2  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'view_icon_24.png'));
%                 
%                 jmenu = javaObjectEDT('javax.swing.JPopupMenu');   
%                 if hModel.getSelectedRow >= 0
% 
%                     menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Show Operating Condition',icon2);
%                     menuItem1h = handle(menuItem1,'CallbackProperties');
%                     menuItem1h.ActionPerformedCallback = {@obj.write2MFile , hModel.getSelectedRows };
%                     
%                     menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All - Analysis');
%                     menuItem2h = handle(menuItem2,'CallbackProperties');
%                     menuItem2h.ActionPerformedCallback = @obj.selectAllAnalysis;
%                     
%                     
%                     menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All - Analysis');
%                     menuItem3h = handle(menuItem3,'CallbackProperties');
%                     menuItem3h.ActionPerformedCallback = @obj.deselectAllAnalysis;
%                     
%                     jmenu.add(menuItem1);
%                     jmenu.add(menuItem2);
%                     jmenu.add(menuItem3);
%                            
%                 else
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     % find all scattered gain files
%                     scattFileNames = {obj.GainsScattered.Children.Name};
%                     scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
% 
%                     % Prepare the context menu (note the use of HTML labels)
%                     menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert New Scattered Gain Object');
%                     menuItem1h = handle(menuItem1,'CallbackProperties');
%                     set(menuItem1h,'ActionPerformedCallback',{@obj.insertEmptyScatteredGainObj_CB,node.Parent,true});
% 
%                         menuItem2 = javax.swing.JMenu('<html>Select Scattered Gain Object for Save');
%                         menuItem2.setIcon(scattIcon);
% 
%                         for i = 1:length(scattFileNames)
%                             menuItem21 = javaObjectEDT('javax.swing.JMenuItem',['<html>',scattFileNames{i}],scattIcon);
%                             menuItem21h = handle(menuItem21,'CallbackProperties');
%                             set(menuItem21h,'ActionPerformedCallback',{@obj.selectScatteredGainFile2Write,node.Parent,scattFileNames{i}});
%                             menuItem2.add(menuItem21);
%                         end
% 
%                     % Add all menu items to the context menu
%                     jmenu.add(menuItem1);
%                     jmenu.add(menuItem2);
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     
%                     menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All - Analysis');
%                     menuItem2h = handle(menuItem2,'CallbackProperties');
%                     menuItem2h.ActionPerformedCallback = @obj.selectAllAnalysis;
%                     
%                     
%                     menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All - Analysis');
%                     menuItem3h = handle(menuItem3,'CallbackProperties');
%                     menuItem3h.ActionPerformedCallback = @obj.deselectAllAnalysis;
% 
%                     jmenu.add(menuItem2);
%                     jmenu.add(menuItem3);
%                 end
% 
%                 jmenu.show(obj.JTable, 35 , 60 );
%                 jmenu.repaint;
%             end
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
            if isempty(event.Indices)
                return;
            end
            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);
            modifiedOC  = obj.FilteredOperConds(modifiedRow);
            newData     = event.NewData;
            switch modifiedCol
                case 1
                    if sum([obj.FilteredOperConds.SelectedforDesign]) > 1 && obj.GainSource == 3
                        updateTable( obj , [obj.FilteredOperConds.SelectedforDesign] , [obj.FilteredOperConds.SelectedforAnalysis]);
                    else
                        modifiedOC.SelectedforAnalysis = newData;
                        obj.LastSelectedAnaylysisCond = [obj.FilteredOperConds.SelectedforAnalysis];
                    end
                case 6
                    if obj.GainSource == 3
                        modifiedOC.SelectedforDesign = newData;
                        if sum([obj.FilteredOperConds.SelectedforDesign]) > 1
                            [obj.FilteredOperConds.SelectedforAnalysis] = obj.FilteredOperConds.SelectedforDesign;
                        end
                        updateTable( obj , [obj.FilteredOperConds.SelectedforDesign] , [obj.FilteredOperConds.SelectedforAnalysis]);
                        obj.LastSelectedDesignCond    = [obj.FilteredOperConds.SelectedforDesign];
                    else
                        [obj.FilteredOperConds.SelectedforDesign] = deal(false);
                        modifiedOC.SelectedforDesign = newData;
                        updateTable( obj , [obj.FilteredOperConds.SelectedforDesign] , [obj.FilteredOperConds.SelectedforAnalysis]);
                        obj.LastSelectedDesignCond    = [obj.FilteredOperConds.SelectedforDesign];
                    end
                case 7
                    % Launch color chooser and update table/background
                    color = uisetcolor(modifiedOC.Color/255);
                    if numel(color)==3
                        color = round(color*255);
                        modifiedOC.Color = color;
                        src.Data{modifiedRow,7} = sprintf('%d,%d,%d',color);
                        s = uistyle('BackgroundColor',color/255);
                        addStyle(src,s,'cell',[modifiedRow 7]);
                    else
                        % revert to previous value if user cancelled
                        src.Data{modifiedRow,7} = sprintf('%d,%d,%d',modifiedOC.Color);
                    end
            end
        end % dataUpdatedInTable
        
        function write2MFile( obj , hModel , hEvent , ind )
            
            file = Utilities.write2mfile(obj.FilteredOperConds(ind + 1 )); 
            for i = 1:length(file)
                open(file{i});
            end
        end % write2MFile 
        
        function selectAllAnalysis( obj , hModel , hEvent )
            [obj.FilteredOperConds.SelectedforAnalysis] = deal(true);
            updateTable( obj , [obj.FilteredOperConds.SelectedforDesign] , [obj.FilteredOperConds.SelectedforAnalysis]);
        end % selectAllAnalysis 
        
        function deselectAllAnalysis( obj , hModel , hEvent )
            [obj.FilteredOperConds.SelectedforAnalysis] = deal(false);
            updateTable( obj , [obj.FilteredOperConds.SelectedforDesign] , [obj.FilteredOperConds.SelectedforAnalysis]);
        end % deselectAllAnalysis
        
        function updateColumnJTable( obj , columnNum , value )
            % columnNum provided using 0-based indexing in original java code
            col = columnNum + 1;
            data = obj.JTable.Data;
            for i = 1:min(size(data,1),numel(value))
                data{i,col} = value(i);
            end
            obj.JTable.Data = data;

            % update color styling if needed
            if col == 7
                for i = 1:min(size(data,1),numel(value))
                    c = sscanf(data{i,7},'%d,%d,%d')';
                    if numel(c)==3
                        s = uistyle('BackgroundColor',c/255);
                        addStyle(obj.JTable,s,'cell',[i 7]);
                    end
                end
            end
        end % updateColumnJTable
        
    end    
    
    %% Methods - Delete
    methods
        
        function delete( obj )
            % Java Components 
            obj.JTable = [];
            obj.JScroll = [];
            obj.JTableH = [];
            obj.JHScroll = [];
            obj.LabelComp = [];
            
            % Javawrappers
            % Check if container is already being deleted
            if ishandle(obj.HContainer) && strcmp(get(obj.HContainer, 'BeingDeleted'), 'off')
                delete(obj.HContainer);
            end
            if ishandle(obj.LabelComp) && strcmp(get(obj.LabelComp, 'BeingDeleted'), 'off')
                delete(obj.LabelComp);
            end




            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.OperatingCondition);
            end
            try %#ok<*TRYNC>             
                delete(obj.FilteredOperConds);
            end
            try %#ok<*TRYNC>             
                delete(obj.LastSelectedDesignCond);
            end
            try %#ok<*TRYNC>             
                delete(obj.LastSelectedAnaylysisCond);
            end



    %          % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
            try %#ok<*TRYNC>             
                delete(obj.TableContainer);
            end

%             obj.Text1
%             obj.Text2
%             obj.Text3
%             obj.Text4
%             obj.SearchVar1_pm
%             obj.SearchValue1_pm
%             obj.SearchVar2_pm
%             obj.SearchValue2_pm       
%             obj.SearchVar3_pm
%             obj.SearchValue3_pm
%             obj.SearchVar4_pm
%             obj.SearchValue4_pm
            

    %         % Data
%             obj.ScatteredGainSourceSelected
%             obj.GainSource
%             obj.Parent
   
        
            
            
        end % delete
        
    end
    
    %% Methods - Static
    methods (Static)
        
        function [data,dataNames] = searchLinearModels(data, fc1, fc1Val, fc2, fc2Val, ic, icVal, wc, wcStr)


            if strcmp(fc1Val,'All')
                fc1LogInd = true(size(data));
            else
                fc1Val = str2double(fc1Val);
                fc1LogInd = arrayfun(@(x)all(round2(x.FlightCondition.(fc1))==round2(fc1Val)),data);
            end

            if strcmp(fc2Val,'All')
                fc2LogInd = true(size(data));
            else
                fc2Val = str2double(fc2Val);
                fc2LogInd = arrayfun(@(x)all(round2(x.FlightCondition.(fc2))==round2(fc2Val)),data);
            end

            if strcmp(icVal,'All')
                icLogInd = true(size(data));
            else
                icVal = str2double(icVal);
                try 
                    icLogInd  = arrayfun(@(x)all(round2(x.Inputs.get(ic).Value)==round2(icVal)),data);
                catch
                    icLogInd  = arrayfun(@(x)all(round2(x.Outputs.get(ic).Value)==round2(icVal)),data);
                end
            end

            if strcmp(wcStr,'All')
                wcLogInd = true(size(data));
            else
                wcVal = str2double(wcStr);
                if ~isnan(wcVal)
                    wcLogInd  = arrayfun(@(x)all(round2(x.MassProperties.get(wc))==round2(wcVal)),data);
                else
                    wcLogInd  = arrayfun(@(x)all(strcmp(x.MassProperties.get(wc),wcStr)),data);
                end
            end


            matchLogInd = fc1LogInd & fc2LogInd & icLogInd & wcLogInd;
            % set data struct to only matching indexes
            data = data(matchLogInd);

            dataNames = [];  


        end % searchLinearModels 
        
        function obj = loadobj(s)
            
            try
                if size(s.SearchVar1.strList,1) == 6                
                    s.SearchVar1.strList = {'All';'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                    s.SearchVar2.strList = {'All';'Mach';'Qbar';'Alt';'KCAS';'KTAS';'KEAS'};
                end
                obj = s;
            catch
                obj = s;
            end
        end % loadobj
    end
end




function defaultColors = constantColors()
    %% Colors 
    %defaultColors = cell(1,808);

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
   
end % constantColors

function z = round2(x)

y = 1e-10;
z = round(x/y)*y;
z = round(z,5,'significant');
end % round2