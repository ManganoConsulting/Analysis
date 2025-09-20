classdef ToolRibbon < handle & UserInterface.GraphicsObject

    %% Version
    properties
        VersionNumber
        InternalVersionNumber
    end % Version

    %% Public properties - Object Handles
    properties (Transient = true)
        RibbonHtml 
        ParentSizeListener event.listener
    end

    %% Public properties - Data Storage
    properties
        CurrSelToolRibbion  = 1
        ToolRibbionSelectedText = 'Main'
        NumberOfPlotPerPageReq = 4
        NumberOfPlotPerPagePostSim = 4
        ShowLoggedSignalsState = false
        ShowInvalidTrimState = 'Show Valid Trims'
        UseAllCombinationsState = true
        TrimSettings
        CurrentUnits char = 'English - US'
    end % Public properties

    %% Private properties
    properties (Access = private)
        RibbonAssets struct = struct()
        RibbonReady logical = false
    end % Private properties

    %% Events
    events
        PanelChange
        SaveWorkspace
        LoadWorkspace
        NewWorkspace

        LoadConfiguration
        NewConfiguration
        SaveOperCond
        RunSave
        Run

        LoadBatchRun
        UnitsChanged
        ClearTable

        NewTrimObject
        NewLinearModelObject
        NewMethodObject
        NewSimulationReqObject
        NewPostSimulationReqObject
        OpenObject

        TabPanelChanged
        ExportTable

        GenerateReport

        NewProject
        LoadProject
        CloseProject

        ShowLogSignals
        UseAllCombinations
        Add2Batch
        NewAnalysis
        LoadAnalysisObject

        SetNumPlotsPlts
        SetNumPlotsPostPlts

        ShowTrimsChanged

        TrimSettingsChanged
    end

    %% Methods - Constructor
    methods
        function obj = ToolRibbon(mainobj, ver, internalver, trimOpt)

            obj.VersionNumber = ver;
            obj.InternalVersionNumber = internalver;
            obj.Parent = mainobj;
            obj.TrimSettings = trimOpt;
            obj.ShowInvalidTrimState = obj.resolveTrimState(obj.ShowInvalidTrimState);

            obj.buildRibbon();
        end % ToolRibbon
    end % Constructor

    %% Methods - Public API
    methods
        function setShowLoggedSignals(obj, state)
            if nargin < 2
                state = obj.ShowLoggedSignalsState;
            end
            obj.ShowLoggedSignalsState = logical(state);
            obj.sendRibbonState();
        end % setShowLoggedSignals

        function setShowInvalidTrim(obj, state)
            if nargin < 2
                state = obj.ShowInvalidTrimState;
            end
            obj.ShowInvalidTrimState = obj.resolveTrimState(state);
            obj.sendRibbonState();
        end % setShowInvalidTrim

        function setUseAllCombinations(obj, state)
            if nargin < 2
                state = obj.UseAllCombinationsState;
            end
            obj.UseAllCombinationsState = logical(state);
            obj.sendRibbonState();
        end % setUseAllCombinations

        function setUnits(obj, units)
            if nargin < 2 || isempty(units)
                units = obj.CurrentUnits;
            end
            obj.CurrentUnits = char(units);
            obj.sendRibbonState();
        end % setUnits

        function createNewAnalysis_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewAnalysis');
        end % createNewAnalysis_CB

        function newTrimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewTrimObject');
        end % newTrimObj_CB

        function newLinMdlObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewLinearModelObject');
        end % newLinMdlObj_CB

        function newMethodObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewMethodObject');
        end % newMethodObj_CB

        function newNonLinSimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewSimulationReqObject');
        end % newNonLinSimObj_CB

        function newPostSimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewPostSimulationReqObject');
        end % newPostSimObj_CB

        function openAnalysisObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Analysis'));
        end % openAnalysisObj_CB

        function openTrimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Trim'));
        end % openTrimObj_CB

        function openLinMdlObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Linear Model'));
        end % openLinMdlObj_CB

        function openMethodObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Requirement'));
        end % openMethodObj_CB

        function openNonLinSimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Simulation Requirement'));
        end % openNonLinSimObj_CB

        function openPostNonLinSimObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'OpenObject',GeneralEventData('Post Simulation Requirement'));
        end % openPostNonLinSimObj_CB

        function loadAnalysisObj_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'LoadAnalysisObject');
        end % loadAnalysisObj_CB

        function loadWorkspace_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'LoadWorkspace');
        end % loadWorkspace_CB

        function batchRun_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'LoadBatchRun');
        end % batchRun_CB

        function batchAdd_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'Add2Batch');
        end % batchAdd_CB

        function saveOperCond_CB(obj, varargin)
            saveType = obj.extractNumericArg(varargin);
            if isempty(saveType)
                saveType = 1;
            end
            notify(obj,'SaveOperCond',GeneralEventData(saveType));
        end % saveOperCond_CB

        function saveWorkspace_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'SaveWorkspace');
        end % saveWorkspace_CB

        function run_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'Run');
        end % run_CB

        function runAndSave_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'RunSave');
        end % runAndSave_CB

        function clearTable_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'ClearTable');
        end % clearTable_CB

        function exportTable_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('mat'));
        end % exportTable_CB

        function exportTableCSV_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('csv'));
        end % exportTableCSV_CB

        function exportTableM_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'ExportTable',UserInterface.UserInterfaceEventData('m'));
        end % exportTableM_CB

        function generateReport_CB(obj, varargin)
            format = 'PDF';
            for k = 1:numel(varargin)
                candidate = varargin{k};
                if ischar(candidate) || isstring(candidate)
                    format = char(candidate);
                    break;
                end
            end
            notify(obj,'GenerateReport',UserInterface.UserInterfaceEventData(format));
        end % generateReport_CB

        function setNumPlotsPlts(obj, varargin)
            numbPlots = obj.extractNumericArg(varargin);
            if isempty(numbPlots)
                return;
            end
            obj.NumberOfPlotPerPageReq = numbPlots;
            notify(obj,'SetNumPlotsPlts',UserInterface.UserInterfaceEventData(numbPlots));
            obj.sendRibbonState();
        end % setNumPlotsPlts

        function setNumPlotsPostPlts(obj, varargin)
            numbPlots = obj.extractNumericArg(varargin);
            if isempty(numbPlots)
                return;
            end
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            notify(obj,'SetNumPlotsPostPlts',UserInterface.UserInterfaceEventData(numbPlots));
            obj.sendRibbonState();
        end % setNumPlotsPostPlts

        function setNumPlotsAll(obj, varargin)
            numbPlots = obj.extractNumericArg(varargin);
            if isempty(numbPlots)
                return;
            end
            obj.NumberOfPlotPerPageReq = numbPlots;
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            notify(obj,'SetNumPlotsPlts',UserInterface.UserInterfaceEventData(numbPlots));
            notify(obj,'SetNumPlotsPostPlts',UserInterface.UserInterfaceEventData(numbPlots));
            obj.sendRibbonState();
        end % setNumPlotsAll

        function setTrimSettings(obj, varargin) %#ok<INUSD>
            if isempty(obj.TrimSettings)
                return;
            end
            obj.TrimSettings.createView();
            uiwait(obj.TrimSettings.Parent);
            notify(obj,'TrimSettingsChanged',UserInterface.UserInterfaceEventData(obj.TrimSettings));
        end % setTrimSettings

        function newProject_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'NewProject');
        end % newProject_CB

        function loadProject_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'LoadProject');
        end % loadProject_CB

        function closeProject_CB(obj, varargin) %#ok<INUSD>
            notify(obj,'CloseProject');
        end % closeProject_CB
    end

    %% Methods - Private helpers
    methods (Access = private)
        function buildRibbon(obj)
            if isempty(obj.Parent) || ~isgraphics(obj.Parent)
                return;
            end

            obj.RibbonAssets = obj.buildRibbonAssets();
            obj.RibbonReady = false;

            parentPos = getpixelposition(obj.Parent);
            if isempty(parentPos)
                parentPos = [0 0 860 93];
            end
            width = max(parentPos(3),1);
            height = max(parentPos(4),1);

            obj.RibbonHtml = uihtml(obj.Parent,...
                'HTMLSource',obj.buildRibbonHtml(),...
                'Position',[0 0 width height]);
            obj.RibbonHtml.DataChangedFcn = @(~,evt)obj.handleRibbonEvent(evt.Data);

            try
                obj.ParentSizeListener = addlistener(obj.Parent,'SizeChanged',@(~,~)obj.updateRibbonGeometry());
            catch
                obj.ParentSizeListener = [];
            end

            obj.updateRibbonGeometry();
        end % buildRibbon

        function handleRibbonEvent(obj, payload)
            if ~isstruct(payload) || ~isfield(payload,'type')
                return;
            end

            msgType = lower(char(string(payload.type)));
            switch msgType
                case 'ready'
                    obj.RibbonReady = true;
                    obj.sendRibbonConfig();
                    obj.sendRibbonState();

                case 'command'
                    if ~isfield(payload,'command')
                        return;
                    end
                    cmd = lower(char(string(payload.command)));
                    option = '';
                    if isfield(payload,'option') && ~isempty(payload.option)
                        option = lower(char(string(payload.option)));
                    end
                    value = [];
                    if isfield(payload,'value')
                        rawVal = payload.value;
                        if ischar(rawVal) || isstring(rawVal)
                            numericVal = str2double(rawVal);
                            if ~isnan(numericVal)
                                rawVal = numericVal;
                            else
                                rawVal = char(rawVal);
                            end
                        end
                        value = rawVal;
                    end
                    obj.executeCommand(cmd, option, value);

                case 'toggle'
                    if ~isfield(payload,'target')
                        return;
                    end
                    target = lower(char(string(payload.target)));
                    value = false;
                    if isfield(payload,'value')
                        value = logical(payload.value);
                    end
                    switch target
                        case 'showlog'
                            obj.ShowLoggedSignalsState = value;
                            notify(obj,'ShowLogSignals',GeneralEventData(value));
                        case 'useall'
                            obj.UseAllCombinationsState = value;
                            notify(obj,'UseAllCombinations',GeneralEventData(value));
                    end
                    obj.sendRibbonState();

                case 'select'
                    if ~isfield(payload,'target') || ~isfield(payload,'value')
                        return;
                    end
                    target = lower(char(string(payload.target)));
                    switch target
                        case 'showinvalid'
                            label = obj.resolveTrimState(payload.value);
                            obj.ShowInvalidTrimState = label;
                            notify(obj,'ShowTrimsChanged',UserInterface.UserInterfaceEventData(label));
                        case 'units'
                            units = char(string(payload.value));
                            obj.CurrentUnits = units;
                            notify(obj,'UnitsChanged',UserInterface.UserInterfaceEventData(units));
                    end
                    obj.sendRibbonState();

                case 'request'
                    if isfield(payload,'subject') && strcmpi(char(string(payload.subject)),'state')
                        obj.sendRibbonState();
                    end
            end
        end % handleRibbonEvent

        function executeCommand(obj, cmd, option, value)
            if nargin < 3 || isempty(option)
                option = '';
            end
            switch cmd
                case 'new'
                    if isempty(option)
                        option = 'trim';
                    end
                    switch option
                        case {'analysis','task'}
                            obj.createNewAnalysis_CB();
                        case 'model'
                            obj.newLinMdlObj_CB();
                        case {'requirement','req'}
                            obj.newMethodObj_CB();
                        case {'simulation','sim'}
                            obj.newNonLinSimObj_CB();
                        otherwise
                            obj.newTrimObj_CB();
                    end

                case 'open'
                    if isempty(option)
                        option = 'trim';
                    end
                    switch option
                        case {'analysis','task'}
                            obj.openAnalysisObj_CB();
                        case 'model'
                            obj.openLinMdlObj_CB();
                        case {'requirement','req'}
                            obj.openMethodObj_CB();
                        case {'simulation','sim'}
                            obj.openNonLinSimObj_CB();
                        otherwise
                            obj.openTrimObj_CB();
                    end

                case 'load'
                    if isempty(option) || strcmp(option,'project')
                        obj.loadWorkspace_CB();
                    elseif any(strcmp(option,{'task','analysis'}))
                        obj.loadAnalysisObj_CB();
                    end

                case 'save'
                    if isempty(option) || strcmp(option,'project')
                        obj.saveWorkspace_CB();
                    elseif strcmp(option,'opercond-all')
                        obj.saveOperCond_CB(1);
                    elseif strcmp(option,'opercond-valid')
                        obj.saveOperCond_CB(0);
                    end

                case 'run'
                    if strcmp(option,'run')
                        obj.run_CB();
                    else
                        obj.runAndSave_CB();
                    end

                case 'batch'
                    obj.batchAdd_CB();

                case 'table'
                    if isempty(option) || strcmp(option,'clear')
                        obj.clearTable_CB();
                    elseif strcmp(option,'export-mat')
                        obj.exportTable_CB();
                    elseif strcmp(option,'export-csv')
                        obj.exportTableCSV_CB();
                    elseif strcmp(option,'export-m')
                        obj.exportTableM_CB();
                    end

                case 'report'
                    if strcmp(option,'word')
                        obj.generateReport_CB('MS Word');
                    else
                        obj.generateReport_CB('PDF');
                    end

                case 'editor'
                    if any(strcmp(option,{'analysis','task'}))
                        obj.createNewAnalysis_CB();
                    elseif strcmp(option,'model')
                        obj.newLinMdlObj_CB();
                    elseif any(strcmp(option,{'requirement','req'}))
                        obj.newMethodObj_CB();
                    elseif any(strcmp(option,{'simulation','sim'}))
                        obj.newNonLinSimObj_CB();
                    else
                        obj.newTrimObj_CB();
                    end

                case 'settings'
                    if strcmp(option,'trim-settings')
                        obj.setTrimSettings();
                    elseif strcmp(option,'plots-all')
                        obj.setNumPlotsAll(value);
                    elseif strcmp(option,'plots-req')
                        obj.setNumPlotsPlts(value);
                    elseif any(strcmp(option,{'plots-post','plots-sim'}))
                        obj.setNumPlotsPostPlts(value);
                    end
            end
        end % executeCommand

        function sendRibbonConfig(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml) || ~obj.RibbonReady
                return;
            end

            obj.RibbonHtml.Data = struct('type','config','icons',obj.RibbonAssets);
        end % sendRibbonConfig

        function sendRibbonState(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml) || ~obj.RibbonReady
                return;
            end

            state = struct();
            state.showLogSignals = logical(obj.ShowLoggedSignalsState);
            state.useAllCombinations = logical(obj.UseAllCombinationsState);
            state.showInvalidTrim = char(obj.ShowInvalidTrimState);
            state.units = char(obj.CurrentUnits);
            state.numPlotsReq = obj.NumberOfPlotPerPageReq;
            state.numPlotsPost = obj.NumberOfPlotPerPagePostSim;
            if obj.NumberOfPlotPerPageReq == obj.NumberOfPlotPerPagePostSim
                state.numPlotsAll = obj.NumberOfPlotPerPageReq;
            else
                state.numPlotsAll = 0;
            end

            obj.RibbonHtml.Data = struct('type','state','state',state);
        end % sendRibbonState

        function updateRibbonGeometry(obj)
            if isempty(obj.Parent) || ~isgraphics(obj.Parent) || isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml)
                return;
            end

            parentPos = getpixelposition(obj.Parent);
            if isempty(parentPos)
                parentPos = [0 0 1 1];
            end
            width = max(parentPos(3),1);
            height = max(parentPos(4),1);
            obj.RibbonHtml.Position = [0 0 width height];
        end % updateRibbonGeometry

        function html = buildRibbonHtml(~)
            lines = {
                '<!doctype html>'
                '<html lang="en">'
                '<head>'
                '<meta charset="utf-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1">'
                '<style>'
                'html,body{margin:0;padding:0;height:100%;background:transparent;font-family:"Segoe UI",Tahoma,Arial,sans-serif;font-size:11px;color:#1f1f1f;}'
                '.ribbon-surface{position:absolute;inset:0;display:flex;align-items:stretch;gap:0;padding:2px 6px 4px;background:linear-gradient(180deg,#f7f7f7 0%,#dedede 100%);border-bottom:1px solid #bcbcbc;box-sizing:border-box;}'
                '.group{position:relative;display:flex;flex-direction:column;align-items:stretch;gap:3px;padding:0 6px 2px;border-right:1px solid #b6b6b6;min-height:100%;}'
                '.group:last-of-type{border-right:none;}'
                '.group-body{display:flex;gap:4px;align-items:flex-start;flex:1 1 auto;}'
                '.group-body.column{flex-direction:column;}'
                '.group-label{text-align:center;font-size:9px;font-weight:600;letter-spacing:0.5px;color:#5a5a5a;text-transform:uppercase;margin-top:auto;padding-top:0;}'
                '.button-base{display:flex;align-items:center;justify-content:center;gap:6px;border:1px solid #b7b7b7;border-radius:3px;background:linear-gradient(180deg,#fefefe 0%,#e3e3e3 100%);box-shadow:0 1px 0 rgba(255,255,255,0.85) inset;color:#1f1f1f;cursor:pointer;padding:4px;transition:border-color .12s ease,box-shadow .12s ease,background .12s ease;}'
                '.button-base:hover{border-color:#7aa7d9;box-shadow:0 0 0 1px rgba(128,170,214,0.45) inset,0 1px 2px rgba(0,0,0,0.15);background:linear-gradient(180deg,#ffffff 0%,#f0f6fd 100%);}'
                '.button-base:active{border-color:#6d96d0;background:linear-gradient(180deg,#dce9fb 0%,#c4d8f4 100%);}'
                '.button-base:focus-visible{outline:2px solid #0e67d2;outline-offset:1px;}'
                '.button-vertical{flex-direction:column;min-width:50px;height:56px;padding:4px 4px 12px;gap:3px;position:relative;}'
                '.button-horizontal{flex-direction:row;justify-content:flex-start;min-width:0;padding:4px 8px;min-height:30px;}'
                '.button-horizontal.compact{min-height:26px;padding:3px 8px;}'
                '.button-wide{min-width:140px;}'
                '.label{text-transform:uppercase;font-size:9px;font-weight:600;letter-spacing:0.3px;color:#2f2f2f;text-align:center;}'
                '.label.small{text-transform:none;font-size:10px;letter-spacing:0.2px;text-align:left;}'
                '.icon-box{width:22px;height:22px;border-radius:4px;background:linear-gradient(180deg,#fefefe 0%,#ececec 100%);display:flex;align-items:center;justify-content:center;box-shadow:0 1px 0 rgba(255,255,255,0.85) inset;}'
                '.icon-box.small{width:18px;height:18px;border-radius:3px;}'
                '.icon-box img{width:16px;height:16px;image-rendering:-webkit-optimize-contrast;}'
                '.icon-box.small img{width:14px;height:14px;}'
                '.split{position:relative;display:flex;}'
                '.split.vertical{flex-direction:column;align-items:stretch;}'
                '.split.vertical .split-main{width:100%;}'
                '.split.vertical .split-trigger{position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:16px;height:14px;border:1px solid transparent;border-radius:3px;background:linear-gradient(180deg,#fcfcfc 0%,#e5e5e5 100%);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:border-color .12s ease,box-shadow .12s ease;}'
                '.split.horizontal{flex-direction:row;align-items:stretch;}'
                '.split.horizontal .split-main{padding-right:24px;}'
                '.split.horizontal .split-trigger{position:absolute;top:50%;right:6px;transform:translateY(-50%);width:16px;height:16px;border:1px solid transparent;border-radius:3px;background:linear-gradient(180deg,#fcfcfc 0%,#e5e5e5 100%);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:border-color .12s ease,box-shadow .12s ease;}'
                '.split-trigger:hover{border-color:#7aa7d9;box-shadow:0 0 0 1px rgba(128,170,214,0.45) inset;}'
                '.split-trigger:focus-visible{outline:2px solid #0e67d2;outline-offset:1px;}'
                '.caret{width:0;height:0;border-left:4px solid transparent;border-right:4px solid transparent;border-top:6px solid #2f2f2f;}'
                '.menu{position:absolute;top:100%;left:0;margin-top:4px;display:none;flex-direction:column;min-width:160px;background:#ffffff;border:1px solid #c3c3c3;border-radius:4px;box-shadow:0 12px 28px rgba(0,0,0,0.18);padding:3px 0;z-index:20;}'
                '.menu.open{display:flex;}'
                '.menu-item{display:flex;align-items:center;gap:8px;padding:4px 10px;font-size:11px;color:#1f1f1f;background:transparent;border:none;text-align:left;cursor:pointer;}'
                '.menu-item:hover{background:#e5f1fb;}'
                '.menu-item.selected{background:#d0e5f8;}'
                '.menu-item:focus{outline:1px solid #0e67d2;}'
                '.menu-icon{width:16px;height:16px;flex:0 0 auto;display:none;}'
                '.menu-item.has-icon .menu-icon{display:block;}'
                '.menu-label{padding:4px 10px;font-size:9px;text-transform:uppercase;letter-spacing:0.4px;color:#6b6b6b;}'
                '.menu-separator{height:1px;background:#d5d5d5;margin:3px 8px;}'
                '.field{display:flex;flex-direction:column;gap:3px;font-size:10px;color:#1f1f1f;}'
                '.field.inline{flex-direction:row;align-items:center;gap:4px;}'
                '.field-label{font-size:9px;text-transform:uppercase;letter-spacing:0.5px;color:#545454;}'
                'select{font:10px "Segoe UI",Tahoma,Arial,sans-serif;padding:2px 4px;border:1px solid #b2b2b2;border-radius:3px;background:#ffffff;color:#1f1f1f;min-width:120px;}'
                'select:focus{outline:1px solid #0e67d2;outline-offset:0;}'
                '.checkbox{display:flex;align-items:center;gap:4px;font-size:10px;color:#1f1f1f;}'
                '.checkbox input{margin:0;}'
                '.hidden-icons{position:absolute;width:0;height:0;overflow:hidden;}'
                '</style>'
                '</head>'
                '<body>'
                '<div class="ribbon-surface" id="ribbonSurface">'
                '  <div class="group" data-group="file">'
                '    <div class="group-body">'
                '      <div class="split vertical">'
                '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="new" title="Create new item">'
                '          <span class="icon-box"><img id="icon-new" alt="New"></span>'
                '          <span class="label">New</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-new" aria-haspopup="menu" aria-expanded="false" title="New options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-new" role="menu">'
                '          <button type="button" class="menu-item" data-command="new" data-option="analysis">Task</button>'
                '          <button type="button" class="menu-item" data-command="new" data-option="trim">Trim</button>'
                '          <button type="button" class="menu-item" data-command="new" data-option="model">Linear Model</button>'
                '          <button type="button" class="menu-item" data-command="new" data-option="requirement">Requirement</button>'
                '          <button type="button" class="menu-item" data-command="new" data-option="simulation">Simulation Requirement</button>'
                '        </div>'
                '      </div>'
                '      <div class="split vertical">'
                '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="open" title="Open existing item">'
                '          <span class="icon-box"><img id="icon-open" alt="Open"></span>'
                '          <span class="label">Open</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-open" aria-haspopup="menu" aria-expanded="false" title="Open options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-open" role="menu">'
                '          <button type="button" class="menu-item" data-command="open" data-option="analysis">Task</button>'
                '          <button type="button" class="menu-item" data-command="open" data-option="trim">Trim</button>'
                '          <button type="button" class="menu-item" data-command="open" data-option="model">Linear Model</button>'
                '          <button type="button" class="menu-item" data-command="open" data-option="requirement">Requirement</button>'
                '          <button type="button" class="menu-item" data-command="open" data-option="simulation">Simulation Requirement</button>'
                '        </div>'
                '      </div>'
                '      <div class="split vertical">'
                '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="load" data-option="project" title="Load project or task">'
                '          <span class="icon-box"><img id="icon-load" alt="Load"></span>'
                '          <span class="label">Load</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-load" aria-haspopup="menu" aria-expanded="false" title="Load options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-load" role="menu">'
                '          <button type="button" class="menu-item" data-command="load" data-option="project">Project</button>'
                '          <button type="button" class="menu-item" data-command="load" data-option="task">Task</button>'
                '        </div>'
                '      </div>'
                '      <div class="split vertical">'
                '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="save" data-option="project" title="Save project or operating conditions">'
                '          <span class="icon-box"><img id="icon-save" alt="Save"></span>'
                '          <span class="label">Save</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-save" aria-haspopup="menu" aria-expanded="false" title="Save options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-save" role="menu">'
                '          <button type="button" class="menu-item" data-command="save" data-option="project">Save Project</button>'
                '          <div class="menu-separator"></div>'
                '          <div class="menu-label">Save Operating Conditions</div>'
                '          <button type="button" class="menu-item" data-command="save" data-option="opercond-all">All</button>'
                '          <button type="button" class="menu-item" data-command="save" data-option="opercond-valid">Valid Only</button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">File</div>'
                '  </div>'
                '  <div class="group" data-group="run">'
                '    <div class="group-body column">'
                '      <div class="split horizontal">'
                '        <button type="button" class="button-base button-horizontal button-wide split-main" data-role="primary" data-command="run" data-option="save" title="Run and save operating conditions">'
                '          <span class="icon-box small"><img id="icon-run" alt="Run"></span>'
                '          <span class="label small">Auto Run Cases</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-run" aria-haspopup="menu" aria-expanded="false" title="Run options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-run" role="menu">'
                '          <button type="button" class="menu-item" data-command="run" data-option="run">Run</button>'
                '          <button type="button" class="menu-item" data-command="run" data-option="save">Run and Save</button>'
                '        </div>'
                '      </div>'
                '      <button type="button" class="button-base button-horizontal compact" data-role="primary" data-command="batch" data-option="add" title="Add new run cases">'
                '        <span class="icon-box small"><img id="icon-add" alt="Add"></span>'
                '        <span class="label small">Add New Run Cases</span>'
                '      </button>'
                '    </div>'
                '    <div class="group-label">Run</div>'
                '  </div>'
                '  <div class="group" data-group="actions">'
                '    <div class="group-body column">'
                '      <div class="split horizontal">'
                '        <button type="button" class="button-base button-horizontal compact split-main" data-role="primary" data-command="table" data-option="clear" title="Table options">'
                '          <span class="icon-box small"><img id="icon-table" alt="Table"></span>'
                '          <span class="label small">Table Options</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-table" aria-haspopup="menu" aria-expanded="false" title="Table menu">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-table" role="menu">'
                '          <button type="button" class="menu-item" data-command="table" data-option="clear">Clear Table</button>'
                '          <div class="menu-separator"></div>'
                '          <button type="button" class="menu-item" data-command="table" data-option="export-mat">Export to MAT</button>'
                '          <button type="button" class="menu-item" data-command="table" data-option="export-csv">Export to CSV</button>'
                '          <button type="button" class="menu-item" data-command="table" data-option="export-m">Export to M Script</button>'
                '        </div>'
                '      </div>'
                '      <div class="split horizontal">'
                '        <button type="button" class="button-base button-horizontal compact split-main" data-role="primary" data-command="report" data-option="pdf" title="Generate analysis report">'
                '          <span class="icon-box small"><img id="icon-report" alt="Report"></span>'
                '          <span class="label small">Generate Report</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-report" aria-haspopup="menu" aria-expanded="false" title="Report format">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-report" role="menu">'
                '          <button type="button" class="menu-item" data-command="report" data-option="pdf">PDF</button>'
                '          <button type="button" class="menu-item" data-command="report" data-option="word">MS Word</button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Actions</div>'
                '  </div>'
                '  <div class="group" data-group="options">'
                '    <div class="group-body column">'
                '      <label class="field">'
                '        <span class="field-label">Trim Visibility</span>'
                '        <select id="sel-trim">'
                '          <option>Show All Trims</option>'
                '          <option>Show Valid Trims</option>'
                '          <option>Show Invalid Trims</option>'
                '        </select>'
                '      </label>'
                '      <label class="checkbox">'
                '        <input type="checkbox" id="chk-log">'
                '        <span>Display Log Signals</span>'
                '      </label>'
                '      <label class="checkbox">'
                '        <input type="checkbox" id="chk-combo">'
                '        <span>Use All Combinations</span>'
                '      </label>'
                '    </div>'
                '    <div class="group-label">Options</div>'
                '  </div>'
                '  <div class="group" data-group="settings">'
                '    <div class="group-body column">'
                '      <label class="field inline">'
                '        <span class="field-label">Units</span>'
                '        <select id="sel-units">'
                '          <option>English - US</option>'
                '          <option>SI</option>'
                '        </select>'
                '      </label>'
                '      <div class="split horizontal">'
                '        <button type="button" class="button-base button-horizontal compact split-main" data-role="primary" data-command="settings" data-option="trim-settings" title="Open trim settings">'
                '          <span class="icon-box small"><img id="icon-settings" alt="Settings"></span>'
                '          <span class="label small">Settings</span>'
                '        </button>'
                '        <button type="button" class="split-trigger" data-menu="menu-settings" aria-haspopup="menu" aria-expanded="false" title="Settings menu">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" id="menu-settings" role="menu">'
                '          <button type="button" class="menu-item" data-command="settings" data-option="trim-settings">Trim Settings...</button>'
                '          <div class="menu-separator"></div>'
                '          <div class="menu-label">Plots Per Page (All)</div>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-all" data-value="1" data-scope="plots-all">1</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-all" data-value="2" data-scope="plots-all">2</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-all" data-value="4" data-scope="plots-all">4</button>'
                '          <div class="menu-label">Requirements</div>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-req" data-value="1" data-scope="plots-req">1</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-req" data-value="2" data-scope="plots-req">2</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-req" data-value="4" data-scope="plots-req">4</button>'
                '          <div class="menu-label">Post Simulation</div>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-post" data-value="1" data-scope="plots-post">1</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-post" data-value="2" data-scope="plots-post">2</button>'
                '          <button type="button" class="menu-item" data-command="settings" data-option="plots-post" data-value="4" data-scope="plots-post">4</button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Settings</div>'
                '  </div>'
                '</div>'
                '<div class="hidden-icons" aria-hidden="true">'
                '  <img id="icon-analysis" alt="Analysis">'
                '  <img id="icon-trim" alt="Trim">'
                '  <img id="icon-model" alt="Model">'
                '  <img id="icon-requirement" alt="Requirement">'
                '  <img id="icon-simulation" alt="Simulation">'
                '</div>'
                '<script>'
                '(function(){'
                '  const matlab = window.parent;'
                '  function send(msg){'
                '    if(matlab && typeof matlab.postMessage === "function"){'
                '      matlab.postMessage(msg,"*");'
                '    }'
                '  }'
                '  function setIcon(id, src){'
                '    const img = document.getElementById(id);'
                '    if(!img){return;}'
                '    if(src){'
                '      img.src = src;'
                '      img.style.visibility = "visible";'
                '    }else{'
                '      img.removeAttribute("src");'
                '      img.style.visibility = "hidden";'
                '    }'
                '  }'
                '  function closeMenus(exceptId){'
                '    document.querySelectorAll(".menu.open").forEach(menu => {'
                '      if(!exceptId || menu.id !== exceptId){'
                '        menu.classList.remove("open");'
                '        const trigger = document.querySelector(`[data-menu="${menu.id}"]`);'
                '        if(trigger){'
                '          trigger.setAttribute("aria-expanded","false");'
                '        }'
                '      }'
                '    });'
                '  }'
                '  document.addEventListener("click", evt => {'
                '    if(!evt.target.closest(".split")){'
                '      closeMenus();'
                '    }'
                '  });'
                '  document.querySelectorAll(".split-trigger[data-menu]").forEach(trigger => {'
                '    const menuId = trigger.dataset.menu;'
                '    const menu = document.getElementById(menuId);'
                '    if(!menu){return;}'
                '    trigger.addEventListener("click", evt => {'
                '      evt.stopPropagation();'
                '      const willOpen = !menu.classList.contains("open");'
                '      closeMenus(willOpen ? menuId : "");'
                '      if(willOpen){'
                '        menu.classList.add("open");'
                '        trigger.setAttribute("aria-expanded","true");'
                '      }else{'
                '        trigger.setAttribute("aria-expanded","false");'
                '      }'
                '    });'
                '    menu.addEventListener("click", evt => {'
                '      const item = evt.target.closest(".menu-item[data-command]");'
                '      if(!item){return;}'
                '      const payload = {type:"command", command:item.dataset.command};'
                '      if(item.dataset.option){payload.option = item.dataset.option;}'
                '      if(item.dataset.value){'
                '        const raw = item.dataset.value;'
                '        const num = Number(raw);'
                '        payload.value = Number.isNaN(num) ? raw : num;'
                '      }'
                '      send(payload);'
                '      menu.classList.remove("open");'
                '      trigger.setAttribute("aria-expanded","false");'
                '    });'
                '  });'
                '  document.querySelectorAll(''[data-role="primary"][data-command]'').forEach(btn => {'
                '    btn.addEventListener("click", () => {'
                '      const payload = {type:"command", command:btn.dataset.command};'
                '      if(btn.dataset.option){payload.option = btn.dataset.option;}'
                '      if(btn.dataset.value){'
                '        const raw = btn.dataset.value;'
                '        const num = Number(raw);'
                '        payload.value = Number.isNaN(num) ? raw : num;'
                '      }'
                '      send(payload);'
                '    });'
                '  });'
                '  const selTrim = document.getElementById("sel-trim");'
                '  if(selTrim){'
                '    selTrim.addEventListener("change", () => {'
                '      send({type:"select", target:"showInvalid", value:selTrim.value});'
                '    });'
                '  }'
                '  const selUnits = document.getElementById("sel-units");'
                '  if(selUnits){'
                '    selUnits.addEventListener("change", () => {'
                '      send({type:"select", target:"units", value:selUnits.value});'
                '    });'
                '  }'
                '  const chkLog = document.getElementById("chk-log");'
                '  if(chkLog){'
                '    chkLog.addEventListener("change", () => {'
                '      send({type:"toggle", target:"showLog", value:chkLog.checked});'
                '    });'
                '  }'
                '  const chkCombo = document.getElementById("chk-combo");'
                '  if(chkCombo){'
                '    chkCombo.addEventListener("change", () => {'
                '      send({type:"toggle", target:"useAll", value:chkCombo.checked});'
                '    });'
                '  }'
                '  function setMenuSelection(scope, value){'
                '    const selector = `.menu-item[data-scope="${scope}"]`;'
                '    document.querySelectorAll(selector).forEach(item => {'
                '      if(value !== null && value !== undefined && String(value) === item.dataset.value){'
                '        item.classList.add("selected");'
                '      }else{'
                '        item.classList.remove("selected");'
                '      }'
                '    });'
                '  }'
                '  window.addEventListener("message", event => {'
                '    const data = event.data || {};'
                '    if(data.type === "config"){'
                '      const icons = data.icons || {};'
                '      setIcon("icon-new", icons.new);'
                '      setIcon("icon-open", icons.open);'
                '      setIcon("icon-load", icons.load);'
                '      setIcon("icon-save", icons.save);'
                '      setIcon("icon-run", icons.run);'
                '      setIcon("icon-add", icons.add);'
                '      setIcon("icon-table", icons.table);'
                '      setIcon("icon-report", icons.report);'
                '      setIcon("icon-analysis", icons.analysis);'
                '      setIcon("icon-trim", icons.trim);'
                '      setIcon("icon-model", icons.model);'
                '      setIcon("icon-requirement", icons.requirement);'
                '      setIcon("icon-simulation", icons.simulation);'
                '      setIcon("icon-settings", icons.settings);'
                '    }else if(data.type === "state"){'
                '      const state = data.state || {};'
                '      if(chkLog){chkLog.checked = !!state.showLogSignals;}'
                '      if(chkCombo){chkCombo.checked = !!state.useAllCombinations;}'
                '      if(selTrim && state.showInvalidTrim){selTrim.value = state.showInvalidTrim;}'
                '      if(selUnits && state.units){selUnits.value = state.units;}'
                '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsReq")){'
                '        setMenuSelection("plots-req", state.numPlotsReq);'
                '      }'
                '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsPost")){'
                '        setMenuSelection("plots-post", state.numPlotsPost);'
                '      }'
                '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsAll")){'
                '        if(state.numPlotsAll){'
                '          setMenuSelection("plots-all", state.numPlotsAll);'
                '        }else{'
                '          setMenuSelection("plots-all", null);'
                '        }'
                '      }'
                '    }'
                '  });'
                '  window.addEventListener("DOMContentLoaded", () => {'
                '    send({type:"ready"});'
                '  });'
                '})();'
                '</script>'
                '</body>'
                '</html>'
            };

            html = strjoin(lines, newline);
        end % buildRibbonHtml

        function assets = buildRibbonAssets(obj)
            thisDir = fileparts(mfilename('fullpath'));
            iconDir = fullfile(thisDir,'..','..','Resources');

            assets = struct();
            assets.new = obj.encodeIcon(fullfile(iconDir,'New_24.png'));
            assets.open = obj.encodeIcon(fullfile(iconDir,'Open_24.png'));
            assets.load = obj.encodeIcon(fullfile(iconDir,'LoadArrow_24.png'));
            assets.save = obj.encodeIcon(fullfile(iconDir,'Save_Dirty_24.png'));
            assets.run = obj.encodeIcon(fullfile(iconDir,'RunSave_24.png'));
            assets.add = obj.encodeIcon(fullfile(iconDir,'New_16.png'));
            assets.table = obj.encodeIcon(fullfile(iconDir,'Clean_16.png'));
            assets.report = obj.encodeIcon(fullfile(iconDir,'report_app_24.png'));
            assets.analysis = obj.encodeIcon(fullfile(iconDir,'analysis_24.png'));
            assets.trim = obj.encodeIcon(fullfile(iconDir,'airplaneTrim_24.png'));
            assets.model = obj.encodeIcon(fullfile(iconDir,'linmdl_24.png'));
            assets.requirement = obj.encodeIcon(fullfile(iconDir,'InOut_24.png'));
            assets.simulation = obj.encodeIcon(fullfile(iconDir,'Simulink_24.png'));
            assets.settings = obj.encodeIcon(fullfile(iconDir,'Settings_16.png'));
        end % buildRibbonAssets

        function uri = encodeIcon(~, filename)
            if exist(filename,'file') ~= 2
                uri = '';
                return;
            end

            fid = fopen(filename,'rb');
            if fid < 0
                uri = '';
                return;
            end

            cleaner = onCleanup(@()fclose(fid)); %#ok<NASGU>
            data = fread(fid,'*uint8');
            if isempty(data)
                uri = '';
                return;
            end

            uri = ['data:image/png;base64,' matlab.net.base64encode(uint8(data(:)))];
        end % encodeIcon

        function label = resolveTrimState(~, state)
            if isstring(state) || ischar(state)
                label = char(state);
                if isempty(label)
                    label = 'Show All Trims';
                end
            elseif isnumeric(state) && isscalar(state)
                switch round(state)
                    case 0
                        label = 'Show All Trims';
                    case 1
                        label = 'Show Valid Trims';
                    case 2
                        label = 'Show Invalid Trims';
                    otherwise
                        label = 'Show All Trims';
                end
            else
                label = 'Show All Trims';
            end
        end % resolveTrimState

        function value = extractNumericArg(~, args)
            value = [];
            for idx = numel(args):-1:1
                candidate = args{idx};
                if isa(candidate,'UserInterface.UserInterfaceEventData')
                    candidate = candidate.Object;
                elseif isa(candidate,'GeneralEventData')
                    candidate = candidate.Value;
                end
                if isnumeric(candidate) && isscalar(candidate)
                    value = double(candidate);
                    return;
                end
            end
        end % extractNumericArg
    end

    %% Method - Delete
    methods
        function delete(obj)
            if ~isempty(obj.ParentSizeListener) && isvalid(obj.ParentSizeListener)
                delete(obj.ParentSizeListener);
            end
            if ~isempty(obj.RibbonHtml) && isvalid(obj.RibbonHtml)
                delete(obj.RibbonHtml);
            end
        end % delete
    end

end
