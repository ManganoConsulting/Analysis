function mdlParamsOut = assignParameters2Model( mdlName , mdlParams )
% Writes parameter collection to model workspace

    if ischar(mdlName)
        mdlName = {mdlName};
    end
    for indMdl = 1:length(mdlName)

        load_system(mdlName{indMdl});

        wrkspace = get_param(mdlName{indMdl},'modelworkspace');
        if ~strcmp(wrkspace.DataSource,'Model File')
            wrkspace.reload;
        end

        if ~isempty(wrkspace)
            for i = 1:length(mdlParams)  
                if isnumeric(mdlParams(i).Value)
                    wrkspace.assignin(mdlParams(i).Name,mdlParams(i).Value);
                end
            end
        end

        wrkspaceParams = wrkspace.whos;
        mdlParamsOut = struct();
        for i = 1:length(wrkspaceParams)

           mdlParamsOut.(wrkspaceParams(i).name) = getVariable(wrkspace,wrkspaceParams(i).name); 

        end
    end

end % assignParameters2Model





%         wrkspace = get_param(mdlName{indMdl},'modelworkspace');
%         wrkspaceParams = wrkspace.whos;
%         mdlParamsOut = struct();
%         for i = 1:length(wrkspaceParams)
%             wrkspaceParams(i).name
%            mdlParamsOut.(wrkspaceParams(i).name) = getVariable(wrkspace,wrkspaceParams(i).name); 
% 
%         end