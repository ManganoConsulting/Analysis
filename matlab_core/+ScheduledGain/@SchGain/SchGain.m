classdef SchGain < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties  
        SchGainVec = ScheduledGain.SchGainVec.empty
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        GainFitTableData = {'1','[0,1]';'','';'','';'','';'','';}
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true)
        Ndim
        Complete
        Initialized
        
        BreakPoints1Name
        Breakpoints1Values
        BreakPoints2Name
        Breakpoints2Values
        TableData
        
        ScatteredGainName
        
        
        BreakPoints1String
        BreakPoints2String
        GainExpression
        BreakpointsExpression
        
        SortOrderBreakPoints1
        SortOrderBreakPoints2
        
        Breakpoints2ValueDisplayStr
    end % Dependant properties
    

    %% Dependant properties SetAccess = private
    properties (Dependent = true )
        Name
    end
    
    %% View Properties
    properties( Hidden = true , Transient = true )

    end

    %% Private Properties
    properties( Access = private )
        PrivateName
    end 
    
    %% Methods - Constructor
    methods   
        
        function obj = SchGain( varargin )
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'SchGainVec',ScheduledGain.SchGainVec.empty);
            addParameter(p,'Name','',@ischar);

            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            obj.SchGainVec = options.SchGainVec;
            obj.Name = options.Name;
            
%             switch nargin
%                 case 0
%                 case 1
%                     if isa(schGainName,'ScheduledGain.SchGainVec')          
%                         obj.SchGainVec = schGainName; 
%                     else
%                        error('If only 1 inputs is specified is must be of the class ScatteredGain.SchGain.Vec'); 
%                     end
%             end
        end % SchGain
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function set.Name( obj , x )
            if ~isempty(obj.SchGainVec)
                obj.PrivateName = x;
            elseif strcmp( x , obj.SchGainVec(1).TableDefinitionTableData )
                obj.PrivateName = x;
            elseif isempty(x)
                obj.PrivateName = obj.SchGainVec(1).TableDefinitionTableData;
            else
                error('ScheduledGain:NameConflict','Cannot set ''Name'' because it conflicts with the name of an existing SchNameVec.');
            end
        end % Set - Name
        
        function y = get.Name( obj )  
            if isempty(obj.PrivateName)
                y = obj.SchGainVec(1).TableDefinitionTableData;  
                if isempty(y)
                    y = [obj.SchGainVec(1).ScatteredGainName,'Sch'] ;
                end
            else
                y = obj.PrivateName;
            end
            
        end % Get - Name
        
        function y = get.BreakPoints1String( obj )   
