classdef ToolRibbon < handle & UserInterface.GraphicsObject
        
    %% Version
    properties  
        VersionNumber
        InternalVersionNumber
    end % Version 
    
    %% Public properties - Object Handles
    properties (Transient = true) 
        %Parent
        
        JRibbonPanel
        JRPHComp
        JRPHCont
        
        NewJButton
        OpenJButton
        LoadJButton
        SaveJButton
        RunJButton
        RunSelJButton
        ClrTblSelJButton
        MainJButton
        TrimEditJButton
        ModelEditJButton
        ReqEditJButton
        AnalysisEditJButton
        UnitsSelComboBox
        SimReqEditJButton
        
        ShowInvalidTrimJCheckbox
        ShowLogSignalsJCheckbox

        PlotJButton

        GenerateReportJButton

    end % Public properties
  
    %% Public properties - Data Storage
    properties       
        CurrSelToolRibbion  = 1
        ToolRibbionSelectedText = 'Main'
        TextColorMain   = [0 0 0]
        TextColorMethod = [0 0 0]
        TextColorRq     = [0 0 0]
        TextColorGains  = [0 0 0]
        TextColorRootLocus = [0 0 0]
        TextColorFilter = [0 0 0]
        ButtonColorMain   = [0.8 0.8 0.8]
        ButtonColorMethod = [0.8 0.8 0.8]
        ButtonColorRq     = [0.8 0.8 0.8]
        ButtonColorGains  = [0.8 0.8 0.8]
        ButtonColorRootLocus = [0.8 0.8 0.8]
        ButtonColorFilter = [0.8 0.8 0.8]
        
        
        NumberOfPlotPerPageReq = 4
        NumberOfPlotPerPagePostSim = 4
        
        ShowLoggedSignalsState = false
        ShowInvalidTrimState = 1
        
        TrimSettings
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Private properties
    properties ( Access = private )
        BrowseStartDir = pwd %mfilename('fullpath')
    end % Private properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Events
    events
        PanelChange
        SaveWorkspace
        LoadWorkspace
        NewWorkspace
        
        LoadConfiguration
        NewConfiguration
        SaveOperCond
        RunSave
%         SaveOnly
        Run
        
        LoadBatchRun
        UnitsChanged
        ClearTable
%         LoadTrimDefinition
%         LoadLinMdlDefinition
%         LoadMethod
%         LoadSimulation
%         LoadSimulationObj
%         LoadPostSimulationObj
        NewTrimObject
        NewLinearModelObject
        NewMethodObject
        NewSimulationReqObject
        NewPostSimulationReqObject
        OpenObject

        TabPanelChanged
        ExportTable

        GenerateReport
        
        NewProject
        LoadProject
        CloseProject
        
