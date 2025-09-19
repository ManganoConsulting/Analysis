classdef StartUpScreen < matlab.mixin.Copyable & hgsetget
    
    %% Version
    properties  
        VersionNumber
        InternalVersionNumber
    end % Version 
    
    %% Public properties - Object Handles
    properties (Transient = true)
        Parent
        Container
        
        PreviousLabelComp
        PreviousLabelCont
        
        PreviousListComp
        PreviousListScrollComp
        PreviousListScrollCont
        
        NewJButton
        NewButtonComp
        NewButtonCont
        
        BrowseJButton
        BrowseButtonComp
        BrowseButtonCont
        
        %LoadLabelComp
        %LoadLabelCont
        
        PropLabelComp
        PropLabelCont
        JPropTableModel
        JPropTable
        JPropTableH
        JPropScroll
        PropTableComp
        PropTableCont
      
        PrefLabelComp
        PrefLabelCont
        JPrefTableModel
        JPrefTable
        JPrefTableH
        JPrefScroll
        PrefTableComp
        PrefTableCont
        
        PrefTabPanel
        GeneralPrefTab
        TrimPrefTab
        SimPrefTab
        PTHComp
        PTHCont
        
        ClearJButton
        ClearButtonComp
        ClearButtonCont
    end % Public properties
    
    %% Public properties - Object Handles Full View
    properties (Transient = true)  
        

    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        RecentPrjFile
        Title
    end % Public properties
    
    %% Properties - Observable
    properties%(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )      
        PrivatePosition
        PrivateUnits
        PrivateVisible
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
        Visible
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Events
    events
        NewProjectCreated
        ProjectLoaded
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = StartUpScreen(varargin) 
%             if nargin == 0
%                return; 
%             end  
            p = inputParser;
            addParameter(p,'Parent',[]);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'RecentPrjFile','');
            addParameter(p,'Title','');
            addParameter(p,'VersionNumber','1.0');
            addParameter(p,'InternalVersionNumber','1.0.1');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.RecentPrjFile   = options.RecentPrjFile;
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;
            obj.VersionNumber   = options.VersionNumber;
            obj.InternalVersionNumber = options.InternalVersionNumber;
                    
            if isempty(options.Parent)
                createView( obj );
            else
                createEmbeddedView( obj , options.Parent );
            end

        end % StartUpScreen
        
    end % Constructor

    %% Methods - Property Access
    methods
        
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
                
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Container,'Visible','on');
            else
                set(obj.Container,'Visible','off');
            end            
        end % Visible - Set
        
        function y = get.Visible(obj)
            y = obj.PrivateVisible;          
        end % Visible - Get
        
    end % Property access methods
    
    %% Methods - View
    methods   
        
        function createView( obj )
            import javax.swing.*;
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' ); 
            
            sz = [ 250 , 460]; % figure size
            screensize = get(0,'ScreenSize');
            xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
            ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically
            
            obj.Parent = figure('Name',['FLIGHT ',obj.Title,' Projects'],...
                                'Units','Pixels',...
                                'Position',[xpos, ypos, sz(2), sz(1)],...
                                'Menubar','none',...   
                                'Toolbar','none',...
                                'NumberTitle','off',...
                                'HandleVisibility', 'on',...
                                'Visible','on',...
                                'Resize','off',...
                                'WindowStyle','modal',...
                                'CloseRequestFcn', @obj.closeFigure_CB);

            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            
            % Previous Applications
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Previous Projects</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.PreviousLabelComp,obj.PreviousLabelCont] = javacomponent(jLabelview,[ ], obj.Container );
            
            obj.PreviousListComp = javaObjectEDT('javax.swing.JEditorPane');
            obj.PreviousListComp.setEditable(false);
            set(obj.PreviousListComp,'HyperlinkUpdateCallback',@obj.linkCallbackFcn);
            set(obj.PreviousListComp,'MouseClickedCallback',@obj.mouseClicked_CB);
            [obj.PreviousListScrollComp,obj.PreviousListScrollCont] = ...
            javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.PreviousListComp)),[ ], obj.Container  );  

            % Create a new Project
            newJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            newJButton.setText('Create New Project   ');        
            newJButtonH = handle(newJButton,'CallbackProperties');
            set(newJButtonH, 'ActionPerformedCallback',@obj.newButtonCB)
            myIcon = fullfile(icon_dir,'NewProject_24.png');
            newJButton.setIcon(javax.swing.ImageIcon(myIcon));
            newJButton.setToolTipText('Create a new project');
            newJButton.setFlyOverAppearance(true);
            newJButton.setBorder([]);
            newJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            newJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            newJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.NewJButton = newJButton;
            [obj.NewButtonComp,obj.NewButtonCont] = javacomponent(obj.NewJButton,[ ], obj.Container );
            
            % Browse to Project           
            browseJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            browseJButton.setText('Load Existing Project');        
            browseJButtonH = handle(browseJButton,'CallbackProperties');
            set(browseJButtonH, 'ActionPerformedCallback',@obj.browseButtonCB)
            myIcon = fullfile(icon_dir,'LoadProject_24.png');
            browseJButton.setIcon(javax.swing.ImageIcon(myIcon));
            browseJButton.setToolTipText('Load an existing project');
            browseJButton.setFlyOverAppearance(true);
            browseJButton.setBorder([]);
            browseJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            browseJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            browseJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.BrowseJButton = browseJButton;
            [obj.BrowseButtonComp,obj.BrowseButtonCont] = javacomponent(obj.BrowseJButton,[ ], obj.Container );
            
            % Clear All Projects           
            clearJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            clearJButton.setText('Clear All Projects    ');        
            clearJButtonH = handle(clearJButton,'CallbackProperties');
            set(clearJButtonH, 'ActionPerformedCallback',@obj.clearButtonCB)
            myIcon = fullfile(icon_dir,'RemoveProject_24.png');
            clearJButton.setIcon(javax.swing.ImageIcon(myIcon));
            clearJButton.setToolTipText('Load an existing project');
            clearJButton.setFlyOverAppearance(true);
            clearJButton.setBorder([]);
            clearJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            clearJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            clearJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.ClearJButton = clearJButton;
            [obj.ClearButtonComp,obj.ClearButtonCont] = javacomponent(obj.ClearJButton,[ ], obj.Container );
            
