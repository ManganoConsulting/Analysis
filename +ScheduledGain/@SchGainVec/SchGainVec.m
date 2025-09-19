classdef SchGainVec < matlab.mixin.Copyable
    %% Public properties - Data Storage
    properties  

    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        Line1
        Line2
        Line3
    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        Color char = '0,114,189'
        Current logical = false % currently being scheduled
        Selected logical = true % Selected in options table
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)

    end % Dependant properties
    
    %% View Properties
    properties( Hidden = true , Transient = true )
        LineH
        
    end

    %% Hidden Properties
    properties( Hidden = true )
        
        
    end
       
    %% Dependant Private properties
    properties (Dependent = true, SetAccess = private)
%         PolyDegreeValue
        BreakPoints1
        BreakPoints2
        
    end % Dependant Private properties
    
    %% Private Properties
    properties ( Access = private )
        
    end
    
    %% Observable Properties
    properties (SetObservable)
        ScatteredGains
        ScatteredGainName
        ScatteredGainDisplayString
        ScatteredGainExpression
        
        NumberOfDimensions
        
        BreakPoints1ValueDisplayString
        
        BreakPoints2DisplayString
        BreakPoints2Expression
        
        TableDefinitionBreakPoints1
        TableDefinitionBreakPoints2
        TableDefinitionTableData

        FitType
        FittingRange
        UserDefinedBreakPoints
        
        PolyDegreeValue       
        
        ScheduledGain
        IncludedInFit
        IsScheduled = false
        BreakPoints2ValuesDisplayString = ''
    end 
    
    %% Methods - Constructor
    methods   
        
        function obj = SchGainVec( scattGainName , gainStr , gainExp , schGainName , numOfDim , bp1ValueStr , bp2Str , bp2Exp , tblBp1Name , tb2Bp1Name ,fitType , fitRange ,userBp , poly1 , scatteredGains , includedInFit, bp2val_dispStr)
            switch nargin
                case 2
                    obj.ScatteredGainName = scattGainName;
                    obj.ScatteredGainExpression = gainExp;
                case 3
                    obj.ScatteredGainName = scattGainName;
                    obj.ScatteredGainExpression = gainExp;
                    obj.TableDefinitionTableData = schGainName;
                case 17
                    obj.ScatteredGainName              = scattGainName;
                    obj.ScatteredGainDisplayString     = gainStr;
                    obj.ScatteredGainExpression        = gainExp; 
                    obj.TableDefinitionTableData       = schGainName; 
                    obj.NumberOfDimensions             = numOfDim;
                    obj.BreakPoints1ValueDisplayString = bp1ValueStr;
                    obj.BreakPoints2DisplayString      = bp2Str;
                    obj.BreakPoints2Expression         = bp2Exp;
                    obj.TableDefinitionBreakPoints1    = tblBp1Name;
                    obj.TableDefinitionBreakPoints2    = tb2Bp1Name; 
                    obj.FitType                        = fitType;  
                    obj.FittingRange                   = fitRange;
                    obj.UserDefinedBreakPoints         = userBp;
                    obj.PolyDegreeValue                = poly1;
                    obj.IncludedInFit                  = includedInFit;
                    
                    obj.ScatteredGains = scatteredGains;
                    obj.BreakPoints2ValuesDisplayString = bp2val_dispStr;
