classdef Level1Container < matlab.mixin.Copyable & UserInterface.GraphicsObject
    %% Version
    properties  
        VersionNumber
        InternalVersionNumber
    end % Version 
    
    %% Public properties - Graphics Handles 
    properties (Transient = true)

        RibbonPanel
        MainPanel
        LogPanel
        Granola
        WarningMsg
        StartUpFlag = true
    end % Public properties
  
    %% Public properties - Data Storage
    properties (Constant , Abstract = true)
        ProjectType
    end % Public properties
    
    %% Abstract properties - Data Storage
    properties  

    end % Abstract properties
    
    %% Public properties - Observable Data Storage
    properties (SetObservable)
       LoadedProjectName = 'Untitled'   % Name of the current project
       ProjectSaved logical = false     % Current save state of the project
       ProjectMatlabPath                % Matlab Path for the current project
       ProjectDirectory = pwd           % The Directory the current Project is located
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        SavedProjectLocation    % Current full path to the project
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
       
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)

    end % Dependant properties
    
    %% Dependant Read-only properties
    properties ( Dependent = true, GetAccess = public, SetAccess = private )
        ApplicationDataFolder 
    end % Read-only properties
      
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  
    
    %% Events
    events
        ShowLogMessageMain % notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(msg,sev));
        ClearLogMessageMain
        ExitApplication
        
        SaveProject 
        LoadProject
        CloseProject
        LaunchStartUp
        SetPointer
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = Level1Container(parent,ver,internalver)  
            switch nargin 
                case 0
                case 3
                    obj.VersionNumber = ver;
                    obj.InternalVersionNumber = internalver;
                   createView(obj,parent,ver,internalver); 
            end
        end % Main
    end % Level1Container

    %% Methods - Property Access
    methods
        
        function y = get.ApplicationDataFolder( obj ) 

            y = fullfile(getenv('appdata'),'FLIGHT',obj.ProjectType);
            
        end % ApplicationDataFolder
        
        function y = get.SavedProjectLocation( obj ) 

            y = fullfile(obj.ProjectDirectory,obj.LoadedProjectName);
            
        end % SavedProjectLocation
        
    end % Property access methods
    
    %% Methods - View
    methods 
        
        function createView(obj,parent)
            

            obj.WarningMsg = suppressWarnings();

            if nargin == 1
                try              
                    defaults = javax.swing.UIManager.getLookAndFeelDefaults;
                    if isempty(defaults.get('Table.alternateRowColor'))
                        defaults.put('Table.alternateRowColor', java.awt.Color( 246/255 , 243/255 , 237/255 ));
                    end
                catch
                   warning('Unable to update ''Table.alternateRowColor''.');
                end
                
                
                figID = [getenv('username'),' Flight ',obj.ProjectType,' | ',obj.InternalVersionNumber];
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
                obj.Parent = figure('Name',['FLIGHT ',obj.ProjectType,' | ',obj.InternalVersionNumber],...%Control',...
                                    'units','pixels',...
                                    'Position',[xpos, ypos, sz(2), sz(1)],...%[193 , 109 , 1384 , 960],...%[193,109,1368,768],
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...
                                    'Tag',figID,...
                                    'CloseRequestFcn', @obj.closeFigure_CB);
 
                if isa(obj.Parent,'matlab.ui.Figure')
                    Utilities.enforceMinimumFigureSize(obj.Parent,[1384 960]);
                end         
            else
                obj.Parent = parent;
            end
            
            set(obj.Parent,'ResizeFcn',@obj.reSize);
            
            position = getpixelposition(obj.Parent);
            % Create Tool Ribbion
            obj.RibbonPanel = uipanel('Parent',obj.Parent,...
                'Units','Pixels',...
                'BorderType','none',...
                'Position',[ 1 , position(4) - 93 , position(3), 93 ]);
