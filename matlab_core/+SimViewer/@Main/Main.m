classdef Main <  handle & matlab.mixin.CustomDisplay & matlab.mixin.SetGet
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Container
        Parent
        RibbonParent
        AxH
        AxisContainer
        DropEditBox
        DropEditBoxComp
        DropEditBoxCont
        
        RootTreeNode
        
        MainPanel
        RibbonPanel
        JRibbonPanel
        JRPHComp
        JRPHCont
        RemoveJButton
        AddJButton
        AllRunsJButton
        TimeRangeJButton

        PlotJButton
        HoldJButton
        ShowMarkerJCheckbox
        FunctionJCombo
        NormalJCheckbox
        ClearJButton
        
        BrowseStartDir = pwd
        AxisPanelCollObj
        
        JTreeComp
        JTreeCont
        
        JScroll
        JHScroll
        HContainer
        
        DropTarget
        
        SearchString_EB
        ExportJButton
        
        RebuildTreeJCheckbox
    end % Public properties
    
    %% Public properties - Tree Object Handles
    properties (Transient = true) 
        TreeContainer
        SimulationDataSelection
        TreeModel
        Tree
        HJTree
        RunNodes = uitreenode('v0','','', [], 0)
        Root
        
        UpButtonHComp
        UpJButtonHCont
        DnButtonHComp
        DnJButtonHCont
        
        MatchCaseJCheckbox
        MatchCaseJCheckboxHComp
        MatchCaseJCheckboxHCont
        
        MatchWholeWordJCheckbox
        MatchWholeWordJCheckboxHComp
        MatchWholeWordJCheckboxHCont
        
    end % Public properties
    
    %% Public properties - Tree Data Storage
    properties  
        SearchString = ''
        MatchCase = false
        MatchWholeWord = false
        
        FoundTreePaths = {}
        FoundTreePathIndex = 1
        
        SavedNodes 
        NodeExpansionState
        CurrentSelectedObject = {}
        CurrentSelectedNodeStr
        CurrentSelectedTreePath
        HoldPlot = false
        
        UseOutputBlockName = false  
        
        ShowBusSignalsOnly
        
        RunSpecificColors
        
        RebuildTreeState = true
        
    end % Public properties 
    
    %% Constant properties - Tree
    properties (Constant) 
        JavaImage_checked        = checkedIcon();
        JavaImage_partialchecked = partialCheckIcon();
        JavaImage_unchecked      = uncheckedIcon();
        JavaImage_folderopen     = folderOpenIcon();
        JavaImage_folder         = folderIcon();
        JavaImage_structure      = structureIcon();
        JavaImage_model          = modelIcon();
        JavaImage_localVar       = localVarIcon(); 
        JavaImage_simulink       = simulinkIcon();
        JavaImage_method         = methodIcon();
        JavaImage_plot           = plotIcon();  
        JavaImage_signals        = signalsIcon()
        JavaImage_output         = outputIcon()
        JavaImage_input          = inputIcon()
        JavaImage_outputArrow    = outArrowIcon()
        JavaImage_inputArrow     = inArrowIcon()
        JavaImage_signalLog      = signalLogIcon()
        JavaImage_bus            = busIcon()
        JavaImage_mdlRef         = simRefIcon()
        
    end % Constant properties  
      
    %% Public properties - Data Storage
    properties   
        Version = '1.0'
        
        
        SimData%@Simulink.SimulationOutput%Simulink.SimulationData.Dataset
        NumOfPlots = 1

        SelectedFunction = 'Normal'
        NormalData = false
        ShowMarkers = false
        
        Title
        RunLabel
        
        SimulationTime
        NumPages = 2
        NumberOfPlot = 1
        
        EnableSave
        EnableLoad
        SortBySubsystem = true
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )     
        PrivateUnits
        PrivatePosition
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )
        Units
        Position
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )
        Figure
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        

    end
    
    %% Events
    events

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = Main( varargin )
               
            filepath = fileparts(mfilename('fullpath'));
%             javaaddpath(fullfile(filepath,'..','java'));
%             if nargin == 0
%                return; 
%             end 


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Check Lic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
%             granola = SimViewer.SimMacLib();
%             status = login(granola);
% 
%             if ~status
%                 throw(granola.LastError); % Terminate Program
%             end

            
            p = inputParser;
            dataTypeCheck = @(x) assert( isa(x,'Simulink.SimulationOutput') || isa(x,'Simulink.SimulationData.Dataset'),'Value must be a Simulink Output or Dataset class');
            addOptional(p,'SimDataOpt',Simulink.SimulationOutput.empty,dataTypeCheck);
            addParameter(p,'SimData',Simulink.SimulationOutput.empty,dataTypeCheck);
            addParameter(p,'Title','Simulation Viewer',@ischar);
            addParameter(p,'SimulationTime',[],@isvector);
            addParameter(p,'EnableSave',true,@islogical);
            addParameter(p,'EnableLoad',true,@islogical);
            addParameter(p,'Parent','');
            addParameter(p,'RibbonParent','');
            checkList = @(x) assert( ischar(x) || iscellstr(x),'Value must be a character or cell array of strings');
            addParameter(p,'RunLabel','Run',checkList);
            checkColor = @(x) assert( isnumeric(x) || length(x) == 3,'Value must be a 3 element numeric vector');
            addParameter(p,'RunSpecificColors',[0,0,1],checkColor);
            addParameter(p,'PlotSettings',[]);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            if isempty(options.SimDataOpt)
                obj.SimData = options.SimData;    
            else
                obj.SimData = options.SimDataOpt;
            end
            obj.Title = options.Title;
            obj.Parent = options.Parent;
            obj.RibbonParent = options.RibbonParent;
            obj.SimulationTime = options.SimulationTime;
            obj.EnableSave = options.EnableSave;
            obj.EnableLoad = options.EnableLoad;
%             obj.RunSpecificColors = options.RunSpecificColors;
            updateRunNodes( obj , options.RunLabel);
            
            if ~isempty(obj.Parent)
                createView( obj ,obj.Parent);
%                 if isempty(obj.RibbonParent)
%                     createView( obj ,obj.Parent);
%                 else
%                     createView( obj ,obj.Parent , obj.RibbonParent);
%                 end
            else
                createView( obj );
            end
            
            % If user specified plot settings update plots
            if ~isempty(options.PlotSettings)
                loadPlotSettings(obj, options.PlotSettings);
            end

        
        end % Main
        
    end % Constructor

    %% Methods - Property Access
    methods
                  
        function y = get.Figure( obj )
            y = ancestor(obj.Parent,'figure','toplevel');
        end % Figure
        
        function set.Position( obj , pos )
            set(obj.Container,'Position',pos);
            obj.PrivatePosition = pos;
        end % Position - Set
        
        function y = get.Position( obj )
            y = obj.PrivatePosition;
        end % Position - Get
        
        function set.Units( obj , units )
            set(obj.Container,'Units',units);
            obj.PrivateUnits = units;
        end % Units -Set
        
        function y = get.Units( obj )
            y = obj.PrivateUnits;
        end % Units -Get
        
    end % Property access methods
    
    %% Methods - View
    methods    
    
        function createView( obj,parent)
            if nargin == 2
                obj.Parent = parent;
            end
            if isempty(obj.Parent)
                figID = [getenv('username'),'|SimViewer'];
                sz = [ 650 , 1200 ];%[ 900 , 650]; % figure size
                screensize = get(0,'ScreenSize');
                xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
                ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically
                obj.Parent = figure('Name',obj.Title,...%Control',...
                                    'units','pixels',...
                                    'Position',[xpos, ypos, sz(2), sz(1)],...%[193 , 109 , 1384 , 960],...%[193,109,1368,768],
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...
                                    'Tag',figID,...
                                    'UserData',obj,...
                                    'CloseRequestFcn', @obj.closeFigure_CB);

            end
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            java_dir = fullfile( this_dir,'..','java' );
%             javaaddpath(java_dir);
            warnStruct = warning('off','MATLAB:uitreenode:DeprecatedFunction');
            
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0 , 0 , 1 , 1 ]); 
                
        
        
            set(obj.Container,'ResizeFcn',@obj.reSize); 
            position = getpixelposition(obj.Container);
            if isempty(obj.RibbonParent)
                obj.RibbonPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'BorderType','none',...
                    'Position',[ 1 , position(4)-93 , position(3), 93 ]);
                % Create Main Container
                obj.MainPanel = uicontainer('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , 1 , position(3) , position(4) - 93 ]); 
            else
                obj.RibbonPanel = obj.RibbonParent;
                % Create Main Container
                obj.MainPanel = uicontainer('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , 1 , position(3) , position(4)]);  
            end
            
%             [ obj.SimulationDataSelection,obj.AxisContainer,hDivider] = uisplitpane(obj.MainPanel);
            
            createToolRibbon(obj, obj.RibbonPanel);            
            
             obj.SimulationDataSelection = uicontainer('Parent',obj.MainPanel,...
                'Units','Pixels',...
                'Position',[ 10 , 100 , 200 , 790 ]); 
                     
            % Create Java tree or Matlab
            createTreeSearchContainer( obj );

            obj.AxisContainer = uicontainer('Parent',obj.MainPanel,...
                'Units','Pixels',...
                'Position',[250 , 1 , position(3) - 250 , position(4)]);  
            
               
            obj.AxisPanelCollObj = SimViewer.AxisPanelCollection('Parent',obj.AxisContainer,'NumOfPages',obj.NumPages,'NumOfAxisPerPage',obj.NumberOfPlot,'Orientation','Vertical'); 
            addlistener(obj.AxisPanelCollObj,'AxisPanelChanged',@obj.updateNumPlotsToolRibbon);  
            addlistener(obj.AxisPanelCollObj,'AxisCollectionEvent',@obj.axisCollectionEvent); 
            
            setDragDrop( obj );

            reSize( obj ,[] , [] );
        
            warning(warnStruct);
        end % createView 
                      
        function createToolRibbon(obj, parent)
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );

            backgroundColor = java.awt.Color(210/255,210/255,210/255);

            obj.JRibbonPanel = javaObjectEDT('javax.swing.JPanel');
            obj.JRibbonPanel.setLayout([]);


            % File Section
            if isempty(obj.RibbonParent)
            sS = 0;
            sL = 270;
            bnW = 40;
            stW = 5;
            
            labelStr = '<html><font color="gray" face="Courier New">OPTIONS</html>';
            jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabel.setOpaque(true);
            jLabel.setBackground(java.awt.Color.lightGray);
            jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabel);
            jLabel.setBounds(sS,76,sL,16);
                
                % New Button
                newJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                newJButton.setText('New');        
                newJButtonH = handle(newJButton,'CallbackProperties');
                set(newJButtonH, 'ActionPerformedCallback',{@obj.loadNewData,false,false,1});
                set(newJButtonH, 'DropDownActionPerformedCallback',@obj.addSelect_CB);     
                myIcon = fullfile(icon_dir,'New_24.png');
                newJButton.setIcon(javax.swing.ImageIcon(myIcon));
                newJButton.setToolTipText('Add new data');
                newJButton.setBorder([]);
                newJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                newJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                newJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(newJButton);
                newJButton.setBounds(stW,3,35,71); 
                
                
                if obj.EnableLoad
                % Load Button             
                loadJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                loadJButton.setText('Open');        
                loadJButtonH = handle(loadJButton,'CallbackProperties');
                set(loadJButtonH, 'ActionPerformedCallback',@obj.loadProjectGUI);
                set(loadJButtonH, 'DropDownActionPerformedCallback',@obj.loadSelect_CB);     
                myIcon = fullfile(icon_dir,'Open_24.png');
                loadJButton.setIcon(javax.swing.ImageIcon(myIcon));
                loadJButton.setToolTipText('Load Project');
                loadJButton.setBorder([]);
                loadJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                loadJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                loadJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(loadJButton);
                loadJButton.setBounds(stW+(bnW*1),3 ,35, 71);
                end  
               
                if obj.EnableSave               
                % save Button             
                saveJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                saveJButton.setText('Save');        
                saveJButtonH = handle(saveJButton,'CallbackProperties');
                set(saveJButtonH, 'ActionPerformedCallback',@obj.saveProjectGUI);
                set(saveJButtonH, 'DropDownActionPerformedCallback',@obj.saveSelect_CB);     
                myIcon = fullfile(icon_dir,'Save_Dirty_24.png');
                saveJButton.setIcon(javax.swing.ImageIcon(myIcon));
                saveJButton.setToolTipText('save');
                saveJButton.setBorder([]);
                saveJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                saveJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                saveJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(saveJButton);
                saveJButton.setBounds(stW+(bnW*2),3 ,35, 71);
     
                end
       
                exportJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                exportJButton.setText('Export');        
                exportJButtonH = handle(exportJButton,'CallbackProperties');
                set(exportJButtonH, 'ActionPerformedCallback',{@obj.exportPlots_CB,'pdf',true});
                set(exportJButtonH, 'DropDownActionPerformedCallback',@obj.exportSelect_CB);     
                myIcon = fullfile(icon_dir,'Export_24.png');
                exportJButton.setIcon(javax.swing.ImageIcon(myIcon));
                exportJButton.setToolTipText('Export');
                exportJButton.setBorder([]);
                exportJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                exportJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(exportJButton);
                exportJButton.setBounds(stW+(bnW*3),3 ,35, 71);
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(sS+sL+2 ,3,2,90);

            end
            
            % Operations Section
            if isempty(obj.RibbonParent)
                sS = sS+sL+2 +4; %276
            else
                sS = 0;
            end
            sL = 240;
            bnW = 40;
            stW = sS + 5;
            
            labelStr = '<html><font color="gray" face="Courier New">OPERATIONS</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(sS,76,sL,16);
            
                % Number of plots           
                plotsJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                plotsJButton.setText(int2str(obj.NumOfPlots));        
                plotsJButtonH = handle(plotsJButton,'CallbackProperties');
                set(plotsJButtonH, 'ActionPerformedCallback',@obj.numPlotsButton_CB)
                myIcon = fullfile(icon_dir,'Subplots_24.png');
                plotsJButton.setIcon(javax.swing.ImageIcon(myIcon));
                plotsJButton.setToolTipText('Number of Plots');
                plotsJButton.setBorder([]);
                plotsJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                plotsJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                plotsJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(plotsJButton);
                plotsJButton.setBounds(stW,3 ,35, 71);
                obj.PlotJButton = plotsJButton; 
            
                % Hold Button             
                holdJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSToggleButton');
                holdJButton.setText('Hold');        
                holdJButtonH = handle(holdJButton,'CallbackProperties');
                set(holdJButtonH, 'ActionPerformedCallback',@obj.holdPlotsButton_CB)
                myIcon = fullfile(icon_dir,'LinePlot_24.png');
                holdJButton.setIcon(javax.swing.ImageIcon(myIcon));
                holdJButton.setToolTipText('Hold Plots');
                holdJButton.setBorder([]);
                holdJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                holdJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                holdJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(holdJButton);
                holdJButton.setBounds(stW+(bnW*1),3 ,35, 71);
                obj.HoldJButton = holdJButton;
                
                % ALL runs            
                allRunsJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSToggleButton');
                allRunsJButton.setText('Multi');        
                allRunsJButtonH = handle(allRunsJButton,'CallbackProperties');
                set(allRunsJButtonH, 'ActionPerformedCallback',@obj.setMultiRun_CB)
                myIcon = fullfile(icon_dir,'plotLines_24.png');
                allRunsJButton.setIcon(javax.swing.ImageIcon(myIcon));
                allRunsJButton.setToolTipText('Hold Plots');
                allRunsJButton.setBorder([]);
                allRunsJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                allRunsJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                allRunsJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(allRunsJButton);
                allRunsJButton.setBounds(stW+(bnW*2),3 ,35, 71);
                obj.AllRunsJButton = allRunsJButton;

                % Clear Button             
                clearJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                clearJButton.setText('Clear');        
                clearJButtonH = handle(clearJButton,'CallbackProperties');
                set(clearJButtonH, 'ActionPerformedCallback',@obj.clearPagePlots_CB);
                set(clearJButtonH, 'DropDownActionPerformedCallback',@obj.clearPlotDropDown_CB);     
                myIcon = fullfile(icon_dir,'ClearPlot_24.png');
                clearJButton.setIcon(javax.swing.ImageIcon(myIcon));
                clearJButton.setToolTipText('Clear');
                clearJButton.setBorder([]);
                clearJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                clearJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                clearJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(clearJButton);
                clearJButton.setBounds(stW+(bnW*3),3,35,71);
                obj.ClearJButton = clearJButton;
                if ~isempty(obj.RibbonParent)
                exportJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton'); %com.mathworks.mwswing.MJButton');
                exportJButton.setText('Export');        
                exportJButtonH = handle(exportJButton,'CallbackProperties');
                set(exportJButtonH, 'ActionPerformedCallback',{@obj.exportPlots_CB,'pdf',true});
                set(exportJButtonH, 'DropDownActionPerformedCallback',@obj.exportSelect_CB);     
                myIcon = fullfile(icon_dir,'Export_24.png');
                exportJButton.setIcon(javax.swing.ImageIcon(myIcon));
                exportJButton.setToolTipText('Export');
                exportJButton.setBorder([]);
                exportJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                exportJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(exportJButton);
                exportJButton.setBounds(stW+(bnW*4),3 ,35, 71);
                end
                
                % Time Range            
                timeRangeJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                timeRangeJButton.setText('Range');        
                timeRangeJButtonH = handle(timeRangeJButton,'CallbackProperties');
                set(timeRangeJButtonH, 'ActionPerformedCallback',@obj.setTimeRange_CB)
                myIcon = fullfile(icon_dir,'Constraint.png');
                timeRangeJButton.setIcon(javax.swing.ImageIcon(myIcon));
                timeRangeJButton.setToolTipText('Time Range');
                timeRangeJButton.setBorder([]);
                timeRangeJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                timeRangeJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                timeRangeJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(timeRangeJButton);
                timeRangeJButton.setBounds(stW+(bnW*5),3 ,35, 71);
                obj.TimeRangeJButton = timeRangeJButton;
               
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(sS+sL+2,3,2,90);
            
            
            % Pages Section
            sS = sS+sL+2 +4; %522
            sL = 100; %240;
            bnW = 40;
            stW = sS + 5;
            
            labelStr = '<html><font color="gray" face="Courier New">PAGES</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(sS,76,sL,16);  
            
            
                addJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                addJButton.setText('Add');        
                addJButtonH = handle(addJButton,'CallbackProperties');
                set(addJButtonH, 'ActionPerformedCallback',@obj.addAxisPanel)
                myIcon = fullfile(icon_dir,'New_24.png');
                addJButton.setIcon(javax.swing.ImageIcon(myIcon));
                addJButton.setToolTipText('Add an Axis Page');
                addJButton.setBorder([]);
                addJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                addJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                addJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(addJButton);
                addJButton.setBounds(stW,3 ,35, 71);
                obj.AddJButton = addJButton;  
            
                removeJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                removeJButton.setText('Remove');        
                removeJButtonH = handle(removeJButton,'CallbackProperties');
                set(removeJButtonH, 'ActionPerformedCallback',@obj.deleteAxisPanel)
                myIcon = fullfile(icon_dir,'StopX_24.png');
                removeJButton.setIcon(javax.swing.ImageIcon(myIcon));
                removeJButton.setToolTipText('Remove Current Page');
                removeJButton.setBorder([]);
                removeJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                removeJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                removeJButton.setBackground(backgroundColor);
                obj.JRibbonPanel.add(removeJButton);
                removeJButton.setBounds(stW+(bnW*1),3 ,45, 71);
                obj.RemoveJButton = removeJButton;   
            
            
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(sS+sL+2,3,2,90);          
            
            % Options Section
            sS = sS+sL+2 +4; %522
            sL = 130;
            bnW = 40;
            stW = sS + 5;
            
            labelStr = '<html><font color="gray" face="Courier New">Options</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(sS,76,sL,16);  

            
                % Rebuild Tree             
                rebuildTreeJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
                rebuildTreeJCheckbox.setText('Rebuild Tree');        
                rebuildTreeJCheckboxH = handle(rebuildTreeJCheckbox,'CallbackProperties');
                set(rebuildTreeJCheckboxH, 'ActionPerformedCallback',@obj.rebuildTreeCheckbox_CB)
                rebuildTreeJCheckbox.setToolTipText('Show Invalid Trims');
                rebuildTreeJCheckbox.setBorder([]);
                rebuildTreeJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(rebuildTreeJCheckbox);
                rebuildTreeJCheckbox.setBounds(stW,3 ,135, 15);
                obj.RebuildTreeJCheckbox = rebuildTreeJCheckbox;
                obj.RebuildTreeJCheckbox.setSelected(obj.RebuildTreeState);


