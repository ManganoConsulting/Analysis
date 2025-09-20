classdef StabTree2 < handle
    % StabTree2: MATLAB uitree('checkbox') implementation for Stability Control
    %
    % This class replaces the legacy Java-based tree with MATLAB's supported
    % uitree checkbox control. It provides a subset of the original StabTree
    % API used by UserInterface.StabilityControl.Main so the rest of the UI
    % can continue to function.

    %% Public properties - Object Handles
    properties (Transient = true)
        TreeObj 
        AnalysisNode 
        TreeContextMenu 
        LastContextNode
    end

    %% Private properties - Data
    properties (Access = private)
        BrowseStartDir = pwd
        SelectedAnalysisNode matlab.ui.container.TreeNode
    end

    %% Observable properties/events (kept for compatibility)
    events
        SelectedPropChanged
        SimulinkModelChanged
        NewTrimDef
        NewLinMdlDef
        NewReqDef
        NewSimReqDef
        NewPostSimReqDef
        ShowLogMessage
        SaveProjectEvent
        ReloadConstantFile
        NewAnalysis
        AnalysisObjectAdded
        AnalysisObjectSelected
        AnalysisObjectSaved
        ConstantFileUpdated
        AnalysisObjectDeleted
        MassPropertyAdded
        BatchNodeSelected
        BatchNodesRemoved
        UseExistingTrim
        AnalysisObjectEdited
    end

    %% Dependent convenience
    properties (Dependent, Access = public)
        ParentFigure
    end

    methods
        function obj = StabTree2(parent)
            % Constructor
            obj.create(struct('Parent',parent));
        end

        function fig = get.ParentFigure(obj)
            if isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                fig = [];
                return;
            end
            fig = ancestor(obj.TreeObj,'figure');
        end
    end

    %% Creation/restore
    methods
        function create(obj, Params)
            % Ensure parent
            if ~isfield(Params,'Parent') || isempty(Params.Parent)
                parent = figure;
            else
                parent = Params.Parent;
            end

            % Create MATLAB uitree with checkboxes
            obj.TreeObj = uitree(parent,'checkbox');
            obj.TreeObj.SelectionChangedFcn = @(src,event) obj.onTreeSelectionChanged(src,event);
            obj.TreeObj.CheckedNodesChangedFcn = @(src,event) obj.onTreeCheckedChanged(src,event);
            obj.LastContextNode = [];
            obj.configureTreeContextMenu();

            % Root content
            obj.AnalysisNode = uitreenode(obj.TreeObj,'Text','Analysis Task','NodeData',1000);
        end

        function restoreTree(obj, parent)
            % Minimal restore that just re-creates a fresh tree
            obj.create(struct('Parent',parent));
        end

        function y = saveTreeState(obj)
            % Minimal save snapshot (structure of names and checked state)
            y = struct('NodeData',[], 'ExpState',[]); %#ok<NASGU>
        end
    end

    %% Public API (compatibility subset)
    methods
        function setStartDirectories(obj, path)
            obj.BrowseStartDir = path;
        end

        function nodeIndex = setBatchNodeLabel(obj, analysisTabSelIndex, uuid, newLabel)
            batchNode = obj.getBatchGroupNodeByIndex(analysisTabSelIndex);
            nodeIndex = -1;
            if isempty(batchNode)
                return;
            end
            kids = batchNode.Children;
            for i = 1:numel(kids)
                if ischar(kids(i).UserData) && strcmp(kids(i).UserData,uuid)
                    kids(i).Text = newLabel;
                    nodeIndex = i-1; % legacy returned 0-based
                    break;
                end
            end
        end

        function uuid = addBatchObj(obj, taskObj, selAnlInd, label)
            if nargin < 4 || isempty(label)
                try
                    label = taskObj(1).SetName_String;
                catch
                    label = sprintf('Run %d', randi([2,999]));
                end
            end
            batchNode = obj.getOrCreateBatchGroupNodeByIndex(selAnlInd);
            if isempty(batchNode)
                uuid = '';
                return;
            end
            node = uitreenode(batchNode,'Text',label,'NodeData',4100); % 4100=batch item
            obj.setNodeChecked(node,true);
            uuid = char(java.util.UUID.randomUUID.toString);
            node.UserData = uuid;
            % Fire selection event for batch context
            notify(obj,'BatchNodeSelected',UserInterface.UserInterfaceEventData({selAnlInd, numel(batchNode.Children)}));
        end

        function LA = getSelectedBatchLA(obj, analysisIndex)
            LA = false(1,0);
            batchNode = obj.getBatchGroupNodeByIndex(analysisIndex);
            if isempty(batchNode) || isempty(batchNode.Children)
                return;
            end
            kids = batchNode.Children;
            LA = obj.areNodesChecked(kids);
        end

        function [selObjs, selObjLogic] = getAnalysisObjs(obj, selected)
            if nargin < 2
                selected = true;
            end
            selObjs = lacm.AnalysisTask.empty;
            selObjLogic = struct('TrimTask',{},'LinearModel',{},'Requirement',{},'SimulationRequirment',{},'Selected',{});

            if isempty(obj.AnalysisNode) || isempty(obj.AnalysisNode.Children)
                return;
            end
            aKids = obj.AnalysisNode.Children;
            for i = 1:numel(aKids)
                aNode = aKids(i);
                if selected && ~obj.isNodeChecked(aNode)
                    continue;
                end
                if ~isempty(aNode.UserData) && isa(aNode.UserData,'lacm.AnalysisTask')
                    selObjs(end+1) = aNode.UserData; %#ok<AGROW>
                else
                    % fall back to empty placeholder
                    selObjs(end+1) = lacm.AnalysisTask; %#ok<AGROW>
                end

                [trimNode,lmNode,reqNode,simNode] = obj.findAnalysisGroups(aNode);
                trimSel = obj.getChildCheckedMask(trimNode);
                lmSel   = obj.getChildCheckedMask(lmNode);
                reqSel  = obj.getChildCheckedMask(reqNode);
                simSel  = obj.getChildCheckedMask(simNode);
                selObjLogic(end+1) = struct('TrimTask',trimSel,'LinearModel',lmSel,'Requirement',reqSel,'SimulationRequirment',simSel,'Selected',obj.isNodeChecked(aNode)); %#ok<AGROW>
            end
        end

        function mdlName = getSelectedSimModel(obj)
            mdlName = '';
            aNode = obj.SelectedAnalysisNode;
            if isempty(aNode) || ~isvalid(aNode)
                return;
            end
            [trimNode,~,~,~] = obj.findAnalysisGroups(aNode);
            if isempty(trimNode) || isempty(trimNode.Children)
                return;
            end
            % Try to find first child that looks like a model subnode (arbitrary policy)
            for k = 1:numel(trimNode.Children)
                c = trimNode.Children(k);
                if ~isempty(c.UserData) && ischar(c.UserData)
                    mdlName = c.UserData;
                    return;
                end
            end
        end

        function [selObjs, selLA] = getSelectedMassPropObjs(obj)
            selObjs = lacm.MassProperties.empty; selLA = [];
            aNode = obj.SelectedAnalysisNode;
            if isempty(aNode) || ~isvalid(aNode)
                return;
            end
            massNode = obj.findChildByText(aNode,'Mass Properties');
            if isempty(massNode) || isempty(massNode.Children)
                return;
            end
            kids = massNode.Children;
            mask = obj.areNodesChecked(kids);
            objs = [kids.UserData];
            % Preserve order
            selObjs = objs(mask);
            if nargout > 1
                selLA = mask;
            end
        end

        function selObjs = getConstantsFile(~)
            selObjs = [];
        end
    end

    %% Insert APIs (mirroring legacy signatures used by Main)
    methods
        function insertAnalysisObj_CB(obj, ~, ~, parentNode, ~, reqObj)
            if nargin < 4 || isempty(parentNode)
                parentNode = obj.AnalysisNode;
            end
            if isempty(reqObj)
                return;
            end
            for idx = 1:numel(reqObj)
                an = reqObj(idx);
                aNode = uitreenode(parentNode,'Text',an.Title,'NodeData',2001,'UserData',an);
                obj.setNodeChecked(aNode,true);
                obj.buildAnalysisChildren(aNode, an);
                % Notify added and mass properties available
                notify(obj,'AnalysisObjectAdded',UserInterface.UserInterfaceEventData(an));
                try
                    aIdx = find(obj.AnalysisNode.Children == aNode,1);
                    if ~isempty(aIdx) && isprop(an,'MassProperties')
                        notify(obj,'MassPropertyAdded',UserInterface.UserInterfaceEventData(struct('Index',aIdx,'MassProperty',an.MassProperties)));
                    end
                catch
                end
            end
            notify(obj,'SaveProjectEvent');
        end

        function insertTrimDefObj_CB(obj, ~, ~, parentNode, ~, newObj)
            if isempty(parentNode)
                parentNode = obj.getCurrentGroup('Trim Definition');
            end
            if isempty(parentNode) || isempty(newObj)
                return;
            end
            for i = 1:numel(newObj)
                t = newObj(i);
                node = uitreenode(parentNode,'Text',t.Label,'NodeData',3001,'UserData',t);
                obj.setNodeChecked(node,true);
                if ~isempty(t.SimulinkModelName)
                    mdlNode = uitreenode(node,'Text',t.SimulinkModelName,'NodeData',3002,'UserData',t.SimulinkModelName);
                    obj.setNodeChecked(mdlNode,true);
                end
            end
            notify(obj,'SaveProjectEvent');
        end

        function insertLinMdlObj_CB(obj, ~, ~, parentNode, ~, newObj)
            if isempty(parentNode)
                parentNode = obj.getCurrentGroup('Linear Model Definition');
            end
            if isempty(parentNode) || isempty(newObj)
                return;
            end
            for i = 1:numel(newObj)
                lm = newObj(i);
                node = uitreenode(parentNode,'Text',lm.Label,'NodeData',3101,'UserData',lm);
                obj.setNodeChecked(node,true);
            end
            notify(obj,'SaveProjectEvent');
        end

        function insertReqObj_CB(obj, ~, ~, parentNode, ~, reqObj)
            if isempty(parentNode)
                parentNode = obj.getCurrentGroup('Requirement');
            end
            if isempty(parentNode) || isempty(reqObj)
                return;
            end
            for i = 1:numel(reqObj)
                r = reqObj(i);
                node = uitreenode(parentNode,'Text',r.Title,'NodeData',3201,'UserData',r);
                obj.setNodeChecked(node,true);
                if isprop(r,'MdlName') && ~isempty(r.MdlName)
                    mdlNode = uitreenode(node,'Text',r.MdlName,'NodeData',3202,'UserData',r.MdlName);
                    obj.setNodeChecked(mdlNode,true);
                end
                if isprop(r,'FunName') && ~isempty(r.FunName)
                    mNode = uitreenode(node,'Text',r.FunName,'NodeData',3203);
                    obj.setNodeChecked(mNode,true);
                end
            end
            notify(obj,'SaveProjectEvent');
        end

        function insertConstantsFile_CB(obj, ~, ~, parentNode)
            if nargin < 4 || isempty(parentNode)
                parentNode = obj.getCurrentGroup('Simulation');
            end
            if isempty(parentNode)
                return;
            end
            [filename, pathname] = uigetfile({'*.m;*.mat'},'Select Constants File:',obj.BrowseStartDir,'MultiSelect','on');
            drawnow(); pause(0.1);
            if isequal(filename,0), return; end
            if ~iscell(filename), filename = {filename}; end
            for k = 1:numel(filename)
                full = fullfile(pathname, filename{k});
                node = uitreenode(parentNode,'Text',filename{k},'NodeData',3301,'UserData',full);
                obj.setNodeChecked(node,true);
            end
            notify(obj,'ConstantFileUpdated');
        end
    end

    %% Removal APIs (subset)
    methods
        function removeAllBatchNodes_CB(obj, ~, ~, batchNode)
            if isempty(batchNode) || ~isvalid(batchNode)
                return;
            end
            delete(batchNode.Children);
            notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(-1));
        end

        function launchMPGUI(obj, ~, ~)
            aNode = obj.SelectedAnalysisNode;
            if isempty(aNode) || ~isvalid(aNode)
                return;
            end
            massNode = obj.findChildByText(aNode,'Mass Properties');
            if isempty(massNode) || isempty(massNode.Children)
                return;
            end
            kids = massNode.Children;
            massProps = [kids.UserData];
            selLA = obj.areNodesChecked(kids);
            mpg = UserInterface.StabilityControl.MassPropGUI(massProps, selLA);
            addlistener(mpg,'MassPropertyGUIChanged',@(~,e) obj.massPropChangedByGUI(massNode,e));
            addlistener(mpg,'FigureClosed',@(varargin) 0);
        end

        function massPropChangedByGUI(obj, massNode, eventdata)
            if isempty(massNode) || isempty(massNode.Children)
                return;
            end
            kids = massNode.Children;
            sel = eventdata.Object;
            sel = logical(sel(:)');
            for i = 1:min(numel(kids), numel(sel))
                obj.setNodeChecked(kids(i), sel(i));
            end
            % Update parent state
            obj.updateAllParentStates();
            % Notify for downstream updates
            try
                aNode = massNode.Parent;
                idx = find(obj.AnalysisNode.Children == aNode,1);
                if ~isempty(idx)
                    notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(obj.getSelectedMassPropObjs()));
                    notify(obj,'MassPropertyAdded',UserInterface.UserInterfaceEventData(struct('Index',idx,'MassProperty',[kids.UserData])));
                end
            catch
            end
        end

        function removeBatchNodes_CB(obj, ~, ~, treeNode)
            if isempty(treeNode) || ~isvalid(treeNode)
                return;
            end
            uuid = '';
            if ischar(treeNode.UserData)
                uuid = treeNode.UserData;
            end
            delete(treeNode);
            if ~isempty(uuid)
                notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(uuid));
            end
        end
    end

    %% Internal helpers
    methods (Access = private)
        function onTreeSelectionChanged(obj, ~, event)
            if isempty(event) || isempty(event.SelectedNodes)
                return;
            end
            node = event.SelectedNodes(1);
            obj.LastContextNode = node;
            % Track selected analysis node for dependent inserts
            if ~isempty(node.Parent) && node.Parent == obj.AnalysisNode
                obj.SelectedAnalysisNode = node;
                % Inform Main of selected analysis index (1-based)
                idx = find(obj.AnalysisNode.Children == node,1);
                if ~isempty(idx)
                    notify(obj,'AnalysisObjectSelected',UserInterface.UserInterfaceEventData(idx));
                end
            elseif node == obj.AnalysisNode
                obj.SelectedAnalysisNode = [];
            end
        end

        function onTreeContextMenuOpening(obj, menu, ~)
            if isempty(menu) || ~isvalid(menu)
                return;
            end
            delete(menu.Children);
            node = obj.LastContextNode;
            if isempty(node) || ~isvalid(node)
                if ~isempty(obj.TreeObj.SelectedNodes)
                    node = obj.TreeObj.SelectedNodes(1);
                else
                    return;
                end
            end
            % Attach for subsequent actions
            obj.LastContextNode = node;

            % Root-level: Analysis Task
            if node == obj.AnalysisNode
                uimenu(menu,'Text','Insert Analysis Task from file...','MenuSelectedFcn',@(~,~) obj.ctxInsertAnalysisFromFile());
                uimenu(menu,'Text','Create New Analysis','MenuSelectedFcn',@(~,~) notify(obj,'NewAnalysis'));
                uimenu(menu,'Separator','on','Text','Remove all','MenuSelectedFcn',@(~,~) obj.ctxRemoveAllAnalyses());
                return;
            end

            % Analysis node
            if ~isempty(node.Parent) && node.Parent == obj.AnalysisNode
                uimenu(menu,'Text','Edit...','MenuSelectedFcn',@(~,~) obj.ctxOpenAnalysis(node));
                uimenu(menu,'Text','Save as...','MenuSelectedFcn',@(~,~) obj.ctxSaveAnalysis(node));
                uimenu(menu,'Text','Remove','Separator','on','MenuSelectedFcn',@(~,~) obj.ctxRemoveAnalysis(node));
                return;
            end

            % Group nodes
            switch node.Text
                case 'Batch runs'
                    uimenu(menu,'Text','Remove all','MenuSelectedFcn',@(~,~) obj.removeAllBatchNodes_CB([],[],node));
                case 'Mass Properties'
                    uimenu(menu,'Text','Open Mass Properties...','MenuSelectedFcn',@(~,~) obj.launchMPGUI());
                    uimenu(menu,'Text','Select All','Separator','on','MenuSelectedFcn',@(~,~) obj.setNodesChecked(node.Children,true));
                    uimenu(menu,'Text','Unselect All','MenuSelectedFcn',@(~,~) obj.setNodesChecked(node.Children,false));
                case 'Trim Definition'
                    % no-op
                case 'Requirement'
                    % no-op
                case 'Simulation'
                    % no-op
            end

            % Leaf actions by NodeData
            if isprop(node,'NodeData') && ~isempty(node.NodeData)
                switch node.NodeData
                    case 3002 % model under Trim Definition
                        uimenu(menu,'Text','Open Model','MenuSelectedFcn',@(~,~) obj.ctxOpenModel(node));
                        uimenu(menu,'Text','Compile/Release Model','MenuSelectedFcn',@(~,~) obj.ctxToggleCompileModel(node));
                    case 3202 % model under Requirement/Simulation
                        uimenu(menu,'Text','Open Model','MenuSelectedFcn',@(~,~) obj.ctxOpenModel(node));
                    case 3203 % method under Requirement
                        uimenu(menu,'Text','Open Method','MenuSelectedFcn',@(~,~) obj.ctxOpenMethod(node));
                end
            end
        end

        function onTreeCheckedChanged(obj, ~, ~)
            % Update parent states based on child check states to emulate
            % mixed-state propagation. MATLAB uitree does not display a
            % tri-state UI, but parents will be checked only when all
            % children are checked.
            obj.updateAllParentStates();
        end

        function configureTreeContextMenu(obj)
            fig = obj.ParentFigure;
            if isempty(fig) || ~isvalid(fig)
                obj.TreeContextMenu = [];
                return;
            end
            if ~isempty(obj.TreeContextMenu) && isvalid(obj.TreeContextMenu)
                delete(obj.TreeContextMenu);
            end
            obj.TreeContextMenu = uicontextmenu(fig,'ContextMenuOpeningFcn',@(m,e) obj.onTreeContextMenuOpening(m,e));
            obj.TreeObj.ContextMenu = obj.TreeContextMenu;
        end

        function [trimNode,lmNode,reqNode,simNode,batchNode] = findAnalysisGroups(obj, aNode)
            trimNode = obj.findChildByText(aNode,'Trim Definition');
            lmNode   = obj.findChildByText(aNode,'Linear Model Definition');
            reqNode  = obj.findChildByText(aNode,'Requirement');
            simNode  = obj.findChildByText(aNode,'Simulation');
            batchNode= obj.findChildByText(aNode,'Batch runs');
        end

        function node = getOrCreateBatchGroupNodeByIndex(obj, analysisIndex)
            if isempty(obj.AnalysisNode) || analysisIndex < 1 || analysisIndex > numel(obj.AnalysisNode.Children)
                node = [];
                return;
            end
            aNode = obj.AnalysisNode.Children(analysisIndex);
            [~,~,~,~,node] = obj.findAnalysisGroups(aNode);
            if isempty(node)
                node = uitreenode(aNode,'Text','Batch runs','NodeData',4000);
            end
        end

        function node = getBatchGroupNodeByIndex(obj, analysisIndex)
            node = [];
            if isempty(obj.AnalysisNode) || analysisIndex < 1 || analysisIndex > numel(obj.AnalysisNode.Children)
                return;
            end
            aNode = obj.AnalysisNode.Children(analysisIndex);
            [~,~,~,~,node] = obj.findAnalysisGroups(aNode);
        end

        function node = getCurrentGroup(obj, name)
            node = [];
            aNode = obj.SelectedAnalysisNode;
            if isempty(aNode) || ~isvalid(aNode)
                return;
            end
            node = obj.findChildByText(aNode,name);
            if isempty(node)
                node = uitreenode(aNode,'Text',name,'NodeData',2000);
            end
        end

        function node = findChildByText(~, parentNode, text)
            node = [];
            if isempty(parentNode) || isempty(parentNode.Children)
                return;
            end
            for k = 1:numel(parentNode.Children)
                if strcmp(parentNode.Children(k).Text, text)
                    node = parentNode.Children(k);
                    return;
                end
            end
        end

        function buildAnalysisChildren(obj, aNode, an)
            % Create standard groups
            trimNode  = uitreenode(aNode,'Text','Trim Definition','NodeData',2101);
            lmNode    = uitreenode(aNode,'Text','Linear Model Definition','NodeData',2102);
            reqNode   = uitreenode(aNode,'Text','Requirement','NodeData',2103);
            simNode   = uitreenode(aNode,'Text','Simulation','NodeData',2104);
            massNode  = uitreenode(aNode,'Text','Mass Properties','NodeData',2106);
            batchNode = uitreenode(aNode,'Text','Batch runs','NodeData',2105);
            %#ok<NASGU>
            % Populate from analysis object contents if present
            try
                for i = 1:numel(an.TrimTask)
                    t = an.TrimTask(i);
                    tNode = uitreenode(trimNode,'Text',t.Label,'NodeData',3001,'UserData',t);
                    obj.setNodeChecked(tNode,true);
                    if isprop(t,'SimulinkModelName') && ~isempty(t.SimulinkModelName)
                        mNode = uitreenode(tNode,'Text',t.SimulinkModelName,'NodeData',3002,'UserData',t.SimulinkModelName);
                        obj.setNodeChecked(mNode,true);
                    end
                end
            catch
            end
            try
                for i = 1:numel(an.LinearModelDef)
                    lm = an.LinearModelDef(i);
                    lmNodeChild = uitreenode(lmNode,'Text',lm.Label,'NodeData',3101,'UserData',lm);
                    obj.setNodeChecked(lmNodeChild,true);
                end
            catch
            end
            try
                for i = 1:numel(an.Requirement)
                    r = an.Requirement(i);
                    rNode = uitreenode(reqNode,'Text',r.Title,'NodeData',3201,'UserData',r);
                    obj.setNodeChecked(rNode,true);
                end
            catch
            end
            try
                for i = 1:numel(an.SimulationRequirment)
                    s = an.SimulationRequirment(i);
                    sNode = uitreenode(simNode,'Text',s.Title,'NodeData',3301,'UserData',s);
                    obj.setNodeChecked(sNode,true);
                end
            catch
            end
            try
                % Mass Properties branch
                if isprop(an,'MassProperties') && ~isempty(an.MassProperties)
                    mp = an.MassProperties;
                    for i = 1:numel(mp)
                        label = mp(i).Label;
                        if isempty(label)
                            try
                                label = mp(i).WeightCode;
                            catch
                                label = sprintf('MassProperty %d', i);
                            end
                        end
                        mNode = uitreenode(massNode,'Text',label,'NodeData',3401,'UserData',mp(i));
                        obj.setNodeChecked(mNode,true);
                    end
                end
            catch
            end
            try
                % Batch runs from SavedTaskCollectionObjBatch
                if ~isempty(an.SavedTaskCollectionObjBatch) && ~isempty(an.SavedTaskCollectionObjBatch.TrimTaskCollObj)
                    for i = 1:numel(an.SavedTaskCollectionObjBatch.TrimTaskCollObj)
                        label = an.SavedTaskCollectionObjBatch.TrimTaskCollObj(i).Label;
                        tNode = uitreenode(batchNode,'Text',label,'NodeData',4100,'UserData',an.SavedTaskCollectionObjBatch.TrimTaskCollObj(i).UUID);
                        obj.setNodeChecked(tNode,true);
                    end
                end
            catch
            end
            % Notify mass properties availability for this analysis index
            try
                idx = find(obj.AnalysisNode.Children == aNode,1);
                if ~isempty(idx) && isprop(an,'MassProperties')
                    notify(obj,'MassPropertyAdded',UserInterface.UserInterfaceEventData(struct('Index',idx,'MassProperty',an.MassProperties)));
                end
            catch
            end
        end

        function m = getChildCheckedMask(obj, node)
            if isempty(node) || isempty(node.Children)
                m = false(1,0);
                return;
            end
            m = obj.areNodesChecked(node.Children);
        end

        function setNodesChecked(obj, nodes, value)
            if isempty(nodes)
                return;
            end
            value = logical(value);
            for k = 1:numel(nodes)
                obj.setNodeChecked(nodes(k), value);
                if ~isempty(nodes(k).Children)
                    obj.setNodesChecked(nodes(k).Children, value);
                end
            end
            obj.updateAllParentStates();
        end

        function updateAllParentStates(obj)
            % Walk all analysis nodes and update parent states based on
            % children. Parent is checked only when all children are checked.
            if isempty(obj.AnalysisNode) || isempty(obj.AnalysisNode.Children)
                return;
            end
            aKids = obj.AnalysisNode.Children;
            for i = 1:numel(aKids)
                obj.updateNodeParentStateRec(aKids(i));
            end
        end

        function updateNodeParentStateRec(obj, node)
            % Post-order traversal: update children first
            for k = 1:numel(node.Children)
                obj.updateNodeParentStateRec(node.Children(k));
            end
            children = node.Children;
            if isempty(children)
                return;
            end
            states = obj.areNodesChecked(children);
            if all(states)
                obj.setNodeChecked(node,true);
            elseif any(states)
                % Mixed: parent visually unchecked (no tri-state), but we
                % could set a partial icon if desired.
                obj.setNodeChecked(node,false);
            else
                obj.setNodeChecked(node,false);
            end
        end

        function tf = areNodesChecked(obj,nodes)
            if isempty(nodes)
                tf = false(size(nodes));
                return;
            end
            checkedNodes = obj.getCheckedNodes();
            tf = false(size(nodes));
            for k = 1:numel(nodes)
                if isvalid(nodes(k))
                    tf(k) = any(nodes(k) == checkedNodes);
                else
                    tf(k) = false;
                end
            end
        end

        function tf = isNodeChecked(obj,node)
            if isempty(node) || ~isvalid(node)
                tf = false;
                return;
            end
            tf = any(node == obj.getCheckedNodes());
        end

        function checkedNodes = getCheckedNodes(obj)
            if isempty(obj.TreeObj) || ~isvalid(obj.TreeObj) || isempty(obj.TreeObj.CheckedNodes)
                checkedNodes = matlab.ui.container.TreeNode.empty;
                return;
            end
            checkedNodes = obj.TreeObj.CheckedNodes;
            checkedNodes = checkedNodes(isvalid(checkedNodes));
        end

        function setNodeChecked(obj,node,value)
            if nargin < 3 || isempty(node) || isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                return;
            end
            value = logical(value);
            checkedNodes = obj.getCheckedNodes();
            for k = 1:numel(node)
                currentNode = node(k);
                if value
                    if ~any(currentNode == checkedNodes)
                        checkedNodes = [checkedNodes(:); currentNode]; %#ok<AGROW>
                    end
                else
                    checkedNodes = checkedNodes(checkedNodes ~= currentNode);
                end
            end
            if isempty(checkedNodes)
                obj.TreeObj.CheckedNodes = matlab.ui.container.TreeNode.empty;
            else
                obj.TreeObj.CheckedNodes = checkedNodes(:);
            end
        end
    end

    %% Delete
    methods
        function delete(obj)
            try
                if ~isempty(obj.TreeContextMenu) && isvalid(obj.TreeContextMenu)
                    delete(obj.TreeContextMenu);
                end
            catch
            end
            try
                if ~isempty(obj.TreeObj) && isvalid(obj.TreeObj)
                    delete(obj.TreeObj);
                end
            catch
            end
        end
    end

    %% Context menu actions (private)
    methods (Access = private)
        function ctxInsertAnalysisFromFile(obj)
            [filename, pathname] = uigetfile({'*.mat'},'Select Analysis Task file',obj.BrowseStartDir,'MultiSelect','on');
            drawnow(); pause(0.1);
            if isequal(filename,0), return; end
            if ~iscell(filename), filename = {filename}; end
            for k = 1:numel(filename)
                s = load(fullfile(pathname,filename{k}));
                fn = fieldnames(s);
                for j = 1:numel(fn)
                    val = s.(fn{j});
                    if isa(val,'lacm.AnalysisTask')
                        obj.insertAnalysisObj_CB([],[],obj.AnalysisNode,[],val);
                    end
                end
            end
        end

        function ctxRemoveAllAnalyses(obj)
            kids = obj.AnalysisNode.Children;
            if isempty(kids)
                return;
            end
            idx = 1:numel(kids);
            delete(kids);
            notify(obj,'AnalysisObjectDeleted',UserInterface.UserInterfaceEventData(idx));
        end

        function ctxOpenAnalysis(obj, node)
            try
                reqDefObj = node.UserData;
                reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
                addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.ctxAnalysisEdited(node,event));
            catch
            end
        end

        function ctxSaveAnalysis(obj, node)
            try
                reqDefObj = node.UserData; %#ok<NASGU>
                [filename, pathname] = uiputfile({'*.mat'},'Save Analysis Object','Analysis');
                drawnow(); pause(0.1);
                if isequal(filename,0), return; end
                analysisObj = reqDefObj; %#ok<NASGU>
                save(fullfile(pathname,filename),'analysisObj');
                parentNode=node.Parent; idx = find(parentNode.Children==node,1)-1; %#ok<NASGU>
                notify(obj,'AnalysisObjectSaved',UserInterface.UserInterfaceEventData({reqDefObj,idx}));
            catch
            end
        end

        function ctxRemoveAnalysis(obj, node)
            parentNode = node.Parent;
            idx = find(parentNode.Children == node,1);
            delete(node);
            if ~isempty(idx)
                notify(obj,'AnalysisObjectDeleted',UserInterface.UserInterfaceEventData(idx));
            end
        end

        function ctxOpenModel(~, node)
            mdlName = '';
            if ~isempty(node.UserData) && ischar(node.UserData)
                mdlName = node.UserData;
            else
                mdlName = node.Text;
            end
            if ~isempty(mdlName)
                try, open_system(mdlName); catch, end
            end
        end

        function ctxToggleCompileModel(obj, node)
            mdlName = '';
            if ~isempty(node.UserData) && ischar(node.UserData)
                mdlName = node.UserData;
            else
                mdlName = node.Text;
            end
            if isempty(mdlName), return; end
            try
                if ~bdIsLoaded(mdlName)
                    load_system(mdlName);
                end
                simStat = get_param(mdlName,'SimulationStatus');
                if strcmp(simStat,'paused')
                    feval(mdlName,[],[],[],'term');
                else
                    feval(mdlName,[],[],[],'compile');
                end
                % Update any title if needed (not rendering HTML here)
                % Re-evaluate parent states
                obj.updateAllParentStates();
            catch
            end
        end

        function ctxOpenMethod(~, node)
            try
                edit(node.Text);
            catch
            end
        end

        function ctxAnalysisEdited(obj, node, eventdata)
            try
                node.UserData = eventdata.Object;
                node.Text = eventdata.Object.Title;
                % Rebuild children
                delete(node.Children);
                obj.buildAnalysisChildren(node, eventdata.Object);
                % Notify edited
                parentNode = node.Parent;
                idx = find(parentNode.Children==node,1)-1;
                notify(obj,'AnalysisObjectEdited',UserInterface.UserInterfaceEventData({eventdata.Object,idx}));
                notify(obj,'SaveProjectEvent');
            catch
            end
        end

        % Compatibility no-op: update any model compiled state visuals
        function setColor4MdlCompiledState(obj, varargin)
            %#ok<*INUSD>
            % Not visually represented in uitree; ensure tree remains valid
            obj.updateAllParentStates();
        end
    end
end
