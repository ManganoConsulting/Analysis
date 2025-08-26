% Nathan added
function outFile =  write2mfileCtrl( operCondColl, indices , singleFile , labelHeader , labelData )
    outFile = [];
    if nargin == 2
        singleFile = false;
    end

    if ~singleFile
        for idx = 1:length(indices)
            filenames{idx} = [tempname,'.m']; %#ok<AGROW>
            fid1 = fopen(filenames{idx},'wt');%fopen(['OperatingCondition',int2str(ind),'.m'],'wt');
            [setIdx, ocIdx] = getOcIdx(operCondColl, indices(idx));
            operCond = operCondColl.OperatingConditionCell{setIdx};
            writeOC(operCond,ocIdx,fid1) 
            fclose('all');

        end
        outFile = filenames;
        
    else
        if nargin == 3
            % Use Flight condition for labels
            outFile = [tempname,'.m']; 
            fid1 = fopen(outFile,'wt');%fid1 = fopen(['ExportedOperatingConditions','.m'],'wt');
            for ind = 1:length(operCond)
                fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'Mach' , '= ' , num2str(operCond(ind).FlightCondition.Mach ));
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'Qbar' , '= ' , num2str(operCond(ind).FlightCondition.Qbar ));
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'Alt' , '= ' , num2str(operCond(ind).FlightCondition.Alt ));
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'KCAS' , '= ' , num2str(operCond(ind).FlightCondition.KCAS ));
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'KEAS' , '= ' , num2str(operCond(ind).FlightCondition.KEAS ));
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , 'KTAS' , '= ' , num2str(operCond(ind).FlightCondition.KTAS ));
                fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
                writeOC(operCond(ind),fid1);
                fprintf(fid1,'\n');
                fprintf(fid1,'\n');
                fprintf(fid1,'\n');
            end
            fclose('all');
        else
            fid1 = fopen(['ExportedOperatingConditions','.m'],'wt');
            for ind = 1:length(operCond)
                fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{1} , '= ' , labelData{ind,1} );
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{2} , '= ' , labelData{ind,2} );
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{3} , '= ' , labelData{ind,3} );
                fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{4} , '= ' , labelData{ind,4} );
                fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
                writeOC(operCond(ind),fid1);
                fprintf(fid1,'\n');
                fprintf(fid1,'\n');
                fprintf(fid1,'\n');
            end
            fclose('all');
        end
    end
end
%%

