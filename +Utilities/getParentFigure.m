function fig = getParentFigure(candidate)
%GETPARENTFIGURE Return the owning UIFigure for the supplied candidate.
%
%   fig = Utilities.getParentFigure(candidate) walks up typical handle and
%   object hierarchies to locate the matlab.ui.Figure that should own modal
%   dialogs. When no UIFigure can be determined an empty array is returned.

fig = matlab.ui.Figure.empty;

if nargin < 1 || isempty(candidate)
    return;
end

if iscell(candidate)
    for k = 1:numel(candidate)
        fig = Utilities.getParentFigure(candidate{k});
        if ~isempty(fig)
            return;
        end
    end
    return;
end

try
    if isa(candidate,'matlab.ui.Figure') && isvalid(candidate)
        fig = candidate;
        return;
    end
catch
    % ignore objects that do not support isa/isvalid
end

try
    if isgraphics(candidate)
        anc = ancestor(candidate,'figure','toplevel');
        if ~isempty(anc) && isa(anc,'matlab.ui.Figure') && isvalid(anc)
            fig = anc;
            return;
        end
    end
catch
    % non-graphics inputs may throw, ignore
end

if isobject(candidate)
    propNames = {'Figure','UIFigure','ParentFigure','Parent', ...
        'ParentUIFigure','TreeObj','Tree','Container','ParentContainer'};
    for k = 1:numel(propNames)
        if isprop(candidate, propNames{k})
            try
                parentCandidate = candidate.(propNames{k});
            catch
                parentCandidate = [];
            end
            fig = Utilities.getParentFigure(parentCandidate);
            if ~isempty(fig)
                return;
            end
        end
    end
end

currentFig = get(groot,'CurrentFigure');
if isa(currentFig,'matlab.ui.Figure') && isvalid(currentFig)
    fig = currentFig;
end
end
