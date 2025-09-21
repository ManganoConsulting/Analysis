classdef (ConstructOnLoad) AxisButtonDownEventData < event.EventData
   properties
      AxisObj
   end
   methods
      function eventData = AxisButtonDownEventData(AxisObj)
        eventData.AxisObj   = AxisObj;

      end
   end
end