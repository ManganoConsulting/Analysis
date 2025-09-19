classdef (ConstructOnLoad) TreeEventData < event.EventData
   properties
      OrgValue = 0;
   end
   methods
      function eventData = TreeEventData(value)
            eventData.OrgValue = value;
      end
   end
end