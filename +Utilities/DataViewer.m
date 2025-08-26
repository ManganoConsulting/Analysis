

function hdl = DataViewer(varargin)
% function gui = DataViewer(SimulinkDataSet,color,DefaultList,varargin)
%ACD Simulation Data Viewer
%#ok<*AGROW>

%% Input Parser
p = inputParser;
p.addParameter('Parent',[]);
p.addParameter('SimulinkDataSet',Simulink.SimulationData.Dataset.empty);
p.addParameter('Color',[]);
p.addParameter('DefaultList',[]);
p.addParameter('ShowHoldButton','on');
p.addParameter('ShowExportButton','off');
p.parse(varargin{:});
inputs = p.Results;

hdl.AddSimulinkData   = @addSimulinkData;
hdl.GetDefaultSignals = @getDefaultSignals;

data = createData(inputs);
gui  = createInterface(inputs);

updateInterface();

    function data = createData(inputs)
    %----------------------------------------------------------------------
    % - Create the shared data-structure for this application
    %---------------------------------------------------------------------- 
        data.SimulinkDataSet   = inputs.SimulinkDataSet;   
        data.color             = inputs.Color;
        data.defaultSignalList = inputs.DefaultList;
        
        
        
        
        data.colorOrder         = [      0         0    1.0000;
                                         0    0.5000         0;
                                    1.0000         0         0;
                                         0    0.7500    0.7500;
                                    0.7500         0    0.7500;
                                    0.7500    0.7500         0;
                                    0.2500    0.2500    0.2500];

        data.linestylesLoop     = 1;                % Initialize linestyles loop
        data.legendNameArray    = {};               % Initialize legend name
        data.holdBtnString      = 'Press to hold plot';
        data.nextPlot           = 'replace';
        data.ParamListStrings   = [];%fieldnames(data.SimulinkDataSet(1).getElement(1).Values);%[]; %
        data.nameStruct         = [];%getNameStruct(SimulinkDataSet(1));
        data.ParamListValue     = 1;
        data.BusIndex           = 1;
        data.CurrentPlot.Time   = [];
        data.CurrentPlot.Data   = [];
        data.CurrentTitle       = [];
        data.lineH              = [];
        data.virtualBusString   = [];