%         ShowInvalidTrim
        ShowLogSignals
        Add2Batch
        NewAnalysis
        LoadAnalysisObject
        
        SetNumPlotsPlts
        SetNumPlotsPostPlts
        
        ShowTrimsChanged
        
        TrimSettingsChanged
    end
    
    %% Methods - Constructor
    methods      
        function obj = ToolRibbon(mainobj,ver,internalver,trimOpt)
            
            obj.VersionNumber = ver;
            obj.InternalVersionNumber = internalver;
            obj.Parent = mainobj;
            obj.TrimSettings = trimOpt;
            
            backgroundColor = java.awt.Color(210/255,210/255,210/255); % java.awt.Color.lightGray
            
            % Create the Home Pane
        
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            obj.JRibbonPanel = javaObjectEDT('javax.swing.JPanel');
            obj.JRibbonPanel.setLayout([]);
            % Configuration Section
            labelStr = '<html><font color="gray" face="Courier New">FILE</html>';
            jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabel.setOpaque(true);
            jLabel.setBackground(java.awt.Color.lightGray);
            jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabel);
            jLabel.setBounds(0,76,163,16);
            
                % New Button             
                newJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                newJButton.setText('New');        
                newJButtonH = handle(newJButton,'CallbackProperties');
                set(newJButtonH, 'ActionPerformedCallback',@obj.newTrimObj_CB);
                set(newJButtonH, 'DropDownActionPerformedCallback',@obj.fileNew_CB);
                myIcon = fullfile(icon_dir,'New_24.png');
                newJButton.setIcon(javax.swing.ImageIcon(myIcon));
                newJButton.setToolTipText('Create New Item');
                %newJButton.setIconTextGap(0);
                %newJButton.setFlyOverAppearance(true);
                newJButton.setBorder([]);
                newJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                newJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(newJButton);
                newJButton.setBounds(5,3,35,71);
                obj.NewJButton = newJButton;

                % Open Button             
                openJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                openJButton.setText('Open');        
                openJButtonH = handle(openJButton,'CallbackProperties');
                set(openJButtonH, 'ActionPerformedCallback',@obj.openTrimObj_CB)
                set(openJButtonH, 'DropDownActionPerformedCallback',@obj.fileOpen_CB);
                myIcon = fullfile(icon_dir,'Open_24.png');
                openJButton.setIcon(javax.swing.ImageIcon(myIcon));
                openJButton.setToolTipText('Open');
                %openJButton.setFlyOverAppearance(true);
                openJButton.setBorder([]);
                openJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                openJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(openJButton);
                openJButton.setBounds(45,3 ,35, 71);
                obj.OpenJButton = openJButton;    
                
                % Load Button             
                loadJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                loadJButton.setText('Load');        
                loadJButtonH = handle(loadJButton,'CallbackProperties');
                set(loadJButtonH, 'ActionPerformedCallback',@obj.loadTrimObj_CB)
                set(loadJButtonH, 'DropDownActionPerformedCallback',@obj.fileLoad_CB);
                myIcon = fullfile(icon_dir,'LoadArrow_24.png');
                loadJButton.setIcon(javax.swing.ImageIcon(myIcon));
                loadJButton.setToolTipText('Load');
                %loadJButton.setFlyOverAppearance(true);
                loadJButton.setBorder([]);
                loadJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                loadJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(loadJButton);
                loadJButton.setBounds(85,3 ,35, 71);
                obj.LoadJButton = loadJButton;
                  
                % Save Button             
                saveJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                saveJButton.setText('Save');        
                saveJButtonH = handle(saveJButton,'CallbackProperties');
                set(saveJButtonH, 'ActionPerformedCallback',@obj.saveWorkspace_CB)
                set(saveJButtonH, 'DropDownActionPerformedCallback',@obj.fileSave_CB);
                myIcon = fullfile(icon_dir,'Save_Dirty_24.png');
                saveJButton.setIcon(javax.swing.ImageIcon(myIcon));
                saveJButton.setToolTipText('Open existing workspace');
                %saveJButton.setFlyOverAppearance(true);
                saveJButton.setBorder([]);
                saveJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                saveJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(saveJButton);
                saveJButton.setBounds(125,3 ,35, 71);
                obj.SaveJButton = saveJButton;

            
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(165,3,2,90);

                
            labelStr = '<html><font color="gray" face="Courier New">RUN</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(169,76,45,16);

            
                % Run Button             
                runJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                runJButton.setText('Run');        
                runJButtonH = handle(runJButton,'CallbackProperties');
                set(runJButtonH, 'ActionPerformedCallback',@obj.runAndSave_CB)
                set(runJButtonH, 'DropDownActionPerformedCallback',@obj.runRibbion_CB);
                myIcon = fullfile(icon_dir,'RunSave_24.png');
                runJButton.setIcon(javax.swing.ImageIcon(myIcon));
                runJButton.setToolTipText('Run and Save');
                %runJButton.setFlyOverAppearance(true);
                runJButton.setBorder([]);
                runJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                %runJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
                %runJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
                runJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                runJButton.setIconTextGap(0);
                obj.JRibbonPanel.add(runJButton);
                runJButton.setBounds(172,3,40,71);
                obj.RunJButton = runJButton;
                
%                 % RunSel Button             
%                 runSelJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
%                 runSelJButton.setText('');        
%                 runSelJButtonH = handle(runSelJButton,'CallbackProperties');
%                 set(runSelJButtonH, 'ActionPerformedCallback',@obj.runRibbion_CB)
%                 myIcon = fullfile(icon_dir,'arrowDown_16.png');
%                 runSelJButton.setIcon(javax.swing.ImageIcon(myIcon));
%                 runSelJButton.setToolTipText('Run');
%                 runSelJButton.setFlyOverAppearance(true);
%                 runSelJButton.setBorder([]);
%                 runSelJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
%                 runSelJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
%                 runSelJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
%                 obj.JRibbonPanel.add(runSelJButton);
%                 runSelJButton.setBounds(172,49,40,15);
%                 obj.RunSelJButton = runSelJButton;
            
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(217,3,2,90);

            
            labelStr = '<html><font color="gray" face="Courier New">ACTIONS</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(222,76,125,16);
            
                addBatchJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                addBatchJButton.setText('Add New Run Cases');        
                addBatchJButtonH = handle(addBatchJButton,'CallbackProperties');
                set(addBatchJButtonH, 'ActionPerformedCallback',@obj.batchAdd_CB)
                myIcon = fullfile(icon_dir,'New_16.png');
                addBatchJButton.setIcon(javax.swing.ImageIcon(myIcon));
                addBatchJButton.setToolTipText('Add Run Cases');
                %addBatchJButton.setFlyOverAppearance(true);
                addBatchJButton.setBorder([]);
                addBatchJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                addBatchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                %addBatchJButton.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 10));
                obj.JRibbonPanel.add(addBatchJButton);
                addBatchJButton.setBounds(224,3,120,20);
