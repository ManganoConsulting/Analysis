classdef StabTree < UserInterface.tree
    
    %% Public properties - Object Handles
    properties (Transient = true)
        TrimSettingsNode
        MassPropNode
        SimNode
        AnalysisNode
        MassPropGUIObj = UserInterface.StabilityControl.MassPropGUI.empty
        DialogParent matlab.ui.Figure = matlab.ui.Figure.empty
    end % Public properties
  
    %% Private properties - Data Storage
    properties (Access = private)  
        BrowseStartDir = pwd %mfilename('fullpath')%
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Constant properties
    properties (Constant) 
        JavaImage_config = UserInterface.Icons.configIcon(); 

    end % Constant properties      
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Events
    events
%         DefinitionAdded
        SelectedPropChanged
        SimulinkModelChanged
        NewTrimDef
        NewLinMdlDef
        NewReqDef
        NewSimReqDef
        NewPostSimReqDef
        %LaunchMassPropGUI
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        SaveProjectEvent
        ReloadConstantFile
        NewAnalysis
        AnalysisObjectAdded
        AnalysisObjectSelected
        AnalysisObjectSaved
        ConstantFileUpdated
        AnalysisObjectDeleted
        MassPropertyAdded
        BatchNodeSelected
        BatchNodesRemoved
        UseExistingTrim
        AnalysisObjectEdited
    end
    
    %% Methods - Constructor
    methods  
        
        function obj = StabTree(parent)

            % Call superclass constructor
            obj = obj@UserInterface.tree(parent);

            % Store the owning UIFigure for dialog parenting
            obj.DialogParent = Utilities.getParentFigure(parent);
            if isempty(obj.DialogParent) || ~isvalid(obj.DialogParent)
                obj.DialogParent = Utilities.getParentFigure(obj);
            end

            % - UItree setup section -------------------------------------
            %  Note: the use of uitree and the other java functionality.                            
            % -------------------------------------------------------------------------
            % - get java tools
            import javax.swing.*
            import javax.swing.tree.*;

            % - create the root node
            warning('off','MATLAB:uitreenode:DeprecatedFunction');
            RootNode = uitreenode('v0','root', 'S & C Workspace', [], 0);
            RootNode.setUserObject('');
%     
%                 obj.MassPropNode = uitreenode('v0','unselected',...
%                     'Mass Properties', [], 0);
%                 obj.MassPropNode.setIcon(obj.JavaImage_unchecked); 
%                 obj.MassPropNode.setUserObject('JavaImage_unchecked');
%                 RootNode.add(obj.MassPropNode ); 
                
                obj.AnalysisNode = uitreenode('v0','',...
                    'Analysis Task', [], 0);
                %obj.AnalysisNode.setIcon(trimIcon); 
                obj.AnalysisNode.setUserObject('');
                RootNode.add(obj.AnalysisNode );
                                
                
                % Display Tree
                obj.showTree(RootNode);
                        
        end % StabTree
        
    end % Constructor

    %% Methods - Property Access
    methods
   
    end % Property access methods
   
    %% Methods - Ordinary
    methods

        function nodeIndex = setBatchNodeLabel( obj , analysisTabSelIndex , index , str  )
            parentNode = obj.AnalysisNode.getChildAt(analysisTabSelIndex - 1 ).getChildAt(4);
            
            allUUIDS = {};
            for i = 0:parentNode.getChildCount - 1
                allUUIDS{end+1} = parentNode.getChildAt(i).handle.UserData;
            end
            
            nodeIndex = find(strcmp(allUUIDS,index)) - 1;

%             parentNode = obj.AnalysisNode.getChildAt(analysisTabSelIndex - 1 ).getChildAt(4);
            node = parentNode.getChildAt( nodeIndex );
%             node = parentNode.getChildAt( index );
            node.setName(str);
            obj.JTree.repaint;
        end % setBatchNodeLabel
        
        function uuid = addBatchObj( obj , taskObj , selAnlInd, label )
            if nargin ~= 4
                label = taskObj(1).SetName_String;
            end
            node  = uitreenode(...
                'v0','selected', label, [], 0);
            node.setUserObject('JavaImage_checked');
            node.setIcon(obj.JavaImage_checked); 
            try
%                 parentNode = obj.AnalysisNode.getChildAt(selAnlInd - 1).getChildAt(0).getChildAt(0);
                parentNode = obj.AnalysisNode.getChildAt(selAnlInd - 1).getChildAt(4);
            catch
                obj.showAlert('Unable to add the run cases.', 'Run Cases');
                return;
            end
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());
%             node.UserData = copy(taskObj);
            uuid = getUUID();
            node.UserData = uuid;
            
            tPath = javax.swing.tree.TreePath( node.getPath() );
            obj.JTree.setSelectionPath( tPath );
            obj.JTree.repaint;
        end % addBatchObj
        
        function setBatchNode2Default( obj , analysisInd )
            node = obj.AnalysisNode.getChildAt(analysisInd - 1 ).getChildAt(0).getChildAt(0);
            tPath = javax.swing.tree.TreePath( node.getPath() );
            obj.JTree.setSelectionPath( tPath );
            obj.JTree.repaint;
            
        end % setBatchNode2Default
        
        function LA = getSelectedBatchLA( obj , ind )
%             parentNode = obj.AnalysisNode.getChildAt(ind - 1).getChildAt(0).getChildAt(0);
            parentNode = obj.AnalysisNode.getChildAt(ind - 1).getChildAt(4);
            numBatchObj = parentNode.getChildCount;
            
            LA = false(1,numBatchObj);
            for i = 1:numBatchObj
                childNode = parentNode.getChildAt( i - 1 );
                if strcmp( childNode.getValue , 'selected' )
                    LA(i) = true;
                end
            end 
            
        end % getSelectedBatchLA 
        
        function LA = getSelectedAnalysisTasks( obj , ind )
            parentNode = obj.AnalysisNode;
            numBatchObj = parentNode.getChildCount;
            
            LA = false(1,numBatchObj);
            for i = 1:numBatchObj
                childNode = parentNode.getChildAt( i - 1 );
                if strcmp( childNode.getValue , 'selected' )
                    LA(i) = true;
                end
            end 
            
        end % getSelectedAnalysisTasks 
              
        function setStartDirectories( obj , path )
            obj.BrowseStartDir = path;     
        end % setStartDirectories
 
        function restoreTree(obj,parent)
            % Call super class method
            restoreTree@UserInterface.tree(obj,parent); 
            
            obj.AnalysisNode         = findNode(obj.TreeModel.getRoot,'Analysis Task');
%             obj.MassPropNode         = findNode(obj.TreeModel.getRoot,'Mass Properties');      
        end % restoreTree 
        
        function saveTreeState(obj)
            % Call super class method
            saveTreeState@UserInterface.tree(obj);
        end % saveTreeState
        
        function [selObjs,selLA] = getSelectedMassPropObjs( obj )

            selLA = [];
            childNodes = findDirectChildrenInNode(obj.MassPropNode);
            selObjs = lacm.MassProperties.empty;
            if ~isempty(childNodes) && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if strcmp( childNodes{i}.getValue , 'selected' )
                        selLA(i) = true;
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs = [ selObjs , childNodes{i}.handle.UserData ]; %#ok<*AGROW>
                        end
                    else
                        selLA(i) = false;
                    end
                end   
            end          
                    
        end % getSelectedMassPropObjs
        
        function [ selObjs , selObjLogic ] = getAnalysisObjs( obj , selected )
            if nargin == 1
                selected = true;
            end
            
            selObjLogic = struct('TrimTask',{},'LinearModel',{},'Requirement',{},'SimulationRequirment',{},'Selected',{});
            childNodes = findDirectChildrenInNode(obj.AnalysisNode);
            selObjs = lacm.AnalysisTask.empty;
            if ~isempty(childNodes) && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if ~selected || strcmp( childNodes{i}.getValue , 'selected' )
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                        
                        % selObjLogic 
                        trimDefNode = childNodes{i}.getChildAt(0);
                        trimDefSel = false(1,trimDefNode.getChildCount);
                        for j = 1:trimDefNode.getChildCount
                            trimDefChild = trimDefNode.getChildAt(j-1);
                            if strcmp( trimDefChild.getValue , 'selected' )
                                trimDefSel(j) = true;
                            end
                        end
                        
                        linearModelNode = childNodes{i}.getChildAt(1);
                        linearModelSel = false(1,linearModelNode.getChildCount);
                        for j = 1:linearModelNode.getChildCount
                           	linerModelChild = linearModelNode.getChildAt(j-1);
                            if strcmp( linerModelChild.getValue , 'selected' )
                                linearModelSel(j) = true;
                            end
                        end     
                        
                        reqNode = childNodes{i}.getChildAt(2);
                        reqSel = false(1,reqNode.getChildCount);
                        for j = 1:reqNode.getChildCount
                            reqChild = reqNode.getChildAt(j-1);
                            if strcmp( reqChild.getValue , 'selected' )
                                reqSel(j) = true;
                            end
                        end   
                        
                        simNode = childNodes{i}.getChildAt(3);
                        simSel = false(1,simNode.getChildCount);
                        for j = 1:simNode.getChildCount
                            simChild = simNode.getChildAt(j-1);
                            if strcmp( simChild.getValue , 'selected' )
                                simSel(j) = true;
                            end
                        end  
                        
                        if strcmp( childNodes{i}.getValue , 'selected' )
                            selVal = true;
                        else
                            selVal = false;
                        end
                        selObjLogic(end +1) = struct('TrimTask',trimDefSel,'LinearModel',linearModelSel,'Requirement',reqSel,'SimulationRequirment',simSel,'Selected',selVal);
                        
                        
                    end
                end   
            end
        end % getAnalysisObjs       
        
        function selObjs = getSelectedTrimDefObjs( obj )
            childNodes = findDirectChildrenInNode(obj.TrimDefNode);
            selObjs = lacm.TrimSettings.empty;
            if ~isempty(childNodes) && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if strcmp( childNodes{i}.getValue , 'selected' )
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                    end
                end   
            end
        end % getSelectedTrimDefObjs
        
        function selObjs = getSelectedLinMdlObjs( obj , analysisObj )
            if nargin == 1

                childNodes = findDirectChildrenInNode(obj.LinMdlDefNode);
                selObjs = lacm.LinearModel.empty;
                if ~isempty(childNodes) && ~isempty(childNodes{1})
                    for i = 1:length(childNodes)
                        if strcmp( childNodes{i}.getValue , 'selected' )
                            if ~isempty(childNodes{i}.handle.UserData)
                                selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                            end
                        end
                    end   
                end
            
            else

                
            end
        end % getSelectedLinMdlObjs
        
        function mdlName = getSelectedSimModel( obj )
            mdlName = [];
