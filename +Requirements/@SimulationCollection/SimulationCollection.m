classdef SimulationCollection < Requirements.Requirement 
    
    %% Public properties
    properties
        %SimObjs@Requirements.Simulation = Requirements.Simulation.empty
        SelectedSignals
        OutputSelector
        PostFunName
        
        
        SimulationData = struct('Input',{},'Output',Simulink.SimulationOutput.empty)
        SimViewerProject
        
        AnalysisOperCond
        AnalysisOperCondDisplayText
    end % Public properties
    
    %% Private properties 
    properties (Access = private)  
        PostSimAxisCounter = 0
            
    end % Public properties
    
    %% Public Observable properties
    properties  (SetObservable) 

%         OutputDataIndex = 1;        % output index number to use
%         
%         RequiermentPlot
%         BackgroundPlotFunc             
    end % Public properties
   
    %% Hidden Properties
    properties (Hidden = true)
        folder           % used only by the tool to store a string of the folder
        plotRefresh = 0  % used only by the tool to determine whether or not to replot the base
        BrowseStartDir = pwd
    end % Hidden Properties

    %% Hidden Transient Properties
    properties (Hidden = true , Transient = true )
        axH              % used only by the tool to store a handle to the axes
        lineH            % used only by the tool to store a handle to the axes
        legendH          % used only by the tool to store a handle to the legend
        axHPost
%         lineHPost
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
        ReqPltText
        BkPltText
        IterText
        IterEB
        BkGrndPlotPB
        ReqPlotPB
        
        ViewPostMethodPB
        MethodPostText
        PostMethodEB
    end % Hidden Transient View Properties
    
    %% Events
    events
%         SimulationOutputUpdate
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end % Events
    
    %% Methods - Constructor
    methods  
        function obj = SimulationCollection(funName,title,model)
          if nargin == 3
             obj.FunName = funName;
             obj.Title = title;
             obj.MdlName = model;
          end
          obj.BrowseStartDir = pwd;
        end % requirement 
    end % Constructor
   
    %% Methods - Property Access
    methods
        
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
                set(get(axisH,'Title'),'String',obj.Title); 
                set(get(axisH,'XLabel'),'String',obj.XLabel);   
                set(get(axisH,'YLabel'),'String',obj.YLabel);

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
                funHandle = str2func(obj.RequiermentPlot);
                funHandle(axisH);
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
            
            %obj.plotBase(axH);
            set(get(axH,'XLabel'),'String','Time');   
%             set(get(axH,'YLabel'),'String',obj.YLabel);
            plot(obj.PlotData , axH);
            

        end % plot
        
        function [mdlParamsCellArray,uniqueMdlNames] = run( obj , axHcoll , OperConds ,gains )
            import UserInterface.ControlDesign.Utilities.*
            mdlParamsCellArray = {};
            uniqueMdlNames = {}; 
            
                 
            if length(gains) == 1 && length(OperConds) > 1
                gains(1:length(OperConds)) = gains;    
            end
                
            uniqueMdlNames = getUniqueModels(obj);
            for numObj = 1:length(obj)
                simOutArray = Simulink.SimulationOutput.empty;
                simInputArray = struct('time',{},'signals',{},'name',{});
                
                if ~bdIsLoaded(obj(numObj).MdlName)
                   load_system(obj(numObj).MdlName); 
                end
                
                if ~bdIsLoaded(obj(numObj).MdlName)
                    load_system(obj(numObj).MdlName);
                end
                
                set_param(obj(numObj).MdlName,'FastRestart','on');
                
                for selMdlInd = 1:length(OperConds)
