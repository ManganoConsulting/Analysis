
function evaledParams = evalUserParameters( obj ,  params , operCond , optParams , defaultParams )
% operCond = the selected design operating condition
% params = requirement collection parameters on 1st and 2nd call. Gains on
% the 3rd call
% optParams = empty on 1st and 2nd call. requirement collection parameters \
% on the 3rd call
% The first time this function is called it is for gain synthesis only .
% The second and third are for running the reqs.

% Evaluate all Parameters in the function workspace
%     % Evaluate all base params in this workspace
%     if nargin == 4
%         for i = 1:length(baseParams)
%             eval( [ baseParams(i).Name , ' = baseParams(i).Value;'  ] );
%         end   
%     end


    %% Initialize Output
    for i = 1:length(params)
        evaledParams(i) = ScatteredGain.Parameter(params(i).Name);
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
            try
                val = getVal(operCond,'FlightCondition',ptlOperCondParam{i}); %#ok<*NASGU>
                eval([ ptlOperCondParam{i} , ' = val;']);   
            catch
                try
                    val = getVal(operCond,'FlightCondition',upper(ptlOperCondParam{i})); %#ok<*NASGU>
                    eval([ ptlOperCondParam{i} , ' = val;']);   
                catch
                    try
                        str = [upper(ptlOperCondParam{i}(1)),ptlOperCondParam{i}(2:end)];
                        val = getVal(operCond,'FlightCondition',str); %#ok<*NASGU>
                        eval([ ptlOperCondParam{i} , ' = val;']);   
                    catch
                        try
                            val = getVal(operCond,'Inputs',ptlOperCondParam{i}); %#ok<*NASGU>
                            eval([ ptlOperCondParam{i} , ' = val;']); 
                        catch
                            try
                                val = getVal(operCond,'Outputs',ptlOperCondParam{i}); %#ok<*NASGU>
                                eval([ ptlOperCondParam{i} , ' = val;']); 
                            catch
                                try
                                    val = getVal(operCond,'MassProperties',ptlOperCondParam{i}); %#ok<*NASGU>
                                    eval([ ptlOperCondParam{i} , ' = val;']);  
                                catch

                                end
                            end
                        end
                    end
                end
            end
        end   
    end

    
%% Create Output
    % Initialize Parameters
    redo  = UserInterface.ControlDesign.Parameter.empty;
    redo2 = UserInterface.ControlDesign.Parameter.empty;
%     evaledParams = ScatteredGain.Parameter.empty;
    
       
    
    for i = 1:length(optParams)
        eval( [ optParams(i).Name , ' = optParams(i).Value;' ] );
    end
    
    % First try to evaluate all parameters.  If they can be evaluated then
    % eval the parameters into the workspace.  If not then store them in
    % the variable 'redo'
    for i = 1:length(params)
        val = params(i).Value;
        if ischar(val) %strcmp(val,'Missing Info')
            try
                val = eval( params(i).ValueString );
                eval( [ params(i).Name , ' = ' , num2str(val) ,';' ] );
                evaledParams( i ) = ScatteredGain.Parameter( params(i).Name , val , params(i).ValueString );
            catch
                redo( end + 1 ) = params(i);
            end
        else
            evaledParams( end + 1 ) = ScatteredGain.Parameter( params(i).Name , val , params(i).ValueString );
            eval( [ params(i).Name , ' = val;' ] );
        end
    end



    for i  = 1:length( redo ) 
        try
            % Try and eval parameter in workspace to see if the needed
            % variable now exists.  If so eval it also to supply future
            % variables needed.
            val = eval( redo(i).ValueString );
            eval( [ redo(i).Name , ' = val;' ] );
            evaledParams( end + 1 ) = ScatteredGain.Parameter( redo(i).Name , val , redo(i).ValueString );
        catch
            redo2( end + 1 ) = redo(i);
        end
    end 
    
    for i  = 1:length( redo2 ) 
        try
            % Try and eval parameter in workspace to see if the needed
            % variable now exists.  If so eval it also to supply future
            % variables needed.
            val = eval( redo2(i).ValueString );
            eval( [ redo2(i).Name , ' = val;' ] );
            evaledParams( end + 1 ) = ScatteredGain.Parameter( redo2(i).Name , val , redo2(i).ValueString );%#ok<*AGROW>
        catch
            
            
            
            %warning([redo2(i).Name ,' could not be evaluated.']); 
            %--------------------------------------------------------------
            %    Display Log Message
            %--------------------------------------------------------------
            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Gain:',gainCellStruct{1}(i).Name,' - ',num2str(gainCellStruct{1}(i).Value),'.'],'info'));
            %--------------------------------------------------------------
        end
    end 
    
    %% Go to default setting
    
    
end % evalUserParameters



