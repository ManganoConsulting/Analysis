classdef Main < UserInterface.Level1Container %matlab.mixin.Copyable
    %% Public properties - Object Handles
    properties   
        RibbonObj UserInterface.StabilityControl.ToolRibbon
        TaskCollectionObj lacm.TrimTaskCollection
        TaskCollectionObjBatch lacm.TrimTaskCollectionBatch
        
        
        OperCondCollObj UserInterface.StabilityControl.OCCStabControl
        Tree UserInterface.StabilityControl.StabTree
        AxisColl UserInterface.AxisPanelCollection
        SimAxisColl = SimViewer.Main.empty 
        PostSimAxisColl UserInterface.AxisPanelCollection
        ConstantsParamColl UserInterface.ControlDesign.ParameterCollection
        AutoSave = false
        AutoSaveFileName
        
        DropTarget
    end

    %% Public properties - Analysis Object Handles
    properties (Transient = true)
        
        AnalysisObjects =  lacm.AnalysisTask.empty;
    end % Public properties
    
    %% Public properties - Graphics Handles
    properties (Transient = true)
        TaskCollectionCardPanel UserInterface.CardPanel
        BrowserPanel
        SmallPanel
        LargePanel
        TaskPanel 
        TabPanel
        TabManual  
        TabConstants 
        ProjectLabelComp
        ProjectLabelCont 
        SettingsLabelComp = javahandle_withcallbacks.javax.swing.JLabel
        SettingsLabelCont 
        ConstantTable  
        AnalysisTabGroub  
        AnalysisTabArray
        TaskObjContainer
        OperCondContainer
        
        RibbonCardPanel
    end % Public properties
  
    %% Public properties - Data Storage
    properties 
        SimulationOutputData
        OperatingConditionForSimData
        
        SelectedTab
        AppendData = true   
        
        ConstantTableData
        AnalysisTabSelIndex
        RunSignalLog = false
        Units = 'English - US'
        
        ShowLoggedSignalsState = false
        ShowInvalidTrimState = 1
        UseAllCombinationsState = true
        UseExistingTrimState = false

        % When true the original Microsoft Word based report generation is
        % used.  When false a new open-source report generator is used that
        % creates HTML or PDF reports without relying on proprietary
        % software.
        UseLegacyReport = true

        NumberOfPlotPerPagePostPlts= 4
        NumberOfPlotPerPagePlts = 4
        
        TrimSettings UserInterface.StabilityControl.TrimOptions = UserInterface.StabilityControl.TrimOptions(0)
    end % Public properties
        
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
        ProjectType = 'Dynamics'
    end % Constant properties  
    
    %% Events
    events

    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = Main(figH,licH,ver,internalver)  
        
            warning('off','MATLAB:uitree:DeprecatedFunction')
            % Create Application Data Folder
            if ~exist(obj.ApplicationDataFolder, 'dir')
                mkdir(obj.ApplicationDataFolder);
            end
            
            switch nargin 
                case 0
                    createView(obj); 
                case 4
                    obj.VersionNumber = ver;
                    obj.InternalVersionNumber = internalver;                                   
                    obj.Granola = licH;
                    createView(obj,figH); 
            end
        end % Main
    end % Constructor

    %% Methods - Property Access
    methods
                      
    
    end % Property access methods
    
    %% Methods - View
    methods 
        
        function createView(obj,parent)
            import Utilities.*
       
            if nargin == 1
                createView@UserInterface.Level1Container(obj);
            else
                createView@UserInterface.Level1Container(obj,parent);
            end

            % Adust default ribbon panel
            position = getpixelposition(obj.Parent);
       
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , position(4) - 93 , 860, 93 ]);
            
            obj.RibbonCardPanel = UserInterface.CardPanel(0,'Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ 860 , position(4) - 93 , position(3) - 860 , 93 ]);
            
             % Create Ribbon Object
            obj.RibbonObj = UserInterface.StabilityControl.ToolRibbon(obj.RibbonPanel,obj.VersionNumber,obj.InternalVersionNumber,obj.TrimSettings);
            addlistener(obj.RibbonObj,'SaveWorkspace',@obj.saveWorkspace);
            addlistener(obj.RibbonObj,'LoadWorkspace',@obj.loadWorkspace);
            addlistener(obj.RibbonObj,'LoadConfiguration',@obj.loadConfiguration);
            addlistener(obj.RibbonObj,'NewConfiguration',@obj.newConfiguration);
            addlistener(obj.RibbonObj,'Run',@obj.runTask);
            addlistener(obj.RibbonObj,'RunSave',@obj.runTaskAndSave);
            addlistener(obj.RibbonObj,'LoadBatchRun',@obj.loadBatchRun);
            addlistener(obj.RibbonObj,'UnitsChanged',@obj.unitsChanged);
            addlistener(obj.RibbonObj,'ClearTable',@obj.clearTable);
            addlistener(obj.RibbonObj,'SaveOperCond',@obj.saveOperCond);
            addlistener(obj.RibbonObj,'NewTrimObject',@obj.newTrimObj_CB);
            addlistener(obj.RibbonObj,'NewLinearModelObject',@obj.newLinMdlObj_CB);
            addlistener(obj.RibbonObj,'NewMethodObject',@obj.newMethodObj_CB);
            addlistener(obj.RibbonObj,'NewSimulationReqObject',@obj.newSimulationObj_CB);
            addlistener(obj.RibbonObj,'OpenObject',@obj.openObjInEditor_CB);
            addlistener(obj.RibbonObj,'NewProject',@obj.newProject_CB);
            addlistener(obj.RibbonObj,'LoadProject',@obj.loadProject_CB);
            addlistener(obj.RibbonObj,'CloseProject',@obj.closeProject_CB); 
%             addlistener(obj.RibbonObj,'ShowInvalidTrim',@obj.showInvalidTrim_CB);
            addlistener(obj.RibbonObj,'ShowLogSignals',@obj.showLogSignals_CB);
            addlistener(obj.RibbonObj,'UseAllCombinations',@obj.useAllCombinations_CB);
            addlistener(obj.RibbonObj,'Add2Batch',@obj.addBatch2AnalysisNode_CB);
            addlistener(obj.RibbonObj,'ExportTable',@obj.exportTable_CB);
            addlistener(obj.RibbonObj,'GenerateReport',@obj.generateReport_CB);
            addlistener(obj.RibbonObj,'NewAnalysis',@obj.newAnalysisObj_CB);
            addlistener(obj.RibbonObj,'LoadAnalysisObject',@obj.loadAnalysisObj);            
            addlistener(obj.RibbonObj,'SetNumPlotsPlts',@obj.setNumPlotsPlts);
            addlistener(obj.RibbonObj,'SetNumPlotsPostPlts',@obj.setNumPlotsPostPlts);
            addlistener(obj.RibbonObj,'ShowTrimsChanged',@obj.showTrims_CB);
            addlistener(obj.RibbonObj,'TrimSettingsChanged',@obj.trimSettings_CB);
            
            
            % Update toolRibon trim settings
            
            
            % Set toolribbon checkboxes
            setShowLoggedSignals(obj.RibbonObj, obj.ShowLoggedSignalsState);
            setShowInvalidTrim(obj.RibbonObj, obj.ShowInvalidTrimState);
            setUseAllCombinations(obj.RibbonObj, obj.UseAllCombinationsState);

            % Create Main Container

            mpPos = UserInterface.Utilities.getPosInPixels(obj.MainPanel);
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Project</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ProjectLabelComp,obj.ProjectLabelCont] = javacomponent(jLabelview,[ 1 , mpPos(4) - 16 , 200 , 16 ], obj.MainPanel );
            

            obj.BrowserPanel = uipanel('Parent',obj.MainPanel,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 1 , 1 , 200 , mpPos(4) - 16 ]);

            
            obj.LargePanel = uipanel('Parent',obj.MainPanel,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 201 , 1 , mpPos(3) - 201 , mpPos(4) ]);
%             test=SimViewer.Main('Parent',obj.LargePanel); 
            if isempty(obj.Tree)
                obj.Tree = UserInterface.StabilityControl.StabTree(obj.BrowserPanel);
                %addTreeListners( obj );
            else
                obj.Tree.restoreTree(obj.BrowserPanel);
            end
            
            % Create Tab sections for Analysis Objects
            obj.AnalysisTabGroub = uitabgroup('Parent',obj.LargePanel);
            obj.AnalysisTabGroub.TabLocation = 'Top';
            obj.AnalysisTabGroub.SelectionChangedFcn = @obj.analysisTabChanged;
            

            
            % Force user to either create a project or open a project
            % Launch StartUp Screen
            reSize( obj , [] , [] );

            addMainListners( obj );
            
  
        end % createView
        
        function addTreeListners( obj ) 

            
            % Tree Listners
            addlistener(obj.Tree,'SelectedPropChanged',@obj.updateTask);
            addlistener(obj.Tree,'SimulinkModelChanged',@obj.modelChanged);
            addlistener(obj.Tree,'NewAnalysis',@obj.newAnalysisObj_CB);
            addlistener(obj.Tree,'NewTrimDef',@obj.newTrimObj_CB);
            addlistener(obj.Tree,'NewLinMdlDef',@obj.newLinMdlObj_CB);
            addlistener(obj.Tree,'NewReqDef',@obj.newMethodObj_CB);
            addlistener(obj.Tree,'NewSimReqDef',@obj.newSimulationObj_CB);
            addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
            addlistener(obj.Tree,'SaveProjectEvent',@obj.autoSaveFile);
            addlistener(obj.Tree,'AnalysisObjectAdded',@obj.addAnalysisObject);
            addlistener(obj.Tree,'ReloadConstantFile',@obj.updateConstantTableData);
            addlistener(obj.Tree,'AnalysisObjectSelected',@obj.analysisObjSelectedInTree);
            addlistener(obj.Tree,'ConstantFileUpdated',@obj.addNewConstantParameters); 
            addlistener(obj.Tree,'AnalysisObjectDeleted',@obj.analysisObjRemovedInTree);
            addlistener(obj.Tree,'MassPropertyAdded',@obj.analysisTaskUpdatedMassProp);
            addlistener(obj.Tree,'BatchNodeSelected',@obj.batchNodeSelected);
            addlistener(obj.Tree,'BatchNodesRemoved',@obj.batchNodesRemoved);    
            addlistener(obj.Tree,'AnalysisObjectSaved',@obj.analysisObjectSaved);
            addlistener(obj.Tree,'AnalysisObjectEdited',@obj.analysisObjectEdited);

        end % addTreeListners
        
        function addMainListners( obj ) 

            addlistener(obj.OperCondCollObj,'ShowLogMessage',@obj.showLogMessage_CB);             
            % Tree Listners
            addlistener(obj.Tree,'SelectedPropChanged',@obj.updateTask);
            addlistener(obj.Tree,'SimulinkModelChanged',@obj.modelChanged);
            addlistener(obj.Tree,'NewAnalysis',@obj.newAnalysisObj_CB);
            addlistener(obj.Tree,'NewTrimDef',@obj.newTrimObj_CB);
            addlistener(obj.Tree,'NewLinMdlDef',@obj.newLinMdlObj_CB);
            addlistener(obj.Tree,'NewReqDef',@obj.newMethodObj_CB);
            addlistener(obj.Tree,'NewSimReqDef',@obj.newSimulationObj_CB);
            addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
            addlistener(obj.Tree,'SaveProjectEvent',@obj.autoSaveFile);
            addlistener(obj.Tree,'AnalysisObjectAdded',@obj.addAnalysisObject);
            addlistener(obj.Tree,'ReloadConstantFile',@obj.updateConstantTableData);
            addlistener(obj.Tree,'AnalysisObjectSelected',@obj.analysisObjSelectedInTree);
            addlistener(obj.Tree,'ConstantFileUpdated',@obj.addNewConstantParameters); 
            addlistener(obj.Tree,'AnalysisObjectDeleted',@obj.analysisObjRemovedInTree);
            addlistener(obj.Tree,'MassPropertyAdded',@obj.analysisTaskUpdatedMassProp);
            addlistener(obj.Tree,'BatchNodeSelected',@obj.batchNodeSelected);
            addlistener(obj.Tree,'BatchNodesRemoved',@obj.batchNodesRemoved);
            addlistener(obj.Tree,'AnalysisObjectSaved',@obj.analysisObjectSaved);
            addlistener(obj.Tree,'AnalysisObjectEdited',@obj.analysisObjectEdited);
            addlistener(obj.Tree,'UseExistingTrim',@obj.useExistingTrim);
            
            
            % Task Collection Listners
            for i = 1:length(obj.TaskCollectionObj)
                addlistener(obj.TaskCollectionObj(i),'ShowLogMessage',@obj.showLogMessage_CB);
            end
            
            addlistener(obj,'LoadedProjectName','PostSet',@obj.setFileTitle);
            addlistener(obj,'ProjectSaved','PostSet',@obj.setFileTitle);   
        end % addMainListners
        
        function createAnalysisView( obj , ind , analysisObj )
            
            
            
            obj.AnalysisTabArray(ind)  = uitab('Parent',obj.AnalysisTabGroub);
            set(obj.AnalysisTabArray(ind),'Title',analysisObj.Title);
            
            mpPos = UserInterface.Utilities.getPosInPixels(obj.MainPanel);
            
            % Create Task Container
            obj.TaskObjContainer(ind) = uicontainer('Parent',obj.AnalysisTabArray(ind),'Units','Pixels','Position',[ 1 , 1 , 352 , mpPos(4) - 3 ]);
            set(obj.TaskObjContainer(ind),'ResizeFcn',@obj.smallPanelResize);
            parentPos = UserInterface.Utilities.getPosInPixels(obj.TaskObjContainer(ind));
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Trim Settings</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.SettingsLabelComp(ind),obj.SettingsLabelCont(ind)] = javacomponent(jLabelview,[ 1 , parentPos(4) - 16 , parentPos(3) , 16 ], handle(obj.TaskObjContainer(ind)) );
            
            obj.TaskPanel(ind) = uicontainer('Parent',obj.TaskObjContainer(ind),'Units','pixels','Position',[ 1 , 1 , parentPos(3) , parentPos(4)-16 ]); %[ 1 , 50 , parentPos(3) , parentPos(4) - 50 ]); 
            % Create Main Tab Group
            obj.TabPanel(ind) = uitabgroup('Parent',obj.TaskPanel(ind));
            set(obj.TabPanel(ind),'SelectionChangedFcn',@obj.tabPanel_CB); 

                % Manual Tab
                obj.TabManual(ind)   = uitab('Parent',obj.TabPanel(ind));
                set(obj.TabManual(ind),'Title',' Manual');
                obj.SelectedTab = obj.TabManual(ind);
              
                
                % Constants Tab
                obj.TabConstants(ind)   = uitab('Parent',obj.TabPanel(ind));
                set(obj.TabConstants(ind),'Title','Parameters');
                
                      
                
            % Create Objects
            % Create Card Panel
            % Create a Batch collection Object
%             obj.TaskCollectionObjBatch(ind) = lacm.TrimTaskCollectionBatch;    
%             obj.TaskCollectionCardPanel(ind) = UserInterface.CardPanel(1,'Parent',obj.TabManual(ind));
%             obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1) = lacm.TrimTaskCollection( obj.TaskCollectionCardPanel(ind).Panel(1), {''}, 'Run 1') ; 
%             updateSelectedConfiguration(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1),analysisObj.TrimTask);
%             uuid = obj.Tree.addBatchObj( obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1) , ind , 'Run 1' );
%             obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1).UUID = uuid;

                % Create Objects
                numCards = length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj);
                obj.TaskCollectionCardPanel(ind) = UserInterface.CardPanel(numCards,'Parent',obj.TabManual(ind));
                for i = 1:numCards 
                    createView(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),{''},obj.TaskCollectionCardPanel(ind).Panel(i));
                    updateSelectedConfiguration(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i), analysisObj.TrimTask);%obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).SelectedTrimDef);% analysisObjs(ind).TrimTask);
                    addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'ShowLogMessage',@obj.showLogMessage_CB);
                    uuid = obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).UUID;
                    addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'LabelUpdated',  @(src,event) obj.batchObjLabelUpdated(src,event,uuid)); 
                end
                