function writeOC(operCond,ocIdx,fid1)

    fprintf(fid1,'%s\n','% -------------------------- GENERAL INFORMATION ---------------------------------------------');
    
    write2File( fid1 , operCond.Label(ocIdx)     , 'Label' );
    write2File( fid1 , operCond.ModelName(ocIdx) , 'ModelName' );
    
    fprintf(fid1,'\n%s\n','% -------------------------- FLIGHT CONDITION ----------------------------------------------');

    props = properties(operCond.FlightCondition(ocIdx)); % needs investigation
    for i = 1:length(props)
        write2File( fid1 , operCond.FlightCondition(ocIdx).(props{i}) , props{i} );
    end

    fprintf(fid1,'\n%s\n','% -------------------------- MASS PROPERTIES ------------------------------------------------');
    
    for i = 1:length(operCond.MassProperties.Parameter)
        write2File( fid1 , operCond.MassProperties.Parameter(i).Value(ocIdx) , operCond.MassProperties.Parameter(i).Name );
    end
    
    fprintf(fid1,'\n%s\n','% -------------------------- INPUTS ---------------------------------------------------------');
    
    for i = 1:length(operCond.Inputs)
        write2File( fid1 , operCond.Inputs(i).Value(ocIdx) , ['Inputs.',operCond.Inputs(i).Name] );
    end 
    
    fprintf(fid1,'\n%s\n','% -------------------------- OUTPUTS --------------------------------------------------------');

    for i = 1:length(operCond.Outputs)
        write2File( fid1 , operCond.Outputs(i).Value(ocIdx) , ['Outputs.',operCond.Outputs(i).Name] );
    end 

    fprintf(fid1,'\n%s\n','% -------------------------- STATES ---------------------------------------------------------');
    
    for i = 1:length(operCond.States)
        write2File( fid1 , operCond.States(i).Value(ocIdx) , ['States.',operCond.States(i).Name] );
    end    
    
    fprintf(fid1,'\n%s\n','% -------------------------- STATE DERIVATIVES ----------------------------------------------');

    for i = 1:length(operCond.StateDerivs)
        write2File( fid1 , operCond.StateDerivs(i).Value(ocIdx) , ['StateDerivs.',operCond.StateDerivs(i).Name] );
    end
   

    for i = 1:length(operCond.LinearModel)
        
        fprintf(fid1,'\n%s\n',['% -------------------------- LINEAR MODEL ' num2str(i) ' ----------------------------------------------------------------------------------------------------------']);
        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s%20s','%','  LABEL                 : ');
        fprintf(fid1,'%-20s\n',operCond.LinearModel(i).Label);
        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s%20s','%','  STATES                : ');
        for j=1:length(operCond.LinearModel(i).States)
            StatesStr = [num2str(j) '.' operCond.LinearModel(i).States{j}];
            fprintf(fid1,'%-20s',StatesStr);
        end
        fprintf(fid1,'\n');
        
        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s%20s','%','  INPUTS                : ');
        for j=1:length(operCond.LinearModel(i).Inputs)
            InputsStr = [num2str(j) '.' operCond.LinearModel(i).Inputs{j}];
            fprintf(fid1,'%-20s',InputsStr);
        end
        fprintf(fid1,'\n');
        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s%20s','%','  OUTPUTS               : ');
        for j=1:length(operCond.LinearModel(i).Outputs)
            OutputStr = [num2str(j) '.' operCond.LinearModel(i).Outputs{j}];
            fprintf(fid1,'%-20s',OutputStr);
        end
        fprintf(fid1,'\n');

        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s%20s','%','  INPUT CONSTRAINTS     : ');
        for j=1:length(operCond.LinearModel(i).InputConstraintsInfo)
            ConstraintsStr = [num2str(j) '.' operCond.LinearModel(i).InputConstraintsInfo{j}];
            
            if j==1
                fprintf(fid1,'%-20s\n',ConstraintsStr);
            else
                fprintf(fid1,'%s%26s','%',' ');
                fprintf(fid1,'%-20s\n',ConstraintsStr);
            end
        end
        fprintf(fid1,'%s\n','%');
        fprintf(fid1,'%s\n\n','% ----------------------------------------------------------------------------------------------------------------------------------------------------');


        write2File( fid1 , operCond.LinearModel(i).A(:,:,ocIdx) , ['A',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).B(:,:,ocIdx) , ['B',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).C(:,:,ocIdx) , ['C',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).D(:,:,ocIdx) , ['D',operCond.LinearModel(i).Label] );
    end


end


function write2File(fid1, x , name )
    %name  = inputname(1);
    units = '';
    
    j=strfind(name,' ');
    if ~isempty(j)
        name = name(1:j-1);
    end
    
    name = strtrim(name);
    
    if max(size(x)) == 1 || ischar(x)
        

        if ischar(x)
            %fprintf(fid1,'%s\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            fprintf(fid1,'%-40s\t%s\t\''%16s''%s\n'  ,name,  '= ',x, ';');
        elseif isnumeric(x)
            %fprintf(fid1,'%s\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            fprintf(fid1,'%-40s\t%s\t%16.4f%s\n'  ,name,  '=',x, ';');
        end
        

    elseif max(size(x)) > 1 && ~ischar(x)
        
%         fprintf(fid1,'\n');
        
        fprintf(fid1,'%s\t%s\n',name, '=[');
        for iter2 = 1:1:size(x,1)
            if iter2 < size(x,1)
                for iter3 =  1:1:size(x,2)
                    if x(iter2,iter3) < 0
                        fprintf(fid1,'%s%.4e',' ',x(iter2,iter3));
                    else 
                        fprintf(fid1,'%s%.4e','  ', x(iter2,iter3));
                    end 
                end
                fprintf(fid1,'\n');
            elseif iter2 == size(x,1)
                for iter3 =  1:1:size(x,2)
                    if x(iter2,iter3) < 0
                        fprintf(fid1,'%s%.4e',' ',x(iter2,iter3));
                    else 
                        fprintf(fid1,'%s%.4e','  ', x(iter2,iter3));
                    end 
                end
                fprintf(fid1,'];\n\n');
            end
        end
    end
end

