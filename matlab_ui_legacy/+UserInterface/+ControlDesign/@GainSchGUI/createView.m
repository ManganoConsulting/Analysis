function createView( obj , parent )
    obj.Parent = parent;
    
    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );


    obj.Container = uipanel('Parent',obj.Parent,...
        'Title',obj.Title,...
        'BorderType',obj.BorderType,...
        'Units', obj.Units,...
        'Position',obj.Position);
    set(obj.Parent,'ResizeFcn',@obj.resize);

    posCont = getpixelposition(obj.Container);
    
    %% Scattered Gains Group
    obj.GainSelectionPanel = uipanel('Parent',obj.Container,...
        'Units','Pixels',...
        'Position', [ 1 , posCont(4) - 110 , 330 , 110 ]);

    %%% Scattered Gains Label %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="white" face="Courier New">&nbsp;Scattered Gains</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
    [obj.ScatterLabelComp,obj.ScatterLabelCont] = javacomponent(jLabelview, [ 1 , posCont(4) - 18 , 330 , 16 ] , obj.GainSelectionPanel );
    
    %%% Scattered Gain File Object: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Scattered Gain Collection:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.ScattFileName] = javacomponent(jLabel,[0,0,230,10], obj.GainSelectionPanel );
    
    scatGainFileComboBox = javaObjectEDT('javax.swing.JComboBox');
    scatGainFileComboBoxH = handle(scatGainFileComboBox,'CallbackProperties');
    set(scatGainFileComboBoxH, 'ActionPerformedCallback',@obj.scattGainFileSel_CB);
    %set(scatGainFileComboBoxH, 'MousePressedCallback',@obj.scattGainFileSelMP_CB);
    scatGainFileComboBox.setToolTipText('Scattered Gain Object');
    %scatGainFileComboBox.setEditable(true);
    [obj.HCompScatGainFile,obj.HContScatGainFile] = javacomponent( scatGainFileComboBox , [] , obj.GainSelectionPanel ); 
    model = javax.swing.DefaultComboBoxModel({' '});
    obj.HCompScatGainFile.setModel(model);
    
    %%% Select Scattered Gain: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Select Scattered Gain:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jlabelH = handle(jLabel,'CallbackProperties');
%     set(jlabelH, 'MousePressedCallback',@obj.mousePressedScatGainSel);  
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.TextGainName] = javacomponent(jLabel,[0,0,230,10], obj.GainSelectionPanel );

    gainSelComboBox = javaObjectEDT('javax.swing.JComboBox');
    gainSelComboBoxH = handle(gainSelComboBox,'CallbackProperties');
    set(gainSelComboBoxH, 'ActionPerformedCallback',@obj.gainSel_CB);
    gainSelComboBox.setToolTipText('Select the Gain');
    gainSelComboBox.setEditable(true);
    [obj.HCompGainSel,obj.HContGainSel] = javacomponent( gainSelComboBox , [] , obj.GainSelectionPanel ); 
    model = javax.swing.DefaultComboBoxModel({' '});
    obj.HCompGainSel.setModel(model);
    
    
    %%% Independent Variable: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Independent Variable:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jlabelH = handle(jLabel,'CallbackProperties');
