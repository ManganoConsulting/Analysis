classdef FrequencyResponseEditorApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SimulinkModelEdit               matlab.ui.control.EditField
        SimulinkModelBrowseButton       matlab.ui.control.Button
        MethodLocationEdit              matlab.ui.control.EditField
        MethodLocationBrowseButton      matlab.ui.control.Button
        MethodFileEdit                  matlab.ui.control.EditField
        CommonNameCheck                 matlab.ui.control.CheckBox
        SelectAllMag
        SelectAllPhase
        SelectAllNick

        NicholsPlotEdit                 matlab.ui.control.EditField
        NicholsPlotBrowseButton         matlab.ui.control.Button
        BodeMagEdit                     matlab.ui.control.EditField
        BodeMagBrowseButton             matlab.ui.control.Button
        BodePhaseEdit                   matlab.ui.control.EditField
        BodePhaseBrowseButton           matlab.ui.control.Button

        FreqVectorEdit                  matlab.ui.control.EditField
        FreqMarkersEdit                 matlab.ui.control.EditField

        DataTable                       matlab.ui.control.Table
        OrderListBox                    matlab.ui.control.ListBox

        LoadButton                      matlab.ui.control.Button
        ExportMethodButton              matlab.ui.control.Button
        MoveUpButton                    matlab.ui.control.Button
        MoveDownButton                  matlab.ui.control.Button

        OrderTable                      matlab.ui.control.Table

        % Properties for user interaction
        MethodFullPath
        SimulinkModel
        Method
        NicholsPlot
        BodeMagnitudePlot
        BodePhasePlot
        PlotOptions
        Order
        FrequencyVector = 'logspace(-2,2,1000)'
        FrequencyMarkers = '[0.2 0.5 1 2 5]'
        PlotTitles = {}
        SelectedPlots = {}
        ObjectTitles = {}
        OutputDataIndexArray = []
        ObjectName2OutputDataInd = {}
        UseCommonName = true
        MethodFileName
        FrequencyMarkersList = {'o','p','^','d','s','<','>','v','h'}
        FrequencyMarkersColors = {'k','r','g','b','y','c','m'}

    end

    events
        ObjectLoaded
    end 
        
    methods (Access = private)

        function startupFcn(app)
            % Populate the table and listbox
            app.DataTable.Data = {};
            app.OrderTable.Data = {};
        end

        function file = openFileDialog(app, filter)
            if nargin == 1  || isempty(filter)
                filter = '*.*';
            end
            [fileName, pathName] = uigetfile(filter, 'Select a File');
            if isequal(fileName, 0)
                file = '';
            else
                % file = fullfile(pathName, fileName);
                file = fileName;
            end
        end

        function [path, file] = newFileDialog(app, filter)
            if nargin == 1  || isempty(filter)
                filter = '*.*';
            end
            [fileName, pathName] = uiputfile(filter, 'New File Location');
            if isequal(fileName, 0)
                file = '';
                path = '';
            else
                path = pathName;
                file = fileName;
            end
        end
    end

    methods (Access = private)
        % Callbacks
        [inputNames, outputNames] = findSimulinkIO(app, mdlName);

        function initOnMdlLoad(app)
            inputNames = {};
            outputNames = {};
            if ~isempty(app.SimulinkModelEdit)
                [~, mdlName] = fileparts(app.SimulinkModelEdit.Value);
                [inputNames, outputNames] = findSimulinkIO(app, mdlName);
            end
        
            % Build all input–output titles (order defined by allcomb)
            all_cell = Utilities.allcomb(inputNames, outputNames);
            app.PlotTitles = cellfun(@(a,b) [a ' to ' b], all_cell(:,1), all_cell(:,2), 'UniformOutput', false);
        
            % Two checkboxes per row (Mag, Phase)
            nPairs = size(app.PlotTitles, 1);
            app.SelectedPlots = repmat({true}, nPairs, 2);
        
            % Expand into per-object titles (one for Mag, one for Phase per pair)
            app.ObjectTitles = cell(2*nPairs, 1);
            k = 0;
            for r = 1:nPairs
                k = k + 1; app.ObjectTitles{k} = [app.PlotTitles{r}, ' - Bode Mag'];
                k = k + 1; app.ObjectTitles{k} = [app.PlotTitles{r}, ' - Bode Phase'];
            end
        
            % Populate the UI tables
            app.DataTable.Data  = [app.PlotTitles, app.SelectedPlots];
            app.OrderTable.Data = app.ObjectTitles;
        
            % === FIX: build indices that exactly match ObjectTitles order ===
            % We want: pair #1 -> indices [1,2], pair #2 -> [3,4], ...
            app.OutputDataIndexArray = 1:(2*nPairs);  % 1..2K
        
            % Map "Object title" -> "its 1-based index in the exported Y{} array"
            app.ObjectName2OutputDataInd = [ app.OrderTable.Data, num2cell(app.OutputDataIndexArray(:)) ];
        
        end

        function objs = createFRObjs(app)
            [~, simMdl] = fileparts(app.SimulinkModelEdit.Value);
            [~, methodName] = fileparts(app.MethodFileName);

            objs(length(app.OrderTable.Data)) = Requirements.FrequencyResponse;
            for i = 1:length(app.OrderTable.Data)

                if contains(app.OrderTable.Data{i}, 'Nichols')
                    [~, pltName] = fileparts(app.NicholsPlotEdit.Value);
 
                elseif contains(app.OrderTable.Data{i}, 'Bode Mag') 
                    [~, pltName] = fileparts(app.BodeMagEdit.Value);

                elseif contains( app.OrderTable.Data{i}, 'Bode Phase')
                    [~, pltName] = fileparts(app.BodePhaseEdit.Value);

                end
                
                objs(i) = Requirements.FrequencyResponse(methodName, app.OrderTable.Data{i}, simMdl);
                objs(i).RequiermentPlot = pltName;
                objs(i).OutputDataIndex = app.OutputDataIndexArray(i);
            end
        end

