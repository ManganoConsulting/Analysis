classdef Editor < UserInterface.Collection
    %% Public properties - Graphics Handles
    properties (Transient = true)
        NewJButton
        LoadJButton
        OpenJButton
        JRibbonPanel
        JRPHComp
        JRPHCont
        
        RibbonPanel
        MainPanel
        
        SaveSelJButton
        ExportJButton
        
        
    end % Public properties
  
    %% Public properties - Data Storage
    properties
        CurrentObjFullName = ''
        Saved logical = true
%         LoadingSaved@logical = false 
        EditInProject logical = false 
        ShowLoadButton = true
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        CurrentReqObj
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        StartDirectory
%         SaveCancelled = false
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        Figure
        CurrentObjDirectory
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  
    
    %% Events
    events
        NewButtonPressed
        OpenButtonPressed
        SaveButtonPressed
        ObjectLoaded
        ObjectCreated
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = Editor(varargin)  

            p = inputParser;
            addParameter(p,'Parent',figure);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'BorderType','none');
            addParameter(p,'StartDirectory',pwd);
            addParameter(p,'EditInProject',false,@islogical);
            addParameter(p,'Requirement',[]);
            addParameter(p,'EditAsHandle',false,@islogical);
            addParameter(p,'FileName','Untitled');
            addParameter(p,'ShowLoadButton',true,@islogical);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj@UserInterface.Collection('Parent',options.Parent,'Units',options.Units,'Position',options.Position,'Title',options.Title,'BorderType',options.BorderType); 
            obj.EditInProject = options.EditInProject;
            obj.ShowLoadButton = options.ShowLoadButton;
            
            if options.EditAsHandle
                obj.CurrentReqObj = options.Requirement;
            else
                if ~isempty(options.Requirement)
                    obj.CurrentReqObj = copy(options.Requirement);
                end
            end
            
            if ~isempty(obj.CurrentReqObj)
                obj.CurrentObjFullName     = options.FileName;