%                 addJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
%                 addJButton.setText('Add');        
%                 addJButtonH = handle(addJButton,'CallbackProperties');
%                 set(addJButtonH, 'ActionPerformedCallback',@obj.addAxisPanel)
%                 myIcon = fullfile(icon_dir,'New_24.png');
%                 addJButton.setIcon(javax.swing.ImageIcon(myIcon));
%                 addJButton.setToolTipText('Add an Axis Page');
%                 addJButton.setBorder([]);
%                 addJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
%                 addJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
%                 addJButton.setBackground(backgroundColor);
%                 obj.JRibbonPanel.add(addJButton);
%                 addJButton.setBounds(stW,3 ,35, 71);
%                 obj.AddJButton = addJButton;  
%             
%                 removeJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
%                 removeJButton.setText('Remove');        
%                 removeJButtonH = handle(removeJButton,'CallbackProperties');
%                 set(removeJButtonH, 'ActionPerformedCallback',@obj.deleteAxisPanel)
%                 myIcon = fullfile(icon_dir,'StopX_24.png');
%                 removeJButton.setIcon(javax.swing.ImageIcon(myIcon));
%                 removeJButton.setToolTipText('Remove Current Page');
%                 removeJButton.setBorder([]);
%                 removeJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
%                 removeJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
%                 removeJButton.setBackground(backgroundColor);
%                 obj.JRibbonPanel.add(removeJButton);
%                 removeJButton.setBounds(stW+(bnW*1),3 ,45, 71);
%                 obj.RemoveJButton = removeJButton;   
%                 

%                 
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(sS+sL+2,3,2,90); 
            
            
            % Create Ribbon
            obj.JRibbonPanel.setVisible(true);

            positionRibbon = getpixelposition(parent);
            [obj.JRPHComp,obj.JRPHCont] = javacomponent(obj.JRibbonPanel,[0,0,positionRibbon(3) , positionRibbon(4)], handle(parent) );
            obj.JRPHCont.Units = 'Normal';
            obj.JRPHCont.Position = [0,0,1,1];

            obj.JRibbonPanel.setBackground(backgroundColor);
        end % createToolRibbon
        
        function updateAxisPanelObj( obj , num )
            selPanel = obj.AxisPanelCollObj.SelectedPanel;
            if selPanel == 0; return; end;
            %replaceAxisPanel( obj.AxisPanelCollObj , selPanel , num );
            replaceKeepAxisPanel( obj.AxisPanelCollObj , selPanel , num );
            setDragDrop( obj );          
        end % updateAxisPanelObj

        function name = assignName( obj , signal )
            name = '';

            if isa(signal,'Simulink.SimulationData.Signal')
                strName = signal.Name;
                
                if isempty(strName)
                    [~,strName] = fileparts(signal.BlockPath.getBlock(1));
                end
                
                if ~isempty(strName) && strcmp(strName(1),'<') && strcmp(strName(end),'>')
                    strName = strName(2:end-1);
                end
                if isa(signal,'Simulink.SimulationData.Signal') && isa(signal.Values,'timeseries') && isempty(signal.Values.Data)
                    name = ['<html><font color="red">', strName,'</html>'];
                else
                    name = ['<html><font color="black">', strName,'</html>'];
                end
            end
        end % assignName
        
        function updateRunNodes( obj , runLabels )
                        
            if iscellstr(runLabels) && (length(obj.SimData) ~= length(runLabels))
                error('If run label is a cell it must be the same length as the data.');
            elseif ischar(runLabels)
                obj.RunLabel = {};
                for i = 1:length(obj.SimData)
                    obj.RunLabel{i} = [runLabels,' # - ',int2str(i)];
                end
            else
                obj.RunLabel = runLabels;
            end
        end % updateRunNodes
        
    end
    
    %% Methods - EditBox
    methods
        
        function dropInEditBox( obj , hobj , eventdata )

        end % dropInEditBox
        
        function linkCallbackFcnEmbedded( obj , hobj , eventdata )

        end % linkCallbackFcnEmbedded
        
        function mouseClicked_CB( obj , hobj , eventdata )

        end % mouseClicked_CB
    end
    
    %% Methods - Tool Ribbon
    methods

        function copy2Clipboard_CB( obj ,  hobj , eventdata )
            screencapture( obj.AxisContainer,[],'clipboard');  
        end % copy2Clipboard_CB
                
        function numPlotsButton_CB( obj , hobj , eventdata )
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
                        
            %obj.PlotJButton.setFlyOverAppearance(false);  
            checkIcon    = javax.swing.ImageIcon(fullfile(icon_dir,'check_16_Black.png'));
            
                       
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            %set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,'Plot'});
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
                    menuItem1 = javax.swing.JMenuItem('<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlots,1};
                    jmenu.add(menuItem1);
                    
                    menuItem2 = javax.swing.JMenuItem('<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlots,2};
                    jmenu.add(menuItem2);
                    
                    menuItem3 = javax.swing.JMenuItem('<html>3');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlots,3};
                    jmenu.add(menuItem3);
                    
                    menuItem4 = javax.swing.JMenuItem('<html>4');
                    menuItem4h = handle(menuItem4,'CallbackProperties');
                    menuItem4h.ActionPerformedCallback = {@obj.setNumPlots,4};
                    jmenu.add(menuItem4);
                    
                    menuItem5 = javax.swing.JMenuItem('<html>5');
                    menuItem5h = handle(menuItem5,'CallbackProperties');
                    menuItem5h.ActionPerformedCallback = {@obj.setNumPlots,5};
                    jmenu.add(menuItem5);
                    
                    menuItem6 = javax.swing.JMenuItem('<html>6');
                    menuItem6h = handle(menuItem6,'CallbackProperties');
                    menuItem6h.ActionPerformedCallback = {@obj.setNumPlots,6};
                    jmenu.add(menuItem6); 
                    
                    

                    switch obj.NumOfPlots 
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 3
                            menuItem3h.setIcon(checkIcon);
                        case 4
                            menuItem4h.setIcon(checkIcon);
                        case 5
                            menuItem5h.setIcon(checkIcon);
                        case 6
                            menuItem6h.setIcon(checkIcon);
                    end
                    
            jmenu.show(obj.PlotJButton, 0 , 60 );
            jmenu.repaint;   
        end % numPlotsButton_CB
        
        function setNumPlots( obj , ~ , ~ , numbPlots )
            obj.NumOfPlots = numbPlots;
            obj.PlotJButton.setText(int2str(obj.NumOfPlots)); 
            if ~isempty(obj.AxisPanelCollObj.Panel)        
                updateAxisPanelObj( obj , numbPlots );
            end
   
        end % setNumPlots
        
        function updateNumPlotsToolRibbon(obj, ~ , ~ )
            
            if ~isempty(obj.AxisPanelCollObj.Panel)
                numPlots = length(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel).Axis);
                obj.NumOfPlots = numPlots;
                obj.PlotJButton.setText(int2str(obj.NumOfPlots)); 
            end
        end % updateNumPlotsToolRibbon
        
        function holdPlotsButton_CB( obj , ~ , eventdata )
            obj.HoldPlot = eventdata.getSource.isSelected;
        end % holdPlotsButton_CB   
        
        function showMarkerCheckbox_CB( obj , ~ , eventdata )
            obj.ShowMarkers = eventdata.getSource.isSelected;
        end % showMarkerCheckbox_CB  
        
        function normalCheckbox_CB( obj , ~ , eventdata )
            obj.NormalData = eventdata.getSource.isSelected;

            if obj.NormalData
            for i = 1:length(obj.AxH)
                lineObjs = findobj(obj.AxH(i),'Type','line');
                yData = lineObjs.YData;
                yData = yData /norm(yData);
                lineObjs.YData = yData;
            end
            end

        end % normalCheckbox_CB  
        
        function setMultiRun_CB( obj , ~ , eventdata )
            if ~eventdata.getSource.isSelected
                obj.SelectedFunction = 'Normal';
            else
                obj.SelectedFunction = 'Multi-Run';
            end
        end % setMultiRun_CB  
                
        function clearPlotDropDown_CB( obj , hobj  , eventdata )
            % Show that the icon is selected
            hobj.setSelected(true);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            clearIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'ClearPlot_16.png'));
            clearAllIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'ClearAllPlots_16.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Page',clearIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.clearPagePlots_CB);

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear All',clearAllIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.clearAllPlots_CB); 

            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Selected',clearIcon);
            menuItem3h = handle(menuItem3,'CallbackProperties');
            set(menuItem3h,'ActionPerformedCallback',@obj.clearSelectedPlots_CB); 
            
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
            
                        
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint; 
                      
        end % clearPlotDropDown_CB
        
        function saveSelect_CB( obj , hobj  , eventdata )
            % Show that the icon is selected
            hobj.setSelected(true);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            saveIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Save_Dirty_24.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Save Project',saveIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.saveProjectGUI);

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save Plot Settings',saveIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.savePlotSettings); 
            
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            
                        
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint; 
                      
        end % saveSelect_CB
        
        function loadSelect_CB( obj , hobj  , eventdata )
            % Show that the icon is selected
            hobj.setSelected(true);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            openIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Open_16.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
            
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Project',openIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.loadProjectGUI);

            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Plot Settings',openIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.loadPlotSettings); 
            
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
                  
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint; 
                      
        end % loadSelect_CB
        
        function exportSelect_CB( obj , hobj  , eventdata )
            % Show that the icon is selected
            hobj.setSelected(true);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            pdfIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'pdf2_16.png'));
            wordIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'word2_16.png'));
            htmlIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'chrome_16.png'));
            saveIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Save_Dirty_16.png'));
            exportIcon = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Export_16.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
            
            menuItem1 = javaObjectEDT('javax.swing.JMenu','<html>Plots to PDF');
            menuItem1.setIcon(pdfIcon);
                menuItem11 = javaObjectEDT('javax.swing.JMenuItem','<html>Current Page',pdfIcon);
                menuItem11h = handle(menuItem11,'CallbackProperties');
                set(menuItem11h,'ActionPerformedCallback',{@obj.exportPlots_CB,'pdf',false});
                menuItem1.add(menuItem11);
                
                menuItem12 = javaObjectEDT('javax.swing.JMenuItem','<html>All',pdfIcon);
                menuItem12h = handle(menuItem12,'CallbackProperties');
                set(menuItem12h,'ActionPerformedCallback',{@obj.exportPlots_CB,'pdf',true});
                menuItem1.add(menuItem12);
                
            menuItem2 = javaObjectEDT('javax.swing.JMenu','<html>Plots to Word');
            menuItem2.setIcon(wordIcon);
                menuItem21 = javaObjectEDT('javax.swing.JMenuItem','<html>Current Page',wordIcon);
                menuItem21h = handle(menuItem21,'CallbackProperties');
                set(menuItem21h,'ActionPerformedCallback',{@obj.exportPlots_CB,'word',false});
                menuItem2.add(menuItem21);
                
                menuItem22 = javaObjectEDT('javax.swing.JMenuItem','<html>All',wordIcon);
                menuItem22h = handle(menuItem22,'CallbackProperties');
                set(menuItem22h,'ActionPerformedCallback',{@obj.exportPlots_CB,'word',true});
                menuItem2.add(menuItem22);
                
            menuItem3 = javaObjectEDT('javax.swing.JMenu','<html>Plots to HTML');
            menuItem3.setIcon(htmlIcon);
                menuItem31 = javaObjectEDT('javax.swing.JMenuItem','<html>Current Page',htmlIcon);
                menuItem31h = handle(menuItem31,'CallbackProperties');
                set(menuItem31h,'ActionPerformedCallback',{@obj.exportPlots_CB,'html',false});
                menuItem3.add(menuItem31);
                
                menuItem32 = javaObjectEDT('javax.swing.JMenuItem','<html>All',htmlIcon);
                menuItem32h = handle(menuItem32,'CallbackProperties');
                set(menuItem32h,'ActionPerformedCallback',{@obj.exportPlots_CB,'html',true});
                menuItem3.add(menuItem32);
            
            if ~isempty(obj.RibbonParent)
                menuItemSPS = javaObjectEDT('javax.swing.JMenuItem','<html>Export Plot Settings',saveIcon);
                menuItemSPSh = handle(menuItemSPS,'CallbackProperties');
                set(menuItemSPSh,'ActionPerformedCallback',@obj.savePlotSettings);
                jmenu.add(menuItemSPS);
                
   
            end
            menuItemESimOut = javaObjectEDT('javax.swing.JMenuItem','<html>Export Simulation Output',exportIcon);
            menuItemSimOut = handle(menuItemESimOut,'CallbackProperties');
            set(menuItemSimOut,'ActionPerformedCallback',@obj.exportSimulationOutput);
            jmenu.add(menuItemESimOut);  
                
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
                        
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint; 
                      
        end % exportSelect_CB
        
        function exportPlots_CB(obj, hobj, eventdata, type, allPlots)
            % allPlots 1 = Print all plots
            if nargin == 1
                type = 'pdf'; 
            end
            
            if strcmp(type,'word')
                extension = 'docx';
            elseif strcmp(type,'pdf')
                extension = 'pdf';
            else
                extension = 'html';
            end
                
            setWaitPtr(obj);
            [file,path] = uiputfile( ...
                {['*.',extension],...
                 ['Export Plots to (*.',extension,')'];
                 '*.*',  'All Files (*.*)'},...
                 'Export Plots',obj.BrowseStartDir);
            

            drawnow();pause(0.5);
            if isequal(file,0) || isequal(path,0)
                return;
            else     
                switch type
                    case 'pdf'
                        if allPlots
                            printAxisObj2File(obj.AxisPanelCollObj.Panel,fullfile(path,file));
                        else
                            printAxisObj2File(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel),fullfile(path,file));
                        end
                    case 'word'
                        if allPlots
                            printAxisObj2File(obj.AxisPanelCollObj.Panel,fullfile(path,file));
                        else
                            printAxisObj2File(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel),fullfile(path,file));
                        end
                    case 'html'
                        if allPlots
                            printAxisObj2File(obj.AxisPanelCollObj.Panel,fullfile(path,file));
                        else
                            printAxisObj2File(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel),fullfile(path,file));
                        end
                end
            end
            releaseWaitPtr(obj);
        end % exportPlots_CB
        
        function addAxisPanel( obj , hobj , eventdata )
            % Add page
            addAxisPage(obj.AxisPanelCollObj , obj.NumOfPlots );
            
            % Add drag and drop listners
            setDragDrop( obj ); 
        end % addAxisPanel
        
        function deleteAxisPanel( obj , hobj , eventdata )
            % Ensure user want to continue
            choice = questdlg('The current page will close and the plots will be lost. Would you like to continue?', ...
                'Remove Page?', ...
                'Yes','No','No');
            drawnow();pause(0.1);
            % Handle response
            switch choice
                case 'Yes'
                    removeAxisPage(obj.AxisPanelCollObj);       
                    setDragDrop( obj );
                otherwise
                    return;
            end
        end % deleteAxisPanel
        
        function addSelect_CB( obj , hobj  , eventdata )
            % Show that the icon is selected
            hobj.setSelected(true);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            clearIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'ClearPlot_16.png'));
            clearAllIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'ClearAllPlots_16.png'));
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});
          
            menuLevel1_1 = javaObjectEDT('javax.swing.JMenu','<html>Add From File');      

                menuLevel2_1 = javaObjectEDT('javax.swing.JMenu','<html>Replace Simulation Data');
                menuLevel1_1.add(menuLevel2_1);
                
                    menuLevel3_1 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Plots');
                    menuLevel3_1h = handle(menuLevel3_1,'CallbackProperties');
                    menuLevel3_1h.ActionPerformedCallback = {@obj.loadNewData,false,false,0};
                    menuLevel2_1.add(menuLevel3_1);
                
                    menuLevel3_2 = javaObjectEDT('javax.swing.JMenuItem','<html>Replace Plot Data');
                    menuLevel3_2h = handle(menuLevel3_2,'CallbackProperties');
                    menuLevel3_2h.ActionPerformedCallback = {@obj.loadNewData,false,false,1};
                    menuLevel2_1.add(menuLevel3_2);
                
                menuLevel2_2 = javaObjectEDT('javax.swing.JMenu','<html>Append Simulation Data');
                menuLevel1_1.add(menuLevel2_2);
                
                    menuLevel3_1 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Plots');
                    menuLevel3_1h = handle(menuLevel3_1,'CallbackProperties');
                    menuLevel3_1h.ActionPerformedCallback = {@obj.loadNewData,false,true,0};
                    menuLevel2_2.add(menuLevel3_1);
                
                    menuLevel3_2 = javaObjectEDT('javax.swing.JMenuItem','<html>Add Simulation Data to Plots');
                    menuLevel3_2h = handle(menuLevel3_2,'CallbackProperties');
                    menuLevel3_2h.ActionPerformedCallback = {@obj.loadNewData,false,true,2};
                    menuLevel2_2.add(menuLevel3_2);
                    
                    menuLevel3_3 = javaObjectEDT('javax.swing.JMenuItem','<html>No Effect on Plots');
                    menuLevel3_3h = handle(menuLevel3_3,'CallbackProperties');
                    menuLevel3_3h.ActionPerformedCallback = {@obj.loadNewData,false,true,3};
                    menuLevel2_2.add(menuLevel3_3);
                    
                    
            menuLevel1_2 = javaObjectEDT('javax.swing.JMenu','<html>Add From Base Workspace');

                menuLevel2_1 = javaObjectEDT('javax.swing.JMenu','<html>Replace Simulation Data');
                menuLevel1_2.add(menuLevel2_1);
                
                    menuLevel3_1 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Plots');
                    menuLevel3_1h = handle(menuLevel3_1,'CallbackProperties');
                    menuLevel3_1h.ActionPerformedCallback = {@obj.loadNewData,true,false,0};
                    menuLevel2_1.add(menuLevel3_1);
                
                    menuLevel3_2 = javaObjectEDT('javax.swing.JMenuItem','<html>Replace Plot Data');
                    menuLevel3_2h = handle(menuLevel3_2,'CallbackProperties');
                    menuLevel3_2h.ActionPerformedCallback = {@obj.loadNewData,true,false,1};
                    menuLevel2_1.add(menuLevel3_2);
                
                menuLevel2_2 = javaObjectEDT('javax.swing.JMenu','<html>Append Simulation Data');
                menuLevel1_2.add(menuLevel2_2);
                
                    menuLevel3_1 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Plots');
                    menuLevel3_1h = handle(menuLevel3_1,'CallbackProperties');
                    menuLevel3_1h.ActionPerformedCallback = {@obj.loadNewData,true,true,0};
                    menuLevel2_2.add(menuLevel3_1);
                
                    menuLevel3_2 = javaObjectEDT('javax.swing.JMenuItem','<html>Add Simulation Data to Plots');
                    menuLevel3_2h = handle(menuLevel3_2,'CallbackProperties');
                    menuLevel3_2h.ActionPerformedCallback = {@obj.loadNewData,true,true,2};
                    menuLevel2_2.add(menuLevel3_2);
                    
                    menuLevel3_3 = javaObjectEDT('javax.swing.JMenuItem','<html>No Effect on Plots');
                    menuLevel3_3h = handle(menuLevel3_3,'CallbackProperties');
                    menuLevel3_3h.ActionPerformedCallback = {@obj.loadNewData,true,true,3};
                    menuLevel2_2.add(menuLevel3_3);
                    
                    
            jmenu.add(menuLevel1_1);
            jmenu.add(menuLevel1_2);
            
                        
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;  
            
