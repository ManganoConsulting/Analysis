function [hdl] = updateSliderDpVals(hdl)
import FilterDesign.*
iFilter = get(hdl.gui.panelFiltersPMList,'value');

PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
        hdl.data.Filter(iFilter).CenterFreq = get(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'value');
        hdl.data.Filter(iFilter).CenterAttn = get(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'value');
        hdl.data.Filter(iFilter).Freq2      = get(hdl.gui.panelDesignParamNotchSlDpFreq2,'value');
        hdl.data.Filter(iFilter).Attn2      = get(hdl.gui.panelDesignParamNotchSlDpAttn2,'value');
        hdl.data.Filter(iFilter).DCGain     = get(hdl.gui.panelDesignParamNotchSlDpDCGain,'value');
        hdl.data.Filter(iFilter).HFGain     = get(hdl.gui.panelDesignParamNotchSlDpHFGain,'value');
        
    elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
        if hdl.data.Filter(iFilter).Order == 1
            hdl.data.Filter(iFilter).Freq  = get(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'value');
            hdl.data.Filter(iFilter).Phase = get(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'value');
            hdl.data.Filter(iFilter).Gain  = get(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'value');
            
        elseif hdl.data.Filter(iFilter).Order == 2
            
            hdl.data.Filter(iFilter).FreqPMax  = get(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'value');
            hdl.data.Filter(iFilter).PhaseMax = get(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'value');
            hdl.data.Filter(iFilter).HFGain  = get(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'value');
            hdl.data.Filter(iFilter).FreqGMax  = get(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'value');
                        
        end
    end
end