function mousePressedInTree_CB( obj , ~ , eventData, ~)
%----------------------------------------------------------------------
% - Callback for "obj.mainLayout.tree" uitree context menu.
% - Only Called when mnData.taskPanelSelect = 3
%----------------------------------------------------------------------
this_dir = fileparts( mfilename( 'fullpath' ) );
icon_dir = fullfile( this_dir,'..','..','Resources' );
    if eventData.isMetaDown  % right-click is like a Meta-button
        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        if ~isempty(treePath)
            node = treePath.getLastPathComponent;
            obj.Tree.setSelectedNode( node );

            jmenu = javax.swing.JPopupMenu;
            
            switch node.getLevel
                case 1
                    switch char(node.getName)
                        case {'Analysis Task'}
                            % Prepare the context menu (note the use of HTML labels)
                            menuItem1 = javax.swing.JMenuItem('<html>Insert Analysis Task');
                            menuItem1h = handle(menuItem1,'CallbackProperties');  
                            % Set the menu items' callbacks
                            set(menuItem1h,'ActionPerformedCallback',{@obj.insertAnalysisObj_CB,node,[],lacm.AnalysisTask.empty});

                            menuItem2 = javax.swing.JMenuItem('<html>Create New Analysis');
                            menuItem2h = handle(menuItem2,'CallbackProperties');
                            set(menuItem2h,'ActionPerformedCallback',@obj.createNewAnalysis_CB);

                            menuItem3 = javax.swing.JMenuItem('<html>Remove all');
                            menuItem3h = handle(menuItem3,'CallbackProperties');
                            set(menuItem3h,'ActionPerformedCallback',{@obj.removeAllSubNodes_CB,node});

                            % Add all menu items to the context menu
                            jmenu.add(menuItem1);
                            jmenu.add(menuItem2);
                            jmenu.add(menuItem3);        

                    end
                case 2
                    switch char(node.getParent.getName)  
                        case {'Analysis Task'}
                            % Prepare the context menu (note the use of HTML labels)
                            menuItem1 = javax.swing.JMenuItem('<html>Edit');
                            menuItem1h = handle(menuItem1,'CallbackProperties');
                            menuItem2 = javax.swing.JMenuItem('<html>Remove');
                            menuItem2h = handle(menuItem2,'CallbackProperties');
                            menuItem3 = javax.swing.JMenuItem('<html>Save as');
                            menuItem3h = handle(menuItem3,'CallbackProperties');

                            % Set the menu items' callbacks
                            set(menuItem1h,'ActionPerformedCallback',{@obj.openAnalysis_CB,node});
                            set(menuItem2h,'ActionPerformedCallback',{@obj.removeSubNode_CB,node});
                            set(menuItem3h,'ActionPerformedCallback',{@obj.saveAnalysisNodeAsMatFile_CB,node});

                            % Add all menu items to the context menu (with internal separator)
                            jmenu.add(menuItem1);     
                            jmenu.add(menuItem2);
                            jmenu.add(menuItem3);

                    end
                case 3 
                    switch char(node.getName)
                        case {'Batch runs'}
                            % Prepare the context menu (note the use of HTML labels)
%                             menuItem1 = javax.swing.JMenuItem('<html>Edit');
%                             menuItem1h = handle(menuItem1,'CallbackProperties');
                            menuItem2 = javax.swing.JMenuItem('<html>Remove all');
                            menuItem2h = handle(menuItem2,'CallbackProperties');

                            % Set the menu items' callbacks
%                             set(menuItem1h,'ActionPerformedCallback',{@obj.openTrimDef_CB,node});
                            set(menuItem2h,'ActionPerformedCallback',{@obj.removeAllBatchNodes_CB,node});


                            % Add all menu items to the context menu (with internal separator)