%             % Create Card Panel
%             obj.MainCardPanel = UserInterface.CardPanel(2,'Parent',obj.Parent,...
%                 'Units','Pixels',...
%                 'Position',[1 , 100 , position(3) , position(4)-208 ]);
            % Create Main Container
            obj.MainPanel = uicontainer('Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[1 , 100 , position(3) , position(4) - 194 ]); 
%             obj.ProjectScreen = UserInterface.StartUpScreen('RecentPrjFile',fullfile(obj.ApplicationDataFolder,'previousprojects.flt'),'Title',obj.ProjectType,'Parent',obj.MainCardPanel.Panel(1),...
%                                                             'VersionNumber',obj.VersionNumber,...
%                                                             'InternalVersionNumber',obj.InternalVersionNumber);   
%             addlistener(obj.ProjectScreen,'NewProjectCreated',@obj.startupPrjCreated);
%             addlistener(obj.ProjectScreen,'ProjectLoaded',@obj.startupPrjLoaded);
            
            obj.LogPanel = UserInterface.LogMessage('Parent',obj.Parent,...
                'Units','Pixels',...
                'Position',[ 1 , 1 , position(3) , 100]);
            addlistener(obj,'ShowLogMessageMain',@obj.showLogMessage_CB);
            addlistener(obj,'ClearLogMessageMain',@obj.clearLogMessage_CB);
        end % createView

    end
   
    %% Methods - Ordinary
    methods 
        
        function y = checkKey( obj )
           
            y = checkKeyStatus( obj.Granola );
            if ~y
                h = errordlg('License key is missing. Save data and exit.','Missing Key','modal');
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('License key is missing. Save data and exit.','warn'));
                %-------------------------------------------------------------- 
                uiwait(h);
                error('License:KeyMissing', ...
                            'The license key is missing.');
            end

        end % checkKey
        
        function showLogMessage_CB( obj , ~ , eventdata )
            obj.LogPanel.logMessage(eventdata.Message,eventdata.Severity);
        end % showLogMessage_CB
        
        function clearLogMessage_CB( obj , ~ , eventdata )
            obj.LogPanel.clearLog();
        end % showLogMessage_CB              
            ;
        
        function setWaitPtr(obj)
            set(obj.Parent, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            set(obj.Parent, 'pointer', 'arrow'); 
        end % releaseWaitPtr
        
        function setPointer( obj , hobj , eventdata )
            if eventdata.State
                set(obj.Parent, 'pointer', 'watch');
            else
                set(obj.Parent, 'pointer', 'arrow'); 
            end
            drawnow()
        end % setPointer
        
        function autoSaveFile( obj , ~ , ~ )
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            %notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData('Saving Project...','info'));
            %--------------------------------------------------------------
            if exist(obj.SavedProjectLocation, 'file') == 2
                notify(obj,'SaveProject');
            else
                saveWorkspace( obj , [] , [] );
            end
            
        end % autoSaveFile
        
        function setFileTitle( obj , hobj , ~ )
            %fig = ancestor(hobj,'figure','toplevel') ;
            
            if obj.ProjectSaved
                obj.Figure.Name = ['FLIGHT ',obj.ProjectType,' | ',obj.InternalVersionNumber,' - ',obj.LoadedProjectName];
            else
                obj.Figure.Name = ['FLIGHT ',obj.ProjectType,' | ',obj.InternalVersionNumber,' - ',obj.LoadedProjectName,' *'];
            end
        end % setFileTitle
        
        function closeFigure_CB( obj , ~ , ~ )
            defaults = javax.swing.UIManager.getLookAndFeelDefaults;
            defaults.put('Table.alternateRowColor', []);
        end %closeFigure
        
    end % Ordinary Methods
   
    %% Methods - Project Related
    methods 
        
        function add2PreviousProjects( obj )
            filename = fullfile(obj.ApplicationDataFolder,'previousprojects.flt');
            Utilities.appendReplaceLineInFile( filename , obj.SavedProjectLocation , 6 );           
        end % add2PreviousProjects
        
%         function startupPrjCreated( obj , ~ , eventdata )
%             [path,file,ext] = fileparts(eventdata.Object);
%             notify(obj,'SaveProject',GeneralEventData( {path , [file,ext]}));
%         end % startupPrjCreated    
        
