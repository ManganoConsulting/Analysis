classdef AnalysisTask < dynamicprops & matlab.mixin.Copyable & UserInterface.GraphicsObject   
    %% Public properties - Data Storage
    properties  
        
        TrimTask lacm.TrimSettings = lacm.TrimSettings 
        LinearModelDef lacm.LinearModel = lacm.LinearModel.empty 
        Requirement Requirements.RequirementTypeOne = Requirements.RequirementTypeOne.empty 
        SimulationRequirment Requirements.SimulationCollection = Requirements.SimulationCollection.empty 
        MassProperties lacm.MassProperties = lacm.MassProperties 
        
        MassPropertiesFileName
        
        CurrentSelListBox = 0
        CurrentSelIndLM   = 0
        CurrentSelIndRQ   = 0
        CurrentSelIndSRQ  = 0
        
        SavedTaskCollectionObjBatch% = lacm.TrimTaskCollectionBatch
        
    end % Public properties
    
    %% Public Observable properties
    properties  (SetObservable) 
        Title
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
    
    %% View Properties
    properties( Hidden = true , Transient = true )
        Container
        EditPanel
        EditGridContainer
        BrowseTrimPB
        NewTrimPB
        TrimText
        TrimEB
        BrowseLMPB
        NewLMPB
%         LMEB 
        BrowseReqPB
        NewReqPB
        ReqText
%         ReqEB 
        BrowseSimReqPB
        NewSimReqPB
        SimReqText
