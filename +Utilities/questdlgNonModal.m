function choice = questdlgNonModal(parent, message, title, varargin)
%QUESTDLGNONMODAL UIFigure-aware replacement for legacy questdlg utility.
%
%   choice = Utilities.questdlgNonModal(parent, message, title, btn1, btn2, ...)
%   displays a confirmation dialog owned by the supplied parent UIFigure. The
%   final argument is treated as the default option when it matches one of the
%   preceding button labels, mimicking the behaviour of questdlg.

arguments
    parent
    message
    title {mustBeTextScalar(title)}
end
arguments (Repeating)
    varargin
end

fig = Utilities.getParentFigure(parent);
if isempty(fig) || ~isvalid(fig)
    error('Utilities:questdlgNonModal:InvalidParent', ...
        'Unable to determine a valid UIFigure for dialog display.');
end

text = Utilities.formatDialogMessage(message);

[options, defaultOption] = iParseOptions(varargin);

args = {'Options', options, 'DefaultOption', defaultOption};
idxCancel = find(strcmpi(options, 'Cancel'), 1);
if ~isempty(idxCancel)
    args = [args, {'CancelOption', options{idxCancel}}]; %#ok<AGROW>
end

choice = uiconfirm(fig, text, title, args{:});
end

function [options, defaultOption] = iParseOptions(inputs)
%IPARSEOPTIONS Derive button options and default selection.
if isempty(inputs)
    options = {'OK'};
    defaultOption = 'OK';
    return;
end

raw = cellfun(@string, inputs, 'UniformOutput', false);
raw = [raw{:}];
options = cellstr(raw);

if numel(options) >= 2
    defaultCandidate = options{end};
    prior = options(1:end-1);
    if any(strcmp(defaultCandidate, prior))
        defaultOption = defaultCandidate;
        options = prior;
    else
        defaultOption = options{1};
    end
else
    defaultOption = options{1};
end

if isempty(options)
    options = {defaultOption};
end

if ~any(strcmp(defaultOption, options))
    options = [options, {defaultOption}]; %#ok<AGROW>
end
end
