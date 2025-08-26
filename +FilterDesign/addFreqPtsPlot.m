function [hdl] = addFreqPtsPlot(hdl,AddFreqPts,wHz,wRad,FreqUnits,magdB,phaseDeg)
import FilterDesign.*
    % array of markers and colors
    markers = {'o','p','^','d','s','<','>','v','h'};
    colors = {'k','r','g','b','y','c','m'};

    AddFreqPlotGain = [];
    AddFreqPlotPhase= [];
    AddFreqPlotNichols = [];
    
    k = 0;
    
    for i = 1:length(AddFreqPts)
        Freqi = AddFreqPts(i);
        
        if strcmp(FreqUnits,'Hz')
            iFreq = find(wHz == Freqi);
        else
            iFreq = find(wRad == Freqi);
        end
                
        magdBi= magdB(iFreq);
        phaseDegi = phaseDeg(iFreq);
        
        
        k = k+1;
        
        % get current marker and colors
        currMarker = markers{1+rem(i-1,length(markers))};
        currColor  = colors{1+rem(i-1,length(colors))};
        
        AddFreqPlotGain(k) = semilogx(hdl.gui.BodeGainAxes,Freqi,magdBi,currMarker,'MarkerSize',5,'MarkerFaceColor',currColor,'MarkerEdgeColor','k');
        AddFreqPlotPhase(k) = semilogx(hdl.gui.BodePhaseAxes,Freqi,phaseDegi,currMarker,'MarkerSize',5,'MarkerFaceColor',currColor,'MarkerEdgeColor','k');
        
        legendGain{k}  = ['\omega = ' num2str(Freqi,'%5.1f') ' ' FreqUnits ', |F| = ' num2str(magdBi,'%5.1f') ' dB'];
        legendPhase{k} = ['\omega = ' num2str(Freqi,'%5.1f') ' ' FreqUnits ', \phi = ' num2str(phaseDegi,'%5.1f') ' deg'];
        
        AddFreqPlotNichols(k) = plot(hdl.gui.NicholsAxes,phaseDegi,magdBi,currMarker,'MarkerSize',8,'MarkerFaceColor',currColor,'MarkerEdgeColor','k');
        
        legendNichols{k} = ['\omega = ' num2str(Freqi,'%5.1f') ' ' FreqUnits];
    end
    
if ~isempty(AddFreqPlotGain)
    axes(hdl.gui.BodeGainAxes);
    legend(AddFreqPlotGain,legendGain,'Location','SouthWest','Fontsize',8);
    axes(hdl.gui.BodePhaseAxes);
    legend(AddFreqPlotPhase,legendPhase,'Location','NorthWest','FontSize',8);
end

if ~isempty(AddFreqPlotNichols)
    axes(hdl.gui.NicholsAxes);
    legend(AddFreqPlotNichols,legendNichols,'Location','SouthWest','Fontsize',8);
end
