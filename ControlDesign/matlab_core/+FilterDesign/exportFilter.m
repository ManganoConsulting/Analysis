function [hdl] = exportFilter(hdl)
import FilterDesign.*

PMList = get(hdl.gui.panelFiltersPMList,'string');

if ~isempty(PMList{1})
    
    selFilter    = get(hdl.gui.panelFiltersListBox,'value');
    nFilter      = length(selFilter);
    
    % Specify filelocation
    [FILENAME, PATHNAME,FILTERINDEX] = uiputfile({'*.m'}, 'Specify *.m file');
    
    if FILTERINDEX
        for i=1:nFilter
            
            iFilter = selFilter(i);
            
            Filter(i).Name = hdl.data.Filter(iFilter).Name;
            Filter(i).Type = hdl.data.Filter(iFilter).Type;
            Filter(i).num  = hdl.data.Filter(iFilter).num;
            Filter(i).den  = hdl.data.Filter(iFilter).den;
        end
        matlab.io.saveVariablesToScript(fullfile(PATHNAME,FILENAME),{'Filter'});
        
    end
end
