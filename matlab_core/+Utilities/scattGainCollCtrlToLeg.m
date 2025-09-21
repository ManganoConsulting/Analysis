function [scattGainLeg] = scattGainCollCtrlToLeg(scattGainCtrl,scattGainIdx)

scattGainLeg = ScatteredGain.GainCollection;

scattGainLeg.Gain = copy(scattGainCtrl.Gain);
for gainIdx = 1:length(scattGainCtrl.Gain)
    scattGainLeg.Gain(gainIdx).Value = scattGainCtrl.Gain(gainIdx).Value(scattGainIdx, :);
end

scattGainLeg.SynthesisDesignParameter = copy(scattGainCtrl.SynthesisDesignParameter);
for synthIdx = 1:length(scattGainCtrl.SynthesisDesignParameter)
    scattGainLeg.SynthesisDesignParameter(synthIdx).Value = scattGainCtrl.SynthesisDesignParameter(synthIdx).Value(scattGainIdx, :);
    scattGainLeg.SynthesisDesignParameter(synthIdx).ValueString = scattGainCtrl.SynthesisDesignParameter(synthIdx).ValueString(scattGainIdx, :);
end

scattGainLeg.RequirementDesignParameter = copy(scattGainCtrl.RequirementDesignParameter);
for reqIdx = 1:length(scattGainCtrl.RequirementDesignParameter)
    scattGainLeg.RequirementDesignParameter(reqIdx).Value = scattGainCtrl.RequirementDesignParameter(reqIdx).Value(scattGainIdx, :);
    scattGainLeg.RequirementDesignParameter(reqIdx).ValueString = scattGainCtrl.RequirementDesignParameter(reqIdx).ValueString(scattGainIdx, :);
end

end