%                     OperConds(selMdlInd).FlightDynLineH = [];  
                    % ---- Bug Workaround ???
                    ScatteredGain.Parameter;
                    % -----------------------------------------------------
                    %               Assign Parameters to Model
                    % -----------------------------------------------------
                    modelParams = {};
                    if ~isempty(gains)
                        modelParams{1} = assignParameters2Model( obj(numObj).MdlName ,gains(selMdlInd), 1 );%modelParams{i} = assignParameters2Model( uniqueMdlNames{i} ,gains(selMdlInd) );%assignParameters2Model( uniqueMdlNames{i} , [params,gainParam] );  
                        mdlParamsCellArray = modelParams;
                        modelParams = Utilities.catstruct( modelParams{:});
                    end

                    funHandle = obj(numObj).getFunctionHandle;
                    % determine the number of output arguments
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            [inputsStruct]    = funHandle( OperConds(selMdlInd) ,obj(numObj).MdlName , modelParams , gains );
                            [simOut,simInput] = obj(numObj).createSimInputs(inputsStruct,obj(numObj).MdlName);
                            simOutArray(end+1)   = simOut; %#ok<AGROW>
                            simInputArray(end+1) = simInput; %#ok<AGROW>
                    end


                end

                status = beep;
                beep('off')
                set_param(obj(numObj).MdlName,'FastRestart','off');
                beep(status);
                
                obj(numObj).SimulationData = struct('Input',simInputArray,'Output',simOutArray);
                
                
                
                %%%%% Testing -- Post Sim Hack %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                try
                    if ~isempty(obj(numObj).PostFunName)
                        newTempFig = figure();
                        axHPostcoll = axes('Parent',newTempFig);   
%                         for idk = 1:length(OperConds)
                            runControlPost( obj(numObj) , axHPostcoll , OperConds , simOutArray , simInputArray );
%                         end
                    end
                catch
                    delete(newTempFig)
                    UserInterface.Utilities.enableDisableFig(gcf, true);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end   
                
            close_system({obj.MdlName},0);  

        end % run

        function runControlPost( obj , axH , OperConds , simOut , simIn )
            import UserInterface.ControlDesign.Utilities.*                
                
                if ~isempty(obj.PostFunName)

                    funHandle = str2func(obj.PostFunName);
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            try
                                newLine = funHandle( OperConds , simOut , simIn  );
                            catch MExc
                                error('FlightControl:MethodError',['There is an error in the Requierment method ',obj(objArrayInd(1)).FunName,'.']);
                            end
                        otherwise
                            error('FlightControl:MethodError',['Only 1 output allowed in the Requierment method ',obj(objArrayInd(1)).FunName,'.']);
                    end
                
                    
                    for axInd = 1:length(newLine)
                        % plot markers and add legend
                        obj.axHPost(end+1) = axH;
                        set(obj.axHPost(end),'Visible','on');
                        
                        setAxisProperties(newLine(axInd),obj.axHPost(end));
                        lineHPost = [];
                        for n = 1:length(newLine(axInd).NewLine) 
                            if isempty(newLine(axInd).NewLine(n).Color)
                                color = getColor(n);
                            else
                                color = newLine(axInd).NewLine(n).Color;
                            end

                            lineHPost(end+1) = line(...
                                'XData',newLine(axInd).NewLine(n).XData,...
                                'YData',newLine(axInd).NewLine(n).YData,...
                                'ZData',newLine(axInd).NewLine(n).ZData,...
                                'Parent',obj.axHPost(end),...
                                'Color',color,...
                                'Marker',newLine(axInd).NewLine(n).Marker,...
                                'MarkerSize',newLine(axInd).NewLine(n).MarkerSize,...
                                'MarkerEdgeColor',color,...
                                'MarkerFaceColor',color,...
                                'LineStyle',newLine(axInd).NewLine(n).LineStyle,... 
                                'LineWidth',newLine(axInd).NewLine(n).LineWidth,... 
                                'DisplayName',newLine(axInd).NewLine(n).DisplayName,...
                                'UserData',newLine(axInd).NewLine(n).UserData );
                        end      
                        if ~all(cellfun(@isempty,{newLine(axInd).NewLine.DisplayName}))
                            legObjH = legend(obj.axHPost(end),lineHPost,'Location','best');
                            set(obj.axHPost(end),'UserData',legObjH);
                        end
                        obj.PostSimAxisCounter = obj.PostSimAxisCounter +1;
                    end
                    
                end
                


        end % runControlPost   
        
        function [mdlParamsCellArray,uniqueMdlNames] = runDynamics( obj , axHcoll , axHPostcoll, OperConds )
            import UserInterface.ControlDesign.Utilities.*
            mdlParamsCellArray = {};
            for i = 1:length(obj)
                obj(i).PostSimAxisCounter = 0;
                obj(i).axHPost = [];
            end

