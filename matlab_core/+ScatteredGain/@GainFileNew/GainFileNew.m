classdef GainFileNew < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Data Storage
    properties  
        Name char
        ScatteredGainCollection ScatteredGain.GainCollectionNew = ScatteredGain.GainCollectionNew.empty
        Date
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)

        
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)
 
    end % Dependant properties
    
    
    %% Methods - Constructor
    methods   
        
        function obj = GainFileNew( varargin )
            
            
            if nargin == 0
                obj.ScatteredGainCollection = ScatteredGain.GainCollectionNew; % Nathan added
                return; 
            end  
            p = inputParser;
            addParameter(p,'Name','');
            addParameter(p,'ScatteredGain',ScatteredGain.GainCollectionNew.empty);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Name = options.Name;
            obj.ScatteredGainCollection = options.ScatteredGain;
            obj.Date = datestr(now);
            
            
        end % GainFile
        
    end % Constructor


    %% Methods - Callbacks
    methods 
 
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function gainAdded = addGain( obj , scattGain )  
            gainAdded = false;

            if isempty(obj.ScatteredGainCollection)
                idx = 1;
                obj.ScatteredGainCollection = ScatteredGain.GainCollectionNew;
                obj.ScatteredGainCollection.NumGainCols = 1;
                obj.ScatteredGainCollection.DesignOperatingCondition = lacm.OperatingConditionCtrl;
                obj.ScatteredGainCollection.DesignOperatingCondition.addOperCond(scattGain.DesignOperatingCondition);
                obj.ScatteredGainCollection.Color = zeros(1,3);
                obj.ScatteredGainCollection.Date = [""];
                obj.ScatteredGainCollection.Selected = true(1,1);
                %obj.ScatteredGainCollection.Gain = ScatteredGain.Gain;
                %obj.ScatteredGainCollection.SynthesisDesignParameter = ScatteredGain.Parameter;
                %obj.ScatteredGainCollection.RequirementDesignParameter = ScatteredGain.Parameter;
                %obj.ScatteredGainCollection.Filters = UserInterface.ControlDesign.Filter;
                %obj.ScatteredGainCollection.OperCondFilterSettings = UserInterface.ControlDesign.OperCondFilterSettings;
            else
                idx = obj.gainExistsCheck(scattGain);
                if idx == 0
                    obj.ScatteredGainCollection.NumGainCols = obj.ScatteredGainCollection.NumGainCols + 1;
                    idx = obj.ScatteredGainCollection.NumGainCols;
                    obj.ScatteredGainCollection.DesignOperatingCondition.addOperCond(scattGain.DesignOperatingCondition);
                end
            end

            %obj.ScatteredGainCollection.DesignOperatingCondition.addOperCond(scattGain.DesignOperatingCondition);
            %obj.ScatteredGainCollection.Color(idx, :) = scattGain.Color;

            for i = 1:length(scattGain.Gain)
                obj.ScatteredGainCollection.addGain(scattGain.Gain(i), idx);
            end
            for i = 1:length(scattGain.SynthesisDesignParameter)
                obj.ScatteredGainCollection.addSynthesisDesignParameter(scattGain.SynthesisDesignParameter(i), idx);
            end
            for i = 1:length(scattGain.RequirementDesignParameter)
                obj.ScatteredGainCollection.addRequirementDesignParameter(scattGain.RequirementDesignParameter(i), idx);
            end
            if ~isempty(scattGain.Filters)