%             for i = 1:length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj)
%                 
%                 obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).createView(obj.TaskCollectionCardPanel(ind).Panel(1), {''}, 'Run 1');
%                 
%             end
            
            
            
            
            addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1),'ShowLogMessage',@obj.showLogMessage_CB);
            addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1),'ShowLogMessage',@obj.showLogMessage_CB);   
            addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1),'LabelUpdated',@(src,event) obj.batchObjLabelUpdated(src,event,uuid)); 
            
            if ~isempty(analysisObj.TrimTask.FlapSimulinkName)
                obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1).Flap_text.String =  analysisObj.TrimTask.FlapSimulinkName;
                obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1).FlapText =  analysisObj.TrimTask.FlapSimulinkName;
            end
            if ~isempty(analysisObj.TrimTask.LandingGearSimulinkName)
                obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1).ACconfig_text.String =  analysisObj.TrimTask.LandingGearSimulinkName;
                obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1).GearText =  analysisObj.TrimTask.LandingGearSimulinkName;
            end
            
            %----------------------------------------------------------
            %          Constants Parameters
            %----------------------------------------------------------
            obj.ConstantsParamColl(ind) = UserInterface.ControlDesign.ParameterCollection('Parent',obj.TabConstants(ind),'Title','Parameters');
            addlistener(obj.ConstantsParamColl,'GlobalIdentified',@obj.globalVariableIndentInConstants);
            addlistener(obj.ConstantsParamColl,'EditButtonPressed',@obj.editPressInConst);
            %addNewConstantParameters( obj , [] , [] , ind );
                
            % Large Panel Disply Created by OperCond Collection
            obj.OperCondContainer(ind) = uicontainer('Parent',obj.AnalysisTabArray(ind),'Units','pixels','Position',[ 1 , 1 , parentPos(3) , parentPos(4)-16 ]);
            
            
            % Add OperColl obj.RibbonCardPanel
            obj.OperCondCollObj(ind) = UserInterface.StabilityControl.OCCStabControl(obj.OperCondContainer(ind),obj.RibbonCardPanel.Panel(ind));
            obj.AxisColl(ind)    = obj.OperCondCollObj(ind).AxisColl;          
            obj.SimAxisColl(ind) = obj.OperCondCollObj(ind).SimAxisColl;
% %             % Listen for SimViewer Launch
% %             addlistener(obj.SimAxisColl(ind),'AxisCollectionEvent',@obj.simAxisEvent_CB);
            
            
            obj.PostSimAxisColl(ind) = obj.OperCondCollObj(ind).PostSimAxisColl;
            
            % Set Selected Tab Index
            obj.AnalysisTabSelIndex = ...
                find(obj.AnalysisTabGroub.SelectedTab == obj.AnalysisTabGroub.Children);
            
            massPropertyAddedToPanel( obj , ind , analysisObj.MassProperties);
            
           
            
%             updateDisplay(obj.TaskCollectionObj(ind));
            updateDisplay(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(1));
            reSize( obj , [] , [] );
        end % createAnalysisView
        
        function restoreAnalysisView( obj , analysisObjs )
            obj.AnalysisObjects = analysisObjs;
            for ind = 1:length(analysisObjs)
            
                obj.AnalysisTabArray(ind)  = uitab('Parent',obj.AnalysisTabGroub);
                set(obj.AnalysisTabArray(ind),'Title',analysisObjs(ind).Title);

                mpPos = UserInterface.Utilities.getPosInPixels(obj.MainPanel);



                % Create Task Container
                obj.TaskObjContainer(ind) = uicontainer('Parent',obj.AnalysisTabArray(ind),'Units','Pixels','Position',[ 1 , 1 , 352 , mpPos(4) - 3 ]);
                set(obj.TaskObjContainer(ind),'ResizeFcn',@obj.smallPanelResize);
                parentPos = UserInterface.Utilities.getPosInPixels(obj.TaskObjContainer(ind));

                labelStr = '<html><font color="white" face="Courier New">&nbsp;Trim Settings</html>';
                jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
                jLabelview.setOpaque(true);
                jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
                jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
                jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
                [obj.SettingsLabelComp(ind),obj.SettingsLabelCont(ind)] = javacomponent(jLabelview,[ 1 , parentPos(4) - 16 , parentPos(3) , 16 ], handle(obj.TaskObjContainer(ind)) );

                obj.TaskPanel(ind) = uicontainer('Parent',obj.TaskObjContainer(ind),'Units','pixels','Position',[ 1 , 1 , parentPos(3) , parentPos(4)-16 ]); %[ 1 , 50 , parentPos(3) , parentPos(4) - 50 ]); 
                % Create Main Tab Group
                obj.TabPanel(ind) = uitabgroup('Parent',obj.TaskPanel(ind));
                set(obj.TabPanel(ind),'SelectionChangedFcn',@obj.tabPanel_CB); 

                    % Manual Tab
                    obj.TabManual(ind)   = uitab('Parent',obj.TabPanel(ind));
                    set(obj.TabManual(ind),'Title',' Manual');
                    obj.SelectedTab = obj.TabManual(ind);
              

                    % Constants Tab
                    obj.TabConstants(ind)   = uitab('Parent',obj.TabPanel(ind));
                    set(obj.TabConstants(ind),'Title','Parameters');

                % Create Objects
                numCards = length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj);
                obj.TaskCollectionCardPanel(ind) = UserInterface.CardPanel(numCards,'Parent',obj.TabManual(ind));
                for i = 1:numCards 
                    createView(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),{''},obj.TaskCollectionCardPanel(ind).Panel(i));
                    updateSelectedConfiguration(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),analysisObjs(ind).TrimTask);
                    addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'ShowLogMessage',@obj.showLogMessage_CB);
                    uuid = obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).UUID;
                    addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'LabelUpdated',  @(src,event) obj.batchObjLabelUpdated(src,event,uuid)); 
                end
%                 obj.TaskCollectionCardPanel(ind) = UserInterface.CardPanel(1,'Parent',obj.TabManual(ind));  
%                 createView(obj.TaskCollectionObj(ind),{''},obj.TaskCollectionCardPanel(ind).Panel(1));
%                 updateSelectedConfiguration(obj.TaskCollectionObj(ind),analysisObjs(ind).TrimTask);
%                 
%                 numCards = length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj);
%                 for i = 1:numCards 
%                     panel = obj.TaskCollectionCardPanel(ind).addPanel(1);
%                     createView(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),{''},panel );
%                     addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'ShowLogMessage',@obj.showLogMessage_CB);
%                     addlistener(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),'LabelUpdated',  @(src,event) obj.batchObjLabelUpdated(src,event,i)); 
%                 end
                

                %----------------------------------------------------------
                %          Constants Parameters
                %----------------------------------------------------------
                obj.ConstantsParamColl(ind).createView(obj.TabConstants(ind));
                addlistener(obj.ConstantsParamColl(ind),'GlobalIdentified',@obj.globalVariableIndentInConstants);
                addlistener(obj.ConstantsParamColl(ind),'EditButtonPressed',@obj.editPressInConst);
                addNewConstantParameters( obj , [] , [] , ind );


                % Large Panel Disply Created by OperCond Collection
                obj.RibbonCardPanel.addPanel(1);
                obj.OperCondContainer(ind) = uicontainer('Parent',obj.AnalysisTabArray(ind),'Units','pixels','Position',[ 1 , 1 , parentPos(3) , parentPos(4)-16 ]);
                createView( obj.OperCondCollObj(ind) , obj.OperCondContainer(ind) , true, obj.RibbonCardPanel.Panel(ind) );
              
                obj.AxisColl(ind)    = obj.OperCondCollObj(ind).AxisColl; 
                
                % for old project ensure the class is set correctly to
                % SimViewer.Main
                if ~isa(obj.SimAxisColl,'SimViewer.Main')
                    obj.SimAxisColl = SimViewer.Main.empty;
                end
                
                obj.SimAxisColl(ind) = obj.OperCondCollObj(ind).SimAxisColl;
% %                 % Listen for SimViewer Launch
% %                 addlistener(obj.SimAxisColl(ind),'AxisCollectionEvent',@obj.simAxisEvent_CB);


                obj.PostSimAxisColl(ind) = obj.OperCondCollObj(ind).PostSimAxisColl;
            end
            
            % Set Selected Tab Index
            obj.AnalysisTabSelIndex = ...
                find(obj.AnalysisTabGroub.SelectedTab == obj.AnalysisTabGroub.Children);
        end % restoreAnalysisView
        
        function analysisObjRemovedInTree( obj , hobj , eventdata )
            
            indices = eventdata.Object;
            for i = 1:length(indices)
                delete(obj.AnalysisTabArray(indices(i)));
                obj.RibbonCardPanel.deletePanel(indices(i));
            end
            
            if length(indices) == length(obj.AnalysisObjects)
                obj.AnalysisTabArray = [];
                obj.TaskPanel = [];
                obj.TabPanel = [];
                obj.TabManual = [];
                obj.TabConstants = [];
%                 obj.TaskCollectionObj = lacm.TrimTaskCollection.empty;
                obj.ConstantsParamColl = UserInterface.ControlDesign.ParameterCollection.empty;
                obj.OperCondContainer = [];
                obj.OperCondCollObj = UserInterface.StabilityControl.OCCStabControl.empty;
                obj.AxisColl = UserInterface.AxisPanelCollection.empty;
                obj.SimAxisColl = SimViewer.Main.empty;
                obj.PostSimAxisColl = UserInterface.AxisPanelCollection.empty;
                obj.SettingsLabelComp = javahandle_withcallbacks.javax.swing.JLabel;
                obj.SettingsLabelCont = [];
                obj.AnalysisObjects = lacm.AnalysisTask.empty;  
                obj.TaskObjContainer= [];
                obj.TaskCollectionObjBatch = lacm.TrimTaskCollectionBatch.empty;
                obj.TaskCollectionCardPanel = UserInterface.CardPanel.empty;
            else
                obj.AnalysisTabArray(indices) = [];
                obj.TaskPanel(indices) = [];
                obj.TabPanel(indices) = [];
                obj.TabManual(indices) = [];
                obj.TabConstants(indices) = [];
%                 obj.TaskCollectionObj(indices) = [];
                obj.ConstantsParamColl(indices) = [];
                obj.OperCondContainer(indices) = [];
                obj.OperCondCollObj(indices) = [];
                obj.AxisColl(indices) = [];
                obj.SimAxisColl(indices) = [];
                obj.PostSimAxisColl(indices) = [];
                obj.SettingsLabelComp(indices) = [];
                obj.SettingsLabelCont(indices) = [];
                obj.AnalysisObjects(indices) = [];
                obj.TaskObjContainer(indices) = [];
                obj.TaskCollectionObjBatch(indices) = [];
                obj.TaskCollectionCardPanel(indices) = [];
            end
            
            
            if isempty(obj.AnalysisTabArray)
                obj.AnalysisTabSelIndex = [];
            else
                obj.AnalysisTabSelIndex = ...
                        find(obj.AnalysisTabGroub.SelectedTab == obj.AnalysisTabGroub.Children);
            end
        end % analysisObjRemovedInTree
        
    end
    
    %% Methods - Constants View
    methods 
        
        function editPressInConst( obj , ~ , ~ )

        end % editPressInConst 
                       
        function globalVariableIndentInConstants( obj , ~ , eventdata )

            globalParamModified( obj.ConstantsParamColl , eventdata.Object );

        end % globalVariableIndentInConstants 
                
        function addNewConstantParameters( obj , ~ , ~ , index )
            if nargin == 3
                len = length(obj.ConstantsParamColl);
                ind = 1;
            else
                len = index;
                ind = index;
            end
            for i = ind:len
                constantTableData = readConstantsFile( obj );
                % *************Add   params*********************************
                % Find global  Params
                ria = ismember({constantTableData.Name},{obj.ConstantsParamColl(i).AvaliableParameterSelection.Name});
                rib = ismember({obj.ConstantsParamColl(i).AvaliableParameterSelection.Name} , {constantTableData.Name});
                constantTableData(ria) = []; % remove unneeded

                if any(rib) && ~isempty(obj.ConstantsParamColl(i).AvaliableParameterSelection)
                    [obj.ConstantsParamColl(i).AvaliableParameterSelection(rib).Global] = deal(true); 
                end
                constantTableData =  [ constantTableData , obj.ConstantsParamColl(i).AvaliableParameterSelection(rib)'] ; %#ok<AGROW>

                add2AvaliableParameters( obj.ConstantsParamColl(i) , constantTableData ); 
            end
        end % addNewReqParameters
        
        function constantTableData = readConstantsFile( obj )
            constantsFile = [];
%             constantsFile = getConstantsFile( obj.Tree );
            constantTableData = UserInterface.ControlDesign.Parameter.empty;
            
            if ~isempty(constantsFile)
                for i = 1:length(constantsFile)

                    [ ~ , fileNoExt , extFLIGHT ] = fileparts(constantsFile{i});
                    if strcmp( extFLIGHT , '.mat' )

                        varStruct = load(constantsFile{i});
                        varNames = fieldnames(varStruct);
                        for j = 1:length(varNames)
                            constantTableData(j) = UserInterface.ControlDesign.Parameter('Name',varNames{j},'String',varStruct.(varNames{j}));
                        end

                        command = sprintf('load(''%s'')', constantsFile{i});
                        evalin('base', command);
                    elseif strcmp( extFLIGHT , '.m' )
                        constantTableData = evalParams( fileNoExt);
                    else
                        error('Constants file must have a ".m" of ".mat" extension');
                    end 
                    
                    constantTableData = [ constantTableData , constantTableData ]; %#ok<AGROW>
                    
                end

            end
            
        end % readConstantsFile    
        
        function constantsTable_ce_CB( obj , ~ , eventData  )
            
            ind = eventData.Indices(1);
            obj.ConstantTableData(ind).Value = eventData.NewData;
            
            assignin('base', obj.ConstantTableData(ind).Name, obj.ConstantTableData(ind).Value);
            
        end % constantsTable_ce_CB
        
        function constantsTable_cs_CB( obj , ~ , eventData  )
            
        
            
        end % constantsTable_cs_CB
        
        function updateConstantTableData( obj , ~ , ~ )
            
            constantsFile = getConstantsFile( obj.Tree );
            obj.ConstantTableData = lacm.Condition.empty;
            constantTableData = lacm.Condition.empty;
            
            if ~isempty(constantsFile)
                for i = 1:length(constantsFile)

                    [ ~ , fileNoExt , extFLIGHT ] = fileparts(constantsFile{i});
                    if strcmp( extFLIGHT , '.mat' )

                        varStruct = load(constantsFile{i});
                        varNames = fieldnames(varStruct);
                        for j = 1:length(varNames)
                            constantTableData(j) = UserInterface.ControlDesign.Parameter('Name',varNames{j},'String',varStruct.(varNames{j}));
                            constantTableData(j) = lacm.Condition(varNames{j},varStruct.(varNames{j}));

                        end

                        command = sprintf('load(''%s'')', constantsFile{i});
                        evalin('base', command);
                    elseif strcmp( extFLIGHT , '.m' )
                        constantTableData = testFunc( fileNoExt);
                    else
                        error('Constants file must have a ".m" of ".mat" extension');
                    end 
                    
                    obj.ConstantTableData = [ obj.ConstantTableData , constantTableData ];
                    
                end
                
                % Set the table data
                for i = 1:length(obj.ConstantTable)
                    set(obj.ConstantTable(i),'Data',[{obj.ConstantTableData.Name}',{obj.ConstantTableData.StringValue}']);
                end
            end
            
        end % updateConstantTableData
        
    end 
    
    %% Methods - Callbacks
    methods (Access = protected)   
        
        function signalDropCB( obj , hobj , eventData )
            disp('Debug point');
            %addSignal2Plot( obj , hobj , eventData );
        end % signalDropCB
        
        function batchObjLabelUpdated( obj , hobj , eventdata , index )
            nodeIndex = obj.Tree.setBatchNodeLabel( obj.AnalysisTabSelIndex , index , eventdata.Object );
            
            obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(nodeIndex + 1).Label = eventdata.Object;
            
        end % batchObjLabelUpdated
        
        function batchNodesRemoved( obj , ~ , eventData)
            
            analysisObj = obj.AnalysisObjects(obj.AnalysisTabSelIndex);
            if eventData.Object == -1 
%                 for i = length(obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).Panel):-1:2
%                     obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).deletePanel(i);  
%                 end
                while length(obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).Panel) > 1
                    index = length(obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).Panel);
                    obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).deletePanel(index);
                end
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj = obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(1);
            else
                if length(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj) == 1
                    return;
                end
                
                allUUIDs = {obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj.UUID};
                
                remUUIDLA  = strcmp(eventData.Object,allUUIDs);
                remUUIDIndex = find(remUUIDLA);
                
                obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).deletePanel(remUUIDIndex); %#ok<FNDSB>
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(remUUIDLA) = [];

                
            end
            analysisObj.SavedTaskCollectionObjBatch = obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex);
            
        end % batchNodesRemoved
        
        function batchNodeSelected( obj , ~ , eventData )
            analysisNodeIndex = eventData.Object{1};
            trimTaskCollInd   = eventData.Object{2};
            
            obj.TaskCollectionCardPanel(analysisNodeIndex).SelectedPanel = trimTaskCollInd;
            
            %Refresh the view for trim setting in case user changed another
            %run
            obj.TaskCollectionObjBatch(analysisNodeIndex).TrimTaskCollObj(trimTaskCollInd).updateDisplay;
            
            
            %obj.RibbonCardPanel(analysisNodeIndex).SelectedPanel = trimTaskCollInd;
        end %j batchNodeSelected
        
        function analysisObjectSaved( obj , ~ , eventData)

            analysisObj = eventData.Object{1};
            index = eventData.Object{2};

            analysisObj.SavedTaskCollectionObjBatch = obj.TaskCollectionObjBatch(index + 1);
            
            setWaitPtr(obj);
            [filename, pathname] = uiputfile({'*.mat'},'Save as .mat file','Analysis Object');
            if isequal(filename,0)
                releaseWaitPtr(obj);
                return;
            end
            save(fullfile(pathname,filename),'analysisObj');
            
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Analysis Object Saved','info'));
            releaseWaitPtr(obj);
            
        end % analysisObjectSaved
        
        function analysisObjectEdited( obj , ~ , eventData)
            setWaitPtr(obj);
            
            analysisObj = eventData.Object{1};
            ind = eventData.Object{2} + 1;
            
            trimSettings = analysisObj.TrimTask;
            
            %obj.Tree.rebuildBatchObj;
             set(obj.AnalysisTabArray(ind),'Title',analysisObj.Title);
             
             for i = 1:length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj)
                 obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).updateSelectedConfiguration(trimSettings); 
             end
            
            releaseWaitPtr(obj);
        end % analysisObjectEdited
        
        function addBatch2AnalysisNode_CB( obj , ~ , eventData )
            setWaitPtr(obj);
            
            analysisObj = obj.AnalysisObjects(obj.AnalysisTabSelIndex);
            
            batchRunNumber = length(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj) + 1;
            
            panel = obj.TaskCollectionCardPanel(obj.AnalysisTabSelIndex).addPanel(1);
            
            obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end + 1) = lacm.TrimTaskCollection( panel, {''}, ['Run ',num2str(batchRunNumber)]) ; 
            updateSelectedConfiguration(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end),analysisObj.TrimTask);

            uuid = obj.Tree.addBatchObj( obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end) , obj.AnalysisTabSelIndex , ['Run ',num2str(batchRunNumber)] );
            obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).Label = ['Run ',num2str(batchRunNumber)];
            obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).UUID = uuid;

            addlistener(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end),'ShowLogMessage',@obj.showLogMessage_CB);
            addlistener(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end),'ShowLogMessage',@obj.showLogMessage_CB);   
            addlistener(obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end),'LabelUpdated',@(src,event) obj.batchObjLabelUpdated(src,event,uuid)); 
            
            if ~isempty(analysisObj.TrimTask.FlapSimulinkName)
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).Flap_text.String   =  analysisObj.TrimTask.FlapSimulinkName;
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).FlapText           =  analysisObj.TrimTask.FlapSimulinkName;
            end
            
            if ~isempty(analysisObj.TrimTask.LandingGearSimulinkName)
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).ACconfig_text.String   =  analysisObj.TrimTask.LandingGearSimulinkName;
                obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex).TrimTaskCollObj(end).GearText               =  analysisObj.TrimTask.LandingGearSimulinkName;
            end
            
            massPropertyAddedToPanel(obj, obj.AnalysisTabSelIndex, analysisObj.MassProperties, batchRunNumber);    
            
            analysisObj.SavedTaskCollectionObjBatch = obj.TaskCollectionObjBatch(obj.AnalysisTabSelIndex);
            
            
            releaseWaitPtr(obj);
        end % addBatch2AnalysisNode_CB
        
        function analysisObjSelectedInTree( obj , ~ , eventData )
            selTabIndex = eventData.Object;
            obj.AnalysisTabSelIndex = selTabIndex;
            obj.AnalysisTabGroub.SelectedTab = obj.AnalysisTabArray(selTabIndex);
            obj.RibbonCardPanel.SelectedPanel = selTabIndex;
        end % analysisObjSelectedInTree
        
        function addAnalysisObject( obj , ~ , eventData )
            
