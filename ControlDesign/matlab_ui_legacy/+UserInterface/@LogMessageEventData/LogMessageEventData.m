classdef (ConstructOnLoad) LogMessageEventData < event.EventData
   properties
      Message
      Severity = 'info'
      Level = 1
   end
   methods
      function eventData = LogMessageEventData(msg,sev,level)
          if nargin == 1
            eventData.Message = msg;
            %eventData.Severity = 'info';
          elseif nargin == 2
            eventData.Message = msg;
            eventData.Severity = sev;
          elseif nargin == 2
            eventData.Message = msg;
            eventData.Severity = sev;
            eventData.Level = level;
          end
      end
   end
end