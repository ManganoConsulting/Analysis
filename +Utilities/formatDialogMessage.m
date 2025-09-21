function text = formatDialogMessage(message)
%FORMATDIALOGMESSAGE Convert dialog message input into a character vector.
%
%   text = Utilities.formatDialogMessage(message) accepts character arrays,
%   string scalars, string arrays, or cell arrays of character vectors and
%   returns a single character vector separated by newline characters. This
%   helper ensures messages display correctly in UIFigure-based alerts and
%   confirmation dialogs.

if nargin < 1 || isempty(message)
    text = '';
    return;
end

if iscell(message)
    message = string(message(:));
    message = join(message, newline);
else
    message = string(message);
end

text = char(message);
end