%         SimReqEB 
        
        BrowseStartDir = pwd 
        
        TitleText
        TitleEB
        
        TabContainer
        TabPanel
        
        TabTrim
        TabLM
        TabReq
        TabSim
        LMListComp
        LMListScrollComp
        LMListScrollCont
        ReqListComp
        ReqListScrollComp
        ReqListScrollCont
        SimListComp
        SimListScrollComp
        SimListScrollCont
        
        RemoveLMPB
        RemoveReqPB
        RemoveReqSimPB
        
        UPJButtonComp
        UPJButtonCont
        
        DNJButtonComp
        DNJButtonCont
        
        ButtonContainer
        BrowsePB
        NewPB
        RemovePB
        
        
        LMContainer
        RQContainer
        SIMContainer
        
        LMText
        
        BrowseMPPB
        MPText
        MPEB
        
    end

    %% Data Storage Properties
    properties( Hidden = true )
        
    end

    %% Constant properties
    properties (Constant) 
 
    end % Constant properties  
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end

    %% Methods - Constructor
    methods      
        function obj = AnalysisTask(varargin)
            switch nargin
                case 0
                    
                case 1
                   
                otherwise

            end
            
        end % TrimTask
    end % Constructor

    %% Methods - Property Access
    methods
   
    end % Property access methods
    
    %% Methods - View Protected
    methods %(Access = protected)
        
        function createView(obj,parent)

            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','+UserInterface','Resources' );
            
            
            obj.Parent = parent;
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);%,...
                set(obj.Container,'ResizeFcn',@obj.resizeFcn);
                % Edit Panel
                contPosition = getpixelposition(obj.Container);
                obj.EditPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , contPosition(4) - 75 , contPosition(3) , 75],...%[0,0.7,1,0.3],...
                    'ResizeFcn',@obj.editPanelResize);
                
                     obj.EditGridContainer = uigridcontainer('v0','Parent',obj.EditPanel,...
                        'Units','Normal',...
                        'Position',[0,0,1,1],...
                        'GridSize',[3,4],...
                        'HorizontalWeight',[1,1,2,5],...
                        'VerticalWeight',[1,1,1]);
                    
                        % Title 
                        uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String',' ',...
                            'HorizontalAlignment','Right');
                        uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String',' ',...
                            'HorizontalAlignment','Right');
                        obj.TitleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Title:',...
                            'HorizontalAlignment','Right');
                        obj.TitleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',@obj.updateTitle);
                    
                        % Trim Def
                        obj.BrowseTrimPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Insert',...
                            'Callback',@obj.browseTrim_CB);
                        obj.NewTrimPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Edit',...
                            'Callback',@obj.createTrim_CB);
                        obj.TrimText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Trim Definition:',...
                            'HorizontalAlignment','Right');
                        obj.TrimEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'Enable','Inactive',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'TrimTask'});
                        
                        % Mass Prop
                        obj.BrowseMPPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Insert',...
                            'Callback',{@obj.massPropAdded,true});
                        uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String',' ',...
                            'HorizontalAlignment','Right');
                        obj.MPText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Mass Properties:',...
                            'HorizontalAlignment','Right');
                        obj.MPEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'Enable','Inactive',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.massPropAdded,false});
                        
            obj.ButtonContainer = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[1 , 1 , contPosition(3) / 2 , contPosition(4) - 75]);              
               set(obj.ButtonContainer,'ResizeFcn',@obj.buttonContResizeFcn);         

                        obj.NewPB = uicontrol(...
                            'Parent',obj.ButtonContainer,...
                            'Style','push',...
                            'String','Edit',...
                            'Callback',@obj.edit_CB);
                        obj.RemovePB = uicontrol(...
                            'Parent',obj.ButtonContainer,...
                            'Style','push',...
                            'String','Remove',...
                            'Callback',@obj.remove_CB);  
                        
                        
                        upJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                        upJButtonH = handle(upJButton,'CallbackProperties');
                        upJButton.setText('UP');        
                        set(upJButtonH, 'ActionPerformedCallback',@obj.up_CB)
                        myIcon = fullfile(icon_dir,'LoadedArrow_24_Blue_UP.png');
                        upJButton.setIcon(javax.swing.ImageIcon(myIcon));
                        upJButton.setToolTipText('UP');
                        upJButton.setFlyOverAppearance(true);
                        upJButton.setBorder([]);
                        upJButton.setIconTextGap(2);
                        upJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
                        upJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
                        upJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                        [obj.UPJButtonComp,obj.UPJButtonCont] = javacomponent(upJButton,[ ], obj.ButtonContainer  );  
                        
                        dnJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                        dnJButtonH = handle(dnJButton,'CallbackProperties');
                        dnJButton.setText('DOWN');        
                        set(dnJButtonH, 'ActionPerformedCallback',@obj.dn_CB)
                        myIcon = fullfile(icon_dir,'LoadedArrow_24_Blue.png');
                        dnJButton.setIcon(javax.swing.ImageIcon(myIcon));
                        dnJButton.setToolTipText('DOWN');
                        dnJButton.setFlyOverAppearance(true);
                        dnJButton.setBorder([]);
                        dnJButton.setIconTextGap(2);
                        dnJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
                        dnJButton.setVerticalTextPosition(javax.swing.SwingConstants.TOP);
                        dnJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                        [obj.DNJButtonComp,obj.DNJButtonCont] = javacomponent(dnJButton,[ ], obj.ButtonContainer  );                              
                        
            dist = contPosition(3) / 4;
                        
            obj.LMContainer = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[ dist , 1 , dist , contPosition(4) - 75]);  
            set(obj.LMContainer,'ResizeFcn',@obj.editBoxContResizeFcn); 
            
            obj.RQContainer = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[ dist * 2 , 1 , dist , contPosition(4) - 75]);  
            
            obj.SIMContainer = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[ dist * 3 , 1 , dist , contPosition(4) - 75]);  


                        obj.LMText = uicontrol(...
                            'Parent',obj.LMContainer,...
                            'Style','text',...
                            'String','Linear Model',...
                            'HorizontalAlignment','Center');
                                 
                        obj.LMListComp = javaObjectEDT('javax.swing.JList');
                        LMListCompH = handle(obj.LMListComp,'CallbackProperties');
                        set( LMListCompH, 'ValueChangedCallback', @obj.valueChangeLM_CB );
                        obj.LMListComp.setDragEnabled(true);
                        obj.LMListComp.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_INTERVAL_SELECTION);
                        [obj.LMListScrollComp,obj.LMListScrollCont] = javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.LMListComp)),[], obj.LMContainer  );                   
                        
                        updateList( obj , obj.LinearModelDef , obj.LMListComp );
                        
                        obj.BrowseLMPB = uicontrol(...
                            'Parent',obj.LMContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.browseLM_CB);
                        
                        obj.NewLMPB = uicontrol(...
                            'Parent',obj.LMContainer,...
                            'Style','push',...
                            'String','Create',...
                            'Visible','off',...
                            'Callback',@obj.createLM_CB);


                        obj.ReqText = uicontrol(...
                            'Parent',obj.RQContainer,...
                            'Style','text',...
                            'String','Requirement',...
                            'HorizontalAlignment','Center');

                        obj.ReqListComp = javaObjectEDT('javax.swing.JList');
                        ReqListCompH = handle(obj.ReqListComp,'CallbackProperties');
                        set( ReqListCompH, 'ValueChangedCallback', @obj.valueChangeRQ_CB );
                        obj.ReqListComp.setDragEnabled(true);
                        obj.ReqListComp.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_INTERVAL_SELECTION);
                        [obj.ReqListScrollComp,obj.ReqListScrollCont] = javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.ReqListComp)),[ ], obj.RQContainer  );                   
                        
                        updateReqList( obj , obj.Requirement , obj.ReqListComp );
                        
                        obj.BrowseReqPB = uicontrol(...
                            'Parent',obj.RQContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.browseReq_CB);
                        
                        obj.NewReqPB = uicontrol(...
                            'Parent',obj.RQContainer,...
                            'Style','push',...
                            'String','Create',...
                            'Visible','off',...
                            'Callback',@obj.createReq_CB);

                        
                        obj.SimReqText = uicontrol(...
                            'Parent',obj.SIMContainer,...
                            'Style','text',...
                            'String','Simulation',...
                            'HorizontalAlignment','Center');
