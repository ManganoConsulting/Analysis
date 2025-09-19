function isEqual = operCondCompare(operCond1,operCond2)

% Single point conversion on values is necessary because of initial single
% point implementation that was backed out. This is temporary and should
% only support the test projects

% Ensure both conditions have the same label
if ~strcmp(operCond1.Label, operCond2.Label)
    isEqual = false;
    return;
end

% Ensure both conditions have the same model
if ~strcmp(operCond1.ModelName, operCond2.ModelName)
    isEqual = false;
    return;
end

% Ensure the values of all the inputs are the same
if ~all(single([operCond1.Inputs.Value]) == single([operCond2.Inputs.Value]))
    isEqual = false;
    return;
end

% Ensure the values of all the outputs are the same
if ~all(single([operCond1.Outputs.Value]) == single([operCond2.Outputs.Value]))
    isEqual = false;
    return;
end

% Ensure the values of all the states are the same
if ~all(single([operCond1.States.Value]) == single([operCond2.States.Value]))
    isEqual = false;
    return;
end

% Ensure the values of all the state derivatives are the same
if ~all(single([operCond1.StateDerivs.Value]) == single([operCond2.StateDerivs.Value]))
    isEqual = false;
    return;
end

% Ensure that the flight conditions are the same
if ~(operCond1.FlightCondition == operCond2.FlightCondition)
    isEqual = false;
    return;
end

% Ensure that the weight codes are the same
if ~strcmp(operCond1.MassProperties.WeightCode, operCond2.MassProperties.WeightCode)
    isEqual = false;
    return;
end

% Ensure that the mass properties labels are the same
if ~strcmp(operCond1.MassProperties.Label, operCond2.MassProperties.Label)
    isEqual = false;
    return;
end

% Ensure that the mass properties values are the same
if ~all(single([operCond1.MassProperties.Parameter.Value]) == single([operCond2.MassProperties.Parameter.Value]))
    isEqual = false;
    return;
end

isEqual = true;

end

