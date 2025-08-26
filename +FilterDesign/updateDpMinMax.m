function [hdl] = updateDpMinMax(hdl)
import FilterDesign.*
iFilter    = get(hdl.gui.panelFiltersPMList,'value');
nFilter    = length(iFilter);

if nFilter ==1
    CenterFreq_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpCenterFreq,'String'));
    CenterFreq_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpCenterFreq,'String'));
    CenterFreq_AMax= hdl.data.NFSettings.CenterFreq_Max;
    CenterFreq_AMin= hdl.data.NFSettings.CenterFreq_Min;
    CenterFreq     = hdl.data.Filter(iFilter).CenterFreq;
    
    [CenterFreq_Min,CenterFreq_Max,CenterFreq] = getMinMaxValue(CenterFreq_Min,CenterFreq_Max,CenterFreq,CenterFreq_AMin,CenterFreq_AMax);
    
    hdl.data.Filter(iFilter).CenterFreq_Min = CenterFreq_Min;
    hdl.data.Filter(iFilter).CenterFreq_Max = CenterFreq_Max;
    hdl.data.Filter(iFilter).CenterFreq     = CenterFreq;
    
    
    CenterAttn_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpCenterAttn,'String'));
    CenterAttn_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpCenterAttn,'String'));
    CenterAttn_AMax= hdl.data.NFSettings.CenterAttn_Max;
    CenterAttn_AMin= hdl.data.NFSettings.CenterAttn_Min;
    CenterAttn     = hdl.data.Filter(iFilter).CenterAttn;
    
    [CenterAttn_Min,CenterAttn_Max,CenterAttn] = getMinMaxValue(CenterAttn_Min,CenterAttn_Max,CenterAttn,CenterAttn_AMin,CenterAttn_AMax);
    
    hdl.data.Filter(iFilter).CenterAttn_Min = CenterAttn_Min;
    hdl.data.Filter(iFilter).CenterAttn_Max = CenterAttn_Max;
    hdl.data.Filter(iFilter).CenterAttn     = CenterAttn;
    
    
    Freq2_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpFreq2,'String'));
    Freq2_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpFreq2,'String'));
    Freq2_AMax= hdl.data.NFSettings.Freq2_Max;
    Freq2_AMin= hdl.data.NFSettings.Freq2_Min;
    Freq2     = hdl.data.Filter(iFilter).Freq2;
    
    [Freq2_Min,Freq2_Max,Freq2] = getMinMaxValue(Freq2_Min,Freq2_Max,Freq2,Freq2_AMin,Freq2_AMax);
    
    hdl.data.Filter(iFilter).Freq2_Min = Freq2_Min;
    hdl.data.Filter(iFilter).Freq2_Max = Freq2_Max;
    hdl.data.Filter(iFilter).Freq2     = Freq2;
    
    
    Attn2_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpAttn2,'String'));
    Attn2_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpAttn2,'String'));
    Attn2_AMax= hdl.data.NFSettings.Attn2_Max;
    Attn2_AMin= hdl.data.NFSettings.Attn2_Min;
    Attn2     = hdl.data.Filter(iFilter).Attn2;
    
    [Attn2_Min,Attn2_Max,Attn2] = getMinMaxValue(Attn2_Min,Attn2_Max,Attn2,Attn2_AMin,Attn2_AMax);
    
    hdl.data.Filter(iFilter).Attn2_Min = Attn2_Min;
    hdl.data.Filter(iFilter).Attn2_Max = Attn2_Max;
    hdl.data.Filter(iFilter).Attn2     = Attn2;
    
    DCGain_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpDCGain,'String'));
    DCGain_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpDCGain,'String'));
    DCGain_AMax= hdl.data.NFSettings.DCGain_Max;
    DCGain_AMin= hdl.data.NFSettings.DCGain_Min;
    DCGain     = hdl.data.Filter(iFilter).DCGain;
    
    [DCGain_Min,DCGain_Max,DCGain] = getMinMaxValue(DCGain_Min,DCGain_Max,DCGain,DCGain_AMin,DCGain_AMax);
    
    hdl.data.Filter(iFilter).DCGain_Min = DCGain_Min;
    hdl.data.Filter(iFilter).DCGain_Max = DCGain_Max;
    hdl.data.Filter(iFilter).DCGain     = DCGain;
    
    HFGain_Min = str2num(get(hdl.gui.panelDesignParamNotchSlMinDpHFGain,'String'));
    HFGain_Max = str2num(get(hdl.gui.panelDesignParamNotchSlMaxDpHFGain,'String'));
    HFGain_AMax= hdl.data.NFSettings.HFGain_Max;
    HFGain_AMin= hdl.data.NFSettings.HFGain_Min;
    HFGain     = hdl.data.Filter(iFilter).HFGain;
    
    [HFGain_Min,HFGain_Max,HFGain] = getMinMaxValue(HFGain_Min,HFGain_Max,HFGain,HFGain_AMin,HFGain_AMax);
    
    hdl.data.Filter(iFilter).HFGain_Min = HFGain_Min;
    hdl.data.Filter(iFilter).HFGain_Max = HFGain_Max;
    hdl.data.Filter(iFilter).HFGain     = HFGain;
end

    function [MinOut,MaxOut,ValueOut] = getMinMaxValue(MinIn,MaxIn,ValueIn,AMin,AMax)
        
        if ~isempty(MinIn)
            if MinIn < AMin
                MinIn = AMin;
            end
        end
        
        if ~isempty(MaxIn)
            if MaxIn > AMax;
                MaxIn = AMax;
            end
        end
        
        if ~isempty(ValueIn) && ~isempty(MinIn)
            if ValueIn < MinIn
                ValueIn = MinIn;
            end
        end
        
        if ~isempty(ValueIn) && ~isempty(MaxIn)
            if ValueIn > MaxIn
                ValueIn = MaxIn;
            end
        end
        
        if ~isempty(MinIn) && ~isempty(MaxIn)
            if MinIn >= MaxIn
                MinIn = [];
                MaxIn = [];
            end
        end
        
        ValueOut = ValueIn;
        MinOut   = MinIn;
        MaxOut   = MaxIn;
    end
end

