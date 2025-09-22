function createToolRibbon(obj)
%CREATETOOLRIBBON Render the Analysis tool ribbon using uihtml with the
% ControlDesign theme and event plumbing, preserving the Analysis layout
% defined by @ToolRibbon/ToolRibbon.m.
%
% This method builds a uihtml-based ribbon with the same CSS, DOM patterns,
% and HTML<->MATLAB bridge style as the working ControlDesign ribbon
% (+UserInterface/+ControlDesign/@ControlDesignGUI/createToolRibbion.m),
% but it preserves the group/order/structure of the Analysis ribbon as
% implemented in +UserInterface/+StabilityControl/@ToolRibbon/ToolRibbon.m.
%
% HTML -> MATLAB event schema (mirrors ControlDesign & Analysis ToolRibbon):
%   - type:"ready"                       : HTML is ready; MATLAB should send config/state
%   - type:"menuopen", menu, rect        : Request to open a dropdown at the given rect
%   - type:"command", command, option?   : Primary button or menu command
%   - type:"toggle", target, value       : Checkbox toggles (showLog, useAll)
%   - type:"select", target, value       : Select inputs (showInvalid, units)
%   - type:"request", subject:"state"    : Ask MATLAB to resend state
%
% MATLAB -> HTML messages:
%   - struct('type','config','icons',assets)   : icon data-URIs
%   - struct('type','state','state',state)     : state sync
%
% Stored state on MATLAB side (obj.ToolRibbonState):
%   struct with fields:
%     showLogSignals      logical
%     useAllCombinations  logical
%     showInvalidTrim     char ('Show All Trims'|'Show Valid Trims'|'Show Invalid Trims')
%     units               char ('English - US'|'SI')
%     numPlotsReq         double (1|2|4)
%     numPlotsPost        double (1|2|4)
%     numPlotsAll         double (0|1|2|4) % 0 means mixed

    % Determine sizes
    parentPos = getpixelposition(obj.RibbonPanel);
    if isempty(parentPos)
        parentPos = [0 0 860 93];
    end
    width  = max(parentPos(3), 1);
    height = max(parentPos(4), 1);

    % Prepare icons once
    assets = buildRibbonAssets();

    % Build HTML
    html = buildRibbonHtml();

    % Create uihtml
    if ~isempty(obj.ToolRibbonHtml) && isvalid(obj.ToolRibbonHtml)
        try delete(obj.ToolRibbonHtml); end %#ok<TRYNC>
    end

    try
        obj.ToolRibbonHtml = uihtml(obj.RibbonPanel, ...
            'HTMLSource', html, ...
            'Position', [0 0 width height]);
        obj.ToolRibbonHtml.DataChangedFcn = @(~,evt)handleRibbonEvent(evt.Data);
    catch err
        % Graceful fallback if uihtml creation fails
        warning('Main:createToolRibbon:HtmlFailed','Failed to initialize HTML ribbon: %s', err.message);
        try
            uilabel('Parent',obj.RibbonPanel, 'Text','Ribbon failed to load', ...
                'FontColor',[1 1 1], 'BackgroundColor',[0.2 0.2 0.2], ...
                'HorizontalAlignment','center', 'Units','pixels', 'Position',[0 0 width height]);
        catch
        end
        return;
    end

    % Listen to parent size change to keep geometry stable
    try
        if ~isempty(obj.ToolRibbonParentSizeListener) && isvalid(obj.ToolRibbonParentSizeListener)
            delete(obj.ToolRibbonParentSizeListener);
        end
    catch
    end
    try
        obj.ToolRibbonParentSizeListener = addlistener(obj.RibbonPanel,'SizeChanged',@(~,~)updateRibbonGeometry());
    catch
        obj.ToolRibbonParentSizeListener = [];
    end

    % Initialize state from Main properties
    obj.ToolRibbonState = struct( ...
        'showLogSignals',      logical(obj.ShowLoggedSignalsState), ...
        'useAllCombinations',  logical(obj.UseAllCombinationsState), ...
        'showInvalidTrim',     resolveTrimState(obj.ShowInvalidTrimState), ...
        'units',               char(obj.Units), ...
        'numPlotsReq',         double(obj.NumberOfPlotPerPagePlts), ...
        'numPlotsPost',        double(obj.NumberOfPlotPerPagePostPlts), ...
        'numPlotsAll',         double( pickAllPlotsValue(obj.NumberOfPlotPerPagePlts, obj.NumberOfPlotPerPagePostPlts) ));

    % Send initial config + state (HTML may queue until ready)
    sendRibbonConfig();
    sendRibbonState();

    % --- Mapping table: Analysis ToolRibbon -> HTML IDs/Commands ---
    % Groups (Order):
    %   File:    New, Open, Load, Save (all split)
    %   Run:     Auto Run Cases (split: Run / Run and Save), Add New Run Cases
    %   Actions: Table Options (split menu), Generate Report (split menu)
    %   Options: Trim Visibility select, Display Log Signals (checkbox), Use All Combinations (checkbox)
    %   Settings: Units select, Settings (split menu for Trim Settings and Plots Per Page)
    %
    % Command routing (command, option):
    %   new, analysis|trim|model|requirement|simulation   -> newAnalysisObj_CB/newTrimObj_CB/newLinMdlObj_CB/newMethodObj_CB/newSimulationObj_CB
    %   open, analysis|trim|model|requirement|simulation  -> openObjInEditor_CB(GeneralEventData(...))
    %   load, project|task                               -> loadWorkspace / loadAnalysisObj
    %   save, project|opercond-all|opercond-valid        -> saveWorkspace / saveOperCond(GeneralEventData(1|0))
    %   run, run|save                                    -> runTask / runTaskAndSave
    %   batch, add                                      -> addBatch2AnalysisNode_CB
    %   table, clear|export-mat|export-csv|export-m     -> clearTable / exportTable_CB(UserInterfaceEventData(...))
    %   report, pdf|word                                -> generateReport_CB(UserInterfaceEventData('PDF'|'MS Word'))
    %   settings, trim-settings|plots-all|plots-req|plots-post with data-value -> trimSettings_CB / setNumPlotsPlts/PostPlts
    %   toggle showLog/useAll                           -> showLogSignals_CB(GeneralEventData(bool)) / useAllCombinations_CB(GeneralEventData(bool))
