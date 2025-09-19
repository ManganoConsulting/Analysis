classdef (ConstructOnLoad) Gain2CollEventData < event.EventData
   properties
%       GainName
%       ScatteredGainName
%       GainValue
%       GainSymVar
%       BP1Name
%       BP1Value
%       BP1Path
%       BP2Name
%       BP2Value
%       BP2Path
%       BP2SymVar
      FileName
%       PossibleGains
%       BP1SymVar
      Object
   end
   methods
    function eventData = Gain2CollEventData(obj,filename)

%       function eventData = Gain2CollEventData(gainName,scattGainName,gainvalue,gainSymVar,bp1name,bp1value,bp1Path,bp2name,bp2value,bp2Path,bp2symVar,filename,possibleGains,pb1symVar)
%         eventData.GainName   = gainName;
%         eventData.ScatteredGainName = scattGainName;
%         eventData.GainValue  = gainvalue;
%         eventData.GainSymVar = gainSymVar;
%         eventData.BP1Name    = bp1name;
%         eventData.BP1Value   = bp1value;
%         eventData.BP1Path    = bp1Path;
%         eventData.BP2Name    = bp2name;
%         eventData.BP2Value   = bp2value;
%         eventData.BP2Path    = bp2Path;
%         eventData.BP2SymVar  = bp2symVar;
        eventData.FileName   = filename;
%         eventData.PossibleGains =  possibleGains;
%         eventData.BP1SymVar  = pb1symVar;
        eventData.Object = obj;
      end
   end
end