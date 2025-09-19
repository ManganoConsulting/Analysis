function pos = getPosInPixels(obj)     
% Returns the postion of a handle graphics object in pixels
    orgUnits = get(obj,'Units');
    set(obj,'Units','Pixels');
    pos = get(obj,'Position');
    set(obj,'Units',orgUnits);

end