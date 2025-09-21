classdef BatchTask < dynamicprops & matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties 
  
        WEIGHTCODE   
        TRIMID  
        TARGETVAR   
        TARGETVAL   
        LINMODEL  
        LABEL     
        VARIABLES
        FLIGHTCONDITION1
        FLIGHTCONDITION2
        FILELOCATION
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)

        
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
        
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = BatchTask(varargin)
            switch nargin
                case 0 
                case 1
                    if exist(varargin{:},'file')
                        import Utilities.*
                        % Open file
                        fid = fopen(varargin{:},'r');

                        % Read header
                        hdr = textscan(fid,'%s%s%s%s%s%s%s%s%s',1);
                        
                        % Read columns
                        cols = textscan(fid,'%s%s%s%s%s%s%s%s%s');

                        % Close Task file
                        fclose(fid); 
                        obj(length(cols{1})) = lacm.BatchTask;
                        for i = 1:length(cols{1})                           
                            obj(i).FLIGHTCONDITION1 = [hdr{1},cols{1}(i)]; %#ok<*AGROW>
                            obj(i).FLIGHTCONDITION2 = [hdr{2},cols{2}(i)];
                            obj(i).(hdr{3}{:})  =  cols{3}{i};
                            obj(i).(hdr{4}{:})  =  cols{4}{i};  
                            obj(i).(hdr{5}{:})  =  cols{5}{i};     
                            obj(i).(hdr{6}{:})  =  cols{6}{i};     
                            obj(i).(hdr{7}{:})  =  cols{7}{i};    
                            obj(i).(hdr{8}{:})  =  cols{8}{i};       
                            obj(i).(hdr{9}{:})  =  cols{9}{i};  
                            obj(i).FILELOCATION = varargin{:};
                        end
                    end
                otherwise


            end
            
        end % TrimTask
    end % Constructor

    %% Methods - Property Access
    methods            
        
        function set.WEIGHTCODE(obj,value)
            [y , str] = Utilities.isInSingleQuotes(value);
            if y    
                obj.WEIGHTCODE = str;
            else
                obj.WEIGHTCODE = value;
            end   
        end % WEIGHTCODE      
        
        function set.TARGETVAR(obj,value)
            if ischar(value)
                try
                    obj.TARGETVAR = eval(value);
                catch
                    obj.TARGETVAR = value;
                end
            end   
        end % TARGETVAR
        
        function set.TARGETVAL(obj,value)
            if ischar(value)
                try
                    obj.TARGETVAL = str2num(value);  %#ok<ST2NM>
                catch
                    obj.TARGETVAL = [];
                    disp('Target Value is incompatiable')
                end
            else
                obj.TARGETVAL = value;
            end  
        end % TARGETVAL
        
        function set.LINMODEL(obj,value)
            [y , str] = Utilities.isInSingleQuotes(value);
            if y    
                obj.LINMODEL = str;
            else
                obj.LINMODEL = value;
            end     
        end % LINMODEL       
        
        function set.VARIABLES(obj,value)
            if isempty(value)
                tempVal = {};
            elseif ischar(value)
                tempVal = eval(value);
            elseif iscell(value)
                tempVal = value;
            else
                error('In the task file the cell matrix format is not supported');
            end
            
            if mod(size(tempVal,2),2) ~= 0
               error('Array must contain Name/Value pairs.'); 
            else
                if size(tempVal,1) == 1 || size(tempVal,2) == 1
                    vars(length(tempVal)/2) = lacm.Condition;
                    ind = 1;
                    for i = 2:2:length(tempVal)
                        vars(ind) = lacm.Condition(tempVal{i-1},tempVal{i}); 
                        ind = ind + 1;
                    end
                elseif size(tempVal,1) == 2 || size(tempVal,2) == 2  
                    vars(size(tempVal,1)) = lacm.Condition;
                    for i = 1:size(tempVal,1)
                        vars(i) = lacm.Condition(tempVal{i,1},tempVal{i,2});   
                    end  
                elseif isempty(tempVal)
                    vars = lacm.Condition.empty;
                else
                    error('In the task file the cell matrix for ''Variables'' is incorrect');
                end
            end
            obj.VARIABLES = vars;
        end % VARIABLES

    end % Property access methods
    
    %% Methods - View Protected
    methods (Access = protected)
        
            
    end % Protected View Methods
    
    %% Methods - Callbacks
    methods 
          
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)   
        
                       
    end
    
    %% Methods - Static
    methods (Static) 
        
        function tempTrimTask = createTaskFromFile( tablehdr , cols ) 
            import Utilities.*

            tabledata = allcomb(cols{:});

            tempTrimTask(size(tabledata,1)) = lacm.TrimTask;    
            for j = 1:size(tabledata,1)

                args = {};
                dargs = {};
                for i = 1:size(tabledata,2)
                    lArray = strcmpi(tablehdr{i},properties(lacm.TrimTask));
                    if any(lArray)
                       args{end+1} =  tablehdr{i};
                       %args{end+1} =  cols{i}{j};
                       args{end+1} =  tabledata{j,i};
                    else
                       dargs{end+1} =  tablehdr{i};
                       %dargs{end+1} =  cols{i}{j};
                       if isnumeric(tabledata{j,i}) && isscalar(tabledata{j,i})
                           dargs{end+1} =  tabledata{j,i};
                       else                          
                           dargs{end+1} =  str2double(tabledata{j,i});
                       end
                    end
                end
                args =[args,'FC',{dargs}]; %#ok<AGROW>
                tempTrimTask(j) = lacm.TrimTask(args{:});     
                
                tempTrimTask(j).FlightCondition = lacm.FlightCondition( dargs{:} );
                
                
            end
        end  % createTaskFromFile
    
    end % Static
    
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the MassPropObj object
%             cpObj.MassPropObj = copy(obj.MassPropObj);
%             % Make a deep copy of the TrimDefObj object
%             cpObj.TrimDefObj = copy(obj.TrimDefObj);
%             % Make a deep copy of the LinMdlObj object
%             cpObj.LinMdlObj = copy(obj.LinMdlObj);
%             % Make a deep copy of the FlightCondition object
%             cpObj.FlightCondition = copy(obj.FlightCondition);
%             % Make a deep copy of the StateConditions object
%             cpObj.StateConditions = copy(obj.StateConditions);
%             % Make a deep copy of the StateDerivativeConditions object
%             cpObj.StateDerivativeConditions = copy(obj.StateDerivativeConditions);
%             % Make a deep copy of the InputConditions object
%             cpObj.InputConditions = copy(obj.InputConditions);
%             % Make a deep copy of the OutputConditions object
%             cpObj.OutputConditions = copy(obj.OutputConditions);
%             % Make a deep copy of the InitialTrimTask object
%             cpObj.InitialTrimTask = copy(obj.InitialTrimTask); 
            
        end
    end
    
end