%             releaseAllTrimMdls(obj, [], []);
            
            for i = 1:length(eventData.Object)
                obj.AnalysisObjects(end+1) = eventData.Object(i);
                obj.TaskCollectionObjBatch(end+1) = eventData.Object(i).SavedTaskCollectionObjBatch;
                ind = length(obj.AnalysisObjects);
                obj.RibbonCardPanel.addPanelKeepSelected(1);
                createAnalysisView(obj,ind,eventData.Object);
                % Add tool ribbon card panel for each analysis Obj
                
            end

            
            pause(0.1);
            reSize( obj , [] , [] );
            pause(0.1);
            notify(obj,'SaveProject');
        end % addAnalysisObject
        
        function projectTabPanel_CB( obj , ~ , eventData )

        end % projectTabPanel_CB
        
        function simAxisEvent_CB( obj , ~ , eventData )
            switch eventData.Type
                case 'SimViewerLaunch'
                    [ selObjs , ~ ] = getAnalysisObjs( obj.Tree , false );
                    logArray = strcmp(obj.AnalysisTabGroub.SelectedTab.Title,{selObjs.Title});
                    
                    selAnObj = selObjs(logArray);
                    
                    logArray2 = strcmp(eventData.Value,{selAnObj.SimulationRequirment.Title});
                    showSimViewer( obj , [] , selAnObj.SimulationRequirment(logArray2) , [selAnObj.Title,' - ',selAnObj.SimulationRequirment(logArray2).Title] );    
                otherwise
                    
            end
        end % simAxisEvent_CB
           
        function saveOperCond( obj , ~ , eventData  )
            [filename, pathname] = uiputfile({'*.mat'},'Save Operating Conditions','OperatingCondition');
            if isequal(filename,0)
                return;
            end
            if ~isempty(obj.AnalysisTabSelIndex)
                setWaitPtr(obj);
                if eventData.Value == 1
                    operCond = obj.OperCondCollObj(obj.AnalysisTabSelIndex).OperatingCondition; 
                else
                    operCondTemp = obj.OperCondCollObj(obj.AnalysisTabSelIndex).OperatingCondition; 
                    operCond = operCondTemp([operCondTemp.SuccessfulTrim]);

                end
                if isempty(operCond)
                    operCond = lacm.OperatingCondition.empty; %#ok<NASGU>
                end
                save(fullfile(pathname,filename),'operCond');
                releaseWaitPtr(obj);
            end        
        end % saveOperCond
        
        function unitsChanged( obj , ~ , eventData  )
            
            obj.Units = eventData.Object;
            
        end % unitsChanged
        
        function clearTable( obj , ~ , ~  )
            if ~isempty(obj.AnalysisTabSelIndex)
                obj.OperCondCollObj(obj.AnalysisTabSelIndex).clear();
                obj.OperCondCollObj(obj.AnalysisTabSelIndex).OperatingConditionStructureIsDefined = false;
            end

            
        end % clearTable       
        
        function modelChanged( obj , ~ , eventData  )
            % Find all names
            if eventData.ThrowError
                try       
                    mdlName = getSelectedSimModel( obj.Tree );
                    readModel( obj , mdlName , eventData.Filename{:} , eventData.NodeName );
                catch Mexc
                    rethrow(Mexc);
                end
            else
                try
                    [ ~ , mdl ] = fileparts(eventData.Filename{:});
                    readModel( obj , mdl );
                end
            end
            
        end % modelChanged
                  
        function newConfiguration( obj , ~ , ~  )
            configBuilder = UserInterface.StabilityControl.ConfigBuilder();
            addlistener(configBuilder,'LoadConfiguration',@obj.addConfiguration);
            configBuilder.createView();
        end %newConfiguration
        
        function loadConfiguration( obj , ~ , ~  )
            addConfigFile_CB( obj.Tree , [] , [] );   
        end % loadConfiguration           
        
        function tabPanel_CB( obj , ~ , ~ )
%             obj.SelectedTab = get(obj.TabPanel,'SelectedTab');
%             update(obj);
        end % tabPanel_CB
        
        function analysisTabChanged( obj , hobj , eventdata )
            obj.AnalysisTabSelIndex = find(hobj.Children == eventdata.NewValue);
            obj.RibbonCardPanel.SelectedPanel = obj.AnalysisTabSelIndex;
        end % analysisTabChanged
        
        function autoSave_CB( obj , hobj , ~ )
            
            obj.AutoSave = get(hobj,'Value');
            
            obj.update;
            
        end % autoSave_CB

        function autoSaveFileName_CB( obj , hobj , ~ )
            
            obj.AutoSaveFileName = get(hobj,'String');
            
        end % autoSaveFileName_CB
              
        function showLogSignals_CB( obj , ~ , eventdata )
            obj.ShowLoggedSignalsState = eventdata.Value;
        
            if obj.ShowLoggedSignalsState
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('All Models will be released.','info'));
                releaseAllTrimMdls(obj, [], []);
%                 setColor4MdlCompiledState(obj.Tree,[], []);
            end
            
          	obj.RunSignalLog =  eventdata.Value;
            for i = 1:length(obj.OperCondCollObj)
                obj.OperCondCollObj(i).OperatingConditionStructureIsDefined = false;
            end
        end % showLogSignals_CB

        function useAllCombinations_CB( obj , ~ , eventdata )
            obj.UseAllCombinationsState = eventdata.Value;
        end % useAllCombinations_CB
        
        function showSimViewer( obj , hobj , eventData , title )
            
            if isa(eventData,'Requirements.SimulationCollection')
                simObj = eventData;
            else
                disp('No other event types are currently supported.')
                return;
            end
            
            if nargin == 3
                title = simObj.Title;
            end
            
            %Common.SimulationViewer.SimViewer(simObj.SimulationData.Output,'Title',title,'RunLabel','Trim');
            Common.SimulationViewer.SimulationViewer.Main(simObj.SimulationData.Output,'Title',title,'RunLabel','Trim');
        end % autoSave_CB
        
        function setNumPlotsPlts( obj , ~ , eventdata )
            numbPlots = eventdata.Object;
            setOrientation( obj.AxisColl(obj.AnalysisTabSelIndex)  , numbPlots );            
            obj.NumberOfPlotPerPagePlts = numbPlots;
            
        end % setNumPlotsPlts
        
        function setNumPlotsPostPlts( obj , ~ , eventdata )
            numbPlots = eventdata.Object;
            setOrientation( obj.PostSimAxisColl(obj.AnalysisTabSelIndex) , numbPlots );            
            obj.NumberOfPlotPerPagePostPlts = numbPlots;
            
        end % setNumPlotsPostPlts
        
        function showTrims_CB(obj , ~ , eventdata )
                        
            if isempty(obj.AnalysisTabSelIndex)
                return;
            else
                if strcmp(eventdata.Object,'Show All Trims')
                    obj.ShowInvalidTrimState = 0;
                    updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 0 );
                elseif strcmp(eventdata.Object,'Show Valid Trims')
                      obj.ShowInvalidTrimState = 1;
                    updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 1 );  
                else 
                    obj.ShowInvalidTrimState = 2;
                    updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 2 );
                end
            end
        end % showTrims_CB
        
    	function updateValidTrims(obj)
                        
            if isempty(obj.AnalysisTabSelIndex)
                return;
            else
                switch obj.ShowInvalidTrimState
                    case 0
                        updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 0 );
                    case 1
                        updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 1 );  
                    case 2
                        updateValidTrimDisplay( obj.OperCondCollObj(obj.AnalysisTabSelIndex) , 2 );
                end
            end
        end % updateValidTrims
        
        
        function trimSettings_CB(obj , ~ , eventdata )
            obj.TrimSettings = copy(eventdata.Object);        

        end % trimSettings_CB       
        
    end
    
    % Methods Ordinary
    methods
        function releaseAllTrimMdls(obj, ~, ~)
            [ analysisObjs , selObjLogic ] = getAnalysisObjs( obj.Tree , false );

            uniqueMdlNames ={};
            for ind = 1:length(analysisObjs)
                uniqueMdlNamesNEW = getAllModelsInAnalysisObj(analysisObjs(ind));
                uniqueMdlNames = [uniqueMdlNames,uniqueMdlNamesNEW];
            end


%             Utilities.multiWaitbar('Closing models...', 0 , 'Color', 'b'); 
            for i = 1:length(uniqueMdlNames)
                while exist(uniqueMdlNames{i}) == 4 && bdIsLoaded(uniqueMdlNames{i}) && strcmp(get_param(uniqueMdlNames{i}, 'SimulationStatus'),'paused')
                    try
                        feval (uniqueMdlNames{i}, [], [], [], 'term');
                    end
                end   
%                 Utilities.multiWaitbar('Closing models...', i/length(uniqueMdlNames) , 'Color', 'b'); 
            end

            
            setColor4MdlCompiledState(obj.Tree,[], []);
            
%             Utilities.multiWaitbar('Closing models...', 'close');  
            
            
        end % releaseAllTrimMdls
    end
    
    %% Calllback Load
    methods (Access = protected) 
        
        function loadAnalysisObj( obj , ~ , ~ )
            insertAnalysisObj_CB( obj.Tree , [] , [] , obj.Tree.AnalysisNode , [] , lacm.AnalysisTask.empty);
        end % loadAnalysisObj_CB    
        
    end
    
    %% Callback New
    methods (Access = protected) 

        function newAnalysisObj_CB( obj , ~ , ~ )
        
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',lacm.AnalysisTask);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end % newAnalysisObj_CB
        
        function newTrimObj_CB( obj , ~ , ~ )
        
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',lacm.TrimSettings,'ShowLoadButton',false);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
            
            simModelName = obj.Tree.getSelectedSimModel();
            if ~isempty(simModelName)
                createDefault( reqEditObj.CurrentReqObj , simModelName );
            end
        end % newTrimObj_CB
        
        function newLinMdlObj_CB( obj , ~ , ~ )            

            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',lacm.LinearModel,'ShowLoadButton',false);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
            
            simModelName = obj.Tree.getSelectedSimModel();
            if ~isempty(simModelName)
                createDefault( reqEditObj.CurrentReqObj , simModelName );
            end
        end % newLinMdlObj_CB
        
        function newMethodObj_CB( obj , ~ , ~ )
  
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.RequirementTypeOne,'ShowLoadButton',false);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end % newMethodObj_CB
        
        function newSimulationObj_CB( obj , ~ , ~ )

            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.SimulationCollection,'ShowLoadButton',false);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));
        end % newSimulationObj_CB     
        
        function openObjInEditor_CB( obj , ~ , eventdata )
            
            [filename, pathname] = uigetfile({'*.mat'},['Select ',eventdata.Value,' Object File:'],obj.ProjectDirectory);
            drawnow();pause(0.5);

            if isequal(filename,0)
                return;
            end
            
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            

            if strcmp(eventdata.Value,'Analysis')
                reqEditObj = UserInterface.ObjectEditor.Editor('EditInProject',false,'Requirement', varStruct.(varNames{1}));
            else
                reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',lacm.TrimSettings,'ShowLoadButton',false);
                addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

                loadObject( reqEditObj , varStruct.(varNames{1}) );
            end

        end % openTrimObj_CB 
        
