classdef (ConstructOnLoad) LoadConfigEventData < event.EventData
   properties
      Config lacm.Configuration = lacm.Configuration.empty;
   end
   methods
      function eventData = LoadConfigEventData(config)
            eventData.Config = config;
      end
   end
end