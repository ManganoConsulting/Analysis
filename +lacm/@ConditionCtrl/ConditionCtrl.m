classdef ConditionCtrl < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties       
        Name
        %Value = 0
        Value
        Units
        Fix
        BasicMode = 'None'  % None,Longitudinal,LateralDirectional
        Constrained = false;
        
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        UsePrevious = false
        DisplayedTableIndex
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        StringValue
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true)
        % Value
    end % Dependant properties
    %% Private Properties
    properties (Access = private)
        %PrivateStringValue
        %PrivateValue
        
    end % Hidden properties
    
    %% Methods - Constructor
    methods      
        function obj = ConditionCtrl(name,value,units,fix,usePrev)
            switch nargin
                case 0                    
                case 1
                    obj.Name = name;
                case 2
                    obj.Name = name;
                    obj.Value = value;
                case 3
                    obj.Name = name;
                    obj.Value = value;
                    obj.Units = units;
                case 4
                    obj.Name = name;
                    obj.Value = value;
                    obj.Units = units;
                    obj.Fix   = fix;
                case 5
                    obj.Name = name;
                    obj.Value = value;
                    obj.Units = units;
                    obj.Fix   = fix;
                    obj.UsePrevious = usePrev;
            end

        end % Condition
    end % Constructor

    %% Methods - Property Access
    methods
        
        %function set.Value( obj , val )
        %    
        %    if ischar(val)
        %        tempVal = str2num(val);
        %        if isempty(tempVal)
        %            if strcmpi(val,'Trim1') || strcmpi(val,'Trim 1')
        %                obj.UsePrevious = true;
        %                obj.PrivateValue = 0;% change for trim2 fix  was = [];
        %                obj.PrivateStringValue = tempVal;
        %                obj.Constrained = false;
        %            else
        %                obj.Fix = true;
        %                obj.UsePrevious = false;
        %                obj.PrivateValue = 0;% change for trim2 fix  was = [];
        %                obj.PrivateStringValue = val;
        %                obj.Constrained = true;
        %                %error('String must be convertable to a numeric array.');
        %            end
        %        else
        %            obj.UsePrevious = false;
        %            obj.PrivateValue = tempVal;
        %            obj.PrivateStringValue = val;
        %            obj.Constrained = false;
        %        end
        %    else
        %        obj.Constrained = false;
        %        obj.PrivateValue = val;
        %        obj.PrivateStringValue = num2str(val);
        %    end
            
        %end % Value
        
        function y = get.Value( obj )
            y = double(obj.Value);
        end % Value
        
        function y = get.StringValue( obj  )
            %if obj.UsePrevious
            %    y = 'Trim 1';
            %else
            %    y = obj.PrivateStringValue;
            %end
            y = num2str(obj.Value);
        end % StringValue
        
        function dispData = getDisplayData(obj)
            
            propNames = properties(obj);
            dispData = cell(length(propNames),2);
            
            for i = 1:length(obj)
                dispData{i,1} = obj(i).Name;
                if isscalar(obj(i).Value) 
                    if ~ischar(obj(i).Value)  
                        dispData{i,2} = num2str(obj(i).Value,4);
                    else
                        dispData{i,2} = obj(i).Value;
                    end
                else
                    dispData{i,2} = class(obj(i).Value);
                end
                
            end
            
        end % getDisplayData
         
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
   
        function newObj = get(obj,name)
            newObj = lacm.Condition.empty;
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
            end   
        end % get
        
        function newObj = geti(obj,name)
            newObj = lacm.Condition.empty;
            lcArray = strcmpi(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
            end   
        end % geti
        
        function ind = find(obj,name)
            ind = find(strcmp(name,{obj.Name}));
        end % find
        
        function y = getValue(obj,name)
            y = [];
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
                y = [newObj.Value];
            end   
        end % getValue

       function y = eq(A,B)
            if length(A) == length(B)
                for i = 1:length(A)
                    if isempty(A(i).Units) && isempty(B(i).Units)
                        if strcmp(A(i).Name,B(i).Name) && ...
                                    A(i).Value == B(i).Value
                            y(i) = true; 
                        else
                            y(i) = false;
                        end
                    else 
                        if strcmp(A(i).Name,B(i).Name) && ...
                                A(i).Value == B(i).Value && ...
                                strcmp(A(i).Units,B(i).Units)
                            y(i) = true;
                        else
                            y(i) = false;
                        end
                    end
                end
            end
        end % eq
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       


    end
    
end
