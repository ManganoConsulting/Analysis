function mousePressedInTree_CB( obj , hobj , eventData , node )
%----------------------------------------------------------------------
%----------------------------------------------------------------------



    if eventData.isMetaDown  % right-click is like a Meta-button
        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        jtree = eventData.getSource;

        jmenu = uiMenus(obj,node);
        jmenu.show(jtree, clickX, clickY);
        jmenu.repaint; 
            

    else
        
        switch node.Value
            case {2,16}
                if obj.GainsSynthesis.Checked == true
                    obj.GainsScheduled.Checked = false;
                    obj.GainsScattered.Checked = false;
                    obj.RootLocusNode.Checked = false;
                end
            case {3,21}
                if obj.GainsScattered.Checked == true
                    obj.GainsScheduled.Checked = false;
                    obj.GainsSynthesis.Checked = false;
                    obj.RootLocusNode.Checked = false;
                end
            case {4,40}
                if obj.GainsScheduled.Checked == true
                    obj.GainsScattered.Checked = false;
                    obj.GainsSynthesis.Checked = false;
                    obj.RootLocusNode.Checked = false;
                end
            case {18}
                deSelNodes = ~(obj.RootLocusNode.Children == node);
                [obj.RootLocusNode.Children(deSelNodes).Checked] = deal(false);
        end
%               get(obj,'TreeNode')
% drawnow();pause(0.5);
obj.TreeObj.getJavaObjects.jTree.repaint();
    end 

end % mousePressedCallback1103358438