%         function updateListBoxItemData(app)
% 
%             for i = 1:app.OrderListBox.Items
%                 if contains(app.OrderListBox.Items{i}, 'Nichols')
%                     itemData = {app.SimulinkModelEdit.Value, app.MethodLocationEdit.Value, app.NicholsPlotEdit.Value};
%                     app.OrderListBox.ItemsData{i} = itemData;
%                 elseif contains(app.OrderListBox.Items{i}, 'Bode Mag') 
%                     itemData = {app.SimulinkModelEdit.Value, app.MethodLocationEdit.Value, app.BodeMagEdit.Value};
%                     app.OrderListBox.ItemsData{i} = itemData;
%                 elseif contains( app.OrderListBox.Items{i}, 'Bode Phase')
%                     itemData = {app.SimulinkModelEdit.Value, app.MethodLocationEdit.Value, app.BodePhaseEdit.Value};
%                     app.OrderListBox.ItemsData{i} = itemData;
%                 end
%  
%             end
% 
%         end

        function onTableEdit(app, ~, event)
            switch event.Indices(2)
                case 2
                    objTitle = [app.PlotTitles{event.Indices(1)}, ' - Bode Mag'];
                    currCol = 'SelectAllMag';
                case 3
                    objTitle = [app.PlotTitles{event.Indices(1)}, ' - Bode Phase'];
                    currCol = 'SelectAllPhase';
                case 4
                    objTitle = [app.PlotTitles{event.Indices(1)}, ' - Nichols'];
                    currCol = 'SelectAllNick';
            end


            if event.NewData 
                app.OrderTable.Data = [app.OrderTable.Data; objTitle];
                idx = strcmp(app.ObjectName2OutputDataInd(:,1), objTitle);
                value = app.ObjectName2OutputDataInd{idx, 2};
                app.OutputDataIndexArray = [app.OutputDataIndexArray, value];
            else
                % Find the tile of the object in the listbox
                match_idx = strcmp(objTitle, app.OrderTable.Data);
                app.OrderTable.Data(match_idx) = [];
                app.OutputDataIndexArray(match_idx) = [];
            end

            if all([app.DataTable.Data{:,event.Indices(2)}])
                app.(currCol).Value = true;
            elseif any([app.DataTable.Data{:,event.Indices(2)}])
%                 app.(currCol).Text = '▣';
            else
                app.(currCol).Value = false;
            end

            focus(app.UIFigure);
        end

%         function onTableEdit(app, ~, event)
%             switch event.Indices(2)
%                 case 2
%                     objTitle = [app.PlotTitles{event.Indices(1)}, ' - Bode Mag'];
%                     currCol = 'SelectAllMag';
%                 case 3
%                     objTitle = [app.PlotTitles{event.Indices(1)}, ' - Bode Phase'];
%                     currCol = 'SelectAllPhase';
%             end
%         
%             if event.NewData
%                 % Add to order
%                 app.OrderTable.Data = [app.OrderTable.Data; objTitle];
%         
%                 % Use the static title->index map we built in initOnMdlLoad
%                 idx = strcmp(app.ObjectName2OutputDataInd(:,1), objTitle);
%                 value = app.ObjectName2OutputDataInd{idx, 2};
%                 app.OutputDataIndexArray = [app.OutputDataIndexArray, value];
%             else
%                 % Remove from order
%                 match_idx = strcmp(objTitle, app.OrderTable.Data);
%                 app.OrderTable.Data(match_idx) = [];
%                 app.OutputDataIndexArray(match_idx) = [];
%             end
%         
%             % Update header checkbox state for that column
%             colVals = [app.DataTable.Data{:,event.Indices(2)}];
%             if all(colVals)
%                 app.(currCol).Value = true;
%             else
%                 app.(currCol).Value = false;
%             end
%         
%             focus(app.UIFigure);
%         end


        function onCommNameCheck(app, ~, eventData)
            app.UseCommonName = eventData.Value;
            focus(app.UIFigure);
        end
        
        function onBrowseSimulink(app, ~)
