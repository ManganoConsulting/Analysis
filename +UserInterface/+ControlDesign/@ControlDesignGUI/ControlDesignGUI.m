classdef ControlDesignGUI < UserInterface.Level1Container
    %% DEBUG OPTIONS
    properties
        Debug = false
    end
    
    %% Public properties - Graphics Handles
    properties (Transient = true)
        ToolRibbionTab
        ProjectPanel
        BrowserPanel
        SelectionPanel
        LargeCardPanel
        TabPanel
        StabilityTab
        FreqRespTab
        SimulationTab
        HQTab
        ASETab
        RTLocusTab   
        DesignParameterPanel
        SliderPanel
        DesignTabPanel
        NewJButton
        OpenJButton
        LoadJButton
        RunSelJButton
        SaveJButton
        ExportJButton
        PlotJButton
        JRibbonPanel
        JRPHComp
        JRPHCont
        StabAxisColl UserInterface.AxisPanelCollection
        FreqRespAxisColl UserInterface.AxisPanelCollection
        HQAxisColl UserInterface.AxisPanelCollection
        ASEAxisColl UserInterface.AxisPanelCollection
        SimViewerColl% UserInterface.AxisPanelCollection
        RTLocusAxisColl UserInterface.AxisPanelCollection
        ProjectLabelComp
        ProjectLabelCont
        ParameterLabelComp
        ParameterLabelCont
        ParamTabPanel
        SynTab
        ReqTab
        FilterTab
        
        Tree
        
        OperCondTabPanel
        OperCondTab
        BatchTab
        RibbonCardPanel
        SimViewerTabPanel
        SimViewerTab
        SimviewerRibbonCardPanel
        
%         SynthesisParameterListners
%         RequiermentParameterListners
%         FilterParameterListners
    end % Public properties
    
    %% Public properties - Data Storage
    properties

        TreeSavedData
        SelectedParameter UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter
        CurrSelToolRibbion  = 1
        ToolRibbionSelectedText = 'Main'   
        OperCondColl UserInterface.ControlDesign.OCCControlDesign
        SynthesisParamColl UserInterface.ControlDesign.ParameterCollection
        ReqParamColl UserInterface.ControlDesign.ParameterCollection
        GainColl UserInterface.ControlDesign.GainCollection
%         ScattteredSynthesisParamColl UserInterface.ControlDesign.ParameterCollection
%         ScattteredReqParamColl UserInterface.ControlDesign.ParameterCollection
%         ScattteredGainColl ScatteredGain.GainCollection
        FilterParamColl UserInterface.ControlDesign.FilterCollection
        GainSchPanel UserInterface.ControlDesign.GainSchGUI
        GainFilterPanel UserInterface.ControlDesign.GainFilterGUI
        ScatteredGainColl ScatteredGain.GainCollection = ScatteredGain.GainCollection.empty
        CurrentScatteredGainColl ScatteredGain.GainCollection = ScatteredGain.GainCollection.empty
        SelectedScatteredGainFileObj ScatteredGain.GainFile  
        NumberOfPlotPerPageStab = 4
        NumberOfPlotPerPageFR = 4
        NumberOfPlotPerPageHQ = 4
        NumberOfPlotPerPageASE = 4
        NumberOfPlotPerPageRTL = 1
        ShowOnlyScalar = true
        SelectedParamTab = 1
        
        BatchRunCollection
        
        BatchSynthesisParamColl UserInterface.ControlDesign.ParameterCollection
        BatchReqParamColl UserInterface.ControlDesign.ParameterCollection
        BatchGainColl UserInterface.ControlDesign.GainCollection
        BatchFilterParamColl UserInterface.ControlDesign.FilterCollection
        
        SimViewerSettings = SimViewer.Main.emptyPlotSettings()
        SimViewerProject = SimViewer.Main.emptyProjectSettings()
    end % Public properties
    
    %% Public properties - Observable Data Storage
    properties (SetObservable)

    end
    
    %% Public properties - Gain Objects
    properties
        ScatteredGainFileObjs
        ScatteredGainFileObjSelectedInTree
        ScatteredGainFileObjSelectedInGainDesign
        
        ScheduledGainFileObjs
        ScheduledGainFileObjSelectedInTree
        ScheduledGainFileObjSelectedInGainDesign
        
        ScattGainFileObjArray = ScatteredGain.GainFile.empty
        SchGainFileObjArray = ScheduledGain.SchGainCollection.empty
        
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Dependant Read-only properties
    properties ( Dependent = true, GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
       LoadingSavedWorkspace = false
       GainSource % 1=Synthesis,2=Schedule,3=model 
       BrowseStartDir = pwd;
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)

    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        ProjectType = 'Control'
        ManualTabName = 'Manual Run'
        BatchTabName = 'Batch Run'
        SingleReportFigureDelta = -50
    end % Constant properties  
    
    %% Events
    events
        LoadOperCond
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = ControlDesignGUI(figH,licH,ver,internalver)  
        
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

        end % ControlDesignGUI
    end % ControlDesignGUI

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
            createToolRibbion(obj, obj.CurrSelToolRibbion);
            
            positionMain = getpixelposition(obj.MainPanel);
            
            parentPosition = getpixelposition(obj.Parent);
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , positionMain(4) - 93 , 860, 93 ]);
            
            obj.RibbonCardPanel = UserInterface.CardPanel(6,'Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ 860 , parentPosition(4) - 93 , parentPosition(3) - 860 , 93 ]);
            obj.SimviewerRibbonCardPanel = UserInterface.CardPanel(0,'Parent',obj.RibbonCardPanel.Panel(3),...
                'Units','Normal',...
                'Position',[ 0, 0, 1, 1 ]);
            
%                 uicontrol(...
%                     'Parent',obj.RibbonCardPanel.Panel(1),...
%                     'Style','edit',...
%                     'String', 'Panel 1',...
%                     'BackgroundColor', [1 1 1],...
%                     'Enable','on',...
%                     'Units','normal',...
%                     'Position', [0,0,1,1]);
%                 uicontrol(...
%                     'Parent',obj.RibbonCardPanel.Panel(3),...
%                     'Style','edit',...
%                     'String', 'Panel 2',...
%                     'BackgroundColor', [1 0 1],...
%                     'Enable','on',...
%                     'Units','normal',...
%                     'Position', [0,0,1,1]);
%             
            
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Project</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ProjectLabelComp,obj.ProjectLabelCont] = javacomponent(jLabelview,[ 1 , positionMain(4) - 18 , 330 , 16 ], obj.MainPanel );

            
            obj.BrowserPanel = uipanel('Parent',obj.MainPanel,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 1 , (positionMain(4))/2  , 330 , ((positionMain(4))/2) - 18]);   
            
            
            obj.SelectionPanel = UserInterface.CardPanel(6,'Parent',obj.MainPanel,...
                'BackgroundColor', [ 1 , 1 , 1 ],...
                'Units','Pixels',...
                'Position',[ 1 , 1 , 330 , (positionMain(4))/2 ]);

            obj.LargeCardPanel = UserInterface.CardPanel(6,'Parent',obj.MainPanel,...
                'BackgroundColor', [ 1 , 1 , 1 ],...
                'Units','Pixels',...
                'Position',[ 332 , 1 , positionMain(3) - 332 , positionMain(4) ]);      
 
               
            % Create Objects
            if obj.LoadingSavedWorkspace
                %----------------------------------------------------------
                %          Control Tree
                %---------------------------------------------------------- 
                obj.Tree = UserInterface.ControlDesign.ControlTree('Parent',obj.BrowserPanel,'Restore',obj.TreeSavedData);
%                 obj.Tree.restoreTree(obj.BrowserPanel);
                addlistener(obj.Tree,'OperCondAdded',@obj.operCondAdded);
                addlistener(obj.Tree,'OperCondRemoved',@obj.operCondRemoved);
                addlistener(obj.Tree,'ReqObjAdded',@obj.reqObjAdded);
                addlistener(obj.Tree,'ReqObjRemoved',@obj.reqObjRemoved);
                addlistener(obj.Tree,'GainSource','PostSet',@obj.gainSourceChanged);
                addlistener(obj.Tree,'SelectedScatteredGainFileObj','PostSet',@obj.scattGainSaveFileChanged);
                addlistener(obj.Tree,'ScatteredGainFileAdded',@obj.setScattGainFileComboBox);
                addlistener(obj.Tree,'ScatteredGainFileExported',@obj.scatteredGainFileExported);
                addlistener(obj.Tree,'ScatteredGainFileCleared',@obj.scatteredGainFileCleared);
                addlistener(obj.Tree,'ScheduleGainCollectionAdded',@obj.updateSchGainCollGainSchGUI);
%                 addlistener(obj.Tree,'LoadedSchGainObj','PostSet',@obj.setSchGainFileComboBox);
                addlistener(obj.Tree,'AddAxisHandle2Q',@obj.addAxisHandle2Q_CB);
                addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.Tree,'ReqObjUpdated',@obj.autoSaveFile);
                addlistener(obj.Tree,'SetPointer',@obj.setPointer);
                
                obj.Tree.SelectedScatteredGainFileObj = obj.SelectedScatteredGainFileObj;
                
                
                %----------------------------------------------------------
                %          Oper/Batch Panel
                %----------------------------------------------------------    
                obj.OperCondTabPanel = uitabgroup('Parent',obj.SelectionPanel.Panel(1),'TabLocation','Bottom','SelectionChangedFcn',@obj.manualBatchTabCallback); 
                
                obj.OperCondTab  = uitab('Parent',obj.OperCondTabPanel);
                obj.OperCondTab.Title = obj.ManualTabName;
                
                obj.BatchTab  = uitab('Parent',obj.OperCondTabPanel);
                obj.BatchTab.Title = obj.BatchTabName;
                %----------------------------------------------------------
                %          Operating Condition Collection
                %----------------------------------------------------------
                obj.OperCondColl.selectionView(obj.OperCondTab);
                addlistener(obj.OperCondColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.OperCondColl,'MousePressedInTable',@obj.operCondTablePopUp);
