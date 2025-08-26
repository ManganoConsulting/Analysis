function [hdl] = initFilter(hdl)
import FilterDesign.*
PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    iFilter = get(hdl.gui.panelFiltersPMList,'value');
    
    if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
        
        hdl.data.Filter(iFilter).CenterFreq = str2num(get(hdl.gui.panelDesignParamNotchEtDpCenterFreq,'string'));
        hdl.data.Filter(iFilter).CenterAttn = str2num(get(hdl.gui.panelDesignParamNotchEtDpCenterAttn,'string'));
        hdl.data.Filter(iFilter).Freq2      = str2num(get(hdl.gui.panelDesignParamNotchEtDpFreq2,'string'));
        hdl.data.Filter(iFilter).Attn2      = str2num(get(hdl.gui.panelDesignParamNotchEtDpAttn2,'string'));
        hdl.data.Filter(iFilter).DCGain     = str2num(get(hdl.gui.panelDesignParamNotchEtDpDCGain,'string'));
        hdl.data.Filter(iFilter).HFGain     = str2num(get(hdl.gui.panelDesignParamNotchEtDpHFGain,'string'));
        
        
        hdl.data.Filter(iFilter).CenterFreq_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpCenterFreq,'string'));
        hdl.data.Filter(iFilter).CenterFreq_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpCenterFreq,'string'));
        
        hdl.data.Filter(iFilter).CenterAttn_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpCenterAttn,'string'));
        hdl.data.Filter(iFilter).CenterAttn_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpCenterAttn,'string'));;
        
        hdl.data.Filter(iFilter).Freq2_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpFreq2,'string'));
        hdl.data.Filter(iFilter).Freq2_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpFreq2,'string'));
        
        hdl.data.Filter(iFilter).Attn2_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpAttn2,'string'));
        hdl.data.Filter(iFilter).Attn2_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpAttn2,'string'));
        
        hdl.data.Filter(iFilter).DCGain_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpDCGain,'string'));
        hdl.data.Filter(iFilter).DCGain_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpDCGain,'string'));
        
        hdl.data.Filter(iFilter).HFGain_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpHFGain,'string'));
        hdl.data.Filter(iFilter).HFGain_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpHFGain,'string'));
        
    elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
        if hdl.data.Filter(iFilter).Order == 1
            hdl.data.Filter(iFilter).Freq = str2num(get(hdl.gui.panelDesignParamLLFirstOrderEtDpFreq,'string'));
            hdl.data.Filter(iFilter).Phase= str2num(get(hdl.gui.panelDesignParamLLFirstOrderEtDpPhase,'string'));
            hdl.data.Filter(iFilter).Gain = str2num(get(hdl.gui.panelDesignParamLLFirstOrderEtDpGain,'string'));
            
            hdl.data.Filter(iFilter).Freq_Min = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMinDpFreq,'string'));
            hdl.data.Filter(iFilter).Freq_Max = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpFreq,'string'));
            
            hdl.data.Filter(iFilter).Phase_Min = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMinDpPhase,'string'));
            hdl.data.Filter(iFilter).Phase_Max = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpPhase,'string'));
            
            hdl.data.Filter(iFilter).Gain_Min = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMinDpGain,'string'));
            hdl.data.Filter(iFilter).Gain_Max = str2num(get(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpGain,'string'));
            
            hdl.data.Filter(iFilter).iMaxPhase = hdl.data.iMaxPhase;
            
        elseif hdl.data.Filter(iFilter).Order == 2
            
            hdl.data.Filter(iFilter).FreqPMax = str2num(get(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqPMax,'string'));
            hdl.data.Filter(iFilter).PhaseMax= str2num(get(hdl.gui.panelDesignParamLLSecondOrderEtDpPhaseMax,'string'));
            hdl.data.Filter(iFilter).HFGain = str2num(get(hdl.gui.panelDesignParamLLSecondOrderEtDpHFGain,'string'));
            hdl.data.Filter(iFilter).FreqGMax = str2num(get(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqGMax,'string'));
            
            hdl.data.Filter(iFilter).FreqPMax_Min = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMinDpFreqPMax,'string'));
            hdl.data.Filter(iFilter).FreqPMax_Max = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpFreqPMax,'string'));
            
            hdl.data.Filter(iFilter).PhaseMax_Min = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMinDpPhaseMax,'string'));
            hdl.data.Filter(iFilter).PhaseMax_Max = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpPhaseMax,'string'));
            
            hdl.data.Filter(iFilter).HFGain_Min = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMinDpHFGain,'string'));
            hdl.data.Filter(iFilter).HFGain_Max = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpHFGain,'string'));
            
            hdl.data.Filter(iFilter).FreqGMax_Min = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMinDpFreqGMax,'string'));
            hdl.data.Filter(iFilter).FreqGMax_Max = str2num(get(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpFreqGMax,'string'));
        end
    end
end