%         function startupPrjLoaded( obj , ~ , eventdata )
%             if ~exist(eventdata.Object,'file')
%                 % Remove from recent projects
%                 prevProjFile = fullfile(obj.ApplicationDataFolder,'previousprojects.flt');
%                 Utilities.removeLineInFile( prevProjFile , eventdata.Object );  
%                 launchStartup( obj );
%                 msgbox('This project no longer exists.');
%                 return;
%             end
% %             obj.MainCardPanel.SelectedPanel = 2;
% %             if strcmp(obj.ProjectType,'Control')
% %                 obj.JRPHComp.setSelectedIndex(1);    
% %             else
% %                 obj.RibbonObj.JRPHComp.setSelectedIndex(1);
% %             end
%             drawnow();
%             [path,file,ext] = fileparts(eventdata.Object);
%             loadProject( obj , path , [file,ext] );
%         end % startupPrjLoaded
%         
%         function launchStartup( obj , parent )
%             try
%                 delete(obj.StartupScreen.Parent);
%             end
%             % Launch StartUp Screen
%             obj.StartUpFlag = false;
%             obj.StartupScreen = UserInterface.StartUpScreen('RecentPrjFile',fullfile(obj.ApplicationDataFolder,'previousprojects.flt'),'Title',obj.ProjectType);
% %             pause(1.1);
%             addlistener(obj.StartupScreen,'NewProjectCreated',@obj.startupPrjCreated);
%             addlistener(obj.StartupScreen,'ProjectLoaded',@obj.startupPrjLoaded);
%             uiwait(obj.StartupScreen.Parent);
%         end % launchStartup
        
        function addProjectPath( obj , path )
            warn = warning('off','MATLAB:rmpath:DirNotFound'); 
            if ~isempty(obj.ProjectMatlabPath)
                rmpath(obj.ProjectMatlabPath);
            end
            addPaths = getAdditionalPaths( path );
            prjPaths  = genpath(path);
            prjPaths = strsplit(prjPaths,';');
            allPaths = [addPaths,prjPaths];
            allPaths = unique(allPaths);
            % Remove empty
            logArray = cellfun(@isempty,allPaths);
            allPaths = allPaths(~logArray);
            allPaths = strjoin(allPaths,';');
%             allPaths = strjoin([prjPaths,addPaths],';');
            if ~isempty(allPaths) && ~strcmp(allPaths(end),';')
                allPaths = [allPaths,';'];   
            end
            obj.ProjectMatlabPath = allPaths;
            addpath(obj.ProjectMatlabPath);  
            warning(warn);
            cd(path);
            setStartDirectories( obj.Tree , path );
            % Store the previous project
            add2PreviousProjects( obj );
        end % addProjectPath       
        
    end
    
    %% Methods - Error Handeling
    methods 
       

        
    end
    
    %% Methods - ReSize
    methods  
            
        function reSize( obj , ~ , ~ )
            
            % get figure position
            position = getpixelposition(obj.Parent);
       
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , position(4) - 93 , position(3), 93 ]);
            
            set(obj.MainPanel,'Units','Pixels',...
                'Position',[1 , 100 , position(3) , position(4) - 194 ]);
                        
            set(obj.LogPanel,'Units','Pixels',...
                'Position',[ 1 , 1 , position(3) , 100]);
        end % reSize
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function newProject_CB( obj , ~ , ~ )


        end % newProject_CB 
        
        function loadProject_CB( obj , ~ , ~ )


        end % loadProject_CB 
        
        function closeProject_CB( obj , ~ , ~ )
                %--------------------------------------------------------------
                %    Display Log Message
                %--------------------------------------------------------------
                notify(obj,'ShowLogMessageMain',UserInterface.LogMessageEventData(['Closing "',obj.LoadedProjectName,'"...'],'info'));
                %--------------------------------------------------------------
                choice = questdlg('Would you like to save the current project before closing?', ...
                    'Closing...', ...
                    'Yes','No','Cancel','Cancel');
                drawnow();pause(0.5);
                 % Handle response
                switch choice
                    case 'Yes'
                        % Save the project
                        notify(obj,'SaveProject');
                        notify(obj,'CloseProject');
                    case 'No'
                        notify(obj,'CloseProject');
                    otherwise
                        % Do nothing
                end
        end % closeProject_CB 
               
        function update( obj, ~ , ~ )
            
        end % update
        
        function buttonClickInAxis( obj , hobj , ~ )
            hcmenu = uicontextmenu;
            uimenu(hcmenu,'Label','Undock','UserData',hobj,'Callback',@obj.unDockAxis);
            uimenu(hcmenu,'Label','Change Axis Limits','UserData',hobj,'Callback',@obj.changeAxisLimits);
            hobj.UIContextMenu = hcmenu;
        end % buttonClickInAxis
        
        function unDockAxis( obj , hobj , eventdata )
            
            newfH  = figure( ...
                'Name', hobj.UserData.Title.String, ...
                'NumberTitle', 'off');

            leg = hobj.UserData.UserData;
            newAxH = copyobj([hobj.UserData,leg],newfH);
            drawnow();pause(0.5);
            newAxH(1).Units = 'Normal';
            newAxH(1).OuterPosition = [ 0 , 0 , 1 , 1 ];
            drawnow();pause(0.5);
            delete ( findobj ( ancestor(hobj,'figure','toplevel'), 'type','uicontextmenu' ) );
            delete ( findobj ( ancestor(newAxH(1),'figure','toplevel'), 'type','uicontextmenu' ) );
        end % unDockAxis
        
        function changeAxisLimits( obj , hobj , eventdata )
            UserInterface.SetAxesProperties(hobj.UserData);
