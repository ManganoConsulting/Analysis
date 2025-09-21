function lineAdded = appendLineInFile( filename , newLine  )
    lineAdded = false;

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
        if ~any(logArray)
            existingRecent = [existingRecent,newLine];
            lineAdded = true;
            
            % write to file
            fileID = fopen(filename,'wt');
            for i = 1:length(existingRecent)
                fprintf(fileID,'%s\n',existingRecent{i});
            end
            fclose(fileID);
        end
    else
        lineAdded = true;
        % write to file
        fileID = fopen(filename,'wt');
        fprintf(fileID,'%s\n',newLine);
        fclose(fileID); 
    end
end