%         function exportTable_CB( obj , ~ , eventData )
%             if isempty(obj.AnalysisTabSelIndex)
%                 return;
%             else
%                 operCondColl = obj.OperCondCollObj(obj.AnalysisTabSelIndex);   
%             end
%             
%             expOpt = UserInterface.ExportOptions();
%             
%             uiwait(expOpt.Figure);
%             
%             if expOpt.Range == 0
%                 return;
%             end
%             
%             maxLength =  size(operCondColl.TableData,2);
%             
%             if isempty(expOpt.Range)
%                 colIndices = 1:maxLength;
%             else
%                 colIndices = [1:3,expOpt.Range + 3];
%                 colIndices = colIndices(colIndices <= maxLength);
%             end
% 
%             
%             
%             operCondTableData = operCondColl.TableData(:,colIndices); 
%             if isempty(operCondTableData)
%                 operCondTableData = {}; 
%             end
%             
%             if strcmp(eventData.Object,'mat')
%                 [filename, pathname] = uiputfile({'*.mat'},'Save Operating Condition Table Data','TableData');
%                 if isequal(filename,0)
%                     return;
%                 end
%                 save(fullfile(pathname,filename),'operCondTableData');
%             elseif strcmp(eventData.Object,'csv')
%                 [filename, pathname] = uiputfile({'*.csv'},'Save Operating Condition Table Data','TableData');
%                 if isequal(filename,0)
%                     return;
%                 end
%                 Utilities.cell2csv(fullfile(pathname,filename), operCondTableData, ',');
%             else
% % %                 maxLengthOC =  length(obj.OperCondCollObj(obj.AnalysisTabSelIndex).OperatingCondition);
% % % 
% % %                 if isempty(expOpt.Range)
% % %                     colIndicesOC = 1:maxLengthOC;
% % %                 else
% % %                     colIndicesOC = expOpt.Range;
% % %                     colIndicesOC = colIndicesOC(colIndicesOC <= maxLengthOC);
% % %                 end
% % %                
% % %                 operCond = operCondColl.OperatingCondition(colIndicesOC);
% % %                 file = Utilities.write2mfile(operCond,true);
% % %                 open(file);
% 
%                 [filename, pathname] = uiputfile({'*.m'},'Save Operating Condition Table Data','TableData');
%                 if isequal(filename,0)
%                     return;
%                 end
%                 Utilities.cell2mfile(fullfile(pathname,filename), operCondTableData);
%                 
%             end
%         end % exportTable_CB

        function exportTable_CB( obj , ~ , eventData )
            if isempty(obj.AnalysisTabSelIndex)
                return;
            else
                operCondColl = obj.OperCondCollObj(obj.AnalysisTabSelIndex);   
            end
        
            expOpt = UserInterface.ExportOptions();
            uiwait(expOpt.Figure);
        
            if expOpt.Range == 0
                return;
            end
        
            maxLength =  size(operCondColl.TableData,2);
        
            if isempty(expOpt.Range)
                colIndices = 1:maxLength;
            else
                colIndices = [1:3,expOpt.Range + 3];
                colIndices = colIndices(colIndices <= maxLength);
            end
        
            operCondTableData = operCondColl.TableData(:,colIndices);
            if isempty(operCondTableData)
                operCondTableData = {};
            end

            exportData = operCondTableData;
            if expOpt.Transpose
                exportData = exportData.';
            end

            if strcmp(eventData.Object,'mat')
                [filename, pathname] = uiputfile({'*.mat'}, 'Save Operating Condition Table Data', 'TableData');
                if isequal(filename,0)
                    return;
                end
                operCondTableData = exportData; %#ok<NASGU>
                save(fullfile(pathname,filename), 'operCondTableData');

            elseif strcmp(eventData.Object,'csv')
                [filename, pathname] = uiputfile({'*.csv'}, 'Save Operating Condition Table Data', 'TableData');
                if isequal(filename,0)
                    return;
                end
                Utilities.cell2csv(fullfile(pathname,filename), exportData, ',');

            else
                [filename, pathname] = uiputfile({'*.m'}, 'Save Operating Condition Table Data', 'TableData');
                if isequal(filename,0)
                    return;
                end
                Utilities.cell2mfile(fullfile(pathname,filename), exportData);
            end
        end % exportTable_CB


        function generateReport_CB( obj , ~ , eventData )
            if nargin < 3 || isempty(eventData) || isempty(eventData.Object)
                format = 'PDF';
            else
                format = eventData.Object;
            end

            obj.UseLegacyReport = strcmpi(format,'MS Word');
            obj.generateReport();
        end % generateReport_CB

        function generateReport(obj)
            %GENERATEREPORT Dispatch to the selected report generator.
            % Notify user that report generation has begun
            notify(obj,'ShowLogMessageMain', ...
                UserInterface.LogMessageEventData('Generating report...','info'));

            if obj.UseLegacyReport
                obj.generateReportLegacy();
            else
                obj.generateReportOpenSource();
            end
        end % generateReport

        function generateReportLegacy(obj)
            %GENERATEREPORTLEGACY Export a report using Microsoft Word.
            %   Implements new, template, and append report generation
            %   similar to the ControlDesign tool.

            rptType = questdlg('Select report type', 'Export Report', ...
                'New', 'Template', 'Append', 'New');
            if isempty(rptType); return; end

            switch rptType
                case 'Append'
                    [file,path] = uigetfile({'*.docx','Word Document (*.docx)'}, ...
                        'Select Report to Append');
                    if isequal(file,0); return; end
                    fullName = fullfile(path,file);
                    try
                        rpt = Report(fullName,'Visible',true);
                    catch
                        warndlg('Microsoft Word is required to export reports.', 'Report');
                        return;
                    end
                    appendContent(rpt);
                    updateTOC(rpt);
                    updateTOF(rpt);
                    saveAs(rpt, fullName);
                    closeWord(rpt);
                    notify(obj,'ShowLogMessageMain', ...
                        UserInterface.LogMessageEventData(['Report generation complete: ' fullName],'info'));

                otherwise % 'New' or 'Template'
                    if strcmp(rptType,'Template')
                        [tmplFile,tmplPath] = uigetfile({'*.docx','Word Document (*.docx)'}, ...
                            'Select Template');
                        if isequal(tmplFile,0); return; end
                        fullName = fullfile(tmplPath,tmplFile);
                        outName = fullfile(tmplPath,[erase(tmplFile,'.docx'),'_NEW.docx']);
                        try
                            rpt = Report(fullName,'Visible',true);
                        catch
                            warndlg('Microsoft Word is required to export reports.', 'Report');
                            return;
                        end
                        appendContent(rpt);
                        updateTOC(rpt);
                        updateTOF(rpt);
                        saveAs(rpt,outName);
                        closeWord(rpt);
                        notify(obj,'ShowLogMessageMain', ...
                            UserInterface.LogMessageEventData(['Report generation complete: ' outName],'info'));
                    else % New report
                        [file,path] = uiputfile({'*.docx';'*.pdf'}, ...
                            'Export Report', 'AnalysisReport.docx');
                        if isequal(file,0); return; end
                        fullName = fullfile(path,file);
                        try
                            rpt = Report(fullName);
                        catch
                            warndlg('Microsoft Word is required to export reports.', 'Report');
                            return;
                        end
                        % Title page
                        rpt.ActX_word.Selection.TypeText('Flight Dynamics Report');
                        rpt.ActX_word.Selection.Style = 'Title';
                        rpt.ActX_word.Selection.TypeParagraph;

                        % Table of contents and figures placeholders
                        rpt.ActX_word.Selection.TypeText('Table of Contents');
                        rpt.ActX_word.Selection.Style = 'Heading 1';
                        rpt.ActX_word.Selection.TypeParagraph;
                        addTOC(rpt);
                        rpt.ActX_word.Selection.InsertBreak;
                        rpt.ActX_word.Selection.TypeText('Table of Figures');
                        rpt.ActX_word.Selection.Style = 'Heading 1';
                        rpt.ActX_word.Selection.TypeParagraph;
                        addTOF(rpt);
                        rpt.ActX_word.Selection.InsertBreak;

                        addContent(rpt);
                        updateTOC(rpt);
                        updateTOF(rpt);
                        saveAs(rpt, fullName);
                        closeWord(rpt);
                        notify(obj,'ShowLogMessageMain', ...
                            UserInterface.LogMessageEventData(['Report generation complete: ' fullName],'info'));
                    end
            end

            function appendContent(rpt)
                rpt.ActX_word.ActiveDocument.Characters.Last.Select;
                rpt.ActX_word.Selection.InsertBreak;
                titleStr = datestr(now,'yyyy-mm-dd HH:MM:SS');
                rpt.ActX_word.Selection.TypeText(titleStr);
                rpt.ActX_word.Selection.Style = 'Heading 1';
                rpt.ActX_word.Selection.TypeParagraph;
                addContent(rpt);
            end

            function addContent(rpt)
                [analysisObjs, selObjLogic] = getSelectedAnalysisData();
                if isempty(analysisObjs) || isempty(selObjLogic)
                    return;
                end

                if ~isfield(selObjLogic, 'Selected')
                    return;
                end

                selectedMask = [selObjLogic.Selected];
                if isempty(selectedMask)
                    return;
                end

                selectedIdx = find(selectedMask);
                if isempty(selectedIdx)
                    return;
                end

                for n = 1:numel(selectedIdx)
                    analysisIdx = selectedIdx(n);
                    if analysisIdx > numel(analysisObjs)
                        continue;
                    end

                    analysisTitle = analysisObjs(analysisIdx).Title;
                    if isa(analysisTitle,'string')
                        analysisTitle = strjoin(cellstr(analysisTitle));
                    elseif iscell(analysisTitle)
                        analysisTitle = strjoin(cellfun(@(c) char(c), analysisTitle, 'UniformOutput', false), ' ');
                    end
                    if isempty(analysisTitle)
                        analysisTitle = sprintf('Analysis Task %d', analysisIdx);
                    end
                    analysisTitle = char(analysisTitle);

                    rpt.ActX_word.Selection.TypeText(analysisTitle);
                    rpt.ActX_word.Selection.Style = 'Heading 1';
                    rpt.ActX_word.Selection.TypeParagraph;

                    analysisHasContent = false;
                    analysisBreakInsertedAtEnd = false;

                    [operAdded, breakAfterOper] = addAnalysisOperatingConditionsSection(rpt, analysisIdx);
                    if operAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterOper;
                    end

                    [analysisPlotsAdded, breakAfterAnalysisPlots] = addAnalysisPlotSection(rpt, analysisIdx);
                    if analysisPlotsAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterAnalysisPlots;
                    end

                    [simPlotsAdded, breakAfterSimPlots] = addAnalysisSimulationSection(rpt, analysisIdx);
                    if simPlotsAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterSimPlots;
                    end

                    postSimAdded = addAnalysisPostSimulationSection(rpt, analysisIdx);
                    if postSimAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = false;
                    end

                    if n ~= numel(selectedIdx) && analysisHasContent && ~analysisBreakInsertedAtEnd
                        addPageBreak(rpt);
                    end
                end
            end

            function addPageBreak(rpt, shouldInsert)
                if nargin < 2
                    shouldInsert = true;
                end
                if nargin < 1 || isempty(rpt) || ~shouldInsert
                    return;
                end
                try
                    rpt.ActX_word.Selection.InsertBreak;
                catch
                    % If Word is unavailable, skip the break.
                end
            end

            function contentAdded = addAxisCollectionPlots(coll, heading)
                if nargin < 2
                    heading = '';
                end
                contentAdded = false;
                if isempty(coll); return; end

                headingShown = false;
                for idx = 1:numel(coll)
                    axisColl = coll(idx);
                    if isempty(axisColl) || ~isvalid(axisColl)
                        continue;
                    end

                    panels = axisColl.Panel;
                    if isempty(panels)
                        continue;
                    end

                    for p = 1:numel(panels)
                        panel = panels(p);
                        if isempty(panel) || ~isvalid(panel)
                            continue;
                        end

                        axesList = panel.Axis;
                        for k = 1:numel(axesList)
                            ax = handle(axesList(k));
                            if ~isgraphics(ax)
                                continue;
                            end

                            axType = get(ax,'Type');
                            if ~any(strcmp(axType, {'axes','polaraxes','uiaxes'}))
                                continue;
                            end

                            if isempty(get(ax,'Children'))
                                continue;
                            end

                            imgFile = [tempname '.png'];
                            success = false;
                            try
                                if exist('exportgraphics','file')
                                    exportgraphics(ax, imgFile, 'Resolution', 150);
                                else
                                    fig = ancestor(ax, 'figure');
                                    saveas(fig, imgFile);
                                end
                                success = true;
                            catch
                                success = false;
                            end

                            if ~success
                                continue;
                            end

                            if ~headingShown
                                if ~isempty(heading)
                                    rpt.ActX_word.Selection.TypeText(heading);
                                    rpt.ActX_word.Selection.Style = 'Heading 2';
                                    rpt.ActX_word.Selection.TypeParagraph;
                                end
                                headingShown = true;
                            end

                            titleObj = get(ax,'Title');
                            titleStr = '';
                            if ~isempty(titleObj)
                                titleStr = get(titleObj,'String');
                            end
                            if iscell(titleStr)
                                titleStr = strjoin(titleStr,' ');
                            elseif isa(titleStr,'string')
                                titleStr = strjoin(cellstr(titleStr));
                            elseif isnumeric(titleStr)
                                titleStr = num2str(titleStr);
                            end
                            if isempty(titleStr)
                                titleStr = 'Plot';
                            end

                            try
                                addFigure(rpt, struct('Filename', imgFile, 'Title', titleStr));
                            catch
                                % Continue without this figure on failure
                            end
                        end
                    end
                end
                contentAdded = headingShown;
            end

            function contentAdded = addSimAxisPlots(simColl, heading)
                if nargin < 2
                    heading = '';
                end
                contentAdded = false;
                if isempty(simColl); return; end
                headingShown = false;
                for s = 1:numel(simColl)
                    try
                        coll = simColl(s).AxisPanelCollObj;
                        if isempty(coll) || isempty(coll.Panel); continue; end
                        panels = coll.Panel;
                        simTitle = obj.getSimulationPageTitle(simColl(s), s);
                        simTitleSafe = strrep(simTitle, '%', '%%');
                        visStates = arrayfun(@(p) p.Visible, panels);
                        for p = 1:numel(panels)
                            for j = 1:numel(panels)
                                panels(j).Visible = (j == p);
                            end
                            drawnow();
                            panelHandle = panels(p).Panel;

                            hasData = false;
                            for k = 1:length(panels(p).Axis)
                                ax = panels(p).Axis(k);
                                if isgraphics(ax) && ~isempty(get(ax,'Children'))
                                    hasData = true; break;
                                end
                            end
                            if ~hasData
                                continue;
                            end

                            imgFile = [tempname '.png'];
                            success = false;
                            try
                                if exist('exportgraphics','file')
                                    exportgraphics(panelHandle, imgFile, 'Resolution', 150);
                                else
                                    fr = getframe(panelHandle);
                                    imwrite(fr.cdata, imgFile);
                                end
                                success = true;
                            catch
                                success = false;
                            end

                            if ~success
                                continue;
                            end

                            if ~headingShown
                                if ~isempty(heading)
                                    rpt.ActX_word.Selection.TypeText(heading);
                                    rpt.ActX_word.Selection.Style = 'Heading 2';
                                    rpt.ActX_word.Selection.TypeParagraph;
                                end
                                headingShown = true;
                            end

                            titleStr = sprintf('%s - Page %d', simTitleSafe, p);
                            try
                                addFigure(rpt, struct('Filename', imgFile, 'Title', titleStr));
                            catch
                                % Ignore failures for this panel
                            end
                        end
                        for j = 1:numel(panels)
                            panels(j).Visible = visStates(j);
                        end
                    catch
                        % Ignore invalid simulation viewers
                    end
                end
                contentAdded = headingShown;
            end

            function [analysisObjs, selObjLogic] = getSelectedAnalysisData()
                analysisObjs = lacm.AnalysisTask.empty;
                selObjLogic = struct('Selected', {});
                if isempty(obj.Tree)
                    return;
                end
                if isa(obj.Tree,'handle') && ~isvalid(obj.Tree)
                    return;
                end
                try
                    [analysisObjs, selObjLogic] = getAnalysisObjs(obj.Tree, false);
                catch
                    analysisObjs = lacm.AnalysisTask.empty;
                    selObjLogic = struct('Selected', {});
                end
            end

            function occ = getOperCondCollectionForIndex(index)
                occ = [];
                if isempty(obj.OperCondCollObj) || index > numel(obj.OperCondCollObj)
                    return;
                end
                candidate = obj.OperCondCollObj(index);
                if isValidHandleObject(candidate)
                    occ = candidate;
                end
            end

            function header = getOperCondHeaderForIndex(index)
                fc1 = getFlightConditionSelection(index, 'FC1');
                fc2 = getFlightConditionSelection(index, 'FC2');
                header = {'', fc1, fc2, 'All', 'All'};
            end

            function value = getFlightConditionSelection(index, prefix)
                value = 'All';
                tcObj = getTrimTaskCollectionForIndex(index);
                if isempty(tcObj)
                    return;
                end
                fcCandidate = getFlightConditionValue(tcObj, prefix);
                if ~isempty(fcCandidate)
                    value = fcCandidate;
                end
            end

            function value = getFlightConditionValue(tcObj, prefix)
                value = 'All';
                strProp = sprintf('%s_PM_String', prefix);
                selProp = sprintf('%s_PM_SelValue', prefix);
                if ~isprop(tcObj, strProp) || ~isprop(tcObj, selProp)
                    return;
                end
                fcStrings = tcObj.(strProp);
                selValue = tcObj.(selProp);
                if isempty(fcStrings) || isempty(selValue)
                    return;
                end
                idx = double(selValue(1));
                if idx < 1 || idx > numel(fcStrings)
                    return;
                end
                fcCandidate = fcStrings{idx};
                if ~isempty(fcCandidate)
                    value = fcCandidate;
                end
            end

            function tcObj = getTrimTaskCollectionForIndex(index)
                tcObj = [];
                if ~isempty(obj.TaskCollectionObj) && index <= numel(obj.TaskCollectionObj)
                    candidate = obj.TaskCollectionObj(index);
                    if isValidHandleObject(candidate)
                        tcObj = candidate;
                        return;
                    end
                end
                if ~isempty(obj.TaskCollectionObjBatch) && index <= numel(obj.TaskCollectionObjBatch)
                    batchCandidate = obj.TaskCollectionObjBatch(index);
                    if isValidHandleObject(batchCandidate)
                        trimList = batchCandidate.TrimTaskCollObj;
                        if ~isempty(trimList)
                            candidate = trimList(1);
                            if isValidHandleObject(candidate)
                                tcObj = candidate;
                                return;
                            end
                        end
                    end
                end
            end

            function tf = isValidHandleObject(objCandidate)
                tf = ~isempty(objCandidate);
                if ~tf
                    return;
                end
                if isa(objCandidate,'handle')
                    tf = isvalid(objCandidate);
                end
            end

            function coll = getAxisCollectionForIndex(collArray, index)
                coll = [];
                if isempty(collArray) || index > numel(collArray)
                    return;
                end
                candidate = collArray(index);
                if isValidHandleObject(candidate)
                    coll = candidate;
                end
            end

            function [added, breakInserted] = addAnalysisOperatingConditionsSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                occ = getOperCondCollectionForIndex(analysisIdx);
                if isempty(occ)
                    return;
                end
                try
                    tableData = occ.TableData;
                catch
                    tableData = [];
                end
                if isempty(tableData)
                    return;
                end
                header = getOperCondHeaderForIndex(analysisIdx);
                rpt.ActX_word.Selection.TypeText('Operating Conditions');
                rpt.ActX_word.Selection.Style = 'Heading 2';
                rpt.ActX_word.Selection.TypeParagraph;
                try
                    addOperCondTable(rpt, occ.OperatingCondition, header);
                catch
                    return;
                end
                addPageBreak(rpt);
                added = true;
                breakInserted = true;
            end

            function [added, breakInserted] = addAnalysisPlotSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                coll = getAxisCollectionForIndex(obj.AxisColl, analysisIdx);
                if isempty(coll)
                    return;
                end
                added = addAxisCollectionPlots(coll, 'Analysis Plots');
                if added
                    addPageBreak(rpt, true);
                    breakInserted = true;
                end
            end

            function [added, breakInserted] = addAnalysisSimulationSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                coll = getAxisCollectionForIndex(obj.SimAxisColl, analysisIdx);
                if isempty(coll)
                    return;
                end
                added = addSimAxisPlots(coll, 'Simulation Plots');
                if added
                    addPageBreak(rpt, true);
                    breakInserted = true;
                end
            end

            function added = addAnalysisPostSimulationSection(rpt, analysisIdx)
                coll = getAxisCollectionForIndex(obj.PostSimAxisColl, analysisIdx);
                if isempty(coll)
                    added = false;
                    return;
                end
                added = addAxisCollectionPlots(coll, 'Post-Simulation Plots');
            end
        end % generateReportLegacy

        function generateReportOpenSource(obj)
            %GENERATEREPORTOPENSOURCE Export a report and save as PDF.
            %   Mirrors generateReportLegacy but always writes a PDF file.

            rptType = questdlg('Select report type', 'Export Report', ...
                'New', 'Template', 'Append', 'New');
            if isempty(rptType); return; end

            switch rptType
                case 'Append'
                    [file,path] = uigetfile({'*.docx','Word Document (*.docx)'}, ...
                        'Select Report to Append');
                    if isequal(file,0); return; end
                    fullName = fullfile(path,file);
                    outName = fullfile(path,[erase(file,'.docx'),'.pdf']);
                    try
                        rpt = Report(fullName,'Visible',true);
                    catch
                        warndlg('Microsoft Word is required to export reports.', 'Report');
                        return;
                    end
                    appendContent(rpt);
                    updateTOC(rpt);
                    updateTOF(rpt);
                    saveAs(rpt, outName);
                    closeWord(rpt);
                    notify(obj,'ShowLogMessageMain', ...
                        UserInterface.LogMessageEventData(['Report generation complete: ' outName],'info'));

                otherwise % 'New' or 'Template'
                    if strcmp(rptType,'Template')
                        [tmplFile,tmplPath] = uigetfile({'*.docx','Word Document (*.docx)'}, ...
                            'Select Template');
                        if isequal(tmplFile,0); return; end
                        fullName = fullfile(tmplPath,tmplFile);
                        outName = fullfile(tmplPath,[erase(tmplFile,'.docx'),'_NEW.pdf']);
                        try
                            rpt = Report(fullName,'Visible',true);
                        catch
                            warndlg('Microsoft Word is required to export reports.', 'Report');
                            return;
                        end
                        appendContent(rpt);
                        updateTOC(rpt);
                        updateTOF(rpt);
                        saveAs(rpt,outName);
                        closeWord(rpt);
                        notify(obj,'ShowLogMessageMain', ...
                            UserInterface.LogMessageEventData(['Report generation complete: ' outName],'info'));
                    else % New report
                        [file,path] = uiputfile({'*.pdf'}, ...
                            'Export Report', 'AnalysisReport.pdf');
                        if isequal(file,0); return; end
                        fullName = fullfile(path,file);
                        try
                            rpt = Report(fullName);
                        catch
                            warndlg('Microsoft Word is required to export reports.', 'Report');
                            return;
                        end
                        % Title page
                        rpt.ActX_word.Selection.TypeText('Flight Dynamics Report');
                        rpt.ActX_word.Selection.Style = 'Title';
                        rpt.ActX_word.Selection.TypeParagraph;

                        % Table of contents and figures placeholders
                        rpt.ActX_word.Selection.TypeText('Table of Contents');
                        rpt.ActX_word.Selection.Style = 'Heading 1';
                        rpt.ActX_word.Selection.TypeParagraph;
                        addTOC(rpt);
                        rpt.ActX_word.Selection.InsertBreak;
                        rpt.ActX_word.Selection.TypeText('Table of Figures');
                        rpt.ActX_word.Selection.Style = 'Heading 1';
                        rpt.ActX_word.Selection.TypeParagraph;
                        addTOF(rpt);
                        rpt.ActX_word.Selection.InsertBreak;

                        addContent(rpt);
                        updateTOC(rpt);
                        updateTOF(rpt);
                        saveAs(rpt, fullName);
                        closeWord(rpt);
                        notify(obj,'ShowLogMessageMain', ...
                            UserInterface.LogMessageEventData(['Report generation complete: ' fullName],'info'));
                    end
            end

            function appendContent(rpt)
                rpt.ActX_word.ActiveDocument.Characters.Last.Select;
                rpt.ActX_word.Selection.InsertBreak;
                titleStr = datestr(now,'yyyy-mm-dd HH:MM:SS');
                rpt.ActX_word.Selection.TypeText(titleStr);
                rpt.ActX_word.Selection.Style = 'Heading 1';
                rpt.ActX_word.Selection.TypeParagraph;
                addContent(rpt);
            end

            function addContent(rpt)
                [analysisObjs, selObjLogic] = getSelectedAnalysisData();
                if isempty(analysisObjs) || isempty(selObjLogic)
                    return;
                end

                if ~isfield(selObjLogic, 'Selected')
                    return;
                end

                selectedMask = [selObjLogic.Selected];
                if isempty(selectedMask)
                    return;
                end

                selectedIdx = find(selectedMask);
                if isempty(selectedIdx)
                    return;
                end

                for n = 1:numel(selectedIdx)
                    analysisIdx = selectedIdx(n);
                    if analysisIdx > numel(analysisObjs)
                        continue;
                    end

                    analysisTitle = analysisObjs(analysisIdx).Title;
                    if isa(analysisTitle,'string')
                        analysisTitle = strjoin(cellstr(analysisTitle));
                    elseif iscell(analysisTitle)
                        analysisTitle = strjoin(cellfun(@(c) char(c), analysisTitle, 'UniformOutput', false), ' ');
                    end
                    if isempty(analysisTitle)
                        analysisTitle = sprintf('Analysis Task %d', analysisIdx);
                    end
                    analysisTitle = char(analysisTitle);

                    rpt.ActX_word.Selection.TypeText(analysisTitle);
                    rpt.ActX_word.Selection.Style = 'Heading 1';
                    rpt.ActX_word.Selection.TypeParagraph;

                    analysisHasContent = false;
                    analysisBreakInsertedAtEnd = false;

                    [operAdded, breakAfterOper] = addAnalysisOperatingConditionsSection(rpt, analysisIdx);
                    if operAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterOper;
                    end

                    [analysisPlotsAdded, breakAfterAnalysisPlots] = addAnalysisPlotSection(rpt, analysisIdx);
                    if analysisPlotsAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterAnalysisPlots;
                    end

                    [simPlotsAdded, breakAfterSimPlots] = addAnalysisSimulationSection(rpt, analysisIdx);
                    if simPlotsAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = breakAfterSimPlots;
                    end

                    postSimAdded = addAnalysisPostSimulationSection(rpt, analysisIdx);
                    if postSimAdded
                        analysisHasContent = true;
                        analysisBreakInsertedAtEnd = false;
                    end

                    if n ~= numel(selectedIdx) && analysisHasContent && ~analysisBreakInsertedAtEnd
                        addPageBreak(rpt);
                    end
                end
            end

            function addPageBreak(rpt, shouldInsert)
                if nargin < 2
                    shouldInsert = true;
                end
                if nargin < 1 || isempty(rpt) || ~shouldInsert
                    return;
                end
                try
                    rpt.ActX_word.Selection.InsertBreak;
                catch
                    % If Word is unavailable, skip the break.
                end
            end

            function contentAdded = addAxisCollectionPlots(coll, heading)
                if nargin < 2
                    heading = '';
                end
                contentAdded = false;
                if isempty(coll); return; end

                headingShown = false;
                for idx = 1:numel(coll)
                    axisColl = coll(idx);
                    if isempty(axisColl) || ~isvalid(axisColl)
                        continue;
                    end

                    panels = axisColl.Panel;
                    if isempty(panels)
                        continue;
                    end

                    for p = 1:numel(panels)
                        panel = panels(p);
                        if isempty(panel) || ~isvalid(panel)
                            continue;
                        end

                        axesList = panel.Axis;
                        for k = 1:numel(axesList)
                            ax = axesList(k);
                            if ~isgraphics(ax)
                                continue;
                            end

                            axType = get(ax,'Type');
                            if ~any(strcmp(axType, {'axes','polaraxes','uiaxes'}))
                                continue;
                            end

                            if isempty(get(ax,'Children'))
                                continue;
                            end

                            imgFile = [tempname '.png'];
                            success = false;
                            try
                                if exist('exportgraphics','file')
                                    exportgraphics(ax, imgFile, 'Resolution', 150);
                                else
                                    fig = ancestor(ax, 'figure');
                                    saveas(fig, imgFile);
                                end
                                success = true;
                            catch
                                success = false;
                            end

                            if ~success
                                continue;
                            end

                            if ~headingShown
                                if ~isempty(heading)
                                    rpt.ActX_word.Selection.TypeText(heading);
                                    rpt.ActX_word.Selection.Style = 'Heading 2';
                                    rpt.ActX_word.Selection.TypeParagraph;
                                end
                                headingShown = true;
                            end

                            titleObj = get(ax,'Title');
                            titleStr = '';
                            if ~isempty(titleObj)
                                titleStr = get(titleObj,'String');
                            end
                            if iscell(titleStr)
                                titleStr = strjoin(titleStr,' ');
                            elseif isa(titleStr,'string')
                                titleStr = strjoin(cellstr(titleStr));
                            elseif isnumeric(titleStr)
                                titleStr = num2str(titleStr);
                            end
                            if isempty(titleStr)
                                titleStr = 'Plot';
                            end

                            try
                                addFigure(rpt, struct('Filename', imgFile, 'Title', titleStr));
                            catch
                                % Continue without this figure on failure
                            end
                        end
                    end
                end
                contentAdded = headingShown;
            end

            function contentAdded = addSimAxisPlots(simColl, heading)
                if nargin < 2
                    heading = '';
                end
                contentAdded = false;
                if isempty(simColl); return; end
                headingShown = false;
                for s = 1:numel(simColl)
                    try
                        coll = simColl(s).AxisPanelCollObj;
                        if isempty(coll) || isempty(coll.Panel); continue; end
                        panels = coll.Panel;
                        simTitle = obj.getSimulationPageTitle(simColl(s), s);
                        simTitleSafe = strrep(simTitle, '%', '%%');
                        visStates = arrayfun(@(p) p.Visible, panels);
                        for p = 1:numel(panels)
                            for j = 1:numel(panels)
                                panels(j).Visible = (j == p);
                            end
                            drawnow();
                            panelHandle = panels(p).Panel;

                            hasData = false;
                            for k = 1:length(panels(p).Axis)
                                ax = panels(p).Axis(k);
                                if isgraphics(ax) && ~isempty(get(ax,'Children'))
                                    hasData = true; break;
                                end
                            end
                            if ~hasData
                                continue;
                            end

                            imgFile = [tempname '.png'];
                            success = false;
                            try
                                if exist('exportgraphics','file')
                                    exportgraphics(panelHandle, imgFile, 'Resolution', 150);
                                else
                                    fr = getframe(panelHandle);
                                    imwrite(fr.cdata, imgFile);
                                end
                                success = true;
                            catch
                                success = false;
                            end

                            if ~success
                                continue;
                            end

                            if ~headingShown
                                if ~isempty(heading)
                                    rpt.ActX_word.Selection.TypeText(heading);
                                    rpt.ActX_word.Selection.Style = 'Heading 2';
                                    rpt.ActX_word.Selection.TypeParagraph;
                                end
                                headingShown = true;
                            end

                            titleStr = sprintf('%s - Page %d', simTitleSafe, p);
                            try
                                addFigure(rpt, struct('Filename', imgFile, 'Title', titleStr));
                            catch
                                % Ignore failures for this panel
                            end
                        end
                        for j = 1:numel(panels)
                            panels(j).Visible = visStates(j);
                        end
                    catch
                        % Ignore invalid simulation viewers
                    end
                end
                contentAdded = headingShown;
            end

            function [analysisObjs, selObjLogic] = getSelectedAnalysisData()
                analysisObjs = lacm.AnalysisTask.empty;
                selObjLogic = struct('Selected', {});
                if isempty(obj.Tree)
                    return;
                end
                if isa(obj.Tree,'handle') && ~isvalid(obj.Tree)
                    return;
                end
                try
                    [analysisObjs, selObjLogic] = getAnalysisObjs(obj.Tree, false);
                catch
                    analysisObjs = lacm.AnalysisTask.empty;
                    selObjLogic = struct('Selected', {});
                end
            end

            function occ = getOperCondCollectionForIndex(index)
                occ = [];
                if isempty(obj.OperCondCollObj) || index > numel(obj.OperCondCollObj)
                    return;
                end
                candidate = obj.OperCondCollObj(index);
                if isValidHandleObject(candidate)
                    occ = candidate;
                end
            end

            function header = getOperCondHeaderForIndex(index)
                fc1 = getFlightConditionSelection(index, 'FC1');
                fc2 = getFlightConditionSelection(index, 'FC2');
                header = {'', fc1, fc2, 'All', 'All'};
            end

            function value = getFlightConditionSelection(index, prefix)
                value = 'All';
                tcObj = getTrimTaskCollectionForIndex(index);
                if isempty(tcObj)
                    return;
                end
                fcCandidate = getFlightConditionValue(tcObj, prefix);
                if ~isempty(fcCandidate)
                    value = fcCandidate;
                end
            end

            function value = getFlightConditionValue(tcObj, prefix)
                value = 'All';
                strProp = sprintf('%s_PM_String', prefix);
                selProp = sprintf('%s_PM_SelValue', prefix);
                if ~isprop(tcObj, strProp) || ~isprop(tcObj, selProp)
                    return;
                end
                fcStrings = tcObj.(strProp);
                selValue = tcObj.(selProp);
                if isempty(fcStrings) || isempty(selValue)
                    return;
                end
                idx = double(selValue(1));
                if idx < 1 || idx > numel(fcStrings)
                    return;
                end
                fcCandidate = fcStrings{idx};
                if ~isempty(fcCandidate)
                    value = fcCandidate;
                end
            end

            function tcObj = getTrimTaskCollectionForIndex(index)
                tcObj = [];
                if ~isempty(obj.TaskCollectionObj) && index <= numel(obj.TaskCollectionObj)
                    candidate = obj.TaskCollectionObj(index);
                    if isValidHandleObject(candidate)
                        tcObj = candidate;
                        return;
                    end
                end
                if ~isempty(obj.TaskCollectionObjBatch) && index <= numel(obj.TaskCollectionObjBatch)
                    batchCandidate = obj.TaskCollectionObjBatch(index);
                    if isValidHandleObject(batchCandidate)
                        trimList = batchCandidate.TrimTaskCollObj;
                        if ~isempty(trimList)
                            candidate = trimList(1);
                            if isValidHandleObject(candidate)
                                tcObj = candidate;
                                return;
                            end
                        end
                    end
                end
            end

            function tf = isValidHandleObject(objCandidate)
                tf = ~isempty(objCandidate);
                if ~tf
                    return;
                end
                if isa(objCandidate,'handle')
                    tf = isvalid(objCandidate);
                end
            end

            function coll = getAxisCollectionForIndex(collArray, index)
                coll = [];
                if isempty(collArray) || index > numel(collArray)
                    return;
                end
                candidate = collArray(index);
                if isValidHandleObject(candidate)
                    coll = candidate;
                end
            end

            function [added, breakInserted] = addAnalysisOperatingConditionsSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                occ = getOperCondCollectionForIndex(analysisIdx);
                if isempty(occ)
                    return;
                end
                try
                    tableData = occ.TableData;
                catch
                    tableData = [];
                end
                if isempty(tableData)
                    return;
                end
                header = getOperCondHeaderForIndex(analysisIdx);
                rpt.ActX_word.Selection.TypeText('Operating Conditions');
                rpt.ActX_word.Selection.Style = 'Heading 2';
                rpt.ActX_word.Selection.TypeParagraph;
                try
                    addOperCondTable(rpt, occ.OperatingCondition, header);
                catch
                    return;
                end
                addPageBreak(rpt);
                added = true;
                breakInserted = true;
            end

            function [added, breakInserted] = addAnalysisPlotSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                coll = getAxisCollectionForIndex(obj.AxisColl, analysisIdx);
                if isempty(coll)
                    return;
                end
                added = addAxisCollectionPlots(coll, 'Analysis Plots');
                if added
                    addPageBreak(rpt, true);
                    breakInserted = true;
                end
            end

            function [added, breakInserted] = addAnalysisSimulationSection(rpt, analysisIdx)
                added = false;
                breakInserted = false;
                coll = getAxisCollectionForIndex(obj.SimAxisColl, analysisIdx);
                if isempty(coll)
                    return;
                end
                added = addSimAxisPlots(coll, 'Simulation Plots');
                if added
                    addPageBreak(rpt, true);
                    breakInserted = true;
                end
            end

            function added = addAnalysisPostSimulationSection(rpt, analysisIdx)
                coll = getAxisCollectionForIndex(obj.PostSimAxisColl, analysisIdx);
                if isempty(coll)
                    added = false;
                    return;
                end
                added = addAxisCollectionPlots(coll, 'Post-Simulation Plots');
            end
        end % generateReportOpenSource

        function reqObjCreated( obj , ~ , eventdata )
            reqObj = eventdata.Object;
            switch class(reqObj)
                case 'lacm.TrimSettings'
                    insertTrimDefObj_CB( obj.Tree , [] , [] , obj.Tree.TrimDefNode , [] , reqObj);
                case 'lacm.LinearModel'
                    insertLinMdlObj_CB( obj.Tree , [] , [] , obj.Tree.LinMdlDefNode , [] , reqObj);
                case 'Requirements.RequirementTypeOne'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.MethodNode , [] , reqObj);
                case 'Requirements.SimulationCollection'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.SimulationObjectNode , [] , reqObj);
