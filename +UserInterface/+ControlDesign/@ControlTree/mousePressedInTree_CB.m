function mousePressedInTree_CB(obj, src, event)
% mousePressedInTree_CB Handle interactions with the control tree.
%   This callback replaces the Java-based mouse handler with logic that
%   uses MATLAB's native UITree events. Context menus are provided through
%   the tree-level uicontextmenu configured in ControlTree, while this
%   routine continues to manage mutually exclusive selections for various
%   gain sources.

    % Determine the node associated with the event
    if isprop(event,'Node') && ~isempty(event.Node)
        node = event.Node;
    elseif isprop(event,'SelectedNodes') && ~isempty(event.SelectedNodes)
        node = event.SelectedNodes(1);
    else
        obj.LastContextNode = [];
        return;
    end

    if isempty(node) || ~isvalid(node)
        obj.LastContextNode = [];
        return;
    end

    obj.LastContextNode = node;

    switch node.NodeData
        case {2,16}
            synthesisActive = obj.isNodeChecked(obj.GainsSynthesis) || any(obj.areNodesChecked(obj.GainsSynthesis.Children));
            if synthesisActive
                obj.setNodeChecked(obj.GainsScheduled,false);
                obj.setNodesChecked(obj.GainsScheduled.Children,false);
                obj.setNodeChecked(obj.GainsScattered,false);
                obj.setNodesChecked(obj.GainsScattered.Children,false);
                obj.setNodeChecked(obj.RootLocusNode,false);
                obj.setNodesChecked(obj.RootLocusNode.Children,false);
            end
        case {3,21}
            scatteredActive = obj.isNodeChecked(obj.GainsScattered) || any(obj.areNodesChecked(obj.GainsScattered.Children));
            if scatteredActive
                obj.setNodeChecked(obj.GainsScheduled,false);
                obj.setNodesChecked(obj.GainsScheduled.Children,false);
                obj.setNodeChecked(obj.GainsSynthesis,false);
                obj.setNodesChecked(obj.GainsSynthesis.Children,false);
                obj.setNodeChecked(obj.RootLocusNode,false);
                obj.setNodesChecked(obj.RootLocusNode.Children,false);
            end
        case {4,40}
            scheduledActive = obj.isNodeChecked(obj.GainsScheduled) || any(obj.areNodesChecked(obj.GainsScheduled.Children));
            if scheduledActive
                obj.setNodeChecked(obj.GainsScattered,false);
                obj.setNodesChecked(obj.GainsScattered.Children,false);
                obj.setNodeChecked(obj.GainsSynthesis,false);
                obj.setNodesChecked(obj.GainsSynthesis.Children,false);
                obj.setNodeChecked(obj.RootLocusNode,false);
                obj.setNodesChecked(obj.RootLocusNode.Children,false);
            end
        case {18}
            deSelNodes = ~(obj.RootLocusNode.Children == node);
            obj.setNodesChecked(obj.RootLocusNode.Children(deSelNodes),false);
    end

    % Ensure the UI updates
    drawnow();
end

