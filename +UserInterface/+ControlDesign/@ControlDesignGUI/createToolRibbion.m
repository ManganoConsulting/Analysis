function createToolRibbion(obj, currSelToolRibbion)
    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );



%     %% Create the Project Panel
%     obj.ProjectPanel = javaObjectEDT('javax.swing.JPanel');
%     obj.ProjectPanel.setLayout([]);  
%     
%             labelStr = '<html><font color="black" size="16" face="Courier New">PROJECT:</html>';
%             %labelStr = '<html><i><font color="gray" size="-2">FILE</html>';
%             jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
%             jLabelview.setOpaque(true);
%             %jLabelview.setBackground(java.awt.Color.lightGray);
%             jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
%             obj.ProjectPanel.add(jLabelview);
%             jLabelview.setBounds(10,5,200,75);
%             
%             labelStr = ['<html><font color="black" size="2" face="Courier New">FLIGHT Control Version ',obj.VersionNumber,'</html>'];
%             %labelStr = '<html><i><font color="gray" size="-2">FILE</html>';
%             jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
%             jLabelview.setOpaque(true);
%             %jLabelview.setBackground(java.awt.Color.lightGray);
%             jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
%             jLabelview.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
%             obj.ProjectPanel.add(jLabelview);
%             jLabelview.setBounds(600,35,300,75);


    backgroundColor = java.awt.Color(210/255,210/255,210/255); % java.awt.Color.lightGray

    %% Create the Home Panel
    

    obj.JRibbonPanel = javaObjectEDT('javax.swing.JPanel');
    obj.JRibbonPanel.setLayout([]);


    % File Section
    labelStr = '<html><font color="gray" face="Courier New">FILE</html>';
    %labelStr = '<html><i><font color="gray" size="-2">FILE</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setBackground(java.awt.Color.lightGray);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    %jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    obj.JRibbonPanel.add(jLabel);
    jLabel.setBounds(0,76,270,14);
    %[hcomponent,hcontainer] = javacomponent(jLabel,[0,0,230,10], obj.RibbonPanel );



        % New Button             
        newJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        newJButton.setText('New');        
        newJButtonH = handle(newJButton,'CallbackProperties');
        set(newJButtonH, 'ActionPerformedCallback',@obj.newRequierment_CB)
        myIcon = fullfile(icon_dir,'New_24.png');
        newJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        newJButton.setToolTipText('Add New Item');
        newJButton.setFlyOverAppearance(true);
        newJButton.setBorder([]);
        newJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
        newJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(newJButton);
        newJButton.setBounds(5,3,35,71);
        obj.NewJButton = newJButton;

        % Open Button             
        openJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        openJButton.setText('Open');        
        openJButtonH = handle(openJButton,'CallbackProperties');
        set(openJButtonH, 'ActionPerformedCallback',@obj.openRequierment_CB)%loadWorkspace_CB
        myIcon = fullfile(icon_dir,'Open_24.png');
        openJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        openJButton.setToolTipText('Open existing workspace');
        openJButton.setFlyOverAppearance(true);
        openJButton.setBorder([]);
        openJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
        openJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(openJButton);
        openJButton.setBounds(45,3 ,35, 71);
        obj.OpenJButton = openJButton;

        % Load Button             
        loadJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        loadJButton.setText('Load');        
        loadJButtonH = handle(loadJButton,'CallbackProperties');
        set(loadJButtonH, 'ActionPerformedCallback',@obj.fileLoad_CB)
        myIcon = fullfile(icon_dir,'LoadArrow_24.png');
        loadJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        loadJButton.setToolTipText('Load File');
        loadJButton.setFlyOverAppearance(true);
        loadJButton.setBorder([]);
        loadJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
        loadJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(loadJButton);
        loadJButton.setBounds(85,3 ,35, 71);
        obj.LoadJButton = loadJButton;

        % Save Button             
        saveJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        saveJButton.setText('Save');        
        saveJButtonH = handle(saveJButton,'CallbackProperties');
        set(saveJButtonH, 'ActionPerformedCallback',@obj.saveToolRibbon_CB)
        myIcon = fullfile(icon_dir,'Save_Dirty_24.png');
        saveJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        saveJButton.setToolTipText('Save');
        saveJButton.setFlyOverAppearance(true);
        saveJButton.setBorder([]);
        saveJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
        saveJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(saveJButton);
        saveJButton.setBounds(125,3 ,35, 71);
        obj.SaveJButton = saveJButton;

        % Export Button             
        exportJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        exportJButton.setText('Export');        
        exportJButtonH = handle(exportJButton,'CallbackProperties');
        set(exportJButtonH, 'ActionPerformedCallback',@obj.exportToolRibbon_CB)
        myIcon = fullfile(icon_dir,'Export_24.png');
        exportJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        exportJButton.setToolTipText('Save');
        exportJButton.setFlyOverAppearance(true);
        exportJButton.setBorder([]);
        exportJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
        exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
        obj.JRibbonPanel.add(exportJButton);
        exportJButton.setBounds(165,3 ,35, 71);
        obj.ExportJButton = exportJButton;