%                 [~,filename] = fileparts(obj.CurrentObjFullName);
%                 obj.CurrentReqObj.FileName = filename;
            end
            
            position = obj.Parent.Position;
            obj.Parent.Position = [ position(1) , position(2) - 200 , 487 , 615 ];
            
            createView( obj , obj.Parent );
            update(obj);
        end % Editor
    end % Editor

    %% Methods - Property Access
    methods
        
        function y = get.Figure(obj)
            if ~isempty(obj.Parent)
                y = ancestor(obj.Parent,'figure','toplevel');
            else
                y = [];
            end
        end % Figure   
        
        function y = get.CurrentObjDirectory(obj)
            if ~isempty(obj.CurrentObjFullName)
                y = fileparts(obj.CurrentObjFullName);
            else
                y = [];
            end
        end % CurrentObjDirectory  
        
        function set.CurrentReqObj( obj , newObj )
            observeProp = findAttrValue(newObj,'SetObservable',true);
            
            
            obj.CurrentReqObj = newObj;
            
            for i = 1:length(observeProp)
                addlistener(obj.CurrentReqObj,observeProp{i},'PostSet',@(src,event) obj.propertyChanged_CB(src,event));
            end
            
        end % CurrentReqObj
        
    end % Property access methods
    
    %% Methods - View
    methods
        
        function createView( obj , parent )  
            
            obj.Parent = parent;
            
            obj.Figure.MenuBar = 'None';
            obj.Figure.NumberTitle = 'off';
            
            warn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            if ~( strcmp(version('-release'),'2015b') || strcmp(version('-release'),'2016a')  || strcmp(version('-release'),'2016a')  || strcmp(version('-release'),'2023a'))
                jFig = get(handle(obj.Figure), 'JavaFrame');
                pause(0.1);
                jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension( 487 , 675 ));       
            end
            warning(warn);
            if ~isempty(parent)
                obj.Parent = parent;
            end
            obj.Container = uipanel('Parent',obj.Parent,...
                'BorderType',obj.BorderType,...
                'Title',obj.Title,...
                'Units', obj.Units,...
                'Position',obj.Position,...
                'Visible','on');
            %set(obj.Container,'ResizeFcn',@obj.reSize);   
            set(obj.Container,'SizeChangedFcn',@obj.reSize);  
            position = getpixelposition(obj.Container);
            % Create Tool Ribbion
            obj.RibbonPanel = uipanel('Parent',obj.Container,...
                'Units','Pixels',...
                'BorderType','none',...
                'Position',[ 1 , position(4)-93 , position(3), 93 ]);
         
            % Create Main Container
            obj.MainPanel = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[1 , 1 , position(3) , position(4)-93 ]); 
            
            % Create the tool ribbon
            createToolRibbion(obj);
            
            % Create Object view if available
            if ~isempty(obj.CurrentReqObj)
                createView (obj.CurrentReqObj , obj.MainPanel );
                addlistener(obj.CurrentReqObj,'Title','PostSet',@obj.setFileTitle);
                setFileTitle( obj );
            end
            
            % Set visability to on
            obj.JRibbonPanel.setVisible(true);
            
        end % createView
        
        function createToolRibbion(obj)
            
            obj.JRibbonPanel = javaObjectEDT('javax.swing.JPanel');
            obj.JRibbonPanel.setLayout([]);
            
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );
            
            % File Section
            labelStr = '<html><font color="gray" face="Courier New">FILE</html>';
            jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabel.setOpaque(true);
            jLabel.setBackground(java.awt.Color.lightGray);
            jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            obj.JRibbonPanel.add(jLabel);
            jLabel.setBounds(0,76,163,16);%(0,66,123,14);

            
            
                % New Button             
                newJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                newJButton.setText('New');        
                newJButtonH = handle(newJButton,'CallbackProperties');
                set(newJButtonH, 'ActionPerformedCallback',@obj.newButton_CB)
                myIcon = fullfile(icon_dir,'New_24.png');
                newJButton.setIcon(javax.swing.ImageIcon(myIcon));
                newJButton.setToolTipText('Add New Item');
                newJButton.setBorder([]);
                newJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                obj.JRibbonPanel.add(newJButton);
                newJButton.setBounds(5,3,35,71);
                obj.NewJButton = newJButton;
                
                % Open Button             
                openJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                openJButton.setText('Open');        
                openJButtonH = handle(openJButton,'CallbackProperties');
                set(openJButtonH, 'ActionPerformedCallback',@obj.openButton_CB)
                myIcon = fullfile(icon_dir,'Open_24.png');
                openJButton.setIcon(javax.swing.ImageIcon(myIcon));
                openJButton.setToolTipText('Open existing workspace');
                openJButton.setFlyOverAppearance(true);
                openJButton.setBorder([]);
                openJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                openJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                obj.JRibbonPanel.add(openJButton);
                openJButton.setBounds(45,3 ,35, 71);   
                obj.OpenJButton = openJButton;
                  
                if obj.ShowLoadButton
                            % Load Button             
                            loadJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                            loadJButtonH = handle(loadJButton,'CallbackProperties');
                            loadJButton.setText('Load');        
                            set(loadJButtonH, 'ActionPerformedCallback',@obj.load_CB)
                            myIcon = fullfile(icon_dir,'LoadedArrow_24.png');
                            loadJButton.setIcon(javax.swing.ImageIcon(myIcon));
                            loadJButton.setToolTipText('Load');
                            loadJButton.setFlyOverAppearance(true);
                            loadJButton.setBorder([]);
                            loadJButton.setIconTextGap(2);
                            loadJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                            loadJButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
                            loadJButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
                            loadJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                            obj.JRibbonPanel.add(loadJButton);
                            loadJButton.setBounds(85,3,35,71);
                            obj.LoadJButton = loadJButton;      

                            % Export Button             
                            exportJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                            exportJButtonH = handle(exportJButton,'CallbackProperties');
                            exportJButton.setText('Export');        
                            set(exportJButtonH, 'ActionPerformedCallback',@obj.export_CB)
                            myIcon = fullfile(icon_dir,'Export_24.png');
                            exportJButton.setIcon(javax.swing.ImageIcon(myIcon));
                            exportJButton.setToolTipText('Save and Load');
                            exportJButton.setFlyOverAppearance(true);
                            exportJButton.setBorder([]);
                            exportJButton.setIconTextGap(2);
                            exportJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                            exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                            obj.JRibbonPanel.add(exportJButton);
                            exportJButton.setBounds(125,3,35,71);
                            obj.ExportJButton = exportJButton;


                        % Break    
                        labelStr = '<html><i><font color="gray"></html>';
                        jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
                        jLabelbk1.setOpaque(true);
                        jLabelbk1.setBackground(java.awt.Color.lightGray);
                        jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                        obj.JRibbonPanel.add(jLabelbk1);
                        jLabelbk1.setBounds(165,3,2,90);%(125,3,2,77);

                        panelPos = getpixelposition(obj.RibbonPanel);
                        % File Section
                        labelStr = '<html><i><font color="gray"></html>';
                        jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
                        jLabel.setOpaque(true);
                        jLabel.setBackground(java.awt.Color.lightGray);
                        jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                        obj.JRibbonPanel.add(jLabel);
                        jLabel.setBounds(169,76,panelPos(3)-129,16);%(129,66,panelPos(3)-129,14);   
            
                else     

                            % Export Button             
                            exportJButton = javaObjectEDT('com.mathworks.toolstrip.components.TSButton');
                            exportJButtonH = handle(exportJButton,'CallbackProperties');
                            exportJButton.setText('Export');        
                            set(exportJButtonH, 'ActionPerformedCallback',@obj.export_CB)
                            myIcon = fullfile(icon_dir,'Export_24.png');
                            exportJButton.setIcon(javax.swing.ImageIcon(myIcon));
                            exportJButton.setToolTipText('Save and Load');
                            exportJButton.setFlyOverAppearance(true);
                            exportJButton.setBorder([]);
                            exportJButton.setIconTextGap(2);
                            exportJButton.setOrientation(com.mathworks.toolstrip.components.ButtonOrientation.VERTICAL);
                            exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                            obj.JRibbonPanel.add(exportJButton);
                            exportJButton.setBounds(85,3,35,71);
                            obj.ExportJButton = exportJButton;


                        % Break    
                        labelStr = '<html><i><font color="gray"></html>';
                        jLabelbk1 = javaObjectEDT('javax.swing.JLabel',labelStr);
                        jLabelbk1.setOpaque(true);
                        jLabelbk1.setBackground(java.awt.Color.lightGray);
                        jLabelbk1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                        obj.JRibbonPanel.add(jLabelbk1);
                        jLabelbk1.setBounds(125,3,2,90);%(125,3,2,77);

                        panelPos = getpixelposition(obj.RibbonPanel);
                        % File Section
                        labelStr = '<html><i><font color="gray"></html>';
                        jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
                        jLabel.setOpaque(true);
                        jLabel.setBackground(java.awt.Color.lightGray);
                        jLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                        obj.JRibbonPanel.add(jLabel);
                        jLabel.setBounds(129,76,panelPos(3)-129,16);%(129,66,panelPos(3)-129,14);   
                end
            obj.JRibbonPanel.setVisible(false);
            positionRibbon = getpixelposition(obj.RibbonPanel);
            [obj.JRPHComp,obj.JRPHCont] = javacomponent(obj.JRibbonPanel,[ 0 , 0 , positionRibbon(3) , positionRibbon(4) ], obj.RibbonPanel );
            %[obj.JRPHComp,obj.JRPHCont] = javacomponent(obj.JRibbonPanel,[0,0,600,90], obj.RibbonPanel );
            backgroundColor = java.awt.Color(210/255,210/255,210/255); % java.awt.Color.lightGray
            obj.JRibbonPanel.setBackground(backgroundColor);
        end % createToolRibbion
        
    end
   
    %% Methods - Ordinary
    methods 
     
        function loadObject( obj , newObj )
            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            obj.CurrentReqObj = newObj;
            createView (obj.CurrentReqObj , obj.MainPanel );
            
            obj.Saved = true;
            update( obj );
        end % loadObject
        
    end % Ordinary Methods
    
    %% Methods - Callbacks
    methods (Access = protected) 
        
        function newButton_CB( obj , hobj , ~ )

            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            switch class(obj.CurrentReqObj)
                case 'Requirements.Stability'
                    obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
                case 'Requirements.FrequencyResponse'
                    obj.CurrentReqObj = Requirements.FrequencyResponse();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.FrequencyResponse);
                case 'Requirements.HandlingQualities'
                    obj.CurrentReqObj = Requirements.HandlingQualities();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.HandlingQualities);
                case 'Requirements.Aeroservoelasticity'
                    obj.CurrentReqObj = Requirements.Aeroservoelasticity();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Aeroservoelasticity);
                case 'Requirements.SimulationCollection'
                    obj.CurrentReqObj = Requirements.SimulationCollection();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.SimulationCollection);
                case 'Requirements.Synthesis'
                    obj.CurrentReqObj = Requirements.Synthesis();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Synthesis);
                case 'lacm.TrimSettings'
                    obj.CurrentReqObj = lacm.TrimSettings();
                case 'lacm.LinearModel'
                    obj.CurrentReqObj = lacm.LinearModel(); 
                case 'lacm.AnalysisTask'
                    obj.CurrentReqObj = lacm.AnalysisTask(); 
                otherwise
                    return;
                    %obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
            end
            createView (obj.CurrentReqObj , obj.MainPanel );
            obj.Saved = true; 
            notify(obj,'NewButtonPressed',UserInterface.UserInterfaceEventData(hobj));
            drawnow();pause(0.1);
            update(obj);
        end % newButton_CB

        function openButton_CB( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Requirement Object File:',obj.CurrentObjDirectory);
            drawnow();pause(0.5);
            if isequal(filename,0)
                return;
            end
            obj.StartDirectory = pathname;
            
            
            
            
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
                
            loadObject( obj ,varStruct.(varNames{1}));
            
        end % openButton_CB
               
        function load_CB( obj , ~  , ~ )
            % Save the tree state if it exists
            try %#ok<TRYNC>
                obj.CurrentReqObj.OutputSelector.Tree.saveTreeState
            end
            if obj.EditInProject
                notify(obj,'ObjectLoaded',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            else
                notify(obj,'ObjectCreated',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            end
            drawnow();pause(0.1);
            obj.Saved = true;
            update(obj);
        end % load_CB
        
        function export_CB( obj , ~ , ~ )
            
            [filename, pathname] = uiputfile({'*.mat'},'Export Requirement',obj.CurrentObjFullName);
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end
            if isa(obj.CurrentReqObj,'Requirements.SimulationCollection')
%                 obj.CurrentReqObj.OutputSelector.Tree.saveTreeState;
%                 obj.CurrentReqObj.OutputSelector.saveTreeState;
            end
            Requirement = obj.CurrentReqObj; %#ok<NASGU>
            drawnow();pause(0.01);
            save(fullfile(pathname,filename),'Requirement');
        end % export_CB
                
        function popUpMenuCancelled( obj , ~ , ~ )

            obj.SaveSelJButton.setFlyOverAppearance(true);

        end % popUpMenuCancelled
        

    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ ) 
            if obj.ShowLoadButton
                this_dir = fileparts( mfilename( 'fullpath' ) );
                icon_dir = fullfile( this_dir,'..','..','Resources' );

                if obj.Saved
                    myIcon = fullfile(icon_dir,'LoadedArrow_24.png');

                else
                    myIcon = fullfile(icon_dir,'LoadArrow_24.png');
                end
                obj.LoadJButton.setIcon(javax.swing.ImageIcon(myIcon));
                obj.LoadJButton.setText('Load');  
            end
            setFileTitle( obj );
        end % update
         
        function reSize( obj , ~ , ~ )
            
            % get figure position
            position = getpixelposition(obj.Container);
       
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , position(4)-93 , position(3), 93 ]);
            
            set(obj.MainPanel,'Units','Pixels',...
                'Position',[1 , 1 , position(3) , position(4)-93 ]);
                                
        end % reSize
        
        function setFileTitle( obj , ~ , ~ )
            fig = ancestor(obj.Parent,'figure','toplevel') ;

            if isempty(obj.CurrentReqObj)
                filename = 'Untitled';
            else
                 filename = class(obj.CurrentReqObj);
            end
            
            if obj.Saved
                fig.Name = filename;
            else
                fig.Name = [filename,'*'];
            end
        end % setFileTitleNoNameNoSave  
        
        function propertyChanged_CB( obj , ~ , ~ )
            obj.Saved = false;
            update(obj);
            %disp('Prop Changed');
        end % propertyChanged_CB
           
    end
    
    %% Methods - Private
    methods (Access = private) 
        
    end
        
    %% Method - Static
    methods ( Static )
        
        
    end
        
end


function cl_out = findAttrValue(obj,attrName,varargin)
   if ischar(obj)
      mc = meta.class.fromName(obj);
   elseif isobject(obj)
      mc = metaclass(obj);
   end
   ii = 0; numb_props = length(mc.PropertyList);
   cl_array = cell(1,numb_props);
   for  c = 1:numb_props
      mp = mc.PropertyList(c);
      if isempty (findprop(mp,attrName))
         error('Not a valid attribute name')
      end
      attrValue = mp.(attrName);
      if attrValue
         if islogical(attrValue) || strcmp(varargin{1},attrValue)
            ii = ii + 1;
            cl_array(ii) = {mp.Name};
         end
      end
   end
   cl_out = cl_array(1:ii);
end