%                     
                        obj.SimListComp = javaObjectEDT('javax.swing.JList');
                        SReqListCompH = handle(obj.SimListComp,'CallbackProperties');
                        set( SReqListCompH, 'ValueChangedCallback', @obj.valueChangeSRQ_CB );
                        obj.SimListComp.setDragEnabled(true);
                        obj.SimListComp.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_INTERVAL_SELECTION);
                        [obj.SimListScrollComp,obj.SimListScrollCont] = javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.SimListComp)),[ ], obj.SIMContainer  );                   
%                         obj.SimListComp.setDragEnabled(true);
                        updateSimList( obj , obj.SimulationRequirment , obj.SimListComp );
                        
                        obj.BrowseSimReqPB = uicontrol(...
                            'Parent',obj.SIMContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.browseSimReq_CB);  
                        
                        obj.NewSimReqPB = uicontrol(...
                            'Parent',obj.SIMContainer,...
                            'Style','push',...
                            'String','Create',...
                            'Visible','off',...
                            'Callback',@obj.createSimReq_CB);                       
                           
            update(obj);
            resizeFcn( obj , [] , [] );
            editBoxContResizeFcn( obj , obj.LMContainer , [] );
        end % createView
        
        
        
 
    end % Protected View Methods
      
    %% Methods - Callbacks
    methods 
        
        function valueChangeLM_CB( obj , hobj , ~ )
            obj.CurrentSelListBox = 1;
            obj.CurrentSelIndLM  = hobj.getSelectedIndex;
            linearModelColSelected( obj );
        end % valueChangeLM_CB
        
        function valueChangeRQ_CB( obj , hobj , ~ )
            obj.CurrentSelListBox = 2;
            obj.CurrentSelIndRQ  = hobj.getSelectedIndex;
            reqColSelected( obj );
        end % valueChangeRQ_CB      
        
        function valueChangeSRQ_CB( obj , hobj , ~ )
            obj.CurrentSelListBox = 3;
            obj.CurrentSelIndSRQ = hobj.getSelectedIndex;
            simColSelected( obj );
        end % valueChangeSRQ_CB   
                
        function up_CB( obj , hobj , eventdata )
            switch obj.CurrentSelListBox
                case 1 % Linear Model
                    if obj.CurrentSelIndLM ~= 0
                        previousIndex = obj.CurrentSelIndLM;
                        obj.CurrentSelIndLM = obj.CurrentSelIndLM - 1;
                        a= obj.CurrentSelIndLM + 1;
                        b= previousIndex + 1;
                        obj.LinearModelDef([a , b]) = obj.LinearModelDef([b , a ]);
                        updateList( obj , obj.LinearModelDef , obj.LMListComp );
                    end
                case 2 % Req
                    if obj.CurrentSelIndRQ ~= 0
                        previousIndex = obj.CurrentSelIndRQ;
                        obj.CurrentSelIndRQ = obj.CurrentSelIndRQ - 1;
                        a= obj.CurrentSelIndRQ + 1;
                        b= previousIndex + 1;
                        obj.Requirement([a , b]) = obj.Requirement([b , a ]);
                        updateReqList( obj , obj.Requirement , obj.ReqListComp );
                    end    
                case 3 % Sim
                    if obj.CurrentSelIndSRQ ~= 0
                        previousIndex = obj.CurrentSelIndSRQ;
                        obj.CurrentSelIndSRQ = obj.CurrentSelIndSRQ - 1;
                        a= obj.CurrentSelIndSRQ + 1;
                        b= previousIndex + 1;
                        obj.SimulationRequirment([a , b]) = obj.SimulationRequirment([b , a ]);
                        updateSimList( obj , obj.SimulationRequirment , obj.SimListComp );
                    end      
            end
                
        end % up_CB
        
        function dn_CB( obj , hobj , eventdata )
            
            switch obj.CurrentSelListBox
                case 1 % Linear Model
                    if obj.CurrentSelIndLM ~= length(obj.LinearModelDef) - 1
                        previousIndex = obj.CurrentSelIndLM;
                        obj.CurrentSelIndLM = obj.CurrentSelIndLM + 1;
                        a= obj.CurrentSelIndLM + 1;
                        b= previousIndex + 1;
                        obj.LinearModelDef([a , b]) = obj.LinearModelDef([b , a ]);
                        updateList( obj , obj.LinearModelDef , obj.LMListComp );
                    end
                case 2 % Req
                    if obj.CurrentSelIndRQ ~= length(obj.Requirement) - 1
                        previousIndex = obj.CurrentSelIndRQ;
                        obj.CurrentSelIndRQ = obj.CurrentSelIndRQ + 1;
                        a= obj.CurrentSelIndRQ + 1;
                        b= previousIndex + 1;
                        obj.Requirement([a , b]) = obj.Requirement([b , a ]);
                        updateReqList( obj , obj.Requirement , obj.ReqListComp );
                    end   
                case 3 % Sim
                    if obj.CurrentSelIndSRQ ~= length(obj.Requirement) - 1
                        previousIndex = obj.CurrentSelIndSRQ;
                        obj.CurrentSelIndSRQ = obj.CurrentSelIndSRQ + 1;
                        a= obj.CurrentSelIndSRQ + 1;
                        b= previousIndex + 1;
                        obj.SimulationRequirment([a , b]) = obj.SimulationRequirment([b , a ]);
                        updateSimList( obj , obj.SimulationRequirment , obj.SimListComp );
                    end       
            end  
        end % dn_CB
        
        function updateTitle( obj , hobj , ~ )
            obj.Title = hobj.String;
        end % updateTitle
        
        function browseTrim_CB( obj , hobj , eventdata )
            [filename, pathname] = uigetfile({'*.mat'},'Select Trim Definition File:',fullfile(obj.BrowseStartDir,obj.TrimTask.Label));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                
                                    
                varStruct = load(fullfile(pathname,filename));
                varNames = fieldnames(varStruct);
                if length(varNames) > 1
                    msgbox({'The file you are attempting to load contains one',...
                        'or more variables with the incorrect format'...
                        'The variable ',varNames{1},' will not be loaded.'},...
                        'Name Conflict','error')
                    return;
                end
                obj.TrimTask = varStruct.(varNames{1});
                update(obj);
            end
        end %browseTrim_CB
        
        function createTrim_CB( obj , hobj , eventdata )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',obj.TrimTask);%,'ShowLoadButton',false);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end %showTrim_CB
        
        function edit_CB( obj , hobj , eventdata )