%             choice = questdlg('Do you want to use common names for the titles?', ...
%                 'Name Option', ...
%                 'Yes', 'No', 'Cancel', 'Yes');
%             
%             switch choice
%                 case 'Cancel'
%                     return; % User canceled, do nothing
%                 case 'Yes'
%                     app.UseCommonName = true;
%                 case 'No'
%                     app.UseCommonName = false;
%             end


            app.SimulinkModelEdit.Value = app.openFileDialog('*.slx');
            if isempty(app.SimulinkModelEdit.Value)
                focus(app.UIFigure);
                return;
            end
            set(app.SimulinkModelEdit,'Value', app.SimulinkModelEdit.Value);
            focus(app.UIFigure);
            initOnMdlLoad(app);
            
        end

        function onBrowseMethodLocation(app, ~)
            path = uigetdir(pwd, 'Select Method File Location');
            if isempty(path)
                focus(app.UIFigure);
                return;
            end
            set(app.MethodLocationEdit,'Value', path);
            app.MethodFullPath = path;
            focus(app.UIFigure);
        end

        function onFileNameEdit(app, ~, event)
            [~, filename, ext] = fileparts(event.Value);
            app.MethodFileName = [filename, '.m'];
            focus(app.UIFigure);
        end

        function onBrowseNichols(app, ~)
            app.NicholsPlotEdit.Value = app.openFileDialog('*.m');
            if isempty(app.NicholsPlotEdit.Value)
                focus(app.UIFigure);
                return;
            end
            set(app.NicholsPlotEdit,'Value', app.NicholsPlotEdit.Value);
            focus(app.UIFigure);
        end

        function onBrowseBodeMag(app, ~)
            app.BodeMagEdit.Value = app.openFileDialog('*.m');
            if isempty(app.BodeMagEdit.Value)
                focus(app.UIFigure);
                return;
            end
            set(app.BodeMagEdit,'Value', app.BodeMagEdit.Value);
            focus(app.UIFigure);
        end

        function onBrowseBodePhase(app, ~)
            app.BodePhaseEdit.Value = app.openFileDialog('*.m');
            if isempty(app.BodePhaseEdit.Value)
                focus(app.UIFigure);
                return;
            end
            set(app.BodePhaseEdit,'Value', app.BodePhaseEdit.Value);
            focus(app.UIFigure);
        end

        function onFreqMrkEdit(app, ~, event)
            try
                x = eval(event.Value);
                if isvector(x)
                    if length(x) <= length(app.FrequencyMarkersList) && ...
                            all(x >= min(eval(app.FrequencyVector)) & x <= max(eval(app.FrequencyVector)))
                        app.FrequencyMarkers = event.Value;
                    else
                        msgbox(['Frequency Marker list can not contain more then ',int2str(length(app.FrequencyMarkersList)),' items.'], "Error", "error");
                        app.FreqMarkersEdit.Value = '';
                        app.FrequencyMarkers = [];
                        return
                    end
                else
                    app.FreqMarkersEdit.Value = '';
                    app.FrequencyMarkers = [];
                    return
                end
            catch
                app.FreqMarkersEdit.Value = '';
                app.FrequencyMarkers = [];
            end
            focus(app.UIFigure);
        end

        function onFreqVecEdit(app, ~, event)
            try
                x = eval(event.Value);
                if isvector(x)
                    app.FrequencyVector = event.Value;
                else
                    app.FreqVectorEdit.Value = '';
                    app.FrequencyVector = [];
                    return
                end
            catch
                app.FreqVectorEdit.Value = '';
                app.FrequencyVector = [];
            end
            focus(app.UIFigure);
        end

        function onLoad(app, ~)

            if check4Missing(app)
                focus(app.UIFigure);
                msgbox("Please Complete All Fields Before Loading.", "Error", "error");
                return;
            end
        
            filepath = fullfile(app.MethodFullPath,app.MethodFileName);
            create_clfr_file(app, filepath);
            
            objs = createFRObjs(app);
            notify(app,'ObjectLoaded',UserInterface.UserInterfaceEventData(objs));
            focus(app.UIFigure);
            msgbox("Method exported successfully.", "Success");
        end

        function onExport(app, ~)
            if check4Missing(app)
                focus(app.UIFigure);
                msgbox("Please Complete All Fields Before Loading.", "Error", "error");
                return;
            end
            filepath = fullfile(app.MethodFullPath,app.MethodFileName);
            create_clfr_file(app, filepath);
            msgbox("Method exported successfully.", "Success");
        end

        function onExportObjects(app, ~)
            if check4Missing(app)
                focus(app.UIFigure);
                msgbox("Please Complete All Fields Before Loading.", "Error", "error");
                return;
            end
            pathname = uigetdir(pwd);
            drawnow();pause(0.1);
            if isequal(pathname,0)
                return;
            end
            objs = createFRObjs(app);outputFile

            for i = 1:length(objs)
                Requirement = objs(i);
                drawnow();pause(0.01);
                filename = objs(i).Title;
                save(fullfile(pathname,filename),'Requirement');
            end
            focus(app.UIFigure);
        end

        function onMoveUp(app, ~)
            idx = app.OrderTable.Selection(1);
            items = app.OrderTable.Data;
            pos = find(strcmp(items, items{idx}));
            if pos > 1
                [items{pos}, items{pos-1}] = deal(items{pos-1}, items{pos});
                [app.OutputDataIndexArray(pos), app.OutputDataIndexArray(pos-1)] = deal(app.OutputDataIndexArray(pos-1), app.OutputDataIndexArray(pos));
                app.OrderTable.Data = items;
                app.OrderTable.Selection = [pos-1,1];
            end
            focus(app.UIFigure);
        end

        function onMoveDown(app, ~)
            idx = app.OrderTable.Selection(1);
            items = app.OrderTable.Data;
            pos = find(strcmp(items, items{idx}));
            if pos < numel(items)
                [items{pos}, items{pos+1}] = deal(items{pos+1}, items{pos});
                [app.OutputDataIndexArray(pos), app.OutputDataIndexArray(pos+1)] = deal(app.OutputDataIndexArray(pos+1), app.OutputDataIndexArray(pos));
                app.OrderTable.Data = items;
                app.OrderTable.Selection = [pos+1,1];
            end
            focus(app.UIFigure);
        end

        function removePlotFromList(app, source, eventdata)
            if isempty(app.OrderTable.Selection)
                return;
            end
            idx = app.OrderTable.Selection(1);
            selLineStr = app.OrderTable.Data{idx};

            if contains(selLineStr, 'Bode Mag') 
                col = 2;
            elseif contains(selLineStr, 'Bode Phase')
                col = 3;
             elseif contains(selLineStr, 'Nichols')
                col = 4;
            end

            selLineCleaned = regexprep(selLineStr, ' - (Bode Mag|Bode Phase|Nichols)$', '');
            row = find(contains(app.DataTable.Data(:,1), selLineCleaned));
            event.Indices = [row, col];
            event.NewData = false;
            onTableEdit(app, [], event);
            app.DataTable.Data{row, col} = false;
            
        end
    
        function selectDeselectAllColumns(app, source, eventdata, type)
            if isempty(app.DataTable.Data)
                return;
            end
            
            switch type
                case 'mag' 
                    col = 2;
                case 'phase'
                    col = 3;
                case 'nick'
                    col = 4;
            end

            if eventdata.Value ==  0
                app.DataTable.Data(:, col) = {false};
                event.NewData = false;
                for i = 1:size(app.DataTable.Data, 1)     
                    event.Indices= [i, col];
                    onTableEdit(app, [], event);
                end
            else
                temp = cell2mat(app.DataTable.Data(:, col));
                app.DataTable.Data(:, col) = {true};
                event.NewData = true;
                for i = 1:size(app.DataTable.Data, 1)  
                    if ~temp(i)
                    event.Indices= [i, col];
                    onTableEdit(app, [], event);
                    end
                end
            end
            




        end