%                 addlistener(obj.OperCondColl,'OperCondTableUpdated',@obj.operCondTableUpdated);
                %----------------------------------------------------------
                %          Batch Collection
                %----------------------------------------------------------
                if isempty(obj.BatchRunCollection)
                    obj.BatchRunCollection = UserInterface.ControlDesign.RunObjectCollection('Parent',obj.BatchTab);  
                    addlistener(obj.BatchRunCollection,'NewBatch',@obj.add2Batch);
                    addlistener(obj.BatchRunCollection,'RemoveBatch',@obj.removeBatch);
                    addlistener(obj.BatchRunCollection,'UpdateBatchView',@obj.updateBatchView);
                    addlistener(obj.BatchRunCollection,'ClearPlots',@obj.resetAllPlots);
                else
                    obj.BatchRunCollection.selectionView(obj.BatchTab);
                    addlistener(obj.BatchRunCollection,'NewBatch',@obj.add2Batch);
                    addlistener(obj.BatchRunCollection,'RemoveBatch',@obj.removeBatch);
                    addlistener(obj.BatchRunCollection,'UpdateBatchView',@obj.updateBatchView);
                    addlistener(obj.BatchRunCollection,'ClearPlots',@obj.resetAllPlots);
                end
                addlistener(obj.BatchRunCollection,'ShowLogMessage',@obj.showLogMessage_CB);
                
                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                set(obj.LargeCardPanel.Panel(1),'resizeFcn',@obj.reSizeDesignPanel);
                obj.DesignParameterPanel = uicontainer('Parent',obj.LargeCardPanel.Panel(1));
                    pos = getpixelposition(obj.DesignParameterPanel);
                    labelStr = '<html><font color="white" face="Courier New">&nbsp;Parameters</html>';
                    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
                    jLabelview.setOpaque(true);
                    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
                    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
                    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
                    [obj.ParameterLabelComp,obj.ParameterLabelCont] = javacomponent(jLabelview,[ 1 , pos(4) - 16 , pos(3) , 16 ], obj.DesignParameterPanel );
                        obj.ParamTabPanel = uitabgroup('Parent',obj.DesignParameterPanel,'SelectionChangedFcn',@obj.updateSelectParamTab); 
                            obj.SynTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.SynTab.Title = 'Synthesis';

                            obj.ReqTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.ReqTab.Title = 'Requirement';
                            
                            obj.FilterTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.FilterTab.Title = 'Filters';
                    
                    
                %----------------------------------------------------------
                %          Synthesis - Requirements - Filter Parameters
                %----------------------------------------------------------
                createParameterTabs(obj);
                
                addlistener(obj.SynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.SynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
                addlistener(obj.SynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);                  
                addlistener(obj.SynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
            
                addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
                addlistener(obj.ReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
                addlistener(obj.ReqParamColl, 'ReInitButtonPressed',@obj.reinitParams); 
                
                addlistener(obj.FilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                
                %----------------------------------------------------------
                %          Gain
                %----------------------------------------------------------
                obj.GainColl.createView(obj.DesignParameterPanel);
                addlistener(obj.GainColl,'ShowLogMessage',@obj.showLogMessage_CB); 
                addlistener(obj.GainColl,'EnlargeGainCollection',@obj.showExpandedGains); 
                
                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                createDesignPanel(obj);
                                
                % Create SimViewer
                createSimViewers( obj , [] , []);
                
                %----------------------------------------------------------
                %          Gain Filter Panel
                %----------------------------------------------------------
                obj.GainFilterPanel.createView(obj.SelectionPanel.Panel(4));
                addlistener(obj.GainFilterPanel,'ShowLogMessage',@obj.showLogMessage_CB);
                %----------------------------------------------------------
                %          Gain Schedule Panel
                %----------------------------------------------------------
                obj.GainSchPanel.createView(obj.LargeCardPanel.Panel(4));
                schGainNameSel_CB( obj.GainSchPanel , obj.GainSchPanel.HCompSchGainName , [] );
                addListenerFilterChange( obj.GainSchPanel , obj.GainFilterPanel );
%                 addlistener(obj.GainSchPanel,'GainScheduleCollAdded',@obj.gainScheduleCollAdded ); 
%                 addlistener(obj.GainSchPanel,'GainScheduleCollRemoved',@obj.gainScheduleCollRemoved ); 
%                 addlistener(obj.GainSchPanel,'GainSelected'       ,@obj.selGainChanged ); 
%                 addlistener(obj.GainSchPanel,'GainAdded2SelectedCollection',@obj.gainAdded2Coll ); 
                addlistener(obj.GainSchPanel,'SchGainFileSelected'    ,@obj.schGainFileSelected );
                addlistener(obj.GainSchPanel,'ScatteredGainFileSelected',@obj.scatteredGainFileSelected );
                addlistener(obj.GainSchPanel,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.GainSchPanel,'AutoSaveFile',@obj.autoSaveFile);
    
                obj.LoadingSavedWorkspace = false;

            else
                %----------------------------------------------------------
                %          Control Tree
                %----------------------------------------------------------  
                obj.Tree = UserInterface.ControlDesign.ControlTree('Parent',obj.BrowserPanel);
                %set(obj.BrowserPanel,'Visible','off');
                addlistener(obj.Tree,'OperCondAdded',@obj.operCondAdded);
                addlistener(obj.Tree,'OperCondRemoved',@obj.operCondRemoved);
                addlistener(obj.Tree,'ReqObjUpdated',@obj.autoSaveFile);
                addlistener(obj.Tree,'ReqObjAdded',@obj.reqObjAdded);
                addlistener(obj.Tree,'ReqObjRemoved',@obj.reqObjRemoved);
                addlistener(obj.Tree,'GainSource','PostSet',@obj.gainSourceChanged);
                addlistener(obj.Tree,'SelectedScatteredGainFileObj','PostSet',@obj.scattGainSaveFileChanged);
                addlistener(obj.Tree,'ScatteredGainFileAdded',@obj.setScattGainFileComboBox);
                addlistener(obj.Tree,'ScatteredGainFileExported',@obj.scatteredGainFileExported);
                addlistener(obj.Tree,'ScatteredGainFileCleared',@obj.scatteredGainFileCleared);
                addlistener(obj.Tree,'ScheduleGainCollectionAdded',@obj.updateSchGainCollGainSchGUI);
                %addlistener(obj.Tree,'LoadedSchGainObj','PostSet',@obj.setSchGainFileComboBox);
                addlistener(obj.Tree,'AddAxisHandle2Q',@obj.addAxisHandle2Q_CB);
                addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.Tree,'SetPointer',@obj.setPointer);
                
                %----------------------------------------------------------
                %          Oper/Batch
                %----------------------------------------------------------    
                obj.OperCondTabPanel = uitabgroup('Parent',obj.SelectionPanel.Panel(1),'TabLocation','Bottom','SelectionChangedFcn',@obj.manualBatchTabCallback); 
                
                obj.OperCondTab  = uitab('Parent',obj.OperCondTabPanel);
                obj.OperCondTab.Title = obj.ManualTabName;
                
                obj.BatchTab  = uitab('Parent',obj.OperCondTabPanel);
                obj.BatchTab.Title = obj.BatchTabName;
                
                
                %----------------------------------------------------------
                %          Operating Condition Collection
                %----------------------------------------------------------
                obj.OperCondColl = UserInterface.ControlDesign.OCCControlDesign('Parent',obj.OperCondTab);  
                addlistener(obj.OperCondColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.OperCondColl,'MousePressedInTable',@obj.operCondTablePopUp);
%                 addlistener(obj.OperCondColl,'OperCondTableUpdated',@obj.operCondTableUpdated);
%                 obj.OperCondColl = UserInterface.ControlDesign.OCCControlDesign('Parent',obj.SelectionPanel.Panel(1));  
%                 addlistener(obj.OperCondColl,'ShowLogMessage',@obj.showLogMessage_CB);

                %----------------------------------------------------------
                %          Batch
                %----------------------------------------------------------
                obj.BatchRunCollection = UserInterface.ControlDesign.RunObjectCollection('Parent',obj.BatchTab);  
                addlistener(obj.BatchRunCollection,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.BatchRunCollection,'NewBatch',@obj.add2Batch);
                addlistener(obj.BatchRunCollection,'RemoveBatch',@obj.removeBatch);
                addlistener(obj.BatchRunCollection,'UpdateBatchView',@obj.updateBatchView);
                addlistener(obj.BatchRunCollection,'ClearPlots',@obj.resetAllPlots);

                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                set(obj.LargeCardPanel.Panel(1),'resizeFcn',@obj.reSizeDesignPanel);
                obj.DesignParameterPanel = uicontainer('Parent',obj.LargeCardPanel.Panel(1));
                    pos = getpixelposition(obj.DesignParameterPanel);
                    labelStr = '<html><font color="white" face="Courier New">&nbsp;Parameters</html>';
                    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
                    jLabelview.setOpaque(true);
                    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
                    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
                    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
                    [obj.ParameterLabelComp,obj.ParameterLabelCont] = javacomponent(jLabelview,[ 1 , pos(4) - 16 , pos(3) , 16 ], obj.DesignParameterPanel );
                        obj.ParamTabPanel = uitabgroup('Parent',obj.DesignParameterPanel,'SelectionChangedFcn',@obj.updateSelectParamTab);  
                            obj.SynTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.SynTab.Title = 'Synthesis';

                            obj.ReqTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.ReqTab.Title = 'Requirement';
                            
                            obj.FilterTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.FilterTab.Title = 'Filters';
                            
                %----------------------------------------------------------
                %          Synthesis - Requirements - Filter Parameters
                %----------------------------------------------------------
                
                obj.SynthesisParamColl = UserInterface.ControlDesign.ParameterCollection('Parent',obj.SynTab,'Title','Synthesis');
                obj.ReqParamColl       = UserInterface.ControlDesign.ParameterCollection('Parent',obj.ReqTab,'Title','Requirement');
                addlistener(obj.SynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.SynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
                addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
                addlistener(obj.ReqParamColl,      'EditButtonPressed',@obj.editPressInReq);
                addlistener(obj.SynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);
                addlistener(obj.ReqParamColl,      'ReInitButtonPressed',@obj.reinitParams);
                addlistener(obj.SynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
                %----------------------------------------------------------
                %          Filter Parameters
                %----------------------------------------------------------
                obj.FilterParamColl = UserInterface.ControlDesign.FilterCollection('Parent',obj.FilterTab,'Title','Filter');
                addlistener(obj.FilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                
                %----------------------------------------------------------
                %          Gain
                %----------------------------------------------------------
                
                obj.GainColl = UserInterface.ControlDesign.GainCollection('Parent',obj.DesignParameterPanel,'Title','Gain');
                addlistener(obj.GainColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.GainColl,'EnlargeGainCollection',@obj.showExpandedGains); 
                
                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                createDesignPanel(obj);
                %----------------------------------------------------------
                %          Gain Filter Panel
                %----------------------------------------------------------
                obj.GainFilterPanel = UserInterface.ControlDesign.GainFilterGUI('Parent',obj.SelectionPanel.Panel(4));
                addlistener(obj.GainFilterPanel,'ShowLogMessage',@obj.showLogMessage_CB);
                
                %----------------------------------------------------------
                %          Gain Schedule Panel
                %----------------------------------------------------------
                obj.GainSchPanel = UserInterface.ControlDesign.GainSchGUI('Parent',obj.LargeCardPanel.Panel(4));
                addListenerFilterChange( obj.GainSchPanel , obj.GainFilterPanel );
%                 addlistener(obj.GainSchPanel,'GainScheduleCollAdded',@obj.gainScheduleCollAdded ); 
%                 addlistener(obj.GainSchPanel,'GainScheduleCollRemoved',@obj.gainScheduleCollRemoved ); 
%                 addlistener(obj.GainSchPanel,'GainSelected'       ,@obj.selGainChanged );
%                 addlistener(obj.GainSchPanel,'GainAdded2SelectedCollection' ,@obj.gainAdded2Coll ); 
                addlistener(obj.GainSchPanel,'SchGainFileSelected'       ,@obj.schGainFileSelected );
                addlistener(obj.GainSchPanel,'ScatteredGainFileSelected',@obj.scatteredGainFileSelected );
                addlistener(obj.GainSchPanel,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.GainSchPanel,'AutoSaveFile',@obj.autoSaveFile);
  
            end            
            update(obj);
            
            % Set visability to on
            set(obj.LargeCardPanel,'Visible','on');
            obj.JRibbonPanel.setVisible(true);
            addlistener(obj,'LoadedProjectName','PostSet',@obj.setFileTitle);
            addlistener(obj,'ProjectSaved','PostSet',@obj.setFileTitle); 
            
            reSize( obj , [] , [] );
            drawnow();
            reSizeDesignPanel( obj , [] , [] );
            drawnow();
            % Force user to either create a project or open a project
            if obj.StartUpFlag
                % Launch StartUp Screen
%                 launchStartup( obj );
%                 notify(obj,'LaunchStartUp');
            end

%             manualBatchTabCallback(obj);

            
        end % createView        
        
        function createDesignPanel(obj)
            

            
            obj.DesignTabPanel = uicontainer('Parent',obj.LargeCardPanel.Panel(1));
                obj.TabPanel = uitabgroup('Parent',obj.DesignTabPanel,'SelectionChangedFcn',@obj.designPanelTabChanged); 

                
                defaultNumPlots = 64;

                obj.StabilityTab  = uitab('Parent',obj.TabPanel);
                obj.StabilityTab.Title = 'Stability';
                obj.StabAxisColl = UserInterface.AxisPanelCollection('Parent',obj.StabilityTab,'NumOfPages',defaultNumPlots/obj.NumberOfPlotPerPageStab,'NumOfAxisPerPage',obj.NumberOfPlotPerPageStab); 

                obj.FreqRespTab  = uitab('Parent',obj.TabPanel);
                obj.FreqRespTab.Title = 'Frequency Response';
                obj.FreqRespAxisColl = UserInterface.AxisPanelCollection('Parent',obj.FreqRespTab,'NumOfPages',defaultNumPlots/obj.NumberOfPlotPerPageFR,'NumOfAxisPerPage',obj.NumberOfPlotPerPageFR); 
                
                
                
                obj.SimulationTab  = uitab('Parent',obj.TabPanel);
                obj.SimulationTab.Title = 'Simulation';

                % Simulation Requirements Plots Tab
                obj.SimViewerTabPanel = uitabgroup('Parent',obj.SimulationTab,'SelectionChangedFcn',@obj.simViewerTabChanged);

                
                
                
                
                
                obj.HQTab  = uitab('Parent',obj.TabPanel);
                obj.HQTab.Title = 'Handling Qualities';
                obj.HQAxisColl = UserInterface.AxisPanelCollection('Parent',obj.HQTab,'NumOfPages',defaultNumPlots/obj.NumberOfPlotPerPageHQ,'NumOfAxisPerPage',obj.NumberOfPlotPerPageHQ); 

                obj.ASETab  = uitab('Parent',obj.TabPanel);
                obj.ASETab.Title = 'Aeroservoelasticity';
                obj.ASEAxisColl = UserInterface.AxisPanelCollection('Parent',obj.ASETab,'NumOfPages',defaultNumPlots/obj.NumberOfPlotPerPageASE,'NumOfAxisPerPage',obj.NumberOfPlotPerPageASE); 


                obj.RTLocusTab  = uitab('Parent',obj.TabPanel);
                obj.RTLocusTab.Title = 'Root Locus';
                obj.RTLocusAxisColl = UserInterface.AxisPanelCollection('Parent',obj.RTLocusTab,'NumOfPages',defaultNumPlots/obj.NumberOfPlotPerPageRTL,'NumOfAxisPerPage',obj.NumberOfPlotPerPageRTL); 
            set(obj.LargeCardPanel,'Visible','off');
            %obj.update;

        end % createDesignPanel
  
        function createParameterTabs(obj)

            obj.SynthesisParamColl.createView(obj.SynTab);
%                 addlistener(obj.SynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%                 addlistener(obj.SynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
%                 addlistener(obj.SynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);                  
%                 addlistener(obj.SynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
            
            obj.ReqParamColl.createView(obj.ReqTab);
%                 addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%                 addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
%                 addlistener(obj.ReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
%                 addlistener(obj.ReqParamColl, 'ReInitButtonPressed',@obj.reinitParams); 
                
            obj.FilterParamColl.createView(obj.FilterTab)
%                 addlistener(obj.FilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
        end % createParameterTabs
                  
%         function createParameterTabs(obj)
% 
%             obj.SynthesisParamColl.createView(obj.SynTab);
%                 obj.SynthesisParameterListners(1) = addlistener(obj.SynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%                 obj.SynthesisParameterListners(2) = addlistener(obj.SynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
%                 obj.SynthesisParameterListners(3) = addlistener(obj.SynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);                  
%                 obj.SynthesisParameterListners(4) = addlistener(obj.SynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
%             
%             obj.ReqParamColl.createView(obj.ReqTab);
%                 obj.RequiermentParameterListners(1) = addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%                 obj.RequiermentParameterListners(2) = addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
%                 obj.RequiermentParameterListners(3) = addlistener(obj.ReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
%                 obj.RequiermentParameterListners(4) = addlistener(obj.ReqParamColl, 'ReInitButtonPressed',@obj.reinitParams); 
%                 
%             obj.FilterParamColl.createView(obj.FilterTab)
%                 obj.FilterParameterListners(1) = addlistener(obj.FilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%         end % createParameterTabs
%                   
    end
    
    %% Methods - Batch
    methods
       
        function manualBatchTabCallback( obj , ~ , ~ )
            setWaitPtr(obj);
          
            if strcmp(obj.OperCondTabPanel.SelectedTab.Title,obj.ManualTabName)
                obj.Tree.Enable = true; 
                obj.GainColl.Visible = true;
                updateManualView( obj );
                
            else 
                obj.Tree.Enable = false; 
                obj.GainColl.Visible = false;
                if ~isempty(obj.BatchRunCollection.RunObjects)    
                    logArray = [obj.BatchRunCollection.RunObjects.IsActive];
                    if ~any(logArray) && ~isempty(logArray)
                        logArray(1) = true; % if no batch objects are active set the first one to active
                    end
                    eventdata.Value = obj.BatchRunCollection.RunObjects(logArray);
                    
                    %----------------------------------------------------------
                    %          Update Parameter Views
                    %----------------------------------------------------------
                    
                    updateBatchView( obj , [] , eventdata )
                    
                else
                    % Remove Graphics Children to save memory
                    try delete(obj.SynTab.Children);end
                    try delete(obj.ReqTab.Children);end
                    try delete(obj.FilterTab.Children);end
                    
                    resetAllPlots( obj , [] , [] );
                end
            end
            releaseWaitPtr(obj);      
        end % updateSelectBatchTab
        
        function updateBatchView( obj , ~ , eventdata )
            setWaitPtr(obj);

            %----------------------------------------------------------
            %          Update Parameter Views
            %---------------------------------------------------------
            % Remove Graphics Children to save memory
            try delete(obj.SynTab.Children);end
            try delete(obj.ReqTab.Children);end
            try delete(obj.FilterTab.Children);end
             
            if ~isempty(eventdata.Value)
                obj.BatchSynthesisParamColl = eventdata.Value.SynthesisParamColl;
                obj.BatchReqParamColl = eventdata.Value.ReqParamColl;
                obj.BatchFilterParamColl = eventdata.Value.FilterParamColl;


                obj.BatchSynthesisParamColl.createView(obj.SynTab);
                obj.BatchSynthesisParamColl.Enable = false;
                addlistener(obj.BatchSynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.BatchSynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
                addlistener(obj.BatchSynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);
%                 addlistener(obj.BatchSynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
                
                obj.BatchReqParamColl.createView(obj.ReqTab);
                obj.BatchReqParamColl.Enable = false;
                addlistener(obj.BatchReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.BatchReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
                addlistener(obj.BatchReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
%                 addlistener(obj.BatchReqParamColl, 'ReInitButtonPressed',@obj.reinitParams);
                
                obj.BatchFilterParamColl.createView(obj.FilterTab);
                obj.BatchFilterParamColl.Enable = false;
                addlistener(obj.BatchFilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
            end
            %----------------------------------------------------------
            %----------------------------------------------------------

            showBatchPlots( obj , [] , eventdata );
            
            releaseWaitPtr(obj);
        end % updateBatchView  
        
        function updateManualView( obj , ~ , eventdata )
            setWaitPtr(obj);
            
            % Disable Tree
            obj.GainColl.Enable = true;
            obj.Tree.TreeObj.Enable = true;

            
            
            % Remove Graphics Children to save memory
            try delete(obj.SynTab.Children);end
            try delete(obj.ReqTab.Children);end
            try delete(obj.FilterTab.Children);end
            
            % Create Manual Parameter Views
            createParameterTabs(obj);
                
            
            % Ensure Manual Parameter View is enabled
            obj.SynthesisParamColl.Enable = true;
            obj.ReqParamColl.Enable = true;
            obj.FilterParamColl.Enable = true;

            % Make Visible normal windows
            obj.SynthesisParamColl.Visible = true;
            obj.ReqParamColl.Visible = true;
            obj.FilterParamColl.Visible = true;
            %----------------------------------------------------------
            %----------------------------------------------------------  
            showManualPlots( obj );

                
            releaseWaitPtr(obj);
        end % updateManualView  
        
        function updateParamGUI( obj , ~ , ~ )
                            
                %----------------------------------------------------------
                %          Requirements Parameters
                %----------------------------------------------------------
                obj.SynthesisParamColl.createView(obj.SynTab);
                obj.ReqParamColl.createView(obj.ReqTab);
                addlistener(obj.SynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);

                addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.SynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
                addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);

                addlistener(obj.ReqParamColl,      'EditButtonPressed',@obj.editPressInReq);
                addlistener(obj.SynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);
                addlistener(obj.ReqParamColl,      'ReInitButtonPressed',@obj.reinitParams);
                addlistener(obj.SynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
                %----------------------------------------------------------
                %          Filter Parameters
                %----------------------------------------------------------
                obj.FilterParamColl.createView(obj.FilterTab);
                addlistener(obj.FilterParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
        end % updateParamGUI

        function add2Batch( obj , ~ , ~ )
            selGainSource = getGainSource( obj.Tree ); 
            if ~(selGainSource == 0 || selGainSource == 2)
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source must be "Scattered" or empty(No gain source selected)','error'));
                error('User:GainSourceSelected','Gain source must be "Scattered" or empty(No source selected)');
            end

            % If scattered gain is selected ensure the design conditon has a gain associated with it
            if selGainSource == 2
                
                selDesignOperCond = obj.OperCondColl.SelDesignOperCond;
                
                % Get the selected scattered gain source
                scattGainObj = getSelectedScatteredGainObjs(obj.Tree);     
                if isempty(scattGainObj)   
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('The Scattered Gain Object is missing or corupt','error'));
                    error('User:ScatteredGainObjectMissing','The Scattered Gain Object is missing or corupt');
                end

                scattGainObjArray = scattGainObj.ScatteredGainCollection;
                    
                if length(selDesignOperCond) > 1
                    logArray = false(1,length(scattGainObjArray));
                    for i = 1:length(selDesignOperCond)
                        logArray = logArray | [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond(i);
                    end
                else
                    logArray = [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond;
                end

                if ~any(logArray)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gains do not exist for the selected design model.','error'));
                    error('User:DesignModelMissing','Select a design Condition that has a gain defined.');
                end
                    
            end
            
            
            
            
            answer = inputdlg('Enter a unique name for the run:',...
                'Run Name',...
                [1 50],...
                {''});
            drawnow();pause(0.5);
            if isempty(answer)
                return;
            elseif iscell(answer) && isempty(answer{:})
                showLogMessage_CB(obj, [] ,UserInterface.LogMessageEventData('Run name can not be empty','warn'));
                return;
            end
            
            existingNameLA = strcmp(answer,{obj.BatchRunCollection.RunObjects.Title});
            if any(existingNameLA)
                showLogMessage_CB(obj, [] ,UserInterface.LogMessageEventData('Batch name must be unique.','error'));
                return;
            end
            title = strtrim(answer{:});
            % Stab
            stabreqObj = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
            if ~isempty(stabreqObj)
                stabreqObjCopy = copy(stabreqObj);
            else
                stabreqObjCopy = Requirements.Stability.empty;
            end
            [stabreqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            % Freq
            freqreqObj = getSelectedReqObjs( obj.Tree , 'FreqNode');
            if ~isempty(freqreqObj)
                freqreqObjCopy = copy(freqreqObj);
            else
                freqreqObjCopy = Requirements.FrequencyResponse.empty;
            end
            [freqreqObj.PlotData]=deal(Requirements.NewLine.empty);
            
            % Sim
            simreqObj = getSelectedReqObjs( obj.Tree , 'SimNode');
            if ~isempty(simreqObj)
                simreqObjCopy = copy(simreqObj);
%                 simreqObjCopy.SimViewerProject = struct('SimulationData',{},'PlotSettings',{},'RunLabel',{},'TreeExpansionState',{},'RunSpecificColors',{});
            else
                simreqObjCopy = Requirements.SimulationCollection.empty;
            end
            
            % HQ
            hqreqObj = getSelectedReqObjs( obj.Tree , 'HQNode');
            if ~isempty(hqreqObj)
                hqreqObjCopy = copy(hqreqObj);
            else
                hqreqObjCopy = Requirements.HandlingQualities.empty;
            end
            [hqreqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            % ASE
            asereqObj = getSelectedReqObjs( obj.Tree , 'ASENode');
            if ~isempty(asereqObj)
                asereqObjCopy = copy(asereqObj);
            else
                asereqObjCopy = Requirements.Aeroservoelasticity.empty;
            end
            [asereqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            scatteredGainColl = getCurrentScatteredGainObj( obj , obj.ReqParamColl , obj.FilterParamColl , obj.OperCondColl.SelDesignOperCond , ...
                getSelectedSynthesisObjs(obj.Tree) , obj.SynthesisParamColl);

            
            header = obj.OperCondColl.TableHeader;
            obj.BatchRunCollection.TableHeader = header(2:5);
            selAnalysis = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];
            batchRunObjects = UserInterface.ControlDesign.RunObject( 'StabReqObj',stabreqObjCopy,...
                                                'FreqReqObj',freqreqObjCopy,...
                                                'SimReqObj',simreqObjCopy,...
                                                'HQReqObj',hqreqObjCopy,...
                                                'ASEReqObj',asereqObjCopy,...
                                                'AnalysisOperCond',copy(obj.OperCondColl.SelAnalysisOperCond),...
                                                'DesignOperCond',copy(obj.OperCondColl.SelDesignOperCond),...
                                                'ReqParamColl',copy(obj.ReqParamColl)  ,...
                                                'FilterParamColl',copy(obj.FilterParamColl) ,...
                                                'SynthesisParamColl',copy(obj.SynthesisParamColl),...
                                                'AnalysisOperCondDisplayText',obj.OperCondColl.SelectedDisplayData(selAnalysis,2),...%'SimViewerProject',simViewerProject,...
                                                'Title',title,...
                                                'ScatteredGainObj',copy(scatteredGainColl)); 
           addRunObject(obj.BatchRunCollection, batchRunObjects);
           
           

           
           

        end % add2Batch
        
        function removeBatch( obj , ~ , eventdata )
            for i = 1:length(eventdata.Value)      
                logArray = strcmp({obj.BatchRunCollection.RunObjects.Title},eventdata.Value{i});
                if all(logArray)
                    obj.BatchRunCollection.RunObjects = UserInterface.ControlDesign.RunObject.empty;
                else
                    obj.BatchRunCollection.RunObjects(logArray) = []; 
                end 
            end  
            
        end % removeBatch
        
        function resetAllPlots( obj , ~ , ~ )
            try

                for i = 0:obj.StabAxisColl.AxisHandleQueue.size-1
                    cla(obj.StabAxisColl.AxisHandleQueue.get(i),'reset');
                    set(obj.StabAxisColl.AxisHandleQueue.get(i),'Visible','off');
                end

                for i = 0:obj.FreqRespAxisColl.AxisHandleQueue.size-1
                    cla(obj.FreqRespAxisColl.AxisHandleQueue.get(i),'reset');
                    set(obj.FreqRespAxisColl.AxisHandleQueue.get(i),'Visible','off');
                end

                for i = 0:obj.HQAxisColl.AxisHandleQueue.size-1
                    cla(obj.HQAxisColl.AxisHandleQueue.get(i),'reset');
                    set(obj.HQAxisColl.AxisHandleQueue.get(i),'Visible','off');
                end

                for i = 0:obj.ASEAxisColl.AxisHandleQueue.size-1
                    cla(obj.ASEAxisColl.AxisHandleQueue.get(i),'reset');
                    set(obj.ASEAxisColl.AxisHandleQueue.get(i),'Visible','off');
                end

    %             for i = 0:obj.SimViewerColl.AxisHandleQueue.size-1
    %                 cla(obj.SimViewerColl.AxisHandleQueue.get(i),'reset');
    %                 set(obj.SimViewerColl.AxisHandleQueue.get(i),'Visible','off');
    %             end
            catch
                error('Unable to clear all plots');
            end
        end % resetAllPlots

        function showBatchPlots( obj , ~ , eventdata )
 
            try
                setWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, false);
                
                resetAllPlots( obj ); drawnow();pause(0.01);
                req2Plot = eventdata.Value;
                %--------------------------------------------------------------
                %                    Stability
                %--------------------------------------------------------------
                axHLL = obj.StabAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(req2Plot.StabReqObj)
                    if ~isempty(req2Plot.StabReqObj(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        req2Plot.StabReqObj(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( req2Plot.StabReqObj(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    FrequencyResponse
                %--------------------------------------------------------------
                axHLL = obj.FreqRespAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(req2Plot.FreqReqObj)
                    if ~isempty(req2Plot.FreqReqObj(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        req2Plot.FreqReqObj(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( req2Plot.FreqReqObj(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    Simulation
                %--------------------------------------------------------------
                if ~isempty(req2Plot.SimReqObj)
                    for i = 1:length(req2Plot.SimReqObj)                       
                        % Update SimViewer Data
                        loadProject(obj.SimViewerColl(i), req2Plot.SimReqObj(i).SimViewerProject )
                    end


                end
                %--------------------------------------------------------------
                %                    HandlingQualities
                %--------------------------------------------------------------
                axHLL = obj.HQAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(req2Plot.HQReqObj)
                    if ~isempty(req2Plot.HQReqObj(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        req2Plot.HQReqObj(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( req2Plot.HQReqObj(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    Aeroservoelasticity
                %--------------------------------------------------------------
                axHLL = obj.ASEAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(req2Plot.ASEReqObj)
                    if ~isempty(req2Plot.ASEReqObj(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        req2Plot.ASEReqObj(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( req2Plot.ASEReqObj(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                
                %updateBatchView( obj , [] , eventdata );
            catch
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                if obj.Debug
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to update plots','error'));
                end
            end
            
        end % showBatchPlots
        
        function showManualPlots( obj , ~ , ~ )
 
            try
                setWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, false);
                
                resetAllPlots( obj ); drawnow();pause(0.01);
                reqObjs = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
                %--------------------------------------------------------------
                %                    Stability
                %--------------------------------------------------------------
                axHLL = obj.StabAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(reqObjs)
                    if ~isempty(reqObjs(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        reqObjs(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( reqObjs(i).PlotData , axH , true );
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    FrequencyResponse
                %--------------------------------------------------------------
                reqObjs = getSelectedReqObjs( obj.Tree , 'FreqNode');
                axHLL = obj.FreqRespAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(reqObjs)
                    if ~isempty(reqObjs(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        reqObjs(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( reqObjs(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    Simulation
                %--------------------------------------------------------------
                reqObjs = getSelectedReqObjs( obj.Tree , 'SimNode');
                if ~isempty(reqObjs)
                    % Update SimViewer Data
                    for i = 1:length(reqObjs)                       
                        % Update SimViewer Data
                        loadProject(obj.SimViewerColl(i), reqObjs(i).SimViewerProject );
                    end
                end
                %--------------------------------------------------------------
                %                    HandlingQualities
                %--------------------------------------------------------------
                reqObjs = getSelectedReqObjs( obj.Tree , 'HQNode');
                axHLL = obj.HQAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(reqObjs)
                    if ~isempty(reqObjs(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        reqObjs(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( reqObjs(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                %--------------------------------------------------------------
                %                    Aeroservoelasticity
                %--------------------------------------------------------------
                reqObjs = getSelectedReqObjs( obj.Tree , 'ASENode');
                axHLL = obj.ASEAxisColl.AxisHandleQueue;
                axInd = 1;
                for i = 1:length(reqObjs)
                    if ~isempty(reqObjs(i).PlotData)
                        set(axHLL.get(i-1),'Visible','on');
                        reqObjs(i).plotBase(axHLL.get(i-1));
                        axH = axHLL.get(i-1);
                        plot( reqObjs(i).PlotData , axH , true);
                        axInd = axInd + 1;
                        set(axH,'ButtonDownFcn',@obj.buttonClickInAxis);
                    end
                end
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            catch
                resetAllPlots( obj , [] , [] );
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                if obj.Debug
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to update plots Error in "ControlDesignGUI.showManualPlots" ','error'));
                end
            end
            
        end % showManualPlots
        
    end
   
    %% Methods - Ordinary
    methods 
        
        function showExpandedGains( obj , ~ , ~ )
            
            obj.GainColl.createExpandedView();
            %addlistener(obj.GainColl,'ShowLogMessage',@obj.showLogMessage_CB);
        end % showExpandedGains    
        
        function editPressInReq( obj , ~ , ~ )
            parametersReq = getAllParmsReqModels( obj ); 
            addNewReqParameters( obj , parametersReq );
        end % editPressInReq    
        
        function editPressInSyn( obj , ~ , ~ )
            parametersSyn = getAllParmsSynModels( obj );
            addNewSynParameters( obj , parametersSyn );
        end % editPressInSyn    
        
        function updateSelectParamTab( obj , ~ , eventdata )
            if eventdata.NewValue == obj.SynTab 
                obj.SelectedParamTab = 1;
            elseif eventdata.NewValue == obj.ReqTab 
                obj.SelectedParamTab = 2;
            elseif eventdata.NewValue == obj.FilterTab 
                obj.SelectedParamTab = 3;
            end
            
            if obj.SelectedParamTab == 1 
                obj.SynthesisParamColl.CurrentSelectedParamter = UserInterface.ControlDesign.Parameter.empty;
            elseif obj.SelectedParamTab == 2
                obj.ReqParamColl.CurrentSelectedParamter = UserInterface.ControlDesign.Parameter.empty;
            end         
        end % updateSelectParamTab
        
        function designPanelTabChanged( obj , ~ , eventdata )
  
            if eventdata.NewValue == obj.StabilityTab 
                obj.RibbonCardPanel.SelectedPanel = 1;
            elseif eventdata.NewValue == obj.FreqRespTab 
                obj.RibbonCardPanel.SelectedPanel = 2;
            elseif eventdata.NewValue == obj.SimulationTab
                obj.RibbonCardPanel.SelectedPanel = 3;
            elseif eventdata.NewValue == obj.HQTab 
                obj.RibbonCardPanel.SelectedPanel = 4;
            elseif eventdata.NewValue == obj.ASETab 
                obj.RibbonCardPanel.SelectedPanel = 5;
            elseif eventdata.NewValue == obj.RTLocusTab 
                obj.RibbonCardPanel.SelectedPanel = 6;
            end
        end % designPanelTabChanged
                        
        function simViewerTabChanged( obj , ~ , eventdata )
 
            ind = find(strcmp(eventdata.NewValue.Title,{obj.SimviewerRibbonCardPanel.Panel.UserData}));
            obj.SimviewerRibbonCardPanel.SelectedPanel = ind;

        end % designPanelTabChanged
        
        function globalVariableIndentInSynthesis( obj , ~ , eventdata )

            globalParamModified( obj.ReqParamColl , eventdata.Object );

        end % globalVariableIndentInSynthesis 
        
        function globalVariableIndentInReq( obj , ~ , eventdata )
                      
            globalParamModified( obj.SynthesisParamColl , eventdata.Object );
            
        end % globalVariableIndentInReq 
        
        function setNumPlotsAll( obj , ~ , ~ , numbPlots )
            
            setOrientation( obj.StabAxisColl , numbPlots ); 
            setOrientation( obj.FreqRespAxisColl , numbPlots ); 
            setOrientation( obj.HQAxisColl , numbPlots ); 
            setOrientation( obj.ASEAxisColl , numbPlots ); 
            
            
            
            obj.NumberOfPlotPerPageStab = numbPlots;
            obj.NumberOfPlotPerPageFR = numbPlots;
            obj.NumberOfPlotPerPageHQ = numbPlots;
            obj.NumberOfPlotPerPageASE = numbPlots;
            
        end % setNumPlotsAll
        
        function setNumPlotsStab( obj , ~ , ~ , numbPlots )
            
            setOrientation( obj.StabAxisColl , numbPlots );            
            obj.NumberOfPlotPerPageStab = numbPlots;
            
        end % setNumPlotsStab
        
        function setNumPlotsFR( obj , ~ , ~ , numbPlots )
            
            setOrientation( obj.FreqRespAxisColl , numbPlots );            
            obj.NumberOfPlotPerPageFR = numbPlots;
            
        end % setNumPlotsFR
        
        function setNumPlotsHQ( obj , ~ , ~ , numbPlots )
            
            setOrientation( obj.HQAxisColl , numbPlots );            
            obj.NumberOfPlotPerPageHQ = numbPlots;
            
        end % setNumPlotsHQ
        
        function setNumPlotsASE( obj , ~ , ~ , numbPlots )
            
            setOrientation( obj.ASEAxisColl , numbPlots );            
            obj.NumberOfPlotPerPageASE = numbPlots;
            
        end % setNumPlotsASE
        
        function setVerboseMode( obj , ~ , ~  )
                    
            obj.Debug = ~obj.Debug;
            
        end % setNumPlotsFR              
        
        function addAxisHandle2Q_CB( obj , ~ , eventdata )
            
            axH = eventdata.Object.axH;
            cla(axH,'reset');
        end % addAxisHandle2Q_CB
        
        function gainSourceChanged( obj , ~ , eventdata )
            obj.GainSource = eventdata.AffectedObject.GainSource;
            obj.OperCondColl.GainSource = eventdata.AffectedObject.GainSource;
            if obj.GainSource == 3 % Scattered
                selectedScatterGainNode = getSelectedScatteredGainObjs(obj.Tree);
                if ~isempty(selectedScatterGainNode) && ~isempty(obj.OperCondColl.OperatingCondition)
                    selectedScatterGainObj  = selectedScatterGainNode.handle.UserData; %selectedScatterGainNode
                    % Get all design conditions in scattered gains file
                    designCond = [selectedScatterGainObj.ScatteredGainCollection.DesignOperatingCondition];
                    
                    % Find all operating conditions with a matching design
                    % condition
                    [obj.OperCondColl.OperatingCondition.HasSavedGain] = deal(false);
                    logArray = false(1,length(obj.OperCondColl.OperatingCondition));
                    for i = 1:length(designCond)
                        logArray = logArray | (designCond(i) == obj.OperCondColl.OperatingCondition);
                    end
                    
                    
                    if all(~logArray)
                        updateTable( obj.OperCondColl , false(1,length(obj.OperCondColl.FilteredOperConds)) , [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis] , true );
                    else
                        [obj.OperCondColl.OperatingCondition(logArray).HasSavedGain] = deal(true);

                        filteredOCSelected = [obj.OperCondColl.FilteredOperConds.HasSavedGain];
                        if sum(filteredOCSelected) <= 1
                            updateTable( obj.OperCondColl , filteredOCSelected , [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis] , true );
                        else
                            updateTable( obj.OperCondColl , false(1,length(obj.OperCondColl.FilteredOperConds)) , [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis] , true );
                        end

                    end
                else
                    obj.OperCondColl.ScatteredGainSourceSelected = false;
                    updateTable( obj.OperCondColl );
                end
            end
            if obj.GainSource == 1 % Synthesis
                obj.OperCondColl.ScatteredGainSourceSelected = true;
                updateTable( obj.OperCondColl );
                %obj.OperCondColl.ScatteredGainSourceSelected = false;
            end
            update( obj );
        end % gainSourceChanged
        
        function scattGainSaveFileChanged( obj , ~ , eventdata )
            obj.SelectedScatteredGainFileObj = eventdata.AffectedObject.SelectedScatteredGainFileObj;
        end % gainSourceChanged  
        
        function setScattGainFileComboBox( obj , ~ , ~ )

            setScattGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScattered.Children.UserData] );

        end % setScattGainFileComboBox

        function scatteredGainFileExported( obj , ~ , ~ )

            obj.SelectedScatteredGainFileObj.ScatteredGainCollection.write2File(obj.SelectedScatteredGainFileObj.Name);
%             setScattGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScattered.Children.UserData] );
%             setScattGainFileComboBox( obj.GainSchPanel , eventdata.AffectedObject.LoadedScattGainObj );
        end % scatteredGainFileExported
        
        function scatteredGainFileCleared( obj , ~ , eventdata )
            
            % Remove scatter Gain file object
            setScattGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScattered.Children.UserData] );
            
            % Add new scattered Gain Object



        end % scatteredGainFileCleared
        
%         function updateSchGainCollGainSchGUI( obj , ~ , ~ )
%             
%             setSchGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScheduled.Children.UserData] );
%             %setSchGainFileComboBox( obj.GainSchPanel , eventdata.AffectedObject.LoadedSchGainObj );
%         end % updateSchGainCollGainSchGUI
        
        function schGainFileSelected( obj , ~ , eventdata )
%             selSchObj = eventdata.Object{1};
%             selScattObj = eventdata.Object{2};
%             if isempty(selSchObj.IncludedGains)
%                 
%                 {selScattObj.ScatteredGainCollection(1).Gain.Name}
%                 
%             end
        end % schGainFileSelected
        
        function scatteredGainFileSelected( obj , ~ , eventdata )
            selectedScatteredGainCollUpdated(obj.GainFilterPanel,eventdata.Object);
        end % scatteredGainFileSelected 
                     
    end % Ordinary Methods
    
    %% Methods - Simulation
    methods 
       function axisCollectionEvent( obj , hobj , eventData )
            
            disp(eventData); 
            reqObjs = getSelectedReqObjs( obj.Tree , 'SimNode');
            logArray = strcmp(eventData.Value,{reqObjs.Title});
            
            selreqObj = reqObjs(logArray);
            
            simOutput = selreqObj.SimulationData.Output;
            SimViewer.Main(simOutput);
            
        end % axisCollectionEvent 
        
        function createSimViewers( obj , hobj , evendData)
            % Add Simviewer Panel if needed
            simObjs = getAllReqObjs( obj.Tree , 'SimNode' );
            for i = 1:length(simObjs)
                
                if isempty(obj.SimViewerTab)
                    obj.SimViewerTab  = uitab('Parent',obj.SimViewerTabPanel);    
                else
                    obj.SimViewerTab(end + 1)  = uitab('Parent',obj.SimViewerTabPanel);
                end
                obj.SimViewerTab(end).Title = simObjs(i).Title;
                 
                % add a panel for the tool ribbon
                obj.SimviewerRibbonCardPanel.addPanel(1,simObjs(i).Title);
                
                % add simviewer
                if isempty(obj.SimViewerColl)
                    obj.SimViewerColl = SimViewer.Main('Parent',obj.SimViewerTab(end),'RibbonParent',obj.SimviewerRibbonCardPanel.Panel(end));
                else
                    obj.SimViewerColl(end + 1) = SimViewer.Main('Parent',obj.SimViewerTab(end),'RibbonParent',obj.SimviewerRibbonCardPanel.Panel(end));
                end
                
                currSimViewerTab = find(obj.SimViewerTab == obj.SimViewerTabPanel.SelectedTab);
                obj.SimviewerRibbonCardPanel.SelectedPanel = currSimViewerTab;
                
                % Add and Update all data in simviewer
                obj.SimViewerColl(end).loadProject( simObjs(i).SimViewerProject );
            end           
                        
        end % createSimViewers       
        
    end 
    
    %% Methods - Gain Schedule 
    methods
        
%         function gainScheduleCollAdded( obj , ~ , eventdata )
%             
%             % This event is called when a new gain schedule is created in
%             % the gains panel
%             
%             
%             %insertEmptySchGainObj_CB( obj.Tree , [] , eventdata );
% 
% %             obj.GainSchPanel.SelectedScattGainFileObj
%             
%             %%%%%%% Check Name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             numOfNodes = length(obj.Tree.GainsScheduled.Children);
%             otherSchNames = {};
%             for i = 1:numOfNodes
%                 child = obj.Tree.GainsScheduled.Children(i);
%                otherSchNames{i + 1} =  char(child.Name);
%             end
%             if isempty(obj.GainSchPanel.SelectedScattGainFileObj)
%                 gainSchCollName = strtrim(['Gain Schedule ',num2str(numOfNodes + 1)]);
%             else
%                 gainSchCollName = strtrim([obj.GainSchPanel.SelectedScattGainFileObj.Name,'Gain Schedule ']);
%             end
%             drawnow();
%             answer = inputdlg('Gain Schedule Object Name:',...
%                 'Gain Schedule Object',...
%                 [1 50],...
%                 {''});
%             drawnow();pause(0.5);
%             if isempty(answer)
%                 return;
%             elseif iscell(answer) && isempty(answer{:})
%                 showLogMessage_CB(obj, [] ,UserInterface.LogMessageEventData('Gain scheduled object name can not be empty','warn'));
%                 return;
%             end
%             if any(strcmp(strtrim(answer{:}),strtrim(otherSchNames)))
%                 errordlg('Gain Schedule object name must be unique.');
%                 return;
%             else
%                 gainSchCollName = strtrim(answer{:});   
%             end
%             
%             
% 
%             %%%%%%% Create New Gain Schedule Collection Object %%%%%%%%%%%%
%             if isempty(obj.GainSchPanel.SelectedScattGainFileObj)
%                 newSchGaincollObj = ScheduledGain.SchGainCollection(gainSchCollName,{}); 
%             else
%                 newSchGaincollObj = ScheduledGain.SchGainCollection(gainSchCollName,{obj.GainSchPanel.SelectedScattGainFileObj.ScatteredGainCollection(1).Gain.Name}); 
%             end
%             
%             %%%%%%% Create Tree Node %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%             node = UserInterface.uiextras.jTree.CheckboxTreeNode('Name',gainSchCollName,...
%                 'Parent',obj.Tree.GainsScheduled,'Checked',false,'CheckboxVisible',true,'Value',40);  
%             node.UserData = newSchGaincollObj;  
%             
%             %%%%%%% Create Sub nodes for each gain %%%%%%%%%%%%%%%%%%%%%%%%
%             allGainNames = newSchGaincollObj.IncludedGains;
%             completedGainNames = newSchGaincollObj.Gains2BeCompleted;
%             parentNode = node;
%             for i = 1:length(allGainNames)
%                 if any(strcmp(allGainNames{i},completedGainNames))
%                     node = UserInterface.uiextras.jTree.CheckboxTreeNode('Name',['<html><font color="red"><i>' allGainNames{i}],'Parent',parentNode,'Checked',false,'CheckboxVisible',false,'Value',41);   
%                 else
%                     node = UserInterface.uiextras.jTree.CheckboxTreeNode('Name',allGainNames{i},'Parent',parentNode,'Checked',false,'CheckboxVisible',false,'Value',42);  
%                 end 
%             end 
%             
%             
%             updateSchGainCollGainSchGUI( obj );
%             %setSchGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScheduled.Children.UserData] );
%             %setLoadedSchGainObj( obj.Tree );
% 
%         end % gainScheduleCollAdded
%         
%         function gainScheduleCollRemoved( obj , ~ , eventdata )
%            
%             removeAll_CB(obj.Tree , [] , [] , obj.Tree.GainsScheduled )
%             
%             
% %             % Save the project
% %             delete(reqObjs);
% %             updateSchGainCollGainSchGUI( obj );
% %             
% %             notify(obj,'SaveProject');
% %             
% %             updateSchGainCollGainSchGUI( obj );
%         end % gainScheduleCollRemoved
        
% %         function selGainChanged( obj , ~ , eventdata )
% %             %setHighlightedGainSchGain(obj.Tree,eventdata.Object{:});
% %         end % selGainChanged
        
    end
    
    %% Methods - ToolRibbon Button Callbacks
    methods (Access = protected) 
        
        function fileNew_CB( obj , ~ , ~)
      
        end % fileNew_CB     

        function fileLoad_CB( obj , ~ , ~)
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.LoadJButton.setFlyOverAppearance(false);
            %obj.LoadJButton.setContentAreaFilled(true);

            req2Icon_Green  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24.png'));
            req2Icon_Blue  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Blue.png'));
            req2Icon_Red  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Red.png'));
            req2Icon_Yellow  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Yellow.png'));
            synIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'gearsFull_24.png'));
            mdlIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Simulink_24.png'));
            operIcon = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Layout_24.png'));
            savePrjIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'LoadProject_24.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,'Load'};
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Operating Condition',operIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem1h.ActionPerformedCallback = @obj.menuAddOperCond;

            
                sourceJmenu = javax.swing.JMenu('<html>Source Gain');
                sourceJmenu.setIcon(synIcon);
                
                menuItem15 = javaObjectEDT('javax.swing.JMenuItem','<html>Synthesis',synIcon);
                menuItem15h = handle(menuItem15,'CallbackProperties');
                menuItem15h.ActionPerformedCallback = @obj.menuAddSynthesis;
                
                menuItem16 = javaObjectEDT('javax.swing.JMenuItem','<html>Scattered',synIcon);
                menuItem16h = handle(menuItem16,'CallbackProperties');
                menuItem16h.ActionPerformedCallback = @obj.menuScattGain;
                
                menuItem17 = javaObjectEDT('javax.swing.JMenuItem','<html>Scheduled',synIcon);
                menuItem17h = handle(menuItem17,'CallbackProperties');
                menuItem17h.ActionPerformedCallback = @obj.menuSchGain;
            
                reqJmenu = javax.swing.JMenu('<html>Requirement');
                reqJmenu.setIcon(req2Icon_Green);
                
                menuItem10 = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',req2Icon_Blue);
                menuItem10h = handle(menuItem10,'CallbackProperties');
                menuItem10h.ActionPerformedCallback = @obj.menuStabReq;
                
                menuItem11 = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',req2Icon_Red);
                menuItem11h = handle(menuItem11,'CallbackProperties');
                menuItem11h.ActionPerformedCallback = @obj.menuFRReq;
                
                menuItem12 = javaObjectEDT('javax.swing.JMenuItem','<html>Handling Qualities',req2Icon_Blue);
                menuItem12h = handle(menuItem12,'CallbackProperties');
                menuItem12h.ActionPerformedCallback = @obj.menuHQReq;
                
                menuItem13 = javaObjectEDT('javax.swing.JMenuItem','<html>Aeroservoelastic',req2Icon_Green);
                menuItem13h = handle(menuItem13,'CallbackProperties');
                menuItem13h.ActionPerformedCallback = @obj.menuASEReq;
                
                menuItem14 = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',req2Icon_Yellow);
                menuItem14h = handle(menuItem14,'CallbackProperties');
                menuItem14h.ActionPerformedCallback = @obj.menuSimReq;
                  
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Project',savePrjIcon);
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem4h.ActionPerformedCallback = @obj.loadWorkspace_CB; 
            
            sourceJmenu.add(menuItem15);
            sourceJmenu.add(menuItem16);
            sourceJmenu.add(menuItem17);
        
            reqJmenu.add(menuItem10);
            reqJmenu.add(menuItem11);
            reqJmenu.add(menuItem14);
            reqJmenu.add(menuItem12);
            reqJmenu.add(menuItem13);
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(sourceJmenu);
            jmenu.add(reqJmenu);
            jmenu.add(menuItem4);
            
            jmenu.show(obj.LoadJButton, 0 , 65 );
            jmenu.repaint;  
         
        end % fileLoad_CB   
        
        function popUpMenuCancelled( obj , ~ , ~ , caller )
            switch caller
                case 'New'
                    obj.NewJButton.setFlyOverAppearance(true);
                    %obj.NewJButton.setContentAreaFilled(true);
                case 'Open'
                    obj.OpenJButton.setFlyOverAppearance(true);
                    %obj.OpenJButton.setContentAreaFilled(true);
                case 'Run'
%                     obj.RunSelJButton.setFlyOverAppearance(true);
                    %obj.RunSelJButton.setContentAreaFilled(true);
                case 'Save'
                    obj.SaveJButton.setFlyOverAppearance(true);
                    %obj.SaveJButton.setContentAreaFilled(true);
                case 'Load'
                    obj.LoadJButton.setFlyOverAppearance(true);
                    %obj.SaveJButton.setContentAreaFilled(true);
                case 'Export'
                    obj.LoadJButton.setFlyOverAppearance(true);
                    %obj.SaveJButton.setContentAreaFilled(true);
                case 'Plot'
                    obj.PlotJButton.setFlyOverAppearance(true);
                    %obj.SaveJButton.setContentAreaFilled(true);
            end
        end % popUpMenuCancelled
    end
    
    %% Methods - ToolRibbon Callbacks
    methods (Access = protected) 
        
        function settingsButton_CB( obj , ~ , ~ )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
                        
            obj.PlotJButton.setFlyOverAppearance(false);
            
            settingsIcon = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Settings_16.png'));
            exportIcon   = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Figure_16.png'));
            checkIcon    = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'check_16.png'));
            
            
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,'Plot'});
            
                plotTopJmenu = javax.swing.JMenu('<html>Plots Per Page');
                plotTopJmenu.setIcon(exportIcon);  
            
                plotJmenu = javax.swing.JMenu('<html>All');
                plotJmenu.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsAll,1};
                    plotJmenu.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsAll,2};
                    plotJmenu.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsAll,4};
                    plotJmenu.add(menuItem3);
                    
                    
                    allPlots = isequal(obj.NumberOfPlotPerPageStab,...
                                obj.NumberOfPlotPerPageFR,...
                                obj.NumberOfPlotPerPageHQ,...
                                obj.NumberOfPlotPerPageASE);
                    if allPlots
                        switch obj.NumberOfPlotPerPageStab
                            case 1
                                menuItem1h.setIcon(checkIcon);
                            case 2
                                menuItem2h.setIcon(checkIcon);
                            case 4
                                menuItem3h.setIcon(checkIcon);
                        end
                    end
                    
                    
                plotJmenuStab = javax.swing.JMenu('<html>Stability');
                plotJmenuStab.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsStab,1};
                    plotJmenuStab.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsStab,2};
                    plotJmenuStab.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsStab,4};
                    plotJmenuStab.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPageStab
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end
                    
                plotJmenuFR = javax.swing.JMenu('<html>Frequency Response');
                plotJmenuFR.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsFR,1};
                    plotJmenuFR.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsFR,2};
                    plotJmenuFR.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsFR,4};
                    plotJmenuFR.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPageFR
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end
                    
                plotJmenuHQ = javax.swing.JMenu('<html>Handeling Qualities');
                plotJmenuHQ.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsHQ,1};
                    plotJmenuHQ.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsHQ,2};
                    plotJmenuHQ.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsHQ,4};
                    plotJmenuHQ.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPageHQ
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end
                    
                plotJmenuASE = javax.swing.JMenu('<html>ASE');
                plotJmenuASE.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsASE,1};
                    plotJmenuASE.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsASE,2};
                    plotJmenuASE.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsASE,4};
                    plotJmenuASE.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPageASE
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end

            plotTopJmenu.add(plotJmenu);
            plotTopJmenu.add(plotJmenuStab);
            plotTopJmenu.add(plotJmenuFR);
            plotTopJmenu.add(plotJmenuHQ);
            plotTopJmenu.add(plotJmenuASE);

            
            verboseTopJmenu = javax.swing.JMenuItem('<html>Verbose Mode');
            if obj.Debug; verboseTopJmenu.setIcon(checkIcon); end
            verboseJMenuh = handle(verboseTopJmenu,'CallbackProperties');
            verboseJMenuh.ActionPerformedCallback = {@obj.setVerboseMode};    
            
            
            
            
            
            jmenu.add(plotTopJmenu);
            jmenu.add(verboseTopJmenu);
            %SaveJButton
            jmenu.show(obj.PlotJButton, 0 , 28 );
            jmenu.repaint;   
        end % settingsButton_CB

        function toolRibButtonPanelSel_CB( obj , ~ , ~ , currSel , selText )
            if currSel == 6
                FilterDesign.main();
                return;
            end
            
            if currSel == 4 
                obj.RunSelJButton.setEnabled(0);        
            else
                obj.RunSelJButton.setEnabled(1);
            end
            obj.CurrSelToolRibbion = currSel; 
            obj.ToolRibbionSelectedText = selText;
            obj.update;  
        end % toolRibButtonPanelSel_CB
        
        function viewDesignHistory_CB( ~ , ~ )
            winopen('DesignHistory.csv');
        end % viewDesignHistory_CB

        function saveToolRibbon_CB( obj , ~ , ~ )
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.SaveJButton.setFlyOverAppearance(false);

            
            saveGainIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Save_Dirty_24.png'));
            saveWorkspaceIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Save_Dirty_24.png'));

            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,'Save'});

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save Project',saveWorkspaceIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.saveWorkspace); 
      
            % Add all menu items to the context menu
%             jmenu.add(menuItem1);
            jmenu.add(menuItem2);

            %SaveJButton
            jmenu.show(obj.SaveJButton, 0 , 65 );
            jmenu.repaint;    
                    
        end % saveToolRibbon_CB
        
        function exportToolRibbon_CB( obj , ~ , ~ )
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.ExportJButton.setFlyOverAppearance(false);

            exportIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Export_24.png'));
            variableIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Variable_24.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,'Export'});

            
            %----------------------------------------------------------
            %         Export Linear Models
            %----------------------------------------------------------   
            exportLMJmenu = javax.swing.JMenu('<html>Linear Models');
            exportLMJmenu.setIcon(exportIcon);
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem1h.ActionPerformedCallback = {@obj.menuExportLinearModels,'all'};
                exportLMJmenu.add(menuItem1);
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Selected',exportIcon);
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem2h.ActionPerformedCallback = {@obj.menuExportLinearModels,'selected'};
                exportLMJmenu.add(menuItem2);
          
            %----------------------------------------------------------
            %         Export Plots
            %----------------------------------------------------------   
            exportPlotsJmenu = javax.swing.JMenu('<html>Plots');
            exportPlotsJmenu.setIcon(exportIcon);
                figJmenu = javaObjectEDT('javax.swing.JMenu','<html>To Matlab Figure');
                figJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportPlots,'All'};
                    figJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportPlots,'Stability'};
                    figJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportPlots,'FrequencyResponse'};
                    figJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportPlots,'Simulation'};
                    figJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportPlots,'HandelingQualities'};
                    figJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportPlots,'ASE'};
                    figJmenu.add(plotJmenuASE);
                exportPlotsJmenu.add(figJmenu);
                
                pdfPJmenu = javaObjectEDT('javax.swing.JMenu','<html>To PDF');
                pdfPJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','All'};
                    pdfPJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','Stability'};
                    pdfPJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','FrequencyResponse'};
                    pdfPJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','Simulation'};
                    pdfPJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','HandelingQualities'};
                    pdfPJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportPlotsWord,'PDF','ASE'};
                    pdfPJmenu.add(plotJmenuASE);
                exportPlotsJmenu.add(pdfPJmenu);
                
                wordPJmenu = javaObjectEDT('javax.swing.JMenu','<html>To Word');
                wordPJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','All'};
                    wordPJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','Stability'};
                    wordPJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','FrequencyResponse'};
                    wordPJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','Simulation'};
                    wordPJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','HandelingQualities'};
                    wordPJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportPlotsWord,'WORD','ASE'};
                    wordPJmenu.add(plotJmenuASE);
                exportPlotsJmenu.add(wordPJmenu);
                
                ppJmenu = javaObjectEDT('javax.swing.JMenu','<html>To Power Point');
                ppJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','All'};
                    ppJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','Stability'};
                    ppJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','FrequencyResponse'};
                    ppJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','Simulation'};
                    ppJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','HandelingQualities'};
                    ppJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportPlotsPowerPoint,'PP','ASE'};
                    ppJmenu.add(plotJmenuASE);
                exportPlotsJmenu.add(ppJmenu);
                
            %----------------------------------------------------------
%             %         Export Report
            %----------------------------------------------------------   
            reportJmenu = javax.swing.JMenu('<html>Report');
            reportJmenu.setIcon(exportIcon);
                wordJmenu = javaObjectEDT('javax.swing.JMenu','<html>To Word');
                wordJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportReport,'WORD','All'};
                    wordJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportReport,'WORD','Stability'};
                    wordJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportReport,'WORD','FrequencyResponse'};
                    wordJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportReport,'WORD','Simulation'};
                    wordJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportReport,'WORD','HandelingQualities'};
                    wordJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportReport,'WORD','ASE'};
                    wordJmenu.add(plotJmenuASE);
                
                
                %wordJmenuh.ActionPerformedCallback = {@obj.exportWord,'All'};
                reportJmenu.add(wordJmenu);

%                 ppJmenu = javaObjectEDT('javax.swing.JMenu','<html>To Power Point');
%                 ppJmenu.setIcon(exportIcon);
%                     plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
%                     plotJmenuh = handle(plotJmenu,'CallbackProperties');
%                     plotJmenuh.ActionPerformedCallback = {@obj.exportReport,'PP','All'};
%                     ppJmenu.add(plotJmenu);
% 
%                     plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
%                     plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
%                     plotJmenuStabh.ActionPerformedCallback = {@obj.exportReport,'PP','Stability'};
%                     ppJmenu.add(plotJmenuStab);
% 
%                     plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
%                     plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
%                     plotJmenuFRh.ActionPerformedCallback = {@obj.exportReport,'PP','FrequencyResponse'};
%                     ppJmenu.add(plotJmenuFR);
% 
%                     plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
%                     plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
%                     plotJmenuSIMh.ActionPerformedCallback = {@obj.exportReport,'PP','Simulation'};
%                     ppJmenu.add(plotJmenuSIM);
% 
%                     plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
%                     plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
%                     plotJmenuHQh.ActionPerformedCallback = {@obj.exportReport,'PP','HandelingQualities'};
%                     ppJmenu.add(plotJmenuHQ);
% 
%                     plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
%                     plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
%                     plotJmenuASEh.ActionPerformedCallback = {@obj.exportReport,'PP','ASE'};
%                     ppJmenu.add(plotJmenuASE);
%                 reportJmenu.add(ppJmenu);
                
                pdfJmenu = javaObjectEDT('javax.swing.JMenu','<html>To PDF');
                pdfJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportReport,'PDF','All'};
                    pdfJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportReport,'PDF','Stability'};
                    pdfJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportReport,'PDF','FrequencyResponse'};
                    pdfJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportReport,'PDF','Simulation'};
                    pdfJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportReport,'PDF','HandelingQualities'};
                    pdfJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportReport,'PDF','ASE'};
                    pdfJmenu.add(plotJmenuASE);
                reportJmenu.add(pdfJmenu);
                
                htmlJmenu = javaObjectEDT('javax.swing.JMenu','<html>To HTML');
                htmlJmenu.setIcon(exportIcon);
                    plotJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>All',exportIcon);
                    plotJmenuh = handle(plotJmenu,'CallbackProperties');
                    plotJmenuh.ActionPerformedCallback = {@obj.exportReport,'HTML','All'};
                    htmlJmenu.add(plotJmenu);

                    plotJmenuStab = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',exportIcon);
                    plotJmenuStabh = handle(plotJmenuStab,'CallbackProperties');
                    plotJmenuStabh.ActionPerformedCallback = {@obj.exportReport,'HTML','Stability'};
                    htmlJmenu.add(plotJmenuStab);

                    plotJmenuFR = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',exportIcon);
                    plotJmenuFRh = handle(plotJmenuFR,'CallbackProperties');
                    plotJmenuFRh.ActionPerformedCallback = {@obj.exportReport,'HTML','FrequencyResponse'};
                    htmlJmenu.add(plotJmenuFR);

                    plotJmenuSIM = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',exportIcon);
                    plotJmenuSIMh = handle(plotJmenuSIM,'CallbackProperties');
                    plotJmenuSIMh.ActionPerformedCallback = {@obj.exportReport,'HTML','Simulation'};
                    htmlJmenu.add(plotJmenuSIM);

                    plotJmenuHQ = javaObjectEDT('javax.swing.JMenuItem','<html>Handeling Qualities',exportIcon);
                    plotJmenuHQh = handle(plotJmenuHQ,'CallbackProperties');
                    plotJmenuHQh.ActionPerformedCallback = {@obj.exportReport,'HTML','HandelingQualities'};
                    htmlJmenu.add(plotJmenuHQ);

                    plotJmenuASE = javaObjectEDT('javax.swing.JMenuItem','<html>ASE',exportIcon);
                    plotJmenuASEh = handle(plotJmenuASE,'CallbackProperties');
                    plotJmenuASEh.ActionPerformedCallback = {@obj.exportReport,'HTML','ASE'};
                    htmlJmenu.add(plotJmenuASE);
                reportJmenu.add(htmlJmenu);
                
                
            %----------------------------------------------------------
            %         Export Scattered Gains
            %----------------------------------------------------------
            exportJmenu = javax.swing.JMenu('<html>Scattered Gains');
            exportJmenu.setIcon(exportIcon);

            gainScattObj = getAllScatteredGainObjs(obj.Tree);
            for i = 1:length(gainScattObj)
                menuItem10 = javaObjectEDT('javax.swing.JMenuItem',['<html>',char(gainScattObj(i).Name)],variableIcon);
                menuItem10h = handle(menuItem10,'CallbackProperties');
                menuItem10h.ActionPerformedCallback = {@obj.menuExportScatteredGains,i};
                exportJmenu.add(menuItem10);
            end

            %----------------------------------------------------------
            %         Export Scheduled Gains
            %----------------------------------------------------------
            exportSchJmenu = javax.swing.JMenu('<html>Scheduled Gains');
            exportSchJmenu.setIcon(exportIcon);

            gainSchObj = getAllScheduledGainObjs(obj.Tree);
            for i = 1:length(gainSchObj)
                menuItem11 = javaObjectEDT('javax.swing.JMenuItem',['<html>',char(gainSchObj(i).Name)],variableIcon);
                menuItem11h = handle(menuItem11,'CallbackProperties');
                menuItem11h.ActionPerformedCallback = {@obj.menuExportScheduledGains,i};
                exportSchJmenu.add(menuItem11);
            end
            
            %----------------------------------------------------------
            %         Export Current Scattered Gain Object to base wksp
            %----------------------------------------------------------
