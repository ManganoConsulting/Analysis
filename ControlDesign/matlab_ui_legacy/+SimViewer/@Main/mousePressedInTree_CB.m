function mousePressedInTree_CB( obj , ~ , eventData, ~)
%----------------------------------------------------------------------
% - Callback for "gui.mainLayout.tree" uitree context menu.
% - Only Called when mnData.taskPanelSelect = 3
%----------------------------------------------------------------------
    if eventData.isMetaDown  % right-click is like a Meta-button
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        if ~isempty(treePath)
%             if clickX <= (jtree.getPathBounds(treePath).x+gui.JavaImage_checked.getWidth)
                node = treePath.getLastPathComponent;
                nodeValue = node.getValue;
                nodeUser = node.handle.UserData;
                
                
%                 this_dir = fileparts( mfilename( 'fullpath' ) );
%                 icon_dir = fullfile( this_dir,'..','..','Resources' );
%                 y = fullfile(icon_dir,imagefilename);
%                 req_Icon_Yellow = javaObjectEDT('javax.swing.ImageIcon',getIcon('workIcon_24_Yellow.png'));


                jmenu = javaObjectEDT('javax.swing.JPopupMenu');
    
                switch node.getLevel
                    case 1 % Run Level Node

                        menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Rename Simulation Data');
                        menuItem1h = handle(menuItem1,'CallbackProperties');

                        menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Simulation Data');
                        menuItem2h = handle(menuItem2,'CallbackProperties');

   
                        set(menuItem1h,'ActionPerformedCallback',{@obj.renameRun,node});
                        set(menuItem2h,'ActionPerformedCallback',{@obj.removeSimulaitonData_CB,node});

                        jmenu.add(menuItem1);
                        jmenu.add(menuItem2);
                    otherwise
                        menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Copy path to clipboard');
                        menuItem1h = handle(menuItem1,'CallbackProperties');

                        menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Go to Signal');
                        menuItem2h = handle(menuItem2,'CallbackProperties');
                        
                        menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Send data to workspace');
                        menuItem3h = handle(menuItem3,'CallbackProperties');
                        
                        menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Expand All');
                        menuItem4h = handle(menuItem4,'CallbackProperties');

                        menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Collapse All');
                        menuItem5h = handle(menuItem5,'CallbackProperties');
                        
                        menuItem6 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Logged Signal From Model');
                        menuItem6h = handle(menuItem6,'CallbackProperties');
                        
                        set(menuItem1h,'ActionPerformedCallback',{@obj.copyPath,node});
                        set(menuItem2h,'ActionPerformedCallback',{@obj.goToBlock,node});
                        set(menuItem3h,'ActionPerformedCallback',{@obj.tsData2WrkSpc,node});
                        set(menuItem4h,'ActionPerformedCallback',{@obj.expandAll,node});
                        set(menuItem5h,'ActionPerformedCallback',{@obj.collapseAll,node});
                        set(menuItem6h,'ActionPerformedCallback',{@obj.removeSignalFromModel,node});
                        
                        jmenu.add(menuItem4); 
                        jmenu.add(menuItem5); 
                        %jmenu.add(menuItem6); 
                        jmenu.add(menuItem1);
                        jmenu.add(menuItem2); 
                        jmenu.add(menuItem3); 
                end
        
                jmenu.show(jtree, clickX, clickY);
                jmenu.repaint; 
        
%                 switch nodeValue
%                     case 'selected'
%                         node.setValue('unselected');
%                         node.setIcon(gui.JavaImage_unchecked);
%                         jtree.treeDidChange();
% 
%                     case 'unselected'
%                         node.setValue('selected');
%                         node.setIcon(gui.JavaImage_checked);
%                         jtree.treeDidChange();

%                 end
%             end
        end
    end



% % %     if ~eventData.isMetaDown  % right-click is like a Meta-button
% % %         clickX = eventData.getX;
% % %         clickY = eventData.getY;
% % %         jtree = eventData.getSource;
% % %         treePath = jtree.getPathForLocation(clickX, clickY);
% % %         if ~isempty(treePath)
% % %             if clickX <= (jtree.getPathBounds(treePath).x+gui.JavaImage_checked.getWidth)
% % %                 node = treePath.getLastPathComponent;
% % %                 nodeValue = node.getValue;
% % %                 % as the value field is the selected/unselected flag,
% % %                 % we can also use it to only act on nodes with these values
% % %                 switch nodeValue
% % %                     case 'selected'
% % %                         node.setValue('unselected');
% % %                         node.setIcon(gui.JavaImage_unchecked);
% % %                         jtree.treeDidChange();
% % % 
% % %                     case 'unselected'
% % %                         node.setValue('selected');
% % %                         node.setIcon(gui.JavaImage_checked);
% % %                         jtree.treeDidChange();
% % % 
% % %                 end
% % %             end
% % %         end
% % %     end

end % mousePressedCallback