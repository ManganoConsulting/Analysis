function setMinFigureSize(fig,minSize)
% setMinFigureSize Enforce a minimum figure size without using JavaFrame
%
%   setMinFigureSize(fig,[width height]) ensures that the figure cannot be
%   resized smaller than the specified width and height.  This avoids use of
%   the removed JavaFrame property in recent MATLAB releases.
%
%   If the figure already defines a SizeChangedFcn it is preserved and
%   executed after the minimum-size check.
%
%   Example:
%       f = figure;
%       setMinFigureSize(f,[400 300]);
%
%   This utility is intended to replace previous JavaFrame based logic such
%   as: jFig = get(handle(fig),'JavaFrame');
%       jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension(w,h));

if nargin < 2 || numel(minSize) ~= 2
    error('minSize must be a two-element vector [width height].');
end

% store existing callback
oldFcn = fig.SizeChangedFcn;
fig.SizeChangedFcn = @(src,evt)resizeGuard(src,evt,minSize,oldFcn);
end

function resizeGuard(src,evt,minSize,oldFcn)
pos = src.Position;
changed = false;
if pos(3) < minSize(1)
    pos(3) = minSize(1);
    changed = true;
end
if pos(4) < minSize(2)
    pos(4) = minSize(2);
    changed = true;
end
if changed
    src.Position = pos;
end
if ~isempty(oldFcn)
    if isa(oldFcn,'function_handle')
        oldFcn(src,evt);
    else
        try
            feval(oldFcn,src,evt);
        catch
            % ignore callback errors
        end
    end
end
end
