classdef OperatingCondition < matlab.mixin.Copyable%< matlab.mixin.CustomDisplay
    
    %% Public properties - Data Storage
    properties  
        Label
        ModelName
        States lacm.Condition
        Inputs lacm.Condition
        Outputs lacm.Condition
        StateDerivs lacm.Condition
        FlightCondition lacm.FlightCondition
        MassProperties lacm.MassProperties   
        LinearModel lacm.LinearModel 
        TrimSettings lacm.TrimSettings 
        SignalLogData lacm.Condition
        SaveFormat
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        SuccessfulTrim
        Cost
        IncorrectTrimText = 'Succesful Trim';
    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        Color double
        SelectedforAnalysis logical = false
        SelectedforDesign logical = false
        % For Scattered Gain soure
        HasSavedGain = false
        
    end % Hidden properties
    
    %% Hidden properties - Object Handles
    properties (Transient = true , Hidden = true)
        FlightDynLineH
    end % Hidden properties
    
    %% Dependant properties SetAccess = private
    properties ( Dependent = true, SetAccess = private , Hidden = true )
        NormalizedColor
        %ModelName
    end % Dependant properties
    
    %% View Properties
    % Object Handles Tansient Properties
    properties( Hidden = true , Transient = true )
        RunViewParent
        Run_pb
    end

    % Data Storage Properties
    properties( Hidden = true )
        FC1_PM_String = {'KCAS','Alt','Mach','Qbar','KTAS','KEAS'};
        FC1_PM_SelValue = 1
        FC2_PM_String = {'KCAS','Alt','Mach','Qbar','KTAS','KEAS'};
        FC2_PM_SelValue = 1
        
        FC1_EB_String
        FC2_EB_String
        
        WC_PM_String
        WC_PM_SelValue
        SetName_String
        TargetVar_String
        TargetValue_String
    end 
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods   
        
        function obj = OperatingCondition(varargin)
            if nargin == 0
                
            elseif nargin == 1 && isa(varargin{1},'lacm.TrimTask')  
                Utilities.multiWaitbar( 'Running Trims...', 0 , 'Color', 'b'); 
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Running Trims...','info'));
                
                % Get default trim options
                TrimOptions = UserInterface.StabilityControl.TrimOptions(false);
                
                taskObj = varargin{1};
                numOfTrims = length(taskObj);                         
                obj(numOfTrims) = lacm.OperatingCondition; % Initialize 
                for i = 1:numOfTrims
                    obj(i).Label = taskObj(i).Label;
                    run( obj(i) , taskObj(i), TrimOptions);
                    Utilities.multiWaitbar( 'Running Trims...', i/numOfTrims , 'Color', 'b'); 
                    %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Running Trim ',int2str(i),' of ',int2str(numOfTrims),'info'));
                end
%                 releaseModel(obj);  
                
                Utilities.multiWaitbar( 'Running Trims...', 'close'); 
                
            elseif nargin == 2 && isa(varargin{1},'lacm.TrimTask')  
                Utilities.multiWaitbar( 'Running Trims...', 0 , 'Color', 'b'); 
                %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Running Trims...','info'));
                taskObj = varargin{1};
                numOfTrims = length(taskObj);
                
                % Get user defined trim options
                TrimOptions = varargin{2};
                
                obj(numOfTrims) = lacm.OperatingCondition; % Initialize 
                for i = 1:numOfTrims
                    obj(i).Label = taskObj(i).Label;
                    run( obj(i) , taskObj(i), TrimOptions);
                    Utilities.multiWaitbar( 'Running Trims...', i/numOfTrims , 'Color', 'b'); 
                    %notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Running Trim ',int2str(i),' of ',int2str(numOfTrims),'info'));
                end
%                 releaseModel(obj);  
                
                Utilities.multiWaitbar( 'Running Trims...', 'close'); 
     
            else
                error('Incorrect number of input arguments');
            end
            
        end % OperatingCondition
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function y = get.SelectedforAnalysis(obj)
%             if obj.SelectedforDesign % Always make the design condition part of the anaysis conditions
%                y = true;
%             else
                y = obj.SelectedforAnalysis;