%             loadStr = '<html><font color="black" face="Courier New">&nbsp;Loading.....</html>';
%             jLoadLabelview = javaObjectEDT('javax.swing.JLabel',loadStr);
%             jLoadLabelview.setOpaque(true);
%             jLoadLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
%             jLoadLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
%             [obj.LoadLabelComp,obj.LoadLabelCont] = javacomponent(jLoadLabelview,[ ], obj.Container );
%             obj.LoadLabelComp.setVisible(false);
            
            % Resize
            reSize( obj , [] , [] );
            
            setRecentProjects( obj );
        end % createView
        
        function createEmbeddedView( obj , parent )
            import javax.swing.*;
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' ); 
            
            obj.Container = uicontainer('Parent',parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSizeEmbeddedView);
            
            % Previous Applications
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Previous Projects</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.PreviousLabelComp,obj.PreviousLabelCont] = javacomponent(jLabelview,[ ], obj.Container );
            
            obj.PreviousListComp = javaObjectEDT('javax.swing.JEditorPane');
            obj.PreviousListComp.setEditable(false);
            set(obj.PreviousListComp,'HyperlinkUpdateCallback',@obj.linkCallbackFcnEmbedded);
            set(obj.PreviousListComp,'MouseClickedCallback',@obj.mouseClicked_CB);
            [obj.PreviousListScrollComp,obj.PreviousListScrollCont] = ...
            javacomponent(javaObjectEDT(javax.swing.JScrollPane(obj.PreviousListComp)),[ ], obj.Container  );  

            % Create a new Project
            newJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            newJButton.setText('Create New Project   ');        
            newJButtonH = handle(newJButton,'CallbackProperties');
            set(newJButtonH, 'ActionPerformedCallback',@obj.newButtonCB)
            myIcon = fullfile(icon_dir,'NewProject_24.png');
            newJButton.setIcon(javax.swing.ImageIcon(myIcon));
            newJButton.setToolTipText('Create a new project');
            newJButton.setFlyOverAppearance(true);
            newJButton.setBorder([]);
            newJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            newJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            newJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.NewJButton = newJButton;
            [obj.NewButtonComp,obj.NewButtonCont] = javacomponent(obj.NewJButton,[ ], obj.Container );
            
            % Browse to Project           
            browseJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            browseJButton.setText('Load Existing Project');        
            browseJButtonH = handle(browseJButton,'CallbackProperties');
            set(browseJButtonH, 'ActionPerformedCallback',@obj.browseButtonCB)
            myIcon = fullfile(icon_dir,'LoadProject_24.png');
            browseJButton.setIcon(javax.swing.ImageIcon(myIcon));
            browseJButton.setToolTipText('Load an existing project');
            browseJButton.setFlyOverAppearance(true);
            browseJButton.setBorder([]);
            browseJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            browseJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            browseJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.BrowseJButton = browseJButton;
            [obj.BrowseButtonComp,obj.BrowseButtonCont] = javacomponent(obj.BrowseJButton,[ ], obj.Container );
            
            % Clear All Projects           
            clearJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            clearJButton.setText('Clear All Projects    ');        
            clearJButtonH = handle(clearJButton,'CallbackProperties');
            set(clearJButtonH, 'ActionPerformedCallback',@obj.clearButtonCB)
            myIcon = fullfile(icon_dir,'RemoveProject_24.png');
            clearJButton.setIcon(javax.swing.ImageIcon(myIcon));
            clearJButton.setToolTipText('Load an existing project');
            clearJButton.setFlyOverAppearance(true);
            clearJButton.setBorder([]);
            clearJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
            clearJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
            clearJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
            obj.ClearJButton = clearJButton;
            [obj.ClearButtonComp,obj.ClearButtonCont] = javacomponent(obj.ClearJButton,[ ], obj.Container ); 
            
