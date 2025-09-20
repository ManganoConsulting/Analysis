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
        RunSelMenuButton
        SaveJButton
        ExportJButton
        PlotJButton
        JRibbonPanel
        JRPHComp
        JRPHCont
        RibbonAnchors = struct()
        RibbonState = struct()
        RibbonDropdowns = struct()
        ActiveRibbonDropdown = ''
        RibbonDropdownOriginalFigureFcn = struct('Stored',false,'Value',[])
        StabAxisColl UserInterface.AxisPanelCollection
        FreqRespAxisColl UserInterface.AxisPanelCollection
        HQAxisColl UserInterface.AxisPanelCollection
        ASEAxisColl UserInterface.AxisPanelCollection
        SimViewerColl% UserInterface.AxisPanelCollection
        RTLocusAxisColl UserInterface.AxisPanelCollection
         ProjectLabel
         ParameterLabel
        ParamTabPanel
        SynTab
        ReqTab
        FilterTab
        
        Tree
        
        OperCondTabPanel
        OperCondTab
        BatchTab
        SimViewerTabPanel
        SimViewerTab
        SimviewerRibbonCardPanel
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

            obj.SimviewerRibbonCardPanel = UserInterface.CardPanel(0,'Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ 860 , parentPosition(4) - 93 , parentPosition(3) - 860 , 93 ]);
            obj.SimviewerRibbonCardPanel.Visible = 'off';

            obj.ProjectLabel = uilabel('Parent', obj.MainPanel, ...
                'Text', 'Project', ...
                'FontName', 'Courier New', ...
                'FontColor', [1 1 1], ...
                'BackgroundColor', [55/255,96/255,146/255], ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom', ...
                'Position', [1, positionMain(4) - 18, 330, 16]);

            
            obj.BrowserPanel = uipanel('Parent',obj.MainPanel,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 1 , (positionMain(4))/2  , 330 , ((positionMain(4))/2) - 18]);

            if isprop(obj.BrowserPanel,'SizeChangedFcn')
                obj.BrowserPanel.SizeChangedFcn = @obj.updateControlTreeLayout;
            end
            if isprop(obj.BrowserPanel,'Padding')
                obj.BrowserPanel.Padding = [0 0 0 0];
            end
            
            
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
                obj.updateControlTreeLayout();
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
                addlistener(obj.Tree,'AddAxisHandle2Q',@obj.addAxisHandle2Q_CB);
                addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.Tree,'ReqObjUpdated',@obj.autoSaveFile);
                addlistener(obj.Tree,'SetPointer',@obj.setPointer);
                
                obj.Tree.SelectedScatteredGainFileObj = obj.SelectedScatteredGainFileObj;
                
                
                %----------------------------------------------------------
                %          Oper/Batch Panel
                %----------------------------------------------------------    
                obj.OperCondTabPanel = uitabgroup( ...
                    'Parent',obj.SelectionPanel.Panel(1), ...
                    'Units','normalized', ...
                    'Position',[0 0 1 1], ...
                    'TabLocation','Bottom', ...
                    'SelectionChangedFcn',@obj.manualBatchTabCallback);
                
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
                % Set pixel positions
                parentPos = getpixelposition(obj.LargeCardPanel.Panel(1));
                desParamW = 287;

                set(obj.LargeCardPanel.Panel(1),'resizeFcn',@obj.reSizeDesignPanel);
                obj.DesignParameterPanel = uipanel('Parent',obj.LargeCardPanel.Panel(1),'BorderType','none',...
                    'Units','Pixels','Position',[1 , 1 , desParamW , parentPos(4)]);
                    paramPanel = getpixelposition(obj.DesignParameterPanel);
                    height = paramPanel(4)/2;
                    obj.ParameterLabel = uilabel(obj.DesignParameterPanel,...
                        'Position',[ 1 , paramPanel(4) - 17 , paramPanel(3) - 5 , 16 ],...
                        'Text',' Parameters',...
                        'FontColor',[1 1 1],...
                        'BackgroundColor',[55 96 146]/255,...
                        'FontName','Courier New',...
                        'HorizontalAlignment','left');
                        obj.ParamTabPanel = uitabgroup('Parent',obj.DesignParameterPanel,'SelectionChangedFcn',@obj.updateSelectParamTab,...
                            'Units','Pixels','Position',[ 1 , height  , paramPanel(3) , paramPanel(4) - height * 1 - 18]); 
                            obj.SynTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.SynTab.Title = 'Synthesis';

                            obj.ReqTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.ReqTab.Title = 'Requirement';
                            
                            obj.FilterTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.FilterTab.Title = 'Filters';
                    
                        tabPanel = getpixelposition(obj.ParamTabPanel);
                %----------------------------------------------------------
                %          Synthesis - Requirements - Filter Parameters
                %----------------------------------------------------------
                createParameterTabs(obj);
                set(obj.SynthesisParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);  
                set(obj.ReqParamColl,'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);

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
                set(obj.GainColl,'Units','Pixels','Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]); 
                addlistener(obj.GainColl,'ShowLogMessage',@obj.showLogMessage_CB); 
                addlistener(obj.GainColl,'EnlargeGainCollection',@obj.showExpandedGains); 
                
                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                createDesignPanel(obj, [desParamW + 1 , 1 , parentPos(3) - desParamW , parentPos(4)]);
                                
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
                obj.updateControlTreeLayout();
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
                addlistener(obj.Tree,'AddAxisHandle2Q',@obj.addAxisHandle2Q_CB);
                addlistener(obj.Tree,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.Tree,'SetPointer',@obj.setPointer);
                
                %----------------------------------------------------------
                %          Oper/Batch
                %----------------------------------------------------------    
                obj.OperCondTabPanel = uitabgroup( ...
                    'Parent',obj.SelectionPanel.Panel(1), ...
                    'Units','normalized', ...
                    'Position',[0 0 1 1], ...
                    'TabLocation','Bottom', ...
                    'SelectionChangedFcn',@obj.manualBatchTabCallback);
                
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
                % Set pixel positions
                parentPos = getpixelposition(obj.LargeCardPanel.Panel(1));
                desParamW = 287;

                set(obj.LargeCardPanel.Panel(1),'resizeFcn',@obj.reSizeDesignPanel);
                obj.DesignParameterPanel = uipanel('Parent',obj.LargeCardPanel.Panel(1),'BorderType','none',...
                    'Units','Pixels','Position',[1 , 1 , desParamW , parentPos(4)]);
                    paramPanel = getpixelposition(obj.DesignParameterPanel);
                    height = paramPanel(4)/2;

                    obj.ParameterLabel = uilabel(obj.DesignParameterPanel,...
                        'Position',[ 1 , paramPanel(4) - 17 , paramPanel(3) - 5 , 16 ],...
                        'Text',' Parameters',...
                        'FontColor',[1 1 1],...
                        'BackgroundColor',[55 96 146]/255,...
                        'FontName','Courier New',...
                        'HorizontalAlignment','left');
                        obj.ParamTabPanel = uitabgroup('Parent',obj.DesignParameterPanel,'SelectionChangedFcn',@obj.updateSelectParamTab,...
                            'Units','Pixels','Position',[ 1 , height  , paramPanel(3) , paramPanel(4) - height * 1 - 18]); 
                            obj.SynTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.SynTab.Title = 'Synthesis';

                            obj.ReqTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.ReqTab.Title = 'Requirement';
                            
                            obj.FilterTab  = uitab('Parent',obj.ParamTabPanel);
                            obj.FilterTab.Title = 'Filters';
                        tabPanel = getpixelposition(obj.ParamTabPanel);
                %----------------------------------------------------------
                %          Synthesis - Requirements - Filter Parameters
                %----------------------------------------------------------
                
                obj.SynthesisParamColl = UserInterface.ControlDesign.ParameterCollection('Parent',obj.SynTab,'Title','Synthesis',...
                    'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);
                obj.ReqParamColl       = UserInterface.ControlDesign.ParameterCollection('Parent',obj.ReqTab,'Title','Requirement',...
                    'Units','Pixels','Position',[ 1 , 1  , tabPanel(3) , tabPanel(4)]);
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
                
                obj.GainColl = UserInterface.ControlDesign.GainCollection('Parent',obj.DesignParameterPanel,'Title','Gain',...
                    'Units','Pixels','Position',[ 1 , 1  , paramPanel(3) , paramPanel(4) - height * 1 ]);
                addlistener(obj.GainColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.GainColl,'EnlargeGainCollection',@obj.showExpandedGains); 
                
                %----------------------------------------------------------
                %          Design Panel
                %----------------------------------------------------------
                createDesignPanel(obj, [desParamW + 1 , 1 , parentPos(3) - desParamW , parentPos(4)]);
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
                addlistener(obj.GainSchPanel,'SchGainFileSelected'       ,@obj.schGainFileSelected );
                addlistener(obj.GainSchPanel,'ScatteredGainFileSelected',@obj.scatteredGainFileSelected );
                addlistener(obj.GainSchPanel,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.GainSchPanel,'AutoSaveFile',@obj.autoSaveFile);
  
            end            
            update(obj);
            
            addlistener(obj,'LoadedProjectName','PostSet',@obj.setFileTitle);
            addlistener(obj,'ProjectSaved','PostSet',@obj.setFileTitle); 
            
            reSize( obj , [] , [] );
            drawnow();
            reSizeDesignPanel( obj , [] , [] );
            drawnow();
            % Force user to either create a project or open a project
            if obj.StartUpFlag
                % Launch StartUp Screen
            end

        end % createView
        
        function createDesignPanel(obj,designTabPos)
            

            
            obj.DesignTabPanel = uipanel('Parent',obj.LargeCardPanel.Panel(1),'BorderType','none',...
                'Units','Pixels','Position',designTabPos);
                obj.TabPanel = uitabgroup('Parent',obj.DesignTabPanel,...
                    'Units','normalized','Position',[0 0 1 1],...
                    'SelectionChangedFcn',@obj.designPanelTabChanged);

                
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
        end % createDesignPanel
  
        function createParameterTabs(obj)

            obj.SynthesisParamColl.createView(obj.SynTab);
            
            obj.ReqParamColl.createView(obj.ReqTab);

            obj.FilterParamColl.createView(obj.FilterTab)

        end % createParameterTabs
                                    
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

                obj.BatchReqParamColl.createView(obj.ReqTab);
                obj.BatchReqParamColl.Enable = false;
                addlistener(obj.BatchReqParamColl,'ShowLogMessage',@obj.showLogMessage_CB);
                addlistener(obj.BatchReqParamColl,'GlobalIdentified',@obj.globalVariableIndentInReq);
                addlistener(obj.BatchReqParamColl, 'EditButtonPressed',@obj.editPressInReq);
                
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
                                                'AnalysisOperCondDisplayText',obj.OperCondColl.SelectedDisplayData(selAnalysis,2),...
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

            if nargin < 3 || isempty(eventdata)
                return;
            end

            if isempty(obj.SimviewerRibbonCardPanel) || ~isvalid(obj.SimviewerRibbonCardPanel)
                return;
            end

            if eventdata.NewValue == obj.SimulationTab && ~isempty(obj.SimviewerRibbonCardPanel.Panel)
                obj.SimviewerRibbonCardPanel.Visible = 'on';
            else
                obj.SimviewerRibbonCardPanel.Visible = 'off';
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
        end % scatteredGainFileExported
        
        function scatteredGainFileCleared( obj , ~ , eventdata )
            
            % Remove scatter Gain file object
            setScattGainFileComboBox( obj.GainSchPanel , [obj.Tree.GainsScattered.Children.UserData] );
            
            % Add new scattered Gain Object



        end % scatteredGainFileCleared
        
        function schGainFileSelected( obj , ~ , eventdata )
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

                if ~isempty(obj.TabPanel) && isvalid(obj.TabPanel) && obj.TabPanel.SelectedTab == obj.SimulationTab
                    obj.SimviewerRibbonCardPanel.Visible = 'on';
                end

                % Add and Update all data in simviewer
                obj.SimViewerColl(end).loadProject( simObjs(i).SimViewerProject );
            end
                        
        end % createSimViewers       
        
    end 
    
    %% Methods - ToolRibbon Button Callbacks
    methods (Access = protected) 
        
        function fileNew_CB( obj , ~ , ~)
      
        end % fileNew_CB     

        function fileLoad_CB( obj , anchor , ~)
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.LoadJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});

            menuItems(end+1) = struct( ...
                'Id','load-operating-condition', ...
                'Label','Operating Condition', ...
                'Icon','Layout_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuAddOperCond([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-source-synthesis', ...
                'Label','Source Gain - Synthesis', ...
                'Icon','gearsFull_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuAddSynthesis([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-source-scattered', ...
                'Label','Source Gain - Scattered', ...
                'Icon','gearsFull_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuScattGain([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-source-scheduled', ...
                'Label','Source Gain - Scheduled', ...
                'Icon','gearsFull_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuSchGain([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-req-stability', ...
                'Label','Requirement - Stability', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuStabReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-req-frequency', ...
                'Label','Requirement - Frequency Response', ...
                'Icon','workIcon_24_Red.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuFRReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-req-simulation', ...
                'Label','Requirement - Simulation', ...
                'Icon','workIcon_24_Yellow.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuSimReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-req-hq', ...
                'Label','Requirement - Handling Qualities', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuHQReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-req-ase', ...
                'Label','Requirement - Aeroservoelastic', ...
                'Icon','workIcon_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuASEReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','load-project', ...
                'Label','Project - Load Project', ...
                'Icon','LoadProject_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.loadWorkspace_CB([],[]));

            obj.showRibbonDropdown('load', anchor, menuItems);
        end % fileLoad_CB
  
        
    end
    
    %% Methods - ToolRibbon Callbacks
    methods (Access = protected) 
        
        function settingsButton_CB( obj , anchor , ~ )
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.PlotJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});
            plotCounts = [1 2 4];
            checkMark = @(condition) repmat(char(10003),1,condition);

            allSame = obj.NumberOfPlotPerPageStab == obj.NumberOfPlotPerPageFR && ...
                obj.NumberOfPlotPerPageStab == obj.NumberOfPlotPerPageHQ && ...
                obj.NumberOfPlotPerPageStab == obj.NumberOfPlotPerPageASE;
            for value = plotCounts
                menuItems(end+1) = struct( ...
                    'Id',sprintf('settings-all-%d',value), ...
                    'Label',sprintf('Plots Per Page - All (%d)',value), ...
                    'Icon','Figure_16.png', ...
                    'Shortcut',checkMark(allSame && obj.NumberOfPlotPerPageStab == value), ...
                    'Callback',@()obj.setNumPlotsAll([],[],value));
            end

            menuItems = [menuItems, createPlotMenu('Stability','stab', ...
                obj.NumberOfPlotPerPageStab,@obj.setNumPlotsStab)];
            menuItems = [menuItems, createPlotMenu('Frequency Response','fr', ...
                obj.NumberOfPlotPerPageFR,@obj.setNumPlotsFR)];
            menuItems = [menuItems, createPlotMenu('Handling Qualities','hq', ...
                obj.NumberOfPlotPerPageHQ,@obj.setNumPlotsHQ)];
            menuItems = [menuItems, createPlotMenu('ASE','ase', ...
                obj.NumberOfPlotPerPageASE,@obj.setNumPlotsASE)];

            verboseState = 'Off';
            if obj.Debug
                verboseState = 'On';
            end
            menuItems(end+1) = struct( ...
                'Id','settings-verbose', ...
                'Label','Verbose Mode', ...
                'Icon','Settings_16.png', ...
                'Shortcut',verboseState, ...
                'Callback',@()obj.setVerboseMode([],[]));

            obj.showRibbonDropdown('settings', anchor, menuItems);

            function items = createPlotMenu(label, prefix, currentValue, callbackFcn)
                items = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});
                for value = plotCounts
                    items(end+1) = struct( ...
                        'Id',sprintf('settings-%s-%d',prefix,value), ...
                        'Label',sprintf('%s Plots Per Page - %d',label,value), ...
                        'Icon','Figure_16.png', ...
                        'Shortcut',checkMark(currentValue == value), ...
                        'Callback',@()callbackFcn([],[],value));
                end
            end
        end % settingsButton_CB

        function toolRibButtonPanelSel_CB( obj , ~ , ~ , currSel , selText )
            if currSel == 6
                FilterDesign.main();
                return;
            end

            runEnabled = currSel ~= 4;
            enableState = 'off';
            if runEnabled
                enableState = 'on';
            end
            if ~isempty(obj.RunSelJButton) && isvalid(obj.RunSelJButton)
                obj.RunSelJButton.Enable = enableState;
            end
            if ~isempty(obj.RunSelMenuButton) && isvalid(obj.RunSelMenuButton)
                obj.RunSelMenuButton.Enable = enableState;
            end
            obj.CurrSelToolRibbion = currSel;
            obj.ToolRibbionSelectedText = selText;
            obj.updateRibbonState(runEnabled, currSel);
            obj.update;
        end % toolRibButtonPanelSel_CB

        function updateRibbonState(obj, runEnabled, selectionId)
            if nargin < 2 || isempty(runEnabled)
                if isstruct(obj.RibbonState) && isfield(obj.RibbonState,'runEnabled')
                    runEnabled = obj.RibbonState.runEnabled;
                else
                    runEnabled = obj.CurrSelToolRibbion ~= 4;
                end
            end
            if nargin < 3 || isempty(selectionId)
                if isstruct(obj.RibbonState) && isfield(obj.RibbonState,'selectionId')
                    selectionId = obj.RibbonState.selectionId;
                else
                    selectionId = obj.CurrSelToolRibbion;
                end
            end

            stateStruct = struct( ...
                'runEnabled', logical(runEnabled), ...
                'selectionId', selectionId, ...
                'activeView', obj.viewIdToKey(selectionId));
            obj.RibbonState = stateStruct;

            if isempty(obj.JRibbonPanel) || ~isvalid(obj.JRibbonPanel)
                return;
            end

            try
                obj.JRibbonPanel.Data = struct('type','set-state', ...
                    'runEnabled', stateStruct.runEnabled, ...
                    'activeView', stateStruct.activeView);
            catch
                % HTML component may not be ready yet. The stored state will
                % be resent when a "ready" event is received.
            end
        end % updateRibbonState

        function key = viewIdToKey(~, selectionId)
            switch selectionId
                case 1
                    key = 'main';
                case 4
                    key = 'gain';
                case 6
                    key = 'filter';
                otherwise
                    key = '';
            end
        end % viewIdToKey
        
        function viewDesignHistory_CB( ~ , ~ )
            winopen('DesignHistory.csv');
        end % viewDesignHistory_CB

        function saveToolRibbon_CB( obj , anchor , ~ )
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.SaveJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});
            menuItems(end+1) = struct( ...
                'Id','save-project', ...
                'Label','Save Project', ...
                'Icon','Save_Dirty_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.saveWorkspace([],[]));

            obj.showRibbonDropdown('save', anchor, menuItems);
        end % saveToolRibbon_CB
        
        function exportToolRibbon_CB( obj , anchor , ~ )
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.ExportJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});

            menuItems(end+1) = struct( ...
                'Id','export-linear-all', ...
                'Label','Linear Models - All', ...
                'Icon','Export_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuExportLinearModels([],[],'all'));

            menuItems(end+1) = struct( ...
                'Id','export-linear-selected', ...
                'Label','Linear Models - Selected', ...
                'Icon','Export_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuExportLinearModels([],[],'selected'));

            plotTargets = { ...
                'All','All'; ...
                'Stability','Stability'; ...
                'Frequency Response','FrequencyResponse'; ...
                'Simulation','Simulation'; ...
                'Handeling Qualities','HandelingQualities'; ...
                'ASE','ASE'};

            addTargetGroup('export-plots-fig','Plots to MATLAB Figure', ...
                'Export_24.png',@(target)@()obj.exportPlots([],[],target));
            addTargetGroup('export-plots-pdf','Plots to PDF', ...
                'Export_24.png',@(target)@()obj.exportPlotsWord([],[],'PDF',target));
            addTargetGroup('export-plots-word','Plots to Word', ...
                'Export_24.png',@(target)@()obj.exportPlotsWord([],[],'WORD',target));
            addTargetGroup('export-plots-ppt','Plots to PowerPoint', ...
                'Export_24.png',@(target)@()obj.exportPlotsPowerPoint([],[],'PP',target));
            addTargetGroup('export-report-word','Report to Word', ...
                'Export_24.png',@(target)@()obj.exportReport([],[],'WORD',target));
            addTargetGroup('export-report-pdf','Report to PDF', ...
                'Export_24.png',@(target)@()obj.exportReport([],[],'PDF',target));
            addTargetGroup('export-report-html','Report to HTML', ...
                'Export_24.png',@(target)@()obj.exportReport([],[],'HTML',target));

            gainScattObj = getAllScatteredGainObjs(obj.Tree);
            for i = 1:numel(gainScattObj)
                gainName = char(gainScattObj(i).Name);
                menuItems(end+1) = struct( ...
                    'Id',sprintf('export-scattered-%d',i), ...
                    'Label',sprintf('Scattered Gains - %s',gainName), ...
                    'Icon','Variable_24.png', ...
                    'Shortcut','', ...
                    'Callback',@()obj.menuExportScatteredGains([],[],i));
            end

            gainSchObj = getAllScheduledGainObjs(obj.Tree);
            for i = 1:numel(gainSchObj)
                gainName = char(gainSchObj(i).Name);
                menuItems(end+1) = struct( ...
                    'Id',sprintf('export-scheduled-%d',i), ...
                    'Label',sprintf('Scheduled Gains - %s',gainName), ...
                    'Icon','Variable_24.png', ...
                    'Shortcut','', ...
                    'Callback',@()obj.menuExportScheduledGains([],[],i));
            end

            obj.showRibbonDropdown('export', anchor, menuItems);

            function addTargetGroup(prefix,labelPrefix,iconName,callbackFactory)
                for idx = 1:size(plotTargets,1)
                    targetLabel = plotTargets{idx,1};
                    targetKey = matlab.lang.makeValidName(lower(plotTargets{idx,2}),'ReplacementStyle','delete');
                    cb = callbackFactory(plotTargets{idx,2});
                    menuItems(end+1) = struct( ...
                        'Id',sprintf('%s-%s',prefix,targetKey), ...
                        'Label',sprintf('%s - %s',labelPrefix,targetLabel), ...
                        'Icon',iconName, ...
                        'Shortcut','', ...
                        'Callback',cb);
                end
            end
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
        
        function newRequierment_CB( obj , anchor , ~ )
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.NewJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});

            menuItems(end+1) = struct( ...
                'Id','new-synthesis', ...
                'Label','Synthesis', ...
                'Icon','gearsFull_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewSynthesis([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-root-locus', ...
                'Label','Root Locus', ...
                'Icon','workIcon_24_Yellow.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewRTLReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-req-stability', ...
                'Label','Requirement - Stability', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewStabReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-req-frequency', ...
                'Label','Requirement - Frequency Response', ...
                'Icon','workIcon_24_Red.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewFRReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-req-simulation', ...
                'Label','Requirement - Simulation', ...
                'Icon','workIcon_24_Yellow.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewSimReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-req-hq', ...
                'Label','Requirement - Handling Qualities', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewHQReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','new-req-ase', ...
                'Label','Requirement - Aeroservoelastic', ...
                'Icon','workIcon_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuNewASEReq([],[]));

            obj.showRibbonDropdown('new', anchor, menuItems);
        end % newRequierment_CB
        
        function openRequierment_CB( obj , anchor , ~)
            if nargin < 2 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.OpenJButton;
            end

            menuItems = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});

            menuItems(end+1) = struct( ...
                'Id','open-synthesis', ...
                'Label','Synthesis', ...
                'Icon','gearsFull_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenSynthesis([],[]));

            menuItems(end+1) = struct( ...
                'Id','open-req-stability', ...
                'Label','Requirement - Stability', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenStabReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','open-req-frequency', ...
                'Label','Requirement - Frequency Response', ...
                'Icon','workIcon_24_Red.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenFRReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','open-req-simulation', ...
                'Label','Requirement - Simulation', ...
                'Icon','workIcon_24_Yellow.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenSimReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','open-req-hq', ...
                'Label','Requirement - Handling Qualities', ...
                'Icon','workIcon_24_Blue.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenHQReq([],[]));

            menuItems(end+1) = struct( ...
                'Id','open-req-ase', ...
                'Label','Requirement - Aeroservoelastic', ...
                'Icon','workIcon_24.png', ...
                'Shortcut','', ...
                'Callback',@()obj.menuOpenASEReq([],[]));

            obj.showRibbonDropdown('open', anchor, menuItems);
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

                    notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Completed Adding Object - ',addedReqObjs(i).Title],'info'));
                end
            end
            % Save the project
            notify(obj,'SaveProject');
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

            if ~isempty(obj.SimviewerRibbonCardPanel) && isvalid(obj.SimviewerRibbonCardPanel)
                if isempty(obj.SimviewerRibbonCardPanel.Panel)
                    obj.SimviewerRibbonCardPanel.Visible = 'off';
                elseif ~isempty(obj.TabPanel) && isvalid(obj.TabPanel) && obj.TabPanel.SelectedTab == obj.SimulationTab
                    obj.SimviewerRibbonCardPanel.Visible = 'on';
                end
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
  
        function runToolR( obj , anchor , ~ )
            menuItems = [ ...
                struct('Id','run-save','Label','Run and Save','Icon','RunSave_24.png', ...
                    'Shortcut','', 'Callback',@()obj.runAndSaveGains([],[])); ...
                struct('Id','run-only','Label','Run','Icon','Run_24.png', ...
                    'Shortcut','', 'Callback',@()obj.runOnly([],[])); ...
                struct('Id','run-export','Label','Run and Export Word Document','Icon','workspace__24.png', ...
                    'Shortcut','', 'Callback',@()obj.runAndReport([],[])) ...
                ];
            obj.showRibbonDropdown('run', anchor, menuItems);
        end % runToolR

        function stabDropMenu( obj , anchor , ~ )
            menuItems = [ ...
                struct('Id','stab-editor','Label','Stability Editor','Icon','workIcon_24_Blue.png', ...
                    'Shortcut','', 'Callback',@()obj.menuNewStabReq([],[])); ...
                struct('Id','stab-bla','Label','Broken Loop Analysis Editor','Icon','workIcon_24_Blue.png', ...
                    'Shortcut','', 'Callback',@()obj.menuNewBLEditor([],[])) ...
                ];
            obj.showRibbonDropdown('stab', anchor, menuItems);
        end % stabDropMenu

        function frDropMenu( obj , anchor , ~ )
            menuItems = [ ...
                struct('Id','fr-single','Label','Frequency Response Editor - Single','Icon','workIcon_24_Red.png', ...
                    'Shortcut','', 'Callback',@()obj.menuNewFRReq([],[])); ...
                struct('Id','fr-multi','Label','Frequency Response Editor - Multi','Icon','workIcon_24_Red.png', ...
                    'Shortcut','', 'Callback',@()obj.menuNewFREditor([],[])) ...
                ];
            obj.showRibbonDropdown('fr', anchor, menuItems);
        end % frDropMenu

        function showContextMenu(obj, menuHandle, anchor)
            if nargin < 3 || isempty(anchor) || ~isvalid(anchor)
                anchor = obj.Parent;
            end
            try
                show(menuHandle, anchor);
            catch
                anchorPos = getpixelposition(anchor,true);
                try
                    show(menuHandle, obj.Parent,'Position',anchorPos(1:2));
                catch
                    menuHandle.Position = anchorPos(1:2);
                    show(menuHandle);
                end
            end
        end % showContextMenu
    end

    methods (Access = private)

        function showRibbonDropdown(obj, menuId, anchor, items)
            if nargin < 4 || isempty(items)
                return;
            end
            if nargin < 3 || isempty(anchor) || ~isvalid(anchor)
                obj.hideRibbonDropdown(menuId);
                return;
            end

            menuKey = char(menuId);
            if isstruct(obj.RibbonDropdowns) && isfield(obj.RibbonDropdowns, menuKey)
                obj.hideRibbonDropdown(menuKey);
                return;
            end

            obj.closeAllRibbonDropdowns();

            if isempty(obj.Parent) || ~isgraphics(obj.Parent)
                return;
            end

            anchorPos = getpixelposition(anchor,true);
            figPos = getpixelposition(obj.Parent);
            figWidth = figPos(3);
            figHeight = figPos(4);

            labelLengths = 0;
            if isfield(items,'Label')
                labelLengths = cellfun(@(c)numel(char(c)),{items.Label});
            end
            shortcutLengths = 0;
            if isfield(items,'Shortcut')
                shortcutLengths = cellfun(@(c)numel(char(c)),{items.Shortcut});
            end
            approxWidth = 140 + 7*max(labelLengths) + 4*max(shortcutLengths);
            menuWidth = max([approxWidth, anchorPos(3)+24, 200]);

            itemHeight = 32;
            menuHeight = numel(items)*itemHeight + 16;

            dropX = max(0, min(anchorPos(1), figWidth - menuWidth));
            dropY = anchorPos(2) - menuHeight;
            dropY = max(0, min(dropY, figHeight - menuHeight));

            htmlItems = items;
            for idx = 1:numel(htmlItems)
                if ~isfield(htmlItems(idx),'Shortcut') || isempty(htmlItems(idx).Shortcut)
                    htmlItems(idx).Shortcut = '';
                else
                    htmlItems(idx).Shortcut = char(htmlItems(idx).Shortcut);
                end
                htmlItems(idx).Icon = obj.encodeRibbonIcon(htmlItems(idx).Icon);
                if ~isfield(htmlItems(idx),'Id') || isempty(htmlItems(idx).Id)
                    htmlItems(idx).Id = sprintf('item-%d', idx);
                end
            end

            html = obj.buildRibbonDropdownHtml(htmlItems);

            dropdown = uihtml(obj.Parent, ...
                'HTMLSource',html, ...
                'Position',[dropX dropY menuWidth menuHeight]);
            dropdown.DataChangedFcn = @(src,evt)obj.dropdownDataHandler(menuKey, evt.Data);
            dropdown.Tag = sprintf('RibbonDropdown_%s', menuKey);
            try %#ok<TRYNC>
                uistack(dropdown,'top');
            end

            obj.RibbonDropdowns.(menuKey) = struct( ...
                'Component',dropdown, ...
                'Callbacks',{items});
            obj.ActiveRibbonDropdown = menuKey;
            obj.setRibbonFigureCallback();
        end

        function dropdownDataHandler(obj, menuKey, data)
            if nargin < 3 || isempty(data) || ~isstruct(data) || ~isfield(data,'type')
                return;
            end

            switch string(data.type)
                case "select"
                    if isfield(data,'id')
                        obj.invokeRibbonDropdownCallback(menuKey, char(data.id));
                    end
                case "close"
                    obj.hideRibbonDropdown(menuKey);
            end
        end

        function invokeRibbonDropdownCallback(obj, menuKey, itemId)
            if nargin < 3 || isempty(itemId)
                obj.hideRibbonDropdown(menuKey);
                return;
            end

            if ~isstruct(obj.RibbonDropdowns) || ~isfield(obj.RibbonDropdowns, menuKey)
                return;
            end

            entry = obj.RibbonDropdowns.(menuKey);
            callbacks = entry.Callbacks;
            if iscell(callbacks)
                callbacks = callbacks{1};
            end

            for idx = 1:numel(callbacks)
                cbDef = callbacks(idx);
                if isfield(cbDef,'Id') && strcmp(char(cbDef.Id), itemId)
                    if isfield(cbDef,'Callback') && ~isempty(cbDef.Callback)
                        try
                            cbDef.Callback();
                        catch err
                            warning('ControlDesignGUI:DropdownCallback', ...
                                'Error executing dropdown callback for "%s": %s', itemId, err.message);
                        end
                    end
                    break;
                end
            end

            obj.hideRibbonDropdown(menuKey);
        end

        function hideRibbonDropdown(obj, menuId)
            if nargin < 2
                return;
            end

            menuKey = char(menuId);
            if ~isstruct(obj.RibbonDropdowns)
                obj.RibbonDropdowns = struct();
            end

            if isfield(obj.RibbonDropdowns, menuKey)
                entry = obj.RibbonDropdowns.(menuKey);
                if isstruct(entry) && isfield(entry,'Component')
                    comp = entry.Component;
                    if ~isempty(comp) && isvalid(comp)
                        delete(comp);
                    end
                end
                obj.RibbonDropdowns = rmfield(obj.RibbonDropdowns, menuKey);
            end

            if strcmp(obj.ActiveRibbonDropdown, menuKey)
                obj.ActiveRibbonDropdown = '';
            end

            if isempty(fieldnames(obj.RibbonDropdowns))
                obj.RibbonDropdowns = struct();
                obj.restoreRibbonFigureCallback();
            end
        end

        function closeAllRibbonDropdowns(obj)
            if ~isstruct(obj.RibbonDropdowns)
                obj.RibbonDropdowns = struct();
            else
                menuKeys = fieldnames(obj.RibbonDropdowns);
                for idx = 1:numel(menuKeys)
                    entry = obj.RibbonDropdowns.(menuKeys{idx});
                    if isstruct(entry) && isfield(entry,'Component')
                        comp = entry.Component;
                        if ~isempty(comp) && isvalid(comp)
                            delete(comp);
                        end
                    end
                end
                obj.RibbonDropdowns = struct();
            end
            obj.ActiveRibbonDropdown = '';
            obj.restoreRibbonFigureCallback();
        end

        function html = buildRibbonDropdownHtml(~, items)
            itemMarkup = cell(1,numel(items));
            for idx = 1:numel(items)
                labelText = escapeHtml(items(idx).Label);
                shortcutText = '';
                if isfield(items(idx),'Shortcut') && ~isempty(items(idx).Shortcut)
                    shortcutText = escapeHtml(items(idx).Shortcut);
                end
                if isempty(shortcutText)
                    shortcutText = '&nbsp;';
                end
                itemMarkup{idx} = sprintf([ ...
                    '<button class="menu-item" type="button" data-id="%s" title="%s">' ...
                    '<span class="item-icon"><img src="%s" alt="" /></span>' ...
                    '<span class="item-label">%s</span>' ...
                    '<span class="item-shortcut">%s</span>' ...
                    '</button>'], ...
                    escapeHtml(items(idx).Id), labelText, items(idx).Icon, labelText, shortcutText);
            end

            styleBlock = strjoin({ ...
                '<style>', ...
                'html,body{margin:0;padding:0;background:transparent;font-family:"Segoe UI","Helvetica Neue",Arial,sans-serif;color:#1f1f1f;}', ...
                '#dropdownRoot{position:absolute;inset:0;padding:6px 0;background:linear-gradient(180deg,#fbfbfc 0%,#d9dde3 100%);' , ...
                'border:1px solid #9ba1ac;border-radius:6px;box-shadow:0 8px 18px rgba(0,0,0,0.25);display:flex;flex-direction:column;gap:2px;}', ...
                '.menu-item{display:flex;align-items:center;gap:10px;padding:6px 16px;border:0;background:transparent;font-size:12px;line-height:18px;color:#202126;cursor:pointer;text-align:left;}', ...
                '.menu-item:hover{background:rgba(56,120,196,0.18);}', ...
                '.menu-item:focus{outline:none;background:rgba(56,120,196,0.24);}', ...
                '.item-icon{width:24px;display:flex;align-items:center;justify-content:center;}', ...
                '.item-icon img{width:20px;height:20px;}', ...
                '.item-label{flex:1;font-weight:500;}', ...
                '.item-shortcut{display:flex;justify-content:flex-end;min-width:64px;color:#4d525a;font-size:11px;white-space:nowrap;}', ...
                '</style>'},'');

            scriptBlock = strjoin({ ...
                '<script>', ...
                'function setup(htmlComponent){', ...
                'const root = document.getElementById("dropdownRoot");', ...
                'if(!root){return;}', ...
                'root.querySelectorAll(".menu-item").forEach(btn=>{', ...
                'btn.addEventListener("click",()=>{', ...
                'const id = btn.dataset.id;', ...
                'htmlComponent.Data = {type:"select",id:id};', ...
                '});', ...
                '});', ...
                'root.addEventListener("keydown",evt=>{', ...
                'if(evt.key==="Escape"){htmlComponent.Data = {type:"close"};}});', ...
                'root.focus();', ...
                'document.addEventListener("wheel",evt=>evt.preventDefault(),{passive:false});', ...
                '}', ...
                '</script>'},'');

            html = strjoin({ ...
                '<!doctype html>', ...
                '<html lang="en">', ...
                '<head>', ...
                '<meta charset="utf-8" />', ...
                styleBlock, ...
                '</head>', ...
                '<body>', ...
                '<div id="dropdownRoot" tabindex="0">', ...
                strjoin(itemMarkup,''), ...
                '</div>', ...
                scriptBlock, ...
                '</body>', ...
                '</html>'},'');

            function str = escapeHtml(text)
                if nargin == 0 || isempty(text)
                    str = '';
                    return;
                end
                text = char(text);
                str = strrep(text,'&','&amp;');
                str = strrep(str,'<','&lt;');
                str = strrep(str,'>','&gt;');
                str = strrep(str,'"','&quot;');
                str = strrep(str,char(39),'&#39;');
            end
        end

        function dataUri = encodeRibbonIcon(~, iconName)
            persistent iconCache iconBaseDir
            if isempty(iconBaseDir)
                thisDir = fileparts(mfilename('fullpath'));
                iconBaseDir = fullfile(thisDir,'..','..','Resources');
            end

            if isempty(iconName)
                dataUri = '';
                return;
            end

            key = char(iconName);
            if isempty(iconCache)
                iconCache = containers.Map('KeyType','char','ValueType','char');
            elseif isKey(iconCache,key)
                dataUri = iconCache(key);
                return;
            end

            fullPath = fullfile(iconBaseDir,key);
            fid = fopen(fullPath,'rb');
            if fid < 0
                error('ControlDesignGUI:MissingIcon','Icon file not found: %s',fullPath);
            end
            cleaner = onCleanup(@()fclose(fid)); %#ok<NASGU>
            raw = fread(fid,Inf,'*uint8');
            dataUri = ['data:image/png;base64,' matlab.net.base64encode(raw')];
            iconCache(key) = dataUri;
        end

        function setRibbonFigureCallback(obj)
            if isempty(obj.Parent) || ~isgraphics(obj.Parent)
                return;
            end

            if ~obj.RibbonDropdownOriginalFigureFcn.Stored
                obj.RibbonDropdownOriginalFigureFcn = struct( ...
                    'Stored',true, ...
                    'Value',obj.Parent.WindowButtonDownFcn);
            end

            obj.Parent.WindowButtonDownFcn = @(src,evt)obj.handleRibbonFigureClick(src,evt);
        end

        function restoreRibbonFigureCallback(obj)
            if isempty(obj.Parent) || ~isgraphics(obj.Parent)
                obj.RibbonDropdownOriginalFigureFcn = struct('Stored',false,'Value',[]);
                return;
            end

            if obj.RibbonDropdownOriginalFigureFcn.Stored
                obj.Parent.WindowButtonDownFcn = obj.RibbonDropdownOriginalFigureFcn.Value;
            else
                obj.Parent.WindowButtonDownFcn = [];
            end

            obj.RibbonDropdownOriginalFigureFcn = struct('Stored',false,'Value',[]);
        end

        function handleRibbonFigureClick(obj, src, evt)
            if nargin < 2 || isempty(src)
                src = obj.Parent;
            end

            originalFcn = obj.RibbonDropdownOriginalFigureFcn;

            clickPoint = [nan nan];
            if ~isempty(src) && isgraphics(src) && isprop(src,'CurrentPoint')
                clickPoint = src.CurrentPoint;
            end

            if all(isfinite(clickPoint)) && obj.isPointInsideDropdown(clickPoint)
                obj.executeFigureCallback(originalFcn.Value, src, evt);
                return;
            end

            obj.closeAllRibbonDropdowns();
            obj.executeFigureCallback(originalFcn.Value, src, evt);
        end

        function inside = isPointInsideDropdown(obj, point)
            inside = false;
            if ~isstruct(obj.RibbonDropdowns)
                return;
            end

            menuKeys = fieldnames(obj.RibbonDropdowns);
            for idx = 1:numel(menuKeys)
                entry = obj.RibbonDropdowns.(menuKeys{idx});
                if ~isstruct(entry) || ~isfield(entry,'Component')
                    continue;
                end
                comp = entry.Component;
                if isempty(comp) || ~isvalid(comp)
                    continue;
                end
                pos = comp.Position;
                if point(1) >= pos(1) && point(1) <= pos(1) + pos(3) && ...
                        point(2) >= pos(2) && point(2) <= pos(2) + pos(4)
                    inside = true;
                    return;
                end
            end
        end

        function executeFigureCallback(~, callbackFcn, src, evt)
            if isempty(callbackFcn)
                return;
            end
            try
                if isa(callbackFcn,'function_handle')
                    if nargin(callbackFcn) == 0
                        callbackFcn();
                    else
                        callbackFcn(src, evt);
                    end
                elseif iscell(callbackFcn) && ~isempty(callbackFcn)
                    feval(callbackFcn{:}, src, evt);
                elseif ischar(callbackFcn) || (isstring(callbackFcn) && isscalar(callbackFcn))
                    feval(callbackFcn, src, evt);
                end
            catch err
                warning('ControlDesignGUI:FigureCallback', ...
                    'Error executing figure WindowButtonDownFcn: %s', err.message);
            end
        end

    end
    
    %% Methods - Load Project
    methods 
       
        function loadProject( obj , pathname , filename )
            
            notify(obj,'LoadProject',GeneralEventData({pathname,filename}));

        end % loadWorkspace_CB
                
        function closeProjectLocal( obj )
            notify(obj,'CloseProject');
        end % closeProjectLocal
        
    end
    
    %% Methods - Export Callbacks
    methods (Access = protected) 
        
        function menuExportScatteredGains( obj , ~ , ~ , index )
            gainSrcObj       = obj.Tree.GainsScattered.Children(index).UserData; %#ok<NASGU>

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
        end % menuExportScheduledGains

        function menuExportLinearModels( obj , ~ , ~ , selected )
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
        end % menuExportLinearModels

        function exportPlots( obj , ~ , ~ , selected )

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
                            loadProject(obj.SimViewerColl(i), batchObj(ind).SimReqObj(i).SimViewerProject );


                            simpts = obj.SimViewerColl(i).export2Files(reqObj(i).Title );
                            y(ind).Requierments(3).Plots = [y(ind).Requierments(3).Plots, simpts];
                        end
                        y(ind).Requierments(3).Title = 'Simulation Analysis';
                        y(ind).Requierments(3).ReqObj = reqObj;

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
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Select All - Analysis');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = @obj.selectAllAnalysis;


                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All - Analysis');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = @obj.deselectAllAnalysis;

                    jmenu.add(menuItem2);
                    jmenu.add(menuItem3);
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
            updateTreeTable( obj.BatchRunCollection );

        end % addOper2Batch
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
                end
            end
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
        
        function menuAddOperCond( obj , ~ , ~ )
            addOperCond(obj.Tree , [] , [] , obj.Tree.OperCondNode );
        end % menuAddOperCond
        
        function menuAddSynthesis( obj , ~ , ~ )
            insertReqObj_CB( obj.Tree , [] , [] , obj.Tree.GainsSynthesis , [] , Requirements.Synthesis.empty);
        end % menuAddSynthesis
            
        function menuScattGain( obj , ~ , ~ )
            insertScatteredGainCollObjFile_CB( obj.Tree , [] , [] , obj.Tree.GainsScattered , [] , ScatteredGain.GainFile.empty);
        end % menuScattGain

        function menuSchGain( obj , ~ , ~ )
            insertSchGainCollObjFile_CB( obj.Tree , [] , [] , obj.Tree.GainSource , [] , ScheduledGain.SchGainCollection.empty);
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
            drawnow();pause(0.1);
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

                    if ~isempty(obj.CurrentScatteredGainColl) && ~isempty(obj.CurrentScatteredGainColl.DesignOperatingCondition)
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

                    if ~isempty(obj.CurrentScatteredGainColl) && ~isempty(obj.CurrentScatteredGainColl.DesignOperatingCondition)
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
        makeBatchReoport(obj,runObjects,['PBeta GS F',num2str(flaps),'.docx']);
            

        profile viewer

        end % runandBuildReport
        
        function makeBatchReoport(obj,runObjects,filenames)

            runBatch( obj, [], [], runObjects);


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
            selAnalysis = [analysisOperCond.SelectedforAnalysis];
            runObjects = UserInterface.ControlDesign.RunObject( 'StabReqObj',stabreqObjCopy,...
                                                'FreqReqObj',freqreqObjCopy,...
                                                'SimReqObj',simreqObjCopy,...
                                                'HQReqObj',hqreqObjCopy,...
                                                'ASEReqObj',asereqObjCopy,...
                                                'AnalysisOperCond',copy(analysisOperCond),...
                                                'DesignOperCond',copy(designOperCond),...
                                                'ReqParamColl',copy(obj.ReqParamColl)  ,...
                                                'FilterParamColl',copy(obj.FilterParamColl) ,...
                                                'SynthesisParamColl',copy(obj.SynthesisParamColl),...
                                                'AnalysisOperCondDisplayText',getSelectedDisplayData(obj,analysisOperCond),...
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
                        BreakPoints1Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints1NameExpression;
                        if ~isempty(strfind(BreakPoints1Path,'DesignOperatingCondition'))
                            BreakPoints1Path = strrep(BreakPoints1Path,'(ind).DesignOperatingCondition','');
                        end
                        BP1 = eval(['arrayfun(@(scatteredGains) ',BreakPoints1Path,',obj.OperCondColl.SelAnalysisOperCond);']);

                        BreakPoints2Path = gainSrcObj.Gain(i).SchGainVec.BreakPoints2Expression;
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

                    if isempty(obj.CurrentScatteredGainColl)
                        scatGain  = ScatteredGain.Gain.empty;
                        selDesignOperCond = lacm.OperatingCondition.empty;
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
            
            if nargin == 3parentPos
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

        function updateControlTreeLayout(obj, ~, ~)
            if isempty(obj.BrowserPanel) || ~isgraphics(obj.BrowserPanel)
                return;
            end

            if isempty(obj.Tree) || ~isa(obj.Tree,'UserInterface.ControlDesign.ControlTree') || ~isvalid(obj.Tree)
                return;
            end

            treeObj = obj.Tree.TreeObj;
            if isempty(treeObj) || ~isvalid(treeObj)
                return;
            end

            if ~isgraphics(treeObj) || ~isprop(treeObj,'Position')
                return;
            end

            panelPos = getpixelposition(obj.BrowserPanel);
            width = panelPos(3);
            height = panelPos(4);

            if width <= 0 || height <= 0
                return;
            end

            if isprop(treeObj,'Units')
                treeObj.Units = 'pixels';
            end

            treeObj.Position = [0 0 width height];
        end

    end
    
    %% Methods - Resize
    methods %(Access = protected) 

        function reSize( obj , ~ , ~ )
       
            % Call super class method
            reSize@UserInterface.Level1Container(obj,[],[]);
            
            positionMain = getpixelposition(obj.MainPanel);
            
            parentPosition = getpixelposition(obj.Parent);
            if ~isempty(obj.SimviewerRibbonCardPanel) && isvalid(obj.SimviewerRibbonCardPanel)
                set(obj.SimviewerRibbonCardPanel,'Units','Pixels',...
                    'Position',[ 860 , parentPosition(4) - 93 , parentPosition(3) - 860 , 93 ]);
            end
            
            set(obj.BrowserPanel,'Units','Pixels',...
                'Position',[ 1 , (positionMain(4))/2 , 330 , ((positionMain(4))/2) - 18 ]);

            set(obj.SelectionPanel,'Units','Pixels',...
                'Position',[ 1 , 1 , 330 , (positionMain(4))/2 ]);

            set(obj.LargeCardPanel,'Units','Pixels',...
                'Position',[ 332 , 1 , positionMain(3) - 332 , positionMain(4) ]);

            obj.updateControlTreeLayout();

            obj.ProjectLabel.Position = [ 1 , positionMain(4) - 18 , 330 , 16 ];

        end % reSize
        
        function reSizeDesignPanel( obj , ~ , ~ )
            
            parentPos = getpixelposition(obj.LargeCardPanel.Panel(1));
            desParamW = 287;%181.5;
            set(obj.DesignParameterPanel,'Units','Pixels','Position',[1 , 1 , desParamW , parentPos(4)]);
            set(obj.DesignTabPanel,'Units','Pixels','Position',[desParamW + 1 , 1 , parentPos(3) - desParamW , parentPos(4)]);
             
            paramPanel = getpixelposition(obj.DesignParameterPanel);
            height = paramPanel(4)/2;
            obj.ParameterLabel.Position = [ 1 , paramPanel(4) - 17 , paramPanel(3) - 5 , 16 ];
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
            
            
            % Delete Figure
            delete(obj.Figure);

            

        end % closeFigure_CB
        
    end
    
    %% Methods - Delete
    methods
        function delete( obj )
            
            
            
        % Java Components 
        obj.ToolRibbionTab = [];
        obj.ProjectPanel = [];
        obj.NewJButton = [];
        obj.OpenJButton = [];
        obj.LoadJButton = [];
        obj.RunSelJButton = [];
        obj.RunSelMenuButton = [];
        obj.SaveJButton = [];
        obj.ExportJButton = [];
        obj.PlotJButton = [];
        obj.JRibbonPanel = [];
        obj.JRPHComp = [];
        obj.ProjectLabel = [];
        obj.ParameterLabel = [];

        obj.closeAllRibbonDropdowns();

        if isstruct(obj.RibbonAnchors)
            anchorNames = fieldnames(obj.RibbonAnchors);
            for idx = 1:numel(anchorNames)
                h = obj.RibbonAnchors.(anchorNames{idx});
                if ~isempty(h) && isvalid(h)
                    delete(h);
                end
            end
        end
        obj.RibbonAnchors = struct();
        obj.RibbonState = struct();
        
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
        if isgraphics(obj.ProjectLabel) && strcmp(get(obj.ProjectLabel, 'BeingDeleted'), 'off')
            delete(obj.ProjectLabel)
        end
        if isgraphics(obj.ParameterLabel) && strcmp(get(obj.ParameterLabel, 'BeingDeleted'), 'off')
            delete(obj.ParameterLabel)
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
        try %#ok<*TRYNC>             
            delete(obj.SelectedParameter);
        end
        try %#ok<*TRYNC>             
            delete(obj.Tree);
        end
        try %#ok<*TRYNC>             
            delete(obj.OperCondColl);
        end
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
        visible = axH(i).Visible;
        if strcmp('on',visible)
            saveFigH(end + 1) = uifigure( ...
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
    
end % undockFigures

function y = printFigure2File( axH )

    y = struct('Filename',{},'Title',{});
    figH = [];   
    for i = 1:length(axH)%axHQ.size 
        visible = axH(i).Visible;
        if strcmp('on',visible)
            figH = uifigure( ...
                    'Name', axH(i).Title.String, ...
                    'NumberTitle', 'off',...
                    'Visible','off');
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
        figH = uifigure( ...
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

            saveFigH(end + 1) = uifigure( ...
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
    figH = uifigure( ...
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
