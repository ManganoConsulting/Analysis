function [hdl] = getFilterPanel(hdl)
import FilterDesign.*
iFilter = get(hdl.gui.panelFiltersPMList,'value');

PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    if strcmp(hdl.data.Filter(iFilter).Type,'Notch/BandPass Filter')
        set(hdl.gui.panelDesignParamLLFirstOrder,'visible','off');
        set(hdl.gui.panelDesignParamLLSecondOrder,'visible','off');
        set(hdl.gui.panelDesignParamNotch,'visible','on');
    elseif strcmp(hdl.data.Filter(iFilter).Type,'Lead/Lag Filter')
        if hdl.data.Filter(iFilter).Order == 1
            set(hdl.gui.panelDesignParamNotch,'visible','off');
            set(hdl.gui.panelDesignParamLLSecondOrder,'visible','off');
            set(hdl.gui.panelDesignParamLLFirstOrder,'visible','on');
        elseif hdl.data.Filter(iFilter).Order == 2
            set(hdl.gui.panelDesignParamLLFirstOrder,'visible','off');
            set(hdl.gui.panelDesignParamNotch,'visible','off');
            set(hdl.gui.panelDesignParamLLSecondOrder,'visible','on');
        end
    end
end

end