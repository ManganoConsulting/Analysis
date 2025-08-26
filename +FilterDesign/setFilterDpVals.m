function [hdl] = setFilterDpVals(hdl)
import FilterDesign.*
iFilter    = get(hdl.gui.panelFiltersPMList,'value');

PMList = get(hdl.gui.panelFiltersPMList,'string');


if ~isempty(PMList{1})
    
    if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
        % Design Parameter Labels and Values (Quick Fix)
        set(hdl.gui.panelDesignParametersStDp,'parent',hdl.gui.panelDesignParamNotch);
        set(hdl.gui.panelFiltersPMList,'parent',hdl.gui.panelDesignParamNotch);
        set(hdl.gui.panelDesignParamStCurVal,'parent',hdl.gui.panelDesignParamNotch);
        set(hdl.gui.panelDesignParamStSlMinDp,'parent',hdl.gui.panelDesignParamNotch);
        set(hdl.gui.panelDesignParamStSlMaxDp,'parent',hdl.gui.panelDesignParamNotch);
        
        
        set(hdl.gui.panelDesignParamNotchSlMinDpCenterFreq,'String',num2str(hdl.data.Filter(iFilter).CenterFreq_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpCenterFreq,'String',num2str(hdl.data.Filter(iFilter).CenterFreq_Max));
        
        set(hdl.gui.panelDesignParamNotchSlMinDpCenterAttn,'String',num2str(hdl.data.Filter(iFilter).CenterAttn_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpCenterAttn,'String',num2str(hdl.data.Filter(iFilter).CenterAttn_Max));
        
        set(hdl.gui.panelDesignParamNotchSlMinDpFreq2,'String',num2str(hdl.data.Filter(iFilter).Freq2_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpFreq2,'String',num2str(hdl.data.Filter(iFilter).Freq2_Max));
        
        set(hdl.gui.panelDesignParamNotchSlMinDpAttn2,'String',num2str(hdl.data.Filter(iFilter).Attn2_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpAttn2,'String',num2str(hdl.data.Filter(iFilter).Attn2_Max));
        
        set(hdl.gui.panelDesignParamNotchSlMinDpDCGain,'String',num2str(hdl.data.Filter(iFilter).DCGain_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpDCGain,'String',num2str(hdl.data.Filter(iFilter).DCGain_Max));
        
        set(hdl.gui.panelDesignParamNotchSlMinDpHFGain,'String',num2str(hdl.data.Filter(iFilter).HFGain_Min));
        set(hdl.gui.panelDesignParamNotchSlMaxDpHFGain,'String',num2str(hdl.data.Filter(iFilter).HFGain_Max));
        
        set(hdl.gui.panelDesignParamNotchEtDpCenterFreq,'string',num2str(hdl.data.Filter(iFilter).CenterFreq))
        set(hdl.gui.panelDesignParamNotchEtDpCenterAttn,'string',num2str(hdl.data.Filter(iFilter).CenterAttn));
        set(hdl.gui.panelDesignParamNotchEtDpFreq2,'string',num2str(hdl.data.Filter(iFilter).Freq2));
        set(hdl.gui.panelDesignParamNotchEtDpAttn2,'string',num2str(hdl.data.Filter(iFilter).Attn2));
        set(hdl.gui.panelDesignParamNotchEtDpDCGain,'string',num2str(hdl.data.Filter(iFilter).DCGain));
        set(hdl.gui.panelDesignParamNotchEtDpHFGain,'string',num2str(hdl.data.Filter(iFilter).HFGain));
        
        
        % Slider Min/Max
        if ~isempty(hdl.data.Filter(iFilter).CenterFreq_Min) && ~isempty(hdl.data.Filter(iFilter).CenterFreq_Max)
            set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'Min',hdl.data.Filter(iFilter).CenterFreq_Min);
            set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'Max',hdl.data.Filter(iFilter).CenterFreq_Max);
        end
        
        if ~isempty(hdl.data.Filter(iFilter).CenterAttn_Min) && ~isempty(hdl.data.Filter(iFilter).CenterAttn_Max)
            set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'Min',hdl.data.Filter(iFilter).CenterAttn_Min);
            set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'Max',hdl.data.Filter(iFilter).CenterAttn_Max);
        end
        
        if ~isempty(hdl.data.Filter(iFilter).Freq2_Min) && ~isempty(hdl.data.Filter(iFilter).Freq2_Max)
            set(hdl.gui.panelDesignParamNotchSlDpFreq2,'Min',hdl.data.Filter(iFilter).Freq2_Min);
            set(hdl.gui.panelDesignParamNotchSlDpFreq2,'Max',hdl.data.Filter(iFilter).Freq2_Max);
        end
        
        if ~isempty(hdl.data.Filter(iFilter).Attn2_Min) && ~isempty(hdl.data.Filter(iFilter).Attn2_Max)
            set(hdl.gui.panelDesignParamNotchSlDpAttn2,'Min',hdl.data.Filter(iFilter).Attn2_Min);
            set(hdl.gui.panelDesignParamNotchSlDpAttn2,'Max',hdl.data.Filter(iFilter).Attn2_Max);
        end
        
        if ~isempty(hdl.data.Filter(iFilter).DCGain_Min) && ~isempty(hdl.data.Filter(iFilter).DCGain_Max)
            set(hdl.gui.panelDesignParamNotchSlDpDCGain,'Min',hdl.data.Filter(iFilter).DCGain_Min);
            set(hdl.gui.panelDesignParamNotchSlDpDCGain,'Max',hdl.data.Filter(iFilter).DCGain_Max);
        end
        
        if ~isempty(hdl.data.Filter(iFilter).HFGain_Min) && ~isempty(hdl.data.Filter(iFilter).HFGain_Max)
            set(hdl.gui.panelDesignParamNotchSlDpHFGain,'Min',hdl.data.Filter(iFilter).HFGain_Min);
            set(hdl.gui.panelDesignParamNotchSlDpHFGain,'Max',hdl.data.Filter(iFilter).HFGain_Max);
        end
        
        % Slider value
        if ~isempty(hdl.data.Filter(iFilter).CenterFreq_Min) && ~isempty(hdl.data.Filter(iFilter).CenterFreq_Max)
            if ~isempty(hdl.data.Filter(iFilter).CenterFreq)
                set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'value',hdl.data.Filter(iFilter).CenterFreq);
            else
                set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'value',get(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'min'));
            end
        end
        
        if ~isempty(hdl.data.Filter(iFilter).CenterAttn_Min) && ~isempty(hdl.data.Filter(iFilter).CenterAttn_Max)
            if ~isempty(hdl.data.Filter(iFilter).CenterAttn)
                set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'value',hdl.data.Filter(iFilter).CenterAttn);
            else
                set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'value',get(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'min'));
            end
        end
        
        if ~isempty(hdl.data.Filter(iFilter).Freq2_Min) && ~isempty(hdl.data.Filter(iFilter).Freq2_Max)
            if ~isempty(hdl.data.Filter(iFilter).Freq2)
                set(hdl.gui.panelDesignParamNotchSlDpFreq2,'value',hdl.data.Filter(iFilter).Freq2);
            else
                set(hdl.gui.panelDesignParamNotchSlDpFreq2,'value',get(hdl.gui.panelDesignParamNotchSlDpFreq2,'min'));
            end
        end
        
        if ~isempty(hdl.data.Filter(iFilter).Attn2_Min) && ~isempty(hdl.data.Filter(iFilter).Attn2_Max)
            if ~isempty(hdl.data.Filter(iFilter).Attn2)
                set(hdl.gui.panelDesignParamNotchSlDpAttn2,'value',hdl.data.Filter(iFilter).Attn2);
            else
                set(hdl.gui.panelDesignParamNotchSlDpAttn2,'value',get(hdl.gui.panelDesignParamNotchSlDpAttn2,'min'));
            end
        end
        
        if ~isempty(hdl.data.Filter(iFilter).DCGain_Min) && ~isempty(hdl.data.Filter(iFilter).DCGain_Max)
            if ~isempty(hdl.data.Filter(iFilter).DCGain)
                set(hdl.gui.panelDesignParamNotchSlDpDCGain,'value',hdl.data.Filter(iFilter).DCGain);
            else
                set(hdl.gui.panelDesignParamNotchSlDpDCGain,'value',get(hdl.gui.panelDesignParamNotchSlDpDCGain,'min'));
            end
        end
        
        if ~isempty(hdl.data.Filter(iFilter).HFGain_Min) && ~isempty(hdl.data.Filter(iFilter).HFGain_Max)
            if ~isempty(hdl.data.Filter(iFilter).HFGain)
                set(hdl.gui.panelDesignParamNotchSlDpHFGain,'value',hdl.data.Filter(iFilter).HFGain);
            else
                set(hdl.gui.panelDesignParamNotchSlDpHFGain,'value',get(hdl.gui.panelDesignParamNotchSlDpHFGain,'min'));
            end
        end
        
    elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
        if hdl.data.Filter(iFilter).Order == 1
            % Design Parameter Labels and Values (Quick Fix)
            set(hdl.gui.panelDesignParametersStDp,'parent',hdl.gui.panelDesignParamLLFirstOrder);
            set(hdl.gui.panelFiltersPMList,'parent',hdl.gui.panelDesignParamLLFirstOrder);
            set(hdl.gui.panelDesignParamStCurVal,'parent',hdl.gui.panelDesignParamLLFirstOrder);
            set(hdl.gui.panelDesignParamStSlMinDp,'parent',hdl.gui.panelDesignParamLLFirstOrder);
            set(hdl.gui.panelDesignParamStSlMaxDp,'parent',hdl.gui.panelDesignParamLLFirstOrder);
            
            set(hdl.gui.panelDesignParamLLFirstOrderSlMinDpFreq,'String',num2str(hdl.data.Filter(iFilter).Freq_Min));
            set(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpFreq,'String',num2str(hdl.data.Filter(iFilter).Freq_Max));
            
            set(hdl.gui.panelDesignParamLLFirstOrderSlMinDpPhase,'String',num2str(hdl.data.Filter(iFilter).Phase_Min));
            set(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpPhase,'String',num2str(hdl.data.Filter(iFilter).Phase_Max));
            
            set(hdl.gui.panelDesignParamLLFirstOrderSlMinDpGain,'String',num2str(hdl.data.Filter(iFilter).Gain_Min));
            set(hdl.gui.panelDesignParamLLFirstOrderSlMaxDpGain,'String',num2str(hdl.data.Filter(iFilter).Gain_Max));
            
            set(hdl.gui.panelDesignParamLLFirstOrderEtDpFreq,'string',num2str(hdl.data.Filter(iFilter).Freq))
            set(hdl.gui.panelDesignParamLLFirstOrderEtDpPhase,'string',num2str(hdl.data.Filter(iFilter).Phase));
            set(hdl.gui.panelDesignParamLLFirstOrderEtDpGain,'string',num2str(hdl.data.Filter(iFilter).Gain));
            
            % Slider Min/Max
            if ~isempty(hdl.data.Filter(iFilter).Freq_Min) && ~isempty(hdl.data.Filter(iFilter).Freq_Max)
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'Min',hdl.data.Filter(iFilter).Freq_Min);
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'Max',hdl.data.Filter(iFilter).Freq_Max);
            end
            
            if ~isempty(hdl.data.Filter(iFilter).Phase_Min) && ~isempty(hdl.data.Filter(iFilter).Phase_Max)
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'Min',hdl.data.Filter(iFilter).Phase_Min);
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'Max',hdl.data.Filter(iFilter).Phase_Max);
            end
            
            if ~isempty(hdl.data.Filter(iFilter).Gain_Min) && ~isempty(hdl.data.Filter(iFilter).Gain_Max)
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'Min',hdl.data.Filter(iFilter).Gain_Min);
                set(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'Max',hdl.data.Filter(iFilter).Gain_Max);
            end
            
            % Slider value
            if ~isempty(hdl.data.Filter(iFilter).Freq_Min) && ~isempty(hdl.data.Filter(iFilter).Freq_Max)
                if ~isempty(hdl.data.Filter(iFilter).Freq)
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'value',hdl.data.Filter(iFilter).Freq);
                else
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'value',get(hdl.gui.panelDesignParamLLFirstOrderSlDpFreq,'min'));
                end
            end
            
            if ~isempty(hdl.data.Filter(iFilter).Phase_Min) && ~isempty(hdl.data.Filter(iFilter).Phase_Max)
                if ~isempty(hdl.data.Filter(iFilter).Phase)
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'value',hdl.data.Filter(iFilter).Phase);
                else
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'value',get(hdl.gui.panelDesignParamLLFirstOrderSlDpPhase,'min'));
                end
            end
            
            if ~isempty(hdl.data.Filter(iFilter).Gain_Min) && ~isempty(hdl.data.Filter(iFilter).Gain_Max)
                if ~isempty(hdl.data.Filter(iFilter).Gain)
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'value',hdl.data.Filter(iFilter).Gain);
                else
                    set(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'value',get(hdl.gui.panelDesignParamLLFirstOrderSlDpGain,'min'));
                end
            end
            
            set(hdl.gui.panelDesignParamLLFirstOrderCBMaxPhase,'Value',hdl.data.Filter(iFilter).iMaxPhase);
            
        elseif hdl.data.Filter(iFilter).Order == 2
            
            % Design Parameter Labels and Values (Quick Fix)
            set(hdl.gui.panelDesignParametersStDp,'parent',hdl.gui.panelDesignParamLLSecondOrder);
            set(hdl.gui.panelFiltersPMList,'parent',hdl.gui.panelDesignParamLLSecondOrder);
            set(hdl.gui.panelDesignParamStCurVal,'parent',hdl.gui.panelDesignParamLLSecondOrder);
            set(hdl.gui.panelDesignParamStSlMinDp,'parent',hdl.gui.panelDesignParamLLSecondOrder);
            set(hdl.gui.panelDesignParamStSlMaxDp,'parent',hdl.gui.panelDesignParamLLSecondOrder);
            
            set(hdl.gui.panelDesignParamLLSecondOrderSlMinDpFreqPMax,'String',num2str(hdl.data.Filter(iFilter).FreqPMax_Min));
            set(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpFreqPMax,'String',num2str(hdl.data.Filter(iFilter).FreqPMax_Max));
            
            set(hdl.gui.panelDesignParamLLSecondOrderSlMinDpPhaseMax,'String',num2str(hdl.data.Filter(iFilter).PhaseMax_Min));
            set(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpPhaseMax,'String',num2str(hdl.data.Filter(iFilter).PhaseMax_Max));
            
            set(hdl.gui.panelDesignParamLLSecondOrderSlMinDpHFGain,'String',num2str(hdl.data.Filter(iFilter).HFGain_Min));
            set(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpHFGain,'String',num2str(hdl.data.Filter(iFilter).HFGain_Max));
            
            set(hdl.gui.panelDesignParamLLSecondOrderSlMinDpFreqGMax,'String',num2str(hdl.data.Filter(iFilter).FreqGMax_Min));
            set(hdl.gui.panelDesignParamLLSecondOrderSlMaxDpFreqGMax,'String',num2str(hdl.data.Filter(iFilter).FreqGMax_Max));
            
            set(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqPMax,'string',num2str(hdl.data.Filter(iFilter).FreqPMax))
            set(hdl.gui.panelDesignParamLLSecondOrderEtDpPhaseMax,'string',num2str(hdl.data.Filter(iFilter).PhaseMax));
            set(hdl.gui.panelDesignParamLLSecondOrderEtDpHFGain,'string',num2str(hdl.data.Filter(iFilter).HFGain));
            set(hdl.gui.panelDesignParamLLSecondOrderEtDpFreqGMax,'string',num2str(hdl.data.Filter(iFilter).FreqGMax))
            
            % Slider Min/Max
            if ~isempty(hdl.data.Filter(iFilter).FreqPMax_Min) && ~isempty(hdl.data.Filter(iFilter).FreqPMax_Max)
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'Min',hdl.data.Filter(iFilter).FreqPMax_Min);
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'Max',hdl.data.Filter(iFilter).FreqPMax_Max);
            end
            
            if ~isempty(hdl.data.Filter(iFilter).PhaseMax_Min) && ~isempty(hdl.data.Filter(iFilter).PhaseMax_Max)
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'Min',hdl.data.Filter(iFilter).PhaseMax_Min);
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'Max',hdl.data.Filter(iFilter).PhaseMax_Max);
            end
            
            if ~isempty(hdl.data.Filter(iFilter).HFGain_Min) && ~isempty(hdl.data.Filter(iFilter).HFGain_Max)
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'Min',hdl.data.Filter(iFilter).HFGain_Min);
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'Max',hdl.data.Filter(iFilter).HFGain_Max);
            end
            
            if ~isempty(hdl.data.Filter(iFilter).FreqGMax_Min) && ~isempty(hdl.data.Filter(iFilter).FreqGMax_Max)
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'Min',hdl.data.Filter(iFilter).FreqGMax_Min);
                set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'Max',hdl.data.Filter(iFilter).FreqGMax_Max);
            end
            
            % Slider value
            if ~isempty(hdl.data.Filter(iFilter).FreqPMax_Min) && ~isempty(hdl.data.Filter(iFilter).FreqPMax_Max)
                if ~isempty(hdl.data.Filter(iFilter).FreqPMax)
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'value',hdl.data.Filter(iFilter).FreqPMax);
                else
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'value',get(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqPMax,'min'));
                end
            end
            
            if ~isempty(hdl.data.Filter(iFilter).PhaseMax_Min) && ~isempty(hdl.data.Filter(iFilter).PhaseMax_Max)
                if ~isempty(hdl.data.Filter(iFilter).PhaseMax)
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'value',hdl.data.Filter(iFilter).PhaseMax);
                else
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'value',get(hdl.gui.panelDesignParamLLSecondOrderSlDpPhaseMax,'min'));
                end
            end
            
            if ~isempty(hdl.data.Filter(iFilter).HFGain_Min) && ~isempty(hdl.data.Filter(iFilter).HFGain_Max)
                if ~isempty(hdl.data.Filter(iFilter).HFGain)
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'value',hdl.data.Filter(iFilter).HFGain);
                else
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'value',get(hdl.gui.panelDesignParamLLSecondOrderSlDpHFGain,'min'));
                end
            end
            
            if ~isempty(hdl.data.Filter(iFilter).FreqGMax_Min) && ~isempty(hdl.data.Filter(iFilter).FreqGMax_Max)
                if ~isempty(hdl.data.Filter(iFilter).FreqGMax)
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'value',hdl.data.Filter(iFilter).FreqGMax);
                else
                    set(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'value',get(hdl.gui.panelDesignParamLLSecondOrderSlDpFreqGMax,'min'));
                end
            end
            
            
            if strcmp(hdl.data.Filter(iFilter).LLSecondOrderOption,'Specify Freq @ Max Gain')
                set(hdl.gui.panelDesignParamLLSecondOrderUIBGroup,'SelectedObject',hdl.gui.panelDesignParamLLSecondOrderRBFreqGMax);
            else
                set(hdl.gui.panelDesignParamLLSecondOrderUIBGroup,'SelectedObject',hdl.gui.panelDesignParamLLSecondOrderRBPhasePos);
            end
        end
    end
    
    
    % else
    %
    %     set(hdl.gui.panelDesignParamNotchEtDpCenterFreq,'string',[])
    %     set(hdl.gui.panelDesignParamNotchEtDpCenterAttn,'string',[]);
    %     set(hdl.gui.panelDesignParamNotchEtDpFreq2,'string',[]);
    %     set(hdl.gui.panelDesignParamNotchEtDpAttn2,'string',[]);
    %     set(hdl.gui.panelDesignParamNotchEtDpDCGain,'string',[]);
    %     set(hdl.gui.panelDesignParamNotchEtDpHFGain,'string',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpCenterFreq,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpCenterFreq,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpCenterAttn,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpCenterAttn,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpFreq2,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpFreq2,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpAttn2,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpAttn2,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpDCGain,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpDCGain,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpHFGain,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpHFGain,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpCenterFreq,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpCenterFreq,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpCenterAttn,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpCenterAttn,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpFreq2,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpFreq2,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpAttn2,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpAttn2,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpDCGain,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpDCGain,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlMinDpHFGain,'String',[]);
    %     set(hdl.gui.panelDesignParamNotchSlMaxDpHFGain,'String',[]);
    %
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'value',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'value',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpFreq2,'value',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpAttn2,'value',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpDCGain,'value',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpHFGain,'value',0);
    %
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'min',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'min',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpFreq2,'min',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpAttn2,'min',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpDCGain,'min',0);
    %     set(hdl.gui.panelDesignParamNotchSlDpHFGain,'min',0);
    %
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterFreq,'max',1);
    %     set(hdl.gui.panelDesignParamNotchSlDpCenterAttn,'max',1);
    %     set(hdl.gui.panelDesignParamNotchSlDpFreq2,'max',1);
    %     set(hdl.gui.panelDesignParamNotchSlDpAttn2,'max',1);
    %     set(hdl.gui.panelDesignParamNotchSlDpDCGain,'max',1);
    %     set(hdl.gui.panelDesignParamNotchSlDpHFGain,'max',1);
end