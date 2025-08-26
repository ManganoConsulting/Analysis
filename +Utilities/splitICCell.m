function y = splitICCell(x)  
    y = regexp(x, ' *', 'split'); 
    y = y(~cellfun(@isempty,y));
    y = [y(1:2:end)',num2cell(str2double(y(2:2:end)'))];
 
end