%             menuLevel1_1 = javaObjectEDT('javax.swing.JMenu','<html>Add/Replace Simulation Data');
%             %menuItem1h = handle(menuItem1,'CallbackProperties');
%             %set(menuItem1h,'ActionPerformedCallback',@obj.loadNewData);            
% 
%                 repDataenuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>From File');
%                 repDataenuItem1h = handle(repDataenuItem1,'CallbackProperties');
%                 repDataenuItem1h.ActionPerformedCallback = {@obj.loadNewData,false,false};
%                 menuLevel1_1.add(repDataenuItem1);
%                 
%                 repDataenuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>From Base Workspace');
%                 repDataenuItem2h = handle(repDataenuItem2,'CallbackProperties');
%                 repDataenuItem2h.ActionPerformedCallback = {@obj.loadNewData,true,false};
%                 menuLevel1_1.add(repDataenuItem2);
%             
%             menuLevel1_2 = javaObjectEDT('javax.swing.JMenu','<html>Append Run to Simulation Data');
%             %menuItem2h = handle(menuItem2,'CallbackProperties');
%             %set(menuItem2h,'ActionPerformedCallback',@obj.addRun); 
%                 appDataenuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>From File');
%                 appDataenuItem1h = handle(appDataenuItem1,'CallbackProperties');
%                 appDataenuItem1h.ActionPerformedCallback = {@obj.loadNewData,false,true};
%                 menuLevel1_2.add(appDataenuItem1);
%                 
%                 appDataenuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>From Base Workspace');
%                 appDataenuItem2h = handle(appDataenuItem2,'CallbackProperties');
%                 appDataenuItem2h.ActionPerformedCallback = {@obj.loadNewData,true,true};
%                 menuLevel1_2.add(appDataenuItem2);
%             jmenu.add(menuLevel1_1);
%             jmenu.add(menuLevel1_2);
%             
%                         
%             jmenu.show(hobj, 0 , 69 );
%             jmenu.repaint; 
                
        end % addSelect_CB
        
        function setTimeRange_CB( obj , hobj , eventdata)
            prompt = {'Lower Limit:','Upper Limit:'};
            title = 'Time Range';
            dims = [1 45];
            definput = {'0','1'};
            answer = inputdlg(prompt,title,dims,definput);
            drawnow();pause(0.5);
            if isempty(answer) || isempty(str2num(answer{1})) || isempty(str2num(answer{2}))
                return;
            else
                lLimit = str2num(answer{1});
                uLimit = str2num(answer{2});
                if lLimit >= uLimit
                    return;
                end
            end
            xLimit = [lLimit,uLimit];
            disp('passed')
            
            % Set the time range
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    axH = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));
                    set(axH,'XLim',xLimit);
                    set(axH,'UserXLim',xLimit);
                end  
            end
            
        end % setTimeRange_CB
        
        function rebuildTreeCheckbox_CB( obj , ~ , eventdata )
            obj.RebuildTreeState = eventdata.getSource.isSelected;
        end % normalCheckbox_CB  
        
    end
    
    %% Methods - Exporting
    methods
        function figH = export2Figures(obj, panelNumber )
        % Input is an AxisCollection object
        % This will print each page seperate
        
            figH = matlab.ui.Figure.empty;

            if nargin == 2
                simPanel = obj.AxisPanelCollObj.Panel(panelNumber);
            else
                for i = 1:length(obj.AxisPanelCollObj.Panel)
                    simPanel(i) = obj.AxisPanelCollObj.Panel(i); %#ok<AGROW>
                end
            end
            
            for i = 1:length(simPanel)% one page per loop
                figH(i) = exportPanel2Figure(simPanel(i) );