%                 case 'Requirements.RequirementTypeOnePost'
%                     insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.PostSimulationObjectNode , [] , reqObj);
                case 'lacm.AnalysisTask'
                    insertAnalysisObj_CB( obj.Tree , [] , [] , obj.Tree.AnalysisNode , [] , reqObj);
            end
            autoSaveFile( obj , [] , [] );
        end % reqObjCreated
        
    end
    
    %% Methods - Workspace Callbacks
    methods
        
        function saveWorkspace( obj , ~ , ~  )
            
            [file,path] = uiputfile( ...
                {'*.fltd',...
                 'FLIGHTdynamics Project Files (*.fltd)';
                 '*.*',  'All Files (*.*)'},...
                 'Save Project as',obj.SavedProjectLocation);%fullfile(obj.ProjectDirectory,'Project.fltc'));
            if isequal(file,0) || isequal(path,0)
                return;
            else
                notify(obj,'SaveProject',GeneralEventData({path , file}) );
            end
                
        end %saveWorkspace
        
        function loadWorkspace( obj , ~ , ~  )            
            Utilities.setWaitPtr(obj.Figure);
            [filename, pathname] = uigetfile(...%{'*.mat'},'Select saved project');
                                {'*.fltd',...
                                 'FLIGHTdynamics Project Files (*.fltd)';
                                 '*.*',  'All Files (*.*)'},...
                                 'Select Saved Project',...
                                 obj.ProjectDirectory);
                             drawnow();pause(0.5);

            % load and assign objects
            if ~isequal(filename,0) 
                
                % Ensure user want to continue
                choice = questdlg('The current project will close. Would you like to continue?', ...
                    'Close Project?', ...
                    'Yes','No','No');
                % Handle response
                switch choice
                    case 'Yes'
                        notify(obj,'LoadProject',GeneralEventData({pathname , filename}));
