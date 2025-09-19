classdef RequirementTypeOne < Requirements.Requirement 
    
    %% Public properties
    properties
        
        XLim                                    % limit of the x-axis
        YLim                                    % limit of the y-axis
        PatchXData                              % x values of the patch object
        PatchYData                              % y values of the patch object
        PatchFaceColor = {[ 1,0.898,0.898 ]}    % Color associated with the face of the patch data
        PatchEdgeColor = {[ 0,0,0 ]}            % Color associated with the edge of the patch data
        XLabel                                  % label of the x axis
        YLabel                                  % label of the y axis
        yAxisLocation = 'left'                  % location of the y axis display
        GridFunction                            % method to set up a grid on the axes
        LineStyle     = '-'                     % style of line
        LineWidth     = 0.5                      % style of line
        Marker        = 'none'                  % marker symbol
        MarkerSize    = 6                       % marker size
        Grid          = 1                       % show grid
        XScale        = 'linear'                % x axis scaling
        YScale        = 'linear'                % x axis scaling
        
        PatchLabel                              % cell array of Patch Labels
        PatchLabelLoc                           % cell array of Position Coordinates for the PatchLabel Property
        
    end % Public properties
   
    %% Public Observable properties
    properties  (SetObservable) 

        OutputDataIndex = 1;        % output index number to use
        
        RequiermentPlot
        BackgroundPlotFunc
        
        IterativeRequierment = false
        
        

    end % Public properties 
    
    %% Hidden Properties
    properties (Hidden = true)
        folder           % used only by the tool to store a string of the folder
        plotRefresh = 0  % used only by the tool to determine whether or not to replot the base
        BrowseStartDir = pwd
        IterativePopUpValue = 1
    end % Hidden Properties

    %% Hidden Transient Properties
    properties (Hidden = true , Transient = true )
        axH              % used only by the tool to store a handle to the axes
        lineH            % used only by the tool to store a handle to the axes
        legendH          % used only by the tool to store a handle to the legend
        
    end % Hidden Transient Properties
    
    %% Hidden Transient View Properties
    properties (Hidden = true , Transient = true )       
        Parent
        Container
        EditPanel
        EditGridContainer
        AxisPanel
        ViewMethodPB
        MethodText
        MethodEB
        ViewModelPB
        ViewModelText
        MdlNameEB
        TitleText
        TitleEB
        OutDataIndText
        OutDataIndEB
        ReqPltText
        ReqPltEB
        BkPltText
        BkPltEB
        IterText
        IterEB
        ReqPlotPB
        PlotAxisH
    end % Hidden Transient View Properties
    
    %% Methods - Constructor
    methods  
        function r = RequirementTypeOne(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % requirement 
    end % Constructor
   
    %% Methods - Property Access
    methods
        function set.PatchXData(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchXData = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchXData = {value};
            end
        end % PatchXData
        
        function set.PatchYData(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchYData = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchYData = {value};
            end
        end % PatchYData
        
        function set.PatchFaceColor(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchFaceColor = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchFaceColor = {value};
            end
        end % PatchFaceColor
        
        function set.PatchEdgeColor(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchEdgeColor = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchEdgeColor = {value};
            end
        end % PatchEdgeColor
        
    end % Methods - Property Access
    
    %% Methods - Ordinary
    methods
    
        function handle = getGridFunctionHandle(obj)
            handle = [];
            if ~isempty(obj.GridFunction)
                handle = str2func(obj.GridFunction);
            end
        end % getGridFunctionHandle

        function obj = plotLine(obj,data,rgb)
            % get handle to the function
            funHandle = obj.getFunctionHandle;
            % determine the number of output arguments
            numOutArg = nargout(funHandle);

            % call the function and return data
            switch numOutArg
                case 2
                    [Y,Y] = funHandle(data,obj.MdlName);

                case 3
                    [X,Y,mrk] = funHandle(data,obj.MdlName); 
                    % plot markers and add legend
                    for i = 1:length(mrk) 
                        obj.lineH(end+1) = line(mrk(i).x,mrk(i).y,...
                            'Parent',obj.axH,...
                            'Color',rgb,...
                            'Marker',mrk(i).Marker,...
                            'MarkerSize',mrk(i).MarkerSize,...
                            'MarkerEdgeColor',mrk(i).MarkerEdgeColor,... 
                            'MarkerFaceColor',mrk(i).MarkerFaceColor);
                    end
                    if any(arrayfun(@(x) ~isempty(x.LegendTitle),mrk))
%                         legend(obj.axH,obj.lineH,{mrk.LegendTitle},'Location','best' );
                        legObjH = legend(obj.axH,obj.lineH,{mrk.LegendTitle},'Location','best' );
                        set(obj.axH,'UserData',legObjH);
                    end
            end
            if isnumeric(X)
                X = {X};
                Y = {Y};
            end
            % plot the normal X and Y data
            for i = 1:length(X) 
                % plot the data
                obj.lineH(end+1) = line(X{i},Y{i},...
                    'Parent',obj.axH,...
                    'Color',rgb,...
                    'Marker',obj.Marker,...
                    'MarkerSize',obj.MarkerSize,...
                    'MarkerFaceColor',rgb,...
                    'LineStyle',obj.LineStyle,... 
                    'LineWidth',obj.LineWidth);
            end

        end % plotLine
        
        function plotBase(obj,varargin)
            
            switch nargin
                case 1      
                    axisH = obj.axH;
                case 2
                    axisH = varargin{1};
            end
            if isempty(obj.RequiermentPlot)
                if ~isempty(obj.XLim)
                    set(axisH,'XLim',obj.XLim);
                end

                if ~isempty(obj.YLim)
                    set(axisH,'YLim',obj.YLim);
                end

                set(axisH,'XScale',obj.XScale);
                set(axisH,'YScale',obj.YScale);
                set(axisH,'yaxislocation',obj.yAxisLocation);
                set(get(axisH,'Title'),'String',obj.Title, 'Interpreter', 'none'); 
                set(get(axisH,'XLabel'),'String',obj.XLabel, 'Interpreter', 'none');   
                set(get(axisH,'YLabel'),'String',obj.YLabel, 'Interpreter', 'none');

                if obj.Grid
                    grid(axisH,'on');
                else 
                    grid(axisH,'off');
                end


                for i = 1:length(obj.PatchXData)
                    zdata = zeros(size(obj.PatchXData{i}));
                    p = patch(obj.PatchXData{i},obj.PatchYData{i},zdata,'Parent',axisH);
                    set(p,'FaceColor',obj.PatchFaceColor{i});
                    set(p,'EdgeColor',obj.PatchEdgeColor{i});
                    set(axisH,'layer','top');
                end

                if ~isempty(obj.GridFunction)
                    grid(axisH,'off');
                    gridHandle = obj.getGridFunctionHandle; 
                    gridHandle(axisH);
                end
            else
                try
                    funHandle = str2func(obj.RequiermentPlot);
                    funHandle(axisH);
                    set(get(axisH,'Title'),'String',obj.Title, 'Interpreter', 'none'); 
                catch
                    msgbox([obj.RequiermentPlot, ' does not exist on the path or contains an error.']);
                end
            end
            
        end % plotBase
        
        function plotBaseBackground(obj,varargin)
            
            switch nargin
                case 1      
                    axisH = obj.axH;
                case 2
                    axisH = varargin{1};
            end
            if ~isempty(obj.RequiermentPlot)
                funHandle = str2func(obj.RequiermentPlot);
                funHandle(axisH);
            end
            
        end % plotBaseBackground
        
        function obj = deleteLines(obj)
            try
                delete(obj.lineH);
            end
            obj.lineH = [];
        end % deleteLines
        
        function plot(obj,axH)
            if nargin == 1
                fh = figure();
                axH = axes(fh);
            end
            
            obj.plotBase(axH);
            
            plot(obj.PlotData , axH);
            
            if ~all(cellfun(@isempty,{obj.PlotData.DisplayName}))
%                 legObjH = legend(axH,[obj.PlotData.LineH],'Location','best');
%                 set(axH,'UserData',legObjH);
                
                allLineH = [obj.PlotData.LineH];
                [~,uniqueLegStrInd] = unique({obj.PlotData.DisplayName});
                emptyInd = find(cellfun(@isempty,{obj.PlotData.DisplayName}));
                showInd = setdiff(uniqueLegStrInd,emptyInd);
                legObjH = legend(axH,allLineH(showInd),'Location','best');
                set(axH,'UserData',legObjH);
            end
        end % plot
        
        function [mdlParamsCellArray,uniqueMdlNames] = run( obj , axHLL , OperConds ,scattGainObj )
            import UserInterface.ControlDesign.Utilities.*
            mdlParamsCellArray = {};
            uniqueMdlNames = {};
                
                for i = 1:length(obj) % Requirement Loop
                 
                    % Set the plot Visible to ON
                    set(axHLL.get(i-1),'Visible','on');
                    obj(i).plotBase(axHLL.get(i-1));
                    obj(i).axH = axHLL.get(i-1);
                    obj(i).deleteLines;
                    obj(i).PlotData = Requirements.NewLine.empty;
                    %obj(i).PlotData = Requirements.NewLineCollection('AxisProperties',getAxisProperties(obj(i).axH),'PatchObject',findobj(handle(obj(i).axH), 'Type', 'patch'));
                end   

                
                if length(scattGainObj) == 1 && length(OperConds) > 1
                    scattGainObj(1:length(OperConds)) = scattGainObj;    
                end
                
                for selMdlInd = 1:length(OperConds)   
                    
   
                    % Determine the unique Simulink models defined by the selected
                    % requirement objects
                    uniqueMdlNames = getUniqueModels(obj); 
                    % Assign the evlauated user defined parameters to the unique
                    % models
                    
                    % ---- Bug Workaround ???
                    ScatteredGain.Parameter;
                    % -----------------------------------------------------
                    %               Assign Parameters to Model
                    % -----------------------------------------------------
                    modelParams = {};
                    if ~isempty(scattGainObj)
                        for i = 1:length(uniqueMdlNames)
                            modelParams{i} = assignParameters2Model( uniqueMdlNames{i} ,scattGainObj(selMdlInd) );%#ok<AGROW> %assignParameters2Model( uniqueMdlNames{i} , [params,gainParam] );
                        end 
                        mdlParamsCellArray = modelParams;
                        if ~isempty(modelParams)
                            modelParams = Utilities.catstruct( modelParams{:});
                        end
                    end
                    % get all the function names of current stability objects
                    funNames = arrayfun(@(x) x.FunName, obj,'UniformOutput',false);
                    
                    % get all the function names of current stability objects
                    mdlNames = arrayfun(@(x) x.MdlName, obj,'UniformOutput',false);
                    
                    % Join mdlNames & Function Names
                    funmdlNames = strcat(funNames,mdlNames);
                    
                    % find all unique function names
                    [~, ~, uniqueInd] = unique(funmdlNames);
                    % find the number of times to run methodes
                    ii = max(uniqueInd);
                    for i = 1:ii 

                        objArrayInd = find(uniqueInd == i);
                        funHandle = obj(objArrayInd(1)).getFunctionHandle;
                        % determine the number of output arguments
                        numOutArg = nargout(funHandle);
                        switch numOutArg
                            case 1
                                [newLine]    = funHandle( OperConds(selMdlInd) ,obj(objArrayInd(1)).MdlName , modelParams , scattGainObj );
                            case 2
                                [X,Y]     = funHandle( OperConds(selMdlInd) ,obj(objArrayInd(1)).MdlName , modelParams , scattGainObj );
                            case 3
                                [X,Y,mrk] = funHandle( OperConds(selMdlInd) , obj(objArrayInd(1)).MdlName , modelParams , scattGainObj ); 
                        end

                        if numOutArg ~= 1 && isnumeric(X)
                            X = {X};
                            Y = {Y};
                        end

                        for j = 1:length(objArrayInd)
                            outInd = obj(objArrayInd(j)).OutputDataIndex;
                            if numOutArg == 1
                                %----------- Line Type Output -------------
                                for n = 1:length(newLine{outInd}) 


                                    if strcmpi(newLine{outInd}(n).MarkerFaceColor,'None')
                                        newLine{outInd}(n).MarkerEdgeColor = OperConds(selMdlInd).NormalizedColor; 
                                        
%                                         mrkEdgeClr = OperConds(selMdlInd).NormalizedColor;
%                                         mrkFaceClr = newLine{outInd}(n).MarkerFaceColor;    
                                    else
                                        newLine{outInd}(n).MarkerFaceColor = OperConds(selMdlInd).NormalizedColor;
                                        
%                                         mrkEdgeClr = newLine{outInd}(n).MarkerEdgeColor;
%                                         mrkFaceClr = OperConds(selMdlInd).NormalizedColor;
                                    end  
                                    newLine{outInd}(n).Color = OperConds(selMdlInd).NormalizedColor;
                                    obj(objArrayInd(j)).lineH(end+1) = line(...
                                        'XData',newLine{outInd}(n).XData,...
                                        'YData',newLine{outInd}(n).YData,...
                                        'ZData',newLine{outInd}(n).ZData,...
                                        'Parent',obj(objArrayInd(j)).axH,...
                                        'Color',newLine{outInd}(n).Color,...%OperConds(selMdlInd).NormalizedColor,...
                                        'Marker',newLine{outInd}(n).Marker,...
                                        'MarkerSize',newLine{outInd}(n).MarkerSize,...
                                        'MarkerEdgeColor',newLine{outInd}(n).MarkerEdgeColor,...%mrkEdgeClr,... 
                                        'MarkerFaceColor',newLine{outInd}(n).MarkerFaceColor,...%mrkFaceClr,...
                                        'LineStyle',newLine{outInd}(n).LineStyle,... 
                                        'LineWidth',newLine{outInd}(n).LineWidth,... 
                                        'DisplayName',newLine{outInd}(n).DisplayName,...
                                        'UserData',newLine{outInd}(n).UserData );
                                    
                                     
                                end      
                                if ~all(cellfun(@isempty,{newLine{outInd}.DisplayName}))
                                    legObjH = legend(obj(objArrayInd(j)).axH,obj(objArrayInd(j)).lineH,'Location','best');
                                    set(obj(objArrayInd(j)).axH,'UserData',legObjH);
                                end
                                obj(objArrayInd(j)).PlotData = [obj(objArrayInd(j)).PlotData , newLine{outInd}];
                            else
                                newLine = Requirements.NewLine.empty;
                                %--------- Original Type Output -----------
                                if numOutArg == 3
                                    % plot markers and add legend
                                    for n = 1:length(mrk{outInd}) 
                                        
                                        if isfield(mrk{outInd}(n),'MarkerFaceColor')
                                            
                                            obj(objArrayInd(j)).lineH(end+1) = line(mrk{outInd}(n).x,mrk{outInd}(n).y,...
                                                'Parent',obj(objArrayInd(j)).axH,...
                                                'Color',OperConds(selMdlInd).NormalizedColor,...%'Color',colRGB{selMdlInd},...
                                                'Marker',mrk{outInd}(n).Marker,...
                                                'MarkerSize',mrk{outInd}(n).MarkerSize,...
                                                'MarkerEdgeColor',mrk{outInd}(n).MarkerEdgeColor,...
                                                'MarkerFaceColor',mrk{outInd}(n).MarkerFaceColor,...%);
                                                'DisplayName',mrk{outInd}(n).LegendTitle);
                                            newLine(end+1) = Requirements.NewLine('XData',mrk{outInd}(n).x,...
                                                'YData',mrk{outInd}(n).y,...
                                                'Color',OperConds(selMdlInd).NormalizedColor,...
                                                'Marker',mrk{outInd}(n).Marker,...
                                                'MarkerSize',mrk{outInd}(n).MarkerSize,...
                                                'MarkerEdgeColor',mrk{outInd}(n).MarkerEdgeColor,...
                                                'MarkerFaceColor',mrk{outInd}(n).MarkerFaceColor,...%);
                                                'DisplayName',mrk{outInd}(n).LegendTitle);
                                            
                                            if isfield(mrk{outInd}(n),'LineWidth')
                                                set(obj(objArrayInd(j)).lineH(end),'LineWidth',mrk{outInd}(n).LineWidth);
                                            end
                                            
                                        else
                                            
                                            obj(objArrayInd(j)).lineH(end+1) = line(mrk{outInd}(n).x,mrk{outInd}(n).y,...
                                                'Parent',obj(objArrayInd(j)).axH,...
                                                'Color',OperConds(selMdlInd).NormalizedColor,...%'Color',colRGB{selMdlInd},...
                                                'Marker',mrk{outInd}(n).Marker,...
                                                'MarkerSize',mrk{outInd}(n).MarkerSize,...
                                                'MarkerEdgeColor',OperConds(selMdlInd).NormalizedColor,...
                                                'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...%);
                                                'LineWidth',mrk{outInd}(n).LineWidth,...%);
                                                'DisplayName',mrk{outInd}(n).LegendTitle);
                                            newLine(end+1) = Requirements.NewLine('XData',mrk{outInd}(n).x,...
                                                'YData',mrk{outInd}(n).y,...
                                                'Color',OperConds(selMdlInd).NormalizedColor,...
                                                'Marker',mrk{outInd}(n).Marker,...
                                                'MarkerSize',mrk{outInd}(n).MarkerSize,...
                                                'MarkerEdgeColor',OperConds(selMdlInd).NormalizedColor,...
                                                'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...%);
                                                'LineWidth',mrk{outInd}(n).LineWidth,...%);
                                                'DisplayName',mrk{outInd}(n).LegendTitle);
                                        end

                                    end
                                    if any(arrayfun(@(x) ~isempty(x.LegendTitle),mrk{outInd}))    
                                        %legObjH = legend(obj(objArrayInd(j)).axH,obj(objArrayInd(j)).lineH,{mrk{outInd}.LegendTitle},'Location','best');
                                        [legObjH,~,~,~] = legend(obj(objArrayInd(j)).axH,obj(objArrayInd(j)).lineH,{mrk{outInd}.LegendTitle},'Location','best');
                                        set(obj(objArrayInd(j)).axH,'UserData',legObjH);
                                    end
                                    
                                end
                                
                                if iscell(X{outInd})
                                    for k = 1:length(X{outInd})
                                        obj(objArrayInd(j)).lineH(end+1) = line(X{outInd}{k},Y{outInd}{k},...
                                            'Parent',obj(objArrayInd(j)).axH,...
                                            'Color',OperConds(selMdlInd).NormalizedColor,...%'Color',colRGB{selMdlInd},...
                                            'Marker',obj(objArrayInd(j)).Marker,...
                                            'MarkerSize',obj(objArrayInd(j)).MarkerSize,...
                                            'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...%colRGB{selMdlInd},...
                                            'LineStyle',obj(objArrayInd(j)).LineStyle,... 
                                            'LineWidth',obj(objArrayInd(j)).LineWidth,...
                                            'DisplayName','');
                                        newLine(end+1) = Requirements.NewLine('XData',X{outInd}{k},...
                                            'YData',Y{outInd}{k},....
                                            'Color',OperConds(selMdlInd).NormalizedColor,...
                                            'Marker',obj(objArrayInd(j)).Marker,...
                                            'MarkerSize',obj(objArrayInd(j)).MarkerSize,...
                                            'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...
                                            'LineStyle',obj(objArrayInd(j)).LineStyle,... 
                                            'LineWidth',obj(objArrayInd(j)).LineWidth,...
                                            'DisplayName','');
                                    end
                                else
                                    obj(objArrayInd(j)).lineH(end+1) = line(X{outInd},Y{outInd},...
                                        'Parent',obj(objArrayInd(j)).axH,...
                                        'Color',OperConds(selMdlInd).NormalizedColor,...%'Color',colRGB{selMdlInd},...
                                        'Marker',obj(objArrayInd(j)).Marker,...
                                        'MarkerSize',obj(objArrayInd(j)).MarkerSize,...
                                        'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...%colRGB{selMdlInd},...
                                        'LineStyle',obj(objArrayInd(j)).LineStyle,... 
                                        'LineWidth',obj(objArrayInd(j)).LineWidth,...
                                        'DisplayName',''); 
                                    newLine(end+1) = Requirements.NewLine('XData',X{outInd},...
                                        'YData',Y{outInd},...
                                        'Color',OperConds(selMdlInd).NormalizedColor,...
                                        'Marker',obj(objArrayInd(j)).Marker,...
                                        'MarkerSize',obj(objArrayInd(j)).MarkerSize,...
                                        'MarkerFaceColor',OperConds(selMdlInd).NormalizedColor,...
                                        'LineStyle',obj(objArrayInd(j)).LineStyle,... 
                                        'LineWidth',obj(objArrayInd(j)).LineWidth,...
                                        'DisplayName','');    %#ok<*AGROW>
                                end
      
                                obj(objArrayInd(j)).PlotData = [ obj(objArrayInd(j)).PlotData , newLine ];
                            end
                        end
                    end
                end
                close_system({obj.MdlName},0);  

        end % run
        
        function runDynamics( obj , axHLL , OperConds )%, colRGB )
            import UserInterface.ControlDesign.Utilities.*
                % Plot the base plot if new objects are added
                

                % Reset Plot Loop
                for i = 1:length(obj) 
                    % Set the plot Visible to ON
                    set(axHLL.get(i-1),'Visible','on');
                    obj(i).plotBase(axHLL.get(i-1));
                    obj(i).axH = axHLL.get(i-1);
                    obj(i).deleteLines;
                end 
                
                % Initialze all line handles for new operating conditions
                for i = 1:length(OperConds) 
                    OperConds(i).FlightDynLineH = [];
                end
                
                % find all iterative and non-iterative req
                itLA = logical([obj.IterativeRequierment]);
                
                iterObj = obj(itLA);
                nonItObj = obj(~itLA);
                
                
                
                
            % ******* Take care of all iterative req objs *****************
            % *************************************************************

                % get all the function names of objects
                iterFunNames = {iterObj.FunName};%arrayfun(@(x) x.FunName, iterObj,'UniformOutput',false);
                uniqueIterFunNames = unique(iterFunNames);
                for i = 1:length(uniqueIterFunNames) % Method(function) Loop - this loop is only run to execute each method one time only
                    if exist(uniqueIterFunNames{i},'file')
                    
                    funHandle = str2func(uniqueIterFunNames{i}); % only need the function handle to the first one found, since they are all the same
                    logArray = strcmp(uniqueIterFunNames{i},iterFunNames);
                        for operCondInd = 1:length(OperConds) 
                            numOutArg = nargout(funHandle);
                            switch numOutArg
                                case 1
                                    try
                                        newLine = funHandle( OperConds(operCondInd) );
                                        % plot the line
                                        lh = plotLineFD( iterObj(logArray) , newLine , operCondInd );
                                        % store the line handle in operating condition
                                        OperConds(operCondInd).FlightDynLineH = [OperConds(operCondInd).FlightDynLineH,lh];
                                        
                                    catch MExc
                                        error('FlightDynamics:MethodError',['There is an error in the Requierment method ',func2str(funHandle),'.']);
                                    end
                                otherwise
                                    error('FlightDynamics:MethodError',['Only one output is supported in the Requierment method ',func2str(funHandle),'.']);
                            end
                        end
                    end
                end
                
            % ******* Take care of all non-iterative req objs *****************
            % *************************************************************

                % get all the function names of objects
                nonItFunNames = {nonItObj.FunName};%arrayfun(@(x) x.FunName, nonItObj,'UniformOutput',false);
                uniqueNonItFunNames = unique(nonItFunNames);
                for i = 1:length(uniqueNonItFunNames) % Method(function) Loop - this loop is only run to execute each method one time only
                    if exist(uniqueNonItFunNames{i},'file')
                    
                    funHandle = str2func(uniqueNonItFunNames{i}); % only need the function handle to the first one found, since they are all the same
                    logArray = strcmp(uniqueNonItFunNames{i},nonItFunNames);
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            try
                                newLine = funHandle( OperConds );
                                % plot the line
                                plotLineFD( nonItObj(logArray) , newLine , i );
                                % No need to store the line handle for
                                % non-iterative reqs.
                            catch MExc
                                error('FlightDynamics:MethodError',['There is an error in the Requierment method ',func2str(funHandle),'.']);
                            end
                        otherwise
                            error('FlightDynamics:MethodError',['Only one output is supported in the Requierment method ',func2str(funHandle),'.']);
                    end
                    end
                end

        end % runDynamics
        
        function lh = plotLineFD( obj , methOut , ind )
            lh = [];
            for i = 1:length(obj)
                if iscell(methOut)
                    newLine = methOut{obj(i).OutputDataIndex}; % Get the index of the output the corresponds to the output data index.
                else
                    newLine = methOut;
                end
                for j = 1:length(newLine)
                    if isempty(newLine(j).Color)
                        color = getColor(j);
                    else
                        color = newLine(j).Color;
                    end

                    obj(i).lineH(end+1) = line(...
                        'XData',newLine(j).XData,...
                        'YData',newLine(j).YData,...
                        'ZData',newLine(j).ZData,...
                        'Parent',obj(i).axH,...
                        'Color',color,...
                        'Marker',newLine(j).Marker,...
                        'MarkerSize',newLine(j).MarkerSize,...
                        'MarkerEdgeColor',color,...
                        'MarkerFaceColor',color,...
                        'LineStyle',newLine(j).LineStyle,... 
                        'LineWidth',newLine(j).LineWidth,... 
                        'DisplayName',newLine(j).DisplayName,...
                        'UserData',newLine(j).UserData );
                    lh(end+1) = obj(i).lineH(end);
                end
                if ~all(cellfun(@isempty,{newLine.DisplayName}))
                    legObjH = legend(obj(i).axH,obj(i).lineH,'Location','best');
                    set(obj(i).axH,'UserData',legObjH);
                end
            end
        end % plotLineFD
        
        function makeLegend( obj , axH , lhs )
            
            legObjH = legend(axH,lhs,'Location','best');
            set(axH,'UserData',legObjH);
            
        end % makeLegend
        
    end % Ordinary Methods

    %% Methods - View
    methods
        
        function createView( obj , parent )