%     set(jlabelH, 'MousePressedCallback',@obj.mousePressedIndVarSel); 
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.IndVarText] = javacomponent(jLabel,[0,0,230,10], obj.GainSelectionPanel );
    
    IndVarComboBox = javaObjectEDT('javax.swing.JComboBox');
    IndVarComboBoxH = handle(IndVarComboBox,'CallbackProperties');
    set(IndVarComboBoxH, 'ActionPerformedCallback',@obj.indVar_CB);
    IndVarComboBox.setToolTipText('Select the Independant Variable');
    IndVarComboBox.setEditable(true);
    [obj.HCompIndVar,obj.HContIndVar] = javacomponent( IndVarComboBox , [5 12 35 60] , obj.GainSelectionPanel ); 

    %%% Edit Scattered Gain List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    editScattGainListJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    editScattGainListJButton.setText('Edit');        
    editScattGainListJButtonH = handle(editScattGainListJButton,'CallbackProperties');
    set(editScattGainListJButtonH, 'ActionPerformedCallback',@obj.updateSelectableScatteredGains)
    myIcon = fullfile(icon_dir,'Settings_16.png');
    editScattGainListJButton.setIcon(javax.swing.ImageIcon(myIcon));
    editScattGainListJButton.setToolTipText('Remove Scheduled Gain Name');
    editScattGainListJButton.setFlyOverAppearance(true);
    editScattGainListJButton.setBorder([]);
    editScattGainListJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    editScattGainListJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    editScattGainListJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.EditGainListButtonHComp,obj.EditGainListJButtonHCont] = javacomponent(editScattGainListJButton, [], obj.GainSelectionPanel);  
    
    %%% Edit Independant Variable List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    editIndVarListJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    editIndVarListJButton.setText('Edit');        
    editIndVarListJButtonH = handle(editIndVarListJButton,'CallbackProperties');
    set(editIndVarListJButtonH, 'ActionPerformedCallback',@obj.updateSelectableIndependantVars)
    myIcon = fullfile(icon_dir,'Settings_16.png');
    editIndVarListJButton.setIcon(javax.swing.ImageIcon(myIcon));
    editIndVarListJButton.setToolTipText('Remove Scheduled Gain Name');
    editIndVarListJButton.setFlyOverAppearance(true);
    editIndVarListJButton.setBorder([]);
    editIndVarListJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    editIndVarListJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    editIndVarListJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.EditIndVarListButtonHComp,obj.EditIndVarListJButtonHCont] = javacomponent(editIndVarListJButton, [], obj.GainSelectionPanel); 
    
	%% Scheduled Gains Group
    obj.GainSchedulePanel = uipanel('Parent',obj.Container,...
        'Units','Pixels',...
        'Position', [ 1 , posCont(4) - 320 , 330 , 200 ]);
    
    labelStr = '<html><font color="white" face="Courier New">&nbsp;Scheduled Gains</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
    [obj.SchLabelComp,obj.SchLabelCont] = javacomponent(jLabelview, [ 1 , posCont(4) - 18 , 330 , 16 ] , obj.GainSchedulePanel );
    
    %%% Scheduled Gain Object: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Scheduled Gain Collection:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.SchFileName] = javacomponent(jLabel,[0,0,280,10], obj.GainSchedulePanel );

    selSchFileComboBox = javaObjectEDT('javax.swing.JComboBox');
    selSchFileComboBoxH = handle(selSchFileComboBox,'CallbackProperties');
    set(selSchFileComboBoxH, 'ActionPerformedCallback',@obj.schGainFileSel_CB);
    selSchFileComboBox.setToolTipText('Scheduled Gain File');
    [obj.HCompSelSchFile,obj.HContSelSchFileFile] = javacomponent( selSchFileComboBox , [] , obj.GainSchedulePanel ); 
    model = javax.swing.DefaultComboBoxModel({'Add New ...'});
    obj.HCompSelSchFile.setModel(model);
    
    %%% Add Scheduled Gain Collection Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     newSchJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSSplitButton','Vertical');
    newSchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    newSchJButton.setText('Add');        
    newSchJButtonH = handle(newSchJButton,'CallbackProperties');
    set(newSchJButtonH, 'ActionPerformedCallback',@obj.newSchedule_CB);
%     set(newSchJButtonH, 'DropDownActionPerformedCallback',@obj.popUpSchedule);
    myIcon = fullfile(icon_dir,'New_16.png');
    newSchJButton.setIcon(javax.swing.ImageIcon(myIcon));
    newSchJButton.setToolTipText('Create new gain schedule');
    newSchJButton.setFlyOverAppearance(true);
    newSchJButton.setBorder([]);
    newSchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    newSchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    newSchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.NewSchJButtonHComp,obj.NewSchJButtonHCont] = javacomponent(newSchJButton, [], obj.GainSchedulePanel);  