%                         loadProject( obj , pathname , filename );
                    otherwise
                        return;
                end

                
            end 
            Utilities.releaseWaitPtr(obj.Figure);
            reSize( obj , [] , [] );
        end % loadWorkspace
        
        function saveProject( obj , path , file )
            notify(obj,'SaveProject',GeneralEventData({path , file}));
        end % saveAsProject
               
    end
    
    %% Methods - Load Project
    methods 
       
        function loadProject( obj , pathname , filename )
            notify(obj,'LoadProject',GeneralEventData({pathname , filename}));
            reSize( obj , [] , [] );
        end % loadWorkspace_CB
        
        function addProjectPath( obj , path )
            addProjectPath@UserInterface.Level1Container( obj , path )
        end % addProjectPath
        
    end    
      
    %% Methods - Run Trim Callbacks
    methods (Access = protected) 
        
        function runTask( obj , ~ , ~ )
            
            try
                
                % Run the trims
                run( obj );
                
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Complete','info'));
                %--------------------------------------------------------------
                releaseWaitPtr(obj); 
                
            catch MExc   
                
                releaseWaitPtr(obj);
                handleErrors( obj , MExc );
            end
            
            try
                % obj.LogPanel.toFile(fullfile(pwd,'logfile.html'));
                if isfolder(obj.ProjectDirectory)
                    obj.LogPanel.toFile(fullfile(obj.ProjectDirectory,'logfile.html'));
                else
                    obj.LogPanel.toFile(fullfile(pwd,'logfile.html'));
                end
            catch
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to create log file.','warn'));
                %--------------------------------------------------------------   
            end
            
        end % runTask
        
        function runTaskAndSave( obj , ~ , ~ )
            
            try
                
                % Run the trims
                run( obj );
                
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                %notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Saving Project...','info'));
                %--------------------------------------------------------------
                notify(obj,'SaveProject');%saveProject( obj );
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Complete','info'));
                %--------------------------------------------------------------
                releaseWaitPtr(obj); 
                
            catch MExc   
                
                releaseWaitPtr(obj);
               
%                 rethrow(MExc);
                handleErrors( obj , MExc );
            end
            
            try
                %obj.LogPanel.toFile(fullfile(pwd,'logfile.html'));
                if isfolder(obj.ProjectDirectory)
                    obj.LogPanel.toFile(fullfile(obj.ProjectDirectory,'logfile.html'));
                else
                    obj.LogPanel.toFile(fullfile(pwd,'logfile.html'));
                end
            catch
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to create log file.','warn'));
                %--------------------------------------------------------------   
            end
            
        end % runTaskAndSave
        
        function operCond = run( obj )
            
            % Profile ON
            %profile('on');
            
            % Define a cleanup function in the event the users uses ctrl-c
            %cleanupObj = onCleanup(@obj.cleanFromRun);
            
            operCond = lacm.OperatingCondition.empty;
            
            % Check for license key
            checkKey( obj );

            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running...','info'));
            %--------------------------------------------------------------

            setWaitPtr(obj);

            % Auto Clear when runnning
            %clearTable( obj , [] , []  );

            [ analysisObjs , selObjLogic ] = getAnalysisObjs( obj.Tree , false );
            selArray = [selObjLogic.Selected];
            for ind = 1:length(analysisObjs)
                if selArray(ind)
                    %--------------------------------------------------------------
                    %    Display Log Messagetesting
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Running Analysis - ',analysisObjs(ind).Title,'.'],'info'));
                    %--------------------------------------------------------------

                    % Write Constants to workspace

%                         params = obj.ConstantsParamColl(ind).Parameters;
%                         for i = 1:length(params)     
%                             assignin('base', params(i).Name, params(i).Value);
%                         end


                    %%-------------------NEW TESTING-------------------

                    uniqueMdlNames = getAllModelsInAnalysisObj(analysisObjs(ind));
                    
                    for i=1:length(uniqueMdlNames)
                        if ~bdIsLoaded(uniqueMdlNames{i})
                            load_system(uniqueMdlNames{i});
                        end
                        SimStatus(i) = strcmp(get_param(uniqueMdlNames{i}, 'SimulationStatus'),'paused');
                    end
                    
                    if isempty(find(SimStatus,1)) % Only get params when model is not compiled.
                        defaultParams = getAllDefaultModelParameters(uniqueMdlNames );
                        updateDefaultParameters( obj.ConstantsParamColl(ind), defaultParams );

                        globalParamsOnly = obj.ConstantsParamColl(ind).Parameters([obj.ConstantsParamColl(ind).Parameters.Global]);

                        UserInterface.StabilityControl.Utilities.assignParameters2Model( uniqueMdlNames , globalParamsOnly );
                    end
                    %%-------------------------------------------------




                    % Check for batch files
                    selBatchLA = obj.Tree.getSelectedBatchLA( ind );

                    if any(selBatchLA)
                        taskObjs = lacm.TrimTask.empty;
                        for i = 1:length(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj)
                            if selBatchLA(i)
                                massProps = obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).MassPropertiesObjects(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).BasicTableRowSelectedLA);
                                if isempty(massProps)
                                    massProps = copy(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).MassPropertiesObjects(1));
                                    massProps.DummyMode = true;
                                end
                                if isempty(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).SelectedTrimDef)
                                    tempTrimSetting = analysisObjs(ind).TrimTask;
                                else
                                    tempTrimSetting = obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i).SelectedTrimDef;
                                end
                                % Call TrimTaskCollection Method "createTaskObjManual"  
                                tempTaskObjs = createTaskObjManual(obj.TaskCollectionObjBatch(ind).TrimTaskCollObj(i),...
                                    tempTrimSetting.SimulinkModelName,...
                                    getConstantsFile( obj.Tree ),...
                                    tempTrimSetting,...
                                    analysisObjs(ind).LinearModelDef(selObjLogic(ind).LinearModel),...
                                    massProps,...
                                    obj.UseAllCombinationsState);  
                                taskObjs = [taskObjs,tempTaskObjs]; %#ok<AGROW> 
                            end
                        end  
                    else

                    end

                    if isempty(taskObjs)
                        errordlg('Not enough information from the user to complete the trim.');
                        return;
                    end
                    for i = 1:length(taskObjs)
                        taskObjs(i).FlightCondition.SimulationUnits = obj.Units;
                    end
                    saveFormat = getSaveFormat(taskObjs);
                    
                    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                uniqueMdlNamesInAnalysisObj = getAllModelsInAnalysisObj( analysisObjs(ind) ) ; 
                simStateAll = {};
                for i = 1:length(uniqueMdlNamesInAnalysisObj)
                    if ~bdIsLoaded(uniqueMdlNamesInAnalysisObj{i}) 
                        load_system(uniqueMdlNamesInAnalysisObj{i});
                    end
                    simStateAll{i} = get_param(uniqueMdlNamesInAnalysisObj{i}, 'SimulationStatus');
                end 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                simObjs = analysisObjs(ind).SimulationRequirment(selObjLogic(ind).SimulationRequirment); 
                simState = {};
                if ~isempty(simObjs)
                    %Get all mdl states
                    mdlname = {simObjs.MdlName};
                    
                    for i = 1:length(mdlname)
                        if ~bdIsLoaded(mdlname{i}) 
                            load_system(mdlname{i});
                        end
                        simState{i} = get_param(mdlname{i}, 'SimulationStatus');
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
                    
                if ~obj.UseExistingTrimState && ...
                        ~isempty(obj.OperCondCollObj(ind).OperatingCondition)
                    % Use previously computed operating conditions
                    operCond = obj.OperCondCollObj(ind).OperatingCondition;
                    linMdlSel = selObjLogic(ind).LinearModel;
                    if any(linMdlSel)
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData( ...
                            'Running linearization on existing operating condition.','info'));
                        linMdlObj = analysisObjs(ind).LinearModelDef(linMdlSel);
                        for k = 1:numel(operCond)
                            runLinearization(operCond(k), linMdlObj);
                        end
                    else
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData( ...
                            'Linearization not run - no linear model selected.','info'));
                    end
                else
                    % ******Run trims *******
                    operCond = lacm.OperatingCondition( taskObjs, obj.TrimSettings);
                    % Assign a unique color to each new operating condition
                    existingCount = length(obj.OperCondCollObj(ind).OperatingCondition);
                    colorMap = round(255*lines(existingCount + length(operCond)));
                    for ocIdx = 1:length(operCond)
                        operCond(ocIdx).Color = colorMap(existingCount + ocIdx,:);
                    end
                    resetSaveFormat( saveFormat );
                    % Get Logged Signal Data for trim
                    if obj.RunSignalLog
                        %--------------------------------------------------------------
                        %    Display Log Message
                        %--------------------------------------------------------------
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Running Signal Logging.'],'info'));
                        %--------------------------------------------------------------
                        releaseAllTrimMdls(obj, [], []);
                        setSignalLoggingData( operCond );
                    end

                    % Check and display message for bad trims
                    logArray  = [operCond.SuccessfulTrim];
                    TotalTrims= length(operCond);
                    BadTrimsID= find(logArray==0);
                    BadTrims  = length(BadTrimsID);

                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Total Trims: ' num2str(TotalTrims)],'info'));
                    if isempty(BadTrimsID)
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Succesful Trims: ' num2str(TotalTrims)],'info'));
                    else
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Succesful Trims: ' num2str(TotalTrims-BadTrims)],'info'));
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Incorrect Trims: '  num2str(BadTrims) ],'warn'));
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Incorrect Trim #: '  strjoin(arrayfun(@(x) num2str(x),BadTrimsID,'UniformOutput',false),',') ],'warn'));

                        unTrimErrors = unique({operCond.IncorrectTrimText});
                        for i = 1:length(unTrimErrors)
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Trim Error: ' unTrimErrors{i} ],'warn'));
                        end
                    end

                    obj.OperCondCollObj(ind).add(operCond);
                    newFunction( obj.OperCondCollObj(ind).OperCondColumnFilterObj );
                end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %********************* Run Methods ************************
                    methodObjs = analysisObjs(ind).Requirement(selObjLogic(ind).Requirement); %getSelectedMethodObjs( obj.Tree );  
                    try  
                        % Turn off all axis first
                        for i = 0:obj.AxisColl(ind).AxisHandleQueue.size-1
                            cla(obj.AxisColl(ind).AxisHandleQueue.get(i),'reset');
                            set(obj.AxisColl(ind).AxisHandleQueue.get(i),'Visible','off');
                        end
                        if ~isempty(methodObjs)
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Requierments...','info'));
                            runDynamics( methodObjs , obj.AxisColl(ind).AxisHandleQueue , operCond ); 
                        end

                        axHQueue = obj.AxisColl(ind).AxisHandleQueue;
                        for i = 0:axHQueue.size-1
                            set(axHQueue.get(i),'ButtonDownFcn',@obj.buttonClickInAxis);
                        end
                    catch MExc
                        if MExc.identifier
                            rethrow(MExc);
                        else
                            error('FlightDynamics:UnknownError',['There is an unkown error running the Requierment ',obj.Title,'.']);
                        end
                    end
                    %********************* Run Simulation ************************
                    simObjs = analysisObjs(ind).SimulationRequirment(selObjLogic(ind).SimulationRequirment); %getSelectedSimulationObjs( obj.Tree );  
                    try  
                        for i = 0:obj.PostSimAxisColl(ind).AxisHandleQueue.size-1
                            cla(handle(obj.PostSimAxisColl(ind).AxisHandleQueue.get(i)),'reset');
                            set(handle(obj.PostSimAxisColl(ind).AxisHandleQueue.get(i)),'Visible','off');
                        end
                        if ~isempty(simObjs)
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Simulation Requirements...','info'));

                            simObjLogMessListen = listener(simObjs(1),'ShowLogMessage',@obj.showLogMessage_CB);

                            
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %Get all mdl states
%                 mdlname = {simObjs.MdlName};
%                 simState = {};
%                 for i = 1:length(mdlname)
%                     if ~bdIsLoaded(mdlname{i}) 
%                         load_system(mdlname{i});
%                     end
%                     simState{i} = get_param(mdlname{i}, 'SimulationStatus');
%                 end
% 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                
                            
                            releaseAllTrimMdls(obj, [], []);
                            
                            
                            runDynamicsSV( simObjs , obj.SimAxisColl(ind) ,obj.PostSimAxisColl(ind).AxisHandleQueue, operCond );

                            
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(simState)            

