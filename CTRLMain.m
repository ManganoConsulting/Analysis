classdef CTRLMain < handle

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
        
        function obj = CTRLMain()
            
            obj.HiddenWarnings = suppressWarnings();

            ProjectType = 'Control';

            % Start the Application and check licensing and tool set up.
            obj.App = Application(2);
                      
            autoCreateShortcut = true;
            if autoCreateShortcut
                [prjPath,prjFile] = fileparts(mfilename('fullpath'));
                Utilities.createShortcut(prjPath,'FLIGHTcontrol',ProjectType,obj.App.VersionNumber,obj.App.InternalVersionNumber);
                eval(['addpath(''',prjPath,''');']);
            end
            
            if obj.App.NeedRestart
                return;
            end
            
            if obj.App.AccessAllowed
                %warn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                % Start up the splash screen
                splash = Utilities.SplashScreen( 'Splashscreen', 'ACDSplash_Control.png', ...
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
                                    'Tag',figID,...
                                    'CloseRequestFcn', @obj.closeFigure_CB);
                                
                drawnow();
%                 UserInterface.Utilities.enableDisableFig(obj.Figure, false);

                if ~( strcmp(version('-release'),'2015b') || strcmp(version('-release'),'2016a') )
                    jFig = get(handle(obj.Figure), 'JavaFrame'); %#ok<JAVFM>
                    pause(0.1);
                    jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension( 1384 , 960 ));       
                end

                obj.ToolObj = UserInterface.ControlDesign.ControlDesignGUI(obj.Figure,obj.App.Granola,obj.App.VersionNumber,obj.App.InternalVersionNumber); 
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
            
        end % CTRLMain

    end % Constructor
    
    %% Methods - StartUp
    methods
        
        function launchStartUp( obj , hobj , eventdata )

            obj.StartupScreen = UserInterface.StartUpScreen('RecentPrjFile',fullfile(obj.ToolObj.ApplicationDataFolder,'previousprojects.flt'),'Title',obj.ToolObj.ProjectType);
%             pause(1.1);
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
            obj.ToolObj.TreeSavedData = obj.ToolObj.Tree.saveTreeState;
            
            % Save the new verion number
            obj.ToolObj.VersionNumber         = obj.App.VersionNumber;
            obj.ToolObj.InternalVersionNumber = obj.App.InternalVersionNumber;
            
            % Save Simviewer Setting with SimObjs
            %simObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'SimNode' );
            simObjs = getSimulationObjs( obj.ToolObj.Tree );
            for i = 1:length(simObjs)
                simObjs(i).SimViewerProject = obj.ToolObj.SimViewerColl(i).getSavedProject;
                simObjs(i).SimulationData = struct('Input',{},'Output',{});  % Don't store the data twice
            end

            obj.ToolObj.ProjectSaved = true;
            
%             obj.ToolObj.saveSimViewerSettings();
%             obj.ToolObj.saveSimViewerProject();
            
            if isa(eventdata,'UserInterface.SaveProjectEventData') && ~isempty(eventdata.SavePath)% Called to create a new saved project
                path = eventdata.SavePath{1};
                file = eventdata.SavePath{2};
                obj.ToolObj.LoadedProjectName = file;
                obj.ToolObj.ProjectDirectory = path;
                addProjectPath( obj.ToolObj , path );
            end
            
            %-----------------------------------------------------------------------------------------     
%             if isa(eventdata,'GeneralEventData')
%                 answer = questdlg('Would you like to save the plot information?  This could result in significantly larger file sizes, but the plot will be available when the project is open.', ...
%                     'Save Plots', ...
%                     'Yes','No','No'); 
%             else
%                 answer = 'No';
%             end

            if isa(eventdata,'UserInterface.SaveProjectEventData') && ~eventdata.SavePlots
                        % Remove PlotData
                        reqObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'StabilityReqNode');
                        if ~isempty(reqObjs)
                            for i = 1:length(reqObjs)
                                reqObjs(i).PlotData = [];
                            end
                        end
                        %--------------------------------------------------------------
                        %                    FrequencyResponse
                        %--------------------------------------------------------------
                        reqObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'FreqNode');
                        if ~isempty(reqObjs)
                            for i = 1:length(reqObjs)
                                reqObjs(i).PlotData = [];
                            end
                        end
                        %--------------------------------------------------------------
                        %                    Simulation
                        %--------------------------------------------------------------
                        reqObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'SimNode');
                        if ~isempty(reqObjs)
                            for i = 1:length(reqObjs)
                                reqObjs(i).SimViewerProject.SimulationData = Simulink.SimulationOutput.empty;
                            end
                        end    
                        %--------------------------------------------------------------
                        %                    HandlingQualities
                        %--------------------------------------------------------------
                        reqObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'HQNode');
                        if ~isempty(reqObjs)
                            for i = 1:length(reqObjs)
                                reqObjs(i).PlotData = [];
                            end
                        end
                        %--------------------------------------------------------------
                        %                    Aeroservoelasticity
                        %--------------------------------------------------------------
                        reqObjs = getSelectedReqObjs( obj.ToolObj.Tree , 'ASENode');
                        if ~isempty(reqObjs)
                            for i = 1:length(reqObjs)
                                reqObjs(i).PlotData = [];
                            end
                        end

            end
            %-----------------------------------------------------------------------------------------               
            
            ctrlObj = obj.ToolObj; 
            save(obj.ToolObj.SavedProjectLocation,'ctrlObj');
            pause(0.1);
            showLogMessage_CB( obj.ToolObj , [] , UserInterface.LogMessageEventData('Project Saved','info') );
        end % saveAsProject
        
        function loadProject( obj , ~ , eventdata )
            pathname = eventdata.Value{1};
            filename = eventdata.Value{2};
            
            
%             splashFig = figure('Name',['Flight ','Control',' | ',obj.App.VersionNumber],...
%                                 'units','pixels',...
%                                 'Position',obj.Figure.Position,...
%                                 'Menubar','none',...   
%                                 'Toolbar','none',...
%                                 'NumberTitle','off',...
%                                 'HandleVisibility', 'on',...
%                                 'Visible','on');
%             UserInterface.Utilities.enableDisableFig(splashFig, false);
            
            
%             % Show splash screen
%             splash = Utilities.SplashScreen( 'Splashscreen', 'ACDSplash_Control.png', ...
%                 'ProgressBar', 'off');
%             splash.addText( 30, 310, ['Version ',obj.App.VersionNumber], 'FontSize', 20, 'Color', [0 0 0] );
%             splash.addText( 33, 325, ['Build - ',obj.App.InternalVersionNumber], 'FontSize', 10, 'Color', [0 0 0] );
            
            a = obj.ToolObj.InternalVersionNumber;
            % Delete current obj and gui
            delete(obj.ToolObj);
            ldObj = load(fullfile(pathname,filename),'-mat');
           	drawnow();pause(0.5);

            obj.ToolObj = ldObj.ctrlObj;
            addlistener(obj.ToolObj,'LoadProject',@obj.loadProject);
            addlistener(obj.ToolObj,'CloseProject',@obj.closeProject);
            addlistener(obj.ToolObj,'SaveProject',@obj.saveProject);
            
            %%% Check Version number
            b = obj.ToolObj.InternalVersionNumber;
            verOK = compareVersionNumbers(a, b);
            
            if ~verOK
                msgbox(['Project Version ',b,' does not match this FLIGHT Control version ',a,'.'],'Version Info');
            end
                
            
            %%%%%%
            
%             addlistener(obj.ToolObj,'LoadedProjectName','PostSet',@obj.setFileTitle);
%             addlistener(obj.ToolObj,'ProjectSaved','PostSet',@obj.setFileTitle); 
            
            obj.ToolObj.Parent = obj.Figure;
            obj.ToolObj.Granola = obj.App.Granola;
            obj.ToolObj.StartUpFlag = false;
            obj.ToolObj.LoadingSavedWorkspace = true;
            obj.ToolObj.createView(obj.Figure);
            obj.ToolObj.ProjectSaved = true;
            
            obj.ToolObj.LoadedProjectName = filename;
            obj.ToolObj.ProjectDirectory = pathname;
%             reSize( obj.ToolObj , [] , [] );
            addProjectPath( obj.ToolObj , pathname );   
            
%             delete(splash);
            drawnow();pause(0.01);
            %updateSelectedBatchTab(obj.ToolObj);
            manualBatchTabCallback(obj.ToolObj);

            drawnow();pause(0.1);
%             UserInterface.Utilities.enableDisableFig(splashFig, true);
%             delete(splashFig);
            showLogMessage_CB( obj.ToolObj , [] , UserInterface.LogMessageEventData('Project Loaded','info') );
        end % loadWorkspace_CB
        
        function closeProject( obj , hobj , eventdata )
            obj.LoadingSavedWorkspace = false;
            
            delete(obj.BrowserPanel);
            delete(obj.SelectionPanel);
            delete(obj.LargeCardPanel);    
            delete(obj.RibbonPanel);

            obj.createView(obj.Parent);
            obj.ProjectSaved = false;
            obj.LoadedProjectName = filename;
            obj.ProjectDirectory = pathname;
            reSize( obj , [] , [] );

            % Remove the path
            if ~isempty(obj.ProjectMatlabPath)
                rmpath(obj.ProjectMatlabPath);
            end
        end % closeProject

    end % Project Control
    
    %% Methods - Close Figure
    methods   
        
        function closeFigure_CB(obj , hobj , eventdata )

            saveFIG = Utilities.saveProjectGUI();
            uiwait(saveFIG.Figure);
% 
%             choice = questdlg('Would you like to save the current project before closing?', ...
%                 'Closing...', ...
%                 'Yes','No','Cancel','Cancel');
            drawnow();pause(0.5);
             % Handle response
            switch saveFIG.PRJresponse %choice
                case 'Yes'
                    % Save the project
                    saveProject( obj , [] , saveFIG.PLTresponse);
%                     autoSaveFile( obj.ToolObj , [] , [] );
                    closeFigure(obj , hobj , [] );
                case 'No'
                    closeFigure(obj , hobj , [] );
                otherwise
                    % Do nothing
            end
        end % closeFigure_CB
    
        function closeFigure(obj , hobj , ~ )
            
            % Remove the path
            if ~isempty(obj.ToolObj.ProjectMatlabPath)
                rmpath(obj.ToolObj.ProjectMatlabPath);
            end
            
            
            
            warning(obj.HiddenWarnings);
            if ~isempty(obj.ToolObj.GainColl.ParentLarge)
                delete(obj.ToolObj.GainColl.ParentLarge);
            end 
            delete(obj.ToolObj);
            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.StartupScreen);
            end
            try %#ok<*TRYNC>             
                delete(obj.App);
            end    
            delete(hobj);
        end % closeFigure_CB

    end % Close Figure
    
    
    
    %% Methods - Misc
    methods  
        
        function loadOperCond(obj , hobj , eventdata )
            
            % Load the Operating Condition
            operCond2Load = eventdata.Value;
            operCond = lacm.OperatingCondition.empty; %#ok<NASGU>
            for j = 1:length(operCond2Load)
                varStruct = load(operCond2Load{j});
                varNames = fieldnames(varStruct);
                for i = 1:length(varNames)
                    obj.OperCond = [obj.OperCond,varStruct.(varNames{i})]; 
                end
            end
            
            % Update Filter Selections
            updateAvaliableSelections(obj.ToolObj.OperCondColl,{obj.OperCond(1).Inputs.Name}',{obj.OperCond(1).MassProperties.Parameter.Name}');
            
        end % loadOperCond
                
    end % Misc
    
%     %% Methods - Delete
%     methods
%         function delete( obj )
%             % User Defined Objects
%             try %#ok<*TRYNC>             
%                 delete(obj.StartupScreen);
%             end
%             try %#ok<*TRYNC>             
%                 delete(obj.App);
%             end       
%         end % delete
%     end
    
    
end


function y = compareVersionNumbers(a, b)

%     a_split = strsplit(a,'.');
%     b_split = strsplit(b,'.');
% 
%     y = true;
%     for i = 1:length(a_split)
%         if str2double(a_split{i}) ~= str2double(b_split{i})
%             y = false;
%         end
%     end

y = strcmp(a,b);

end % compareVersionNumbers

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