%             % Find directories
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             icon_dir = fullfile( this_dir,'..','..','Resources' );settingsIcon = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'Settings_16.png'));
        % Show History Button             
        plotsJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
        plotsJButton.setText('Settings');        
        plotsJButtonH = handle(plotsJButton,'CallbackProperties');
        set(plotsJButtonH, 'ActionPerformedCallback',@obj.settingsButton_CB)
        myIcon = fullfile(icon_dir,'Settings_16.png');
        plotsJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
        plotsJButton.setToolTipText('Show Design History');
        plotsJButton.setFlyOverAppearance(true);
        plotsJButton.setBorder([]);
        plotsJButton.setIconTextGap(2);
        plotsJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
        plotsJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
        plotsJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
%                 plotsJButton.setEnabled(false);
%                 plotsJButton.setVisible(false);
        obj.JRibbonPanel.add(plotsJButton);
        plotsJButton.setBounds(200,3 ,70, 28);
        obj.PlotJButton = plotsJButton;
        %javacomponent(plotsJButton, [125 44 95 28], obj.RibbonPanel);              

    % Break    
    labelStr = '<html><i><font color="gray"></html>';
    jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelbk1.setOpaque(true);
    jLabelbk1.setBackground(java.awt.Color.lightGray);
    jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelbk1);
    jLabelbk1.setBounds(272,3,2,90);
    %javacomponent(jLabelbk1,[232,0,2,70], obj.RibbonPanel );

    labelStr = '<html><font color="gray" face="Courier New">RUN</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color.lightGray);
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelview);
    jLabelview.setBounds(276,76,50,14);
    %javacomponent(jLabelview,[236,0,50,10], obj.RibbonPanel );