%             childNodes = findDirectChildrenInNode(obj.SimNode);
%             if isempty(childNodes) || isempty(childNodes{:})
%                 mdlName = [];
%             else
%                 mdlName = [];%{};
% 
%                 for i = 1:length(childNodes)
%                     mdlnameExt = childNodes{i}.handle.UserData; %#ok<*AGROW>selObjs{end+1} = childNodes{i}.handle.UserData; %#ok<*AGROW>
%                     if ischar(mdlnameExt); mdlnameExt = {mdlnameExt};end;
%                     [~,mdlName] = fileparts(mdlnameExt{:});
%                 end   
%             end
        end % getSelectedSimModel
        
        function selObjs = getConstantsFile( obj )
            selObjs = [];
%             childNodes = findDirectChildrenInNode(obj.SimNode);
%             if ~isempty(childNodes) && ~isempty(childNodes{1})
%                 constNodes = findDirectChildrenInNode(childNodes{:});
%                 selObjs = {};
%                 if ~isempty(constNodes{:})
%                     for i = 1:length(constNodes)
%                         filename = constNodes{i}.handle.UserData;
%                         if iscell(filename)
%                             selObjs(end+1) = constNodes{i}.handle.UserData; %#ok<*AGROW>
%                         else
%                             selObjs{end+1} = constNodes{i}.handle.UserData; %#ok<*AGROW>
%                         end
%                     end    
%                 end
%             else
%                 selObjs = [];
%             end
        end % getConstantsFile
        
        function selObjs = getAllMassPropObjs( obj )
            
            childNodes = findDirectChildrenInNode(obj.MassPropNode);
            selObjs = {};
            if isempty(childNodes{1})
                return;
            end
            for i = 1:length(childNodes)
                if ~isempty(childNodes{i}.handle.UserData)
                    selObjs{end+1} = childNodes{i}.handle.UserData; %#ok<*AGROW>
                end
            end                  
        end % getAllMassPropObjs
        
        function selObjs = getAllLinMdlObjs( obj )
            %synNode    = findNode(obj.TreeModel.getRoot,'Linear Model Definition');
            childNodes = findDirectChildrenInNode(obj.LinMdlDefNode);
            selObjs = lacm.LinearModel.empty;
            for i = 1:length(childNodes)
                    if ~isempty(childNodes{i}.handle.UserData)
                        selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                    end
            end    
        end % getAllLinMdlObjs
        
        function selObjs = getAllTrimDefObjs( obj )
            %synNode    = findNode(obj.TreeModel.getRoot,'Trim Definition');
            childNodes = findDirectChildrenInNode(obj.TrimDefNode);
            selObjs = lacm.TrimSettings.empty;
            for i = 1:length(childNodes)
                    if ~isempty(childNodes{i}.handle.UserData)
                        selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                    end
            end    
        end % getAllTrimDefObjs      
        
        function selObjs = getSelectedMethodObjs( obj )
            childNodes = findDirectChildrenInNode(obj.MethodNode);
            selObjs = Requirements.RequirementTypeOne.empty;
            if length(childNodes) >= 1 && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if strcmp( childNodes{i}.getValue , 'selected' )
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                    end
                end   
            end
        end % getSelectedMethodObjs
        
        function selObjs = getAllSimulationObjs( obj )
            
            
            
            
            
            
            
            
            
            
            childNodes = findDirectChildrenInNode(obj.SimulationObjectNode);
            selObjs = Requirements.SimulationCollection.empty;
            if length(childNodes) >= 1 && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if ~isempty(childNodes{i}.handle.UserData)
                        selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                    end
                   
                end   
            end
        end % getAllSimulationObjs 
        
        function selObjs = getSelectedSimulationObjs( obj )
            childNodes = findDirectChildrenInNode(obj.SimulationObjectNode);
            selObjs = Requirements.SimulationCollection.empty;
            if length(childNodes) >= 1 && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if strcmp( childNodes{i}.getValue , 'selected' )
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                    end
                end   
            end
        end % getSelectedSimulationObjs 
        
        function selObjs = getSelectedPostSimulationObjs( obj )
            childNodes = findDirectChildrenInNode(obj.PostSimulationObjectNode);
            selObjs = Requirements.RequirementTypeOnePost.empty;
            if length(childNodes) >= 1 && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                    if strcmp( childNodes{i}.getValue , 'selected' )
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                    end
                end   
            end
        end % getSelectedPostSimulationObjs 
        
        function setColor4MdlCompiledState(obj, ~, ~)
            
            childNodes = findDirectChildrenInNode(obj.AnalysisNode);
            selObjs = lacm.AnalysisTask.empty;
            if ~isempty(childNodes) && ~isempty(childNodes{1})
                for i = 1:length(childNodes)
                        if ~isempty(childNodes{i}.handle.UserData)
                            selObjs(end+1) = childNodes{i}.handle.UserData; %#ok<*AGROW>
                        end
                        
                        % selObjLogic 
                        trimDefNodeMdl = childNodes{i}.getChildAt(0).getChildAt(0).getChildAt(0);
                        
                        mdlname = char(get(trimDefNodeMdl,'UserData'));
                        
                        if ~bdIsLoaded(mdlname) 
                            load_system(mdlname);
                        end
                        simState = get_param(mdlname, 'SimulationStatus');
                        
                        if strcmp(simState,'paused')
                            trimDefNodeMdl.setName(['<html><font color="red">&nbsp;',char(mdlname),'</html>']);
                        else
                            trimDefNodeMdl.setName(['<html><font color="black">&nbsp;',char(mdlname),'</html>']);
                        end
                end
            end
            
            try
                obj.JTree.repaint;
            end
            
        end  % setColor4MdlCompiledState
        
    end % Ordinary Methods
    
    %% Methods - Insert Node Callbacks
    methods 
        
        function insertDefinitionObj_CB( obj , ~ , ~ , parentNode , path , newObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
            reqClass = class(newObj);
            if isempty(path)
                [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
            else
                [pathname,name,ext] = fileparts(path) ;
                filename = [name,ext];
            end
            drawnow();pause(0.5);
            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
            %if ~isequal(filename{1},0)
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            obj.showAlert({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','Icon','error');
                            continue;
                        end
                        % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))   
                            
                            newObj(end+1) = varStruct.(varNames{i})(mult); %#ok<AGROW>
                            index = length(newObj);
                            node = treeNode(newObj(end),obj.TreeModel);

%                             node.setUserObject('JavaImage_checked');
                            obj.TreeModel.insertNodeInto(...
                                node,...
                                parentNode,...
                                parentNode.getChildCount());
                            %set requirement to selected by default
%                             node.setIcon(obj.JavaImage_checked); 
%                             node.setValue('selected');

                            
                            node.UserData = newObj(index);    
                        
                        end
                        
                    end
                end
                obj.JTree.repaint;
%                 notify(obj,'DefinitionAdded',UserInterface.UserInterfaceEventData(newObj));     
                notify(obj,'SaveProjectEvent');
            %end 
        end % insertDefinitionObj_CB        
        
        function insertTrimDefObj_CB( obj , ~ , ~ , parentNode , path , newObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
            if isempty(newObj)
                reqClass = class(newObj);
                if isempty(path)
                    [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
                else
                    [pathname,name,ext] = fileparts(path) ;
                    filename = [name,ext];
                end
                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                obj.BrowseStartDir = pathname;
                if ~iscell(filename)
                    filename = {filename};
                end
                %if ~isequal(filename{1},0)
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            obj.showAlert({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','Icon','error');
                            continue;
                        end
                       % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))  
                            newObj(end+1) = varStruct.(varNames{i})(mult);
                            insertTrimObj_Private( obj , parentNode , newObj);
                        end
                    end
                end
            else
                insertTrimObj_Private( obj , parentNode , newObj);
            end
            obj.JTree.repaint;  
            notify(obj,'SaveProjectEvent');
          
        end % insertTrimDefObj_CB   
    
        function insertLinMdlObj_CB( obj , ~ , ~ , parentNode , path , newObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
            if isempty(newObj)
                reqClass = class(newObj);
                if isempty(path)
                    [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
                else
                    [pathname,name,ext] = fileparts(path) ;
                    filename = [name,ext];
                end
                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                obj.BrowseStartDir = pathname;
                if ~iscell(filename)
                    filename = {filename};
                end
             
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            obj.showAlert({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','Icon','error');
                            continue;
                        end
                        % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))     
                            newObj(end+1) = varStruct.(varNames{i})(mult); 
                            newObj(end).FileName = filename{k};
                            insertLinearModelObj_Private( obj , parentNode , newObj);

                        end

                    end
                end
            else
                insertLinearModelObj_Private( obj , parentNode , newObj);
            end
            obj.JTree.repaint;
            notify(obj,'SaveProjectEvent');
        
        end % insertLinMdlObj_CB    
        
        function addModel_CB( obj , ~ , ~ , parentNode )
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
        
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:','MultiSelect', 'on');
            drawnow();pause(0.5);

            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
            
            obj.showAlert('Remember to set the correct units.', 'Units');
            %disp('Ask user to insert units here.');
            
            removeAllChildNodes( obj , parentNode  );
            node  = uitreenode(...
                'v0','', filename, [], 0); % obj.Label
            node.setIcon(obj.JavaImage_model); 
            node.setUserObject('JavaImage_model');
            
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());

            node.UserData = filename;      

            obj.JTree.repaint;
            notify(obj,'SimulinkModelChanged',UserInterface.StabilityControl.ModelAddedEventData( filename , false ));  
            notify(obj,'SaveProjectEvent');
        end % addModel_CB

        function insertFolder_CB( obj , ~ , ~ , node )
        %----------------------------------------------------------------------
        %- Callback for "gui.mainLayout.tree" uitree context menu
        %----------------------------------------------------------------------

            answer = inputdlg({'Folder Name:'},'Add New Folder',1,{'New Folder'});
            drawnow();pause(0.5);
            if isempty(answer)
                return;
                elseif isempty(answer{1})
                 answer = 'Folder Name';
            end

            newFolder = uitreenode(...
                'v0','folder', answer, [], 0);
            newFolder.setIcon(obj.JavaImage_folderopen); 
            newFolder.setUserObject('JavaImage_folderopen');

            obj.TreeModel.insertNodeInto(...
                newFolder,...
                node,...
                node.getChildCount());

        end % insertFolder_CB
        
        function addMethod_CB( obj , ~ , ~ , parentNode, path , reqObj )
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             icon_dir = fullfile( this_dir,'..','..','Resources' );             
%             methIconPath = fullfile(icon_dir,'new_script_ts_16.png');
%             im = imread(methIconPath,'BackgroundColor',[1,1,1]);
%             methIcon = im2java(im); 
%             
%             plotIconPath = fullfile(icon_dir,'Figure_16.png');
%             im = imread(plotIconPath,'BackgroundColor',[1,1,1]);
%             plotIcon = im2java(im);
            
            
            reqClass = class(reqObj);
            if isempty(path)
                [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
            else
                [pathname,name,ext] = fileparts(path) ;
                filename = [name,ext];
            end
            drawnow();pause(0.5);
            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
            %if ~isequal(filename{1},0)
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)


                        % add to requirement object array
                        reqObj(end+1) = varStruct.(varNames{i}); 
                        % get the index
                        index = length(reqObj);
                        
                        % Set Parent node to selected by default
                        if parentNode.getChildCount() == 0 && ~strcmp(parentNode.getUserObject(),'JavaImage_folderopen') && ~strcmp(parentNode.getName(),'Synthesis')
                            parentNode.setValue('selected');
                            parentNode.setIcon(obj.JavaImage_checked); 
                            parentNode.setUserObject('JavaImage_checked');
                        end
                        
                        node  = uitreenode(...
                            'v0','selected', reqObj(index).Title, [], 0);
                        node.setUserObject('JavaImage_checked');
                        obj.TreeModel.insertNodeInto(...
                            node,...
                            parentNode,...
                            parentNode.getChildCount());
                        % set requirement to selected by default
                        node.setIcon(obj.JavaImage_checked); 
                        node.setValue('selected');
                        
                        
                            if ~isempty(reqObj(index).MdlName)
                                % Add model node if one exists
                                modelNode  = uitreenode(...
                                    'v0','', reqObj(index).MdlName, [], 0);
                                modelNode.setUserObject('JavaImage_model');
                                obj.TreeModel.insertNodeInto(...
                                    modelNode,...
                                    node,...
                                    node.getChildCount());
                                % set requirement to selected by default
                                modelNode.setIcon(obj.JavaImage_model); 
                            end
                            if ~isempty(reqObj(index).FunName)            

                                % Add method node if one exists
                                methodNode  = uitreenode(...
                                    'v0','', reqObj(index).FunName , [], 0);
                                methodNode.setUserObject('JavaImage_method');
                                obj.TreeModel.insertNodeInto(...
                                    methodNode,...
                                    node,...
                                    node.getChildCount());
                                % set requirement to selected by default
                                methodNode.setIcon(obj.JavaImage_method); 
                                methodNode.setValue('Method');
                            end
                            if (isa(reqObj,'Requirements.RequirementTypeOne') && ~isempty(reqObj(index).RequiermentPlot)) ||  (isa(reqObj,'Requirements.RootLocus') && ~isempty(reqObj(index).RequiermentPlot))         

                                % Add reqPlot node if one exists
                                plotNode  = uitreenode(...
                                    'v0','', reqObj(index).RequiermentPlot , [], 0);
                                plotNode.setUserObject('JavaImage_plot');
                                obj.TreeModel.insertNodeInto(...
                                    plotNode,...
                                    node,...
                                    node.getChildCount());
                                % set requirement to selected by default
                                plotNode.setIcon(obj.JavaImage_plot); 
                                plotNode.setValue('RequiermentPlot');
                            end
                            if strcmp(parentNode.getName(),'Synthesis') && ~isa(reqObj,'Requirements.RootLocus')
                                % insert New Scatt Gain File
                                %gainScattCollName = insertNewScatteredGainObj_CB( obj , [] , [] , node );
                                insertNewScatteredGainObj_CB( obj , [] , [] , node );
                                % Set to selected by default
                                node.setIcon(obj.JavaImage_checked); 
                                node.setValue('selected');
                                obj.GainSource = 1;
                                % select the new scatt Gain File
                                %selectScatteredGainFile2Write( obj , [] , [] , node , gainScattCollName );
                            end
                            
                            
                            
                        
                        reqObj(index).FileName = filename{k};
                        reqObj(index).SelectedStatus = 'selected';
                        %reqObj(index).uitreenode = node;
                        node.UserData = reqObj(index);        
                    end
                end
                obj.JTree.repaint;
                %notify(obj,'ReqObjAdded',UserInterface.ControlDesign.ControlTreeEventData(reqObj));   
 
        end % addMethod_CB
        
        function insertReqObj_CB( obj , ~ , ~ , parentNode , path , reqObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
 
            if isempty(reqObj)
                reqClass = class(reqObj);
                if isempty(path)
                    [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
                else
                    [pathname,name,ext] = fileparts(path) ;
                    filename = [name,ext];
                end
                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                obj.BrowseStartDir = pathname;
                if ~iscell(filename)
                    filename = {filename};
                end
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            obj.showAlert({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','Icon','error');
                            continue;
                        end
                        reqObj(end+1) = varStruct.(varNames{i}); 
                        insertReqObj_Private( obj , parentNode , reqObj);

                    end
                end
                
            else
                insertReqObj_Private( obj , parentNode , reqObj);
            end
            obj.JTree.repaint;
%             notify(obj,'ReqObjAdded',UserInterface.ControlDesign.ControlTreeEventData(reqObj));      
            notify(obj,'SaveProjectEvent');
        end % insertReqObj_CB   
        
        function insertConstantsFile_CB( obj , ~ , ~ , parentNode )
            [filename, pathname] = uigetfile({'*.m;*.mat',...
                                                 'MATLAB Files (*.m,*.mat)';
                                                   '*.m',  'Code files (*.m)'; ...
                                                   '*.mat','MAT-files (*.mat)'; ...
                                                   '*.*',  'All Files (*.*)'},...
                                                   'Select Constants File:',obj.BrowseStartDir,'MultiSelect', 'on');
                                               drawnow();pause(0.5);

            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
            
            node  = uitreenode(...
                'v0','', filename, [], 0); % obj.Label
            node.setIcon(obj.JavaImage_method); 
            node.setUserObject('JavaImage_method');
            
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());

            node.UserData = filename;      

            obj.JTree.repaint;
            notify(obj,'SimulinkModelChanged',UserInterface.StabilityControl.ModelAddedEventData( filename , true , char(parentNode.getName))); 
            notify(obj,'ConstantFileUpdated');
        end % insertConstantsFile_CB 
        
    end
    
    %% Methods - Analysis Methods Callbacks
    methods
        
        function insertAnalysisObj_CB( obj , ~ , ~ , parentNode , path , reqObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
 
            if isempty(reqObj)
                reqClass = class(reqObj);
                if isempty(path)
                    [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.BrowseStartDir,'MultiSelect', 'on');
                else
                    [pathname,name,ext] = fileparts(path) ;
                    filename = [name,ext];
                end
                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                obj.BrowseStartDir = pathname;
                if ~iscell(filename)
                    filename = {filename};
                end
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            obj.showAlert({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','Icon','error');
                            continue;
                        end
                        reqObj(end+1) = varStruct.(varNames{i}); 
                        insertAnalysisObj_Private( obj , parentNode , reqObj);
                        notify(obj,'AnalysisObjectAdded',UserInterface.UserInterfaceEventData(reqObj(end)));
                    end
                end
                
            else
                insertAnalysisObj_Private( obj , parentNode , reqObj);
                notify(obj,'AnalysisObjectAdded',UserInterface.UserInterfaceEventData(reqObj(end)));
            end
            obj.JTree.repaint;
%             notify(obj,'ReqObjAdded',UserInterface.ControlDesign.ControlTreeEventData(reqObj));  

            setColor4MdlCompiledState(obj, [], []);

            notify(obj,'SaveProjectEvent');
            
        end % insertAnalysisObj_CB 
        
        function insertAnalysisObj_Private( obj , parentNode , reqObj )  
            % get the index
            index = length(reqObj);

            node  = uitreenode(...
                'v0','selected', reqObj(index).Title, [], 0);
            node.setUserObject('JavaImage_checked');
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());
            % set requirement to selected by default
            node.setIcon(obj.JavaImage_checked); 
            node.setValue('selected');

            obj.JTree.repaint;

            node.UserData = reqObj(index); 
            
            updateAnalysisNode( obj , node );       
        end % insertAnalysisObj_Private   
        
        function updateAnalysisNode( obj , node )
            
            removeAllChildNodes( obj , node );
            reqObj = node.handle.UserData;
            
            % Insert the trim group node
            trimGroupNode  = uitreenode(...
                'v0','', 'Trim Definition', [], 0);
            obj.TreeModel.insertNodeInto(...
                trimGroupNode,...
                node,...
                node.getChildCount());

            for i = 1:length(reqObj.TrimTask)
                insertTrimObj_Private( obj , trimGroupNode , reqObj.TrimTask(i));
            end

            % Insert the linear model group node
            lmGroupNode  = uitreenode(...
                'v0','', 'Linear Model Definition', [], 0);
            obj.TreeModel.insertNodeInto(...
                lmGroupNode,...
                node,...
                node.getChildCount());

            for i = 1:length(reqObj.LinearModelDef)
                insertLinearModelObj_Private( obj , lmGroupNode , reqObj.LinearModelDef(i));
            end

            % Insert the req group node
            reqGroupNode  = uitreenode(...
                'v0','', 'Requirement', [], 0);
            obj.TreeModel.insertNodeInto(...
                reqGroupNode,...
                node,...
                node.getChildCount());

            for i = 1:length(reqObj.Requirement)
                insertReqObj_Private( obj , reqGroupNode , reqObj.Requirement(i));
            end   

            % Insert the sim group node
            simGroupNode  = uitreenode(...
                'v0','', 'Simulation', [], 0);
            obj.TreeModel.insertNodeInto(...
                simGroupNode,...
                node,...
                node.getChildCount());

            for i = 1:length(reqObj.SimulationRequirment)
                insertReqObj_Private( obj , simGroupNode , reqObj.SimulationRequirment(i));
            end
            
            
            % Insert the trim settings
            batchGroupNode  = uitreenode(...
                'v0','', 'Batch runs', [], 0);
            obj.TreeModel.insertNodeInto(...
                batchGroupNode,...
                node,...
                node.getChildCount());
            
            if isempty(reqObj.SavedTaskCollectionObjBatch)
                reqObj.SavedTaskCollectionObjBatch = lacm.TrimTaskCollectionBatch;
                reqObj.SavedTaskCollectionObjBatch.TrimTaskCollObj = lacm.TrimTaskCollection;
                reqObj.SavedTaskCollectionObjBatch.TrimTaskCollObj.Label = 'Run 1';
            end
            
            for i = 1:length(reqObj.SavedTaskCollectionObjBatch.TrimTaskCollObj)

                label = reqObj.SavedTaskCollectionObjBatch.TrimTaskCollObj(i).Label;

                nodeTCC  = uitreenode(...
                    'v0','selected', label, [], 0);
                nodeTCC.setUserObject('JavaImage_checked');
                nodeTCC.setIcon(obj.JavaImage_checked); 
                obj.TreeModel.insertNodeInto(...
                    nodeTCC,...
                    batchGroupNode,...
                    batchGroupNode.getChildCount());
                nodeTCC.UserData = reqObj.SavedTaskCollectionObjBatch.TrimTaskCollObj(i).UUID;

                tPath = javax.swing.tree.TreePath( nodeTCC.getPath() );
                obj.JTree.setSelectionPath( tPath );
                obj.JTree.repaint;        
            end


            index = node.getParent.getIndex(node) + 1;
            notify(obj,'MassPropertyAdded',UserInterface.UserInterfaceEventData(struct('Index',index,'MassProperty',reqObj.MassProperties)));  
        end
                
        function createNewAnalysis_CB( obj , ~ , ~ )
            notify(obj,'NewAnalysis');
        end % createNewAnalysis_CB
        
    end
    
    %% Methods - Remove Node Callbacks
    methods   
    
        function removeAllSubNodes_CB( obj , ~ , ~ , treeNode )  
            analysisObjRemoved = false;
            if strcmp('Analysis Task',treeNode.getName) 
                removeIndex = 1:1:treeNode.getChildCount;
                analysisObjRemoved = true;
            end
            
            selPath = obj.JTree.getSelectionPath; 
            if any(strcmp({'Mass Properties'},{char(treeNode.getName),char(treeNode.getParent.getName)})) 
                type = 1; 
                
                % Warn User that all mass Properties will be removed in all
                % run cases
                choice = obj.confirmDialog('Mass Properties will be removed in all Run Cases. Continue?', ...
                    'Mass Properties', {'Yes','No'}, 'Yes', 'No');
                switch choice
                    case 'Yes'
                         % Do nothing and continue
                    otherwise
                        return; % Return
                end

            elseif selPath.getPathCount > 4 && strcmp('Trim Definition',char(selPath.getPathComponent(3).getName))%any(strcmp({'Trim Definition'},{char(treeNode.getName),char(treeNode.getParent.getName)}))
                type = 6;
            elseif any(strcmp({'Linear Model Definition'},{char(treeNode.getName),char(treeNode.getParent.getName)}))
                type = 3;
            elseif any(strcmp({'Requirement'},{char(treeNode.getName),char(treeNode.getParent.getName)}))
                type = 4;
            else
                type = 5;
%                 try
%                     selPath = obj.JTree.getSelectionPath; 
%                     if selPath.getPathCount > 4 && strcmp('Trim Definition',char(selPath.getPathComponent(3).getName))
%                         type = 6;
%                     end
%                 end
            end
            
            removeAllChildNodes( obj , treeNode  );     
            
            switch type
                case 1
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedMassPropObjs(obj)));
                case 2
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedTrimDefObjs(obj)));
                case 3
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedLinMdlObjs(obj)));
                otherwise
                    
            end
            
            % reset checkbox
            switch type
                case {1,3,4}                   
                    treeNode.setIcon(obj.JavaImage_unchecked); 
                    treeNode.setValue('unselected');        
            end
            obj.JTree.repaint;
            
            if analysisObjRemoved
                notify(obj,'AnalysisObjectDeleted',UserInterface.UserInterfaceEventData(removeIndex));
            end
            
            if type == 1
%                 notify(obj,'MassPropertyAdded');  
            end
            
            if type == 6 
                notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(-1)); 
            end
        end % removeAllSubNodes_CB
        
        function removeAllBatchNodes_CB( obj , ~ , ~ , treeNode )  

            numChildNodes = treeNode.getChildCount;
            for i = (numChildNodes - 1):-1:1
                subNode = treeNode.getChildAt(i);
                removeNode( obj , subNode);  
            end
%             removeAllChildNodes( obj , treeNode  );              
            obj.JTree.repaint;
            
            notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(-1)); 

        end % removeAllBatchNodes_CB
        
        function removeBatchNodes_CB( obj , ~ , ~ , treeNode )  

            selPath = obj.JTree.getSelectionPath; 
            index = selPath.getPathComponent(3).getIndex(treeNode) + 1;
            uuid = treeNode.handle.UserData;
            if index == 1
                return;
            end
   
            removeNode(obj, treeNode);            
            obj.JTree.repaint;
            
            notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(uuid)); 

        end % removeBatchNodes_CB
        
        function removeSubNode_CB( obj , ~ , ~ , treeNode ) 
            parentNode = treeNode.getParent;
            analysisObjRemoved = false;
            if strcmp('Analysis Task',parentNode.getName) 
                removeIndex = parentNode.getIndex(treeNode) + 1;
                analysisObjRemoved = true;
            end
            
            
            if strcmp('Mass Properties',parentNode.getName) && strcmp(char(treeNode.getValue),'selected')
                type = 1; 
                
                % Warn User that all mass Properties will be removed in all
                % run cases
                choice = obj.confirmDialog('Mass Properties will be reset in all Run Cases. Continue?', ...
                    'Mass Properties', {'Yes','No'}, 'Yes', 'No');
                switch choice
                    case 'Yes'
                         % Do nothing and continue
                    otherwise
                        return; % Return
                end
            elseif strcmp('Trim Definition',parentNode.getName) && strcmp(char(treeNode.getValue),'selected')
                type = 2;
            elseif strcmp('Linear Model Definition',parentNode.getName) && strcmp(char(treeNode.getValue),'selected')
                type = 3;
            elseif strcmp('Requirement',parentNode.getName) && strcmp(char(treeNode.getValue),'selected')
                type = 4;
            else
                type = 5;
                try
                    selPath = obj.JTree.getSelectionPath; 
                    if selPath.getPathCount > 5 && strcmp('Trim Definition',char(selPath.getPathComponent(3).getName))
                        type = 6;
                        index = selPath.getPathComponent(4).getIndex(treeNode) + 1;;
                        
                    end
                end
                
            end
            
            removeNode( obj , treeNode);   
            
            switch type
                case 1
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedMassPropObjs(obj)));
                case 2
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedTrimDefObjs(obj)));
                case 3