%                 [obj.AddBatchJButtonHComp,obj.AddBatchJButtonHCont] = javacomponent(addBatchJButton, [ ], handle(obj.Parent));  
            


                % Clear Button             
                clrTblButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                clrTblButton.setText('Table Options');        
                clrTblButtonH = handle(clrTblButton,'CallbackProperties');
                set(clrTblButtonH, 'ActionPerformedCallback',@obj.clearTable_CB)
                myIcon = fullfile(icon_dir,'Clean_16.png');
                clrTblButton.setIcon(javax.swing.ImageIcon(myIcon));
                clrTblButton.setToolTipText('Switch to Home View');
                %clrTblButton.setFlyOverAppearance(true);
                clrTblButton.setBorder([]);
                clrTblButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                clrTblButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(clrTblButton);
                clrTblButton.setBounds(224,39,95,20);
                obj.MainJButton = clrTblButton;

                % Generate Report Button
                genRptButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                genRptButton.setText('Generate Report');
                genRptButtonH = handle(genRptButton,'CallbackProperties');
                set(genRptButtonH,'ActionPerformedCallback',@obj.generateReport_CB);
                myIcon = fullfile(icon_dir,'report_app_24.png');
                genRptButton.setIcon(javax.swing.ImageIcon(myIcon));
                genRptButton.setToolTipText('Generate analysis report');
                genRptButton.setBorder([]);
                genRptButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.HORIZONTAL);
                genRptButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(genRptButton);
                genRptButton.setBounds(224,63,120,20);
                obj.GenerateReportJButton = genRptButton;

                % ClearSel Button
                clrTblSelJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                clrTblSelJButton.setText('');
                clrTblSelJButtonH = handle(clrTblSelJButton,'CallbackProperties');
                set(clrTblSelJButtonH, 'ActionPerformedCallback',@obj.clearSelect_CB)
                myIcon = fullfile(icon_dir,'arrowDown_16.png');
                clrTblSelJButton.setIcon(javax.swing.ImageIcon(myIcon));
                clrTblSelJButton.setToolTipText('Clear');
                %clrTblSelJButton.setFlyOverAppearance(true);
                clrTblSelJButton.setBorder([]);
                clrTblSelJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                clrTblSelJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(clrTblSelJButton);
                clrTblSelJButton.setBounds(319,39,25,20);
                obj.ClrTblSelJButton = clrTblSelJButton;
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(349,3,2,90);

            
            labelStr = '<html><font color="gray" face="Courier New">EDITOR</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(354,76,200,16);
  
                % Analysis Button             
                analysisEditJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                analysisEditJButton.setText('Task');        
                analysisEditJButtonH = handle(analysisEditJButton,'CallbackProperties');
                set(analysisEditJButtonH, 'ActionPerformedCallback',@obj.createNewAnalysis_CB)
                myIcon = fullfile(icon_dir,'analysis_24.png');
                analysisEditJButton.setIcon(javax.swing.ImageIcon(myIcon));
                analysisEditJButton.setToolTipText('Open Analysis Task Editor');
                %analysisEditJButton.setFlyOverAppearance(true);
                analysisEditJButton.setBorder([]);
                analysisEditJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                analysisEditJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(analysisEditJButton);
                analysisEditJButton.setBounds(357,3 ,35, 71);
                obj.AnalysisEditJButton = analysisEditJButton;  
            
                % Trim Button             
                trimEditJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                trimEditJButton.setText('Trim');        
                trimEditJButtonH = handle(trimEditJButton,'CallbackProperties');
                set(trimEditJButtonH, 'ActionPerformedCallback',@obj.newTrimObj_CB)
                myIcon = fullfile(icon_dir,'airplaneTrim_24.png');
                trimEditJButton.setIcon(javax.swing.ImageIcon(myIcon));
                trimEditJButton.setToolTipText('Open Trim Definition Editor');
                %trimEditJButton.setFlyOverAppearance(true);
                trimEditJButton.setBorder([]);
                trimEditJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                trimEditJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(trimEditJButton);
                trimEditJButton.setBounds(397,3 ,35, 71);
                obj.TrimEditJButton = trimEditJButton;  
                
                % LinMdl Button             
                modelEditJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                modelEditJButton.setText('Model');        
                modelEditJButtonH = handle(modelEditJButton,'CallbackProperties');
                set(modelEditJButtonH, 'ActionPerformedCallback',@obj.newLinMdlObj_CB)
                myIcon = fullfile(icon_dir,'linmdl_24.png');
                modelEditJButton.setIcon(javax.swing.ImageIcon(myIcon));
                modelEditJButton.setToolTipText('Open Linear Model Editor');
                %modelEditJButton.setFlyOverAppearance(true);
                modelEditJButton.setBorder([]);
                modelEditJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                modelEditJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(modelEditJButton);
                modelEditJButton.setBounds(437,3 ,35, 71);
                obj.ModelEditJButton = modelEditJButton;  
                
                % LinMdl Button             
                reqEditJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                reqEditJButton.setText('Req');        
                reqEditJButtonH = handle(reqEditJButton,'CallbackProperties');
                set(reqEditJButtonH, 'ActionPerformedCallback',@obj.newMethodObj_CB)
                myIcon = fullfile(icon_dir,'InOut_24.png');
                reqEditJButton.setIcon(javax.swing.ImageIcon(myIcon));
                reqEditJButton.setToolTipText('Open Requirement Editor');
                %reqEditJButton.setFlyOverAppearance(true);
                reqEditJButton.setBorder([]);
                reqEditJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                reqEditJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(reqEditJButton);
                reqEditJButton.setBounds(477,3 ,35, 71);
                obj.ReqEditJButton = reqEditJButton;    
                
                % LinMdl Button             
                simReqEditJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                simReqEditJButton.setText('Sim');        
                simReqEditJButtonH = handle(simReqEditJButton,'CallbackProperties');
                set(simReqEditJButtonH, 'ActionPerformedCallback',@obj.newNonLinSimObj_CB)
                myIcon = fullfile(icon_dir,'Simulink_24.png');
                simReqEditJButton.setIcon(javax.swing.ImageIcon(myIcon));
                simReqEditJButton.setToolTipText('Open Requirement Editor');
                %simReqEditJButton.setFlyOverAppearance(true);
                simReqEditJButton.setBorder([]);
                simReqEditJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                simReqEditJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(simReqEditJButton);
                simReqEditJButton.setBounds(517,3 ,35, 71);
                obj.SimReqEditJButton = simReqEditJButton;  
                
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(557,3,2,90);

            
            labelStr = '<html><font color="gray" face="Courier New">OPTIONS</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(562,76,160,16);   
            
                % Show History Button             
                showInvalidTrimJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSComboBox');
