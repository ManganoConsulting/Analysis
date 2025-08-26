classdef DYNMain < handle

    %% Properties
    properties(Hidden = true)
       ToolObj
       OperCond = lacm.OperatingCondition.empty;
       StartupScreen
       Figure
       App
       HiddenWarnings
    end
    
    %% Methods - Constructor
    methods
        function obj = DYNMain()

            obj.HiddenWarnings = suppressWarnings();
            
            ProjectType = 'Dynamics';

            % Start the Application and check licensing and tool set up.
            obj.App = Application(1);
  
            autoCreateShortcut = true;
            if autoCreateShortcut
                [prjPath,prjFile] = fileparts(mfilename('fullpath'));
                Utilities.createShortcut(prjPath,'FLIGHTdynamics',ProjectType,obj.App.VersionNumber,obj.App.InternalVersionNumber);
                eval(['addpath(''',prjPath,''');']);
            end
                     
            if obj.App.NeedRestart
                return;
            end    
            
            if obj.App.AccessAllowed
                %warn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                % Start up the splash screen
                splash = Utilities.SplashScreen( 'Splashscreen', 'ACDSplash_Dynamics.png', ...
                    'ProgressBar', 'off');
                splash.addText( 30, 310, ['Version ',obj.App.VersionNumber], 'FontSize', 20, 'Color', [0 0 0] , 'Shadow' , 'off' );
                splash.addText( 33, 325, ['Build - ',obj.App.InternalVersionNumber], 'FontSize', 10, 'Color', [0 0 0] , 'Shadow' , 'off' );

                % Set the look and feel for the table models
                try              
                    defaults = javax.swing.UIManager.getLookAndFeelDefaults;
                    if isempty(defaults.get('Table.alternateRowColor'))
                        defaults.put('Table.alternateRowColor', java.awt.Color( 246/255 , 243/255 , 237/255 ));
                    end
                catch
                   warning('Unable to update ''Table.alternateRowColor''.');
                end
                
                figID = [getenv('username'),' Flight ',ProjectType,' | ',obj.App.InternalVersionNumber];
                %check if GUI is already open
                FigureHdl = findobj('Tag', figID);
                if ~isempty(FigureHdl)
                    try
                        figure(FigureHdl);
                        return
                    catch %#ok<CTCH>
                        disp('Error With Loading User Data');
                    end                             
                end

                sz = [ 960 , 1384]; % figure size
                screensize = get(0,'ScreenSize');
                xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
                ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically

                obj.Figure = figure('Name',['FLIGHT ',ProjectType,' | ',obj.App.InternalVersionNumber],...
                                    'units','pixels',...
                                    'Position',[xpos, ypos, sz(2), sz(1)],...
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...
                                    'Tag','figID',...
                                    'CloseRequestFcn', @obj.closeFigure_CB);
                                

                drawnow();
                UserInterface.Utilities.enableDisableFig(obj.Figure, false);


                if ~( strcmp(version('-release'),'2015b') || strcmp(version('-release'),'2016a') )
                    jFig = get(handle(obj.Figure), 'JavaFrame');
                    pause(0.1);
                    jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension( 1384 , 960 ));       
                end

                obj.ToolObj = UserInterface.StabilityControl.Main(obj.Figure,obj.App.Granola,obj.App.VersionNumber,obj.App.InternalVersionNumber); 
                
                addlistener(obj.ToolObj,'LoadProject',@obj.loadProject);
                addlistener(obj.ToolObj,'CloseProject',@obj.closeProject);
                addlistener(obj.ToolObj,'SaveProject',@obj.saveProject);
                
                
                addlistener(obj.ToolObj,'LaunchStartUp',@obj.launchStartUp);
                launchStartUp(obj);

                drawnow();
                UserInterface.Utilities.enableDisableFig(obj.Figure, true);
                delete(splash);

%                 warning(warn);
            else
                throw(obj.App.Granola.LastError); % Terminate Program
            end
        end % DYNMain

    end % Constructor
    
    %% Methods - StartUp
    methods
        
        function launchStartUp( obj , hobj , eventdata )

            obj.StartupScreen = UserInterface.StartUpScreen('RecentPrjFile',fullfile(obj.ToolObj.ApplicationDataFolder,'previousprojects.flt'),'Title',obj.ToolObj.ProjectType);

            addlistener(obj.StartupScreen,'NewProjectCreated',@obj.startupPrjCreated);
            addlistener(obj.StartupScreen,'ProjectLoaded',@obj.startupPrjLoaded);

        end % launchStartUp
        
        function createProjectGUI( obj , hobj , eventdata )
            obj.ProjectScreen = UserInterface.StartUpScreen('RecentPrjFile',fullfile(obj.ApplicationDataFolder,'previousprojects.flt'),'Title',obj.ProjectType,'Parent',obj.MainCardPanel.Panel(1),...
                                                'VersionNumber',obj.VersionNumber,...
                                                'InternalVersionNumber',obj.InternalVersionNumber);   
            addlistener(obj.ProjectScreen,'NewProjectCreated',@obj.startupPrjCreated);
            addlistener(obj.ProjectScreen,'ProjectLoaded',@obj.startupPrjLoaded);
        end % createProjectGUI
        
        function startupPrjCreated( obj , ~ , eventdata )
            delete(obj.StartupScreen);
            [path,file,ext] = fileparts(eventdata.Object);
            saveProject( obj , [] , GeneralEventData({path , [file,ext]}) );
        end % startupPrjCreated    
        
        function startupPrjLoaded( obj , ~ , eventdata )
            delete(obj.StartupScreen);
            if ~exist(eventdata.Object,'file')
                % Remove from recent projects
                prevProjFile = fullfile(obj.ApplicationDataFolder,'previousprojects.flt');
                Utilities.removeLineInFile( prevProjFile , eventdata.Object );  
                launchStartUp( obj );
                msgbox('This project no longer exists.');
                return;
            end
            drawnow();
            [path,file,ext] = fileparts(eventdata.Object);
            loadProject( obj , [] , GeneralEventData({path,[file,ext]}) );
        end % startupPrjLoaded      
        
    end % StartUp
    
    %% Methods - Project Control
    methods    
        
        function saveProject( obj , ~ , eventdata )
            showLogMessage_CB( obj.ToolObj , [] , UserInterface.LogMessageEventData('Saving Project...','info') );
            obj.ToolObj.Tree.saveTreeState;
            
            % Save the new verion number
            obj.ToolObj.VersionNumber         = obj.App.VersionNumber;
            obj.ToolObj.InternalVersionNumber = obj.App.InternalVersionNumber;           
            
            %obj.BatchTree.saveTreeState;
            for i = 1:length(obj.ToolObj.OperCondCollObj)
                % Save the table row filter tree
                obj.ToolObj.OperCondCollObj(i).OperCondRowFilterObj.saveTreeState;
                % Save the sim viewer state
                obj.ToolObj.OperCondCollObj(i).saveSimViewerSettings();
                obj.ToolObj.OperCondCollObj(i).saveSimViewerProject();
            end
            obj.ToolObj.ProjectSaved = true;

            if isa(eventdata,'GeneralEventData') % Called to create a new saved project
                path = eventdata.Value{1};
                file = eventdata.Value{2};
                obj.ToolObj.LoadedProjectName = file;
                obj.ToolObj.ProjectDirectory = path;
                addProjectPath( obj.ToolObj , path );
            end
            dynObj = obj.ToolObj; %#ok<NASGU>
            save(obj.ToolObj.SavedProjectLocation,'dynObj');
            pause(0.1);
            showLogMessage_CB( obj.ToolObj , [] , UserInterface.LogMessageEventData('Project Saved','info') );
        end % saveAsProject
        
        function loadProject( obj , hobj , eventdata )
            pathname = eventdata.Value{1};
            filename = eventdata.Value{2};
            
%             createInterfaceComponents( obj, 'Test', 'ACDSplash_Dynamics.png' , obj.Figure.Position )
%             splashFig = figure('Name',['Flight ','Dynamics',' | ',obj.App.VersionNumber],...
%                                 'units','pixels',...
%                                 'Position',obj.Figure.Position,...
%                                 'Menubar','none',...   
%                                 'Toolbar','none',...
%                                 'NumberTitle','off',...
%                                 'HandleVisibility', 'on',...
%                                 'Visible','on');%'WindowStyle','modal');
%             position = obj.Figure.Position;
%             ha = axes('Parent',splashFig,'units','normalized', ...
%                     'position',[0 0 1 1]);
% 
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             I=imread(fullfile(this_dir,'\+UserInterface\Resources\ACDSplash_Dynamics.png'));
%             %hi = imagesc(I)  
% 
% 
%             set(ha,'handlevisibility','off', ...
%                         'visible','off',...
%                         'Units','Pixels',...
%                         'Position',[1, (position(4) / 2) - 160 , position(3), 320]);
% 
%             imshow(I, 'Parent', ha);
% 
% 
%             pleaseWait = uicontrol(...
%                 'Parent',splashFig,...
%                 'Style','text',...
%                 'String', 'Please Wait...',...
%                 'FontSize',24,...
%                 'FontWeight','bold',...%'BackgroundColor', [1 1 1],...
%                 'Units','Pixels',...
%                 'Position',[ 1 , position(4) /4 - 30 , position(3) , 50 ],...
%                 'Enable','on',...
%                 'HorizontalAlignment','Center');
% 
% 
%             set(splashFig, 'pointer', 'watch');
%             UserInterface.Utilities.enableDisableFig(splashFig, false);
%             set(splashFig, 'pointer', 'watch');
            % Project Saving
            
            obj.ToolObj.ProjectSaved = true;
            obj.ToolObj.LoadedProjectName = filename;
            obj.ToolObj.ProjectDirectory = pathname;
            obj.ToolObj.StartUpFlag = false;
            addProjectPath( obj.ToolObj , pathname ); 
            
            a = obj.ToolObj.InternalVersionNumber;
            
            delete(obj.ToolObj);

            ldObj = load(fullfile(pathname,filename),'-mat');
            try
                newObject = ldObj.obj;
            catch
                newObject = ldObj.dynObj;
            end
            
            %%% Check Version number
            b = newObject.InternalVersionNumber;
            verOK = compareVersionNumbers(a, b);
            
            if ~verOK
                msgbox(['Project Version ',b,' does not match this FLIGHT Dynamics Version ',a,'.'],'Version Info');
            end
                
            
            %%%%%%
            
            obj.ToolObj = newObject;
            obj.ToolObj.Granola = obj.App.Granola;
            obj.ToolObj.ProjectSaved = true;
            obj.ToolObj.LoadedProjectName = filename;
            obj.ToolObj.ProjectDirectory = pathname;
            obj.ToolObj.StartUpFlag = false;
            addProjectPath( obj.ToolObj , pathname );   
            
            addlistener(obj.ToolObj,'LoadProject',@obj.loadProject);
            addlistener(obj.ToolObj,'CloseProject',@obj.closeProject);
            addlistener(obj.ToolObj,'SaveProject',@obj.saveProject);  
            addlistener(obj.ToolObj,'LaunchStartUp',@obj.launchStartUp);   

            createView(obj.ToolObj,obj.Figure);
            
            % Update Units
            if strcmp(obj.ToolObj.Units,'English - US')
                obj.ToolObj.RibbonObj.UnitsSelComboBox.setSelectedIndex(0);
            else
                obj.ToolObj.RibbonObj.UnitsSelComboBox.setSelectedIndex(1);
            end

            % Add correct parents to each object
            % Tree
            drawnow();pause(0.1);
            % Restore Analysis View
            selObjs = getAnalysisObjs( obj.ToolObj.Tree , false );
            restoreAnalysisView( obj.ToolObj , selObjs );
            drawnow();pause(0.1);
            
            %addMainListners( obj.ToolObj );
            
            try 
                % Load Constants file and model into workspace
                constantsFile = getConstantsFile( obj.ToolObj.Tree );
                if ~isempty(constantsFile)
                    for i = 1:length(constantsFile)
                        [ ~ , ~ , ext ] = fileparts(constantsFile{i});
                        if strcmp( ext , '.mat' )
                            command = sprintf('load(''%s'')', constantsFile{i});
                            evalin('base', command);
                        elseif strcmp( ext , '.m' )
                            [~,command,~] = fileparts(constantsFile{i});
                            %command = sprintf('run(''%s'')', constantsFile{i});
                            evalin('base', command);
                        else
                            error('Constants file must have a ".m" of ".mat" extension');
                        end 
                    end
                end
                updateConstantTableData( obj.ToolObj );
                drawnow();pause(0.1);
            catch Mexc
                Utilities.releaseWaitPtr(obj.Figure);
                switch Mexc.identifier
                    case 'MATLAB:run:FileNotFound'
                        warndlg({['The constants file(s) ''',strjoin(constantsFile,'-'),  ''' was not found on the path.']; ...
                            'Please add the correct path and load the file into the base workspace.'});

                    otherwise
                        rethrow(Mexc);
                end
            end 
            reSize( obj.ToolObj );
            
            drawnow();
%             UserInterface.Utilities.enableDisableFig(splashFig, true);
%             delete(splashFig);
            Utilities.releaseWaitPtr(obj.Figure);
            showLogMessage_CB( obj.ToolObj , [] , UserInterface.LogMessageEventData('Project Loaded','info') );
        end % loadWorkspace_CB
        
        function closeProject( obj , hobj , eventdata )
%             obj.LoadingSavedWorkspace = false;
%             
%             delete(obj.BrowserPanel);
%             delete(obj.SelectionPanel);
%             delete(obj.LargeCardPanel);    
%             delete(obj.RibbonPanel);
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
        end % closeProject

    end % Project Control
    
    %% Methods - Close Figure
    methods  
                
        function closeFigure_CB(obj , hobj , eventdata )
            
            releaseAllTrimMdls(obj.ToolObj, [], []);

            choice = questdlg('Would you like to save the current project before closing?', ...
                'Closing...', ...
                'Yes','No','Cancel','Cancel');
            drawnow();pause(0.5);
             % Handle response
            switch choice
                case 'Yes'
                    % Save the project
                    autoSaveFile( obj.ToolObj , [] , [] );
                    closeFigure(obj , hobj , [] );
                case 'No'
                    closeFigure(obj , hobj , [] );
                otherwise
                    % Do nothing
            end
        end % closeFigure_CB
        
        
        function closeFigure(obj , hobj , eventdata )
            
            
%             releaseOpenModels();
            
                        
            warning(obj.HiddenWarnings);
            
            delete(obj.ToolObj);
            try %#ok<*TRYNC>             
                delete(obj.StartupScreen);
            end
            try %#ok<*TRYNC>             
                delete(obj.App);
            end   
            delete(hobj);
        end % closeFigure
        
        function releaseOpenModels(obj)

            Utilities.multiWaitbar('Closing models...', 0 , 'Color', 'b'); 
            % Release model

            openMdls = Simulink.allBlockDiagrams('model');


            uniqueMdlNames = get_param(openMdls, 'Name');
            for i = 1:length(uniqueMdlNames)
                while strcmp(get_param(uniqueMdlNames{i}, 'SimulationStatus'),'paused')
                    try
                        feval (uniqueMdlNames{i}, [], [], [], 'term');
                    end
                end   
                Utilities.multiWaitbar('Closing models...', i/length(uniqueMdlNames) , 'Color', 'b'); 
            end

            Utilities.multiWaitbar('Closing models...', 'close'); 

        end % releaseOpenModels 
        
    end % Close Figure
    
    %% Methods
    methods
    
        function coverfig = createInterfaceComponents( obj, title, imageFile , position )
            import javax.swing.*;
            
            % Load the image
            imageFile = getFullName( imageFile );
            jImFile = java.io.File( imageFile );
            try
                originalImage = javax.imageio.ImageIO.read( jImFile );
            catch err
                error('SplashScreen:BadFile', 'Image ''%s'' could not be loaded.', imageFile );
            end
            % Read it again into the copy we'll draw on
            bufferedImage = javax.imageio.ImageIO.read( jImFile );
            
            % Create the icon
            icon = ImageIcon( bufferedImage );
            
            % Create the frame and fill it with the image

            coverfig = JWindow(  );
            
            coverfig.setLayout( java.awt.BorderLayout() );
            pBar = JProgressBar(0,100);
            label = JLabel( icon );
            p = coverfig.getContentPane();
            p.add( label );
            p.add( pBar );
            
%             pBar.setBounds
                        
            % Update the on-screen image
            coverfig.repaint();
            
            
            % Resize and reposition the window

            coverfig.setSize( position(3), position(4) );
            coverfig.setLocation( position(1), position(2) );
            coverfig.setAlwaysOnTop( true );
            coverfig.setVisible(true);
            
            pause(5);
            coverfig.dispose();
        end % createInterfaceComponents


        
    end
    
end

function releaseOpenModels()

    Utilities.multiWaitbar( 'Closing models...', 0 , 'Color', 'b'); 
    % Release model

    openMdls = Simulink.allBlockDiagrams('model');


    uniqueMdlNames = get_param(openMdls, 'Name');
    for i = 1:length(uniqueMdlNames)
        while strcmp(get_param(uniqueMdlNames{i}, 'SimulationStatus'),'paused')
            try
                feval (uniqueMdlNames{i}, [], [], [], 'term');
            end
        end   
        Utilities.multiWaitbar( 'Closing models...', i/length(uniqueMdlNames) , 'Color', 'b'); 
    end
    
    Utilities.multiWaitbar( 'Closing models...', 'close'); 
    
end % releaseOpenModels 
        
function filename = getFullName( filename )

    this_dir = fileparts( mfilename( 'fullpath' ) );
    filename = fullfile( this_dir,'+UserInterface','Resources' ,filename );

end % getFullName

function y = compareVersionNumbers(a, b)

    a_split = strsplit(a,'.');
    b_split = strsplit(b,'.');

    y = true;
    for i = 1:length(a_split)
        if str2double(a_split{i}) ~= str2double(b_split{i})
            y = false;
        end
    end

end

function warn = suppressWarnings()
% these warning appear due to using undocumented and unsupported
% features in matalb    

    warn(1) = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    warn(2) = warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
    warn(3) = warning('off','MATLAB:ui:javacomponent:FunctionToBeRemoved'); 
    warn(4) = warning('off','MATLAB:uitree:DeprecatedFunction');
    warn(5) = warning('off','MATLAB:ui:javacomponent:FunctionToBeRemoved');
    warn(6) = warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
%     warn(5) = warning('off','MATLAB:legend:IgnoringExtraEntries');
%     warn(6) = warning('off','MATLAB:class:loadError');   
%     warn(7) = warning('off','MATLAB:hg:PossibleDeprecatedJavaSetHGProperty');  
%     warn(8) = warning('off','MATLAB:hg:ColorSpec_None');
%     warn(9) = warning('off','MATLAB:uitabgroup:OldVersion');

end % suppressWarnings

