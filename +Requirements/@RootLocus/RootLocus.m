classdef RootLocus < Requirements.Synthesis
    
    %% Public properties
    properties
        KValueString
        KValue
        GainValues
        GainName
        UserSelectedGainValues
        Z
        P
        R
        GainValue
        RequiermentPlot
        
        ScatteredGainObj
    end % Public properties
    
    %% Hidden Properties   
    properties (Hidden = true)
        folder           % used only by the tool to store a string of the folder
        %BrowseStartDir = pwd
    end % Hidden Properties

    %% Hidden Transient View Properties
    properties (Hidden = true , Transient = true )       

        AxisPanel
        OutDataIndText
        OutDataIndEB
        ReqPltText
        ReqPltEB
        BkPltText
        BkPltEB
        IterText
        IterEB
        BkGrndPlotPB
        ReqPlotPB
        PlotAxisH
        GainNameText
        GainNameEB
        KValueText
        KValueEB
        
        axH
        lineH
        CurrentSelLineH
        
        DataCursor
    end % Hidden Transient View Properties
    
    %% Properties - Observable
    properties(SetObservable)
        SelectedIndex
    end
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        SelectedGainValue
        
    end % Dependant properties 
    
    %% Events
    events
        GainChanged

        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods
        function obj = RootLocus(fname,model,title)
            if nargin == 3
                obj.FunName = fname;
                obj.MdlName = model;
                obj.Title = title;
            end
        end % Synthesis
    end % Methods - Constructor

    %% Methods - Property Access
    methods
