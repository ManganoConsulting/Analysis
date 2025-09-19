classdef (ConstructOnLoad) TableDataChangedEventData < event.EventData
   properties
      DisplayData
      AllData
   end
   methods
      function eventData = TableDataChangedEventData( displaydata , alldata )
          switch nargin
              case 2
                eventData.DisplayData = displaydata;
                eventData.AllData     = alldata;
          end
      end
   end
end