%             if nargin == 1
%                 
%             else
                obj.Parent = parent;
%             end
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);%,...
                set(obj.Container,'ResizeFcn',@obj.resizeFcn);
                % Edit Panel
                contPosition = getpixelposition(obj.Container);
                obj.EditPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , contPosition(4) - 159 , contPosition(3) , 159],...%[0,0.7,1,0.3],...
                    'ResizeFcn',@obj.editPanelResize);
                
                     obj.EditGridContainer = uigridcontainer('v0','Parent',obj.EditPanel,...
                        'Units','Normal',...
                        'Position',[0,0,1,1],...
                        'GridSize',[7,3],...
                        'HorizontalWeight',[1,3,6]);
                        % Method
                        obj.ViewMethodPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewMethod);
                        obj.MethodText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Method:',...
                            'HorizontalAlignment','Right');
                        obj.MethodEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'FunName'});
                        % Model Name  
                        obj.ViewModelPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewModel);
                        obj.ViewModelText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Model Name:',...
                            'HorizontalAlignment','Right');
                        obj.MdlNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'MdlName'}); 
                        % Title 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.TitleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Title:',...
                            'HorizontalAlignment','Right');
                        obj.TitleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Title'});
                        % Output Data Index
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.OutDataIndText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Output Data Index:',...
                            'HorizontalAlignment','Right');
                        obj.OutDataIndEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'OutputDataIndex'});

                        % Req Plot 
                        obj.ReqPlotPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewReqPlot);
                        obj.ReqPltText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String',' Requirement Plot:',...
                            'HorizontalAlignment','Right');
                        obj.ReqPltEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'RequiermentPlot'});
