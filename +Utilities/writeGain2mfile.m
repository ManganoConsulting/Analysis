function writeGain2mfile( objIn , filename )


    if isa(objIn,'ScheduledGain.SchGain')
        gainObj = objIn;
    elseif isa(objIn,'ScheduledGain.SchGainCollection')
        gainObj = objIn.Gain;
    else
        return;
    end
    
        
    fid1 = fopen(filename,'wt');
    for ind = 1:length(gainObj)
        fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
        fprintf(fid1,'%s\t%s\n', '%' , gainObj(ind).Name );
        fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
        writeOC(gainObj(ind),fid1);
        fprintf(fid1,'\n');
        fprintf(fid1,'\n');
        fprintf(fid1,'\n');
    end
    fclose('all');

end
%%

function writeOC(schGainObj,fid1)


    if schGainObj.Ndim == 2
        
        breakpoints1Values = schGainObj.Breakpoints1Values;
        breakpoints2Values = schGainObj.Breakpoints2Values;
        
%         if ~iscolumn(breakpoints1Values);breakpoints1Values = breakpoints1Values';end
%         if ~iscolumn(breakpoints2Values);breakpoints2Values = breakpoints2Values';end
        
        write2File( fid1 , breakpoints1Values   , [schGainObj.Name,'.',schGainObj.BreakPoints1Name] );

        write2File( fid1 , breakpoints2Values  , [schGainObj.Name,'.',schGainObj.BreakPoints2Name] );

        write2File( fid1 , schGainObj.TableData              , [schGainObj.Name,'.TableData']);

    else
        breakpoints2Values = schGainObj.Breakpoints2Values';
        if ~iscolumn(breakpoints2Values);breakpoints2Values = breakpoints2Values';end
        
        write2File( fid1 , breakpoints2Values   , [schGainObj.Name,'.',schGainObj.BreakPoints2Name] );

        write2File( fid1 , schGainObj.TableData , [schGainObj.Name,'.TableData']);
    end

end


function write2File(fid1, x , name )
    %name  = inputname(1);
    
    [str, ~] = Utilities.gencode_rvalue(x);
    
    if length(str) == 1
        fprintf(fid1,'%s\t%s\n'  ,name, ['= ',str{1}, ';']);%fprintf(fid1,'%s\t%s\t\%s%s\n'  ,name, '= ',str{1}, ';');
    else
        for i = 1:length(str)
            if i == 1
                fprintf(fid1,'%s\t%s\n'  ,name, ['= ',str{i}]);%fprintf(fid1,'%s\t%s\t\%s%s\n'  ,name, '= ',str{i}, '...');
            elseif i == length(str)
                fprintf(fid1,'\t\t%s\n'  ,[str{i}, ';']);%fprintf(fid1,'%s\t%s\t\%s%s\n'  ,name, '= ',str{i}, ';');
            else
                fprintf(fid1,'\t\t%s\n'  ,[str{i}]);%fprintf(fid1,'%s\t%s\t\%s%s\n'  ,name, '= ',str{i}, '...');
            end
                
            
        end
    end
   
end


