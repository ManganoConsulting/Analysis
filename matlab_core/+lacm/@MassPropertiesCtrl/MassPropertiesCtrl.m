classdef MassPropertiesCtrl < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties 
        Parameter lacm.ConditionCtrl
        %ParameterVals single
        WeightCode = ""
        Label = ""
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        DummyMode = false
    end % Hidden properties
    
    %% Hidden Properties
    properties (Hidden = true , SetAccess = private )
        Node
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Constant properties
    properties (Hidden = true, Constant) 
%         JavaImage_checked        = checkedIcon();
%         JavaImage_partialchecked = partialCheckIcon();
%         JavaImage_unchecked      = uncheckedIcon(); 
    end % Constant properties 
    
    %% Methods - Constructor
    methods      
        function obj = MassPropertiesCtrl(varargin)
            switch nargin
                case 0
                case 1
                    if exist(varargin{:},'file')
                        
                        
                        %T = readtable(varargin{:})
                        % Open mass properties file
                        fid = fopen(varargin{:},'r');

                        % Read header
                        %hdr = textscan(fid,'%s%s%s%s%s%s',1);%hdr = textscan(fid,'%s%s%s%s%s%s%s%s%s',1);

                        tLine = fgets(fid);
                        hdr = strsplit(strtrim(tLine));
                        ncols = length(hdr);
                        
                        formatstr = repmat(['%s'],[1,ncols]);
                        
                        % Read columns
                        cols = textscan(fid,formatstr);%cols = textscan(fid,'%s%s%s%s%s%s%s%s%s');
                        obj(length(cols{1})) = lacm.MassProperties;
                        
                        
                        for i = 1:length(cols{1})
                            
                            args = {};
                            vars = lacm.Condition.empty;
                            for j = 1:length(cols)
                                if isprop(obj,hdr{j})
                                    args{end+1} = hdr{j};
                                    args{end+1} = cols{j}{i};
                                else
                                    temp = str2double(cols{j}{i});
                                    if isnan(temp)
                                        vars(end+1) = lacm.Condition(hdr{j},cols{j}{i});
                                    else
                                        vars(end+1) = lacm.Condition(hdr{j},temp);
                                    end
                                    
                                end
                            end
                            
                            inputargs = [args,{'Parameter'},{vars}];
                            obj(i) = lacm.MassProperties(inputargs{:});
                        end
                        % Close file
                        fclose(fid);
                    else
                       error('File does not exist'); 
                    end
                otherwise
                    p = inputParser;
                    errorStr = 'Value must be of the class lacm.Condition.';
                    validationFcn = @(x) assert(isa(x,'lacm.Condition'),errorStr);
                    addParameter(p,'WeightCode',0,@ischar);
                    addParameter(p,'Label',0,@ischar);
                    addParameter(p,'Parameter',lacm.Condition.empty,validationFcn);
                    p.KeepUnmatched = true;
                    parse(p,varargin{:});
                    options = p.Results;

                    obj.Parameter  = options.Parameter;
                    obj.WeightCode = options.WeightCode;
                    obj.Label = options.Label;
            end       
        end % MassProperties
    end % Constructor

    %% Methods - Property Access
    methods
   
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
        function [y,ind] = getWC(obj,wc)
           y = lacm.MassProperties.empty;
           ind = [];
           lArray = strcmp(wc,{obj.WeightCode});
           if any(lArray)
               y = obj(lArray);
               ind = find(lArray);
           end 
        end
        
        function dispData = getDisplayData(obj)
            
            propNames = properties(obj);
            dispData = cell(length(propNames),2);
            for i = 1:length(propNames)
                dispData{i,1} = propNames{i};
                if isscalar(obj.(propNames{i})) 
                    if ~ischar(obj.(propNames{i}))  
                        dispData{i,2} = num2str(obj.(propNames{i}),4);
                    else
                        dispData{i,2} = obj.(propNames{i});
                    end
                else
                    dispData{i,2} = class(obj.(propNames{i}));
                end
                
            end    
        end % getDisplayData
        
        function data = getHeaderData(obj)
            if isempty(obj)
                names = {'NA'};
                units = {[]};
                type  = cell(length(names)+1,1);
                type(:) = {'Mass Property'};

%                 [ names , I ] = sort(names);
%                 units = units(I); 

                data = [type,[names,'Weight Code']',[units,'-']'];
            else
                names = {obj.Parameter.Name};
                units = {obj.Parameter.Units};
                type  = cell(length(names)+1,1);
                type(:) = {'Mass Property'};

                [ names , I ] = sort(names);
                units = units(I); 

                data = [type,[names,'Weight Code']',[units,'-']'];     
            end
            
        end % getHeaderData
        
        function data = getStructHeader(obj)
            if isempty(obj)
                names = {'NA'};
                units = {[]};
                type  = cell(length(names)+1,1);
                type(:) = {'Mass Property'};

%                 [ names , I ] = sort(names);
%                 units = units(I); 
                data = struct('Type',type,'Name',[names,'Weight Code']','Units',[units,'-']');
            else
                names = {obj.Parameter.Name};
                units = {obj.Parameter.Units};
                type  = cell(length(names)+1,1);
                type(:) = {'Mass Property'};

                [ names , I ] = sort(names);
                units = units(I); 
                data = struct('Type',type,'Name',[names,'Weight Code']','Units',[units,'-']');
            end
        end % getStructHeader
        
        function data = getTableData(obj)
            if isempty(obj)
                %data = getSortedValue(obj.Parameter);%{obj.Parameter.Value};
                data = {0,'NA'}; 
            else
                data = getSortedValue(obj.Parameter);
                data = [data,obj.WeightCode];     
            end
            
        end % getTableData      
        
        function y = get(obj,name,ocIdx) % Nathan changed
            
            %if strcmp('WeightCode',name) || strcmp('Label',name)
            %    y = obj.(name);         
            if strcmp('WeightCode',name)
                y = char(obj.WeightCode(ocIdx));
            elseif strcmp('Label',name)
                y = char(obj.Label(ocIdx));
            else
                y = obj.Parameter.get(name).Value(ocIdx);
            end
        end % get
        
        function y = eq(A,B)            

            if length(A) == length(B)
                for i = 1:length(A)
                    if length(A(i).Parameter) == length(B(i).Parameter)
                        if isempty(A(i).Parameter) && isempty(B(i).Parameter)
                            y(i) = true;
                        elseif all(A(i).Parameter == B(i).Parameter)% && ...
%                                     Utilities.strcmpEmptys(A(i).WeightCode,B(i).WeightCode)&& ...
%                                     Utilities.strcmpEmptys(A(i).Label,B(i).Label)
                            y(i) = true;
                        else
                            y(i) = false;
                        end
                    else 
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                for i = 1:length(B)
                    if all(A.Parameter == B(i).Parameter)% && ...
%                             Utilities.strcmpEmptys(A.WeightCode,B(i).WeightCode)&& ...
%                             Utilities.strcmpEmptys(A.Label,B(i).Label)
                        
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if all(A(i).Parameter == B.Parameter)% && ...
%                             Utilities.strcmpEmptys(A(i).WeightCode,B.WeightCode)&& ...
%                             Utilities.strcmpEmptys(A(i).Label,B.Label)
                        
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
    
    %% Methods - Protected
    methods (Access = protected)       
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Parameter object
            cpObj.Parameter = copy(obj.Parameter);
        end
    end
    
end

function val = getSortedValue(conds)
    [~,I] = sort({conds.Name});
    
    val = num2cell([conds(I).Value]);
    

end % getSortedValue