function mousePressedInTree_CB( gui , ~ , eventData, ~)
%----------------------------------------------------------------------
% - Callback for "gui.mainLayout.tree" uitree context menu.
% - Only Called when mnData.taskPanelSelect = 3
%----------------------------------------------------------------------
    if ~eventData.isMetaDown  % right-click is like a Meta-button
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        if ~isempty(treePath)
            if clickX <= (jtree.getPathBounds(treePath).x+gui.JavaImage_checked.getWidth)
                node = treePath.getLastPathComponent;
                nodeValue = node.getValue;
                % as the value field is the selected/unselected flag,
                % we can also use it to only act on nodes with these values
                switch nodeValue
                    case 'selected'
                        node.setValue('unselected');
                        node.setIcon(gui.JavaImage_unchecked);
                        jtree.treeDidChange();

                    case 'unselected'
                        node.setValue('selected');
                        node.setIcon(gui.JavaImage_checked);
                        jtree.treeDidChange();

                end
            end
        end
    end

end % mousePressedCallback