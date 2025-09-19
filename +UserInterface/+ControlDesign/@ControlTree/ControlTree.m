classdef ControlTree < handle
    
    %% Public properties - Data Storage
    properties 
       
    end % Public properties
     
    %% Public properties - Object Handles
    properties (Transient = true)
        TreeObj

        GainsNode
        GainsScheduled
        GainsScattered
        GainsSynthesis
        RootLocusNode
        ReqNode
        StabilityReqNode
        FreqNode
        SimNode
        HQNode
        ASENode
        OperCondNode
        TreeContextMenu
        LastContextNode
    end % Public properties
  
    %% Private properties - Data Storage
    properties (Access = private)  
        OperCondBrowseStartDir = mfilename('fullpath')
        ReqObjBrowseStartDir = mfilename('fullpath')
        ScattStartDir = mfilename('fullpath')
        SchStartDir = mfilename('fullpath')
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)
       SelectedScatteredGainFileObj 
%        LoadedScattGainObj
%        LoadedSchGainObj
    end
    
    %% Properties - Observable
    properties(SetObservable , AbortSet)
       GainSource = 1 % 1=Synthesis, 2=Schedule, 3=ScatteredFile, 4=RootLocus, 5=model 
    end
    
    %% Constant properties
    properties (Constant) 
        ScattGainIcon = 'fit_app_16.png'

    end % Constant properties      
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        ParentFigure
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent=true, SetAccess=public, GetAccess=public)
        Enable
    end % Dependant properties
    
    %% Events
    events
        OperCondAdded
        OperCondRemoved
        ReqObjAdded
        ReqObjRemoved
        AddAxisHandle2Q
        ReqObjUpdated
        SetPointer
