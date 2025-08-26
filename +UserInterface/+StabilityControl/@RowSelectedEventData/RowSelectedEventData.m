classdef (ConstructOnLoad) RowSelectedEventData < event.EventData
   properties
      Index
   end
   methods
      function eventData = RowSelectedEventData( index  )
            eventData.Index = index;
      end
   end
end