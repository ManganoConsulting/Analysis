classdef (ConstructOnLoad) ModelAddedEventData < event.EventData
   properties
      Filename
      ThrowError
      NodeName
   end
   methods
      function eventData = ModelAddedEventData( filename , throwError , nodeName )
          switch nargin
              case 1
                eventData.Filename = filename;
              case 2
                eventData.Filename = filename;
                eventData.ThrowError = throwError;
              case 3
                eventData.Filename = filename;
                eventData.ThrowError = throwError;
                eventData.NodeName = nodeName;
          end
      end
   end
end