%         if isempty(data.color)
%             ind = 1;
%             for i = 1:length(data.ParamListStrings)
%                 data.color{i} = data.colorOrder(ind,:);
%                 ind = ind + 1;
%                 if ind > 7
%                     ind = 1;
%                 end
%             end
%         end
    end % createData
        
    function gui = createInterface(inputs)
    %----------------------------------------------------------------------
    % - Create the user interface for the application and return a 
    %    structure of handles for global use.
    %----------------------------------------------------------------------
    %% Open a new figure window or make a child of varagin{1}
    if isempty(inputs.Parent)
        gui.fh = figure( 'Name', 'ACD Simulation Data Viewer', ...
            'MenuBar', 'none', ...
            'Toolbar', 'figure', ...
            'NumberTitle', 'off',...
            'Position',[349   236   894   644]);
    else
        gui.fh = inputs.Parent;
    end
    
    gui.Container = uicontainer('Parent',gui.fh,...
        'Units','Normal',...
        'Position',[ 0 , 0 , 1 , 1 ]);
    set(gui.Container,'ResizeFcn',@reSize);
    posPix = getpixelposition(gui.Container);
    listboxHeight = (posPix(4) - 100)/3;
            % Add "Virtual Bus" label text box
            gui.VB_Text = uicontrol('Parent',gui.Container,...
                'Style','text',...
                'Units','Pixels',...
                'Position',[6  , posPix(4) - 25  , 166  ,  25],...
                'String','Virtual Bus:',...
                'FontName','FixedWidth',...
                'FontSize',12,...
                'FontWeight','Bold');
            % Add "Virtual Bus" edit box
            gui.BusList = uicontrol('Parent',gui.Container,...
                'Style','listbox',...
                'Units','Pixels',...
                'Position',[6 , (listboxHeight * 2)  + 75 , 166  , listboxHeight],...
                'String','',...
                'Callback',@setParamList); 
            % Add "Signals" label text box
            gui.Sig_Text = uicontrol('Parent',gui.Container,...
                'Style','text',...
                'units','pixels',...
                'String','Signals:',...
                'FontName','FixedWidth',...
                'FontSize',12,...
                'FontWeight','Bold',...
                'Position',[6  ,(listboxHeight * 2)  + 50 , 166 ,  25]); 
            % Add "Signals" list box
            gui.ParamList = uicontrol('Parent',gui.Container,...
                'Style','listbox',...
                'units','pixels',...
                'String','',...
                'Position',[6 , (listboxHeight)  + 50 , 166  , listboxHeight],...
                'Callback',@plotParam);
            
            gui.addRemButtonPanel = uicontainer('Parent',gui.Container,...
                'Units','Pixels',...
                'Position',[6    (listboxHeight)  + 25   166   25]);
                gui.AddDefault = uicontrol('Parent',gui.addRemButtonPanel,...
                    'Style','togglebutton',...
                    'units','normal',...
                    'Position',[.05  ,  .05  , .40 , .90],...
                    'String','Add',...
                    'Callback',@AddDefault,...
                    'Visible','on');
                gui.RmDefault =uicontrol('Parent',gui.addRemButtonPanel,...
                    'Style','togglebutton',...
                    'units','normal',...
                    'Position',[.55  ,  .05  , .40 , .90],...
                    'String','Remove',...
                    'Callback',@RmDefault,...
                    'Visible','on');


            gui.DefaultList = uicontrol('Parent',gui.Container,...
                'Style','listbox',...
                'units','pixels',...
                'String','',...
                'Position',[6 ,   25  , 166  , listboxHeight],...
                'Callback','');
            gui.holdButtonPanel = uicontainer('Parent',gui.Container,...
                'Units','Pixels',...
                'Position',[6  ,  1  , 166  , 25]);
                gui.HoldBtn = uicontrol('Parent',gui.holdButtonPanel,...
                    'Style','togglebutton',...
                    'units','normal',...
                    'Position',[.05  ,  .05  , .40 , .90],...
                    'String','Press to hold plot',...
                    'Callback',@HoldBtn,...
                    'Visible',inputs.ShowHoldButton);
                gui.ExData_Text = uicontrol('Parent',gui.holdButtonPanel,...
                    'Style','togglebutton',...
                    'units','normal',...
                    'Position',[.55  ,  .05  , .40 , .90],...
                    'String','Export Data',...
                    'Callback',@export,...
                    'Visible',inputs.ShowExportButton);
        % Add axes to the figure
        gui.Panel = uipanel('Parent',gui.Container,...
            'Units','Pixels',...
            'Position',[186  ,  1 , posPix(3) - 186 , posPix(4) ]);
        gui.Axis = axes('Parent',gui.Panel,...
            'PlotBoxAspectRatioMode','auto',...
            'Units','Normal',...
            'OuterPosition',[0 , 0 , 1 , 1],...
            'ActivePositionProperty', 'Position'); 
        set(get(gui.Axis,'XLabel'),'String','time (s)')

        % Add "Hold Plot" button
        
    end % createInterface

    function updateInterface()
        set(gui.DefaultList,'string',data.defaultSignalList);
        set(gui.ParamList,'String',data.ParamListStrings);
        set(gui.HoldBtn,'String',data.holdBtnString);
        set(gui.BusList,'String',data.virtualBusString);

        set(gui.ParamList,'Value',data.ParamListValue);
        set(gui.BusList,'Value',data.BusIndex);
        
        %% Plot routine
        if ~isempty(data.lineH)
            delete(data.lineH);
            data.lineH = [];
        end
        for i = 1:length(data.SimulinkDataSet)

            
            switch length(data.defaultSignalList)
                case 0
                    data.CurrentPlot.Time = data.SimulinkDataSet(i).getElement(data.BusIndex).Values.(data.ParamListStrings{data.ParamListValue}).Time;
                    data.CurrentPlot.Data = data.SimulinkDataSet(i).getElement(data.BusIndex).Values.(data.ParamListStrings{data.ParamListValue}).Data;
                    data.CurrentTitle = data.ParamListStrings{data.ParamListValue};
                    data.lineH(i) = line(...
                        data.CurrentPlot.Time,...
                        data.CurrentPlot.Data,...
                        'Parent',gui.Axis,...
                        'color',data.color{i});
                case 1
                    set(gui.Axis,'Position',[0.07  0.07  0.90  0.86]);
                    mtch = regexp(data.defaultSignalList{1}, '([^ \.][^\.]*)', 'match');
                    data.lineH(i) = line(...
                        data.SimulinkDataSet(i).getElement(mtch{1}).Values.(mtch{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch{1}).Values.(mtch{2}).Data,...
                        'Parent',gui.Axis,...
                        'color',data.color{i});
                    data.CurrentTitle = mtch{2};
                case 2
                    if ~isfield(gui,'axis2')
                        set(gui.Axis,'Position',[0.07  0.57  0.90  0.36]);
                        gui.axis2 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.07  0.07  0.90  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    mtch1 = regexp(data.defaultSignalList{1}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Data,...
                        'Parent',gui.Axis,...
                        'color',data.color{i});
                    data.CurrentTitle = mtch1{2};

                    mtch2 = regexp(data.defaultSignalList{2}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Data,...
                        'Parent',gui.axis2,...
                        'color',data.color{i});
                    title(gui.axis2,mtch2{2},'Interpreter', 'none');
                    grid(gui.axis2,'on'); 
                case 3

                    if ~isfield(gui,'axis2')
                        gui.axis2 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.57  0.57  0.40  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    if ~isfield(gui,'axis3')
                        set(gui.Axis, 'Position',[0.07  0.57  0.40  0.36]);
                        set(gui.axis2,'Position',[0.57  0.57  0.40  0.36]);
                        gui.axis3 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.07  0.07  0.90  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    mtch1 = regexp(data.defaultSignalList{1}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Data,...
                        'Parent',gui.Axis,...
                        'color',data.color{i});
                    data.CurrentTitle = mtch1{2};

                    mtch2 = regexp(data.defaultSignalList{2}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Data,...
                        'Parent',gui.axis2,...
                        'color',data.color{i});
                    title(gui.axis2,mtch2{2},'Interpreter', 'none');
                    grid(gui.axis2,'on');  

                    mtch3 = regexp(data.defaultSignalList{3}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch3{1}).Values.(mtch3{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch3{1}).Values.(mtch3{2}).Data,...
                        'Parent',gui.axis3,...
                        'color',data.color{i});
                    title(gui.axis3,mtch3{2},'Interpreter', 'none');
                    grid(gui.axis3,'on'); 
                case 4
                    if ~isfield(gui,'axis2')
                        gui.axis2 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.57  0.57  0.40  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    if ~isfield(gui,'axis3')
                        gui.axis3 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.07  0.07  0.40  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    if ~isfield(gui,'axis4')
                        set(gui.Axis, 'Position',[0.07  0.57  0.40  0.36]);
                        set(gui.axis2,'Position',[0.57  0.57  0.40  0.36]);
                        set(gui.axis3,'Position',[0.07  0.07  0.40  0.36]);
                        gui.axis4 = axes('Parent',gui.Panel,...
                            'PlotBoxAspectRatioMode','auto',...
                            'Units','Normal',...
                            'Position',[0.57  0.07  0.40  0.36],...
                            'ActivePositionProperty', 'Position');
                    end

                    mtch1 = regexp(data.defaultSignalList{1}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch1{1}).Values.(mtch1{2}).Data,...
                        'Parent',gui.Axis,...
                        'color',data.color{i});
                    data.CurrentTitle = mtch1{2};

                    mtch2 = regexp(data.defaultSignalList{2}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch2{1}).Values.(mtch2{2}).Data,...
                        'Parent',gui.axis2,...
                        'color',data.color{i});
                    title(gui.axis2,mtch2{2},'Interpreter', 'none');
                    grid(gui.axis2,'on');  

                    mtch3 = regexp(data.defaultSignalList{3}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch3{1}).Values.(mtch3{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch3{1}).Values.(mtch3{2}).Data,...
                        'Parent',gui.axis3,...
                        'color',data.color{i});
                    title(gui.axis3,mtch3{2},'Interpreter', 'none');
                    grid(gui.axis3,'on');      

                    mtch4 = regexp(data.defaultSignalList{4}, '([^ \.][^\.]*)', 'match');
                    data.lineH(end+1) = line(...
                        data.SimulinkDataSet(i).getElement(mtch4{1}).Values.(mtch4{2}).Time,...
                        data.SimulinkDataSet(i).getElement(mtch4{1}).Values.(mtch4{2}).Data,...
                        'Parent',gui.axis4,...
                        'color',data.color{i});
                    title(gui.axis4,mtch4{2},'Interpreter', 'none');
                    grid(gui.axis4,'on');  
            end
                        
        end
        
        %%
        title(gui.Axis,data.CurrentTitle,'Interpreter', 'none');
        if ~isempty(data.ParamListStrings)
            data.legendNameArray{data.linestylesLoop} = data.ParamListStrings{data.ParamListValue};
        end
