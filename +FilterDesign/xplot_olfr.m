function [hdl] = xplot_olfr(hdl,col)
import FilterDesign.*

% Get model name and full path
modelname = hdl.data.anmodel.model(1:end-4);
modeldir  = hdl.data.anmodel.modeldir;

% Go to model directory
cur_dir = pwd;

% Get break loops titles
brokenLoopFlags  = hdl.data.input.breakloops(:,1); %Gain names
brokenLoopPoints = hdl.data.input.breakloops(:,2); %Titles
brokenLoopTypes  = hdl.data.input.breakloops(:,3); %Nichols-Bodemag-Bodephase

% Get frequency range
w = hdl.data.anmodel.freqrnge;

% Get selected break loops
brokenLoopSel = get(hdl.pnl_an_stab.lb_olfr,'Value');

% IterDataSave
idata = 1;

% for each broken loop
for iBrokenLoop = brokenLoopSel
    % Set Simulink model flags
    % Current flag = 1, all others = 0
    for jBrokenLoop = 1:length(brokenLoopFlags)
        eval([brokenLoopFlags{jBrokenLoop} '=' num2str(jBrokenLoop==iBrokenLoop) ';']);
        assignin('base',brokenLoopFlags{jBrokenLoop},(jBrokenLoop==iBrokenLoop));
    end
    % Go to model directory
    cd(modeldir);
    
    % Generate State-Space linear model from Simulink model
    %[A,B,C,D] = linmodv5(modelname);
    [A,B,C,D] = linmod(modelname);
    %
    % Get back to current directory
    cd(cur_dir);
    
    B = B(:,1);
    D = D(:,1);
    C = C(1,:);
    D = D(1,:);
    
    brokenLoop = ss(A,B,C,D);

    % Generate plots
    brokenLoopTitle = brokenLoopPoints{iBrokenLoop};
    brokenLoopType  = brokenLoopTypes{iBrokenLoop};
    
    % Identify plots
    in = strfind(lower(brokenLoopType),'nichols');
    ibm= strfind(lower(brokenLoopType),'bodemag');
    ibp= strfind(lower(brokenLoopType),'bodephase');
    
    if ~isempty(in)
        iFigNichols = 200+iBrokenLoop;
    else
        iFigNichols = 0;
    end
    if ~isempty(ibm)
        iFigBode    = 250+iBrokenLoop;
    else
        iFigBode = 0;
    end
    if ~isempty(ibp)
        hideBodePhase = 0;
    else
        hideBodePhase = 1;
    end
    
    figTitle = ['OLFR, broken at ' brokenLoopTitle]; % OLFR: Open Loop Frequency Response
    StabilityMargins = Nichols_GS(brokenLoop,w,iFigNichols,iFigBode,col,hideBodePhase,figTitle);
    
    % Store Data in hdl.data.analysis_data.olfr
    hdl.data.analysis_data.olfr(idata).title =  brokenLoopTitle;
    hdl.data.analysis_data.olfr(idata).descrp = [brokenLoopTitle, ' Stability Margins'];
    hdl.data.analysis_data.olfr(idata).results = StabilityMargins;

    idata = idata + 1;
end  % endfor iBrokenLopp