%                 menuItemExportSGObj = javaObjectEDT('javax.swing.JMenuItem','<html>Export current variables to base wrksp',exportIcon);
%                 menuItemExportSGObjh = handle(menuItemExportSGObj,'CallbackProperties');
%                 menuItemExportSGObjh.ActionPerformedCallback = @obj.exportCurrentScattGainObj2Base;    
            
            %----------------------------------------------------------
            %         Add all menu items to the context menu
            %----------------------------------------------------------

            if ~isempty(gainScattObj)
                jmenu.add(exportJmenu);
            end
            if ~isempty(gainSchObj)
                jmenu.add(exportSchJmenu);
            end
            jmenu.add(exportLMJmenu);
            jmenu.add(reportJmenu);
            jmenu.add(exportPlotsJmenu);
%             jmenu.add(menuItemExportSGObj);
            jmenu.show(obj.ExportJButton, 0 , 65 );
            jmenu.repaint;    
                    
        end % exportToolRibbon_CB

        function loadWorkspace_CB( obj , ~ , ~)
            
            [filename, pathname] = uigetfile(...%{'*.mat'},'Select saved project');
                                {'*.fltc',...
                                 'FLIGHTcontrol Project Files (*.fltc)';
                                 '*.*',  'All Files (*.*)'},...
                                 'Select Saved Project',...
                                 obj.ProjectDirectory);
            drawnow()
            % load and assign objects
            if ~isequal(filename,0)
                
                
                % Ensure user want to continue
                choice = questdlg('The current project will close. Would you like to continue?', ...
                    'Close Project?', ...
                    'Yes','No','No');
                % Handle response
                switch choice
                    case 'Yes'
                        loadProject( obj , pathname , filename );
                    otherwise
                        return;
                end
                 
            end 
        end % loadWorkspace_CB
        
        function newRequierment_CB( obj , ~ , ~ )
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.NewJButton.setFlyOverAppearance(false);
            %obj.NewJButton.setContentAreaFilled(true);
            
%             reqIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'req_24.png'));
            req2Icon_Green  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24.png'));
            req2Icon_Blue  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Blue.png'));
            req2Icon_Red  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Red.png'));
            req2Icon_Yellow  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Yellow.png'));
            synIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'gearsFull_24.png'));

            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,'New'};
            

                reqSynmenu = javax.swing.JMenu('<html>Synthesis');
                reqSynmenu.setIcon(synIcon);
                
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Synthesis',synIcon);
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem2h.ActionPerformedCallback = @obj.menuNewSynthesis; 
            
                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Root Locus',req2Icon_Yellow);
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem3h.ActionPerformedCallback = @obj.menuNewRTLReq;
            
            

            
                reqJmenu = javax.swing.JMenu('<html>Requirement');
                reqJmenu.setIcon(req2Icon_Green);
                
                menuItem10 = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',req2Icon_Blue);
                menuItem10h = handle(menuItem10,'CallbackProperties');
                menuItem10h.ActionPerformedCallback = @obj.menuNewStabReq;
                
                menuItem11 = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',req2Icon_Red);
                menuItem11h = handle(menuItem11,'CallbackProperties');
                menuItem11h.ActionPerformedCallback = @obj.menuNewFRReq;
                
                menuItem12 = javaObjectEDT('javax.swing.JMenuItem','<html>Handling Qualities',req2Icon_Blue);
                menuItem12h = handle(menuItem12,'CallbackProperties');
                menuItem12h.ActionPerformedCallback = @obj.menuNewHQReq;
                
                menuItem13 = javaObjectEDT('javax.swing.JMenuItem','<html>Aeroservoelastic',req2Icon_Green);
                menuItem13h = handle(menuItem13,'CallbackProperties');
                menuItem13h.ActionPerformedCallback = @obj.menuNewASEReq;
                
                menuItem14 = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',req2Icon_Yellow);
                menuItem14h = handle(menuItem14,'CallbackProperties');
                menuItem14h.ActionPerformedCallback = @obj.menuNewSimReq;
                

                

            

            reqSynmenu.add(menuItem2);
            reqSynmenu.add(menuItem3);
            
            reqJmenu.add(menuItem10);
            reqJmenu.add(menuItem11);
            reqJmenu.add(menuItem14);
            reqJmenu.add(menuItem12);
            reqJmenu.add(menuItem13);

            
            % Add all menu items to the context menu

            jmenu.add(menuItem2);

            jmenu.add(reqJmenu);

            
            jmenu.show(obj.NewJButton, 0 , 65 );
            jmenu.repaint;    
                    

        end % newRequierment_CB
        
        function openRequierment_CB( obj , ~ , ~)

            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.OpenJButton.setFlyOverAppearance(false);

           
            req2Icon_Green  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24.png'));
            req2Icon_Blue  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Blue.png'));
            req2Icon_Red  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Red.png'));
            req2Icon_Yellow  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Yellow.png'));

            synIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'gearsFull_24.png'));

            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,'Open'};
            


            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Synthesis',synIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem2h.ActionPerformedCallback = @obj.menuOpenSynthesis; 
            

            
                reqJmenu = javax.swing.JMenu('<html>Requirement');
                reqJmenu.setIcon(req2Icon_Green);
                menuItem10 = javaObjectEDT('javax.swing.JMenuItem','<html>Stability',req2Icon_Blue);
                menuItem10h = handle(menuItem10,'CallbackProperties');
                menuItem10h.ActionPerformedCallback = @obj.menuOpenStabReq;
                
                menuItem11 = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response',req2Icon_Red);
                menuItem11h = handle(menuItem11,'CallbackProperties');
                menuItem11h.ActionPerformedCallback = @obj.menuOpenFRReq;
                
                menuItem12 = javaObjectEDT('javax.swing.JMenuItem','<html>Handling Qualities',req2Icon_Blue);
                menuItem12h = handle(menuItem12,'CallbackProperties');
                menuItem12h.ActionPerformedCallback = @obj.menuOpenHQReq;
                
                menuItem13 = javaObjectEDT('javax.swing.JMenuItem','<html>Aeroservoelastic',req2Icon_Green);
                menuItem13h = handle(menuItem13,'CallbackProperties');
                menuItem13h.ActionPerformedCallback = @obj.menuOpenASEReq;
                
                menuItem14 = javaObjectEDT('javax.swing.JMenuItem','<html>Simulation',req2Icon_Yellow);
                menuItem14h = handle(menuItem14,'CallbackProperties');
                menuItem14h.ActionPerformedCallback = @obj.menuOpenSimReq;
                
            
            
            
            reqJmenu.add(menuItem10);
            reqJmenu.add(menuItem11);
            reqJmenu.add(menuItem14);
            reqJmenu.add(menuItem12);
            reqJmenu.add(menuItem13);
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem2);
            jmenu.add(reqJmenu);

            
            jmenu.show(obj.OpenJButton, 0 , 65 );
            jmenu.repaint;    
        end % openRequierment_CB    
      
        function operCondAdded( obj , ~ , eventdata )

            operCond2Load = eventdata.Object;
            for j = 1:length(operCond2Load)
                [~,filename,ext] = fileparts(operCond2Load{j});
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Loading - ',[filename,ext],'...'],'info'));
                drawnow();pause(0.1);
                varStruct = load(operCond2Load{j});
                drawnow();pause(0.5);
                varNames = fieldnames(varStruct);
                numOperCond = 0;
                for i = 1:length(varNames)
                    operCond = varStruct.(varNames{i});
                    addOperCond(obj.OperCondColl,operCond);
                    numOperCond = numOperCond + length(operCond);
                end
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([num2str(numOperCond),' Operating Conditions from "',[filename,ext],'" have been added.'],'info'));
                %delete(varStruct);
            end

            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Complete - All Operating Conditions have been added.'],'info'));

            
        end % operCondAdded
        
        function operCondRemoved( obj , hobj , eventdata )
            
            removeOperCond( obj.OperCondColl , eventdata.Object );
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Removed Operating Conditons Successfully','info'));
        end % operCondRemoved
    
        function reqObjAdded( obj , ~ , eventdata )
            
            % Add avaliable parameters to parameter selection
            addedReqObjs = eventdata.Object;
            parametersReq = UserInterface.ControlDesign.Parameter.empty;
            parametersSyn = UserInterface.ControlDesign.Parameter.empty;
            try
                for i = 1:length(addedReqObjs)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Adding Object - ',addedReqObjs(i).Title],'info'));
                    if isa(addedReqObjs(i),'Requirements.Synthesis')
                        parametersSyn = [parametersSyn,addedReqObjs(i).getModelWorspaceData]; %#ok<AGROW>
                    else
                        parametersReq = [parametersReq,addedReqObjs(i).getModelWorspaceData]; %#ok<AGROW>
                    end
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Completed Adding Object - ',addedReqObjs(i).Title],'info'));
                end
            catch Mexc
                if strcmp('Simulink:Commands:OpenSystemUnknownSystem',Mexc.identifier)
                    error(Mexc.message);
                else
                    rethrow(Mexc);
                end
            end
            
            % *************Add req  params*********************************
            addNewReqParameters( obj , parametersReq );
            
            % ***************** Add synthesis Params***********************
            addNewSynParameters( obj , parametersSyn );
            
            
            % Add Simviewer Panel if needed
            for i = 1:length(addedReqObjs)
                if isa(addedReqObjs(i),'Requirements.SimulationCollection')
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Adding Object - ',addedReqObjs(i).Title],'info'));
                    % add a new panel for the simulation viewer
                    if isempty(obj.SimViewerTab)
                        obj.SimViewerTab  = uitab('Parent',obj.SimViewerTabPanel);    
                    else
                        obj.SimViewerTab(end + 1)  = uitab('Parent',obj.SimViewerTabPanel);
                    end
                    obj.SimViewerTab(end).Title = addedReqObjs(i).Title;

                    % add a panel for the tool ribbon
                    obj.SimviewerRibbonCardPanel.addPanel(1,addedReqObjs(i).Title);

                    % add simviewer
                    if isempty(obj.SimViewerColl)
                        obj.SimViewerColl = SimViewer.Main('Parent',obj.SimViewerTab(end),'RibbonParent',obj.SimviewerRibbonCardPanel.Panel(end));
                    else
                        obj.SimViewerColl(end + 1) = SimViewer.Main('Parent',obj.SimViewerTab(end),'RibbonParent',obj.SimviewerRibbonCardPanel.Panel(end));
                    end

                    currSimViewerTab = find(obj.SimViewerTab == obj.SimViewerTabPanel.SelectedTab);
                    obj.SimviewerRibbonCardPanel.SelectedPanel = currSimViewerTab;

                    % Select the correct tool bar panel for the simviewer, each
                    % instance of simviewer will have its own panel
    %                 selPanel = length(obj.SimviewerRibbonCardPanel.Panel);
    %                 obj.SimviewerRibbonCardPanel.SelectedPanel(selPanel);
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Completed Adding Object - ',addedReqObjs(i).Title],'info'));
                end
            end
            % Save the project
            notify(obj,'SaveProject');
           
