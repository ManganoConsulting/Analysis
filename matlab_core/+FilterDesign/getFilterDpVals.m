function [hdl] = getFilterDpVals(hdl)
import FilterDesign.*
iFilter    = get(hdl.gui.panelFiltersPMList,'value');

PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
        %% NOTCH FILTER UPDATE
        CenterFreqSt = get(hdl.gui.panelDesignParamNotchEtDpCenterFreq,'string');
        
        if ~isnan(str2double(CenterFreqSt))
            CenterFreq = str2double(CenterFreqSt);
            
            if CenterFreq <= hdl.data.NFSettings.CenterFreq_Max && CenterFreq >= hdl.data.NFSettings.CenterFreq_Min
                hdl.data.Filter(iFilter).CenterFreq = CenterFreq;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).CenterFreq = [];
            end
        else
            if ~isempty(CenterFreqSt)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).CenterFreq = [];
            end
        end
        
        CenterFreq     = hdl.data.Filter(iFilter).CenterFreq;
        CenterFreq_Max = hdl.data.Filter(iFilter).CenterFreq_Max;
        CenterFreq_Min = hdl.data.Filter(iFilter).CenterFreq_Min;
        CenterFreq_AMax= hdl.data.NFSettings.CenterFreq_Max;
        CenterFreq_AMin= hdl.data.NFSettings.CenterFreq_Min;
        if ~isempty(CenterFreq)
            if isempty(CenterFreq_Max) || CenterFreq > CenterFreq_Max
                CenterFreq_Max = min([CenterFreq+5,CenterFreq_AMax]);
                
                hdl.data.Filter(iFilter).CenterFreq_Max = CenterFreq_Max;
            end
            if isempty(CenterFreq_Min) || CenterFreq < CenterFreq_Min
                CenterFreq_Min = max([CenterFreq-5,CenterFreq_AMin]);
                
                hdl.data.Filter(iFilter).CenterFreq_Min = CenterFreq_Min;
            end
        else
            hdl.data.Filter(iFilter).CenterFreq_Min = [];
            hdl.data.Filter(iFilter).CenterFreq_Max = [];
        end
        
        
        CenterAttnSt = get(hdl.gui.panelDesignParamNotchEtDpCenterAttn,'string');
        
        if ~isnan(str2double(CenterAttnSt))
            CenterAttn = str2double(CenterAttnSt);
            
            if CenterAttn <= hdl.data.NFSettings.CenterAttn_Max && CenterAttn >= hdl.data.NFSettings.CenterAttn_Min
                hdl.data.Filter(iFilter).CenterAttn = CenterAttn;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).CenterAttn = [];
            end
        else
            if ~isempty(CenterAttnSt)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).CenterAttn = [];
            end
        end
        
        CenterAttn     = hdl.data.Filter(iFilter).CenterAttn;
        CenterAttn_Max = hdl.data.Filter(iFilter).CenterAttn_Max;
        CenterAttn_Min = hdl.data.Filter(iFilter).CenterAttn_Min;
        CenterAttn_AMax= hdl.data.NFSettings.CenterAttn_Max;
        CenterAttn_AMin= hdl.data.NFSettings.CenterAttn_Min;
        if ~isempty(CenterAttn)
            if isempty(CenterAttn_Max) || CenterAttn > CenterAttn_Max
                CenterAttn_Max = min([CenterAttn+5,CenterAttn_AMax]);
                
                hdl.data.Filter(iFilter).CenterAttn_Max = CenterAttn_Max;
            end
            if isempty(CenterAttn_Min) || CenterAttn < CenterAttn_Min
                CenterAttn_Min = max([CenterAttn-5,CenterAttn_AMin]);
                
                hdl.data.Filter(iFilter).CenterAttn_Min = CenterAttn_Min;
            end
        else
            hdl.data.Filter(iFilter).CenterAttn_Min = [];
            hdl.data.Filter(iFilter).CenterAttn_Max = [];
        end
        
        
        Freq2St = get(hdl.gui.panelDesignParamNotchEtDpFreq2,'string');
        
        if ~isnan(str2double(Freq2St))
            Freq2 = str2double(Freq2St);
            
            if Freq2 <= hdl.data.NFSettings.Freq2_Max && Freq2 >= hdl.data.NFSettings.Freq2_Min
                hdl.data.Filter(iFilter).Freq2 = Freq2;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).Freq2 = [];
            end
        else
            if ~isempty(Freq2St)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).Freq2 = [];
            end
        end
        
        Freq2     = hdl.data.Filter(iFilter).Freq2;
        Freq2_Max = hdl.data.Filter(iFilter).Freq2_Max;
        Freq2_Min = hdl.data.Filter(iFilter).Freq2_Min;
        Freq2_AMax= hdl.data.NFSettings.Freq2_Max;
        Freq2_AMin= hdl.data.NFSettings.Freq2_Min;
        if ~isempty(Freq2)
            if isempty(Freq2_Max) || Freq2 > Freq2_Max
                Freq2_Max = min([Freq2+5,Freq2_AMax]);
                
                hdl.data.Filter(iFilter).Freq2_Max = Freq2_Max;
            end
            if isempty(Freq2_Min) || Freq2 < Freq2_Min
                Freq2_Min = max([Freq2-5,Freq2_AMin]);
                
                hdl.data.Filter(iFilter).Freq2_Min = Freq2_Min;
            end
        else
            hdl.data.Filter(iFilter).Freq2_Min = [];
            hdl.data.Filter(iFilter).Freq2_Max = [];
        end
        
        
        Attn2St = get(hdl.gui.panelDesignParamNotchEtDpAttn2,'string');
        
        if ~isnan(str2double(Attn2St))
            Attn2 = str2double(Attn2St);
            
            if Attn2 <= hdl.data.NFSettings.Attn2_Max && Attn2 >= hdl.data.NFSettings.Attn2_Min
                hdl.data.Filter(iFilter).Attn2 = Attn2;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).Attn2 = [];
            end
        else
            if ~isempty(Attn2St)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).Attn2 = [];
            end
        end
        
        Attn2     = hdl.data.Filter(iFilter).Attn2;
        Attn2_Max = hdl.data.Filter(iFilter).Attn2_Max;
        Attn2_Min = hdl.data.Filter(iFilter).Attn2_Min;
        Attn2_AMax= hdl.data.NFSettings.Attn2_Max;
        Attn2_AMin= hdl.data.NFSettings.Attn2_Min;
        if ~isempty(Attn2)
            if isempty(Attn2_Max) || Attn2 > Attn2_Max
                Attn2_Max = min([Attn2+5,Attn2_AMax]);
                
                hdl.data.Filter(iFilter).Attn2_Max = Attn2_Max;
            end
            if isempty(Attn2_Min) || Attn2 < Attn2_Min
                Attn2_Min = max([Attn2-5,Attn2_AMin]);
                
                hdl.data.Filter(iFilter).Attn2_Min = Attn2_Min;
            end
        else
            hdl.data.Filter(iFilter).Attn2_Min = [];
            hdl.data.Filter(iFilter).Attn2_Max = [];
        end
        
        DCGainSt = get(hdl.gui.panelDesignParamNotchEtDpDCGain,'string');
        
        if ~isnan(str2double(DCGainSt))
            DCGain = str2double(DCGainSt);
            
            if DCGain <= hdl.data.NFSettings.DCGain_Max && DCGain >= hdl.data.NFSettings.DCGain_Min
                hdl.data.Filter(iFilter).DCGain = DCGain;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).DCGain = [];
            end
        else
            if ~isempty(DCGainSt)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).DCGain = [];
            end
        end
        
        DCGain     = hdl.data.Filter(iFilter).DCGain;
        DCGain_Max = hdl.data.Filter(iFilter).DCGain_Max;
        DCGain_Min = hdl.data.Filter(iFilter).DCGain_Min;
        DCGain_AMax= hdl.data.NFSettings.DCGain_Max;
        DCGain_AMin= hdl.data.NFSettings.DCGain_Min;
        if ~isempty(DCGain)
            if isempty(DCGain_Max) || DCGain > DCGain_Max
                DCGain_Max = min([DCGain+5,DCGain_AMax]);
                
                hdl.data.Filter(iFilter).DCGain_Max = DCGain_Max;
            end
            if isempty(DCGain_Min) || DCGain < DCGain_Min
                DCGain_Min = max([DCGain-5,DCGain_AMin]);
                
                hdl.data.Filter(iFilter).DCGain_Min = DCGain_Min;
            end
        else
            hdl.data.Filter(iFilter).DCGain_Min = [];
            hdl.data.Filter(iFilter).DCGain_Max = [];
        end
        
        HFGainSt = get(hdl.gui.panelDesignParamNotchEtDpHFGain,'string');
        
        if ~isnan(str2double(HFGainSt))
            HFGain = str2double(HFGainSt);
            
            if HFGain <= hdl.data.NFSettings.HFGain_Max && HFGain >= hdl.data.NFSettings.HFGain_Min
                hdl.data.Filter(iFilter).HFGain = HFGain;
            else
                errordlg('Entered value is outside valid range.');return;
                hdl.data.Filter(iFilter).HFGain = [];
            end
        else
            if ~isempty(HFGainSt)
                errordlg('Entered value is not a scalar number.');
                return;
            else
                hdl.data.Filter(iFilter).HFGain = [];
            end
        end
        
        HFGain     = hdl.data.Filter(iFilter).HFGain;
        HFGain_Max = hdl.data.Filter(iFilter).HFGain_Max;
        HFGain_Min = hdl.data.Filter(iFilter).HFGain_Min;
        HFGain_AMax= hdl.data.NFSettings.HFGain_Max;
        HFGain_AMin= hdl.data.NFSettings.HFGain_Min;
        if ~isempty(HFGain)
            if isempty(HFGain_Max) || HFGain > HFGain_Max
                HFGain_Max = min([HFGain+5,HFGain_AMax]);
                
                hdl.data.Filter(iFilter).HFGain_Max = HFGain_Max;
            end
            if isempty(HFGain_Min) || HFGain < HFGain_Min
                HFGain_Min = max([HFGain-5,HFGain_AMin]);
                
                hdl.data.Filter(iFilter).HFGain_Min = HFGain_Min;
            end
        else
            hdl.data.Filter(iFilter).HFGain_Min = [];
            hdl.data.Filter(iFilter).HFGain_Max = [];
        end
    elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
        
        if hdl.data.Filter(iFilter).Order == 1
            %% LEAD/LAG FIRST ORDER UPDATE
            FreqSt = get(hdl.gui.panelDesignParamLLFirstOrderEtDpFreq,'string');
            
            if ~isnan(str2double(FreqSt))
                Freq = str2double(FreqSt);
                
                if Freq <= hdl.data.LL1Settings.Freq_Max && Freq >= hdl.data.LL1Settings.Freq_Min
                    hdl.data.Filter(iFilter).Freq = Freq;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).Freq = [];
                end
            else
                if ~isempty(FreqSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).Freq = [];
                end
            end
            
            Freq     = hdl.data.Filter(iFilter).Freq;
            Freq_Max = hdl.data.Filter(iFilter).Freq_Max;
            Freq_Min = hdl.data.Filter(iFilter).Freq_Min;
            Freq_AMax= hdl.data.LL1Settings.Freq_Max;
            Freq_AMin= hdl.data.LL1Settings.Freq_Min;
            if ~isempty(Freq)
                if isempty(Freq_Max) || Freq > Freq_Max
                    Freq_Max = min([Freq+5,Freq_AMax]);
                    
                    hdl.data.Filter(iFilter).Freq_Max = Freq_Max;
                end
                if isempty(Freq_Min) || Freq < Freq_Min
                    Freq_Min = max([Freq-5,Freq_AMin]);
                    
                    hdl.data.Filter(iFilter).Freq_Min = Freq_Min;
                end
            else
                hdl.data.Filter(iFilter).Freq_Min = [];
                hdl.data.Filter(iFilter).Freq_Max = [];
            end
            
            
            PhaseSt = get(hdl.gui.panelDesignParamLLFirstOrderEtDpPhase,'string');
            
            if ~isnan(str2double(PhaseSt))
                Phase = str2double(PhaseSt);
                
                if Phase <= hdl.data.LL1Settings.Phase_Max && Phase >= hdl.data.LL1Settings.Phase_Min
                    hdl.data.Filter(iFilter).Phase = Phase;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).Phase = [];
                end
            else
                if ~isempty(PhaseSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).Phase = [];
                end
            end
            
            Phase     = hdl.data.Filter(iFilter).Phase;
            Phase_Max = hdl.data.Filter(iFilter).Phase_Max;
            Phase_Min = hdl.data.Filter(iFilter).Phase_Min;
            Phase_AMax= hdl.data.LL1Settings.Phase_Max;
            Phase_AMin= hdl.data.LL1Settings.Phase_Min;
            if ~isempty(Phase)
                if isempty(Phase_Max) || Phase > Phase_Max
                    Phase_Max = min([Phase+5,Phase_AMax]);
                    
                    hdl.data.Filter(iFilter).Phase_Max = Phase_Max;
                end
                if isempty(Phase_Min) || Phase < Phase_Min
                    Phase_Min = max([Phase-5,Phase_AMin]);
                    
                    hdl.data.Filter(iFilter).Phase_Min = Phase_Min;
                end
            else
                hdl.data.Filter(iFilter).Phase_Min = [];
                hdl.data.Filter(iFilter).Phase_Max = [];
            end
            
            
            GainSt = get(hdl.gui.panelDesignParamLLFirstOrderEtDpGain,'string');
            
            if ~isnan(str2double(GainSt))
                Gain = str2double(GainSt);
                
                if Gain <= hdl.data.LL1Settings.Gain_Max && Gain >= hdl.data.LL1Settings.Gain_Min
                    hdl.data.Filter(iFilter).Gain = Gain;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).Gain = [];
                end
            else
                if ~isempty(GainSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).Gain = [];
                end
            end
            
            Gain     = hdl.data.Filter(iFilter).Gain;
            Gain_Max = hdl.data.Filter(iFilter).Gain_Max;
            Gain_Min = hdl.data.Filter(iFilter).Gain_Min;
            Gain_AMax= hdl.data.LL1Settings.Gain_Max;
            Gain_AMin= hdl.data.LL1Settings.Gain_Min;
            if ~isempty(Gain)
                if isempty(Gain_Max) || Gain > Gain_Max
                    Gain_Max = min([Gain+5,Gain_AMax]);
                    
                    hdl.data.Filter(iFilter).Gain_Max = Gain_Max;
                end
                if isempty(Gain_Min) || Gain < Gain_Min
                    Gain_Min = max([Gain-5,Gain_AMin]);
                    
                    hdl.data.Filter(iFilter).Gain_Min = Gain_Min;
                end
            else
                hdl.data.Filter(iFilter).Gain_Min = [];
                hdl.data.Filter(iFilter).Gain_Max = [];
            end
        elseif hdl.data.Filter(iFilter).Order == 2
            %% LEAD LAG SECOND ORDER UPDATE
            FreqPMaxSt = get(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqPMax,'string');
            
            if ~isnan(str2double(FreqPMaxSt))
                FreqPMax = str2double(FreqPMaxSt);
                
                if FreqPMax <= hdl.data.LL2Settings.FreqPMax_Max && FreqPMax >= hdl.data.LL2Settings.FreqPMax_Min
                    hdl.data.Filter(iFilter).FreqPMax = FreqPMax;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).FreqPMax = [];
                end
            else
                if ~isempty(FreqPMaxSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).FreqPMax = [];
                end
            end
            
            FreqPMax     = hdl.data.Filter(iFilter).FreqPMax;
            FreqPMax_Max = hdl.data.Filter(iFilter).FreqPMax_Max;
            FreqPMax_Min = hdl.data.Filter(iFilter).FreqPMax_Min;
            FreqPMax_AMax= hdl.data.LL2Settings.FreqPMax_Max;
            FreqPMax_AMin= hdl.data.LL2Settings.FreqPMax_Min;
            if ~isempty(FreqPMax)
                if isempty(FreqPMax_Max) || FreqPMax > FreqPMax_Max
                    FreqPMax_Max = min([FreqPMax+5,FreqPMax_AMax]);
                    
                    hdl.data.Filter(iFilter).FreqPMax_Max = FreqPMax_Max;
                end
                if isempty(FreqPMax_Min) || FreqPMax < FreqPMax_Min
                    FreqPMax_Min = max([FreqPMax-5,FreqPMax_AMin]);
                    
                    hdl.data.Filter(iFilter).FreqPMax_Min = FreqPMax_Min;
                end
            else
                hdl.data.Filter(iFilter).FreqPMax_Min = [];
                hdl.data.Filter(iFilter).FreqPMax_Max = [];
            end
            
            
            PhaseMaxSt = get(hdl.gui.panelDesignParamLLSecondOrderEtDpPhaseMax,'string');
            
            if ~isnan(str2double(PhaseMaxSt))
                PhaseMax = str2double(PhaseMaxSt);
                
                if PhaseMax <= hdl.data.LL2Settings.PhaseMax_Max && PhaseMax >= hdl.data.LL2Settings.PhaseMax_Min
                    hdl.data.Filter(iFilter).PhaseMax = PhaseMax;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).PhaseMax = [];
                end
            else
                if ~isempty(PhaseMaxSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).PhaseMax = [];
                end
            end
            
            PhaseMax     = hdl.data.Filter(iFilter).PhaseMax;
            PhaseMax_Max = hdl.data.Filter(iFilter).PhaseMax_Max;
            PhaseMax_Min = hdl.data.Filter(iFilter).PhaseMax_Min;
            PhaseMax_AMax= hdl.data.LL2Settings.PhaseMax_Max;
            PhaseMax_AMin= hdl.data.LL2Settings.PhaseMax_Min;
            if ~isempty(PhaseMax)
                if isempty(PhaseMax_Max) || PhaseMax > PhaseMax_Max
                    PhaseMax_Max = min([PhaseMax+5,PhaseMax_AMax]);
                    
                    hdl.data.Filter(iFilter).PhaseMax_Max = PhaseMax_Max;
                end
                if isempty(PhaseMax_Min) || PhaseMax < PhaseMax_Min
                    PhaseMax_Min = max([PhaseMax-5,PhaseMax_AMin]);
                    
                    hdl.data.Filter(iFilter).PhaseMax_Min = PhaseMax_Min;
                end
            else
                hdl.data.Filter(iFilter).PhaseMax_Min = [];
                hdl.data.Filter(iFilter).PhaseMax_Max = [];
            end
            
            
            HFGainSt = get(hdl.gui.panelDesignParamLLSecondOrderEtDpHFGain,'string');
            
            if ~isnan(str2double(HFGainSt))
                HFGain = str2double(HFGainSt);
                
                if HFGain <= hdl.data.LL2Settings.HFGain_Max && HFGain >= hdl.data.LL2Settings.HFGain_Min
                    hdl.data.Filter(iFilter).HFGain = HFGain;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).HFGain = [];
                end
            else
                if ~isempty(HFGainSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).HFGain = [];
                end
            end
            
            HFGain     = hdl.data.Filter(iFilter).HFGain;
            HFGain_Max = hdl.data.Filter(iFilter).HFGain_Max;
            HFGain_Min = hdl.data.Filter(iFilter).HFGain_Min;
            HFGain_AMax= hdl.data.LL2Settings.HFGain_Max;
            HFGain_AMin= hdl.data.LL2Settings.HFGain_Min;
            if ~isempty(HFGain)
                if isempty(HFGain_Max) || HFGain > HFGain_Max
                    HFGain_Max = min([HFGain+5,HFGain_AMax]);
                    
                    hdl.data.Filter(iFilter).HFGain_Max = HFGain_Max;
                end
                if isempty(HFGain_Min) || HFGain < HFGain_Min
                    HFGain_Min = max([HFGain-5,HFGain_AMin]);
                    
                    hdl.data.Filter(iFilter).HFGain_Min = HFGain_Min;
                end
            else
                hdl.data.Filter(iFilter).HFGain_Min = [];
                hdl.data.Filter(iFilter).HFGain_Max = [];
            end
            
            FreqGMaxSt = get(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqGMax,'string');
            
            if ~isnan(str2double(FreqGMaxSt))
                FreqGMax = str2double(FreqGMaxSt);
                
                if FreqGMax <= hdl.data.LL2Settings.FreqGMax_Max && FreqGMax >= hdl.data.LL2Settings.FreqGMax_Min
                    hdl.data.Filter(iFilter).FreqGMax = FreqGMax;
                else
                    errordlg('Entered value is outside valid range.');return;
                    hdl.data.Filter(iFilter).FreqGMax = [];
                end
            else
                if ~isempty(FreqGMaxSt)
                    errordlg('Entered value is not a scalar number.');
                    return;
                else
                    hdl.data.Filter(iFilter).FreqGMax = [];
                end
            end
            
            FreqGMax     = hdl.data.Filter(iFilter).FreqGMax;
            FreqGMax_Max = hdl.data.Filter(iFilter).FreqGMax_Max;
            FreqGMax_Min = hdl.data.Filter(iFilter).FreqGMax_Min;
            FreqGMax_AMax= hdl.data.LL2Settings.FreqGMax_Max;
            FreqGMax_AMin= hdl.data.LL2Settings.FreqGMax_Min;
            if ~isempty(FreqGMax)
                if isempty(FreqGMax_Max) || FreqGMax > FreqGMax_Max
                    FreqGMax_Max = min([FreqGMax+5,FreqGMax_AMax]);
                    
                    hdl.data.Filter(iFilter).FreqGMax_Max = FreqGMax_Max;
                end
                if isempty(FreqGMax_Min) || FreqGMax < FreqGMax_Min
                    FreqGMax_Min = max([FreqGMax-5,FreqGMax_AMin]);
                    
                    hdl.data.Filter(iFilter).FreqGMax_Min = FreqGMax_Min;
                end
            else
                hdl.data.Filter(iFilter).FreqGMax_Min = [];
                hdl.data.Filter(iFilter).FreqGMax_Max = [];
            end
        end
    end
end