%                 numFilts = length(scattGain.Filters);
%                 if length(obj.ScatteredGainCollection.Filters) < numFilts
%                     for i = (length(obj.ScatteredGainCollection.Filters) + 1):numFilts
%                         for j = 1:(idx-1)
%                             obj.ScatteredGainCollection.Filters{j}(i) = copy(scattGain.Filters(i));
%                             obj.ScatteredGainCollection.Filters{j}(i).setFilterValuesNan();
%                         end
%                     end
%                 end
                obj.ScatteredGainCollection.Filters{idx} = copy(scattGain.Filters);
            end
            obj.ScatteredGainCollection.OperCondFilterSettings(idx) = copy(scattGain.OperCondFilterSettings);

            %obj.ScatteredGainCollection.Color(idx, :) = scattGain.Color;
            obj.ScatteredGainCollection.Date(idx) = scattGain.Date;
            obj.ScatteredGainCollection.Selected(idx) = true;

            gainAdded = true;

        end % addGain

        function scattGain = getGains( obj, idx )
            scattGain = ScatteredGain.GainCollectionNew;
            if isempty(obj.ScatteredGainCollection)
                return;
            end
            scattGain.NumGainCols = length(idx);
            scattGain.DesignOperatingCondition = lacm.OperatingConditionCtrl;
            for i = 1:length(idx)
                operCond = Utilities.operCondCtrlToLeg(obj.ScatteredGainCollection.DesignOperatingCondition, idx(i));
                scattGain.DesignOperatingCondition.addOperCond(operCond);
                scattGain.Color(i,:) = obj.ScatteredGainCollection.Color(idx(i),:);
                scattGain.Date(i) = obj.ScatteredGainCollection.Date(idx(i));
                scattGain.Selected(i) = obj.ScatteredGainCollection.Selected(idx(i));
                if ~isempty(obj.ScatteredGainCollection.Filters)
                    scattGain.Filters{i} = copy(obj.ScatteredGainCollection.Filters{idx(i)});
                end
                scattGain.OperCondFilterSettings(i) = copy(obj.ScatteredGainCollection.OperCondFilterSettings(idx(i)));
                for j = 1:length(obj.ScatteredGainCollection.Gain)
                    gain = ScatteredGain.Gain;
                    gain.Name = obj.ScatteredGainCollection.Gain(j).Name;
                    gain.Expression = obj.ScatteredGainCollection.Gain(j).Expression;
                    gain.Value = obj.ScatteredGainCollection.Gain(j).Value(idx(i));
                    scattGain.addGain(gain, i);
                end
                for j = 1:length(obj.ScatteredGainCollection.SynthesisDesignParameter)
                    synth = ScatteredGain.Parameter;
                    synth.Name = obj.ScatteredGainCollection.SynthesisDesignParameter(j).Name;
                    synth.Value = obj.ScatteredGainCollection.SynthesisDesignParameter(j).Value(idx(i));
                    synth.ValueString = obj.ScatteredGainCollection.SynthesisDesignParameter(j).ValueString(idx(i));
                    scattGain.addSynthesisDesignParameter(synth, i);
                end
                for j = 1:length(obj.ScatteredGainCollection.RequirementDesignParameter)
                    req = ScatteredGain.Parameter;
                    req.Name = obj.ScatteredGainCollection.RequirementDesignParameter(j).Name;
                    req.Value = obj.ScatteredGainCollection.RequirementDesignParameter(j).Value(idx(i));
                    req.ValueString = obj.ScatteredGainCollection.RequirementDesignParameter(j).ValueString(idx(i));
                    scattGain.addRequirementDesignParameter(req, i);
                end
            end
        end

        function gainIdx = gainExistsCheck( obj, scattGain )
            operCond1 = obj.ScatteredGainCollection.DesignOperatingCondition;
            operCond2 = scattGain.DesignOperatingCondition;

            %numGains1 = length(obj.ScatteredGainCollection.Gain);
            %numGains2 = length(scattGain.Gain);
            %if numGains1 ~= numGains2
            %    return;
            %end
            %numSynth1 = length(obj.ScatteredGainCollection.SynthesisDesignParameter);
            %numSynth2 = length(scattGain.SynthesisDesignParameter);
            %if numSynth1 ~= numSynth2
            %    return;
            %end
            %numReqs1 = length(obj.ScatteredGainCollection.RequirementDesignParameter);
            %numReqs2 = length(scattGain.RequirementDesignParameter);
            %if numReqs1 ~= numReqs2
            %    return;
            %end

            for i = 1:obj.ScatteredGainCollection.NumGainCols
                gainExists = true;
                %for j = 1:numGains1
                %    if ~strcmp(obj.ScatteredGainCollection.Gain(j).Name, scattGain.Gain(j).Name);
                %        return;
                %    end
                %    if obj.ScatteredGainCollection.Gain(j).Value(i) ~= single(scattGain.Gain(j).Value);
                %        return;
                %    end
                %end
                %for j = 1:numSynth1
                %    if ~strcmp(obj.ScatteredGainCollection.SynthesisDesignParameter(j).Name, scattGain.SynthesisDesignParameter(j).Name);
                %        return;
                %    end
                %    if obj.ScatteredGainCollection.SynthesisDesignParameter(j).Value(i) ~= single(scattGain.SynthesisDesignParameter(j).Value);
                %        return;
                %    end
                %end
                %for j = 1:numReqs1
                %    if ~strcmp(obj.ScatteredGainCollection.RequirementDesignParameter(j).Name, scattGain.RequirementDesignParameter(j).Name);
                %        return;
                %    end
                %    if obj.ScatteredGainCollection.RequirementDesignParameter(j).Value(i) ~= single(scattGain.RequirementDesignParameter(j).Value);
                %        return;
                %    end
                %end
                for j = 1:length(operCond1.States)
                    if operCond1.States(j).Value(i) ~= single(operCond2.States(j).Value)
                        gainExists = false;
                    end
                end
                for j = 1:length(operCond1.Inputs)
                    if operCond1.Inputs(j).Value(i) ~= single(operCond2.Inputs(j).Value)
                        gainExists = false;
                    end
                end
                for j = 1:length(operCond1.Outputs)
                    if operCond1.Outputs(j).Value(i) ~= single(operCond2.Outputs(j).Value)
                        gainExists = false;
                    end
                end
                for j = 1:length(operCond1.StateDerivs)
                    if operCond1.StateDerivs(j).Value(i) ~= single(operCond2.StateDerivs(j).Value)
                        gainExists = false;
                    end
                end
                for j = 1:length(operCond1.MassProperties.Parameter)
                    if operCond1.MassProperties.Parameter(j).Value(i) ~= single(operCond2.MassProperties.Parameter(j).Value)
                        gainExists = false;
                    end
                end
                for j = 1:length(operCond1.LinearModel)
                    if ~isequal(squeeze(operCond1.LinearModel(j).A(:,:,i)), single(operCond2.LinearModel(j).A))
                        gainExists = false;
                    end
                    if ~isequal(squeeze(operCond1.LinearModel(j).B(:,:,i)), single(operCond2.LinearModel(j).B))
                        gainExists = false;
                    end
                    if ~isequal(squeeze(operCond1.LinearModel(j).C(:,:,i)), single(operCond2.LinearModel(j).C))
                        gainExists = false;
                    end
                    if ~isequal(squeeze(operCond1.LinearModel(j).D(:,:,i)), single(operCond2.LinearModel(j).D))
                        gainExists = false;
                    end
                end
                if ~(operCond1.FlightCondition(i) == operCond2.FlightCondition)
                    gainExists = false;
                end
                if gainExists
                    gainIdx = i;
                    return;
                end
            end
            gainIdx = 0;
            return;
            %gainIdx = true;
        end

        function uisave( obj ) %#ok<MANU>
            builtin('uisave','obj','ScatteredGainFile') %call builtin
        end % uisave
        
        function y = eq(A,B)
            if isempty(A) || isempty(B)
                y = false;
            elseif length(A) == length(B)
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                for i = 1:length(B)
                    if A.DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end   
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B.DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end     
            end
        end % eq
        
        function exportGains(obj, filename)
            j=1;
            varnames = {};
            for i = 1:length(obj.ScatteredGainCollection(j).Gain)
                eval([obj.ScatteredGainCollection(j).Gain(i).Name,' = obj.ScatteredGainCollection(j).Gain(i).Value;']);
                varnames{i} = ['''',obj.ScatteredGainCollection(j).Gain(i).Name,'''']; %#ok<AGROW>
            end
            if ~isempty(varnames)
                varnameStr = ['{',strjoin(varnames,','),'}'];

                eval(['matlab.io.saveVariablesToScript(filename,',varnameStr,');']);
            end
        end % end
        
    end % Ordinary Methods    
       
    %% Methods - Protected
    methods (Access = protected)     
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the ScatteredGainCollection object
            cpObj.ScatteredGainCollection = copy(obj.ScatteredGainCollection); 
        end % copyElement
        
    end
    
    %% Methods - Private
    methods ( Access = private )
        

        
    end
    
    %% Methods - Static
    methods (Static)

    end
    
    
end