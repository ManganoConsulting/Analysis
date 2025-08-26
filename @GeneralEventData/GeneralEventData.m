classdef (ConstructOnLoad) GeneralEventData < event.EventData
   properties
      Value = 0;
   end
   methods
      function eventData = GeneralEventData(value)
            eventData.Value = value;
      end
   end
end