function mdlParams = assignParameters2Model( mdlName , mdlParams, selMdlInd )
    import ScatteredGain.*
    load_system(mdlName);
    wrkspace = get_param(mdlName,'modelworkspace');
    if ~strcmp(wrkspace.DataSource,'Model File')
        wrkspace.reload;
    end
    
    if ~isempty(wrkspace)
        % Call if the input is Scattered Gains Collection - Called for
        % Requirment objects
        if isa(mdlParams,'ScatteredGain.GainCollection')
            % Assign the Design Parameters to the model
            for i = 1:length(mdlParams.RequirementDesignParameter)  
                wrkspace.assignin(mdlParams(selMdlInd).RequirementDesignParameter(i).Name,mdlParams.RequirementDesignParameter(i).Value(selMdlInd));%(mdlParams.DesignParameter(i).Name,mdlParams.DesignParameter(i).Value);
            end
            % Assign the Gains to the model
            for i = 1:length(mdlParams.Gain)  
                wrkspace.assignin(mdlParams.Gain(i).Name,mdlParams.Gain(i).Value(selMdlInd));
            end
            % Assign the Filter Parameters to the model
            filtParams = mdlParams.Filters.getFilterParameterValues;
            for i = 1:length(filtParams)  
                wrkspace.assignin(filtParams(i).Name,filtParams(i).Value);
            end
        else % Called in input is Name-Value struct
            for i = 1:length(mdlParams)  
                wrkspace.assignin(mdlParams(i).Name,mdlParams(i).Value(selMdlInd));
            end
        end
    end

    wrkspaceParams = wrkspace.whos;
    mdlParams = struct();
    for i = 1:length(wrkspaceParams)
       mdlParams.(wrkspaceParams(i).name) = getVariable(wrkspace,wrkspaceParams(i).name); 
        
    end
    
end % assignParameters2Model 