%             xlim = hobj.UserData.XLim;
%             ylim = hobj.UserData.YLim;
%             
%             
%             prompt = {'X Lower Limit:','X Upper Limit:','Y Lower Limit:','Y Upper Limit:'};
%             dlg_title = 'Input';
%             num_lines = 1;
%             defaultans = {num2str(xlim(1)),num2str(xlim(2)),num2str(ylim(1)),num2str(ylim(2))};
%             answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
%             if isempty(answer)
%                 return;
%             end
%             try
%                 newXlim = [str2double(answer{1}),str2double(answer{2})];
%                 newYlim = [str2double(answer{3}),str2double(answer{4})];
% 
%                 hobj.UserData.XLim = newXlim;
%                 hobj.UserData.YLim = newYlim; 
%             end
        end % changeAxisLimits

    end
    
    %% Methods - Private
    methods (Access = private)   

    end
    
    %% Method - Delete
    methods
        function delete(obj)

%             % Matlab Properties
            try %#ok<*TRYNC> 
                delete(obj.RibbonPanel);
            end
            try %#ok<*TRYNC> 
                delete(obj.MainPanel);
            end
            % User Defined Properties
            try %#ok<*TRYNC>             
                delete(obj.LogPanel);
            end
%             try %#ok<*TRYNC>  
%                 delete(obj.StartupScreen);
%             end
%             try %#ok<*TRYNC>  
%                 delete(obj.ProjectScreen);
%             end
%             try %#ok<*TRYNC>  
%                 delete(obj.Granola);
%             end
%             try %#ok<*TRYNC>  
%                 delete(obj.MainCardPanel);
%             end
            % Data
%             obj.WarningMsg
%             obj.StartUpFlag  

        end % delete
    end
  
    %% Methods - Protected (Abstract)
    methods (Abstract,Access = protected) 
        
    end 
    
    %% Method - Static
    methods ( Static )
        
        function disable( container )
            children = get(container,'Children');   
            for i = 1:length(children)
                
               set(children(i),'Enable','Off'); 
            end        
        end % disable 
        
        function enable( container )
            children = get(container,'Children');   
            for i = 1:length(children)
                
               set(children(i),'Enable','on'); 
            end  
        end % enable   
        
    end
        
end

function addPaths = getAdditionalPaths( prjPath )
    pathFile = fullfile(prjPath,'paths.txt');
    % Read in the file
    addPaths = {};
    if exist(pathFile, 'file')
        fid = fopen( pathFile );           
        tline = fgets(fid);
        while ischar(tline)
            addPaths{end + 1} = strtrim(tline); %#ok<AGROW>
            tline = fgets(fid);
        end
        fclose(fid);

        % Remove any empty's
        blankLogArray = cellfun(@(x) isempty(strtrim(x)),addPaths);
        addPaths(blankLogArray) = [];
        
        % concatenate project paths if relative
        for i = 1:length(addPaths)
            if strcmp(addPaths{i}(1),'\') || strcmp(addPaths{i}(1),'/') 
                addPaths{i} = Utilities.GetFullPath(fullfile(prjPath,strtrim(addPaths{i})));
            else
                addPaths{i} = Utilities.GetFullPath(strtrim(addPaths{i}));
            end
        end   
    end
end % getAdditionalPaths

function warn = suppressWarnings()
% these warning appear due to using undocumented and unsupported
% features in matalb    
    warn(1)       = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
    warn(end + 1) = warning('off','MATLAB:legend:IgnoringExtraEntries');
    warn(end + 1) = warning('off','Simulink:Data:WksGettingDataSource');
    warn(end + 1) = warning('off','MATLAB:rmpath:DirNotFound'); 
%     warn(end + 1) = warning('off','Simulink:Data:WksGettingDataSource');
%     warn(1) = warning('off','MATLAB:Java:ConvertFromOpaque'); 
%     warn(2) = warning('off','MATLAB:uitree:DeprecatedFunction'); 
%     warn(3) = warning('off','MATLAB:uitreenode:DeprecatedFunction'); 
%     warn(4) = warning('off','MATLAB:hg:JavaSetHGProperty');

%     warn(6) = warning('off','MATLAB:class:loadError');   
%     warn(7) = warning('off','MATLAB:hg:PossibleDeprecatedJavaSetHGProperty');  
%     warn(8) = warning('off','MATLAB:hg:ColorSpec_None');
%     warn(9) = warning('off','MATLAB:uitabgroup:OldVersion');

end % suppressWarnings