%   select showInvalid/units                        -> showTrims_CB(UserInterfaceEventData(label)) / unitsChanged(UserInterfaceEventData(units))
%
% Smoke test (manual):
%   m = UserInterface.StabilityControl.Main;  % or Main(fig,...)
%   % Verify ribbon renders, open menus by clicking arrows; pick options.
%   % Programmatic state reflect:
%   m.ShowLoggedSignalsState = true; m.createToolRibbon();
%   % Click 'Settings' -> 'Plots Per Page - All (2)' and verify plots update handlers fire.

    function updateRibbonGeometry()
        if isempty(obj.RibbonPanel) || ~isgraphics(obj.RibbonPanel) || isempty(obj.ToolRibbonHtml) || ~isvalid(obj.ToolRibbonHtml)
            return;
        end
        p = getpixelposition(obj.RibbonPanel);
        if isempty(p), p = [0 0 1 1]; end
        obj.ToolRibbonHtml.Position = [0 0 max(p(3),1) max(p(4),1)];
        % Close any open dropdowns to avoid stale positioning
        closeAllRibbonDropdowns();
    end

    function handleRibbonEvent(payload)
        if ~isstruct(payload) || ~isfield(payload,'type')
            return;
        end
        switch lower(string(payload.type))
            case "ready"
                % HTML is ready; send icons and current state
                sendRibbonConfig();
                sendRibbonState();

            case "menuopen"
                % Request to open dropdown anchored at rect
                if isfield(payload,'menu')
                    menuId = char(string(payload.menu));
                    rect = [];
                    if isfield(payload,'rect') && isstruct(payload.rect)
                        rect = payload.rect;
                    end
                    openRibbonDropdown(menuId, rect);
                end

            case "command"
                if ~isfield(payload,'command'), return; end
                cmd = lower(char(string(payload.command)));
                opt = '';
                if isfield(payload,'option') && ~isempty(payload.option)
                    opt = lower(char(string(payload.option)));
                end
                val = [];
                if isfield(payload,'value'); val = payload.value; end
                executeCommand(cmd, opt, val);

            case "toggle"
                if ~isfield(payload,'target'), return; end
                tgt = lower(char(string(payload.target)));
                val = false;
                if isfield(payload,'value'), val = logical(payload.value); end
                switch tgt
                    case 'showlog'
                        obj.ShowLoggedSignalsState = val;
                        safeCall(@obj.showLogSignals_CB, GeneralEventData(val));
                    case 'useall'
                        obj.UseAllCombinationsState = val;
                        safeCall(@obj.useAllCombinations_CB, GeneralEventData(val));
                end
                % reflect new state
                obj.ToolRibbonState.showLogSignals = logical(obj.ShowLoggedSignalsState);
                obj.ToolRibbonState.useAllCombinations = logical(obj.UseAllCombinationsState);
                sendRibbonState();

            case "select"
                if ~isfield(payload,'target') || ~isfield(payload,'value'), return; end
                tgt = lower(char(string(payload.target)));
                switch tgt
                    case 'showinvalid'
                        label = resolveTrimState(payload.value);
                        obj.ShowInvalidTrimState = labelToNumeric(label); % maintain numeric compatibility (0/1/2)
                        safeCall(@obj.showTrims_CB, UserInterface.UserInterfaceEventData(label));
                        obj.ToolRibbonState.showInvalidTrim = char(label);
                    case 'units'
                        unitsVal = char(string(payload.value));
                        obj.Units = unitsVal;
                        safeCall(@obj.unitsChanged, UserInterface.UserInterfaceEventData(unitsVal));
                        obj.ToolRibbonState.units = unitsVal;
                end
                sendRibbonState();

            case "request"
                if isfield(payload,'subject') && strcmpi(char(string(payload.subject)),'state')
                    sendRibbonState();
                end
        end
    end

    function sendRibbonConfig()
        if isempty(obj.ToolRibbonHtml) || ~isvalid(obj.ToolRibbonHtml), return; end
        obj.ToolRibbonHtml.Data = struct('type','config','icons',assets);
    end

    function sendRibbonState()
        if isempty(obj.ToolRibbonHtml) || ~isvalid(obj.ToolRibbonHtml), return; end
        % Ensure derived field numPlotsAll is consistent
        if obj.ToolRibbonState.numPlotsReq == obj.ToolRibbonState.numPlotsPost
            obj.ToolRibbonState.numPlotsAll = obj.ToolRibbonState.numPlotsReq;
        else
            obj.ToolRibbonState.numPlotsAll = 0;
        end
        obj.ToolRibbonHtml.Data = struct('type','state','state',obj.ToolRibbonState);
    end

    function executeCommand(cmd, option, value)
        % Map the ToolRibbon commands to Main methods (no change in behavior)
        switch cmd
            case 'new'
                if isempty(option), option = 'trim'; end
                switch option
                    case {'analysis','task'}
                        safeCall(@obj.newAnalysisObj_CB);
                    case 'model'
                        safeCall(@obj.newLinMdlObj_CB);
                    case {'requirement','req'}
                        safeCall(@obj.newMethodObj_CB);
                    case {'simulation','sim'}
                        safeCall(@obj.newSimulationObj_CB);
                    otherwise
                        safeCall(@obj.newTrimObj_CB);
                end

            case 'open'
                if isempty(option), option = 'trim'; end
                switch option
                    case {'analysis','task'}
                        safeCall(@obj.openObjInEditor_CB, GeneralEventData('Analysis'));
                    case 'model'
                        safeCall(@obj.openObjInEditor_CB, GeneralEventData('Linear Model'));
                    case {'requirement','req'}
                        safeCall(@obj.openObjInEditor_CB, GeneralEventData('Requirement'));
                    case {'simulation','sim'}
                        safeCall(@obj.openObjInEditor_CB, GeneralEventData('Simulation Requirement'));
                    otherwise
                        safeCall(@obj.openObjInEditor_CB, GeneralEventData('Trim'));
                end

            case 'load'
                if isempty(option) || strcmp(option,'project')
                    safeCall(@obj.loadWorkspace);
                elseif any(strcmp(option,{'task','analysis'}))
                    safeCall(@obj.loadAnalysisObj);
                end

            case 'save'
                if isempty(option) || strcmp(option,'project')
                    safeCall(@obj.saveWorkspace);
                elseif strcmp(option,'opercond-all')
                    safeCall(@obj.saveOperCond, GeneralEventData(1));
                elseif strcmp(option,'opercond-valid')
                    safeCall(@obj.saveOperCond, GeneralEventData(0));
                end

            case 'run'
                if strcmp(option,'run')
                    safeCall(@obj.runTask);
                else
                    safeCall(@obj.runTaskAndSave);
                end

            case 'batch'
                safeCall(@obj.addBatch2AnalysisNode_CB);

            case 'table'
                if isempty(option) || strcmp(option,'clear')
                    safeCall(@obj.clearTable);
                elseif strcmp(option,'export-mat')
                    safeCall(@obj.exportTable_CB, UserInterface.UserInterfaceEventData('mat'));
                elseif strcmp(option,'export-csv')
                    safeCall(@obj.exportTable_CB, UserInterface.UserInterfaceEventData('csv'));
                elseif strcmp(option,'export-m')
                    safeCall(@obj.exportTable_CB, UserInterface.UserInterfaceEventData('m'));
                end

            case 'report'
                if strcmp(option,'word')
                    safeCall(@obj.generateReport_CB, UserInterface.UserInterfaceEventData('MS Word'));
                else
                    safeCall(@obj.generateReport_CB, UserInterface.UserInterfaceEventData('PDF'));
                end

            case 'settings'
                if strcmp(option,'trim-settings')
                    % Use existing flow: raise callback with TrimSettings
                    safeCall(@obj.trimSettings_CB, UserInterface.UserInterfaceEventData(obj.TrimSettings));
                elseif strcmp(option,'plots-all')
                    if isnumeric(value) && isscalar(value)
                        % Update both and reflect in state
                        val = double(value);
                        obj.NumberOfPlotPerPagePlts = val;
                        obj.NumberOfPlotPerPagePostPlts = val;
                        safeCall(@obj.setNumPlotsPlts, UserInterface.UserInterfaceEventData(val));
                        safeCall(@obj.setNumPlotsPostPlts, UserInterface.UserInterfaceEventData(val));
                        obj.ToolRibbonState.numPlotsReq = val;
                        obj.ToolRibbonState.numPlotsPost = val;
                        sendRibbonState();
                    end
                elseif strcmp(option,'plots-req')
                    if isnumeric(value) && isscalar(value)
                        val = double(value);
                        obj.NumberOfPlotPerPagePlts = val;
                        safeCall(@obj.setNumPlotsPlts, UserInterface.UserInterfaceEventData(val));
                        obj.ToolRibbonState.numPlotsReq = val;
                        sendRibbonState();
                    end
                elseif any(strcmp(option,{'plots-post','plots-sim'}))
                    if isnumeric(value) && isscalar(value)
                        val = double(value);
                        obj.NumberOfPlotPerPagePostPlts = val;
                        safeCall(@obj.setNumPlotsPostPlts, UserInterface.UserInterfaceEventData(val));
                        obj.ToolRibbonState.numPlotsPost = val;
                        sendRibbonState();
                    end
                end
        end
    end

    function openRibbonDropdown(menuId, rect)
        % Build items for the requested menu and show a floating uihtml popup
        items = buildDropdownItems(menuId);
        if isempty(items), return; end

        fig = ancestor(obj.RibbonPanel,'figure');
        if isempty(fig) || ~isgraphics(fig)
            return;
        end

        % Compute anchor position in figure pixel coords
        figPos = getpixelposition(fig);
        figW = figPos(3); figH = figPos(4);

        dropW = computeDropdownWidth(items);
        itemH = 32; % matches CSS
        dropH = numel(items)*itemH + 16;

        % Resolve rect relative to the ribbon html if provided
        x = 0; y = height; w = 16; h = 16;
        if nargin >= 2 && ~isempty(rect) && isstruct(rect) && all(isfield(rect,{'x','y','width','height'}))
            htmlAbs = getpixelposition(obj.ToolRibbonHtml,true);
            x = htmlAbs(1) + double(rect.x);
            % rect.y measures from ribbon top; convert to figure bottom
            yTop = htmlAbs(2) + htmlAbs(4) - double(rect.y);
            y = yTop - double(rect.height);
            w = double(rect.width);
            h = double(rect.height);
        end

        dropX = max(0, min(x, figW - dropW));
        dropY = max(0, min(y - dropH, figH - dropH));

        % Prepare items for HTML
        htmlItems = items;
        for k = 1:numel(htmlItems)
            if ~isfield(htmlItems(k),'Shortcut') || isempty(htmlItems(k).Shortcut)
                htmlItems(k).Shortcut = '';
            else
                htmlItems(k).Shortcut = char(htmlItems(k).Shortcut);
            end
            htmlItems(k).Icon = encodeRibbonIcon(htmlItems(k).Icon);
            if ~isfield(htmlItems(k),'Id') || isempty(htmlItems(k).Id)
                htmlItems(k).Id = sprintf('item-%d', k);
            end
        end

        htmlPopup = buildRibbonDropdownHtml(htmlItems);

        closeAllRibbonDropdowns();
        dropdown = uihtml(fig, 'HTMLSource', htmlPopup, 'Position', [dropX dropY dropW dropH]);
        dropdown.DataChangedFcn = @(~,evt)dropdownDataHandler(char(menuId), evt.Data);
        dropdown.Tag = sprintf('RibbonDropdown_%s', char(menuId));
        try, uistack(dropdown,'top'); end %#ok<TRYNC>

        obj.RibbonDropdowns.(char(menuId)) = struct('Component', dropdown, 'Callbacks', {items});
        obj.ActiveRibbonDropdown = char(menuId);
        setRibbonFigureCallback();
    end

    function w = computeDropdownWidth(items)
        % Estimate width from labels/shortcuts similar to ControlDesign
        labelLen = 0; shortLen = 0;
        if ~isempty(items)
            labelLen = max([cellfun(@(c)numel(char(c)), {items.Label}), 0]);
            if isfield(items,'Shortcut')
                shortLen = max([cellfun(@(c)numel(char(c)), {items.Shortcut}), 0]);
            end
        end
        approx = 140 + 7*labelLen + 4*shortLen;
        w = max([approx, 220]);
    end

    function dropdownDataHandler(menuKey, data)
        if nargin < 2 || ~isstruct(data) || ~isfield(data,'type')
            return;
        end
        switch string(data.type)
            case "select"
                if isfield(data,'id')
                    invokeRibbonDropdownCallback(menuKey, char(data.id));
                end
            case "close"
                hideRibbonDropdown(menuKey);
        end
    end

    function invokeRibbonDropdownCallback(menuKey, itemId)
        if nargin < 2 || isempty(itemId)
            hideRibbonDropdown(menuKey);
            return;
        end
        if ~isstruct(obj.RibbonDropdowns) || ~isfield(obj.RibbonDropdowns, menuKey)
            return;
        end
        entry = obj.RibbonDropdowns.(menuKey);
        cbs = entry.Callbacks;
        if iscell(cbs), cbs = cbs{1}; end
        for idx = 1:numel(cbs)
            cbDef = cbs(idx);
            if isfield(cbDef,'Id') && strcmp(char(cbDef.Id), itemId)
                if isfield(cbDef,'Callback') && ~isempty(cbDef.Callback)
                    try, cbDef.Callback(); catch err, warning('Main:createToolRibbon:DropdownCallback','Error executing callback for %s: %s',itemId,err.message); end
                end
                break;
            end
        end
        hideRibbonDropdown(menuKey);
    end

    function hideRibbonDropdown(menuId)
        if nargin < 1 || isempty(menuId), return; end
        menuKey = char(menuId);
        if ~isstruct(obj.RibbonDropdowns)
            obj.RibbonDropdowns = struct();
        end
        if isfield(obj.RibbonDropdowns, menuKey)
            entry = obj.RibbonDropdowns.(menuKey);
            if isstruct(entry) && isfield(entry,'Component')
                comp = entry.Component;
                if ~isempty(comp) && isvalid(comp)
                    delete(comp);
                end
            end
            obj.RibbonDropdowns = rmfield(obj.RibbonDropdowns, menuKey);
        end
        if strcmp(obj.ActiveRibbonDropdown, menuKey)
            obj.ActiveRibbonDropdown = '';
        end
        if isempty(fieldnames(obj.RibbonDropdowns))
            obj.RibbonDropdowns = struct();
            restoreRibbonFigureCallback();
        end
    end

    function closeAllRibbonDropdowns()
        if ~isstruct(obj.RibbonDropdowns)
            obj.RibbonDropdowns = struct();
        else
            keys = fieldnames(obj.RibbonDropdowns);
            for idx = 1:numel(keys)
                entry = obj.RibbonDropdowns.(keys{idx});
                if isstruct(entry) && isfield(entry,'Component')
                    comp = entry.Component; if ~isempty(comp) && isvalid(comp), delete(comp); end
                end
            end
            obj.RibbonDropdowns = struct();
        end
        obj.ActiveRibbonDropdown = '';
        restoreRibbonFigureCallback();
    end

    function setRibbonFigureCallback()
        fig = ancestor(obj.RibbonPanel,'figure');
        if isempty(fig) || ~isgraphics(fig), return; end
        if ~isstruct(obj.RibbonDropdownOriginalFigureFcn) || ~isfield(obj.RibbonDropdownOriginalFigureFcn,'Stored') || ~obj.RibbonDropdownOriginalFigureFcn.Stored
            obj.RibbonDropdownOriginalFigureFcn = struct('Stored',true,'Value',fig.WindowButtonDownFcn);
        end
        fig.WindowButtonDownFcn = @(src,evt)handleRibbonFigureClick(src,evt);
    end

    function restoreRibbonFigureCallback()
        fig = ancestor(obj.RibbonPanel,'figure');
        if isempty(fig) || ~isgraphics(fig)
            obj.RibbonDropdownOriginalFigureFcn = struct('Stored',false,'Value',[]);
            return;
        end
        if isstruct(obj.RibbonDropdownOriginalFigureFcn) && obj.RibbonDropdownOriginalFigureFcn.Stored
            fig.WindowButtonDownFcn = obj.RibbonDropdownOriginalFigureFcn.Value;
        else
            fig.WindowButtonDownFcn = [];
        end
        obj.RibbonDropdownOriginalFigureFcn = struct('Stored',false,'Value',[]);
    end

    function handleRibbonFigureClick(src, evt)
        if nargin < 1 || isempty(src)
            src = ancestor(obj.RibbonPanel,'figure');
        end
        orig = obj.RibbonDropdownOriginalFigureFcn;
        pt = [nan nan];
        if ~isempty(src) && isgraphics(src) && isprop(src,'CurrentPoint')
            pt = src.CurrentPoint;
        end
        if all(isfinite(pt)) && isPointInsideDropdown(pt)
            executeFigureCallback(orig.Value, src, evt);
            return;
        end
        closeAllRibbonDropdowns();
        executeFigureCallback(orig.Value, src, evt);
    end

    function inside = isPointInsideDropdown(point)
        inside = false;
        if ~isstruct(obj.RibbonDropdowns), return; end
        keys = fieldnames(obj.RibbonDropdowns);
        for idx = 1:numel(keys)
            entry = obj.RibbonDropdowns.(keys{idx});
            if ~isstruct(entry) || ~isfield(entry,'Component'), continue; end
            comp = entry.Component;
            if isempty(comp) || ~isvalid(comp), continue; end
            pos = comp.Position;
            if point(1) >= pos(1) && point(1) <= pos(1)+pos(3) && point(2) >= pos(2) && point(2) <= pos(2)+pos(4)
                inside = true; return;
            end
        end
    end

    function executeFigureCallback(callbackFcn, src, evt)
        if isempty(callbackFcn), return; end
        try
            if isa(callbackFcn,'function_handle')
                if nargin(callbackFcn) == 0, callbackFcn(); else, callbackFcn(src,evt); end
            elseif iscell(callbackFcn) && ~isempty(callbackFcn)
                feval(callbackFcn{:}, src, evt);
            elseif ischar(callbackFcn) || (isstring(callbackFcn) && isscalar(callbackFcn))
                feval(callbackFcn, src, evt);
            end
        catch err
            warning('Main:createToolRibbon:FigureCallback','Error executing figure WindowButtonDownFcn: %s', err.message);
        end
    end

    function items = buildDropdownItems(menuId)
        % Builds dropdown items matching ToolRibbon.m (labels/icons)
        items = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});
        switch lower(char(menuId))
            case 'menu-new'
                items(end+1) = mkItem('new-analysis','Task','analysis_24.png', @()executeCommand('new','analysis',[]));
                items(end+1) = mkItem('new-trim','Trim','airplaneTrim_24.png', @()executeCommand('new','trim',[]));
                items(end+1) = mkItem('new-model','Linear Model','linmdl_24.png', @()executeCommand('new','model',[]));
                items(end+1) = mkItem('new-req','Requirement','InOut_24.png', @()executeCommand('new','requirement',[]));
                items(end+1) = mkItem('new-sim','Simulation Requirement','Simulink_24.png', @()executeCommand('new','simulation',[]));
            case 'menu-open'
                items(end+1) = mkItem('open-analysis','Task','analysis_24.png', @()executeCommand('open','analysis',[]));
                items(end+1) = mkItem('open-trim','Trim','airplaneTrim_24.png', @()executeCommand('open','trim',[]));
                items(end+1) = mkItem('open-model','Linear Model','linmdl_24.png', @()executeCommand('open','model',[]));
                items(end+1) = mkItem('open-req','Requirement','InOut_24.png', @()executeCommand('open','requirement',[]));
                items(end+1) = mkItem('open-sim','Simulation Requirement','Simulink_24.png', @()executeCommand('open','simulation',[]));
            case 'menu-load'
                items(end+1) = mkItem('load-project','Project','LoadProject_24.png', @()executeCommand('load','project',[]));
                items(end+1) = mkItem('load-task','Task','LoadArrow_24.png', @()executeCommand('load','task',[]));
            case 'menu-save'
                items(end+1) = mkItem('save-project','Save Project','Save_Dirty_24.png', @()executeCommand('save','project',[]));
                items(end+1) = mkItem('save-oper-all','Save Operating Conditions - All','Save_Dirty_24.png', @()executeCommand('save','opercond-all',[]));
                items(end+1) = mkItem('save-oper-valid','Save Operating Conditions - Valid Only','Save_Dirty_24.png', @()executeCommand('save','opercond-valid',[]));
            case 'menu-run'
                items(end+1) = mkItem('run-only','Run','Run_24.png', @()executeCommand('run','run',[]));
                items(end+1) = mkItem('run-save','Run and Save','RunSave_24.png', @()executeCommand('run','save',[]));
            case 'menu-table'
                items(end+1) = mkItem('table-clear','Clear Table','Clean_16.png', @()executeCommand('table','clear',[]));
                items(end+1) = mkItem('table-export-mat','Export to MAT','Export_24.png', @()executeCommand('table','export-mat',[]));
                items(end+1) = mkItem('table-export-csv','Export to CSV','Export_24.png', @()executeCommand('table','export-csv',[]));
                items(end+1) = mkItem('table-export-m','Export to M Script','Export_24.png', @()executeCommand('table','export-m',[]));
            case 'menu-report'
                items(end+1) = mkItem('report-pdf','PDF','report_app_24.png', @()executeCommand('report','pdf',[]));
                items(end+1) = mkItem('report-word','MS Word','report_app_24.png', @()executeCommand('report','word',[]));
            case 'menu-settings'
                items(end+1) = mkItem('settings-trim','Trim Settings...','Settings_16.png', @()executeCommand('settings','trim-settings',[]));
                items(end+1) = mkItem('settings-all-1','Plots Per Page - All (1)','Figure_16.png', @()executeCommand('settings','plots-all',1));
                items(end+1) = mkItem('settings-all-2','Plots Per Page - All (2)','Figure_16.png', @()executeCommand('settings','plots-all',2));
                items(end+1) = mkItem('settings-all-4','Plots Per Page - All (4)','Figure_16.png', @()executeCommand('settings','plots-all',4));
                items(end+1) = mkItem('settings-req-1','Requirements Plots Per Page - 1','Figure_16.png', @()executeCommand('settings','plots-req',1));
                items(end+1) = mkItem('settings-req-2','Requirements Plots Per Page - 2','Figure_16.png', @()executeCommand('settings','plots-req',2));
                items(end+1) = mkItem('settings-req-4','Requirements Plots Per Page - 4','Figure_16.png', @()executeCommand('settings','plots-req',4));
                items(end+1) = mkItem('settings-post-1','Post Simulation Plots Per Page - 1','Figure_16.png', @()executeCommand('settings','plots-post',1));
                items(end+1) = mkItem('settings-post-2','Post Simulation Plots Per Page - 2','Figure_16.png', @()executeCommand('settings','plots-post',2));
                items(end+1) = mkItem('settings-post-4','Post Simulation Plots Per Page - 4','Figure_16.png', @()executeCommand('settings','plots-post',4));
            otherwise
                items = struct('Id',{},'Label',{},'Icon',{},'Shortcut',{},'Callback',{});
        end

        function s = mkItem(id,label,icon,cb)
            s = struct('Id',id,'Label',label,'Icon',icon,'Shortcut','', 'Callback',cb);
        end
    end

    function html = buildRibbonHtml()
        % HTML/CSS/JS: styled to match ControlDesign ribbon theme; layout as ToolRibbon
        % Pre-embed icon URIs so icons show even before config message arrives
        iconsJson = jsonencode(assets);
        iconLine = ['  const initialIcons = ' iconsJson ';'];
        lines = {
            '<!doctype html>'
            '<html lang="en">'
            '<head>'
            '<meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width, initial-scale=1">'
            '<style>'
            'html,body{margin:0;padding:0;height:100%;background:transparent;font-family:"Segoe UI","Helvetica Neue",Arial,sans-serif;font-size:11px;color:#f3f5f7;}'
            '.ribbon-surface{position:absolute;inset:0;display:flex;align-items:stretch;gap:0;padding:2px 6px 4px;background:linear-gradient(180deg,#3c3f45 0%,#292c33 100%);border-bottom:1px solid #14161a;box-sizing:border-box;}'
            '.group{position:relative;display:flex;flex-direction:column;align-items:stretch;gap:3px;padding:0 6px 2px;border-right:1px solid rgba(255,255,255,0.15);min-height:100%;}'
            '.group:last-of-type{border-right:none;}'
            '.group-body{display:flex;gap:4px;align-items:flex-start;flex:1 1 auto;}'
            '.group-body.column{flex-direction:column;}'
            '.group-label{text-align:center;font-size:10px;font-weight:600;letter-spacing:1px;color:#cfd2d6;text-transform:uppercase;margin-top:auto;padding:1px 0;background:linear-gradient(180deg,rgba(255,255,255,0.08) 0%,rgba(0,0,0,0.25) 100%);border:1px solid rgba(0,0,0,0.6);border-radius:3px;}'
            '.button-base{display:flex;align-items:center;justify-content:center;gap:6px;border:1px solid #1f2025;border-radius:4px;background:linear-gradient(180deg,#4f535c 0%,#2f3238 100%);box-shadow:0 1px 0 rgba(255,255,255,0.12) inset,0 1px 2px rgba(0,0,0,0.6);color:#f3f5f7;cursor:pointer;padding:4px;transition:background 0.15s ease,box-shadow 0.15s ease,transform 0.15s ease;}'
            '.button-base:hover{background:linear-gradient(180deg,#5d616b 0%,#343840 100%);box-shadow:0 1px 0 rgba(255,255,255,0.18) inset,0 2px 4px rgba(0,0,0,0.55);}'
            '.button-base:active{transform:translateY(1px);}'
            '.button-base:focus-visible{outline:2px solid #0e67d2;outline-offset:1px;}'
            '.button-vertical{flex-direction:column;min-width:50px;height:56px;padding:4px 4px 12px;gap:3px;position:relative;}'
            '.button-horizontal{flex-direction:row;justify-content:flex-start;min-width:0;padding:4px 8px;min-height:30px;}'
            '.button-horizontal.compact{min-height:26px;padding:3px 8px;}'
            '.button-wide{min-width:140px;}'
            '.label{text-transform:uppercase;font-size:9px;font-weight:600;letter-spacing:0.3px;color:#e6e8eb;text-align:center;}'
            '.label.small{text-transform:none;font-size:10px;letter-spacing:0.2px;text-align:left;color:#f3f5f7;}'
            '.icon-box{width:22px;height:22px;border-radius:4px;background:linear-gradient(180deg,#5a5f69 0%,#3a3e46 100%);display:flex;align-items:center;justify-content:center;box-shadow:0 1px 0 rgba(255,255,255,0.12) inset;}'
            '.icon-box.small{width:18px;height:18px;border-radius:3px;}'
            '.icon-box img{width:16px;height:16px;image-rendering:-webkit-optimize-contrast;}'
            '.icon-box.small img{width:14px;height:14px;}'
            '.split{position:relative;display:flex;}'
            '.split.vertical{flex-direction:column;align-items:stretch;}'
            '.split.vertical .split-main{width:100%;}'
            '.split.vertical .split-trigger{position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:16px;height:14px;border:1px solid #1f2025;border-radius:3px;background:linear-gradient(180deg,#4f535c 0%,#2f3238 100%);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:background 0.15s ease,box-shadow 0.15s ease;}'
            '.split.horizontal{flex-direction:row;align-items:stretch;}'
            '.split.horizontal .split-main{padding-right:24px;}'
            '.split.horizontal .split-trigger{position:absolute;top:50%;right:6px;transform:translateY(-50%);width:16px;height:16px;border:1px solid #1f2025;border-radius:3px;background:linear-gradient(180deg,#4f535c 0%,#2f3238 100%);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:background 0.15s ease,box-shadow 0.15s ease;}'
            '.split-trigger:hover{background:linear-gradient(180deg,#5d616b 0%,#343840 100%);box-shadow:0 1px 0 rgba(255,255,255,0.18) inset,0 2px 4px rgba(0,0,0,0.55);}'
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
            '.field-label{font-size:9px;text-transform:uppercase;letter-spacing:0.5px;color:#cfd2d6;}'
            'select{font:10px "Segoe UI",Tahoma,Arial,sans-serif;padding:2px 4px;border:1px solid #b2b2b2;border-radius:3px;background:#ffffff;color:#1f1f1f;min-width:120px;}'
            'select:focus{outline:1px solid #0e67d2;outline-offset:0;}'
            '.checkbox{display:flex;align-items:center;gap:4px;font-size:10px;color:#f3f5f7;}'
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
            '      </div>'
            '      <div class="split vertical">'
            '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="open" title="Open existing item">'
            '          <span class="icon-box"><img id="icon-open" alt="Open"></span>'
            '          <span class="label">Open</span>'
            '        </button>'
            '        <button type="button" class="split-trigger" data-menu="menu-open" aria-haspopup="menu" aria-expanded="false" title="Open options">'
            '          <span class="caret"></span>'
            '        </button>'
            '      </div>'
            '      <div class="split vertical">'
            '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="load" data-option="project" title="Load project or task">'
            '          <span class="icon-box"><img id="icon-load" alt="Load"></span>'
            '          <span class="label">Load</span>'
            '        </button>'
            '        <button type="button" class="split-trigger" data-menu="menu-load" aria-haspopup="menu" aria-expanded="false" title="Load options">'
            '          <span class="caret"></span>'
            '        </button>'
            '      </div>'
            '      <div class="split vertical">'
            '        <button type="button" class="button-base button-vertical split-main" data-role="primary" data-command="save" data-option="project" title="Save project or operating conditions">'
            '          <span class="icon-box"><img id="icon-save" alt="Save"></span>'
            '          <span class="label">Save</span>'
            '        </button>'
            '        <button type="button" class="split-trigger" data-menu="menu-save" aria-haspopup="menu" aria-expanded="false" title="Save options">'
            '          <span class="caret"></span>'
            '        </button>'
            '      </div>'
            '    </div>'
            '    <div class="group-label">File</div>'
            '  </div>'
            '  <div class="divider"></div>'
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
            '      </div>'
            '      <button type="button" class="button-base button-horizontal compact" data-role="primary" data-command="batch" data-option="add" title="Add new run cases">'
            '        <span class="icon-box small"><img id="icon-add" alt="Add"></span>'
            '        <span class="label small">Add New Run Cases</span>'
            '      </button>'
            '    </div>'
            '    <div class="group-label">Run</div>'
            '  </div>'
            '  <div class="divider"></div>'
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
            '      </div>'
            '      <div class="split horizontal">'
            '        <button type="button" class="button-base button-horizontal compact split-main" data-role="primary" data-command="report" data-option="pdf" title="Generate analysis report">'
            '          <span class="icon-box small"><img id="icon-report" alt="Report"></span>'
            '          <span class="label small">Generate Report</span>'
            '        </button>'
            '        <button type="button" class="split-trigger" data-menu="menu-report" aria-haspopup="menu" aria-expanded="false" title="Report format">'
            '          <span class="caret"></span>'
            '        </button>'
            '      </div>'
            '    </div>'
            '    <div class="group-label">Actions</div>'
            '  </div>'
            '  <div class="divider"></div>'
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
            '  <div class="divider"></div>'
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
'  let matlabComponent = null;'
'  const pending = [];'
'  function setup(htmlComponent){ matlabComponent = htmlComponent; while(pending.length){ const m = pending.shift(); try{ matlabComponent.Data = m; }catch(e){} } }'
'  window.setup = setup;'
            '  function send(msg){ if(matlabComponent){ try{ matlabComponent.Data = msg; }catch(e){} } else { pending.push(msg); } }'
'  function setIcon(id, src){'
'    const img = document.getElementById(id);'
'    if(!img){return;}'
'    if(src){ img.src = src; img.style.visibility = "visible"; } else { img.removeAttribute("src"); img.style.visibility = "hidden"; }'
'  }'
iconLine
'  function preloadIcons(){'
'    try{ if(initialIcons){ for(const k in initialIcons){ const id = "icon-"+k; const val = initialIcons[k]; if(val){ setIcon(id,val); } } } }catch(e){}'
'  }'
            '  function setMenuSelection(scope, value){'
            '    const selector = `.menu-item[data-scope="${scope}"]`;' 
            '    document.querySelectorAll(selector).forEach(item => {'
            '      if(value !== null && value !== undefined && String(value) === item.dataset.value){ item.classList.add("selected"); }'
            '      else { item.classList.remove("selected"); }'
            '    });'
            '  }'
            '  const root = document.getElementById("ribbonSurface");'
'  document.addEventListener("click", evt => { if(!evt.target.closest(".split")){ send({type:"request", subject:"state"}); } });'
'  try{ preloadIcons(); }catch(e){}'
            '  document.querySelectorAll(".split-trigger[data-menu]").forEach(trigger => {'
            '    const menuId = trigger.dataset.menu;'
            '    trigger.addEventListener("click", evt => {'
            '      evt.stopPropagation();'
            '      const rect = trigger.getBoundingClientRect();'
            '      const rootRect = root.getBoundingClientRect();'
            '      const rel = {x: Math.round(rect.left - rootRect.left), y: Math.round(rect.bottom - rootRect.top), width: Math.round(rect.width), height: Math.round(rect.height)};'
            '      send({type:"menuopen", menu:menuId, rect:rel});'
            '    });'
            '  });'
            '  document.querySelectorAll(''[data-role="primary"][data-command]'').forEach(btn => {'
            '    btn.addEventListener("click", () => {'
            '      const payload = {type:"command", command:btn.dataset.command};'
            '      if(btn.dataset.option){payload.option = btn.dataset.option;}'
            '      if(btn.dataset.value){'
            '        const raw = btn.dataset.value; const num = Number(raw); payload.value = Number.isNaN(num) ? raw : num;'
            '      }'
            '      send(payload);'
            '    });'
            '  });'
            '  const selTrim = document.getElementById("sel-trim"); if(selTrim){ selTrim.addEventListener("change", () => { send({type:"select", target:"showInvalid", value:selTrim.value}); }); }'
            '  const selUnits = document.getElementById("sel-units"); if(selUnits){ selUnits.addEventListener("change", () => { send({type:"select", target:"units", value:selUnits.value}); }); }'
            '  const chkLog = document.getElementById("chk-log"); if(chkLog){ chkLog.addEventListener("change", () => { send({type:"toggle", target:"showLog", value:chkLog.checked}); }); }'
            '  const chkCombo = document.getElementById("chk-combo"); if(chkCombo){ chkCombo.addEventListener("change", () => { send({type:"toggle", target:"useAll", value:chkCombo.checked}); }); }'
            '  window.addEventListener("message", event => {'
            '    const data = event.data || {};'
            '    if(data.type === "config"){'
            '      const icons = data.icons || {};'
            '      setIcon("icon-new", icons.new); setIcon("icon-open", icons.open); setIcon("icon-load", icons.load); setIcon("icon-save", icons.save);'
            '      setIcon("icon-run", icons.run); setIcon("icon-add", icons.add); setIcon("icon-table", icons.table); setIcon("icon-report", icons.report);'
            '      setIcon("icon-analysis", icons.analysis); setIcon("icon-trim", icons.trim); setIcon("icon-model", icons.model); setIcon("icon-requirement", icons.requirement); setIcon("icon-simulation", icons.simulation);'
            '      setIcon("icon-settings", icons.settings);'
            '    } else if (data.type === "state"){'
            '      const state = data.state || {};'
            '      if(chkLog){ chkLog.checked = !!state.showLogSignals; }'
            '      if(chkCombo){ chkCombo.checked = !!state.useAllCombinations; }'
            '      if(selTrim && state.showInvalidTrim){ selTrim.value = state.showInvalidTrim; }'
            '      if(selUnits && state.units){ selUnits.value = state.units; }'
            '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsReq")){ setMenuSelection("plots-req", state.numPlotsReq); }'
            '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsPost")){ setMenuSelection("plots-post", state.numPlotsPost); }'
            '      if(Object.prototype.hasOwnProperty.call(state,"numPlotsAll")){ if(state.numPlotsAll){ setMenuSelection("plots-all", state.numPlotsAll); } else { setMenuSelection("plots-all", null); } }'
            '    }'
            '  });'
            '  window.addEventListener("DOMContentLoaded", () => { send({type:"ready"}); });'
            '})();'
            '</script>'
            '</body>'
            '</html>'
        };
        html = strjoin(lines, newline);
    end

    function assets = buildRibbonAssets()
        assets = struct();
        assets.new         = encodeIconByName('New_24.png');
        assets.open        = encodeIconByName('Open_24.png');
        assets.load        = encodeIconByName('LoadArrow_24.png');
        assets.save        = encodeIconByName('Save_Dirty_24.png');
        assets.run         = encodeIconByName('RunSave_24.png');
        assets.add         = encodeIconByName('New_16.png');
        assets.table       = encodeIconByName('Clean_16.png');
        assets.report      = encodeIconByName('report_app_24.png');
        assets.analysis    = encodeIconByName('analysis_24.png');
        assets.trim        = encodeIconByName('airplaneTrim_24.png');
        assets.model       = encodeIconByName('linmdl_24.png');
        assets.requirement = encodeIconByName('InOut_24.png');
        assets.simulation  = encodeIconByName('Simulink_24.png');
        assets.settings    = encodeIconByName('Settings_16.png');
    end

    function dirs = iconSearchDirs()
        % Search both +UserInterface/Resources and +SimViewer/Resources
        thisDir = fileparts(mfilename('fullpath'));
        dirs = {
            fullfile(thisDir,'..','..','Resources'), ... % +UserInterface/Resources
            fullfile(thisDir,'..','..','..','+SimViewer','Resources') ... % +SimViewer/Resources
        };
    end

    function uri = encodeIconByName(fileName)
        % Look through candidate folders and return data URI, or '' if not found
        candDirs = iconSearchDirs();
        fullPaths = cellfun(@(d) fullfile(d,fileName), candDirs,'UniformOutput',false);
        fullPath = '';
        for i = 1:numel(fullPaths)
            if exist(fullPaths{i},'file') == 2
                fullPath = fullPaths{i};
                break;
            end
        end
        if isempty(fullPath)
            uri = '';
            return;
        end
        fid = fopen(fullPath,'rb');
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
    end

    function dataUri = encodeRibbonIcon(iconName)
        % Dropdown menu icon encoder with multi-folder search and caching
        persistent iconCache searchDirs
        if isempty(searchDirs)
            searchDirs = iconSearchDirs();
        end
        if isempty(iconName)
            dataUri = '';
            return;
        end
        key = char(iconName);
        if isempty(iconCache)
            iconCache = containers.Map('KeyType','char','ValueType','char');
        elseif isKey(iconCache,key)
            dataUri = iconCache(key);
            return;
        end
        % Search both directories
        foundPath = '';
        for i = 1:numel(searchDirs)
            p = fullfile(searchDirs{i}, key);
            if exist(p,'file') == 2
                foundPath = p; break;
            end
        end
        if isempty(foundPath)
            dataUri = '';
            return;
        end
        fid = fopen(foundPath,'rb');
        if fid < 0
            dataUri = '';
            return;
        end
        cleaner = onCleanup(@()fclose(fid)); %#ok<NASGU>
        raw = fread(fid,Inf,'*uint8');
        dataUri = ['data:image/png;base64,' matlab.net.base64encode(raw')];
        iconCache(key) = dataUri;
    end

    function html = buildRibbonDropdownHtml(items)
        % Lightweight ControlDesign-like dropdown (standalone uihtml)
        itemMarkup = cell(1,numel(items));
        for idx = 1:numel(items)
            labelText = escapeHtml(items(idx).Label);
            shortcutText = '';
            if isfield(items(idx),'Shortcut') && ~isempty(items(idx).Shortcut)
                shortcutText = escapeHtml(items(idx).Shortcut);
            end
            if isempty(shortcutText), shortcutText = '&nbsp;'; end
            itemMarkup{idx} = sprintf(['<button class="menu-item" type="button" data-id="%s" title="%s">' ...
                '<span class="item-icon"><img src="%s" alt="" /></span>' ...
                '<span class="item-label">%s</span>' ...
                '<span class="item-shortcut">%s</span>' ...
                '</button>'], escapeHtml(items(idx).Id), labelText, items(idx).Icon, labelText, shortcutText);
        end

        styleBlock = strjoin({ ...
            '<style>', ...
            'html,body{margin:0;padding:0;background:transparent;font-family:"Segoe UI","Helvetica Neue",Arial,sans-serif;color:#1f1f1f;}', ...
            '#dropdownRoot{position:absolute;inset:0;padding:6px 0;background:linear-gradient(180deg,#fbfbfc 0%,#d9dde3 100%);', ...
            'border:1px solid #9ba1ac;border-radius:6px;box-shadow:0 8px 18px rgba(0,0,0,0.25);display:flex;flex-direction:column;gap:2px;}', ...
            '.menu-item{display:flex;align-items:center;gap:10px;padding:6px 16px;border:0;background:transparent;font-size:12px;line-height:18px;color:#202126;cursor:pointer;text-align:left;}', ...
            '.menu-item:hover{background:rgba(56,120,196,0.18);}', ...
            '.menu-item:focus{outline:none;background:rgba(56,120,196,0.24);}', ...
            '.item-icon{width:24px;display:flex;align-items:center;justify-content:center;}', ...
            '.item-icon img{width:20px;height:20px;}', ...
            '.item-label{flex:1;font-weight:500;}', ...
            '.item-shortcut{display:flex;justify-content:flex-end;min-width:64px;color:#4d525a;font-size:11px;white-space:nowrap;}', ...
            '</style>'},'');

        scriptBlock = strjoin({ ...
            '<script>', ...
'function setup(htmlComponent){',
            'const root = document.getElementById("dropdownRoot");', ...
            'if(!root){return;}', ...
            'root.querySelectorAll(".menu-item").forEach(btn=>{', ...
            'btn.addEventListener("click",()=>{ const id = btn.dataset.id; htmlComponent.Data = {type:"select",id:id}; });', ...
            '});', ...
            'root.addEventListener("keydown",evt=>{ if(evt.key==="Escape"){ htmlComponent.Data = {type:"close"}; } });', ...
'root.focus();', ...
'document.addEventListener("DOMContentLoaded",()=>{ try{ if(window && typeof window.setup === "function"){ /* noop */ } }catch(e){} });',
            'document.addEventListener("wheel",evt=>evt.preventDefault(),{passive:false});', ...
            '}', ...
            '</script>'},'');

        html = strjoin({ ...
            '<!doctype html>', ...
            '<html lang="en">', ...
            '<head>', ...
            '<meta charset="utf-8" />', ...
            styleBlock, ...
            '</head>', ...
            '<body>', ...
            '<div id="dropdownRoot" tabindex="0">', ...
            strjoin(itemMarkup,''), ...
            '</div>', ...
            scriptBlock, ...
            '</body>', ...
            '</html>'},'');

        function str = escapeHtml(text)
            if nargin == 0 || isempty(text)
                str = '';
                return;
            end
            text = char(text);
            str = strrep(text,'&','&amp;');
            str = strrep(str,'<','&lt;');
            str = strrep(str,'>','&gt;');
            str = strrep(str,'"','&quot;');
            str = strrep(str,char(39),'&#39;');
        end
    end

    function label = resolveTrimState(state)
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
    end

    function num = labelToNumeric(label)
        % Keep compatibility with existing numeric ShowInvalidTrimState usage
        label = char(label);
        switch label
            case 'Show All Trims',    num = 0;
            case 'Show Valid Trims',  num = 1;
            case 'Show Invalid Trims',num = 2;
            otherwise,                num = 0;
        end
    end

    function v = pickAllPlotsValue(a,b)
        if isequal(double(a), double(b)), v = double(a); else, v = 0; end
    end

    function safeCall(fh, evt)
        % Invoke method handle with optional event data in a try/catch
        try
            if nargin < 2
                fh([] , []);
            else
                fh([], evt);
            end
        catch err
            % Swallow but warn in debug mode if available
            try
                if isprop(obj,'Debug') && obj.Debug
                    warning('Main:createToolRibbon:Callback','Error executing callback: %s', err.message);
                end
            catch
            end
        end
    end
end
