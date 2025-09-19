function cmenu = uiMenus(obj, node, cmenu)
%UIMENUS Create MATLAB context menus for ControlTree nodes.
%   CMENU = UIMENUS(OBJ, NODE) builds a uicontextmenu populated with the
%   actions that apply to NODE.  The callbacks invoke methods on OBJ so the
%   behaviour matches the original Java-based implementation. When an
%   existing menu handle is supplied, the menu items are rebuilt in place.

    reuseMenu = false;
    if nargin >= 3 && ~isempty(cmenu) && isvalid(cmenu)
        reuseMenu = true;
    else
        cmenu = [];
    end

    if nargin < 2 || isempty(node) || ~isvalid(node)
        if reuseMenu
            delete(cmenu.Children);
            cmenu.Visible = 'off';
        end
        return;
    end

    if ~reuseMenu
        parentFig = obj.ParentFigure;
        if isempty(parentFig) || ~isvalid(parentFig)
            parentFig = ancestor(obj.TreeObj, 'figure');
        end

        if isempty(parentFig) || ~isvalid(parentFig)
            return;
        end

        cmenu = uicontextmenu(parentFig);
    else
        delete(cmenu.Children);
    end

    value = getNodeValue(node);

    switch value
        case 1 % Operating Conditions root
            addMenuItem(cmenu, 'Insert Operating Conditions', ...
                @(src, evt) obj.addOperCond(src, evt, node));
            addMenuItem(cmenu, 'Remove All Operating Conditions', ...
                @(src, evt) obj.removeAllOperCond_CB(src, evt, node));

        case 2 % Synthesis root
            addMenuItem(cmenu, 'Insert Synthesis Object', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.Synthesis.empty));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));

        case 3 % Scattered root
            addMenuItem(cmenu, 'Load Scattered Gain Object', ...
                @(src, evt) obj.insertScatteredGainFileObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Insert New Scattered Gain Object', ...
                @(src, evt) obj.insertEmptyScatteredGainObj_CB(src, evt, node, false));

        case 4 % Scheduled root
            addMenuItem(cmenu, 'Insert Scheduled Gain Object', ...
                @(src, evt) obj.insertSchGainCollObjFile_CB(src, evt, node, [], ScheduledGain.SchGainCollection.empty));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));

        case 5 % Root Locus root
            addMenuItem(cmenu, 'Insert Root Locus Object', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.RootLocus.empty));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));

        case 6 % Stability root
            addMenuItem(cmenu, 'Insert Stability Requirement', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.Stability.empty));
            addMenuItem(cmenu, 'Save All', ...
                @(src, evt) obj.saveAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Change "Checked" Requirement Simulations (Stability)', ...
                @(src, evt) obj.changeSimulation_CB(src, evt, node));

        case 7 % Frequency Response root
            addMenuItem(cmenu, 'Insert Frequency Response Requirement', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.FrequencyResponse.empty));
            addMenuItem(cmenu, 'Save All', ...
                @(src, evt) obj.saveAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Change "Checked" Requirement Simulations (Frequency Response)', ...
                @(src, evt) obj.changeSimulation_CB(src, evt, node));

        case 8 % Simulation root
            addMenuItem(cmenu, 'Insert Simulation', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.SimulationCollection.empty));
            addMenuItem(cmenu, 'Save All', ...
                @(src, evt) obj.saveAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Change "Checked" Requirement Simulations (Simulation)', ...
                @(src, evt) obj.changeSimulation_CB(src, evt, node));

        case 9 % Handling Qualities root
            addMenuItem(cmenu, 'Insert HQ Requirement', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.HandlingQualities.empty));
            addMenuItem(cmenu, 'Save All', ...
                @(src, evt) obj.saveAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Change "Checked" Requirement Simulations (Handling Qualities)', ...
                @(src, evt) obj.changeSimulation_CB(src, evt, node));

        case 10 % Aeroservoelasticity root
            addMenuItem(cmenu, 'Insert ASE Requirement', ...
                @(src, evt) obj.insertReqObj_CB(src, evt, node, [], Requirements.Aeroservoelasticity.empty));
            addMenuItem(cmenu, 'Save All', ...
                @(src, evt) obj.saveAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove All', ...
                @(src, evt) obj.removeAll_CB(src, evt, node));
            addMenuItem(cmenu, 'Change "Checked" Requirement Simulations (Aeroservoelasticity)', ...
                @(src, evt) obj.changeSimulation_CB(src, evt, node));

        case 11 % Operating Conditions child
            addMenuItem(cmenu, 'Remove', ...
                @(src, evt) obj.removeOperCond_CB(src, evt, node));

        case 12 % Stability requirement
            addMenuItem(cmenu, 'Move - Up', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'up'));
            addMenuItem(cmenu, 'Move - Down', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'down'));
            addMenuItem(cmenu, 'Remove Stability Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Edit Stability Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Save', ...
                @(src, evt) obj.saveReqObj_CB(src, evt, node));

        case 13 % Frequency Response requirement
            addMenuItem(cmenu, 'Move - Up', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'up'));
            addMenuItem(cmenu, 'Move - Down', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'down'));
            addMenuItem(cmenu, 'Remove Frequency Response Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Edit Frequency Response Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Save', ...
                @(src, evt) obj.saveReqObj_CB(src, evt, node));

        case 14 % Handling Qualities requirement
            addMenuItem(cmenu, 'Move - Up', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'up'));
            addMenuItem(cmenu, 'Move - Down', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'down'));
            addMenuItem(cmenu, 'Remove Handling Qualities Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Edit Handling Qualities Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Save', ...
                @(src, evt) obj.saveReqObj_CB(src, evt, node));

        case 15 % Aeroservoelasticity requirement
            addMenuItem(cmenu, 'Move - Up', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'up'));
            addMenuItem(cmenu, 'Move - Down', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'down'));
            addMenuItem(cmenu, 'Remove Aeroservoelasticity Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Edit Aeroservoelasticity Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Save', ...
                @(src, evt) obj.saveReqObj_CB(src, evt, node));

        case 16 % Synthesis requirement
            addMenuItem(cmenu, 'Edit Synthesis Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove Synthesis Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));

        case 17 % Simulation requirement
            addMenuItem(cmenu, 'Move - Up', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'up'));
            addMenuItem(cmenu, 'Move - Down', ...
                @(src, evt) obj.mvReqNode_CB(src, evt, node, 'down'));
            addMenuItem(cmenu, 'Edit Simulation Requirement', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove Simulation Requirement', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));
            addMenuItem(cmenu, 'Save', ...
                @(src, evt) obj.saveReqObj_CB(src, evt, node));

        case 18 % Root Locus requirement
            addMenuItem(cmenu, 'Edit Root Locus', ...
                @(src, evt) obj.editReq_CB(src, evt, node));
            addMenuItem(cmenu, 'Remove Root Locus', ...
                @(src, evt) obj.removeReqObj_CB(src, evt, node));

        case 19 % Model link
            addMenuItem(cmenu, 'Open Model', ...
                @(src, evt) obj.openModel_CB(src, evt, node));

        case {20, 30} % Method or plot link
            addMenuItem(cmenu, 'Open Method', ...
                @(src, evt) obj.openMethod_CB(src, evt, node));

        case 21 % Scattered gain file node
            addMenuItem(cmenu, 'Remove Scattered Gain File', ...
                @(src, evt) obj.removeScatteredGainFile(src, evt, node));
            addMenuItem(cmenu, 'Save Scattered Gain File (.mat)', ...
                @(src, evt) obj.saveScattGainFromNode(src, evt, node));
            addMenuItem(cmenu, 'Export Scattered Gain File (.csv)', ...
                @(src, evt) obj.exportScattGainFromNode(src, evt, node));
            addMenuItem(cmenu, 'Clear Scattered Gain File', ...
                @(src, evt) obj.clearScattGainFromNode(src, evt, node));

        case 22 % Associated scattered gain node under synthesis/root locus
            addMenuItem(cmenu, 'Insert New Scattered Gain Object', ...
                @(src, evt) obj.insertEmptyScatteredGainObj_CB(src, evt, node.Parent, true));
            submenu = uimenu(cmenu, 'Label', 'Select Scattered Gain Object for Save');
            scattFileNames = {obj.GainsScattered.Children.Name};
            for k = 1:numel(scattFileNames)
                addMenuItem(submenu, scattFileNames{k}, ...
                    @(src, evt) obj.selectScatteredGainFile2Write(src, evt, node.Parent, scattFileNames{k}));
            end

        case {23, 40} % Scheduled gain object
            addMenuItem(cmenu, 'Save Gain Schedule', ...
                @(src, evt) obj.saveGainSchFromNode(src, evt, node));

        case {41, 42, 43, 44, 45} % Scheduled gain details
            addMenuItem(cmenu, 'Create Simulink Block', ...
                @(src, evt) obj.createSimulinkBlock(src, evt, node.Parent, node.Name));

        case 100 % Folder node
            addRequirementInsertMenu(obj, cmenu, node);
            if ismethod(obj, 'removeFolder_CB')
                addMenuItem(cmenu, 'Remove Folder', ...
                    @(src, evt) obj.removeFolder_CB(src, evt, node));
            end
    end

    if isempty(cmenu.Children) && ischar(value)
        switch value
            case {'Method', 'RequiermentPlot'}
                addMenuItem(cmenu, 'Open Method', ...
                    @(src, evt) obj.openMethod_CB(src, evt, node));
            case 'Model'
                addMenuItem(cmenu, 'Open Model', ...
                    @(src, evt) obj.openModel_CB(src, evt, node));
            case 'Scheduled Child Child'
                addMenuItem(cmenu, 'Create Simulink Block', ...
                    @(src, evt) obj.createSimulinkBlock(src, evt, node.Parent, node.Name));
        end
    end

    if isempty(cmenu.Children)
        if reuseMenu
            cmenu.Visible = 'off';
        else
            delete(cmenu);
            cmenu = [];
        end
    else
        cmenu.Visible = 'on';
        if ~reuseMenu && isprop(node, 'ContextMenu')
            node.ContextMenu = cmenu;
        end
    end

end

function menuItem = addMenuItem(parent, label, callback)
%ADD MENUITEM Create a uimenu item and assign a callback that supports
% standard figures and UIFIGURE-based apps.

    menuItem = uimenu(parent, 'Label', label);
    if isprop(menuItem, 'MenuSelectedFcn')
        menuItem.MenuSelectedFcn = callback;
    end
    if isprop(menuItem, 'Callback')
        menuItem.Callback = callback;
    end
end

function value = getNodeValue(node)
%GETNODEVALUE Retrieve the identifier stored in a tree node.

    value = [];
    if isempty(node) || ~isvalid(node)
        return;
    end
    if isprop(node, 'NodeData')
        value = node.NodeData;
    end
    if isempty(value) && isprop(node, 'Value')
        value = node.Value;
    end
end

function addRequirementInsertMenu(obj, parentMenu, node)
%ADDREQUIREMENTINSERTMENU Add a menu item that inserts a requirement into a
% folder node.

    rootValue = findRequirementRootValue(node);
    reqObj = getRequirementPrototype(rootValue);
    if isempty(reqObj)
        return;
    end
    addMenuItem(parentMenu, 'Insert Requirements', ...
        @(src, evt) obj.insertReqObj_CB(src, evt, node, [], reqObj));
end

function rootValue = findRequirementRootValue(node)
%FINDREQUIREMENTROOTVALUE Locate the requirement root type for a folder.

    rootValue = [];
    current = node;
    while ~isempty(current) && isvalid(current)
        value = getNodeValue(current);
        if isnumeric(value) && any(value == [2, 5, 6, 7, 8, 9, 10, 16, 17, 18])
            rootValue = value;
            return;
        end
        current = current.Parent;
    end
end

function reqObj = getRequirementPrototype(rootValue)
%GETREQUIREMENTPROTOTYPE Return an empty requirement object for a given
% tree branch.

    switch rootValue
        case {2, 16}
            reqObj = Requirements.Synthesis.empty;
        case {5, 18}
            reqObj = Requirements.RootLocus.empty;
        case 6
            reqObj = Requirements.Stability.empty;
        case 7
            reqObj = Requirements.FrequencyResponse.empty;
        case {8, 17}
            reqObj = Requirements.SimulationCollection.empty;
        case 9
            reqObj = Requirements.HandlingQualities.empty;
        case 10
            reqObj = Requirements.Aeroservoelasticity.empty;
        otherwise
            reqObj = [];
    end
end
