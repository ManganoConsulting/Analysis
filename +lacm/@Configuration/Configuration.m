classdef Configuration < matlab.mixin.Copyable%< matlab.mixin.CustomDisplay
    
    %% Public properties - Data Storage
    properties  
        Label
        ModelNamePath
        ModelConstantsFile
        MassPropertiesDatabase lacm.MassProperties   
        LinearModelSettings lacm.LinearModel 
        TrimSettings lacm.TrimSettings 
        
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        TrimSettingSelectedIndex logical
        LinearModelSettingSelectedIndex logical
        MassPropertiesSelectedIndex logical
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        SelectedLinearModelSettings
        SelectedTrimSettings
        SelectedMassProperties
        ModelName
    end % Dependant properties
    
    %% View Properties
    % Object Handle properties
    properties (Hidden = true, Transient = true)
        Figure
        Parent
        
        RootNode
        ConfigurationNode
        TrimDefinitionNode
        LinearMdlDefininitionNode
        MassPropertiesNode
        SimDefinitionNode
        
    end % Public properties
    
    % Constant properties
    properties (Hidden = true, Constant) 
        JavaImage_checked        = UserInterface.Icons.checkedIcon();
        JavaImage_partialchecked = UserInterface.Icons.partialCheckIcon();
        JavaImage_unchecked      = UserInterface.Icons.uncheckedIcon();
        JavaImage_folderopen     = UserInterface.Icons.folderOpenIcon();
        JavaImage_folder         = UserInterface.Icons.folderIcon();
        JavaImage_structure      = UserInterface.Icons.structureIcon();
        JavaImage_model          = UserInterface.Icons.modelIcon();
        JavaImage_localVar       = UserInterface.Icons.localVarIcon();  
        JavaImage_config         = UserInterface.Icons.configIcon();  
    end % Constant properties  
    
    %% Methods - Constructor
    methods   
        
        function obj = Configuration(sys,constantfile,trimFile,linFile,masspropFile,label)
            if nargin == 0
            else
                if nargin > 5  
                    obj.ModelNamePath = sys;
                    obj.ModelConstantsFile = constantfile;
                    obj.MassPropertiesDatabase = lacm.MassProperties(masspropFile);
                    obj.TrimSettings   = lacm.TrimSettings(trimFile);
                    obj.LinearModelSettings    = lacm.LinearModel(linFile);
                end
                if nargin == 6
                    obj.Label = label;
                end
            end
            
        end % Configuration
        
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.ModelName(obj)
            [~,file] = fileparts(obj.ModelNamePath);
            y = file;
        end % ModelName
        function y = get.SelectedLinearModelSettings(obj)
            if ~isempty(obj.LinearModelSettingSelectedIndex)
                y = obj.LinearModelSettings(obj.LinearModelSettingSelectedIndex);
            else
                y = obj.LinearModelSettings;
            end
        end % SelectedLinearModelSettings
    
        function y = get.SelectedTrimSettings(obj)
            if ~isempty(obj.TrimSettingSelectedIndex)
                y = obj.TrimSettings(obj.TrimSettingSelectedIndex);
            else
                y = obj.TrimSettings;
            end
        end % SelectedTrimSettings
        
        function y = get.SelectedMassProperties(obj)
            if ~isempty(obj.MassPropertiesSelectedIndex)
                y = obj.MassPropertiesDatabase(obj.MassPropertiesSelectedIndex);
            else
                y = obj.MassPropertiesDatabase;
            end
        end % SelectedMassProperties
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 

    end % Ordinary Methods
    
    %% Methods - View
    methods 