%             loadStr = '<html><font color="black" face="Courier New">&nbsp;LOADING.....</html>';
%             jLoadLabelview = javaObjectEDT('javax.swing.JLabel',loadStr);
%             jLoadLabelview.setOpaque(true);
%             jLoadLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
%             jLoadLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
%             [obj.LoadLabelComp,obj.LoadLabelCont] = javacomponent(jLoadLabelview,[ ], obj.Container );
%             obj.LoadLabelComp.setVisible(false);
            
            % Prop Table Label
            labelStr = '<html><font color="white" face="Courier New">&nbsp;CURRENT PROJECT STATUS:</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.PropLabelComp,obj.PropLabelCont] = javacomponent(jLabelview,[ ], obj.Container );
            
            % Current Project Properties Table
%             tabledata = {'Name:','Project';...
%                 'Date Modified:','10/16/2016';...
%                 'Modified By:','mmangano';...
%                 'Created By:','mmangano';...
%                 'Database Version:','1.6';...
%                 'SVN Version:','1.6';...
%                 'SVN Location:','https://aerospacecontroldynamics.svn/****/****/****';...
%                 'Aircraft','F-16'};
            tabledata = {'','';...
                '','';...
                '','';...
                '',''};
            
            obj.JPropTableModel = javaObjectEDT('javax.swing.table.DefaultTableModel',tabledata,{'m','m'});
            obj.JPropTable = javaObjectEDT(javax.swing.JTable(obj.JPropTableModel));
            obj.JPropTable.setTableHeader([]);
            obj.JPropTableH = handle(javaObjectEDT(obj.JPropTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.JPropScroll = javaObjectEDT('javax.swing.JScrollPane',obj.JPropTable);
            [obj.PropTableComp,obj.PropTableCont] = javacomponent(obj.JPropScroll,[], obj.Container );

            % Prefrences Table Label
            labelStr = '<html><font color="white" face="Courier New">&nbsp;USER PREFERENCES</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.PrefLabelComp,obj.PrefLabelCont] = javacomponent(jLabelview,[ ], obj.Container );


            % Create the Tab
            obj.PrefTabPanel =  javaObjectEDT('javax.swing.JTabbedPane');
            %PrefTabPanelH = handle(obj.ToolRibbionTab,'CallbackProperties');
            %set(PrefTabPanelH, 'StateChangedCallback',@obj.tabPanelChanged);

            if strcmp(obj.Title,'Dynamics')
                    % Prefrences Properties Table
        %             tabledata = {'Plots Per Page:','4';...
        %                 'Default Units:','SI';...
        %                 'Default Trim Mode:','mmangano';...
        %                 'Run Configuration:','Save'};
                    tabledata = {'','';...
                        '','';...
                        '','';...
                        '',''};

                    obj.JPrefTableModel = javaObjectEDT('javax.swing.table.DefaultTableModel',tabledata,{'m','m'});
                    obj.JPrefTable = javaObjectEDT('javax.swing.JTable',obj.JPrefTableModel);
                    obj.JPrefTable.setTableHeader([]);
                    obj.JPrefTableH = handle(javaObjectEDT(obj.JPrefTable), 'CallbackProperties');  % ensure that we're using EDT
                    obj.JPrefScroll = javaObjectEDT('javax.swing.JScrollPane',obj.JPrefTable);
        %             [obj.PrefTableComp,obj.PrefTableCont] = javacomponent(obj.JPrefScroll,[], obj.Container );

        %             obj.GeneralPrefTab = javaObjectEDT('javax.swing.JPanel');
                    obj.TrimPrefTab = javaObjectEDT('javax.swing.JPanel');
                    obj.SimPrefTab = javaObjectEDT('javax.swing.JPanel');


                genStr = '<html><font color="black" size="4" face="Courier New"><b>General</b></html>';
                obj.PrefTabPanel.addTab(genStr, obj.JPrefScroll);
                obj.PrefTabPanel.setBackgroundAt(0, java.awt.Color(int32(55),int32(96),int32(146)) );
                obj.PrefTabPanel.setMnemonicAt(0, java.awt.event.KeyEvent.VK_1);

                trimStr = '<html><font color="black" size="4" face="Courier New"><b>Trim</b></html>';
                obj.PrefTabPanel.addTab(trimStr, obj.TrimPrefTab);
                obj.PrefTabPanel.setMnemonicAt(1, java.awt.event.KeyEvent.VK_2);
                obj.PrefTabPanel.setBackgroundAt(1, java.awt.Color(int32(55),int32(96),int32(146)));

                simStr = '<html><font color="black" size="4" face="Courier New"><b>Simulation</b></html>';
                obj.PrefTabPanel.addTab(simStr, obj.SimPrefTab);
                obj.PrefTabPanel.setMnemonicAt(2, java.awt.event.KeyEvent.VK_3);
                obj.PrefTabPanel.setBackgroundAt(2, java.awt.Color(int32(55),int32(96),int32(146)));
            else
                    % Prefrences Properties Table
        %             tabledata = {'Plots Per Page:','4';...
        %                 'Default Units:','SI';...
        %                 'Default Trim Mode:','mmangano';...
        %                 'Run Configuration:','Save'};
                    tabledata = {'','';...
                        '','';...
                        '','';...
                        '',''};

                    obj.JPrefTableModel = javaObjectEDT('javax.swing.table.DefaultTableModel',tabledata,{'m','m'});
                    obj.JPrefTable = javaObjectEDT('javax.swing.JTable',obj.JPrefTableModel);
                    obj.JPrefTable.setTableHeader([]);
                    obj.JPrefTableH = handle(javaObjectEDT(obj.JPrefTable), 'CallbackProperties');  % ensure that we're using EDT
                    obj.JPrefScroll = javaObjectEDT(javax.swing.JScrollPane(obj.JPrefTable));
        %             [obj.PrefTableComp,obj.PrefTableCont] = javacomponent(obj.JPrefScroll,[], obj.Container );

        %             obj.GeneralPrefTab = javaObjectEDT('javax.swing.JPanel');
                    obj.TrimPrefTab = javaObjectEDT('javax.swing.JPanel');
                    obj.SimPrefTab = javaObjectEDT('javax.swing.JPanel');


                genStr = '<html><font color="black" size="4" face="Courier New"><b>General</b></html>';
                obj.PrefTabPanel.addTab(genStr, obj.JPrefScroll);
                obj.PrefTabPanel.setBackgroundAt(0, java.awt.Color(int32(55),int32(96),int32(146)) );
                obj.PrefTabPanel.setMnemonicAt(0, java.awt.event.KeyEvent.VK_1);

                trimStr = '<html><font color="black" size="4" face="Courier New"><b>Scattered</b></html>';
                obj.PrefTabPanel.addTab(trimStr, obj.TrimPrefTab);
                obj.PrefTabPanel.setMnemonicAt(1, java.awt.event.KeyEvent.VK_2);
                obj.PrefTabPanel.setBackgroundAt(1, java.awt.Color(int32(55),int32(96),int32(146)));

                simStr = '<html><font color="black" size="4" face="Courier New"><b>Scheduled</b></html>';
                obj.PrefTabPanel.addTab(simStr, obj.SimPrefTab);
                obj.PrefTabPanel.setMnemonicAt(2, java.awt.event.KeyEvent.VK_3);
                obj.PrefTabPanel.setBackgroundAt(2, java.awt.Color(int32(55),int32(96),int32(146)));
            end

           [obj.PTHComp,obj.PTHCont] = javacomponent(obj.PrefTabPanel,[], obj.Container );


            % Resize
            reSizeEmbeddedView( obj , [] , [] );

            setRecentProjects( obj );
        end % createEmbeddedView
        
    end
    
    %% Methods - Protected Callbacks
    methods (Access = protected) 
        
        function newButtonCB( obj , hobj , eventdata )
            switch obj.Title
                case 'Dynamics'
                    ext = '*.fltd';
                case 'Control'
                    ext = '*.fltc';
                otherwise
                    ext = '*.mat';
            end
            
            [filename, pathname] = uiputfile( ...
                        {ext,...
                         ['FLIGHT',obj.Title,' Project Files (',ext,')'];
                         '*.*',  'All Files (*.*)'},...
                         ['New FLIGHT',obj.Title,' Project']);
            if isequal(filename,0) || isequal(pathname,0)
               % Do nothing
            else
               %obj.LoadLabelComp.setVisible(true);
               pause(0.1);
               notify(obj,'NewProjectCreated',UserInterface.UserInterfaceEventData(fullfile(pathname,filename)));
%                try
%                 delete(obj.Parent);
%                end
            end
            
        end % newButtonCB
        
        function browseButtonCB( obj , hobj , eventdata )
            switch obj.Title
                case 'Dynamics'
                    ext = '*.fltd';
                case 'Control'
                    ext = '*.fltc';
                otherwise
                    ext = '*.mat';
            end
            
            [filename, pathname] = uigetfile( ...
                        {ext,...
                         ['FLIGHT',obj.Title,' Project Files (',ext,')'];
                         '*.*',  'All Files (*.*)'},...
                         ['Load FLIGHT',obj.Title,' Project']);
                     drawnow();pause(0.5);
            if isequal(filename,0) || isequal(pathname,0)
               % Do nothing
            else
               %obj.LoadLabelComp.setVisible(true);
               pause(0.1);
               notify(obj,'ProjectLoaded',UserInterface.UserInterfaceEventData(fullfile(pathname,filename)));
%                try
%                 delete(obj.Parent);
%                end
            end
        end % browseButtonCB
        
        function clearButtonCB( obj , hobj , eventdata )
            % Clears all stored previous projects
            if exist(obj.RecentPrjFile, 'file')
                fid = fopen( obj.RecentPrjFile , 'wt');           
                fclose(fid);
            end
            obj.PreviousListComp.setText('');
        end % clearButtonCB
        
        function clearSelected( obj )

            Utilities.removeLineInFile( obj.RecentPrjFile , eventdata.Object );  
            setRecentProjects( obj );
        end % clearSelected
        
        function linkCallbackFcn( obj , hobj , eventdata )
            
            %inputevent = get(eventdata,'InputEvent');
            inputevent = eventdata.getInputEvent;
            hobj.setToolTipText(char(eventdata.getDescription));
            if inputevent.getID == 500 % 500 = MouseClickedEvent
                setWaitPtr(obj);
                fullFileName = char(eventdata.getDescription);
                drawnow();pause(0.01);
                %obj.LoadLabelComp.setVisible(true);
                pause(0.1);
                notify(obj,'ProjectLoaded',UserInterface.UserInterfaceEventData(fullFileName));
                try
%                     delete(obj.Parent);
                    releaseWaitPtr(obj);
                end
                
            end
        end % linkCallbackFcn
        
        function linkCallbackFcnEmbedded( obj , hobj , eventdata )
            
            %inputevent = get(eventdata,'InputEvent');
            
            inputevent = eventdata.getInputEvent;
            hobj.setToolTipText(char(eventdata.getDescription));
            if inputevent.getID == 500 % 500 = MouseClickedEvent
                setWaitPtr(obj);
                fullFileName = char(eventdata.getDescription);
                %obj.LoadLabelComp.setVisible(true);
                pause(0.1);
                notify(obj,'ProjectLoaded',UserInterface.UserInterfaceEventData(fullFileName));
                releaseWaitPtr(obj);
            end
        end % linkCallbackFcnEmbedded
        
        function mouseClicked_CB( obj , hobj , eventdata )
            
%             elem = getHyperlinkElement(obj,eventdata) ;
%             inputevent.getID
%             if inputevent.getID == 500 % 500 = MouseClickedEvent
%                 fullFileName = char(eventdata.getDescription);
%                 obj.LoadLabelComp.setVisible(true);
%                 pause(0.1);
%                 notify(obj,'ProjectLoaded',UserInterface.UserInterfaceEventData(fullFileName));
%                 try
%                     delete(obj.Parent);
%                 end
%             end
        end % mouseClicked_CB
        
        function y = getHyperlinkElement(obj , event) 
            import javax.swing.text.html.*
            y = [];
            editor = event.getSource();
            pos = editor.getUI().viewToModel(editor, event.getPoint());
            if pos >= 0 && isa(editor.getDocument() , 'javax.swing.text.html.HTMLDocument') 
                hdoc = editor.getDocument();
                elem = hdoc.getCharacterElement(pos);
%                 if (elem.getAttributes().getAttribute(javax.swing.text.html.HTML.getTag('A')) ~= []) 
                    y = elem;
%                 end
            end
        end       
        
    end
    
    %% Methods - Ordinary
    methods     
        
        function existingRecent = getPreviousProjects( obj )
            % Read in the file
            existingRecent = {};
            if exist(obj.RecentPrjFile, 'file')
                fid = fopen( obj.RecentPrjFile );           
                tline = fgets(fid);
                while ischar(tline)
                    existingRecent{end + 1} = strtrim(tline); %#ok<AGROW>
                    tline = fgets(fid);
                end
                fclose(fid);

                % Remove any empty's
                blankLogArray = cellfun(@(x) isempty(strtrim(x)),existingRecent);
                existingRecent(blankLogArray) = [];
            end
        end % getPreviousProjects
 
        function setRecentProjects( obj )
            prjs = getPreviousProjects( obj );
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','Resources' );  
            
            % Ensure we have an HTML-ready editbox
            HTMLclassname = 'javax.swing.text.html.HTMLEditorKit';
            if ~isa(obj.PreviousListComp.getEditorKit,HTMLclassname)
              obj.PreviousListComp.setContentType('text/html');
            end
            
            
            for  i = 1:length(prjs)
                if ~exist(prjs{i},'file')
                    % Remove from recent projects
                    Utilities.removeLineInFile( obj.RecentPrjFile , prjs{i});  
                else
                    [~,filename,ext] = fileparts(prjs{i});
                    text = [filename,ext];
                    % Set the icon
                    icon  = fullfile(icon_dir,'Project_24.png');
                    iconTxt =['<img src="file:///',icon,'" height=16 width=16>'];
                    color = 'blue'; 
                    msgTxt = ['<a href="',prjs{i},'">',['&nbsp;<font color=',color,'>',text,'</font>'],'</a>'];  
                    newText =  [ iconTxt , '&nbsp;' , msgTxt ];

                    % Place the HTML message segment at the bottom of the editbox
                    Doc = obj.PreviousListComp.getDocument();
                    obj.PreviousListComp.getEditorKit().read(java.io.StringReader(newText), Doc, Doc.getLength());
                    obj.PreviousListComp.setCaretPosition(Doc.getLength());   
                end
            end
                
        end % setRecentProjects
        
        function reSize( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            set(obj.PreviousLabelCont,'Units','Pixels','Position',[ 10 , panelPos(4)-50 , 150 , 17 ] );  
            set(obj.PreviousListScrollCont,'Units','Pixels','Position',[ 10 , panelPos(4)-175 , 425 , 125 ] );  
            
%             set(obj.NewButtonCont,'Units','Pixels','Position',[ 270 , panelPos(4)-100 , 150 , 25 ] ); 
%             set(obj.BrowseButtonCont,'Units','Pixels','Position',[ 270 , panelPos(4)-150 , 150 , 25 ] ); 
%             set(obj.ClearButtonCont,'Units','Pixels','Position',[ 270 , panelPos(4)-200 , 150 , 25 ] ); 
%             set(obj.LoadLabelCont,'Units','Pixels','Position',[ 10 , 5 , 150 , 45 ] ); 
            
            set(obj.NewButtonCont,'Units','Pixels','Position',[ 10 , 20 , 150 , 25 ] ); 
            set(obj.BrowseButtonCont,'Units','Pixels','Position',[ 160 , 20 , 150 , 25 ] ); 
            set(obj.ClearButtonCont,'Units','Pixels','Position',[ 310 , 20 , 150 , 25 ] ); 
            %set(obj.LoadLabelCont,'Units','Pixels','Position',[ 170 , panelPos(4)-45 , 150 , 90 ] ); 

        end %reSize      
        
        function reSizeEmbeddedView( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            
            set(obj.NewButtonCont,'Units','Pixels','Position',[ 25 , panelPos(4) - 50 , 150 , 25 ] ); 
            set(obj.BrowseButtonCont,'Units','Pixels','Position',[ 175 , panelPos(4) - 50 , 150 , 25 ] ); 
            set(obj.ClearButtonCont,'Units','Pixels','Position',[ 325 , panelPos(4) - 50 , 150 , 25 ] ); 
            
            set(obj.PreviousLabelCont,'Units','Pixels','Position',[ 25 , panelPos(4) - 100 , 350 , 25 ] );  
            set(obj.PreviousListScrollCont,'Units','Pixels','Position',[ 25 , panelPos(4) - 325 , 350 , 225 ] );  
            
            set(obj.PropLabelCont,'Units','Pixels','Position',[ 25 , panelPos(4) - 400 , 350 , 25 ] );
            set(obj.PropTableCont,'Units','Pixels','Position',[ 25 , panelPos(4) - 625 , 350 , 225 ] ); 

            set(obj.PrefLabelCont,'Units','Pixels','Position',[ 400 , panelPos(4) - 100 , 650 , 25 ] );
            set(obj.PTHCont,'Units','Pixels','Position',[ 400 , panelPos(4) - 625 , 650 , 525 ] ); 
            
            
            %set(obj.LoadLabelCont,'Units','Pixels','Position',[ 10 , 5 , 150 , 45 ] ); 

        end %reSize
        
        function update(obj)


        end % update        
        
        function setWaitPtr(obj)
            fig = ancestor(obj.Parent,'figure','toplevel');
            set(fig, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            fig = ancestor(obj.Parent,'figure','toplevel');
            set(fig, 'pointer', 'arrow'); 
        end % releaseWaitPtr  
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)  
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
%             cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the AvaliableParameterSelection object
%             cpObj.AvaliableParameterSelection = copy(obj.AvaliableParameterSelection);
        end % copyElement
        
        function closeFigure_CB(obj , hobj , ~ )
            delete(hobj); 
%             delete(obj);
        end % closeFigure_CB
        
    end
    
    %% Method - Delete
    methods
        function delete(obj)
                      
%             % Matlab Properties
%             obj.Parent
%             obj.Container
            
            % Java Properties
            obj.PreviousLabelComp = [];
            obj.PreviousListComp = [];
            obj.PreviousListScrollComp = [];
            obj.NewJButton = [];
            obj.NewButtonComp = [];
            obj.BrowseJButton = [];
            obj.BrowseButtonComp = [];
            %obj.LoadLabelComp = [];
            obj.PropLabelComp = [];
            obj.JPropTableModel = [];
            obj.JPropTable = [];
            obj.JPropTableH = [];
            obj.JPropScroll = [];
            obj.PropTableComp = [];
            obj.PrefLabelComp = [];
            obj.JPrefTableModel = [];
            obj.JPrefTable = [];
            obj.JPrefTableH = [];
            obj.JPrefScroll = [];
            obj.PrefTableComp = [];
            obj.PrefTabPanel = [];
            obj.GeneralPrefTab = [];
            obj.TrimPrefTab = [];
            obj.SimPrefTab = [];
            obj.PTHComp = [];
            obj.ClearJButton = [];
            obj.ClearButtonComp = [];
            
            % Java wrappers
            if ~isempty(obj.PreviousLabelCont) && ishandle(obj.PreviousLabelCont) && strcmp(get(obj.PreviousLabelCont, 'BeingDeleted'), 'off')
                delete(obj.PreviousLabelCont)
            end
            if ~isempty(obj.PreviousListScrollCont) && ishandle(obj.PreviousListScrollCont) && strcmp(get(obj.PreviousListScrollCont, 'BeingDeleted'), 'off')
                delete(obj.PreviousListScrollCont)
            end
            if ~isempty(obj.NewButtonCont) && ishandle(obj.NewButtonCont) && strcmp(get(obj.NewButtonCont, 'BeingDeleted'), 'off')
                delete(obj.NewButtonCont)
            end
            if ~isempty(obj.BrowseButtonCont) && ishandle(obj.BrowseButtonCont) && strcmp(get(obj.BrowseButtonCont, 'BeingDeleted'), 'off')
                delete(obj.BrowseButtonCont)
            end
%             if ~isempty(obj.LoadLabelCont) && ishandle(obj.LoadLabelCont) && strcmp(get(obj.LoadLabelCont, 'BeingDeleted'), 'off')
%                 delete(obj.LoadLabelCont)
%             end
            if ~isempty(obj.PropLabelCont) && ishandle(obj.PropLabelCont) && strcmp(get(obj.PropLabelCont, 'BeingDeleted'), 'off')
                delete(obj.PropLabelCont)
            end
            if ~isempty(obj.PropTableCont) && ishandle(obj.PropTableCont) && strcmp(get(obj.PropTableCont, 'BeingDeleted'), 'off')
                delete(obj.PropTableCont)
            end
            if ~isempty(obj.PrefLabelCont) && ishandle(obj.PrefLabelCont) && strcmp(get(obj.PrefLabelCont, 'BeingDeleted'), 'off')
                delete(obj.PrefLabelCont)
            end
            if ~isempty(obj.PTHCont) && ishandle(obj.PTHCont) && strcmp(get(obj.PTHCont, 'BeingDeleted'), 'off')
                delete(obj.PTHCont)
            end
            if ~isempty(obj.ClearButtonCont) && ishandle(obj.ClearButtonCont) && strcmp(get(obj.ClearButtonCont, 'BeingDeleted'), 'off')
                delete(obj.ClearButtonCont)
            end
            
            
            

            % Matalb Object Properties
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
            try %#ok<*TRYNC>             
                delete(obj.Parent);
            end
                    
        
            % Data            

        
       
 

        end % delete
    end
    
end