%                             jmenu.add(menuItem1);     
                            jmenu.add(menuItem2); 
                    end

                case 4
                    switch char(node.getParent.getName)
                        case {'Batch runs'}
                            menuItem1 = javax.swing.JMenuItem('<html>Remove');
                            menuItem1h = handle(menuItem1,'CallbackProperties');

                            % Set the menu items' callbacks
                            set(menuItem1h,'ActionPerformedCallback',{@obj.removeBatchNodes_CB,node});

                            % Add all menu items to the context menu (with internal separator) 
                            jmenu.add(menuItem1);   
                    end
                case 5
                                
                    selPath = jtree.getSelectionPath;
                    if selPath.getPathCount > 5 && any(strcmp(char(selPath.getPathComponent(3).getName),{'Requirement','Simulation'}))

                        if strcmp(char(node.getValue),'Model')
                            scattIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Layout_16.png'));
                            % Prepare the context menu (note the use of HTML labels)
                            menuItem1 = javax.swing.JMenuItem('<html>Open Model');
                            menuItem1.setIcon(scattIcon);
                            menuItem1h = handle(menuItem1,'CallbackProperties');
                            set(menuItem1h,'ActionPerformedCallback',{@obj.openModel_CB,node});
                            
                            menuItem2 = javax.swing.JMenuItem('<html>Compile Model');
                            menuItem2.setIcon(scattIcon);
                            menuItem2h = handle(menuItem1,'CallbackProperties');
                            set(menuItem2h,'ActionPerformedCallback',{@obj.openModel_CB,node});
                            
                            jmenu.add(menuItem1);
                            jmenu.add(menuItem2);
                        else
                            scattIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Layout_16.png'));
                            % Prepare the context menu (note the use of HTML labels)
                            menuItem1 = javax.swing.JMenuItem('<html>Open Method');
                            menuItem1.setIcon(scattIcon);
                            menuItem1h = handle(menuItem1,'CallbackProperties');
                            set(menuItem1h,'ActionPerformedCallback',{@obj.openMethod_CB,node});
                            jmenu.add(menuItem1); 
                        end  
                    elseif selPath.getPathCount > 5 && any(strcmp(char(selPath.getPathComponent(3).getName),{'Trim Definition'}))

%                             menuItem2 = javax.swing.JMenuItem('<html>Remove');
%                             menuItem2h = handle(menuItem2,'CallbackProperties');
%                             set(menuItem2h,'ActionPerformedCallback',{@obj.removeSubNode_CB,node});
%                             jmenu.add(menuItem2);
                            
                            
                            mdlname = char(get(node,'UserData'));
                            
                            isloaded = bdIsLoaded(mdlname);
                            if ~isloaded
                                load_system(mdlname);
                            end
            
                            sim_Status = get_param(char(mdlname), 'SimulationStatus');

                            menuItem1 = javax.swing.JMenuItem('<html>Open Model');
                            
                            
% %                             node.setName(['<html><font color="red" face="Courier New">&nbsp;',char(mdlname),'</html>']);
%                             node.setName(['<html><font color="red">&nbsp;',char(mdlname),'</html>']);
                            
                            if strcmp(sim_Status,'paused')
                                menuItem2 = javax.swing.JMenuItem('<html>Release Model');
                            else
                                menuItem2 = javax.swing.JMenuItem('<html>Compile Model');
                            end
                            
                            
                            
%                             menuItem3 = javax.swing.JMenuItem('<html>Remove Model');

                            menuItem1h = handle(menuItem1,'CallbackProperties');
                            menuItem2h = handle(menuItem2,'CallbackProperties');
%                             menuItem3h = handle(menuItem3,'CallbackProperties');

                            % Set the menu items' callbacks
                            set(menuItem1h,'ActionPerformedCallback',{@obj.openMdl_CB,char(get(node, 'UserData'))});
                            set(menuItem2h,'ActionPerformedCallback',{@obj.compileMdl_CB,node,sim_Status});
%                             set(menuItem3h,'ActionPerformedCallback',{@obj.removeSubNode_CB,node});

                            % Add all menu items to the context menu (with internal separator)
                            jmenu.add(menuItem1);     
                            jmenu.add(menuItem2); 
