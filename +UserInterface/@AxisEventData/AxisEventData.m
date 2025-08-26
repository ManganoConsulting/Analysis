classdef (ConstructOnLoad) AxisEventData < event.EventData
   properties
      Type
      Value
      AxisObj
   end
   methods
      function eventData = AxisEventData(type,value,axisObj)
        eventData.Type      = type;
        eventData.Value     = value;
        eventData.AxisObj   = axisObj;

      end
   end
end