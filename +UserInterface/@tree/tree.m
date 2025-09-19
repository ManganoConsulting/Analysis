classdef tree < matlab.mixin.Copyable & UserInterface.GraphicsObject
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        %Parent
        %Figure
        TreeModel
        Tree
        JTree
    end % Public properties
  
    %% Private properties - Data Storage
    properties %(Access = private)  
        SavedNodes 
        NodeExpansionState
    end % Public properties
    
    %% Constant properties
    properties (Constant) 
        JavaImage_checked        = checkedIcon();
        JavaImage_partialchecked = partialCheckIcon();
        JavaImage_unchecked      = uncheckedIcon();
        JavaImage_folderopen     = folderOpenIcon();
        JavaImage_folder         = folderIcon();
        JavaImage_structure      = structureIcon();
        JavaImage_model          = modelIcon();
        JavaImage_localVar       = localVarIcon(); 
        JavaImage_simulink       = simulinkIcon();
        JavaImage_method         = methodIcon();
        JavaImage_plot           = plotIcon();   
        JavaImage_simref         = simRefIcon();
    end % Constant properties      
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
%         JavaImage_method
%         JavaImage_plot
    end % Dependant properties
    
    %% Events
    events
       NodeChanged
       NodeAdded
       NodeRemoved
    end
    
    %% Methods - Constructor
    methods      
        function obj = tree(parent)

            obj.Parent = parent;
            
        end % tree
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
        function restoreTree(obj,parent)
            % - get java tools
            import javax.swing.*
            import javax.swing.tree.*;
            warning('off','MATLAB:uitree:DeprecatedFunction');
            switch nargin
                case 1
                    obj.Parent = uifigure('Menubar','none',...   
                                        'Toolbar','none',...
                                        'NumberTitle','off',...
                                        'HandleVisibility', 'on',...
                                        'Visible','on');
                    %obj.Figure = obj.Parent;
                case 2
                    %obj.Figure = ancestor(parent,'figure','toplevel') ;
                    obj.Parent = parent;  
            end
             
            % - create the root node
            nodes = uitreenode('v0',obj.SavedNodes(1).Value, obj.SavedNodes(1).Title, [], 0);
            %obj.JTree.setRootVisible(false);
            
            % set treeModel
            obj.TreeModel = javaObjectEDT('javax.swing.tree.DefaultTreeModel',nodes );

            % create the tree
            [obj.Tree, container] = uitree('v0',obj.Figure );
            set(container, 'Parent',obj.Parent);
            set(container, 'Visible','on');
            set(container, 'Units','normal')
            set(container, 'position',[0, 0, 1, 1])

            % set tree to treemodel
            obj.Tree.setModel( obj.TreeModel );

            obj.JTree = handle(obj.Tree.getTree,'CallbackProperties');


            set(obj.Tree, 'NodeSelectedCallback', @obj.nodeSelected_CB );



            % Set the tree mouse-click callback
            % Note: MousePressedCallback is better than MouseClickedCallback
            %       since it fires immediately when mouse button is pressed,
            %       without waiting for its release, as MouseClickedCallback does
            set(obj.JTree, 'MousePressedCallback',...
                @obj.mousePressedInTree_CB);
            
            % Add nodes 2 tree
%             tic
            for i = 2:length(obj.SavedNodes) 

                parentNode  = findNodeParent(obj.SavedNodes(i).Parent,nodes);
                nodes(i) = obj.struct2node(obj.SavedNodes(i)); % (end+1)
                obj.TreeModel.insertNodeInto(nodes(end),...
                    parentNode,...
                    parentNode.getChildCount());
                
            end