%         function val = check4Missing(app)
%             val = 1;
%             if isempty(app.SimulinkModelEdit.Value) || ... 
%                     isempty(app.MethodLocationEdit.Value) || ... 
%                     isempty(app.MethodFileEdit.Value) || ... 
%                     isempty(app.FreqVectorEdit.Value) || ... 
%                     isempty(app.FreqMarkersEdit.Value) || ...
%                     any([app.DataTable.Data{:,4}]) && isempty(app.NicholsPlotEdit.Value) || ...
%                     any([app.DataTable.Data{:,2}]) && isempty(app.BodeMagEdit.Value) || ... 
%                     any([app.DataTable.Data{:,3}]) && isempty(app.BodePhaseEdit.Value)
%             else
%                 val = 0;
%             end
%         end
    
        function val = check4Missing(app)
            val = 1;
            if isempty(app.SimulinkModelEdit.Value) || ...
               isempty(app.MethodLocationEdit.Value) || ...
               isempty(app.MethodFileEdit.Value) || ...
               isempty(app.FreqVectorEdit.Value) || ...
               ( any([app.DataTable.Data{:,2}]) && isempty(app.BodeMagEdit.Value) ) || ...
               ( any([app.DataTable.Data{:,3}]) && isempty(app.BodePhaseEdit.Value) )
                % remain val = 1
            else
                val = 0;
            end
        end        

    end

    methods (Access = public)

        % Construct app
        function app = FrequencyResponseEditorApp
            createComponents(app)
            startupFcn(app);
        end

        % Code that executes before app deletion
        function delete(app)
            delete(app.UIFigure)
        end
    end

    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and grid layout
            app.UIFigure = uifigure('Name', 'Frequency Response Editor');
            position = app.UIFigure.Position;
            app.UIFigure.Position = [ position(1) , position(2) - 300 , 990 , 750 ];        
            app.UIFigure.Resize = 'off';

            % --- Title ---
            t1 = uipanel(app.UIFigure, ...
                'Position', [10 720 970 30], ...
                'BorderType', 'line', ...
                'BackgroundColor', 'black');
            uilabel(t1, 'Text', ' Frequency Response Editor', 'FontWeight', 'bold', 'FontSize', 16,...
                'BackgroundColor', [55/255, 96/255, 146/255],...
                'FontColor', [1, 1, 1],...
                'FontName', 'Courier New',...
                'Position', [2 2 966 26]);
        
            % Panel: Model and Method
            methodPanel = uipanel(app.UIFigure, ...
                'Title', 'Model and Method', ...
                'Position', [10 600 970 110]);
            
            uilabel(methodPanel, 'Text', 'Simulink Model:', ...
                'Position', [10 60 120 22]);
            app.SimulinkModelEdit = uieditfield(methodPanel, 'text', ...
                'Position', [130 60 550 22]);
            app.SimulinkModelEdit.Editable = false;
            app.SimulinkModelBrowseButton = uibutton(methodPanel, 'Text', 'Browse', ...
                'ButtonPushedFcn', @(s, e) onBrowseSimulink(app),...
                'Position', [700 60 70 22]);
            
            uilabel(methodPanel, 'Text', 'Method Export Folder:', ...
                'Position', [10 35 130 22]);
            app.MethodLocationEdit = uieditfield(methodPanel, 'text', ...
                'Position', [130 35 550 22]);
            app.MethodLocationEdit.Editable = false;
            app.MethodLocationBrowseButton = uibutton(methodPanel, 'Text', 'Browse', ...
                'ButtonPushedFcn', @(s, e) onBrowseMethodLocation(app),...
                'Position', [700 35 70 22]);
            
            uilabel(methodPanel, 'Text', 'Method Filename:', ...
                'Position', [10 10 120 22]);
            app.MethodFileEdit = uieditfield(methodPanel, 'text', ...
                'Value', '', 'Position', [130 10 550 22], ...
                'ValueChangedFcn', @(s, e) onFileNameEdit(app, s, e));
            % Plot Settings panel
            plotPanel = uipanel(app.UIFigure, 'Title', 'Plot Settings', 'Position', [10 480 970 110]);
            
            % (Nichols row removed)
            
            % Row 1 (top): Bode Magnitude
            uilabel(plotPanel, 'Text', 'Bode Magnitude Background Plot:', 'Position', [10 60 185 22]);
            app.BodeMagEdit = uieditfield(plotPanel, 'text', 'Position', [200 60 360 22]);
            app.BodeMagEdit.Editable = false;
            app.BodeMagBrowseButton = uibutton(plotPanel, 'Text', 'Browse', ...
                'ButtonPushedFcn', @(s, e) onBrowseBodeMag(app), ...
                'Position', [570 60 70 22]);
            
            % Row 2 (middle): Bode Phase
            uilabel(plotPanel, 'Text', 'Bode Phase Background Plot:', 'Position', [10 35 185 22]);
            app.BodePhaseEdit = uieditfield(plotPanel, 'text', 'Position', [200 35 360 22]);
            app.BodePhaseEdit.Editable = false;
            app.BodePhaseBrowseButton = uibutton(plotPanel, 'Text', 'Browse', ...
                'ButtonPushedFcn', @(s, e) onBrowseBodePhase(app), ...
                'Position', [570 35 70 22]);
            
            % Right side: Frequency inputs (kept aligned with two-row layout)
            uilabel(plotPanel, 'Text', 'Frequency Vector', 'Position', [660 45 120 22]);
            app.FreqVectorEdit = uieditfield(plotPanel, 'text', 'Value', app.FrequencyVector, ...
                'ValueChangedFcn', @(s, e) onFreqVecEdit(app, s, e), ...
                'Position', [770 45 160 22]);
            