%     %%% Add Scheduled Gain Collection Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     newSchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
%     newSchJButton.setText('Add');        
%     newSchJButtonH = handle(newSchJButton,'CallbackProperties');
%     set(newSchJButtonH, 'ActionPerformedCallback',@obj.newSchedule_CB)
%     myIcon = fullfile(icon_dir,'New_16.png');
%     newSchJButton.setIcon(javax.swing.ImageIcon(myIcon));
%     newSchJButton.setToolTipText('Create new gain schedule');
%     newSchJButton.setFlyOverAppearance(true);
%     newSchJButton.setBorder([]);
%     newSchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
%     newSchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
%     newSchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
%     [obj.NewSchJButtonHComp,obj.NewSchJButtonHCont] = javacomponent(newSchJButton, [], obj.GainSchedulePanel);  
    %%% Remove Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    removeSchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    removeSchJButton.setText('Remove');        
    removeSchJButtonH = handle(removeSchJButton,'CallbackProperties');
    set(removeSchJButtonH, 'ActionPerformedCallback',@obj.removeSchedule_CB)
    myIcon = fullfile(icon_dir,'StopX_16.png');
    removeSchJButton.setIcon(javax.swing.ImageIcon(myIcon));
    removeSchJButton.setToolTipText('Remove Scheduled Gain Collection');
    removeSchJButton.setFlyOverAppearance(true);
    removeSchJButton.setBorder([]);
    removeSchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    removeSchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    removeSchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.RemoveSchCollJButtonHComp,obj.RemoveSchCollJButtonHCont] = javacomponent(removeSchJButton, [], obj.GainSchedulePanel);  
    
    

    
    %%% Export Scheduled Gain Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    expSchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    expSchJButton.setText('Export');        
    expSchJButtonH = handle(expSchJButton,'CallbackProperties');
    set(expSchJButtonH, 'ActionPerformedCallback',@obj.exportSchedule_CB)
    myIcon = fullfile(icon_dir,'Export_16.png');
    expSchJButton.setIcon(javax.swing.ImageIcon(myIcon));
    expSchJButton.setToolTipText('Create new gain schedule');
    expSchJButton.setFlyOverAppearance(true);
    expSchJButton.setBorder([]);
    expSchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    expSchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    expSchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.ExportSchJButtonHComp,obj.ExportSchJButtonHCont] = javacomponent(expSchJButton, [], obj.GainSchedulePanel);  
      
    %%% Scheduled Gain Name: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Scheduled Gain Name:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.SchGainName] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );

    schGainNameComboBox = javaObjectEDT('javax.swing.JComboBox');
    schGainNameComboBoxH = handle(schGainNameComboBox,'CallbackProperties');
    set(schGainNameComboBoxH, 'ActionPerformedCallback',@obj.schGainNameSel_CB);
    schGainNameComboBox.setToolTipText('Scheduled Gain Name');
    [obj.HCompSchGainName,obj.HContSchGainName] = javacomponent( schGainNameComboBox , [] , obj.GainSchedulePanel ); 
    if isempty(obj.ScheduledGainNamesArray)
        obj.ScheduledGainNamesArray = {' '};
    end
    model = javax.swing.DefaultComboBoxModel(obj.ScheduledGainNamesArray);
    obj.HCompSchGainName.setModel(model);
    
    %%% Add Scheduled Gain Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newSchGainNameJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    newSchGainNameJButton.setText('Add');        
    newSchGainNameJButtonH = handle(newSchGainNameJButton,'CallbackProperties');
    set(newSchGainNameJButtonH, 'ActionPerformedCallback',@obj.newSchGainName_CB)
    myIcon = fullfile(icon_dir,'New_16.png');
    newSchGainNameJButton.setIcon(javax.swing.ImageIcon(myIcon));
    newSchGainNameJButton.setToolTipText('Create new gain name');
    newSchGainNameJButton.setFlyOverAppearance(true);
    newSchGainNameJButton.setBorder([]);
    newSchGainNameJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    newSchGainNameJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    newSchGainNameJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.NewSchGainNameJButtonHComp,obj.NewSchGainNameJButtonHCont] = javacomponent(newSchGainNameJButton, [], obj.GainSchedulePanel);  

    %%% Remove Scheduled Gain Object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rmSchGainNameJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    rmSchGainNameJButton.setText('Remove');        
    rmSchGainNameJButtonH = handle(rmSchGainNameJButton,'CallbackProperties');
    set(rmSchGainNameJButtonH, 'ActionPerformedCallback',@obj.rmScheduleGainName_CB)
    myIcon = fullfile(icon_dir,'StopX_16.png');
    rmSchGainNameJButton.setIcon(javax.swing.ImageIcon(myIcon));
    rmSchGainNameJButton.setToolTipText('Remove Scheduled Gain Name');
    rmSchGainNameJButton.setFlyOverAppearance(true);
    rmSchGainNameJButton.setBorder([]);
    rmSchGainNameJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    rmSchGainNameJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    rmSchGainNameJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.RemoveSchGainNameJButtonHComp,obj.RemoveSchGainNameJButtonHCont] = javacomponent(rmSchGainNameJButton, [], obj.GainSchedulePanel);  
    
    %%% Dimension: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Dimension:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.TextDimension] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );

