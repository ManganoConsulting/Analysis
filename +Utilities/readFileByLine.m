function existingRecent = readFileByLine( filename )
debug = false;
    existingRecent = {};
    fid = fopen(filename);  
    if fid ~= -1
        tline = fgets(fid);
        while ischar(tline)
            existingRecent{end + 1} = strtrim(tline); %#ok<AGROW>
            tline = fgets(fid);
        end
        fclose(fid);

        % Remove any empty's
        blankLogArray = cellfun(@(x) isempty(strtrim(x)),existingRecent);
        existingRecent(blankLogArray) = [];
    else
        if debug
            warning(['The file "',filename,'" does not exist']);
        end
    end

end % readFileByLine