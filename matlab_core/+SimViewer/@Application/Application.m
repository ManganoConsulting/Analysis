classdef Application < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
%         Figure
        ToolLoadedObj
        Granola
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        VersionNumber = '1.0'
        InternalVersionNumber = '1.1.0.0'
        
        AccessAllowed = false
        
        NeedRestart = false
    end % Public properties
    
    %% Methods - Constructor
    methods      
        
        function obj = Application( productID )



            
            %% ************************************************************
            %****************Check For Matlab Version Compatability *******
            %**************************************************************

            % Check for compatible matlab version        
            if verLessThan('matlab', '8.5.0')
                error('You need Matlab 2015a or later to run the SimViewer application.'); % Terminate Program
            end


            %% ************************************************************
            %******************Check Java Static Path Compatability *******
            %**************************************************************

            % ******* Find directory's for current install *******************
            jpath         = Application.javapath();                         % Java Static class path
            flightPath    = Application.flightpath();                       % Location of top level FLIGHT directory
            prefDirectory = prefdir;                                        % Location of the users Matlab prefrences directory
            classPathFile = fullfile(prefDirectory,'javaclasspath.txt');    % Path to the javaclasspath.txt file
            jFLIGHTPath{1} = fullfile(flightPath,'java');         % Current location of java classes


            % ******* Check for java static paths *************************
            % Ensure the static java path contains the correct paths
            existsOnStaticPath = all(ismember(jFLIGHTPath,jpath));
            
            %% ************************************************************
            %******************Check library.txt Path Compatability *******
            %**************************************************************
            libraryPath = fullfile(prefDirectory,'javalibrarypath.txt');
            libPath = fullfile(flightPath,'+Utilities\lib');
            added2LibraryPath = Utilities.appendLineInFile( libraryPath , libPath );
            currPathEnv = getenv('PATH');
            ind = strfind(currPathEnv,libPath);
            if isempty(ind)
                setenv('PATH', [getenv('PATH') ';',libPath]);
            end

            %% ************************************************************
            %******************Update Java and DLL paths ******************
            %**************************************************************
            if ~existsOnStaticPath  || added2LibraryPath
                if ~existsOnStaticPath
                    if ~existsOnStaticPath
                        for i = 1:length(jFLIGHTPath)
                            % Add the new Location
                            Utilities.appendReplaceLineInFile( classPathFile , jFLIGHTPath{i} );
                        end
                    end
                end
                warning('The installation is complete: Please RESTART Matlab');
                msgbox('The installation is complete: Please RESTART Matlab');
                obj.NeedRestart = true;
                return;% Terminate Program
            end
                       
            %% ************************************************************
            %********************** Validate License Key ******************
            %**************************************************************
            useLIC = false;
            if useLIC
                switch productID   %#ok<UNRCH>
                    case 1
                        obj.Granola = SimulationLib(200);
                    case 2
                        obj.Granola = SimulationLib(300);
                    case 3
                        obj.Granola = SimulationLib(400);
                end
            else
                switch productID   %#ok<UNRCH>
                    case 1
                        obj.Granola = SimMacLib(200);
                    case 2
                        obj.Granola = SimMacLib(300);
                    case 3
                        obj.Granola = SimMacLib(400);
                end
            end
            status = login(obj.Granola);

            if ~status
                obj.AccessAllowed = false;
                %throw(obj.Granola.LastError); % Terminate Program
            else
                obj.AccessAllowed = true;
            end 

        end % SimulationLib
        
    end % Constructor
    
    %% Methods - Static
    methods ( Static )
        
        function path = javapath()
            path         = javaclasspath('-static');                       % Java Static class path
        end % javapath
        
        function path = flightpath()
            path         = fileparts(fileparts(mfilename('fullpath')));    % Java Static class path
        end % flightpath
        
        function path = installpaths()
            filename       = fullfile(prefdir,'javaclasspath.txt');
            javapaths      = Utilities.readFileByLine( filename );
            
            newStr = cell(1,length(javapaths));
            for i = 1:length(javapaths)
                newStr{i} = regexprep(javapaths{i},['[\\\/]','\+Utilities','.*'],'');
            end
            path = unique(newStr);
        end %installpaths
        
        function removeInstallsFromMPath()
            warnStruct = warning('off','MATLAB:rmpath:DirNotFound');
            path = Application.installpaths();
            rmpath(strjoin(path,';'));   
            warning(warnStruct); % restore the warning state
        end % removeInstallsFromMPath
        
    end
    
end



