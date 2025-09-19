function [y_In , y_Out , y_State , y_StateDot , inUnit , outUnit , stateUnit , stateDotUnit, CStateID] = getNamesFromModel( mdlName ) % obj.ModelName
% Get the input, output, state, state derivative names from the model
% type = 'Input' | 'Output' | 'State'
% stateGetType 1 = blocknames | 2 = maskParameters |  3 = Simulink.BlockDiagram.getInitialState

% y_In = {}; y_Out = {}; y_State = {}; y_StateDot = {};


%% Load the model
load_system(mdlName);

%% Input Names
inH  = find_system( mdlName, 'SearchDepth' , 1 , 'BlockType', 'Inport' );
[ ~ , y_In ] = cellfun( @fileparts , inH , 'UniformOutput' , false );
try
    inUnit = get_param(inH,'Unit');
catch
    inUnit = get_param(inH,'Tag');
end
inUnit(strcmp(inUnit,'inherit')) = deal({'-'});

%% Output Names
outH = find_system( mdlName, 'SearchDepth' , 1 , 'BlockType', 'Outport' );
[ ~ , y_Out ] = cellfun( @fileparts , outH , 'UniformOutput' , false );
try
    outUnit = get_param(outH,'Unit');
catch
    outUnit = get_param(outH,'Tag');
end
outUnit(strcmp(outUnit,'inherit')) = deal({'-'});

%% State(Dot) Names
try
    [~,x0,stateblocks,~,xts]=eval([ mdlName '([],[],[],0)']);
catch
    [~,x0,stateblocks,~,xts]=evalin('base',[ mdlName '([],[],[],0)']);
end

% Find the unique state names
[uniquestates,uind] = unique(stateblocks);
uniquexts = xts(uind);

% Find Continuous States Only - very important for jj_trim
CStateID = true(length(stateblocks),1);

for ct = length(uniquestates):-1:1
    ind = find(strcmp(uniquestates(ct),stateblocks));
    if uniquexts(ct) == 0 || isnan(uniquexts(ct))
        CStateID(ind) = true;
    else
        CStateID(ind) = false;
    end
end

% Get all blocktypes
BlockTypes = get_param(stateblocks(CStateID),'BlockType');

% Eliminate all Model Reference Blocks -- in future we will support
indC = ~strcmp(BlockTypes,'ModelReference');

% Get 'ContinuousStateAttributes'
uniqueCStateBlocks = unique(stateblocks(CStateID(indC)));

% Remove path
[ ~ , stateStrings ] = cellfun( @fileparts , stateblocks , 'UniformOutput' , false );
stateCell = cellfun( @(x) strsplit(x,'\n') , stateStrings , 'UniformOutput' , false );
y_State = [stateCell{:}];

% Overwrite the names from teh 'State Names' field if it exists
for i=1:length(uniqueCStateBlocks)
    try
        intStateAttribsStr= get_param(uniqueCStateBlocks{i},'ContinuousStateAttributes');
        intStateAttribs = eval(intStateAttribsStr);
    catch
        intStateAttribs= [];
    end
    %intStateAttribs = eval(intStateAttribsStr);
    
    if ~isempty(intStateAttribs)
        ind = strcmp(uniqueCStateBlocks{i},stateblocks);
        if ischar(intStateAttribs)
            y_State(ind) = {intStateAttribs};
        else
            y_State(ind) = intStateAttribs;
        end
    end   
end

% State Dot Names
if ~isempty(y_State)
    y_StateDot = cellfun(@(x) [x,'_dot'],y_State,'UniformOutput',false);
else
    y_StateDot = [];
end
    
stateUnit = get_param(stateblocks,'Tag');
emptyStateName = cellfun( @isempty , stateUnit );
stateUnit(strcmp(stateUnit,'')) = deal({'-'});
stateDotUnit = cell(size(stateUnit));
for i = 1:length(stateUnit)
    if ~emptyStateName(i)
        stateDotUnit{i} = [stateUnit{i},'/s'];
    else
        stateDotUnit{i} = '-';
    end
end
   

end % getNamesFromModel