%         function y = get.GainValues( obj )
%             currentGainValue = scattGainObj.Gain.get(obj.GainName).Value;
%             obj.GainValue = currentGainValue;
%             y = sort(unique([obj.UserSelectedGainValues,currentGainValue]));
%         end % GainValues
    end % Property access methods
    
    %% Methods - Ordinary
    methods
        
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

            else
                try
                    funHandle = str2func(obj.RequiermentPlot);
                    funHandle(axisH);
                    set(get(axisH,'Title'),'String',obj.Title); 
                catch
                    msgbox([obj.RequiermentPlot, ' does not exist on the path']);
                end
            end
            
        end % plotBase
        
        function obj = deleteLines(obj)
            try
                delete(obj.lineH);
            end
            try
                delete(obj.CurrentSelLineH);
            end
            obj.lineH = [];
            obj.CurrentSelLineH = [];
        end % deleteLines
        
        function [mdlParamsCellArray,uniqueMdlNames] = run( obj , axHLL , scattGainObj )
            import UserInterface.ControlDesign.Utilities.*
            mdlParamsCellArray = {};
            uniqueMdlNames = {};
            
            obj.ScatteredGainObj = scattGainObj;
            
            if isempty(obj.ScatteredGainObj)
                OperConds = lacm.OperatingCondition.empty;
            else
                OperConds = obj.ScatteredGainObj.DesignOperatingCondition;
            end
            
            K = struct('GainName',[],'GainValues',[],'Z',[],'P',[],'R',[]);
            
            % Clear Plots and set the plot properties
            for i = 1:length(obj)
                % Set the plot Visible to ON
                set(axHLL.get(i-1),'Visible','on');
                obj(i).plotBase(axHLL.get(i-1));
                obj(i).axH = axHLL.get(i-1);
                obj(i).deleteLines;


                K(i).GainName = obj(i).GainName;
                
                currentGainValue = obj.ScatteredGainObj.Gain.get(obj(i).GainName).Value;
                obj(i).GainValue = currentGainValue;
                K(i).GainValues = sort(unique([obj(i).KValue,currentGainValue]));
            end   

            if length(obj.ScatteredGainObj) == 1 && length(OperConds) > 1
                obj.ScatteredGainObj(1:length(OperConds)) = obj.ScatteredGainObj;    
            end
                           
            % Determine the unique Simulink models defined by the selected
            % requirement objects
            uniqueMdlNames = getUniqueModels(obj); 
            % Assign the evlauated user defined parameters to the unique
            % models
            % -----------------------------------------------------
            %               Assign Parameters to Model
            % -----------------------------------------------------
            modelParams = {};
            for i = 1:length(uniqueMdlNames)
                modelParams{i} = assignParameters2Model( uniqueMdlNames{i} ,obj.ScatteredGainObj );%assignParameters2Model( uniqueMdlNames{i} , [params,gainParam] );
            end 
            mdlParamsCellArray = modelParams;
            modelParams = Utilities.catstruct( modelParams{:});
            % get all the function names of current stability objects
            funNames = arrayfun(@(x) x.FunName, obj,'UniformOutput',false);
            mdlNames = arrayfun(@(x) x.MdlName, obj,'UniformOutput',false);
            % find all unique function names
            [~, ~, uniqueInd] = unique(strcat(funNames,mdlNames));
            %[~, ~, uniqueIndMdl] = unique(mdlNames);
            % find the number of times to run methodes
            ii = max(uniqueInd);
            
            K_Out(length(obj)) = struct('GainName',[],'GainValues',[],'Z',[],'P',[],'R',[]);
            for i = 1:ii
                objArrayInd = find(uniqueInd == i);
                funHandle = obj(objArrayInd(1)).getFunctionHandle;
                % determine the number of output arguments
                numOutArg = nargout(funHandle);
                switch numOutArg
                    case 1
                        K_Out(objArrayInd) = funHandle( OperConds ,obj(objArrayInd(1)).MdlName , modelParams , obj.ScatteredGainObj , K );
                end 
            end

            
            for i = 1:length(obj)
                
                obj(i).GainValues = K_Out(i).GainValues; 
                obj(i).Z = K_Out(i).Z;
                obj(i).P = K_Out(i).P;
                obj(i).R = K_Out(i).R;
                
                
                for c = 1:size(K_Out(i).R,1)  %Plot locus
                    obj(i).lineH(end+1) = line(...
                        'XData',real(obj(i).R(c,:)),...
                        'YData',imag(obj(i).R(c,:)),...
                        'Parent',obj(i).axH,...
                        'Color','b',...
                        'ButtonDownFcn',{@obj.dataCursorUpdated,obj(i),K_Out(i),c});%,...
                end
                obj(i).lineH(end+1) = line(...
                    'XData',real(obj(i).P),...
                    'YData',imag(obj(i).P),...
                    'Parent',obj(i).axH,...
                    'Marker','x',...
                    'MarkerSize',10,...
                    'LineStyle','None',...
                    'Color','k');
                obj(i).lineH(end+1) = line(...
                    'XData',real(obj(i).Z),...
                    'YData',imag(obj(i).Z),...
                    'Parent',obj(i).axH,...
                    'Marker','o',...
                    'MarkerSize',10,...
                    'LineStyle','None',...
                    'Color','r');  
                % Get Gains
                currentGainValue = obj(i).ScatteredGainObj.Gain.get(obj(i).GainName).Value;
                logArray = currentGainValue == obj(i).GainValues;
                test = obj(i).R(:,logArray);

                updateCurrentGainMarkers( obj(i) , test );

                
                set(get(obj.axH,'Title'),'String',[obj.Title,' : ',num2str(currentGainValue)]); 
            
            end
            
            
            close_system({obj.MdlName},0);

        end % run
        
        function updateCurrentGainMarkers( obj ,test )
            try
                delete(obj.CurrentSelLineH);
            end
            obj.CurrentSelLineH = [];
            obj.CurrentSelLineH(end+1) = line(...
                                'XData',real(test),...
                                'YData',imag(test),...
                                'Parent',obj.axH,...
                                'Marker','sq',...
                                'MarkerSize',10,...
                                'MarkerFaceColor','g',...
                                'LineStyle','None',...
                                'Color','k');  
                            
                            
        end % updateCurrentGainMarkers

        function names = getStateNames(obj)
            load_system(obj.MdlName);
            stateSignals = Simulink.BlockDiagram.getInitialState(obj.MdlName);
            names = {stateSignals.signals.stateName}; 
        end % getStateNames

        function assignGains(obj,varName,varValue)
            wrkspace = obj.modelWorkspace;
            wrkspace.assignin(varName,varValue);
        end % assignGains

        function mdlVars = getAllGainsAsMdlVars(obj)
            mdlVarsState = obj.StateGains.getAsMdlVars();
            mdlVarsGain  = obj.Gains.getAsMdlVars();
            mdlVars = [mdlVarsState,mdlVarsGain];

        end % getAllGainsAsMdlVars

        function names = getAllGainNames(obj)

            names = [{obj.StateGains.Name},{obj.Gains.Name}];

        end % getAllGainsAsMdlVars  
        
        function dataCursorUpdated( obj , hobj , eventdata , sobj , K , ind )
            
            interPoint = eventdata.IntersectionPoint;
            selectedPoint = complex(interPoint(1),interPoint(2));
            rValues = K.R(ind,:);
            [ix,ix]=min(abs(bsxfun(@minus,selectedPoint,rValues)));
            
            nearestValue = rValues(ix);
            nearestGain  = K.GainValues(ix);
            
            test = K.R(:,ix);
            
            updateCurrentGainMarkers( sobj , test );
            
            gain.Name = obj.GainName;
            gain.Value = nearestGain;
            notify( obj , 'GainChanged', UserInterface.UserInterfaceEventData(gain));
            
           
            
            set(get(obj.axH,'Title'),'String',[obj.Title,' : ',num2str(nearestGain)]); 
           
            
            % Display Gain Value
            
            
