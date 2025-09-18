function nodeSelection_CB( obj , node )         
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
                elseif any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement'}))
                    count = node.getChildCount;
                    for i = 0:(count-1)
                        currNode = node.getChildAt(i);
                        currNode.setIcon(obj.JavaImage_unchecked);
                        currNode.setValue('unselected');
                    end

                elseif any(strcmp(char(node.getParent.getName),{'Linear Model Definition','Mass Properties','Requirement'}))
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
                if any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement'}))
                    count = node.getChildCount;
                    for i = 0:(count-1)
                        currNode = node.getChildAt(i);
                        currNode.setIcon(obj.JavaImage_checked);
                        currNode.setValue('selected');
                    end
                elseif any(strcmp(node.getParent.getName,{'Trim Definition','Output'}))
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
                elseif any(strcmp(char(node.getParent.getName),{'Linear Model Definition','Mass Properties','Requirement'}))
                    count = node.getParent.getChildCount;
                    for i = 0:(count-1)
                        currNode = node.getParent.getChildAt(i);
                        selBool{i+1} = currNode.getValue;
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
                if any(strcmp(node.getName,{'Linear Model Definition','Mass Properties','Requirement'}))
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
    end

    if node.getLevel >= 1
        fireSelectedObjectChangedEvent( obj , node );
    end