%             end
        end % SelectedforAnalysis
        
        function y = get.NormalizedColor(obj)
            y = obj.Color/255;
        end % NormalizedColor
        
    end % Property access methods

    %% Methods - Callbacks
    methods 
        
        function run_CB( obj , ~ , ~ )
            update(obj);
        end % fc1_CB  
        
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function [y,names] = getDisplayData(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = [{obj.Inputs.Name}';{obj.Outputs.Name}'];
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{2};end;
            if strcmp(fc2,'All');fc2 = fcFnames{3};end;
            if strcmp(ic,'All');ic = icFnames{1};end;
            if strcmp(wc,'All');wc = wcFnames{2};end;

            if ~isempty(obj.Inputs.get(ic))
                y = {num2str(obj.FlightCondition.(fc1),4),...%{sprintf('%.0f 1 ',obj.FlightCondition.(fc1),4),...%
                    num2str(obj.FlightCondition.(fc2),4),...
                    num2str(obj.Inputs.get(ic).Value,4),...
                    obj.MassProperties.get(wc)};
            else
                y = {num2str(obj.FlightCondition.(fc1),4),...%{sprintf('%.0f 1 ',obj.FlightCondition.(fc1),4),...%
                    num2str(obj.FlightCondition.(fc2),4),...
                    num2str(obj.Outputs.get(ic).Value,4),...
                    obj.MassProperties.get(wc)};
            end
            names = {fc1,fc2,ic,wc};
        end % getDisplayText
        
        function y = getDisplayText(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = {obj.Inputs.Name}';
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{1};end
            if strcmp(fc2,'All');fc2 = fcFnames{2};end
            if strcmp(ic,'All');ic = icFnames{1};end
            if strcmp(wc,'All');wc = wcFnames{2};end
            
            if obj.SelectedforDesign
                y = ['<html><font color="rgb(0,0,255)">',fc1,'=',num2str(obj.FlightCondition.(fc1),4),' ',...
                                            fc2,'=',num2str(obj.FlightCondition.(fc2),4),' ',...
                                            ic,'=',num2str(obj.Inputs.get(ic).Value,4),' ',...
                                            wc,'=',obj.MassProperties.(wc),'</font></html>'];    
            else
                y = ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',fc1,'=',num2str(obj.FlightCondition.(fc1),4),' ',...
                                            fc2,'=',num2str(obj.FlightCondition.(fc2),4),' ',...
                                            ic,'=',num2str(obj.Inputs.get(ic).Value,4),' ',...
                                            wc,'=',obj.MassProperties.(wc),'</font></html>']; 
            end
        end % getDisplayText
        
        function y = getSelectedDisplayText(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = {obj.Inputs.Name}';
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{1};end
            if strcmp(fc2,'All');fc2 = fcFnames{2};end
            if strcmp(ic,'All');ic = icFnames{1};end
            if strcmp(wc,'All');wc = wcFnames{2};end
            
            icParamIN = obj.Inputs.get(ic);
            if isempty(icParamIN)
                icParamOUT = obj.Outputs.get(ic);
                if isempty(icParamOUT)
                    icVal = 9999;
                else
                    icVal = icParamOUT.Value;
                end
            else
                icVal = icParamIN.Value;
            end
            
            
            if strcmp(wc,'WeightCode') || strcmp(wc,'Label')
                y = ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',fc1,'=',num2str(obj.FlightCondition.(fc1),4),' ',...
                                        fc2,'=',num2str(obj.FlightCondition.(fc2),4),' ',...
                                        ic,'=',num2str(icVal,4),' ',...
                                        wc,'=',obj.MassProperties.(wc),'</font></html>']; 
            else
                y = ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',fc1,'=',num2str(obj.FlightCondition.(fc1),4),' ',...
                                        fc2,'=',num2str(obj.FlightCondition.(fc2),4),' ',...
                                        ic,'=',num2str(icVal,4),' ',...
                                        wc,'=',num2str(obj.MassProperties.get(wc)),'</font></html>'];
            end
                
        end % getSelectedDisplayText
        
        function y = getUnformattedDisplayText(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = {obj.Inputs.Name}';
            ocFnames = {obj.Outputs.Name}';
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{1};end
            if strcmp(fc2,'All');fc2 = fcFnames{2};end
            if strcmp(ic,'All');ic = icFnames{1};end
            if strcmp(wc,'All');wc = wcFnames{2};end
            
            if ~isempty(obj.Inputs.get(ic))
                icvalstr = num2str(obj.Inputs.get(ic).Value,4);
            else
                icvalstr = num2str(obj.Outputs.get(ic).Value,4);
            end
            
            if strcmp(wc,'WeightCode') || strcmp(wc,'Label')
                

                
                y = { num2str(obj.FlightCondition.(fc1),4),...
                      num2str(obj.FlightCondition.(fc2),4),...
                      icvalstr,...
                    obj.MassProperties.(wc)}; 
            else
                y = { num2str(obj.FlightCondition.(fc1),4),...
                      num2str(obj.FlightCondition.(fc2),4),...
                      icvalstr,...
                      num2str(obj.MassProperties.get(wc))};
            end
                
        end % getUnformattedDisplayText
        
        function y = getDisplayTextCell(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = {obj.Inputs.Name}';
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{1};end
            if strcmp(fc2,'All');fc2 = fcFnames{2};end
            if strcmp(ic,'All');ic = icFnames{1};end
            if strcmp(wc,'All');wc = wcFnames{2};end
            
            if obj.SelectedforDesign
                y = {['<html><font color="rgb(0,0,255)">',num2str(obj.FlightCondition.(fc1),4),'</font></html>'],...
                                            ['<html><font color="rgb(0,0,255)">',num2str(obj.FlightCondition.(fc2),4),'</font></html>'],...
                                            ['<html><font color="rgb(0,0,255)">',num2str(obj.Inputs.get(ic).Value,4),'</font></html>'],...
                                            ['<html><font color="rgb(0,0,255)">',obj.MassProperties.(wc),'</font></html>']};    
            else
                y = {['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',num2str(obj.FlightCondition.(fc1),4),'</font></html>'],...
                                            ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',num2str(obj.FlightCondition.(fc2),4),'</font></html>'],...
                                            ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',num2str(obj.Inputs.get(ic).Value,4),'</font></html>'],...
                                            ['<html><font color="rgb(',int2str(obj.Color(1)),',',int2str(obj.Color(2)),',',int2str(obj.Color(3)),')">',obj.MassProperties.(wc),'</font></html>']}; 
            end
        end % getDisplayTextCell
        
        function y = getDisplayColumns(obj,fc1,fc2,ic,wc)
           % Get the filterd operating conditon names in html
            
            fcFnames = fieldnames(obj.FlightCondition);
            icFnames = {obj.Inputs.Name}';
            wcFnames = fieldnames(obj.MassProperties);

            if strcmp(fc1,'All');fc1 = fcFnames{1};end
            if strcmp(fc2,'All');fc2 = fcFnames{2};end
            if strcmp(ic,'All');ic = icFnames{1};end
            if strcmp(wc,'All');wc = wcFnames{2};end
            
            y = {fc1,fc2,ic,wc}; 
            
           
        end % getDisplayColumns
      
        
        function y = eq(A,B)
            if length(A) == length(B)
                if A.FlightCondition == B.FlightCondition &&  ...
                        A.MassProperties == B.MassProperties && ...
                        all(A.Inputs == B.Inputs) && ...
                        all(A.Outputs == B.Outputs)
                    y = true;
                else
                    y = false;
                end
            elseif length(A) == 1 && length(B) > 1
                for i = 1:length(B)
                    if A.FlightCondition == B(i).FlightCondition &&  ...
                            A.MassProperties == B(i).MassProperties && ...
                            all(A.Inputs == B(i).Inputs) && ...
                            all(A.Outputs == B(i).Outputs)
                        y(i) = true;
                    else
                        y(i) = false;
                    end
                end
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if A(i).FlightCondition == B.FlightCondition &&  ...
                            A(i).MassProperties == B.MassProperties && ...
                            all(A(i).Inputs == B.Inputs) && ...
                            all(A(i).Outputs == B.Outputs)
                        y(i) = true;
                    else
                        y(i) = false;
                    end
                end
            elseif length(A) > 1 && length(B) > length(A)
                for i = 1:length(A)
                    if any(A(i).FlightCondition == [B.FlightCondition] &  ...
                            A(i).MassProperties == [B.MassProperties])
                        y(i) = true;
                    else
                        y(i) = false;
                    end
                end
            else
                y = false;
            end
        end % eq
        
        function y = setdiff(A,B)
            if length(A) == length(B)
                if A.FlightCondition == B.FlightCondition &&  ...
                        A.MassProperties == B.MassProperties
                    y = true;
                else
                    y = false;
                end
%             elseif length(A) == 1 && length(B) > 1
%                 for i = 1:length(B)
%                     if A.FlightCondition == B(i).FlightCondition &&  ...
%                             A.MassProperties == B(i).MassProperties
%                         y(i) = true;
%                     else
%                         y(i) = false;
%                     end  
%                 end
            elseif length(A) > 1 && length(B) == 1
                for i = 1:length(A)
                    if A(i).FlightCondition == B.FlightCondition &&  ...
                            A(i).MassProperties == B.MassProperties
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            elseif length(A) > 1 && length(B) > length(A)
                for i = 1:length(A)
                    if any(A(i).FlightCondition == [B.FlightCondition] &  ...
                            A(i).MassProperties == [B.MassProperties])
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            elseif length(B) > 1 && length(A) > length(B)
                for i = 1:length(A)
                    if any(A(i).FlightCondition == [B.FlightCondition] &  ...
                            A(i).MassProperties == [B.MassProperties])
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            else
                y = false;
            end
        end % setdiff
        
        function val = getICVal(obj,prop,str)
            lth = length(obj);
            val = nan(lth,1);
            for i = 1:lth
                try %#ok<TRYNC>
                    val(i) = obj(i).IC.(prop).get(str).Value;
                end 
            end
            
        end % getICVal

        function val = getVal(obj,prop,str)
            
            if length(obj) == 1
                
                if strcmp(prop,'States') || strcmp(prop,'Inputs') || strcmp(prop,'Outputs') || strcmp(prop,'StateDerivs')
                    newVal = obj.(prop).get(str).Value;
                elseif strcmp(prop,'FlightCondition')
                    newVal = obj.(prop).(str);
                elseif strcmp(prop,'MassProperties')
                    newVal = obj.(prop).(str).Value;
                elseif strcmp(prop,'LinearModel')
                   newVal = obj.(prop).get(str(2:end)).(upper(str(1)));
                end
                val = newVal;  
            else
            
                if strcmp(prop,'LinearModel')
                    len = length(obj);
                    val = cell(len,1);
                    for i = 1:length(obj)         
                        newVal = obj(i).(prop).get(str(2:end)).(upper(str(1)));
                        val{i} = newVal;
                    end
                else
                    len = length(obj);
                    val = nan(len,1);
                    for i = 1:length(obj)         
                        if strcmp(prop,'States') || strcmp(prop,'Inputs') || strcmp(prop,'Outputs') || strcmp(prop,'StateDerivs')
                            newVal = obj(i).(prop).get(str).Value;
                        elseif strcmp(prop,'FlightCondition')
                            newVal = obj(i).(prop).(str);
                        elseif strcmp(prop,'MassProperties')
                            newVal = obj(i).(prop).(str).Value;
                        elseif strcmp(prop,'LinearModel')
                           newVal = obj(i).(prop).get(str(2:end)).(upper(str(1)));
                        end
                        val(i) = newVal;
                    end 
                end
            end

        end % getVal
        
        function data = getTableData(obj)
            data = [];
            for i = 1:length(obj)
                states      = getSortedValue(obj(i).States);%{obj(i).States.Value};
                inputs      = getSortedValue(obj(i).Inputs);%{obj(i).Inputs.Value};
                outputs     = getSortedValue(obj(i).Outputs);%{obj(i).Outputs.Value};
                signallog   = getSortedValue(obj(i).SignalLogData);%{obj(i).StateDerivs.Value};
                statederivs = getSortedValue(obj(i).StateDerivs);
                fltcond     = obj(i).FlightCondition.getTableData;
                massprop    = obj(i).MassProperties.getTableData;

                data = [data,[fltcond;massprop';inputs';outputs';states';statederivs';signallog']];
            end
        end % getTableData
        
        function data = getHeaderData(obj)
            
            states      = getCellHeader(obj,'States');
            inputs      = getCellHeader(obj,'Inputs');
            outputs     = getCellHeader(obj,'Outputs');
            statederivs = getCellHeader(obj,'StateDerivs');
            fltcond     = lacm.FlightCondition.getHeaderData;
            massprop    = obj.MassProperties.getHeaderData;
            if ~isempty(obj.SignalLogData)
                signallog   = getCellHeader(obj,'SignalLogData');
                data = [fltcond;massprop;inputs;outputs;states;statederivs;signallog];
            else
                data = [fltcond;massprop;inputs;outputs;states;statederivs];
            end
        end % getHeaderData 
        
        function data = getHeaderStructureData(obj)
            

                
            states      = getStructHeader(obj,'States');
            inputs      = getStructHeader(obj,'Inputs');
            outputs     = getStructHeader(obj,'Outputs');
            statederivs = getStructHeader(obj,'StateDerivs');
            fltcond     = lacm.FlightCondition.getStructHeader;
            massprop    = obj.MassProperties.getStructHeader;
            if ~isempty(obj.SignalLogData)
                sigLogData  = getStructHeader(obj,'SignalLogData');
                data = [fltcond;massprop;inputs;outputs;states;statederivs;sigLogData];
            else
                data = [fltcond;massprop;inputs;outputs;states;statederivs];
            end
            

        end % getHeaderData         

        function path = findUnigueField( obj , str )
            path = [];
            % Try all properties
            if ~isempty(obj.States.get(str))
                path = ['States.',str];
            elseif ~isempty(obj.Inputs.get(str))
                path = ['Inputs.',str]; 
            elseif ~isempty(obj.Outputs.get(str))
                path = ['Outputs.',str]; 
            elseif ~isempty(obj.StateDerivs.get(str))
                path = ['StateDerivs.',str];
            else
                p = properties(lacm.FlightCondition);
                if any(strcmpi(str,p))
                    path = ['FlightCondition.',str];
                else
                    p = properties(lacm.MassProperties);
                    if any(strcmpi(str,p))
                        path = ['MassProperties.',str];
                    else      
                        p = strcmpi(str(2:end),{obj.LinearModel.Label});
                        if any(p)
                            path = ['LinearModel.get(''',str(2:end),''').',str(1)];
                        end
                    end
                    
                end
                
                
                
            end   
        end % findUniqueField       

        function y = getRange(obj,type,name,val1,val2)
            y = lacm.OperatingCondition.empty;
            
            for i= 1:length(obj)
                val = obj(i).(type).getValue(name);
                if val >= val1 && val <= val2
                    y(end+1) = obj(i);
                end  
            end
            
         
        end % getRange
        
        function yout = filterOC(obj,filterParam)
            % Example: filterParam: {'Outputs','Nzb',[0.9,1.2];'Inputs','XCG_PCT',[45,45],...,etc} 
            nFilt = size(filterParam,1);
            yin  = obj;
            for iFilt = 1:nFilt
                yout = lacm.OperatingCondition.empty;
                
                for i = 1:length(yin)
                    type = filterParam{iFilt,1};
                    name = filterParam{iFilt,2};
                    val1 = filterParam{iFilt,3}(1);
                    val2 = filterParam{iFilt,3}(2);
                    val = yin(i).(type).getValue(name);
                    if val >= val1 && val <= val2
                        yout(end+1) = yin(i);
                    end
                end
                yin = yout;
            end
            
        end %filterOC
        
        function setSignalLoggingData( obj )
% %             % Compile model if it is not already compiled
% %             if ~strcmp('paused',get_param(obj(1).ModelName, 'SimulationStatus'))
% %                 feval (obj(1).ModelName, [], [], [], 'compile');
% %             end
            
            
            % Run Signal Logging for trim
            set_param(obj(1).ModelName,'FastRestart','on')
            for i = 1:length(obj)
                Input(i).trimStruct = obj(i).Inputs;
                Input(i).time = [ 0 , 0 ]';
                Input(i).ReBuildMDLRef = 1;
                simOut(i) = Requirements.SimulationCollection.createSimInputs(Input(i),obj(i).ModelName);
                signalLogSignals = simOut(i).get('SignalLog');
                tsObjs = timeseries.empty;
                if ~isempty(signalLogSignals)
                    for j = 1:signalLogSignals.numElements
                        % Extract and plot the signals                                      
                        sig = signalLogSignals.getElement(j);              
                        tsObjs = [ tsObjs , Requirements.SimulationCollection.extractAllSignals( sig.Values ) ]; %#ok<*AGROW>                   
                    end  
                    obj(i).SignalLogData = lacm.Condition.empty;
                    for j = 1:length(tsObjs)
                        obj(i).SignalLogData(j) = lacm.Condition( tsObjs(j).Name , tsObjs(j).Data(1) );
                    end
                end
            end
            set_param(obj(1).ModelName,'FastRestart','off')
        end % setSignalLoggingData
        
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)     
        
        function y = getFree(obj,prop)
            y = [];
            lArray = [obj.(prop).Fix];
%             if any(lArray)
                y = find(~lArray)';
%             end
        end % getFree

        function y = getFixed(obj,prop)
            y = [];
            lArray = [obj.(prop).Fix];
%             if any(lArray)
                y = find(lArray)';
%             end
        end % getFixed
        
        function c = getConstraintsTrim(obj,prop)
            % Example Array  by columns [ Input Index | Constraind to Index | Initial Value ];
            %   constrainedArray = [ 5  , 3 , 1.5 ;...
            %                        2  , 1 , 20 ];
            names = {obj.(prop).Name};
            la = [obj.Inputs.Constrained];
            inputIndex = find(la)';          
            constIndex = zeros(length(inputIndex),1);
            constNames = {obj.Inputs(inputIndex).StringValue}';
            initialVal = zeros(length(inputIndex),1);
            for i = 1:length(inputIndex)
                % check if there is a '-' sign
                if contains(constNames(i),'-')
                    temp = strrep(constNames(i),'-','');
                    constNamei = strrep(temp,'+','');
                    constIndex(i) = -find(strcmp(constNamei,names));
                    initialVal(i) = -[obj.Inputs(-constIndex(i)).Value]';
                else
                    constIndex(i) = find(strcmp(constNames(i),names));
                    initialVal(i) = [obj.Inputs(constIndex(i)).Value]';
                end
            end
            
            c = [ inputIndex , constIndex , initialVal ];
        end
        
        function c = getStateConstraintsTrim(obj,prop)
            % Example Array  by columns [ Input Index | Constraind to Index | Initial Value ];
            %   constrainedArray = [ 5  , 3 , 1.5 ;...
            %                        2  , 1 , 20 ];
            names = {obj.(prop).Name};
            la = [obj.States.Constrained];
            stateIndex = find(la)';          
            constIndex = zeros(length(stateIndex),1);
            constNames = {obj.States(stateIndex).StringValue}';
            initialVal = zeros(length(stateIndex),1);
            for i = 1:length(stateIndex)
                % check if there is a '-' sign
                if contains(constNames(i),'-')
                    temp = strrep(constNames(i),'-','');
                    constNamei = strrep(temp,'+','');
                    constIndex(i) = -find(strcmp(constNamei,names));
                    initialVal(i) = -[obj.States(-constIndex(i)).Value]';
                else
                    constIndex(i) = find(strcmp(constNames(i),names));
                    initialVal(i) = [obj.States(constIndex(i)).Value]';
                end
            end
            
            c = [ stateIndex , constIndex , initialVal ];
        end
        
        
        function vec = getValues(obj,prop)
            vec = [obj.(prop).Value]'; 
        end % getValues
        
        function str = getNames(obj,prop)
            str = {obj.(prop).Name}'; 
        end % getNames
        
        function initializeConditions(obj,useBlkNames,initOC)
            if nargin == 2
                % Find all the inport, outport, states, and statederivative names.
                % Find names and assign the values to the 'Inports' from the Simulink model
                % Get units from Tag
                in_names = find_system(obj.ModelName,'SearchDepth',1,'BlockType','Inport');
                inputs(length(in_names)) = lacm.Condition; % Initialize
                for i = 1:length(in_names)
                   [~,name] = fileparts(in_names{i}); 
                   units = get_param(in_names{i},'Tag');
                   inputs(i) = lacm.Condition(name,0,units,true);
                end

                % Find names of the 'Outports' from the Simulink model
                % Get units from Tag
                out_names = find_system(obj.ModelName,'SearchDepth',1,'BlockType','Outport');
                outputs(length(out_names)) = lacm.Condition; % Initialize
                for i = 1:length(out_names)
                   [~,name] = fileparts(out_names{i}); 
                   units = get_param(out_names{i},'Tag');
                   outputs(i) = lacm.Condition(name,0,units,false);
                end

                if ~useBlkNames
                    % Turn off warnings
                    set_param(obj.ModelName, 'InitInArrayFormatMsg', 'None');
                    x1 = Simulink.BlockDiagram.getInitialState(obj.ModelName);   
                else
                    % Find names and ordering of states from Simulink model
                    [~,~,statenames]=eval([obj.ModelName '([],[],[],0)']);
                    states(length(statenames)) = lacm.Condition; % Initialize
                    statederivs(length(statenames)) = lacm.Condition; % Initialize
                    for i = 1:length(statenames)
                        [~,name] = fileparts(statenames{i}); 
                        units = get_param(statenames{i},'Tag');
                        states(i) = lacm.Condition(name,0,units,true);
                        statederivs(i) = lacm.Condition([name,'dot'],0,units,false);
                    end    
                end
                obj.States      = states;
                obj.Inputs      = inputs;
                obj.Outputs     = outputs;
                obj.StateDerivs = statederivs;
            else
                obj.States      = copy(initOC.States);
                obj.Inputs      = copy(initOC.Inputs);
                obj.Outputs     = copy(initOC.Outputs);
                obj.StateDerivs = copy(initOC.StateDerivs);
            end
        end  % initializeConditions
        
        function updateConditions(obj,prop,cond,fixed)
            % Update condition values
            for i = 1:length(cond)
                ind = find(obj.(prop),cond(i).Name);
                if ~isempty(ind)
                    if isnumeric(cond(i).Value)
                        obj.(prop)(ind).Value = cond(i).Value;
                    else
                        obj.(prop)(ind).Value = str2double(cond(i).Value); %#ok<*ST2NM>
                    end
                end    
            end
            
            % Update condition fixed status         
            for i = 1:length(fixed)
               ind = find(obj.(prop),fixed(i).Name);
               if ~isempty(ind)
                   if any(strcmp(prop,{'Inputs','States'}))
                   %temp = obj.(prop)(ind).Fix;
                   %obj.(prop)(ind).Fix = ~temp;
                        obj.(prop)(ind).Fix = false;
                   else
                        obj.(prop)(ind).Fix = true;
                   end
               end    
            end
        end % updateConditions    
        
        function updateMassPropObj(obj)
           % Update condition values
            for i = 1:length(obj.MassProperties.Parameter)
                ind = find(obj.Inputs,obj.MassProperties.Parameter(i).Name);
                if ~isempty(ind)
                    if isnumeric(obj.Inputs(ind).Value)
                        obj.MassProperties.Parameter(i).Value = obj.Inputs(ind).Value;
                    else
                        obj.MassProperties.Parameter(i).Value = str2double(obj.Inputs(ind).Value); %#ok<*ST2NM>
                    end        
                end    
            end
            temp =  java.util.UUID.randomUUID;
            y = char(temp.toString);
            obj.MassProperties.WeightCode = y;
        end % updateMassPropObj 
        
        function defaultFixFree(obj,prop)
            % Set default fix/free
            for i = 1:length(obj.(prop))
                if any(strcmp(prop,{'Inputs','States'}))
                    obj.(prop)(i).Fix = true;
                else
                    obj.(prop)(i).Fix = false;
                end
            end
        end % updateConditions    
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the States object
            cpObj.States = copy(obj.States);
            % Make a deep copy of the Inputs object
            cpObj.Inputs = copy(obj.Inputs);
            % Make a deep copy of the Outputs object
            cpObj.Outputs = copy(obj.Outputs);            
            % Make a deep copy of the StateDerivs object
            cpObj.StateDerivs = copy(obj.StateDerivs);  
            % Make a deep copy of the FlightCondition object
            cpObj.FlightCondition = copy(obj.FlightCondition);  
            % Make a deep copy of the MassProperties object
            cpObj.MassProperties = copy(obj.MassProperties);  
            % Make a deep copy of the LinearModel object
            cpObj.LinearModel = copy(obj.LinearModel);  
            % Make a deep copy of the TrimSettings object
            cpObj.TrimSettings = copy(obj.TrimSettings);  
        end % copyElement
                  
        function update( obj , ~ , ~ )
            
        end % update
        
        function releaseModel(obj)
            % Release model
             
            if length(obj) > 1
                uniqueMdlNames = unique({obj.ModelName});
                for i = 1:length(uniqueMdlNames)
                    while strcmp(get_param(uniqueMdlNames{i}, 'SimulationStatus'),'paused')
                        feval (uniqueMdlNames{i}, [], [], [], 'term');
                    end   
                end
            else 
                while strcmp(get_param(obj.ModelName, 'SimulationStatus'),'paused')
                    feval (obj.ModelName, [], [], [], 'term');
                end              
            end
        end % releaseModel  

        function orderConditions( obj )

            % Find all the inport, outport, states, and statederivative names.
            % Find names and assign the values to the 'Inports' from the Simulink model
            % Get units from Tag
            % **** These should already be ordered ******

            [inNames , outNames , stateNames , stateDerivNames , inUnit , outUnit , stateUnit , stateDotUnit, cStateID] = Utilities.getNamesFromModel( obj.ModelName );
            
            obj.TrimSettings.CStateID = cStateID;
            
             [ ~ , ia ] = ismember(inNames,{obj.Inputs.Name});%[ ~ , ia ] = ismember(inNames,{obj.Inputs.Name});
            obj.Inputs      = obj.Inputs(ia);
            % assign update units to opercond obj
            inUnit = inUnit(ia);
            for i = 1:length(obj.Inputs)
                obj.Inputs(i).Units = inUnit{i};
            end
            [ ~ , ia ] = ismember(outNames,{obj.Outputs.Name});%[ ~ , ia ] = ismember(outNames,{obj.Outputs.Name});
            obj.Outputs = obj.Outputs(ia);
            % assign update units to opercond obj
            outUnit = outUnit(ia);
            for i = 1:length(obj.Outputs)
                obj.Outputs(i).Units = outUnit{i};
            end
            
            
            [ ~ , ia ] = ismember(stateNames,{obj.States.Name});%[ ~ , ia ] = ismember(stateNames,{obj.States.Name});
            obj.States      = obj.States(ia);
            obj.StateDerivs = obj.StateDerivs(ia);
            % assign update units to opercond obj
            stateUnit = stateUnit(ia);
            for i = 1:length(obj.States)
                obj.States(i).Units = stateUnit{i};
                obj.StateDerivs(i).Units = stateDotUnit{i};
            end
            
%             [ ~ , ia ] = ismember(stateDerivNames,{obj.StateDerivs.Name});%[ ~ , ia ] = ismember(stateDerivNames,{obj.StateDerivs.Name});
%             obj.StateDerivs = obj.StateDerivs(ia);
%             % assign update units to opercond obj
%             stateDotUnit = stateDotUnit(ia);
%             for i = 1:length(obj.StateDerivs)
%                 obj.StateDerivs(i).Units = stateDotUnit{i};
%             end
            
%             obj.Inputs      = obj.Inputs;
%             obj.Outputs     = obj.Outputs;
%             obj.States      = obj.States;
%             obj.StateDerivs = obj.StateDerivs;
        end % orderConditions
        
        function copyConditions( obj , initOC )
            if any([obj.Inputs.UsePrevious])
                [obj.Inputs([obj.Inputs.UsePrevious]).Value] = initOC.Inputs([obj.Inputs.UsePrevious]).Value;
            end
            if any([obj.Outputs.UsePrevious])
                [obj.Outputs([obj.Outputs.UsePrevious]).Value] = initOC.Outputs([obj.Outputs.UsePrevious]).Value;
            end
            if any([obj.States.UsePrevious])
                [obj.States([obj.States.UsePrevious]).Value] = initOC.States([obj.States.UsePrevious]).Value;
            end
            if any([obj.StateDerivs.UsePrevious])
                [obj.StateDerivs([obj.StateDerivs.UsePrevious]).Value] = initOC.StateDerivs([obj.StateDerivs.UsePrevious]).Value;
            end

        end % copyConditions

        function initializeConditions2Task( obj , task )
            obj.States      = copy(task.StateConditions);
            obj.Inputs      = copy(task.InputConditions);
            obj.Outputs     = copy(task.OutputConditions);
            obj.StateDerivs = copy(task.StateDerivativeConditions);
        end % initializeConditions2Task

    end % methods (Access = protected)

    methods

        function runLinearization(obj, linMdlObj)
            %RUNLINEARIZATION Run linearization on an existing operating condition.
            %   runLinearization(operCond, linMdlObj) uses the current
            %   state of the operating condition to linearize the model
            %   described by the supplied lacm.LinearModel object.
            %
            %   linMdlObj should be a lacm.LinearModel or array of such.
            %
            if nargin < 2 || ~isa(linMdlObj,'lacm.LinearModel')
                error('Input must be a lacm.LinearModel object');
            end

            % Compile model if needed
            if ~strcmp('paused', get_param(obj.ModelName, 'SimulationStatus'))
                try
                    feval(obj.ModelName, [], [], [], 'compile');
                catch
                    error('Unable to compile model');
                end
            end

            % Gather names and values
            stateNames   = getNames(obj,'States');
            inportNames  = getNames(obj,'Inputs');
            outportNames = getNames(obj,'Outputs');
            X0_trim      = getValues(obj,'States');
            U0_trim      = getValues(obj,'Inputs');
            Y0_trim      = getValues(obj,'Outputs');
            CStateIDs    = obj.TrimSettings.CStateID;

            % Run the linearization
            for i = 1:length(linMdlObj)
                run(linMdlObj(i), obj.ModelName, stateNames, inportNames, ...
                    outportNames, X0_trim, U0_trim, Y0_trim, CStateIDs);
            end
        end % runLinearization

    end
    
    %% Methods - Private - Trim Methods
    methods ( Access = private )
        
        function run( obj , trimTask, TrimOptions)
       
            obj.FlightCondition = trimTask.FlightCondition;
            obj.ModelName       = trimTask.Simulation;
            obj.LinearModel     = trimTask.LinMdlObj;
            obj.TrimSettings    = trimTask.TrimDefObj;
            obj.MassProperties  = trimTask.MassPropObj;
            
            % Load System
            try
                load_system(obj.ModelName);
            catch
                error('FCDAT:notFoundInPath',obj.ModelName);
            end

            if isempty(obj.TrimSettings.InitialTrim)
                initializeConditions2Task( obj , trimTask );
                
                trimLoop( obj, TrimOptions); 
            else
                tempObj = copy(obj);
                initializeConditions2Task( tempObj , trimTask.InitialTrimTask );
                
                trimLoop( tempObj, TrimOptions);
                
                initializeConditions2Task( obj , trimTask );
                
                copyConditions( obj , tempObj )
                
                if tempObj.SuccessfulTrim
                    trimLoop( obj, TrimOptions)
                else
                    obj.SuccessfulTrim = tempObj.SuccessfulTrim;
                    obj.IncorrectTrimText = tempObj.IncorrectTrimText;
                end
                
            end 

        end % run
 
        function trimLoop( obj, TrimOptions)
            %**************************************************************
            %********************Update Conditions*************************
            %**************************************************************
                  
 

            % Update the Mass Property Values to Inputs
            if ~obj.MassProperties(1).DummyMode
                updateConditions(obj,'Inputs',...
                    obj.MassProperties.Parameter,...
                    []);  
            else
                updateMassPropObj(obj);
            end
            % Update the Flight Condition to Inputs
            updateConditions(obj,'Inputs',...
                obj.FlightCondition.FltCond4Sim,...
                []);
            % Update the Flight Condition to Inputs
            updateConditions(obj,'States',...
                obj.FlightCondition.FltCond4Sim,...
                []);
            
            
            % Update IC of xecef using the Flight Condition object
            objH = geti(obj.States,'xecef');
            
            if isempty(objH)
                objH = geti(obj.States,'xecef_ft');
                
                if isempty(objH)
                    objH = geti(obj.States,'xecef_m');
                end
            end
            
            if ~isempty(objH)
                temp = obj.FlightCondition.FltCond4Sim;
                objH.Value = temp(1).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
            else
                warning('Can not set initial condition for True Airspeed.');
            end
            
  
            % Update IC of Altitude using the Flight Condition object
            objH = geti(obj.Inputs,'Alt_IC');
            
            if isempty(objH)
                objH = geti(obj.Inputs,'Altitude_IC');
                
                if isempty(objH)
                    objH = geti(obj.Inputs,'Alt_ft_IC');
                    
                    if isempty(objH)
                        objH = geti(obj.Inputs,'Alt_m_IC');
                        
                        if isempty(objH)
                            objH = geti(obj.Inputs,'Altitude_ft_IC');
                            
                            if isempty(objH)
                                objH = geti(obj.Inputs,'Altitude_m_IC');
                            end
                        end
                        
                    end
                end
            end
                   
            if ~isempty(objH)
                objH.Value = obj.FlightCondition.Alt*obj.FlightCondition.SimUnitConversionFactor;
            else
                warning('Can not set initial condition for Altitude.');
            end
            
            
            % Speed mapping to IC and output port
            
            % Update IC of V
            objH = geti(obj.Inputs,'V_IC');
            
            if isempty(objH)
                objH = geti(obj.Inputs,'V_mps_IC');
                
                if isempty(objH)
                    objH = geti(obj.Inputs,'V_fps_IC');
                end
            end
            
            if ~isempty(objH)
                temp = obj.FlightCondition.FltCond4Sim;
                objH.Value = temp(3).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
            else
                warning('Can not set initial condition for True Airspeed.');
            end
            
            
            % Update V (output ports)
            if obj.FlightCondition.SimUnitConversionFactor == 1
                objH = geti(obj.Outputs,'V_fps');
                if ~isempty(objH)
                    temp = obj.FlightCondition.FltCond4Sim;
                    objH.Value = temp(3).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
                end
            else
                objH = geti(obj.Outputs,'V_mps');
                if ~isempty(objH)
                    temp = obj.FlightCondition.FltCond4Sim;
                    objH.Value = temp(3).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
                end
            end
            
            % Update initial condition on Ub state if exist - this is for convergence
            objH = geti(obj.States,'ubi');
            
            if isempty(objH)
                objH = geti(obj.States,'ub');
            end
            
            if isempty(objH)
                objH = geti(obj.States,'ubi_fps');
                
                if isempty(objH)
                    objH = geti(obj.States,'ubi_mps');
                    
                    if isempty(objH)
                        objH = geti(obj.States,'ub_fps');
                        
                        if isempty(objH)
                            objH = geti(obj.States,'ub_mps');
                        end
                        
                    end
                end
            end
            
            if ~isempty(objH) && objH.Fix==0
                temp = obj.FlightCondition.FltCond4Sim;
                objH.Value = temp(3).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
            end
                
                
            
            % Ensure conditions are order as the model
            % orderConditions( obj );
            
            %**************************************************************
            %********************Setup Vectors*****************************
            %**************************************************************
            n_inputs  = getFree(obj,'Inputs');
            n_outputs = getFixed(obj,'Outputs');
            n_states  = getFree(obj,'States');
            n_deriv   = getFixed(obj,'StateDerivs');
            

            X0_in  = getValues(obj,'States');
            U0_in  = getValues(obj,'Inputs');
            Y0_in  = getValues(obj,'Outputs');
            X0_dot = getValues(obj,'StateDerivs');

            stateNames   = getNames(obj,'States');
            inportNames  = getNames(obj,'Inputs');
            derivNames   = getNames(obj,'StateDerivs');
            outportNames = getNames(obj,'Outputs');
            
            %**************************************************************
            %***************Calculate Input Constraints********************
            %**************************************************************  
            constraintsInputsArray = getConstraintsTrim(obj,'Inputs');
            
            %**************************************************************
            %***************Calculate Input Constraints********************
            %************************************************************** 
            constraintsStatesArray = getStateConstraintsTrim(obj,'States');

            
            % Update U0_in vector
            for i = 1:size(constraintsInputsArray,1)
                U0_in(constraintsInputsArray(i,1)) = constraintsInputsArray(i,3);
            end
            
            % Update X0_in vector
            for i = 1:size(constraintsStatesArray,1)
                X0_in(constraintsStatesArray(i,1)) = constraintsStatesArray(i,3);
            end
            
            % Get Continuous States IDs
            CStateIDs = obj.TrimSettings.CStateID;
            
            %**************************************************************
            %********************Run Trim**********************************
            %**************************************************************     
            % Compile model if it is not already compiled
            if ~strcmp('paused',get_param(obj.ModelName, 'SimulationStatus'))
                try
                    feval (obj.ModelName, [], [], [], 'compile');
                catch
                    error('Unable to compile model');
                end
            end
            % Get trim condition
            %trim_options = [42, 1e-9, 10];
            trim_options = [TrimOptions.MaxInterations, TrimOptions.MaxCostFunction, TrimOptions.MaxBisection,...
                TrimOptions.StatePertubationSize, TrimOptions.InputPertubationSize];


            [X0_trim,U0_trim,DX0,Y0_trim,j_trim, cost] = ...
                jj_trim(obj.ModelName,X0_in,U0_in,X0_dot,Y0_in,...
                n_states,n_inputs,n_deriv,...
                n_outputs,stateNames,inportNames,derivNames,outportNames, [],[],[],[],constraintsInputsArray, constraintsStatesArray, CStateIDs, trim_options);   
            
            if j_trim > 0
                obj.SuccessfulTrim = false;
                switch j_trim
                    case 1
                        obj.IncorrectTrimText = ['Improper condition: Number of trim variables not equal to number of trim requirements | ',...
                                        'Number of trim variables is less than 1 | ',...
                                        'Number of trim requirements is less than 1'];
                    case 2
                        obj.IncorrectTrimText = 'Trim variables are not independent';
                    case 3
                        obj.IncorrectTrimText = 'Number of step size bisections exceeds 10, no trim found';
                    case 4
                        obj.IncorrectTrimText = 'Unable to trim after max number of iterations';
                        
                end
                
            else
                obj.SuccessfulTrim = true;
            end

            obj.Cost = cost;

            %**************************************************************
            %********************Run Linearization*************************
            %************************************************************** 
            for i = 1:length(obj.LinearModel)
                run(obj.LinearModel(i),obj.ModelName,stateNames,inportNames,outportNames,X0_trim,U0_trim,Y0_trim,CStateIDs);
            end

            %**************************************************************
            %**Assign Values to Inputs,Outputs,States, and State Derivs****
            %************************************************************** 
            % Assign Values to States
            X0_trim = num2cell(X0_trim);
            [obj.States.Value] = deal(X0_trim{:});

            % Assign Values to StatesDerivs
            DX0 = num2cell(DX0);
            [obj.StateDerivs.Value] = deal(DX0{:});

            % Assign Values to Inputs
            U0_trim = num2cell(U0_trim);
            [obj.Inputs.Value] = deal(U0_trim{:});

            % Assign Values to Outputs
            Y0_trim = num2cell(Y0_trim);
            [obj.Outputs.Value] = deal(Y0_trim{:});

            % Assign IC values to Inputs
            for i =1:length(obj.States)
                objH = get(obj.Inputs,[obj.States(i).Name,'_IC']);
                if ~isempty(objH) && objH.Value==0 % assuming default value for IC inputs to be zero
                    objH.Value = obj.States(i).Value;
                end
            end
            
            % Check if Altitude or Speed was not fixed
            objV = geti(obj.States,'V');
            
            if isempty(objV)
                objV = geti(obj.States,'V_mps');
                
                if isempty(objV)
                    objV = geti(obj.States,'V_fps');
                end
            end
            
            objA = geti(obj.States,'xecef');
            if isempty(objA)
                objA = geti(obj.States,'xecef_m');
                
                if isempty(objA)
                    objA = geti(obj.States,'xecef_ft');
                end
            end
            
            
            if ~isempty(objV) && ~isempty(objA)
                
                if objV.Fix==0 || objA.Fix ==0
                    V  = objV.Value/obj.FlightCondition.SimUnitConversionFactor;
                    Alt= objA.Value/obj.FlightCondition.SimUnitConversionFactor - 20925646.3572663;
                    
                    FCObject = lacm.FlightCondition('KTAS',V*(6858/11575),'Alt',Alt);
                    obj.FlightCondition = FCObject;
                end
                
            end
                
            
            % Update IC of Altitude using the Flight Condition object
            objH = geti(obj.Inputs,'Alt_IC');
            
            if isempty(objH)
                objH = geti(obj.Inputs,'Altitude_IC');
                
                if isempty(objH)
                    objH = geti(obj.Inputs,'Alt_ft_IC');
                    
                    if isempty(objH)
                        objH = geti(obj.Inputs,'Alt_m_IC');
                        
                        if isempty(objH)
                            objH = geti(obj.Inputs,'Altitude_ft_IC');
                            
                            if isempty(objH)
                                objH = geti(obj.Inputs,'Altitude_m_IC');
                            end
                        end
                        
                    end
                end
            end
                   
            if ~isempty(objH)
                objH.Value = obj.FlightCondition.Alt*obj.FlightCondition.SimUnitConversionFactor;
            else
                warning('Can not set initial condition for Altitude.');
            end
     
            
            % Update IC of V
            objH = geti(obj.Inputs,'V_IC');
            
            if isempty(objH)
                objH = geti(obj.Inputs,'V_mps_IC');
                
                if isempty(objH)
                    objH = geti(obj.Inputs,'V_fps_IC');
                end
            end
            
            if ~isempty(objH)
                temp = obj.FlightCondition.FltCond4Sim;
                objH.Value = temp(3).Value; % Note temp(1)=xecef, temp(2)=alt, temp(3)=V
            else
                warning('Can not set initial condition for True Airspeed.');
            end

            
            
        end % trimLoop   
        

        
    end 
    
    %% Methods - Private
    methods ( Access = private )
        
        function y = getCellHeader(obj,prop)

            names = {obj.(prop).Name};
            units = {obj.(prop).Units};
            type  = cell(length(names),1);
            if strcmp(prop,'StateDerivs')
                type(:) = {'State Derivatives'};
            else
                type(:) = {prop};
            end

            [ names , I ] = sort(names);
            units = units(I);
            
            y = [type,names',units'];
        end % getCellHeader
        
        function y = getStructHeader(obj,prop)

            names = {obj.(prop).Name};
            units = {obj.(prop).Units};
            type  = cell(length(names),1);
            if strcmp(prop,'StateDerivs')
                type(:) = {'State Derivatives'};
            elseif strcmp(prop,'SignalLogData')
                type(:) = {'Signal Log'};
            else
                type(:) = {prop};
            end
            
            % Sort alphabeticly
            [ names , I ] = sort(names);
            units = units(I);
            
            if ~isempty(names)
                y = struct('Type',type,'Name',names','Units',units');
            else
                y= [];
            end
            
            
        end % getStructHeader
        
    end
    
    %% Methods - Static
    methods (Static)
        
        function cond = setVariables(value)
            if ischar(value)
                tempVal = eval(value);
            elseif iscell(value)
                tempVal = value;
            else
                error('In the task file the cell matrix format is not supported');
            end
            
            if mod(length(tempVal),2) ~= 0
               error('Array must contain Name/Value pairs.'); 
            else
                if size(tempVal,1) == 1 || size(tempVal,2) == 1
                    vars(length(tempVal)/2) = lacm.Condition;
                    ind = 1;
                    for i = 2:2:length(tempVal)
                        vars(ind) = lacm.Condition(tempVal{i-1},tempVal{i}); 
                        ind = ind + 1;
                    end
                elseif size(tempVal,1) == 2 || size(tempVal,2) == 2  
                    vars(size(tempVal,1)) = lacm.Condition;
                    for i = 1:size(tempVal,1)
                        vars(i) = lacm.Condition(tempVal{i,1},tempVal{i,2});   
                    end  
                elseif isempty(tempVal)
                    vars = lacm.Condition();
                else
                    error('In the task file the cell matrix for ''Variables'' is incorrect');
                end
            end
            cond = vars;
        end % Variables 
        
        function operCond = convertStruct2Class( ocStruct )
            
            %ocStruct = varargin{1};
            massProp = lacm.MassProperties('C:\Projects\ACD Tools\trunk\Design Tools\ACD FCDAT\Examples\StabilityControl\Examples4Testing\massProperties.txt');
            
            for i = 1:length(ocStruct)
                operCond(i) = lacm.OperatingCondition();
                operCond(i).Label = inputname(1);
                operCond(i).ModelName = 'ERV2FlightDynamics';
                operCond(i).States = createCondition(ocStruct(i).IC.States);
                operCond(i).Inputs = createCondition(ocStruct(i).IC.Inputs);
                operCond(i).Outputs = createCondition(ocStruct(i).IC.Outputs);
                for j = 1:length(ocStruct(i).IC.StateDerivs.DX0)
                    operCond(i).StateDerivs(j) = lacm.Condition( ocStruct(i).IC.States.X0_names{j} , ocStruct(i).IC.StateDerivs.DX0(j) );
                end

                operCond(i).FlightCondition = lacm.FlightCondition('Mach',ocStruct(i).FC.mach,'Qbar',ocStruct(i).FC.qbar);
                operCond(i).MassProperties = massProp.getWC(ocStruct(i).wcode);
                operCond(i).MassProperties.Label = inputname(1);
                operCond(i).LinearModel(1) = lacm.LinearModel();
                operCond(i).LinearModel(1).Label = 'Lon';
                operCond(i).LinearModel(1).A = ocStruct(i).LinearModel.Alon;
                operCond(i).LinearModel(1).B = ocStruct(i).LinearModel.Blon;
                operCond(i).LinearModel(1).C = ocStruct(i).LinearModel.Clon;
                operCond(i).LinearModel(1).D = ocStruct(i).LinearModel.Dlon;
                
                
                operCond(i).LinearModel(2) = lacm.LinearModel();
                operCond(i).LinearModel(2).Label = 'Lat';
                operCond(i).LinearModel(2).A = ocStruct(i).LinearModel.Alat;
                operCond(i).LinearModel(2).B = ocStruct(i).LinearModel.Blat;
                operCond(i).LinearModel(2).C = ocStruct(i).LinearModel.Clat;
                operCond(i).LinearModel(2).D = ocStruct(i).LinearModel.Dlat;       
                
                operCond(i).TrimSettings = lacm.TrimSettings('FixedDerivatives',createCondFromCell(ocStruct(i).trimdef.fixDerivs),...
                    'FixedOutputs',createCondFromCell(ocStruct(i).trimdef.fixOutputs),...
                    'FreeStates',createCondFromCell(ocStruct(i).trimdef.freeStates),...
                    'FreeInputs',createCondFromCell(ocStruct(i).trimdef.freeInputs),...
                    'ICStates',createCondFromCell(ocStruct(i).trimdef.icStates{:}(:,1),ocStruct(i).trimdef.icStates{:}(:,2)),...
                    'ICInputs',createCondFromCell(ocStruct(i).trimdef.icInputs{:}(:,1),ocStruct(i).trimdef.icInputs{:}(:,2)),...
                    'ICOutputs',createCondFromCell(ocStruct(i).trimdef.icOutputs{:}(:,1),ocStruct(i).trimdef.icOutputs{:}(:,2)),...
                    'Label',ocStruct(i).trimdef.name,...
                    'TrimID',ocStruct(i).trimdef.id,...
                    'NTrim',ocStruct(i).trimdef.ntrim,...
                    'TrimNumber',1);   
            end
        end % convertStruct2Class
    end
    
end

function cond = createCondition(field)

    fieldNames = fieldnames(field);
    for j = 1:length(fieldNames)-3
        cond(j) = lacm.Condition(fieldNames{j},field.(fieldNames{j}));                  %#ok<*AGROW>
    end 
    
end

function cond = createCondFromCell(names,values)

    if nargin == 1
        for i = 1:length(names)
            cond(i) = lacm.Condition(names{i},0);
        end
    elseif nargin == 2
        for i = 1:length(names)
            cond(i) = lacm.Condition(names{i},values{i});
        end
    end
end

function val = getSortedValue(conds)
    [~,I] = sort({conds.Name});
    
    val = num2cell([conds(I).Value]);
    

end % getSortedValue

function [x_tr, u_tr, d_tr, y_tr, j_trim, cost] = jj_trim (...
  sys, ...
  x, u, d, y, ...
  i_x, i_u, i_d, i_y, ...
  x_nam, u_nam, d_nam, y_nam, ...
  del_x_max, del_u_max, ...
  del_x_lin, del_u_lin, ...
  constraintsInputsArray, ...
  constraintsStatesArray, ...
  cstateid,...
  options)

    %JJ_TRIM   Trim point determination of a nonlinear ordinary differential equation system
    %
    %   [X_TR, U_TR, D_TR, Y_TR, J_TRIM] 
    %        = JJ_TRIM (SYS, X, U, D, Y, I_X, I_U, I_D, I_Y, X_NAM, U_NAM, D_NAM, Y_NAM)
    %   trims the system SYS towards an operating point defined by the elements of
    %   X (state vector), U (input vector), D (derivative of the state vector),
    %   and Y (output vector).
    %   I_X and I_U define the indices of the so-called trim variables, which
    %   are those states and inputs the trim algorithm has to find
    %   the appropriate values for. Specified values of the trim variables
    %   are taken as initial starting guesses for the iteration.
    %   I_D and I_Y are the indices of the so-called trim requirements, which
    %   the trim algorithm has to satisfy. The values of the other D(i) and Y(i)
    %   do not matter.
    %   X_NAM, U_NAM, D_NAM, and Y_NAM are cell arrays of the form
    %   X_NAM = {'state_1'; 'state_2'; ...}
    %   containing the names of the states, inputs, derivatives, and outputs.
    %   The names can be chosen arbitrarily. They are used only to identify
    %   linear dependent trim variables or trim requirements.
    %
    %   J_TRIM is a trim validity indication:
    %       J_TRIM  RESULT
    %       ------  ------
    %       0       Good Trim
    %       1       Improper condition: #trim vars ~= #trim reqts
    %                                   #trim vars<1 | #trim reqts<1
    %       2       Trim variables not independent
    %       3       # step size bisections exceeds 10, no trim found
    %       4       Unable to trim after max # iterations (defined below)
    %
    %   IMPORTANT: o There have to be as many trim variables as there are
    %                trim requirements.
    %
    %              o All vectors (and cell arrays) have to be column vectors.
    %
    %   To see more help, enter TYPE JJ_TRIM.
    %
    %   [X_TR, ...] = JJ_TRIM (..., Y_NAM, DEL_X_MAX, DEL_U_MAX)
    %   allows the additional specification of maximum alterations
    %   of state and input during one trim step.
    %   The lengths of DEL_X_MAX and DEL_U_MAX are equal to those of
    %   X and U respectively.
    %   The default values of DEL_X_MAX and DEL_U_MAX are 1e42.
    %
    %   [X_TR, ...] = JJ_TRIM (..., DEL_U_MAX, DEL_X_LIN, DEL_U_LIN)
    %   allows the additional specification of the state and input step size
    %   to be used for the calculation of the Jacobian-matrix (sensitivity
    %   matrix)
    %   in the linearization procedure.
    %   The default values of DEL_X_LIN and DEL_U_LIN are
    %   1e-6*(1 + abs(x)) and 1e-6*(1 + abs(u)) respectively.
    %
    %   [X_TR, ...] = JJ_TRIM (..., DEL_U_LIN, OPTIONS)
    %   allows the additional specification of
    %   the maximum number of iterations "OPTIONS(1)" (default: 42) and
    %   the cost value "OPTIONS(2)" (default: 1e-9) to be gained.
    %
    %   Copyright 2000-2004, J. J. Buchholz, Hochschule Bremen, buchholz@hs-bremen.de
    %
    %   Version 1.2     26.05.2000
    %
    %   The names of inputs, ... outputs for the error messages
    %   are now transferred via the parameter list.
    %
    %   The precompilation and the release of the system is now done in JJ_TRIM.
    import lacm.Utilities.*
    % Initially assume good trim
    j_trim=0;

    % Feed through all initial vectors, 
    % usefull in case of an emergency exit
    x_tr = x;
    u_tr = u;
    d_tr = d;   % this includes more than pure integrators
    d    = d(cstateid);
    y_tr = y;

    % Determine lengths of basic vectors
    n_x  = length (x);
    n_u  = length (u); 
    n_d  = length (d);
    n_y  = length (y);

    n_i_x = length (i_x);
    n_i_u = length (i_u);
    n_i_y = length (i_y);
    n_i_d = length (i_d);

    % Assemble generalized input vector and generalized output vector
    x_u = [x; u];
    d_y = [d; y];

    % Determine length of generalized input vector and generalized output vector
    n_x_u = length (x_u);
    n_d_y = length (d_y);

    % Assemble trim variable index vector and trim requirement index vector
    i_t_v = [i_x; i_u + n_x]; 
    i_t_r = [i_d; i_y + n_d];

    % Determine number of trim variables and trim requirements
    n_t_v = n_i_x + n_i_u;
    n_t_r = n_i_y + n_i_d;

    % There have to be as many trim variables as there are trim requirements
    if n_t_r ~= n_t_v

      l1 = ['The number of trim variables: ', int2str(n_t_v)];
      l2 = 'does not equal';
      l3 = ['the number of trim requirements: ', int2str(n_t_r)];
      l4 = ' ';
      l5 = 'The returned trim point is not valid.';
      h1 = 'Error';
      %disp(' ');
      %disp(h1);
      %disp(l1); disp(l2); disp(l3); disp(l4); disp(l5);
      %disp(' ');
      %errordlg ({l1; l2; l3; l4; l5}, h1); 

      % Game over
      j_trim=1;
      cost = NaN;
      return

    end

    % There should be at least one trim variable and one trim requirement
    %     if n_t_r == 0 && n_t_v == 0
    %
    %       l1 = 'There should be at least';
    %       l2 = 'one trim variable and';
    %       l3 = 'one trim requirement.';
    %       h1 = 'Nothing to trim';
    %       %disp(' ')
    %       %disp(h1)
    %       %disp(l1); disp(l2); disp(l3);
    %       %disp(' ')
    %       %warndlg ({l1; l2; l3}, h1);
    %
    %       j_trim=1;
    %       return
    %
    %     end
    
    % If no maximum step sizes have been defined,
    if nargin < 14
        
        % set defaults
        del_max = 1.e42*ones (n_x_u, 1);
        
        % otherwise assemble generalized maximum step vector
    else
        
        %   Adds Option for User Specify Bisection Counter
        if isempty(del_x_max )
            del_x_max = 1.e42*ones (n_x, 1);
        end
        
        if isempty(del_u_max )
            del_u_max = 1.e42*ones (n_u, 1);
        end
        
        
        del_max = [del_x_max; del_u_max];
        
        
        
    end
    
    % If no step sizes for the linearization have been defined,
    if nargin < 16
        
        
        % set defaults
        del_lin = 1e-6*(1 + abs(x_u));
        
        % otherwise assemble generalized linearization step vector
    else
        
        %   Addes Option for User Specify Bisection Counter
        if isempty(del_x_lin )
            %         del_x_lin = 1e-6*(1 + abs(x));
            del_x_lin = options(4)*(1 + abs(x));
        end
        
        if isempty(del_u_lin )
            %         del_u_lin = 1e-6*(1 + abs(u));
            del_u_lin = options(5)*(1 + abs(u));
        end
        
        del_lin = [del_x_lin; del_u_lin];
        
    end
    
    del_lin_type = zeros(length(del_lin),1);
    
    % If no options have been defined,
    if nargin < 18
        
        % set defaults (maximum number of iterations and cost value to be gained)
        options(1) = 42;
        options(2) = 1e-9;
        
        % Adds Option for User Specify Bisection Counter, default is 10;
        options(3) = 10;
        %
    end

    % Save and rename the options 
    n_iter   = options(1);
    cost_tbg = options(2);
    n_bisect = options(3);

    % Set time to zero explicitely (assume a time invariant system)
    t = 0;

    % Set old cost value to infinity, in oder to definitely have 
    % an improvement with the first try
    cost_old = inf;

    % Precompile system.
    % Unfortunately, this is necessary because only precompiled systems can be evaluated.
    % If the trim algorithm is aborted without the corresponding "Release system" command
    % the next precompilation attempt will lead to an error and the simulation cannot
    % be started.
    % The system then has to be released manually (maybe more than once!) with:
    % model_name ([], [], [], 'term')

    %feval (sys, [], [], [], 'compile');

    % Loop over maximum n_iter iterations
    for i_iter = 0 : n_iter

      % Calculate outputs and derivatives at the current trim point.
      % Important: We have to calculate the outputs first!
      %            The derivatives would be wrong otherwise.
      % Unbelievable but true: Mathworks argues that this is not a bug but a feature!
      % And furthermore: Sometimes it is even necessary to do the output calculation twice
      % before you get the correct derivatives!
      % Mathworks says, they will take care of that problem in one of the next releases...
      %y_tr = feval (sys, t, x_u(1:n_x), x_u(n_x+1:end), 3); 
      y_tr = feval (sys, t, x_u(1:n_x), x_u(n_x+1:end), 3); 
      d_trs = feval (sys, t, x_u(1:n_x), x_u(n_x+1:end), 1);
      d_y_tr = [d_trs; y_tr];
      d_tr(cstateid) = d_trs;

      % Calculate differences between required and current generalized output vectors
      del_d_y = d_y - d_y_tr;

      % Pick trim requirements only
      del_t_r = del_d_y(i_t_r);


      % Comments: trim routine will some how generate del_t_r that has some
      % components of NaN. the line: cost = max(abs(del_tr_r)) then output a
      % cost = 0.... which gets passed as a trimmed solution.
      % Fix 
      %%

      if sum(isnan(del_t_r))>0
            del_t_r(isnan(del_t_r)) = 100;
            cost = max (abs (del_t_r));
            display('*** WARNING! Trim Requirments are NaN! Sim Outputs are NaN! ***')
      else 
            cost = max (abs (del_t_r));

      end 

      %% fix end 

      % Cost is an empty matrix if there are no trim variables and trim requirements
      if isempty (cost)
        cost = 0;
      end

      % If current cost value has become smaller 
      % than the cost value to be gained
      if cost < cost_tbg

        % Output cost value and number of iterations needed
        l1 = ['A cost value of ',num2str(cost)];
        l2 = ['has been gained after ', int2str(i_iter), ' iteration(s).'];   
        h1 = 'Success';
        %msgbox ({l1, l2}, h1);
     %   disp(l1)
     %   disp(l2)
     %   disp(h1)

        % Release system
        %feval (sys, [], [], [], 'term');

        % Game over
        j_trim=0;
        return

      end

      % If an improvement has been obtained
      % with respect to the last point,
      if cost < cost_old

        % accept and save this new point.
        % Important for a possible step size bisection later on
        x_u_old = x_u;

        % Save the cost value of this new point for a comparison later on
        cost_old = cost;    

        % Reset step size bisection counter
        i_bisec = 0;

        % Linearize relevant subsystem at current operating point
        jaco = jj_lin (sys, x_u, n_x, i_t_v, i_t_r, del_lin, del_lin_type, constraintsInputsArray, constraintsStatesArray);

        % Singular Value Decomposition of the sensitivity matrix
        [u, s, v] = svd (jaco);

        % A singular value is assumed to be "zero", if it is 1e12 times smaller 
        % than the maximum singular value. Such a singular value indicates a rank deficiency.
        sv_min = s(1,1)*1e-12;

        % Find the indices of those "zero-singular-values"
        i_sv_zero = find (abs (diag (s)) <= sv_min);

        % If there are any zero-singular-values,
        if ~isempty (i_sv_zero) 

          % the jacobian matrix is singular.
          h1 = 'Singular Jacobian-Matrix';

          % Assemble cell arrays containing the names of all trim variables and trim requirements
          trim_variables = [x_nam; u_nam];
          trim_requirements = [d_nam; y_nam];

          % Loop over all zero-singular-values
          for i_sv = i_sv_zero'

            % Find those elements of the corresponding singular vectors that are not "zero"
            u_sing = find (abs (u(:,i_sv)) > sv_min);
            v_sing = find (abs (v(:,i_sv)) > sv_min);   

              % Separating empty line
              l0 = {' '};

            % If there is only one zero element in the left singular vector,
            if length (u_sing) == 1

              % prepare the corresponding error message
              l1 = {'The trim requirement'};
              l2 = trim_requirements(i_t_r(u_sing));
              l3 = {'could not be affected by any trim variable.'};       

            % If there are more than one zero element in the left singular vector
            else

              % prepare the corresponding error message
              l1 = {'The trim requirements'};
              l2 = trim_requirements(i_t_r(u_sing));
              l3 = {'linearly depend on each other.'};       

            end 

            % Separating empty line
            l4 = {' '};

            % If there is only one zero element in the right singular vector,
            if length (v_sing) == 1

              % prepare the corresponding error message
              l5 = {'The trim variable'};
              l6 = trim_variables(i_t_v(v_sing));
              l7 = {'does not affect any trim requirement.'};       

            % If there are more than one zero element in the right singular vector
            else

              % prepare the corresponding error message
              l5 = {'The trim variables'};
              l6 = trim_variables(i_t_v(v_sing));
              l7 = {'linearly depend on each other.'};       

            end 

            l8 = {'Chose different trim variables and/or trim requirements.'};
            l9 = {'Or try different initial values.'};

            % Separating empty line
            l10 = {' '};

            l11 = {'The returned trim point is not valid.'};
            l12 = {'You can use the Untrim menu entry to return to the pre-trim state.'};

            % Output error message
    %         disp(' ')
    %         disp(h1)
    %         disp(l1); disp(l2); disp(l3); disp(l4); disp(l5); disp(l6); disp(l7);
    %         disp(l8); disp(l9); disp(l10); disp(l11); disp(l12);
    %         disp(' ')
            %errordlg ([l0; l1; l2; l3; l4; l5; l6; l7; l4; l8; l9; l10; l11; l12], h1);

          end

          % Release system
          %feval (sys, [], [], [], 'term');

          % Game over
          j_trim=2;
          return

        end

        % Assuming a linear system, the alteration of the trim variables 
        % necessary to compensate the trim requirements error can directly 
        % be calculated by the inversion of the linear subsystem model
        % (differential equations and output equations)
        del_t_v = jaco\del_t_r;

        % Calculate maximum ratio between allowed and necessary trim step size
        ratio_t_v = del_t_v ./ del_max(i_t_v);
        max_rat = max (abs (ratio_t_v));

        % If allowed step size has been exceeded,
        if max_rat > 1

          % scale all state and input step sizes, 
          % in order to exploit most of the allowed step size
          del_t_v = del_t_v/max_rat;

        end

        % If no improvement has been obtained
        % with respect to the last point,
      else

        % and if step size has not been bisected ten times before,
        if i_bisec < n_bisect

          % bisect step size and change sign
          del_t_v = -del_t_v/2;

          % and increment bisection counter
          i_bisec = i_bisec + 1;

          % If step size has already been bisected ten times before,
        else

          % output error message and stop program
          l1 = ['Step size has been bisected ', int2str(n_bisect),' times.'];		% BKL 061808 Added bisection number
          l2 = ['Program was aborted after ', int2str(i_iter), ' iteration(s)'];   
          l3 = ['with a cost value of ', num2str(cost)];
          l4 = 'Try different initial values.';
          h1 = 'Program aborted';
          %disp(' ')
          %disp(h1)
          %disp(l1); %disp(l2); disp(l3); disp(l4);
          %disp(' ')
          %errordlg ({l1; l2; l3; l4}, h1);

          % Release system
          %feval (sys, [], [], [], 'term');

          % Game over
          j_trim=3;
          return

        end

      end

      % Calculate new trim point.
      % Always use old value *before* first bisection
      x_u(i_t_v) = x_u_old(i_t_v) + del_t_v;

      % Update input constraints
      for i = 1:size(constraintsInputsArray,1)
          if constraintsInputsArray(i,2) > 0
            x_u(constraintsInputsArray(i,1)+n_x) = x_u(abs(constraintsInputsArray(i,2))+n_x);
          else
            x_u(constraintsInputsArray(i,1)+n_x) = -x_u(abs(constraintsInputsArray(i,2))+n_x);
          end
      end
      
      % Update state constraints
      for i = 1:size(constraintsStatesArray,1)
          if constraintsStatesArray(i,2) > 0
            x_u(constraintsStatesArray(i,1)) = x_u(abs(constraintsStatesArray(i,2)));
          else
            x_u(constraintsStatesArray(i,1)) = -x_u(abs(constraintsStatesArray(i,2)));
          end
      end

      % Disassemble the generalized input vector
      x_tr = x_u(1:n_x);
      u_tr = x_u(n_x+1:end);

    end

    % If maximum number of iterations has been exceeded,
    % output error message and abort program
    l1 = ['Maximum number of iterations exceeded: ', int2str(i_iter)];   
    l2 = 'Program was aborted';   
    l3 = ['with a cost value of: ', num2str(cost)];
    h1 = 'Program aborted';
    %disp(' ')
    %disp(h1)
    %disp(l1); disp(l2); disp(l3);
    %disp(' ')
    %errordlg ({l1; l2; l3}, h1);
    j_trim=4;

    % Release system
    %feval (sys, [], [], [], 'term');
end