%             uilabel(plotPanel, 'Text', 'Frequency Markers', 'Position', [660 20 120 22]);
%             app.FreqMarkersEdit = uieditfield(plotPanel, 'text', 'Value', app.FrequencyMarkers, ...
%                 'ValueChangedFcn', @(s, e) onFreqMrkEdit(app, s, e), ...
%                 'Position', [770 20 160 22]);

            % Plot Settings panel
%             plotPanel = uipanel(app.UIFigure, 'Title', 'Plot Settings', 'Position', [10 480 970 110]);
% 
%             uilabel(plotPanel, 'Text', 'Nichols Background Plot:', 'Position', [10 60 185 22]);
%             app.NicholsPlotEdit = uieditfield(plotPanel, 'text', 'Position', [200 60 360 22]);
%             app.NicholsPlotEdit.Editable = false;
%             app.NicholsPlotBrowseButton = uibutton(plotPanel, 'Text', 'Browse',...
%                 'ButtonPushedFcn', @(s, e) onBrowseNichols(app), ...
%                 'Position', [570 60 70 22]);
% 
%             uilabel(plotPanel, 'Text', 'Bode Magnitude Background Plot:', 'Position', [10 35 185 22]);
%             app.BodeMagEdit = uieditfield(plotPanel, 'text', 'Position', [200 35 360 22]);
%             app.BodeMagEdit.Editable = false;
%             app.BodeMagBrowseButton = uibutton(plotPanel, 'Text', 'Browse', ...
%                 'ButtonPushedFcn', @(s, e) onBrowseBodeMag(app),...
%                 'Position', [570 35 70 22]);
% 
%             uilabel(plotPanel, 'Text', 'Bode Phase Background Plot:', 'Position', [10 10 185 22]);
%             app.BodePhaseEdit = uieditfield(plotPanel, 'text', 'Position', [200 10 360 22]);
%             app.BodePhaseEdit.Editable = false;
%             app.BodePhaseBrowseButton = uibutton(plotPanel, 'Text', 'Browse', ...
%                 'ButtonPushedFcn', @(s, e) onBrowseBodePhase(app),...
%                 'Position', [570 10 70 22]);
% 
%             uilabel(plotPanel, 'Text', 'Frequency Vector', 'Position', [660 45 120 22]);
%             app.FreqVectorEdit = uieditfield(plotPanel, 'text', 'Value', app.FrequencyVector, ...
%                 'ValueChangedFcn', @(s, e) onFreqVecEdit(app, s, e),...
%                 'Position', [770 45 160 22]);
% 
%             uilabel(plotPanel, 'Text', 'Frequency Markers', 'Position', [660 20 120 22]);
%             app.FreqMarkersEdit = uieditfield(plotPanel, 'text', 'Value', app.FrequencyMarkers, ...
%                 'ValueChangedFcn', @(s, e) onFreqMrkEdit(app, s, e),...
%                 'Position', [770 20 160 22]);
                % --- Brokenloop Selection Panel ---
                brknLoopPanel = uipanel(app.UIFigure, ...
                    'Title', 'Plot Selection', ...
                    'Position', [10 70 970 400]);
                
                p0 = uipanel(brknLoopPanel, ...
                    'Position', [10 340 40 30], ...
                    'BorderType', 'line', ...
                    'BackgroundColor', 'black');
                uilabel(p0, 'Text', ' #', 'FontWeight', 'bold', ...
                    'BackgroundColor', [55/255, 96/255, 146/255], ...
                    'FontColor', [1, 1, 1], ...
                    'FontName', 'Courier New', ...
                    'Position', [2 2 36 26]);
                
                p1 = uipanel(brknLoopPanel, ...
                    'Position', [50 340 270 30], ...
                    'BorderType', 'line', ...
                    'BackgroundColor', 'black');
                uilabel(p1, 'Text', ' Title', 'FontWeight', 'bold', ...
                    'BackgroundColor', [55/255, 96/255, 146/255], ...
                    'FontColor', [1, 1, 1], ...
                    'FontName', 'Courier New', ...
                    'Position', [2 2 266 26]);
                
                p2 = uipanel(brknLoopPanel, ...
                    'Position', [320 340 80 30], ...
                    'BorderType', 'line', ...
                    'BackgroundColor', 'black');
                uilabel(p2, 'Text', 'Bode Mag', 'FontWeight', 'bold', ...
                    'BackgroundColor', [55/255, 96/255, 146/255], ...
                    'FontColor', [1, 1, 1], ...
                    'FontName', 'Courier New', ...
                    'Position', [2 2 76 26]);
                
                p3 = uipanel(brknLoopPanel, ...
                    'Position', [400 340 85 30], ...
                    'BorderType', 'line', ...
                    'BackgroundColor', 'black');
                uilabel(p3, 'Text', 'Bode Phase', 'FontWeight', 'bold', ...
                    'BackgroundColor', [55/255, 96/255, 146/255], ...
                    'FontColor', [1, 1, 1], ...
                    'FontName', 'Courier New', ...
                    'Position', [2 2 81 26]);
                
                % Nichols column removed
                
                app.DataTable = uitable(brknLoopPanel, ...
                    'Position', [10 30 475 310]);  % shrink width since Nichols gone
                app.DataTable.ColumnName = {}; % {'Title','Bode Mag','Bode Phase'};
                app.DataTable.ColumnWidth = {'auto',80,85}; 
                app.DataTable.ColumnEditable = [false true true];
                app.DataTable.CellEditCallback = @(s, e) onTableEdit(app, s, e);
                
                % --- Select/Deselect All checkboxes ---
                uilabel(brknLoopPanel, 'Text', 'Select/Deselect All:', ...
                    'Position', [220 5 105 20]); 
                
                app.SelectAllMag = uicheckbox(brknLoopPanel, 'Text', '', 'Value', true, ...
                    'ValueChangedFcn', @(s, e) selectDeselectAllColumns(app, s, e, 'mag'), ...
                    'Position', [360 5 20 20]);
                
                app.SelectAllPhase = uicheckbox(brknLoopPanel, 'Text', '', 'Value', true, ...
                    'ValueChangedFcn', @(s, e) selectDeselectAllColumns(app, s, e, 'phase'), ...
                    'Position', [432 5 20 20]);

