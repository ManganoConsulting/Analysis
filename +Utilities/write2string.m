function str = write2string( operCond )

if length(operCond) ~= 1
    error('Operating condition length can only be one.');
end


str = writeOC(operCond); 


end
%%

function str = writeOC(operCond)

    str = '';
    
    str = [ str , write2File(  operCond.Label     , 'Label' )];
    str = [ str , write2File(  operCond.ModelName , 'ModelName' )];

    props = properties(operCond.FlightCondition);
    for i = 1:length(props)
        str = [ str , write2File(  operCond.FlightCondition.(props{i}) , props{i} )];
    end


    for i = 1:length(operCond.MassProperties.Parameter)
        str = [ str , write2File(  operCond.MassProperties.Parameter(i).Value , operCond.MassProperties.Parameter(i).Name )];
    end

    for i = 1:length(operCond.LinearModel)

        str = [ str , write2File(  operCond.LinearModel(i).A , ['A',operCond.LinearModel(i).Label] )];
        str = [ str , write2File(  operCond.LinearModel(i).B , ['B',operCond.LinearModel(i).Label] )];
        str = [ str , write2File(  operCond.LinearModel(i).C , ['C',operCond.LinearModel(i).Label] )];
        str = [ str , write2File(  operCond.LinearModel(i).D , ['D',operCond.LinearModel(i).Label] )];
    end

    for i = 1:length(operCond.Inputs)
        str = [ str , write2File(  operCond.Inputs(i).Value , ['Inputs.',operCond.Inputs(i).Name] )];
    end        

    for i = 1:length(operCond.Outputs)
        str = [ str , write2File(  operCond.Outputs(i).Value , ['Outputs.',operCond.Outputs(i).Name] )];
    end 

    for i = 1:length(operCond.States)
        str = [ str , write2File(  operCond.States(i).Value , ['States.',operCond.States(i).Name] )];
    end    

    for i = 1:length(operCond.StateDerivs)
        str = [ str , write2File(  operCond.StateDerivs(i).Value , ['StateDerivs.',operCond.StateDerivs(i).Name] )];
    end   
end


function str = write2File( x , name )

    units = '[-]';
    if max(size(x)) == 1 || ischar(x)
        if length(name) >= 12 
            if ischar(x)
                str = sprintf('%s\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                str = sprintf('%s\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        elseif length(name) >= 8 && length(name) < 12  ;
            if ischar(x)
                str = sprintf('%s\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                str = sprintf('%s\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end

        elseif length(name) >= 4  && length(name) < 8  ;
            if ischar(x)
                str = sprintf('%s\t\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                str = sprintf('%s\t\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        elseif length(name) >= 1  && length(name) < 4  ;
            if ischar(x)
                str = sprintf('%s\t\t\t\t%s\t\''%s''%s\t\t\t%s\t%s\n'  ,name,  '= ',x, ';','%',units);
            elseif isnumeric(x)
                str = sprintf('%s\t\t\t\t%s\t%10.4f%s\t\t\t%s\t%s\n'  ,name,  '=',x, ';','%',units);
            end
        end
        

    elseif max(size(x)) > 1 && ~ischar(x)
        str = sprintf('\n');
        str = [ str , sprintf('%s\t%s\n','%',units)];
        str = [ str , sprintf('%s\t%s\n',name, '=[')];
        for iter2 = 1:1:max(size(x))
            if iter2 < max(size(x))
                for iter3 =  1:1:min(size(x))
                    if x(iter2,iter3) < 0
                        str = [ str , sprintf('%s%.4e',' ',x(iter2,iter3))];
                    else 
                        str = [ str , sprintf('%s%.4e','  ', x(iter2,iter3))];
                    end 
                end
                str = [ str , sprintf('\n')];

            elseif iter2 == max(size(x))

                for iter3 =  1:1:min(size(x))
                    if x(iter2,iter3) < 0
                        str = [ str , sprintf('%s%.4e',' ',x(iter2,iter3))];
                    else 
                        str = [ str , sprintf('%s%.4e','  ', x(iter2,iter3))];
                    end 
                end
                str = [ str , sprintf('];\n\n')]; %#ok<*AGROW>
            end
        end


    end
end