%             y = obj.SchGainVec(1).BreakPoints1NameDisplayString;    
            y = obj.SchGainVec(1).TableDefinitionBreakPoints1;
        end % BreakPoints1String
        
        function y = get.BreakPoints2String( obj )   
            y = obj.SchGainVec(1).BreakPoints2DisplayString;      
        end % BreakPoints2String 
        
        function y = get.GainExpression( obj )   
            y = obj.SchGainVec(1).ScatteredGainDisplayString;      
        end % GainExpression 
        
        function y = get.BreakpointsExpression( obj )   
            y = obj.SchGainVec(1).BreakPoints2DisplayString;      
        end % BreakpointsExpression  
        
        function y = get.TableData( obj )   
            tempData = vertcat(obj.SchGainVec.ScheduledGain);
            if isempty(tempData)
                y = [];
            else
                % Sort 1 dim
                if obj.SchGainVec(1).NumberOfDimensions == 2
                    [~,I1] = sort([obj.SchGainVec.BreakPoints1]);
                    tempData = tempData(I1,:);
                end
                % Sort 2 dim
                [~,I2] = sort(obj.SchGainVec(1).BreakPoints2);
                y = tempData(:,I2); 
            end
        end % TableData
        
        function y = get.ScatteredGainName( obj )   
            y = obj.SchGainVec(1).ScatteredGainName;      
        end % ScatteredGainName
        
        function y = get.BreakPoints1Name( obj )   
            y = obj.SchGainVec(1).TableDefinitionBreakPoints1;      
        end % BreakPoints1Name
        
        function y = get.Breakpoints1Values( obj )   
            y = sort([obj.SchGainVec.BreakPoints1]);  
        end % Breakpoints1Values 
        
        function y = get.SortOrderBreakPoints1( obj )   
            [ ~ , y ] = sort([obj.SchGainVec.BreakPoints1]);  
        end % SortOrderBreakPoints1 
        
        function y = get.BreakPoints2Name( obj )   
            y = obj.SchGainVec(1).TableDefinitionBreakPoints2;      
        end % BreakPoints2Name
        
        function y = get.Breakpoints2Values( obj )   
            y = sort(obj.SchGainVec(1).BreakPoints2);       
        end % Breakpoints2Values  
        
        function y = get.SortOrderBreakPoints2( obj )   
            [ ~ , y ] = sort(obj.SchGainVec(1).BreakPoints2);   
        end % SortOrderBreakPoints2 
        
        function y = get.Breakpoints2ValueDisplayStr( obj )   
            y = obj.SchGainVec(1).BreakPoints2ValuesDisplayString;       
        end % Breakpoints2Values  
        
        function y = get.Ndim( obj )
            
            if isvector( obj.TableData ) || isempty(obj.Breakpoints1Values)
                y = 1;
            else 
                y = 2;
            end
                
        end % Ndim
               
        function y = get.Complete( obj )
            if isempty(obj.TableData)
                y = false;
            else
                y = ~any(any(isnan(obj.TableData)));
            end
        end % Complete
        
        function y = get.Initialized( obj )
            if isempty(obj.Breakpoints1Values) && isempty(obj.Breakpoints2Values)
                y = false;
            else
                y = true;
            end
        end % Initialized     
        
        function set.BreakPoints1Name( obj , x )  
            for i = 1:length(obj.SchGainVec)
                obj.SchGainVec(i).TableDefinitionBreakPoints1 = x;  
            end
        end % BreakPoints1Name
        
        function set.Breakpoints1Values( obj , x )   
            for i = 1:length(obj.SchGainVec)
                obj.SchGainVec(i).BreakPoints1ValueDisplayString = x; 
            end
        end % Breakpoints1Values 
                
        function set.BreakPoints2Name( obj , x )   
            for i = 1:length(obj.SchGainVec)
                obj.SchGainVec(i).TableDefinitionBreakPoints2 = x; 
            end
        end % BreakPoints2Name
        
        function set.Breakpoints2Values( obj , x ) 
            for i = 1:length(obj.SchGainVec)
                obj.SchGainVec(i).UserDefinedBreakPoints = x;   
            end
        end % Breakpoints2Values  
        
        
    end % Property access methods

    %% Methods - Callbacks
    methods 
 
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        function createSimulinkBlock( obj )
            switch obj.Ndim
                case 1
                    
                    if length(obj.Breakpoints1Values) == 1
                        bpValues = obj.Breakpoints2Values;
                        bpName   = obj.BreakPoints2Name;
                        bpPath   = obj.BreakPoints2String;
                    else
                        bpValues = obj.Breakpoints1Values;
                        bpName   = obj.BreakPoints1Name;
                        bpPath   = obj.BreakPoints1String;
                    end
                    
                    
                    try
                        h = new_system( [obj.Name,'_LookupTable'], 'ErrorIfShadowed'); 
                    catch
                        button = questdlg([obj.Name,' exists on the path. Do you want to overwrite?'],...
                        'Overwrite?','Yes','No','No');
                        if strcmp(button,'Yes')
                           h = new_system( [obj.Name,'_LookupTable']); 
                        elseif strcmp(button,'No')
                           return;
                        end
                    end
                    open_system(h);
                    sysName = get_param(h,'Name');
                    
                    
                    inputs = symvar(bpPath);
                    
                    for i = 1:length(inputs)
                        inportPath{i} = [sysName,'/',inputs{i}];
                        inport(i)     = add_block('simulink/Sources/In1', inportPath{i},'Position', [ 35 , 3 + (35*i) , 65 , 17 + (35*i) ]);
                    end
                    
                    outportPath = [sysName,'/',obj.ScatteredGainName];
                    outport     = add_block('simulink/Sinks/Out1', outportPath,'Position', [ 700 , 38 , 730 , 52 ]);
                    
                    
                    lookupTableName = [sysName,'/',obj.Name];
                    block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                        'NumberOfTableDimensions','1',...
                                        'BreakpointsForDimension1', bpName ,...
                                        'Table','TableData',...
                                        'InterpMethod','Linear',...
                                        'ExtrapMethod','Clip',...
                                        'Position', [ 370 , 13 , 435 , 77 ]);
                    
                    
                    % Add Scaling for Input               
                    if  ~strcmp(inputs{1},bpPath)     
                        expression = bpPath;
                        for i = 1:length(inputs)
                            expression = strrep(expression, inputs{i}, ['u(',int2str(i),')']);
                        end
                        inputScalePath = [sysName,'/Input Scaling'];
                        inputScale     = add_block('simulink/User-Defined Functions/Fcn', inputScalePath,'Position', [ 175 , 33 , 320 , 57 ]);  
                        set_param(inputScale,'ShowName','off');
                        set_param(inputScale,'Expression',expression); 
                        inputScaleMuxPath = [sysName,'/Mux'];
                        inputScaleMux  = add_block('simulink/Signal Routing/Mux', inputScaleMuxPath,'Position', [ 125 , 26 , 130 , 64 ]); 
                        set_param(inputScaleMux,'ShowName','off');
                        set_param(inputScaleMux,'Inputs',int2str(length(inputs)));
                    else
                        inputScale = [];
                        inputScaleMux = [];
                    end                
                                    
                    % Add Scaling for Gain               
                    if  ~strcmp(obj.ScatteredGainName,obj.GainExpression)
                        if license('test','Symbolic_Toolbox')
                            % Find the inverse of a function
                            expression = Utilities.findInverse(obj.GainExpression);
                            expression = strrep(expression, obj.ScatteredGainName, 'u(1)');
                            gainScalePath = [sysName,'/Gain Scaling'];
                            gainScale     = add_block('simulink/User-Defined Functions/Fcn', gainScalePath,'Position', [ 500 , 33 , 645 , 57 ]);       
                            set_param(gainScale,'ShowName','off');
                            set_param(gainScale,'Expression',expression); 
                        else
                            gainScale = [];
                            warning('The Mathworks Symbolic Math toolbox is needed to automaticly add the inverse gain expression.  Please add this block manually.');
                        end
                    else
                        gainScale = [];
                    end                  
                    
                    
                    
                    % Connect Lines
                    if  ~strcmp(inputs{1},bpPath) 
                        for i = 1:length(inportPath)
                            add_line(sysName,[inputs{i},'/1'],['Mux/',int2str(i)]);
                        end
                        add_line(sysName,'Mux/1','Input Scaling/1');   
                        add_line(sysName,'Input Scaling/1',[obj.Name,'/1']); 
                    else
                        add_line(sysName,[inputs{1},'/1'],[obj.Name,'/1']);
                    end
                    
                    if  ~strcmp(obj.ScatteredGainName,obj.GainExpression) 
                        add_line(sysName,[obj.Name,'/1'],'Gain Scaling/1');   
                        add_line(sysName,'Gain Scaling/1',[obj.ScatteredGainName,'/1']); 
                    else
                        add_line(sysName,[obj.Name,'/1'],[obj.ScatteredGainName,'/1']);
                    end     
                    
                    
                    blocks = [inport,inputScale,inputScaleMux,block,gainScale,outport];
                    Simulink.BlockDiagram.createSubSystem(blocks)
                    
                    set_param([sysName,'/Subsystem'],'Name',obj.Name);
                    set_param([sysName,'/',obj.Name],'Position',[ 295 , 17 , 435 , 73 ]);
                    
                    maskObj = Simulink.Mask.create([sysName,'/',obj.Name]);
                    
                    str1 = [bpName,' = ',mat2str(bpValues)];
                    str2 = ['TableData = ',mat2str(obj.TableData)];
                    maskObj.Initialization = sprintf([str1,'\n',str2]);
                                              
                case 2
                                          
                    try
                        h = new_system( [obj.Name,'_LookupTable'], 'ErrorIfShadowed'); 
                    catch
                        button = questdlg([obj.Name,' exists on the path. Do you want to overwrite?'],...
                        'Overwrite?','Yes','No','No');
                        if strcmp(button,'Yes')
                           h = new_system( [obj.Name,'_LookupTable']); 
                        elseif strcmp(button,'No')
                           return;
                        end
                    end
                    open_system(h);
                    sysName = get_param(h,'Name');
                    
                    inportPath = {};
                    inport = [];
                    % BP 1
                    inputsBP1 = symvar(obj.BreakPoints1String);
                    
                    for i = 1:length(inputsBP1)
                        inportPath{i} = [sysName,'/',inputsBP1{i}];
                        inport(i)     = add_block('simulink/Sources/In1', inportPath{i},'Position', [ 35 , 3 + (35*i) , 65 , 17 + (35*i) ]);
                    end
                    
                    lastPositionInput = get_param(inport(end),'Position');
                    % BP 2
                    inputsBP2 = symvar(obj.BreakPoints2String);
                    
                    for i = 1:length(inputsBP2)
                        if ~any(strcmp(inputsBP2{i},inputsBP1))
                            pos2 = lastPositionInput(2) + 35;
                            pos4 = lastPositionInput(4) + 35;
                            inportPath{end+1} = [sysName,'/',inputsBP2{i}];
                            inport(end+1)     = add_block('simulink/Sources/In1', inportPath{end},'Position', [ 35 , pos2 , 65 , pos4 ]);
                        end
                    end     
                    
                    
                    
                    outportPath = [sysName,'/',obj.ScatteredGainName];
                    outport     = add_block('simulink/Sinks/Out1', outportPath,'Position', [ 700 , 48 , 730 , 62 ]);
                    
                    
                    lookupTableName = [sysName,'/',obj.Name];
                    block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                        'NumberOfTableDimensions','2',...
                                        'BreakpointsForDimension1', [obj.Name,'.',obj.BreakPoints1Name],... %obj.BreakPoints1Name ,...
                                        'BreakpointsForDimension2', [obj.Name,'.',obj.BreakPoints2Name],... %obj.BreakPoints2Name ,...
                                        'Table',[obj.Name,'.TableData'],...%'TableData',...
                                        'InterpMethod','Linear',...
                                        'ExtrapMethod','Clip',...
                                        'Position', [ 375 , 5 , 480 , 105 ]);
                    
                    
                    % Add Scaling for Input BP 1               
                    if  ~strcmp(inputsBP1{1},obj.BreakPoints1String)     
                        expression = obj.BreakPoints1String;
                        for i = 1:length(inputsBP1)
                            expression = strrep(expression, inputsBP1{i}, ['u(',int2str(i),')']);
                        end
                        inputScalePath1 = [sysName,'/Input Scaling BP1'];
                        inputScale1     = add_block('simulink/User-Defined Functions/Fcn', inputScalePath1,'Position', [ 175 , 18 , 320 , 42 ]);  
                        set_param(inputScale1,'ShowName','off');
                        set_param(inputScale1,'Expression',expression); 
                        inputScaleMuxPath1 = [sysName,'/Mux BP1'];
                        inputScaleMux1  = add_block('simulink/Signal Routing/Mux', inputScaleMuxPath1,'Position', [ 135 , 11 , 140 , 49 ]); 
                        set_param(inputScaleMux1,'ShowName','off');
                        set_param(inputScaleMux1,'Inputs',int2str(length(inputsBP1)));
                    else
                        inputScale1 = [];
                        inputScaleMux1 = [];
                    end              
                    
                    % Add Scaling for Input BP 2               
                    if  ~strcmp(inputsBP2{1},obj.BreakPoints2String)     
                        expression = obj.BreakPoints2String;
                        for i = 1:length(inputsBP2)
                            expression = strrep(expression, inputsBP2{i}, ['u(',int2str(i),')']);
                        end
                        inputScalePath2 = [sysName,'/Input Scaling BP2'];
                        inputScale2     = add_block('simulink/User-Defined Functions/Fcn', inputScalePath2,'Position', [ 175 , 68 , 320 , 92 ]);  
                        set_param(inputScale2,'ShowName','off');
                        set_param(inputScale2,'Expression',expression); 
                        inputScaleMuxPath2 = [sysName,'/Mux BP2'];
                        inputScaleMux2  = add_block('simulink/Signal Routing/Mux', inputScaleMuxPath2,'Position', [ 135 , 61 , 140 , 99 ]); 
                        set_param(inputScaleMux2,'ShowName','off');
                        set_param(inputScaleMux2,'Inputs',int2str(length(inputsBP2)));
                    else
                        inputScale2 = [];
                        inputScaleMux2 = [];
                    end  
                                    
                    % Add Scaling for Gain               
                    if  ~strcmp(obj.ScatteredGainName,obj.GainExpression)
                        if license('test','Symbolic_Toolbox')
                            % Find the inverse of a function
                            expression = Utilities.findInverse(obj.GainExpression);
                            expression = strrep(expression, obj.ScatteredGainName, 'u(1)');
                            gainScalePath = [sysName,'/Gain Scaling'];
                            gainScale     = add_block('simulink/User-Defined Functions/Fcn', gainScalePath,'Position', [ 520 , 43 , 665 , 67 ]);       
                            set_param(gainScale,'ShowName','off');
                            set_param(gainScale,'Expression',expression); 
                        else
                            gainScale = [];
                            warning('The Mathworks Symbolic Math toolbox is needed to automaticly add the inverse gain expression.  Please add this block manually.');   
                        end
                    else
                        gainScale = [];
                    end                  
                    
                    
                    
                    % Connect Lines
                    if  ~strcmp(inputsBP1{1},obj.BreakPoints1String)
                        for i = 1:length(inputsBP1)
                            add_line(sysName,[inputsBP1{i},'/1'],['Mux BP1/',int2str(i)]);
                        end
                        add_line(sysName,'Mux BP1/1','Input Scaling BP1/1');   
                        add_line(sysName,'Input Scaling BP1/1',[obj.Name,'/1']); 
                    else
                        add_line(sysName,[inputsBP1{1},'/1'],[obj.Name,'/1']);
                    end
                    
                    if  ~strcmp(inputsBP2{1},obj.BreakPoints2String)
                        for i = 1:length(inputsBP2)
                            add_line(sysName,[inputsBP2{i},'/1'],['Mux BP2/',int2str(i)]);
                        end
                        add_line(sysName,'Mux BP2/1','Input Scaling BP2/1');   
                        add_line(sysName,'Input Scaling BP2/1',[obj.Name,'/2']); 
                    else
                        add_line(sysName,[inputsBP2{1},'/1'],[obj.Name,'/2']);
                    end  
                    
                    
                    if  ~strcmp(obj.ScatteredGainName,obj.GainExpression) 
                        add_line(sysName,[obj.Name,'/1'],'Gain Scaling/1');   
                        add_line(sysName,'Gain Scaling/1',[obj.ScatteredGainName,'/1']); 
                    else
                        add_line(sysName,[obj.Name,'/1'],[obj.ScatteredGainName,'/1']);
                    end     
                    
                    
                    blocks = [inport,inputScale1,inputScale2,inputScaleMux1,inputScaleMux2,block,gainScale,outport];
                    Simulink.BlockDiagram.createSubSystem(blocks)
                    
                    set_param([sysName,'/Subsystem'],'Name',obj.Name);
                    set_param([sysName,'/',obj.Name],'Position',[ 295 , 17 , 435 , 73 ]);
                    
