function [inputNames, outputNames] = findSimulinkIO(app, modelName)
% findSimulinkIO Finds all top-level input and output ports in a Simulink model
%   [inputNames, outputNames] = findSimulinkIO(modelName)
%
%   Inputs:
%     modelName - Name of the Simulink model (without .slx)
%
%   Outputs:
%     inputNames  - Cell array of input port names sorted by Port number
%     outputNames - Cell array of output port names sorted by Port number

    % Load model if not already loaded
    if ~bdIsLoaded(modelName)
        load_system(modelName);
    end

    % Find top-level Inport and Outport blocks
    inports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Inport');
    outports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Outport');

    % Get Inport names and port numbers
    inputInfo = arrayfun(@(b) struct( ...
        'Name', get_param(b{1}, 'Name'), ...
        'Port', str2double(get_param(b{1}, 'Port'))), ...
        inports);

    % Get Outport names and port numbers
    outputInfo = arrayfun(@(b) struct( ...
        'Name', get_param(b{1}, 'Name'), ...
        'Port', str2double(get_param(b{1}, 'Port'))), ...
        outports);

    % Sort by port number
    [~, idxIn] = sort([inputInfo.Port]);
    [~, idxOut] = sort([outputInfo.Port]);

    inputNames = {inputInfo(idxIn).Name};
    outputNames = {outputInfo(idxOut).Name};
end