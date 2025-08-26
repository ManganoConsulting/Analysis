classdef (ConstructOnLoad) AnalysisOCSelEventData < event.EventData
   properties
      AnalysisOC lacm.OperatingCondition = @lacm.OperatingCondition.empty;
   end
   methods
      function eventData = AnalysisOCSelEventData(analysisOC)
            eventData.AnalysisOC = analysisOC;
      end
   end
end