%                 axHArray = simPanel(i).Axis;
%                 numOfAxis = length(simPanel(i).Axis);
% 
%                 % Create figure
%                 figH(i) = figure( ...
%                     'Name', '', ...
%                     'NumberTitle', 'off',...
%                     'Visible','off');
% 
%                 height = 1/numOfAxis;
% 
%                 axHt = 1/numOfAxis;
% 
%                 offset = 0;
%                 for k = 1:numOfAxis
% 
%                     oldaxH = handle(axHArray(k));
% 
%                     if isempty(oldaxH.LegendData)
%                         graphH = copyobj(oldaxH,figH(i));
%                     else
%                         graphH = copyobj([oldaxH,oldaxH.LegendData],figH(i));
%                     end
%                     axH = graphH(1);
%                     axH.Units = 'Normal';
%                     axH.OuterPosition = [ offset , 1 - (axHt * k) , 1 - offset , axHt ]; 
% 
%                     axH.Title = copy(oldaxH.Title);
%                     axH.XLabel = copy(oldaxH.XLabel);
%                     axH.YLabel = copy(oldaxH.YLabel);
%                 end   
% 
% 
%                 switch numOfAxis
%                     case 1
%                         add2Height = 0;
%                         add2Width = 0;
%                     case 2
%                         add2Height = 100;
%                         add2Width = 0;
%                     case 3
%                         add2Height = 200;
%                         add2Width = 0;
%                     case 4
%                         add2Height = 300;
%                         add2Width = 0;
%                     case 5
%                         add2Height = 400;
%                         add2Width = 0;
%                     case 6
%                         add2Height = 500;
%                         add2Width = 0;
% 
%                     otherwise
%                 end
%                 set(figH(i) ,'PaperPositionMode','auto');
%                 pos = getpixelposition(figH(i));
%                 set(figH(i) ,'Units','Pixels');
%                 set(figH(i) ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
% 
% 
% %                 figH(i).Visible = 'on';
%             
%                 set(figH(i),'CreateFcn','set(gcf,''Visible'',''on'')');
            end 

        end % export2Figures
        
        function y = export2Files(obj, title, panelNumber )
        % Input is an AxisCollection object
        % This will print each page seperate
            y = struct('Filename',{},'Title',{}); 
            figH = matlab.ui.Figure.empty;

            if nargin == 3
                simPanel = obj.AxisPanelCollObj.Panel(panelNumber);
            else
                for i = 1:length(obj.AxisPanelCollObj.Panel)
                    simPanel(i) = obj.AxisPanelCollObj.Panel(i); %#ok<AGROW>
                end
            end
            
            for i = 1:length(simPanel)% one page per loop
                figH(i) = exportPanel2Figure(simPanel(i) );
                filelocation = [tempname,'.png'];
                print(figH(i) ,'-dpng',filelocation,'-r300');
                y(end + 1).Filename = filelocation; %#ok<AGROW>
                y(end).Title = title;
            end 

        end % export2Files
        
%         function figH = exportPanel2Figure(obj, simPanel )
% 
%             axHArray = simPanel.Axis;
%             numOfAxis = length(simPanel.Axis);
% 
%             % Create figure
%             figH = figure( ...
%                 'Name', '', ...
%                 'NumberTitle', 'off',...
%                 'Visible','off');
% 
%             height = 1/numOfAxis;
% 
%             axHt = 1/numOfAxis;
% 
%             offset = 0;
%             for k = 1:numOfAxis
% 
%                 oldaxH = handle(axHArray(k));
% 
%                 if isempty(oldaxH.LegendData)
%                     graphH = copyobj(oldaxH,figH);
%                 else
%                     graphH = copyobj([oldaxH,oldaxH.LegendData],figH);
%                 end
%                 axH = graphH(1);
%                 axH.Units = 'Normal';
%                 axH.OuterPosition = [ offset , 1 - (axHt * k) , 1 - offset , axHt ]; 
% 
%                 axH.Title = copy(oldaxH.Title);
%                 axH.XLabel = copy(oldaxH.XLabel);
%                 axH.YLabel = copy(oldaxH.YLabel);
%             end   
% 
% 
%             switch numOfAxis
%                 case 1
%                     add2Height = 0;
%                     add2Width = 0;
%                 case 2
%                     add2Height = 100;
%                     add2Width = 0;
%                 case 3
%                     add2Height = 200;
%                     add2Width = 0;
%                 case 4
%                     add2Height = 300;
%                     add2Width = 0;
%                 case 5
%                     add2Height = 400;
%                     add2Width = 0;
%                 case 6
%                     add2Height = 500;
%                     add2Width = 0;
% 
%                 otherwise
%             end
%             set(figH ,'PaperPositionMode','auto');
%             pos = getpixelposition(figH);
%             set(figH ,'Units','Pixels');
%             set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
% 
%             set(figH,'CreateFcn','set(gcf,''Visible'',''on'')');
%         end % exportPanel2Figure
    end
    
    %% Methods - Save and Load functions
    methods
        function saveProjectGUI(obj, ~ , ~ )
            setWaitPtr(obj);
            [file,path] = uiputfile( ...
                {'*.svw',...
                 'SimViewer Project Files (*.svw)';
                 '*.*',  'All Files (*.*)'},...
                 'Save Settings as',obj.BrowseStartDir);
            drawnow();pause(0.5);
            if isequal(file,0) || isequal(path,0)
                return;
            else
%                 pltSet = getPlotSettings(obj);
%                 saveExpansionState(obj);
%                 SimViewerSavedData = struct('SimulationData',obj.SimData,...
%                     'PlotSettings',pltSet,'RunLabel',{obj.RunLabel},'TreeExpansionState',obj.NodeExpansionState); %#ok<NASGU>

                SimViewerSavedData = getSavedProject(obj); %#ok<NASGU>
                save(fullfile(path,file),'SimViewerSavedData');
            end

            releaseWaitPtr(obj);
        end % saveProjectGUI
        
        function SimViewerSavedData = getSavedProject(obj)

            pltSet = getPlotSettings(obj);
            saveExpansionState(obj);
            SimViewerSavedData = struct('SimulationData',obj.SimData,...
                'PlotSettings',pltSet,'RunLabel',{obj.RunLabel},'TreeExpansionState',obj.NodeExpansionState,'RunSpecificColors',{obj.RunSpecificColors}); %#ok<NASGU>

        end % getSavedProject
         
        function pltSet = getPlotSettings(obj)
              
            pltSet = SimViewer.Main.emptyPlotSettings();
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    hAxes = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));  
                    pltProps(j) = struct('SignalData',hAxes.SignalData,'PlotType', hAxes.PlotType,...
                        'SimViewerData',hAxes.SimViewerData,'UserTitle',hAxes.UserTitle,...
                        'UserXLabel',hAxes.UserXLabel,'UserYLabel',hAxes.UserYLabel,...
                        'UserXLim',hAxes.UserXLim,'UserYLim',hAxes.UserYLim,...
                        'PatchData',hAxes.PatchData);
                end 
                pltSet(i) = struct('NumOfPlots',numPerPanel,'Data',pltProps);
            end
            
        end % getPlotSettings
        
        function savePlotSettings(obj, hobj, eventdata)
            setWaitPtr(obj);
            [file,path] = uiputfile( ...
                {'*.svs',...
                 'SimViewer Settings Files (*.svs)';
                 '*.*',  'All Files (*.*)'},...
                 'Save Settings as',obj.BrowseStartDir);
            drawnow();pause(0.5);
            if isequal(file,0) || isequal(path,0)
                return;
            else
                PlotSettings = getPlotSettings(obj); %#ok<NASGU>
                save(fullfile(path,file),'PlotSettings');
            end
            releaseWaitPtr(obj);
        end % savePlotSettings
        
        function exportSimulationOutput(obj, hobj, eventdata)
            
            if isempty(obj.SimData)
                return;
            end
            
            setWaitPtr(obj);
            [file,path] = uiputfile( ...
                {'*.mat',...
                 'Simulation Output (*.mat)';
                 '*.*',  'All Files (*.*)'},...
                 'Save Output as',obj.BrowseStartDir);
            drawnow();pause(0.5);
            if isequal(file,0) || isequal(path,0)
                return;
            else
                SimData = obj.SimData;
                save(fullfile(path,file),'SimData');
            end
            releaseWaitPtr(obj);
        end % exportSimulationOutput
        
        function loadProjectGUI(obj, hobj, eventdata)
            setWaitPtr(obj);
            [filename, pathname] = uigetfile({'*.svw'},'Select Project File:',obj.BrowseStartDir);
            drawnow();pause(0.5);
            if isequal(filename,0)
                releaseWaitPtr(obj);
                return;
            end
            obj.BrowseStartDir = pathname;
            varStruct = load(fullfile(pathname,filename),'-mat');
           	drawnow();pause(0.5);
            varNames = fieldnames(varStruct);   
            
            
            loadProject(obj, varStruct.(varNames{1}) )         
            releaseWaitPtr(obj);
        end % loadProjectGUI
        
        function loadProject(obj, prjSettings )
            setWaitPtr(obj);
            
            % if empty project and called with no arguments
            if nargin == 1 || isempty(prjSettings)
                obj.SimData = [];
                obj.RunLabel = {};
                clearAllPlots_CB( obj , [] , [] );
                createMatlabJTree( obj ); 
                reSize( obj ,[] , [] );
                releaseWaitPtr(obj);
                return;
            end
            % Restore plot settings
            restorePlotSettings(obj, prjSettings.PlotSettings);
            
            % Add data tree
            clearTree( obj );
            obj.SimData = prjSettings.SimulationData;
            obj.RunLabel = prjSettings.RunLabel;
            if isfield(prjSettings,'RunSpecificColors')
                obj.RunSpecificColors = prjSettings.RunSpecificColors;
            end
            
            createMatlabJTree( obj ); 
            reSize( obj ,[] , [] );
            
            % Restore Expansion state of tree
            obj.NodeExpansionState = prjSettings.TreeExpansionState;
            restoreExpansionState(obj);
            
            % Update the plots with the data
            updateAllPlots( obj );
            
            % Update the 'PlotNumber' button
                
            releaseWaitPtr(obj);
        end % loadProject
        
        function loadPlotSettings(obj, hobj, eventdata)
            setWaitPtr(obj);
            if nargin == 3
                [filename, pathname] = uigetfile({'*.svs'},'Select Settings File:',obj.BrowseStartDir);
                drawnow();pause(0.5);
                if isequal(filename,0)
                    return;
                end
                obj.BrowseStartDir = pathname;
                varStruct = load(fullfile(pathname,filename),'-mat');
                drawnow();pause(0.5);
                varNames = fieldnames(varStruct);  
                pltSettings = varStruct.(varNames{1});
            else
                if ischar(hobj)
                    varStruct = load(hobj,'-mat');
                    drawnow();pause(0.5);
                    varNames = fieldnames(varStruct);  
                    pltSettings = varStruct.(varNames{1});
                else
                    pltSettings = hobj;
                end
            end
            
            % Restore plot settings
            restorePlotSettings(obj, pltSettings);
            
            % Update the plots with the data
            updateAllPlots( obj );
            
            releaseWaitPtr(obj);
        end % loadPlotSettings
        
        function restorePlotSettings(obj, pltSettings)
            % Remove current axis panels
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = numPanels:-1:1 % i = 1:numPanels
                removeAxisPage(obj.AxisPanelCollObj,i);
            end
            
            % Add panels and plots
            for i = 1:length(pltSettings) % same as number of pages
                numPerPanel = pltSettings(i).NumOfPlots;
                % Add the axis panel page
                addAxisPage(obj.AxisPanelCollObj , numPerPanel );
                for j = 1:numPerPanel
                    hAxes = handle(obj.AxisPanelCollObj.Panel(i).Axis(j)); 
                    % Set all properties 
                    set(hAxes,pltSettings(i).Data(j));
                end
            end
        end % restorePlotSettings
        
        function loadNewData(obj, ~, ~, source, append, plotOp)
            % plotOp  0 - clear plots
            %         1 - replot using same settings while using new data
            %         2 - add new data to existing plots
            %         3 - leave plots as is
            
            % source 0 - from file
            %        1 - from Base Workspace
            
            setWaitPtr(obj);
            % Get data from user
            if source
                prompt = {'Variable Name In Base Workspace:'};
                dlg_title = 'Workspace Variable';
                num_lines = [1 50];
                currName = {''};
                options = struct('Resize','off','WindowStyle','modal','Interpreter','none');
                answer = inputdlg(prompt,dlg_title,num_lines,currName,options);
                pause(0.01);drawnow;

                if isempty(answer) || iscell(answer) && isempty(answer{:})
                    releaseWaitPtr(obj);
                    return;
                end

                try
                    x = evalin('base', answer{:});
                catch
                    msgbox(['The variable ''',answer{:}, ''' cannot be found in the base workspace.']);
                    drawnow();pause(0.5);
                    releaseWaitPtr(obj);
                    return;
                end

                if length(x) > 1
                    msgbox({'Unable to add this file because it contains more then 1 variable.',...
                        'If you have multiple runs specify them as an array of Datasets or Simulink.Outputs'});
                    drawnow();pause(0.5);
                    releaseWaitPtr(obj);
                    return;
                end

                assert( isa(x,'Simulink.SimulationOutput') || isa(x,'Simulink.SimulationData.Dataset'),'Value must be a Simulink Output or Dataset class');  
            else
                [filename, pathname] = uigetfile({'*.mat'},'Select Simulation Output or Dataset File:',obj.BrowseStartDir);
                drawnow();pause(0.5);

                if isequal(filename,0)
                    releaseWaitPtr(obj);
                    return;
                end
                obj.BrowseStartDir = pathname;

                varStruct = load(fullfile(pathname,filename));
                varNames = fieldnames(varStruct);
                if length(varNames) > 1
                    msgbox({'Unable to add this file because it contains more then 1 variable.',...
                        'If you have multiple runs specify them as an array of Datasets or Simulink.Outputs'});
                    drawnow();pause(0.5);
                    releaseWaitPtr(obj);
                    return;
                end

                x = varStruct.(varNames{1});
                assert( isa(x,'Simulink.SimulationOutput') || isa(x,'Simulink.SimulationData.Dataset'),'Value must be a Simulink Output or Dataset class');
            end
            
            updateNewData(obj ,x ,append, plotOp);
            
            releaseWaitPtr(obj);

        end % loadNewData  
        
        function updateNewData(obj , x, append, plotOp, runLabels, runColors)
            % plotOp  0 - clear plots
            %         1 - replot using same settings while using new data
            %         2 - add new data to existing plots
            %         3 - leave plots as is

            if nargin < 5
                runLabels = 'Run';
            end
            if nargin == 6
                obj.RunSpecificColors = runColors;
            end
            setWaitPtr(obj);
            % Save the tree expansion state
            saveExpansionState(obj);
            % If simdata is empty just add data and create the tree
            if isempty(obj.SimData) % Since data is empty append has no effect
                obj.SimData = x;
                updateRunNodes( obj , runLabels);
                createMatlabJTree( obj ); 
            elseif isempty(x) && ~append % if not appending and no data added
                obj.SimData = [];
                obj.RunLabel = {};
                clearAllPlots_CB( obj , [] , [] );
                createMatlabJTree( obj ); 
            elseif ~append && plotOp == 0 % Replace with new data and clear plots
                clearTree( obj );
                clearAllPlots_CB( obj , [] , [] );
                obj.SimData = x;
                updateRunNodes( obj , runLabels);
                createMatlabJTree( obj ); 
            elseif ~append && plotOp == 1 % Replace with new data and update the plots
                if obj.RebuildTreeState
                    clearTree( obj );       % REMOVE THIS ONE
                end
                obj.SimData = x;
                updateRunNodes( obj , runLabels);
                if obj.RebuildTreeState
                    createMatlabJTree( obj );   % REMOVE THIS ONE
                end
                updateAllPlots( obj );
            elseif append && plotOp == 0 % Append original data with new data and clear plots
                clearTree( obj );
                clearAllPlots_CB( obj , [] , [] );
                obj.SimData = [obj.SimData,x];
                updateRunNodes( obj , runLabels);
                createMatlabJTree( obj ); 
            elseif append && plotOp == 2 % Append original data with new data and add to existing plots
                clearTree( obj );
                obj.SimData = [obj.SimData,x];
                updateRunNodes( obj , runLabels);
                createMatlabJTree( obj ); 
                addRun2AllPlots_CB( obj , obj.RunLabel(end) );
                updateAllPlots( obj );
            elseif append && plotOp == 3 % Append original data with new data and leave plots as is
                clearTree( obj );
                obj.SimData = [obj.SimData,x];
                updateRunNodes( obj , runLabels);
                createMatlabJTree( obj ); 
            else
                error('This combination of append data and plot operations is incorrect.');
                
            end    
            % Try and restore the tree expansion state
            restoreExpansionState(obj);
            
            reSize( obj ,[] , [] );
            releaseWaitPtr(obj);
        end % updateNewData 
 
        function clearTree(obj)
            obj.SearchString = '';
            obj.FoundTreePaths = {};
            obj.FoundTreePathIndex = 1;
            obj.CurrentSelectedObject = {};
            try delete(obj.Tree); end
        end % clearTree
        
    end
    
    %% Methods - Generic PopUp Menu Cancelled
    methods
        function popUpMenuCancelled( ~ , ~ , ~ , comp )
            comp.setSelected(false);
        end % popUpMenuCancelled
    end
    
    %% Methods - Plotting
    methods
        
        function buttonClickOnLine( obj, hobj , eventdata)
            if eventdata.Button == 1

            else 
                hobj.Selected = 'on';
                axH   = ancestor(hobj,'axes');
                hcmenu = uicontextmenu; 
                uimenu(hcmenu,'Label','Clear','UserData',hobj,'Callback',@obj.clearLine);
                uimenu(hcmenu,'Label','Line Properties','Callback',{@obj.showLinePropBrowser,axH,hobj});
                uimenu(hcmenu,'Label','Add Y Data Operation','UserData',hobj,'Callback',{@obj.addDataOperation,axH,hobj,'Y'}); 
                uimenu(hcmenu,'Label','Add X Data Operation','UserData',hobj,'Callback',{@obj.addDataOperation,axH,hobj,'X'});  
                hobj.UIContextMenu = hcmenu;       
            end    
        end % buttonClickOnLine
        
        function showLinePropBrowser( obj , hobj , eventdata, axH, lineH)
            
            propBrowser = SimViewer.LinePropertyBrowser(lineH);
            
            addlistener(propBrowser,'OK_Pressed',  @(src,event) obj.closeLinePropBrowser(src,event,axH,lineH)); 
            addlistener(propBrowser,'Cancel_Pressed',  @(src,event) obj.closeLinePropBrowser(src,event,axH,lineH)); 
            
            %c = uisetcolor
            %inspect(hobj.UserData);
            drawnow;pause(0.01);
            
        end % showLinePropBrowser     
        
        function closeLinePropBrowser(obj , hobj, eventdata, axH, lineH)
            try
                if strcmp(eventdata.EventName,'Cancel_Pressed')
                    deleteFigure( hobj );
                    return;
                end

                % Update the graphical line using its handle
                lineP = eventdata.Value;
                lineP.update(lineH);

                % Update the stored line properties
                logArray = compareSignalData2lineH( obj , axH , lineH );
                axH.SignalData(logArray).LineProps = lineP;

                deleteFigure( hobj );
                lineH.Selected = 'off';
            catch
                warning('Signal data was not saved correctly.');
                deleteFigure( hobj );
            end
        end % closeLinePropBrowser
        
        function clearLine( obj , hobj , eventdata)
            % Clear the plot
            lineH = hobj.UserData;
            axH   = ancestor(lineH,'axes');
            
            logArray = compareSignalData2lineH( obj , axH , lineH );
            % Clear signal from the axis data
            if length(axH.SignalData) == 1
                % Clear axis labels
                cla(axH);
                axH.Title.String = '';axH.XLabel.String = '';axH.YLabel.String = '';
                axH.SignalData = SimViewer.SignalData.empty;
                
            else
                axH.SignalData(logArray) = [];
            end

            % delete the line object
            delete(hobj.UserData);
            
            % Update the legend and title
            lineObjs = findobj(axH,'Type','line');
            if length(lineObjs) == 1
                % Clear the legend
                delete(axH.LegendData);   
                set(get(axH,'YLabel'),'String',lineObjs.DisplayName,'Interpreter','none');  
            elseif ~isempty(lineObjs)
                axH.LegendData = legend(axH,'Location','best'); 
                set(axH.LegendData,'Interpreter','none');
            end
            
  
        end % clearLine  
        
        function clearAllPlots_CB( obj , ~ , ~ )
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    eventdata.AxisObj = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));
                    clearPlotEvent( obj , [] , eventdata);
                end  
            end
        end % clearAllPlots_CB   
        
        function clearSelectedPlots_CB( obj , ~ , ~ )
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    eventdata.AxisObj = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));
                    if strcmpi(eventdata.AxisObj.Selected,'on')
                        clearPlotEvent( obj , [] , eventdata);
                    end
                end  
            end
        end % clearSelectedPlots_CB
        
        function addRun2AllPlots_CB( obj , runLabel )
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    axH = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));
                    signalData = axH.SignalData; 
                    
                    if ~isempty(signalData)
                        % Ensure colors don't overlap
                        newColor = obj.getColor([signalData.LineProps]);
                        % Copy the properties from the first signal, there
                        % should always be at least one signal
                        tempSigData = signalData(1);
                        tempSigData.Run = runLabel; % Give the plot the new runlabel
                        tempSigData.LineProps.LineColor = newColor; % assign a new color
                        axH.SignalData = [signalData,tempSigData];
                    end
                end  
            end
        end % addRun2AllPlots_CB 
        
        function clearPagePlots_CB( obj , ~ , ~ )
            panel = obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel);
            numPerPanel = length(panel.Axis);
            for j = 1:numPerPanel
                eventdata.AxisObj = handle(panel.Axis(j));
                clearPlotEvent( obj , [] , eventdata);
            end  

            
        end % clearPagePlots_CB  
        
        function clearPlotEvent( obj , ~ , eventdata)
            % Clear the plot
            cla(eventdata.AxisObj);
            % Clear axis labels
            eventdata.AxisObj.Title.String = '';eventdata.AxisObj.XLabel.String = '';eventdata.AxisObj.YLabel.String = '';
            eventdata.AxisObj.UserTitle  = '';
            eventdata.AxisObj.UserXLabel = '';
            eventdata.AxisObj.UserYLabel = '';
            eventdata.AxisObj.UserXLim = '';
            eventdata.AxisObj.UserYLim = '';
            
            % Clear the legend
            delete(eventdata.AxisObj.LegendData);
            delete(eventdata.AxisObj.SimViewerData);
            % Turn on the grid
            grid(eventdata.AxisObj,'on');
            
            % Clear the stored signal data
            eventdata.AxisObj.SignalData = SimViewer.SignalData.empty;
        end % clearPlotEvent
        
        function plotTypeChanged( obj , ~ , eventdata)
            % Clear the plot
            grid(eventdata.AxisObj{1},'on');
            updatePlot(obj,eventdata.AxisObj{1});
        end % plotTypeChanged
               
        function addDataOperation( obj , hobj ,eventdata , axH, lineH, type )
            setWaitPtr(obj);

            % Get current stored X-Y Data
            logArray = compareSignalData2lineH( obj , axH , lineH );

            currOp = axH.SignalData(logArray).([type,'Operation']);
            
            if isempty(currOp)
                default_val = {''};
            else
                default_val = {currOp};
            end
            prompt = {['Operation performed on ',type,' data. (Use ''',lower(type),''' as the variable Example - ''',lower(type),' * pi/180''):']};
            dlg_title = 'Data Operation';
            num_lines = [1 50];
            options = struct('Resize','off','WindowStyle','modal','Interpreter','none');
            answer = inputdlg(prompt,dlg_title,num_lines,default_val,options);
            pause(0.01);drawnow;

            lineH.Selected = 'off';
            
            if isempty(answer)
                releaseWaitPtr(obj);
                return;
            end
            
            
            
            % Update the stored X-Y Data
            axH.SignalData(logArray).([type,'Operation']) = answer{:};
    
            updatePlot( obj , axH );
            
            releaseWaitPtr(obj);      
        end % addDataOperation
        
        function axisCollectionEvent( obj , hobj , eventdata )
            switch eventdata.Type
                case 'RemovePlot'
                    panel = obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel);
                    panel.removeAxis(eventdata.AxisObj);
                case 'ClearAxis'
                    clearPlotEvent( obj , [] , eventdata);
                case 'PlotTypeChanged'
                    plotTypeChanged( obj , [] , eventdata);
                case 'AddSelectedSignals'
                    addSignals2PlotAxhCallback( obj , [] , eventdata);      
            end
        end % axisCollectionEvent
        
        function addSignals2PlotAxhCallback( obj , hobj , eventdata )
            
            if ~isempty(obj.CurrentSelectedObject)
                addSignal2Plot( obj , [] , eventdata );
            end
        end % addSignals2PlotAxhCallback
		
        function logArray = compareSignalData2lineH( obj , axH , lineH )
%             if length(obj.SimData) > 1
%                 names = {axH.SignalData.DisplayName};
%             else
                names = {axH.SignalData.BasicDisplayName};
%             end
            %names = {axH.SignalData.DisplayName};
            logArray = strcmp(lineH.DisplayName, names);
        end % compareSignalData2lineH
        
        function [y, s] = getColor(obj, lineP, runIndex)
            
            s = '-';
            if nargin == 2 || isempty(runIndex) || isempty(obj.RunSpecificColors)
                if isempty(lineP)
                    y = [0, 0, 1];
                else

                    % Colors to choose from
                    color = {[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 0 1],[0 1 1],[0.5,0.5,0]};
                    for i = 7:length(lineP) + 1
                        color{i+1} = [rand(1),rand(1),rand(1)];
                    end

                    usedColors = {lineP.LineColor};
                    Ad = cat(1, color{:});
                    Bd = cat(1, usedColors{:});
                    ac = setdiff(Ad,Bd,'rows','stable');
                    availableColors = num2cell(ac,2);
                    if ~isempty(availableColors)
                        y = availableColors{1};
                    else
                        error('Unable to choose line color');
                    end
                end
            else
                
                color = obj.RunSpecificColors{runIndex};
                y = color/255;
                
                usedColors = {lineP.LineColor};
                if ~isempty(usedColors)
                    usedColorMatrix = cat(1, usedColors{:});         
                    isUsed = ismember(y,usedColorMatrix,'rows');

                    if isUsed
                        % Styles to choose from
                        styles = {'-','--',':','-.'};
                        sind = 1;
                        for i = 4:length(lineP) + 1
                            styles{i+1} = styles{sind};
                            sind = sind + 1;
                            if sind > 4
                                sind = 1;
                            end
                        end
                        usedStyles= {lineP.LineStyle};
                        availableStyles = setdiff(styles,usedStyles,'rows','stable'); 
                        if ~isempty(availableStyles)
                            s = availableStyles{1};
                        else
                            s = '-';
                            warning('Unable to choose line style');
                        end
                    end
                end
                    
            end
            
        end % getColor
            
    end
    
    %% Methods - Axis
    methods
        
        function setDragDrop( obj )
%             warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
%             obj.DropTarget = handle(javaObjectEDT('MLDropTarget'),'CallbackProperties');
%             set(obj.DropTarget,'DropCallback',{@obj.signalDropCB,obj});   
%             jFrame = get(obj.Figure,'JavaFrame');
%             jAxis = jFrame.getAxisComponent;
%             jAxis.setDropTarget(obj.DropTarget);
%             warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        end % setDragDrop

        function axesSelected( obj , hobj , eventdata )
            if eventdata.Button == 1
                hobj.SelectionHighlight = 'off';
                if strcmpi(hobj.Selected,'on')
                    hobj.Selected = 'off';
                    hobj.XColor = [0.15 0.15 0.15];
                    hobj.YColor = [0.15 0.15 0.15];
                    hobj.ZColor = [0.15 0.15 0.15];
                else
                    hobj.Selected = 'on';
                    hobj.XColor = [0 0 1];
                    hobj.YColor = [0 0 1];
                    hobj.ZColor = [0 0 1];

                end
            else
                hcmenu = uicontextmenu;
                uimenu(hcmenu,'Label','Undock','UserData',hobj,'Callback',@obj.unDockAxis);
                hobj.UIContextMenu = hcmenu;
            end
        end % axesSelected     
        
        function signalDropCB( obj , hobj , eventData , temp)
            addSignal2Plot( obj , hobj , eventData );
        end % signalDropCB
        
        function addSignal2Plot( obj , hobj , eventData )

            setWaitPtr(obj);
            % Get the axis handle for signal drop