%                         % Background Plot 
%                         obj.BkGrndPlotPB = uicontrol(...
%                             'Parent',obj.EditGridContainer,...
%                             'Style','push',...
%                             'String','Browse',...
%                             'Callback',@obj.viewBackgroundPlot);
%                         obj.BkPltText = uicontrol(...
%                             'Parent',obj.EditGridContainer,...
%                             'Style','text',...
%                             'String','Backgound Plot:',...
%                             'HorizontalAlignment','Right');
%                         obj.BkPltEB = uicontrol(...
%                             'Parent',obj.EditGridContainer,...
%                             'Style','edit',...
%                             'String','',...
%                             'BackgroundColor',[1 1 1],...
%                             'Callback',{@obj.reqUpdate,'BackgroundPlotFunc'});
                        if ~isControlObject(obj)
                        % Iterative  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.IterText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Iterative:',...
                            'HorizontalAlignment','Right');
                        obj.IterEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','popup',...
                            'String',{'False','True'},...
                            'Value',obj.IterativePopUpValue,...
                            'BackgroundColor',[1 1 1],...
                            'Callback',@obj.iterUpdate_CB);
                        end




           
     
                % Axis Panel       
                obj.AxisPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , 1 , contPosition(3) , contPosition(4) - 159]);
                    set(obj.AxisPanel,'ResizeFcn',@obj.axisPanelResize);     
                    obj.PlotAxisH =axes('Parent',obj.AxisPanel,...
                        'Units', 'Normalized',...
                        'Visible','on',...
                        'OuterPosition', [0 0.05 1 0.95] );
                    
            update(obj);
                      
        end % createView      
        
    end % Methods - View
        
    %% Methods - Protected Callbacks
    methods
        
        function reqUpdate( obj , hobj , ~ , type )
            value = get(hobj,'String');
            testValue = str2double(value);
            if length(testValue) == 1 && isnan(testValue)
                newValue = value;
            else
                newValue = testValue;