%                     setScatteredGains(obj, scatteredGains, bp1NameExp, bp2Exp)
   
            end

            
        end % SchGainVec
        
    end % Constructor

    %% Methods - Property Access
    methods
               
        function y = get.UserDefinedBreakPoints( obj )
            if ischar(obj.UserDefinedBreakPoints)
                y = {obj.UserDefinedBreakPoints};
            else
                y = obj.UserDefinedBreakPoints;
            end
        end % UserDefinedBreakPoints        
        
        function y = get.BreakPoints1( obj )
            temp = str2double(obj.BreakPoints1ValueDisplayString);
            if isnan(temp)
                y = [];
            else
                y = str2double(obj.BreakPoints1ValueDisplayString);
            end
        end % BreakPoints1
        
        function y = get.BreakPoints2( obj )
            y = cell2mat(obj.UserDefinedBreakPoints);
        end % BreakPoints2       
        
    end % Property access methods

    %% Methods - Callbacks
    methods 
 
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 

        function setScatteredGains(obj, scatteredGains, bp1NameExp, bp2Exp)
            scatteredGainsCopy = copy(scatteredGains);
            
            if ~contains(bp1NameExp,'DesignOperatingCondition')  && ...
                ~contains(bp2Exp.AccessString,'DesignOperatingCondition')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).DesignOperatingCondition = lacm.OperatingCondition.empty;
                end
            end
            if ~contains(bp1NameExp,'SynthesisDesignParameter')  && ...
                ~contains(bp2Exp.AccessString,'SynthesisDesignParameter')
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).SynthesisDesignParameter = ScatteredGain.Parameter.empty;
                end
            end
            if ~contains(bp1NameExp,'RequirementDesignParameter')  && ...
                ~contains(bp2Exp.AccessString,'RequirementDesignParameter')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).RequirementDesignParameter = ScatteredGain.Parameter.empty;
                end
            end    
            if ~contains(bp1NameExp,'Filters')  && ...
                ~contains(bp2Exp.AccessString,'Filters')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).Filters = UserInterface.ControlDesign.Filter.empty;
                end
            end        
            
            obj.ScatteredGains = scatteredGainsCopy;
        end % setScatteredGains
        
        function updateDataPoint( obj , val , bp1 , bp2 )
            obj.addBreakpoints1Values(bp1);
            obj.addBreakpoints2Values(bp2);
            for i = 1:length(val)
                ind1 = obj.Breakpoints1Values == bp1(i);
                ind2 = obj.Breakpoints2Values == bp2(i);
                obj.TableData(ind1,ind2) = val(i);
            end
            sortAccending(obj);
        end % updateDataPoint
        
        function y = getGain( obj , value1 , value2 )
            % Clip the data points so they do not extend outside of the
            % specified values
            value1 = clip( value1 , obj.Breakpoints1Values );
            value2 = clip( value2 , obj.Breakpoints2Values );
            %             if obj.Ndim == 2
            %                 y = interp2(obj.Breakpoints2Values,obj.Breakpoints1Values,obj.TableData,value2,value1,'linear');
            %             else
            if isscalar(obj.Breakpoints1Values) && ~isscalar(obj.Breakpoints2Values)
                y = interp1(obj.Breakpoints2Values,obj.TableData,value2,'linear');
            elseif ~isscalar(obj.Breakpoints1Values) && isscalar(obj.Breakpoints2Values)
                y = interp1(obj.Breakpoints1Values,obj.TableData,value1,'linear');
            elseif isscalar(obj.Breakpoints1Values) && isscalar(obj.Breakpoints2Values)
                y = obj.TableData;
            end
            %             end
            
            % Scale the gain output if needed
            
            svar = symvar(obj.GainExpression);
            if ~( length(svar) == 1 ) && ( strcmp(svar{1},obj.GainExpression) )
                if ( length(svar) == 1 ) && ( strcmp(svar{1},obj.ScatteredGainName) )
                    y = eval(strrep(obj.GainExpression, obj.ScatteredGainName, num2str(y,17)));
                else
                    y = strrep(obj.GainExpression, obj.ScatteredGainName, num2str(y,17));
                end
            end
        end % getGain
        
        function [ pfLine1 , pfLine2 , pfLine3 ] = polyfit( obj , scatteredGains , includedInFit )
            
            pfLine1 = struct('XData',{},'YData',{});
            pfLine2 = struct('XData',{},'YData',{});
            %pfLine3 = struct('XData',{},'YData',{});
            
            xData = getXData( obj , obj.ScatteredGains);%scatteredGains );
            yData = getYData( obj , obj.ScatteredGains);%scatteredGains );
            
            Y_vec = [];
            bp_val_vec = [];
            
            xData = xData(obj.IncludedInFit);%includedInFit);
            yData = yData(obj.IncludedInFit);%includedInFit);
            
            if length(obj.FittingRange) > 1 && length(obj.UserDefinedBreakPoints) == 1
                userDefinedBreakPoints = {};
                for i=1:length(obj.FittingRange)
                    fitRange = obj.FittingRange{i};
                    userDefinedBreakPoints{i} = obj.UserDefinedBreakPoints{1}( obj.UserDefinedBreakPoints{1} >= fitRange(1) & obj.UserDefinedBreakPoints{1} <= fitRange(2)); %#ok<AGROW>
                end
            else
                userDefinedBreakPoints = obj.UserDefinedBreakPoints;
                
            end
            
            if ~isempty(obj.FittingRange)
                for ireg = 1:length(obj.FittingRange)
                    % Get polynomial fitting order
                    try
                        polyfit_order_i = obj.PolyDegreeValue(ireg);
                    catch
                        polyfit_order_i = 1;
                    end
                    
                    % Get bp region
                    bp_val_i = userDefinedBreakPoints{ireg};
                    
                    % Get polyfit range
                    polyfit_range_i = obj.FittingRange{ireg};
                    
                    % Get data in polyfit region
                    scaled_gain_i = yData(xData <= polyfit_range_i(2) & ...
                        xData >= polyfit_range_i(1));
                    ipvar_i = xData(xData <= polyfit_range_i(2) & ...
                        xData >= polyfit_range_i(1));
                    
                    % Perform polynomial fit
                    P = polyfit(ipvar_i,scaled_gain_i,polyfit_order_i);
                    
                    % Fit Curve (within max/min polyfitrange
                    Xc1 = linspace(polyfit_range_i(1),polyfit_range_i(2),1000);
                    Yc1 = polyval(P,Xc1);
                    
                    % Scheduled gain at BP
                    Y_i = polyval(P,bp_val_i);
                    Y_vec = [Y_vec,Y_i];
                    bp_val_vec = [bp_val_vec,bp_val_i];
                    
                    pfLine1(ireg) = struct('XData',Xc1,'YData',Yc1);
                    pfLine2(ireg) = struct('XData',ipvar_i,'YData',scaled_gain_i);
                end
                
            else
                bp_val_vec = userDefinedBreakPoints{1};
                
                [xUnique,iA] = unique(xData);
                yUnique = yData(iA);
                
                if length(xUnique)>1
                
                    Y_vec = interp1(xUnique,yUnique,bp_val_vec,'linear','extrap');
                    
             
                    if length(bp_val_vec)>1
                        Xc1 = linspace(bp_val_vec(1),bp_val_vec(end),1000);
                        Yc1 = interp1(xUnique,yUnique,Xc1,'linear','extrap');
                    else
                        Xc1 = linspace(xUnique(1),xUnique(end),1000);
                        Yc1 = interp1(xUnique,yUnique,Xc1,'linear','extrap');
                    end
          
                    
                    pfLine1(1) = struct('XData',Xc1,'YData',Yc1);
                    pfLine2(1) = struct('XData',xData,'YData',yData);
                
                else
                    errordlg(['At least two distinct independent variable points need to used.'],'Gain Schedule');
                    return;
                end
            end
            
            pfLine3 = struct('XData',bp_val_vec,'YData',Y_vec);

            obj.ScheduledGain = Y_vec;
            obj.IsScheduled = true;
            obj.Line1 = pfLine1;
            obj.Line2 = pfLine2;
            obj.Line3 = pfLine3;
            
            
            
            
            
            
            %bp2Value = str2num(obj.BP1ValueString)*ones(1,length(bp_val_vec)); %#ok<ST2NM>
            %obj.PlottedGain = struct('Gain',num2cell(Y_vec),'BP1',num2cell(bp2Value),'BP2',num2cell(bp_val_vec));
        end % polyfit
        
        function y = eq( A , B )
            if length(A) == length(B)
                if strcmp( A.BreakPoints1ValueDisplayString , B.BreakPoints1ValueDisplayString )
                    y = true;
                else
                    y = false;
                end
            elseif length(A) == 1 && length(B) > 1
                for i = 1:length(B)
                    if strcmp( A.BreakPoints1ValueDisplayString,B(i).BreakPoints1ValueDisplayString )
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if strcmp( A(i).BreakPoints1ValueDisplayString,B.BreakPoints1ValueDisplayString )
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            else
                y = false;
            end
        end % eq
        
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DesignOperatingCondition object
            % cpObj.DesignOperatingCondition = copy(obj.DesignOperatingCondition);
        end
    end
    
    %% Methods - Private
    methods ( Access = private )
        
        function addBreakpoints1Values( obj , val )           
            if ischar(val)
                newPoints = eval(val);
            elseif iscellstr(val)
                newPoints = cellfun(@(x) str2double(x),val);
            else
                newPoints = val;
            end  
            addPoints = unique(newPoints);
            addPoints = setdiff(addPoints,obj.Breakpoints1Values);  
            origBP1L = length(obj.Breakpoints1Values);
            obj.Breakpoints1Values = [obj.Breakpoints1Values,addPoints];  
            newBP1L = length(obj.Breakpoints1Values);
            initialNaN = nan( newBP1L - origBP1L , length(obj.Breakpoints2Values));
            obj.TableData = [obj.TableData;initialNaN];
        end % addBreakpoints1Values
        
        function addBreakpoints2Values( obj , val )
            if ischar(val)
                newPoints = eval(val);
            elseif iscellstr(val)
                newPoints = cellfun(@(x) str2double(x),val);
            else
                newPoints = val;
            end
            addPoints = unique(newPoints);
            addPoints = setdiff(addPoints,obj.Breakpoints2Values);   
            origBP2L = length(obj.Breakpoints2Values);
            obj.Breakpoints2Values = [obj.Breakpoints2Values,addPoints];
            newBP2L = length(obj.Breakpoints2Values); 
            initialNaN = nan( length(obj.Breakpoints1Values) , newBP2L - origBP2L );
            obj.TableData = [obj.TableData,initialNaN];
        end % addBreakpoints2Values 
        
        function obj = sortAccending(obj)
            
            %dim = ndims(obj.TableData);
%             switch obj.Ndim
%                 case 1
                    [B,IX] = sort(obj.Breakpoints1Values);
                    obj.Breakpoints1Values = B;
                    obj.TableData = obj.TableData(IX);
%                 case 2
%                     % Sort 1 dim
%                     [B1,I1] = sort(obj.Breakpoints1Values);
%                     obj.Breakpoints1Values = B1;
%                     obj.TableData = obj.TableData(I1,:);
%                     % Sort 2 dim
%                     [B2,I2] = sort(obj.Breakpoints2Values);
%                     obj.Breakpoints2Values = B2;
%                     obj.TableData = obj.TableData(:,I2);
%             end
        end % sortAccending
        
        function y = getXData( obj , scatteredGains ) 
            y = [];
            if ~isempty(obj.BreakPoints2Expression)
                for i = 1:length(scatteredGains)
                    y(i) = eval( getString(obj.BreakPoints2Expression,'scatteredGains(i).') );
                    %y(i) = eval(['scatteredGains(i).', obj.BreakPoints2Expression]);
                end
            end
        end % getXData
        
        function y = getYData( obj , scatteredGains )
            y = [];
            if ~isempty(obj.ScatteredGainExpression)
                for i = 1:length(scatteredGains)
                    y(i) = eval( getString(obj.ScatteredGainExpression,'scatteredGains(i).') );
                   % y(i) = eval(['scatteredGains(i).',obj.ScatteredGainExpression]);
                end
            end
        end % getYData
        
    end
    
    %% Methods - Static
    methods (Static)

    end
end

function value = clip( value, clip )
    if length(clip) > 1
        value(max(clip) < value) = max(clip);
        value(value < min(clip)) = min(clip);
    else
        value = clip;
    end
end %clip

