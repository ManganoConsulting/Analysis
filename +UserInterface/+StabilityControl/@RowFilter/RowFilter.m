classdef RowFilter < UserInterface.tree
    
    %% Public properties - Object Handles
    properties (Transient = true)      
        VarSelectNode
        StatesNode
        StateDerivsNode
        InputsNode
        OutputsNode
        FltCondNode
        MassPropNode
        SignalLogNode
            
    end
    
    %% Public properties - Observable Data Storage
    properties (SetObservable)
        ShowData
    end
    %% Public properties - Data Storage
    properties  
        
    end % Public properties
    
    %% Private properties - Data Storage
    properties  ( Access = private )
 
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties

    %% Constant properties
    properties (Constant) 

    end % Constant properties  
    
    %% Events
    events
        RowSelectedEvent
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        ShowDataEvent
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = RowFilter( parent )
            obj = obj@UserInterface.tree( parent );
            createView( obj , parent );
        end % RowFilter
    end % Constructor

    %% Methods - Property Access
    methods
        

    end % Property access methods
   
    %% Methods - View
    methods 
            
        function createView( obj , parent )
            obj.Parent = parent;

                % - get java tools
                import javax.swing.*
                import javax.swing.tree.*;

                % - create the root node
                obj.VarSelectNode = uitreenode('v0','root', '', [], 0);
                obj.VarSelectNode.setUserObject('');
                
                    % - create the outputs sub node
                    obj.FltCondNode = uitreenode('v0','',...
                        'Flight Condition', [], 0);
                    obj.FltCondNode.setIcon(obj.JavaImage_checked); 
                    obj.FltCondNode.setUserObject('JavaImage_checked');
                    obj.FltCondNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.FltCondNode);
                    
                    % - create the outputs sub node
                    obj.MassPropNode = uitreenode('v0','',...
                        'Mass Property', [], 0);
                    obj.MassPropNode.setIcon(obj.JavaImage_checked); 
                    obj.MassPropNode.setUserObject('JavaImage_checked');
                    obj.MassPropNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.MassPropNode);
                    
                    % - create the inputs sub node
                    obj.InputsNode = uitreenode('v0','',...
                        'Inputs', [], 0);
                    obj.InputsNode.setIcon(obj.JavaImage_checked); 
                    obj.InputsNode.setUserObject('JavaImage_checked');
                    obj.InputsNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.InputsNode);

                    % - create the outputs sub node
                    obj.OutputsNode = uitreenode('v0','',...
                        'Outputs', [], 0);
                    obj.OutputsNode.setIcon(obj.JavaImage_checked); 
                    obj.OutputsNode.setUserObject('JavaImage_checked');
                    obj.OutputsNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.OutputsNode);

                    % - create the states sub node
                    obj.StatesNode = uitreenode('v0','',...
                        'States', [], 0);
                    obj.StatesNode.setIcon(obj.JavaImage_checked); 
                    obj.StatesNode.setUserObject('JavaImage_checked');
                    obj.StatesNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.StatesNode);               
                    
                    
                    % - create the state deriv sub node
                    obj.StateDerivsNode = uitreenode('v0','',...
                        'State Derivatives', [], 0);
                    obj.StateDerivsNode.setIcon(obj.JavaImage_checked); 
                    obj.StateDerivsNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.StateDerivsNode);
                    
                    % - create the state deriv sub node
                    obj.SignalLogNode = uitreenode('v0','',...
                        'Signal Log', [], 0);
                    obj.SignalLogNode.setIcon(obj.JavaImage_checked); 
                    obj.SignalLogNode.setValue('selected'); 
                    obj.VarSelectNode.add(obj.SignalLogNode);       
                    
                
                % Display Tree
                obj.showTree(obj.VarSelectNode);          
                                    
        end % createView
        
    end
       
   %% Methods - Ordinary
    methods 
        function restoreTree(obj,parent)
            % Call super class method
            restoreTree@UserInterface.tree(obj,parent); 
            
%             obj.VarSelectNode        = findNode(obj.TreeModel.getRoot,'Variable Selection');
            obj.StatesNode           = findNode(obj.TreeModel.getRoot,'States');
            obj.StateDerivsNode      = findNode(obj.TreeModel.getRoot,'State Derivatives');
            obj.InputsNode           = findNode(obj.TreeModel.getRoot,'Inputs');
            obj.OutputsNode          = findNode(obj.TreeModel.getRoot,'Outputs');
            obj.FltCondNode          = findNode(obj.TreeModel.getRoot,'Flight Condition');
            obj.MassPropNode         = findNode(obj.TreeModel.getRoot,'Mass Property');
            obj.SignalLogNode        = findNode(obj.TreeModel.getRoot,'Signal Log');
            
        end % restoreTree    
    end % Ordinary Methods
    
    %% Methods - Callbacks Protected
    methods (Access = protected) 
        