%             notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Complete - Adding Object - ',addedReqObjs(i).Title],'info'));
        end % reqObjAdded 
        
        function reqObjRemoved( obj , ~ , eventdata )
 
            reqObjs = eventdata.Object;
            % Add Simviewer Panel if needed
            if isa(reqObjs,'Requirements.SimulationCollection')
                if isempty(obj.SimviewerRibbonCardPanel.Panel)
                    try     
                        delete(reqObjs);
                    catch
                        warning('Unable to delete requeierment objects');
                    end
                    return;
                end
                for i = 1:length(reqObjs)
                    ind = find(strcmp(reqObjs(i).Title,{obj.SimviewerRibbonCardPanel.Panel.UserData}));

                    if isempty(ind) 
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([reqObjs(i).Title,' - does not exist.'],'Error'));
                        return;
                    end
                    % remove all panels
                    delete( obj.SimViewerColl(ind));
                    obj.SimViewerColl(ind) = [];

                    delete( obj.SimViewerTab(ind));
                    obj.SimViewerTab(ind) = [];

                    obj.SimviewerRibbonCardPanel.deletePanel(ind);
                    
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Complete - Removing Object - ',reqObjs(i).Title],'info'));
                end
       
            end
            
            if ~isempty(obj.SimViewerTab)
            
                currSimViewerTab = find(obj.SimViewerTab == obj.SimViewerTabPanel.SelectedTab);
                obj.SimviewerRibbonCardPanel.SelectedPanel = currSimViewerTab;
                
            end
            
            % Save the project
            delete(reqObjs);
            updateSchGainCollGainSchGUI( obj );
            
            notify(obj,'SaveProject');
            
        end % reqObjAdded 
        
        function addNewReqParameters( obj , parametersReq )
            % *************Add req  params*********************************
            % Find global Req Params
            ria = ismember({parametersReq.Name},{obj.SynthesisParamColl.AvaliableParameterSelection.Name});
            rib = ismember({obj.SynthesisParamColl.AvaliableParameterSelection.Name} , {parametersReq.Name});
            parametersReq(ria) = []; % remove unneeded
 
            if any(rib) && ~isempty(obj.SynthesisParamColl.AvaliableParameterSelection)
                [obj.SynthesisParamColl.AvaliableParameterSelection(rib).Global] = deal(true); 
            end
            parametersReq =  [ parametersReq , obj.SynthesisParamColl.AvaliableParameterSelection(rib)'] ;

            
            
        end % addNewReqParameters

        function addNewSynParameters( obj , parametersSyn )
           % ***************** Add synthesis Params***********************
            % Find global Syn Params
            sia = ismember({parametersSyn.Name},{obj.ReqParamColl.AvaliableParameterSelection.Name});
            sib = ismember({obj.ReqParamColl.AvaliableParameterSelection.Name} , {parametersSyn.Name});
            parametersSyn(sia) = []; % remove unneeded 
            if any(sib) && ~isempty(obj.ReqParamColl.AvaliableParameterSelection)
                [obj.ReqParamColl.AvaliableParameterSelection(sib).Global] = deal(true);   % set existing to global
            end
            parametersSyn =  [ parametersSyn , obj.ReqParamColl.AvaliableParameterSelection(sib)'] ;
   
            add2AvaliableParameters( obj.SynthesisParamColl , parametersSyn );
        end % addNewSynParameters
  
        function runToolR( obj , hobj  , eventdata )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );

            
            runIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Run_24.png'));
            runSaveIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'RunSave_24.png'));
            batchIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workspace__24.png'));
%             runwordIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workspace__24.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
%             set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',@obj.runPopUpMenuCancelled);

            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Run and Save',runSaveIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.runAndSaveGains);


            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Run',runIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.runOnly); 

            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Run and Export Word Document',batchIcon);
            menuItem3h = handle(menuItem3,'CallbackProperties');
            set(menuItem3h,'ActionPerformedCallback',@obj.runAndReport); 
            
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Run and Create Batch Report',batchIcon);
            menuItem4h = handle(menuItem4,'CallbackProperties');
            set(menuItem4h,'ActionPerformedCallback',@obj.runAndBuildReport);  
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
%             jmenu.add(menuItem4);
            
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;    
                      
        end % runToolR

        function stabDropMenu( obj , hobj  , eventdata )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            stabIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Blue.png'));
            blEditorIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Blue.png'));
    
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Broken Loop Analysis Editor',blEditorIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.menuNewBLEditor);

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Stablity Editor',stabIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.menuNewStabReq); 
            
            % Add all menu items to the context menu
            jmenu.add(menuItem2);
            jmenu.add(menuItem1);
            
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;    
                      
        end % stabDropMenu

        function frDropMenu( obj , hobj  , eventdata )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            stabIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Red.png'));
            blEditorIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'workIcon_24_Red.png'));
    
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response Analysis Editor',blEditorIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.menuNewFREditor);

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Frequency Response Editor',stabIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.menuNewFRReq); 
            
            % Add all menu items to the context menu
            jmenu.add(menuItem2);
            jmenu.add(menuItem1);
            
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;    
                      
        end % frDropMenu
    end
    
    %% Methods - Load Project
    methods 
       
        function loadProject( obj , pathname , filename )
            
            notify(obj,'LoadProject',GeneralEventData({pathname,filename}));
            
%             orgGranola = obj.Granola;
%             orgParent = obj.Parent;
% %             eraseWorkspace(obj);
%             delete(obj);
%             ldObj = load(fullfile(pathname,filename),'-mat');
%             obj = ldObj.obj;
%             obj.Parent = orgParent;
%             obj.Granola = orgGranola;
%             obj.StartUpFlag = false;
%             obj.LoadingSavedWorkspace = true;
%             obj.createView(obj.Parent);
%             obj.ProjectSaved = true;
%             
%             obj.LoadedProjectName = filename;
%             obj.ProjectDirectory = pathname;
%             reSize( obj , [] , [] );
%             addProjectPath( obj , pathname );   
            
        end % loadWorkspace_CB
                
        function closeProjectLocal( obj )
            notify(obj,'CloseProject');
%             obj.LoadingSavedWorkspace = false;
%             eraseWorkspace(obj);
% 
%             obj.createView(obj.Parent);
%             obj.ProjectSaved = false;
%             obj.LoadedProjectName = filename;
%             obj.ProjectDirectory = pathname;
%             reSize( obj , [] , [] );
% 
%             % Remove the path
%             if ~isempty(obj.ProjectMatlabPath)
%                 rmpath(obj.ProjectMatlabPath);
%             end
        end % closeProjectLocal
        
    end
    
    %% Methods - Export Callbacks
    methods (Access = protected) 
        
        function menuExportScatteredGains( obj , ~ , ~ , index )
            gainSrcObj       = obj.Tree.GainsScattered.Children(index).UserData; %#ok<NASGU>
%             uisave('gainSrcObj','ScatteredGain');
            
                [file,path] = uiputfile( ...
                    {'*.mat','Scattered Gain Files (*.mat)';
                     '*.*',  'All Files (*.*)'},...
                     'Save Scattered Gains as',obj.SavedProjectLocation);
                drawnow();pause(0.1);
                if isequal(file,0) || isequal(path,0)
                    return;
                else
                    save(fullfile(path,file),'gainSrcObj');
                end
            
        end % menuExportScatteredGains
        
        function menuExportScheduledGains( obj , ~ , ~ , index )
%             gainSrcObj       = obj.Tree.GainsScattered.getChildAt(index - 1).handle.UserData; %#ok<NASGU>
%             uisave('gainSrcObj','ScatteredGain');
        end % menuExportScheduledGains
        
        function menuExportLinearModels( obj , ~ , ~ , selected )
%             allFilteredOC = obj.OperCondColl.FilteredOperConds;
%             for i = 1:length(allFilteredOC)
            if strcmp('all',selected)
                drawnow();pause(0.1);
                Utilities.write2mfile( obj.OperCondColl.FilteredOperConds , true , obj.OperCondColl.TableHeader(2:5) , obj.OperCondColl.TableData(:,2:5) );
                drawnow();pause(0.1);
            else
                logArray = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];
                headerData = obj.OperCondColl.TableHeader(2:5);
                tableData = obj.OperCondColl.TableData(:,2:5);
                drawnow();pause(0.1);
                Utilities.write2mfile( obj.OperCondColl.FilteredOperConds(logArray) , true , headerData , tableData(logArray,:) );
                drawnow();pause(0.1);
            end