%     tableDimComboBox = javaObjectEDT('javax.swing.JComboBox');
%     tableDimComboBoxH = handle(tableDimComboBox,'CallbackProperties');
%     set(tableDimComboBoxH, 'ActionPerformedCallback',@obj.tableDim_CB)
%     tableDimComboBox.setToolTipText('Select the Name');
%     tableDimComboBox.setEditable(false);
%     [obj.HCompTableDim,obj.HContTableDim] = javacomponent( tableDimComboBox , [] , obj.GainSchedulePanel ); 
%     model = javax.swing.DefaultComboBoxModel({'1-D','2-D'});
%     obj.HCompTableDim.setModel(model);
%     obj.HCompTableDim.setSelectedIndex( 1 ); % default to 2-D
% %     obj.HCompTableDim.SelectedIndex = 1; % default to 2-D

    obj.HContTableDim = uicontrol(...
        'Parent',obj.GainSchedulePanel,...
        'Style','popupmenu',...
        'String', {'1-D','2-D'},...
        'Value',obj.SelectedTableDimension,...
        'BackgroundColor', [1 1 1],...
        'Enable','on',...
        'Callback',@obj.tableDim_CB);
    
    %%% Break Points 1 Name: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Break Points 1 Name:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [~,obj.TextBP1Name] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );

    obj.BP1Name_eb = uicontrol(...
        'Parent',obj.GainSchedulePanel,...
        'Style','edit',...
        'String', obj.BreakPoints1TableName,...
        'BackgroundColor', [1 1 1],...
        'Enable','on',...
        'Callback',@obj.bp1TableName_CB);
    
    %%% Break Points 2 Name: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Break Points 2 Name:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [obj.TextBP2Name,obj.TextBP2NameCont] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );  

    obj.BP2Name_eb = uicontrol(...
        'Parent',obj.GainSchedulePanel,...
        'Style','edit',...
        'String', obj.BreakPoints2TableName,...%'FontSize',popupFtSize,...
        'BackgroundColor', [1 1 1],...
        'Enable','on',...
        'Callback',@obj.bp2TableName_CB);

    %%% Break Points 1 Value: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    labelStr = '<html><font color="black" face="Courier New">Break Points 1 Value:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [obj.TextBP1Value,obj.TextBP1ValueCont] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );  

    obj.BP1ValueString_eb = uicontrol(...
        'Parent',obj.GainSchedulePanel,...
        'Style','edit',...
        'String', obj.BP1ValueString,...
        'BackgroundColor', [1 1 1],...
        'Enable','on',...
        'Callback',@obj.bp1Value_CB);
        
    %%% Break Points 2 Value: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="black" face="Courier New">Break Points 2 Values:</html>';
    jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabel.setOpaque(true);
    jLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabel.setVerticalAlignment(javax.swing.SwingConstants.TOP);
    [obj.TextBP,obj.TextBPCont] = javacomponent(jLabel,[0,0,230,10], obj.GainSchedulePanel );  

    obj.BP_eb = uicontrol(...
        'Parent',obj.GainSchedulePanel,...
        'Style','edit',...
        'String', obj.BreakPointsString,...
        'BackgroundColor', [1 1 1],...
        'Enable','on',...
        'Callback',@obj.bp_CB);
        
    %% Gain Fit 
        
    obj.GainFittingPanel = uipanel('Parent',obj.Container,...
        'Units','Pixels');
    
    %%% Gain Fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    labelStr = '<html><font color="white" face="Courier New">&nbsp;Gain Fit</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
    [obj.GainFitLabelComp,obj.GainFitLabelCont] = javacomponent(jLabelview, [ 1 , posCont(4) - 18 , 330 , 16 ] , obj.GainFittingPanel ); 
           
    obj.PolyFitTable = uitable('Parent',obj.GainFittingPanel,...
        'ColumnName',{'Polynomial Order','Fitting Range'},...
        'RowName',[],...
        'ColumnEditable', [true,true],...
        'ColumnFormat',{'char', 'char'},...
        'ColumnWidth',{100,200},...
        'Data',obj.PolyFitData,...
        'CellEditCallback', @obj.polyTable_ce_CB,...
        'CellSelectionCallback', @obj.polyTable_cs_CB); 
    
    %%% Schedule %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    schJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    schJButton.setText('Schedule');        
    schJButtonH = handle(schJButton,'CallbackProperties');
    set(schJButtonH, 'ActionPerformedCallback',@obj.schedule_CB)
    myIcon = fullfile(icon_dir,'fit_app_16.png');
    schJButton.setIcon(javax.swing.ImageIcon(myIcon));
    schJButton.setToolTipText('Create new workspace');
    schJButton.setFlyOverAppearance(true);
    schJButton.setBorder([]);
    schJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    schJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    schJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.SchJButtonHComp,obj.SchJButtonHCont] = javacomponent(schJButton, [], obj.GainFittingPanel);
     
    %%% Clear Schedule %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    removeSchJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    removeSchJButton.setText('Clear Plot');        
    removeSchJButtonH = handle(removeSchJButton,'CallbackProperties');
    set(removeSchJButtonH, 'ActionPerformedCallback',@obj.removeSch_CB)
    myIcon = fullfile(icon_dir,'Clean_16.png');
    removeSchJButton.setIcon(javax.swing.ImageIcon(myIcon));
    removeSchJButton.setToolTipText('Remove Scheduled Plot');
    removeSchJButton.setFlyOverAppearance(true);
    removeSchJButton.setBorder([]);
    removeSchJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    removeSchJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    removeSchJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.RemoveSchJButtonHComp,obj.RemoveSchJButtonHCont] = javacomponent(removeSchJButton, [], obj.GainFittingPanel);    
        
    %% Options
    obj.OptionsPanel = uipanel('Parent',obj.Container,...
        'Units','Pixels');
    
    labelStr = '<html><font color="white" face="Courier New">&nbsp;Options</html>';
    jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
    jLabelview.setOpaque(true);
    jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
    jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
    jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
    [obj.OptionsLabelComp,obj.OptionsLabelCont] = javacomponent(jLabelview, [ 1 , posCont(4) - 18 , 330 , 16 ] , obj.OptionsPanel ); 
    
        
    %%% Option Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.TableModel = javax.swing.table.DefaultTableModel(cell(5,5),{' ',' ',' ',' ',' '});
    obj.JTable = javaObjectEDT(javax.swing.JTable(obj.TableModel));
    obj.JTableH = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');  % ensure that we're using EDT
    obj.JScroll = javaObjectEDT(javax.swing.JScrollPane(obj.JTable));
    obj.FixColTbl= javaObjectEDT(FixedColumnTable(1, obj.JScroll));
    [obj.JHScroll,obj.HContainer] = javacomponent(obj.JScroll, [], obj.OptionsPanel);

    obj.JScroll.setVerticalScrollBarPolicy(obj.JScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
    obj.JScroll.setHorizontalScrollBarPolicy(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    obj.JTable.setAutoResizeMode( obj.JTable.AUTO_RESIZE_OFF );


    % Set Callbacks
    obj.JTableH.MousePressedCallback = @obj.mousePressedInTable;
    JModelH = handle(obj.JTable.getModel, 'CallbackProperties');
    JModelH.TableChangedCallback     = {@obj.dataUpdatedInTable,obj.JTable};
              
    %%% Plot Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    viewTableJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    viewTableJButton.setText('Plot Table');        
    viewTableJButtonH = handle(viewTableJButton,'CallbackProperties');
    set(viewTableJButtonH, 'ActionPerformedCallback',@obj.viewTable_CB)
    myIcon = fullfile(icon_dir,'SendToFigure_16.png');
    viewTableJButton.setIcon(javax.swing.ImageIcon(myIcon));
    viewTableJButton.setToolTipText('View Table');
    viewTableJButton.setFlyOverAppearance(true);
    viewTableJButton.setBorder([]);
    viewTableJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    viewTableJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    viewTableJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.ViewTableJButtonHComp,obj.ViewTableJButtonHCont] = javacomponent(viewTableJButton, [], obj.OptionsPanel);
    
    %%% Remove Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    removeRowJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    removeRowJButton.setText('Remove');        
    removeRowJButtonH = handle(removeRowJButton,'CallbackProperties');
    set(removeRowJButtonH, 'ActionPerformedCallback',@obj.removeRowGainTable)
    myIcon = fullfile(icon_dir,'StopX_16.png');
    removeRowJButton.setIcon(javax.swing.ImageIcon(myIcon));
    removeRowJButton.setToolTipText('Remove Gain');
    removeRowJButton.setFlyOverAppearance(true);
    removeRowJButton.setBorder([]);
    removeRowJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    removeRowJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    removeRowJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.RemoveRowJButtonHComp,obj.RemoveRowJButtonHCont] = javacomponent(removeRowJButton, [], obj.OptionsPanel);  
    
    %%% Export Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    exportTableJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
    exportTableJButton.setText('Export Table');        
    exportTableJButtonH = handle(exportTableJButton,'CallbackProperties');
    set(exportTableJButtonH, 'ActionPerformedCallback',@obj.exportTable_CB)
    myIcon = fullfile(icon_dir,'Export_16.png');
    exportTableJButton.setIcon(javax.swing.ImageIcon(myIcon));
    exportTableJButton.setToolTipText('Export Table');
    exportTableJButton.setFlyOverAppearance(true);
    exportTableJButton.setBorder([]);
    exportTableJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
    exportTableJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
    exportTableJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
    [obj.ExportTableJButtonHComp,obj.ExportTableJButtonHCont] = javacomponent(exportTableJButton, [], obj.OptionsPanel);    
            
    %% Axis        
    %%% Axis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.GainSchAxisColl = UserInterface.AxisPanelCollection('Parent',obj.Container,'NumOfPages',1,'NumOfAxisPerPage',1);
    for i = 0:obj.GainSchAxisColl.AxisHandleQueue.size-1
        set(obj.GainSchAxisColl.AxisHandleQueue.get(i),'Visible','on');
    end
    
    
    %% Update 
    updateTable( obj );
    setScatteredGainFileComboBox( obj );
    setGainSelectionComboBox( obj ); 
    setIndVarComboBox( obj );
    setSchGainFileComboBox( obj );
    update( obj );
            
   resize( obj , [] , [] );
end % createView


