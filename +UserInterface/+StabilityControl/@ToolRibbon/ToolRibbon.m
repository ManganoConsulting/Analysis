classdef ToolRibbon < handle & UserInterface.GraphicsObject

    %% Version
    properties
        VersionNumber
        InternalVersionNumber
    end % Version

    %% Public properties - Object Handles
    properties (Transient = true)
        RibbonHtml matlab.ui.control.HTML
        ParentSizeChangedListener
    end % Public properties

    %% Public properties - Data Storage
    properties
        NumberOfPlotPerPageReq (1,1) double {mustBePositive} = 4
        NumberOfPlotPerPagePostSim (1,1) double {mustBePositive} = 4
        ShowLoggedSignalsState (1,1) logical = false
        ShowInvalidTrimState char = 'Show Valid Trims'
        UseAllCombinationsState (1,1) logical = true
        TrimSettings
        UnitsSelectionIndex (1,1) double {mustBeInteger,mustBePositive} = 1
    end % Public properties

    %% Private properties
    properties (Access = private)
        RibbonAssets struct = struct()
        RibbonReady (1,1) logical = false
    end % Private properties

    properties (Constant, Access = private)
        ShowTrimOptions cell = {'Show All Trims','Show Valid Trims','Show Invalid Trims'}
        UnitOptions cell = {'English - US','SI'}
    end

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
        function obj = ToolRibbon(parent, ver, internalver, trimOpt)

            obj.VersionNumber = ver;
            obj.InternalVersionNumber = internalver;
            obj.Parent = parent;
            obj.TrimSettings = trimOpt;

            panelPos = getpixelposition(obj.Parent);
            if isempty(panelPos)
                panelPos = [0 0 860 93];
            end
            width = max(panelPos(3), 1);
            height = max(panelPos(4), 1);

            obj.RibbonAssets = obj.buildRibbonAssets();
            obj.RibbonReady = false;

            obj.RibbonHtml = uihtml(obj.Parent, ...
                'HTMLSource', obj.buildRibbonHtml(), ...
                'Position', [0 0 width height]);
            obj.RibbonHtml.DataChangedFcn = @(~, evt)obj.handleRibbonEvent(evt.Data);

            obj.updateRibbonGeometry();

            try
                obj.ParentSizeChangedListener = addlistener(obj.Parent, 'SizeChanged', @(~, ~)obj.updateRibbonGeometry());
            catch
                obj.ParentSizeChangedListener = [];
            end
        end % ToolRibbon
    end % Constructor

    %% Methods - Property Access
    methods
        function setShowLoggedSignals(obj, state)
            obj.applyShowLogSignals(state, false);
        end % setShowLoggedSignals

        function setShowInvalidTrim(obj, state)
            label = obj.normalizeTrimSelection(state);
            obj.applyShowInvalidTrim(label, false);
        end % setShowInvalidTrim

        function setUseAllCombinations(obj, state)
            obj.applyUseAllCombinations(state, false);
        end % setUseAllCombinations

        function setUnitsSelectionIndex(obj, index)
            [label, idx] = obj.normalizeUnitsSelection(index);
            obj.applyUnitsSelection(label, idx, false);
        end % setUnitsSelectionIndex
    end % Property access methods

    %% Methods - Ordinary
    methods
        function createNewAnalysis_CB(obj, ~, ~)
            notify(obj, 'NewAnalysis');
        end % createNewAnalysis_CB

        function newTrimObj_CB(obj, ~, ~)
            notify(obj, 'NewTrimObject');
        end % newTrimObj_CB

        function newLinMdlObj_CB(obj, ~, ~)
            notify(obj, 'NewLinearModelObject');
        end % newLinMdlObj_CB

        function newMethodObj_CB(obj, ~, ~)
            notify(obj, 'NewMethodObject');
        end % newMethodObj_CB

        function newNonLinSimObj_CB(obj, ~, ~)
            notify(obj, 'NewSimulationReqObject');
        end % newNonLinSimObj_CB

        function newPostSimObj_CB(obj, ~, ~)
            notify(obj, 'NewPostSimulationReqObject');
        end % newPostSimObj_CB

        function openAnalysisObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Analysis'));
        end % openAnalysisObj_CB

        function openTrimObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Trim'));
        end % openTrimObj_CB

        function openLinMdlObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Linear Model'));
        end % openLinMdlObj_CB

        function openMethodObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Requirement'));
        end % openMethodObj_CB

        function openNonLinSimObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Simulation Requirement'));
        end % openNonLinSimObj_CB

        function openPostNonLinSimObj_CB(obj, ~, ~)
            notify(obj, 'OpenObject', GeneralEventData('Post Simulation Requirement'));
        end % openPostNonLinSimObj_CB

        function loadAnalysisObj_CB(obj, ~, ~)
            notify(obj, 'LoadAnalysisObject');
        end % loadAnalysisObj_CB

        function loadSimulation_CB(obj, ~, ~)
            notify(obj, 'LoadSimulation');
        end % loadSimulation_CB

        function loadWorkspace_CB(obj, ~, ~)
            notify(obj, 'LoadWorkspace');
        end % loadWorkspace_CB

        function batchAdd_CB(obj, ~, ~)
            notify(obj, 'Add2Batch');
        end % batchAdd_CB

        function batchRun_CB(obj, ~, ~)
            notify(obj, 'LoadBatchRun');
        end % batchRun_CB

        function saveOperCond_CB(obj, varargin)
            saveType = obj.parseNumericArgument(varargin{:});
            if isempty(saveType)
                saveType = 1;
            end
            notify(obj, 'SaveOperCond', GeneralEventData(saveType));
        end % saveOperCond_CB

        function saveWorkspace_CB(obj, ~, ~)
            notify(obj, 'SaveWorkspace');
        end % saveWorkspace_CB

        function run_CB(obj, ~, ~)
            notify(obj, 'Run');
        end % run_CB

        function runAndSave_CB(obj, ~, ~)
            notify(obj, 'RunSave');
        end % runAndSave_CB

        function generateReport_CB(obj, ~, ~, format)
            if nargin < 4 || isempty(format)
                format = 'PDF';
            end
            notify(obj, 'GenerateReport', UserInterface.UserInterfaceEventData(format));
        end % generateReport_CB

        function exportTable_CB(obj, ~, ~)
            notify(obj, 'ExportTable', UserInterface.UserInterfaceEventData('mat'));
        end % exportTable_CB

        function exportTableCSV_CB(obj, ~, ~)
            notify(obj, 'ExportTable', UserInterface.UserInterfaceEventData('csv'));
        end % exportTableCSV_CB

        function exportTableM_CB(obj, ~, ~)
            notify(obj, 'ExportTable', UserInterface.UserInterfaceEventData('m'));
        end % exportTableM_CB

        function clearTable_CB(obj, ~, ~)
            notify(obj, 'ClearTable');
        end % clearTable_CB

        function setNumPlotsPlts(obj, varargin)
            numbPlots = obj.parseNumericArgument(varargin{:});
            if isempty(numbPlots)
                return;
            end
            obj.NumberOfPlotPerPageReq = numbPlots;
            notify(obj, 'SetNumPlotsPlts', UserInterface.UserInterfaceEventData(numbPlots));
            obj.sendRibbonState();
        end % setNumPlotsPlts

        function setNumPlotsPostPlts(obj, varargin)
            numbPlots = obj.parseNumericArgument(varargin{:});
            if isempty(numbPlots)
                return;
            end
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            notify(obj, 'SetNumPlotsPostPlts', UserInterface.UserInterfaceEventData(numbPlots));
            obj.sendRibbonState();
        end % setNumPlotsPostPlts

        function setNumPlotsAll(obj, varargin)
            numbPlots = obj.parseNumericArgument(varargin{:});
            if isempty(numbPlots)
                return;
            end
            notify(obj, 'SetNumPlotsPlts', UserInterface.UserInterfaceEventData(numbPlots));
            drawnow(); pause(0.01);
            notify(obj, 'SetNumPlotsPostPlts', UserInterface.UserInterfaceEventData(numbPlots));
            obj.NumberOfPlotPerPageReq = numbPlots;
            obj.NumberOfPlotPerPagePostSim = numbPlots;
            obj.sendRibbonState();
        end % setNumPlotsAll

        function setTrimSettings(obj)
            if isempty(obj.TrimSettings)
                return;
            end
            obj.TrimSettings.createView();
            uiwait(obj.TrimSettings.Parent);
            notify(obj, 'TrimSettingsChanged', UserInterface.UserInterfaceEventData(obj.TrimSettings));
        end % setTrimSettings

        function delete(obj)
            if ~isempty(obj.ParentSizeChangedListener) && isvalid(obj.ParentSizeChangedListener)
                delete(obj.ParentSizeChangedListener);
            end
            obj.ParentSizeChangedListener = [];

            if ~isempty(obj.RibbonHtml) && isvalid(obj.RibbonHtml)
                delete(obj.RibbonHtml);
            end
            obj.RibbonHtml = [];
        end % delete
    end % Ordinary Methods

    %% Methods - Private
    methods (Access = private)
        function handleRibbonEvent(obj, payload)
            if ~isstruct(payload) || ~isfield(payload, 'type')
                return;
            end

            msgType = lower(string(payload.type));

            switch msgType
                case "ready"
                    obj.RibbonReady = true;
                    obj.sendRibbonConfig();
                    obj.sendRibbonState();

                case "action"
                    if ~isfield(payload, 'id')
                        return;
                    end
                    id = lower(string(payload.id));
                    mode = "";
                    if isfield(payload, 'mode') && ~isempty(payload.mode)
                        mode = lower(string(payload.mode));
                    end
                    command = "";
                    if isfield(payload, 'command') && ~isempty(payload.command)
                        command = lower(string(payload.command));
                    end
                    value = [];
                    if isfield(payload, 'value')
                        value = payload.value;
                    end
                    obj.dispatchAction(id, mode, command, value);

                case "select"
                    if ~isfield(payload, 'id') || ~isfield(payload, 'value')
                        return;
                    end
                    id = lower(string(payload.id));
                    switch id
                        case "showinvalidtrim"
                            label = obj.normalizeTrimSelection(payload.value);
                            obj.applyShowInvalidTrim(label, true);
                        case "units"
                            [label, idx] = obj.normalizeUnitsSelection(payload.value);
                            obj.applyUnitsSelection(label, idx, true);
                    end

                case "toggle"
                    if ~isfield(payload, 'id') || ~isfield(payload, 'value')
                        return;
                    end
                    id = lower(string(payload.id));
                    switch id
                        case "showlogsignals"
                            obj.applyShowLogSignals(payload.value, true);
                        case "useallcombinations"
                            obj.applyUseAllCombinations(payload.value, true);
                    end
            end
        end % handleRibbonEvent

        function dispatchAction(obj, id, mode, command, value)
            switch id
                case "new"
                    if strcmp(mode, "menu")
                        switch command
                            case "analysis"
                                obj.createNewAnalysis_CB([], []);
                            case "trim"
                                obj.newTrimObj_CB([], []);
                            case "linear-model"
                                obj.newLinMdlObj_CB([], []);
                            case "requirement"
                                obj.newMethodObj_CB([], []);
                            case "simulation"
                                obj.newNonLinSimObj_CB([], []);
                        end
                    else
                        obj.newTrimObj_CB([], []);
                    end

                case "open"
                    if strcmp(mode, "menu")
                        switch command
                            case "analysis"
                                obj.openAnalysisObj_CB([], []);
                            case "trim"
                                obj.openTrimObj_CB([], []);
                            case "linear-model"
                                obj.openLinMdlObj_CB([], []);
                            case "requirement"
                                obj.openMethodObj_CB([], []);
                            case "simulation"
                                obj.openNonLinSimObj_CB([], []);
                        end
                    else
                        obj.openTrimObj_CB([], []);
                    end

                case "load"
                    if strcmp(mode, "menu")
                        switch command
                            case "project"
                                obj.loadWorkspace_CB([], []);
                            case "analysis"
                                obj.loadAnalysisObj_CB([], []);
                        end
                    else
                        obj.loadWorkspace_CB([], []);
                    end

                case "save"
                    if strcmp(mode, "menu")
                        switch command
                            case "project"
                                obj.saveWorkspace_CB([], []);
                            case "oper-all"
                                obj.saveOperCond_CB([], [], [], 1);
                            case "oper-valid"
                                obj.saveOperCond_CB([], [], [], 0);
                        end
                    else
                        obj.saveWorkspace_CB([], []);
                    end

                case "run"
                    if strcmp(mode, "menu")
                        switch command
                            case "run"
                                obj.run_CB([], []);
                            case "run-save"
                                obj.runAndSave_CB([], []);
                        end
                    else
                        obj.runAndSave_CB([], []);
                    end

                case "addcases"
                    obj.batchAdd_CB([], []);

                case "tableoptions"
                    if strcmp(mode, "menu")
                        switch command
                            case "clear"
                                obj.clearTable_CB([], []);
                            case "export-mat"
                                obj.exportTable_CB([], []);
                            case "export-csv"
                                obj.exportTableCSV_CB([], []);
                            case "export-m"
                                obj.exportTableM_CB([], []);
                        end
                    else
                        obj.clearTable_CB([], []);
                    end

                case "generatereport"
                    if strcmp(mode, "menu")
                        switch command
                            case "report-pdf"
                                obj.generateReport_CB([], [], 'PDF');
                            case "report-word"
                                obj.generateReport_CB([], [], 'MS Word');
                        end
                    else
                        obj.generateReport_CB([], [], 'PDF');
                    end

                case "editor-task"
                    obj.createNewAnalysis_CB([], []);
                case "editor-trim"
                    obj.newTrimObj_CB([], []);
                case "editor-model"
                    obj.newLinMdlObj_CB([], []);
                case "editor-req"
                    obj.newMethodObj_CB([], []);
                case "editor-sim"
                    obj.newNonLinSimObj_CB([], []);

                case "settings"
                    if strcmp(mode, "menu")
                        switch command
                            case "plots-all"
                                val = obj.parseNumericArgument(value);
                                if ~isempty(val)
                                    obj.setNumPlotsAll(val);
                                end
                            case "plots-req"
                                val = obj.parseNumericArgument(value);
                                if ~isempty(val)
                                    obj.setNumPlotsPlts(val);
                                end
                            case "plots-post"
                                val = obj.parseNumericArgument(value);
                                if ~isempty(val)
                                    obj.setNumPlotsPostPlts(val);
                                end
                            case "trim-settings"
                                obj.setTrimSettings();
                        end
                    end
            end
        end % dispatchAction

        function sendRibbonConfig(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml)
                return;
            end

            payload = struct( ...
                'type', 'init', ...
                'icons', obj.RibbonAssets, ...
                'state', obj.captureRibbonState());

            obj.RibbonHtml.Data = payload;
        end % sendRibbonConfig

        function sendRibbonState(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml) || ~obj.RibbonReady
                return;
            end

            payload = struct( ...
                'type', 'state', ...
                'state', obj.captureRibbonState());

            obj.RibbonHtml.Data = payload;
        end % sendRibbonState

        function state = captureRibbonState(obj)
            state = struct();
            state.showLogSignals = logical(obj.ShowLoggedSignalsState);
            state.useAllCombinations = logical(obj.UseAllCombinationsState);
            state.showInvalidTrim = obj.ShowInvalidTrimState;
            state.units = obj.UnitOptions{obj.UnitsSelectionIndex};

            if obj.NumberOfPlotPerPageReq == obj.NumberOfPlotPerPagePostSim
                state.plotsAll = obj.NumberOfPlotPerPageReq;
            else
                state.plotsAll = 0;
            end
            state.plotsReq = obj.NumberOfPlotPerPageReq;
            state.plotsPost = obj.NumberOfPlotPerPagePostSim;
        end % captureRibbonState

        function updateRibbonGeometry(obj)
            if isempty(obj.Parent) || ~isvalid(obj.Parent) || isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml)
                return;
            end

            panelPos = getpixelposition(obj.Parent);
            if isempty(panelPos)
                panelPos = [0 0 1 1];
            end
            width = max(panelPos(3), 1);
            height = max(panelPos(4), 1);
            obj.RibbonHtml.Position = [0 0 width height];
        end % updateRibbonGeometry

        function [label, idx] = normalizeUnitsSelection(obj, value)
            opts = obj.UnitOptions;
            n = numel(opts);
            idx = 1;

            if isnumeric(value)
                val = double(value);
                if val >= 0 && val < n && abs(val - round(val)) < eps
                    idx = round(val) + 1;
                else
                    idx = min(max(round(val), 1), n);
                end
            else
                str = char(string(value));
                match = find(strcmpi(str, opts), 1, 'first');
                if ~isempty(match)
                    idx = match;
                end
            end

            label = opts{idx};
        end % normalizeUnitsSelection

        function label = normalizeTrimSelection(obj, value)
            opts = obj.ShowTrimOptions;
            idx = 2;
            if isnumeric(value)
                val = double(value);
                if val >= 0 && val < numel(opts) && abs(val - round(val)) < eps
                    idx = round(val) + 1;
                else
                    idx = min(max(round(val), 1), numel(opts));
                end
            else
                str = char(string(value));
                match = find(strcmpi(str, opts), 1, 'first');
                if ~isempty(match)
                    idx = match;
                end
            end
            label = opts{idx};
        end % normalizeTrimSelection

        function applyShowLogSignals(obj, value, triggerEvent)
            newValue = logical(value);
            obj.ShowLoggedSignalsState = newValue;
            if triggerEvent
                notify(obj, 'ShowLogSignals', GeneralEventData(newValue));
            end
            obj.sendRibbonState();
        end % applyShowLogSignals

        function applyUseAllCombinations(obj, value, triggerEvent)
            newValue = logical(value);
            obj.UseAllCombinationsState = newValue;
            if triggerEvent
                notify(obj, 'UseAllCombinations', GeneralEventData(newValue));
            end
            obj.sendRibbonState();
        end % applyUseAllCombinations

        function applyShowInvalidTrim(obj, label, triggerEvent)
            obj.ShowInvalidTrimState = char(label);
            if triggerEvent
                notify(obj, 'ShowTrimsChanged', UserInterface.UserInterfaceEventData(obj.ShowInvalidTrimState));
            end
            obj.sendRibbonState();
        end % applyShowInvalidTrim

        function applyUnitsSelection(obj, label, idx, triggerEvent)
            obj.UnitsSelectionIndex = idx;
            if triggerEvent
                notify(obj, 'UnitsChanged', UserInterface.UserInterfaceEventData(char(label)));
            end
            obj.sendRibbonState();
        end % applyUnitsSelection

        function value = parseNumericArgument(~, varargin)
            value = [];
            if isempty(varargin)
                return;
            end
            candidate = varargin{end};
            if ischar(candidate) || isstring(candidate)
                candidate = str2double(candidate);
            end
            if isnumeric(candidate) && isscalar(candidate) && ~isnan(candidate)
                value = double(candidate);
            end
        end % parseNumericArgument

        function html = buildRibbonHtml(obj)
            %#ok<*NASGU>
            lines = {
                '<!doctype html>'
                '<html lang="en">'
                '<head>'
                '<meta charset="utf-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1">'
                '<style>'
                ':root{' ...
                    'color-scheme:dark;' ...
                    '--ribbon-top:#2d3036;' ...
                    '--ribbon-bottom:#212328;' ...
                    '--group-bg:#363a41;' ...
                    '--group-border:#4a4f58;' ...
                    '--tile-top:#454a55;' ...
                    '--tile-bottom:#2f3238;' ...
                    '--tile-hover:#505664;' ...
                    '--tile-active:#1f6feb;' ...
                    '--tile-border:#5b6070;' ...
                    '--text:#f4f5f7;' ...
                    '--muted:#b4b8bf;' ...
                    '--menu-bg:#272b32;' ...
                    '--menu-border:#434852;' ...
                    '--menu-hover:#343944;' ...
                    '--control-bg:#1d2025;' ...
                    '--accent:#1f6feb;' ...
                    '--checkbox-bg:#111318;' ...
                '}'
                'html,body{margin:0;height:100%;background:transparent;font-family:"Segoe UI",Tahoma,Arial,sans-serif;font-size:12px;color:var(--text);}'
                '.ribbon{position:absolute;inset:0;display:flex;gap:12px;align-items:flex-start;padding:6px 12px 10px;background:linear-gradient(180deg,var(--ribbon-top),var(--ribbon-bottom));box-sizing:border-box;overflow-x:auto;overflow-y:hidden;}'
                '.group{display:flex;flex-direction:column;min-width:150px;padding:8px 10px 10px;background:linear-gradient(180deg,rgba(255,255,255,0.06),rgba(255,255,255,0));border:1px solid var(--group-border);border-radius:8px;box-shadow:inset 0 1px 0 rgba(255,255,255,0.06);}'
                '.group .controls{display:flex;gap:10px;align-items:flex-start;flex-wrap:nowrap;}'
                '.group .controls.column{flex-direction:column;gap:10px;}'
                '.group-label{text-transform:uppercase;letter-spacing:1px;font-size:10px;color:var(--muted);text-align:center;margin-top:6px;}'
                '.control{position:relative;display:flex;flex-direction:column;align-items:center;gap:2px;}'
                '.control.horizontal{flex-direction:row;align-items:stretch;}'
                '.control.horizontal .btn.line{flex:1;}'
                '.btn{font:inherit;color:inherit;background:none;border:none;padding:0;margin:0;cursor:pointer;}'
                '.btn.tile{width:74px;height:72px;background:linear-gradient(180deg,var(--tile-top),var(--tile-bottom));border:1px solid rgba(255,255,255,0.08);border-radius:6px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;box-shadow:0 1px 3px rgba(0,0,0,0.45);transition:background .12s,border-color .12s,box-shadow .12s;}'
                '.btn.tile:hover{background:linear-gradient(180deg,var(--tile-hover),var(--tile-bottom));border-color:rgba(31,111,235,0.6);box-shadow:0 0 0 1px rgba(31,111,235,0.35) inset,0 2px 6px rgba(0,0,0,0.35);}'
                '.btn.tile:active{background:linear-gradient(180deg,var(--tile-active),#184d96);box-shadow:0 0 0 1px rgba(31,111,235,0.5) inset;}'
                '.btn.drop{width:74px;height:18px;border:1px solid rgba(255,255,255,0.08);border-radius:4px;background:linear-gradient(180deg,var(--tile-top),var(--tile-bottom));display:flex;align-items:center;justify-content:center;box-shadow:0 1px 2px rgba(0,0,0,0.35);}'
                '.btn.drop:hover{background:linear-gradient(180deg,var(--tile-hover),var(--tile-bottom));border-color:rgba(31,111,235,0.6);}'
                '.btn.line{min-width:150px;height:36px;padding:0 12px;background:linear-gradient(180deg,var(--tile-top),var(--tile-bottom));border:1px solid rgba(255,255,255,0.08);border-radius:6px;display:flex;align-items:center;gap:8px;justify-content:flex-start;box-shadow:0 1px 3px rgba(0,0,0,0.45);}'
                '.btn.line:hover{background:linear-gradient(180deg,var(--tile-hover),var(--tile-bottom));border-color:rgba(31,111,235,0.6);}'
                '.btn.line .caret-inline{margin-left:auto;}'
                '.icon-wrap{width:40px;height:40px;border-radius:8px;background:linear-gradient(180deg,#4e5460,#2f3238);display:flex;align-items:center;justify-content:center;box-shadow:inset 0 1px 0 rgba(255,255,255,0.08);}'
                '.icon-wrap img{width:28px;height:28px;image-rendering:-webkit-optimize-contrast;}'
                '.icon-small{width:20px;height:20px;display:flex;align-items:center;justify-content:center;}'
                '.icon-small img{width:18px;height:18px;}'
                '.label{font-size:11px;font-weight:600;letter-spacing:0.4px;text-transform:uppercase;text-align:center;}'
                '.btn.line .label{text-transform:none;font-size:12px;font-weight:500;letter-spacing:0.2px;}'
                '.caret{width:0;height:0;border-left:5px solid transparent;border-right:5px solid transparent;border-top:6px solid var(--text);}'
                '.menu{position:absolute;top:100%;left:0;margin-top:4px;display:none;min-width:200px;background:var(--menu-bg);border:1px solid var(--menu-border);border-radius:8px;box-shadow:0 12px 28px rgba(0,0,0,0.45);padding:6px 0;z-index:200;}'
                '.menu.open{display:block;}'
                '.menu-item{width:100%;display:flex;align-items:center;gap:10px;padding:6px 14px;background:none;border:none;color:inherit;font:inherit;text-align:left;cursor:pointer;}'
                '.menu-item:hover{background:var(--menu-hover);}'
                '.menu-icon{width:18px;height:18px;display:flex;align-items:center;justify-content:center;}'
                '.menu-icon img{width:16px;height:16px;}'
                '.menu-text{flex:1;white-space:nowrap;}'
                '.menu-divider{height:1px;background:rgba(255,255,255,0.08);margin:6px 0;}'
                '.menu-title{font-size:11px;text-transform:uppercase;letter-spacing:0.6px;color:var(--muted);padding:4px 14px 2px;}'
                '.menu-subtitle{font-size:11px;color:var(--muted);padding:4px 14px 2px;}'
                '.menu-item.checkable::before{content:"";display:inline-block;width:12px;height:12px;border:1px solid rgba(255,255,255,0.3);border-radius:3px;margin-right:8px;background:var(--checkbox-bg);}'
                '.menu-item.checkable.checked::before{background:var(--accent);border-color:var(--accent);}'
                '.field{display:flex;flex-direction:column;gap:4px;width:160px;}'
                '.field-label{text-transform:uppercase;letter-spacing:0.5px;font-size:10px;color:var(--muted);}'
                'select{background:var(--control-bg);color:var(--text);border:1px solid var(--group-border);border-radius:4px;padding:4px 6px;font:inherit;}'
                'select:focus{outline:1px solid var(--accent);}'
                'option{background:var(--control-bg);color:var(--text);}'
                '.toggle{display:flex;align-items:center;gap:8px;font-size:12px;}'
                '.toggle input[type="checkbox"]{width:14px;height:14px;margin:0;border:1px solid var(--group-border);border-radius:3px;background:var(--checkbox-bg);-webkit-appearance:none;appearance:none;position:relative;}'
                '.toggle input[type="checkbox"]:checked{background:var(--accent);border-color:var(--accent);}'
                '.toggle input[type="checkbox"]:checked::after{content:"";position:absolute;top:2px;left:4px;width:4px;height:8px;border:2px solid #fff;border-top:none;border-left:none;transform:rotate(45deg);}'
                '.control.menu-open .btn.tile, .control.menu-open .btn.line{border-color:rgba(31,111,235,0.8);box-shadow:0 0 0 1px rgba(31,111,235,0.4) inset,0 2px 8px rgba(0,0,0,0.35);}'
                '.control.menu-open .btn.drop{border-color:rgba(31,111,235,0.8);}'
                '</style>'
                '</head>'
                '<body>'
                '<div class="ribbon" id="ribbonRoot">'
                '  <div class="group" data-group="file">'
                '    <div class="controls">'
                '      <div class="control split" data-control="new" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="new" alt="New"></span>'
                '          <span class="label">New</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="New options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="analysis">'
                '            <span class="menu-icon"><img data-icon="analysis" alt=""></span>'
                '            <span class="menu-text">Task</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="trim">'
                '            <span class="menu-icon"><img data-icon="trim" alt=""></span>'
                '            <span class="menu-text">Trim</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="linear-model">'
                '            <span class="menu-icon"><img data-icon="model" alt=""></span>'
                '            <span class="menu-text">Linear Model</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="requirement">'
                '            <span class="menu-icon"><img data-icon="requirement" alt=""></span>'
                '            <span class="menu-text">Requirement</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="simulation">'
                '            <span class="menu-icon"><img data-icon="simulation" alt=""></span>'
                '            <span class="menu-text">Simulation Requirement</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '      <div class="control split" data-control="open" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="open" alt="Open"></span>'
                '          <span class="label">Open</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Open options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="analysis">'
                '            <span class="menu-icon"><img data-icon="analysis" alt=""></span>'
                '            <span class="menu-text">Task</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="trim">'
                '            <span class="menu-icon"><img data-icon="trim" alt=""></span>'
                '            <span class="menu-text">Trim</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="linear-model">'
                '            <span class="menu-icon"><img data-icon="model" alt=""></span>'
                '            <span class="menu-text">Linear Model</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="requirement">'
                '            <span class="menu-icon"><img data-icon="requirement" alt=""></span>'
                '            <span class="menu-text">Requirement</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="simulation">'
                '            <span class="menu-icon"><img data-icon="simulation" alt=""></span>'
                '            <span class="menu-text">Simulation Requirement</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '      <div class="control split" data-control="load" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="load" alt="Load"></span>'
                '          <span class="label">Load</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Load options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="project">'
                '            <span class="menu-icon"><img data-icon="loadProject" alt=""></span>'
                '            <span class="menu-text">Project</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="analysis">'
                '            <span class="menu-icon"><img data-icon="analysis" alt=""></span>'
                '            <span class="menu-text">Task</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '      <div class="control split" data-control="save" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="save" alt="Save"></span>'
                '          <span class="label">Save</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Save options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="project">'
                '            <span class="menu-icon"><img data-icon="saveProject" alt=""></span>'
                '            <span class="menu-text">Save Project</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="oper-all">'
                '            <span class="menu-icon"><img data-icon="save" alt=""></span>'
                '            <span class="menu-text">Save Operating Conditions (All)</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="oper-valid">'
                '            <span class="menu-icon"><img data-icon="save" alt=""></span>'
                '            <span class="menu-text">Save Operating Conditions (Valid)</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">File</div>'
                '  </div>'
                '  <div class="group" data-group="run">'
                '    <div class="controls">'
                '      <div class="control split" data-control="run" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="run" alt="Run"></span>'
                '          <span class="label">Run</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Run options">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="run">'
                '            <span class="menu-icon"><img data-icon="runOnly" alt=""></span>'
                '            <span class="menu-text">Run</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="run-save">'
                '            <span class="menu-icon"><img data-icon="run" alt=""></span>'
                '            <span class="menu-text">Run and Save</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Run</div>'
                '  </div>'
                '  <div class="group" data-group="actions">'
                '    <div class="controls column">'
                '      <div class="control horizontal" data-control="addCases" data-behavior="primary-action">'
                '        <button type="button" class="btn line" data-role="primary">'
                '          <span class="icon-small"><img data-icon="addCases" alt=""></span>'
                '          <span class="label">Add New Run Cases</span>'
                '        </button>'
                '      </div>'
                '      <div class="control horizontal split" data-control="tableOptions" data-behavior="primary-action">'
                '        <button type="button" class="btn line" data-role="primary">'
                '          <span class="icon-small"><img data-icon="table" alt=""></span>'
                '          <span class="label">Table Options</span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Table options menu">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="clear">'
                '            <span class="menu-icon"><img data-icon="table" alt=""></span>'
                '            <span class="menu-text">Clear Table</span>'
                '          </button>'
                '          <div class="menu-divider"></div>'
                '          <button type="button" class="menu-item" data-command="export-mat">'
                '            <span class="menu-icon"><img data-icon="export" alt=""></span>'
                '            <span class="menu-text">Export to MAT</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="export-csv">'
                '            <span class="menu-icon"><img data-icon="export" alt=""></span>'
                '            <span class="menu-text">Export to CSV</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="export-m">'
                '            <span class="menu-icon"><img data-icon="export" alt=""></span>'
                '            <span class="menu-text">Export to M Script</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '      <div class="control horizontal split" data-control="generateReport" data-behavior="menu-only">'
                '        <button type="button" class="btn line" data-role="primary">'
                '          <span class="icon-small"><img data-icon="report" alt=""></span>'
                '          <span class="label">Generate Report</span>'
                '          <span class="caret caret-inline"></span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Report formats">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <button type="button" class="menu-item" data-command="report-pdf">'
                '            <span class="menu-icon"><img data-icon="report" alt=""></span>'
                '            <span class="menu-text">PDF</span>'
                '          </button>'
                '          <button type="button" class="menu-item" data-command="report-word">'
                '            <span class="menu-icon"><img data-icon="report" alt=""></span>'
                '            <span class="menu-text">MS Word</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Actions</div>'
                '  </div>'
                '  <div class="group" data-group="editor">'
                '    <div class="controls">'
                '      <div class="control" data-control="editor-task" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="analysis" alt=""></span>'
                '          <span class="label">Task</span>'
                '        </button>'
                '      </div>'
                '      <div class="control" data-control="editor-trim" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="trim" alt=""></span>'
                '          <span class="label">Trim</span>'
                '        </button>'
                '      </div>'
                '      <div class="control" data-control="editor-model" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="model" alt=""></span>'
                '          <span class="label">Model</span>'
                '        </button>'
                '      </div>'
                '      <div class="control" data-control="editor-req" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="requirement" alt=""></span>'
                '          <span class="label">Req</span>'
                '        </button>'
                '      </div>'
                '      <div class="control" data-control="editor-sim" data-behavior="primary-action">'
                '        <button type="button" class="btn tile" data-role="primary">'
                '          <span class="icon-wrap"><img data-icon="simulation" alt=""></span>'
                '          <span class="label">Sim</span>'
                '        </button>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Editor</div>'
                '  </div>'
                '  <div class="group" data-group="options">'
                '    <div class="controls column">'
                '      <label class="field">'
                '        <span class="field-label">Show Trims</span>'
                '        <select id="showInvalidTrim">'
                '          <option value="Show All Trims">Show All Trims</option>'
                '          <option value="Show Valid Trims">Show Valid Trims</option>'
                '          <option value="Show Invalid Trims">Show Invalid Trims</option>'
                '        </select>'
                '      </label>'
                '      <label class="toggle">'
                '        <input type="checkbox" id="toggleShowLog">'
                '        <span>Display Log Signals</span>'
                '      </label>'
                '      <label class="toggle">'
                '        <input type="checkbox" id="toggleUseAll">'
                '        <span>Use All Combinations</span>'
                '      </label>'
                '    </div>'
                '    <div class="group-label">Options</div>'
                '  </div>'
                '  <div class="group" data-group="settings">'
                '    <div class="controls column">'
                '      <label class="field">'
                '        <span class="field-label">Units</span>'
                '        <select id="unitsSelect">'
                '          <option value="English - US">English - US</option>'
                '          <option value="SI">SI</option>'
                '        </select>'
                '      </label>'
                '      <div class="control horizontal split" data-control="settings" data-behavior="menu-only">'
                '        <button type="button" class="btn line" data-role="primary">'
                '          <span class="icon-small"><img data-icon="settings" alt=""></span>'
                '          <span class="label">Settings</span>'
                '          <span class="caret caret-inline"></span>'
                '        </button>'
                '        <button type="button" class="btn drop" data-role="menu" aria-label="Settings menu">'
                '          <span class="caret"></span>'
                '        </button>'
                '        <div class="menu" role="menu">'
                '          <div class="menu-title">Plots per Page</div>'
                '          <div class="menu-subtitle">All</div>'
                '          <button type="button" class="menu-item checkable" data-command="plots-all" data-value="1">'
                '            <span class="menu-text">1</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-all" data-value="2">'
                '            <span class="menu-text">2</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-all" data-value="4">'
                '            <span class="menu-text">4</span>'
                '          </button>'
                '          <div class="menu-divider"></div>'
                '          <div class="menu-subtitle">Requirements</div>'
                '          <button type="button" class="menu-item checkable" data-command="plots-req" data-value="1">'
                '            <span class="menu-text">1</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-req" data-value="2">'
                '            <span class="menu-text">2</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-req" data-value="4">'
                '            <span class="menu-text">4</span>'
                '          </button>'
                '          <div class="menu-divider"></div>'
                '          <div class="menu-subtitle">Post Simulation</div>'
                '          <button type="button" class="menu-item checkable" data-command="plots-post" data-value="1">'
                '            <span class="menu-text">1</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-post" data-value="2">'
                '            <span class="menu-text">2</span>'
                '          </button>'
                '          <button type="button" class="menu-item checkable" data-command="plots-post" data-value="4">'
                '            <span class="menu-text">4</span>'
                '          </button>'
                '          <div class="menu-divider"></div>'
                '          <button type="button" class="menu-item" data-command="trim-settings">'
                '            <span class="menu-icon"><img data-icon="settings" alt=""></span>'
                '            <span class="menu-text">Trim Settings</span>'
                '          </button>'
                '        </div>'
                '      </div>'
                '    </div>'
                '    <div class="group-label">Settings</div>'
                '  </div>'
                '</div>'
                '<script>'
                '(function(){'
                '  const matlab = window.parent;'
                '  const controls = document.querySelectorAll(".control");'
                '  function postMessageToMatlab(payload){'
                '    if(matlab && typeof matlab.postMessage === "function"){'
                '      matlab.postMessage(payload, "*");'
                '    }'
                '  }'
                '  function closeMenus(except){'
                '    document.querySelectorAll(".menu.open").forEach(menu => {'
                '      if(menu !== except){'
                '        menu.classList.remove("open");'
                '        const parent = menu.closest(".control");'
                '        if(parent){parent.classList.remove("menu-open");}'
                '      }'
                '    });'
                '  }'
                '  function toggleMenu(control, menu){'
                '    if(!menu){return;}'
                '    const willOpen = !menu.classList.contains("open");'
                '    closeMenus(willOpen ? menu : null);'
                '    if(willOpen){'
                '      menu.classList.add("open");'
                '      if(control){control.classList.add("menu-open");}'
                '    } else {'
                '      menu.classList.remove("open");'
                '      if(control){control.classList.remove("menu-open");}'
                '    }'
                '  }'
                '  controls.forEach(control => {'
                '    const id = control.dataset.control || "";'
                '    const behavior = control.dataset.behavior || "primary-action";'
                '    const primary = control.querySelector('[data-role="primary"]');'
                '    const menuButton = control.querySelector('[data-role="menu"]');'
                '    const menu = control.querySelector(".menu");'
                '    if(primary){'
                '      if(behavior === "menu-only") {'
                '        primary.addEventListener("click", event => {'
                '          event.stopPropagation();'
                '          toggleMenu(control, menu);'
                '        });'
                '      } else {'
                '        primary.addEventListener("click", () => {'
                '          postMessageToMatlab({type:"action", id:id, mode:"primary"});'
                '        });'
                '      }'
                '    }'
                '    if(menuButton){'
                '      menuButton.addEventListener("click", event => {'
                '        event.stopPropagation();'
                '        toggleMenu(control, menu);'
                '      });'
                '    }'
                '    if(menu){'
                '      menu.addEventListener("click", event => {'
                '        const item = event.target.closest(".menu-item");'
                '        if(!item){return;}'
                '        const command = item.dataset.command || "";'
                '        const value = item.dataset.value || "";'
                '        postMessageToMatlab({type:"action", id:id, mode:"menu", command:command, value:value});'
                '        menu.classList.remove("open");'
                '        control.classList.remove("menu-open");'
                '      });'
                '    }'
                '  });'
                '  document.addEventListener("click", event => {'
                '    if(!event.target.closest(".menu") && !event.target.closest(".control")) {'
                '      closeMenus();'
                '    }'
                '  });'
                '  const showInvalid = document.getElementById("showInvalidTrim");'
                '  const showLog = document.getElementById("toggleShowLog");'
                '  const useAll = document.getElementById("toggleUseAll");'
                '  const unitsSelect = document.getElementById("unitsSelect");'
                '  function updatePlotSelection(command, value){'
                '    const target = String(value || "");'
                '    document.querySelectorAll(`.menu-item[data-command="${command}"]`).forEach(item => {'
                '      const itemValue = String(item.dataset.value || "");'
                '      item.classList.toggle("checked", itemValue === target && target !== "");'
                '    });'
                '  }'
                '  function applyState(state){'
                '    if(!state){return;}'
                '    if(showInvalid && state.showInvalidTrim){'
                '      showInvalid.value = state.showInvalidTrim;'
                '    }'
                '    if(showLog && typeof state.showLogSignals === "boolean"){'
                '      showLog.checked = state.showLogSignals;'
                '    }'
                '    if(useAll && typeof state.useAllCombinations === "boolean"){'
                '      useAll.checked = state.useAllCombinations;'
                '    }'
                '    if(unitsSelect && state.units){'
                '      unitsSelect.value = state.units;'
                '    }'
                '    updatePlotSelection("plots-all", state.plotsAll || "");'
                '    updatePlotSelection("plots-req", state.plotsReq || "");'
                '    updatePlotSelection("plots-post", state.plotsPost || "");'
                '  }'
                '  if(showInvalid){'
                '    showInvalid.addEventListener("change", () => {'
                '      postMessageToMatlab({type:"select", id:"showInvalidTrim", value:showInvalid.value});'
                '    });'
                '  }'
                '  if(showLog){'
                '    showLog.addEventListener("change", () => {'
                '      postMessageToMatlab({type:"toggle", id:"showLogSignals", value:showLog.checked});'
                '    });'
                '  }'
                '  if(useAll){'
                '    useAll.addEventListener("change", () => {'
                '      postMessageToMatlab({type:"toggle", id:"useAllCombinations", value:useAll.checked});'
                '    });'
                '  }'
                '  if(unitsSelect){'
                '    unitsSelect.addEventListener("change", () => {'
                '      postMessageToMatlab({type:"select", id:"units", value:unitsSelect.value});'
                '    });'
                '  }'
                '  function applyIcons(icons){'
                '    if(!icons){return;}'
                '    document.querySelectorAll("img[data-icon]").forEach(img => {'
                '      const key = img.dataset.icon;
                '      if(key && icons[key]){'
                '        img.src = icons[key];'
                '      }
                '    });'
                '  }'
                '  window.addEventListener("message", event => {'
                '    const data = event.data || {};
                '    if(data.type === "init"){'
                '      applyIcons(data.icons || {});'
                '      applyState(data.state || {});'
                '    } else if(data.type === "state"){'
                '      applyState(data.state || {});'
                '    }
                '  });'
                '  window.addEventListener("DOMContentLoaded", () => {'
                '    setTimeout(() => postMessageToMatlab({type:"ready"}), 0);'
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
            assets.runOnly = obj.encodeIcon(fullfile(iconDir,'Run_24.png'));
            assets.addCases = obj.encodeIcon(fullfile(iconDir,'New_16.png'));
            assets.table = obj.encodeIcon(fullfile(iconDir,'Clean_16.png'));
            assets.report = obj.encodeIcon(fullfile(iconDir,'report_app_24.png'));
            assets.analysis = obj.encodeIcon(fullfile(iconDir,'Analysis_24.png'));
            assets.trim = obj.encodeIcon(fullfile(iconDir,'airplaneTrim_24.png'));
            assets.model = obj.encodeIcon(fullfile(iconDir,'linmdl_24.png'));
            assets.requirement = obj.encodeIcon(fullfile(iconDir,'InOut_24.png'));
            assets.simulation = obj.encodeIcon(fullfile(iconDir,'Simulink_24.png'));
            assets.settings = obj.encodeIcon(fullfile(iconDir,'Settings_16.png'));
            assets.export = obj.encodeIcon(fullfile(iconDir,'Export_24.png'));
            assets.saveProject = obj.encodeIcon(fullfile(iconDir,'SaveProject_24.png'));
            assets.loadProject = obj.encodeIcon(fullfile(iconDir,'LoadProject_24.png'));

            fields = fieldnames(assets);
            for i = 1:numel(fields)
                key = fields{i};
                if isempty(assets.(key))
                    assets.(key) = '';
                end
            end
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

            [~, ~, ext] = fileparts(filename);
            switch lower(ext)
                case {'.png'}
                    mime = 'image/png';
                case {'.jpg','.jpeg'}
                    mime = 'image/jpeg';
                case {'.gif'}
                    mime = 'image/gif';
                otherwise
                    mime = 'application/octet-stream';
            end

            encoded = matlab.net.base64encode(data);
            uri = ['data:' mime ';base64,' encoded];
        end % encodeIcon
    end % Private methods

end
