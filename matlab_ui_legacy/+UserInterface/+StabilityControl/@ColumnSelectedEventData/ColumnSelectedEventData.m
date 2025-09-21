classdef (ConstructOnLoad) ColumnSelectedEventData < event.EventData
   properties
      Index
   end
   methods
      function eventData = ColumnSelectedEventData( index  )
            eventData.Index = index;
      end
   end
end