%         function treeView(gui,parent,tree,figure)
%         % - UItree setup section -------------------------------------------------
%         %  Note: the use of uitree and the other java functionality.                            
%         % -------------------------------------------------------------------------
% 
%             % - get java tools
%             import javax.swing.*
%             import javax.swing.tree.*;
% 
%             if nargin > 3
%                 % - create the root node
%                 gui.RootNode = uitreenode('v0','root', 'Configuration', [], 0);
%                 gui.RootNode.setIcon(gui.JavaImage_config); 
%             else
%                 gui.RootNode = parent;
%             end      
% 
%             % - create the trim definition sub node
%             gui.TrimDefinitionNode = uitreenode('v0','',...
%                 'Trim Definition', [], 0);
%             gui.TrimDefinitionNode.setIcon(gui.JavaImage_unchecked); 
%             gui.TrimDefinitionNode.setValue('unselected');
%             tree.insertNodeInto(gui.TrimDefinitionNode,...
%                                 gui.RootNode,...
%                                 gui.RootNode.getChildCount());
%                 % Add sub noded for each trim definition
%                 for i = 1:length(gui.TrimSettings)
%                     node = treeNode(gui.TrimSettings(i),tree);
%                     tree.insertNodeInto(...
%                         node,...
%                         gui.TrimDefinitionNode,...
%                         gui.TrimDefinitionNode.getChildCount());
%                 end
%                 gui.TrimSettingSelectedIndex = false(1,length(gui.TrimSettings));
% 
%             % - create the linear model definition sub node
%             gui.LinearMdlDefininitionNode = uitreenode('v0','',...
%                 'Linear Model Definition', [], 0);
%             gui.LinearMdlDefininitionNode.setIcon(gui.JavaImage_unchecked); 
%             gui.LinearMdlDefininitionNode.setValue('unselected');
%             tree.insertNodeInto(gui.LinearMdlDefininitionNode,...
%                                 gui.RootNode,...
%                                 gui.RootNode.getChildCount());
%                 % Add sub noded for each trim definition
%                 for i = 1:length(gui.LinearModelSettings)
%                     node = treeNode(gui.LinearModelSettings(i),tree);
%                     tree.insertNodeInto(...
%                         node,...
%                         gui.LinearMdlDefininitionNode,...
%                         gui.LinearMdlDefininitionNode.getChildCount());
%                 end
%                 gui.LinearModelSettingSelectedIndex = false(1,length(gui.LinearModelSettings));
% 
%             % - create the MassProperties sub node
%             gui.MassPropertiesNode = uitreenode('v0','',...
%                 'Mass Properties', [], 0);
%             gui.MassPropertiesNode.setIcon(gui.JavaImage_unchecked); 
%             gui.MassPropertiesNode.setValue('unselected');
%             tree.insertNodeInto(gui.MassPropertiesNode,...
%                                 gui.RootNode,...
%                                 gui.RootNode.getChildCount());
%                 % Add sub noded for each trim definition
%                 for i = 1:length(gui.MassPropertiesDatabase)
%                     node = uitreenode('v0','',...
%                                     gui.MassPropertiesDatabase(i).WeightCode, [], 0);
%                     node.setIcon(gui.JavaImage_unchecked); 
%                     node.setValue('unselected');    
%                     tree.insertNodeInto(...
%                         node,...
%                         gui.MassPropertiesNode,...
%                         gui.MassPropertiesNode.getChildCount());
%                     
%                     for j = 1:length(gui.MassPropertiesDatabase(i).Parameter)
%                         nameNode = uitreenode('v0','',...
%                                         gui.MassPropertiesDatabase(i).Parameter(j).Name, [], 0);    
%                         tree.insertNodeInto(...
%                             nameNode,...
%                             node,...
%                             node.getChildCount());
%                         
%                             valueNode = uitreenode('v0','',...
%                                             num2str(gui.MassPropertiesDatabase(i).Parameter(j).Value), [], 0);    
%                             tree.insertNodeInto(...
%                                 valueNode,...
%                                 nameNode,...
%                                 nameNode.getChildCount());
%                     end
%                      
%                 end
%                 gui.MassPropertiesSelectedIndex = false(1,length(gui.MassPropertiesDatabase));
%             % - create the simulation definition sub node
%             [~,file,~] = fileparts(gui.ModelName);
%             gui.SimDefinitionNode = uitreenode('v0','',...
%                 file, [], 0);
%             gui.SimDefinitionNode.setIcon(gui.JavaImage_model); 
%             gui.SimDefinitionNode.setUserObject(gui.ModelName);
%             gui.SimDefinitionNode.setValue('Simulation');
%             tree.insertNodeInto(gui.SimDefinitionNode,...
%                                 gui.RootNode,...
%                                 gui.RootNode.getChildCount());
%             if nargin > 3
%                 gui.Figure = figure;
%                 gui.Parent = parent;
%                 % set treeModel
%                 gui.TreeModel = DefaultTreeModel( gui.RootNode );
% 
%                 % create the tree
%                 [gui.Tree, gui.Container] = uitree('v0',gui.Figure );
%                 set(gui.Container, 'Parent',gui.Parent);
%                 set(gui.Container, 'Visible','on');
%                 set(gui.Container, 'Units','normal')
%                 set(gui.Container, 'position',[0.015 0.003 1 1])
% 
%                 % set tree to treemodel
%                 gui.Tree.setModel( gui.TreeModel );
% 
%                 gui.JTree = handle(gui.Tree.getTree,'CallbackProperties');
% 
% 
%                 %set(gui.Tree, 'NodeSelectedCallback', fun.nodeSelectd_CB_H );
% 
%                 % Set the tree mouse-click callback
%                 % Note: MousePressedCallback is better than MouseClickedCallback
%                 %       since it fires immediately when mouse button is pressed,
%                 %       without waiting for its release, as MouseClickedCallback does
%                 %set(gui.JTree, 'MousePressedCallback',fun.mousePressedInTree_CB_H);   
%             end
%         end
    end % View Methods
    
    %% Methods - Protected
    methods (Access = protected) 
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the MassPropertiesDatabase object
            cpObj.MassPropertiesDatabase = copy(obj.MassPropertiesDatabase);
            % Make a deep copy of the LinearModelSettings object
            cpObj.LinearModelSettings = copy(obj.LinearModelSettings);
            % Make a deep copy of the TrimSettings object
            cpObj.TrimSettings = copy(obj.TrimSettings);

        end % copyElement
    end
    
    %% Method - Delete
    methods
%         function delete(obj)
%             try
%                 close_system(obj.ModelName);
%             end
%         end % delete
    end
end

