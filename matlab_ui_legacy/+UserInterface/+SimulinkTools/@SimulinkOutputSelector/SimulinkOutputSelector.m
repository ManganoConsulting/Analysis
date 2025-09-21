classdef SimulinkOutputSelector < handle
    
    %% Public properties
    properties
        SelectedRemoveSignalIndex = 1
        
        TreeSavedData
        InportData
        OutportData
        SignalData
    end % Public properties
    
    %% Public properties
    properties(SetObservable) 
        SelectedSignals = struct('Name',{},'Path',{},'Type',{})
        
    end % Public properties
     
    %% Hidden Properties
    properties (Hidden = true)

    end % Hidden Properties

    %% Hidden Transient Properties
    properties (Transient = true , Hidden = true )
        Parent
        TreeContainer
        ButtonContainer
        SignalSelBtn
        SignalRmBtn
        SelectedSignalList
        Tree
    end % Hidden Transient Properties
    
    %% Hidden Transient View Properties
    properties (Hidden = true , Transient = true )       

    end % Hidden Transient View Properties
    
    %% Methods - Constructor
    methods  
        function obj = SimulinkOutputSelector(parent)
          if nargin == 1
             obj.Parent = parent;
             createView(obj);
          end
        end % requirement 
    end % Constructor
   
    %% Methods - Property Access
    methods


    end % Methods - Property Access
    
    %% Methods - Ordinary
    methods
        
        function saveTreeState(obj)
            
            obj.TreeSavedData = saveTreeState(obj.Tree);

        end % saveTreeState 
        
        function updateOutputNode( obj , outports )
            obj.OutportData = outports;
            
            outputIcon = 'Chevrons_HideMO_16.png';
            
            if ischar(outports)
               name = fileparts(outports);
               addNode( obj.Tree , 'OutputsNode' ,name , ['Output|',outports] , outputIcon ); 
            else
                for i = 1:length(outports)
                    [ ~ , name ] = fileparts(outports{i});
                    addNode( obj.Tree , 'OutputsNode' , name , ['Output|',outports{i}] , outputIcon );
                end
            end
        end % updateOutputNode
   
        function updateInputNode( obj , inports )
            obj.InportData = inports;
           
            inputIcon = 'Chevrons_ShowMO_16.png';
            
            if ischar(inports)
               name = fileparts(inports);
               addNode( obj.Tree , 'InputsNode' ,name , ['Input|',inports] , inputIcon ); 
            else
                for i = 1:length(inports)
                    [ ~ , name ] = fileparts(inports{i});
                    addNode( obj.Tree , 'InputsNode' , name , ['Input|',inports{i}] , inputIcon );
                end
            end
        end % updateOutputNode
        
        function updateSignalLogNode( obj , signals )
            obj.SignalData = signals;
            addSignalsWithMdlRef(obj.Tree,...
                signals,obj.Tree.SignalLogNode,'');
            %obj.Tree.addSignalHierarchy(signals,obj.Tree.SignalLogNode,'');
        end % updateOutputNode
        
    end % Ordinary Methods

    %% Methods - View
    methods
        
        function createView( obj , parent , loadSaved )
            if nargin == 1
                loadSaved = false;
            elseif nargin == 2
                obj.Parent = parent;
                loadSaved = false;
            elseif nargin >= 3
                obj.Parent = parent;
            end
            % Main TreeContainer 
            parentPos = getpixelposition(obj.Parent);
            set(obj.Parent,'ResizeFcn',@obj.resizeFcn);
            obj.TreeContainer = uicontainer('Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ 1 , 1 , parentPos(3)/3 , parentPos(4) - 5 ]);%,...
            
            if loadSaved
                obj.Tree = UserInterface.SimulinkTools.OutputTree('Parent',obj.TreeContainer,'Restore',obj.TreeSavedData);
            else
                obj.Tree = UserInterface.SimulinkTools.OutputTree('Parent',obj.TreeContainer);
            end
            % Button TreeContainer 
            parentPos = getpixelposition(obj.Parent);
            obj.ButtonContainer = uicontainer('Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ parentPos(3) , 1 , parentPos(3)/3 , parentPos(4) - 5 ]);
            set(obj.ButtonContainer,'ResizeFcn',@obj.resizeFcnBC);
            obj.SignalSelBtn = uicontrol('Parent',obj.ButtonContainer,...
                'Style','pushbutton',...
                'String','>>',...
                'Callback',@obj.selectedSignal);
            obj.SignalRmBtn = uicontrol('Parent',obj.ButtonContainer,...
                'Style','pushbutton',...
                'String','Remove',...
                'Callback',@obj.removeSignal);    
            
            obj.SelectedSignalList = uicontrol('Parent',obj.Parent,...
                'Style','listbox',...
                'BackgroundColor',[ 1 , 1 , 1 ],...
                'String',{obj.SelectedSignals.Name},...
                'Callback',@obj.selectedSignalList);
            
            
%             drawnow();pause(0.1);
            resizeFcn( obj );
            resizeFcnBC( obj );
            update(obj);
                      
        end % createView      
        
    end % Methods - View
        
    %% Methods - Protected Callbacks
    methods
        function selectedSignal( obj , ~ , ~ )
            jTree = obj.Tree.TreeObj.getJavaObjects().jTree;
            javaObjectEDT(jTree);
            treePath = jTree.getSelectionPaths();
            node     = treePath(1).getPathComponent(treePath(1).getPathCount - 1);

            mNode = get(node,'TreeNode');
            pathSplit = strsplit(char(mNode.Value),'|');
            obj.SelectedSignals(end+1) = struct('Name',char(mNode.Name),'Path',pathSplit{2},'Type',pathSplit{1});
            update(obj);
        end % selectedSignal
        
        function removeSignal( obj , ~ , ~ )
            
            obj.SelectedSignals(obj.SelectedRemoveSignalIndex) = [];
            obj.SelectedRemoveSignalIndex = 1;
            update(obj);
        end % removeSignal
        
        function selectedSignalList( obj , hobj , ~ )            
            obj.SelectedRemoveSignalIndex = hobj.Value;
        end % selectedSignalList
        
    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        function update( obj )
            obj.SelectedSignalList.Value  = obj.SelectedRemoveSignalIndex;
            obj.SelectedSignalList.String = {obj.SelectedSignals.Name};
            
        end % update
            

        
        function resizeFcn( obj , ~ , ~ )
            % get figure position
            parentPosition = getpixelposition(obj.Parent);

            try %#ok<TRYNC>
            obj.TreeContainer.Units = 'Pixels';
            obj.TreeContainer.Position = [ 1 , 1 , parentPosition(3)/2 - 40 , parentPosition(4) - 5 ];
            obj.ButtonContainer.Units = 'Pixels';
            obj.ButtonContainer.Position = [ parentPosition(3)/2 - 40 , 1 , 80 , parentPosition(4) - 5 ];
            obj.SelectedSignalList.Units = 'Pixels';
            obj.SelectedSignalList.Position = [ parentPosition(3)/2 + 40 , 1 , parentPosition(3)/2 - 40 , parentPosition(4) - 5 ];
            end
        end % resizeFcn
        
        function resizeFcnBC( obj , ~ , ~ )
            % get figure position
            parentPosition = getpixelposition(obj.ButtonContainer);

            obj.SignalRmBtn.Units = 'Pixels';
            obj.SignalRmBtn.Position = [ 10 , parentPosition(4)/2 - 30 , 60 , 25 ];
            obj.SignalSelBtn.Units = 'Pixels';
            obj.SignalSelBtn.Position = [ 10 , parentPosition(4)/2 + 5 , 60 , 25 ];
        end % resizeFcnBC
    end
    
    %% Methods - Protected
    methods (Access = protected)  
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            cpObj.Tree = copy(obj.Tree);
        end
        
    end % Methods - Protected
   
end