%             hAxes = overobj(obj);
            hAxes = eventData.AxisObj;
            
            % If unable to get axis handle exit clean
            if isempty(hAxes)
                releaseWaitPtr(obj);
                return;
            end
            
            % Hold and multi-user selected states
            if ~obj.HoldPlot && ~strcmp(obj.SelectedFunction,'Multi-Run') % Normal Run
                hAxes.SignalData = obj.CurrentSelectedObject{1}.handle.UserData;
            elseif ~obj.HoldPlot && strcmp(obj.SelectedFunction,'Multi-Run') % Multi only
                for i = 1:length(obj.RunLabel)
                    signalData(i) = obj.CurrentSelectedObject{1}.handle.UserData; %#ok<AGROW>
                    signalData(i).Run = obj.RunLabel(i); %#ok<AGROW>
                end  
                hAxes.SignalData = signalData;
            else
                if obj.HoldPlot && ~strcmp(obj.SelectedFunction,'Multi-Run') % Hold only
                    signalData = obj.CurrentSelectedObject{1}.handle.UserData;
                else % Both Hold and Multi
                    for i = 1:length(obj.RunLabel)
                        signalData(i) = obj.CurrentSelectedObject{1}.handle.UserData; %#ok<AGROW>
                        signalData(i).Run = obj.RunLabel(i); %#ok<AGROW>
                    end  
                end
                hAxes.SignalData = [signalData , hAxes.SignalData];  
            end
            
            
%             % Decide to hold plot data or clear the plot
%             if obj.HoldPlot || hAxes.PlotType    
%                 hAxes.SignalData = [obj.CurrentSelectedObject{1}.handle.UserData , hAxes.SignalData];   
%             else
%                 signalData = obj.CurrentSelectedObject{1}.handle.UserData;                     
%                if strcmp(obj.SelectedFunction,'Multi-Run')
%                    for i = 1:length(obj.RunLabel)
%                        tempSigData(i) = signalData;
%                        tempSigData(i).Run = obj.RunLabel(i);
%                    end
%                    hAxes.SignalData = tempSigData; 
%                else
%                    hAxes.SignalData = signalData;  
%                end
%             end
            

            updatePlot( obj , hAxes );
            releaseWaitPtr(obj);
            drawnow();
        end % addSignal2Plot
        
        function updateAllPlots( obj )
                        
            numPanels = length(obj.AxisPanelCollObj.Panel);
            for i = 1:numPanels
                numPerPanel = length(obj.AxisPanelCollObj.Panel(i).Axis);
                for j = 1:numPerPanel
                    hAxes = handle(obj.AxisPanelCollObj.Panel(i).Axis(j));
                    
                                    
                    update2ShowAllRuns( obj, hAxes);
                
                    
                    updatePlot( obj , hAxes );
                end  
            end
        end % updateAllPlots
        
        function updatePlot( obj , hAxes )
            % start with empty an axis
            cla(hAxes); 
            % Clear axis labels
            if isempty(hAxes.UserTitle)
                hAxes.Title.String = '';
            else
                hAxes.Title.String = hAxes.UserTitle;
            end
            
            hAxes.XLabel.String = '';hAxes.YLabel.String = '';
            % Clear the legend
            delete(hAxes.LegendData);   
            delete(hAxes.SimViewerData);  
            
            signals = hAxes.SignalData;
            
            if ~hAxes.PlotType  
               % ColorSet = SimViewer.Utilities.varycolor(length(signals));
                for i = 1:length(signals)
                    
                    runIndex = find(strcmp(signals(i).Run, obj.RunLabel));
                    if numel(runIndex) > 1
                        runIndex = runIndex(end);
                    end
                    if isempty(runIndex) || runIndex > length(obj.SimData)
                        warning('Unable to find signal. The run may have been remvoved.');
                        % Remove from the singnal data from axis object
                        if length(hAxes.SignalData) == 1
                            hAxes.SignalData = SimViewer.SignalData.empty;
                        else
                            hAxes.SignalData(i) = [];
                        end
                        return;
                    end
                    if isempty(signals(i).SimulationOutputName)
                        data = find(obj.SimData(runIndex),'Name',signals(i).Name,'BlockPath',signals(i).BlockPath);
                    else
                        data = find(obj.SimData(runIndex).get(signals(i).SimulationOutputName),'Name',signals(i).Name,'BlockPath',signals(i).BlockPath);
                    end

                    % Show Run number in label if there is more than 1 run
%                     if length(obj.SimData) > 1
%                         name = signals(i).DisplayName;
%                     else
                        name = signals(i).BasicDisplayName;
%                     end
                    
                    if data.numElements ~= 1
                        warning('Cannot add signal. Either no data has been found or multiple datasets were detected.');
                        % Remove from the singnal data from axis object
                        if length(hAxes.SignalData) == 1
                            hAxes.SignalData = SimViewer.SignalData.empty;
                        else
                            hAxes.SignalData(i) = [];
                        end
                        continue; %return;
                    end

                    timehistData = data.getElement(1).Values;
                    if ~isa(timehistData,'timeseries')
                        % Look for possible bus objects
                        try
                            % Dig into the structure to find the
                            % timeseries data
                            for ind =2:length(signals(i).BusPath)
                                timehistData = timehistData.(signals(i).BusPath{ind});
                            end                            
                        end
                        if ~isa(timehistData,'timeseries')
                            % Remove from the axis object
                            if length(hAxes.SignalData) == 1
                                hAxes.SignalData = SimViewer.SignalData.empty;
                            else
                                hAxes.SignalData(i) = [];
                            end
                            return; 
                        else
                            %name = timehistData.Name;
                            %name = [timehistData.Name,' | ',signals(i).Run{1}];
                            %name = [timehistData.Name,' ( ',signals(i).Run{1},' )'];
                            
                            % Show Run number in label if there is more than 1 run
%                             if length(obj.SimData) > 1
%                                 name = [timehistData.Name,' ( ',signals(i).Run{1},' )'];
%                             else
                                name = timehistData.Name;
%                             end
                            
                        end
                    end
                    
                    % Apply Data Operations is needed
                    if isempty(signals(i).XOperation)
                        xData = timehistData.Time;
                    else
                        xData = evalDataOperation( timehistData.Time ,signals(i).XOperation, 'X' );
                    end
                    if isempty(signals(i).YOperation)
                        yData = squeeze(timehistData.Data);
                    else
                        yData = evalDataOperation( squeeze(timehistData.Data) , signals(i).YOperation, 'Y' );
                    end
                    
                    % Convert to double
                    xData = double(xData);
                    yData = double(yData);
                    
                    % Add the line to the axis
                    if isempty(signals(i).LineProps)
                        
                        % This is called for newly added lines
                        [clr, sty] = obj.getColor([signals.LineProps],runIndex);
                        newLineH = line(xData,yData,...
                            'Parent',hAxes,...
                            'Color',clr,...
                            'LineStyle', sty,...
                            'DisplayName', strtrim(name),...
                            'ButtonDownFcn',@obj.buttonClickOnLine,...
                            'Visible','on');
                        
                        signals(i).LineProps = SimViewer.LineProps(...
                                    'LineStyle', newLineH.LineStyle,...
                                    'LineWidth', newLineH.LineWidth,...
                                    'LineColor', newLineH.Color,...
                                    'MarkerStyle', newLineH.Marker,...
                                    'MarkerSize', newLineH.MarkerSize,...
                                    'MarkerFaceColor', newLineH.MarkerFaceColor,...
                                    'MarkerEdgeColor', newLineH.MarkerEdgeColor);
                                
                        hAxes.SignalData(i).LineProps = signals(i).LineProps;
                        
                    else
                        line('Parent',hAxes,...
                            'XData',xData,...
                            'YData',yData,...
                            'Color',signals(i).LineProps.LineColor,...
                            'Marker',signals(i).LineProps.MarkerStyle,...
                            'MarkerSize',signals(i).LineProps.MarkerSize,...
                            'MarkerEdgeColor',signals(i).LineProps.MarkerEdgeColor,...
                            'MarkerFaceColor',signals(i).LineProps.MarkerFaceColor,...
                            'LineStyle',signals(i).LineProps.LineStyle,... 
                            'LineWidth',signals(i).LineProps.LineWidth,... 
                            'DisplayName',strtrim(name),...
                            'ButtonDownFcn',@obj.buttonClickOnLine,...
                            'Visible','on');
                    end
                end
                % Turn on the grid
                grid(hAxes,'on');
                % Find all line objects on the axes
                lineObjs = findobj(hAxes,'Type','line');
                if ~isempty(lineObjs) % If no data exists skip labels
                    % Set X Limit
                    if ~isempty(hAxes.UserXLim)
                        hAxes.XLim = hAxes.UserXLim; 
                    else
                         set(hAxes,'XLimMode','auto');
                    end 
                    % Set Y Limit
                    if ~isempty(hAxes.UserYLim)
                        hAxes.YLim = hAxes.UserYLim; 
                    else
                        set(hAxes,'YLimMode','auto');
                    end 
                    % Set X Axis Label
                    if isempty(hAxes.UserXLabel)
                        %set(get(hAxes,'XLabel'),'String','Time (s)','Interpreter','none'); 
                        set(get(hAxes,'XLabel'),'String',getAutoAxisLabel('Time (s)',signals,'X'),'Interpreter','none'); 
                    else
                        set(get(hAxes,'XLabel'),'String',hAxes.UserXLabel,'Interpreter','none'); 
                    end
                    % Set Legend or Y Axis Label
                    if length(lineObjs) == 1 || length(unique({lineObjs.DisplayName})) == 1
                        if isempty(hAxes.UserYLabel)
                            %set(get(hAxes,'YLabel'),'String',lineObjs.DisplayName,'Interpreter','none');  
                            set(get(hAxes,'YLabel'),'String',getAutoAxisLabel(lineObjs(1).DisplayName,signals(1),'Y'),'Interpreter','none'); 
                        else
                            set(get(hAxes,'YLabel'),'String',hAxes.UserYLabel,'Interpreter','none');  
                        end
                    else
                        hAxes.LegendData = legend(hAxes,'Location','best'); 
                        set(hAxes.LegendData,'Interpreter','none');
                        if ~isempty(hAxes.UserYLabel)
                            set(get(hAxes,'YLabel'),'String',hAxes.UserYLabel,'Interpreter','none');  
                        end
                        
                    end
                end
                
            else
                if length(signals) == 1 || length(signals) > 2  
                    if length(signals) > 2  
                        signals = hAxes.SignalData(1);
                        hAxes.SignalData = signals;
                    end
                        runIndex = strcmp(signals.Run, obj.RunLabel);
                        if isempty(signals.SimulationOutputName)
                            data = find(obj.SimData(runIndex),'Name',signals.Name,'BlockPath',signals.BlockPath);
                        else
                            data = find(obj.SimData(runIndex).get(signals.SimulationOutputName),'Name',signals.Name,'BlockPath',signals.BlockPath);
                        end
                        
                        name = signals.Name;
                        if data.numElements ~= 1
                            warning('Cannot add signal. Either no data has been found or multiple datasets were detected.');
                            % Remove from the axis object
                            hAxes.SignalData = SimViewer.SignalData.empty;
                            return;
                        end

                        timehistData = data.getElement(1).Values;
                        if ~isa(timehistData,'timeseries')
                            % Look for possible bus objects
                            try
                                % Dig into the structure to find the
                                % timeseries data
                                for ind =2:length(signals.BusPath)
                                    timehistData = timehistData.(signals.BusPath{ind});
                                end                            
                            end
                            if ~isa(timehistData,'timeseries')
                                % Remove from the axis object
                                 hAxes.SignalData = SimViewer.SignalData.empty;
                                return; 
                            else
                                name = timehistData.Name;
                            end
                        end

                        grid(hAxes,'off');
                        hAxes.SimViewerData = text(hAxes, 0.4, 0.5, {['X = ',name],'Add Y Data to show the plot.'}, 'Color', 'Blue', 'Interpreter','none');
                elseif length(signals) == 2 
                        grid(hAxes,'on');
                        % Init timeseries array
                        %timehistData(2) = timeseries;
                        timehistData = cell(1,2);
                        for i=1:2
                            runIndex = strcmp(signals(i).Run, obj.RunLabel);      
                            if isempty(signals(i).SimulationOutputName)
                                data = find(obj.SimData(runIndex),'Name',signals(i).Name,'BlockPath',signals(i).BlockPath);
                            else
                                data = find(obj.SimData(runIndex).get(signals(i).SimulationOutputName),'Name',signals(i).Name,'BlockPath',signals(i).BlockPath);
                            end
                        
                            if data.numElements ~= 1
                                warning('Cannot add signal. Either no data has been found or multiple datasets were detected.');
                                % Remove from the axis object
                                if length(hAxes.SignalData) == 1
                                    hAxes.SignalData = SimViewer.SignalData.empty;
                                else
                                    hAxes.SignalData(i) = [];
                                end
                                return;
                            end

                            timehistData{i} = data.getElement(1).Values;
                            if ~isa(timehistData{i},'timeseries')
                                % Look for possible bus objects
                                try
                                    % Dig into the structure to find the
                                    % timeseries data
                                    for ind =2:length(signals(i).BusPath)
                                        timehistData{i} = timehistData{i}.(signals(i).BusPath{ind});
                                    end                            
                                end
                                if ~isa(timehistData{i},'timeseries')
                                    % Remove from the axis object
                                    if length(hAxes.SignalData) == 1
                                        hAxes.SignalData = SimViewer.SignalData.empty;
                                    else
                                        hAxes.SignalData(i) = [];
                                    end
                                    return; 
                                end
                            end
   
                        end
                        % Add the line to the axis
                        set(get(hAxes,'XLabel'),'String',timehistData{2}.Name,'Interpreter','none'); 
                        set(get(hAxes,'YLabel'),'String',timehistData{1}.Name,'Interpreter','none'); 
                        
                        xData = squeeze(timehistData{2}.Data);
                        yData = squeeze(timehistData{1}.Data);
                    
                        line(xData,yData,...
                            'Parent',hAxes,...
                            'Color','b',...
                            'DisplayName', strtrim([timehistData{2}.Name,' x ',timehistData{1}.Name]),...
                            'ButtonDownFcn',@obj.buttonClickOnLine,...
                            'Visible','on');
                end  
            end
        end % updatePlot
        
        function unDockAxis( obj , hobj , eventdata )
            
            newfH  = figure( ...
                'Name', hobj.UserData.Title.String, ...
                'NumberTitle', 'off');

            leg = hobj.UserData.UserData;
            newAxH = copyobj([hobj.UserData,leg],newfH);

            newAxH(1).Units = 'Normal';
            newAxH(1).OuterPosition = [ 0 , 0 , 1 , 1 ];
            delete ( findobj ( ancestor(hobj,'figure','toplevel'), 'type','uicontextmenu' ) );
            delete ( findobj ( ancestor(newAxH(1),'figure','toplevel'), 'type','uicontextmenu' ) );
        end % unDockAxis
        
        function update2ShowAllRuns( obj, hAxes )
                                  
            signals = hAxes.SignalData;
            if isempty(signals)
                return;
            end
            
            paths = cell(length(signals), 1);
            for i = 1:length(signals)
                tempPath = signals(i).BlockPath.convertToCell;
                tempFullPath = strjoin(tempPath,'/');
                if isempty(signals(i).BusPath)
                    paths{i,1} = [tempFullPath ,'/',signals(i).Name];
                else
                    paths{i,1} = [tempFullPath ,'/',strjoin(signals(i).BusPath,'/')];
                end
            end
            
            [~, ia] = unique(paths);
            
            uniqueSignals = signals(ia);
            
            ind = 1;
            for j = 1:length(uniqueSignals)
                
                for i = 1:length(obj.RunLabel)
                    tempSigData(ind) = uniqueSignals(j); %#ok<AGROW>
                    tempSigData(ind).Run = obj.RunLabel(i); %#ok<AGROW>
                    if length(obj.RunSpecificColors) >= i && ~isempty(obj.RunSpecificColors)
                        tempSigData(ind).LineProps.LineColor = obj.RunSpecificColors{i}/255; %#ok<AGROW>
                    end
                    ind = ind + 1;
                end
                
            end
            
            hAxes.SignalData = tempSigData; 
        end %update2ShowAllRuns
       
    end    
    
    %% Methods - Search Tree
    methods
        
        function searchTreeEditBox( obj , hobj , eventdata )
            obj.SearchString = strtrim(hobj.String);
            obj.FoundTreePaths = {};
            obj.FoundTreePathIndex = 1;
            
            searchDnButtonPressed( obj , [] , [] );
            checkPathsFound(obj);
            % Collapse main nodes when search comes up empty
%             if isempty(obj.FoundTreePaths)
%                 collapseRunNodes( obj );
%                 obj.Tree.setSelectedNode([]);
%                 obj.Tree.repaint;
%             end
        end % searchTreeEditBox
            
        function searchUpButtonPressed( obj , ~ , ~ )
            
            if isempty(obj.SearchString);return;end;
            
            if isempty(obj.FoundTreePaths) && ~isempty(obj.SearchString)
                type = findSearchType( obj );
                obj.FoundTreePaths = findNodePath(obj.Root, obj.SearchString, type);
                obj.FoundTreePathIndex = 1;
                if isempty(obj.FoundTreePaths);return;end; % Search didn't find anything
            else
                if obj.FoundTreePathIndex == 1
                    obj.FoundTreePathIndex = length(obj.FoundTreePaths);
                else
                    obj.FoundTreePathIndex = obj.FoundTreePathIndex - 1;
                end 
            end 
            
            jTreePath = javax.swing.tree.TreePath(obj.FoundTreePaths{obj.FoundTreePathIndex});
            treePath =  obj.FoundTreePaths{obj.FoundTreePathIndex}(end);
%             obj.Tree.Tree.scrollPathToVisible(jTreePath);
%             obj.Tree.setSelectedNode(treePath);
            obj.Tree.setSelectedNode(treePath);
            drawnow();pause(0.1);
            obj.Tree.Tree.scrollPathToVisible(jTreePath);
            drawnow();pause(0.1);
            obj.Tree.repaint;

        end % searchUpButtonPressed
        
        function searchDnButtonPressed( obj , ~ , ~ )
            
            if isempty(obj.SearchString);return;end;
            
            if isempty(obj.FoundTreePaths) && ~isempty(obj.SearchString)
                type = findSearchType( obj );
                obj.FoundTreePaths = findNodePath(obj.Root, obj.SearchString, type);
                obj.FoundTreePathIndex = 1;
                if isempty(obj.FoundTreePaths);return;end; % Search didn't find anything
            else
                if obj.FoundTreePathIndex == length(obj.FoundTreePaths)
                    obj.FoundTreePathIndex = 1;
                else
                    obj.FoundTreePathIndex = obj.FoundTreePathIndex + 1;
                end 
            end 
            
            jTreePath = javax.swing.tree.TreePath(obj.FoundTreePaths{obj.FoundTreePathIndex});
            treePath =  obj.FoundTreePaths{obj.FoundTreePathIndex}(end);
