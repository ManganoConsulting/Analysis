function y = strcmpEmptys(A,B)

    
    if iscell(A) || iscell(B)
        error('Cell arrays are currently not supported');
    end
    if isnumeric(A) && isnumeric(B)
        if isempty(A) && isempty(B)
            y = true;
        else
            y = A == B;
        end
    else
        if isempty(A) && isempty(B)
            y = true;
        else
            y = strcmp(A,B);
        end
    end
end