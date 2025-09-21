function nodeSelected_CB( obj , hobj , eventdata )
%----------------------------------------------------------------------
% - Callback for "gui.mainLayout.tree" uitree context menu.
% - Only Called when mnData.taskPanelSelect = 3
%----------------------------------------------------------------------

obj.CurrentSelectedObject   = {};
obj.CurrentSelectedNodeStr  = {};
obj.CurrentSelectedTreePath = {};
% For multiple selections
% treePaths = obj.JTree.getSelectionPaths();
treePaths = obj.HJTree.getSelectionPaths();
pause(0.001);
for i = 1:length(treePaths)
    obj.CurrentSelectedObject{i}   = treePaths(i).getLastPathComponent;%treePaths(i).getLastPathComponent.handle.UserData;
    obj.CurrentSelectedNodeStr{i}  = treePaths(i).getLastPathComponent.toString;
    obj.CurrentSelectedTreePath{i} = getPathString(treePaths(i));
end

pause(0.01);
% node = get(eventdata,'CurrentNode');
% node = treePaths(i).getLastPathComponent   n=mdl.getPathToRoot(node)
% obj.CurrentSelectedObject = {node.handle.UserData};
end % mousePressedCallback


function y = getPathString( treePath)

    
    allPaths = treePath.getPath;
    y = zeros(1,double(allPaths.length)-1);
    for i = 2:allPaths.length

        y(i-1) = allPaths(i).getParent.getIndex(allPaths(i));

    end

end

% function y = getPathString( treePath)
% 
%     y = '';
%     allPaths = treePath.getPath;
%     
%     for i = 1:allPaths.length
%         
%         if i == 1 
%             y = char(allPaths(i).getName);
%         else
%             y = [y , ',' , char(allPaths(i).getName)]; %#ok<AGROW>
%         end
%     end
% 
% end