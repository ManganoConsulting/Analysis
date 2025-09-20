function create_clfr_file(app, outputFile)
%CREATE_OLFR_FILE Generates the user selected file in the specified directory


    fid = fopen(outputFile, 'w');
    if fid == -1
        error('Failed to open file for writing: %s', outputFile);
    end
    [~,filename] = fileparts(outputFile);


    skip = 3;
    nicholspltnum = 1;
    bodePlts = "";
    for i = 1:length(app.ObjectName2OutputDataInd)
%         app.ObjectName2OutputDataInd
        
        if i ~= skip
            outputIndStr = int2str(app.ObjectName2OutputDataInd{i,2});
            if contains(app.ObjectName2OutputDataInd{i,1}, 'Bode Mag')
                tempbodePlts = [
                    ""
                    "% " + app.ObjectName2OutputDataInd{i,1} 
                    "X{" + outputIndStr + "} = w; Y{" + outputIndStr + "} = Z{" + int2str(nicholspltnum) + "}; marker{" + outputIndStr + "} = '';"
    
                ];   
            else
                tempbodePlts = [
                    ""
                    "% " + app.ObjectName2OutputDataInd{i,1} 
                    "X{" + outputIndStr + "} = w; Y{" + outputIndStr + "} = phase_Save{" + int2str(nicholspltnum) + "}; marker{" + outputIndStr + "} = '';"
    
                ];   
            end
            bodePlts = [bodePlts; tempbodePlts];
        else
            nicholspltnum = nicholspltnum + 1;
            skip = skip +3;
        end
        
    end

    lines = [
        "function [X,Y,marker] = " + filename + "(oc, model, params, gains)"
        ""
        "% Call common parameters"
        "commonOCscript_Req(oc,model,params,gains);"
        ""
        "% load_system(model);"
        "[A,B,C,D] = linmod(model);"
        ""
        "% Define frequency vector"
        "w = " + app.FrequencyVector + ";"
        ""
        "% Define state space model"
        "sys  = ss(A,B,C,D);"
        ""
        "%% Frequency markers (to appear in the plots)"
        "freqMarkers = " + app.FrequencyMarkers + "; % rad/sec"
        "markers = {'o','p','^','d','s','<','>','v','h'};"
        "colors = {'k','r','g','b','y','c','m'};"
        "iFreqMarkers = zeros(size(freqMarkers));"
        "for j = 1:length(freqMarkers)"
        "    currFreqMark = freqMarkers(j);"
        "    iFreqCross = find((w(1:end-1)-currFreqMark).*(w(2:end)-currFreqMark)<=0, 1 );"
        "    iFreqMarkers(j) = iFreqCross;"
        "end"
        ""
        "nolfr = " + int2str(size(app.DataTable.Data, 1)) + ";"
        "for j = 1:nolfr"
        "    if j==1"
        "        olfrj = lft(sys,ss([],[],[],eye(nolfr-1)));"
        "    elseif j>1 && j<nolfr"
        "        dummy = lft(ss([],[],[],eye(j-1)),sys);"
        "        olfrj = lft(dummy,ss([],[],[],eye(nolfr-j)));"
        "    elseif j==nolfr"
        "        olfrj = lft(ss([],[],[],eye(nolfr-1)),sys);"
        "    end"
        ""
        "    [mag,ph] = bode(-olfrj,w);"
        "    mag_db = 20*log10(squeeze(mag));"
        "    phase  = squeeze(ph);"
        "    [magOut,phaseOut] = phaseMod(phase,mag_db);"
        ""
        "    X{j} = phaseOut;"
        "    Y{j} = magOut;"
        "    Z{j} = mag_db;"
        "    phase_Save{j} = mod(phase,-360.0);"
        "    for jj = 1:length(iFreqMarkers)"
        "        currIndex = iFreqMarkers(jj);"
        "        currMarker = markers{1+rem(jj-1,length(markers))};"
        "        currColor  = colors{1+rem(jj-1,length(colors))};"
        "        oMrk(jj).x               = phase_Save{j}(currIndex);"
        "        oMrk(jj).y               = mag_db(currIndex);"
        "        oMrk(jj).Marker          = currMarker;"
        "        oMrk(jj).MarkerSize      = 8;"
        "        oMrk(jj).MarkerFaceColor = currColor;"
        "        oMrk(jj).MarkerEdgeColor = 'k';"
        "        oMrk(jj).LegendTitle     =  [num2str(freqMarkers(jj)) ' rad/sec'];"
        "    end"
        "    marker{j} = oMrk;"
        "end"
        "" + bodePlts
        ""
        ""
        "    function [magOut,phaseOut] = phaseMod(phase,mag_db)"
        "        idPhase360 = floor(phase/360);"
        "        newId = max(idPhase360) + 1;"
        "        for id = min(idPhase360):max(idPhase360)"
        "            iPhase = find(idPhase360==id);"
        "            for i = 2:length(iPhase)"
        "                if (iPhase(i)-iPhase(i-1))>1"
        "                    idPhase360(iPhase(i:end)) = newId;"
        "                    newId = newId + 1;"
        "                end"
        "            end"
        "        end"
        ""
        "        phase = mod(phase,-360.0);"
        "        phaseOut={}; magOut={}; k=1;"
        "        for id = min(idPhase360):max(idPhase360)"
        "            iPhase = find(idPhase360==id);"
        "            phaseOut{k} = phase(iPhase);"
        "            magOut{k} = mag_db(iPhase);"
        "            k = k+1;"
        "        end"
        "    end"
        ""
        "end"
    ];

    % Write each line to file
    for i = 1:numel(lines)
        fprintf(fid, '%s\n', lines(i));
    end

    fclose(fid);
    fprintf('✅ olfr.m successfully written to: %s\n', outputFile);
end