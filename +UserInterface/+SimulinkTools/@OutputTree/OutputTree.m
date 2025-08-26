classdef OutputTree < handle
    
    %% Public properties - Object Handles
    properties (Transient = true) 
        TreeObj
        SignalLogNode
        OutputsNode
        InputsNode
    end % Public properties
  
    %% Private properties - Data Storage
    properties (Access = private)  

    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Constant properties
    properties (Constant) 

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
        SignalSelected

    end
    
    %% Methods - Constructor
    methods      
        function obj = OutputTree(varargin)
                        
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = false;
            
            % Define defaults and requirements for each parameter
            p.addParamValue('Parent',[]); %#ok<*NVREPL>
            p.addParamValue('Restore',[]);
            %p.addParamValue('ComparisonData',[]);
            p.parse(varargin{:});
             
            % Which parameters are not at defaults and need setting?
            Params = rmfield(p.Results, p.UsingDefaults);   
             
            % Create new or restore
            if ~isfield(Params,'Restore') || isempty(Params.Restore)
                create(obj,Params);
            else
                restore(obj,Params);
            end

            
        end % OutputTree
        
    end % Constructor

    %% Methods - Property Access
    methods
   
    end % Property access methods
   
    %% Methods - Create
    methods
        
        function create( obj , Params ) 
            import UserInterface.uiextras.jTree.*
            
            % Ensure there is a valid parent
            if ~isfield(Params,'Parent') || isempty(Params.Parent)
                parent = figure;
            else
                parent = Params.Parent;
                Params = rmfield(Params,'Parent');
            end
            

            obj.TreeObj = Tree('Parent',parent);%,'MouseClickedCallback',@obj.mousePressedInTree_CB);
            obj.TreeObj.RootVisible= false;
            
            % Create tree nodes
            obj.InputsNode = TreeNode('Name','Input Ports','Parent',obj.TreeObj.Root,'Value',1);
            obj.InputsNode.setIcon(getIcon('simulink_app_16_IN.png'));

            obj.OutputsNode = TreeNode('Name','Output Ports','Parent',obj.TreeObj.Root,'Value',2);
            obj.OutputsNode.setIcon(getIcon('simulink_app_16_OUT.png'));
            
            obj.SignalLogNode = TreeNode('Name','Signal Logs','Parent',obj.TreeObj.Root,'Value',3);
            obj.SignalLogNode.setIcon(getIcon('signal_app_16.png'));
  
        end % create  
        
        function restore( obj , Params ) 
            import UserInterface.uiextras.jTree.*
            
            % Ensure there is a valid parent
            if ~isfield(Params,'Parent') || isempty(Params.Parent)
                parent = figure;
            else
                parent = Params.Parent;
                Params = rmfield(Params,'Parent');
            end
            
            
            obj.TreeObj = Tree('Parent',parent);%,'MouseClickedCallback',@obj.mousePressedInTree_CB);
            obj.TreeObj.RootVisible= false;
            
            nodeData = Params.Restore.NodeData;

            TreeNodes = TreeNode.empty;
            
            for i = 2:length(nodeData)
                
                
                % Remove brackets from end of string
                str = nodeData(i).TreePath(2:end-1);
                % Split into a cell array of strings
                cellStr = strsplit(str,',');
                % Remove leading and trailing blanks 
                cellStr = strtrim(cellStr);
                
                
                if length(cellStr) == 2
                    parentNode = obj.TreeObj;
                    TreeNodes = TreeNode.empty;
                elseif length(cellStr) - 1 == length(TreeNodes)  % Needs a new branch
                    TreeNodes = TreeNodes(1:end-1);
                    parentNode = TreeNodes(end); 
                elseif length(cellStr) - 1 > length(TreeNodes)  % Needs a new branch
                    parentNode = TreeNodes(end); 
                elseif length(cellStr) - 1 < length(TreeNodes) % Moves up x number of branches
                    num2keep = length(cellStr) - 2;
                    TreeNodes = TreeNodes(1:num2keep);
                    parentNode = TreeNodes(end);  
                else
                    error('UserInterface:ControlTree:RestoreTree','Unable to restore control tree');
                end
                node = TreeNode('Parent',parentNode,...
                        'Name',nodeData(i).Name,...
                        'TooltipString',nodeData(i).TooltipString,...
                        'Value',nodeData(i).Value,...
                        'UserData',nodeData(i).UserData,...
                        'UIContextMenu',nodeData(i).UIContextMenu);
                if ~isempty(nodeData(i).Icon)
                    try
                        thisdir = fileparts(mfilename( 'fullpath' ));
                        matchStr = regexp(char(nodeData(i).Icon),'\.\.\\\.\.\\Resources.*','match');
                        icon = fullfile(thisdir,matchStr{:});
                        node.setIcon(icon); 
                    catch
                        node.setIcon(char(nodeData(i).Icon));   
                    end
                end
                setNodeProperty( obj , node );    
                 
                TreeNodes(end + 1) = node;                    
            end
            
            % Restore Expansion State
            restoreExpansionState(obj.TreeObj,Params.Restore.ExpState)
                  
        end % restore
        
        function setNodeProperty( obj , node )
    
            switch node.Value
                case 1
                    obj.InputsNode = node;
                case 2
                    obj.OutputsNode = node;
                case 3
                    obj.SignalLogNode = node;
      
            end  
        end % setNodeProperty
        
    end  
    
    %% Methods - Ordinary
    methods
         
        function y = saveTreeState(obj)
            
            s = saveTreeState(obj.TreeObj);
            
            e = saveExpansionState(obj.TreeObj);
            
            y = struct('NodeData',s,'ExpState',e);

        end % saveTreeState    
        
        function addNode( obj , parentNode , name , path , icon )
            import UserInterface.uiextras.jTree.*
            node = TreeNode('Name',name,'Parent',obj.(parentNode),'Value',path);
            node.setIcon(getIcon(icon));
                  
        end % addNode
        
        function addSignalsWithMdlRef( obj , x , parentNode , sigParentName )
            import UserInterface.uiextras.jTree.*
            addSignalHierarchy( obj , x.DataLoggingSignals , parentNode , sigParentName );
                    
            fnames = fieldnames(x.MdlRef); 
            for i = 1:length(fnames)
                node = TreeNode('Name',fnames{i},'Parent',parentNode,'Value',fnames{i});
                node.setIcon(getIcon('simulink_model_reference.png'));            
                addSignalsWithMdlRef( obj , x.MdlRef.(fnames{i}) , node , sigParentName );
            end      
                
        end % addSignalsWithMdlRef
        
        function addSignalHierarchy( obj , signals , parentNode , sigParentName )
            import UserInterface.uiextras.jTree.*
            for i = 1:length(signals)
                % Create a name for the signal node
                if isempty(sigParentName)
                    sigName = ['Signal|',signals(i).SignalName];
                else
                    sigName = [sigParentName,'.',signals(i).SignalName];
                end
                % Create the node and add it to the tree
                node = TreeNode('Name',signals(i).SignalName,'Parent',parentNode,'Value',sigName);
                
                if isempty(signals(i).Children)
                    node.setIcon(getIcon('LogSignals_16.png')); 
                else
                    node.setIcon(getIcon('bus_object.png'));  
                end

                
                for j = 1:length(signals(i).Children)
                    child = signals(i).Children(j);
                    
                    childSigName = [sigName,'.',child.SignalName];
                    childNode = TreeNode('Name',child.SignalName,'Parent',node,'Value',childSigName);
                    if isempty(child.Children)
                        childNode.setIcon(getIcon('LogSignals_16.png'));
                    else
                        childNode.setIcon(getIcon('bus_object.png'));
                    end

                    if ~isempty(child.Children)
                        addSignalHierarchy( obj , child.Children , childNode , childSigName )
                    end
                end
            end
            
            
        end % addSignalHierarchy 
        
        function initializeNodes(obj)
            delete(obj.SignalLogNode.Children);
            delete(obj.OutputsNode.Children);
            delete(obj.InputsNode.Children);
        end
                 
    end % Ordinary Methods
    
    %% Methods - Callbacks
    methods %(Access = protected) 
   
        function openModel_CB( obj , ~ , ~ , node )
            mdlName = char(node.Name);
            open_system(mdlName);
        end % openModel_CB
        
        function editReq_CB( obj , ~ , ~ , node )
            reqDefObj = node.UserData;
            reqTypeCell = strsplit(class(reqDefObj),'.');
            f=figure;
            reqEditObj = UserInterface.ObjectEditor.ReqEditor('Parent',f,reqTypeCell{2});
            loadExisting(reqEditObj, reqDefObj , reqDefObj.FileName );
        end % editReq_CB
        
    end
       
    %% Methods - Private    
    methods (Access = private)

        
    end
    
    %% Methods - Static    
    methods (Static)
        

        
    end 
    
    %% Method - Delete
    methods

    end  
    
end

function y = getIcon( imagefilename )

    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    y = fullfile(icon_dir,imagefilename);
end % getIcon

