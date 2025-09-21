function [hdl] = setStringUnits(hdl)
import FilterDesign.*
if strcmp(hdl.data.FreqUnits,'Hz')
    set(hdl.gui.panelFiltersStFreqPts,'String',strrep(get(hdl.gui.panelFiltersStFreqPts,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamNotchStDpCenterFreq,'String',strrep(get(hdl.gui.panelDesignParamNotchStDpCenterFreq,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    set(hdl.gui.panelDesignParamNotchStDpFreq2,'String',strrep(get(hdl.gui.panelDesignParamNotchStDpFreq2,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamLLFirstOrderStDpFreq,'String',strrep(get(hdl.gui.panelDesignParamLLFirstOrderStDpFreq,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamLLSecondOrderStDpFreqPMax,'String',strrep(get(hdl.gui.panelDesignParamLLSecondOrderStDpFreqPMax,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    set(hdl.gui.panelDesignParamLLSecondOrderStDpFreqGMax,'String',strrep(get(hdl.gui.panelDesignParamLLSecondOrderStDpFreqGMax,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    
    %set(hdl.gui.panelPlotOptionsStAddDispFreq,'String',strrep(get(hdl.gui.panelPlotOptionsStAddDispFreq,'String'),'(rad/s)',['(' hdl.data.FreqUnits ')']));
    
    
 
else
    set(hdl.gui.panelFiltersStFreqPts,'String',strrep(get(hdl.gui.panelFiltersStFreqPts,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamNotchStDpCenterFreq,'String',strrep(get(hdl.gui.panelDesignParamNotchStDpCenterFreq,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    set(hdl.gui.panelDesignParamNotchStDpFreq2,'String',strrep(get(hdl.gui.panelDesignParamNotchStDpFreq2,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamLLFirstOrderStDpFreq,'String',strrep(get(hdl.gui.panelDesignParamLLFirstOrderStDpFreq,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    
    set(hdl.gui.panelDesignParamLLSecondOrderStDpFreqPMax,'String',strrep(get(hdl.gui.panelDesignParamLLSecondOrderStDpFreqPMax,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    set(hdl.gui.panelDesignParamLLSecondOrderStDpFreqGMax,'String',strrep(get(hdl.gui.panelDesignParamLLSecondOrderStDpFreqGMax,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
    
    %set(hdl.gui.panelPlotOptionsStAddDispFreq,'String',strrep(get(hdl.gui.panelPlotOptionsStAddDispFreq,'String'),'(Hz)',['(' hdl.data.FreqUnits ')']));
end

