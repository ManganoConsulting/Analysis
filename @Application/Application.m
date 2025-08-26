classdef Application < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        ToolLoadedObj
        Granola
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        VersionNumber = '4.1'
        InternalVersionNumber = '4.0.1'
        
        AccessAllowed = false
        
        NeedRestart = false
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )     

    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )

    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 

    end
    
    %% Events
    events
        
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = Application( productID )



            
            %% ************************************************************
            %****************Check For Matlab Version Compatability *******
            %**************************************************************

            % Check for compatible matlab version        
            if verLessThan('matlab', '8.5.0')
                error('You need Matlab 2015a or later to run the FLIGHT application.'); % Terminate Program
            end


            %% ************************************************************
            %******************Check Java Static Path Compatability *******
            %**************************************************************

            % ******* Find directory's for current install *******************
            jpath         = Application.javapath();                         % Java Static class path
            flightPath    = Application.flightpath();                       % Location of top level FLIGHT directory
            prefDirectory = prefdir;                                        % Location of the users Matlab prefrences directory
            classPathFile = fullfile(prefDirectory,'javaclasspath.txt');    % Path to the javaclasspath.txt file
            occPath       = fullfile(flightPath,'+UserInterface\+ControlDesign\@OCCControlDesign'); % Original directory containing java classes
            utilPath      = fullfile(flightPath,'+Utilities');                                      % Original directory containing java classes
            jFLIGHTPath{1} = fullfile(flightPath,'+Utilities\java');         % Current location of java classes
            jFLIGHTPath{2} = fullfile(jFLIGHTPath{1},'hasp-srm-api.jar');    % Current location of Hasp Jar File
            jFLIGHTPath{3} = fullfile(jFLIGHTPath{1},'UIExtrasTree.jar');
            % Remove the original location from javaclasspath.txt if it exists
            Utilities.removeLineInFile( classPathFile , occPath );
            Utilities.removeLineInFile( classPathFile , utilPath  );

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

    %% Methods - Property Access
    methods
  
    end % Property access methods
  
    %% Methods - Protected Callbacks
    methods (Access = protected)
        
    end
    
    %% Methods - Resize Ordinary Methods
    methods     

                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods
        

        
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        

    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Example object
            % cpObj.Example = copy(obj.Example);
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)

    end
    
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
            utilPath       = fullfile(Application.flightpath,'+Utilities');
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