%                     maskObj = Simulink.Mask.create([sysName,'/',obj.Name]);
%                     
%                     str1 = [obj.BreakPoints1Name,' = ',mat2str(obj.Breakpoints1Values)];
%                     str2 = [obj.BreakPoints2Name,' = ',mat2str(obj.Breakpoints2Values)];
%                     str3 = ['TableData = ',mat2str(obj.TableData)];
%                     maskObj.Initialization = sprintf([str1,'\n',str2,'\n',str3]);
            end
        end % createSimulinkBlock
        
        function createSimulinkBlocks( obj )
            
            try
                h = new_system( ['LookupTable'], 'ErrorIfShadowed'); 
            catch
                button = questdlg([obj.Name,' exists on the path. Do you want to overwrite?'],...
                'Overwrite?','Yes','No','No');
                if strcmp(button,'Yes')
                   h = new_system( [obj.Name,'_LookupTable']); 
                elseif strcmp(button,'No')
                   return;
                end
            end
            open_system(h);
            sysName = get_param(h,'Name');  
            
            for i = 1:length(obj) 
                switch obj(i).Ndim
                    case 1

                        lookupTableName = [sysName,'/',obj(i).Name];
                        block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                            'NumberOfTableDimensions','1',...
                                            'BreakpointsForDimension1', [obj(i).Name,'.',obj(i).BreakPoints2Name] ,...
                                            'Table','TableData',...
                                            'InterpMethod','Linear',...
                                            'ExtrapMethod','Clip',...
                                            'Position', [ 370 , 13 , 435 , 77 ]);






                    case 2

                        lookupTableName = [sysName,'/',obj(i).Name];
                        block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                            'NumberOfTableDimensions','2',...
                                            'BreakpointsForDimension1', [obj(i).Name,'.',obj(i).BreakPoints1Name],... %obj(i).BreakPoints1Name ,...
                                            'BreakpointsForDimension2', [obj(i).Name,'.',obj(i).BreakPoints2Name],... %obj(i).BreakPoints2Name ,...
                                            'Table',[obj(i).Name,'.TableData'],...%'TableData',...
                                            'InterpMethod','Linear',...
                                            'ExtrapMethod','Clip',...
                                            'Position', [ 375 , 5 , 480 , 105 ]);
                    
                end
            end
            
            
        end % createSimulinkBlock
        
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
        
        function updateBreakpoints( obj , bp )
            
        end % updateBreakpoints
        
        function y = getGain( obj , value1 , value2 )
            % Clip the data points so they do not extend outside of the
            % specified values
            value1 = clip( value1 , obj.Breakpoints1Values );
            value2 = clip( value2 , obj.Breakpoints2Values );
            if obj.Ndim == 2
                y = interp2(obj.Breakpoints2Values,obj.Breakpoints1Values,obj.TableData,value2,value1,'linear');
            else
                if isscalar(obj.Breakpoints1Values) && ~isscalar(obj.Breakpoints2Values)
                    y = interp1(obj.Breakpoints2Values,obj.TableData,value2,'linear');
                elseif ~isscalar(obj.Breakpoints1Values) && isscalar(obj.Breakpoints2Values)
                    y = interp1(obj.Breakpoints1Values,obj.TableData,value1,'linear');
                elseif isscalar(obj.Breakpoints1Values) && isscalar(obj.Breakpoints2Values)
                    y = obj.TableData;
                end
            end
            
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
        
        function y = eq( A , B )
            if isa(A,'ScheduledGain.SchGain') && isa(B,'ScheduledGain.SchGainVec')
                y = A.SchGainVec == B;
            elseif isa(A,'ScheduledGain.SchGain') && isa(B,'ScheduledGain.SchGain')
                if length(A) == length(B)
                    if length(A.SchGainVec) == length(B.SchGainVec)
                        if all(A.SchGainVec == B.SchGainVec)
                            y = true;
                        else 
                            y = false;
                        end  
                    else 
                        y = false;
                    end
                elseif length(A) == 1 && length(B) > 1
                    for i = 1:length(B)
                        if length(A.SchGainVec) == length(B(i).SchGainVec)
                            if all(A.SchGainVec == B(i).SchGainVec)
                                y(i) = true;
                            else 
                                y(i) = false;
                            end  
                        else 
                            y(i) = false;
                        end
                    end
                elseif length(A) > 1 && length(B) == 1
                    for i = 1:length(A)
                        if length(A(i).SchGainVec) == length(B.SchGainVec)
                            if all(A(i).SchGainVec == B(i).SchGainVec)
                                y(i) = true;
                            else 
                                y(i) = false;
                            end  
                        else 
                            y(i) = false;
                        end
                    end
                end  
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
            switch obj.Ndim
                case 1
                    [B,IX] = sort(obj.Breakpoints1Values);
                    obj.Breakpoints1Values = B;
                    obj.TableData = obj.TableData(IX);
                case 2
                    % Sort 1 dim
                    [B1,I1] = sort(obj.Breakpoints1Values);
                    obj.Breakpoints1Values = B1;
                    obj.TableData = obj.TableData(I1,:);
                    % Sort 2 dim
                    [B2,I2] = sort(obj.Breakpoints2Values);
                    obj.Breakpoints2Values = B2;
                    obj.TableData = obj.TableData(:,I2);
            end
        end % sortAccending
        
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