%                     Utilities.multiWaitbar('Restoring model compilation state...', 0 , 'Color', 'b'); 
                    for i = 1:length(mdlname)
                        if exist(mdlname{i}) == 4 && ~bdIsLoaded(mdlname{i})
                            load_system(mdlname{i});
                        end
                        if strcmp(simState{i},'paused')
                            try
                                feval (mdlname{i}, [], [], [], 'compile');
                            end
                        else
                            try
                                feval (mdlname{i}, [], [], [], 'term');
                            end        
                        end
%                         Utilities.multiWaitbar('Restoring model compilation state...', i/length(mdlname) , 'Color', 'b'); 
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Restored model compilation state.','info'));
                    end


                    setColor4MdlCompiledState(obj.Tree,[], []);

%                     Utilities.multiWaitbar('Restoring model compilation state...', 'close');        
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 
                            
                            
                            
                            
                            
                            
                            
                            delete(simObjLogMessListen);

                        end
                        axHPostQueue = obj.PostSimAxisColl(ind).AxisHandleQueue;
                        for i = 0:axHPostQueue.size-1
                            set(axHPostQueue.get(i),'ButtonDownFcn',@obj.buttonClickInAxis);
                        end
                    catch MExc
                        if MExc.identifier
                            rethrow(MExc);
                        else
                            error('FlightDynamics:Simulation:UnknownError',['There is an unkown error running the Simulation methods.']);
                        end
                    end

                    
                    
                    
                    
                    
                    
                    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(simStateAll)            

%                     Utilities.multiWaitbar('Restoring model compilation state...', 0 , 'Color', 'b'); 
                    for i = 1:length(uniqueMdlNamesInAnalysisObj)
                        if exist(uniqueMdlNamesInAnalysisObj{i}) == 4 && ~bdIsLoaded(uniqueMdlNamesInAnalysisObj{i})
                            load_system(uniqueMdlNamesInAnalysisObj{i});
                        end
                        if strcmp(simStateAll{i},'paused')
                            try
                                feval (uniqueMdlNamesInAnalysisObj{i}, [], [], [], 'compile');
                            end
                        else
                            try
                                feval (uniqueMdlNamesInAnalysisObj{i}, [], [], [], 'term');
                            end        
                        end
%                         Utilities.multiWaitbar('Restoring model compilation state...', i/length(uniqueMdlNamesInAnalysisObj) , 'Color', 'b'); 
                    end


                    setColor4MdlCompiledState(obj.Tree,[], []);
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Restored model compilation state.','info'));

%                     Utilities.multiWaitbar('Restoring model compilation state...', 'close');        
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                    
                    
                    
                    
                    
                    

                    update(obj);

                    cleanUp( obj );
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Trim Complete.','info'));
                    %--------------------------------------------------------------
                    
                    
                    
                end
%                 newFunction( obj.OperCondCollObj(ind).OperCondColumnFilterObj );
                
            end
            
            updateValidTrims(obj)
%             newFunction( obj.OperCondCollObj(ind).OperCondColumnFilterObj );

            setColor4MdlCompiledState(obj.Tree,[], []);
            
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('All analysis complete.','info'));
            %--------------------------------------------------------------

            
            
            %profile('viewer');
        end % run
        
        function cleanFromRun( obj )
                                    
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Trim Cancelled.','warn'));
            %--------------------------------------------------------------
        end % cleanFromRun
        
        function taskObjs = createTaskObjs( obj , ind )
            [ analysisObjs , selObjLogic ] = getAnalysisObjs( obj.Tree , false );

            massProps = getSelectedMassPropObjs( obj.Tree );
            massPropSelArray = obj.TaskCollectionObj(ind).SelectedMassPropArray;

            taskObjs = createTaskObjManual(obj.TaskCollectionObj(ind),getSelectedSimModel( obj.Tree ),...
                getConstantsFile( obj.Tree ),...
                analysisObjs(ind).TrimTask,...
                analysisObjs(ind).LinearModelDef(selObjLogic(ind).LinearModel),...
                massProps(massPropSelArray));      
        end % createTaskObj
        
        function save( obj , operCond )

            selOutputFile = getSelectedOutputFiles( obj.Tree );

            if isempty(selOutputFile)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Saving Trims...','info'));
                %--------------------------------------------------------------
                choice = questdlg('An output file is not selected.  How would you like to proceeed?', ...simState
                    'Saving...', ...
                    'Create a new output file','Open and existing output file','Do not save','Create a new output file');

                 % Handle response
                switch choice
                    case 'Create a new output file'
                        fileName = newSelectedOutputFile_CB( obj.Tree , [] , [] , obj.Tree.OutputNode );
                        if ~isempty(fileName)
                            save(fileName,'operCond');
                        end
                    case 'Open and existing output file'
                        fileName = insertSelectedOutputFile_CB( obj.Tree , [] , [] , obj.Tree.OutputNode );
                        if ~isempty(fileName)
                            fileStruct = load(fileName);
                            fnames = fieldnames(fileStruct);

                            choiceAppend = questdlg('Would you like to append to the existing data?', ...
                                'Saving...', ...
                                'Yes','No','Yes');
                            switch choiceAppend
                                case 'Yes'
                                    obj.AppendData = true;
                                case 'No'
                                    obj.AppendData = false;
                                otherwise
                                    % Do Nothing and return
                                    return;
                            end
                            if obj.AppendData
                                operCond = [fileStruct.(fnames{1}),operCond];  %#ok<NASGU>
                            end

                            save(fileName,'operCond');
                        end

                    case 'Do not save'
                        % Do nothing
                end

            elseif length(selOutputFile) == 1
                selOutputFile = selOutputFile{:};
                fileStruct = load(selOutputFile);
                fnames = fieldnames(fileStruct);
                choiceAppend = questdlg('Would you like to append to the existing data?', ...
                                'Saving...', ...
                                'Yes','No','Yes');
                switch choiceAppend
                    case 'Yes'
                        obj.AppendData = true;
                    case 'No'
                        obj.AppendData = false;
                    otherwise
                        % Do Nothing and return
                        return;
                end
                if obj.AppendData
                    operCond = [fileStruct.(fnames{1}),operCond];  %#ok<NASGU>
                end
                save(selOutputFile,'operCond'); 
            else
                error('OUTPUTFILE:TOOMANY','Too many output files selected.');  
            end       
        end % save
        
        function handleErrors( obj , exc )

            
               % msgString = getReport(exc);
                msgString = exc.message;
                switch exc.identifier
                    case 'Parameter:Evaluate'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error')); 
                    case 'License:KeyMissing'
                        saveWorkspace( obj , [] ,[] );
                        closeFigure_CB( obj , [] , [] );      
                    case 'FCDAT:notFoundInPath'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([exc.message,' was not found.'],'error'));
                    case 'FCOND:EMPTY'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Flight Conditions must be specified.','error'));
                    case 'SETNAME:MISSING'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Set Name must be specified.','error'));
                    case 'Req:ScriptError'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Error in Requierments scripts.','error'));
                    otherwise        
                        switch exc.message
                            case 'No Trim ID is selected.'
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Trim not selected','warn'));
                            otherwise
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(msgString,'error')); 

                                Utilities.multiWaitbar('Close All');
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('*****The run terminated unexpectedly.*****','error')); 
%                                 throwAsCaller(exc);
                                debug = true;
                                if debug
                                    assignin('base','exc',exc);
                                    evalin('base','rethrow(exc);');
                                end
                        end
                end   
                Utilities.multiWaitbar('Close All');
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('*****The run terminated unexpectedly.*****','error')); 
                            
        end % handleErrors
        
        function cleanUp( obj )

        end % cleanUp
        

        
    end
    
    %% Methods - Protected - Update
    methods (Access = protected) 
        
        function update( obj, ~ , ~ )

             
        end % update         
        
        function updateTask( obj , ~ , eventData , ~ )

        end % updateTask

        function analysisTaskUpdatedMassProp( obj , ~ , eventdata )
            index = eventdata.Object.Index;
            massProps = eventdata.Object.MassProperty;
            massPropertyAddedToPanel( obj , index, massProps);
        end % analysisTaskUpdatedMassProp
        
        function massPropertyAddedToPanel( obj , index, massProps, batchRunNumber)
            if nargin ~= 4
                batchRunNumber = 1;
            end
             if length(obj.TaskCollectionObjBatch) >= index && ~isempty(obj.TaskCollectionObjBatch(index))
                updateMassProps( obj.TaskCollectionObjBatch(index).TrimTaskCollObj(batchRunNumber) , massProps );
            end
        end % massPropertyAddedToPanel

        function useExistingTrim( obj , ~ , eventData )
            obj.UseExistingTrimState = eventData.Value;
        end % useExistingTrim

    end

    %% Methods - Protected - ReSize
    methods %(Access = protected) 
        
        function reSize( obj , ~ , ~ )
            