%             setWaitPtr(obj);   
            
            switch obj.CurrentSelListBox
                case 1 % Linear Model
                    reqDefObj = obj.LinearModelDef(obj.CurrentSelIndLM + 1);
                case 2 % Req
                    reqDefObj = obj.Requirement(obj.CurrentSelIndRQ + 1);
                case 3 % Sim
                    reqDefObj = obj.SimulationRequirment(obj.CurrentSelIndSRQ + 1);
                otherwise
                    return;
            end

            reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',true,'Requirement',reqDefObj);
            addlistener(reqEditObj,'ObjectLoaded',@(src,event) obj.objEdited(src,event));
        
%             releaseWaitPtr(obj);  
        end % edit_CB
        
        function objEdited( obj , ~ , eventdata )
      
            switch obj.CurrentSelListBox
                case 1 % Linear Model
                    obj.LinearModelDef(obj.CurrentSelIndLM + 1) = eventdata.Object;
                case 2 % Req
                    obj.Requirement(obj.CurrentSelIndRQ + 1) = eventdata.Object;
                case 3 % Sim
                    obj.SimulationRequirment(obj.CurrentSelIndSRQ + 1) = eventdata.Object;
                otherwise
                    return;
            end
%             notify(obj,'SaveProjectEvent');   
        end % objEdited  
        
        function remove_CB( obj , hobj , eventdata )
            
            switch obj.CurrentSelListBox
                case 1 % Linear Model
                    obj.LinearModelDef(obj.CurrentSelIndLM + 1) = [];
                    updateList(obj , obj.LinearModelDef , obj.LMListComp );
                case 2 % Req
                    obj.Requirement(obj.CurrentSelIndRQ + 1) = [];
                    updateReqList( obj , obj.Requirement , obj.ReqListComp );
                case 3 % Sim
                    obj.SimulationRequirment(obj.CurrentSelIndSRQ + 1) = [];
                    updateSimList( obj , obj.SimulationRequirment , obj.SimListComp )
                otherwise
                    return;
            end
            update(obj);
        end %remove_CB    
        
        function browseLM_CB( obj , hobj , eventdata )
            [filename, pathname] = uigetfile({'*.mat'},'Select LInear Model Definition File:',fullfile(obj.BrowseStartDir,obj.LinearModelDef.Label),'MultiSelect', 'on');
            drawnow();pause(0.5);
            if ~isequal(filename,0)
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

                        if ~isa(varStruct.(varNames{i}),'lacm.LinearModel')
                            msgbox({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','error')
                            continue;
                        end
                       % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))  
                            obj.LinearModelDef(end + 1) = varStruct.(varNames{i})(mult);
                        end
                    end
                end
                
                updateList(obj , obj.LinearModelDef , obj.LMListComp );
                update(obj);
            end
        end %browseLM_CB
        
        function createLM_CB( obj , hobj , eventdata )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',lacm.LinearModel);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end %showLM_CB
        
        function removeLM_CB( obj , hobj , eventdata )

        end %removeLM_CB   
        
        function browseReq_CB( obj , hobj , eventdata )
            [filename, pathname] = uigetfile({'*.mat'},'Select Req File:',fullfile(obj.BrowseStartDir,obj.Requirement.Title),'MultiSelect', 'on');
            drawnow();pause(0.5);
            if ~isequal(filename,0)
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

                        if ~isa(varStruct.(varNames{i}),'Requirements.RequirementTypeOne')
                            msgbox({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','error')
                            continue;
                        end
                       % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))  
                            obj.Requirement(end + 1) = varStruct.(varNames{i})(mult);
                        end
                    end
                end
                
                updateReqList( obj , obj.Requirement , obj.ReqListComp );
                update(obj);

            end
        end %browseReq_CB
        
        function createReq_CB( obj , hobj , eventdata )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.RequirementTypeOne);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end %showReq_CB
        
        function removeReq_CB( obj , hobj , eventdata )

        end %removeReq_CB   
        
        function browseSimReq_CB( obj , hobj , eventdata )
            [filename, pathname] = uigetfile({'*.mat'},'Select Simulation Requirement File:',fullfile(obj.BrowseStartDir,obj.SimulationRequirment.Title),'MultiSelect', 'on');
            drawnow();pause(0.5);
            if ~isequal(filename,0)
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
                        if ~isa(varStruct.(varNames{i}),'Requirements.SimulationCollection')
                            msgbox({'The file you are attempting to load contains one',...
                                'or more variables with the incorrect format'...
                                'The variable ',varNames{i},' will not be loaded.'},...
                                'Name Conflict','error')
                            continue;
                        end
                       % add to requirement object array
                        for mult = 1:length(varStruct.(varNames{i}))  
                            obj.SimulationRequirment(end + 1) = varStruct.(varNames{i})(mult);
                        end
                    end
                end
                updateSimList( obj , obj.SimulationRequirment , obj.SimListComp );
                update(obj);
                

            end
        end %browseSimReq_CB
        
        function createSimReq_CB( obj , hobj , eventdata )
            reqEditObj = UserInterface.ObjectEditor.Editor('SimRequirement',Requirements.SimulationCollection);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end %showSimReq_CB   
        
        function removeSimReq_CB( obj , hobj , eventdata )

        end %removeSimReq_CB   
        
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function massPropAdded( obj , ~ , eventdata , browse )
%             reqObj = eventdata.Object;
            if browse
