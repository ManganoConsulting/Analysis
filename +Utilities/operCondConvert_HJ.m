function allOperCond = operCondConvert_HJ( dir , operMap , LinearModelMap , massPropMap , fltCondMap , type )
% Convert Honda linear models to an operating condition class


    allFilesofType = Utilities.subdir(fullfile(dir,['*.',type]));

    allOperCond = lacm.OperatingCondition.empty();
    

    for i = 1:length(allFilesofType)
        
        operCond = lacm.OperatingCondition();
        operCond.MassProperties = lacm.MassProperties();
        loadedFile = load(allFilesofType(i).name);
        loadedFileVarNames = fieldnames(loadedFile);
        conds = lacm.Condition.empty;
        
        fltcond = struct('Name',{},'Value',{});
        for j = 1:length(loadedFileVarNames)
            
            if any(strcmp(loadedFileVarNames{j},{operMap.Origin}));
                currentMap = operMap(strcmp(loadedFileVarNames{j},{operMap.Origin}));
                operCond.(currentMap.DestProperty) = loadedFile.(loadedFileVarNames{j}); %#ok<*AGROW>
            elseif any(strcmp(loadedFileVarNames{j},{LinearModelMap.Origin}));
                currentMap = LinearModelMap(strcmp(loadedFileVarNames{j},{LinearModelMap.Origin}));
                if isempty(operCond.LinearModel)
                    operCond.LinearModel = lacm.LinearModel('Label',currentMap.Set);
                    selCond = get(operCond.LinearModel,currentMap.Set);
                    selCond.(currentMap.DestProperty) = loadedFile.(loadedFileVarNames{j});
                else
                    selCond = get(operCond.LinearModel,currentMap.Set);
                    if isempty(selCond)
                        operCond.LinearModel(end+1) = lacm.LinearModel('Label',currentMap.Set);
                        selCond = get(operCond.LinearModel,currentMap.Set);
                        selCond.(currentMap.DestProperty) = loadedFile.(loadedFileVarNames{j});
                    else
                        selCond.(currentMap.DestProperty) = loadedFile.(loadedFileVarNames{j});
                    end
                end
            elseif any(strcmp(loadedFileVarNames{j},{massPropMap.Origin}));
                
                if strcmp(loadedFileVarNames{j},'Label')
                    operCond.MassProperties.Label = loadedFile.(loadedFileVarNames{j});
                elseif strcmp(loadedFileVarNames{j},'WeightCode')
                    operCond.MassProperties.WeightCode = loadedFile.(loadedFileVarNames{j});
                    operCond.MassProperties.Label = loadedFile.(loadedFileVarNames{j});
                else
                    operCond.MassProperties.Parameter(end + 1) = lacm.Condition(loadedFileVarNames{j},loadedFile.(loadedFileVarNames{j})); %#ok<*AGROW>
                end

            elseif any(strcmp(loadedFileVarNames{j},{fltCondMap.Origin}));
                currentMap = fltCondMap(strcmp(loadedFileVarNames{j},{fltCondMap.Origin}));
                if strcmp(currentMap.DestProperty,'TAS')
                    fltcond(end+1) = struct('Name',currentMap.DestProperty,'Value', 1/(3600/(1852/0.3048))* eval(['loadedFile.' loadedFileVarNames{j}]));
                elseif strcmp(currentMap.DestProperty,'Qbar') % Pa to psf
                    fltcond(end+1) = struct('Name',currentMap.DestProperty,'Value',(1/47.8802588889) * eval(['loadedFile.' loadedFileVarNames{j}]));
                else
                    fltcond(end+1) = struct('Name',currentMap.DestProperty,'Value',eval(['loadedFile.' loadedFileVarNames{j}]));
                end
            elseif isnumeric(loadedFile.(loadedFileVarNames{j}))

                conds(end + 1) = lacm.Condition(loadedFileVarNames{j},loadedFile.(loadedFileVarNames{j})); %#ok<*AGROW>
            elseif isstruct(loadedFile.(loadedFileVarNames{j}))

                baseNames              = Utilities.fieldnamesr(loadedFile.(loadedFileVarNames{j}));
                embeddedStructVarNames = strcat(loadedFileVarNames{j},'.',baseNames);
                fullStructVarNames     = strcat('loadedFile.',loadedFileVarNames{j},'.',baseNames);
                for k = 1:length(embeddedStructVarNames)

                    if any(strcmp(embeddedStructVarNames{k},{operMap.Origin}))
                        operCond.MassProperties.Parameter(end + 1) = lacm.Condition(baseNames{k},eval(fullStructVarNames{k})); %#ok<*AGROW>

                    elseif any(strcmp(embeddedStructVarNames{k},{LinearModelMap.Origin}))
                        operCond.MassProperties.Parameter(end + 1) = lacm.Condition(baseNames{k},eval(fullStructVarNames{k})); %#ok<*AGROW>


                    elseif any(strcmp(embeddedStructVarNames{k},{massPropMap.Origin}))
                        currentMap = massPropMap(strcmp(embeddedStructVarNames{k},{massPropMap.Origin}));
                        if strcmp(currentMap.DestProperty,'Label')
                            operCond.MassProperties.Label = eval(fullStructVarNames{k});
                        elseif strcmp(currentMap.DestProperty,'WeightCode')
                            operCond.MassProperties.WeightCode = eval(fullStructVarNames{k});
                        else
                            operCond.MassProperties.Parameter(end + 1) = lacm.Condition(baseNames{k},eval(fullStructVarNames{k})); %#ok<*AGROW>
                        end
                    elseif any(strcmp(embeddedStructVarNames{k},{fltCondMap.Origin}))
                        currentMap = fltCondMap(strcmp(embeddedStructVarNames{k},{fltCondMap.Origin}));
                        if strcmp(currentMap.DestProperty,'TAS')
                            fltcond(end+1) = struct('Name',currentMap.DestProperty,'Value',1.68780986 * eval(fullStructVarNames{k}));
                        else
                            fltcond(end+1) = struct('Name',currentMap.DestProperty,'Value',eval(fullStructVarNames{k}));
                        end

                    elseif isnumeric(eval(fullStructVarNames{k}))
                        conds(end + 1) = lacm.Condition(baseNames{k},eval(fullStructVarNames{k})); %#ok<*AGROW>

                    elseif isstruct(eval(fullStructVarNames{k}))
                       error('Broken.');  
                    end

                end
                
                

            end
        end

        operCond.FlightCondition = lacm.FlightCondition(fltcond(1).Name,fltcond(1).Value,fltcond(2).Name,fltcond(2).Value,fltcond(3).Name,fltcond(3).Value,fltcond(4).Name,fltcond(4).Value,fltcond(5).Name,fltcond(5).Value);
        operCond.Inputs = conds;
%         operCond.Outputs= conds;
        allOperCond(end+1) = copy(operCond);

    end

end