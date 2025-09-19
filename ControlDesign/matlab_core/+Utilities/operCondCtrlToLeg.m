function [operCondLeg] = operCondCtrlToLeg(operCondCtrl, ocIdx)

%% Setup
operCondLeg = lacm.OperatingCondition;

numStates = length(operCondCtrl.States);
numInputs = length(operCondCtrl.Inputs);
numOutputs = length(operCondCtrl.Outputs);
numStateDerivs = length(operCondCtrl.StateDerivs);
numMassProps = length(operCondCtrl.MassProperties.Parameter);
numLinMdls = length(operCondCtrl.LinearModel);

%% Common
operCondLeg.Label = operCondCtrl.Label(ocIdx);
operCondLeg.ModelName = operCondCtrl.ModelName(ocIdx);
%operCondLeg.SuccessfulTrim = operCondCtrl.SuccessfulTrim(ocIdx);
%operCondLeg.Cost = operCondCtrl.Cost(ocIdx);
operCondLeg.SelectedforAnalysis = operCondCtrl.SelectedforAnalysis(ocIdx);
operCondLeg.SelectedforDesign = operCondCtrl.SelectedforDesign(ocIdx);
operCondLeg.Color = operCondCtrl.Color(ocIdx, :);

%% States
for i = 1:numStates
	operCondLeg.States(i).Name = operCondCtrl.States(i).Name;
	operCondLeg.States(i).Units = operCondCtrl.States(i).Units;
	operCondLeg.States(i).Fix = operCondCtrl.States(i).Fix;
	operCondLeg.States(i).BasicMode = operCondCtrl.States(i).BasicMode;
	operCondLeg.States(i).Constrained = operCondCtrl.States(i).Constrained;
	operCondLeg.States(i).Value = double(operCondCtrl.States(i).Value(ocIdx));
end

%% Inputs
for i = 1:numInputs
	operCondLeg.Inputs(i).Name = operCondCtrl.Inputs(i).Name;
	operCondLeg.Inputs(i).Units = operCondCtrl.Inputs(i).Units;
	operCondLeg.Inputs(i).Fix = operCondCtrl.Inputs(i).Fix;
	operCondLeg.Inputs(i).BasicMode = operCondCtrl.Inputs(i).BasicMode;
	operCondLeg.Inputs(i).Constrained = operCondCtrl.Inputs(i).Constrained;
	operCondLeg.Inputs(i).Value = double(operCondCtrl.Inputs(i).Value(ocIdx));
end

%% Outputs
for i = 1:numOutputs
	operCondLeg.Outputs(i).Name = operCondCtrl.Outputs(i).Name;
	operCondLeg.Outputs(i).Units = operCondCtrl.Outputs(i).Units;
	operCondLeg.Outputs(i).Fix = operCondCtrl.Outputs(i).Fix;
	operCondLeg.Outputs(i).BasicMode = operCondCtrl.Outputs(i).BasicMode;
	operCondLeg.Outputs(i).Constrained = operCondCtrl.Outputs(i).Constrained;
	operCondLeg.Outputs(i).Value = double(operCondCtrl.Outputs(i).Value(ocIdx));
end

%% State Derivs
for i = 1:numStateDerivs
	operCondLeg.StateDerivs(i).Name = operCondCtrl.StateDerivs(i).Name;
	operCondLeg.StateDerivs(i).Units = operCondCtrl.StateDerivs(i).Units;
	operCondLeg.StateDerivs(i).Fix = operCondCtrl.StateDerivs(i).Fix;
	operCondLeg.StateDerivs(i).BasicMode = operCondCtrl.StateDerivs(i).BasicMode;
	operCondLeg.StateDerivs(i).Constrained = operCondCtrl.StateDerivs(i).Constrained;
	operCondLeg.StateDerivs(i).Value = double(operCondCtrl.StateDerivs(i).Value(ocIdx));
end

%% Flight Condition
operCondLeg.FlightCondition = operCondCtrl.FlightCondition(ocIdx);

%% Mass Properties
operCondLeg.MassProperties = lacm.MassProperties;
operCondLeg.MassProperties.Parameter(numMassProps) = lacm.Condition;

operCondLeg.MassProperties.WeightCode = operCondCtrl.MassProperties.WeightCode(ocIdx);
operCondLeg.MassProperties.Label = operCondCtrl.MassProperties.Label(ocIdx);

for i = 1:numMassProps
	operCondLeg.MassProperties.Parameter(i).Name = ...
		operCondCtrl.MassProperties.Parameter(i).Name;
	operCondLeg.MassProperties.Parameter(i).Units = ...
		operCondCtrl.MassProperties.Parameter(i).Units;
	operCondLeg.MassProperties.Parameter(i).Fix = ...
		operCondCtrl.MassProperties.Parameter(i).Fix;
	operCondLeg.MassProperties.Parameter(i).BasicMode = ...
		operCondCtrl.MassProperties.Parameter(i).BasicMode;
	operCondLeg.MassProperties.Parameter(i).Constrained = ...
		operCondCtrl.MassProperties.Parameter(i).Constrained;
	operCondLeg.MassProperties.Parameter(i).Value = ...
		operCondCtrl.MassProperties.Parameter(i).Value(ocIdx);
end

%% Linear Model
operCondLeg.LinearModel(numLinMdls) = lacm.LinearModel;
for i = 1:numLinMdls
	operCondLeg.LinearModel(i) = lacm.LinearModel;

	operCondLeg.LinearModel(i).Label = ...
		operCondCtrl.LinearModel(i).Label;
	operCondLeg.LinearModel(i).States = ...
		operCondCtrl.LinearModel(i).States;
	operCondLeg.LinearModel(i).Inputs = ...
		operCondCtrl.LinearModel(i).Inputs;
	operCondLeg.LinearModel(i).Outputs = ...
		operCondCtrl.LinearModel(i).Outputs;
	operCondLeg.LinearModel(i).AlgebraicInput = ...
		operCondCtrl.LinearModel(i).AlgebraicInput;
	operCondLeg.LinearModel(i).AlgebraicOutput = ...
		operCondCtrl.LinearModel(i).AlgebraicOutput;
	operCondLeg.LinearModel(i).InputConstraintsArray = ...
		operCondCtrl.LinearModel(i).InputConstraintsArray;
	operCondLeg.LinearModel(i).InputConstraintsInfo = ...
		operCondCtrl.LinearModel(i).InputConstraintsInfo;

	operCondLeg.LinearModel(i).A = ...
		double(squeeze(operCondCtrl.LinearModel(i).A(:,:,ocIdx)));
	operCondLeg.LinearModel(i).B = ...
		double(squeeze(operCondCtrl.LinearModel(i).B(:,:,ocIdx)));
	operCondLeg.LinearModel(i).C = ...
		double(squeeze(operCondCtrl.LinearModel(i).C(:,:,ocIdx)));
	operCondLeg.LinearModel(i).D = ...
		double(squeeze(operCondCtrl.LinearModel(i).D(:,:,ocIdx)));
end

end