%                     notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedLinMdlObjs(obj)));
                otherwise
                    
            end
            
            % reset checkbox

            if strcmp('Mass Properties',parentNode.getName) || ...
                    strcmp('Linear Model Definition',parentNode.getName) || ...
                    strcmp('Requirement',parentNode.getName)
                
                count = parentNode.getChildCount;
                   selBool = {};
                    for i = 0:(count-1)
                        currNode = parentNode.getChildAt(i);
                        selBool{i+1} = currNode.getValue;
                    end
                    ret = setxor(selBool,{'selected','unselected'});
                    if isempty(ret)
                        parentNode.setIcon(obj.JavaImage_partialchecked); 
                        parentNode.setValue('mixed');
                    elseif strcmp(ret,'unselected')
                        parentNode.setIcon(obj.JavaImage_checked); 
                        parentNode.setValue('selected'); 
                    else
                        parentNode.setIcon(obj.JavaImage_unchecked); 
                        parentNode.setValue('unselected');  
                    end                           
            end
            obj.JTree.repaint;
            
            if analysisObjRemoved
                notify(obj,'AnalysisObjectDeleted',UserInterface.UserInterfaceEventData(removeIndex));
            end
            
            if type == 1
%                 notify(obj,'MassPropertyAdded');  
            end
            if type == 6 
               notify(obj,'BatchNodesRemoved',UserInterface.UserInterfaceEventData(index));   
            end
        end % removeSubNode_CB
        
        function removeConstants_CB( obj , ~ , ~ , node )
            removeNode( obj , node); 
        end % removeConstants_CB 
        
    end
    
    %% Methods - Callbacks
    methods  
        
        function insertOutputFile_CB( obj , ~ , ~ , parentNode )
            [filename, pathname] = uigetfile({'*.m;*.mat',...
                                                 'MATLAB Files (*.m,*.mat)';
                                                   '*.m',  'Code files (*.m)'; ...
                                                   '*.mat','MAT-files (*.mat)'; ...
                                                   '*.*',  'All Files (*.*)'},...
                                                   'Select Constants File:',obj.BrowseStartDir,'MultiSelect', 'on');
                                               drawnow();pause(0.5);

            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            
            node  = uitreenode(...
                'v0','unselected', filename, [], 0); 
            node.setIcon(obj.JavaImage_unchecked); 
            node.setUserObject('JavaImage_unchecked');
            
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());

            node.UserData = fullfile(pathname,filename);      

            obj.JTree.repaint;
            %notify(obj,'SimulinkModelChanged',UserInterface.StabilityControl.ModelAddedEventData( filename , true , char(parentNode.getName))); 
        end % insertOutputFile_CB
        
        function newOutputFile_CB( obj , ~ , ~ , parentNode )
            
            [filename, pathname] = uiputfile(...
             {'*.mat'},...
             'Save as',fullfile(obj.BrowseStartDir,'operCond.mat'));
         
            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            
            operCond = lacm.OperatingCondition.empty; %#ok<NASGU>
            save(fullfile(pathname, filename),'operCond');
            
            node  = uitreenode(...
                'v0','unselected', filename, [], 0); 
            node.setIcon(obj.JavaImage_unchecked); 
            node.setUserObject('JavaImage_unchecked');
            
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());

            node.UserData = fullfile(pathname , filename);      

            obj.JTree.repaint;
            %notify(obj,'SimulinkModelChanged',UserInterface.StabilityControl.ModelAddedEventData( filename , true , char(parentNode.getName))); 
        end % newOutputFile_CB
          
        function launchMPGUI( obj , ~ , ~ )
            %notify(obj,'LaunchMassPropGUI');
            massPropObjs = getAllMassPropObjs(obj);
            if isempty(massPropObjs)
                return;
            end
            [~,selLA] = getSelectedMassPropObjs( obj ); 
            obj.MassPropGUIObj = UserInterface.StabilityControl.MassPropGUI(massPropObjs,selLA);
            addlistener(obj.MassPropGUIObj,'MassPropertyGUIChanged',@obj.massPropChangedByGUI);
            addlistener(obj.MassPropGUIObj,'FigureClosed',@obj.massPropClosed);
        end % launchMPGUI
        
        function openMdl_CB( ~ , ~ , ~ , selMdlName )
            %selObjs = getSelectedSimModel( obj );
            if ~isempty(selMdlName)
               open_system(selMdlName); 
            end
            
        end % openModel_CB     
                
        function compileMdl_CB( obj , ~ , ~ , node, sim_Status )
            setWaitPtr(obj); 
            selMdlName = char(get(node,'UserData'));
            
            %node.setName(['<html><font color="red" face="Courier New">&nbsp;',char(mdlname),'</html>']);