% %             % Call super class method
% %             reSize@UserInterface.Level1Container(obj,[],[]); 
            % get figure position
            position = getpixelposition(obj.Parent);
       
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , position(4) - 93 , 860 , 93 ]);
            
            set(obj.MainPanel,'Units','Pixels',...
                'Position',[1 , 100 , position(3) , position(4) - 194 ]);
                        
            set(obj.LogPanel,'Units','Pixels',...
                'Position',[ 1 , 1 , position(3) , 100]);
            
            set(obj.RibbonCardPanel, 'Units','Pixels',...
                'Position',[ 860 , position(4) - 93 , position(3) - 860 , 92 ]);
            
            
            %get figure position   
            
            mpPos = getpixelposition(obj.MainPanel);
            obj.ProjectLabelCont.Units = 'Pixels';
            obj.ProjectLabelCont.Position = [ 2 , mpPos(4) - 16 , 198 , 16 ];  
            
            set(obj.BrowserPanel,'Units','Pixels',...
                'Position',[ 1 , 1 , 200 , mpPos(4) - 16 ]);%[ 1 , 490 , 352 , mpPos(4) - 490 ]);
                %'Position',[ 1 , 1 , 175 , mpPos(4) ]);
            
            set(obj.LargePanel,'Units','Pixels',...
                'Position',[ 201 , 1 , mpPos(3) - 201 , mpPos(4) ]); % 'Position',[ 553 , 1 , mpPos(3) - 553 , mpPos(4) ]);
            set(obj.AnalysisTabGroub,'Units','Pixels',...
                'Position',[ 1 , 1 , mpPos(3) , mpPos(4) - 5 ]);
            
            mpPos = getpixelposition(obj.LargePanel);
            set(obj.TaskObjContainer,'Units','Pixels',...
                'Position',[ 1 , 1 , 352 , mpPos(4) - 35 ]);
            set(obj.OperCondContainer,'Units','Pixels',...
                'Position',[ 352 , 1 , mpPos(3) - 352 , mpPos(4) - 30 ]);
        end % reSize
        
        function smallPanelResize( obj , ~ , ~ )
            parentPos = getpixelposition(obj.TaskObjContainer(1));

            
            set(obj.SettingsLabelCont,'Units','Pixels','Position',[ 1 , parentPos(4) - 16 , parentPos(3) , 16 ]); 
            set(obj.TaskPanel,'Units','Pixels','Position',[ 1 , 1 , parentPos(3) , parentPos(4)-16]);%[ 1 , 50 , parentPos(3) , parentPos(4)-50 ]);      
            
        end % smallPanelResize 
        
    end
    
    %% Methods - Private
    methods (Access = private)        
        
        function readModel( obj , mdl , constantsFile , nodeName )
            try
                if nargin == 4
                    Utilities.setWaitPtr(obj.Figure);
                    [ ~ , ~ , ext ] = fileparts(constantsFile);
                    if strcmp( ext , '.mat' )
                        command = sprintf('load(''%s'')', constantsFile);
                        evalin('base', command);
                    elseif strcmp( ext , '.m' )
                        command = sprintf('run(''%s'')', constantsFile);
                        evalin('base', command);
                    else
                        error('Constants file must have a ".m" of ".mat" extension');
                    end  
                end
                
                % Update the constants table
                updateConstantTableData( obj );

                if ~isempty(obj.TaskCollectionObj)
                load_system(mdl);
                inH  = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Inport' );
                [ ~ , inNames ] = cellfun( @fileparts , inH , 'UniformOutput' , false );

                outH = find_system( mdl, 'SearchDepth' , 1 , 'BlockType', 'Outport' );
                [ ~ , outNames ] = cellfun( @fileparts , outH , 'UniformOutput' , false );

                [~,~,x0]=eval([mdl '([],[],[],0)']);
                [ ~ , stateNames ] = cellfun( @fileparts , x0 , 'UniformOutput' , false );
                modelUpdated( obj.TaskCollectionObj , inNames , outNames , stateNames );
                end
                Utilities.releaseWaitPtr(obj.Figure);
            catch Mexc
                
                switch Mexc.identifier
                    case 'MATLAB:run:FileNotFound'
                        choice = Utilities.questdlgNonModal(['The file ''',constantsFile,''' does NOT exist on the Matlab path. Please add the path and press continue.'], ...
                            'Add Path', ...
                            'Continue','Cancel','Continue');
                        % Handle response
                        switch choice
                            case 'Continue'
                                readModel( obj , mdl , constantsFile );
                                Utilities.releaseWaitPtr(obj.Figure);
                            otherwise
                                removeConstantsFile_CB( obj.Tree , [] , [] , nodeName );
                                Utilities.releaseWaitPtr(obj.Figure);
                                return;
                        end
                    case 'Simulink:Commands:OpenSystemUnknownSystem'
                        choice = Utilities.questdlgNonModal(['The model ''',nodeName,''' does NOT exist on the Matlab path. Please add the path and press continue.'], ...
                            'Add Path', ...
                            'Continue','Cancel','Continue');
                        % Handle response
                        switch choice
                            case 'Continue'
                                readModel( obj , mdl , constantsFile );
                                Utilities.releaseWaitPtr(obj.Figure);
                            otherwise
                                removeConstantsFile_CB( obj.Tree , [] , [] , nodeName );
                                Utilities.releaseWaitPtr(obj.Figure);
                                return;
                        end
                    otherwise
                        Utilities.releaseWaitPtr(obj.Figure);
                        rethrow(Mexc);
                end
            end
            
        end % readModel

        function simTitle = getSimulationPageTitle(obj, simViewer, analysisIndex)
            simTitle = '';
            names = {};
            if nargin >= 2 && ~isempty(simViewer)
                try
                    if isa(simViewer, 'handle') && isvalid(simViewer) && isprop(simViewer,'RunLabel')
                        runLabels = simViewer.RunLabel;
                        names = parseRunLabels(runLabels);
                    end
                catch
                    names = {};
                end
            end

            if ~isempty(names)
                names = uniqueStable(names);
                simTitle = joinWithComma(names);
            elseif nargin >= 3 && ~isempty(obj.AnalysisObjects) && ...
                    analysisIndex >= 1 && analysisIndex <= numel(obj.AnalysisObjects)
                try
                    analysisObj = obj.AnalysisObjects(analysisIndex);
                    if ~isempty(analysisObj)
                        simReqs = analysisObj.SimulationRequirment;
                        if ~isempty(simReqs)
                            titles = arrayfun(@extractTitle, simReqs, 'UniformOutput', false);
                            titles = titles(~cellfun(@isempty, titles));
                            titles = uniqueStable(titles);
                            if ~isempty(titles)
                                simTitle = joinWithComma(titles);
                            end
                        end
                    end
                catch
                    % Ignore errors when gathering titles
                end
            end

            if isempty(simTitle)
                simTitle = 'Simulation';
            end

            if iscell(simTitle)
                simTitle = joinWithComma(simTitle);
            end

            if ~ischar(simTitle)
                try
                    simTitle = char(simTitle);
                catch
                    simTitle = 'Simulation';
                end
            end

            function namesOut = parseRunLabels(runLabels)
                namesOut = {};
                if isempty(runLabels)
                    return;
                end
                if ischar(runLabels)
                    runLabels = {runLabels};
                elseif ~iscell(runLabels)
                    return;
                end
                cleaned = cellfun(@cleanRunLabel, runLabels, 'UniformOutput', false);
                cleaned = cleaned(~cellfun(@isempty, cleaned));
                if isempty(cleaned)
                    return;
                end
                namesOut = cleaned;
            end

            function nameOut = cleanRunLabel(label)
                nameOut = '';
                if isempty(label)
                    return;
                end
                if iscell(label)
                    label = label{1};
                end
                if ~ischar(label)
                    return;
                end
                try
                    label = regexprep(label, '<[^>]*>', '');
                catch
                    % Ignore regex errors
                end
                label = strtrim(label);
                if isempty(label)
                    return;
                end
                try
                    label = regexprep(label, '\s+', ' ');
                catch
                    % Ignore regex errors
                end
                pipeIdx = find(label == '|', 1, 'first');
                if ~isempty(pipeIdx)
                    label = strtrim(label(1:pipeIdx-1));
                end
                if isempty(label)
                    return;
                end
                nameOut = label;
            end

            function titleText = extractTitle(simReq)
                titleText = '';
                if isempty(simReq)
                    return;
                end
                try
                    titleText = simReq.Title;
                catch
                    titleText = '';
                    return;
                end
                if isempty(titleText)
                    return;
                end
                if iscell(titleText)
                    titleText = titleText{1};
                end
                if ~ischar(titleText)
                    try
                        titleText = char(titleText);
                    catch
                        titleText = '';
                        return;
                    end
                end
                titleText = strtrim(titleText);
            end

            function listOut = uniqueStable(listIn)
                listOut = {};
                for idx = 1:numel(listIn)
                    value = listIn{idx};
                    if isempty(value)
                        continue;
                    end
                    if ~any(strcmp(listOut, value))
                        listOut{end+1} = value; %#ok<AGROW>
                    end
                end
            end

            function joined = joinWithComma(listIn)
                if isempty(listIn)
                    joined = '';
                    return;
                end
                joined = listIn{1};
                for idx = 2:numel(listIn)
                    joined = [joined ', ' listIn{idx}]; %#ok<AGROW>
                end
            end
        end % getSimulationPageTitle

    end

    %% Methods - Figure Callbacks
    methods
        
        function closeFigure_CB( obj , hobj , eventdata )
            

            closeFigure_CB@UserInterface.Level1Container( obj , hobj , eventdata);
            
            try             
                status = logout(obj.Granola);
                if ~status
                    throw(obj.Granola.LastError); % Terminate Program
                end
            end 
            % Remove the path
            if ~isempty(obj.ProjectMatlabPath)
                rmpath(obj.ProjectMatlabPath);
            end
            
            mdl = obj.Tree.getSelectedSimModel;
            openModels = find_system('SearchDepth', 0);
            if ~isempty(intersect(mdl,openModels))
                if ~isempty(mdl)
                    refMdls = find_mdlrefs(mdl);
                    for i = 1:length(refMdls)
                        bdclose(refMdls{i});
                    end
                end
            end
            deleteUserData(obj.Tree);
            delete(obj.Figure);
            deleteObjects( obj );
%             notify(obj,'ExitApplication');
        end % closeFigure_CB
       
        
    end
      
    %% Method - Static
    methods ( Static )
        
        function disable( container )
            children = get(container,'Children');   
            for i = 1:length(children)
                
               set(children(i),'Enable','Off'); 
            end        
        end % disable 
        
        function enable( container )
            children = get(container,'Children');   
            for i = 1:length(children)
                
               set(children(i),'Enable','on'); 
            end  
        end % enable  

%         function obj = loadobj(s)
%             obj = s;
%             
%             figH = FLIGHTdynamics();
%         end % loadobj
        
    end
        
    %% Method - Delete
    methods
        function delete(obj)

            % Java Components 
            obj.ProjectLabelComp = [];   
            obj.SettingsLabelComp = [];




            % Javawrappers
            % Check if container is already being deleted
            if ~isempty(obj.ProjectLabelCont) && ishandle(obj.ProjectLabelCont) && strcmp(get(obj.ProjectLabelCont, 'BeingDeleted'), 'off')
                delete(obj.ProjectLabelCont)
            end
            for i = 1:length(obj.SettingsLabelCont)
                if ~isempty(obj.SettingsLabelCont(i)) && ishandle(obj.SettingsLabelCont(i)) && strcmp(get(obj.SettingsLabelCont(i), 'BeingDeleted'), 'off')
                    delete(handle(obj.SettingsLabelCont(i)));
                end
            end



            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.RibbonObj);
            end
            try %#ok<*TRYNC>
                delete(obj.TaskCollectionObj);
            end
            try %#ok<*TRYNC>
                delete(obj.TaskCollectionObjBatch);
            end
            try %#ok<*TRYNC>
                delete(obj.OperCondCollObj);
            end
            try %#ok<*TRYNC>
                delete(obj.Tree);
            end
            try %#ok<*TRYNC>
                delete(obj.AxisColl);
            end
            try %#ok<*TRYNC>
                delete(obj.SimAxisColl);
            end
            try %#ok<*TRYNC>
                delete(obj.PostSimAxisColl);
            end
            try %#ok<*TRYNC>
                delete(obj.ConstantsParamColl);
            end
            try %#ok<*TRYNC>
                delete(obj.AnalysisObjects);
            end
            try %#ok<*TRYNC>
                delete(obj.TaskCollectionCardPanel);
            end
            try %#ok<*TRYNC>
                delete(obj.ConstantTableData);
            end
            

            delete@UserInterface.Level1Container(obj);
             
%         obj.RibbonObj
%         obj.TaskCollectionObj
%         obj.TaskCollectionObjBatch
%         obj.OperCondCollObj
%         obj.Tree
%         obj.AxisColl
%         obj.SimAxisColl
%         obj.PostSimAxisColl
%         obj.ConstantsParamColl
%         obj.AutoSave
%         obj.AutoSaveFileName
%         obj.AnalysisObjects
%         obj.TaskCollectionCardPanel
%         obj.BrowserPanel
%         obj.SmallPanel
%         obj.LargePanel
%         obj.TaskPanel 
%         obj.TabPanel
%         obj.TabManual  
%         obj.TabConstants 
%  
%         obj.ConstantTable  
%         obj.AnalysisTabGroub  
%         obj.AnalysisTabArray
%         obj.TaskObjContainer
%         obj.OperCondContainer
%         obj.SimulationOutputData
%         obj.OperatingConditionForSimData
%         obj.SelectedTab




        end % delete
    end 
    
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the RibbonObj object
%             cpObj.RibbonObj = copy(obj.RibbonObj);
            % Make a deep copy of the TaskCollectionObj object
            cpObj.TaskCollectionObj = copy(obj.TaskCollectionObj);
            % Make a deep copy of the TaskCollectionObjBatch object
            cpObj.TaskCollectionObjBatch = copy(obj.TaskCollectionObjBatch);
            % Make a deep copy of the OperCondCollObj object
            cpObj.OperCondCollObj = copy(obj.OperCondCollObj);
            % Make a deep copy of the Tree object
            cpObj.Tree = copy(obj.Tree);
            % Make a deep copy of the ConstantsParamColl object
            cpObj.ConstantsParamColl = copy(obj.ConstantsParamColl);
            
            
        end
    end
    
end

function uniqueMdlNames = getAllModelsInAnalysisObj( analysisObj )

    mdlNames = {};

    for i = 1:length(analysisObj.TrimTask)
        mdlNames{end+1} = analysisObj.TrimTask(i).SimulinkModelName; %#ok<AGROW>
    end
    for i = 1:length(analysisObj.LinearModelDef)
        mdlNames{end+1} = analysisObj.LinearModelDef(i).SimulinkModelName; %#ok<AGROW>
    end
    for i = 1:length(analysisObj.Requirement)
        mdlNames{end+1} = analysisObj.Requirement(i).MdlName; %#ok<AGROW>
    end
    for i = 1:length(analysisObj.SimulationRequirment)
        mdlNames{end+1} = analysisObj.SimulationRequirment(i).MdlName; %#ok<AGROW>
    end

    mdlNames = mdlNames(~cellfun('isempty',mdlNames));

    % Find unique mdlNames 
    if ~isempty(mdlNames)
        uniqueMdlNames = unique(mdlNames);
        uniqueMdlNames = uniqueMdlNames(~cellfun('isempty',uniqueMdlNames));
    else
        uniqueMdlNames = {};
    end 

end % getAllModelsInAnalysisObj

function parameters = getAllDefaultModelParameters( uniqueMdlNames )

    parameters = UserInterface.ControlDesign.Parameter.empty;

    if isempty(uniqueMdlNames)
        return;
    end

    parameters = getParametersFromModel( uniqueMdlNames );

end % getAllDefaultModelParameters
        
function parameters = getParametersFromModel( mdlNames )
    parameters = UserInterface.ControlDesign.Parameter.empty;
    uniqueMdlNames = unique(mdlNames);
    warning('off','Simulink:Data:WksGettingDataSource')
    for i = 1:length(uniqueMdlNames)
        if ~isempty(uniqueMdlNames{i})
            load_system(uniqueMdlNames{i});
            wrksp = get_param(uniqueMdlNames{i},'modelworkspace');
            % First Clear the workspace
            wrksp.clear;
            if ~strcmp(wrksp.DataSource,'Model File')
                wrksp.reload;
            end
            workspaceData = wrksp.data;
            for k = 1:length(workspaceData)
                parameters(end + 1)  = UserInterface.ControlDesign.Parameter('Name',workspaceData(k).Name,'String',workspaceData(k).Value); %#ok<AGROW>
            end
        end
    end
    
    % Get Unique Parameters
    [~,ia] = unique({parameters.Name});
    
    parameters = parameters(ia);
end % getParametersFromModel

function resetSaveFormat( saveFormat )
    for i = 1:length(saveFormat)
        % Reset Array Format
        try
            set_param(saveFormat(i).ModelName,'SaveFormat',saveFormat(i).Format);
        catch
            try
                % Get the Configuration Set
                cref = getActiveConfigSet(saveFormat(i).ModelName);
                if isa(cref,'Simulink.ConfigSetRef')
                    cset = cref.getRefConfigSet;
                else
                    cset = cref;
                end
                set_param(cset,'SaveFormat',saveFormat(i).Format);
            catch
                error('SIMULINK:GETSTATENAMESDATASAVEFORMAT','Unable to set the data save format to ''array''. This is neccessary to use the command ''getInitialState''.');  
            end
        end
    end
end % resetSaveFormat

function saveFormat = getSaveFormat(taskObj)
    uniqueMdlNames = unique({taskObj.Simulation});
    saveFormat = struct('ModelName',uniqueMdlNames,'Format',[]);
    for i = 1:length(uniqueMdlNames)
        % Load System
        try
            load_system(uniqueMdlNames{i});
        catch
            error('FLIGHTDynamics:SimulationNotFoundInPath',['The model "',uniqueMdlNames{i},'" is not on the path or was created in a newer version of Matlab']);
        end
        
        try
            saveFormat(i).Format = get_param(uniqueMdlNames{i},'SaveFormat');
        catch
            try
                % Get the Configuration Set
                cref = getActiveConfigSet(uniqueMdlNames{i});
                if isa(cref,'Simulink.ConfigSetRef')
                    cset = cref.getRefConfigSet;
                else
                    cset = cref;
                end
                saveFormat(i).Format = get_param(cset,'SaveFormat');
            catch
                error('SIMULINK:GETSTATENAMESDATASAVEFORMAT','Unable to set the data save format to ''array''. This is neccessary to use the command ''getInitialState''.');  
            end
        end
    end
end % getSaveFormat

function FLIGHtOutpUt = testFunc( FLIGHtInpUt)
    FLIGHtOutpUt = lacm.Condition.empty;
    eval(FLIGHtInpUt);
    vars = whos;
    for FliGhtJJ = 1:length(vars)
        if ~any(strcmp(vars(FliGhtJJ).name,{'FLIGHtInpUt','FLIGHtOutpUt','FliGhtJJ'}))   
            if isnumeric(eval(vars(FliGhtJJ).name))
                FLIGHtOutpUt(end+1) = lacm.Condition(vars(FliGhtJJ).name,eval(vars(FliGhtJJ).name)); %#ok<AGROW>
            end
        end
    end
end % testFunc

function FLIGHtOutpUt = evalParams( FLIGHtInpUt)
    FLIGHtOutpUt = UserInterface.ControlDesign.Parameter.empty;
    eval(FLIGHtInpUt);
    vars = whos;
    for FliGhtJJ = 1:length(vars)
        if ~any(strcmp(vars(FliGhtJJ).name,{'FLIGHtInpUt','FLIGHtOutpUt','FliGhtJJ'}))   
            if isnumeric(eval(vars(FliGhtJJ).name))
                FLIGHtOutpUt(end+1) = UserInterface.ControlDesign.Parameter('Name',vars(FliGhtJJ).name,'String',eval(vars(FliGhtJJ).name));%#ok<AGROW> %lacm.Condition(vars(FliGhtJJ).name,eval(vars(FliGhtJJ).name)); %#ok<AGROW>
            end
        end
    end
end % evalParams
