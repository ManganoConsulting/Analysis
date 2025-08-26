function y = sizeString( var , showClass )
    if nargin == 1
        showClass = false;
    end
    sz = size(var);
    cStr = cellfun(@num2str , num2cell(sz),'UniformOutput',false);
    y = strjoin(cStr,'x');
    if showClass
        y = [y,' ',class(var)];
    end
end