% Nichols select-all removed

%             % --- Brokenloop Selection Panel ---
%             brknLoopPanel = uipanel(app.UIFigure, ...
%                 'Title', 'Brokenloop Selection', ...
%                 'Position', [10 70 970 400]);
% 
%             p0 = uipanel(brknLoopPanel, ...
%                 'Position', [10 340 40 30], ...
%                 'BorderType', 'line', ...
%                 'BackgroundColor', 'black');
%             uilabel(p0, 'Text', ' #', 'FontWeight', 'bold', ...
%                 'BackgroundColor', [55/255, 96/255, 146/255], ...
%                 'FontColor', [1, 1, 1], ...
%                 'FontName', 'Courier New', ...
%                 'Position', [2 2 36 26]);
%             p1 = uipanel(brknLoopPanel, ...
%                 'Position', [50 340 270 30], ...
%                 'BorderType', 'line', ...
%                 'BackgroundColor', 'black');
%             uilabel(p1, 'Text', ' Title', 'FontWeight', 'bold', ...
%                 'BackgroundColor', [55/255, 96/255, 146/255], ...
%                 'FontColor', [1, 1, 1], ...
%                 'FontName', 'Courier New', ...
%                 'Position', [2 2 266 26]);
% 
%             p2 = uipanel(brknLoopPanel, ...
%                 'Position', [320 340 80 30], ...
%                 'BorderType', 'line', ...
%                 'BackgroundColor', 'black');
%             uilabel(p2, 'Text', 'Bode Mag', 'FontWeight', 'bold', ...
%                 'BackgroundColor', [55/255, 96/255, 146/255], ...
%                 'FontColor', [1, 1, 1], ...
%                 'FontName', 'Courier New', ...
%                 'Position', [2 2 76 26]);
% 
%             p3 = uipanel(brknLoopPanel, ...
%                 'Position', [400 340 85 30], ...
%                 'BorderType', 'line', ...
%                 'BackgroundColor', 'black');
%              uilabel(p3, 'Text', 'Bode Phase', 'FontWeight', 'bold', ...
%                 'BackgroundColor', [55/255, 96/255, 146/255], ...
%                 'FontColor', [1, 1, 1], ...
%                 'FontName', 'Courier New', ...
%                 'Position', [2 2 81 26]);
% 
%             p4 = uipanel(brknLoopPanel, ...
%                 'Position', [485 340 60 30], ...
%                 'BorderType', 'line', ...
%                 'BackgroundColor', 'black');
%              uilabel(p4, 'Text', 'Nichols', 'FontWeight', 'bold', ...
%                 'BackgroundColor', [55/255, 96/255, 146/255], ...
%                 'FontColor', [1, 1, 1], ...
%                 'FontName', 'Courier New', ...
%                 'Position', [2 2 56 26]);  
% 
%             app.DataTable = uitable(brknLoopPanel, ...
%                 'Position', [10 30 535 310]);
%             app.DataTable.ColumnName = {}; %{'Title','Bode Mag','Bode Phase','Nichols'};
%             app.DataTable.ColumnWidth = {'auto',80,85,60};
%             app.DataTable.ColumnEditable = [false true true true];
%             app.DataTable.CellEditCallback = @(s, e) onTableEdit(app, s, e);
% 
%              uilabel(brknLoopPanel, 'Text', 'Select/Deselect All:',....
%                 'Position', [220 5 105 20]); 
% 
%             app.SelectAllMag = uicheckbox(brknLoopPanel, 'Text', '', 'Value', true, ...
%                 'ValueChangedFcn', @(s, e) selectDeselectAllColumns(app, s, e, 'mag'),...
%                 'Position', [360 5 20 20]);
% 
%             app.SelectAllPhase = uicheckbox(brknLoopPanel, 'Text', '', 'Value', true, ...
%                 'ValueChangedFcn', @(s, e) selectDeselectAllColumns(app, s, e, 'phase'),...
%                 'Position', [432 5 20 20]);
% 
%             app.SelectAllNick = uicheckbox(brknLoopPanel, 'Text', '', 'Value', true, ...
%                 'ValueChangedFcn', @(s, e) selectDeselectAllColumns(app, s, e, 'nick'),...
%                 'Position', [505 5 20 20]);

            % Order listbox
            p6 = uipanel(brknLoopPanel, ...
                'Position', [550 340 40 30], ...
                'BorderType', 'line', ...
                'BackgroundColor', 'black');
            uilabel(p6, 'Text', ' #', 'FontWeight', 'bold', ...
                'BackgroundColor', [55/255, 96/255, 146/255], ...
                'FontColor', [1, 1, 1], ...
                'FontName', 'Courier New', ...
                'Position', [2 2 36 26]);

            p7 = uipanel(brknLoopPanel, ...
                'Position', [590 340 316 30], ...
                'BorderType', 'line', ...
                'BackgroundColor', 'black');
             uilabel(p7, 'Text', ' Order', 'FontWeight', 'bold', ...
                'BackgroundColor', [55/255, 96/255, 146/255], ...
                'FontColor', [1, 1, 1], ...
                'FontName', 'Courier New', ...
                'Position', [2 2 312 26]);
  
            cm = uicontextmenu(app.UIFigure);
            uimenu(cm,'Text','Remove','Callback',@app.removePlotFromList);

            app.OrderTable = uitable(brknLoopPanel, ...
                'uicontextmenu',cm,...
                'Position', [550 30 355 310]);
            app.OrderTable.ColumnName = {}; 
            app.OrderTable.ColumnWidth = {'auto'};
            app.OrderTable.ColumnEditable = [false];


  
            % --- Move Buttons ---
            app.MoveUpButton = uibutton(brknLoopPanel, 'Text', 'Up', ...
                'ButtonPushedFcn', @(s, e) onMoveUp(app), ...
                'Position', [910 240 50 22]);
        
            app.MoveDownButton = uibutton(brknLoopPanel, 'Text', 'Down', ...
                'ButtonPushedFcn', @(s, e) onMoveDown(app), ...
                'Position', [910 210 50 22]);
        
            % --- Load and Export Buttons ---
            app.LoadButton = uibutton(app.UIFigure, 'Text', 'Load', ...
                'ButtonPushedFcn', @(s, e) onLoad(app),...
                'Position', [20 20 120 30]);
        
            app.ExportMethodButton = uibutton(app.UIFigure, 'Text', 'Export Method', ...
                'ButtonPushedFcn', @(s, e) onExport(app),...
                'Position', [160 20 120 30]);

            focus(app.UIFigure);
        end
    end