%             postSimAxisCounter = 0;
%             axHPost = [];
%          
            
            
            % Group panels and axis handles together dependant on num of
            % signals assigned to each object.
            availableNumPanels          = length(axHcoll.Panel);
            availableNumSignalsPerPanel = length(axHcoll.Panel(1).Axis);
            for i = 1:length(obj)
                numPanelsNeededPerObject(i)  = ceil( length(obj(i).SelectedSignals) / availableNumSignalsPerPanel ); %#ok<AGROW>
            end
            numOfPanelsNeeded = sum(numPanelsNeededPerObject);
            
            % Error Check
            if numOfPanelsNeeded > availableNumPanels
                error('Too many signals per Simulation Objects exist or more Simulation Objects exists then available axis panels.');
            end
            
            
            ind = 0;
            SignalGroup(length(obj)) = struct('Panel',UserInterface.AxisPanel.empty,'AxH',[]);
            for i = 1:length(obj) % same as number of objects
                
                SignalGroup(i) = struct('Panel',UserInterface.AxisPanel.empty,'AxH',[]);
                for j = 1:numPanelsNeededPerObject(i)
                    ind = ind + 1;
                    SignalGroup(i).Panel(j) = axHcoll.Panel(ind);
                    SignalGroup(i).AxH  = [SignalGroup(i).AxH,axHcoll.Panel(ind).Axis];
                end   
            end
                                   
            
            for i = 1:length(obj)
                % Set the Group Title
                for j = 1:length(SignalGroup(i).Panel)
                    setTitle( SignalGroup(i).Panel(j) , obj(i).Title );
                end
                
                for j = 1:length(obj(i).SelectedSignals) % Requirement Loop
                    if j == length(obj(i).SelectedSignals)
                        set(get(SignalGroup(i).AxH(j),'XLabel'),'String','Time(sec)');   % Time_{s}
                    end
                    set(get(SignalGroup(i).AxH(j),'Title'),'String',obj(i).SelectedSignals(j).Name,'interpreter','none');
                    grid(SignalGroup(i).AxH(j),'on');
                    set(SignalGroup(i).AxH(j),'Visible','on');
                end  
            end

            uniqueMdlNames = getUniqueModels(obj);
