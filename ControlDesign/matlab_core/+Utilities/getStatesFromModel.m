function getStatesFromModel( mdlName ) % obj.ModelName
                [~,~,x0]=eval([ mdlName '([],[],[],0)']);

% % %             % Use StateNames
% % %             blkTypes = get_param(x0,'BlockType');
% % %             % Remove Mdl Reg
% % %             stateBlks = x0(~strcmp(blkTypes,'ModelReference'));
% % %             stateNameInfo = get_param( stateBlks ,'ContinuousStateAttributes');
% % %             stateNames = {};
% % %             for i = 1:length(stateNameInfo)
% % %                 stateNames = [stateNames , eval(stateNameInfo{i})];
% % %             end

    [ ~ , stateNames ] = cellfun( @fileparts , x0 , 'UniformOutput' , false );
    [ ~ , ia ] = ismember(stateNames,{obj.States.Name});
    obj.States      = obj.States(ia);


            % State Names
            try
                [~,~,x0]=eval([mdl '([],[],[],0)']);
                [ ~ , stateNames ] = cellfun( @fileparts , x0 , 'UniformOutput' , false );
            catch
                msgbox('Unable to update model');
                return;
            end
                
            % State Deriv Names
            stateDerivNames = cellfun(@(x) [x,'dot'],stateNames,'UniformOutput',false);



end % getStatesFromModel