% %     % Run Button             
% %     runJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
% %     runJButton.setText('Run');        
% %     runJButtonH = handle(runJButton,'CallbackProperties');
% %     set(runJButtonH, 'ActionPerformedCallback',@obj.runAndSaveGains)
% %     myIcon = fullfile(icon_dir,'RunSave_24.png');
% %     runJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
% %     runJButton.setToolTipText('Run and Save');
% %     runJButton.setFlyOverAppearance(true);
% %     runJButton.setBorder([]);
% %     runJButton.setIconTextGap(2);
% %     runJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
% %     runJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
% %     runJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
% %     obj.JRibbonPanel.add(runJButton);
% %     runJButton.setBounds(281,3,40,46);
% %     % RunSel Button             
% %     runSelJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
% %     runSelJButton.setText('');        
% %     runSelJButtonH = handle(runSelJButton,'CallbackProperties');
% %     set(runSelJButtonH, 'ActionPerformedCallback',@obj.runToolR)
% %     myIcon = fullfile(icon_dir,'arrowDown_16.png');
% %     runSelJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
% %     runSelJButton.setToolTipText('Run');
% %     runSelJButton.setFlyOverAppearance(true);
% %     runSelJButton.setBorder([]);
% %     runSelJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
% %     runSelJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
% %     runSelJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
% %     obj.JRibbonPanel.add(runSelJButton);
% %     runSelJButton.setBounds(281,49,40,15);
% %     obj.RunSelJButton = runSelJButton;
    
                    
                runJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton');
                runJButton.setText('Run');        
                runJButtonH = handle(runJButton,'CallbackProperties');
                set(runJButtonH, 'ActionPerformedCallback',@obj.runAndSaveGains);
                set(runJButtonH, 'DropDownActionPerformedCallback',@obj.runToolR);
                myIcon = fullfile(icon_dir,'RunSave_24.png');
                runJButton.setIcon(javax.swing.ImageIcon(myIcon));
                runJButton.setToolTipText('Run and Save');
                runJButton.setBorder([]);
                runJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                runJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(runJButton);
                runJButton.setBounds(281,3,40,71);
                obj.RunSelJButton = runJButton;
                
            if currSelToolRibbion  == 4 
                obj.RunSelJButton.setEnabled(0);        
            else
                obj.RunSelJButton.setEnabled(1);
            end

            

    % Break    
    labelStr = '<html><i><font color="gray"></html>';
    jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelbk1.setOpaque(true);
    jLabelbk1.setBackground(java.awt.Color.lightGray);
    jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelbk1);
    jLabelbk1.setBounds(328,3,2,90);
    %javacomponent(jLabelbk1,[288,0,2,70], obj.RibbonPanel );

    labelStr = '<html><font color="gray" face="Courier New">VIEW</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color.lightGray);
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelview);
    jLabelview.setBounds(332,76,140,14);%(332,66,300,14);
    %javacomponent(jLabelview,[292,0,300,10], obj.RibbonPanel );

    % Main View Button             
    mainJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    mainJButton.setText('Main');   %('<html>Scatt<br />Gain</html>');   
    mainJButtonH = handle(mainJButton,'CallbackProperties');
    set(mainJButtonH, 'ActionPerformedCallback',{@obj.toolRibButtonPanelSel_CB,1,'Main'})
    myIcon = fullfile(icon_dir,'design_35.png');
    mainJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    mainJButton.setToolTipText('Switch to Main View');
    mainJButton.setFlyOverAppearance(true);
    mainJButton.setBorder([]);
    mainJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    mainJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(mainJButton);
    mainJButton.setBounds(337,3,40,71);
    %javacomponent(mainJButton, [297 12 40 60], obj.RibbonPanel);


    % Gain View Button             
    gainJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    gainJButton.setText('Gain');%('<html>Sch<br />Gain</html>');        
    gainJButtonH = handle(gainJButton,'CallbackProperties');
    set(gainJButtonH, 'ActionPerformedCallback',{@obj.toolRibButtonPanelSel_CB,4,'Gains'})
    myIcon = fullfile(icon_dir,'fit_app_35.png');%gains2
    gainJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    gainJButton.setToolTipText('Switch to Gain View');
    gainJButton.setFlyOverAppearance(true);
    gainJButton.setBorder([]);
    gainJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    gainJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(gainJButton);
    gainJButton.setBounds(382 ,3, 40 ,71);
    %gainJButton.setBounds(472, 3 ,40, 65);
    %javacomponent(gainJButton, [432 12 40 60], obj.RibbonPanel);  


    % Filter View Button             
    filterJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    filterJButton.setText('Filter');        
    filterJButtonH = handle(filterJButton,'CallbackProperties');
    set(filterJButtonH, 'ActionPerformedCallback',{@obj.toolRibButtonPanelSel_CB,6,'Filter'})
    myIcon = fullfile(icon_dir,'Filter_35.png');
    filterJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    filterJButton.setToolTipText('Switch to Filter View');
    filterJButton.setFlyOverAppearance(true);
    filterJButton.setBorder([]);
    filterJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    filterJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    filterJButton.setEnabled(true);
    obj.JRibbonPanel.add(filterJButton);
    filterJButton.setBounds(427,3, 40 ,71)
    %filterJButton.setBounds(517,3,40 ,65);%.setBounds(523,3,40,65);

    % Break    
    labelStr = '<html><i><font color="gray"></html>';
    jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelbk1.setOpaque(true);
    jLabelbk1.setBackground(java.awt.Color.lightGray);
    jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelbk1);
    jLabelbk1.setBounds(474,3,2,90);

    labelStr = '<html><font color="gray" face="Courier New">EDITOR</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color.lightGray);
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelview);
    jLabelview.setBounds(478,76,315,14);%(332,66,300,14);
    %javacomponent(jLabelview,[292,0,300,10], obj.RibbonPanel );

    % Synth Edit Button             
    synthJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    synthJButton.setText('SYN'); 
    synthJButtonH = handle(synthJButton,'CallbackProperties');
    set(synthJButtonH, 'ActionPerformedCallback',@obj.menuNewSynthesis)
    myIcon = fullfile(icon_dir,'gearsFull_35.png');
    synthJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    synthJButton.setToolTipText('Launch Synthesis Editor');
    synthJButton.setFlyOverAppearance(true);
    synthJButton.setBorder([]);
    synthJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    synthJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(synthJButton);
    synthJButton.setBounds(481,3,40,71);

    % Stab Edit Button             
    stabJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    stabJButton.setText('STAB'); 
    stabJButtonH = handle(stabJButton,'CallbackProperties');
    set(stabJButtonH, 'ActionPerformedCallback',@obj.menuNewStabReq)
    myIcon = fullfile(icon_dir,'workIcon_35_Blue.png');
    stabJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    stabJButton.setToolTipText('Launch Stability Requirement Editor');
    stabJButton.setFlyOverAppearance(true);
    stabJButton.setBorder([]);
    stabJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    stabJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(stabJButton);
    stabJButton.setBounds(526,3,40,71);   

    % FR Edit Button             
    frJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    frJButton.setText('FR'); 
    frJButtonH = handle(frJButton,'CallbackProperties');
    set(frJButtonH, 'ActionPerformedCallback',@obj.menuNewFRReq)
    myIcon = fullfile(icon_dir,'workIcon_35_Red.png');
    frJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    frJButton.setToolTipText('Launch FR Requirement Editor');
    frJButton.setFlyOverAppearance(true);
    frJButton.setBorder([]);
    frJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    frJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(frJButton);
    frJButton.setBounds(570,3,40,71);   

    % Sim Edit Button             
    simJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    simJButton.setText('SIM'); 
    simJButtonH = handle(simJButton,'CallbackProperties');
    set(simJButtonH, 'ActionPerformedCallback',@obj.menuNewSimReq)
    myIcon = fullfile(icon_dir,'workIcon_35_Yellow.png');%Simulink_35.png
    simJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    simJButton.setToolTipText('Launch Simulation Editor');
    simJButton.setFlyOverAppearance(true);
    simJButton.setBorder([]);
    simJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    simJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(simJButton);
    simJButton.setBounds(615,3,40,71);

    % HQ Edit Button             
    hqJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    hqJButton.setText('HQ'); 
    hqJButtonH = handle(hqJButton,'CallbackProperties');
    set(hqJButtonH, 'ActionPerformedCallback',@obj.menuNewHQReq)
    myIcon = fullfile(icon_dir,'workIcon_35_Blue.png');
    hqJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    hqJButton.setToolTipText('Launch HQ Requirement Editor');
    hqJButton.setFlyOverAppearance(true);
    hqJButton.setBorder([]);
    hqJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    hqJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(hqJButton);
    hqJButton.setBounds(660,3,40,71);

    % ASE Edit Button             
    aseJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    aseJButton.setText('ASE'); 
    aseJButtonH = handle(aseJButton,'CallbackProperties');
    set(aseJButtonH, 'ActionPerformedCallback',@obj.menuNewASEReq)
    myIcon = fullfile(icon_dir,'workIcon_35.png');
    aseJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    aseJButton.setToolTipText('Launch HQ Requirement Editor');
    aseJButton.setFlyOverAppearance(true);
    aseJButton.setBorder([]);
    aseJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    aseJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(aseJButton);
    aseJButton.setBounds(705,3,40,71);

    % Root Locus View Button             
    rtlocusJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
    rtlocusJButton.setText('RLocus');        
    rtlocusJButtonH = handle(rtlocusJButton,'CallbackProperties');
    set(rtlocusJButtonH, 'ActionPerformedCallback',@obj.menuNewRTLReq);
    myIcon = fullfile(icon_dir,'RTLocus_32.png');
    rtlocusJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
    rtlocusJButton.setToolTipText('Launch Root Locus Editor');
    rtlocusJButton.setFlyOverAppearance(true);
    rtlocusJButton.setBorder([]);
    rtlocusJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
    rtlocusJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    obj.JRibbonPanel.add(rtlocusJButton);
    rtlocusJButton.setBounds(750,3,40 ,71);

    % Break    
    labelStr = '<html><i><font color="gray"></html>';
    jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelbk1.setOpaque(true);
    jLabelbk1.setBackground(java.awt.Color.lightGray);
    jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
    obj.JRibbonPanel.add(jLabelbk1);
    jLabelbk1.setBounds(795,3,2,90);


    obj.JRibbonPanel.setVisible(false);

    positionRibbon = getpixelposition(obj.RibbonPanel);
    [obj.JRPHComp,obj.JRPHCont] = javacomponent(obj.JRibbonPanel,[0,0,positionRibbon(3) , positionRibbon(4)], obj.RibbonPanel );

    obj.JRibbonPanel.setBackground(backgroundColor);
        
    

end % createToolRibbion