%         function updateShowData(obj,type)
%             Utilities.setWaitPtr(obj.Figure);
%             type = char(type);
%             if strcmp(type,'States')
%                 nodeType = 'StatesNode';
%             elseif strcmp(type,'State Derivatives')
%                 nodeType = 'StateDerivsNode';
%             elseif strcmp(type,'Inputs')
%                 nodeType = 'InputsNode';           
%             elseif strcmp(type,'Outputs')
%                 nodeType = 'OutputsNode';
%             elseif strcmp(type,'Flight Condition')
%                 nodeType = 'FltCondNode';
%             elseif strcmp(type,'Mass Property')
%                 nodeType = 'MassPropNode';    
%             elseif strcmp(type,'Signal Log')
%                 nodeType = 'SignalLogNode'; 
%             end
%                 
%                 
%         
%   
%             
%             for i = 1:(obj.(nodeType).ChildCount )
% 
%                 if strcmpi('unselected',char(obj.(nodeType).getChildAt(i-1).getValue))
%                     col2 = char(obj.(nodeType).getChildAt(i-1).getName);
%                     B = {type,col2};
%                     A = obj.Data(:,1:2);
%                     
%                     indArray = arrayfun(@(i1)all(ismember(A(i1,:),B)),(1:size(A,1))');
%                     obj.ShowDataRow(indArray) = false;
%                 else
%                     col2 = char(obj.(nodeType).getChildAt(i-1).getName);
%                     B = {type,col2};
%                     A = obj.Data(:,1:2);
%                     
%                     indArray = arrayfun(@(i1)all(ismember(A(i1,:),B)),(1:size(A,1))');
%                     obj.ShowDataRow(indArray) = true;
%                 end
%                 
%             end
%         
%             update(obj);
%             Utilities.releaseWaitPtr(obj.Figure);
%         end %updateShowData
%         
%         function updateShowDataSingle(obj,node)
%             
%             
% 
%             if strcmpi('unselected',char(node.getValue))
%                 col2 = char(node.getName);
%                 B = {char(node.getParent.getName),col2};
%                 A = obj.Data(:,1:2);
% 
%                 indArray = arrayfun(@(i1)all(ismember(A(i1,:),B)),(1:size(A,1))');
%                 obj.ShowDataRow(indArray) = false;
%                 
%             else
%                 col2 = char(node.getName);
%                 B = {char(node.getParent.getName),col2};
%                 A = obj.Data(:,1:2);
% 
%                 indArray = arrayfun(@(i1)all(ismember(A(i1,:),B)),(1:size(A,1))');
%                 obj.ShowDataRow(indArray) = true;   
%             end
%             update(obj);
% 
%         end %updateShowDataSingle
    end
 
    %% Methods - Public Update Methods
    methods 
        
        function initialize( obj , struct )
            % Store current selections before clearing existing nodes so that
            % previously selected/unselected nodes can be restored if they
            % exist in the new data set
            nodeVariableNames =  {'StatesNode','StateDerivsNode',...
                'InputsNode','OutputsNode','FltCondNode','MassPropNode','SignalLogNode'};
            prevSelection = containers.Map('KeyType','char','ValueType','logical');
            for k = 1:length(nodeVariableNames)
                parentNode = obj.(nodeVariableNames{k});
                parentName = char(parentNode.getName);
                for j = 0:(parentNode.getChildCount-1)
                    child = parentNode.getChildAt(j);
                    key = [parentName ':' char(child.getName)];
                    prevSelection(key) = strcmpi('selected',char(child.getValue));
                end
            end

            % Remove all existing nodes from the tree
            clearNodes( obj );

            % Logic array describing which rows of the table should be shown
            logicArray = false(length(struct),1);

            % Add nodes for the new data, restoring previous selections when
            % possible and selecting any new nodes by default
            for i = 1:length(struct)
                switch struct(i).Type
                    case 'States'
                        nodeName = 'StatesNode';
                    case 'State Derivatives'
                        nodeName = 'StateDerivsNode';
                    case 'Inputs'
                        nodeName = 'InputsNode';
                    case 'Outputs'
                        nodeName = 'OutputsNode';
                    case 'Flight Condition'
                        nodeName = 'FltCondNode';
                    case 'Mass Property'
                        nodeName = 'MassPropNode';
                    case 'Signal Log'
                        nodeName = 'SignalLogNode';
                end
                node = uitreenode('v0','',...
                    struct(i).Name, [], 0);
                obj.TreeModel.insertNodeInto(...
                    node,...
                    obj.(nodeName),...
                    obj.(nodeName).getChildCount());

                key = [struct(i).Type ':' struct(i).Name];
                if isKey(prevSelection,key) && prevSelection(key)
                    node.setIcon(obj.JavaImage_checked);
                    node.setValue('selected');
                    logicArray(i) = true;
                elseif isKey(prevSelection,key) && ~prevSelection(key)
                    node.setIcon(obj.JavaImage_unchecked);
                    node.setValue('unselected');
                    logicArray(i) = false;
                else
                    % New node, select by default
                    node.setIcon(obj.JavaImage_checked);
                    node.setValue('selected');
                    logicArray(i) = true;
                end
            end

            % Update parent node icons based on their children's selection
            for k = 1:length(nodeVariableNames)
                parentNode = obj.(nodeVariableNames{k});
                count = parentNode.getChildCount;
                if count == 0
                    parentNode.setValue('unselected');
                    parentNode.setIcon(obj.JavaImage_unchecked);
                else
                    selState = cell(count,1);
                    for j = 0:(count-1)
                        selState{j+1} = char(parentNode.getChildAt(j).getValue);
                    end
                    if all(strcmp('selected',selState))
                        parentNode.setValue('selected');
                        parentNode.setIcon(obj.JavaImage_checked);
                    elseif all(strcmp('unselected',selState))
                        parentNode.setValue('unselected');
                        parentNode.setIcon(obj.JavaImage_unchecked);
                    else
                        parentNode.setValue('mixed');
                        parentNode.setIcon(obj.JavaImage_partialchecked);
                    end
                end
            end

            obj.JTree.treeDidChange();
            obj.JTree.repaint;

            % Notify listeners so that the table can be updated to reflect
            % the new selections
            notify(obj,'ShowDataEvent',UserInterface.UserInterfaceEventData(logicArray));
        end % initialize

            
    end
        
    %% Methods - Private - Private Update Methods
    methods (Access = private)
        
        function clearNodes( obj )
            nodeVariableNames =  {'StatesNode','StateDerivsNode',...
                'InputsNode','OutputsNode','FltCondNode','MassPropNode','SignalLogNode'};
            for i = 1:length(nodeVariableNames)
                % Remove Existing Nodes
                while obj.(nodeVariableNames{i}).getChildCount > 0
                    child = obj.(nodeVariableNames{i}).getChildAt(0);
                    obj.TreeModel.removeNodeFromParent(child);
                end 
            end
        end       
        
%         function initializePrivate( obj , operCond )
%             % Remove Existing Nodes
%             while obj.(objName).ChildCount > 0
%                 child = obj.(objName).getChildAt(0);
%                 obj.TreeModel.removeNodeFromParent(child);
%             end 
%             
%             % Add sub noded for each trim definition
%             for i = 1:length(names)
%                 node = uitreenode('v0','',...
%                     names{i}, [], 0);
%                 obj.TreeModel.insertNodeInto(...
%                     node,...
%                     obj.(objName),...
%                     obj.(objName).getChildCount()); 
%                 node.setIcon(obj.JavaImage_checked); 
%                 node.setValue('selected');
% 
%             end
%             obj.JTree.treeDidChange();
%             obj.JTree.repaint;                
%         end
%   
%         function updateNode( obj ,  operCond )
%             refreshNodes(obj,'States','StatesNode');
%             refreshNodes(obj,'State Derivatives','StateDerivsNode');
%             refreshNodes(obj,'Inputs','InputsNode');
%             refreshNodes(obj,'Outputs','OutputsNode');
%             refreshNodes(obj,'Flight Condition','FltCondNode');
%             refreshNodes(obj,'Mass Property','MassPropNode');
%             refreshNodes(obj,'Signal Log','SignalLogNode');
%         end % updateNode
%         
%         function refreshNodes( obj , nodeName , objName )
%             lgArray = strcmp(obj.Data(:,1),nodeName);
%             names = obj.Data(lgArray,2);
%             % Remove Existing Nodes
%             while obj.(objName).ChildCount > 0
%                 child = obj.(objName).getChildAt(0);
%                 obj.TreeModel.removeNodeFromParent(child);
%             end 
% 
%             % Add sub noded for each trim definition
%             for i = 1:length(names)
%                 node = uitreenode('v0','',...
%                     names{i}, [], 0);
%                 obj.TreeModel.insertNodeInto(...
%                     node,...
%                     obj.(objName),...
%                     obj.(objName).getChildCount()); 
%                 node.setIcon(obj.JavaImage_checked); 
%                 node.setValue('selected');
% 
%             end
%             obj.JTree.treeDidChange();
%             obj.JTree.repaint; 
%         end % refreshNodes
        

    end
    
    %% Methods - Protected -  Copy
    methods (Access = protected)            
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the xxxx object
%             cpObj.xxxx = copy(obj.xxxx);
            
        end
        
    end
    
end

function treeNode =  findNode(root, s)

    e = root.depthFirstEnumeration();
    while (e.hasMoreElements()) 
        node = e.nextElement();
        if node.getName.equalsIgnoreCase(s)
            treeNode = node;
            break;
        end
    end
end % findNode
