function mousePressedInTree_CB( gui , ~ , eventData, ~)
%----------------------------------------------------------------------
% - Callback for  uitree context menu.
%----------------------------------------------------------------------
import javax.swing.*
import javax.swing.tree.*
import UserInterface.StabilityControl.*
    if eventData.isMetaDown  % right-click is like a Meta-button
        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        if ~isempty(treePath)
            node = treePath.getLastPathComponent;
            gui.Tree.setSelectedNode( node );

            jmenu = javax.swing.JPopupMenu;

%             if ~node.isRoot && any(strcmp(char(node.getParent.getName),{'Results'}))
%                     % Prepare the context menu (note the use of HTML labels)
%                     menuItem1 = javax.swing.JMenuItem('<html>Save Operating Condition');
% 
%                     % Set the menu items' callbacks
%                     menuItem1h = handle(menuItem1,'CallbackProperties');
%                     set(menuItem1h,'ActionPerformedCallback',{@gui.saveOperatingCondition2File,node});
%                 
%                     % Add all menu items to the context menu
%                     jmenu.add(menuItem1);
%             end

            % Display the (possibly-modified) context menu
            jmenu.show(jtree, clickX, clickY);
            jmenu.repaint;     
        end
    else
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
                
                % Multiple Selections Allowed
                if any(strcmp(node.getName,{'States','State Derivatives','Inputs','Outputs','Flight Condition','Mass Property','Signal Log'}))
                    
                    switch nodeValue
                        case 'selected'
                            node.setValue('unselected');
                            node.setIcon(gui.JavaImage_unchecked);
                            jtree.treeDidChange();

                            count = node.getChildCount;
                            for i = 0:(count-1)
                                currNode = node.getChildAt(i);
                                currNode.setIcon(gui.JavaImage_unchecked); 
                                currNode.setValue('unselected');
                            end
                            jtree.treeDidChange();

                        case {'unselected','mixed'}
                            node.setValue('selected');
                            node.setIcon(gui.JavaImage_checked);
                            jtree.treeDidChange();
                            count = node.getChildCount;
                            for i = 0:(count-1)
                                currNode = node.getChildAt(i);
                                currNode.setIcon(gui.JavaImage_checked); 
                                currNode.setValue('selected');
                            end
                            jtree.treeDidChange();
                    end  
                    
                elseif ~node.isRoot && any(strcmp(char(node.getParent.getName),{'States','State Derivatives','Inputs','Outputs','Flight Condition','Mass Property','Signal Log'}))

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

                    % update the parent node to reflect selections
                    %parentName = char(node.getParent.getName);
                    parentNode = node.getParent;
                    count = parentNode.getChildCount;
                    selState = cell(count,1);
                    for i = 0:(count-1)
                        currNode = parentNode.getChildAt(i);
                        selState{i+1} = char(currNode.getValue);
                    end

                    if all(strcmp('selected',selState))
                        parentNode.setValue('selected');
                        parentNode.setIcon(gui.JavaImage_checked);
                        jtree.treeDidChange();           
                    elseif all(strcmp('unselected',selState))
                        parentNode.setValue('unselected');
                        parentNode.setIcon(gui.JavaImage_unchecked);
                        jtree.treeDidChange();         
                    else
                        parentNode.setValue('mixed');
                        parentNode.setIcon(gui.JavaImage_partialchecked);
                        jtree.treeDidChange();     
                    end
                    
                    
                    
                elseif ~node.isRoot && any(strcmp(char(node.getParent.getName),{'Results'}))
                    
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


                logicArray = [];
                for j = 0:gui.JTree.getModel().getRoot().getChildCount - 1%gui.VarSelectNode.getChildCount - 1
                    child = gui.JTree.getModel().getRoot().getChildAt(j);%gui.VarSelectNode.getChildAt(j);
                    for i = 0:child.getChildCount - 1
                        grandchild = child.getChildAt(i);
                        if strcmp(grandchild.getValue,'selected')
                            logicArray(end+1) = true;
                        else
                            logicArray(end+1) = false;
                        end
                    end

                end    
                
                % Observable Property
%                 gui.ShowData = logicArray;
                notify(gui,'ShowDataEvent',UserInterface.UserInterfaceEventData(logicArray));
                
            
            else
                %node = treePath.getLastPathComponent;

   
            end
        end
    end % case 3

end % mousePressedCallback