%                 showInvalidTrimJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
%                 showInvalidTrimJCheckbox.setText('Show Invalid Trims');        
                showInvalidTrimJCheckboxH = handle(showInvalidTrimJCheckbox,'CallbackProperties');
                set(showInvalidTrimJCheckboxH, 'ActionPerformedCallback',@obj.showInvalidTrimCheckbox_CB)
                showInvalidTrimJCheckbox.setToolTipText('Show Invalid Trims');
%                 showInvalidTrimJCheckbox.setBorder([]);
%                 showInvalidTrimJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
                model = javax.swing.DefaultComboBoxModel({'Show All Trims','Show Valid Trims','Show Invalid Trims'});
                showInvalidTrimJCheckbox.setModel(model);  
                obj.JRibbonPanel.add(showInvalidTrimJCheckbox);
                showInvalidTrimJCheckbox.setBounds(565,3 ,135, 15);
                obj.ShowInvalidTrimJCheckbox = showInvalidTrimJCheckbox;
%                 obj.ShowInvalidTrimJCheckbox.setSelected(obj.ShowInvalidTrimState);
                
                
                
                        % Show History Button             
        plotsJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        plotsJButton.setText('Settings');        
        plotsJButtonH = handle(plotsJButton,'CallbackProperties');
        set(plotsJButtonH, 'ActionPerformedCallback',@obj.settingsButton_CB)
        myIcon = fullfile(icon_dir,'Settings_16.png');
        plotsJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        plotsJButton.setToolTipText('Settings');
        plotsJButton.setFlyOverAppearance(true);
        plotsJButton.setBorder([]);
        plotsJButton.setIconTextGap(2);
        plotsJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
        plotsJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
        plotsJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(plotsJButton);
        plotsJButton.setBounds(733,25 ,90, 28);
        obj.PlotJButton = plotsJButton; 
        
                
                % Display Log Signals in Trim Button             
                showLogSignalsJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
                showLogSignalsJCheckbox.setText('Display Log Signals');        
                showLogSignalsJCheckboxH = handle(showLogSignalsJCheckbox,'CallbackProperties');
                set(showLogSignalsJCheckboxH, 'ActionPerformedCallback',@obj.showLogSignalsCheckbox_CB)
                showLogSignalsJCheckbox.setToolTipText('Show logged signals');
                showLogSignalsJCheckbox.setBorder([]);
                showLogSignalsJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(showLogSignalsJCheckbox);
                showLogSignalsJCheckbox.setBounds(565,20 ,135, 15);
                obj.ShowLogSignalsJCheckbox = showLogSignalsJCheckbox;
                obj.ShowLogSignalsJCheckbox.setSelected(obj.ShowLoggedSignalsState);
                
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(725,3,2,90);

            
            labelStr = '<html><font color="gray" face="Courier New">SETTINGS</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color.lightGray);
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelview);
            jLabelview.setBounds(729,76,125,16);

            
                unitsSelComboBoxText = javaObjectEDT('javax.swing.JTextField');
                unitsSelComboBoxText.setText('Units');
                unitsSelComboBoxText.setBorder(javax.swing.BorderFactory.createEmptyBorder());
                unitsSelComboBoxText.setToolTipText('Select Units');
                unitsSelComboBoxText.setBackground(backgroundColor);
                unitsSelComboBoxText.setEditable(false);   
                obj.JRibbonPanel.add(unitsSelComboBoxText);
                unitsSelComboBoxText.setBounds(733,3,30,20);

                unitsSelComboBox = javaObjectEDT('javax.swing.JComboBox');
                unitsSelComboBoxH = handle(unitsSelComboBox,'CallbackProperties');
                set(unitsSelComboBoxH, 'ActionPerformedCallback',@obj.unitsSel_CB);  
                unitsSelComboBox.setToolTipText('Select Units');
                unitsSelComboBox.setEditable(false);
                model = javax.swing.DefaultComboBoxModel({'English - US','SI'});
                unitsSelComboBox.setModel(model);     
                obj.JRibbonPanel.add(unitsSelComboBox);
                unitsSelComboBox.setBounds(763,3,90,20);
                obj.UnitsSelComboBox = unitsSelComboBox;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
                
        % Show History Button             
        plotsJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        plotsJButton.setText('Settings');        
        plotsJButtonH = handle(plotsJButton,'CallbackProperties');
        set(plotsJButtonH, 'ActionPerformedCallback',@obj.settingsButton_CB)
        myIcon = fullfile(icon_dir,'Settings_16.png');
        plotsJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        plotsJButton.setToolTipText('Settings');
        plotsJButton.setFlyOverAppearance(true);
        plotsJButton.setBorder([]);
        plotsJButton.setIconTextGap(2);
        plotsJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
        plotsJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
        plotsJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(plotsJButton);
        plotsJButton.setBounds(733,25 ,90, 28);
        obj.PlotJButton = plotsJButton; 
                
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
                
                
            % Break    
            labelStr = '<html><i><font color="gray"></html>';
            jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelbk1.setOpaque(true);
            jLabelbk1.setBackground(java.awt.Color.lightGray);
            jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabelbk1);
            jLabelbk1.setBounds(857,3,2,90);    

            positionRibbon = getpixelposition(obj.Parent);
            [obj.JRPHComp,obj.JRPHCont] = javacomponent(obj.JRibbonPanel,[ 0 , 0 , positionRibbon(3) , positionRibbon(4) ], obj.Parent );


            obj.JRibbonPanel.setBackground(backgroundColor);
        end % ToolRibbon
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods

    %% Methods - Ordinary
    methods 
        
    end
    
    %% Methods - Callbacks
    methods 
        
        function setShowLoggedSignals(obj, state)
            obj.ShowLoggedSignalsState = state;
           obj.ShowLogSignalsJCheckbox.setSelected(obj.ShowLoggedSignalsState); 
        end % setShowLoggedSignals
        
        function setShowInvalidTrim(obj, state)
            obj.ShowInvalidTrimState = state;
           obj.ShowInvalidTrimJCheckbox.setSelectedItem(obj.ShowInvalidTrimState);
        end % setShowInvalidTrim
        
        function createNewAnalysis_CB( obj , ~ , ~ )
            notify(obj,'NewAnalysis');
        end % createNewAnalysis_CB
        
        function showLogSignalsCheckbox_CB( obj , ~ , eventdata )
            obj.ShowLoggedSignalsState = eventdata.getSource.isSelected;
            notify(obj,'ShowLogSignals',GeneralEventData(eventdata.getSource.isSelected));  
        end % showLogSignalsCheckbox_CB
        
        function showInvalidTrimCheckbox_CB( obj , hobj , eventdata )
