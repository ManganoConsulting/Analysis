function appendReplaceLineInFile( filename , newLine , num2Keep )

    if nargin == 2
        num2Keep = inf;
    end


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
            existingRecent = [newLine,existingRecent];
            %existingRecent{end + 1} = newLine;
        else
            keepRecent = existingRecent(~logArray);
            shiftRecent = existingRecent(logArray);
            existingRecent = [shiftRecent,keepRecent];
        end


        % Determine how many to keep
        if length(existingRecent) > num2Keep
            prj2keep = existingRecent( 1 : num2Keep );
        else
            prj2keep = existingRecent;
        end

    else
        prj2keep = {newLine};
    end

    % write to file
    fileID = fopen(filename,'wt');
    for i = 1:length(prj2keep)
        fprintf(fileID,'%s\n',prj2keep{i});
    end
    fclose(fileID);

end