%                 choice = questdlg('Mass Properties will be reset in all Run Cases. Continue?', ...
%                     'Mass Properties', ...
%                     'Yes','No','Yes');
%                 switch choice
%                     case 'Yes'
%                          % Do nothing and continue
%                     otherwise
%                         return; % Return
%                 end

                [filename, pathname] = uigetfile({'*.mat;*.txt','Mass Properties:'},['Select Object File (lacm.MassProperty):'],obj.BrowseStartDir,'MultiSelect', 'off');

                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                
                
                
                                  
                [~,~,extCheck] = fileparts(filename) ;
                 
                if strcmp(extCheck,'.mat')
                    varStruct = load(fullfile(pathname,filename));
                    varNames = fieldnames(varStruct);
                else
                    newMassPropObj = lacm.MassProperties(fullfile(pathname,filename));
                    varStruct.MassPropObj = newMassPropObj;
                    varNames = fieldnames(varStruct);
                end
                newObj = lacm.MassProperties.empty;
                for i = 1:length(varNames)
                    if ~isa(varStruct.(varNames{i}),'lacm.MassProperties')
                        msgbox({'The file you are attempting to load contains one',...
                            'or more variables with the incorrect format'...
                            'The variable ',varNames{i},' will not be loaded.'},...
                            'Name Conflict','error')
                        return;
                    end
                    % add to requirement object array
                    for mult = 1:length(varStruct.(varNames{i}))     
                        newObj(end+1) = varStruct.(varNames{i})(mult);
                    end
                 end
                 
                 obj.MassProperties = newObj;   
                 obj.MassPropertiesFileName = filename;
            end
            update(obj);

        end % massPropAdded
        
        function linearModelColSelected( obj )
            obj.ReqListComp.clearSelection();
            obj.CurrentSelIndRQ = 0;
            
            obj.SimListComp.clearSelection();
            obj.CurrentSelIndSRQ = 0;
        end %linearModelColSelected
        
        function reqColSelected( obj )
            obj.LMListComp.clearSelection();
            obj.CurrentSelIndLM = 0;
            
            obj.SimListComp.clearSelection();
            obj.CurrentSelIndSRQ = 0; 
        end %reqColSelected
        
        function simColSelected( obj )
            obj.LMListComp.clearSelection();
            obj.CurrentSelIndLM = 0;    
            
            obj.ReqListComp.clearSelection();
            obj.CurrentSelIndRQ = 0;
        end %simColSelected
        
        function updateList( obj , object , component )
            listModel = javaObjectEDT('javax.swing.DefaultListModel');
            for i = 1:length(object)
                listModel.addElement(object(i).Label);
            end
            component.setModel(listModel);
            component.setSelectedIndex(obj.CurrentSelIndLM);
        end % updateList

        function updateReqList( obj , object , component )
            listModel = javaObjectEDT('javax.swing.DefaultListModel');
            for i = 1:length(object)
                listModel.addElement(object(i).Title);
            end
            component.setModel(listModel);
            component.setSelectedIndex(obj.CurrentSelIndRQ);
        end % updateReqList
        
        function updateSimList( obj , object , component )
            listModel = javaObjectEDT('javax.swing.DefaultListModel');
            for i = 1:length(object)
                listModel.addElement(object(i).Title);
            end
            component.setModel(listModel);
            component.setSelectedIndex(obj.CurrentSelIndSRQ);
        end % updateSimList
        
        function reqUpdate( obj , hobj , ~ , type )
            value = get(hobj,'String');
            testValue = str2double(value);
            if length(testValue) == 1 && isnan(testValue)
                newValue = value;
            else
                newValue = testValue;
            end
            obj.(type) = newValue;

            update(obj);

        end % reqUpdate
        
        function update( obj )
            obj.TitleEB.String = obj.Title;
            obj.TrimEB.String = obj.TrimTask.Label;