%             node.setName(['<html><font color="red">&nbsp;',char(mdlname),'</html>']);
            
            isloaded = bdIsLoaded(selMdlName);
            if ~isloaded
                load_system(selMdlName);
            end
            if ~strcmp(sim_Status,'paused')
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Simulation: ',selMdlName,' state is being set to: "Compile".'],'info'));
                feval(selMdlName, [], [], [], 'compile');
                node.setName(['<html><font color="red">&nbsp;',char(selMdlName),'</html>']);
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Simulation: ',selMdlName,' state change completed.'],'info'));
            else   
                while strcmp('paused',get_param(char(selMdlName), 'SimulationStatus'))
                    feval(selMdlName, [], [], [], 'term');
                    pause(0.1);
                end
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Simulation: ',selMdlName,' has been released from its compiled state.'],'info'));
                node.setName(['<html><font color="black">&nbsp;',char(selMdlName),'</html>']);
            end
            
            
            setColor4MdlCompiledState(obj, [],[]);
            
            
            obj.JTree.repaint;
            releaseWaitPtr(obj);        
        end % compileMdl_CB
              
        function openModel_CB( obj , ~ , ~ , node )
            mdlName = char(node.getName);
            open_system(mdlName);
        end % openModel_CB       
        
        function openMethod_CB( obj , ~ , ~ , node )
            methodName = char(node.getName);
            open(methodName);
        end % openMethod_CB
        
        function runMFile_CB( obj , ~ , ~ , node )
            [~,filename] = fileparts(char(node.getName));
            try