%         ScatteredGainObjReplaced
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        
        ScatteredGainFileAdded
        ScheduleGainCollectionAdded
        
        ScatteredGainFileObj4Save
        ScatteredGainFileExported
        ScatteredGainFileCleared
    end
    
    %% Methods - Constructor
    methods      
        function obj = ControlTree(varargin)
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = false;
            
            % Define defaults and requirements for each parameter
            p.addParamValue('Parent',[]); %#ok<*NVREPL>
            p.addParamValue('Restore',[]);
            p.parse(varargin{:});
             
            % Which parameters are not at defaults and need setting?
            Params = rmfield(p.Results, p.UsingDefaults);   
             
            % Create new or restore
            if ~isfield(Params,'Restore') || isempty(Params.Restore)
                create(obj,Params);
            else
                restore(obj,Params);
            end
     
        end % tree
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function y = get.ParentFigure( obj )
            y = ancestor(obj.TreeObj,'Figure','toplevel');
        end % ParentFigure
        
        % Enable
        function value = get.Enable(obj)
            value = obj.TreeObj.Enable;
        end
        
        function set.Enable(obj,value)
            if ischar(value)
                value = strcmp(value,'on');
            end
            validateattributes(value,{'numeric','logical'},{'scalar'});
            value = logical(value);
            obj.TreeObj.Enable = value;
        end % Enable
        
    end % Property access methods
    
    %% Methods - Create
    methods
        
        function create( obj , Params )
            
            % Ensure there is a valid parent
            if ~isfield(Params,'Parent') || isempty(Params.Parent)
                parent = figure;
            else
                parent = Params.Parent;
                Params = rmfield(Params,'Parent');
            end
            

            % Use MATLAB's native uitree rather than the legacy Java-based
            % control.  The SelectionChangedFcn is used in place of the
            % MouseClickedCallback from the previous implementation.
            obj.TreeObj = uitree(parent,'checkbox');
            obj.TreeObj.SelectionChangedFcn = @(src,event) obj.mousePressedInTree_CB(src,event);
            obj.TreeObj.CheckedNodesChangedFcn = @(src,event) obj.mousePressedInTree_CB(src,event);
            obj.LastContextNode = [];
            obj.configureTreeContextMenu();
            
            % Create tree nodes
            obj.OperCondNode = uitreenode(obj.TreeObj,'Text','Operating Condition',...
                'NodeData',1);

            obj.GainsNode = uitreenode(obj.TreeObj,'Text','Gain Source',...
                'NodeData',1000);
                obj.GainsSynthesis = uitreenode(obj.GainsNode,'Text','Synthesis',...
                    'NodeData',2);
                obj.GainsScattered = uitreenode(obj.GainsNode,'Text','Scattered',...
                    'NodeData',3);
                obj.GainsScheduled = uitreenode(obj.GainsNode,'Text','Scheduled',...
                    'NodeData',4);
                obj.RootLocusNode = uitreenode(obj.GainsNode,'Text','Root Locus',...
                    'NodeData',5);

            obj.ReqNode = uitreenode(obj.TreeObj,'Text','Requirements',...
                'NodeData',2000);
                obj.StabilityReqNode = uitreenode(obj.ReqNode,'Text','Stability',...
                    'NodeData',6);
                obj.FreqNode = uitreenode(obj.ReqNode,'Text','FrequencyResponse',...
                    'NodeData',7);
                obj.SimNode = uitreenode(obj.ReqNode,'Text','Simulation',...
                    'NodeData',8);
                obj.HQNode = uitreenode(obj.ReqNode,'Text','HandlingQualities',...
                    'NodeData',9);
                obj.ASENode = uitreenode(obj.ReqNode,'Text','Aeroservoelasticity',...
                    'NodeData',10);
        end % create  
        
        function restore( obj , Params )
            % Ensure there is a valid parent
            if ~isfield(Params,'Parent') || isempty(Params.Parent)
                parent = figure;
            else
                parent = Params.Parent;
                Params = rmfield(Params,'Parent');
            end

            obj.TreeObj = uitree(parent,'checkbox');
            obj.TreeObj.SelectionChangedFcn = @(src,event) obj.mousePressedInTree_CB(src,event);
            obj.TreeObj.CheckedNodesChangedFcn = @(src,event) obj.mousePressedInTree_CB(src,event);
            obj.LastContextNode = [];
            obj.configureTreeContextMenu();

            nodeData = Params.Restore.NodeData;

            TreeNodes = matlab.ui.container.TreeNode.empty;

            for i = 2:length(nodeData)

                % Remove brackets from end of string
                str = nodeData(i).TreePath(2:end-1);
                % Split into a cell array of strings
                cellStr = strsplit(str,',');
                % Remove leading and trailing blanks
                cellStr = strtrim(cellStr);

                if length(cellStr) == 2
                    parentNode = obj.TreeObj;
                    TreeNodes = matlab.ui.container.TreeNode.empty;
                elseif length(cellStr) - 1 == length(TreeNodes)
                    TreeNodes = TreeNodes(1:end-1);
                    parentNode = TreeNodes(end);
                elseif length(cellStr) - 1 > length(TreeNodes)
                    parentNode = TreeNodes(end);
                elseif length(cellStr) - 1 < length(TreeNodes)
                    num2keep = length(cellStr) - 2;
                    TreeNodes = TreeNodes(1:num2keep);
                    parentNode = TreeNodes(end);
                else
                    error('UserInterface:ControlTree:RestoreTree','Unable to restore control tree');
                end

                node = uitreenode(parentNode,'Text',nodeData(i).Name,...
                        'Tooltip',nodeData(i).TooltipString,...
                        'Enable',matlab.lang.OnOffSwitchState(nodeData(i).CheckboxEnabled),...
                        'NodeData',nodeData(i).Value,...
                        'UserData',nodeData(i).UserData);
                obj.setNodeChecked(node,logical(nodeData(i).Checked));
                setNodeProperty( obj , node );

                TreeNodes(end + 1) = node;
            end

            % Restore Expansion State if available
            if isfield(Params.Restore,'ExpState')
                expand(obj.TreeObj,Params.Restore.ExpState);
            end

        end % restore
        
        function setNodeProperty( obj , node )
                      
            
            switch node.Value
                case 1000
                    obj.GainsNode = node;
                case 2000
                    obj.ReqNode = node;
                case 1
                    obj.OperCondNode = node;
                case 2
                    obj.GainsSynthesis = node;
                case 3
                    obj.GainsScattered = node;
                case 4
                    obj.GainsScheduled = node;
                case 5
                    obj.RootLocusNode = node;
                case 6
                    obj.StabilityReqNode = node;
                case 7
                    obj.FreqNode = node;
                case 8
                    obj.SimNode = node;
                case 9
                    obj.HQNode = node;
                case 10
                    obj.ASENode = node;       
            end  
        end % setNodeProperty
        
    end
      
    %% Methods - Ordinary
    methods
 
        function setStartDirectories( obj , path )
            obj.OperCondBrowseStartDir = path;
            obj.ReqObjBrowseStartDir = path;
            obj.ScattStartDir = path;
            obj.SchStartDir = path;      
        end % setStartDirectories
        
        function rObjs = getSelectedSynthesisObjs( obj )
            
            if ~isempty(obj.GainsSynthesis.Children)
                logArray = obj.areNodesChecked(obj.GainsSynthesis.Children);
                rObjs = [obj.GainsSynthesis.Children(logArray).UserData];
            else
               rObjs = Requirements.Synthesis.empty;
            end
          
        end % getSelectedSynthesisObjs
        
        function rObjs = getSelectedRLocusObjs( obj )
            
            if ~isempty(obj.RootLocusNode.Children)
                logArray = obj.areNodesChecked(obj.RootLocusNode.Children);
                rObjs = [obj.RootLocusNode.Children(logArray).UserData];
            else
               rObjs = Requirements.RootLocus.empty;
            end
            
        end % getSelectedRLocusObjs 
        
        function rObjs = getAllRLocusObjs( obj )
            
            if ~isempty(obj.RootLocusNode.Children)
                rObjs = [obj.RootLocusNode.Children.UserData];
            else
               rObjs = Requirements.RootLocus.empty; 
            end
            
        end % getAllRLocusObjs 
        
        function rObjs = getAllSynthesisObjs(obj)
            
            if ~isempty(obj.GainsSynthesis.Children)
                rObjs = [obj.GainsSynthesis.Children.UserData];
            else
               rObjs = Requirements.Synthesis.empty; 
            end
            
        end % getAllSynthesisObjs
        
        function rObjs = getSelectedReqObjs( obj , type )
            
            if ~isempty(obj.(type).Children)
                children = obj.(type).Children;
                logArray = obj.areNodesChecked(children);
                rObjs = [children(logArray).UserData];
            else
                switch type
                    case {'StabilityReqNode'}
                        rObjs = Requirements.Stability.empty;
                    case {'FreqNode'}
                        rObjs = Requirements.FrequencyResponse.empty; 
                    case {'SimNode'}
                        rObjs = Requirements.SimulationCollection.empty; 
                    case {'HQNode'}
                        rObjs = Requirements.HandlingQualities.empty; 
                    case {'ASENode'}
                        rObjs = Requirements.Aeroservoelasticity.empty; 
                end
            end
            
        end % getSelectedReqObjs
        
        function y = reqObjisSelected( obj , type )
            
            if ~isempty(obj.(type).Children)
                y = obj.areNodesChecked(obj.(type).Children);
            else
                y = [];
            end
            
        end % reqObjisSelected
        
        function rObjs = getAllReqObjs( obj , type )
            
            if ~isempty(obj.(type).Children)
                rObjs = [obj.(type).Children.UserData];
            else
                switch type
                    case {'StabilityReqNode'}
                        rObjs = Requirements.Stability.empty; 
                    case {'FreqNode'}
                        rObjs = Requirements.FrequencyResponse.empty; 
                    case {'SimNode'}
                        rObjs = Requirements.SimulationCollection.empty; 
                    case {'HQNode'}
                        rObjs = Requirements.HandlingQualities.empty; 
                    case {'ASENode'}
                        rObjs = Requirements.Aeroservoelasticity.empty; 
                end
            end
            
        end % getAllReqObjs
        
        function rObjs = getSelectedSourceGainObjs(obj)
            
            if ~isempty(obj.GainsScheduled.Children)
                logArray = obj.areNodesChecked(obj.GainsScheduled.Children);
                rObjs = [obj.GainsScheduled.Children(logArray).UserData];
            else
               rObjs = ScheduledGain.SchGainCollection.empty;
            end
            
        end % getSelectedSourceGainObjs
               
        function rObjs = getSelectedScatteredGainObjs(obj)
            
            if ~isempty(obj.GainsScattered.Children)
                logArray = obj.areNodesChecked(obj.GainsScattered.Children);
                rObjs = [obj.GainsScattered.Children(logArray).UserData];
            else
               rObjs = ScatteredGain.GainFile.empty;
            end
            
        end % getSelectedScatteredGainObjs
        
        function rObjs = getAllScatteredGainObjs(obj)
           
            if ~isempty(obj.GainsScattered.Children)
                rObjs = [obj.GainsScattered.Children.UserData];
            else
               rObjs = ScatteredGain.GainFile.empty; 
            end
            
        end % getAllScatteredGainObjs       
                
        function rObjs = getAllScheduledGainObjs(obj)
            
            if ~isempty(obj.GainsScheduled.Children)
                rObjs = [obj.GainsScheduled.Children.UserData];
            else
               rObjs = ScheduledGain.SchGainCollection.empty; 
            end
            
        end % getAllScheduledGainObjs
        
        function setHighlightedGainSchGain( obj , gainName )
            
            
        end % setHighlightedGainSchGain
        
        function [ selGainSource , rlSel ] = getGainSource( obj )
            % Return 
            % selGainSource 0-No source selected 
            %               1-Synthesis Selected 
            %               2-Scattered Selected 
            %               3-Scheduled Selected 
            %
            % rlSel 0-No RootLocus selected
            %       1-One RootLocus selected
