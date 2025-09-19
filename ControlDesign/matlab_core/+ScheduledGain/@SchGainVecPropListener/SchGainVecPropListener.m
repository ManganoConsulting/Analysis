classdef SchGainVecPropListener < handle
    
    %% Method - Constructor
    methods
        function obj = SchGainVecPropListener(evtobj)
            if nargin > 0
                addlistener(evtobj,'ScatteredGainName','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'ScatteredGainDisplayString','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'ScatteredGainExpression','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'NumberOfDimensions','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'BreakPoints1ValueDisplayString','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'BreakPoints2DisplayString','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'BreakPoints2Expression','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'TableDefinitionBreakPoints1','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'TableDefinitionBreakPoints2','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'TableDefinitionTableData','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'FitType','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'FittingRange','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'UserDefinedBreakPoints','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
                addlistener(evtobj,'PolyDegreeValue','PostSet',@ScheduledGain.SchGainVecPropListener.handlePropEvents);
            end
        end % SchGainVecPropListener
    end
   
    %% Methods - Static
    methods (Static)
        function handlePropEvents( ~ , evnt )
            evnt.AffectedObject.IsScheduled = false;
        end % handlePropEvents
    end
end