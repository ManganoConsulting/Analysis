classdef (ConstructOnLoad) DesignOCSelEventData < event.EventData
   properties
      DesignOC lacm.OperatingCondition = @lacm.OperatingCondition.empty;
   end
   methods
      function eventData = DesignOCSelEventData(designOC)
            eventData.DesignOC = designOC;
      end
   end
end