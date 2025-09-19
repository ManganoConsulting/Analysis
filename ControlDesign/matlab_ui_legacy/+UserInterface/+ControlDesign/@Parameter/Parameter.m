classdef Parameter < matlab.mixin.Copyable
    
    %% Public properties
    properties   
        Name
        ValueString
        %Workspace
        
        Displayed logical = false
        
    end % Public properties
    
    %% Properties - Observable AbortSet
    properties( SetObservable , AbortSet )
       Global = false
    end
  
    %% Private properties
    properties ( Access = private )  

    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties% (Hidden = true)
        Max double = 1
        Min double = 0
        UserDefined logical = false
        
        ObjectValue
        Type = 'Normal'
        
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        Value
        DisplayString 
%         Type
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        SliderEnable
        DisplayName
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = Parameter(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Name','x',@ischar);
            addParameter(p,'String','');
            addParameter(p,'Value',[]);
            addParameter(p,'UserDefined',false);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Name = options.Name;
            obj.UserDefined = options.UserDefined;

            if isempty(options.Value)
                switch class(options.String)
                    case 'struct'
                        obj.ValueString = Utilities.sizeString( options.String,true);
                        obj.ObjectValue = options.String;
                        obj.Type = 'Struct';
                    case 'cell'
                        obj.ValueString = Utilities.sizeString( options.String,true);
                        obj.ObjectValue = options.String;
                        obj.Type = 'Cell';
                    case 'char'
                        obj.ValueString = options.String;
                        obj.Type = 'String';
                    case 'tf'
                        obj.ValueString = Utilities.sizeString( options.String,true);
                        obj.ObjectValue = options.String;
                        obj.Type = 'tf';
                    otherwise
                        if isnumeric(options.String)
                            obj.ValueString = num2str(options.String);
                        else
                            obj.ValueString = Utilities.sizeString( options.String,true);
                            obj.ObjectValue = options.String;
                            obj.Type = class(options.String); 
                        end
                end
            else
                obj.Value = options.Value;
            end
            defaultMinMax( obj );
        end % Parameter
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        
        function y = get.DisplayName(obj)

                if isempty(obj.Name)
                    y = '';
                else
                    if obj.Global
                        y = ['<html><FONT color="red">',obj.Name,'</Font></html>'];
                    else
                        y = obj.Name;
                    end              
                end
                
        end % DisplayName
                
        function y = get.DisplayString(obj)
            if ~isempty(obj.ValueString)
                temp = str2num(obj.ValueString); %#ok<ST2NM>
                if isempty(temp)
                    y = obj.ValueString;
                else
                    if isscalar(temp)
%                         if obj.Global
%                             y = ['<html><FONT color="red">',obj.ValueString,'</Font></html>'];
%                         else
                            y = obj.ValueString;
%                         end
                        
                    else
                        y = ['<html><i>',Utilities.sizeString( temp , true ),'</i></html>'];
                    end
                        
                end
                
                
                

            else
                % Default to 0
                y = '';
            end
        end % DisplayString
        
        function y = get.SliderEnable(obj)
            testNum = str2double(obj.ValueString);
            if isnan(testNum)
                y = false;     
            else
                y = true;     
            end
        end % Value
        
        function y = get.Value(obj)
            if ~isempty(obj.ValueString)
                y = str2num(obj.ValueString); %#ok<ST2NM>
                if isempty(y)
%                     try
%                         %try and evaluate in the base workspace
%                         y = evalin('base',obj.ValueString);
%                     catch %#ok<CTCH>
%                         % try and evaluate using tool parameters
%                         y = 'Missing Info';
                        y = obj.ValueString;
%                     end
                end
            else
                y = 0;
            end
        end % Value
        
        function set.Value(obj,val)
            if isnumeric(val)
                newvalue = num2str(val);
            elseif ischar(val)
                newvalue = val;
            end
            if ischar(newvalue)
                obj.ValueString = newvalue;
            else  
                error('Value must be convertible to a number');
            end
        end % Value
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 

        function defaultMinMax( obj )
            if obj.SliderEnable
                value = obj.Value;
                obj.Max = value + (abs(value) * 0.5);
                obj.Min = value - (abs(value) * 0.5);
            else
                obj.Max = 1;
                obj.Min = 0;  
            end
        end % defaultMinMax
        
        function y = sort( obj )
            [~,I] = sort({obj.Name});
            y = obj(I);
        end % sort
        
        function newObj = get(obj,name)
            newObj = UserInterface.ControlDesign.Parameter.empty;
            lcArray = strcmp(name,{obj.Name});
            if any(lcArray)
                newObj = obj(lcArray);
            end   
        end % get
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)     
        
        function update(obj)

        end

        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            %cpObj.Tree = copy(obj.Tree);
        end
        
    end


    %% Methods - Static
    methods(Static)
    end % Methods - Static
end


