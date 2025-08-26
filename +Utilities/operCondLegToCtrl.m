function [operCondCtrl] = operCondLegToCtrl(operCondLeg)

%% Setup
operCondCtrl = lacm.OperatingConditionCtrl;
numConds = length(operCondLeg);
operCondCtrl.NumConds = numConds;
operCondTemplate = operCondLeg(1);

perCondCtrl.Label = string(zeros(numConds,1));
operCondCtrl.ModelName = string(zeros(numConds,1));
operCondCtrl.SuccessfulTrim = false(numConds,1);
operCondCtrl.Cost = single(zeros(numConds,1));
operCondCtrl.SelectedforAnalysis = false(numConds,1);
operCondCtrl.SelectedforDesign = false(numConds,1);
operCondCtrl.HasSavedGain = false(numConds,1);
operCondCtrl.Color = zeros(numConds, 3);

%% Common
for i = 1:numConds
	operCondCtrl.Label(i) = string(operCondLeg(i).Label);
	operCondCtrl.ModelName(i) = string(operCondLeg(i).ModelName);
	operCondCtrl.SuccessfulTrim(i) = logical(operCondLeg(i).SuccessfulTrim);
	operCondCtrl.Cost(i) = single(operCondLeg(i).Cost);
	operCondCtrl.SelectedforAnalysis(i) = logical(operCondLeg(i).SelectedforAnalysis);
	operCondCtrl.SelectedforDesign(i) = logical(operCondLeg(i).SelectedforDesign);
	%operCondCtrl.IncorrectTrimText(i) = string(operCondLeg(i).IncorrectTrimText);
end

%% States
numStates = length(operCondTemplate.States);

operCondCtrl.States(numStates) = lacm.ConditionCtrl;
for s = 1:numStates
	operCondCtrl.States(s).Name = operCondTemplate.States(s).Name;
	operCondCtrl.States(s).Units = operCondTemplate.States(s).Units;
	operCondCtrl.States(s).Fix = operCondTemplate.States(s).Fix;
	operCondCtrl.States(s).BasicMode = operCondTemplate.States(s).BasicMode;
	operCondCtrl.States(s).Constrained = operCondTemplate.States(s).Constrained;

	operCondCtrl.States(s).Value = zeros(numConds,1);
	for c = 1:numConds
		operCondCtrl.States(s).Value(c) = operCondLeg(c).States(s).Value;
	end
end

% operCondCtrl.StateVals = single(zeros(numConds, numStates));
% for i = 1:numConds
% 	for j = 1:numStates
% 		operCondCtrl.StateVals(i,j) = single(operCondLeg(i).States(j).Value);
% 	end
% end

%% Inputs
numInputs = length(operCondTemplate.Inputs);

operCondCtrl.Inputs(numInputs) = lacm.ConditionCtrl;
for i = 1:numInputs
	operCondCtrl.Inputs(i).Name = operCondTemplate.Inputs(i).Name;
	operCondCtrl.Inputs(i).Units = operCondTemplate.Inputs(i).Units;
	operCondCtrl.Inputs(i).Fix = operCondTemplate.Inputs(i).Fix;
	operCondCtrl.Inputs(i).BasicMode = operCondTemplate.Inputs(i).BasicMode;
	operCondCtrl.Inputs(i).Constrained = operCondTemplate.Inputs(i).Constrained;

	operCondCtrl.Inputs(i).Value = zeros(numConds,1);
	for c = 1:numConds
		operCondCtrl.Inputs(i).Value(c) = operCondLeg(c).Inputs(i).Value;
	end
end

%operCondCtrl.Inputs(numInputs) = operCondTemplate.Inputs(numInputs);
%for i = 1:(numInputs-1)
%	operCondCtrl.Inputs(i) = operCondTemplate.Inputs(i);
%end
%
%operCondCtrl.InputVals = single(zeros(numConds, numInputs));
%for i = 1:numConds
%	for j = 1:numInputs
%		operCondCtrl.InputVals(i,j) = single(operCondLeg(i).Inputs(j).Value);
%	end
%end

%% Outputs
numOutputs = length(operCondTemplate.Outputs);