%                 try
%                     newValue = eval(value);
%                 catch
%                     newValue = value;
%                 end
            end
            obj.(type) = newValue;

            update(obj);

        end % reqUpdate
                
        function saveReqUpdate( obj , ~ , ~ )
            
            obj.plotRefresh = 1;
            
            filename = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).objPath;
            %eval([filename(1:end-4),'=cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex);']);
            saveVarStruct.(filename(1:end-4)) = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex); %#ok<STRNU>
            filepath = which(filename);
            save(filepath, '-struct','saveVarStruct');
        end % saveReqUpdate       
        
        function viewMethod( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.m'},'Select Method File:',fullfile(obj.BrowseStartDir,obj.FunName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.FunName = file;
                update(obj);
            end
            
        end % viewMethod

        function viewModel( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:',fullfile(obj.BrowseStartDir,obj.MdlName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.MdlName = file;
                update(obj);
            end
            
        end % viewModel
        
        function viewReqPlot( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.m'},'Select Plot File:',fullfile(obj.BrowseStartDir,obj.RequiermentPlot));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.RequiermentPlot = file;
                update(obj);
            end
            
        end % viewReqPlot

        function viewBackgroundPlot( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.m'},'Select Plot File:',fullfile(obj.BrowseStartDir,obj.BackgroundPlotFunc));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.BackgroundPlotFunc = file;
                update(obj);
            end
            
        end % viewBackgroundPlot
        
        function iterUpdate_CB( obj , hobj , ~ )
            obj.IterativePopUpValue = hobj.Value;
            if obj.IterativePopUpValue == 1
                obj.IterativeRequierment = false;
            else 
                obj.IterativeRequierment = true;
            end
            update(obj);
        end % iterUpdate_CB
        
    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        function update( obj )
            obj.MethodEB.String = obj.FunName;
            obj.MdlNameEB.String = obj.MdlName;
            obj.TitleEB.String = obj.Title;
            obj.OutDataIndEB.String = num2str(obj.OutputDataIndex);
            obj.ReqPltEB.String = obj.RequiermentPlot;
            obj.BkPltEB.String = obj.BackgroundPlotFunc;
            obj.IterEB.Value = obj.IterativePopUpValue;

            cla(obj.PlotAxisH,'reset');
            obj.plotBase(obj.PlotAxisH); 
            
        end % update
            
        function editPanelResize( obj , ~ , ~ )
  
        end % editPanelResize
        
        function resizeFcn( obj , ~ , ~ )
            % get figure position
            contPosition = getpixelposition(obj.Container);

            set(obj.EditPanel,'Units','Pixels');
            set(obj.EditPanel,'Position',[1 , contPosition(4) - 159 , contPosition(3) , 159] );
            set(obj.AxisPanel,'Units','Pixels');
            set(obj.AxisPanel,'Position',[1 , 1 , contPosition(3) , contPosition(4) - 159]);   
        end % resizeFcn
        
        function axisPanelResize( obj , ~ , ~ )
    
            % get figure position
            orgUnits = get(obj.AxisPanel,'Units');
            set(obj.AxisPanel,'Units','Pixels');
            panelPos = get(obj.AxisPanel,'Position');
            set(obj.AxisPanel,'Units',orgUnits);
            
            plotAxisRight  = 1;
            plotAxisBottom = 26;
            plotAxisWidth  = panelPos(3);
            plotAxisHeight = panelPos(4) - 27;
            set(obj.PlotAxisH,'Units','Pixels');
            set(obj.PlotAxisH,'OuterPosition',[plotAxisRight, plotAxisBottom ,plotAxisWidth, plotAxisHeight] );
            
%             saveReqUpdateRight  = 3;
%             saveReqUpdateBottom = 3;
%             saveReqUpdateWidth  = 60;
%             saveReqUpdateHeight = 20;
%             set(obj.SaveReqUpdatePB,'Units','Pixels');
%             set(obj.SaveReqUpdatePB,'Position',[saveReqUpdateRight, saveReqUpdateBottom ,saveReqUpdateWidth, saveReqUpdateHeight] );            
  
        end % axisPanelResize
        
        function tf = isControlObject( obj )
            tf = false;
            classType = class(obj);
            if any(strcmp(classType,{'Requirements.Stability','Requirements.FrequencyResponse','Requirements.HandlingQualities','Requirements.Aeroservoelasticity','Requirements.Simulation'}))
                tf = true;
            end
        end % isControlObject
        
    end % Methods - Protected
   
end

function y = getColor(ind)

color = {'b','r','g','k','m','c',[0.5,0.5,0]};
if ind <= 7
    y = color{ind};
else
    y = [rand(1),rand(1),rand(1)];
end

end % getColor