%             obj.ShowInvalidTrimState = eventdata.getSource.isSelected;
%             notify(obj,'ShowInvalidTrim',GeneralEventData(eventdata.getSource.isSelected));
           notify(obj,'ShowTrimsChanged',UserInterface.UserInterfaceEventData(char(hobj.getSelectedItem))); 
        end % showInvalidTrimCheckbox_CB
        
        function tabPanelChanged( obj , ~ , eventdata )
            notify(obj,'TabPanelChanged',GeneralEventData(eventdata));
        end % tabPanelChanged
        
        function clearSelect_CB( obj , hobj , ~ )
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            

            runSaveIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'RunSave_24.png'));
            clrIon = javax.swing.ImageIcon(fullfile(icon_dir,'Clean_16.png'));
            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj}); 

            
            menuItem1 = javax.swing.JMenuItem('<html>Clear Table',clrIon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.clearTable_CB);

            menuItem2 = javax.swing.JMenu('<html>Export Table');
            
                menuItem2_1 = javax.swing.JMenuItem('<html>Export to Mat',runSaveIcon);
                menuItem2_1h = handle(menuItem2_1,'CallbackProperties');
                set(menuItem2_1h,'ActionPerformedCallback',@obj.exportTable_CB); 
            
                menuItem2_2 = javax.swing.JMenuItem('<html>Export to CSV',runSaveIcon);
                menuItem2_2h = handle(menuItem2_2,'CallbackProperties');
                set(menuItem2_2h,'ActionPerformedCallback',@obj.exportTableCSV_CB); 
                
                menuItem2_3 = javax.swing.JMenuItem('<html>Export to M script',runSaveIcon);
                menuItem2_3h = handle(menuItem2_3,'CallbackProperties');
                set(menuItem2_3h,'ActionPerformedCallback',@obj.exportTableM_CB);             
                
            menuItem2.add(menuItem2_1);        
            menuItem2.add(menuItem2_2);        
            menuItem2.add(menuItem2_3);  
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            
            jmenu.show(obj.ClrTblSelJButton, -95 , 20 );
            jmenu.repaint;      
        end % clearSelect_CB   
        
        function batchAdd_CB( obj , hobj , eventdata )
            notify(obj,'Add2Batch');
        end % batchAdd_CB
                
        function unitsSel_CB( obj , hobj , ~ )
            notify(obj,'UnitsChanged',UserInterface.UserInterfaceEventData(char(hobj.getSelectedItem))); 
        end % unitsSel_CB 
        
        function newProject_CB( obj , ~ , ~)
            notify(obj,'NewProject');
        end % newProject_CB
        
        function loadProject_CB( obj , ~ , ~)
            notify(obj,'LoadProject');
        end % loadProject_CB
        
        function closeProject_CB( obj , ~ , ~)
            notify(obj,'CloseProject');
        end % closeProject_CB
        
        function fileNew_CB( obj , hobj , ~)
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );

            analysisIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'analysis_24.png'));
            LMObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'linmdl_24.png'));
            methObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'InOut_24.png'));
            NLSimObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Simulink_24.png'));
            trimIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'airplaneTrim_24.png'));
            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,hobj};
            
            menuItem1 = javax.swing.JMenuItem('<html>Task',analysisIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem1h.ActionPerformedCallback = @obj.createNewAnalysis_CB;            
            
            menuItem2 = javax.swing.JMenuItem('<html>Trim',trimIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem2h.ActionPerformedCallback = @obj.newTrimObj_CB;      
            
            menuItem3 = javax.swing.JMenuItem('<html>Linear Model',LMObjIcon);
            menuItem3h = handle(menuItem3,'CallbackProperties');
            set(menuItem3h,'ActionPerformedCallback',@obj.newLinMdlObj_CB);
               
            menuItem4 = javax.swing.JMenuItem('<html>Requirement',methObjIcon);
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem4h.ActionPerformedCallback = @obj.newMethodObj_CB;  
            
            menuItem5 = javax.swing.JMenuItem('<html>Simulation Requirement',NLSimObjIcon);
            menuItem5h = handle(menuItem5,'CallbackProperties');
            menuItem5h.ActionPerformedCallback = @obj.newNonLinSimObj_CB;
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);

            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;       
        end % fileNew_CB    
        
        function fileOpen_CB( obj , hobj , ~)
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );

            analysisIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'analysis_24.png'));
            LMObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'linmdl_24.png'));
            methObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'InOut_24.png'));
            NLSimObjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Simulink_24.png'));
            trimIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'airplaneTrim_24.png'));
            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,hobj};
            
            menuItem1 = javax.swing.JMenuItem('<html>Task',analysisIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem1h.ActionPerformedCallback = @obj.openAnalysisObj_CB;  

            menuItem2 = javax.swing.JMenuItem('<html>Trim',trimIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem2h.ActionPerformedCallback = @obj.openTrimObj_CB;      
            
            menuItem3 = javax.swing.JMenuItem('<html>Linear Model',LMObjIcon);
            menuItem3h = handle(menuItem3,'CallbackProperties');
            set(menuItem3h,'ActionPerformedCallback',@obj.openLinMdlObj_CB);
               
            menuItem4 = javax.swing.JMenuItem('<html>Requirement',methObjIcon);
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem4h.ActionPerformedCallback = @obj.openMethodObj_CB;    
            
            menuItem5 = javax.swing.JMenuItem('<html>Simulation Requirement',NLSimObjIcon);
            menuItem5h = handle(menuItem5,'CallbackProperties');
            menuItem5h.ActionPerformedCallback = @obj.openNonLinSimObj_CB; 
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);

            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;       
        end % fileOpen_CB     

        function fileLoad_CB( obj , hobj , ~)
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            savePrjIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'LoadProject_24.png'));
            analysisIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'analysis_24.png'));
            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            jmenuh.PopupMenuWillBecomeInvisibleCallback = {@obj.popUpMenuCancelled,hobj};
            

            
            menuItem6 = javax.swing.JMenuItem('<html>Project',savePrjIcon);
            menuItem6h = handle(menuItem6,'CallbackProperties');
            menuItem6h.ActionPerformedCallback = @obj.loadWorkspace_CB; 
            
            menuItem11 = javax.swing.JMenuItem('<html>Task',analysisIcon);
            menuItem11h = handle(menuItem11,'CallbackProperties');
            menuItem11h.ActionPerformedCallback = @obj.loadAnalysisObj_CB;   
            
            
            % Add all menu items to the context menu
            jmenu.add(menuItem6);
            jmenu.add(menuItem11);

            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;       
        end % fileLoad_CB   
        
        function fileSave_CB( obj , hobj , ~)    
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            %obj.SaveJButton.setFlyOverAppearance(false);

            
            saveGainIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Save_Dirty_24.png'));
            saveWorkspaceIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'SaveProject_24.png'));

            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});

            saveJmenu = javax.swing.JMenu('<html>Save Operating Conditions');
            saveJmenu.setIcon(saveGainIcon);
            
            menuItem11 = javax.swing.JMenuItem('<html>All',saveGainIcon);
            menuItem11h = handle(menuItem11,'CallbackProperties');
            set(menuItem11h,'ActionPerformedCallback',{@obj.saveOperCond_CB,1});
            saveJmenu.add(menuItem11);
            
            menuItem21 = javax.swing.JMenuItem('<html>Valid Only',saveGainIcon);
            menuItem21h = handle(menuItem21,'CallbackProperties');
            set(menuItem21h,'ActionPerformedCallback',{@obj.saveOperCond_CB,0});
            saveJmenu.add(menuItem21);

            menuItem2 = javax.swing.JMenuItem('<html>Save Project',saveWorkspaceIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.saveWorkspace_CB); 
      
            % Add all menu items to the context menu
            jmenu.add(menuItem2);
            jmenu.add(saveJmenu);

            %SaveJButton
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;    
                    
        end % fileSave_CB
        
        function runRibbion_CB( obj , hobj , ~ )
            hobj.setSelected(true);
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            runIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'Run_24.png'));
            runSaveIcon  = javax.swing.ImageIcon(fullfile(icon_dir,'RunSave_24.png'));
            
            jmenu = javax.swing.JPopupMenu;
            jmenuh = handle(jmenu,'CallbackProperties');
            set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,hobj});

            
            menuItem1 = javax.swing.JMenuItem('<html>Run',runIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.run_CB);


            menuItem2 = javax.swing.JMenuItem('<html>Run and Save',runSaveIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.runAndSave_CB); 
            

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);

            
            jmenu.show(hobj, 0 , 69 );
            jmenu.repaint;   
        end % runRibbion_CB
        
        function popUpMenuCancelled( obj , ~ , ~ , comp )
            comp.setSelected(false);
        end % popUpMenuCancelled
        
        function clearTable_CB( obj , ~ , ~ )
            notify(obj,'ClearTable');
        end % clearTable_CB

        function methodButton_CB( gui , ~ , ~ )
            gui.CurrSelToolRibbion  = 2;
            gui.ToolRibbionSelectedText = 'Method';
            gui.TextColorMain   = [0 0 0];
            gui.TextColorMethod = [0 0 1];


            gui.ButtonColorMain   = [0.8 0.8 0.8];
            gui.ButtonColorMethod = [0 0 1];

            gui.update; 
        end % methodButton_CB
           
        function newWorkspace_CB( gui , ~ , ~ )
            
        end % newWorkspace_CB       
          
        function newTrimObj_CB( obj , ~ , ~ )
            notify(obj,'NewTrimObject');
        end % newTrimObj_CB
        
        function newLinMdlObj_CB( obj , ~ , ~ )
            notify(obj,'NewLinearModelObject');  
        end % newLinMdlObj_CB
        
        function newMethodObj_CB( obj , ~ , ~ )
            notify(obj,'NewMethodObject'); 
        end % newMethodObj_CB
        
        function newNonLinSimObj_CB( obj , ~ , ~ )
            notify(obj,'NewSimulationReqObject');
        end % newNonLinSimObj_CB
        
        function newPostSimObj_CB( obj , ~ , ~ )
            notify(obj,'NewPostSimulationReqObject');
        end % newPostSimObj_CB    
        
        function openAnalysisObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Analysis'));   
        end % openAnalysisObj_CB
    
        function openTrimObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Trim'));   
        end % openTrimObj_CB
        
        function openLinMdlObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Linear Model'));
        end % openLinMdlObj_CB
        
        function openMethodObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Requirement'));
        end % openMethodObj_CB
        
        function openNonLinSimObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Simulation Requirement'));
        end % openNonLinSimObj_CB
        
        function openPostNonLinSimObj_CB( obj , ~ , ~ )
            notify(obj,'OpenObject',GeneralEventData('Post Simulation Requirement'));
        end % openPostNonLinSimObj_CB
        
        function loadAnalysisObj_CB( obj , ~ , ~ )
            notify(obj,'LoadAnalysisObject');
        end % loadAnalysisObj_CB
        
        function loadSimulation_CB( obj , ~ , ~ )
            notify(obj,'LoadSimulation');
        end % loadSimulation_CB
        
        function loadWorkspace_CB( obj , ~ , ~)
            notify(obj,'LoadWorkspace');
        end % loadWorkspace_CB
            
        function batchRun_CB( gui , ~ , ~)
            notify(gui,'LoadBatchRun');
        end % batchRun_CB
        
        function saveOperCond_CB( gui , ~ , ~ , saveType)
            notify(gui,'SaveOperCond',GeneralEventData(saveType));          
        end % saveOperCond_CB
        
        function saveWorkspace_CB( gui , ~ , ~ )
            notify(gui,'SaveWorkspace');          
        end % saveWorkspace_CB
        
        function run_CB( obj , ~ , ~ )
            notify(obj,'Run');

        end % run_CB
        
        function runAndSave_CB( obj , ~ , ~ )
            notify(obj,'RunSave');
        end % runAndSave_CB 
          
        function exportTable_CB( obj , ~ , ~ )
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('mat'));
        end % exportTable_CB    
        
        function exportTableCSV_CB( obj , ~ , ~ )
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('csv'));
        end % exportTableCSV_CB   
        
        function exportTableM_CB( obj , ~ , ~ )
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('m'));
        end % exportTableCSV_CB

        function generateReport_CB( obj , ~ , ~ )
            notify(obj,'GenerateReport');
        end % generateReport_CB

        function settingsButton_CB( obj , ~ , ~ )
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
                        
            obj.PlotJButton.setFlyOverAppearance(false);
            
            settingsIcon = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Settings_16.png'));
            exportIcon   = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Figure_16.png'));
            checkIcon    = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'check_16.png'));
            
            
            
            jmenu = javaObjectEDT('javax.swing.JPopupMenu');
            jmenuh = handle(jmenu,'CallbackProperties');
