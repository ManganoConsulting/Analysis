classdef GainFile < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Data Storage
    properties  
        Name char
        ScatteredGainCollection ScatteredGain.GainCollection = ScatteredGain.GainCollection.empty
        Date
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)

        
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)
 
    end % Dependant properties
    
    
    %% Methods - Constructor
    methods   
        
        function obj = GainFile( varargin )
            
            
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Name','');
            addParameter(p,'ScatteredGain',ScatteredGain.GainCollection.empty);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Name = options.Name;
            obj.ScatteredGainCollection = options.ScatteredGain;
            obj.Date = datestr(now);
            
            
        end % GainFile
        
    end % Constructor


    %% Methods - Callbacks
    methods 
 
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function gainAdded = addGain( obj , scattGain )  
            gainAdded = false;
            
            logArray = scattGain == obj.ScatteredGainCollection;
            if all(~logArray)
                obj.ScatteredGainCollection(end + 1) = scattGain;
                gainAdded = true;
            else
                obj.ScatteredGainCollection(logArray) = scattGain;
            end
        end % addGain
        
        function uisave( obj ) %#ok<MANU>
            builtin('uisave','obj','ScatteredGainFile') %call builtin
        end % uisave
        
        function y = eq(A,B)
            if isempty(A) || isempty(B)
                y = false;
            elseif length(A) == length(B)
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                for i = 1:length(B)
                    if A.DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end   
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B.DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end     
            end
        end % eq
        
        function exportGains(obj, filename)
            j=1;
            varnames = {};
            for i = 1:length(obj.ScatteredGainCollection(j).Gain)
                eval([obj.ScatteredGainCollection(j).Gain(i).Name,' = obj.ScatteredGainCollection(j).Gain(i).Value;']);
                varnames{i} = ['''',obj.ScatteredGainCollection(j).Gain(i).Name,'''']; %#ok<AGROW>
            end
            if ~isempty(varnames)
                varnameStr = ['{',strjoin(varnames,','),'}'];

                eval(['matlab.io.saveVariablesToScript(filename,',varnameStr,');']);
            end
        end % end
        
    end % Ordinary Methods    
       
    %% Methods - Protected
    methods (Access = protected)     
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the ScatteredGainCollection object
            cpObj.ScatteredGainCollection = copy(obj.ScatteredGainCollection); 
        end % copyElement
        
    end
    
    %% Methods - Private
    methods ( Access = private )
        

        
    end
    
    %% Methods - Static
    methods (Static)

    end
    
    
end