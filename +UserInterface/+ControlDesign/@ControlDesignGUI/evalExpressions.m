function evaledParams = evalExpressions( obj ,  params , operCond , optParams , defaultParams )
% This function evaluates parameter and gain expressions
% Input arguments
% 1 - handle object
% 2 - array of parameters/gains to be evaluated | 1xN
% 3 - the operating conditon that is used in the expression | 1x1
% 4 - additional parameters to evaluate, cannot contain expressions | 1xN
% 5 - The default parameter(s) to use if the expression cannot be evaluated

%     if nargin == 5
%         for i = 1:length(defaultParams)
%             eval( [ defaultParams(i).Name , ' = defaultParams(i).Value;'  ] );
%         end   
%     end


    % Initialize Output
    evaledParams = ScatteredGain.Parameter.empty;
    for i = 1:length(params)
        evaledParams(i) = ScatteredGain.Parameter(params(i).Name);
    end
    
    % Evaluate Optional Parameters
    for i = 1:length(optParams)
        eval( [ optParams(i).Name , ' = optParams(i).Value;' ] );
    end

    %% Find all potential operating condition parameters
    symVars = {};
    for i = 1:length(params)
        if isvector(params(i).ValueString)
            symVars = [symVars;symvar(params(i).ValueString)];
        end
    end

    ptlOperCondParam = setdiff(symVars,{params.Name});

    %% Evaluate all potential operating condition parameters
    for i = 1:length(ptlOperCondParam)
        try
            val = getVal(operCond,'LinearModel',ptlOperCondParam{i}); %#ok<*NASGU>
            eval([ ptlOperCondParam{i} , ' = val;']); 
        catch
%             error(['Unable to find parameter ',ptlOperCondParam{i}])
            try
                val = getVal(operCond,'FlightCondition',ptlOperCondParam{i}); %#ok<*NASGU>
                eval([ ptlOperCondParam{i} , ' = val;']);   
            catch
%                 error(['Unable to find parameter ',ptlOperCondParam{i}])
                try
                    val = getVal(operCond,'FlightCondition',upper(ptlOperCondParam{i})); %#ok<*NASGU>
                    eval([ ptlOperCondParam{i} , ' = val;']);   
                catch
%                     error(['Unable to find parameter ',ptlOperCondParam{i}])
                    try
                        str = [upper(ptlOperCondParam{i}(1)),ptlOperCondParam{i}(2:end)];
                        val = getVal(operCond,'FlightCondition',str); %#ok<*NASGU>
                        eval([ ptlOperCondParam{i} , ' = val;']);   
                    catch
%                         error(['Unable to find parameter ',ptlOperCondParam{i}])
                        try
                            val = getVal(operCond,'Inputs',ptlOperCondParam{i}); %#ok<*NASGU>
                            eval([ ptlOperCondParam{i} , ' = val;']); 
                        catch
%                             error(['Unable to find parameter ',ptlOperCondParam{i}])
                            try
                                val = getVal(operCond,'Outputs',ptlOperCondParam{i}); %#ok<*NASGU>
%                                 eval([ ptlOperCondParam{i} , ' = val;']); 
                            catch
%                                 error(['Unable to find parameter ',ptlOperCondParam{i}])
                                try
                                    val = getVal(operCond,'MassProperties',ptlOperCondParam{i}); %#ok<*NASGU>
                                    eval([ ptlOperCondParam{i} , ' = val;']);  
                                catch
%                                     error(['Unable to find parameter ',ptlOperCondParam{i}])
                                end
                            end
                        end
                    end
                end
            end
        end   
    end

    %% Initialize Parameters
    redoIndex  = [];
    redoIndex2 = [];
    
    % First try to evaluate all parameters.  If they can be evaluated then
    % eval the parameters into the workspace.  If not then store them in
    % the variable 'redoIndex'
    for i = 1:length(params)
        val = params(i).Value;
        if ischar(val) %strcmp(val,'Missing Info');
            try
                val = eval( params(i).ValueString );
                eval( [ params(i).Name , ' = ' , num2str(val) ,';' ] );
                evaledParams(i) = ScatteredGain.Parameter( params(i).Name , val , params(i).ValueString );
            catch
                redoIndex( end + 1 ) = i;
            end
        else
            evaledParams(i).Value       =  val;
            evaledParams(i).ValueString = params(i).ValueString;
            eval( [ params(i).Name , ' = val;' ] );
        end
    end
 
    
    for i  = 1:length( redoIndex ) 
        ind = redoIndex(i);
        try
            % Try and eval parameter in workspace to see if the needed
            % variable now exists.  If so eval it also to supply future
            % variables needed.
            val = eval( params(ind).ValueString );
            eval( [ params(ind).Name , ' = val;' ] );
            evaledParams(ind).Value       =  val;
            evaledParams(ind).ValueString = params(ind).ValueString; 
        catch
            redoIndex2( end + 1 ) = ind;
        end
    end 
    
    
    removeInd = [];
    for i  = 1:length( redoIndex2 ) 
        ind = redoIndex2(i);
        try
            % Try and eval parameter in workspace to see if the needed
            % variable now exists.  If so eval it also to supply future
            % variables needed.
            val = eval( params(ind).ValueString );
            eval( [ params(ind).Name , ' = val;' ] );
            evaledParams(ind).Value       =  val;
            evaledParams(ind).ValueString = params(ind).ValueString; 
        catch
            
            if strcmp(params(ind).Type,'Normal')
                        error('Parameter:Evaluate',  ['Unable to evaluate parameter ', evaledParams(ind).Name ,'.']);
            else
                removeInd = [removeInd,ind]; %#ok<AGROW>
                error(['Unable to find parameter ',evaledParams(ind).Name]);
            end

        end
    end 
     
    evaledParams(removeInd) = [];
    
    
    
end