%                 run(filename);
                evalin('base', ['run(''',filename,''');']);
                notify(obj,'ReloadConstantFile'); 
                notify(obj,'ConstantFileUpdated');
            catch
                error('FlightDynamics:ConstatsFileMissing',['Unable to find ',filename,' on the Matalb path']);
            end
        end % runMFile_CB  
           
    end
    
    %% Methods - Callbacks
    methods 
    
        function massPropChangedByGUI( obj , ~ , eventdata )
            childNodes = findDirectChildrenInNode(obj.MassPropNode);
            for i = 1:length(childNodes)
                switch eventdata.Object(i)
                    case true
                        childNodes{i}.setValue('selected');
                        childNodes{i}.setIcon(obj.JavaImage_checked);
                    case false
                        childNodes{i}.setValue('unselected');
                        childNodes{i}.setIcon(obj.JavaImage_unchecked);       
                end
            end             
            count = obj.MassPropNode.getChildCount;
            for i = 0:(count-1)
                currNode = obj.MassPropNode.getChildAt(i);
                selBool{i+1} = currNode.getValue; 
            end
            ret = setxor(selBool,{'selected','unselected'});
            if isempty(ret)
                obj.MassPropNode.setIcon(obj.JavaImage_partialchecked); 
                obj.MassPropNode.setValue('mixed');
            elseif strcmp(ret,'unselected')
                obj.MassPropNode.setIcon(obj.JavaImage_checked); 
                obj.MassPropNode.setValue('selected'); 
            elseif strcmp(ret,'selected')
                obj.MassPropNode.setIcon(obj.JavaImage_unchecked); 
                obj.MassPropNode.setValue('unselected'); 
            end
            notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedMassPropObjs(obj)));
            obj.JTree.treeDidChange();
        end % massPropChangedByGUI
        
        function trimSettings = createDefaultTrimDefinition( obj , numOfTrims )
            mdl = getSelectedSimModel( obj );
            if isempty(mdl)
                error('A Simulink Model must be avaliable');
            end
            
            load_system(mdl);
            inH  = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Inport' );
            [ ~ , inNames ] = cellfun( @fileparts , inH , 'UniformOutput' , false );

            outH = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Outport' );
            [ ~ , outNames ] = cellfun( @fileparts , outH , 'UniformOutput' , false );

            [~,~,x0]=eval([mdl '([],[],[],0)']);
            [ ~ , stateNames ] = cellfun( @fileparts , x0 , 'UniformOutput' , false );

            stateDerivNames = cellfun(@(x) [x,'dot'],stateNames,'UniformOutput',false);
            
            inputConditions = lacm.Condition.empty;
            for i = 1:length(inNames)
                inputConditions(i)      = lacm.Condition( inNames{i}, 0 , [] , true );
            end
            outputConditions = lacm.Condition.empty;
            for i = 1:length(outNames)
                outputConditions(i)     = lacm.Condition( outNames{i}, 0 , [] , false );
            end  
            stateConditions = lacm.Condition.empty;
            for i = 1:length(stateNames)
                stateConditions(i)      = lacm.Condition( stateNames{i}, 0 , [] , true );
            end
            stateDerivConditions = lacm.Condition.empty;
            for i = 1:length(stateDerivNames)
                stateDerivConditions(i) = lacm.Condition( stateDerivNames{i}, 0 , [] , false );
            end  
            
            if numOfTrims == 1
                trimSettings = lacm.TrimSettings();
                trimSettings.StateDerivatives = stateDerivConditions;
                trimSettings.Outputs          = outputConditions;
                trimSettings.States           = stateConditions;
                trimSettings.Inputs           = inputConditions;
            elseif numOfTrims == 2
                secondTrimSettings = lacm.TrimSettings();
                secondTrimSettings.StateDerivatives = stateDerivConditions;
                secondTrimSettings.Outputs          = outputConditions;
                secondTrimSettings.States           = stateConditions;
                secondTrimSettings.Inputs           = inputConditions; 
                
                trimSettings = lacm.TrimSettings();
                trimSettings.StateDerivatives = copy(stateDerivConditions);
                trimSettings.Outputs          = copy(outputConditions);
                trimSettings.States           = copy(stateConditions);
                trimSettings.Inputs           = copy(inputConditions);
                trimSettings.InitialTrim = secondTrimSettings;
            end
            
        end % createDefaultTrimDefinition
        
    end
    
    %% Methods - Create Object Callbacks
    methods    
        function createNewTrimDef_CB( obj , ~ , ~ )
            notify(obj,'NewTrimDef');
        end % createNewTrimDef_CB
        
        function createNewLinMdlDef_CB( obj , ~ , ~ )
            notify(obj,'NewLinMdlDef');
        end % createNewLinMdlDef_CB
        
        function createNewReqDef_CB( obj , ~ , ~ )
            notify(obj,'NewReqDef');
        end % createNewReqDef_CB
        
        function createNewSimReqDef_CB( obj , ~ , ~ )
            notify(obj,'NewSimReqDef');
        end % createNewSimReqDef_CB
        
        function createNewPostSimReqDef_CB( obj , ~ , ~ )
            notify(obj,'NewPostSimReqDef');
        end % createNewPostSimReqDef_CB
        
    end
    
    %% Methods - Open Object Callbacks
    methods 
        function openTrimDef_CB( obj , ~ , ~ , node)
            reqDefObj = node.handle.UserData;
            updateMdlConditions( reqDefObj , reqDefObj.SimulinkModelName )
            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.trimObjEdited(src,event,node));
            
            
%             trimDefObj = node.handle.UserData;
%             f=figure;
%             trimEditObj = UserInterface.ObjectEditor.TrimEditor('Parent',f);
%             loadExisting(trimEditObj, trimDefObj, trimDefObj.FileName);
            
          

        end
        
        function saveTrimDef_CB( ~ , ~ , ~ , node)
            filename = char(node.getName);
            trimDefObj = node.handle.UserData; %#ok<NASGU>
            uisave('trimDefObj',filename);
        end % saveTrimDef_CB
        
        function openLMDef_CB( obj , ~ , ~ , node)
            reqDefObj = node.handle.UserData;
            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.linMdlObjEdited(src,event,node));
            
%             lmDefObj = node.handle.UserData;
%             f=figure;
%             lmEditObj = UserInterface.ObjectEditor.LinMdlEditor('Parent',f);
%             loadExisting(lmEditObj, lmDefObj , lmDefObj.FileName );
        end % openLMDef_CB
        
        function openReqDef_CB( obj , ~ , ~ , node)

            setWaitPtr(obj);
            
            reqDefObj = node.handle.UserData;
            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.reqObjEdited(src,event,node));
        
            releaseWaitPtr(obj);       
        end % openReqDef_CB
        
        function openAnalysis_CB( obj , ~ , ~ , node)

            setWaitPtr(obj);
            
            reqDefObj = node.handle.UserData;
            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.anlaysisObjEdited(src,event,node));
        
            releaseWaitPtr(obj);       
        end % openAnalysis_CB
        
        function saveAnalysisNodeAsMatFile_CB( obj , ~ , ~ , node)

            parentNode=node.getParent;
            index = parentNode.getIndex(node);
            
            reqDefObj = node.handle.UserData;
            notify(obj,'AnalysisObjectSaved',UserInterface.UserInterfaceEventData({reqDefObj,index}));
                   
        end % saveAnalysisNodeAsMatFile_CB
        
    end
    
    %% Methods - Open Object Event Callbacks
    methods 
        function trimObjEdited( obj , ~ , eventdata , node )
      
            node.handle.UserData = eventdata.Object;
            node.setName(eventdata.Object.Label); 
            obj.JTree.repaint;
            if strcmp(char(node.getValue),'selected')
                fireSelectedObjectChangedEvent( obj , node );
            end
            notify(obj,'SaveProjectEvent');   
        end % trimObjEdited  
        
        function linMdlObjEdited( obj , ~ , eventdata , node )
      
            node.handle.UserData = eventdata.Object;
            node.setName(eventdata.Object.Label); 
            
            removeAllChildNodes( obj , node );
            
            updateLinearMdlNodes( obj , eventdata.Object , node )
      
            
            
            
            obj.JTree.repaint;
            notify(obj,'SaveProjectEvent');   
        end % linMdlObjEdited  
        
        function reqObjEdited( obj , ~ , eventdata , node )
      
            node.handle.UserData = eventdata.Object;
            node.setName(eventdata.Object.Title); 
            
            removeAllChildNodes( obj , node );
            updateReqNodes( obj , eventdata.Object , node  ) ;

            obj.JTree.repaint;
            notify(obj,'SaveProjectEvent');   
        end % reqObjEdited  
        
        function anlaysisObjEdited( obj , ~ , eventdata , node )
      
            node.handle.UserData = eventdata.Object;
            node.setName(eventdata.Object.Title); 
            
            removeAllChildNodes( obj , node );
            updateAnalysisNode( obj , node );
            
            obj.JTree.repaint;
            
            parentNode=node.getParent;
            index = parentNode.getIndex(node);
            notify(obj,'AnalysisObjectEdited',UserInterface.UserInterfaceEventData({eventdata.Object,index}));
            
            
            notify(obj,'SaveProjectEvent');   
        end % anlaysisObjEdited  

    end
    
    %% Methods - Edit Methods Callbacks
    methods 
        
        function editReqMeth_CB( ~ , ~ , ~ , node)
            reqDefObj = node.handle.UserData;
            FunName   = reqDefObj.FunName;
            if ~isempty(FunName)
                if exist(FunName,'file') == 2
                    edit(FunName);
                else
                    errordlg(['Method function ' FunName 'does not exist on Matlab path.']);
                end
            else
                errordlg(['Method function is not defined.']);
            end
        end  % editReqMeth_CB
        
        function editReqPlot_CB( ~ , ~ , ~ , node)
            reqDefObj = node.handle.UserData;
            FunName   = reqDefObj.RequiermentPlot;
            if ~isempty(FunName)
                if exist(FunName,'file') == 2
                    edit(FunName);
                else
                    errordlg(['Requirement plot function ' FunName 'does not exist on Matlab path.']);
                end
            else
                errordlg(['Requirement plot function is not defined.']);
            end
        end % editReqPlot_CB
        
        function editBGPlot_CB( ~ , ~ , ~ , node)
            reqDefObj = node.handle.UserData;
            FunName   = reqDefObj.BackgroundPlotFunc;
            if ~isempty(FunName)
                if exist(FunName,'file') == 2
                    edit(FunName);
                else
                    errordlg(['Background plot function  ' FunName 'does not exist on Matlab path.']);
                end
            else
                errordlg(['Background plot function is not defined.']);
            end
        end % editBGPlot_CB
    end
    
    %% Methods - Callbacks
    methods 
        
        function massPropClosed( obj , ~ , ~ )
            try
                obj.MassPropGUIObj = UserInterface.StabilityControl.MassPropGUI.empty;
            end
        end % massPropClosed
        
    end
    
    %% Methods - Private
    methods (Access = private)

        function fig = getDialogParent(obj)
            fig = obj.DialogParent;
            if isempty(fig) || ~isvalid(fig)
                fig = Utilities.getParentFigure(obj);
            end
        end % getDialogParent

        function text = formatDialogMessage(~, message)
            text = Utilities.formatDialogMessage(message);
        end % formatDialogMessage

        function showAlert(obj, message, title, varargin)
            fig = obj.getDialogParent();
            if isempty(fig) || ~isvalid(fig)
                return;
            end
            text = obj.formatDialogMessage(message);
            uialert(fig, text, title, varargin{:});
        end % showAlert

        function choice = confirmDialog(obj, message, title, options, defaultOption, cancelOption)
            fig = obj.getDialogParent();
            if isempty(fig) || ~isvalid(fig)
                choice = '';
                return;
            end
            text = obj.formatDialogMessage(message);
            args = {'Options', options};
            if nargin >= 5 && ~isempty(defaultOption)
                args = [args, {'DefaultOption', defaultOption}];
            end
            if nargin >= 6 && ~isempty(cancelOption)
                args = [args, {'CancelOption', cancelOption}];
            elseif any(strcmp(options,'Cancel'))
                args = [args, {'CancelOption','Cancel'}];
            end
            choice = uiconfirm(fig, text, title, args{:});
        end % confirmDialog

        function fireSelectedObjectChangedEvent( obj , node )
            if any(strcmp({'Mass Properties'},{char(node.getName),char(node.getParent.getName)}))

                if ~isempty(obj.MassPropGUIObj) %isa(obj.MassPropGUIObj,'UserInterface.StabilityControl.MassPropGUI')
                    [~,selLA] = getSelectedMassPropObjs( obj ); 
                    obj.MassPropGUIObj.updateSelected(selLA);
                end
                obj.JTree.repaint;
                notify(obj,'SelectedPropChanged',UserInterface.UserInterfaceEventData(getSelectedMassPropObjs(obj)));
            end
        end % fireSelectedObjectChangedEvent
        
    end
    
    %% Methods - Static    
    methods (Static)
        

        
    end 
    
    %% Methods - Private    
    methods (Access = private)
        
        function insertLinearModelObj_Private( obj , parentNode , newObj)
            index = length(newObj);

            node  = uitreenode(...
                'v0','selected', newObj(index).Label, [], 0); % obj.Label
            node.setIcon(obj.JavaImage_checked); 
            node.setUserObject('JavaImage_checked');
            node.UserData = newObj(index);


            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());
            
                        
            parentNode.setIcon(obj.JavaImage_checked); 
            parentNode.setUserObject('JavaImage_checked');

            updateLinearMdlNodes( obj , newObj(index) , node );
        end % insertLinearModelObj_Private  
        
        function updateLinearMdlNodes( obj , newObj , node )
            
            statesNode  = uitreenode(...
                            'v0','', 'States', [], 0);
            obj.TreeModel.insertNodeInto(...
                statesNode,...
                node,...
                node.getChildCount());             
            for mm = 1:length(newObj.States)
                newNode  = uitreenode(...
                                'v0','', newObj.States{mm}, [], 0); 
                obj.TreeModel.insertNodeInto(...
                    newNode,...
                    statesNode,...
                    statesNode.getChildCount()); 
            end
            inputsNode  = uitreenode(...
                            'v0','', 'Inputs', [], 0);
            obj.TreeModel.insertNodeInto(...
                inputsNode,...
                node,...
                node.getChildCount());          
            for mm = 1:length(newObj.Inputs)
                newNode  = uitreenode(...
                                'v0','', newObj.Inputs{mm}, [], 0);
                obj.TreeModel.insertNodeInto(...
                    newNode,...
                    inputsNode,...
                    inputsNode.getChildCount());
            end
            outputsnode  = uitreenode(...
                            'v0','', 'Outputs', [], 0);
            obj.TreeModel.insertNodeInto(...
                outputsnode,...
                node,...
                node.getChildCount());           
            for mm = 1:length(newObj.Outputs)
                newNode  = uitreenode(...
                                'v0','', newObj.Outputs{mm}, [], 0);
                obj.TreeModel.insertNodeInto(...
                    newNode,...
                    outputsnode,...
                    outputsnode.getChildCount());
            end
            algInNode  = uitreenode(...
                            'v0','', 'AlgebraicInput', [], 0);
            obj.TreeModel.insertNodeInto(...
                algInNode,...
                node,...
                node.getChildCount());           
            for mm = 1:length(newObj.AlgebraicInput)
                newNode  = uitreenode(...
                                'v0','', newObj.AlgebraicInput{mm}, [], 0);
                obj.TreeModel.insertNodeInto(...
                    newNode,...
                    algInNode,...
                    algInNode.getChildCount());
            end
            algOutNode  = uitreenode(...
                            'v0','', 'AlgebraicOutput', [], 0);
            obj.TreeModel.insertNodeInto(...
                algOutNode,...
                node,...
                node.getChildCount());       
            for mm = 1:length(newObj.AlgebraicOutput)
                newNode  = uitreenode(...
                                'v0','', newObj.AlgebraicOutput{mm}, [], 0);
                obj.TreeModel.insertNodeInto(...
                    newNode,...
                    algOutNode,...
                    algOutNode.getChildCount());
            end  
        end
        
        function insertTrimObj_Private( obj , parentNode , newObj)

                index = length(newObj);

                node  = uitreenode(...
                    'v0','selected', newObj(index).Label, [], 0);
                % Ensure trim nodes display as checkboxes by default
                node.setUserObject('JavaImage_checked');
                node.setIcon(obj.JavaImage_checked);
                obj.TreeModel.insertNodeInto(...
                    node,...
                    parentNode,...
                    parentNode.getChildCount());
                node.UserData = newObj(index);

                % Insert Model Name

%                 newMdlName = getModelCompiledStateName(newObj(index).SimulinkModelName);
                newMdlName = newObj(index).SimulinkModelName;
                
                mdlNode  = uitreenode(...
                    'v0','', newMdlName, [], 0);
                mdlNode.setUserObject('JavaImage_model');
                obj.TreeModel.insertNodeInto(...
                    mdlNode,...
                    node,...
                    node.getChildCount());
                mdlNode.setIcon(obj.JavaImage_model); 
                mdlNode.setValue('Model');
                mdlNode.UserData = newObj(index).SimulinkModelName;

        end % insertTrimObj_Private

        function syncTrimDefinitionGeneralNode(obj, trimNode, isSelected)
            % Keep the "General" trim definition child in sync with the parent node
            if nargin < 3 || ~strcmp(char(trimNode.getName), 'Trim Definition')
                return;
            end

            generalNode = [];
            childCount = trimNode.getChildCount();
            stateChanged = false;

            for idx = 0:(childCount-1)
                childNode = trimNode.getChildAt(idx);
                childName = char(childNode.getName);
                if strcmp(childName, 'General')
                    generalNode = childNode;
                elseif strcmp(char(childNode.getValue), 'selected')
                    childNode.setValue('unselected');
                    childNode.setIcon(obj.JavaImage_unchecked);
                    stateChanged = true;
                end
            end

            if isempty(generalNode)
                if stateChanged
                    obj.JTree.treeDidChange();
                end
                return;
            end

            childWasSelected = strcmp(char(generalNode.getValue), 'selected');

            if isSelected && ~childWasSelected
                generalNode.setValue('selected');
                generalNode.setIcon(obj.JavaImage_checked);
                stateChanged = true;
            elseif ~isSelected && childWasSelected
                generalNode.setValue('unselected');
                generalNode.setIcon(obj.JavaImage_unchecked);
                stateChanged = true;
            end

            if stateChanged
                obj.JTree.treeDidChange();
            end

            if childWasSelected ~= isSelected
                notify(obj,'UseExistingTrim',GeneralEventData(isSelected));
            end
        end % syncTrimDefinitionGeneralNode
        
        function insertReqObj_Private( obj , parentNode , reqObj)
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             icon_dir = fullfile( this_dir,'..','..','Resources' );             
%             methIconPath = fullfile(icon_dir,'new_script_ts_16.png');
%             im = imread(methIconPath,'BackgroundColor',[1,1,1]);
%             methIcon = im2java(im); 
%             
%             plotIconPath = fullfile(icon_dir,'Figure_16.png');
%             im = imread(plotIconPath,'BackgroundColor',[1,1,1]);
%             plotIcon = im2java(im); 
            
            % get the index
            index = length(reqObj);

            % Set Parent node to selected by default
            if parentNode.getChildCount() == 0 && ~strcmp(parentNode.getUserObject(),'JavaImage_folderopen') && ~strcmp(parentNode.getName(),'Synthesis') && ~strcmp(parentNode.getName(),'Root Locus')
                parentNode.setValue('selected');
                parentNode.setIcon(obj.JavaImage_checked); 
                parentNode.setUserObject('JavaImage_checked');
            end

            node  = uitreenode(...
                'v0','selected', reqObj(index).Title, [], 0);
            node.setUserObject('JavaImage_checked');
            obj.TreeModel.insertNodeInto(...
                node,...
                parentNode,...
                parentNode.getChildCount());
            % set requirement to selected by default
            node.setIcon(obj.JavaImage_checked); 
            node.setValue('selected');
            
            parentNode.setIcon(obj.JavaImage_checked); 
            parentNode.setValue('');
            if isa(reqObj,'Requirements.RootLocus')
                node.setIcon(obj.JavaImage_unchecked); 
                node.setValue('unselected');
                node.setUserObject('JavaImage_unchecked');
            end
            
            updateReqNodes( obj , reqObj(index) , node );

            reqObj(index).SelectedStatus = 'selected';
            node.UserData = reqObj(index);        
           
        end % insertReqObj_Private     
        
        function updateReqNodes( obj , reqObj , node ) 
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             icon_dir = fullfile( this_dir,'..','..','Resources' );             
%             methIconPath = fullfile(icon_dir,'new_script_ts_16.png');
%             im = imread(methIconPath,'BackgroundColor',[1,1,1]);
%             methIcon = im2java(im); 
%             
%             plotIconPath = fullfile(icon_dir,'Figure_16.png');
%             im = imread(plotIconPath,'BackgroundColor',[1,1,1]);
%             plotIcon = im2java(im); 
            
            
            if ~isempty(reqObj.MdlName)
                % Add model node if one exists
                modelNode  = uitreenode(...
                    'v0','', reqObj.MdlName, [], 0);
                modelNode.setUserObject('JavaImage_model');
                obj.TreeModel.insertNodeInto(...
                    modelNode,...
                    node,...
                    node.getChildCount());
                % set requirement to selected by default
                modelNode.setIcon(obj.JavaImage_model); 
                modelNode.setValue('Model');
            end
            if ~isempty(reqObj.FunName)            

                % Add method node if one exists
                methodNode  = uitreenode(...
                    'v0','', reqObj.FunName , [], 0);
                methodNode.setUserObject('JavaImage_method');
                obj.TreeModel.insertNodeInto(...
                    methodNode,...
                    node,...
                    node.getChildCount());
                % set requirement to selected by default
                methodNode.setIcon(obj.JavaImage_method); 
                methodNode.setValue('Method');
            end
            if isprop(reqObj,'PostFunName')&& ~isempty(reqObj.PostFunName)            

                % Add method node if one exists
                methodNode  = uitreenode(...
                    'v0','', reqObj.PostFunName , [], 0);
                methodNode.setUserObject('JavaImage_method');
                obj.TreeModel.insertNodeInto(...
                    methodNode,...
                    node,...
                    node.getChildCount());
                % set requirement to selected by default
                methodNode.setIcon(obj.JavaImage_method); 
                methodNode.setValue('Method');
            end
            if (isa(reqObj,'Requirements.RequirementTypeOne') && ~isempty(reqObj.RequiermentPlot)) ||  (isa(reqObj,'Requirements.RootLocus') && ~isempty(reqObj.RequiermentPlot))         

                % Add reqPlot node if one exists
                plotNode  = uitreenode(...
                    'v0','', reqObj.RequiermentPlot , [], 0);
                plotNode.setUserObject('JavaImage_plot');
                obj.TreeModel.insertNodeInto(...
                    plotNode,...
                    node,...
                    node.getChildCount());
                % set requirement to selected by default
                plotNode.setIcon(obj.JavaImage_plot); 
                plotNode.setValue('RequiermentPlot');
            end
            if strcmp(node.getParent.getName(),'Synthesis') && ~isa(reqObj,'Requirements.RootLocus')
                % insert New Scatt Gain File
                %gainScattCollName = insertNewScatteredGainObj_CB( obj , [] , [] , node );
                insertNewScatteredGainObj_CB( obj , [] , [] , node );
                % Set to selected by default
                node.setIcon(obj.JavaImage_checked); 
                node.setValue('selected');
                obj.GainSource = 1;
                % select the new scatt Gain File
                %selectScatteredGainFile2Write( obj , [] , [] , node , gainScattCollName );
            end

        end % updateReqNodes
        
        
    end
    
    %% Method - Delete
    methods
        
        function delete(obj)

            try 
                warnStruct = warning;
                warning('off');  
                e = obj.TreeModel.getRoot.depthFirstEnumeration();
                while (e.hasMoreElements()) 
                    node = e.nextElement();
                    if ~ischar(node.handle.UserData)
                        delete(node.handle.UserData);
                    end
                end
                warning(warnStruct);
            end
            
        end % delete
        
%         function deleteUserData(obj)
%             try %#ok<*TRYNC>  - Mass Properties
%                 childNodes = findDirectChildrenInNode(obj.MassPropNode);
%                 for i = 1:length(childNodes)
%                     if ~isempty(childNodes{i}.handle.UserData)
%                         delete(childNodes{i}.handle.UserData);
%                     end
%                 end  
%             end
%             try %#ok<*TRYNC> - Drim Definitions
%                 childNodes = findDirectChildrenInNode(obj.TrimDefNode);
%                 for i = 1:length(childNodes)
%                     if ~isempty(childNodes{i}.handle.UserData)
%                         delete(childNodes{i}.handle.UserData);
%                     end
%                 end 
%             end
%             try %#ok<*TRYNC> - Linear Model Definitions
%                 childNodes = findDirectChildrenInNode(obj.LinMdlDefNode);
%                 for i = 1:length(childNodes)
%                     if ~isempty(childNodes{i}.handle.UserData)
%                         delete(childNodes{i}.handle.UserData);
%                     end
%                 end 
%             end
%             try %#ok<*TRYNC> - Method Nodes
%                 childNodes = findDirectChildrenInNode(obj.MethodNode);
%                 for i = 1:length(childNodes)
%                     if ~isempty(childNodes{i}.handle.UserData)
%                         delete(childNodes{i}.handle.UserData);
%                     end
%                 end 
%             end
% 
%       
%         end % delete
        
    end 
    
end

function newMdlName = getModelCompiledStateName(mdlname)

    if ~bdIsLoaded(mdlname) 
        load_system(mdlname);
    end
    simState = get_param(mdlname, 'SimulationStatus');

    if strcmp(simState,'paused')
        newMdlName = ['<html><font color="red">&nbsp;',char(mdlname),'</html>'];
    else
        newMdlName = ['<html><font color="black">&nbsp;',char(mdlname),'</html>'];
    end

end % getModelCompiledStateName

function y = getUUID()
    temp =  java.util.UUID.randomUUID;
    y = char(temp.toString);
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

function childNodes = findAllChildrenInNode(root)
    e = root.depthFirstEnumeration();
    %childNodes = uitreenode('v0',[], [], [], 0);
    %childNodes = com.mathworks.hg.peer.UITreeNode([],[],[],0);
    %childNodes =javahandle.com.mathworks.hg.peer.UITreeNode([],[],[],0);
    childNodes = {};
    while (e.hasMoreElements()) 
        node = e.nextElement();
        if ~node.toString().equalsIgnoreCase(root.toString())
            childNodes{end+1} = node; %#ok<AGROW>
            node.handle.UserData
        end
    end
%     childNodes(1) = [];
end % findAllChildrenInNode

function childNodes = findDirectChildrenInNode(root)
    if isempty(root); childNodes = {}; return; end;
    childNodes = cell(1,length(root.getChildCount));
    for i = 0:root.getChildCount - 1
        childNodes{i+1} = root.getChildAt(i);
    end

end % findDirectChildrenInNode