operCondCtrl.Outputs(numOutputs) = lacm.ConditionCtrl;
for o = 1:numOutputs
	operCondCtrl.Outputs(o).Name = operCondTemplate.Outputs(o).Name;
	operCondCtrl.Outputs(o).Units = operCondTemplate.Outputs(o).Units;
	operCondCtrl.Outputs(o).Fix = operCondTemplate.Outputs(o).Fix;
	operCondCtrl.Outputs(o).BasicMode = operCondTemplate.Outputs(o).BasicMode;
	operCondCtrl.Outputs(o).Constrained = operCondTemplate.Outputs(o).Constrained;

	operCondCtrl.Outputs(o).Value = zeros(numConds,1);
	for c = 1:numConds
		operCondCtrl.Outputs(o).Value(c) = operCondLeg(c).Outputs(o).Value;
	end
end

%operCondCtrl.Outputs(numOutputs) = operCondTemplate.Outputs(numOutputs);
%for i = 1:(numOutputs-1)
%	operCondCtrl.Outputs(i) = operCondTemplate.Outputs(i);
%end
%
%operCondCtrl.Outputs = single(zeros(numConds, numOutputs));
%for i = 1:numConds
%	for j = 1:numOutputs
%		operCondCtrl.OutputVals(i,j) = single(operCondLeg(i).Outputs(j).Value);
%	end
%end

%% State Derivs
numStateDerivs = length(operCondTemplate.StateDerivs);

operCondCtrl.StateDerivs(numStateDerivs) = lacm.ConditionCtrl;
for s = 1:numStateDerivs
	operCondCtrl.StateDerivs(s).Name = operCondTemplate.StateDerivs(s).Name;
	operCondCtrl.StateDerivs(s).Units = operCondTemplate.StateDerivs(s).Units;
	operCondCtrl.StateDerivs(s).Fix = operCondTemplate.StateDerivs(s).Fix;
	operCondCtrl.StateDerivs(s).BasicMode = operCondTemplate.StateDerivs(s).BasicMode;
	operCondCtrl.StateDerivs(s).Constrained = operCondTemplate.StateDerivs(s).Constrained;

	operCondCtrl.StateDerivs(s).Value = zeros(numConds,1);
	for c = 1:numConds
		operCondCtrl.StateDerivs(s).Value(c) = operCondLeg(c).StateDerivs(s).Value;
	end
end

%operCondCtrl.StateDerivs(numStateDerivs) = ...
%	operCondTemplate.StateDerivs(numStateDerivs);
%for i = 1:(numStateDerivs-1)
%	operCondCtrl.StateDerivs(i) = operCondTemplate.StateDerivs(i);
%end
%
%operCondCtrl.StateDerivVals = single(zeros(numConds, numStateDerivs));
%for i = 1:numConds
%	for j = 1:numStateDerivs
%		operCondCtrl.StateDerivVals(i,j) = operCondLeg(i).StateDerivs(j).Value;
%	end
%end

%% Flight Conditions
operCondCtrl.FlightCondition(numConds) = operCondLeg(numConds).FlightCondition;
for i = 1:(numConds-1)
	operCondCtrl.FlightCondition(i) = operCondLeg(i).FlightCondition;
end

%% MassProperties
numMassProps = length(operCondTemplate.MassProperties.Parameter);

operCondCtrl.MassProperties = lacm.MassPropertiesCtrl;
operCondCtrl.MassProperties.Parameter(numMassProps) = lacm.ConditionCtrl;
for m = 1:numMassProps
	operCondCtrl.MassProperties.Parameter(m).Name = ...
		operCondTemplate.MassProperties.Parameter(m).Name;
	operCondCtrl.MassProperties.Parameter(m).Units = ...
		operCondTemplate.MassProperties.Parameter(m).Units;
	operCondCtrl.MassProperties.Parameter(m).Fix = ...
		operCondTemplate.MassProperties.Parameter(m).Fix;
	operCondCtrl.MassProperties.Parameter(m).BasicMode = ...
		operCondTemplate.MassProperties.Parameter(m).BasicMode;
	operCondCtrl.MassProperties.Parameter(m).Constrained = ...
		operCondTemplate.MassProperties.Parameter(m).Constrained;

	operCondCtrl.MassProperties.Parameter(m).Value = zeros(numConds,1);
	for c = 1:numConds
		operCondCtrl.MassProperties.WeightCode(c) = operCondLeg(c).MassProperties.WeightCode; % redundant, fix later
		operCondCtrl.MassProperties.Label(c) = operCondLeg(c).MassProperties.Label; % redundant, fix later
		operCondCtrl.MassProperties.Parameter(m).Value(c) = ...
			operCondLeg(c).MassProperties.Parameter(m).Value;
	end
