classdef (ConstructOnLoad) ControlTreeEventData < event.EventData
   properties
      Object
   end
   methods
      function eventData = ControlTreeEventData(operCond)
          if nargin == 1
            eventData.Object = operCond;
          end
      end
   end
end