%             obj.Tree.Tree.scrollPathToVisible(jTreePath);  
%             obj.Tree.setSelectedNode(treePath);
            obj.Tree.setSelectedNode(treePath);
            drawnow();pause(0.1);
            obj.Tree.Tree.scrollPathToVisible(jTreePath);  
            drawnow();pause(0.1);
            obj.Tree.repaint;
            
            % expand(node)
            %obj.Tree.Tree.scrollPathToVisible(jTreePath)
            %obj.Tree.scrollPathToVisible(treePath);
        end % searchDnButtonPressed
        
        function collapseRunNodes( obj )
            for i = 1:length(obj.RunNodes)
                obj.Tree.collapse(obj.RunNodes(i));
            end
        end % collapseRunNodes
        
        function matchCase_CB( obj , hobj , eventdata )
            
            obj.MatchCase = eventdata.getSource.isSelected;
            obj.FoundTreePaths = {};
            obj.FoundTreePathIndex = 1;
            searchDnButtonPressed( obj , [] , [] );
            checkPathsFound(obj);
        end % matchCase_CB
        
        function matchWholeWord_CB( obj , hobj , eventdata )
            
            obj.MatchWholeWord = eventdata.getSource.isSelected;
            obj.FoundTreePaths = {};
            obj.FoundTreePathIndex = 1;
            searchDnButtonPressed( obj , [] , [] );
            checkPathsFound(obj);
        end % matchWholeWord_CB
        
        function checkPathsFound(obj)   
            % Collapse main nodes when search comes up empty
            if isempty(obj.FoundTreePaths)
                collapseRunNodes( obj );
                obj.Tree.setSelectedNode([]);
                obj.Tree.repaint;
            end
        end % checkPathsFound
        
        function y = findSearchType( obj )
            y = 2;
            if obj.MatchCase && obj.MatchWholeWord
                y = 1;
            elseif ~obj.MatchCase && obj.MatchWholeWord
                y = 2;
            elseif obj.MatchCase && ~obj.MatchWholeWord
                y = 3;
            elseif ~obj.MatchCase && ~obj.MatchWholeWord
                y = 4;
            end
        end % findSearchType
        
        function searchTreeKeyPressed( obj , hobj , eventdata )
            
            keyCode = eventdata.getKeyCode;
            if keyCode == 38 
                searchUpButtonPressed( obj , [] , [] );
            elseif keyCode == 40
                searchDnButtonPressed( obj , [] , [] );
            end
        end % searchTreeKeyPressed
        
    end
    
    %% Methods - Tree
    methods
        
        function createTreeSearchContainer( obj )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );
            
            position = getpixelposition(obj.SimulationDataSelection);
            % Create Search Box
            obj.SearchString_EB = uicontrol(...
                'Parent',obj.SimulationDataSelection,...
                'Style','edit',...
                'String', obj.SearchString,...
                'FontSize',8,...%'FontWeight','bold',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Position',[ 1 , position(4) - 30 , position(3) , 30 ],...
                'Enable','on',...
                'HorizontalAlignment','left',...
                'Callback',@obj.searchTreeEditBox);
            
            upJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            upJButton.setText('');        
            upJButtonH = handle(upJButton,'CallbackProperties');
            set(upJButtonH, 'ActionPerformedCallback',@obj.searchUpButtonPressed)
            myIcon = fullfile(icon_dir,'LoadedArrow_16_Blue_UP.png');
            upJButton.setIcon(javax.swing.ImageIcon(myIcon));
            upJButton.setToolTipText('Search Up'); %obj.UpButtonHComp.setFlyOverAppearance(false)
            upJButton.setFlyOverAppearance(false);
            upJButton.setBorder(javax.swing.border.LineBorder(java.awt.Color.BLACK, 1));                    %obj.UpButtonHComp.setBorder(javax.swing.border.LineBorder(java.awt.Color.BLACK, 1))
            upJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            upJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            upJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            [obj.UpButtonHComp,obj.UpJButtonHCont] = javacomponent(upJButton, [], obj.SimulationDataSelection); 

            dnJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            dnJButton.setText('');        
            dnJButtonH = handle(dnJButton,'CallbackProperties');
            set(dnJButtonH, 'ActionPerformedCallback',@obj.searchDnButtonPressed)
            myIcon = fullfile(icon_dir,'LoadedArrow_16_Blue.png');
            dnJButton.setIcon(javax.swing.ImageIcon(myIcon));
            dnJButton.setToolTipText('Search Down');
            dnJButton.setFlyOverAppearance(false);%obj.DnButtonHComp.setFlyOverAppearance(false)
            dnJButton.setBorder(javax.swing.border.LineBorder(java.awt.Color.BLACK, 1));   %obj.DnButtonHComp.setBorder(javax.swing.border.LineBorder(java.awt.Color.BLACK, 1))
            dnJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            dnJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            dnJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            [obj.DnButtonHComp,obj.DnJButtonHCont] = javacomponent(dnJButton, [], obj.SimulationDataSelection);     

    
            % Match Case Button             
            matchCaseJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
            matchCaseJCheckbox.setText('Match Case');        
            matchCaseJCheckboxH = handle(matchCaseJCheckbox,'CallbackProperties');
            set(matchCaseJCheckboxH, 'ActionPerformedCallback',@obj.matchCase_CB)
            matchCaseJCheckbox.setToolTipText('Match case of the search string');
            matchCaseJCheckbox.setBorder([]);
            matchCaseJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.JRibbonPanel.add(matchCaseJCheckbox);
            obj.MatchCaseJCheckbox = matchCaseJCheckbox;
            [obj.MatchCaseJCheckboxHComp,obj.MatchCaseJCheckboxHCont] = javacomponent(matchCaseJCheckbox, [], obj.SimulationDataSelection);

            % Match Whole Word Button             
            matchWordJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
            matchWordJCheckbox.setText('Match Whole Word');        
            matchWordJCheckboxH = handle(matchWordJCheckbox,'CallbackProperties');
            set(matchWordJCheckboxH, 'ActionPerformedCallback',@obj.matchWholeWord_CB)
            matchWordJCheckbox.setToolTipText('Match the entire search string word');
            matchWordJCheckbox.setBorder([]);
            matchWordJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.JRibbonPanel.add(matchWordJCheckbox);
            obj.MatchWholeWordJCheckbox = matchWordJCheckbox;
            [obj.MatchWholeWordJCheckboxHComp,obj.MatchWholeWordJCheckboxHCont] = javacomponent(matchWordJCheckbox, [], obj.SimulationDataSelection);
        
            createMatlabJTree( obj );
        
        end % createTreeSearchContainer

        function createMatlabJTree( obj )
            import javax.swing.*
            import javax.swing.tree.*;
    warning('off','MATLAB:uitree:DeprecatedFunction'); 
    warning('off','all');
            position = getpixelposition(obj.SimulationDataSelection);

            obj.Root = uitreenode('v0','root', 'RootNode', [], 0);

            obj.TreeModel = DefaultTreeModel( obj.Root );  
            [obj.Tree, obj.TreeContainer] = uitree('v0',obj.Figure );
            set(obj.TreeContainer, 'Parent',obj.SimulationDataSelection);
            set(obj.TreeContainer, 'Visible','on');
            set(obj.TreeContainer, 'Units','pixels');
            set(obj.TreeContainer, 'Background','w');
            set(obj.TreeContainer, 'position',[ 1 , 1 , position(3) , position(4) - 30 ]);
            obj.Tree.setModel( obj.TreeModel );

            set(obj.Tree, 'NodeSelectedCallback', @obj.nodeSelected_CB );
            set(obj.Tree, 'NodeDroppedCallback', @obj.nodeDroppedCB); 
            
            obj.HJTree = handle(obj.Tree.getTree,'CallbackProperties');
            set(obj.HJTree, 'MousePressedCallback',@obj.mousePressedInTree_CB);
            set(obj.HJTree, 'KeyPressedCallback', @obj.searchTreeKeyPressed );
            
            obj.HJTree.getSelectionModel().setSelectionMode(TreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION);
                    
            for i = 1:length(obj.SimData)
  
                node = uitreenode('v0','',...
                    obj.RunLabel(i), [], 0);

                node.setUserObject('JavaImage_simulink');
                node.setIcon(obj.JavaImage_simulink);
                obj.Root.add(node); 
                obj.RunNodes(i) = node;  
                
                % Find singal logging and output names
                switch class(obj.SimData(i))
                    case 'Simulink.SimulationOutput' % output of the "sim" function
                        loggedVars = obj.SimData(i).who;
%                         loggedVars = {'SignalLog'};
                        for sl = 1:length(loggedVars)
                            simOUT = obj.SimData(i).get(loggedVars{sl});
                            % Add the Node
                            logNode = uitreenode('v0','',...
                            loggedVars{sl}, [], 0);
                            logNode.setUserObject('JavaImage_output');
                            logNode.setIcon(obj.JavaImage_output);
                            node.add(logNode); 
                            switch class(simOUT)
                                case 'Simulink.SimulationData.Dataset' % Saved signal logging
                                    for j=1:simOUT.numElements
                                        buildTreeFromSignal(obj, simOUT.get(j) , logNode, obj.RunLabel(i), loggedVars{sl});
                                    end
                                otherwise
                                    warning(['[Unsupported data class - ',class(simOUT),'.']);
                                    continue;
                            end
                            %addNodeData( obj , simOUT , logNode );
                        end  
                    case 'Simulink.SimulationData.Dataset' % Saved signal logging
                        for j=1:obj.SimData(i).numElements
                            buildTreeFromSignal(obj, obj.SimData(i).get(j) , obj.RunNodes(i), obj.RunLabel(i), []);
                        end
                    otherwise
                        error(['[Unsupported data class - ',class(obj.SimData(i)),'.']);
                end       
            end
            
            obj.HJTree.expandRow(0);
            obj.HJTree.setRootVisible(false);
            obj.HJTree.setShowsRootHandles(true);
            warning('on','MATLAB:uitree:DeprecatedFunction'); 
        end %  createMatlabJTree 
        
        function obj = buildTreeFromSignal(obj, signal , root, runLabel, simulationOutputName)
                 
            % Get cell array of the path
            if obj.SortBySubsystem
                pathString = strjoin(signal.BlockPath.convertToCell,'/'); 
            else
                L = signal.BlockPath.getLength;
                pathString = signal.BlockPath.getBlock(L); 
            end 
            strings = strsplit(pathString,'/');
            % Replace the last path parameter with the signal name
            strings{end} = signal.Name;
            %strings{end+1} = signal.Name;

            node = root;% 

            % Iterate of the string array
            for i = 1:length(strings) 
                % Look for the index of a node at the current level that
                % has a value equal to the current string
                index = childIndex(node, strings{i});

                % Index less than 0, this is a new node not currently present on the tree
                if (index < 0) 
                    % Add the new node
                    newChild = uitreenode('v0','',strings{i}, [], 0);
                    if i == length(strings)
                        addNodeUserObject( obj , signal , newChild , runLabel, simulationOutputName);
                    end
                    obj.TreeModel.insertNodeInto(newChild,node,node.getChildCount());
                    node = newChild;
                % Else, existing node, skip to the next string
                else
                    node = node.getChildAt(index);
                end
            end          
        end  % buildTreeFromSignal
        
        function addNodeUserObject( obj , signal , node , runLabel, simulationOutputName)
            % Add Data
            switch class(signal.Values)
                case 'timeseries'
                    node.setUserObject('JavaImage_signalLog');
                    node.setIcon(obj.JavaImage_signalLog);
                    node.UserData = SimViewer.SignalData('Name', signal.Name, 'BlockPath', signal.BlockPath, 'BusPath', {}, 'Run', runLabel, 'SimulationOutputName', simulationOutputName);
                case 'struct'    
                    node.setUserObject('JavaImage_bus');
                    node.setIcon(obj.JavaImage_bus);
                    %node.UserData = signal;
                    addBusHierarchy( obj , signal.Values , node , signal , {signal.Name} , runLabel, simulationOutputName);

                case 'double'


            end
            
        end % addNodeUserObject
        
        function addBusHierarchy( obj , sigVal , node , signal , path , runLabel, simulationOutputName)

            childNames = fieldnames(sigVal);
            for j = 1:length(childNames)
                
                child =  sigVal.(childNames{j});
                childNode  = uitreenode(...
                    'v0','', childNames{j} , [], 0);
                childNode.setUserObject('JavaImage_signalLog');
                childNode.setIcon(obj.JavaImage_signalLog);
                
                %childNode.UserData = child;
                node.add(childNode);
                
                if isstruct(child)
                    childNode.setUserObject('JavaImage_bus');
                    childNode.setIcon(obj.JavaImage_bus);
                    
                    newPath = [path,childNames{j}];
                    usrData = SimViewer.SignalData('Name', signal.Name, 'BlockPath', signal.BlockPath, 'BusPath', newPath, 'Run', runLabel, 'SimulationOutputName', simulationOutputName);
                    childNode.UserData = usrData;                    
                    
                    addBusHierarchy( obj , child , childNode , signal , newPath , runLabel, simulationOutputName);
                else     
                    newPath = [path,childNames{j}];
                    usrData = SimViewer.SignalData('Name', signal.Name, 'BlockPath', signal.BlockPath, 'BusPath', newPath, 'Run', runLabel, 'SimulationOutputName', simulationOutputName);
                    childNode.UserData = usrData;  
                end
            end
   
        end % addBusHierarchy  
        
    end
    
    %% Methods - Tree Functions and Callbacks
    methods
        
        function expandAll( obj , hobj , eventdata , node )
            treepath = node.getPath;
            jTreePath = javax.swing.tree.TreePath(treepath);
            expandAll(obj.Tree.Tree , jTreePath);
            %obj.Tree.Tree.repaint;
        end % expandAll
        
        function collapseAll( obj , hobj , eventdata , node )
            treepath = node.getPath;
            jTreePath = javax.swing.tree.TreePath(treepath);
            expandAll(obj.Tree.Tree , jTreePath , true );
            %obj.Tree.Tree.repaint;
        end % collapseAll
        
        function saveExpansionState(obj)
            if isempty(obj.HJTree);return;end;
            obj.HJTree.setRootVisible(true);
            obj.NodeExpansionState = [];
            for i = 0:obj.HJTree.getRowCount() - 1
                if obj.HJTree.isExpanded(i)
                    obj.NodeExpansionState(end+1) = i;
                end
            end
            obj.HJTree.setRootVisible(false);
        end % saveExpansionState
        
        function restoreExpansionState(obj)
            if isempty(obj.HJTree);return;end;
            for i =1:length(obj.NodeExpansionState)
                obj.HJTree.expandRow(obj.NodeExpansionState(i));          
            end
        end % restoreExpansionState
        
        function removeSimulaitonData_CB( obj , hobj , eventdata , node)
            
            logArray = strcmp(char(node.getName),obj.RunLabel);
            obj.SimData(logArray) = [];
            obj.TreeModel.removeNodeFromParent(node);
        end % removeSimulaitonData_CB
    
        function dragEnteredInTree( obj , hobj , eventdata )
            
%             disp('Drag Entered');
        end % dragEnteredInTree
        
        function nodeDroppedCB( obj , hobj , eventdata )
            