end

%operCondCtrl.MassProperties = lacm.MassPropertiesCtrl;
%operCondCtrl.MassProperties.Parameter(numMassProps) = ...
%	operCondTemplate.MassProperties.Parameter(numMassProps);
%for i = 1:(numMassProps-1)
%	operCondCtrl.MassProperties.Parameter(i) = ...
%		operCondTemplate.MassProperties.Parameter(i);
%end
%
%operCondCtrl.MassProperties.ParameterVals = ...
%	single(zeros(numConds, numMassProps));
%for i = 1:numConds
%	operCondCtrl.MassProperties.WeightCode(i) = ...
%		operCondLeg(i).MassProperties.WeightCode;
%	operCondCtrl.MassProperties.Label(i) = ...
%		operCondLeg(i).MassProperties.Label;
%	for j = 1:numMassProps
%		operCondCtrl.MassProperties.ParameterVals(i,j) = ...
%			single(operCondLeg(i).MassProperties.Parameter(j).Value);
%	end
%end

%% Linear Model
numLinearModels = length(operCondTemplate.LinearModel);

operCondCtrl.LinearModel(numLinearModels) = lacm.LinearModel;
for i = 1:numLinearModels
	operCondCtrl.LinearModel(i) = lacm.LinearModel;

	operCondCtrl.LinearModel(i).Label = ...
		operCondTemplate.LinearModel(i).Label;
	operCondCtrl.LinearModel(i).States = ...
		operCondTemplate.LinearModel(i).States;
	operCondCtrl.LinearModel(i).Inputs = ...
		operCondTemplate.LinearModel(i).Inputs;
	operCondCtrl.LinearModel(i).Outputs = ...
		operCondTemplate.LinearModel(i).Outputs;
	operCondCtrl.LinearModel(i).AlgebraicInput = ...
		operCondTemplate.LinearModel(i).AlgebraicInput;
	operCondCtrl.LinearModel(i).AlgebraicOutput = ...
		operCondTemplate.LinearModel(i).AlgebraicOutput;
	operCondCtrl.LinearModel(i).InputConstraintsArray = ...
		operCondTemplate.LinearModel(i).InputConstraintsArray;
	operCondCtrl.LinearModel(i).InputConstraintsInfo = ...
		operCondTemplate.LinearModel(i).InputConstraintsInfo;

	Am = size(operCondTemplate.LinearModel(i).A, 1);
	An = size(operCondTemplate.LinearModel(i).A, 2);
	Bm = size(operCondTemplate.LinearModel(i).B, 1);
	Bn = size(operCondTemplate.LinearModel(i).B, 2);
	Cm = size(operCondTemplate.LinearModel(i).C, 1);
	Cn = size(operCondTemplate.LinearModel(i).C, 2);
	Dm = size(operCondTemplate.LinearModel(i).D, 1);
	Dn = size(operCondTemplate.LinearModel(i).D, 2);

	operCondCtrl.LinearModel(i).A = zeros(Am, An, numConds);
	operCondCtrl.LinearModel(i).B = zeros(Bm, Bn, numConds);
	operCondCtrl.LinearModel(i).C = zeros(Cm, Cn, numConds);
	operCondCtrl.LinearModel(i).D = zeros(Dm, Dn, numConds);

	for j = 1:numConds
		operCondCtrl.LinearModel(i).A(:,:,j) = ...
			operCondLeg(j).LinearModel(i).A;

		operCondCtrl.LinearModel(i).B(:,:,j) = ...
			operCondLeg(j).LinearModel(i).B;

		operCondCtrl.LinearModel(i).C(:,:,j) = ...
			operCondLeg(j).LinearModel(i).C;

		operCondCtrl.LinearModel(i).D(:,:,j) = ...
			operCondLeg(j).LinearModel(i).D;

	end
end

%% Trim Settings, not currently needed


end