%         legend(gui.Axis,data.legendNameArray,'Interpreter', 'none')
        grid(gui.Axis,'on'); 
        
        set(gui.Axis,'NextPlot',data.nextPlot);
        set(gui.DefaultList,'String',data.defaultSignalList);
    end % updateInterface

%% Callbacks
    function setParamList( hobj , ~ )
    %Display the list of parameters associated with the selected virtual
    %bus
        data.BusIndex = get(hobj,'Value');
        data.ParamListValue = 1;
        data.ParamListStrings = fieldnames(data.SimulinkDataSet.getElement(get(hobj,'Value')).Values);
        if get(gui.HoldBtn,'Value')
            incrementLineStyleLoop();
        end
        updateInterface();
    end

    function plotParam( hobj , ~ )
    %Plot the selected parameter   
        data.ParamListValue = get(hobj,'Value');
        data.BusIndex = get(gui.BusList,'Value');
        
        if get(gui.HoldBtn,'Value')
            incrementLineStyleLoop();
        end
        updateInterface();
    end

    function HoldBtn( hobj , ~ )
    %Hold the plot
        hldState = get(hobj,'Value');
        if hldState == 1
            data.holdBtnString ='Press to release plot';
            data.nextPlot = 'add';
            updateInterface();
        else
            data.holdBtnString = 'Press to hold plot';
            data.nextPlot = 'replace';
            updateInterface();
            data.legendNameArray = {};
            data.linestylesLoop = 1;
        end
        
    end

    function y = getNameStruct(x)  
    %Get Names of all buses and signals in the bus
        for i = 1:getLength(x)
            busSignals  = x.getElement(i).Values;
            busName     = x.getElement(i).Name;
            signalNames = fieldnames(busSignals);
            y(i).TSNames = signalNames; 
            y(i).Name = busName;

        end
    end

    function incrementLineStyleLoop()
        data.linestylesLoop = data.linestylesLoop + 1;
        if data.linestylesLoop == length(data.colorOrder)+1
            data.linestylesLoop = 1;
        end
    end
    
    function export( ~ , ~ )
        tsObj = timeseries(data.CurrentPlot.Data,data.CurrentPlot.Time,...
            'name',data.CurrentTitle); %#ok<NASGU>
        uisave('tsObj');
    end % export

    function AddDefault( ~ , ~ )
        if length(data.defaultSignalList) < 4
            temp = {[data.SimulinkDataSet(1).getElement(data.BusIndex).Name,'.',data.ParamListStrings{data.ParamListValue}]}; 
            data.defaultSignalList = [data.defaultSignalList,temp];
            updateInterface();
        end
    end % AddDefault

    function RmDefault( ~ , ~ )
        val = get(gui.DefaultList,'value');
        data.defaultSignalList(val) = [];
        
        if ~isempty(data.lineH)
            delete(data.lineH);
            data.lineH = [];
        end
        
        if isfield(gui,'axis2')
            delete(gui.axis2);
            gui = rmfield(gui, 'axis2');
        end
        if isfield(gui,'axis3')
            delete(gui.axis3);
            gui = rmfield(gui, 'axis3');
        end   
        if isfield(gui,'axis4')
            delete(gui.axis4);
            gui = rmfield(gui, 'axis4');
        end 
        if length(data.defaultSignalList) < 2
            temp =  1;
        else
            temp = length(data.defaultSignalList);
        end
        set(gui.DefaultList,'value',temp);
        updateInterface();    
    end % RmDefault

    function addSimulinkData(simDataSet,color,dfList)
        data.SimulinkDataSet   = simDataSet;   
        data.color             = color;
        data.defaultSignalList = dfList;
        

        
        if isempty(data.defaultSignalList)
            
        end
        
        
        
       try
            data.ParamListStrings   = fieldnames(data.SimulinkDataSet(1).getElement(1).Values);
            data.nameStruct         = getNameStruct(data.SimulinkDataSet(1));
            data.virtualBusString   = {data.nameStruct.Name};
        catch
            data.ParamListStrings   = [];
            data.nameStruct         = [];
            data.virtualBusString   = [];
       end
        
        if isempty(data.color)
            ind = 1;
            for i = 1:length(data.ParamListStrings)
                data.color{i} = data.colorOrder(ind,:);
                ind = ind + 1;
                if ind > 7
                    ind = 1;
                end
            end
        end
       
       
       if ~isempty(data.lineH)
            delete(data.lineH);
            data.lineH = [];
        end
       if isfield(gui,'axis2')
            delete(gui.axis2);
            gui = rmfield(gui, 'axis2');
        end
        if isfield(gui,'axis3')
            delete(gui.axis3);
            gui = rmfield(gui, 'axis3');
        end   
        if isfield(gui,'axis4')
            delete(gui.axis4);
            gui = rmfield(gui, 'axis4');
        end 
        set(gui.Axis,'Position',[0.07  0.07  0.90  0.86]);
        updateInterface();
    end %addSimulinkData

    function out = getDefaultSignals( ~ , ~)
        
        out = data.defaultSignalList;
        
    end %getDefaultSignals
    
    function reSize( ~ , ~ )
        posPix = getpixelposition(gui.Container);
        listboxHeight = (posPix(4) - 100)/3;
        % Add "Virtual Bus" label text box
        set(gui.VB_Text,'Units','Pixels',...
            'Position',[6  , posPix(4) - 25  , 166  ,  25]);
        % Add "Virtual Bus" edit box
        set(gui.BusList,'Units','Pixels',...
            'Position',[6 , (listboxHeight * 2)  + 75 , 166  , listboxHeight]); 
        % Add "Signals" label text box
        set(gui.Sig_Text,'units','pixels',...
            'Position',[6  ,(listboxHeight * 2)  + 50 , 166 ,  25]); 
        % Add "Signals" list box
        set(gui.ParamList,'units','pixels',...
            'Position',[6 , (listboxHeight)  + 50 , 166  , listboxHeight]);

        set(gui.addRemButtonPanel,'Units','Pixels',...
            'Position',[6    (listboxHeight)  + 25   166   25]);

        set(gui.DefaultList,'units','pixels',...
            'Position',[6 ,   25  , 166  , listboxHeight]);
        set(gui.holdButtonPanel,'Units','Pixels',...
            'Position',[6  ,  1  , 166  , 25]);
        set(gui.Panel,'Units','Pixels',...
            'Position',[186  ,  1 , posPix(3) - 186 , posPix(4) ]);
   
    end % reSize

end
%