%             disp('Test drop');
        end % nodeDroppedCB
          
        function renameRun( obj , ~ , ~ , node )
            prompt = {'Name:'};
            dlg_title = 'Rename';
            num_lines = 1;
            currName = {char(node.getName)};
            options = struct('Resize','off','WindowStyle','modal','Interpreter','none');
            answer = inputdlg(prompt,dlg_title,num_lines,currName,options);
            pause(0.01);drawnow;
            if ~(isempty(answer) || iscell(answer) && isempty(answer{:}))
                node.setName(answer(:));
                obj.HJTree.treeDidChange();   
                
                logArray = strcmp(currName , obj.RunLabel);
                obj.RunLabel{logArray} = answer(:);
            end

        end % renameNode
        
        function copyPath( obj , ~ , ~ , node )
            signalData = node.handle.UserData;
            
            if isprop(signalData,'BlockPath') 
                length = signalData.BlockPath.getLength;
                bPath = signalData.BlockPath.getBlock(length);
                clipboard('copy',bPath)
            end

        end % copyPath
        
        function goToBlock( obj , ~ , ~ , node )
            signalData = node.handle.UserData;
            % path=getfullname(handle)
            if isprop(signalData,'BlockPath') 
                length = signalData.BlockPath.getLength;
                bPath = signalData.BlockPath.getBlock(length);
                try
                    blocks = strsplit(bPath,'/');
                    open_system(blocks{1});
                    hilite_system(bPath,'find');
                catch mexc
                    error('Model does not exist or is not on the path.')
                end
            end

        end % goToBlock
        
        function removeSignalFromModel( obj , ~ , ~ , node )
            
            
            
            
            L = find_system('vdp','FindAll','on','type','line')
            
            
            signalData = node.handle.UserData;
            % path=getfullname(handle)
            if isprop(signalData,'BlockPath') 
                length = signalData.BlockPath.getLength;
                bPath = signalData.BlockPath.getBlock(length);
                try
                    blocks = strsplit(bPath,'/');
                    open_system(blocks{1});
                    hilite_system(bPath,'find');
                catch mexc
                    error('Model does not exist or is not on the path.')
                end
            end

        end % removeSignalFromModel
   
        function tsData2WrkSpc( obj , ~ , ~ , node )

        end % tsData2WrkSpc
        
    end
    
    %% Methods - Decrepitated
    methods   
                
        function refreshPlots( obj )
            for i = 1:obj.AxisPanelCollObj.AxisHandleQueue.size
                
                axH = obj.AxisPanelCollObj.AxisHandleQueue.get(i - 1);
                allNodePaths = get(handle(axH),'NodePath2Data');
                if ~isempty(allNodePaths) && ~isnumeric(allNodePaths{1})
                    nodeObjs = allNodePaths;
                else
                    nodeObjs = cell(1,length(allNodePaths));
                    for j = 1:length(allNodePaths)   
                        rootNode = obj.TreeModel.getRoot();
                        nodePath = allNodePaths{j};
                        for k = 1:length(nodePath)
                            rootNode = rootNode.getChildAt(nodePath(k));
                        end
                        nodeObjs{j} = rootNode;
                    end
                
                end
                lineObjs = findobj(handle(axH), 'type', 'line');
                
                for j = 1:length(nodeObjs)
                    logArray = strcmp(char(nodeObjs{j}.getName) , {lineObjs.DisplayName});
                    data = nodeObjs{j}.handle.UserData;
                    if isa(data,'Simulink.SimulationData.Signal')
                        lineObjs(logArray).XData = data.Values.Time;
                        lineObjs(logArray).YData = squeeze(data.Values.Data);   
                    elseif isa(data,'timeseries')
                        lineObjs(logArray).XData = data.Time;
                        lineObjs(logArray).YData = squeeze(data.Data);
                    end
                    
                end
                
            end
            
        end % refreshPlots
        
        function clearPlots( obj )
            for i = 1:obj.AxisPanelCollObj.AxisHandleQueue.size
                
                ax = obj.AxisPanelCollObj.AxisHandleQueue.get(i - 1);
                axH = handle(ax);
                %Clear current axis objects only when 'Hold' button is off
                cla(axH); 
                % Clear stored timehistory data
                axH.TimeHistoryData = timeseries.empty;
                % Clear the nodedata
                axH.NodeData = nodedata.empty;
                % Clear axis title and strings
                axH.Title.String = '';axH.XLabel.String = '';axH.YLabel.String = '';
                grid(axH,'off');
                % Clear the legend
                delete(axH.UserData);
            end
            
        end % clearPlots
        
        function obj = buildTreeFromString(obj, str , root)
            % Fetch the root node
            %root = model.getRoot();
                 
            % Split the string around the delimiter
            strings = strsplit(str,'/');

            % Create a node object to use for traversing down the tree as it 
            % is being created
            node = root;% 

            % Iterate of the string array
            for i = 1:length(strings) 
                % Look for the index of a node at the current level that
                % has a value equal to the current string
                index = childIndex(node, strings{i});

                % Index less than 0, this is a new node not currently present on the tree
                if (index < 0) 
                    % Add the new node
                    newChild = uitreenode('v0','',strings{i}, [], 0);
                    obj.TreeModel.insertNodeInto(newChild,node,node.getChildCount());
                    node = newChild;
                % Else, existing node, skip to the next string
                else
                    node = node.getChildAt(index);
                end
            end          
        end
        
        function createJavaTree( obj , parent )
            
            pathList = {};
            for i = 1:length(obj.SimData)
                % Find singal logging and output names
                if isa(obj.SimData(i),'Simulink.SimulationOutput') % output of the "sim" function
                    
                else isa(obj.SimData(i),'Simulink.SimulationData.Dataset') % Saved signal logging
                    obj.SortBySubsystem =false
                    if obj.SortBySubsystem
                        for j = 1:obj.SimData(i).numElements
                            pathList{end+1} = strjoin(obj.SimData(i).get(j).BlockPath.convertToCell,'/'); %#ok<AGROW>
                        end
                    else
                        for j = 1:obj.SimData(i).numElements
                            L = obj.SimData(i).get(j).BlockPath.getLength;
                            pathList{end+1} = obj.SimData(i).get(j).BlockPath.getBlock(L); %#ok<AGROW>
                        end
                    end

                end

            end
            
            str = javaArray('java.lang.String',length(pathList));
            for i = 1:length(pathList)
                str(i) = java.lang.String(pathList{i});
            end
            
            panel = SimViewTreePanel(str);
%             panel.setLayout([]);
            if 0
                    
                f = javaObjectEDT('javax.swing.JFrame'); 
                

                f.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
                f.add(panel);
                f.setSize(300, 300);
                f.setLocation(200, 200);
                f.setVisible(true);
            else
                

                
                panel.setLayout(java.awt.GridLayout(0, 1));
                
                obj.JScroll = javaObjectEDT(javax.swing.JScrollPane(panel));
                [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], parent);
                set(obj.HContainer,'Units','Normal');
                set(obj.HContainer,'Position',[ 0 , 0 , 1 , 1 ]);
                
                
%                 [obj.JTreeComp,obj.JTreeCont] = javacomponent(panel,[ 0, 0, 1, 1 ],parent);
%                 obj.JTreeCont.Units = 'Normal';
%                 obj.JTreeCont.Position = [0,0,1,1];
            end
        end %  createJavaTree
          
        function childnode = addNodeSub( obj , name , data , parentNode)
            
            numOfChildNodes = parentNode.getChildCount;
            childNames = {};
            for i = 1:numOfChildNodes
                childNames{i} = parentNode.getChildAt(i - 1).getName;
            end
            
            if any(strcmp( name , childNames))
                childnode =  parentNode;
            else
            
                childnode = uitreenode('v0','',...
                    name, [], 0);
                childnode.setUserObject('JavaImage_signalLog');
                childnode.setIcon(obj.JavaImage_signalLog);
                childnode.UserData = data;
                parentNode.add(childnode); 
%                 obj.TreeModel.insertNodeInto(...
%                     parentNode,...
%                     childnode,...
%                     childnode.getChildCount());
            end
           
        end % addNodeSub
        
        function addNodeData( obj , simOUT , logNode )
            % Add Data
            switch class(simOUT)
                case 'Simulink.SimulationData.Dataset'
                    for j = 1:simOUT.numElements
                        signal = simOUT.get(j);
                        childnode  = uitreenode(...
                            'v0','',assignName( obj , signal ), [], 0);
                        childnode.setUserObject('JavaImage_signalLog');
                        childnode.setIcon(obj.JavaImage_signalLog);
                        childnode.UserData = signal;
                        logNode.add(childnode);  

                        if isstruct(signal.Values)
                            childnode.setUserObject('JavaImage_bus');
                            childnode.setIcon(obj.JavaImage_bus);
                            addSignalHierarchy( obj , signal.Values , childnode );
                        end
                    end   
                case 'timeseries'
                    for j = 1:length(simOUT)
                        signal = simOUT(j);
                        if isempty(signal.Name)
                            name = 'Unknown';
                        else
                            name = signal.Name;
                        end
                        childnode = uitreenode('v0','',...
                            name, [], 0);
                        childnode.setUserObject('JavaImage_signalLog');
                        childnode.setIcon(obj.JavaImage_signalLog);
                        childnode.UserData = signal;
                        logNode.add(childnode);

                    end
                case 'Simulink.SimulationData.Signal'    
                   for j = 1:length(simOUT)
                            if isempty(simOUT(j).Name)
                                name = 'Unknown';
                            else
                                name = simOUT(j).Name;
                            end
                            signal = simOUT(j);
                            childnode = uitreenode('v0','',...
                                name, [], 0);
                            childnode.setUserObject('JavaImage_signalLog');
                            childnode.setIcon(obj.JavaImage_signalLog);
                            childnode.UserData = signal;
                            logNode.add(childnode);
                            
                       if isa(simOUT(j).Values,'timeseries')
                            
                       elseif isstruct(simOUT(j).Values)
                            childnode.setUserObject('JavaImage_bus');
                            childnode.setIcon(obj.JavaImage_bus);
                            addSignalHierarchy( obj , signal.Values , childnode );
                       end
                   end
                case 'double'
% %                     if isempty(obj.SimulationTime)
% %                         %continue;
% %                     end
% %                     for j = 1:size(simOUT,2)
% %                         name = ['Out',' ',int2str(j)];
% %                         ts = timeseries(simOUT(:,j),obj.SimulationTime,'Name',name);
% %                         childnode = uitreenode('v0','',...
% %                             name, [], 0);
% %                         childnode.setUserObject('JavaImage_signalLog');
% %                         childnode.setIcon(obj.JavaImage_signalLog);
% %                         childnode.UserData = ts;
% %                         logNode.add(childnode);
% % 
% %                     end    

            end
        end % addNodeData
        
        function addSignalHierarchy( obj , signal , node  )

            childNames = fieldnames(signal);
            for j = 1:length(childNames)
                child =  signal.(childNames{j});


                childNode  = uitreenode(...
                    'v0','', childNames{j} , [], 0);
                childNode.setUserObject('JavaImage_signalLog');
                childNode.setIcon(obj.JavaImage_signalLog);
                childNode.UserData = child;
                node.add(childNode);

                if isstruct(child)
                    childNode.setUserObject('JavaImage_bus');
                    childNode.setIcon(obj.JavaImage_bus);
                    
                    addSignalHierarchy( obj , child , childNode )
                end
            end
   
        end % addSignalHierarchy 
        
        function h = overobj2(Type)

            % function h = overobj2(Type)
            % ------------------------------------------------------------------------
            % This function searches the current PointerWindow for visible or
            % non-visible objects of the type specified by the input Type. It returns
            % the handle to the first object it finds under the pointer or, if none are
            % found returns an empty matrix. 
            % This function is similar to MATLAB's (undocumented) overobj function.
            % However it differs in the sense that figure and root units are enforced
            % to both be in pixels prior to search. In addition hidden objects (such as
            % axes with the axis off option) are also found returned.
            % 
            % Example: h = overobj2('axes');
            %
            % Modified from MATLAB's overobj function and the overobj2 function at:
            % http://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
            %
            % See also OVEROBJ, FINDOBJ
            %
            % Kevin Mattheus Moerman
            % gibbon.toolbox@gmail.com
            % 
            % 2015/04/18
            % ------------------------------------------------------------------------

            %

            %Get figure pointed at
            hf = matlab.ui.internal.getPointerWindow();

            % Look for quick exit (if mouse pointer is not over any figure)
            if hf==0,
               h = [];
               return
            end

            % Ensure root and figure units are pixels
            oldUnitsRoot = get(0,'units');
            set(0,'units','pixels');

            oldUnitsFig = get(hf,'units');
            set(hf,'units','pixels');

            %Get position
            p = get(0,'PointerLocation');

            % Compute figure offset of mouse pointer in pixels
            % figPos = getpixelposition(hf);
            figPos = get(hf,'Position');

            x = (p(1)-figPos(1))/figPos(3);
            y = (p(2)-figPos(2))/figPos(4);

            %Restore units
            set(0,'units',oldUnitsRoot);
            set(hf,'units',oldUnitsFig); 

            % Loop over all figure descendents
            c = findobj(get(hf,'Children'),'flat','Type',Type); %,'Visible','on'
            for h = c',
               hUnit = get(h,'Units');
               set(h,'Units','norm')
               r = get(h,'Position');
               set(h,'Units',hUnit)
               if ( (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4)) )
                  return
               end
            end
            h = [];
        end % overobj2
        
        function showTree(obj,RootNode)
            % - get java tools
            import javax.swing.*
            import javax.swing.tree.*;

            % set treeModel
            obj.TreeModel = DefaultTreeModel( RootNode );

            % create the tree
            [obj.Tree, obj.TreeContainer] = uitree('v0',obj.Figure );
            

            set(obj.TreeContainer, 'Parent',obj.SimulationDataSelection);
            set(obj.TreeContainer, 'Visible','on');
            set(obj.TreeContainer, 'Units','normal')
            set(obj.TreeContainer, 'position',[0 0 1 1])
            % set tree to treemodel
            obj.Tree.setModel( obj.TreeModel );

            obj.HJTree = handle(obj.Tree.getTree,'CallbackProperties');


            set(obj.Tree, 'NodeSelectedCallback', @obj.nodeSelected_CB );
            set(obj.Tree, 'NodeDroppedCallback', @obj.nodeDroppedCB);

%     obj.HJTree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
%     obj.HJTree.getSelectionModel().setSelectionMode(TreeSelectionModel.CONTIGUOUS_TREE_SELECTION);
    obj.HJTree.getSelectionModel().setSelectionMode(TreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION);

            % set parents resize function
            set(obj.obj.TreeContainer,'ResizeFcn',@obj.reSize);


            % Set the tree mouse-click callback
            % Note: MousePressedCallback is better than MouseClickedCallback
            %       since it fires immediately when mouse button is pressed,
            %       without waiting for its release, as MouseClickedCallback does
            set(obj.HJTree, 'MousePressedCallback',...
                @obj.mousePressedInTree_CB);
            
            %obj.HJTree.expandPath(RootNode.getPath());
            % Hide Root node for asthetic purposes
            obj.HJTree.expandRow(0);
            obj.HJTree.setRootVisible(false);
            obj.HJTree.setShowsRootHandles(true);
        end % showTree
        
        function saveAllNodesAsStructs(obj) 
            obj.SavedNodes = saveNodesAsStructs(obj,obj.TreeModel.getRoot);
        end % saveAllNodesAsStructs 
        
        function nodeStruct = saveNodesAsStructs(obj,node)
            nodeStruct = node2struct(node);
            for i = 1:node.getChildCount 
                nodeStruct = [nodeStruct,saveNodesAsStructs(obj,node.getChildAt(i-1))]; %#ok<AGROW>
            end
        end % saveNodesAsStructs
        
        function node = struct2node(obj, struct)
            node = uitreenode('v0',struct.Value, struct.Title, [], 0);
            if ~isempty(struct.Icon)
                node.setIcon(obj.(struct.Icon));
            end
            node.setUserObject(struct.Icon);
            node.UserData = struct.UserData;
        end % struct2node
        
        function removeNodesFromParent( obj , node , value )
%            warning('"removeNodesFromParent" will no longer be supported.  Use "removeNode" and "removeAllChildNodes" instead.')
            % Remove Existing Nodes
            if nargin == 2
                while node.getChildCount > 0
                    child = node.getChildAt(0);
                    if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                        %clear(child.handle.UserData);%delete(child.handle.UserData);
                    end
                    obj.TreeModel.removeNodeFromParent(child);
                end 
            elseif nargin == 3
                for i = 0:node.getChildCount - 1
                    child = node.getChildAt(i);
                    if strcmp(value,char(child.getValue))
                        if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                            %clear(child.handle.UserData);%delete(child.handle.UserData);
                        end
                        obj.TreeModel.removeNodeFromParent(child);
                    end
                end   
            end
        end
        
        function removeNode( obj , node )
            if ~ischar(node.handle.UserData) && ~iscell(node.handle.UserData)
                delete(node.handle.UserData);
            end
            obj.TreeModel.removeNodeFromParent(node);
            obj.HJTree.repaint;
        end % removeNode
        
        function removeAllChildNodes( obj , parentNode )
            while parentNode.getChildCount > 0
                child = parentNode.getChildAt(0);
                if ~ischar(child.handle.UserData) && ~iscell(child.handle.UserData)
                    delete(child.handle.UserData);
                end
                obj.TreeModel.removeNodeFromParent(child);
            end 
            obj.HJTree.repaint;
        end % removeAllChildNodes
        
        function restoreTree(obj,parent)
            % - get java tools
            import javax.swing.*
            import javax.swing.tree.*;
            switch nargin
                case 1
                    obj.Parent = figure('Menubar','none',...   
                                        'Toolbar','none',...
                                        'NumberTitle','off',...
                                        'HandleVisibility', 'on',...
                                        'Visible','on'); 
                    %obj.Figure = obj.Parent;
                case 2
                    %obj.Figure = ancestor(parent,'figure','toplevel') ;
                    obj.obj.TreeContainer = parent;  
            end
             
            % - create the root node
            nodes = uitreenode('v0',obj.SavedNodes(1).Value, obj.SavedNodes(1).Title, [], 0);
            %obj.HJTree.setRootVisible(false);
            
            % set treeModel
            obj.TreeModel = DefaultTreeModel( nodes );

            % create the tree
            [obj.Tree, obj.TreeContainer] = uitree('v0',obj.Figure );
            set(obj.TreeContainer, 'Parent',obj.obj.TreeContainer);
            set(obj.TreeContainer, 'Visible','on');
            set(obj.TreeContainer, 'Units','normal')
            set(obj.TreeContainer, 'position',[0, 0, 1, 1])

            % set tree to treemodel
            obj.Tree.setModel( obj.TreeModel );

            obj.HJTree = handle(obj.Tree.getTree,'CallbackProperties');


            set(obj.Tree, 'NodeSelectedCallback', @obj.nodeSelected_CB );



            % Set the tree mouse-click callback
            % Note: MousePressedCallback is better than MouseClickedCallback
            %       since it fires immediately when mouse button is pressed,
            %       without waiting for its release, as MouseClickedCallback does
            set(obj.HJTree, 'MousePressedCallback',...
                @obj.mousePressedInTree_CB);
            
            % Add nodes 2 tree
%             tic
            for i = 2:length(obj.SavedNodes) 

                parentNode  = findNodeParent(obj.SavedNodes(i).Parent,nodes);

                nodes(i) = obj.struct2node(obj.SavedNodes(i)); %#ok<AGROW> % (end+1)
                obj.TreeModel.insertNodeInto(nodes(end),...
                    parentNode,...
                    parentNode.getChildCount());
                
            end
