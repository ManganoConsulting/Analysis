function enforceMinimumFigureSize(fig, minSize)
%enforceMinimumFigureSize Ensure a UI figure cannot be resized below a threshold.
%   Utilities.enforceMinimumFigureSize(FIG, MINSIZE) clamps the Width and Height
%   of the figure FIG so that they are not resized below the values specified in
%   the 1x2 vector MINSIZE. The enforcement is applied immediately and is also
%   installed on the figure SizeChangedFcn so that future user interactions
%   respect the same minimum size. Any existing SizeChangedFcn defined on the
%   figure is preserved and executed after the size enforcement logic.
%
%   This helper is intended to replace the old JavaFrame minimum-size logic
%   that relied on undocumented APIs. It provides similar behaviour in a
%   UIFIGURE-compatible manner.
%
%   Example
%       fig = uifigure('Position',[100 100 400 300]);
%       Utilities.enforceMinimumFigureSize(fig,[400 300]);
%
%   See also UIFIGURE

%   Copyright 2024

arguments
    fig (1,1) matlab.ui.Figure
    minSize (1,2) double {mustBeNonnegative}
end

% Normalise the minimum size vector to [width height].
minSize = double(minSize(:).');
if numel(minSize) ~= 2
    error('Utilities:enforceMinimumFigureSize:InvalidSize', ...
        'The minimum size must be a two-element vector of [width height].');
end

appDataKey = localAppDataKey();
existingState = getappdata(fig, appDataKey);

if ~isempty(existingState)
    % Update stored minimum size if the helper is re-run on the same figure.
    existingState.MinSize = minSize;
    setappdata(fig, appDataKey, existingState);
else
    state = struct(...
        'MinSize', minSize,...
        'OriginalCallback', fig.SizeChangedFcn,...
        'Enforcing', false);
    setappdata(fig, appDataKey, state);
    fig.SizeChangedFcn = @(src, evt)localSizeChangedProxy(src, evt, appDataKey);
end

% Apply the constraint immediately so the figure honours the minimum size
% even before the user interacts with it.
localApplyMinimumSize(fig, appDataKey);
end

function localSizeChangedProxy(src, evt, appDataKey)
if ~isvalid(src)
    return;
end
state = getappdata(src, appDataKey);
if isempty(state)
    return;
end

if ~state.Enforcing
    state.Enforcing = true;
    setappdata(src, appDataKey, state);
    cleanup = onCleanup(@()localResetEnforcing(src, appDataKey));
    %#ok<NASGU> intentionally unused variable keeps cleanup alive
    localApplyMinimumSize(src, appDataKey);
end

if ~isempty(state.OriginalCallback)
    try
        if isa(state.OriginalCallback, 'function_handle')
            state.OriginalCallback(src, evt);
        else
            feval(state.OriginalCallback, src, evt);
        end
    catch err
        warning('Utilities:enforceMinimumFigureSize:CallbackError', ...
            'Error executing original SizeChangedFcn: %s', err.message);
    end
end
end

function localApplyMinimumSize(fig, appDataKey)
if ~isvalid(fig)
    return;
end
state = getappdata(fig, appDataKey);
if isempty(state)
    return;
end
pos = fig.Position;
newWidth = max(pos(3), state.MinSize(1));
newHeight = max(pos(4), state.MinSize(2));
if newWidth ~= pos(3) || newHeight ~= pos(4)
    fig.Position(3:4) = [newWidth, newHeight];
end
end

function localResetEnforcing(fig, appDataKey)
if ~isvalid(fig)
    return;
end
state = getappdata(fig, appDataKey);
if isempty(state)
    return;
end
state.Enforcing = false;
setappdata(fig, appDataKey, state);
end

function key = localAppDataKey()
key = 'Utilities_MinimumFigureSize';
end