%             x = [(obj.GainsSynthesis.Checked || obj.GainsSynthesis.PartiallyChecked) && ~isempty(obj.GainsSynthesis.Children),...
%                 (obj.GainsScattered.Checked || obj.GainsScattered.PartiallyChecked) && ~isempty(obj.GainsScattered.Children),...
%                 (obj.GainsScheduled.Checked || obj.GainsScheduled.PartiallyChecked) && ~isempty(obj.GainsScheduled.Children)];       
            synthesisActive = obj.isNodeChecked(obj.GainsSynthesis) || any(obj.areNodesChecked(obj.GainsSynthesis.Children));
            scatteredActive = obj.isNodeChecked(obj.GainsScattered) || any(obj.areNodesChecked(obj.GainsScattered.Children));
            scheduledActive = obj.isNodeChecked(obj.GainsScheduled) || any(obj.areNodesChecked(obj.GainsScheduled.Children));
            rootLocusActive = obj.isNodeChecked(obj.RootLocusNode) || any(obj.areNodesChecked(obj.RootLocusNode.Children));

            x = [synthesisActive, scatteredActive, scheduledActive, rootLocusActive];
            if any(x)
                selGainSource = find(x);
            else
                selGainSource = 0;
            end
%             rlSel = (obj.RootLocusNode.Checked || obj.RootLocusNode.PartiallyChecked) && ~isempty(obj.RootLocusNode.Children);
            rlSel = rootLocusActive;
        end % getGainSource
        
        function selgainObj = getSelectedScatteredGainFileObj( obj )
            
        end % getSelectedScatteredGainFileObj
        
        function y = sourceGainSelected( obj )
            y = false;
            
            rObjs = getSelectedSynthesisObjs( obj );
            if ~isempty(rObjs)
                y = true;
            end
            rObjs = getSelectedRLocusObjs( obj );
            if ~isempty(rObjs)
                y = true;
            end
            rObjs = getSelectedSourceGainObjs(obj);
            if ~isempty(rObjs)
                y = true;
            end
            rObjs = getSelectedScatteredGainObjs(obj);
            if ~isempty(rObjs)
                y = true;
            end
            
        end % sourceGainSelected
          
    end % Ordinary Methods
    
    %% Methods - Insert Callbacks
    methods

        function addOperCond(obj, ~ , ~ , parentNode )
            [filename, pathname] = uigetfile(...
                {'*.mat'},'File Selector',obj.OperCondBrowseStartDir,'MultiSelect', 'on'); 
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, false);
            obj.OperCondBrowseStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
                operCond = cell(1,length(filename));
                for k = 1:length(filename)
                    operCond{k} = fullfile(pathname,filename{k});
                    node = uitreenode(parentNode,'Text',filename{k},...
                        'NodeData',11);
                    obj.setNodeChecked(node,true);
                end
                
            notify(obj,'OperCondAdded',UserInterface.ControlDesign.ControlTreeEventData(operCond));
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, true);
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            drawnow();
        end % insertMATFile

        function insertFolder_CB( obj , ~ , ~ , parentNode )
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

            node = uitreenode(parentNode,'Text',answer,...
                'NodeData',100);
            obj.setNodeChecked(node,true);
            % Icons are not supported in the same manner with uitree; this
            % call is retained for compatibility if a custom helper exists.
            try
                node.Icon = getIcon('Open_16.png');
            catch
            end
            

        end % insertFolder_CB
        
        function insertReqObj_CB( obj , ~ , ~ , parentNode , path , reqObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, false);
            if isempty(reqObj)
                reqClass = class(reqObj);
                if isempty(path)
                    [filename, pathname] = uigetfile({'*.mat'},['Select Object File (',reqClass,'):'],obj.ReqObjBrowseStartDir,'MultiSelect', 'on');
                else
                    [pathname,name,ext] = fileparts(path) ;
                    filename = [name,ext];
                end
                drawnow();pause(0.1);
                if isequal(filename,0)
                    UserInterface.Utilities.enableDisableFig(obj.ParentFigure, true);
                    return;
                end
                obj.ReqObjBrowseStartDir = pathname;
                if ~iscell(filename)
                    filename = {filename};
                end
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            msgbox({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Type Conflict','error')
                            continue;
                        end
%                         if checkTitle(obj, varStruct.(varNames{i}), reqClass)
%                             msgbox({'The file you are attempting to load contains one',...
%                                 'or more variables with the incorrect format'...
%                                 'The variable ',varNames{i},' will not be loaded.'},...
%                                 'Name Conflict','error')
%                             continue;
%                         end
                        reqObj(end+1) = varStruct.(varNames{i}); 
                        insertReqObj_Private( obj , parentNode , reqObj);

                    end
                end
                
            else
                reqClass = class(reqObj);
                insertReqObj_Private( obj , parentNode , reqObj);
            end

            notify(obj,'ReqObjAdded',UserInterface.ControlDesign.ControlTreeEventData(reqObj));      
            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Completed Adding - ',reqClass, 'objects'],'info'));
            UserInterface.Utilities.enableDisableFig(obj.ParentFigure, true);
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            drawnow();
        end % insertReqObj_CB                         
        
        function openModel_CB( obj , ~ , ~ , node )
            mdlName = node.Name;
            open_system(mdlName);
        end % openModel_CB       
        
        function openMethod_CB( obj , ~ , ~ , node )
            methodName = node.Name;
            open(methodName);
        end % openMethod_CB
        
        function editReq_CB( obj , ~ , ~ , node )

            reqDefObj = node.UserData;
            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.reqObjEdited(src,event,node));

        end % editReq_CB
        
        function reqObjEdited( obj , ~ , eventdata , node )
      
            node.UserData = eventdata.Object;
            node.Name = eventdata.Object.Title; 
            for i = 1:length(node.Children)
                child = node.Children(i);
                type = child.Value;
                switch type
                    case 19
                        child.Name = eventdata.Object.MdlName; 
                    case 20
                        child.Name = eventdata.Object.FunName; 
                    case 30
                        child.Name = eventdata.Object.RequiermentPlot; 
                end   
            end
            % Refresh the tree display
            drawnow();
            notify(obj,'ReqObjUpdated');   
        end % reqObjEdited
        
    end
    
    %% Methods - Private    
    methods (Access = private)

        function configureTreeContextMenu(obj)

            if isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                return;
            end

            if ~isempty(obj.TreeContextMenu) && isvalid(obj.TreeContextMenu)
                delete(obj.TreeContextMenu);
                obj.TreeContextMenu = [];
            end

            parentFig = obj.ParentFigure;
            if isempty(parentFig) || ~isvalid(parentFig)
                parentFig = ancestor(obj.TreeObj,'figure');
            end

            if isempty(parentFig) || ~isvalid(parentFig)
                obj.TreeContextMenu = [];
                obj.TreeObj.ContextMenu = [];
                return;
            end

            obj.TreeContextMenu = uicontextmenu(parentFig,...
                'ContextMenuOpeningFcn',@(src,event) obj.onTreeContextMenuOpening(src,event));
            obj.TreeContextMenu.Visible = 'off';
            obj.TreeObj.ContextMenu = obj.TreeContextMenu;
        end

        function onTreeContextMenuOpening(obj, menu, ~)

            if isempty(menu) || ~isvalid(menu)
                return;
            end

            if isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                delete(menu.Children);
                menu.Visible = 'off';
                return;
            end

            node = [];
            if ~isempty(obj.LastContextNode) && isvalid(obj.LastContextNode)
                node = obj.LastContextNode;
            end

            if isempty(node) || ~isvalid(node)
                if isprop(obj.TreeObj,'SelectedNodes') && ~isempty(obj.TreeObj.SelectedNodes)
                    node = obj.TreeObj.SelectedNodes(1);
                elseif isprop(obj.TreeObj,'CurrentNode') && ~isempty(obj.TreeObj.CurrentNode)
                    node = obj.TreeObj.CurrentNode;
                end
            end

            if isempty(node) || ~isvalid(node)
                obj.LastContextNode = [];
                delete(menu.Children);
                menu.Visible = 'off';
                return;
            end

            obj.LastContextNode = node;
            obj.uiMenus(node, menu);

            if isempty(menu.Children)
                menu.Visible = 'off';
            else
                menu.Visible = 'on';
            end
        end

        function insertReqObj_Private( obj , parentNode , reqObj)
            
            % get the index
%             index = length(reqObj);
            for index = 1:length(reqObj)
                switch class(reqObj)
                    case 'Requirements.Stability'
                        value = 12;
                        check = true;
                    case 'Requirements.FrequencyResponse'
                        value = 13;
                        check = true;
                    case 'Requirements.HandlingQualities'
                        value = 14;
                        check = true;
                    case 'Requirements.Aeroservoelasticity'
                        value = 15;
                        check = true;
                    case 'Requirements.Synthesis'
                        value = 16;
                        check = true;
                    case 'Requirements.SimulationCollection'
                        value = 17;
                        check = true;
                    case 'Requirements.RootLocus'
                        value = 18;
                        check = false;
                    otherwise
                        value = 0;
                end
    
                node = uitreenode(parentNode,'Text',reqObj(index).Title,...
                    'NodeData',value);
                obj.setNodeChecked(node,check);

                if ~isempty(reqObj(index).MdlName)
                    modelNode = uitreenode(node,'Text',reqObj(index).MdlName,...
                        'NodeData',19);
                    obj.setNodeChecked(modelNode,check);
                    try
                        modelNode.Icon = getIcon('Simulink_16.png');
                    catch
                    end

                end
                if ~isempty(reqObj(index).FunName)
                    methodNode = uitreenode(node,'Text',reqObj(index).FunName,...
                        'NodeData',20);
                    obj.setNodeChecked(methodNode,check);
                    try
                        methodNode.Icon = getIcon('new_script_ts_16.png');
                    catch
                    end

                end
                if (isa(reqObj,'Requirements.RequirementTypeOne') && ~isempty(reqObj(index).RequiermentPlot)) ||  (isa(reqObj,'Requirements.RootLocus') && ~isempty(reqObj(index).RequiermentPlot))
                    methodNode = uitreenode(node,'Text',reqObj(index).RequiermentPlot,...
                        'NodeData',30);
                    obj.setNodeChecked(methodNode,check);
                    try
                        methodNode.Icon = getIcon('Figure_16.png');
                    catch
                    end

                end
                if isa(reqObj,'Requirements.Synthesis') %& ~isa(reqObj,'Requirements.RootLocus')
                    % Insert an empty scattered gain object or choose an
                    % existing scattered gain file.
    
                    
                    if isempty(obj.SelectedScatteredGainFileObj )
                        scatteredNode = uitreenode(node,'Text','',...
                            'NodeData',22,'UserData',[]);
                        obj.setNodeChecked(scatteredNode,true);
                        try
                            scatteredNode.Icon = getIcon(obj.ScattGainIcon);
                        catch
                        end
                        choice = questdlg({'A scattered gain file must be associated with your synthesis object in order to save your gains.', ...
                            'Please choose one of the following.'},...
                            'Choose Scattered Gain File',...
                            'Create a new scattered gain file', ...
                            'Add a saved scattered gain file','Create a new scattered gain file');
                        drawnow();pause(0.1);
                        switch choice
                            case 'Create a new scattered gain file'
                                insertEmptyScatteredGainObj_CB( obj , [] , [] , node , true );
                            case 'Add an saved scattered gain file'
    
                        end
                    else
                        scatteredNode = uitreenode(node,'Text',obj.SelectedScatteredGainFileObj.Name,...
                            'NodeData',22,'UserData',[]);
                        obj.setNodeChecked(scatteredNode,true);
                        try
                            scatteredNode.Icon = getIcon(obj.ScattGainIcon);
                        catch
                        end
                    end

                    % Set to selected by default
                    obj.setNodeChecked(node,true);
                end
    
                reqObj(index).SelectedStatus = 'selected';
                node.UserData = reqObj(index);        
            end
        end % insertReqObj_Private    
        
        function status = checkTitle( obj, reqObj, reqClass)
            status = false;
                                  
            switch reqClass
                case {'Requirements.Stability'}
                    rObjs = getSelectedReqObjs( obj , 'StabilityReqNode' );
                case {'Requirements.FrequencyResponse'}
                    rObjs = getSelectedReqObjs( obj , 'FreqNode' );
                case {'Requirements.SimulationCollection'}
                    rObjs = getSelectedReqObjs( obj , 'SimNode' );
                case {'Requirements.HandlingQualities'}
                    rObjs = getSelectedReqObjs( obj , 'HQNode' );
                case {'Requirements.Aeroservoelasticity'}
                    rObjs = getSelectedReqObjs( obj , 'ASENode' );
                case {'Requirements.RootLocus'}
                    rObjs = getAllRLocusObjs( obj );
                case {'Requirements.Synthesis'}
                    rObjs = getAllSynthesisObjs( obj );
            end
            
        end % checkTitle
        
    end
    
    %% Methods - Callbacks - Remove
    methods 
        
        function removeOperCond_CB( obj , ~ , ~ , treeNode )
            choice = questdlg(['Are you sure you would like to remove the Operating Condtions "',treeNode.Name,'"?'], ...
                'Remove?', ...
                'Yes','No','No');
            drawnow();pause(0.1);
            switch choice
                case 'Yes'
                    parentNode = treeNode.Parent;  
                    ind = find(treeNode == parentNode.Children);
                    delete(treeNode);
                    if isempty(parentNode.Children)
                        obj.setNodeChecked(parentNode,false);
                    end
                    notify(obj,'OperCondRemoved',UserInterface.ControlDesign.ControlTreeEventData(ind));
                otherwise
                    return;
            end
        end % removeOperCond_CB
        
        function removeAllOperCond_CB(obj , ~ , ~ , treeNode )
            choice = questdlg('Are you sure you would like to remove all Operating Condtions?', ...
                'Remove?', ...
                'Yes','No','No');
            drawnow();pause(0.1);
            switch choice
                case 'Yes'
                    delete(treeNode.Children);
                    obj.setNodeChecked(treeNode,false);
                    notify(obj,'OperCondRemoved',UserInterface.ControlDesign.ControlTreeEventData('All'));
                otherwise
                    % Do nothing and exit callback
                    return;
            end
        end % removeAllOperCond_CB
        
        function removeFolder(obj , ~ , ~ )
            
        end % removeFolder
        
        function removeReqObj_CB( obj , ~ , ~ , treeNode )
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------

            reqobj = copy(treeNode.UserData);

            
            parentNode = treeNode.Parent;
            delete(treeNode);
            if isempty(parentNode.Children)
                obj.setNodeChecked(parentNode,false);
            end
            
            notify(obj,'ReqObjRemoved',UserInterface.ControlDesign.ControlTreeEventData(reqobj));  
        end % removeReqObj_CB  
        
        function removeAll_CB(obj , ~ , ~ , treeNode )
            
            if strcmp(treeNode.Name,'Scheduled')
                                
                choice = questdlg({'Would you like to remove all Scheduled Gain Collections ?',...
                    'This will remove the Scheduled Gain Collections in the Gain Schedule panel also.'}, ...
                    'Remove?', ...
                    'Yes',...
                    'No','No');
                drawnow();pause(0.5);
                % Handle response
                if strcmp(choice,'Yes')
                    % Do nothing and move on
                else
                    return;
                end
                
                
                
            end
            nodes =treeNode.Children;
            reqObjs = copy([nodes.UserData]);
            
            delete(treeNode.Children);
            obj.setNodeChecked(treeNode,false);
            
            notify(obj,'ReqObjRemoved',UserInterface.ControlDesign.ControlTreeEventData(reqObjs));  
            
        end % removeAll
        
        function saveAll_CB(obj , ~ , ~ , node )
            
            selDir = uigetdir(pwd,'Save all requierments');
            
            if selDir == 0
                return;
            end

            for i = 1:length(node.Children)
                reqDefObj = copy(node.Children(i).UserData); 
                if obj.isNodeChecked(node.Children(i))
                    filename = genvarname(node.Children(i).Name);
                    save(fullfile(selDir,filename),'reqDefObj');
                end
            end        
        end % saveAll_CB
        
        function saveReqObj_CB( obj , ~ , ~ , treeNode )
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------

            [filename, path] = uiputfile('*.mat','Save requierment');
            
            if filename == 0
                return;
            end
            
            reqobj = copy(treeNode.UserData);

            save(fullfile(path,filename),'reqobj'); 
        end % saveReqObj_CB
        
        function mvReqNode_CB( obj , ~ , ~ , node, direction )
        %MOVETREENODE Move a tree node up or down among its siblings using
        % MATLAB's uitree. This is a simplified replacement for the
        % previous Java-based implementation.

            parent = node.Parent;
            if isempty(parent)
                error('Cannot move the root node.');
            end

            siblings = parent.Children;
            idx = find(siblings == node);
            switch direction
                case 'up'
                    if idx <= 1
                        return; % Already at top
                    end
                    newOrder = [siblings(1:idx-2) node siblings(idx-1) siblings(idx+1:end)];
                case 'down'
                    if idx >= numel(siblings)
                        return; % Already at bottom
                    end
                    newOrder = [siblings(1:idx-1) siblings(idx+1) node siblings(idx+2:end)];
                otherwise
                    newOrder = siblings;
            end
            parent.Children = newOrder;
            drawnow();
        end % mvStabNode_UP_CB

        function changeSimulation_CB(obj , ~ , ~ , node )
            
            [filename, pathname] = uigetfile({'*.slx;*.mdl'},'Select New Simulation:',pwd,'MultiSelect', 'off');
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end

            [~,newName,~] = fileparts(filename);
            
            for i = 1:length(node.Children)
                reqNode = node.Children(i); 
                if obj.isNodeChecked(reqNode)
                    reqNode.UserData.MdlName = newName;
                    for j = 1:length(reqNode.Children)
                        child = reqNode.Children(j);
                        type = child.Value;
                        switch type
                            case 19
                                child.Name = newName; 
                        end   
                    end
                end   
            end     
            % Refresh the tree display
            drawnow();
            notify(obj,'ReqObjUpdated'); 
        end % changeSimulation_CB
        
    end
    
    %% Methods - Gain Schedule Callbacks
    methods %(Access = protected) 
        
        function insertSchGainCollObjFile_CB( obj , ~ , ~ , parentNode , path , reqObj)
        %----------------------------------------------------------------------
        % - Callback for "obj.LayoutHandles.tree" uitree context menu
        %----------------------------------------------------------------------
            reqClass = class(reqObj);
            if isempty(path)
                [filename, pathname] = uigetfile({'*.mat'},'Select Scattered Gain File:',obj.SchStartDir,'MultiSelect', 'on');
            else
                [pathname,name,ext] = fileparts(path) ;
                filename = [name,ext];
            end
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            obj.SchStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
                for k = 1:length(filename)
                    varStruct = load(fullfile(pathname,filename{k}));
                    varNames = fieldnames(varStruct);
                    for i = 1:length(varNames)

                        % check for correct class

                        if ~isa(varStruct.(varNames{i}),reqClass)
                            msgbox({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','error')
                            continue;
                        end
                        % add to requirement object array
                        reqObj(end+1) = varStruct.(varNames{i});  %#ok<AGROW>
                        % get the index
                        index = length(reqObj);
                        
                                        
                node = uitreenode(parentNode,'Text',reqObj(index).Name,...
                    'NodeData',40);
                obj.setNodeChecked(node,false);
                        
                        allGainNames = reqObj(index).IncludedGains;
                        completedGainNames = reqObj(index).Gains2BeCompleted;
                        parentNode = node;
                        for j = 1:length(allGainNames)
                        if any(strcmp(allGainNames{j},completedGainNames))
                            node = uitreenode(parentNode,'Text',['<html><font color="red"><i>' allGainNames{j}],...
                                'NodeData',41);
                        else
                            node = uitreenode(parentNode,'Text',allGainNames{j},...
                                'NodeData',42);
                        end
                        obj.setNodeChecked(node,false);

                        m=j;

                        node1 = uitreenode(node,'Text',[reqObj(index).Gain(m).BreakPoints1Name,' - ',num2str(reqObj(index).Gain(m).Breakpoints1Values)],...
                            'NodeData',43);
                        obj.setNodeChecked(node1,false);

                        if ~isempty(reqObj(index).Gain(m).BreakPoints2Name)
                            node2 = uitreenode(node,'Text',[reqObj(index).Gain(m).BreakPoints2Name,' - ',num2str(reqObj(index).Gain(m).Breakpoints2Values)],...
                                'NodeData',44);
                            obj.setNodeChecked(node2,false);
                        end
                        node3 = uitreenode(node,'Text',['TableData - ',[num2str(size(reqObj(index).Gain(m).TableData,1)),' x ',num2str(size(reqObj(index).Gain(m).TableData,2))]],...
                            'NodeData',45);
                        obj.setNodeChecked(node3,false);

                        end
                        
                        
                        parentNode.UserData = reqObj(index);
                               
                    end
                end 
%                 obj.LoadedSchGainObj = [obj.GainsScheduled.Children.UserData];
                notify( obj , 'ScheduleGainCollectionAdded' );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            drawnow();
        end % insertSchGainCollObjFile_CB
               
        function saveGainSchFromNode( ~ , ~ , ~ , node)
            [file, path] = uiputfile(...
                 {'*.mat';'*.*'},...
                 'Save as');
           drawnow();pause(0.5);
           gainSrcObj       = node.UserData; %#ok<NASGU>
           save(fullfile(path,file) , 'gainSrcObj');
%             
%             
%            gainSrcObj       = node.UserData; %#ok<NASGU>
%            uisave('gainSrcObj','GainSchedule');
        end % saveGainSchFromNode
        
        function createSimulinkBlock( obj , ~ , ~ , schNode , name )
            gainSchCollObj = schNode.UserData;
            gainSchObj = findGainScatt(gainSchCollObj,name);
            createSimulinkBlock( gainSchObj );
        end % createSimulinkBlock
        
    end
    
    %% Methods - Gain Scattered Callbacks
    methods 
        
        function setAllSynNodeScattGainFileObj2Save( obj )
            for i = 1:length(obj.GainsSynthesis.Children)
                synNode = obj.GainsSynthesis.Children(i);
                % Remove the old scattered gain file node under the chossen
                % synthesis object
                delLogArray = 22 == [synNode.Children.Value];
                delNode = synNode.Children(delLogArray);
                delNode.Name = obj.SelectedScatteredGainFileObj.Name;
%                 delete(delNode);
% 
%                 % Create a new scattered gain file object node under the
%                 % chossen sythesis object
%                 node = UserInterface.uiextras.jTree.CheckboxTreeNode('Name',obj.SelectedScatteredGainFileObj.Name,'Parent',synNode,...
%                     'Checked',true,'CheckboxVisible',false,'Value',22,'UserData',obj.SelectedScatteredGainFileObj);
%                 node.setIcon(getIcon(obj.ScattGainIcon)); 
            end
            
            for i = 1:length(obj.RootLocusNode.Children)
                synNode = obj.RootLocusNode.Children(i);
                % Remove the old scattered gain file node under the chossen
                % synthesis object
                delLogArray = 22 == [synNode.Children.Value];
                delNode = synNode.Children(delLogArray);
                delNode.Name = obj.SelectedScatteredGainFileObj.Name;
%                 delete(delNode);
% 
%                 % Create a new scattered gain file object node under the
%                 % chossen sythesis object
%                 node = UserInterface.uiextras.jTree.CheckboxTreeNode('Name',obj.SelectedScatteredGainFileObj.Name,'Parent',synNode,...
%                     'Checked',true,'CheckboxVisible',false,'Value',22,'UserData',obj.SelectedScatteredGainFileObj);
%                 node.setIcon(getIcon(obj.ScattGainIcon)); 
            end
            
        end % setAllSynNodeScattGainFileObj2Save
        
        function insertEmptyScatteredGainObj_CB( obj , ~ , ~ , synNode , set2saved )
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            
            % unselect all gain sources
            unselectAllGainSources( obj );
            
            % Find a default Scattered Gain File name
            numOfNodes = length(obj.GainsScattered.Children);
            gainScattCollName = ['Scattered Gains File ',num2str(numOfNodes + 1)];
            
            % Ask user to modify the default file name
            answer = inputdlg('Scattered Gain File Name:',...
                'Scattered Gain File Name',...
                [1 50],...
                {gainScattCollName});
            drawnow();pause(0.1);
            if ~isempty(answer)
                gainScattCollName = strtrim(answer{:});
            end
            
            % Create an empty Scattered Gain file object
            tempScattGainFile = ScatteredGain.GainFile('Name',gainScattCollName,'ScatteredGain',ScatteredGain.GainCollection.empty);
            
            % Create a new Scattered Gain file node under "Scattered"
            node = uitreenode(obj.GainsScattered,'Text',gainScattCollName,...
                'NodeData',21,'UserData',tempScattGainFile);
            obj.setNodeChecked(node,false);
            try
                node.Icon = getIcon(obj.ScattGainIcon);
            catch
            end

            if set2saved
                selectScatteredGainFile2Write( obj , [] , [] , synNode , gainScattCollName );%synNode.getParent
            end
            
            notify( obj , 'ScatteredGainFileAdded' );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            drawnow();
        end % insertEmptyScatteredGainObj_CB
        
        function insertScatteredGainFileObj_CB( obj , ~ , ~ , parentNode  )
 
          
            [filename, pathname] = uigetfile({'*.mat'},'Select Scattered Gain File:',obj.ScattStartDir,'MultiSelect', 'on');
            drawnow();pause(0.1);
            
            if isequal(filename,0)
                return;
            end
            
            set(obj.ParentFigure, 'pointer', 'watch');
            drawnow();
            obj.ScattStartDir = pathname;
            if ~iscell(filename)
                filename = {filename};
            end
            for k = 1:length(filename)
                varStruct = load(fullfile(pathname,filename{k}));
                varNames = fieldnames(varStruct);
                
                
                for i = 1:length(varNames) % loop for multiple objects in the loaded file

                    currentObj = varStruct.(varNames{i});
                    % check for correct class
                    if ~isa(currentObj,'ScatteredGain.GainFile')
                        msgbox({'The file you are attempting to load contains one',...
                            'or more variables with the incorrect format'...
                            'The variable ',varNames{i},' will not be loaded.'},...
                            'Name Conflict','error')
                        continue;
                    end

                    % Check for name conflicts - names must be unique
                    gainFileObjNames = {obj.GainsScattered.Children.Name};

                    if ~isempty(gainFileObjNames)
                        lA_name = strcmp(currentObj.Name,gainFileObjNames);
                        if any(lA_name) % Ask user to replace or select a new name
                            choice = questdlg('A scattered gain object of the same name exists?', ...
                                'Name Conflict', ...
                                'Replace','Change Name','Cancel','Cancel');
                            drawnow();pause(0.1);
                            switch choice
                                case 'Replace'
                                    logArray = strcmp(currentObj.Name,{obj.GainsScattered.Children.Name});
                                    treeNode = obj.GainsScattered.Children(logArray);
                                    treeNode.UserData = currentObj;
                                    drawnow();
                                    set(obj.ParentFigure, 'pointer', 'arrow');
                                    continue;%return;
                                case 'Change name'                                    
                                    answer = inputdlg('Choose a new name:',...
                                        'Name',...
                                        [1 40],...
                                        {[currentObj.Name,' - Copy']});
                                    drawnow();pause(0.1);
                                    if isempty(answer)
                                        % Do nothing and exit callback
                                        return;
                                    else
                                        currentObj.Name = answer{:};
                                    end
                                case 'Cancel'
                                    % Do nothing and exit callback
                                    drawnow();
                                    set(obj.ParentFigure, 'pointer', 'arrow');
                                    drawnow();
                                    continue;%return;
                            end
                        end
                    end

                    % add to requirement object array
                    reqObj(end+1) = currentObj; %#ok<AGROW>
                    % get the index
                    index = length(reqObj);

                    node = uitreenode(parentNode,'Text',reqObj(index).Name,...
                        'NodeData',40);
                    obj.setNodeChecked(node,false);
                    node.UserData = reqObj(index);
                end
            end  
            notify( obj , 'ScatteredGainFileAdded' );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
            drawnow();
        end % insertScatteredGainFileObj_CB   
        
        function removeScatteredGainFile( obj , hobj , eventdata , node)
            
            testedName   = node.UserData.Name;
            selectedName = obj.SelectedScatteredGainFileObj.Name;
            if ~strcmp(testedName,selectedName)
                delete(node);
            else
                % --------------Send Log Message-----------
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData([selectedName,' is the current scattered gain file and cannot be removed.'],'warn'));
            end
            notify( obj , 'ScatteredGainFileAdded' );

        end % removeScatteredGainFile
        
        function renameScatteredGainFile( obj , hobj , eventdata , node)
            notify( obj , 'ScatteredGainFileAdded' );
%             setLoadedScattGainObj( obj );
        end % renameScatteredGainFile
        
        function selectScatteredGainFile2Write( obj , ~ , ~ , synNode , selFileObjName)
                
            % Find the scattered gain file object from within the
            % "Scattered" branch of the tree
            logArray = strcmp(selFileObjName,{obj.GainsScattered.Children.Name});
            selectedNode = obj.GainsScattered.Children(logArray);
         
            % Set the Scattered Gain file object used to store gains
            obj.SelectedScatteredGainFileObj = selectedNode.UserData; 
            setAllSynNodeScattGainFileObj2Save( obj );
        end % selectScatteredGainFile2Write
        
        function saveScattGainFromNode( ~ , ~ , ~ , node)
            [file, path] = uiputfile(...
                 {'*.mat';'*.*'},...
                 'Save as');
            drawnow();pause(0.5);
           gainSrcObj       = node.UserData; %#ok<NASGU>
           save(fullfile(path,file) , 'gainSrcObj');
%            uisave('gainSrcObj','ScatteredGain');
        end % saveGainSchFromNode
        
        function exportScattGainFromNode( obj , ~ , ~ , node)
%             [file, path] = uiputfile(...
%                  {'*.m';'*.*'},...
%                  'Save as');
%             drawnow();pause(0.5);
%            gainSrcObj       = node.UserData; 
%            
%            % need code to export to m-file
%            gainSrcObj.ScatteredGainCollection.write2File(fullfile(path,file));
           notify( obj , 'ScatteredGainFileExported' );
        end % exportGainSchFromNode
        
        function clearScattGainFromNode( obj , ~ , ~ , node)
            % Ensure user want to continue
            choice = questdlg('This will clear all Scattered Gains from the selected file. Would you like to continue?', ...
                'Clear Scattered Gains?', ...
                'Yes','No','No');
            % Handle response
            switch choice
                case 'Yes'
                    testedName   = node.UserData.Name;
                    node.UserData.ScatteredGainCollection = ScatteredGain.GainCollection.empty;
                    node.UserData.Date = datestr(now);
            
                    notify( obj , 'ScatteredGainFileCleared', UserInterface.ControlDesign.ControlTreeEventData(testedName) );
                otherwise
                    return;
            end      
        end % clearScattGainFromNode
        
    end
    
    %% Methods - Private    
    methods %(Access = private)
        
        function unselectAllGainSources( obj )
            % unselect all gain sources
            count = length(obj.GainsScheduled.Children);
            for i = 1:count
                currNode = obj.GainsScheduled.Children(i);
                obj.setNodesChecked(currNode,false);
            end
            count = length(obj.GainsSynthesis.Children);
            for i = 1:count
                currNode = obj.GainsSynthesis.Children(i);
                obj.setNodesChecked(currNode,false);
            end
            count = length(obj.GainsScattered.Children);
            for i = 1:count
                currNode = obj.GainsScattered.Children(i);
                obj.setNodesChecked(currNode,false);
            end
        end % unselectAllGainSources

        function unselectScatteredGainSources( obj )
            for i = 1:length(obj.GainsScattered.Children)
                obj.setNodesChecked(obj.GainsScattered.Children(i),false);
            end
        end % unselectScatteredGainSources

        function unselectScheduledGainSources( obj )
            for i = 1:length(obj.GainsScheduled.Children)
                obj.setNodesChecked(obj.GainsScheduled.Children(i),false);
            end
        end % unselectScheduledGainSources

        function unselectRootLocusSources( obj )
            for i = 1:length(obj.RootLocusNode.Children)
                obj.setNodesChecked(obj.RootLocusNode.Children(i),false);
            end
        end % unselectRootLocusSources

        function setNodesChecked(obj,nodes,value)
            if isempty(nodes)
                return;
            end
            for k = 1:numel(nodes)
                currentNode = nodes(k);
                obj.setNodeChecked(currentNode,value);
                if ~value
                    obj.setNodesChecked(currentNode.Children,value);
                end
            end
        end

        function setNodeChecked(obj,node,value)
            if nargin < 3 || isempty(node) || isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                return;
            end

            node = node(isvalid(node));
            if isempty(node)
                return;
            end

            value = logical(value);
            checkedNodes = obj.getCheckedNodes();

            for k = 1:numel(node)
                currentNode = node(k);
                if value
                    if ~any(currentNode == checkedNodes)
                        checkedNodes = [checkedNodes(:); currentNode]; %#ok<AGROW>
                    end
                else
                    checkedNodes = checkedNodes(checkedNodes ~= currentNode);
                end
            end

            checkedNodes = checkedNodes(:);
            if isempty(checkedNodes)
                obj.TreeObj.CheckedNodes = matlab.ui.container.TreeNode.empty;
            else
                obj.TreeObj.CheckedNodes = checkedNodes;
            end
        end

        function checkedNodes = getCheckedNodes(obj)
            if isempty(obj.TreeObj) || ~isvalid(obj.TreeObj)
                checkedNodes = matlab.ui.container.TreeNode.empty;
                return;
            end
            checkedNodes = obj.TreeObj.CheckedNodes;
            if isempty(checkedNodes)
                checkedNodes = matlab.ui.container.TreeNode.empty;
                return;
            end
            checkedNodes = checkedNodes(isvalid(checkedNodes));
        end

        function tf = areNodesChecked(obj,nodes)
            if isempty(nodes)
                tf = false(size(nodes));
                return;
            end

            checkedNodes = obj.getCheckedNodes();
            tf = false(size(nodes));
            for k = 1:numel(nodes)
                if ~isvalid(nodes(k))
                    tf(k) = false;
                else
                    tf(k) = any(nodes(k) == checkedNodes);
                end
            end
        end

        function tf = isNodeChecked(obj,node)
            if isempty(node) || ~isvalid(node)
                tf = false;
                return;
            end
            tf = any(node == obj.getCheckedNodes());
        end

        function tf = isNodePartiallyChecked(obj,node)
            if isempty(node) || ~isvalid(node)
                tf = false;
                return;
            end

            children = node.Children;
            if isempty(children)
                tf = false;
                return;
            end

            childStates = obj.areNodesChecked(children);
            tf = any(childStates) && ~all(childStates);
        end
        
%         function setLoadedScattGainObj( obj )
%             
%             for i = length(obj.GainsScattered.Children)
%                 nodeObj(i) = obj.GainsScattered.Children(i).UserData;
%             end
%             obj.LoadedScattGainObj = nodeObj;     
%         end % setLoadedScattGainObj
        
%         function setLoadedSchGainObj( obj )
% % %             childNodes = findAllChildrenInNode(obj.GainsScheduled);
% % %             for i = 1:length(childNodes)
% % %                 nodeObj(i) = childNodes{i}.handle.UserData; %#ok<*AGROW>
% % %             end     
% % %             obj.LoadedSchGainObj = nodeObj;
% %             
% %             
% %             for i = 1:obj.GainsScheduled.getChildCount
% %                 childNode = obj.GainsScheduled.getChildAt(i-1);
% %                 nodeObj(i) = childNode.handle.UserData; %#ok<*AGROW>
% %             end 
% %             obj.LoadedSchGainObj = nodeObj;
% %             
%             obj.LoadedSchGainObj = [obj.GainsScheduled.Children.UserData];
%         end % setLoadedSchGainObj
        
    end
    
    %% Methods Tree
    methods
              
        function y = saveTreeState(obj)
            
            s = saveTreeState(obj.TreeObj);
            
            e = saveExpansionState(obj.TreeObj);
            
            y = struct('NodeData',s,'ExpState',e);

        end % saveTreeState 
              
        function reSize( obj , ~ , ~ )
            % get figure position
%             position = getpixelposition(obj.Parent);
            

        end % reSize
       
    end
    
    %% Methods - Static    
    methods (Static)
        

        
    end 
    
    %% Method - Delete
    methods
        function delete( obj ) 
                    
            try %#ok<*TRYNC> 
                delete(obj.TreeObj);
            end
            try %#ok<*TRYNC> 
                delete(obj.GainsNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.GainsScheduled);
            end
            try %#ok<*TRYNC> 
                delete(obj.GainsScattered);
            end
            try %#ok<*TRYNC> 
                delete(obj.GainsSynthesis);
            end
            try %#ok<*TRYNC> 
                delete(obj.RootLocusNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.ReqNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.StabilityReqNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.FreqNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.SimNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.HQNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.ASENode);
            end
            try %#ok<*TRYNC> 
                delete(obj.OperCondNode);
            end
            try %#ok<*TRYNC> 
                delete(obj.SelectedScatteredGainFileObj);
            end
%             try %#ok<*TRYNC> 
%                 delete(obj.LoadedScattGainObj);
%             end
%             try %#ok<*TRYNC> 
%                 delete(obj.LoadedSchGainObj);
%             end
        end % delete
    end  
    
%     %% Method - Save
%     methods
%         function s = saveobj(obj)
%             s.Prop1 = obj.Prop1;
%             s.Prop2 = obj.Prop2;
%             s.Data = obj.GraphHandle.YData;
%         end 
%     end
%     
%     %% Method - Load
%     methods(Static)
%         function obj = loadobj(s)
%             if isstruct(s)
%                 newObj = ClassConstructor; 
%                 newObj.Prop1 = s.Prop1;
%                 newObj.Prop2 = s.Prop2;
%                 newObj.GraphHandle = plot(s.Data);
%                 obj = newObj;
%             else
%                 obj = s;
%             end
%         end
%     end

end

function y = getIcon( imagefilename )

    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    y = fullfile(icon_dir,imagefilename);
end % getIcon