%             obj.MPEB.String = obj.MassProperties.Label;
            obj.MPEB.String = obj.MassPropertiesFileName;
%             obj.LMEB.String = obj.LinearModelDef.Label;
%             obj.ReqEB.String = obj.Requirement.Title;
%             obj.SimReqEB.String = obj.SimulationRequirment.Title;

        end % update  
                
        function reqObjCreated( obj , ~ , eventdata )
            reqObj = eventdata.Object;
            switch class(reqObj)
                case 'lacm.TrimSettings'
                    obj.TrimTask = reqObj;  
                case 'lacm.LinearModel'
                    obj.TrimTask = reqObj;
                case 'Requirements.RequirementTypeOne'
                    obj.TrimTask = reqObj;
                case 'Requirements.SimulationCollection'
                    obj.SimulationRequirment = reqObj;
                case 'Requirements.RequirementTypeOnePost'

            end
            update(obj);
%             autoSaveFile( obj , [] , [] );
        end % reqObjCreated
              
    end % Ordinary Methods
    
    
    %% Methods - Private
    methods (Access = private)    
          
        
    end    
    
    %% Methods - Resize Protected
    methods (Access = protected) 
        
        function editPanelResize( obj , ~ , ~ )
  
        end % editPanelResize
        
        function resizeFcn( obj , ~ , ~ )
            % get figure position
            
            contPosition = getpixelposition(obj.Container);
            dist = contPosition(3) / 4;
            
            set(obj.EditPanel,'Units','Pixels');
            set(obj.EditPanel,'Position',[1 , contPosition(4) - 75 , contPosition(3) , 75] );
            set(obj.TabContainer,'Units','Pixels');
            set(obj.TabContainer,'Position',[contPosition(3) / 3 , 1 , 2 * (contPosition(3) / 3) , contPosition(4) - 75] );
            set(obj.ButtonContainer,'Units','Pixels',...
                'Position',[1 , 1 , contPosition(3) / 3 , contPosition(4) - 75]); 
            set(obj.LMContainer,'Units','Pixels',...
                'Position',[ dist , 1 , dist , contPosition(4) - 75]); 
            set(obj.RQContainer,'Units','Pixels',...
                'Position',[ dist * 2 , 1 , dist , contPosition(4) - 75]); 
            set(obj.SIMContainer,'Units','Pixels',...
                'Position',[ dist * 3 , 1 , dist , contPosition(4) - 75]); 
                 
        end % resizeFcn
        
        function tabContResizeFcn( obj , hobj , ~ )
            % get figure position
            position = getpixelposition(hobj);
            
            set(obj.LMListScrollCont, 'Units','Pixels','Position',[1 , 1 , position(3) , position(4) ]); 
            set(obj.ReqListScrollCont,'Units','Pixels','Position',[1 , 1 , position(3) , position(4) ]); 
            set(obj.SimListScrollCont,'Units','Pixels','Position',[1 , 1 , position(3) , position(4) ]);         
        end % tabContResizeFcn 
        
         function editBoxContResizeFcn( obj , hobj , ~ )
            % get figure position
            position = getpixelposition(hobj);
            
            offset = 0;
            
            set(obj.LMText, 'Units','Pixels','Position',[1 , position(4) - 25 , position(3) , 15 ]); 
            set(obj.LMListScrollCont, 'Units','Pixels','Position',[5 , 65 + offset , position(3) - 10 , position(4) -  90 - offset]); 
            set(obj.BrowseLMPB,'Units','Pixels','Position',[5 , 35 + offset , position(3) - 10 , 25 ]); 
            set(obj.NewLMPB,'Units','Pixels','Position',[5 , 5 + offset , position(3) - 10 , 25 ]); 
            
            
            set(obj.ReqText, 'Units','Pixels','Position',[1 , position(4) - 25 , position(3) , 15 ]); 
            set(obj.ReqListScrollCont, 'Units','Pixels','Position',[5 , 65 + offset , position(3) - 10 , position(4) -  90 - offset]); 
            set(obj.BrowseReqPB,'Units','Pixels','Position',[5 , 35 + offset , position(3) - 10 , 25 ]); 
            set(obj.NewReqPB,'Units','Pixels','Position',[5 , 5 + offset , position(3) - 10 , 25 ]); 
            
            
            set(obj.SimReqText, 'Units','Pixels','Position',[1 , position(4) - 25 , position(3) , 15 ]); 
            set(obj.SimListScrollCont, 'Units','Pixels','Position',[5 , 65 + offset , position(3) - 10 , position(4) -  90 - offset]); 
            set(obj.BrowseSimReqPB,'Units','Pixels','Position',[5 , 35 + offset , position(3) - 10 , 25 ]);    
            set(obj.NewSimReqPB,'Units','Pixels','Position',[5 , 5 + offset , position(3) - 10 , 25 ]);
            
        end % tabContResizeFcn 
        
        function buttonContResizeFcn( obj , hobj , ~ )
            % get figure position
            position = getpixelposition(hobj);
            
%             set(obj.BrowsePB,'Units','Pixels','Position',[15 , position(4) - 60 , 60 , 25 ]); 
            set(obj.NewPB,'Units','Pixels','Position',[15 , position(4) - 60 , 60 , 25 ]); 
            set(obj.RemovePB,'Units','Pixels','Position',[15 , position(4) - 90 , 60 , 25 ]); 
            set(obj.UPJButtonCont,'Units','Pixels','Position',[15 , position(4) - 190 , 60 , 50 ]); 
            set(obj.DNJButtonCont,'Units','Pixels','Position',[ 15 , position(4) - 250 , 60 , 50 ]); 


        end % buttonContResizeFcn 
        
    end
    
    %% Method - Static
    methods ( Static )
     
    end
        
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the TrimTask object
%             cpObj.TrimTask = copy(obj.TrimTask);    
            
        end
    end
    
end

