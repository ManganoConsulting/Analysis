function cell2mfile(fileName, cellArray)
% Writes cell array content into a *.csv file.
% 

fid = fopen(fileName, 'w');

for z=1:size(cellArray, 1)
    
    if ~isempty(cellArray{z,4}) && ~ischar(cellArray{z,4})
        str = [strrep(cellArray{z,1},' ','_'), '.', strrep(cellArray{z,2},' ','_'), ' = [', char(strjoin(string(cellArray(z,4:end)),', ')), '];\n'];
    else
        str = [strrep(cellArray{z,1},' ','_'), '.', strrep(cellArray{z,2},' ','_'), ' = {''', char(strjoin(cellArray(z,4:end),''','' ')), '''};\n'];
    end
    fprintf(fid,str);

end
% Closing file
fclose(fid);






