classdef (ConstructOnLoad) UserInterfaceEventData < event.EventData
   properties
      Object
   end
   methods
      function eventData = UserInterfaceEventData(obj)
          if nargin == 1
            eventData.Object = obj;
          end
      end
   end
end