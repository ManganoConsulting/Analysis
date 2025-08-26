function [hdl] = plotInfo(hdl,wRad,FreqUnits,magdB,phaseDeg,H_Final)
import FilterDesign.*
% Get filter
iFilter    = get(hdl.gui.panelFiltersPMList,'value');

% Frequency Hz
wHz = wRad/2/pi;

AddInfoGBode = [];

% Select plottype
if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
    DCGaindB = 20*log10(dcgain(H_Final)); 
%     AddInfoGBode(1) = semilogx(hdl.gui.BodeGainAxes,0,DCGaindB,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
%     legendGain{1}  = ['\omega = 0 ' FreqUnits ', DC |F| = ' num2str(DCGaindB,'%5.1f') ' dB'];
%     
    HFGaindB = 20*log10(H_Final.num{1}(1)/H_Final.den{1}(1));
%     AddInfoGBode(2) = semilogx(hdl.gui.BodeGainAxes,0,HFGaindB,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
%     legendGain{2}  = ['\omega = inf ' FreqUnits ', HF |F| = ' num2str(HFGaindB,'%5.1f') ' dB'];
    
    if hdl.data.Filter(iFilter).CenterAttn < hdl.data.Filter(iFilter).DCGain
        [MGain,iM] = min(magdB);
        GainType = 'MIN';
        legLocG = 'SouthWest';
        legLocP = 'NorthWest';
        legLocN = 'Northwest';
    else
        [MGain,iM] = max(magdB);
        GainType = 'MAX';
        
        legLocG = 'NorthWest';
        legLocP = 'SouthWest';
        legLocN = 'Southwest';
    end
    
    MPhase = phaseDeg(iM);
    
    if strcmp(FreqUnits,'Hz');
        wM = wHz(iM);
    else
        wM = wRad(iM);
    end
    
    AddInfoGBode(1) = semilogx(hdl.gui.BodeGainAxes,wM,MGain,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    legendGain{1}  =  ['\omega = ' num2str(wM,'%5.1f') ' ' FreqUnits ', |F|_{' GainType '} = ' num2str(MGain,'%5.1f') ' dB'];
    
    
    [MinPhase,iMin] = min(phaseDeg);
    MinGain = magdB(iMin);
    [MaxPhase,iMax] = max(phaseDeg);
    MaxGain = magdB(iMax);
    
    if strcmp(FreqUnits,'Hz');
        wMinPhase = wHz(iMin);
        wMaxPhase = wHz(iMax);
    else
        wMinPhase = wRad(iMin);
        wMaxPhase = wRad(iMax);
    end
    
    AddInfoPBode(1) = semilogx(hdl.gui.BodePhaseAxes,wMinPhase,MinPhase,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    legendPhase{1}  = ['\omega = ' num2str(wMinPhase,'%5.1f') ' ' FreqUnits ', \phi_{MIN} = ' num2str(MinPhase,'%5.1f') ' deg'];
    
    AddInfoPBode(2) = semilogx(hdl.gui.BodePhaseAxes,wMaxPhase,MaxPhase,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    legendPhase{2}  = ['\omega = ' num2str(wMaxPhase,'%5.1f') ' ' FreqUnits ', \phi_{MAX} = ' num2str(MaxPhase,'%5.1f') ' deg'];
    
    AddInfoNichols(1) = plot(hdl.gui.NicholsAxes,MinPhase,MinGain,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    AddInfoNichols(2) = plot(hdl.gui.NicholsAxes,MaxPhase,MaxGain,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    AddInfoNichols(3) = plot(hdl.gui.NicholsAxes,MPhase,MGain,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
    
    legendNichols{1}  = ['\omega = ' num2str(wMinPhase,'%5.1f') ' ' FreqUnits ', \phi_{MIN} = ' num2str(MinPhase,'%5.1f') ' deg, |F| = ' num2str(MinGain,'%5.1f') ' dB'];
    legendNichols{2}  = ['\omega = ' num2str(wMaxPhase,'%5.1f') ' ' FreqUnits ', \phi_{MAX} = ' num2str(MaxPhase,'%5.1f') ' deg, |F| = ' num2str(MaxGain,'%5.1f') ' dB'];
    legendNichols{3}  = ['\omega = ' num2str(wM,'%5.1f') ' ' FreqUnits ', \phi = ' num2str(MPhase,'%5.1f') ' deg, |F|_{' GainType '} = ' num2str(MGain,'%5.1f') ' dB'];
    
    
elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')  
    if hdl.data.Filter(iFilter).Order == 1
        if hdl.data.Filter(iFilter).Phase >= 0
            phaseType = 'MAX';
            [phaseM,iPhase] = max(phaseDeg);
            legLocG = 'NorthWest';
            legLocP = 'NorthWest';
            legLocN = 'Northwest';
        else
            phaseType = 'MIN';
            [phaseM,iPhase] = min(phaseDeg);
            legLocG = 'SouthWest';
            legLocP = 'Southwest';
            legLocN = 'Southwest';
        end
        
        gainM = magdB(iPhase);
        
        if strcmp(FreqUnits,'Hz');
            wM = wHz(iPhase);
        else
            wM = wRad(iPhase);
        end
        
        AddInfoGBode(1) = semilogx(hdl.gui.BodeGainAxes,wM,gainM,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendGain{1}  =   ['\omega = ' num2str(wM,'%5.1f') ' ' FreqUnits ', \phi_{' phaseType '} = ' num2str(phaseM,'%5.1f') ' deg, |F| = ' num2str(gainM,'%5.1f') ' dB'];
        
        AddInfoPBode(1) = semilogx(hdl.gui.BodePhaseAxes,wM,phaseM,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendPhase{1}  =  ['\omega = ' num2str(wM,'%5.1f') ' ' FreqUnits ', \phi_{' phaseType '} = ' num2str(phaseM,'%5.1f') ' deg, |F| = ' num2str(gainM,'%5.1f') ' dB'];
        
        AddInfoNichols(1) = plot(hdl.gui.NicholsAxes,phaseM,gainM,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendNichols{1}  = ['\omega = ' num2str(wM,'%5.1f') ' ' FreqUnits ', \phi_{' phaseType '} = ' num2str(phaseM,'%5.1f') ' deg, |F| = ' num2str(gainM,'%5.1f') ' dB'];
    elseif hdl.data.Filter(iFilter).Order == 2
        [phaseMax,iPMax] = max(phaseDeg);
        [phaseMin,iPMin] = min(phaseDeg);
        gainMax = magdB(iPMax);
        gainMin = magdB(iPMin);
        
        if strcmp(FreqUnits,'Hz');
            wPMax = wHz(iPMax);
            wPMin = wHz(iPMin);
        else
            wPMax = wRad(iPMax);
            wPMin = wRad(iPMin);
        end
        
        if iPMax < iPMin
            gainType = 'MAX';
            [gainGM,iGM] = max(magdB);
            legLocG = 'NorthWest';
            legLocP = 'Southwest';
            legLocN = 'Southwest';
        else
            gainType = 'MIN';
            [gainGM,iGM] = min(magdB);
            legLocG = 'SouthWest';
            legLocP = 'Northwest';
            legLocN = 'Northwest';
        end
        
        if strcmp(FreqUnits,'Hz');
            wGM = wHz(iGM);
        else
            wGM = wRad(iGM);
        end
        phaseGM = phaseDeg(iGM);
        
        AddInfoGBode(1) = semilogx(hdl.gui.BodeGainAxes,wGM,gainGM,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendGain{1}  = ['\omega = ' num2str(wGM,'%5.1f') ' ' FreqUnits ', |F|_{' gainType '} = ' num2str(gainGM,'%5.1f') ' dB'];
        
        AddInfoPBode(1) = semilogx(hdl.gui.BodePhaseAxes,wPMax,phaseMax,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendPhase{1}  =  ['\omega = ' num2str(wPMax,'%5.1f') ' ' FreqUnits ', \phi_{MAX} = ' num2str(phaseMax,'%5.1f') ' deg'];
        
        AddInfoPBode(2) = semilogx(hdl.gui.BodePhaseAxes,wPMin,phaseMin,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendPhase{2}  =  ['\omega = ' num2str(wPMin,'%5.1f') ' ' FreqUnits ', \phi_{MIN} = ' num2str(phaseMin,'%5.1f') ' deg'];
        
        AddInfoNichols(1) = plot(hdl.gui.NicholsAxes,phaseGM,gainGM,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendNichols{1}  = ['\omega = ' num2str(wGM,'%5.1f') ' ' FreqUnits ', \phi = ' num2str(phaseGM,'%5.1f') ' deg, |F|_{' gainType '} = ' num2str(gainGM,'%5.1f') ' dB'];
        
        AddInfoNichols(2) = plot(hdl.gui.NicholsAxes,phaseMax,gainMax,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendNichols{2}  = ['\omega = ' num2str(wPMax,'%5.1f') ' ' FreqUnits ', \phi_{MAX} = ' num2str(phaseMax,'%5.1f') ' deg, |F| = ' num2str(gainMax,'%5.1f') ' dB'];
        
        AddInfoNichols(3) = plot(hdl.gui.NicholsAxes,phaseMin,gainMin,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',4);
        legendNichols{3}  = ['\omega = ' num2str(wPMin,'%5.1f') ' ' FreqUnits ', \phi_{MIN} = ' num2str(phaseMin,'%5.1f') ' deg, |F| = ' num2str(gainMin,'%5.1f') ' dB'];
        
    end
end

if ~isempty(AddInfoGBode)
    axes(hdl.gui.BodeGainAxes);
    legend(AddInfoGBode,legendGain,'Location',legLocG,'Fontsize',8);
    axes(hdl.gui.BodePhaseAxes);
    legend(AddInfoPBode,legendPhase,'Location',legLocP,'FontSize',8);
    axes(hdl.gui.NicholsAxes);
    legend(AddInfoNichols,legendNichols,'Location',legLocN,'FontSize',8);
end