%             simDataOut = cell(1,length(obj));
%             simDataInput = cell(1,length(obj));
            
            for numObj = 1:length(obj)
                
                for selMdlInd = 1:length(OperConds)   
                    OperConds(selMdlInd).FlightDynLineH = [];   

                    funHandle = obj(numObj).getFunctionHandle;
                    % determine the number of output arguments
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            [inputsStruct]    = funHandle( OperConds(selMdlInd) );% ,obj(numObj).MdlName , modelParams , gains );
                            [simOut(selMdlInd),simInput(selMdlInd)] = obj(numObj).createSimInputs(inputsStruct,obj(numObj).MdlName); %#ok<AGROW>
                    end
                    if numOutArg == 1

                        %------------------------------------------
                        %   Loop Outports
                        %------------------------------------------

                        outputSignals    = simOut(selMdlInd).get('Outports');
                        signalLogSignals = simOut(selMdlInd).get('SignalLog');

                        newLine = Requirements.NewLine.empty();
                        for ii = 1:length(obj(numObj).SelectedSignals)

                            % ********************************************
                            % **  Temp solution to fix existing stored simulation objs
                            % ********************************************
                            if ~isfield(obj(numObj).SelectedSignals,'Type')
                               [obj(numObj).SelectedSignals(:).Type]=deal('Output');
                            end
                            % ********************************************
                            
                            
                            switch obj(numObj).SelectedSignals(ii).Type
                                case 'Output'
                                    % Extract and plot the signals
                                    sig = outputSignals.getElement(obj(numObj).SelectedSignals(ii).Path,'-blockpath').Values;
                                    linePlotOne(1) = Requirements.NewLine(sig.Time,sig.Data);
                                    linePlotOne(1).Color = getColor(selMdlInd);%'b';
                                    linePlotOne(1).axH= SignalGroup(numObj).AxH(ii);
                                    newLine(end + 1) = linePlotOne; %#ok<AGROW>
                                case 'Input'
                                    [~,y] = fileparts(obj(numObj).SelectedSignals(ii).Path);
                                    time = simInput(selMdlInd).time;
                                    inLogArray = strcmp(y,simInput(selMdlInd).name);
                                    dataStruct = simInput(selMdlInd).signals(inLogArray);
                                    data = dataStruct.values;
                                    linePlot = Requirements.NewLine(time,data);
                                    linePlot.Color = getColor(selMdlInd);%'b';
                                    linePlot.axH= SignalGroup(numObj).AxH(ii);
                                    newLine(end + 1) = linePlot; %#ok<AGROW>
                                case 'Signal'
                                    % Extract and plot the signals                                      
                                    fullPath = obj(numObj).SelectedSignals(ii).Path;
                                    cellPath = strsplit(fullPath,'.');
                                    sig = signalLogSignals.getElement(cellPath{1});
                                    if isempty(sig)
                                        warning(['Signal ',cellPath{1},' cannot be found.']);
                                    else
                                        if length(cellPath) == 1 && isa(sig.Values,'struct')
                                            % Plot all signals in bus
                                            tsObjs = Requirements.SimulationCollection.extractAllSignals( sig.Values );
                                            for tsInd = 1:length(tsObjs)
                                                linePlot = Requirements.NewLine(tsObjs(tsInd).Time,tsObjs(tsInd).Data);
                                                linePlot.Color = getColor(selMdlInd);%'b';
                                                linePlot.axH= SignalGroup(numObj).AxH(ii);
                                                newLine(end + 1) = linePlot; %#ok<AGROW> 
                                            end                                           
                                        else
                                            if ~isstruct(sig.Values)
                                                newSig = sig.Values;
                                            else
                                                newSig = sig.Values.(cellPath{2});
                                                for busInd = 3:length(cellPath) 
                                                    newSig = newSig.(cellPath{busInd});  
                                                end
                                            end
                                            tsObjs = Requirements.SimulationCollection.extractAllSignals( newSig );
                                            for tsInd = 1:length(tsObjs)
                                                linePlot = Requirements.NewLine(tsObjs(tsInd).Time,tsObjs(tsInd).Data);
                                                linePlot.Color = getColor(selMdlInd);%'b';
                                                linePlot.axH= SignalGroup(numObj).AxH(ii);
                                                newLine(end + 1) = linePlot; %#ok<AGROW> 
                                            end  
                                        end
                                    end
                            end  
                            
                        end

                        %----------- Line Type Output -------------
                        for n = 1:length(newLine) 
                            if isempty(newLine(n).Color)
                                color = getColor(selMdlInd);
                            else
                                color = newLine(n).Color;
                            end
                            obj(numObj).lineH(end+1) = line(...
                                'XData',newLine(n).XData,...
                                'YData',newLine(n).YData,...
                                'ZData',newLine(n).ZData,...
                                'Parent',newLine(n).axH,...
                                'Color',color,...
                                'Marker',newLine(n).Marker,...
                                'MarkerSize',newLine(n).MarkerSize,...
                                'MarkerEdgeColor',newLine(n).MarkerEdgeColor,... 
                                'MarkerFaceColor',newLine(n).MarkerFaceColor,...
                                'LineStyle',newLine(n).LineStyle,... 
                                'LineWidth',newLine(n).LineWidth,... 
                                'DisplayName',newLine(n).DisplayName,...
                                'UserData',newLine(n).UserData );
                            OperConds(selMdlInd).FlightDynLineH(end+1) = obj(numObj).lineH(end);
                        end      
                    end
                end 
                
