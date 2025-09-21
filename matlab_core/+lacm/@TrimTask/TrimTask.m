classdef TrimTask < dynamicprops & matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties 
        Label
  

        MassPropObj = lacm.MassProperties.empty
        TrimDefObj = lacm.TrimSettings.empty
        LinMdlObj = lacm.LinearModel.empty
        Simulation
        ConstantsFile
                
        TargetStateConditions = lacm.Condition.empty
        TargetStateDerivConditions = lacm.Condition.empty
        TargetInputConditions = lacm.Condition.empty
        TargetOutputConditions = lacm.Condition.empty
        
        Units
        
        FlightCondition lacm.FlightCondition
        
        StateConditions = lacm.Condition.empty
        StateDerivativeConditions = lacm.Condition.empty
        InputConditions = lacm.Condition.empty
        OutputConditions = lacm.Condition.empty  
        
        InitialTrimTask lacm.TrimTask
        
        BatchTrimID
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        FC1Type
        FC2Type
        FC1Value
        FC2Value
        
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
%         TargetCondition
        
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = TrimTask(varargin)
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
                
                        Utilities.multiWaitbar( 'Loading Trims...', 0 , 'Color', 'b'); 
                        tempObj = lacm.TrimTask.empty;
                        for i = 1:length(cols{1})
                            args = {};
                            for j = 1:length(cols)
                                if isempty(str2num(cols{j}{i}))
                                    args{end+1} = cols{j}(i);  
                                else
                                    args{end+1} = num2cell(str2num(cols{j}{i}));
                                    
                                end  
                            end
                            
                            tempTrimTask = lacm.TrimTask.createTaskFromFile( [hdr{:}] , args ); 
                            
                            for mm = 1:length(tempTrimTask)
                                tempTrimTask(mm).BatchTrimID= args{4};
                            end
                            tempObj = [tempObj,tempTrimTask];
                            Utilities.multiWaitbar( 'Loading Trims...', i/length(cols{1}) , 'Color', 'b'); 
                        end
                        obj = tempObj;
                        Utilities.multiWaitbar( 'Loading Trims...', 'close');
                    end
                otherwise
                    p = inputParser;
                    addParameter(p,'Label','');
                    
                    p.KeepUnmatched = true;
                    parse(p,varargin{:});
                    options = p.Results;

                    obj.Label = options.Label;
                    obj.FC1Type  = options.FC{1};
                    obj.FC1Value  = options.FC{2};
                    obj.FC2Type = options.FC{3};
                    obj.FC2Value = options.FC{4};

            end
            
        end % TrimTask
    end % Constructor

    %% Methods - Property Access
    methods            
     

        function set.Label(obj,value)
            [y , str] = Utilities.isInSingleQuotes(value);
            if y    
                obj.Label = str;
            else
                obj.Label = value;
            end 
        end % Label    

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
        
        function update(obj)
        
        end % update
                       
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
            % Make a deep copy of the MassPropObj object
            cpObj.MassPropObj = copy(obj.MassPropObj);
            % Make a deep copy of the TrimDefObj object
            cpObj.TrimDefObj = copy(obj.TrimDefObj);
            % Make a deep copy of the LinMdlObj object
            cpObj.LinMdlObj = copy(obj.LinMdlObj);
            % Make a deep copy of the FlightCondition object
            cpObj.FlightCondition = copy(obj.FlightCondition);
            % Make a deep copy of the StateConditions object
            cpObj.StateConditions = copy(obj.StateConditions);
            % Make a deep copy of the StateDerivativeConditions object
            cpObj.StateDerivativeConditions = copy(obj.StateDerivativeConditions);
            % Make a deep copy of the InputConditions object
            cpObj.InputConditions = copy(obj.InputConditions);
            % Make a deep copy of the OutputConditions object
            cpObj.OutputConditions = copy(obj.OutputConditions);
            % Make a deep copy of the InitialTrimTask object
            cpObj.InitialTrimTask = copy(obj.InitialTrimTask); 
        end
    end
    
end


