function [y , str] = isInSingleQuotes(x)
    y = false;
    str = [];
    if ~isempty(x) && ischar(x)
        str = x;
        if strcmp(x(1),'''') && strcmp(x(end),'''')
            y = true;
            str = x(2:end-1);
        end
    end
end