%             strmax = ['Gain = ',num2str(nearestGain)];
%             text(0,0,strmax,'HorizontalAlignment','right','Parent',obj.axH);
%             
            
            
%                 currentGainValue = obj.ScatteredGainObj.Gain.get(obj.GainName);
%                 currentGainValue.Value = nearestGain;
                
                
%                 logArray = currentGainValue == obj.GainValues;
%                 test = K_Out(i).R(:,logArray);
            
            
            %obj.GainValue = nearestGain;
            
            
            
%             
%             logArray = temp == K.R(ind,:)
%             
%             n=[50 150 200];
%             m=[40 65 130 201 -10 199]; % the engine
%             [ix,ix]=min(abs(bsxfun(@minus,m,n.')));
% 
%             disp(int2str(ind))
        end % dataCursorUpdated

    end % Methods - Ordinary
    
    %% Methods - View
    methods
        
        function createView( obj , parent )
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
%                         % Output Data Index
%                         uicontrol('Parent',obj.EditGridContainer,...
%                             'Style','text',...
%                             'String','');
%                         obj.OutDataIndText = uicontrol(...
%                             'Parent',obj.EditGridContainer,...
%                             'Style','text',...
%                             'String','Output Data Index:',...
%                             'HorizontalAlignment','Right');
%                         obj.OutDataIndEB = uicontrol(...
%                             'Parent',obj.EditGridContainer,...
%                             'Style','edit',...
%                             'String','',...
%                             'BackgroundColor',[1 1 1],...
%                             'Callback',{@obj.reqUpdate,'OutputDataIndex'});
                        % Gain Name
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.GainNameText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Gain name:',...
                            'HorizontalAlignment','Right');
                        obj.GainNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'GainName'});
                        % K Value
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.KValueText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','K value:',...
                            'HorizontalAlignment','Right');
                        obj.KValueEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'KValue'});
                        

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
            newValueString = [];
            if length(testValue) == 1 && isnan(testValue)
                try
                    newValue = eval(value);
                    newValueString = value;
                catch
                    newValue = value;
                end
            else
                newValue = testValue;
%                 try
%                     newValue = eval(value);
%                 catch
%                     newValue = value;
%                 end
            end
            obj.(type) = newValue;
            if ~isempty(newValueString)
                obj.([type,'String']) = newValueString;
            end

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
 
    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        function update( obj )
            obj.MethodEB.String = obj.FunName;
            obj.MdlNameEB.String = obj.MdlName;
            obj.TitleEB.String = obj.Title;
            obj.ReqPltEB.String = obj.RequiermentPlot;

            obj.KValueEB.String = obj.KValueString;
            obj.GainNameEB.String = obj.GainName;
            
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
            
        end % axisPanelResize
              
    end % Methods - Protected
   
end