%             set(jmenuh,'PopupMenuWillBecomeInvisibleCallback',{@obj.popUpMenuCancelled,'Plot'});

                plotTrimSettingsJmenu = javaObjectEDT('javax.swing.JMenuItem','<html>Trim Settings');
                plotTrimSettingsJmenu.setIcon(settingsIcon); 
                plotTrimSettingsJmenuh = handle(plotTrimSettingsJmenu,'CallbackProperties');
                plotTrimSettingsJmenuh.ActionPerformedCallback = @obj.setTrimSettings;

            
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
                    
                    
                    allPlots = isequal(obj.NumberOfPlotPerPageReq,...
                                obj.NumberOfPlotPerPagePostSim);
                    if allPlots
                        switch obj.NumberOfPlotPerPageReq
                            case 1
                                menuItem1h.setIcon(checkIcon);
                            case 2
                                menuItem2h.setIcon(checkIcon);
                            case 4
                                menuItem3h.setIcon(checkIcon);
                        end
                    end
                    
                    
                plotJmenuReq = javax.swing.JMenu('<html>Requirements');
                plotJmenuReq.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsPlts,1};
                    plotJmenuReq.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsPlts,2};
                    plotJmenuReq.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsPlts,4};
                    plotJmenuReq.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPageReq
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end
                    
                plotJmenuPS = javax.swing.JMenu('<html>Post Simulation');
                plotJmenuPS.setIcon(exportIcon);
                    menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>1');
                    menuItem1h = handle(menuItem1,'CallbackProperties');
                    menuItem1h.ActionPerformedCallback = {@obj.setNumPlotsPostPlts,1};
                    plotJmenuPS.add(menuItem1);
                    menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>2');
                    menuItem2h = handle(menuItem2,'CallbackProperties');
                    menuItem2h.ActionPerformedCallback = {@obj.setNumPlotsPostPlts,2};
                    plotJmenuPS.add(menuItem2);
                    menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>4');
                    menuItem3h = handle(menuItem3,'CallbackProperties');
                    menuItem3h.ActionPerformedCallback = {@obj.setNumPlotsPostPlts,4};
                    plotJmenuPS.add(menuItem3);
                    
                    switch obj.NumberOfPlotPerPagePostSim
                        case 1
                            menuItem1h.setIcon(checkIcon);
                        case 2
                            menuItem2h.setIcon(checkIcon);
                        case 4
                            menuItem3h.setIcon(checkIcon);
                    end


            plotTopJmenu.add(plotJmenu);
            plotTopJmenu.add(plotJmenuReq);
            plotTopJmenu.add(plotJmenuPS);

            
            jmenu.add(plotTopJmenu);
            jmenu.add(plotTrimSettingsJmenu);
            %SaveJButton
            jmenu.show(obj.PlotJButton, 0 , 28 );
            jmenu.repaint;   
        end % settingsButton_CB
        
        function setNumPlotsPlts( obj , ~ , ~ , numbPlots )
            obj.NumberOfPlotPerPageReq = numbPlots;
            notify(obj,'SetNumPlotsPlts',UserInterface.UserInterfaceEventData(numbPlots)); 
            