%             toc
            % Restore the expansion state of the tree
            restoreExpansionState(obj);
            
            % Hide Root node for asthetic purposes
            obj.JTree.expandRow(0);
            obj.JTree.setRootVisible(false);
            obj.JTree.setShowsRootHandles(true);
        end % restoreTree
        
        function saveTreeState(obj)
            saveExpansionState(obj);
            saveAllNodesAsStructs(obj);
        end % saveTreeState
        
        function getNode(obj)
            
        end % getNode
        
        function setWaitPtr(obj)
            set(obj.Figure, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            set(obj.Figure, 'pointer', 'arrow'); 
        end % releaseWaitPtr
        
    end % Ordinary Methods
    
    %% Methods - Callbacks (Abstract)
    methods (Abstract,Access = protected) 

    end  
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function showTree(obj,RootNode)
            % - get java tools
            import javax.swing.*
            import javax.swing.tree.*;

            warning('off','MATLAB:uitree:DeprecatedFunction');
            % set treeModel
            obj.TreeModel = javaObjectEDT('javax.swing.tree.DefaultTreeModel',RootNode );

            % create the tree

            [obj.Tree, container] = uitree('v0',obj.Figure );

            set(container, 'Parent',obj.Parent);
            set(container, 'Visible','on');
            set(container, 'Units','normal')
            set(container, 'position',[0 0 1 1])
            % set tree to treemodel
            obj.Tree.setModel( obj.TreeModel );

            obj.JTree = handle(obj.Tree.getTree,'CallbackProperties');


            set(obj.Tree, 'NodeSelectedCallback', @obj.nodeSelected_CB );
            
            % set parents resize function
            set(obj.Parent,'ResizeFcn',@obj.reSize);


            % Set the tree mouse-click callback
            % Note: MousePressedCallback is better than MouseClickedCallback
            %       since it fires immediately when mouse button is pressed,
            %       without waiting for its release, as MouseClickedCallback does
            set(obj.JTree, 'MousePressedCallback',...
                @obj.mousePressedInTree_CB);
            
            %obj.JTree.expandPath(RootNode.getPath());
            % Hide Root node for asthetic purposes
            obj.JTree.expandRow(0);
            obj.JTree.setRootVisible(false);
            obj.JTree.setShowsRootHandles(true);
        end % showTree
        
        function saveExpansionState(obj)
            obj.JTree.setRootVisible(true);
            row = 0;
            rowPath = obj.JTree.getPathForRow(row);
            %rowPath = obj.TreeModel.getRoot.getPath;
            buf = [];
            for i = 0:obj.JTree.getRowCount()-1
                path = obj.JTree.getPathForRow(i);
                if (i==row || isDescendant(path, rowPath))
                    if(obj.JTree.isExpanded(path))
                        buf(end+1) = i-row; %#ok<AGROW>
                    end
%                  else
%                     break;
                end
            end
            obj.JTree.setRootVisible(false);
            obj.NodeExpansionState = buf;
            
        end % saveExpansionState
        
        function restoreExpansionState(obj)
            for i =1:length(obj.NodeExpansionState)
                obj.JTree.expandRow(obj.NodeExpansionState(i));          
            end
        end % restoreExpansionState
        
        function saveAllNodesAsStructs(obj) 
            obj.SavedNodes = saveNodesAsStructs(obj,obj.TreeModel.getRoot);
        end % saveAllNodesAsStructs 
        
        function nodeStruct = saveNodesAsStructs(obj,node)
            nodeStruct = node2struct(node);
            for i = 1:node.getChildCount 
                nodeStruct = [nodeStruct,saveNodesAsStructs(obj,node.getChildAt(i-1))]; %#ok<AGROW>
            end
        end % saveNodesAsStructs
        
        function node = struct2node(obj, struct)
%             if strcmp(struct.Title,'Analysis Task')
%                 disp('debug')
%             end
            node = uitreenode('v0',struct.Value, struct.Title, [], 0);
            if ~isempty(struct.Icon)
                node.setIcon(obj.(struct.Icon));
            end
            node.setUserObject(struct.Icon);
            node.UserData = struct.UserData;
        end % struct2node
        
        function reSize( obj , ~ , ~ )
            % get figure position
%             position = getpixelposition(obj.Parent);
            

        end % reSize
        
        function removeNodesFromParent( obj , node , value )
%            warning('"removeNodesFromParent" will no longer be supported.  Use "removeNode" and "removeAllChildNodes" instead.')
            % Remove Existing Nodes
            if nargin == 2
                while node.getChildCount > 0
                    child = node.getChildAt(0);
                    if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                        %clear(child.handle.UserData);%delete(child.handle.UserData);
                    end
                    obj.TreeModel.removeNodeFromParent(child);
                end 
            elseif nargin == 3
                for i = 0:node.getChildCount - 1
                    child = node.getChildAt(i);
                    if strcmp(value,char(child.getValue))
                        if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                            %clear(child.handle.UserData);%delete(child.handle.UserData);
                        end
                        obj.TreeModel.removeNodeFromParent(child);
                    end
                end   
            end
        end
        
        function removeNode( obj , node )
            if ~ischar(node.handle.UserData) && ~iscell(node.handle.UserData)
                delete(node.handle.UserData);
            end
            obj.TreeModel.removeNodeFromParent(node);
            obj.JTree.repaint;
        end % removeNode
        
        function removeAllChildNodes( obj , parentNode )
            while parentNode.getChildCount > 0
                child = parentNode.getChildAt(0);
                if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                    delete(child.handle.UserData);
                end
                obj.TreeModel.removeNodeFromParent(child);
            end 
            obj.JTree.repaint;
        end % removeAllChildNodes
        
    end
    
    %% Methods - Protected    
    methods (Static)
        
    end
    
end

function outStruct = node2struct(node)

    if isempty(node.getParent())
        %parentName = 'root';
        parent = [];
    else
        %parentName = node.getParent.getName;
        parent = node2struct(node.getParent);
    end
    
    switch char(node.getValue)
        case 'selected'
            icon = 'JavaImage_checked';
        case 'unselected'
            icon = 'JavaImage_unchecked';
        case 'mixed'
            icon = 'JavaImage_partialchecked';
        otherwise
            icon = node.getUserObject;
    end
    
    outStruct = struct('Title',char(node.getName),...
                        'Value',node.getValue,...
                        'Depth',node.getDepth,...
                        'Parent',parent,...
                        'Icon',icon,...
                        'UserData',node.handle.UserData);

end % node2struct

function y = isDescendant(path1,path2)
    count1 = path1.getPathCount();
    count2 = path2.getPathCount();
    if(count1<=count2)
        y = false;
    else
        while(count1 ~= count2)
            path1 = path1.getParentPath();
            count1 = count1 - 1;
        end
        y =  path1.equals(path2);
    end
end

function parentNode = findNodeParent(nodeStruct,nodes)    
%     nodeNames = {1,length(nodes)};
    nodeNames       = cell(1,length(nodes));
    nodeParentNames = cell(1,length(nodes));
    for i = 1:length(nodes)
        nodeNames{i} = char(nodes(i).getName);
        if nodes(i).isRoot
            nodeParentNames{i} = nodeNames{i};
        else
            nodeParentNames{i} = char(nodes(i).getParent.getName);
        end
    end


    
    logArray       = strcmp(nodeStruct.Title,nodeNames);
    if isempty(nodeStruct.Parent)
        parentStructName = nodeStruct.Title;
    else
        parentStructName = nodeStruct.Parent.Title;
    end
    logArrayParent = strcmp(parentStructName,nodeParentNames);
    % Need second check to ensure names need not be unique
    
    parentNode = nodes(logArray & logArrayParent);
    
    if ~isempty(parentNode)
        parentNode = parentNode(end);
    end
end % findNodeParent



