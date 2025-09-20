classdef StabTree2 < handle
    % StabTree2: MATLAB uitree('checkbox') implementation for Stability Control
    %
    % This class replaces the legacy Java-based tree with MATLAB's supported
    % uitree checkbox control. It provides a subset of the original StabTree
    % API used by UserInterface.StabilityControl.Main so the rest of the UI
    % can continue to function.

    %% Public properties - Object Handles
    properties (Transient = true)
        TreeObj matlab.ui.container.Tree
        AnalysisNode matlab.ui.container.TreeNode
        TreeContextMenu matlab.ui.container.ContextMenu
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

        function [selObjs, selLA] = getSelectedMassPropObjs(~)
            selObjs = lacm.MassProperties.empty; selLA = [];
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
                notify(obj,'AnalysisObjectAdded',UserInterface.UserInterfaceEventData(an));
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

        function onTreeCheckedChanged(obj, ~, ~)
            % noop; placeholder for future propagation logic
        end

        function configureTreeContextMenu(obj)
            fig = obj.ParentFigure;
            if isempty(fig) || ~isvalid(fig)
                obj.TreeContextMenu = [];
                return;
            end
            obj.TreeContextMenu = uicontextmenu(fig);
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
        end

        function m = getChildCheckedMask(obj, node)
            if isempty(node) || isempty(node.Children)
                m = false(1,0);
                return;
            end
            m = obj.areNodesChecked(node.Children);
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
end
