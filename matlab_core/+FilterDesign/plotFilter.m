function [hdl] = plotFilter(hdl)
import FilterDesign.*


PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    
    selFilter    = get(hdl.gui.panelFiltersListBox,'value');
    nFilter      = length(selFilter);
    H_Final      = tf(1,1);
    
    Valids       = false(1,nFilter);
    
    GainLim = get(hdl.gui.panelFiltersEtGainLim,'string');
    PhaseLim= get(hdl.gui.panelFiltersEtPhaseLim,'string');
    
    MaxFreqLim = get(hdl.gui.panelFiltersEtFreqMax,'string');
    
    % Get Additional Data Points
    AddFreqPts = str2num(get(hdl.gui.panelPlotOptionsEtAddDispFreq,'string'));
    
    % Get Frequency Points
    wSt = get(hdl.gui.panelFiltersEtFreqPts,'String');
    
    if ~isempty(wSt)
        wIn = eval(wSt);
    else
        errordlg('Please specify frequency points.');
        return;
    end
    
    
    FigureTitle = [];
    Hstf      = [];
    
    [hdl] = clearPlotAxes(hdl);
    
    FreqUnits = hdl.data.FreqUnits;
    for i = 1:nFilter
        
        iFilter = selFilter(i);
        Valid   = false;
        
        if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
            CenterFreq = hdl.data.Filter(iFilter).CenterFreq;
            CenterAttn = hdl.data.Filter(iFilter).CenterAttn;
            Freq2 = hdl.data.Filter(iFilter).Freq2;
            Attn2 = hdl.data.Filter(iFilter).Attn2;
            DCGain = hdl.data.Filter(iFilter).DCGain;
            HFGain = hdl.data.Filter(iFilter).HFGain;
            
            if ~isempty(CenterFreq*CenterAttn*Freq2*Attn2*DCGain*HFGain)
                
                [Valid,H_Notch] = getNotchFilter(CenterFreq,CenterAttn,Freq2,Attn2,DCGain,HFGain,FreqUnits);
                H_Filter = H_Notch;
            end
        elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
            if hdl.data.Filter(iFilter).Order == 1
                Freq  = hdl.data.Filter(iFilter).Freq;
                Phase = hdl.data.Filter(iFilter).Phase;
                Gain  = hdl.data.Filter(iFilter).Gain;
                iMaxPhase = hdl.data.Filter(iFilter).iMaxPhase;
                if iMaxPhase == 1
                    if ~isempty(Freq*Phase)
                        [Valid,H_LL1] = getLLFilter1stOrder1(Freq,Phase,FreqUnits);
                        H_Filter = H_LL1;
                    end
                elseif iMaxPhase == 0
                    if ~isempty(Freq*Phase*Gain)
                        [Valid,H_LL1] = getLLFilter1stOrder2(Freq,Phase,Gain,FreqUnits);
                        H_Filter = H_LL1;
                    end
                end
            elseif hdl.data.Filter(iFilter).Order == 2
                FreqPMax  = hdl.data.Filter(iFilter).FreqPMax;
                PhaseMax = hdl.data.Filter(iFilter).PhaseMax;
                HFGain  = hdl.data.Filter(iFilter).HFGain;
                
                FreqGMax = hdl.data.Filter(iFilter).FreqGMax;
                
                option = hdl.data.Filter(iFilter).LLSecondOrderOption;
                
                if strcmp(option,'Specify Freq @ Max Gain')
                    if ~isempty(FreqPMax*PhaseMax*HFGain*FreqGMax)
                        [Valid,H_LL2] = getLLFilter2ndOrder2(FreqPMax,PhaseMax,HFGain,FreqGMax,FreqUnits);
                        H_Filter = H_LL2;
                    end
                else
                    if ~isempty(FreqPMax*PhaseMax*HFGain)
                        [Valid,H_LL2] = getLLFilter2ndOrder1(FreqPMax,PhaseMax,HFGain,FreqUnits);
                        H_Filter = H_LL2;
                    end
                end
            end
        end
        
        if Valid
            Valids(i) = true;
            H_Final   = H_Final * H_Filter;
            [Hst] = getTfString(H_Filter);
            if isempty(FigureTitle);
                FigureTitle = [hdl.data.Filter(iFilter).Name];
                Hstf = [Hstf,Hst];
            else
                FigureTitle = [FigureTitle,'*',hdl.data.Filter(iFilter).Name];
                Hstf = [Hstf,'\cdot',Hst];
            end
            
            % store filter num den
            hdl.data.Filter(iFilter).num = H_Filter.num{1};
            hdl.data.Filter(iFilter).den = H_Filter.den{1};
        end
    end
    
    
    Hstf = ['$$' Hstf '$$'];
    
    
    if ~isempty(find(Valids,1))
        
        if strcmp(FreqUnits,'Hz')
            wHz  = unique([wIn,AddFreqPts]);
            wRad = wHz*2*pi;
        else
            wRad    = unique([wIn,AddFreqPts]);
            wHz     = wRad/2/pi;
        end
        
        [HFR] = freqresp(H_Final,wRad);
        HFRs  = squeeze(HFR);
        magdB = 20*log10(abs(HFRs));
        phaseDeg = angle(HFRs)*(180/pi);
        
        hold(hdl.gui.BodeGainAxes,'off');
        
        %% Bode Plot
        if strcmp(FreqUnits,'Hz')
            semilogx(hdl.gui.BodeGainAxes,wHz,magdB);
        else
            semilogx(hdl.gui.BodeGainAxes,wRad,magdB);
        end
        
        hold(hdl.gui.BodeGainAxes,'on');
        grid(hdl.gui.BodeGainAxes,'on');
        xlabel(hdl.gui.BodeGainAxes,['Frequency (' FreqUnits ')']);
        ylabel(hdl.gui.BodeGainAxes,'Gain (dB)');
        
        %[Hst] = getTfString(H_Final);
        
        %title([FigureTitle ' = ' Hstf],'interpreter','latex','FontSize',9,'FontWeight','bold');
        
        %title(['Bode: ' FigureTitle]);
        
        hold(hdl.gui.BodePhaseAxes,'off');
        
        if strcmp(FreqUnits,'Hz')
            semilogx(hdl.gui.BodePhaseAxes,wHz,phaseDeg);
        else
            semilogx(hdl.gui.BodePhaseAxes,wRad,phaseDeg);
        end
        
        hold(hdl.gui.BodePhaseAxes,'on');
        grid(hdl.gui.BodePhaseAxes,'on');
        xlabel(hdl.gui.BodePhaseAxes,['Frequency (' FreqUnits ')']);
        ylabel(hdl.gui.BodePhaseAxes,'Phase (deg)');
        
        
        %% Axes Limits
        if ~strcmp(GainLim,'auto')
            ylim(hdl.gui.BodeGainAxes,str2num(GainLim));
        end
        if ~strcmp(PhaseLim,'auto')
            ylim(hdl.gui.BodePhaseAxes,str2num(PhaseLim));
        end
        
        %% Nichols Plot
        hold(hdl.gui.NicholsAxes,'off');
        plot(hdl.gui.NicholsAxes,phaseDeg,magdB);
        
        hold(hdl.gui.NicholsAxes,'on');
        grid(hdl.gui.NicholsAxes,'on');
        xlabel(hdl.gui.NicholsAxes,'Phase (deg)');
        ylabel(hdl.gui.NicholsAxes,'Magnutude (dB)');
        
        if ~strcmp(GainLim,'auto')
            ylim(hdl.gui.NicholsAxes,str2num(GainLim));
        end
        if ~strcmp(PhaseLim,'auto')
            xlim(hdl.gui.NicholsAxes,str2num(PhaseLim));
        end
        
        %% Pz Map
        [P,Z] = pzmap(H_Final);
        
        hold(hdl.gui.PZMapAxes,'off');
        %hold(hdl.gui.PZMapAxes,'on');
        plot(hdl.gui.PZMapAxes,real(P),imag(P),'sq','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',5);
        hold(hdl.gui.PZMapAxes,'on');
        plot(hdl.gui.PZMapAxes,real(Z),imag(Z),'o','MarkerFaceColor','b','MarkerSize',5);
        xlabel(hdl.gui.PZMapAxes,'Real Part');
        ylabel(hdl.gui.PZMapAxes,'Imaginary Part');
        %axis(hdl.gui.PZMapAxes,'equal');
        if strcmp(MaxFreqLim,'auto')
            maxFreq = max(abs([P;Z]));
            xlim(hdl.gui.PZMapAxes,[-maxFreq-5,0]);
            ylim(hdl.gui.PZMapAxes,[0,maxFreq+5]);
        else
            maxFreq = str2num(MaxFreqLim);
            xlim(hdl.gui.PZMapAxes,[-maxFreq,0]);
            ylim(hdl.gui.PZMapAxes,[0,maxFreq]);
        end
        
        axes(hdl.gui.PZMapAxes);
        sgrid([0:0.1:1],[0:round(maxFreq/10):maxFreq*2]);
        %axis(hdl.gui.PZMapAxes,'square');
        %axis(hdl.gui.PZMapAxes,'equal');
        
        %% Plot additional points
        selFilter = get(hdl.gui.panelFiltersListBox,'value');
        if length(selFilter) > 1 || (length(selFilter) == 1 && hdl.data.FilterInfo == 0)
            [hdl] = addFreqPtsPlot(hdl,AddFreqPts,wHz,wRad,FreqUnits,magdB,phaseDeg);
        end
        
        
        %% Get Individual Plot Info
        if length(selFilter) == 1
            if hdl.data.FilterInfo == 1
                [hdl] = plotInfo(hdl,wRad,FreqUnits,magdB,phaseDeg,H_Final);
            end
        end
    end
end
