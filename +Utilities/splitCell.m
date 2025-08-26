function y = splitCell(x)      
    y = regexp(x, ' *', 'split');
    y = y(~cellfun(@isempty,y));
end