%                 notify(obj,'SimulationOutputUpdate',GeneralEventData(simOut));
                
                % Run Post Sim Method
                runDynamicsPost( obj(numObj) , axHPostcoll , OperConds , simOut , simInput );
                
                obj(numObj).SimulationData = struct('Input',simInput,'Output',simOut);
%                 simDataOut{numObj} = simOut;
%                 simDataInput{numObj} = simInput;
                
            end

            % Send the input and output to the base workspace
%             Utilities.putvar(simOut,simInput); 
            close_system({obj.MdlName},0);  

        end % runDynamics
        
        function mdlParamsCellArray = runDynamicsSV( obj , simViewH , axHPostcoll, OperConds )
            import UserInterface.ControlDesign.Utilities.*
            mdlParamsCellArray = {};
            for i = 1:length(obj)
                obj(i).PostSimAxisCounter = 0;
                obj(i).axHPost = [];
            end
            
            simOutputSV = Simulink.SimulationOutput.empty;
            runLabels = {};
            for numObj = 1:length(obj)
                % Initialize
                simOut = Simulink.SimulationOutput.empty;
                simInput = struct('time',[],'signals',[],'name',{{}});
                
                % Load Model
                load_system(obj(numObj).MdlName);
                set_param(obj(numObj).MdlName,'FastRestart','on');
                for selMdlInd = 1:length(OperConds)   

                    funHandle = obj(numObj).getFunctionHandle;
                    % determine the number of output arguments
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            [inputsStruct]    = funHandle( OperConds(selMdlInd), obj(numObj).MdlName );%, modelParams , gains );
                            if isa(inputsStruct,'Simulink.ConfigSet')
                                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Running ',obj(numObj).Title,' using Trim #',num2str(selMdlInd),' for model: ',obj(numObj).MdlName],'info'));
                                simMode = get_param(obj(numObj).MdlName, 'SimulationMode');
                                set_param(obj(numObj).MdlName,'SimulationMode','Normal');
                                simOut(selMdlInd) = sim(obj(numObj).MdlName, inputsStruct);
                                set_param(obj(numObj).MdlName, 'SimulationMode', simMode);
                            else
                                [simOut(selMdlInd),simInput(selMdlInd)] = obj(numObj).createSimInputs(inputsStruct,obj(numObj).MdlName); 
                            end
                            simOutputSV(end+1) = simOut(selMdlInd); %#ok<AGROW>
                            runLabels{end+1} = [obj(numObj).Title,' | Trim # ',num2str(selMdlInd) ]; %#ok<AGROW>
                        otherwise
                            error('FlightDynamics:MethodError',['The Simulation method ''',obj(numObj).FunName,''' can have only 1 output.']);    
                    end  
                end
                set_param(obj(numObj).MdlName,'FastRestart','off');
          
                % Run Post Sim Method
                try
                    runDynamicsPost( obj(numObj) , axHPostcoll , OperConds , simOut , simInput );
                catch 
                    error('FlightDynamics:MethodError',['Error in post simulation method - ',obj(numObj).PostFunName,'.']);
                end
                
                obj(numObj).SimulationData = struct('Input',simInput,'Output',simOut);      
            end
            runColors       = cell(1,length(runLabels));
            runLabelColors  = cell(1,length(runLabels));
            for i = 1:length(runLabels)
                runColors{i}        = getSimViewerColor(i);
                runLabelColors{i}   = ['<html><font color="rgb(',int2str(runColors{i}(1)),',',int2str(runColors{i}(2)),',',int2str(runColors{i}(3)),')">',runLabels{i},'</font></html>']; 
            end
            updateNewData(simViewH ,simOutputSV , false , 1, runLabelColors, runColors); % Replace Data and update plots with new data with Run Labels
            
            % Send the input and output to the base workspace
%             Utilities.putvar(simOut,simInput); 
            close_system({obj.MdlName},0);  

        end % runDynamicsSV
     
        function runDynamicsPost( obj , axH , OperConds , simOut , simIn )
            import UserInterface.ControlDesign.Utilities.*
 
%                 axH.get(obj.PostSimAxisCounter)
%    
%                 
%                 % Set the plot Visible to ON
%                 set(axH,'Visible','on');
%                 obj.axHPost = axH;
                
                
                
                if ~isempty(obj.PostFunName)

                    funHandle = str2func(obj.PostFunName);
                    numOutArg = nargout(funHandle);
                    switch numOutArg
                        case 1
                            try
                                newLineColl = funHandle( OperConds , simOut , simIn  );
                            catch MExc
                                error('FlightDynamics:MethodError',['There is an error in the Requierment method ',obj.PostFunName,'.']);
                            end
                        otherwise
                            error('FlightDynamics:MethodError',['Only 1 output allowed in the Requierment method ',obj.PostFunName,'.']);
                    end
                
                    
                    for axInd = 1:length(newLineColl)
                        % plot markers and add legend
                        obj.axHPost(end+1) = axH.get(obj.PostSimAxisCounter);
                        set(obj.axHPost(end),'Visible','on');
                        
                        setAxisProperties(newLineColl(axInd),obj.axHPost(end));
                        lineHPost = [];
                        for n = 1:length(newLineColl(axInd).NewLine) 
                            if isempty(newLineColl(axInd).NewLine(n).Color)
                                color = getColor(n);
                            else
                                color = newLineColl(axInd).NewLine(n).Color;
                            end

                            lineHPost(end+1) = line(...
                                'XData',newLineColl(axInd).NewLine(n).XData,...
                                'YData',newLineColl(axInd).NewLine(n).YData,...
                                'ZData',newLineColl(axInd).NewLine(n).ZData,...
                                'Parent',obj.axHPost(end),...
                                'Color',color,...
                                'Marker',newLineColl(axInd).NewLine(n).Marker,...
                                'MarkerSize',newLineColl(axInd).NewLine(n).MarkerSize,...
                                'MarkerEdgeColor',color,...
                                'MarkerFaceColor',color,...
                                'LineStyle',newLineColl(axInd).NewLine(n).LineStyle,... 
                                'LineWidth',newLineColl(axInd).NewLine(n).LineWidth,... 
                                'DisplayName',newLineColl(axInd).NewLine(n).DisplayName,...
                                'UserData',newLineColl(axInd).NewLine(n).UserData );
                        end      
                        if ~all(cellfun(@isempty,{newLineColl(axInd).NewLine.DisplayName}))
                            legObjH = legend(obj.axHPost(end),lineHPost,'Location','best');
                            set(obj.axHPost(end),'UserData',legObjH);
                        end
                        obj.PostSimAxisCounter = obj.PostSimAxisCounter +1;
                    end
                    
                end
                


        end % runDynamicsPost    
        
    end % Ordinary Methods

    %% Methods - View
    methods
        
        function createView( obj , parent )
%             if nargin == 2
%                 savedWrkspace = false;
%             end
            obj.Parent = parent;
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);%,...
                set(obj.Container,'ResizeFcn',@obj.resizeFcn);
                % Edit Panel
                contPosition = getpixelposition(obj.Container);
                obj.EditPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , contPosition(4) - 75 , contPosition(3) , 75],...%[0,0.7,1,0.3],...
                    'ResizeFcn',@obj.editPanelResize);
                
                     obj.EditGridContainer = uigridcontainer('v0','Parent',obj.EditPanel,...
                        'Units','Normal',...
                        'Position',[0,0,1,1],...
                        'GridSize',[4,3],...
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
                        % Post Sim Method
                        obj.ViewPostMethodPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewPostMethod);
                        obj.MethodPostText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Post-Simulation Method:',...
                            'HorizontalAlignment','Right');
                        obj.PostMethodEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'PostFunName'});

            update(obj);
                      
        end % createView      
        
    end % Methods - View
        
    %% Methods - Protected Callbacks
    methods
        
        function updateSimObjs( obj , ~ , eventdata )
            obj.SelectedSignals = eventdata.AffectedObject.SelectedSignals;
            
        end % updateSimObjs
        
        function reqUpdate( obj , hobj , ~ , type )
            value = get(hobj,'String');
            testValue = str2double(value);
            if length(testValue) == 1 && isnan(testValue)
                newValue = value;
            else
                newValue = testValue;
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
        
        function viewPostMethod( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.m'},'Select Post Simulation Method File:',fullfile(obj.BrowseStartDir,obj.PostFunName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.PostFunName = file;
                update(obj);
            end
            
        end % viewPostMethod

        function viewModel( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:',fullfile(obj.BrowseStartDir,obj.MdlName));%fullfile(obj.BrowseStartDir,obj.MdlName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.MdlName = file;
                
                try
                    load_system(obj.MdlName);
                catch
                    try
                    addpath(genpath(pathname));
                    load_system(obj.MdlName);
                    catch
                        error('FlightDynamics:UnableToOpenModel',['The model ''',filename,''' cannot be found']);
                    end
                end
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
        
    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        function update( obj )
            obj.MethodEB.String = obj.FunName;
            obj.MdlNameEB.String = obj.MdlName;
            obj.TitleEB.String = obj.Title;
            obj.PostMethodEB.String = obj.PostFunName;

        end % update
            
        function editPanelResize( obj , ~ , ~ )
  
        end % editPanelResize
        
        function resizeFcn( obj , ~ , ~ )
            % get figure position
            contPosition = getpixelposition(obj.Container);

            set(obj.EditPanel,'Units','Pixels');
            set(obj.EditPanel,'Position',[1 , contPosition(4) - 75 , contPosition(3) , 75] );
            set(obj.AxisPanel,'Units','Pixels');
            set(obj.AxisPanel,'Position',[1 , 1 , contPosition(3) , contPosition(4) - 75]);   
        end % resizeFcn
        
        function axisPanelResize( obj , ~ , ~ )
    
            % get figure position
            orgUnits = get(obj.AxisPanel,'Units');
            set(obj.AxisPanel,'Units','Pixels');
            panelPos = get(obj.AxisPanel,'Position');
            set(obj.AxisPanel,'Units',orgUnits);
            
        end % axisPanelResize
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the OutputSelector object
            %cpObj.OutputSelector = copy(obj.OutputSelector);
        end
        
    end % Methods - Protected
    
    %% Methods - Static
    methods (Static)
    
            function [simOut,simInput] = createSimInputs( Input , model )
            % Initialize input structure for the simulation

            simInput = struct('time',[],'signals',[],'name',{{}});
            
            %model      = obj.MdlName;
            trimStruct = Input.trimStruct;


            % Build Input Structure - signalsOut
            simInput.time = Input.time;
            inportsMdl        = find_system(model,'SearchDepth',1,'BlockType','Inport');
            InputNames        = get_param(inportsMdl,'Name');
            if ~isempty(trimStruct)
                ICfields          = {trimStruct.Name}; %fieldnames(trimStruct.IC.Inputs);
            else 
                ICfields = [];
            end
            inputFields       = fieldnames(Input);

            for i = 1:length(InputNames)

                if any(strcmp(ICfields,InputNames(i)))
                    if any(strcmp(inputFields,InputNames(i)))
                        deltaValue     = Input.(InputNames{i});
                    else
                        deltaValue     = zeros(length(simInput.time),1);
                    end
                    simInput.signals(i).values     = (trimStruct.get(InputNames{i}).Value* ones(length(simInput.time),1) + deltaValue) ;
                    simInput.signals(i).dimensions = 1; 
                    simInput.name(i) = InputNames(i); 
                elseif any(strcmp(inputFields,InputNames(i)))
                    if strcmp(get_param(inportsMdl(i),'OutDataTypeStr'),'boolean')
                        simInput.signals(i).values     = boolean(Input.(InputNames{i}));
                        simInput.signals(i).dimensions = 1;
                    else
                        simInput.signals(i).values     = Input.(InputNames{i});
                        simInput.signals(i).dimensions = 1;
                    end
                    simInput.name(i) = InputNames(i); 
                else
                    if strcmp(get_param(inportsMdl(i),'OutDataTypeStr'),'boolean')
                        simInput.signals(i).values = boolean(zeros(length(simInput.time),1));
                    else
                        simInput.signals(i).values = zeros(length(simInput.time),1);
                    end
                    simInput.signals(i).dimensions = 1;
                    simInput.name(i) = InputNames(i); 
                end


            end


            simDataIn = rmfield(simInput,'name');
            % Set Cache Folder - All binary files will be stored here
            % Get file location to set the correct path
            [pathstr, name, ext] = fileparts(get_param(model,'FileName'));
            cacheFldrLoc = fullfile(pathstr,'SimCacheFolder');
            % Get current config and store
            cfg = Simulink.fileGenControl('getConfig');
            currCacheFolder = cfg.CacheFolder;
            cfg.CacheFolder = cacheFldrLoc;
            Simulink.fileGenControl('setConfig', 'config', cfg, 'createDir', true);

            %%% Create Simulink Options
            %options = simset('SrcWorkspace','current');

            % Create a Configuration Set
            simMode = get_param(model, 'SimulationMode');
            cref = getActiveConfigSet(model);
            if isa(cref,'Simulink.ConfigSetRef')
                cset = cref.getRefConfigSet;
            else
                cset = cref;
            end
            model_cs = cset.copy;

            % Set model reference rebuild options
            switch Input.ReBuildMDLRef
                case 0
                    mdlRefUpdatStr = 'AssumeUpToDate';
                case 1
                    mdlRefUpdatStr = 'IfOutOfDate';
                otherwise
                    mdlRefUpdatStr = 'Force';
            end
            model_cs.Name = 'TempConfigRef';

            set_param(model_cs,'LoadExternalInput','on');
            set_param(model_cs,'ExternalInput','simInput');
            set_param(model_cs,'SignalLogging','on');
            set_param(model_cs,'SignalLoggingName','SignalLog');
            set_param(model_cs,'SignalLoggingSaveFormat','Dataset');
            set_param(model_cs,'UpdateModelReferenceTargets',mdlRefUpdatStr);
            set_param(model_cs,'StopTime', num2str(Input.time(end)));
            set_param(model_cs,'SaveOutput','on');
            set_param(model_cs,'OutputSaveName','Outports');
            set_param(model_cs,'LimitDataPoints','off');
            set_param(model_cs,'SaveFormat','Dataset');
            
            assignin('base','simInput',simDataIn);     
            % Run the simulation
            try set_param(model,'SimulationMode','Normal'); end %#ok<TRYNC>
            simOut = sim(model, model_cs);
            set_param(model, 'SimulationMode', simMode);

            % Set Cache Folder - Set back to original location
            cfg.CacheFolder = currCacheFolder;
            Simulink.fileGenControl('setConfig', 'config', cfg);


        end % createSimInputs
        
        function tsObjs = extractAllSignals( sig )
            tsObjs = timeseries.empty;
            if isa(sig,'struct')
                fnames = fieldnames(sig);
                for i = 1:length(fnames)
                    tsObjsTemp = Requirements.SimulationCollection.extractAllSignals( sig.(fnames{i}) );
                    tsObjs = [tsObjs,tsObjsTemp]; %#ok<AGROW>
                end
            else
                tsObjs = sig;
            end

        end % extractAllSignals
    end
end

function y = getColor(ind)

color = {'b','r','g','k','m','c',[0.5,0.5,0]};
if ind <= 7
    y = color{ind};
else
    y = [rand(1),rand(1),rand(1)];
end

end % getColor

function y = getSimViewerColor(ind)

color = {[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 0 1],[0 1 1],[0.5,0.5,0]};
color = cellfun(@(x) x*255,color,'UniformOutput',false);
if ind <= 7
    y = color{ind};
else
    y = [rand(1),rand(1),rand(1)];
end

end % getSimViewerColor