%             toc
            % Restore the expansion state of the tree
            restoreExpansionState(obj);
            
            % Hide Root node for asthetic purposes
            obj.HJTree.expandRow(0);
            obj.HJTree.setRootVisible(false);
            obj.HJTree.setShowsRootHandles(true);
        end % restoreTree
        
        function saveTreeState(obj)
            saveExpansionState(obj);
            saveAllNodesAsStructs(obj);
        end % saveTreeState     
         
    end
  
    %% Methods - Protected Callbacks
    methods (Access = protected)
      
        function closeFigure_CB( obj , hobj ,eventdata )
            warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            delete(obj.Figure);
            
        end % closeFigure_CB
        
        function setWaitPtr(obj)
            set(obj.Figure, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            set(obj.Figure, 'pointer', 'arrow'); 
        end % releaseWaitPtr
        
    end
    
    %% Methods - Resize Methods
    methods  
        
        function reSize( obj , ~ , ~ )
            % get figure position  
            drawnow();
            position = getpixelposition(obj.Container);
            if isempty(obj.RibbonParent)
                obj.RibbonPanel.Position = [ 1 , position(4)-93 , position(3), 93 ];
                obj.MainPanel.Position = [1 , 1 , position(3) , position(4) - 93 ]; 
            else
                obj.MainPanel.Position = [1 , 1 , position(3) , position(4) ]; 
            end
            
            position = getpixelposition(obj.MainPanel);
            obj.SimulationDataSelection.Position = [ 1 , 1 , 250 , position(4) - 2 ];   
            
            positionSD = getpixelposition(obj.SimulationDataSelection);
            obj.SearchString_EB.Position = [ 1 , positionSD(4) - 20 , positionSD(3) - 51 , 20 ]; 
            
            obj.UpJButtonHCont.Position = [ positionSD(3) - 50 , positionSD(4) - 39 , 25 , 39 ];  
            obj.DnJButtonHCont.Position = [ positionSD(3) - 25 , positionSD(4) - 39 , 25 , 39 ]; 
            
            obj.MatchCaseJCheckboxHCont.Position = [  1 , positionSD(4) - 40 , 83 , 20 ];  
            obj.MatchWholeWordJCheckboxHCont.Position = [ 83 , positionSD(4) - 40 , 115 , 20 ]; 
            
            obj.TreeContainer.Position = [ 1 , 1 , positionSD(3) , positionSD(4) - 40 ];  
            try
                obj.AxisContainer.Position  = [255 , 5 , position(3) - 260 , position(4) - 10];
            end
        end % reSize 
        
    end % Ordinary Methods
       
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Example object
%             cpObj.Example = copy(obj.Example);
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function h = overobj(obj)
        % This function is undocumented and will change in a future release
        %OVEROBJ Get handle of object the pointer is over.
        %   H = OVEROBJ(TYPE) check searches visible objects of Type TYPE in 
        %   the PointerWindow looking for one that is under the pointer.  It
        %   returns the handle to the first object it finds under the pointer
        %   or else the empty matrix.
        %
        %   Notes:
        %   Assumes root units are pixels
        %   Only works with object types that are children of figure
        %   ** Updated to work with container parameter
        %   Example:
        %       axes ; 
        %       %after executing the following line place the pointer over the axes
        %       %object or else the overobj function will return empty
        %       pause(2),overobj('axes')
        %
        %   See also UICONTROL, UIPANEL
        %   Copyright 1984-2013 The MathWorks, Inc.

        % fig = matlab.ui.internal.getPointerWindow();
        % Look for quick exit
        if obj.Figure==0,
           h = [];
           return
        end

        % Assume root and figure units are pixels
        p = get(0,'PointerLocation');
        figPos = get(obj.Figure,'Position');

        c = findobj(get(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel).Panel,'Children'),'flat','Type','Axes','Visible','on');

        for h = c',
            
            position = getpixelposition(h,true);
            posOnScreen = [ figPos(1) + position(1) ,...
                figPos(2) + position(2) ,...
                position(3) ,...
                position(4) ];

           if ( (p(1) > posOnScreen(1)) && (p(1) < posOnScreen(1) + posOnScreen(3)) && (p(2) > posOnScreen(2)) && (p(2) < posOnScreen(2) + posOnScreen(4)) )
              return
           end
        end
        h = [];
        end % overobj
        
        function h = overobjOLD(obj)
        % This function is undocumented and will change in a future release
        %OVEROBJ Get handle of object the pointer is over.
        %   H = OVEROBJ(TYPE) check searches visible objects of Type TYPE in 
        %   the PointerWindow looking for one that is under the pointer.  It
        %   returns the handle to the first object it finds under the pointer
        %   or else the empty matrix.
        %
        %   Notes:
        %   Assumes root units are pixels
        %   Only works with object types that are children of figure
        %   ** Updated to work with container parameter
        %   Example:
        %       axes ; 
        %       %after executing the following line place the pointer over the axes
        %       %object or else the overobj function will return empty
        %       pause(2),overobj('axes')
        %
        %   See also UICONTROL, UIPANEL
        %   Copyright 1984-2013 The MathWorks, Inc.

        % fig = matlab.ui.internal.getPointerWindow();
        % Look for quick exit
        if obj.Figure==0,
           h = [];
           return
        end

        % Assume root and figure units are pixels
        p = get(0,'PointerLocation');
        % Get figure position in pixels
        %figUnit = get(obj.Figure,'Units');
        %set(obj.Figure,'Units','pixels');
        figPos = get(obj.Figure,'Position');
        %set(obj.Figure,'Units',figUnit)

        axContPos = obj.AxisContainer.Position;

        % x = (p(1)-figPos(1))/figPos(3);
        % y = (p(2)-figPos(2))/figPos(4);
        figPos = [ figPos(1) + axContPos(1) ,...
            figPos(2) ,...
            axContPos(3) ,...
            axContPos(4) ];
        x = (p(1)-figPos(1))/figPos(3);
        y = (p(2)-figPos(2))/figPos(4);

        c = findobj(get(obj.AxisPanelCollObj.Panel(obj.AxisPanelCollObj.SelectedPanel).Panel,'Children'),'flat','Type','Axes','Visible','on');
        %%% c = findobj(get(obj.Figure,'Children'),'flat','Type',Type,'Visible','on');
        % c = findobj(get(obj.AxisContainer,'Children'),'flat','Type','Axes','Visible','on');
        for h = c',         
           hUnit = get(h,'Units');
           set(h,'Units','norm')
           r = get(h,'Position');
           set(h,'Units',hUnit)
           if ( (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4)) )
              return
           end
        end
        h = [];
        end % overobj
   
    end
    
    %% Methods - Static
    methods ( Static )
        function addData( data, append, plotOp )
            
                %check if GUI is already open
                figID = [getenv('username'),'|SimViewer'];
                FigureHdl = findobj('Tag', figID);
                if ~isempty(FigureHdl)
                    try
                        figure(FigureHdl);
                        SimViewerHandle = FigureHdl.UserData;
                        SimViewerHandle.updateNewData(data,append,plotOp);
                    catch %#ok<CTCH>
                        error('SimViewer handle is missing or more then one simviewer is open.');
                    end 
                else
                    error('No SimViewer figure exists');
                end

        end % addData
        
        function pltSet = emptyPlotSettings()
            pltProps = struct('SignalData',{},'PlotType', {},...
                'SimViewerData',{},'UserTitle',{},'UserXLabel',{},...
                'UserYLabel',{},'UserXLim',{},'UserYLim',{},'PatchData',{});
            pltSet = struct('NumOfPlots',{},'Data',pltProps);  
        end % emptyPlotSettings
        
        function prjSet = emptyProjectSettings()
            
            pltSet = SimViewer.Main.emptyPlotSettings();
            prjSet = struct('SimulationData',{},...
                'PlotSettings',pltSet,'RunLabel',{},'TreeExpansionState',{});  
        end % emptyProjectSettings
    end
    
    %% Methods - Delete
    methods
        
        function delete( obj )
            % Java Components 
            obj.JRibbonPanel = [];
            obj.JRPHComp = [];
            %obj.CopyJButton = [];
            obj.PlotJButton = [];
            obj.HoldJButton = [];
            obj.ShowMarkerJCheckbox = [];
            obj.FunctionJCombo = [];
            obj.NormalJCheckbox = [];
            
            % Javawrappers
            % Check if container is already being deleted
            if ~isempty(obj.JRPHCont) && ishandle(obj.JRPHCont) && strcmp(get(obj.JRPHCont, 'BeingDeleted'), 'off')
                delete(obj.JRPHCont);
            end




            % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end

            
        end % delete
        
    end
    
    %% Methods - Display
    methods (Access = protected)
        
       function header = getHeader(obj)
           header = 'Simulation Viewer GUI';

       end % getHeader

       function propgrp = getPropertyGroups(obj)
           propgrp = '';

       end % getPropertyGroups

       function footer = getFooter(obj)
           footer = sprintf('%s\n','');

       end % getFooter
       
    end
    
end % Main

function y = getAutoAxisLabel( x , signalData, var)
    
    try
        if length(signalData) > 1; y=x; return; end
        if isempty(signalData.([var,'Operation']))
            y = x;
        else
            y = strrep(signalData.([var,'Operation']),lower(var),x);
            if strcmp(y,signalData.([var,'Operation']))
                y = strrep(signalData.([var,'Operation']),upper(var),x);
            end
        end

    catch
        y = x;
    end
end % getAutoAxisLabel



function out = evalDataOperation( data ,operStr , type )
    try
        specialVarInd = 1;
        vars = symvar(operStr);
        for i = 1:length(vars)
            if strcmpi(vars{i},type)
                specialVarInd = i;
            else
                try
                    eval([vars{i},' = evalin(''base'',vars{i});']);
                end
            end
        end
        eval([lower(vars{specialVarInd}),' = data;']);
        out = eval(operStr);
    catch
        warning(['Unable to evaluate expression ''',operStr,''' for ''',type,''' data']);
        out = data;
    end

end % evalDataOperation

function treePath =  findNodePath(root, s, searchType)
% SearchType  1 - matches exactly
%             2 - matches ignoring case
%             3 - partial match
%             4 - partial match ignore case
%             5 - reqular expression match - not implemented currently

    if nargin == 2
        searchType = 2;
    end

    s = java.lang.String(s);
    
    treePath = {};
    e = root.depthFirstEnumeration();
    while (e.hasMoreElements()) 
        node = e.nextElement();
        switch searchType
            case 1
                if node.getName.equalsIgnoreCase(s)   % strcmpi(node.getName,s)
                    treePath{end+1} = node.getPath(); %#ok<AGROW>
                end 
            case 2
                if node.getName.equalsIgnoreCase(s) % strcmpi(node.getName,s)
                    treePath{end+1} = node.getPath(); %#ok<AGROW>
                    %break;
                end
            case 3 
                if node.getName.contains(s) 
                    treePath{end+1} = node.getPath(); %#ok<AGROW>
                end  
            case 4 
                if node.getName.toLowerCase().contains(s.toLowerCase()) 
                    treePath{end+1} = node.getPath(); %#ok<AGROW>
                end 
        end
    end
    
end % findNodePath

function expandAll(tree, parent, collapse)
    if nargin == 2; collapse = false;end;

    node = parent.getLastPathComponent();
    if node.getChildCount() >= 0
        e = node.children();
        while (e.hasMoreElements()) %for (Enumeration e = node.children(); e.hasMoreElements();)
            n = e.nextElement();
            path = parent.pathByAddingChild(n);
            expandAll(tree, path, collapse);
        end
    end
    if collapse
        tree.collapsePath(parent);
        %tree.collapse(parent);
    else
        tree.expandPath(parent);
    end
    tree.repaint;
end % expandAll

function figH = exportPanel2Figure(simPanel )

    axHArray = simPanel.Axis;
    numOfAxis = length(simPanel.Axis);

    % Create figure
    figH = figure( ...
        'Name', '', ...
        'NumberTitle', 'off',...
        'Visible','off');

    height = 1/numOfAxis;

    axHt = 1/numOfAxis;

    offset = 0;
    for k = 1:numOfAxis

        oldaxH = handle(axHArray(k));

        if isempty(oldaxH.LegendData)
            graphH = copyobj(oldaxH,figH);
        else
            graphH = copyobj([oldaxH,oldaxH.LegendData],figH);
        end
        drawnow();pause(0.5);
        axH = graphH(1);
        axH.Units = 'Normal';
        axH.OuterPosition = [ offset , 1 - (axHt * k) , 1 - offset , axHt ]; 

        axH.Title = copy(oldaxH.Title);
        axH.XLabel = copy(oldaxH.XLabel);
        axH.YLabel = copy(oldaxH.YLabel);
    end   


    switch numOfAxis
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
        case 5
            add2Height = 400;
            add2Width = 0;
        case 6
            add2Height = 500;
            add2Width = 0;

        otherwise
    end
    set(figH ,'PaperPositionMode','auto');
    pos = getpixelposition(figH);
    set(figH ,'Units','Pixels');
    set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);

    set(figH,'CreateFcn','set(gcf,''Visible'',''on'')');
end % exportPanel2Figure

function printAxisObj2File( axHCol , filename )
% Input is an AxisCollection object
% This will print each page seperate
   
    savedPNGtempFiles = struct('Filename',{},'Title',{});

    for i = 1:length(axHCol)% one page per loop
        nSubPlots = length(axHCol(i).Axis);
        
        % Create figure
        figH = figure( ...
            'Name', '', ...
            'NumberTitle', 'off',...
            'Visible','off',...
            'Color','w');
        
        bottom = 0;
        height = 1/nSubPlots;
        for k = nSubPlots:-1:1 % 1:nSubPlots %nSubPlots:-1:1
            oldaxH = handle(axHCol(i).Axis(k));
%             axH(k) = axes(figH); %#ok<*AGROW,*LAXES>
%             axH(k).Units = 'Normal';
%             axH(k).OuterPosition = [ 0 , bottom , 1 , height ];
%             grid(axH(k),'on');

            if isempty(oldaxH.LegendData) || ~isvalid(oldaxH.LegendData)
                graphH = copyobj(oldaxH,figH);
                drawnow();pause(0.5);
            else
                graphH = copyobj([oldaxH,oldaxH.LegendData],figH);
                drawnow();pause(0.5);
            end
            axH = graphH(1);
            axH.Units = 'Normal';
            drawnow();pause(0.5);
            axH.OuterPosition = [ 0 , bottom , 1 , height ]; 
            
            
%             if isempty(oldaxH(k).LegendData)
%                 copyobj(allchild(oldaxH),axH(k));
%             else
%                 copyobj([allchild(oldaxH);oldaxH(k).LegendData],axH(k));
%             end
%             copyobj([oldaxH;oldaxH(k).LegendData],axH(k));
            
            axH.Title = copy(oldaxH.Title);
            axH.XLabel = copy(oldaxH.XLabel);
            axH.YLabel = copy(oldaxH.YLabel);
            bottom = bottom + height;
        end
        
        switch nSubPlots
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
            case 5
                add2Height = 400;
                add2Width = 0;
            case 6
                add2Height = 500;
                add2Width = 0;

            otherwise
        end
        set(figH ,'PaperPositionMode','auto');
        pos = getpixelposition(figH);
        set(figH ,'Units','Pixels');
        set(figH ,'Position',[pos(1) - add2Width , pos(2) - add2Height , pos(3) + add2Width , pos(4) + add2Height ]);
        
        % Save to temporary image files
        filelocation = [tempname,'.png'];
        print(figH ,'-dpng',filelocation,'-r300');
        savedPNGtempFiles(end + 1).Filename = filelocation; 
        savedPNGtempFiles(end).Title = ['Page #',int2str(i)]; 
        delete(figH);

%         [~,~,ext] = fileparts(filename);
%         switch ext
%             case '.pdf'
%                 % Print to a PDF
%                 location = [tempname,'.ps'];
%                 print(figH,'-dpsc',location,'-append');
%                 delete(figH);
%                 SimViewer.Utilities.eps2pdf(location, filename, 1, 1, 0, [], {});
%                 %SimViewer.Utilities.ghostscript('psfile', location, 'pdffile', filename, 'gspapersize', 'a4', 'deletepsfile', 1);
%                 %SimViewer.Utilities.ps2pdf('psfile', location, 'pdffile', filename, 'gspapersize', 'a4', 'deletepsfile', 1);
%             case {'.doc','.docx'}
%          
%             case {'.html'}
%                 %print(figH,'-dsvg',filename);
%                 %SimViewer.Plot2svg.plot2svg(filename,figH);
%         end


    end 
    
    createFiguresWordDocument( filename , savedPNGtempFiles )
    

end % printSimFigure2File

function outStruct = node2struct(node)

    if isempty(node.getParent())
        %parentName = 'root';
        parent = [];
    else
        %parentName = node.getParent.getName;
        parent = node2struct(node.getParent);
    end
    
    switch char(node.getValue)
        case 'selected'
            icon = 'JavaImage_checked';
        case 'unselected'
            icon = 'JavaImage_unchecked';
        case 'mixed'
            icon = 'JavaImage_partialchecked';
        otherwise
            icon = node.getUserObject;
    end
    
    outStruct = struct('Title',char(node.getName),...
                        'Value',node.getValue,...
                        'Depth',node.getDepth,...
                        'Parent',parent,...
                        'Icon',icon,...
                        'UserData',node.handle.UserData);

end % node2struct

function parentNode = findNodeParent(nodeStruct,nodes)    
%     nodeNames = {1,length(nodes)};
    nodeNames       = cell(1,length(nodes));
    nodeParentNames = cell(1,length(nodes));
    for i = 1:length(nodes)
        nodeNames{i} = char(nodes(i).getName);
        if nodes(i).isRoot
            nodeParentNames{i} = nodeNames{i};
        else
            nodeParentNames{i} = char(nodes(i).getParent.getName);
        end
    end


    
    logArray       = strcmp(nodeStruct.Title,nodeNames);
    if isempty(nodeStruct.Parent)
        parentStructName = nodeStruct.Title;
    else
        parentStructName = nodeStruct.Parent.Title;
    end
    logArrayParent = strcmp(parentStructName,nodeParentNames);
    % Need second check to ensure names need not be unique
    
    parentNode = nodes(logArray & logArrayParent);
    
    if ~isempty(parentNode)
        parentNode = parentNode(end);
    end
end % findNodeParent

function index = childIndex( node, childValue)
    children = node.children();%Enumeration<DefaultMutableTreeNode> children = node.children();
    %child = [];%DefaultMutableTreeNode child = null;
    index = -1;

    while (children.hasMoreElements() && index < 0) 
        child = children.nextElement();

%         if (~isempty(child.getUserObject()) && strcmp(childValue,child.getUserObject())) %(child.getUserObject() != null && childValue.equals(child.getUserObject())) 
        if (~isempty(child.getName()) && strcmp(childValue,child.getName()))
            index = node.getIndex(child);
        end
    end
end % childIndex

function createFiguresWordDocument( filename , saveFigs )

    rpt = SimViewer.Report(filename);

    addTOF( rpt );

    for i = 1:length(saveFigs)
        addFigure( rpt , saveFigs(i));
    end

    updateTOF( rpt );

    saveAs( rpt , filename  );
    closeWord( rpt );           

end % createFiguresWordDocument 



