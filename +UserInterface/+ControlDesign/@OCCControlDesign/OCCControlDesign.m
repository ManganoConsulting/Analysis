classdef OCCControlDesign < hgsetget %< lacm.OperatingConditionCollection & hgsetget
    
    %% Public Properties
    properties 
        %OperatingCondition = lacm.OperatingCondition.empty
        
        FilteredOperConds = [] % Temporary
        FilteredOperCondIdx = [] % Nathan changed
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

        NumConds = 0 % Nathan added
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
        LabelCont
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
        SelDesignOperCond % Temporary
        SelDesignOperCondIdx % Nathan added
        SelAnalysisOperCond % Temporary
        SelAnalysisOperCondIdx % Nathan added
        TableModel 
        SelectedFilterFields
        
        TableData
        TableHeader
        
        ParentFigure
        
        FilterSettings

        DesignBool
        AnalysisBool
        
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
                y = lacm.OperatingConditionCtrl.empty;
            else
                y = [obj.OperatingConditionCell{:}];
            end
        end % OperatingCondition
        
        function set.OperatingCondition(obj , x)
            if isa(x,'lacm.OperatingConditionCtrl')
                obj.OperatingConditionCell = {x};
            else
                warning('The property OperatingCondition could not be set in OCCControlDesign.m');
            end
            
        end % OperatingCondition

        % Nathan added
        function y = get.DesignBool(obj)
            y = false(length(obj.FilteredOperCondIdx),1);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = getOcIdx(obj, obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                if (oc.SelectedforDesign(ocIdx))
                    y(i) = true;
                end
            end
        end

        % Nathan added
        function y = get.AnalysisBool(obj)
            y = false(length(obj.FilteredOperCondIdx),1);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = getOcIdx(obj, obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                if (oc.SelectedforAnalysis(ocIdx))
                    y(i) = true;
                end
            end
        end
        
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
            
            
            %designOC = obj.SelectedforDesign
            % Nathan changed
            
            %if isempty(designOC)      
            %    designOC = obj.FilteredOperConds(1);
            %end

            designOcIdx = obj.SelDesignOperCondIdx;
            if isempty(designOcIdx)
                [setIdx,ocIdx] = obj.getOcIdx(1);
                oc = obj.OperatingConditionCell{setIdx};
            else
                [setIdx,ocIdx] = obj.getOcIdx(designOcIdx);
                oc = obj.OperatingConditionCell{setIdx};
            end
            
            valsStrCellArray = getUnformattedDisplayText(oc, ocIdx, fc1_Str, fc2_Str, ic_Str, wc_Str); % Nathan changed
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
            %y = cell(length(obj.FilteredOperConds),2);
            %for i = 1:length(obj.FilteredOperConds)
            %    % get the display text for the operCond
            %    y{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;
            %    y{i,2} = getDisplayText(obj.FilteredOperConds(i),fc1,fc2,ic,wc);
            %end
            % Nathan changed
            y = cell(length(obj.FilteredOperCondIdx),2);
            for i = 1:length(obj.FilteredOperCondIdx)
                % get the display text for the operCond
                [setIdx, ocIdx] = obj.getOcIdx(obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                y{i,1} = oc.SelectedforAnalysis(i);
                y{i,2} = getDisplayText(oc,ocIdx,fc1,fc2,ic,wc);
            end
        end % DisplayData
        
        function y = get.SelectedDisplayData(obj)
            fc1 = obj.SearchVar1.selStr;
            fc2 = obj.SearchVar2.selStr;
            ic  = obj.SearchVar3.selStr;
            wc  = obj.SearchVar4.selStr;
            %y = cell(length(obj.FilteredOperConds),2);
            %for i = 1:length(obj.FilteredOperConds)
            %    % get the display text for the operCond
            %    y{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;
            %    y{i,2} = getSelectedDisplayText(obj.FilteredOperConds(i),fc1,fc2,ic,wc);
            %end
            % Nathan changed
            y = cell(length(obj.FilteredOperCondIdx),2);
            for i = 1:length(obj.FilteredOperCondIdx)
                % get the display text for the operCond
                [setIdx, ocIdx] = obj.getOcIdx(obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                y{i,1} = oc.SelectedforAnalysis(i);
                y{i,2} = getSelectedDisplayText(oc,ocIdx,fc1,fc2,ic,wc);
            end
        end % SelectedDisplayData
        
        % Nathan changed
        function data = get.TableData(obj)
            selFields = {'All','All','All','All'}; 
            data = cell(length(obj.FilteredOperCondIdx),7);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = obj.getOcIdx(obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                data{i,1} = oc.SelectedforAnalysis(ocIdx);
                [ data(i,2:5) , selFields ] = getDisplayData(oc, ocIdx, obj.SelectedFilterFields{:});
                data{i,6} = oc.SelectedforDesign(ocIdx);
                data{i,7} = [int2str(oc.Color(ocIdx,1)),',',int2str(oc.Color(ocIdx,2)),',',int2str(oc.Color(ocIdx,3))];
                % data{i,1} = obj.FilteredOperConds(i).SelectedforAnalysis;%true;
                % [ data(i,2:5) , selFields ] = getDisplayData(obj.FilteredOperConds(i),obj.SelectedFilterFields{:});
                % data{i,6} = obj.FilteredOperConds(i).SelectedforDesign;%false;%
                % data{i,7} = [int2str(obj.FilteredOperConds(i).Color(1)),',',int2str(obj.FilteredOperConds(i).Color(2)),',',int2str(obj.FilteredOperConds(i).Color(3))];
            end
            obj.PrivateTableHeader = ['A',selFields,'D',' '];
        end % TableData
        
        function data = getFilteredOperCondColors(obj)
            data = cell(length(obj.FilteredOperCondIdx),3);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = obj.getOcIdx(obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                data{i} = oc.Color(ocIdx,:);
            end
        end

        function data = getAnalysisOperCondColors(obj)
            data = cell(length(obj.SelAnalysisOperCondIdx),1);
            for i = 1:length(obj.SelAnalysisOperCondIdx)
                [setIdx, ocIdx] = obj.getOcIdx(obj.SelAnalysisOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                data{i} = oc.Color(ocIdx,:);
            end
        end
        
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

        % Nathan added
        function idx = get.SelDesignOperCondIdx(obj)
            % for i = 1:obj.NumConds
            %     [setIdx,ocIdx] = getOcIdx(obj,i);
            %     oc = obj.OperatingConditionCell{setIdx};
            %     if oc.SelectedforDesign(ocIdx)
            %         idx = i;
            %         return; % only one design condition, can return after found
            %     end
            % end
            idx = obj.FilteredOperCondIdx(find(obj.DesignBool));
        end

        function idx = get.SelAnalysisOperCondIdx(obj)
            % idx = [];
            % for i = 1:obj.NumConds
            %     [setIdx,ocIdx] = getOcIdx(obj,i);
            %     oc = obj.OperatingConditionCell{setIdx};
            %     if oc.SelectedforAnalysis(ocIdx)
            %         idx = [idx i]; % try to come up with way to preallocate in the future, maybe not possible
            %     end
            % end
            idx = obj.FilteredOperCondIdx(find(obj.AnalysisBool));
        end
        
        function ocObj = get.SelAnalysisOperCond(obj)
            logArray = [obj.FilteredOperConds.SelectedforAnalysis];
            ocObj = obj.FilteredOperConds(logArray);
        end % SelAnalysisOperCond
        
        function text = get.DesignOCDisplayText(obj) % Nathan changed
            if ~isempty(obj.SelDesignOperCondIdx)
                [setIdx,ocIdx] = obj.getOcIdx(obj.SelDesignOperCondIdx);
                oc = obj.OperatingConditionCell{setIdx};
                text = getDisplayText(oc,ocIdx,obj.SearchVar1.selStr,obj.SearchVar2.selStr,obj.SearchVar3.selStr,obj.SearchVar4.selStr);
            else
                text = '<html><font color="rgb(0,0,255)">Design Model Not Selected</font></html>'; 
            end
            
        end % DesignOCDisplayText
        
        function model = get.TableModel(obj)
            selFields = cell(1,4); 
            %data = cell(length(obj.FilteredOperConds),6);
            %for i = 1:length(obj.FilteredOperConds)
            %    data{i,1} = java.lang.Boolean(false);
            %    [ data(i,2:5) , selFields ] = getDisplayData(obj.FilteredOperConds(i),obj.SelectedFilterFields{:});
            %    data{i,6} = java.lang.Boolean(false);
            %end
            % Nathan changed
            data = cell(length(obj.FilteredOperCondIdx),6);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = obj.getOcIdx(obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                data{i,1} = java.lang.Boolean(false);
                [ data(i,2:5) , selFields ] = getDisplayData(oc, ocIdx, obj.SelectedFilterFields{:});
                data{i,6} = java.lang.Boolean(false);
            end
            colNames = ['A',selFields,'D'];

            model = javaObjectEDT('javax.swing.table.DefaultTableModel',data,colNames);
            
           
        end % TableModel
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 

        % Nathan added
        function setDesignOc(obj, idx, setting)
            for i = 1:obj.NumConds
                [setIdx,ocIdx] = getOcIdx(obj,i);
                oc = obj.OperatingConditionCell{setIdx};
                if (i == idx)
                    oc.SelectedforDesign(ocIdx) = setting;
                else
                    oc.SelectedforDesign(ocIdx) = false;
                end
            end
        end

        % Nathan added
        function resetDesignOc(obj)
            for i = 1:obj.NumConds
                [setIdx,ocIdx] = getOcIdx(obj,i);
                oc = obj.OperatingConditionCell{setIdx};
                oc.SelectedforDesign(ocIdx) = false;
            end
        end

        % Nathan added
        function resetAnalysisOc(obj)
            for i = 1:obj.NumConds
                [setIdx,ocIdx] = getOcIdx(obj,i);
                oc = obj.OperatingConditionCell{setIdx};
                oc.SelectedforAnalysis(ocIdx) = false;
            end
        end

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
        
        function initializeFilteredOC(obj) % Nathan changed
            
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = getOcIdx( obj, obj.FilteredOperCondIdx(i));
                obj.OperatingConditionCell{setIdx}.SelectedforAnalysis(ocIdx) = true;
                obj.OperatingConditionCell{setIdx}.Color(ocIdx, :) = obj.Colors{i};
                % obj.FilteredOperConds(i).SelectedforAnalysis = true;
                % obj.FilteredOperConds(i).Color = obj.Colors{i};
            end
        end % initializeFilteredOC  
               
        function addOperCond(obj, newOperCond)
            
            obj.OperatingConditionCell{end + 1} = newOperCond;
            obj.NumConds = obj.NumConds + newOperCond.NumConds; % Nathan added
            updateAvaliableSelections(obj);

%             obj.OperatingCondition = [obj.OperatingCondition,newOperCond];
%             updateAvaliableSelections(obj);
        end % addOperCond     
        
        function removeOperCond( obj , x )
            if ischar(x) || length(obj.OperatingConditionCell) < 2
                obj.OperatingConditionCell = {};
                obj.NumConds = 0; % Nathan added
            else
                obj.NumConds = obj.NumConds - obj.OperatingConditionCell{x}.NumConds; % Nathan added
                obj.OperatingConditionCell(x) = [];
            end
            updateAvaliableSelections(obj);
        end % removeOperCond

        function [setIdx, ocIdx] = getOcIdx( obj, idx )
            if (idx > obj.NumConds)
                setIdx = 1;
                ocIdx = 1;
                return;
            end

            numSets = length(obj.OperatingConditionCell);
            ocIdx = idx;
            setIdx = 1;
            idxSwitch = obj.OperatingConditionCell{1}.NumConds;
            while (idx > idxSwitch)
                ocIdx = ocIdx - obj.OperatingConditionCell{setIdx}.NumConds;
                setIdx = setIdx + 1;
                idxSwitch = idxSwitch + obj.OperatingConditionCell{setIdx}.NumConds;
            end
        end

        function operCondLeg = getOperCondLeg( obj, idx )
            [setIdx, ocIdx] = getOcIdx( obj, idx );
            operCondLeg = Utilities.operCondCtrlToLeg(obj.OperatingConditionCell{setIdx}, ocIdx);
        end

        function operCondDesign = getOperCondDesign( obj )
            [setIdx, ocIdx] = getOcIdx( obj, obj.SelDesignOperCondIdx )
            operCondDesign = Utilities.operCondCtrlToLeg(OperatingConditionCell{setIdx}, ocIdx);
        end

            
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
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Operating&nbsp;Conditons</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[ 1 , panelPos(4) - 17 , panelPos(3) , 16 ], obj.Container );
            
            
            
            
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
                    if length(obj.LastSelectedAnaylysisCond) == length(obj.FilteredOperCondIdx) % Nathan changed
                        analysisCheckBool = obj.LastSelectedAnaylysisCond;
                    else  
                        analysisCheckBool = true(1,length(obj.FilteredOperCondIdx)); % Nathan changed
                    end
                    if obj.ScatteredGainSourceSelected
                        %filteredOCSelected = [obj.FilteredOperConds.HasSavedGain];
                        % Nathan changed
                        hasSavedGain = zeros(length(obj.FilteredOperCondIdx), 1);
                        for i = 1:length(obj.FilteredOperCondIdx)
                            [setIdx, ocIdx] = getOcIdx(obj, obj.FilteredOperCondIdx(i));
                            hasSavedGain(i) = obj.OperatingConditionCell{setIdx}.HasSavedGain(ocIdx);
                        end
                        filteredOCSelected = hasSavedGain;
                        if sum(filteredOCSelected) <= 1
                            designSelBool = filteredOCSelected;
                        else
                            designSelBool = false(1,length(obj.FilteredOperCondIdx)); % Nathan changed
                        end
                    else
                        if length(obj.LastSelectedDesignCond) == length(obj.FilteredOperCondIdx) % Nathan changed
                            designSelBool = obj.LastSelectedDesignCond;
                        else
                            designSelBool = false(1,length(obj.FilteredOperCondIdx)); % Nathan changed
                        end
                    end
                case 2 % Nathan changed
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperCondIdx)
                        designSelBool     = false(1,length(obj.FilteredOperCondIdx));
                    end
                    analysisCheckBool = true(1,length(obj.FilteredOperCondIdx));
                case 3 % Nathan changed
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperCondIdx)
                        designSelBool     = false(1,length(obj.FilteredOperCondIdx));
                    end
                    if ~islogical(analysisCheckBool) || length(analysisCheckBool) ~= length(obj.FilteredOperCondIdx)
                        analysisCheckBool = true(1,length(obj.FilteredOperCondIdx));
                    end  
                case 4 % Nathan changed
                    if ~islogical(designSelBool) || length(designSelBool) ~= length(obj.FilteredOperCondIdx)
                        designSelBool     = false(1,length(obj.FilteredOperCondIdx));
                    end
                    if ~islogical(analysisCheckBool) || length(analysisCheckBool) ~= length(obj.FilteredOperCondIdx)
                        analysisCheckBool = true(1,length(obj.FilteredOperCondIdx));
                    end  
                    obj.ScatteredGainSourceSelected = gainSourceScattered;
            end

            obj.resetDesignOc(); % reset design oc
            obj.resetAnalysisOc(); % reset all analysis
            
            % Nathan changed
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = getOcIdx(obj, obj.FilteredOperCondIdx(i));
                oc = obj.OperatingConditionCell{setIdx};
                % obj.FilteredOperConds(i).SelectedforDesign   = designSelBool(i); 
                % obj.FilteredOperConds(i).SelectedforAnalysis = analysisCheckBool(i);
                oc.SelectedforDesign(ocIdx) = designSelBool(i);
                oc.SelectedforAnalysis(ocIdx) = analysisCheckBool(i);
            end
            
            delete(obj.HContainer);
            
            
            model = javaObjectEDT('javax.swing.table.DefaultTableModel',obj.TableData,obj.TableHeader);
            obj.JTable = javaObjectEDT('javax.swing.JTable',model);
            obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');  % ensure that we're using EDT
            % Present the tree-table within a scrollable viewport on-screen
            obj.JScroll = javaObjectEDT('javax.swing.JScrollPane',obj.JTable);
            [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], obj.TableContainer);
                set(obj.HContainer,'Units','Normal');
                set(obj.HContainer,'Position',[ 0 , 0 , 1 , 1 ]);
                
            % Set Callbacks
            obj.JTableH.MousePressedCallback = @obj.mousePressedInTable;
            obj.JTableH.KeyReleasedCallback  = @obj.keyReleasedInTable; 
            obj.JTableH.FocusGainedCallback  = @obj.focusGainedInTable;
            obj.JTableH.KeyPressedCallback   = @obj.keyPressedInTable;
            obj.JTableH.KeyTypedCallback     = @obj.keyTypedInTable;
            JModelH = handle(obj.JTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = {@obj.dataUpdatedInTable,obj.JTable};
            set(handle(obj.JTable.getModel, 'CallbackProperties'),  'TableChangedCallback', {@obj.dataUpdatedInTable,obj.JTable});              
            
            obj.JTable.getTableHeader().setReorderingAllowed(false);
            
            obj.JTable.setVisible(false);
%             obj.JTable.setModel(javax.swing.table.DefaultTableModel(obj.TableData,obj.TableHeader)); 
            
            obj.JTable.getColumnModel.getColumn(6).setCellRenderer(ColorCellRenderer); 
            obj.JTable.getColumnModel.getColumn(6).setCellEditor(ColorCellEditor);
            


            checkBoxCR = javaObjectEDT('com.jidesoft.grid.BooleanCheckBoxCellRenderer');
            checkBoxCE = javaObjectEDT('com.jidesoft.grid.BooleanCheckBoxCellEditor');
            %pause(0.01);
            %checkBoxCR.setBackground(java.awt.Color.blue); 
            nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.
            obj.JTable.getColumnModel.getColumn(0).setCellRenderer(checkBoxCR); 
            obj.JTable.getColumnModel.getColumn(0).setCellEditor(checkBoxCE); 
            obj.JTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR); 
            obj.JTable.getColumnModel.getColumn(2).setCellEditor(nonEditCR); 
            obj.JTable.getColumnModel.getColumn(3).setCellEditor(nonEditCR); 
            obj.JTable.getColumnModel.getColumn(4).setCellEditor(nonEditCR); 
            obj.JTable.getColumnModel.getColumn(5).setCellRenderer(checkBoxCR); 
            obj.JTable.getColumnModel.getColumn(5).setCellEditor(checkBoxCE); 
       
            cr = javaObjectEDT('ColoredFieldCellRenderer'); 

            column0 = obj.JTable.getColumnModel().getColumn(0);column0.setPreferredWidth(20);column0.setMinWidth(20);column0.setMaxWidth(60);
            column1 = obj.JTable.getColumnModel().getColumn(1);column1.setPreferredWidth(60);column1.setMinWidth(60);%column1.setMaxWidth(60);
            column2 = obj.JTable.getColumnModel().getColumn(2);column2.setPreferredWidth(60);column2.setMinWidth(60);%column2.setMaxWidth(60);
            column3 = obj.JTable.getColumnModel().getColumn(3);column3.setPreferredWidth(60);column3.setMinWidth(60);%column3.setMaxWidth(60);
            column4 = obj.JTable.getColumnModel().getColumn(4);column4.setPreferredWidth(60);column4.setMinWidth(60);%column4.setMaxWidth(60);
            column5 = obj.JTable.getColumnModel().getColumn(5);column5.setPreferredWidth(20);column5.setMinWidth(20);column5.setMaxWidth(60);
            column6 = obj.JTable.getColumnModel().getColumn(6);column6.setPreferredWidth(20);column6.setMinWidth(20);column6.setMaxWidth(60);
            
%             %--------------------------------------------------------------
%             %           ScatteredGain Source Highlight
%             %--------------------------------------------------------------
%             scatterdGainExistsBool = [obj.FilteredOperConds.HasSavedGain];
%             if obj.ScatteredGainSourceSelected
%                 for i = 0:double(obj.JTable.getRowCount) - 1
%                     if scatterdGainExistsBool(i+1)
%                         cr.setCellFgColor( i,1,java.awt.Color.red );
%                     end
%                 end
%                 obj.JTable.getColumnModel.getColumn(2).setCellRenderer(cr);
%                 for i = 0:double(obj.JTable.getRowCount) - 1
%                     if scatterdGainExistsBool(i+1)
%                         cr.setCellFgColor( i,2,java.awt.Color.red );
%                     end 
%                 end
%                 obj.JTable.getColumnModel.getColumn(3).setCellRenderer(cr);
%                 for i = 0:double(obj.JTable.getRowCount) - 1
%                     if scatterdGainExistsBool(i+1)
%                         cr.setCellFgColor( i,3,java.awt.Color.red );
%                     end 
%                 end  
%                 obj.JTable.getColumnModel.getColumn(4).setCellRenderer(cr);
%                 for i = 0:double(obj.JTable.getRowCount) - 1
%                     if scatterdGainExistsBool(i+1)
%                         cr.setCellFgColor( i,4,java.awt.Color.red );
%                     end 
%                 end
%             end
            

            obj.JTable.setGridColor(java.awt.Color.lightGray);

            set(handle(obj.JTable.getModel, 'CallbackProperties'),  'TableChangedCallback', {@obj.dataUpdatedInTable,obj.JTable});
            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.JTable. repaint;
            obj.JTable.setVisible(true);
           
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

        function searchLinMdlHelper(obj) % Nathan changed
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, false);


            [obj.FilteredOperCondIdx,~] =...
                searchLinearModels(obj,...
                obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                obj.SearchVar4.selStr, obj.SearchValue4.selStr); 

            if ~strcmp(obj.SearchVar1.selStr,'All') % Nathan changed

                [FilteredOperCondIdx1,~] = searchLinearModels(obj,...
                    obj.SearchVar1.selStr, 'All',...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl1 = zeros(size(FilteredOperCondIdx1));
                for i = 1:length(FilteredOperCondIdx1)
                    [setIdx,ocIdx] = getOcIdx(obj,FilteredOperCondIdx1(i));
                    oc = obj.OperatingConditionCell{setIdx};
                    sl1(i) = oc.FlightCondition(ocIdx).(obj.SearchVar1.selStr);
                end
                obj.SearchValue1.strList = ['All';cellstr(num2str(sort(unique(sl1))))]; % Nathan changed
            end
            if ~strcmp(obj.SearchVar2.selStr,'All') % Nathan changed

                [FilteredOperCondIdx2,~] = searchLinearModels(obj,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, 'All',...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl2 = zeros(size(FilteredOperCondIdx2));
                for i = 1:length(FilteredOperCondIdx2)
                    [setIdx,ocIdx] = getOcIdx(obj,FilteredOperCondIdx2(i));
                    oc = obj.OperatingConditionCell{setIdx};
                    sl2(i) = oc.FlightCondition(ocIdx).(obj.SearchVar2.selStr);
                end
                obj.SearchValue2.strList = ['All';cellstr(num2str(sort(unique(sl2))))];
            end
            if ~strcmp(obj.SearchVar3.selStr,'All') % Nathan changed

                [FilteredOperCondIdx3,~] = searchLinearModels(obj,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, 'All',...
                    obj.SearchVar4.selStr, obj.SearchValue4.selStr); 
                sl3 = zeros(size(FilteredOperCondIdx3));
                for i = 1:length(FilteredOperCondIdx3)
                    [setIdx,ocIdx] = getOcIdx(obj,FilteredOperCondIdx3(i));
                    oc = obj.OperatingConditionCell{setIdx};
                    try % This will take input values with the same name first
                        sl3(i) = oc.Inputs.get(obj.SearchVar3.selStr).Value(ocIdx);
                    catch
                        sl3(i) = oc.Outputs.get(obj.SearchVar3.selStr).Value(ocIdx);
                    end
                end
                
                sl3 = round2(sl3);
                obj.SearchValue3.strList = ['All';cellstr(num2str(sort(unique(sl3))))];
            end
            if ~strcmp(obj.SearchVar4.selStr,'All') % Nathan changed

                [FilteredOperCondIdx4,~] = searchLinearModels(obj,...
                    obj.SearchVar1.selStr, obj.SearchValue1.selStr,...
                    obj.SearchVar2.selStr, obj.SearchValue2.selStr,...
                    obj.SearchVar3.selStr, obj.SearchValue3.selStr,...
                    obj.SearchVar4.selStr, 'All'); 
                sl4 = cell(size(FilteredOperCondIdx4));
                for i = 1:length(FilteredOperCondIdx4)
                    [setIdx,ocIdx] = getOcIdx(obj,FilteredOperCondIdx4(i));
                    oc = obj.OperatingConditionCell{setIdx};
                    sl4{i} = num2str(oc.MassProperties.get(obj.SearchVar4.selStr,ocIdx));
                end
                obj.SearchValue4.strList = ['All';sort(unique(sl4))]; 
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
            
            obj.LabelCont.Units = 'Pixels';
            obj.LabelCont.Position = [ 1 , panelPos(4) - 17 , panelPos(3) , 16 ];

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
        
        % Nathan removing gain source 3 functionality
        function dataUpdatedInTable( obj , hModel , hEvent , jtable ) % Nathan changed, this is a mess and needs to be revisited
            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            %modifiedOC = obj.FilteredOperConds(modifiedRow + 1);

            %designBool = obj.DesignBool;
            %analysisBool = obj.AnalysisBool;

            idx = obj.FilteredOperCondIdx(modifiedRow + 1);
            [setIdx,ocIdx] = getOcIdx(obj, idx);
            oc = obj.OperatingConditionCell{setIdx};
            newData = hModel.getValueAt(modifiedRow,modifiedCol);

            switch modifiedCol
                case 0
                    %if sum(designBool) > 1 && obj.GainSource == 3
                    %    updateTable( obj , designBool , analysisBool);
                    %else
                        oc.SelectedforAnalysis(ocIdx) = newData;
                        %obj.LastSelectedDesignCond    = [obj.FilteredOperConds.SelectedforDesign];
                        obj.LastSelectedAnaylysisCond = obj.AnalysisBool;
                    %end
                case 5
                    %if obj.GainSource == 3
                    %    %[obj.FilteredOperConds.SelectedforDesign] = deal(false);
                    %    oc.SelectedforDesign(ocIdx) = newData;
                    %    designBool(modifiedRow + 1) = newData;
                    %    if sum(designBool) > 1
                    %        analysisBool = designBool; % Nathan note, not sure why you would do this
                    %    end
                    %    updateTable( obj , designBool , analysisBool); % use local since analysis bool can change internally
                    %    obj.LastSelectedDesignCond    = designBool;
                    %    %obj.LastSelectedAnaylysisCond = [obj.FilteredOperConds.SelectedforAnalysis];      
                    %else
                        %designBool = false(length(obj.FilteredOperCondIdx),1);
                        %oc.SelectedforDesign(ocIdx) = newData;
                        setDesignOc(obj, idx, newData);
                        updateTable( obj , obj.DesignBool , obj.AnalysisBool);
                        obj.LastSelectedDesignCond    = obj.DesignBool;
                    %end
                case 6
                    color = double([ newData.getRed , newData.getGreen , newData.getBlue ]);
                    oc.Color(ocIdx,:) = color;
            end
%             updateTable( obj );
        end % dataUpdatedInTable
        
        function write2MFile( obj , hModel , hEvent , ind )
            
            file = Utilities.write2mfileCtrl(obj, obj.FilteredOperCondIdx(ind + 1 )); 
            for i = 1:length(file)
                open(file{i});
            end
        end % write2MFile 
        
        function selectAllAnalysis( obj , hModel , hEvent ) % Nathan changed
            %[obj.FilteredOperConds.SelectedforAnalysis] = deal(true);
            %obj.FilteredOperConds.SelectedforAnalysis = true(size(obj.FilteredOperConds.SelectedforAnalysis));
            %updateTable( obj , obj.FilteredOperConds.SelectedforDesign , obj.FilteredOperConds.SelectedforAnalysis);
            for i = 1:length(obj.FilteredOperCondIdx)
                [setIdx, ocIdx] = getOcIdx(obj, obj.FilteredOperCondIdx(i));
                obj.OperatingConditionCell{setIdx}.SelectedforAnalysis(ocIdx) = true;
            end

            updateTable(obj, obj.DesignBool, obj.AnalysisBool);
        end % selectAllAnalysis 
        
        function deselectAllAnalysis( obj , hModel , hEvent ) % Nathan changed
            %obj.FilteredOperConds.SelectedforAnalysis = false(size(obj.FilteredOperConds.SelectedforAnalysis));
            %updateTable( obj , obj.FilteredOperConds.SelectedforDesign , obj.FilteredOperConds.SelectedforAnalysis);
            obj.resetAnalysisOc();

            updateTable(obj, obj.DesignBool, obj.AnalysisBool);
        end % deselectAllAnalysis
        
        function updateColumnJTable( obj , columnNum , value )
            for i=1:double(obj.JTable.getRowCount)
                obj.JTable.setValueAt(value(i), (i - 1) ,columnNum);
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
            if ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont, 'BeingDeleted'), 'off')
                delete(obj.LabelCont);
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
    methods % Nathan changed, why was it static???
        
        function [indices,dataNames] = searchLinearModels(obj, fc1, fc1Val, fc2, fc2Val, ic, icVal, wc, wcStr)

            % Nathan changed
            if strcmp(fc1Val,'All')
                fc1LogInd = true(obj.NumConds, 1); % Nathan changed
            else
                fc1LogInd = false(obj.NumConds,1);
                fc1Val = str2double(fc1Val);
                
                for i = 1:obj.NumConds
                    [setIdx,ocIdx] = getOcIdx(obj,i);
                    oc = obj.OperatingConditionCell{setIdx};
                    fc1LogInd(i) = round2(oc.FlightCondition(ocIdx).(fc1)) == round2(fc1Val);
                end

                 %fc1LogInd = arrayfun(@(x)all(round2(x.FlightCondition.(fc1))==round2(fc1Val)),data);
            end

            if strcmp(fc2Val,'All')
                fc2LogInd = true(obj.NumConds, 1); % Nathan changed
            else
                fc2LogInd = false(obj.NumConds,1);
                fc2Val = str2double(fc2Val);
                
                for i = 1:obj.NumConds
                    [setIdx,ocIdx] = getOcIdx(obj,i);
                    oc = obj.OperatingConditionCell{setIdx};
                    fc2LogInd(i) = round2(oc.FlightCondition(ocIdx).(fc2)) == round2(fc2Val);
                end
%                 fc2Val = str2double(fc2Val);
%                 fc2LogInd = arrayfun(@(x)all(round2(x.FlightCondition.(fc2))==round2(fc2Val)),data);
            end

            if strcmp(icVal,'All')
                icLogInd = true(obj.NumConds, 1); % Nathan changed
            else
                icLogInd = false(obj.NumConds, 1);
                icVal = str2double(icVal);
                for i = 1:obj.NumConds
                    [setIdx,ocIdx] = getOcIdx(obj,i);
                    oc = obj.OperatingConditionCell{setIdx};
                    try
                        icLogInd(i) = round2(oc.Inputs.get(ic).Value(ocIdx)) == round2(icVal);
                    catch
                        icLogInd(i) = round2(oc.Outputs.get(ic).Value(ocIdx)) == round2(icVal);
                    end
                end
                %try 
                %    icLogInd  = arrayfun(@(x)all(round2(x.Inputs.get(ic).Value)==round2(icVal)),data);
                %catch
                %    icLogInd  = arrayfun(@(x)all(round2(x.Outputs.get(ic).Value)==round2(icVal)),data);
                %end
            end

            if strcmp(wcStr,'All')
                wcLogInd = true(obj.NumConds, 1); % Nathan changed
            else
                wcLogInd = false(obj.NumConds, 1);
                wcVal = str2double(wcStr);
                for i = 1:obj.NumConds
                    [setIdx,ocIdx] = getOcIdx(obj,i);
                    oc = obj.OperatingConditionCell{setIdx};
                    if ~isnan(wcVal)
                        wcLogInd(i) = round2(oc.MassProperties.get(wc,ocIdx)) == round2(wcVal);
                    else
                        wcLogInd(i) = strcmp(oc.MassProperties.get(wc,ocIdx), wcStr);
                    end
                end
                %if ~isnan(wcVal)
                %    wcLogInd  = arrayfun(@(x)all(round2(x.MassProperties.get(wc))==round2(wcVal)),data);
                %else
                %    wcLogInd  = arrayfun(@(x)all(strcmp(x.MassProperties.get(wc),wcStr)),data);
                %end
            end

            % Nathan changed
            indices = find(fc1LogInd & fc2LogInd & icLogInd & wcLogInd);

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