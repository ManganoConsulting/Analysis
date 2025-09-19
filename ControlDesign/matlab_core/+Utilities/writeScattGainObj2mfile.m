function outFile =  writeScattGainObj2mfile( operCond , singleFile , labelHeader , labelData )
    outFile = [];
    if nargin == 1
        singleFile = false;
    end

    if ~singleFile
        for ind = 1:length(operCond)
            filenames{ind} = [tempname,'.m']; %#ok<AGROW>
            fid1 = fopen(filenames{ind},'wt');%fopen(['OperatingCondition',int2str(ind),'.m'],'wt');
            writeOC(operCond(ind),fid1) 
            fclose('all');

        end
        outFile = filenames;
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
%%

function writeOC(operCond,fid1)


    
    write2File( fid1 , operCond.Label     , 'Label' );
    write2File( fid1 , operCond.ModelName , 'ModelName' );

    props = properties(operCond.FlightCondition);
    for i = 1:length(props)
        write2File( fid1 , operCond.FlightCondition.(props{i}) , props{i} );
    end


    for i = 1:length(operCond.MassProperties.Parameter)
        write2File( fid1 , operCond.MassProperties.Parameter(i).Value , operCond.MassProperties.Parameter(i).Name );
    end

    for i = 1:length(operCond.LinearModel)

        write2File( fid1 , operCond.LinearModel(i).A , ['A',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).B , ['B',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).C , ['C',operCond.LinearModel(i).Label] );
        write2File( fid1 , operCond.LinearModel(i).D , ['D',operCond.LinearModel(i).Label] );
    end

    for i = 1:length(operCond.Inputs)
        write2File( fid1 , operCond.Inputs(i).Value , ['Inputs.',operCond.Inputs(i).Name] );
    end        

    for i = 1:length(operCond.Outputs)
        write2File( fid1 , operCond.Outputs(i).Value , ['Outputs.',operCond.Outputs(i).Name] );
    end 

    for i = 1:length(operCond.States)
        write2File( fid1 , operCond.States(i).Value , ['States.',operCond.States(i).Name] );
    end    

    for i = 1:length(operCond.StateDerivs)
        write2File( fid1 , operCond.StateDerivs(i).Value , ['StateDerivs.',operCond.StateDerivs(i).Name] );
    end   
end


function write2File(fid1, x , name )
    %name  = inputname(1);
    units = '[-]';
    if max(size(x)) == 1 || ischar(x)
        if length(name) >= 12 
            if ischar(x)
                fprintf(fid1,'%s\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                fprintf(fid1,'%s\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        elseif length(name) >= 8 && length(name) < 12  ;
            if ischar(x)
                fprintf(fid1,'%s\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                fprintf(fid1,'%s\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end

        elseif length(name) >= 4  && length(name) < 8  ;
            if ischar(x)
                fprintf(fid1,'%s\t\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                fprintf(fid1,'%s\t\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        elseif length(name) >= 1  && length(name) < 4  ;
            if ischar(x)
                fprintf(fid1,'%s\t\t\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                fprintf(fid1,'%s\t\t\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        end
        

    elseif max(size(x)) > 1 && ~ischar(x)
        
        fprintf(fid1,'\n');
        fprintf(fid1,'%s\t%s\n','%',units);
        fprintf(fid1,'%s\t%s\n',name, '=[');
        for iter2 = 1:1:max(size(x))
            if iter2 < max(size(x))
                for iter3 =  1:1:min(size(x))
                    if x(iter2,iter3) < 0
                        fprintf(fid1,'%s%.4e',' ',x(iter2,iter3));
                    else 
                        fprintf(fid1,'%s%.4e','  ', x(iter2,iter3));
                    end 
                end
                fprintf(fid1,'\n');

            elseif iter2 == max(size(x))

                for iter3 =  1:1:min(size(x))
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

