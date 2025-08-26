function out = cat1D( cArray )
    if ~iscell(cArray)
       cArray = {cArray}; 
    end
    out = [];
    for i=1:length(cArray)

        if iscolumn(cArray{i})
            out = [out,cArray{i}'];
        else
            out = [out,cArray{i}];
        end

    end



end

