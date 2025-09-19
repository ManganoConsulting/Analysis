classdef (ConstructOnLoad) GainSchEventData < event.EventData
   properties
      Object = 0;
   end
   methods
      function eventData = GainSchEventData(val)
            eventData.Object = val;
      end
   end
end