%             end
        end % menuExportLinearModels
        
        function exportPlots( obj , ~ , ~ , selected )
            
            %filename = fullfile(pwd,'StabilityPlots.fig');
            [file, path] = uiputfile( ...
                {'*.fig;',...
                 'Figure Files (*.fig)';
                 '*.fig','Figures (*.fig)'},...
                 'Save as',...
                 fullfile(obj.ProjectDirectory,[selected,'_Plots.fig']));
            drawnow();pause(0.1);
            
            if isequal(file,0) || isequal(path,0)
               return;
            end 
            
            filename = fullfile(path,file);
            setWaitPtr(obj);

            try 
                saveFigH = [];
                switch selected
                    case {'All'}

                        axS = obj.StabAxisColl.AxisHandleQueue; 
                        for i = 1:axS.size % Requirement Loop
                            axH(i) = handle(axS.get(i-1)); %#ok<AGROW>
                        end
                        axFR = obj.FreqRespAxisColl.AxisHandleQueue;  
                        for i = 1:axFR.size % Requirement Loop
                            axH(end + 1) = handle(axFR.get(i-1)); %#ok<AGROW>
                        end
                        axHQ = obj.HQAxisColl.AxisHandleQueue; 
                        for i = 1:axHQ.size % Requirement Loop
                            axH(end + 1) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        axASE = obj.ASEAxisColl.AxisHandleQueue;  
                        for i = 1:axASE.size % Requirement Loop
                            axH(end + 1) = handle(axASE.get(i-1)); %#ok<AGROW>
                        end

                        saveFigH = undockFigures( axH );

                        %% Add simulation viewer figures
                        simSaveFigH = matlab.ui.Figure.empty;
                        for i = 1:length(obj.SimViewerColl)
                            tempSaveFigH = obj.SimViewerColl(i).export2Figures();   
                            simSaveFigH = [simSaveFigH, tempSaveFigH];
                        end
                        saveFigH = [saveFigH, simSaveFigH];
                        
                        % Save figures
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'Stability'}
                        axHQ = obj.StabAxisColl.AxisHandleQueue;  
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'FrequencyResponse'}
                        axHQ = obj.FreqRespAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'Simulation'}
                        saveFigH = matlab.ui.Figure.empty;
                        for i = 1:length(obj.SimViewerColl)
                            tempSaveFigH = obj.SimViewerColl(i).export2Figures();   
                            saveFigH = [saveFigH, tempSaveFigH];
                        end
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'HandelingQualities'}
                        axHQ = obj.HQAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'ASE'}
                        axHQ = obj.ASEAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                end
                if ~isempty(saveFigH)
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Plots saved to: ',filename],'info'));
                    %-------------------------------------------------------------- 
                else
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['No ',selected,' plots exist.'],'info'));
                    %--------------------------------------------------------------    
                end
                releaseWaitPtr(obj);
            catch Mexc
                releaseWaitPtr(obj);
                rethrow(Mexc);
            end
        end % exportPlots
        
        function exportPlotsPDF( obj , ~ , ~ , type , selected )
            
            %filename = fullfile(pwd,'StabilityPlots.fig');
            [file, path] = uiputfile( ...
                {'*.fig;',...
                 'Figure Files (*.fig)';
                 '*.fig','Figures (*.fig)'},...
                 'Save as',...
                 fullfile(obj.ProjectDirectory,[selected,'_Plots.fig']));
            drawnow();pause(0.1);
            
            if isequal(file,0) || isequal(path,0)
               return;
            end 
            
            filename = fullfile(path,file);
            setWaitPtr(obj);

            try 
                saveFigH = [];
                switch selected
                    case {'All'}

                        axS = obj.StabAxisColl.AxisHandleQueue; 
                        for i = 1:axS.size % Requirement Loop
                            axH(i) = handle(axS.get(i-1)); %#ok<AGROW>
                        end
                        axFR = obj.FreqRespAxisColl.AxisHandleQueue;  
                        for i = 1:axFR.size % Requirement Loop
                            axH(end + 1) = handle(axFR.get(i-1)); %#ok<AGROW>
                        end
                        axHQ = obj.HQAxisColl.AxisHandleQueue; 
                        for i = 1:axHQ.size % Requirement Loop
                            axH(end + 1) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        axASE = obj.ASEAxisColl.AxisHandleQueue;  
                        for i = 1:axASE.size % Requirement Loop
                            axH(end + 1) = handle(axASE.get(i-1)); %#ok<AGROW>
                        end

                        %% Add simulation viewer figures
                        simSaveFigH = matlab.ui.Figure.empty;
                        for i = 1:length(obj.SimViewerColl)
                            tempSaveFigH = obj.SimViewerColl(i).export2Figures();   
                            simSaveFigH = [simSaveFigH, tempSaveFigH];
                        end
                        saveFigH = [saveFigH, simSaveFigH];
                        
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename);
                        end  
                        delete(saveFigH);
                    case {'Stability'}
                        axHQ = obj.StabAxisColl.AxisHandleQueue;  
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename);
                        end  
                        delete(saveFigH);
                    case {'FrequencyResponse'}
                        axHQ = obj.FreqRespAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename);
                        end  
                        delete(saveFigH);
                    case {'Simulation'}
                        saveFigH = matlab.ui.Figure.empty;
                        for i = 1:length(obj.SimViewerColl)
                            tempSaveFigH = obj.SimViewerColl(i).export2Figures();   
                            saveFigH = [saveFigH, tempSaveFigH];
                        end
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename,'compact');
                        end  
                        delete(saveFigH);
                    case {'HandelingQualities'}
                        axHQ = obj.HQAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename);
                        end  
                        delete(saveFigH);
                    case {'ASE'}
                        axHQ = obj.ASEAxisColl.AxisHandleQueue;   
                        for i = 1:axHQ.size % Requirement Loop
                            axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                        end
                        saveFigH = undockFigures( axH );
                        if ~isempty(saveFigH)
                            savefig(saveFigH,filename);
                        end  
                        delete(saveFigH);
                end
                if ~isempty(saveFigH)
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Plots saved to: ',filename],'info'));
                    %-------------------------------------------------------------- 
                else
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['No ',selected,' plots exist.'],'info'));
                    %--------------------------------------------------------------    
                end
                releaseWaitPtr(obj);
            catch Mexc
                releaseWaitPtr(obj);
                rethrow(Mexc);
            end
        end % exportPlotsPDF
                
        function exportPlotsWord( obj , ~ , ~ , type , selected )
            
            [file , path ] = putPlotsFiles( obj , type , selected );
   
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating figures...','info'));
            if isequal(file,0) || isequal(path,0)
               return;
            end 
            
            filename = fullfile(path,file);
            setWaitPtr(obj);
            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            try
                
                if strcmp(obj.OperCondTabPanel.SelectedTab.Title,obj.ManualTabName)
                    saveFigs = printPlots2File( obj , selected );

                    obj.createFiguresWordDocument( filename , saveFigs  );
                else
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Export Plots Batch Feature coming soon.','warn'));
                end

                for i = 1:length(saveFigs)
                    for j = 1:length(saveFigs(i).Plots)
                        delete(saveFigs(i).Plots(j).Filename);
                    end
                end
                
                if ~isempty(saveFigs)
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Plots saved to: ',filename],'info'));
                    %-------------------------------------------------------------- 
                else
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['No "',selected,'" plots exist.'],'info'));
                    %--------------------------------------------------------------    
                end
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            catch Mexc
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                releaseWaitPtr(obj);
                rethrow(Mexc);
            end
        end % exportPlotsWord  
        
        function exportPlotsPowerPoint( obj , ~ , ~ , type , selected )
            
            [file , path ] = putPlotsFiles( obj , type , selected );
   
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating figures...','info'));
            if isequal(file,0) || isequal(path,0)
               return;
            end 
            
            filename = fullfile(path,file);
            setWaitPtr(obj);
            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            try
                
                if strcmp(obj.OperCondTabPanel.SelectedTab.Title,obj.ManualTabName)
                    saveFigs = printPlots2File( obj , selected );

                    obj.createPowerPoint( filename , saveFigs  );
                else
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Export Plots Batch Feature coming soon.','warn')); 
                end

                for i = 1:length(saveFigs)
                    for j = 1:length(saveFigs(i).Plots)
                        delete(saveFigs(i).Plots(j).Filename);
                    end
                end
                
                if ~isempty(saveFigs)
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Plots saved to: ',filename],'info'));
                    %-------------------------------------------------------------- 
                else
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['No "',selected,'" plots exist.'],'info'));
                    %--------------------------------------------------------------    
                end
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            catch Mexc
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                releaseWaitPtr(obj);
                rethrow(Mexc);
            end
        end % exportPlotsWord
        
        function exportCurrentScattGainObj2Base( obj , ~ , ~ )
            if ~isempty(obj.CurrentScatteredGainColl)
                drawnow();pause(0.5);
                file = write2File(obj.CurrentScatteredGainColl);
                drawnow();pause(0.5);
                evalin('base',['run(''',file{:},''');']);
            end
        end % exportCurrentScattGainObj2Base
        
        function exportReport( obj , ~ , ~ , type , selected )
            
%             if strcmp(type,'PP')
%                 [file , path ] = getReportFiles( obj , type );
%                 
%                 return; 
%             end
            choice = questdlg('Would you like to create a new report, use a template, or append to an existing report?', ...
                'Report Generation', ...
                'New','Template','Append','New');
            % Handle response
            switch choice
                case 'New'
                    rptType = 'New';
                    [file , path ] = putReportFiles( obj , type , selected );
                case 'Template'
                    if ~strcmp(type,'WORD')
                        try
                            error('Report:UnsupportedFeature','"Template" can only be used with a MS Word document.');
                        catch Mexc
                            handleErrors( obj , Mexc );
                        end
                    end
                    rptType = 'Template';
                    [file , path ] = getReportFiles( obj , type );
                case 'Append'
                    rptType = 'Append';
                    [file , path ] = getReportFiles( obj , type );
                otherwise
                    return;
            end  
            drawnow();pause(0.01);
            
            
            
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Generating report...','info'));
            drawnow();pause(0.01);
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating figures...','info'));
            if isequal(file,0) || isequal(path,0)
               return;
            end 
            
            filename = fullfile(path,file);
            setWaitPtr(obj);
            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            try
                
                if strcmp(obj.OperCondTabPanel.SelectedTab.Title,obj.ManualTabName)
                    charAnswer = getSectionName();
                    saveFigs = printPlots2File( obj , selected );

                    obj.createReport( filename , saveFigs , rptType, charAnswer);
                    
                    allReq = saveFigs;% saveFigs = struct('Title',{},'Plots',{},'ReqObj',{})
                    for i = 1:length(allReq)
                        try
                            for j = 1:length(allReq(i).Plots)
                                try
                                    delete(allReq(i).Plots(j).Filename);
                                end
                            end
                        end
                    end
                else
                    saveFigs = printBatchPlots2File( obj , selected );

                    obj.createBatchReport( filename , saveFigs , rptType  );  
                    
                    allReq = [saveFigs.Requierments];% y = struct('Title',{},'OperatingConditions',{},'Requierments',{})
                    for i = 1:length(allReq)
                        try
                            for j = 1:length(allReq(i).Plots)
                                try
                                    delete(allReq(i).Plots(j).Filename);
                                end
                            end
                        end
                    end
                end
                
%                 try
%                     allReq = saveFigs;      
%                 catch
%                     allReq = [saveFigs.Requierments];
%                 end
                
%                 for i = 1:length(allReq)
%                     for j = 1:length(allReq(i).Plots)
%                         delete(allReq(i).Plots(j).Filename);
%                     end
%                 end
                
                if ~isempty(saveFigs)
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Report saved to: ',filename],'info'));
                    %-------------------------------------------------------------- 
                else
                    %--------------------------------------------------------------
                    %    Display Log Message
                    %--------------------------------------------------------------
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['No "',selected,'" plots exist.'],'info'));
                    %--------------------------------------------------------------    
                end
                releaseWaitPtr(obj);
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            catch Mexc
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                releaseWaitPtr(obj);
                rethrow(Mexc);
           end
        end % exportReport
           
        function printModel( obj , models , type , path)
        % Do not delete
% %             notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Printing Models...','info'));
% %             drawnow();pause(0.01);
% %             %type = 'pdf' of 'html'
% %             switch type
% %                 case 'pdf'
% %                     for i = 1:length(models)
% %                         load_system(models{i});
% %                         printInfo = struct(...
% %                             'PrintLog','off',...%: attach log of what's got printed? ('on'/'off')
% %                             'PrintTsLegend','off',...%: print sample time legends? ('on'/'off')
% %                             'PrintFrame',fullfile(matlabroot,'toolbox/simulink/simulink/sldefaultframe.fig'),...%: path to frame file. Empty if no frame
% %                             'FileName',[fullfile(path,'models_report',models{i}),'.pdf'],...%: path to output file. Empty if to real printer
% %                             'PrintOptions','-dwin',...
% %                             'PaperType','usletter',...%: paper size
% %                             'PaperOrientation','landscape',...%: paper orientation ('landscape'/'portrait')
% %                             'TiledPrint','off',...%: tile? ('on'/'off')
% %                             'FromPage',1,...%: default to 0
% %                             'ToPage',99,...%: default to 9999
% %                             'NumCopies',1,...%: default to 1
% %                             'ShowSysPrintDialog',0,...%: invoke system print dialog before print? (true/false)
% %                             'PrinterName',[]); %: name of printer. Empty if to file
% % 
% %                         simPrintFromDialog(get_param(models{i},'handle'), 'AllSystems', 1, 1, printInfo);
% %                     end
% %                 otherwise
% %                     for i = 1:length(models)
% %                         load_system(models{i});
% %                         currDir = pwd;
% %                         cd(fullfile(path,'models_report'));
% %                         rptgen_sl.slbook();
% %                         cd(currDir);
% %                     end
% %             end

        end % printModel
        
        function saveFigs = printPlots2File( obj , selected )
            saveFigs = struct('Title',{},'Plots',{},'ReqObj',{});
            switch selected
                case {'All'}

                    axS = obj.StabAxisColl.AxisHandleQueue; 
                    for i = 1:axS.size % Requirement Loop
                        axH(i) = handle(axS.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(1).Title = 'Stability Analysis';
                    saveFigs(1).Plots = printFigure2File( axH );
                    saveFigs(1).ReqObj = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');

                    axH = matlab.graphics.axis.Axes.empty;
                    axFR = obj.FreqRespAxisColl.AxisHandleQueue;  
                    for i = 1:axFR.size % Requirement Loop
                        axH(i) = handle(axFR.get(i-1)); 
                    end
                    saveFigs(2).Title = 'Frequency Response Analysis';
                    saveFigs(2).Plots = printFigure2File( axH );
                    saveFigs(2).ReqObj = getSelectedReqObjs( obj.Tree , 'FreqNode');

                    selReqObj =  reqObjisSelected( obj.Tree , 'SimNode');
                    reqObj = getAllReqObjs( obj.Tree , 'SimNode');
                    simObjs = obj.SimViewerColl;
                    saveFigs(3).Plots = struct('Filename',{},'Title',{}); 
                    for i = 1:length(simObjs)
                        if selReqObj(i)                            
                            simpts = obj.SimViewerColl(i).export2Files(reqObj(i).Title );
                            saveFigs(3).Plots = [saveFigs(3).Plots, simpts];
                        end
                    end 
                    saveFigs(3).Title = 'Simulation Analysis';
                    saveFigs(3).ReqObj = reqObj(selReqObj);

                    
                    axH = matlab.graphics.axis.Axes.empty;
                    axHQ = obj.HQAxisColl.AxisHandleQueue; 
                    for i = 1:axHQ.size % Requirement Loop
                        axH(end + 1) = handle(axHQ.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(4).Title = 'Handling Qualities Analysis';
                    saveFigs(4).Plots = printFigure2File( axH );
                    saveFigs(4).ReqObj = getSelectedReqObjs( obj.Tree , 'HQNode');

                    axH = matlab.graphics.axis.Axes.empty;
                    axASE = obj.ASEAxisColl.AxisHandleQueue;  
                    for i = 1:axASE.size % Requirement Loop
                        axH(end + 1) = handle(axASE.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(5).Title = 'ASE Analysis';
                    saveFigs(5).Plots = printFigure2File( axH );
                    saveFigs(5).ReqObj = getSelectedReqObjs( obj.Tree , 'ASENode');
                case {'Stability'}
                    axHQ = obj.StabAxisColl.AxisHandleQueue;  
                    for i = 1:axHQ.size % Requirement Loop
                        axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(1).Title = 'Stability Analysis';
                    saveFigs(1).Plots = printFigure2File( axH );
                    saveFigs(1).ReqObj = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
                case {'FrequencyResponse'}
                    axHQ = obj.FreqRespAxisColl.AxisHandleQueue;   
                    for i = 1:axHQ.size % Requirement Loop
                        axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(1).Title = 'Frequency Response Analysis';
                    saveFigs(1).Plots = printFigure2File( axH );
                    saveFigs(1).ReqObj = getSelectedReqObjs( obj.Tree , 'FreqNode');
                case {'Simulation'} 
                    selReqObj =  reqObjisSelected( obj.Tree , 'SimNode');
                    reqObj = getAllReqObjs( obj.Tree , 'SimNode');
                    simObjs = obj.SimViewerColl;
                    saveFigs(1).Plots = struct('Filename',{},'Title',{}); 
                    for i = 1:length(simObjs)
                        if selReqObj(i)  
                            simpts = obj.SimViewerColl(i).export2Files(reqObj(i).Title );
                            saveFigs(1).Plots = [saveFigs(1).Plots, simpts];
                        end
                    end 
                    saveFigs(1).Title = 'Simulation Analysis';
                    saveFigs(1).ReqObj = reqObj(selReqObj);
                case {'HandelingQualities'}
                    axHQ = obj.HQAxisColl.AxisHandleQueue;   
                    for i = 1:axHQ.size % Requirement Loop
                        axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(1).Title = 'Handling Qualities Analysis';
                    saveFigs(1).Plots = printFigure2File( axH );
                    saveFigs(1).ReqObj = getSelectedReqObjs( obj.Tree , 'HQNode');
                case {'ASE'}
                    axHQ = obj.ASEAxisColl.AxisHandleQueue;   
                    for i = 1:axHQ.size % Requirement Loop
                        axH(i) = handle(axHQ.get(i-1)); %#ok<AGROW>
                    end
                    saveFigs(1).Title = 'ASE Analysis';
                    saveFigs(1).Plots = printFigure2File( axH );
                    saveFigs(1).ReqObj = getSelectedReqObjs( obj.Tree , 'ASENode');
            end
        end % printPlots2File
        
        function y = printBatchPlots2File( obj , selected, batchObj )

            y = struct('Title',{},'OperatingConditions',{},'Requierments',{});
            if nargin == 2
                batchObj = obj.BatchRunCollection.RunObjects;
                batchObj = batchObj([batchObj.Selected]);
            end
            for ind = 1:length(batchObj)
                y(ind) = struct('Title',batchObj(ind).Title,...
                    'OperatingConditions',batchObj(ind).AnalysisOperCond,...
                    'Requierments',struct('Title',{},'Plots',{},'ReqObj',{}));

                switch selected
                    case {'All'}

                        y(ind).Requierments(1).Title = 'Stability Analysis';
                        y(ind).Requierments(1).Plots = printBatchFigure2File( batchObj(ind).StabReqObj );
                        y(ind).Requierments(1).ReqObj = copy(batchObj(ind).StabReqObj);

                        y(ind).Requierments(2).Title = 'Frequency Response Analysis';
                        y(ind).Requierments(2).Plots = printBatchFigure2File( batchObj(ind).FreqReqObj );
                        y(ind).Requierments(2).ReqObj = copy(batchObj(ind).FreqReqObj);

                        reqObj = copy(batchObj(ind).SimReqObj);
                        simObjs = obj.SimViewerColl;
                        y(ind).Requierments(3).Plots = struct('Filename',{},'Title',{}); 
                        for i = 1:length(simObjs)
%                             loadProject(obj, prjSettings )                      
%                             simpts = obj.SimViewerColl(i).exportProject2Files(reqObj(i).Title );
%                             batchObj(i).SimReqObj(j).SimViewerProject = obj.SimViewerColl(j).getSavedProject;
%                             batchObj(ind).SimReqObj(i).SimViewerProject
                            loadProject(obj.SimViewerColl(i), batchObj(ind).SimReqObj(i).SimViewerProject ); 
                            
                            
                            simpts = obj.SimViewerColl(i).export2Files(reqObj(i).Title );
                            y(ind).Requierments(3).Plots = [y(ind).Requierments(3).Plots, simpts];
                        end 
                        y(ind).Requierments(3).Title = 'Simulation Analysis';
                        y(ind).Requierments(3).ReqObj = reqObj;
                        
%                         batchObj(i).SimReqObj(j).SimViewerProject
                        
                        
                        y(ind).Requierments(4).Title = 'Handling Qualities Analysis';
                        y(ind).Requierments(4).Plots = printBatchFigure2File( batchObj(ind).HQReqObj );
                        y(ind).Requierments(4).ReqObj = copy(batchObj(ind).HQReqObj);

                        y(ind).Requierments(5).Title = 'ASE Analysis';
                        y(ind).Requierments(5).Plots = printBatchFigure2File( batchObj(ind).ASEReqObj );
                        y(ind).Requierments(5).ReqObj = copy(batchObj(ind).ASEReqObj);
                    case {'Stability'}
  
                        y(ind).Requierments(1).Title = 'Stability Analysis';
                        y(ind).Requierments(1).Plots = printBatchFigure2File( batchObj(ind).StabReqObj );
                        y(ind).Requierments(1).ReqObj = copy(batchObj(ind).StabReqObj);
                    case {'FrequencyResponse'}

                        y(ind).Requierments(1).Title = 'Frequency Response Analysis';
                        y(ind).Requierments(1).Plots = printBatchFigure2File( batchObj(ind).FreqReqObj );
                        y(ind).Requierments(1).ReqObj = copy(batchObj(ind).FreqReqObj) ;
                    case {'Simulation'}

%                         y(ind).Requierments(1).Title = 'Simulation Analysis';
%                         y(ind).Requierments(1).Plots = printSimFigure2File( batchObj(ind).SimReqObj );
%                         y(ind).Requierments(1).ReqObj = getSelectedReqObjs( obj.Tree , 'SimNode');
                        
                        reqObj = copy(batchObj(ind).SimReqObj);
                        simObjs = obj.SimViewerColl;
                        y(ind).Requierments(3).Plots = struct('Filename',{},'Title',{}); 
                        for i = 1:length(simObjs)
                            simpts = obj.SimViewerColl(i).export2Files(reqObj(i).Title );
                            y(ind).Requierments(3).Plots = [y(ind).Requierments(3).Plots, simpts];
                        end 
                        y(ind).Requierments(3).Title = 'Simulation Analysis';
                        y(ind).Requierments(3).ReqObj = reqObj;
                    case {'HandelingQualities'}

                        y(ind).Requierments(1).Title = 'Handling Qualities Analysis';
                        y(ind).Requierments(1).Plots = printBatchFigure2File( batchObj(ind).HQReqObj );
                        y(ind).Requierments(1).ReqObj = copy(batchObj(ind).HQReqObj);
                    case {'ASE'}

                        y(ind).Requierments(1).Title = 'ASE Analysis';
                        y(ind).Requierments(1).Plots = printBatchFigure2File( batchObj(ind).ASEReqObj );
                        y(ind).Requierments(1).ReqObj = copy(batchObj(ind).ASEReqObj);
                end
            end
        end % printBatchPlots2File
      
    end
    
    %% Methods - OperCond Callbacks
    methods
        function operCondTablePopUp( obj , ~ , eventdata )
            hEvent = eventdata.Value{2};
            hModel = eventdata.Value{1};
            if hEvent.isMetaDown
                this_dir = fileparts( mfilename( 'fullpath' ) );
                icon_dir = fullfile( this_dir,'..','..','Resources' );
                icon1  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Layout_16.png'));
                icon2  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'view_icon_24.png'));
                
                jmenu = javaObjectEDT('javax.swing.JPopupMenu'); 
                
                

                if hModel.getSelectedRow >= 0
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % find all batch files
                    batchObjNames = {obj.BatchRunCollection.RunObjects.Title};

                    menuItem4 = javaObjectEDT('javax.swing.JMenu','<html>Add to Batch Run');
                    %menuItem4.setIcon(scattIcon);

                    if ~isempty(batchObjNames)
                        for i = 1:length(batchObjNames)
                            menuItem41 = javaObjectEDT('javax.swing.JMenuItem',['<html>',batchObjNames{i}],icon1);
                            menuItem41h = handle(menuItem41,'CallbackProperties');
                            set(menuItem41h,'ActionPerformedCallback',{@obj.addOper2Batch,batchObjNames{i},hModel.getSelectedRows});
                            menuItem4.add(menuItem41);
                        end
                    else
                        menuItem4.setEnabled(false);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    

                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Show Operating Condition',icon2);
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.write2MFile , hModel.getSelectedRows };
                    
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All - Analysis');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = @obj.selectAllAnalysis;
                    
                    
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All - Analysis');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = @obj.deselectAllAnalysis;
                    
                    jmenu.add(menuItem1);
                    jmenu.addSeparator();
                    jmenu.add(menuItem2);
                    jmenu.add(menuItem3);
                    jmenu.addSeparator();
                    jmenu.add(menuItem4);
                           
                else
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     % find all batch files
%                     batchObjNames = {obj.BatchRunCollection.RunObjects.Title};
%                     scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
% 
%                     menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Add to Batch Run');
%                     menuItem4.setIcon(scattIcon);
% 
%                     for i = 1:length(batchObjNames)
%                         menuItem41 = javaObjectEDT('javax.swing.JMenuItem',['<html>',batchObjNames{i}],scattIcon);
%                         menuItem41h = handle(menuItem41,'CallbackProperties');
%                         set(menuItem41h,'ActionPerformedCallback',@obj.addOper2Batch);
%                         menuItem4.add(menuItem41);
%                     end
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All - Analysis');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = @obj.selectAllAnalysis;
                    
                    
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All - Analysis');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = @obj.deselectAllAnalysis;

                    jmenu.add(menuItem2);
                    jmenu.add(menuItem3);
%                     jmenu.addSeparator();
%                     jmenu.add(menuItem4);
                end

                jmenu.show(obj.OperCondColl.JTable, 35 , 60 );
                jmenu.repaint;
            end
        end % operCondTablePopUp
        
        function deselectAllAnalysis( obj , ~ , ~ )
            
            obj.OperCondColl.deselectAllAnalysis;
        end % deselectAllAnalysis
        
        function selectAllAnalysis( obj , ~ , ~ )
            obj.OperCondColl.selectAllAnalysis;
            
        end % selectAllAnalysis
        
        function write2MFile( obj , ~ , ~ , selRows )
            
            write2MFile(obj.OperCondColl , [] , [] , selRows ); 
            
        end % write2MFile
        
        function addOper2Batch( obj , ~ , ~ , batchName , selRows )
            
            batchObjNames = {obj.BatchRunCollection.RunObjects.Title};
            logArray = strcmp(batchObjNames,batchName);
            
            header = obj.OperCondColl.TableHeader;
            obj.BatchRunCollection.TableHeader = header(2:5);
            
            selRows = double(selRows) + 1;
            highlightedOC = obj.OperCondColl.FilteredOperConds(selRows);
            
            addAnalysisOperCond(obj.BatchRunCollection.RunObjects(logArray) , copy(highlightedOC));
            %addAnalysisOperCond(obj.BatchRunCollection.RunObjects(logArray) , copy(obj.OperCondColl.SelAnalysisOperCond));
            updateTreeTable( obj.BatchRunCollection );
            
        end % addOper2Batch      
        
%         function operCondTableUpdated( obj , ~ , eventdata )
%             if obj.GainSource == 3
%                 % Update Req param table
%                 try delete(obj.ReqTab.Children);end
%                 try delete(obj.ScatteredGainColl.Gain_Container); end
% 
% 
%                 % Update Gains
%                 %try delete(obj.GainColl.Children);end
%                 obj.GainColl.Visible = false;
%                 
%                 if length(obj.OperCondColl.SelDesignOperCond) == 1
%                     
%                     
%                     if obj.OperCondColl.SelDesignOperCond.HasSavedGain
%                         
%                         
%                         
%                         
%                         selDesignOperCond = obj.OperCondColl.SelDesignOperCond;
%                     
%                         % Get the selected scattered gain source
%                         scattGainObj = getSelectedScatteredGainObjs(obj.Tree);     
%                         if isempty(scattGainObj)   
%                             error('User:ScatteredGainObjectMissing','The Scattered Gain Object is missing or corupt');
%                         end
% 
%                         scattGainObjArray = scattGainObj.ScatteredGainCollection;
% 
%                         if length(selDesignOperCond) > 1
%                             logArray = false(1,length(scattGainObjArray));
%                             for i = 1:length(selDesignOperCond)
%                                 logArray = logArray | [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond(i);
%                             end
%                         else
%                             logArray = [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond;
%                         end
% 
%                         if ~any(logArray)
%                             notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gains do not exist for the selected design model.','error'));
%     %                         scatGainCollObj = ScatteredGain.GainCollection.empty;   
%                             error('User:DesignModelMissing','Select a design Condition that has a gain defined.');
%                         else
%                             scatGainCollObj = scattGainObjArray(logArray);
%                         end
%                         obj.ScatteredGainColl = scatGainCollObj;
% %                         createScatteredParameters(obj, scatGainCollObj);
%                         %disp('this one does')
%                         
%                     else
% %                         try delete(obj.ReqTab.Children);end
% %                         obj.ScattteredReqParamColl = UserInterface.ControlDesign.ParameterCollection;
%                         
%                     end
%                 else
%                     % Do Nothing %notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Select one and only one design condition.','warn'));
%                     
%                 end
%                 
% % % %                 selectedScatterGainObj = getSelectedScatteredGainObjs(obj.Tree);
% % % %                 designCond = [selectedScatterGainObj.ScatteredGainCollection.DesignOperatingCondition];                  
% % % % %                 % Find all operating conditions with a matching design
% % % % %                 % condition
% % % % %                 [obj.OperCondColl.OperatingCondition.HasSavedGain] = deal(false);
% % % %                 logArray = false(1,length(obj.OperCondColl.OperatingCondition));
% % % %                 for i = 1:length(designCond)
% % % %                     logArray = logArray | (designCond(i) == obj.OperCondColl.OperatingCondition);
% % % %                 end
%                   
%                     
%             
%             else
%                 obj.ReqParamColl.createView(obj.ReqTab);
%                 addlistener(obj.ReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
%                 addlistener(obj.ReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
%                 addlistener(obj.ReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
%                 addlistener(obj.ReqParamColl, 'ReInitButtonPressed',@obj.reinitParams); 
% %                 createParameterTabs(obj);
%                 try delete(obj.ScatteredGainColl.Gain_Container); end
%                 obj.GainColl.Visible = true;
%             end
%         end % operCondTableUpdated
        
%         function createScatteredParameters(obj, scatGainCollObj)
%              
% 
%             
% % % % %             obj.ScattteredSynthesisParamColl = UserInterface.ControlDesign.ParameterCollection('Parent',obj.SynTab,'Title','Synthesis');
% % % %             obj.ScattteredReqParamColl       = UserInterface.ControlDesign.ParameterCollection('Parent',obj.ReqTab,'Title','Requirement');
% % % % %             addlistener(obj.ScattteredSynthesisParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
% % % %             addlistener(obj.ScattteredReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
% % % % %             addlistener(obj.ScattteredSynthesisParamColl,'GlobalIdentified',@obj.globalVariableIndentInSynthesis);
% % % %             addlistener(obj.ScattteredReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
% % % %             addlistener(obj.ScattteredReqParamColl,      'EditButtonPressed',@obj.editPressInReq);
% % % % %             addlistener(obj.ScattteredSynthesisParamColl,'EditButtonPressed',@obj.editPressInSyn);
% % % %             addlistener(obj.ScattteredReqParamColl,      'ReInitButtonPressed',@obj.reinitParams);
% % % % %             addlistener(obj.ScattteredSynthesisParamColl,'ReInitButtonPressed',@obj.reinitParams);
% % % %                 
% % % % %             add2AvaliableParameters( obj.ScattteredSynthesisParamColl , parametersReq ); 
% % % % 
% % % %             for i = 1:length(scatGainCollObj.RequirementDesignParameter)
% % % %                 newParams(i) = UserInterface.ControlDesign.Parameter('Name', scatGainCollObj.RequirementDesignParameter(i).Name, 'Value', scatGainCollObj.RequirementDesignParameter(i).Value );
% % % % 
% % % %             end
% % % %             add2AvaliableParameters( obj.ScattteredReqParamColl , newParams ); 
%             
%             
%             
%             % Set Gains
%             scatGainCollObj.req_createView(obj.ReqTab);
%             
% %             % Resize
% %             paramPanel = getpixelposition(obj.DesignParameterPanel);
% %             height = paramPanel(4)/2;
% %             try set(obj.ScatteredGainColl,'Gain_Units','Pixels','Gain_Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]);end         
%             
%             
%             
%             
%             
%             
%             
%             % Set Gains
%             scatGainCollObj.gain_createView(obj.DesignParameterPanel);
%             
%             % Resize
%             paramPanel = getpixelposition(obj.DesignParameterPanel);
%             height = paramPanel(4)/2;
%             try set(obj.ScatteredGainColl,'Gain_Units','Pixels','Gain_Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]);end
%             
%            
% %             obj.ScatteredGainColl = UserInterface.ControlDesign.GainCollection('Parent',obj.DesignParameterPanel,'Title','Gain');
% %             addlistener(obj.ScatteredGainColl,'ShowLogMessage',@obj.showLogMessage_CB);
% %             addlistener(obj.ScatteredGainColl,'EnlargeGainCollection',@obj.showExpandedGains); 
% %             
% %             setGains( obj.ScatteredGainColl , scatGainCollObj.Gain );
%         
%         end % createScatteredParameters
        
    end
    
    %% Methods - Report
    methods
        
        function [file , path ] = getReportFiles( obj , type )
           switch type
                case 'WORD'
                    [file, path] = uigetfile( ...
                        {'*.docx;*.doc;','Word Document (*.docx,*.doc)';...
                        '*.*',  'All Files (*.*)'},...
                         'Select File');
                    drawnow();pause(0.1);      
                case 'PP'
                    [file, path] = uigetfile( ...
                        {'*.pptx;',...
                         'PowerPoint (*.pptx)';...
                         '*.*',  'All Files (*.*)'},...
                         'Select File');
                    drawnow();pause(0.1); 
                case 'PDF'
                    [file, path] = uigetfile( ...
                        {'*.pdf;',...
                         'PDF (*.pdf)';...
                         '*.*',  'All Files (*.*)'},...
                         'Select File');
                    drawnow();pause(0.1); 
                case 'HTML'
                    [file, path] = uiputfile( ...
                        {'*.htm;*.html',...
                         'Web Doc (*.htm,*.html)';...
                         '*.*',  'All Files (*.*)'},...
                         'Select File');
                    drawnow();pause(0.1); 
           end
        end % getReportFiles
        
        function [file , path ] = putReportFiles( obj , type , selected )
           switch type
                case 'WORD'
                    [file, path] = uiputfile( ...
                        {'*.docx;*.doc;',...
                         'Word Document (*.docx,*.doc;)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Report.docx']));
                    drawnow();pause(0.1);       
                case 'PDF'
                    [file, path] = uiputfile( ...
                        {'*.pdf;',...
                         'PDF (*.pdf)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Report.pdf']));
                    drawnow();pause(0.1); 
                case 'HTML'
                    [file, path] = uiputfile( ...
                        {'*.htm;*.html',...
                         'Web Doc (*.htm,*.html)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Report.htm']));
                    drawnow();pause(0.1); 
           end
        end % putReportFiles
        
        function [file , path ] = putPlotsFiles( obj , type , selected )
           switch type
                case 'WORD'
                    [file, path] = uiputfile( ...
                        {'*.docx;*.doc;',...
                         'Word Document (*.docx,*.doc;)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Plots.docx']));
                    drawnow();pause(0.1);      
                case 'PP'
                    [file, path] = uiputfile( ...
                        {'*.pptx;',...
                         'PowerPoint (*.pptx)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Presentation.pptx']));
                    drawnow();pause(0.1); 
                case 'PDF'
                    [file, path] = uiputfile( ...
                        {'*.pdf;',...
                         'PDF (*.pdf)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Plots.pdf']));
                    drawnow();pause(0.1); 
                case 'HTML'
                    [file, path] = uiputfile( ...
                        {'*.htm;*.html',...
                         'Web Doc (*.htm,*.html)';},...
                         'Save as',...
                         fullfile(obj.ProjectDirectory,[selected,'_Plots.htm']));
                    drawnow();pause(0.1); 
           end
        end % putPlotsFiles
        
        function createReport( obj , fullFilename , saveFigs , rptType, charAnswer )
            [path,filename,ext] = fileparts(fullFilename);

            
            
            switch rptType
                case 'New'
                    switch ext
                        case '.pptx'
                            createPowerPoint( obj , fullFilename , saveFigs );
                        otherwise
                            % create a directory for the models
                            if ~(exist(fullfile(path,'models_report'),'dir') == 7)
                                mkdir(path,'models_report');
                            end
                            % get all unique models
                            mdls = {};
                            for i=1:length(saveFigs)  
                                if ~isempty(saveFigs(i).ReqObj)
                                    mdls = [mdls,{saveFigs(i).ReqObj.MdlName}]; %#ok<AGROW>
                                end
                            end
                            uniqueMdls = unique(mdls);
                            switch ext 
                                case '.pdf'
                                    printModel( obj , uniqueMdls , 'pdf' , path );
                                    rpt = createWordDocument( obj , saveFigs , '.pdf' , false, [], charAnswer );
                                case '.docx'
                                    printModel( obj , uniqueMdls , 'html' , path );
                                    rpt = createWordDocument( obj , saveFigs , '.html' , true, [], charAnswer );
                                otherwise
                                    printModel( obj , uniqueMdls , 'html' , path );
                                    rpt = createWordDocument( obj , saveFigs , '.html' , false, [], charAnswer );
                            end  

                        % save( rpt );
                        saveAs( rpt , fullFilename  );

                        closeWord( rpt );

                    end
                case 'Template'
                    % Only Word documents are supported
                    % create a directory for the models
                    if ~(exist(fullfile(path,'models_report'),'dir') == 7)
                        mkdir(path,'models_report');
                    end
                    % get all unique models
                    mdls = {};
                    for i=1:length(saveFigs)  
                        if ~isempty(saveFigs(i).ReqObj)
                            mdls = [mdls,{saveFigs(i).ReqObj.MdlName}]; %#ok<AGROW>
                        end
                    end
                    uniqueMdls = unique(mdls);        
                    printModel( obj , uniqueMdls , 'pdf' , path );
                    rpt = createWordDocument( obj , saveFigs , '.pdf' , true , fullFilename, [] );
 

                    % save( rpt );
                    saveAs( rpt , [fullfile(path,[filename,'_NEW']),ext]  );

                    closeWord( rpt );
                case 'Append'
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating Document...','info'));
                    drawnow();pause(0.01);
                    rpt = Report( fullFilename , 'Visible' , true );
                    appendRun2WordDocument( obj , saveFigs , rpt , obj.OperCondColl.FilteredOperConds([obj.OperCondColl.FilteredOperConds.SelectedforAnalysis]) );
                    updateTOC( rpt );
                    updateTOF( rpt );
                    saveAs( rpt , fullFilename  );
                    closeWord( rpt );
            end

        end % createReport
        
        function rpt = createWordDocument( obj , saveFigs , mdlFileExt , visible , filename, charAnswer )
            
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating Document...','info'));
            drawnow();pause(0.01);
            if isempty(filename)
                filename = tempname;
            end
            
            if isempty(charAnswer)
                charAnswer = getSectionName();
            end
            
            rpt = Report( filename , 'Visible' , visible );

            % Go to the end of the document
            rpt.ActX_word.ActiveDocument.Characters.Last.Select;
            % Insert a page break
            %rpt.ActX_word.Selection.InsertBreak; 
            % Add Table of Contents
            rpt.ActX_word.Selection.TypeText('Table of Contents');
            rpt.ActX_word.Selection.Style = 'Normal';
            rpt.ActX_word.Selection.Font.Size = 14; 
            rpt.ActX_word.Selection.Font.Bold = 1;
            rpt.ActX_word.Selection.ParagraphFormat.Alignment = 1; %Center
            rpt.ActX_word.Selection.TypeParagraph;      
            addTOC( rpt );
            rpt.ActX_word.Selection.InsertBreak;
            % Add the Table of figures
            rpt.ActX_word.Selection.TypeText('Table of Figures');
            rpt.ActX_word.Selection.Style = 'Normal';
            rpt.ActX_word.Selection.Font.Size = 14; 
            rpt.ActX_word.Selection.Font.Bold = 1;
            rpt.ActX_word.Selection.ParagraphFormat.Alignment = 1; %Center
            rpt.ActX_word.Selection.TypeParagraph;
            addTOF( rpt );
            rpt.ActX_word.Selection.InsertBreak;

            rpt.ActX_word.Selection.TypeText('Analysis Setup');
            rpt.ActX_word.Selection.Style = 'Heading 1';
            rpt.ActX_word.Selection.TypeParagraph;
            for i = 1:length(saveFigs)
                if ~isempty(saveFigs(i).ReqObj)
                    rpt.ActX_word.Selection.TypeText(saveFigs(i).Title);
                    rpt.ActX_word.Selection.Style = 'Heading 2';
                    rpt.ActX_word.Selection.TypeParagraph; %enter
                    addReqTable( rpt , saveFigs(i).ReqObj , mdlFileExt );
           
                end
            end
%             rpt.ActX_word.Selection.InsertBreak; 

            
            appendRun2WordDocument( obj , saveFigs , rpt , obj.OperCondColl.FilteredOperConds([obj.OperCondColl.FilteredOperConds.SelectedforAnalysis]) , charAnswer );

            updateTOC( rpt );
            updateTOF( rpt );
        end % createWordDocument
        
        function rpt = createBatchWordDocument( obj , saveFigs , mdlFileExt , visible , filename )
            
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating Document...','info'));
            drawnow();pause(0.01);
            if nargin == 4
                filename = tempname;
            end
 
            rpt = Report( filename , 'Visible' , visible );

            % Go to the end of the document
            rpt.ActX_word.ActiveDocument.Characters.Last.Select;
            % Insert a page break
            %rpt.ActX_word.Selection.InsertBreak; 
            % Add Table of Contents
            rpt.ActX_word.Selection.TypeText('Table of Contents');
            rpt.ActX_word.Selection.Style = 'Normal';
            rpt.ActX_word.Selection.Font.Size = 14; 
            rpt.ActX_word.Selection.Font.Bold = 1;
            rpt.ActX_word.Selection.ParagraphFormat.Alignment = 1; %Center
            rpt.ActX_word.Selection.TypeParagraph;      
            addTOC( rpt );
            rpt.ActX_word.Selection.InsertBreak;
            
            % Add the Table of figures
            rpt.ActX_word.Selection.TypeText('Table of Figures');
            rpt.ActX_word.Selection.Style = 'Normal';
            rpt.ActX_word.Selection.Font.Size = 14; 
            rpt.ActX_word.Selection.Font.Bold = 1;
            rpt.ActX_word.Selection.ParagraphFormat.Alignment = 1; %Center
            rpt.ActX_word.Selection.TypeParagraph;
            addTOF( rpt );
            rpt.ActX_word.Selection.InsertBreak;
            
            rpt.ActX_word.Selection.TypeText('Analysis Setup');
            rpt.ActX_word.Selection.Style = 'Heading 1';
            rpt.ActX_word.Selection.TypeParagraph;
            
            allReq = [saveFigs.Requierments];
            [~,ind] = unique({allReq.Title});
            uniqueReq = allReq(ind);
            
            notEmptyUReq = arrayfun(@(x) ~isempty(x.ReqObj),uniqueReq); 
            nonEmptyUniqueReq = uniqueReq(notEmptyUReq);
            
            for i = length(nonEmptyUniqueReq):-1:1 %for i = 1:length(nonEmptyUniqueReq)
                if ~isempty(nonEmptyUniqueReq(i).ReqObj)
                    rpt.ActX_word.Selection.TypeText(nonEmptyUniqueReq(i).Title);
                    rpt.ActX_word.Selection.Style = 'Heading 2';
                    rpt.ActX_word.Selection.TypeParagraph; %enter
                    addReqTable( rpt , nonEmptyUniqueReq(i).ReqObj , mdlFileExt );
                    if i ~= 1
                        rpt.ActX_word.Selection.TypeParagraph; %enter
                    end
           
                end
            end
%             rpt.ActX_word.Selection.InsertBreak; 
            for i = 1:length(saveFigs)
                appendRun( obj , saveFigs(i).Requierments , rpt , saveFigs(i).OperatingConditions , saveFigs(i).Title );
            end
            updateTOC( rpt );
            updateTOF( rpt );
        end % createBatchWordDocument
        
        function appendRun2WordDocument( obj , saveFigs , rpt , operCond , answer )
            
            if nargin < 5
                charAnswer = getSectionName();
            else
                charAnswer = answer;
            end
            
            appendRun( obj , saveFigs , rpt , operCond , charAnswer );

        end % appendRun2WordDocument
        
        function appendRun( obj , saveFigs , rpt , operCond , title )
            
            % Go to the end of the document
            rpt.ActX_word.ActiveDocument.Characters.Last.Select;
            rpt.ActX_word.Selection.InsertBreak; 
%             rpt.ActX_word.Selection.TypeParagraph; %enter
            rpt.ActX_word.Selection.TypeText(title);%['Run #',runNum]);
            rpt.ActX_word.Selection.Style = 'Heading 1';
            rpt.ActX_word.Selection.TypeParagraph; %enter
            
            rpt.ActX_word.Selection.TypeText('Operating Conditions');
            rpt.ActX_word.Selection.Style = 'Heading 2';
            rpt.ActX_word.Selection.TypeParagraph; %enter
                    
            addOperCondTable( rpt , operCond , obj.OperCondColl.TableHeader );
            
            rpt.ActX_word.Selection.TypeParagraph; %enter
            rpt.ActX_word.Selection.InsertBreak; 
            
            
            notEmptyReq = arrayfun(@(x) ~isempty(x.ReqObj),saveFigs); 
            nonEmptySaveFigs = saveFigs(notEmptyReq);
            
            for i = 1:length(nonEmptySaveFigs)
                if ~isempty(nonEmptySaveFigs(i).ReqObj)   
                    rpt.ActX_word.Selection.TypeText(nonEmptySaveFigs(i).Title);
                    rpt.ActX_word.Selection.Style = 'Heading 2';
                    rpt.ActX_word.Selection.TypeParagraph; %enter  
                    addFigure( rpt , nonEmptySaveFigs(i).Plots , title );
                    %rpt.ActX_word.Selection.TypeParagraph; %enter  
                    if i~=length(nonEmptySaveFigs)
%                         rpt.ActX_word.Selection.InsertBreak; 
                    end
                end
            end
%             rpt.ActX_word.Selection.InsertBreak; 
        end % appendRun

        function createPowerPoint( obj , filename , saveFigs )

            ppt = Presentation(filename);

            for i = 1:length(saveFigs)
                if ~isempty(saveFigs(i).ReqObj)
                    addFigure( ppt , saveFigs(i).Plots );
                end
            end

            saveAs( ppt , filename , '.pptx' );

            closePowerPoint( ppt );

        end % createPowerPoint
        
        function createFiguresWordDocument( obj , filename , saveFigs )

            rpt = Report(filename);

            addTOF( rpt );
            
            for i = 1:length(saveFigs)
                if ~isempty(saveFigs(i).ReqObj)
                    addFigure( rpt , saveFigs(i).Plots );
                end
            end

            updateTOF( rpt );
            
            saveAs( rpt , filename  );
            closeWord( rpt );           

        end % createFiguresWordDocument 
        
        function createBatchReport( obj , fullFilename , saveFigs , rptType )
            [path,filename,ext] = fileparts(fullFilename);

            
            
            switch rptType
                case 'New'
                    switch ext
                        case '.pptx'
                            createPowerPoint( obj , fullFilename , saveFigs );
                        otherwise
                            % create a directory for the models
                            if ~(exist(fullfile(path,'models_report'),'dir') == 7)
                                mkdir(path,'models_report');
                            end
                            % get all unique models
                            allReqObjs = [saveFigs.Requierments];
                            mdls = {};
                            for i=1:length(allReqObjs)  
                                if ~isempty(allReqObjs(i).ReqObj)
                                    mdls = [mdls,{allReqObjs(i).ReqObj.MdlName}];
                                end
                            end
                            uniqueMdls = unique(mdls);
                            switch ext 
                                case '.pdf'
                                    printModel( obj , uniqueMdls , 'pdf' , path );
                                    rpt = createBatchWordDocument( obj , saveFigs , '.pdf' , false );
                                case '.docx'
                                    printModel( obj , uniqueMdls , 'html' , path );
                                    rpt = createBatchWordDocument( obj , saveFigs , '.html' , true );
                                otherwise
                                    printModel( obj , uniqueMdls , 'html' , path );
                                    rpt = createBatchWordDocument( obj , saveFigs , '.html' , false );
                            end  

                        % save( rpt );
                        saveAs( rpt , fullFilename  );

                        closeWord( rpt );

                    end
                case 'Template'
                    % Only Word documents are supported
                    % create a directory for the models
                    if ~(exist(fullfile(path,'models_report'),'dir') == 7)
                        mkdir(path,'models_report');
                    end
                    % get all unique models
                    allReqObjs = [saveFigs.Requierments];
                    mdls = {};
                    for i=1:length(allReqObjs)  
                        if ~isempty(allReqObjs(i).ReqObj)
                            mdls = [mdls,{allReqObjs(i).ReqObj.MdlName}]; 
                        end
                    end
                    uniqueMdls = unique(mdls);        
                    printModel( obj , uniqueMdls , 'pdf' , path );
                    rpt = createBatchWordDocument( obj , saveFigs , '.pdf' , true , fullFilename );
 

                    % save( rpt );
                    saveAs( rpt , [fullfile(path,[filename,'_NEW']),ext]  );

                    closeWord( rpt );
                case 'Append'
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Creating Document...','info'));
                    drawnow();pause(0.01);
                    rpt = Report( fullFilename , 'Visible' , true );
                    appendRun2WordDocument( obj , saveFigs , rpt , obj.OperCondColl.FilteredOperConds([obj.OperCondColl.FilteredOperConds.SelectedforAnalysis]) );
                    updateTOC( rpt );
                    updateTOF( rpt );
                    saveAs( rpt , fullFilename  );
                    closeWord( rpt );
            end

        end % createBatchReport
        
    end
    
    %% Methods - Add Menu Callbacks
    methods (Access = protected) 
        
%         function newOperCond( ~ , ~ , ~ )
%             f=figure;
%             UserInterface.ObjectEditor.ReqEditor('Parent',f);
%         end % newOperCond
        
        function menuAddOperCond( obj , ~ , ~ )
            addOperCond(obj.Tree , [] , [] , obj.Tree.OperCondNode );
            obj.NewJButton.setFlyOverAppearance(true);
        end % menuAddOperCond
        
        function menuAddSynthesis( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.GainsSynthesis , [] , Requirements.Synthesis.empty);
        end % menuAddSynthesis
            
        function menuScattGain( obj , ~ , ~ )
            insertScatteredGainCollObjFile_CB( obj.Tree , [] , [] , obj.Tree.GainsScattered , [] , ScatteredGain.GainFile.empty);
            %obj.Tree.GainsSource
        end % menuScattGain
        
        function menuSchGain( obj , ~ , ~ )
            insertSchGainCollObjFile_CB( obj.Tree , [] , [] , obj.Tree.GainSource , [] , ScheduledGain.SchGainCollection.empty);
            %obj.Tree.GainsSource
        end % menuSchGain
                   
        function menuAddReq( obj , ~ , eventdata )

        end % menuAddReq
        
        function menuStabReq( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.StabilityReqNode , [] , Requirements.Stability.empty);
        end % menuStabReq
        
        function menuFRReq( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.FreqNode , [] , Requirements.FrequencyResponse.empty);
        end % menuFRReq
        
        function menuHQReq( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.HQNode , [] , Requirements.HandlingQualities.empty);
        end % menuHQReq
        
        function menuASEReq( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.ASENode , [] , Requirements.Aeroservoelasticity.empty);
        end % menuASEReq

        function menuSimReq( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.SimNode , [] , Requirements.SimulationCollection.empty);
        end % menuSimReq
    end% Add Menu Callbacks
    
    %% Methods - New Menu Callbacks
    methods (Access = protected) 

        function menuNewBLEditor( obj , ~ , ~ )
            brokenLoopEdit = UserInterface.ControlDesign.BrokenloopEditorApp;
            addlistener(brokenLoopEdit,'ObjectLoaded',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewBLEditor

        function menuNewFREditor( obj , ~ , ~ )
            brokenLoopEdit = UserInterface.ControlDesign.FrequencyResponseEditorApp;
            addlistener(brokenLoopEdit,'ObjectLoaded',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewFREditor
        
        function menuNewStabReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewStabReq
        
        function menuNewFRReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.FrequencyResponse);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewFRReq
        
        function menuNewHQReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.HandlingQualities);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewHQReq
        
        function menuNewASEReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.Aeroservoelasticity);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewASEReq

        function menuNewSimReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.SimulationCollection);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewSimReq      
        
        function menuNewSynthesis( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.Synthesis);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewSynthesis
        
        function menuNewRTLReq( obj , ~ , ~ )
            reqEditObj = UserInterface.ObjectEditor.Editor('Requirement',Requirements.RootLocus);
            addlistener(reqEditObj,'ObjectCreated',@(src,event) obj.reqObjCreated(src,event));

        end % menuNewRTLReq
        
        function reqObjCreated( obj , ~ , eventdata )
            reqObj = eventdata.Object;
%             if strcmp(class(eventdata.Source), 'UserInterface.ControlDesign.BrokenloopEditorApp')
%                 for i = 1:length(reqObj)
%                     insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.StabilityReqNode , [] , reqObj(i));
%                 end
%             else
            switch class(reqObj)
                case 'Requirements.SimulationCollection'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.SimNode , [] , reqObj);
                case 'Requirements.Stability'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.StabilityReqNode , [] , reqObj);
                case 'Requirements.FrequencyResponse'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.FreqNode , [] , reqObj);
                case 'Requirements.HandlingQualities'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.HQNode , [] , reqObj);
                case 'Requirements.Aeroservoelasticity'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.ASENode , [] , reqObj);
                case 'Requirements.Synthesis'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.GainsSynthesis , [] , reqObj);
                case 'Requirements.RootLocus'
                    insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.RootLocusNode , [] , reqObj);
            end
%             end
            drawnow();pause(0.1);
            %autoSaveFile( obj , [] , [] );
        end % reqObjCreated
        
    end % New Menu Callbacks
    
    %% Methods - Open Menu Callbacks
    methods (Access = protected) 
        
        function menuOpenStabReq( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.mat'},'Select Stability Requirement File:',obj.BrowseStartDir);
            if isequal(filename,0)
                return;
            end
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}),'FileName',fullfile(pathname,filename));
            
 
        end % menuOpenStabReq
        
        function menuOpenFRReq( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Frequency Response Requirement File:',obj.BrowseStartDir);
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}));

        end % menuOpenFRReq
        
        function menuOpenHQReq( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select HQ Requirement File:',obj.BrowseStartDir);
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}));

        end % menuOpenHQReq
        
        function menuOpenASEReq( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select ASE Requirement File:',obj.BrowseStartDir);
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}));

        end % menuOpenASEReq

        function menuOpenSimReq( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Simulation Requirement File:',obj.BrowseStartDir);
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}));
% 

        end % menuOpenSimReq      
        
        function menuOpenSynthesis( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Synthesis Requirement File:',obj.BrowseStartDir);
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
            UserInterface.ObjectEditor.Editor('Requirement',varStruct.(varNames{1}));

        end % menuOpenSynthesis
        
    end % Open Menu Callbacks
    
    %% Methods - Run Menu Callbacks
    methods (Access = protected) 
        
        function runAndSaveGains( obj , ~ , ~ )

            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running...','info'));
            %--------------------------------------------------------------
            try
      
                if obj.OperCondTabPanel.SelectedTab == obj.BatchTab
                    runBatch( obj , [] , [] ); 
                else
                    run( obj , [] , [] );  

                    if ~isempty(obj.CurrentScatteredGainColl) && ~isempty(obj.CurrentScatteredGainColl.DesignOperatingCondition)% && ...
                            %sourceGainSelected( obj.Tree )
                        if sourceGainSelected( obj.Tree ) 
                            if obj.Tree.GainSource == 1
                                gainAdded = addGain( obj.SelectedScatteredGainFileObj , obj.CurrentScatteredGainColl );
                                if gainAdded
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gains and Parameters Added in ',obj.SelectedScatteredGainFileObj.Name,'.'],'info'));
                                else
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gains and Parameters Replaced in ',obj.SelectedScatteredGainFileObj.Name,'.'],'info'));
                                end
                                resetFilter( obj.GainFilterPanel );
                            end
                        else
                            if ~isempty(obj.OperCondColl.SelDesignOperCond )
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Selected design operating condition will be ignored.','warn'));
                            end
                        end
                        

                    end
                
                end

                autoSaveFile( obj , [] , [] );


            catch exc 
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                releaseWaitPtr(obj);
                handleErrors( obj , exc );
                
            end
            
            
            try 
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
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            end
            drawnow();pause(1);
            UserInterface.Utilities.enableDisableFig(obj.Figure, true);

            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Complete!','info'));
        end % runAndSaveGains
        
        function runOnly( obj , ~ , ~ )
            
            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running...','info'));
            %--------------------------------------------------------------
            try
      
                if obj.OperCondTabPanel.SelectedTab == obj.BatchTab
                    runBatch( obj , [] , [] ); 
                else
                    run( obj , [] , [] );  

                    if ~isempty(obj.CurrentScatteredGainColl) && ~isempty(obj.CurrentScatteredGainColl.DesignOperatingCondition)% && ...
                            %sourceGainSelected( obj.Tree )
                        if sourceGainSelected( obj.Tree ) 
                            if obj.Tree.GainSource == 1
                                gainAdded = addGain( obj.SelectedScatteredGainFileObj , obj.CurrentScatteredGainColl );
                                if gainAdded
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gains and Parameters Added in ',obj.SelectedScatteredGainFileObj.Name,'.'],'info'));
                                else
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gains and Parameters Replaced in ',obj.SelectedScatteredGainFileObj.Name,'.'],'info'));
                                end
                                resetFilter( obj.GainFilterPanel );
                            end
                        else
                            if ~isempty(obj.OperCondColl.SelDesignOperCond )
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Selected design operating condition will be ignored.','warn'));
                            end
                        end
                        

                    end
                
                end

            catch exc 
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                releaseWaitPtr(obj);
                handleErrors( obj , exc );
                
            end
            
            
            try 
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
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
            end
            drawnow();pause(1);
            UserInterface.Utilities.enableDisableFig(obj.Figure, true);

            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Complete!','info'));
        end % runOnly
        
        function runAndReport( obj , ~ , ~ )

            UserInterface.Utilities.enableDisableFig(obj.Figure, false);
            
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running...','info'));
            %--------------------------------------------------------------
            
            % Run the tool
            runOnly( obj , [] , [] );
            
            drawnow();pause(1);
            
            % Create Report
            exportReport(obj, [],[],'WORD','All');
            
            
            UserInterface.Utilities.enableDisableFig(obj.Figure, true);

            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Complete!','info'));
        end % runAndReport
        
        function handleErrors( obj , exc )
                msgString = getReport(exc);
                switch exc.identifier
                    case 'Parameter:Evaluate'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error')); 
                    case 'License:KeyMissing'
                        saveWorkspace( obj , [] ,[] );
                        closeFigure_CB( obj , [] , [] );
                    case 'User:DesignModelMissing'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error')); 
                    case 'User:SynthesisObjectMissing'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error')); 
                    case 'User:GainSourceSelected'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error')); 
                    case 'MATLAB:UndefinedFunction'
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.message,'error'));  
                    case 'Simulink:Parameters:InvParamSetting'
                        try
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(exc.cause{1}.cause{1}.message,'error'));   
                        catch
                            rethrow(exc);
                        end
                    otherwise
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(msgString,'error')); 
                        rethrow(exc);
%                         throwAsCaller(exc);
                end
                
                if obj.Debug
                    rethrow(exc);
                end
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('*****The run terminated.*****','error')); 
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
        end % handleErrors
  
    end
    
    %% Methods - Save Menu Callbacks
    methods 
        
        function saveScatteredGains( obj , ~ , ~ )

        end % saveScatteredGains
        
        function saveWorkspace( obj , ~ , ~ )

                [file,path] = uiputfile( ...
                    {'*.fltc',...
                     'FLIGHTcontrol Project Files (*.fltc)';
                     '*.*',  'All Files (*.*)'},...
                     'Save Project as',obj.SavedProjectLocation);
                if isequal(file,0) || isequal(path,0)
                    return;
                else
                    notify(obj,'SaveProject',GeneralEventData({path , file}));
                end

        end % saveWorkspace
                
    end
    
    %% Methods - Run and Build Report
    methods
        function runAndBuildReport(obj, ~, ~)
        %        profile on
        flaps = 30;

            if flaps == 0
   
                % Search Flap Setting 0
                [filteredOperConds,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                        'Mach', 'All',...
                        'Qbar', 'All',...
                        'FLAP', '0',...
                        'All', 'All'); 

                % Find all Mach numbers    
                allMachs = zeros(size(filteredOperConds));
                for i = 1:length(filteredOperConds)
                    allMachs(i) = filteredOperConds(i).FlightCondition.Mach;
                end
                uniMachs = unique(allMachs);
                
                % Only use mach 0.78 and under
%                 uniMachs = uniMachs(uniMachs<=0.78);

    %             flaps0_OperCondColl = cell(1,numel(uniMachs));
                runObjects = UserInterface.ControlDesign.RunObject.empty;

                for i = 1:length(uniMachs)
                    [flaps0_OperCond_Mach,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                        'Mach', num2str(round2(uniMachs(i))),...
                        'Qbar', 'All',...
                        'FLAP', '0',...
                        'All', 'All');                 
                    % Find Qbar for given Mach
                    allQ = zeros(size(flaps0_OperCond_Mach));
                    for ind = 1:length(flaps0_OperCond_Mach)
                        allQ(ind) = flaps0_OperCond_Mach(ind).FlightCondition.Qbar;
                    end
                    uniQ = unique(allQ);
                    for j = 1:length(uniQ)
                        [flaps0_OperCond_mach_q,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                            'Mach', num2str(round2(uniMachs(i))),...
                            'Qbar', num2str(round2(uniQ(j))),...
                            'FLAP', '0',...
                            'W', 'All'); 
                        if isempty(flaps0_OperCond_mach_q)
                            disp('Empty');
                        end

                        designOperCond = lacm.OperatingCondition.empty;
                        runName = ['Flap 0 Mach ', num2str(uniMachs(i)),' Qbar ', num2str(uniQ(j),'%10.2f')];
                        runObjects(end+1) = getReportRunObj(obj,flaps0_OperCond_mach_q, designOperCond, runName);   
                    end
                end
            
%             else
%                 runObjsVar = load('SavedRunObjs.mat');
%                 runObjects = runObjsVar.runObjects;           
%             end
            
            elseif flaps == 30
   
                % Search Flap Setting 0
                [filteredOperConds,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                        'Mach', 'All',...
                        'Qbar', 'All',...
                        'FLAP', '30',...
                        'All', 'All'); 

                % Find all Mach numbers    
                allMachs = zeros(size(filteredOperConds));
                for i = 1:length(filteredOperConds)
                    allMachs(i) = filteredOperConds(i).FlightCondition.Mach;
                end
                uniMachs = unique(allMachs);

    %             flaps0_OperCondColl = cell(1,numel(uniMachs));
                runObjects = UserInterface.ControlDesign.RunObject.empty;

                for i = 1:length(uniMachs)
                    [flaps0_OperCond_Mach,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                        'Mach', num2str(round2(uniMachs(i))),...
                        'Qbar', 'All',...
                        'FLAP', '30',...
                        'All', 'All');                 
                    % Find Qbar for given Mach
                    allQ = zeros(size(flaps0_OperCond_Mach));
                    for ind = 1:length(flaps0_OperCond_Mach)
                        allQ(ind) = flaps0_OperCond_Mach(ind).FlightCondition.Qbar;
                    end
                    uniQ = unique(allQ);
                    for j = 1:length(uniQ)
                        [flaps0_OperCond_mach_q,~] = UserInterface.ControlDesign.OCCControlDesign.searchLinearModels(obj.OperCondColl.OperatingCondition,...
                            'Mach', num2str(round2(uniMachs(i))),...
                            'Qbar', num2str(round2(uniQ(j))),...
                            'FLAP', '30',...
                            'W', 'All'); 
                        if isempty(flaps0_OperCond_mach_q)
                            disp('Empty');
                        end

                        designOperCond = lacm.OperatingCondition.empty;
                        runName = ['Flap 30 Mach ', num2str(uniMachs(i)),' Qbar ', num2str(uniQ(j),'%10.2f')];
                        runObjects(end+1) = getReportRunObj(obj,flaps0_OperCond_mach_q, designOperCond, runName);   
                    end
                end
            
            else
                runObjsVar = load('SavedRunObjs.mat');
                runObjects = runObjsVar.runObjects;           
            end
%         runObjects = runObjects(5)
%         makeBatchReoport(obj,runObjects,['NzU GS F',num2str(flaps),'.docx']);      
        makeBatchReoport(obj,runObjects,['PBeta GS F',num2str(flaps),'.docx']);     
            

        profile viewer

        end % runandBuildReport
        
        function makeBatchReoport(obj,runObjects,filenames)
                        
            runBatch( obj, [], [], runObjects);

%             runObjectsVar = load('runObjects.mat');
%             runObjects = runObjectsVar.runObjects;
%             save('runObjects','runObjects');
%             notify(obj,'SaveProject');%,fullfile(pwd , 'TempProject.fltc'))


            % Create Report
            filename = fullfile('D:\Projects\Mitsubishi\Linear Control Law Design\OpenLoopHQFQProject\',filenames);
            
            saveFigs = printBatchPlots2File( obj , 'All', runObjects);

            obj.createBatchReport( filename , saveFigs , 'New'  );  

            allReq = [saveFigs.Requierments];
            for i = 1:length(allReq)
                try
                    for j = 1:length(allReq(i).Plots)
                        try
                            delete(allReq(i).Plots(j).Filename);
                        end
                    end
                end
            end

        end % runandBuildReport
        
        function runObjects = getReportRunObj( obj , analysisOperCond, designOperCond, title)
            selGainSource = getGainSource( obj.Tree ); 
            if ~(selGainSource == 0 || selGainSource == 2)
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source must be "Scattered" or empty(No gain source selected)','error'));
                error('User:GainSourceSelected','Gain source must be "Scattered" or empty(No source selected)');
            end

            % If scattered gain is selected ensure the design conditon has a gain associated with it
            if selGainSource == 2
                
                selDesignOperCond = obj.OperCondColl.SelDesignOperCond;
                
                % Get the selected scattered gain source
                scattGainObj = getSelectedScatteredGainObjs(obj.Tree);     
                if isempty(scattGainObj)   
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('The Scattered Gain Object is missing or corupt','error'));
                    error('User:ScatteredGainObjectMissing','The Scattered Gain Object is missing or corupt');
                end

                scattGainObjArray = scattGainObj.ScatteredGainCollection;
                    
                if length(selDesignOperCond) > 1
                    logArray = false(1,length(scattGainObjArray));
                    for i = 1:length(selDesignOperCond)
                        logArray = logArray | [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond(i);
                    end
                else
                    logArray = [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond;
                end

                if ~any(logArray)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gains do not exist for the selected design model.','error'));
                    error('User:DesignModelMissing','Select a design Condition that has a gain defined.');
                end
                    
            end
        
          
            % Stab
            stabreqObj = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
            if ~isempty(stabreqObj)
                stabreqObjCopy = copy(stabreqObj);
            else
                stabreqObjCopy = Requirements.Stability.empty;
            end
            [stabreqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            % Freq
            freqreqObj = getSelectedReqObjs( obj.Tree , 'FreqNode');
            if ~isempty(freqreqObj)
                freqreqObjCopy = copy(freqreqObj);
            else
                freqreqObjCopy = Requirements.FrequencyResponse.empty;
            end
            [freqreqObj.PlotData]=deal(Requirements.NewLine.empty);
            
            % Sim
            simreqObj = getSelectedReqObjs( obj.Tree , 'SimNode');
            if ~isempty(simreqObj)
                simreqObjCopy = copy(simreqObj);
%                 simreqObjCopy.SimViewerProject = struct('SimulationData',{},'PlotSettings',{},'RunLabel',{},'TreeExpansionState',{},'RunSpecificColors',{});
            else
                simreqObjCopy = Requirements.SimulationCollection.empty;
            end
            
            % HQ
            hqreqObj = getSelectedReqObjs( obj.Tree , 'HQNode');
            if ~isempty(hqreqObj)
                hqreqObjCopy = copy(hqreqObj);
            else
                hqreqObjCopy = Requirements.HandlingQualities.empty;
            end
            [hqreqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            % ASE
            asereqObj = getSelectedReqObjs( obj.Tree , 'ASENode');
            if ~isempty(asereqObj)
                asereqObjCopy = copy(asereqObj);
            else
                asereqObjCopy = Requirements.Aeroservoelasticity.empty;
            end
            [asereqObjCopy.PlotData]=deal(Requirements.NewLine.empty);
            
            scatteredGainColl = getCurrentScatteredGainObj( obj , obj.ReqParamColl , obj.FilterParamColl , obj.OperCondColl.SelDesignOperCond , ...
                getSelectedSynthesisObjs(obj.Tree) , obj.SynthesisParamColl);

            
            header = obj.OperCondColl.TableHeader;
            obj.BatchRunCollection.TableHeader = header(2:5);
%             selAnalysis = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];
            selAnalysis = [analysisOperCond.SelectedforAnalysis];
            runObjects = UserInterface.ControlDesign.RunObject( 'StabReqObj',stabreqObjCopy,...
                                                'FreqReqObj',freqreqObjCopy,...
                                                'SimReqObj',simreqObjCopy,...
                                                'HQReqObj',hqreqObjCopy,...
                                                'ASEReqObj',asereqObjCopy,...
                                                'AnalysisOperCond',copy(analysisOperCond),...
                                                'DesignOperCond',copy(designOperCond),... %copy(obj.OperCondColl.SelDesignOperCond),...
                                                'ReqParamColl',copy(obj.ReqParamColl)  ,...
                                                'FilterParamColl',copy(obj.FilterParamColl) ,...
                                                'SynthesisParamColl',copy(obj.SynthesisParamColl),...
                                                'AnalysisOperCondDisplayText',getSelectedDisplayData(obj,analysisOperCond),...%'SimViewerProject',simViewerProject,...
                                                'Title',title,...
                                                'ScatteredGainObj',copy(scatteredGainColl)); 
                                            
        end
        
        function y = getSelectedDisplayData(obj,analysisOperCond)
            fc1 = obj.OperCondColl.SearchVar1.selStr;
            fc2 = obj.OperCondColl.SearchVar2.selStr;
            ic  = obj.OperCondColl.SearchVar3.selStr;
            wc  = obj.OperCondColl.SearchVar4.selStr;
            y = cell(length(analysisOperCond),2);
            for i = 1:length(analysisOperCond)
                y{i} = getSelectedDisplayText(analysisOperCond(i),fc1,fc2,ic,wc);
            end
        end % SelectedDisplayData
    end
    
    %% Methods - Run
    methods (Access = protected)
        
        function setCurrentScatteredGainObj( obj )
            import UserInterface.ControlDesign.Utilities.*
            
            % Determine source of gain
            [ selGainSource , rlSel ] = getGainSource( obj.Tree );            
            
            if length(selGainSource) > 1
                error('ControlDesign:GainSource','Only one gain source may be selected.');
            end
            switch selGainSource
                case 0 % No Gain Sourec Selected - Using user defined paramaters and gains defined in the gain window.
                    
                    %--------------------------------------------------
                    %    Create the Scattered Gains Object
                    %--------------------------------------------------  
                    % Evaluate Requirement Parameters to send to Requirement models
                    % Get globals
                    requirementParams = evalExpressions( obj , [obj.ReqParamColl.Parameters;obj.FilterParamColl.Filters.getFilterParameterValues'] , obj.OperCondColl.SelDesignOperCond , [] );

                    % Evaluate Gain Expressions
% %                     gainParam = evalExpressions( obj , obj.GainColl.Gains , obj.OperCondColl.SelDesignOperCond , requirementParams ); 
% % 
% %                     % Create an array of Gain Objects
% %                     scatGain  = ScatteredGain.Gain(gainParam);
                    scatGain  = obj.CurrentScatteredGainColl.Gain;
                    
                    % Create the Scattered Gain Collection Object 
                    obj.CurrentScatteredGainColl = ScatteredGain.GainCollection( 'OperatingCondition', obj.OperCondColl.SelDesignOperCond ,...
                                                                 'Gains' , scatGain ,...
                                                                 'SynthesisDesignParameter' , ScatteredGain.Parameter.empty ,...
                                                                 'RequirementDesignParameter' , requirementParams ,...
                                                                 'Filters', obj.FilterParamColl.Filters,...
                                                                 'OperCondFilterSettings', obj.OperCondColl.FilterSettings);   
                    
                case 1 % Gain is determined from synthesis model
                    
                    % Get all the selected synthesis objs from the tree
                    synthObjs = getSelectedSynthesisObjs(obj.Tree);
                    if isempty(synthObjs)   
                        error('User:SynthesisObjectMissing','The Synthesis Object is missing or corrupt');
                    end
                    
                    % Notify user of selected gain source
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Synthesis"','info'));
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Synthesis Object...','info'));
                    
                    % Design model must be selected - if not then error
                    if isempty(obj.OperCondColl.SelDesignOperCond)
                        error('User:DesignModelMissing','Design Model not selected');
                    end


                    
                    % Evaluate the sythesis parameters, filter parameters,
                    % and selected operating condition together to
                    % determine the numeric value of each.
                    synthParameters = cell(1,length(obj.OperCondColl.SelDesignOperCond));
                    for i = 1:length(obj.OperCondColl.SelDesignOperCond)
                        synthParameters{i} = evalExpressions( obj , [obj.SynthesisParamColl.Parameters ; obj.FilterParamColl.Filters.getFilterParameterValues'] ,...
                            obj.OperCondColl.SelDesignOperCond(i) , [] );
                    end
                    
                    % RUN SYNTHESIS
                    [gainCellStruct,mdlParams,mdlNames] = run( synthObjs , obj.OperCondColl.SelDesignOperCond , synthParameters );

                    % Display the parameters that were assigned to the
                    % synthesis model in the Status Window.
                    if obj.Debug
                        for j = 1:length(mdlParams)
                            fnames = fieldnames(mdlParams{j});
                            for i = 1:length(fnames)
                                if ~isstruct(mdlParams{j}.(fnames{i}))
                                    if ~isstruct(mdlParams{j}.(fnames{i}))
                                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Assigning :',fnames{i},' :: ',mat2str(mdlParams{j}.(fnames{i})),' in model ',mdlNames{j},'.'],'info'));
                                    end
                                end
                            end
                        end
                    end

                    % Create the Scattered Gains Object
                    if isempty(gainCellStruct) 
                        % no gains were assigned in the synthesis method
                        scattGainObj = ScatteredGain.GainCollection.empty;
                    else
                        gainStruct = gainCellStruct{:};
                        for i = 1:length(gainStruct)
                           gainParamsFromSynthesis(i) = UserInterface.ControlDesign.Parameter('Name',gainStruct(i).Name,'String',gainStruct(i).Value);  %#ok<AGROW>
                        end
                        % Update the GainCollection table
                        setGains( obj.GainColl , gainParamsFromSynthesis );

                        %--------------------------------------------------
                        %    Create the Scattered Gains Object
                        %--------------------------------------------------  
                        % Evaluate Requirement Parameters to send to Requirement models
                        % Get globals
                        %requirementParams = evalExpressions( obj , obj.ReqParamColl.Parameters , obj.OperCondColl.SelDesignOperCond , synthParameters{:} );
                        requirementParams = evalExpressions( obj , obj.ReqParamColl.Parameters , obj.OperCondColl.SelDesignOperCond , [] );
                        
                        % Evaluate Gain Expressions
                        gainParam = evalExpressions( obj , obj.GainColl.Gains , obj.OperCondColl.SelDesignOperCond , [requirementParams,synthParameters{:}] ); 

                        % Create an array of Gain Objects
                        scatGain  = ScatteredGain.Gain(gainParam);
                        
                        % Create the Scattered Gain Collection Object 
                        scattGainObj = ScatteredGain.GainCollection( 'OperatingCondition', obj.OperCondColl.SelDesignOperCond ,...
                                                                     'Gains' , scatGain ,...
                                                                     'SynthesisDesignParameter' , synthParameters{:} ,...
                                                                     'RequirementDesignParameter' , requirementParams ,...
                                                                     'Filters', obj.FilterParamColl.Filters,...
                                                                     'OperCondFilterSettings', obj.OperCondColl.FilterSettings);  

                        %--------------------------------------------------
                        %    Update Gains for display
                        %--------------------------------------------------
                        for i = 1:length(scattGainObj.Gain)
                           gainParamsNew(i) = UserInterface.ControlDesign.Parameter('Name',scattGainObj.Gain(i).Name,'String',scattGainObj.Gain(i).Value);  %#ok<AGROW>
                        end
                        % Update the GainCollection table
                        setGains( obj.GainColl , gainParamsNew );
                        drawnow();pause(0.1);

                        % Notify user of the gains and values 
                        for i = 1:length(gainParamsNew)
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gain:',gainParamsNew(i).Name,' :: ',num2str(gainParamsNew(i).Value),'.'],'info'));
                        end
                    end
                   obj.CurrentScatteredGainColl = scattGainObj; 
                   
                case 2 % Gain comes from a Scattered Gain File
                    
                    % Notify user that scattered gain source is being used
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Scattered"','info'));
                    
                    % Get the selected scattered gain source
                    scattGainObj = getSelectedScatteredGainObjs(obj.Tree);     
                    if isempty(scattGainObj)   
                        error('User:ScatteredGainObjectMissing','The Scattered Gain Object is missing or corupt');
                    end
                    
                    scattGainObjArray = scattGainObj.ScatteredGainCollection;

                    if length(obj.OperCondColl.SelDesignOperCond) > 1
                        logArray = false(1,length(scattGainObjArray));
                        selOperCond = obj.OperCondColl.SelDesignOperCond;
                        for i = 1:length(selOperCond)
                            logArray = logArray | [scattGainObjArray.DesignOperatingCondition] == selOperCond(i);
                        end
                    else
                        logArray = [scattGainObjArray.DesignOperatingCondition] == obj.OperCondColl.SelDesignOperCond;
                    end

                    if ~any(logArray)
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gains do not exist for the selected design model.','warn'));
                        scattGainObj = ScatteredGain.GainCollection.empty;   
                    else
                        scattGainObj = scattGainObjArray(logArray);
                    end

                    obj.CurrentScatteredGainColl = scattGainObj; 
                   
                case 3 % Gain comes from a Scheduled Gain Table
                    %%%% Warn user of missing feature %%%%%%%%%%%
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('This feature is currently under construction.  Contact ACD for further information."','warn'));
                    return;
                    
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Scheduled"','info'));
                    gainNode     = getSelectedSourceGainObjs(obj.Tree);
                    gainSrcObj   = gainNode.handle.UserData;
                    for i = 1:length(gainSrcObj.Gain)
                        ind = i; 
                        BreakPoints1Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints1NameExpression; %BreakPoints1Path = gainSrcObj.Gain(i).BreakPoints1Path;
                        if ~isempty(strfind(BreakPoints1Path,'DesignOperatingCondition'))
                            BreakPoints1Path = strrep(BreakPoints1Path,'(ind).DesignOperatingCondition','');
                        end
                        BP1 = eval(['arrayfun(@(scatteredGains) ',BreakPoints1Path,',obj.OperCondColl.SelAnalysisOperCond);']);

                        BreakPoints2Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints2Expression; %BreakPoints2Path = gainSrcObj.Gain(i).BreakPoints2Path;
                        if ~isempty(strfind(BreakPoints2Path,'DesignOperatingCondition'))
                            BreakPoints2Path = strrep(BreakPoints2Path,'(ind).DesignOperatingCondition','');
                        end
                        BP2 = eval(['arrayfun(@(scatteredGains) ',BreakPoints2Path,',obj.OperCondColl.SelAnalysisOperCond);']);

                        % Below replicates a lookup block
                        for j = 1:length(BP1)
                            GainValue(j) = getGain( gainSrcObj.Gain(i) , BP1(j) , BP2(j) );
                            GainArray{j}(i) = ScatteredGain.Gain(gainSrcObj.Gain(i).ScatteredGainName,GainValue(j)); %GainArray{j}(i) = ScatteredGain.Gain(gainSrcObj.Gain(i).ScatteredGainName{:},GainValue(j));                  
                        end
                    end   
                    for k = 1:length(GainArray)
                        scattGainObj(k) = ScatteredGain.GainCollection( 'Gain',GainArray{k} , 'OperatingCondition', obj.OperCondColl.SelDesignOperCond );
                    end    
                    obj.CurrentScatteredGainColl = scattGainObj;

            end 
            
            if rlSel %&& ~isempty(obj.CurrentScatteredGainColl)
                runRootLocusObjs( obj );
            end
                       
            
        end % setCurrentScatteredGainObj
        
        function scatGainCollObj = getCurrentScatteredGainObj( obj , reqParamColl , filterParamColl ,selDesignOperCond , synthObjs , synthesisParamColl )
            import UserInterface.ControlDesign.Utilities.*

            % Determine source of gain
            [ selGainSource , rlSel ] = getGainSource( obj.Tree );            

            if length(selGainSource) > 1
                error('ControlDesign:GainSource','Only one gain source may be selected.');
            end
            switch selGainSource
                case 0 % No Gain Sourec Selected - Using user defined paramaters and gains defined in the gain window.

                    %--------------------------------------------------
                    %    Create the Scattered Gains Object
                    %--------------------------------------------------  
                    % Evaluate Requirement Parameters to send to Requirement models
                    % Get globals
                    requirementParams = evalExpressions( obj , [reqParamColl.Parameters;filterParamColl.Filters.getFilterParameterValues'] , selDesignOperCond , [] );

                    % Evaluate Gain Expressions
        % %                     gainParam = evalExpressions( obj , obj.GainColl.Gains , obj.OperCondColl.SelDesignOperCond , requirementParams ); 
        % % 
        % %                     % Create an array of Gain Objects
        % %                     scatGain  = ScatteredGain.Gain(gainParam);
                    if isempty(obj.CurrentScatteredGainColl)
                        scatGain  = ScatteredGain.Gain.empty;
                        selDesignOperCond = lacm.OperatingCondition.empty;
                        %notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Selected design operating condition will not be used.','warn'));
                    else
                        scatGain  = obj.CurrentScatteredGainColl.Gain;
                    end
                    % Create the Scattered Gain Collection Object 
                    scatGainCollObj = ScatteredGain.GainCollection( 'OperatingCondition', selDesignOperCond ,...
                                                                 'Gains' , scatGain ,...
                                                                 'SynthesisDesignParameter' , ScatteredGain.Parameter.empty ,...
                                                                 'RequirementDesignParameter' , requirementParams ,...
                                                                 'Filters', filterParamColl.Filters,...
                                                                 'OperCondFilterSettings', obj.OperCondColl.FilterSettings);   

                case 1 % Gain is determined from synthesis model

                    % Get all the selected synthesis objs from the tree

                    if isempty(synthObjs)   
                        error('User:SynthesisObjectMissing','The Synthesis Object is missing or corrupt');
                    end

                    % Notify user of selected gain source
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Synthesis"','info'));
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Synthesis Object...','info'));

                    % Design model must be selected - if not then error
                    if isempty(selDesignOperCond)
                        error('User:DesignModelMissing','Design Model not selected');
                    end

                    % Evaluate the sythesis parameters, filter parameters,
                    % and selected operating condition together to
                    % determine the numeric value of each.
                    synthParameters = cell(1,length(selDesignOperCond));
                    for i = 1:length(selDesignOperCond)
                        synthParameters{i} = evalExpressions( obj , [synthesisParamColl.Parameters ; filterParamColl.Filters.getFilterParameterValues'] ,...
                            selDesignOperCond(i) , [] );
                    end

                    % RUN SYNTHESIS
                    [gainCellStruct,mdlParams,mdlNames] = run( synthObjs , selDesignOperCond , synthParameters );

                    % Display the parameters that were assigned to the
                    % synthesis model in the Status Window.
                    if obj.Debug
                        for j = 1:length(mdlParams)
                            fnames = fieldnames(mdlParams{j});
                            for i = 1:length(fnames)
                                if ~isstruct(mdlParams{j}.(fnames{i}))
                                    if ~isstruct(mdlParams{j}.(fnames{i}))
                                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Assigning :',fnames{i},' :: ',mat2str(mdlParams{j}.(fnames{i})),' in model ',mdlNames{j},'.'],'info'));
                                    else
                                        debug('structures');
                                    end
                                else
                                    fnames2 = fieldnames(mdlParams{j}.(fnames{i}));
                                    try
                                        for m = 1:length(fnames2)
                                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Assigning :',fnames{i},'.',fnames2{m},' :: ',mat2str(mdlParams{j}.(fnames{i}).(fnames2{m})),' in model ',mdlNames{j},'.'],'info'));
                                        end
                                    catch
                                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to display structure parameters.','error'));
                                    end
                                    %debug('structures');
                                end
                            end
                        end
                    end

                    % Create the Scattered Gains Object
                    if isempty(gainCellStruct) 
                        % no gains were assigned in the synthesis method
                        scatGainCollObj = ScatteredGain.GainCollection.empty;
                    else
                        gainStruct = gainCellStruct{:};
                        for i = 1:length(gainStruct)
                           gainParamsFromSynthesis(i) = UserInterface.ControlDesign.Parameter('Name',gainStruct(i).Name,'String',gainStruct(i).Value);  %#ok<AGROW>
                        end
                        % Update the GainCollection table
                        setGains( obj.GainColl , gainParamsFromSynthesis );

                        %--------------------------------------------------
                        %    Create the Scattered Gains Object
                        %--------------------------------------------------  
                        % Evaluate Requirement Parameters to send to Requirement models
                        % Get globals
                        %requirementParams = evalExpressions( obj , obj.ReqParamColl.Parameters , obj.OperCondColl.SelDesignOperCond , synthParameters{:} );
                        requirementParams = evalExpressions( obj , reqParamColl.Parameters , selDesignOperCond , [] );

                        % Evaluate Gain Expressions
                        gainParam = evalExpressions( obj , obj.GainColl.Gains , selDesignOperCond , [requirementParams,synthParameters{:}] ); 

                        % Create an array of Gain Objects
                        scatGain  = ScatteredGain.Gain(gainParam);

                        % Create the Scattered Gain Collection Object 
                        scatGainCollObj = ScatteredGain.GainCollection( 'OperatingCondition', selDesignOperCond ,...
                                                                     'Gains' , scatGain ,...
                                                                     'SynthesisDesignParameter' , synthParameters{:} ,...
                                                                     'RequirementDesignParameter' , requirementParams ,...
                                                                     'Filters', filterParamColl.Filters,...
                                                                     'OperCondFilterSettings', obj.OperCondColl.FilterSettings);  

                        %--------------------------------------------------
                        %    Update Gains for display
                        %--------------------------------------------------
                        for i = 1:length(scatGainCollObj.Gain)
                           gainParamsNew(i) = UserInterface.ControlDesign.Parameter('Name',scatGainCollObj.Gain(i).Name,'String',scatGainCollObj.Gain(i).Value);  %#ok<AGROW>
                        end
                        % Update the GainCollection table
                        setGains( obj.GainColl , gainParamsNew );
                        drawnow();pause(0.1);

                        % Notify user of the gains and values 
                        if obj.Debug
                            for i = 1:length(gainParamsNew)
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Gain:',gainParamsNew(i).Name,' :: ',num2str(gainParamsNew(i).Value),'.'],'info'));
                            end
                        end
                    end

                case 2 % Gain comes from a Scattered Gain File

                    % Notify user that scattered gain source is being used
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Scattered"','info'));

                    % Get the selected scattered gain source
                    scattGainObj = getSelectedScatteredGainObjs(obj.Tree);     
                    if isempty(scattGainObj)   
                        error('User:ScatteredGainObjectMissing','The Scattered Gain Object is missing or corupt');
                    end

                    scattGainObjArray = scattGainObj.ScatteredGainCollection;

                    if length(selDesignOperCond) > 1
                        logArray = false(1,length(scattGainObjArray));
                        for i = 1:length(selDesignOperCond)
                            logArray = logArray | [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond(i);
                        end
                    else
                        logArray = [scattGainObjArray.DesignOperatingCondition] == selDesignOperCond;
                    end

                    if ~any(logArray)
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gains do not exist for the selected design model.','error'));
%                         scatGainCollObj = ScatteredGain.GainCollection.empty;   
                        error('User:DesignModelMissing','Select a design Condition that has a gain defined.');
                    else
                        scatGainCollObj = scattGainObjArray(logArray);
                    end

                case 3 % Gain comes from a Scheduled Gain Table
                    %%%% Warn user of missing feature %%%%%%%%%%%
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('This feature is currently under construction.  Contact ACD for further information."','warn'));
                    return;

                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is "Scheduled"','info'));
                    gainNode   = getSelectedSourceGainObjs(obj.Tree);
                    gainSrcObj = gainNode.handle.UserData;
                    for i = 1:length(gainSrcObj.Gain)
                        ind = i; 
                        BreakPoints1Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints1NameExpression; %BreakPoints1Path = gainSrcObj.Gain(i).BreakPoints1Path;
                        if ~isempty(strfind(BreakPoints1Path,'DesignOperatingCondition'))
                            BreakPoints1Path = strrep(BreakPoints1Path,'(ind).DesignOperatingCondition','');
                        end
                        BP1 = eval(['arrayfun(@(scatteredGains) ',BreakPoints1Path,',obj.OperCondColl.SelAnalysisOperCond);']);

                        BreakPoints2Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints2Expression; %BreakPoints2Path = gainSrcObj.Gain(i).BreakPoints2Path;
                        if ~isempty(strfind(BreakPoints2Path,'DesignOperatingCondition'))
                            BreakPoints2Path = strrep(BreakPoints2Path,'(ind).DesignOperatingCondition','');
                        end
                        BP2 = eval(['arrayfun(@(scatteredGains) ',BreakPoints2Path,',obj.OperCondColl.SelAnalysisOperCond);']);

                        % Below replicates a lookup block
                        for j = 1:length(BP1)
                            GainValue(j) = getGain( gainSrcObj.Gain(i) , BP1(j) , BP2(j) );
                            GainArray{j}(i) = ScatteredGain.Gain(gainSrcObj.Gain(i).ScatteredGainName,GainValue(j)); %GainArray{j}(i) = ScatteredGain.Gain(gainSrcObj.Gain(i).ScatteredGainName{:},GainValue(j));                  
                        end
                    end   
                    for k = 1:length(GainArray)
                        scattGainObj(k) = ScatteredGain.GainCollection( 'Gain',GainArray{k} , 'OperatingCondition', obj.OperCondColl.SelDesignOperCond );
                    end    
                    scatGainCollObj = scattGainObj;

            end 

            if rlSel %&& ~isempty(obj.CurrentScatteredGainColl)
                runRootLocusObjs( obj, scatGainCollObj);
            end


        end % getCurrentScatteredGainObj    

        function runRootLocusObjs( obj, scatGainCollObj )
            rtLObjs = getSelectedRLocusObjs( obj.Tree );
            if ~isempty(rtLObjs) 
                % Design model must be selected - if not then error
                if isempty(obj.OperCondColl.SelDesignOperCond)
                    error('User:DesignModelMissing','Design Model not selected');
                end
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Root Locus Objects...','info'));
                %--------------------------------------------------------------
                if nargin == 2
                    run( rtLObjs ,obj.RTLocusAxisColl.AxisHandleQueue , scatGainCollObj );
                else
                    run( rtLObjs ,obj.RTLocusAxisColl.AxisHandleQueue , obj.CurrentScatteredGainColl );
                end
                addlistener(rtLObjs,'GainChanged',@obj.rootLocusGainUpdated);
                for i = 0:obj.RTLocusAxisColl.AxisHandleQueue.size-1
                    set(obj.RTLocusAxisColl.AxisHandleQueue.get(i),'ButtonDownFcn',@obj.buttonClickInAxis);
                end
            else  
                error('User:SynthesisObjectMissing','The Root Locus Object is missing or corrupt');
            end
        end % runRootLocusObjs
        
        function rootLocusGainUpdated( obj , hobj , eventdata )
            selGain = obj.CurrentScatteredGainColl.Gain.get(eventdata.Object.Name);
            selGain.Value = eventdata.Object.Value;
            
            for i = 1:length(obj.CurrentScatteredGainColl.Gain)
               gainParamsNew(i) = UserInterface.ControlDesign.Parameter('Name',obj.CurrentScatteredGainColl.Gain(i).Name,'String',obj.CurrentScatteredGainColl.Gain(i).Value);  %#ok<AGROW>
            end
            % Update the GainCollection table
            setGains( obj.GainColl , gainParamsNew );
                            
        end % rootLocusGainUpdated
                           
        function run( obj , ~ , ~ )

            
            % Test for license
            checkKey( obj );
          
            setWaitPtr(obj);

            notify(obj,'ClearLogMessageMain');

            %--------------------------------------------------
            %    Get all default model Parameters
            %--------------------------------------------------
            defaultParams = getAllParmsReqModels(obj);

            updateDefaultParameters( obj.ReqParamColl , defaultParams );
            
            defaultParams = getAllParmsSynModels( obj );
            
            updateDefaultParameters( obj.SynthesisParamColl , defaultParams );

            % Reset RL Plots
            for i = 0:obj.RTLocusAxisColl.AxisHandleQueue.size-1
                cla(obj.RTLocusAxisColl.AxisHandleQueue.get(i),'reset');
                set(obj.RTLocusAxisColl.AxisHandleQueue.get(i),'Visible','off');
            end


            obj.CurrentScatteredGainColl = getCurrentScatteredGainObj( obj , obj.ReqParamColl , obj.FilterParamColl , obj.OperCondColl.SelDesignOperCond , ...
                getSelectedSynthesisObjs(obj.Tree) , obj.SynthesisParamColl);

            obj.OperCondColl.LastSelectedDesignCond    = [obj.OperCondColl.FilteredOperConds.SelectedforDesign];
            obj.OperCondColl.LastSelectedAnaylysisCond = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];

            if isempty(obj.CurrentScatteredGainColl)
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Gain source is internal to model','info'));
            end
            
            resetAllPlots( obj );
            runRequirementSelected( obj , obj.OperCondColl.SelAnalysisOperCond , obj.CurrentScatteredGainColl );

            releaseWaitPtr(obj);

        end % run
        
        function runBatch( obj , ~ , ~ , customBatchObjs)
            
            if nargin == 3
                batchObj = obj.BatchRunCollection.RunObjects;
                batchObj = batchObj([batchObj.Selected]);
            elseif nargin == 4
                batchObj = customBatchObjs;
            end
            % Test for license
            checkKey( obj );
          
            setWaitPtr(obj);

            for i = 1:length( batchObj)             
                disp(batchObj(i).Title);
                % Reset RL Plots
                for j = 0:obj.RTLocusAxisColl.AxisHandleQueue.size-1
                    cla(obj.RTLocusAxisColl.AxisHandleQueue.get(j),'reset');
                    set(obj.RTLocusAxisColl.AxisHandleQueue.get(j),'Visible','off');
                end
                resetAllPlots( obj );
                 
                %--------------------------------------------------------------
                %             Scattered Gain Collection Object
                %--------------------------------------------------------------
                currentScatteredGainColl = batchObj(i).ScatteredGainObj;

                %--------------------------------------------------------------
                %                    Stability
                %--------------------------------------------------------------
                if ~isempty(batchObj(i).StabReqObj)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Stability Requirements...','info'));
                    %--------------------------------------------------------------
                    runRequirement( obj , batchObj(i).StabReqObj , obj.StabAxisColl.AxisHandleQueue , batchObj(i).AnalysisOperCond , currentScatteredGainColl );
                end
                
                %--------------------------------------------------------------
                %                    Frequency Response
                %--------------------------------------------------------------
                if ~isempty(batchObj(i).FreqReqObj)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Frequency Response Requirements...','info'));
                    %--------------------------------------------------------------
                    runRequirement( obj , batchObj(i).FreqReqObj , obj.FreqRespAxisColl.AxisHandleQueue , batchObj(i).AnalysisOperCond , currentScatteredGainColl );
                end
                
                %--------------------------------------------------------------
                %                    Simulation
                %--------------------------------------------------------------
                if ~isempty(batchObj(i).SimReqObj)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Simulation Requirements...','info'));
                    runRequirement( obj , batchObj(i).SimReqObj , [] , batchObj(i).AnalysisOperCond , currentScatteredGainColl );  
                    % Update SimViewer Data
                    for j = 1:length(batchObj(i).SimReqObj)
                        updateNewData(obj.SimViewerColl(j), batchObj(i).SimReqObj(j).SimulationData.Output, false , 1, batchObj(i).AnalysisOperCondDisplayText, {batchObj(i).AnalysisOperCond.Color});   
                        batchObj(i).SimReqObj(j).SimViewerProject = obj.SimViewerColl(j).getSavedProject;
                    end   
                end
                
                %--------------------------------------------------------------
                %                    HQ
                %--------------------------------------------------------------
                if ~isempty(batchObj(i).HQReqObj)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Handling Qualities Requirements...','info'));
                    %--------------------------------------------------------------
                    runRequirement( obj , batchObj(i).HQReqObj , obj.HQAxisColl.AxisHandleQueue , batchObj(i).AnalysisOperCond , currentScatteredGainColl );
                end
                
                %--------------------------------------------------------------
                %                    ASE
                %--------------------------------------------------------------
                if ~isempty(batchObj(i).ASEReqObj)
                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running ASE Requirements...','info'));
                    %--------------------------------------------------------------
                    runRequirement( obj , batchObj(i).ASEReqObj , obj.ASEAxisColl.AxisHandleQueue , batchObj(i).AnalysisOperCond , currentScatteredGainColl ); 
                end
                
                
            end
            
            releaseWaitPtr(obj);

        end % runBatch  
        
        function runRequirementSelected( obj , analysisOperCond , scattGainCollObj )
            % Get the selected Requirement objects from the tree
            %--------------------------------------------------------------
            %                    Stability
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
            if ~isempty(reqObjs)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Stability Requirements...','info'));
                %--------------------------------------------------------------
                runRequirement( obj , reqObjs , obj.StabAxisColl.AxisHandleQueue , analysisOperCond , scattGainCollObj );
            end
            %--------------------------------------------------------------
            %                    FrequencyResponse
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'FreqNode');
            if ~isempty(reqObjs)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Frequency Response Requirements...','info'));
                %--------------------------------------------------------------
                runRequirement( obj , reqObjs , obj.FreqRespAxisColl.AxisHandleQueue , analysisOperCond , scattGainCollObj );
            end
            %--------------------------------------------------------------
            %                    Simulation
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'SimNode');
            y = reqObjisSelected(obj.Tree, 'SimNode');
            if ~isempty(reqObjs)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Simulation Requirements...','info'));
                %--------------------------------------------------------------
                runRequirement( obj , reqObjs , [] , analysisOperCond , scattGainCollObj );   
                % Update SimViewer Data
                simViewInd = find(y);
                for i = 1:length(reqObjs)
                    selAnalysis = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];
                    allFilterColors = {obj.OperCondColl.FilteredOperConds.Color};
                    
                    if any(selAnalysis)
                        updateNewData(obj.SimViewerColl(simViewInd(i)) ,reqObjs(i).SimulationData.Output , false , 1, obj.OperCondColl.SelectedDisplayData(selAnalysis,2),allFilterColors(selAnalysis));   
                    end
                    selAnalysis = [obj.OperCondColl.FilteredOperConds.SelectedforAnalysis];
                    reqObjs(i).AnalysisOperCondDisplayText = obj.OperCondColl.SelectedDisplayData(selAnalysis,2);
                    reqObjs(i).AnalysisOperCond = copy(obj.OperCondColl.SelAnalysisOperCond);
                    
                    reorderTabs(obj, reqObjs)

                    % Save the manual project
                    reqObjs(i).SimViewerProject = obj.SimViewerColl(simViewInd(i)).getSavedProject;
                end
            end    
            %--------------------------------------------------------------
            %                    HandlingQualities
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'HQNode');
            if ~isempty(reqObjs)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running Handling Qualities Requirements...','info'));
                %--------------------------------------------------------------
                runRequirement( obj , reqObjs , obj.HQAxisColl.AxisHandleQueue , analysisOperCond , scattGainCollObj );
            end
            %--------------------------------------------------------------
            %                    Aeroservoelasticity
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'ASENode');
            if ~isempty(reqObjs)
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Running ASE Requirements...','info'));
                %--------------------------------------------------------------
                runRequirement( obj , reqObjs , obj.ASEAxisColl.AxisHandleQueue , analysisOperCond , scattGainCollObj ); 
            end
        end % runRequirementSelected  
        
        function reorderTabs(obj, reqObjs)
            tabGroup = obj.SimViewerTabPanel;
            allTabs = tabGroup.Children;
        
            % Convert titles to strings (if needed)
            desiredTitles = string({reqObjs.Title});
        
            % Build a map from tab title to tab object
            tabMap = containers.Map();
            for i = 1:numel(allTabs)
                tabMap(allTabs(i).Title) = allTabs(i);
            end
        
            % Reorder the tabs to match desiredTitles
            newOrder = gobjects(1, numel(desiredTitles)); % preallocate
            for i = 1:numel(desiredTitles)
                title = desiredTitles{i};
                if isKey(tabMap, title)
                    newOrder(i) = tabMap(title);
                else
                    error('Tab titled "%s" not found.', title);
                end
            end
        
            % Reassign in the desired order
            tabGroup.Children = newOrder;
        end

        function runRequirementEvent( obj , ~ , eventdata )
            % Get the selected Requirement objects from the tree
            reqObjs = eventdata.Object;
            runRequirement( obj , reqObjs , obj.OperCondColl , obj.CurrentScatteredGainColl );
            
        end %runRequirementEvent 
        
        function mdlBaseParams = getDefaultParmsReqModels( obj ) 
            % Get the selected Requirement objects from the tree
            mdlBaseParams = struct('Name',{},'Value',{});
            %--------------------------------------------------------------
            %                    Stability
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'StabilityReqNode');
            uniqueMdlNames = getUniqueModels ( reqObjs );
            for j = 1:length(uniqueMdlNames)
                load_system(uniqueMdlNames{j});
                wrkspace = get_param(uniqueMdlNames{j},'modelworkspace');
                if ~strcmp(wrkspace.DataSource,'Model File')
                    wrkspace.reload;
                end
                wrkspaceParams = wrkspace.whos;
                for k = 1:length(wrkspaceParams)
                   mdlBaseParams( end + 1 ).Name  = wrkspaceParams(k).name;  %#ok<AGROW>
                   mdlBaseParams(   end   ).Value = getVariable(wrkspace,wrkspaceParams(k).name);  
                end
            end
            %--------------------------------------------------------------
            %                    FrequencyResponse
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'FreqNode');
            uniqueMdlNames = getUniqueModels ( reqObjs );
            for j = 1:length(uniqueMdlNames)
                load_system(uniqueMdlNames{j});
                wrkspace = get_param(uniqueMdlNames{j},'modelworkspace');
                if ~strcmp(wrkspace.DataSource,'Model File')
                    wrkspace.reload;
                end
                wrkspaceParams = wrkspace.whos;
                for k = 1:length(wrkspaceParams)
                   mdlBaseParams( end + 1 ).Name  = wrkspaceParams(k).name;  %#ok<AGROW>
                   mdlBaseParams(   end   ).Value = getVariable(wrkspace,wrkspaceParams(k).name);  
                end
            end

            %--------------------------------------------------------------
            %                    Simulation
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'SimNode');
            uniqueMdlNames = getUniqueModels ( reqObjs );
            for j = 1:length(uniqueMdlNames)
                load_system(uniqueMdlNames{j});
                wrkspace = get_param(uniqueMdlNames{j},'modelworkspace');
                if ~strcmp(wrkspace.DataSource,'Model File')
                    wrkspace.reload;
                end
                wrkspaceParams = wrkspace.whos;
                for k = 1:length(wrkspaceParams)
                   mdlBaseParams( end + 1 ).Name  = wrkspaceParams(k).name;  %#ok<AGROW>
                   mdlBaseParams(   end   ).Value = getVariable(wrkspace,wrkspaceParams(k).name);  
                end
            end
  
            %--------------------------------------------------------------
            %                    HandlingQualities
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'HQNode');
            uniqueMdlNames = getUniqueModels ( reqObjs );
            for j = 1:length(uniqueMdlNames)
                load_system(uniqueMdlNames{j});
                wrkspace = get_param(uniqueMdlNames{j},'modelworkspace');
                if ~strcmp(wrkspace.DataSource,'Model File')
                    wrkspace.reload;
                end
                wrkspaceParams = wrkspace.whos;
                for k = 1:length(wrkspaceParams)
                   mdlBaseParams( end + 1 ).Name  = wrkspaceParams(k).name;  %#ok<AGROW>
                   mdlBaseParams(   end   ).Value = getVariable(wrkspace,wrkspaceParams(k).name);  
                end
            end

            %--------------------------------------------------------------
            %                    Aeroservoelasticity
            %--------------------------------------------------------------
            reqObjs = getSelectedReqObjs( obj.Tree , 'ASENode');
            uniqueMdlNames = getUniqueModels ( reqObjs );
            for j = 1:length(uniqueMdlNames)
                load_system(uniqueMdlNames{j});
                wrkspace = get_param(uniqueMdlNames{j},'modelworkspace');
                if ~strcmp(wrkspace.DataSource,'Model File')
                    wrkspace.reload;
                end
                wrkspaceParams = wrkspace.whos;
                for k = 1:length(wrkspaceParams)
                   mdlBaseParams( end + 1 ).Name  = wrkspaceParams(k).name;  %#ok<AGROW>
                   mdlBaseParams(   end   ).Value = getVariable(wrkspace,wrkspaceParams(k).name);  
                end
            end

        end % getDefaultParmsReqModels
        
        function parameters = getAllParmsReqModels( obj )
            import Utilities.*            
            
            parameters = UserInterface.ControlDesign.Parameter.empty;
            mdlNames = {};
            reqObjsS = getAllReqObjs( obj.Tree , 'StabilityReqNode');
            mdlNames = rowcat( mdlNames , getUniqueModels ( reqObjsS ));
            reqObjsF = getAllReqObjs( obj.Tree , 'FreqNode');
            mdlNames = rowcat( mdlNames , getUniqueModels ( reqObjsF ));
            reqObjsSI = getAllReqObjs( obj.Tree , 'SimNode');
            mdlNames = rowcat( mdlNames , getUniqueModels ( reqObjsSI ));
            reqObjsH = getAllReqObjs( obj.Tree , 'HQNode');
            mdlNames = rowcat( mdlNames , getUniqueModels ( reqObjsH ));
            reqObjsA = getAllReqObjs( obj.Tree , 'ASENode');
            mdlNames = rowcat( mdlNames , getUniqueModels ( reqObjsA ));
            
            if isempty(mdlNames)
                return;
            end
            
            parameters = getParametersFromModel( mdlNames );
            
        end % getAllParmsReqModels
                
        function parameters = getAllParmsSynModels( obj )
            import Utilities.*            
            
            parameters = UserInterface.ControlDesign.Parameter.empty;
            mdlNames = {};
            synObjs = getAllSynthesisObjs( obj.Tree );
            mdlNames = rowcat( mdlNames , getUniqueModels ( synObjs ));
            rlObjs = getAllRLocusObjs( obj.Tree );
            mdlNames = rowcat( mdlNames , getUniqueModels ( rlObjs ));
            
            if isempty(mdlNames)
                return;
            end
            
            parameters = getParametersFromModel( mdlNames );
            
        end % getAllParmsSynModels        
    
        function reinitParams( obj , hobj , ~ )
            
                choice = questdlg('Choose to Re-Initialize "All" of the parameters or only the "Selected" Parameter?', ...
                    'ReInitialize Parameters...', ...
                    'All','Selected','Cancel','Cancel');
                drawnow();pause(0.5);

                switch choice
                    case 'All'

                        setWaitPtr(obj);     
                        if strcmp(hobj.Title,'Synthesis')
                            isSYN = true;
                            selParam = obj.SynthesisParamColl.AvaliableParameterSelection;
                        elseif strcmp(hobj.Title,'Requirement')   
                            isSYN = false;
                            selParam = obj.ReqParamColl.AvaliableParameterSelection;
                        else
                            releaseWaitPtr(obj);
                            return;
                        end
                        
                        if isempty(selParam)
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('No parameters exist.','info'));
                                releaseWaitPtr(obj);
                                return;
                        elseif(all([selParam.UserDefined])) 
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('All Parameters are User Defined and cannot be re-initialized.','info'));
                            releaseWaitPtr(obj);
                            return;
                        end
                        
                        defaultParamsSYN = getAllParmsSynModels( obj );
                        defaultParamsREQ = getAllParmsReqModels(obj);
                            
                        for i = 1:length(selParam)  
                            if(selParam(i).UserDefined)
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam(i).Name,' - Parameter is User Defined and cannot be re-initialized.'],'info'));
                            elseif(selParam(i).Global)
                                defaultParams = [defaultParamsSYN, defaultParamsREQ];
                                updateSelectedParameter2DefaultGlobal( obj.SynthesisParamColl , defaultParams, copy(selParam(i)));
                                updateSelectedParameter2DefaultGlobal( obj.ReqParamColl , defaultParams, copy(selParam(i)));

                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam(i).Name,' - Global Parameter has been re-initialized.'],'info'));
                            else
                                if isSYN
                                    updateSelectedParameter2DefaultGlobal( obj.SynthesisParamColl , defaultParamsSYN, copy(selParam(i))); 
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam(i).Name,' - Synthesis Parameter has been re-initialized.'],'info'));
                                else
                                    updateSelectedParameter2DefaultGlobal( obj.ReqParamColl , defaultParamsREQ, copy(selParam(i)));
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam(i).Name,' - Requirement Parameter has been re-initialized.'],'info'));
                                end   
                            end
                        end
                        updateSelectedTable(obj.SynthesisParamColl);
                        updateSelectedTable(obj.ReqParamColl);
                        
                        releaseWaitPtr(obj);
                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('All Parameters have been re-initialized.','info'));



                        
                    case 'Selected'
                        setWaitPtr(obj);     
                        if strcmp(hobj.Title,'Synthesis')
                            selParam = obj.SynthesisParamColl.CurrentSelectedParamter;
                            isSYN = true;
                        elseif strcmp(hobj.Title,'Requirement')     
                            selParam = obj.ReqParamColl.CurrentSelectedParamter;
                            isSYN = false;
                        else
                            releaseWaitPtr(obj);
                            return;
                        end
                        
                        if isempty(selParam)
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('No parameter is selected.','info'));
                                releaseWaitPtr(obj);
                                return;
                        elseif(selParam.UserDefined) 
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam.Name,' - Parameter is User Defined and cannot be re-initialized.'],'info'));
                        elseif(selParam.Global)
                            defaultParamsSYN = getAllParmsSynModels( obj );
                            defaultParamsREQ = getAllParmsReqModels(obj);
                            defaultParams = [defaultParamsSYN, defaultParamsREQ];
                            
                            updateSelectedParameter2DefaultGlobal( obj.SynthesisParamColl , defaultParams, copy(selParam));
                            updateSelectedTable(obj.SynthesisParamColl);
                            
                            updateSelectedParameter2DefaultGlobal( obj.ReqParamColl , defaultParams, copy(selParam));
                            updateSelectedTable(obj.ReqParamColl);
                            
                            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam.Name,' - Parameter has been re-initialized.'],'info'));
                        else
                            if isSYN
                                defaultParams = getAllParmsSynModels( obj );
                                updateSelectedParameter2DefaultGlobal( obj.SynthesisParamColl , defaultParams, copy(selParam)); 
                                updateSelectedTable(obj.SynthesisParamColl);
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam.Name,' - Synthesis Parameter has been re-initialized.'],'info'));
                            else
                                defaultParams = getAllParmsReqModels(obj);
                                updateSelectedParameter2DefaultGlobal( obj.ReqParamColl , defaultParams, copy(selParam));
                                updateSelectedTable(obj.ReqParamColl);
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData([selParam.Name,' - Requirement Parameter has been re-initialized.'],'info'));
                            end   
                        end
                        obj.SynthesisParamColl.CurrentSelectedParamter = UserInterface.ControlDesign.Parameter.empty;
                        obj.ReqParamColl.CurrentSelectedParamter = UserInterface.ControlDesign.Parameter.empty;
                        releaseWaitPtr(obj);
                    otherwise
                        % Do nothing
                end
          


        end % reinitParams
    end
    
    %% Methods - Run Private
    methods (Access = private) 
        
        function showDesignOperCondSelected( obj , operCond )
            
            
        end % showDesignOperCondSelected
                   
        function runRequirement( obj , reqArray , axHQueue , selAnalysisOperCond , currentScattGainColl )   
            
            [mdlParams,mdlNames] = run( reqArray , axHQueue , selAnalysisOperCond , currentScattGainColl ); 

            if obj.Debug
                for j = 1:length(mdlParams)
                    fnames = fieldnames(mdlParams{j});
                    for i = 1:length(fnames)
    %                     if isscalar(mdlParams{j}.(fnames{i}))
                            %--------------------------------------------------------------
                            %    Display Log Message
                            %--------------------------------------------------------------
                            if ~isstruct(mdlParams{j}.(fnames{i}))
                                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Assigning :',fnames{i},' :: ',mat2str(mdlParams{j}.(fnames{i})),' in model ',mdlNames{j},'.'],'info'));
                            %end
                            %--------------------------------------------------------------  
                            else
                                fnames2 = fieldnames(mdlParams{j}.(fnames{i}));
                                try
                                    for m = 1:length(fnames2)
                                        notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Assigning :',fnames{i},'.',fnames2{m},' :: ',mat2str(mdlParams{j}.(fnames{i}).(fnames2{m})),' in model ',mdlNames{j},'.'],'info'));
                                    end
                                catch
                                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Unable to display structure parameters.','error'));
                                end
                                    
                                    %debug('structures');
                            end
    %                     end
    %--------------------------------------------------------------  
                    end
                end
            end
                
            if isa(axHQueue,'UserInterface.AxisPanelCollection')
                axHQueue = axHQueue.AxisHandleQueue;
            end
            
            if isa(axHQueue,'java.util.LinkedList')
                for i = 0:axHQueue.size-1
                    set(axHQueue.get(i),'ButtonDownFcn',@obj.buttonClickInAxis);
                end
            end
            
        end %runRequirement
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ ) 
            obj.SelectionPanel.SelectedPanel = obj.CurrSelToolRibbion;
            obj.LargeCardPanel.SelectedPanel = obj.CurrSelToolRibbion;
%             set(obj.SelectPageText,'String',obj.ToolRibbionSelectedText);

%             gainSource = 1;
%             switch obj.Tree.GainSource
%                 case 1
%                     %set(obj.SynthesisParamColl,'Visible',1);
%                     %set(obj.ReqParamColl,'Visible',1);
%                     set(obj.GainColl,'Visible',1);  
%                 case 2
%                     %set(obj.SynthesisParamColl,'Visible',0);
%                     %set(obj.ReqParamColl,'Visible',1);
%                     set(obj.GainColl,'Visible',0);
%                 case 3
%                     %set(obj.SynthesisParamColl,'Visible',0);
%                     %set(obj.ReqParamColl,'Visible',1);
%                     set(obj.GainColl,'Visible',0);
%                 case 4
%                     %set(obj.SynthesisParamColl,'Visible',1);
%                     %set(obj.ReqParamColl,'Visible',1);
%                     set(obj.GainColl,'Visible',0);
%                 otherwise
%             end  
            
            

%             updateCurrentSelectedParameter( obj.ReqParamColl , num2str(obj.SliderValue) );
        end % update
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            cpObj.Tree = copy(obj.Tree);
        end
        
    end
    
    %% Methods - Private
    methods (Access = private) 

  
    end
    
    %% Methods - Resize
    methods %(Access = protected) 

        function reSize( obj , ~ , ~ )
       
            % Call super class method
            reSize@UserInterface.Level1Container(obj,[],[]);
            
            positionMain = getpixelposition(obj.MainPanel);
            
            parentPosition = getpixelposition(obj.Parent);          
            set(obj.RibbonCardPanel,'Units','Pixels',...
                'Position',[ 860 , parentPosition(4) - 93 , parentPosition(3) - 860 , 93 ]);
            
            set(obj.BrowserPanel,'Units','Pixels',...
                'Position',[ 1 , (positionMain(4))/2 , 330 , ((positionMain(4))/2) - 18 ]);

            set(obj.SelectionPanel,'Units','Pixels',...
                'Position',[ 1 , 1 , 330 , (positionMain(4))/2 ]);

            set(obj.LargeCardPanel,'Units','Pixels',...
                'Position',[ 332 , 1 , positionMain(3) - 332 , positionMain(4) ]); 
% %             set(obj.BrowserPanel,'Units','Pixels',...
% %                 'Position',[ 1 , (positionMain(4)- 100)/2 + 100 , 330 , ((positionMain(4)- 100)/2) - 18 ]);
% % 
% %             set(obj.SelectionPanel,'Units','Pixels',...
% %                 'Position',[ 1 , 100 , 330 , (positionMain(4)- 100)/2 ]);
% % 
% %             set(obj.LargeCardPanel,'Units','Pixels',...
% %                 'Position',[ 332 , 100 , positionMain(3) - 332 , positionMain(4) - 100 ]);
            
%             set(obj.LogPanel,'Units','Pixels',...
%                 'Position',[ 1 , 1 , positionMain(3) , 100]); %'Position',[ 1 , 1 , positionMain(3) , 100]); 

            obj.ProjectLabelCont.Units = 'Pixels';
            obj.ProjectLabelCont.Position = [ 1 , positionMain(4) - 18 , 330 , 16 ];

        end % reSize
        
        function reSizeDesignPanel( obj , ~ , ~ )
            
            parentPos = getpixelposition(obj.LargeCardPanel.Panel(1));
            desParamW = 287;%181.5;
            set(obj.DesignParameterPanel,'Units','Pixels','Position',[1 , 1 , desParamW , parentPos(4)]);
            set(obj.DesignTabPanel,'Units','Pixels','Position',[desParamW + 1 , 1 , parentPos(3) - desParamW , parentPos(4)]);
             
            paramPanel = getpixelposition(obj.DesignParameterPanel);
            height = paramPanel(4)/2;
            obj.ParameterLabelCont.Units = 'Pixels';
            obj.ParameterLabelCont.Position = [ 1 , paramPanel(4) - 17 , paramPanel(3) - 5 , 16 ];
            obj.ParamTabPanel.Units = 'Pixels';
            obj.ParamTabPanel.Position = [ 1 , height  , paramPanel(3) , paramPanel(4) - height * 1 - 18];
            
            tabPanel = getpixelposition(obj.ParamTabPanel);
            try
            set(obj.SynthesisParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);  
            set(obj.ReqParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]); 
            end
            try
            set(obj.BatchSynthesisParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);  
            set(obj.BatchReqParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]); 
            end
            
            set(obj.GainColl,'Units','Pixels','Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]); 
            try set(obj.ScatteredGainColl,'Units','Pixels','Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]);end
                
        end % reSizeDesignPanel
              
    end
    
    %% Methods - Static
    methods ( Static )

%         function obj = loadobj(s)
%             obj = s;
%             
%             figH = FLIGHTcontrol();
%         end % loadobj
        
    end
    
    %% Methods - Figure Callbacks
    methods
        
        function closeFigure_CB( obj , hobj , eventdata )
            
            closeFigure_CB@UserInterface.Level1Container( obj , hobj , eventdata );
            
            try             
                status = logout(obj.Granola);
                if ~status
                    throw(obj.Granola.LastError); % Terminate Program
                end
            end 
             % restore the original state of all warnings
            for i = 1:length(obj.WarningMsg)
                 warning(obj.WarningMsg(i));
            end
   
            % Remove the path
            if ~isempty(obj.ProjectMatlabPath)
                rmpath(obj.ProjectMatlabPath);
            end
            
            % Notify user that the tool is closing
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Closing...','info'));
            pause(0.01);
            %--------------------------------------------------------------
            setWaitPtr(obj);
            drawnow();
            
%             delete(obj.Granola);
%             delete(obj.SelectionPanel);
%             delete(obj.LargeCardPanel);
%             delete(obj.StabAxisColl);
%             delete(obj.FreqRespAxisColl);
%             delete(obj.HQAxisColl);
%             delete(obj.ASEAxisColl);
%             delete(obj.SimViewerColl);
%             delete(obj.RTLocusAxisColl);
%             %delete(obj.CreateReqPanel);
% %             deleteUserData(obj.Tree);
%             delete(obj.Tree);
%             delete(obj.OperCondColl);
%             delete(obj.SynthesisParamColl);
%             delete(obj.ReqParamColl);
%             delete(obj.GainColl);
%             delete(obj.GainSchPanel);
%             delete(obj.GainFilterPanel);
%             
%             delete(obj.MainCardPanel);
%             
%             %deleteUserData(obj.Tree);
%             releaseWaitPtr(obj);
            
            % Delete Figure
            delete(obj.Figure);

%             notify(obj,'ExitApplication');
            

        end % closeFigure_CB
        
    end
    
    %% Methods - Delete
    methods
        function delete( obj )
            
            
%         % Temp Disabled
%          obj.SliderPanel   
            
        % Java Components 
        obj.ToolRibbionTab = [];
        obj.ProjectPanel = [];
        obj.NewJButton = [];
        obj.OpenJButton = [];
        obj.LoadJButton = [];
%         obj.RunSelJButton = [];
        obj.SaveJButton = [];
        obj.ExportJButton = [];
        obj.PlotJButton = [];
        obj.JRibbonPanel = [];
        obj.JRPHComp = [];
        obj.ProjectLabelComp = [];
        obj.ParameterLabelComp = [];
        
        % close parameter windows if they are open
        if ~isempty(obj.SynthesisParamColl.Frame) && isvalid(obj.SynthesisParamColl.Frame)
            delete(obj.SynthesisParamColl.Frame);
        end
        if ~isempty(obj.ReqParamColl.Frame) && isvalid(obj.ReqParamColl.Frame)
            delete(obj.ReqParamColl.Frame);
        end
        
        % Javawrappers
        % Check if container is already being deleted
        if ishandle(obj.JRPHCont) && strcmp(get(obj.JRPHCont, 'BeingDeleted'), 'off')
            delete(obj.JRPHCont)
        end
        if ishandle(obj.ProjectLabelCont) && strcmp(get(obj.ProjectLabelCont, 'BeingDeleted'), 'off')
            delete(obj.ProjectLabelCont)
        end
        if ishandle(obj.ParameterLabelCont) && strcmp(get(obj.ParameterLabelCont, 'BeingDeleted'), 'off')
            delete(obj.ParameterLabelCont)
        end       
        

        
        % User Defined Objects
        try %#ok<*TRYNC>             
            delete(obj.GainSchPanel);
        end
        try %#ok<*TRYNC>
            delete(obj.SynthesisParamColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.SelectionPanel);
        end
        try %#ok<*TRYNC>             
            delete(obj.LargeCardPanel);
        end
        try %#ok<*TRYNC>             
            delete(obj.StabAxisColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.FreqRespAxisColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.HQAxisColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.ASEAxisColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.SimViewerColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.RTLocusAxisColl);
        end
%         try %#ok<*TRYNC>             
%             delete(obj.SliderObj);
%         end
        try %#ok<*TRYNC>             
            delete(obj.SelectedParameter);
        end
        try %#ok<*TRYNC>             
            delete(obj.Tree);
        end
        try %#ok<*TRYNC>             
            delete(obj.OperCondColl);
        end
%         try %#ok<*TRYNC>             
%             delete(obj.SynthesisParamColl);
%         end
        try %#ok<*TRYNC>             
            delete(obj.ReqParamColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.GainColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.FilterParamColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.GainFilterPanel);
        end
        try %#ok<*TRYNC>             
            delete(obj.ScatteredGainColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.CurrentScatteredGainColl);
        end
        try %#ok<*TRYNC>             
            delete(obj.SelectedScatteredGainFileObj);
        end

        delete@UserInterface.Level1Container(obj);




     
%          % Matlab Components
%         obj.BrowserPanel
%         obj.TabPanel
%         obj.StabilityTab
%         obj.FreqRespTab
%         obj.SimulationTab
%         obj.HQTab
%         obj.ASETab
%         obj.RTLocusTab 
%         obj.DesignParameterPanel
%         obj.DesignTabPanel
%         obj.ParamTabPanel
%         obj.SynTab
%         obj.ReqTab
%         obj.FilterTab
            
        
%         % Data
%         obj.TreeSavedData
%         obj.NumberOfPlotPerPageStab
%         obj.NumberOfPlotPerPageFR
%         obj.NumberOfPlotPerPageHQ
%         obj.NumberOfPlotPerPageASE
%         obj.NumberOfPlotPerPageRTL
%         obj.ShowOnlyScalar
%         obj.SelectedParamTab 
%         obj.CurrSelToolRibbion
%         obj.ToolRibbionSelectedText
        

        end % delete
    end
        
end


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

function saveFigH = undockFigures( axH )
    saveFigH = [];   
    for i = 1:length(axH)%axHQ.size 
        %axH = handle(axHQ.get(i-1));
        visible = axH(i).Visible;
        if strcmp('on',visible)
            saveFigH(end + 1) = figure( ...
                    'Name', axH(i).Title.String, ...
                    'NumberTitle', 'off',...
                    'Visible','off'); %#ok<AGROW>
            set(saveFigH(end),'CreateFcn','set(gcf,''Visible'',''on'')');

            leg = axH(i).UserData;
            newAxH = copyobj([axH(i),leg],saveFigH(end));
            newAxH(1).Units = 'Normal';
            newAxH(1).OuterPosition = [ 0 , 0 , 1 , 1 ];  
        end
    end 
    
%     if ~isempty(saveFigH)
%         savefig(saveFigH,filename);
%     end  
%     delete(saveFigH);
end % undockFigures

function y = printFigure2File( axH )

    y = struct('Filename',{},'Title',{});
    figH = [];   
    for i = 1:length(axH)%axHQ.size 
        %axH = handle(axHQ.get(i-1));
        visible = axH(i).Visible;
        if strcmp('on',visible)
            figH = figure( ...
                    'Name', axH(i).Title.String, ...
                    'NumberTitle', 'off',...
                    'Visible','off');
%             set(gcf,'Visible','on');
            %set(saveFigH(end),'CreateFcn','set(gcf,''Visible'',''on'')');
            % first undock the axis into a new figure
            leg = axH(i).UserData;
            newAxH = copyobj([axH(i),leg],figH);
            drawnow();pause(0.5);
            newAxH(1).Units = 'Normal';
            newAxH(1).OuterPosition = [ 0 , 0 , 1 , 1 ];  
            drawnow();pause(0.5);
            set(get(newAxH(1),'Title'),'String',''); % Remove title
            add2Height = -50;
            add2Width = -50;
            set(figH ,'PaperPositionMode','auto');
            pos = getpixelposition(figH);
            set(figH ,'Units','Pixels'); 
            set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
            set(figH ,'PaperPositionMode','auto');
            set(figH ,'PaperUnits','inches ','PaperPosition',[0 0 5.17 3.75] );
%             set(figH ,'PaperUnits','inches ','PaperPosition',[0 0 5.31 3.85] );
%             set(figH ,'PaperUnits','inches ','PaperPosition',[.25 2.5 8 6] );
%             set(figH ,'PaperUnits','inches ','PaperSize',[11,8.5]);
%             set(figH ,'PaperOrientation','portrait');
            filelocation = [tempname,'.png'];
            print(figH ,'-dpng',filelocation,'-r300');
            y(end + 1).Filename = filelocation; 
            y(end).Title =get(get(axH(i),'Title'),'String'); 
            delete(figH);

        end
    end 

end % printFigure2File

function y = printSimFigure2File( reqObjs )
   
    y = struct('Filename',{},'Title',{}); 
    for i = 1:length(reqObjs)%axHQ.size 
        numPerFig = 4;
        nSubPlots = length(reqObjs(i).PlotData);
        nFig = floor(nSubPlots/numPerFig);
        nRem = rem(nSubPlots,numPerFig);%rem(nFig,4);%
        if nRem>0
                        
            ind = 0;
            for j = 1:nFig
                if j<nFig
                    y1 = createSimFig( reqObjs(i).Title , reqObjs(i).PlotData( ind + 1 : ind + numPerFig ));
                    y = [y,y1];
                    ind = ind + numPerFig;
                else
                    y1 = createSimFig( reqObjs(i).Title , reqObjs(i).PlotData( ind + 1 : ind + nRem ));
                    y = [y,y1];
                    ind = ind + numPerFig;       
                end
            end
                    
        else
            ind = 0;
            for j = 1:nFig
                y1 = createSimFig( reqObjs(i).Title , reqObjs(i).PlotData( ind + 1 : ind + numPerFig ));
                y = [y,y1];
                ind = ind + numPerFig;
            end
        end
        
        
        

    end 

end % printSimFigure2File

function y = printBatchFigure2File( reqObjs )
   
    y = struct('Filename',{},'Title',{}); 
    for i = 1:length(reqObjs)%axHQ.size 
        figH = figure( ...
        'Name', reqObjs(i).Title, ...
                'NumberTitle', 'off',...
                'Visible','off');        
        axH = axes(figH);
        plot(reqObjs(i),axH);
        set(get(axH,'Title'),'String',''); % Remove title
        
        add2Height = -50;
        add2Width = -50;
        set(figH ,'PaperPositionMode','auto');
        pos = getpixelposition(figH);
        set(figH ,'Units','Pixels'); 
        set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
        set(figH ,'PaperPositionMode','auto');
        set(figH ,'PaperUnits','inches ','PaperPosition',[0 0 5.17 3.75] );
%         set(figH ,'PaperUnits','inches ','PaperPosition',[.25 2.5 8 6] );
%         set(figH ,'PaperUnits','inches ','PaperSize',[11,8.5]);
%         set(figH ,'PaperOrientation','portrait');
        filelocation = [tempname,'.png'];
        print(figH ,'-dpng',filelocation,'-r300');
        y(end + 1).Filename = filelocation; 
        y(end).Title = reqObjs(i).Title; 
        delete(figH);
    end 

end % printBatchFigure2File

function saveFigH = undockSimulationFigures( axHColl )
    saveFigH = [];   
    
    for i = 1:length(axHColl.Panel)
        
        for j = 1:length(axHColl.Panel(i).Axis) % Requirement Loop
            axH(j) = handle(axHColl.Panel(i).Axis(j)); %#ok<AGROW>
        end
        
        visible = axH(1).Visible;
        if strcmp('on',visible)
            
            saveFigH(end + 1) = figure( ...
                    'Name', axHColl.Panel(i).Title, ...
                    'NumberTitle', 'off',...
                    'Visible','off'); %#ok<AGROW>
            set(saveFigH(end),'CreateFcn','set(gcf,''Visible'',''on'')');

            for k = 1:length(axH)%axHQ.size 
                leg = axH(k).UserData;
                newAxH = copyobj([axH(k),leg],saveFigH(end));
                newAxH.Units = 'Normal';
                newPosition = newAxH.OuterPosition;
                newAxH.OuterPosition = [ 0 , newPosition(2) , 1 , newPosition(4) ]; 
            end 
    
        end
    end
%     if ~isempty(saveFigH)
%         savefig(saveFigH,filename);
%     end  
%     delete(saveFigH);
end % undockSimulationFigures

function charAnswer = getSectionName()
    answer = inputdlg('Section name for current run:',...
        'Section Name',...
        [1 50],...
        {''});
    drawnow();pause(0.5);
    if isempty(answer)
        charAnswer = 'Section';
    elseif iscell(answer) && isempty(answer{:})
        charAnswer = 'Section';
    else
        charAnswer = answer{:};
    end 
end % getSectionName

function y = createSimFig( title , plotData )
    y = struct('Filename',{},'Title',{}); 
    figH = figure( ...
        'Name', title, ...
        'NumberTitle', 'off',...
        'Visible','off');
    bottom = 0;
    height = 1/length(plotData);
    for k = length(plotData):-1:1%1:length(plotData)

        axH(k) = axes(figH); %#ok<*AGROW,*LAXES>
        axH(k).Units = 'Normal';
        axH(k).OuterPosition = [ 0 , bottom , 1 , height ];
        grid(axH(k),'on');
        plot(plotData(k),axH(k) , false);
        set(get(axH(k),'Title'),'String',plotData(k).Title,'interpreter','none'); 
        bottom = bottom + height;
    end
    switch length(plotData)
        case 1
            add2Height = 0;
            add2Width = 0;
        case 2
            add2Height = 100;
            add2Width = 0;
        case 3
            add2Height = 200;
            add2Width = 0;
        case 4
            add2Height = 300;
            add2Width = 0;
        otherwise
    end
    set(get(axH(end),'XLabel'),'String','Time');

    set(figH ,'PaperPositionMode','auto');
    pos = getpixelposition(figH);
    set(figH ,'Units','Pixels');

    set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
    filelocation = [tempname,'.png'];
    print(figH ,'-dpng',filelocation,'-r300');
    y(end + 1).Filename = filelocation;
    y(end).Title = title;
    delete(figH);

end % createSimFig

function z = round2(x)

y = 1e-10;
z = round(x/y)*y;
z = round(z,5,'significant');
end % round2
