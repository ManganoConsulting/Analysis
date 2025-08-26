function [operCondCtrl] = convertOperCond(operCond)

%% Setup
operCondCtrl = lacm.OperatingConditionCtrl;
numConds = length(operCond);
operCondTemplate = operCond(1);

%% Miscellanious
for i = 1:numConds
	operCondCtrl.Label(i) = string(operCond(i).Label);
	operCondCtrl.ModelName(i) = string(operCond(i).ModelName);
	operCondCtrl.SuccessfulTrim(i) = single(operCond(i).SuccessfulTrim);
	operCondCtrl.Cost(i) = single(operCond(i).Cost);
	%operCondCtrl.IncorrectTrimText(i) = string(operCond(i).IncorrectTrimText);
end

%% States
numStates = length(operCondTemplate.States);

operCondCtrl.States(numStates) = operCondTemplate.States(numStates);
for i = 1:(numStates-1)
	operCondCtrl.States(i) = operCondTemplate.States(i);
end

operCondCtrl.StateVals = single(zeros(numConds, numStates));
for i = 1:numConds
	for j = 1:numStates
		operCondCtrl.StateVals(i,j) = single(operCond(i).States(j).Value);
	end
end

%% Inputs
numInputs = length(operCondTemplate.Inputs);

operCondCtrl.Inputs(numInputs) = operCondTemplate.Inputs(numInputs);
for i = 1:(numInputs-1)
	operCondCtrl.Inputs(i) = operCondTemplate.Inputs(i);
end

operCondCtrl.InputVals = single(zeros(numConds, numInputs));
for i = 1:numConds
	for j = 1:numInputs
		operCondCtrl.InputVals(i,j) = single(operCond(i).Inputs(j).Value);
	end
end

%% Outputs
numOutputs = length(operCondTemplate.Outputs);

operCondCtrl.Outputs(numOutputs) = operCondTemplate.Outputs(numOutputs);
for i = 1:(numOutputs-1)
	operCondCtrl.Outputs(i) = operCondTemplate.Outputs(i);
end

operCondCtrl.Outputs = single(zeros(numConds, numOutputs));
for i = 1:numConds
	for j = 1:numOutputs
		operCondCtrl.OutputVals(i,j) = single(operCond(i).Outputs(j).Value);
	end
end

%% State Derivs
numStateDerivs = length(operCondTemplate.StateDerivs);

operCondCtrl.StateDerivs(numStateDerivs) = ...
	operCondTemplate.StateDerivs(numStateDerivs);
for i = 1:(numStateDerivs-1)
	operCondCtrl.StateDerivs(i) = operCondTemplate.StateDerivs(i);
end

operCondCtrl.StateDerivVals = single(zeros(numConds, numStateDerivs));
for i = 1:numConds
	for j = 1:numStateDerivs
		operCondCtrl.StateDerivVals(i,j) = operCond(i).StateDerivs(j).Value;
	end
end

%% Flight Conditions
operCondCtrl.FlightCondition(numConds) = operCond(numConds).FlightCondition;
for i = 1:(numConds-1)
	operCondCtrl.FlightCondition(i) = operCond(i).FlightCondition;
end

%% MassProperties
numMassProps = length(operCondTemplate.MassProperties.Parameter);

operCondCtrl.MassProperties = lacm.MassPropertiesCtrl;
operCondCtrl.MassProperties.Parameter(numMassProps) = ...
	operCondTemplate.MassProperties.Parameter(numMassProps);
for i = 1:(numMassProps-1)
	operCondCtrl.MassProperties.Parameter(i) = ...
		operCondTemplate.MassProperties.Parameter(i);
end

operCondCtrl.MassProperties.ParameterVals = ...
	single(zeros(numConds, numMassProps));
for i = 1:numConds
	for j = 1:numMassProps
		operCondCtrl.MassProperties.ParameterVals(i,j) = ...
			single(operCond(i).MassProperties.Parameter(j).Value);
	end
end

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

	operCondCtrl.LinearModel(i).A = single(zeros(Am, An, numConds));
	operCondCtrl.LinearModel(i).B = single(zeros(Bm, Bn, numConds));
	operCondCtrl.LinearModel(i).C = single(zeros(Cm, Cn, numConds));
	operCondCtrl.LinearModel(i).D = single(zeros(Dm, Dn, numConds));

	for j = 1:numConds
		operCondCtrl.LinearModel(i).A(:,:,j) = ...
			single(operCond(j).LinearModel(i).A);

		operCondCtrl.LinearModel(i).B(:,:,j) = ...
			single(operCond(j).LinearModel(i).B);

		operCondCtrl.LinearModel(i).C(:,:,j) = ...
			single(operCond(j).LinearModel(i).C);

		operCondCtrl.LinearModel(i).D(:,:,j) = ...
			single(operCond(j).LinearModel(i).D);

	end
end

%% Trim Settings, not currently needed


end