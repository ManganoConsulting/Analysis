function gainColNew = gainColLegUpdate(gainColLeg)

numGainCols = length(gainColLeg);
gainColNew = ScatteredGain.GainCollectionNew;

%% Design Operating Conditions
gainColNew.DesignOperatingCondition = ...
	Utilities.operCondLegToCtrl([gainColLeg.DesignOperatingCondition]);
gainColNew.NumGainCols = numGainCols;

%% Gains
for i = 1:numGainCols
	for j = 1:length(gainColLeg(i).Gain)
		gainColNew.addGain(gainColLeg(i).Gain(j), i);
	end
	for j = 1:length(gainColLeg(i).SynthesisDesignParameter)
		gainColNew.addSynthesisDesignParameter(gainColLeg(i).SynthesisDesignParameter(j), i);
	end
	for j = 1:length(gainColLeg(i).RequirementDesignParameter)
		gainColNew.addRequirementDesignParameter(gainColLeg(i).RequirementDesignParameter(j), i);
	end
	gainColNew.Filters(i,:) = copy(gainColLeg(i).Filters);
	gainColNew.OperCondFilterSettings(i) = copy(gainColLeg(i).OperCondFilterSettings);
end

end