end
function result = generateCustomPattern(nBlocks)
% Generates pattern like [1,5,6,2,7,8,...] with nBlocks blocks
% Each block = [i, offset1, offset1+1], where offset1 starts at nBlocks+1
    result = zeros(1, nBlocks * 2);  % Each block contributes 3 elements
    offset = nBlocks + 1;
    idx = 1;

    for i = 1:nBlocks
        result(idx)     = offset;
        result(idx + 1) = offset + 1;
        result(idx + 2) = i;
%         offset = offset + 2;
        idx = idx + 2;
    end
end
% function result = generateCustomPattern(nBlocks)
% % Generates pattern like [1,5,6,2,7,8,...] with nBlocks blocks
% % Each block = [i, offset1, offset1+1], where offset1 starts at nBlocks+1
%     result = zeros(1, nBlocks * 3);  % Each block contributes 3 elements
%     offset = nBlocks + 1;
%     idx = 1;
% 
%     for i = 1:nBlocks
%         result(idx)     = offset;
%         result(idx + 1) = offset + 1;
%         result(idx + 2) = i;
%         offset = offset + 2;
%         idx = idx + 3;
%     end
% end

function common = longestCommonSubstring(str1, str2)
%LONGESTCOMMONSUBSTRING Returns the longest common substring between two strings

    n = length(str1);
    m = length(str2);
    L = zeros(n+1, m+1);
    len = 0;
    pos = 0;

    for i = 1:n
        for j = 1:m
            if str1(i) == str2(j)
                L(i+1,j+1) = L(i,j) + 1;
                if L(i+1,j+1) > len
                    len = L(i+1,j+1);
                    pos = i;
                end
            end
        end
    end

    if len > 0
        common = str1(pos-len+1:pos);
    else
        common = '';
    end

    common = regexprep(common, '_+$', '');
%     common = strrep(common, '_', ' ');
end
