function [X,Y,marker] = olfr(oc, model, params, gains)

% Call common parameters
commonOCscript_Req(oc,model,params,gains);

% load_system(model);
[A,B,C,D] = linmod(model);

% Define frequency vector
w = logspace(-2,2,1000);

% Define state space model
sys  = ss(A,B,C,D);


%% Frequency markers (to appear in the plots)
freqMarkers = [0.2 0.5 1 2 5]; % rad/sec
% Frequency Markers
markers = {'o','p','^','d','s','<','>','v','h'};
colors = {'k','r','g','b','y','c','m'};
% Get indices corresponding to frequency markers
iFreqMarkers = zeros(size(freqMarkers)); % initialization
for j = 1:length(freqMarkers)
    currFreqMark = freqMarkers(j);
%     iFreqCross = min(find((w(1:end-1)-currFreqMark).*(w(2:end)-currFreqMark)<=0));
    iFreqCross = find((w(1:end-1)-currFreqMark).*(w(2:end)-currFreqMark)<=0, 1 );
    iFreqMarkers(j) = iFreqCross; % store current index
end

nolfr = 11;
for j = 1:nolfr
    if j==1
        olfrj = lft(sys,ss([],[],[],eye(nolfr-1)));
    elseif j>1 && j<nolfr
        dummy = lft(ss([],[],[],eye(j-1)),sys);
        olfrj = lft(dummy,ss([],[],[],eye(nolfr-j)));
    elseif j==nolfr
        olfrj = lft(ss([],[],[],eye(nolfr-1)),sys);
    end
    
    [mag,ph] = bode(-olfrj,w);
    mag_db = 20*log10(squeeze(mag));
    phase  = squeeze(ph);
    [magOut,phaseOut] = phaseMod(phase,mag_db);
    
    X{j} = phaseOut;
    Y{j} = magOut;
    Z{j} = mag_db;
    phase = mod(phase,-360.0);
    for jj = 1:length(iFreqMarkers)
        % get current index over arrays of phase, magnitude and frequency
        currIndex = iFreqMarkers(jj);
        % get current marker and colors
        currMarker = markers{1+rem(jj-1,length(markers))};
        currColor  = colors{1+rem(jj-1,length(colors))};
        oMrk(jj).x               = phase(currIndex);
        oMrk(jj).y               = mag_db(currIndex);
        oMrk(jj).Marker          = currMarker;
        oMrk(jj).MarkerSize      = 8;
        oMrk(jj).MarkerFaceColor = currColor;
        oMrk(jj).MarkerEdgeColor = 'k';
        oMrk(jj).LegendTitle     =  [num2str(freqMarkers(jj)) ' rad/sec'];
    end  % end for jj

    marker{j} = oMrk;
end

%------------------------------
% Bode Magnitude Plots
%------------------------------
% Stabilator
X{12} = w;
Y{12} = Z{7};
marker{12} = '';

% Elevons 1&6
X{13} = w;
Y{13} = Z{8};
marker{13} = '';

% Elevons 2&5
X{14} = w;
Y{14} = Z{9};
marker{14} = '';

% Elevons 3&4
X{15} = w;
Y{15} = Z{10};
marker{15} = '';

% Pitch Control
X{16} = w;
Y{16} = Z{11};
marker{16} = '';

% Pitch Rate
X{17} = w;
Y{17} = Z{3};
marker{17} = '';



    function [magOut,phaseOut] = phaseMod(phase,mag_db)
        
        % Get identifiers for regions where phase does not vary more than 360 deg
        idPhase360 = floor(phase/360);
        
        % Ensure that different curve parts in the same 360-deg-phase region
        % are assigned different identifiers
        newId = max(idPhase360) + 1; % new identifier
        for id = min(idPhase360):max(idPhase360) % for each old identifier
            iPhase = find(idPhase360==id); % get indices corresponding to current identifier
            for i = 2:length(iPhase) % analyze index by index
                if (iPhase(i)-iPhase(i-1))>1 % if indices vary more than one unit, than the curve is not continuous; a new part is starting
                    idPhase360(iPhase(i:end)) = newId;  % change identifiers for the starting part
                    newId = newId + 1; % new identifier
                end
            end
        end
        
        % Phase between -360 and 0 degrees
        phase = mod(phase,-360.0);
        
        % Plot phase and magnitude
%         phaseOut = phase(idPhase360>=min(idPhase360) & idPhase360 <= max(idPhase360));
        phaseOut={};
        magOut={};
        k=1;
        % Plot phase and magnitude
        for id = min(idPhase360):max(idPhase360)
            iPhase = find(idPhase360==id);
            phaseOut{k} = phase(iPhase);
            magOut{k} = mag_db(iPhase);
            k = k+1;
        end
    end

end