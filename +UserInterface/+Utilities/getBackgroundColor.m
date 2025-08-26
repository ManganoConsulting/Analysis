function color = getBackgroundColor(h)     
% Returns the color of a handle graphics object
    if ishandle(h) && strcmp(get(h,'type'),'figure');
        color = get(h,'Color') ; 
    else
        color = get(h,'BackgroundColor');
    end
end