%                             jmenu.add(menuItem3);
                            
                    end
                    
            end

            % Display the (possibly-modified) context menu
            jmenu.show(jtree, clickX, clickY);
            jmenu.repaint;     
        end
    else % left-click
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;
        treePath = jtree.getPathForLocation(clickX, clickY);
        if ~isempty(treePath)
            if clickX <= (jtree.getPathBounds(treePath).x+obj.JavaImage_checked.getWidth)
                
                node = treePath.getLastPathComponent;
                nodeValue = node.getValue;
                % as the value field is the selected/unselected flag,
                % we can also use it to only act on nodes with these values
                
                if ~isempty(nodeValue)
                    
                    switch nodeValue
                        case 'selected'
                            node.setValue('unselected');
                            node.setIcon(obj.JavaImage_unchecked);
                            jtree.treeDidChange();
                            if strcmp(node.getName,'Trim Definition')
                                obj.syncTrimDefinitionGeneralNode(node,false);
                            end
                            if strcmp(node.getName,'General') && strcmp(char(node.getParent.getName),'Trim Definition')
                                obj.syncTrimDefinitionGeneralNode(node.getParent,false);
                            elseif any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement','Simulation'}))
                                count = node.getChildCount;
                                for i = 0:(count-1)
                                    currNode = node.getChildAt(i);
                                    currNode.setIcon(obj.JavaImage_unchecked);
                                    currNode.setValue('unselected');
                                end
                            elseif any(strcmp(char(node.getParent.getName),{'Linear Model Definition','Mass Properties','Requirement','Simulation'}))
                                count = node.getParent.getChildCount;
                                for i = 0:(count-1)
                                    currNode = node.getParent.getChildAt(i);
                                    selBool{i+1} = currNode.getValue; %#ok<AGROW>
                                end
                                ret = setxor(selBool,{'selected','unselected'});
                                if isempty(ret)
                                    node.getParent.setIcon(obj.JavaImage_partialchecked); 
                                    node.getParent.setValue('mixed');
                                else
                                    node.getParent.setIcon(obj.JavaImage_unchecked); 
                                    node.getParent.setValue('unselected'); 
                                end
                            
                            end
                            
 
                        case 'unselected'
                            node.setValue('selected');
                            node.setIcon(obj.JavaImage_checked);
                            jtree.treeDidChange();
                            if strcmp(node.getName,'Trim Definition')
                                obj.syncTrimDefinitionGeneralNode(node,true);
                            end
                            if any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement','Simulation'}))
                                count = node.getChildCount;
                                for i = 0:(count-1)
                                    currNode = node.getChildAt(i);
                                    currNode.setIcon(obj.JavaImage_checked);
                                    currNode.setValue('selected');
                                end
                            elseif any(strcmp(node.getParent.getName,{'Trim Definition','Output','Analysis Task'}))
                                parentNode = node.getParent;
                                count = parentNode.getChildCount;
                                for i = 0:(count-1)
                                    currNode = parentNode.getChildAt(i);
                                    currNode.setIcon(obj.JavaImage_unchecked);
                                    currNode.setValue('unselected');
                                end
                                node.setValue('selected');
                                node.setIcon(obj.JavaImage_checked);
                                jtree.treeDidChange();
                                if strcmp(char(parentNode.getName),'Trim Definition') && strcmp(node.getName,'General')
                                    obj.syncTrimDefinitionGeneralNode(parentNode,true);
                                end
                            elseif any(strcmp(char(node.getParent.getName),{'Linear Model Definition','Mass Properties','Requirement','Simulation'}))
                                count = node.getParent.getChildCount;
                                for i = 0:(count-1)
                                    currNode = node.getParent.getChildAt(i);
                                    selBool{i+1} = currNode.getValue; %#ok<AGROW>
                                end
                                ret = setxor(selBool,{'selected','unselected'});
                                if isempty(ret)
                                    node.getParent.setIcon(obj.JavaImage_partialchecked); 
                                    node.getParent.setValue('mixed');
                                else
                                    node.getParent.setIcon(obj.JavaImage_checked); 
                                    node.getParent.setValue('selected'); 
                                end

                            end
                        case 'mixed'
                            if any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement','Simulation'}))
                            node.setValue('selected');
                            node.setIcon(obj.JavaImage_checked);
                            jtree.treeDidChange();
                                count = node.getChildCount;
                                for i = 0:(count-1)
                                    currNode = node.getChildAt(i);
                                    currNode.setIcon(obj.JavaImage_checked); 
                                    currNode.setValue('selected');
                                end
                            end
                    end
                    if strcmp(node.getParent.getName,'Trim Definition')
                        notify(obj,'UseExistingTrim',GeneralEventData(strcmp(node.getValue,'selected')));
                    end
                    if strcmp(char(node.getParent.getName),'Mass Properties')
                        notify(obj,'MassPropertyAdded');
                    end
                end
                
                if node.getLevel >= 1
                    fireSelectedObjectChangedEvent( obj , node );
                end
            end 
            selPath = jtree.getSelectionPath;
            if selPath.getPathCount > 2 && strcmp('Analysis Task',char(selPath.getPathComponent(1).getName))
                analysisNode = selPath.getPathComponent(1);
                selNode = selPath.getPathComponent(2);
                index = analysisNode.getIndex(selNode) + 1;
                notify(obj,'AnalysisObjectSelected',UserInterface.UserInterfaceEventData(index));
                if selPath.getPathCount > 4 && strcmp('Batch runs',char(selPath.getPathComponent(3).getName))
                    analysisNode = selPath.getPathComponent(2);      
                    analysisNodeIndex = obj.AnalysisNode.getIndex(analysisNode) + 1;
%                     if selPath.getPathCount == 5
%                         trimTaskCollInd = 1;
%                     else
                        trimNode = selPath.getPathComponent(4);
%                         batchNode = selPath.getPathComponent(5);
%                         trimTaskCollInd = trimNode.getIndex(batchNode) + 2;
trimTaskCollInd = trimNode.getParent.getIndex(trimNode) + 1;
%                     end
                    taskCArray{1} = analysisNodeIndex;
                    taskCArray{2} = trimTaskCollInd;
                    notify(obj,'BatchNodeSelected',UserInterface.UserInterfaceEventData(taskCArray));
                end
            end
            
        end
        
        obj.JTree.repaint;
    end % case 3

end % mousePressedCallback1103358438