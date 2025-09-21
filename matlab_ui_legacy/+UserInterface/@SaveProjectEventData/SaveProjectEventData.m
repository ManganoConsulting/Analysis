classdef (ConstructOnLoad) SaveProjectEventData < event.EventData
   properties
      SavePath
      SavePlots     
   end
   methods
      function eventData = SaveProjectEventData(path, plots)
          if nargin == 1
            eventData.SavePath = path;
          elseif nargin == 2
            eventData.SavePath = path;
            eventData.SavePlots = plots;
          end
      end
   end
end