%             setOrientation( obj.AxisColl , numbPlots );            
%             obj.NumberOfPlotPerPagePlts = numbPlots;
            
        end % setNumPlotsPlts
        
        function setNumPlotsPostPlts( obj , ~ , ~ , numbPlots )
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            notify(obj,'SetNumPlotsPostPlts',UserInterface.UserInterfaceEventData(numbPlots)); 
%             setOrientation( obj.PostSimAxisColl , numbPlots );            
%             obj.NumberOfPlotPerPageStab = numbPlots;
            
        end % setNumPlotsPostPlts
        
        function setNumPlotsAll( obj , ~ , ~ , numbPlots )
            
            notify(obj,'SetNumPlotsPlts',UserInterface.UserInterfaceEventData(numbPlots)); 
            drawnow();pause(0.01);
            notify(obj,'SetNumPlotsPostPlts',UserInterface.UserInterfaceEventData(numbPlots)); 
            
            
            
            obj.NumberOfPlotPerPageReq = numbPlots;
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            
        end % setNumPlotsAll
        
        function setTrimSettings( obj , ~ , ~ )
            
            
%             objH = UserInterface.StabilityControl.TrimOptions;
%             uiwait(objH.Parent);
            obj.TrimSettings.createView();
            uiwait(obj.TrimSettings.Parent);
            
            notify(obj,'TrimSettingsChanged',UserInterface.UserInterfaceEventData(obj.TrimSettings)); 

        end % setTrimSettings
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       
        function update(obj)    
            
            set(obj.SelectPageText,'String',obj.ToolRibbionSelectedText);

            set(obj.MainText,'ForegroundColor',obj.TextColorMain);
            set(obj.LinmdlText,'ForegroundColor',obj.TextColorMethod);
            set(obj.RqText,'ForegroundColor',obj.TextColorRq);
            set(obj.GainsText,'ForegroundColor',obj.TextColorGains);
            set(obj.RootLocusText,'ForegroundColor',obj.TextColorRootLocus);
            set(obj.FilterText,'ForegroundColor',obj.TextColorFilter);

        end
    end
    
    %% Method - Delete
    methods
        function delete(obj)

            % Java Components 
            obj.JRibbonPanel = [];   
            obj.JRPHComp = [];
            obj.NewJButton = [];
            obj.OpenJButton = [];
            obj.LoadJButton = [];
            obj.SaveJButton = [];
            obj.RunJButton = [];
            obj.RunSelJButton = [];
            obj.ClrTblSelJButton = [];
            obj.MainJButton = [];
            obj.TrimEditJButton = [];
            obj.ModelEditJButton = [];
            obj.ReqEditJButton = [];
            obj.ShowInvalidTrimJCheckbox = [];
            obj.ShowLogSignalsJCheckbox = [];
            obj.UnitsSelComboBox = [];
            obj.SimReqEditJButton = [];
            
            % Javawrappers
            % Check if container is already being deleted
            if ~isempty(obj.JRPHCont) && ishandle(obj.JRPHCont) && strcmp(get(obj.JRPHCont, 'BeingDeleted'), 'off')
                delete(obj.JRPHCont)
            end

        end % delete
    end 
    
end