function removeLineInFile( filename , newLine )
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
        % Check for duplicates
        logArray = strcmp(newLine,existingRecent);
        if any(logArray)
            existingRecent(logArray) = [];
            % write to file
            fileID = fopen(filename,'wt');
            for i = 1:length(existingRecent)
                fprintf(fileID,'%s\n',existingRecent{i});
            end
            fclose(fileID);  
        end
    else
        if debug
            warning(['The file "',filename,'" does not exist']);
        end
    end

end