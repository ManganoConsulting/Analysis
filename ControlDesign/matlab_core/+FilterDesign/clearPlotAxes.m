function [hdl] = clearPlotAxes(hdl)
import FilterDesign.*
    cla(hdl.gui.BodeGainAxes);
    cla(hdl.gui.BodePhaseAxes);
    cla(hdl.gui.NicholsAxes);
    cla(hdl.gui.PZMapAxes);
    axes(hdl.gui.BodeGainAxes);
    title([]);

end