classdef GainCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Data Storage
    properties  
        DesignOperatingCondition lacm.OperatingCondition = lacm.OperatingCondition.empty
        Gain ScatteredGain.Gain = ScatteredGain.Gain.empty
        SynthesisDesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty 
        RequirementDesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty 
        Filters UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        OperCondFilterSettings = UserInterface.ControlDesign.OperCondFilterSettings.empty
        Date
    end % Public properties
        
%     %% Public properties - Object Handles
%     properties ( Transient = true )  
%         Gain_Parent
%         Gain_Container
%         GainTable
%         Gain_LabelComp
%         Gain_LabelCont
% 
%         Req_Parent
%         Req_Container
%         ReqTable
%         Req_LabelComp
%         Req_LabelCont
% 
%     end % Public properties
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        Selected
        Color
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)
        DesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty  
    end % Dependant properties
    
%     %% Dependant properties
%     properties ( Dependent = true )
%         Gain_Units
%         Gain_Position  
%         Gain_Visible
%         Gain_Enable
%         GainTableData
%         
%         Req_Units
%         Req_Position  
%         Req_Visible
%         Req_Enable
%         ReqTableData
%     end % Dependant properties

        %% Private properties
    properties
        Gain_PrivatePosition = [0 0 1 1]
        Gain_PrivateUnits = 'normalized'
        Gain_PrivateVisible
        Gain_PrivateEnable
        
        Req_PrivatePosition = [0 0 1 1]
        Req_PrivateUnits = 'normalized'
        Req_PrivateVisible
        Req_PrivateEnable 
    end
    
%     %% Events
%     events
%         ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
%     end
    %% Methods - Constructor
    methods   
        
        function obj = GainCollection( varargin )
%             obj.DesignOperatingCondition = oc;
%             obj.Gain = gain;
%             obj.DesignParameter = param;
%             obj.Date = datestr(now);
            
            
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'OperatingCondition',lacm.OperatingCondition.empty);
            addParameter(p,'Gains',ScatteredGain.Gain.empty);
            addParameter(p,'SynthesisDesignParameter',ScatteredGain.Parameter.empty );
            addParameter(p,'RequirementDesignParameter',ScatteredGain.Parameter.empty );
            addParameter(p,'Filters',UserInterface.ControlDesign.Filter.empty );
            addParameter(p,'OperCondFilterSettings',UserInterface.ControlDesign.OperCondFilterSettings.empty );
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.DesignOperatingCondition = options.OperatingCondition;
            obj.Gain = options.Gains;
            %obj.DesignParameter = options.Parameters;
            obj.SynthesisDesignParameter = options.SynthesisDesignParameter;
            obj.RequirementDesignParameter = options.RequirementDesignParameter;
            obj.Filters = options.Filters;
            obj.OperCondFilterSettings = options.OperCondFilterSettings;
            
            obj.Date = datestr(now);
            
            check4RepeatedName( obj );
        end % GainCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.DesignParameter( obj )
            y = Utilities.rowcat(obj.SynthesisDesignParameter,obj.RequirementDesignParameter);
        end %DesignParameter     
              
    end % Property access methods
    
    %% Methods - Callbacks
    methods 

    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function check4RepeatedName( obj )
            try
                A = unique({obj.DesignParameter.Name});
                B = unique({obj.Gain.Name});
                C = intersect(A,B);
                if ~isempty(C)
                    error('GainCollection:InvalidName','The names must be unique between the gains and parameters.');
                end
            end
        end % check4RepeatedName

        function file = write2File(obj, ScatteredGainObjName)
        
            [file, path] = uiputfile(...
                {'*.csv';'*.*'},...
                'Save as');
        
            drawnow(); pause(0.5);
        
            fid = fopen(fullfile(path,file),'w');
        
            fprintf(fid,'%s\n','% -------------------------- GENERAL INFORMATION ---------------------------------------------');
            fprintf(fid,'\n');
            fprintf(fid,'%s%s\n',' SCATTERED GAINS COLLECTION',['  : ' ScatteredGainObjName]);
            fprintf(fid,'\n');
            fprintf(fid,'%s%s\n',' DATE                      ',['  : ' datestr(now)]);
            fprintf(fid,'\n');
        
            % Number of design conditions
            nCond = length(obj);
            if nCond > 0
                fprintf(fid,'%s%s\n',' NUMBER OF DESIGN CONDITIONS',[' : ' num2str(nCond)]);
                fprintf(fid,'\n');
                fprintf(fid,'%s\n\n','% ---------------------------- DESIGN DATA ---------------------------------------------------');
        
                DateVec(nCond) = datetime;
                for i=1:nCond
                    DateVec(i) = datetime(obj(i).Date);
                end
                [~,isort] = sort(DateVec);
        
                for i=isort
                    var = {};
                    val = {};
        
                    var{1} = 'Date';
                    val{1} = obj(i).Date;
        
                    var{2} = obj(i).OperCondFilterSettings.Parameter1_FC1_Str;
                    var{3} = obj(i).OperCondFilterSettings.Parameter2_FC2_Str;
                    var{4} = obj(i).OperCondFilterSettings.Parameter3_IOC_Str;
                    var{5} = obj(i).OperCondFilterSettings.Parameter4_WC_Str;
        
                    val{2} = num2str(obj(i).OperCondFilterSettings.Parameter1_FC1_Value);
                    val{3} = num2str(obj(i).OperCondFilterSettings.Parameter2_FC2_Value);
                    val{4} = num2str(obj(i).OperCondFilterSettings.Parameter3_IOC_Value);
                    val{5} = num2str(obj(i).OperCondFilterSettings.Parameter4_WC_Value);
        
                    % Gains
                    for j=1:length(obj(i).Gain)
                        var{end+1} = obj(i).Gain(j).Name;
                        val{end+1} = num2str(obj(i).Gain(j).Value);
                    end
        
                    % Unique Design Parameters
                    [~,ia] = unique({obj(i).DesignParameter.Name});
                    uniqueParams = obj(i).DesignParameter(ia);
                    for j=1:length(uniqueParams)
                        if isscalar(uniqueParams(j).Value)
                            var{end+1} = uniqueParams(j).Name;
                            val{end+1} = num2str(uniqueParams(j).Value);
                        end
                    end
        
                    % Write as CSV
                    fprintf(fid, '%s\n', strjoin(var, ','));
                    fprintf(fid, '%s\n', strjoin(val, ','));
                    fprintf(fid, '\n');
                end
        
            else
                fprintf(fid,'%s%s\n','% NUMBER OF DESIGN CONDITIONS',[' : 0']);
                fprintf(fid,'%s\n','%');
                fprintf(fid,'%s\n','%');
                fprintf(fid,'%s\n','% -------------------------- END OF FILE -----------------------------------------------');
            end
        
            fclose(fid);
        end   
%         function file = write2File( obj, ScatteredGainObjName)
%             
%             
%             [file, path] = uiputfile(...
%                 {'*.txt';'*.*'},...
%                 'Save as');
%             
%             drawnow();pause(0.5);
%             
%             
%             fid = fopen(fullfile(path,file),'w');
%             
%             fprintf(fid,'%s\n','% -------------------------- GENERAL INFORMATION ---------------------------------------------');
%             fprintf(fid,'\n');
%             fprintf(fid,'%s%s\n',' SCATTERED GAINS COLLECTION',['  : ' ScatteredGainObjName]);
%             fprintf(fid,'\n');
%             fprintf(fid,'%s%s\n',' DATE                      ',['  : ' datestr(now)]);
%             fprintf(fid,'\n');
%             
%             
%             % Number of design conditions
%             nCond = length(obj);
%             if nCond > 0
%                 fprintf(fid,'%s%s\n',' NUMBER OF DESIGN CONDITIONS',[' : ' num2str(nCond)]);
%                 fprintf(fid,'\n');
%                 fprintf(fid,'%s\n\n','% ---------------------------- DESIGN DATA ---------------------------------------------------');
%                 
%                 DateVec(nCond) = datetime;
%                 for i=1:nCond
%                     DateVec(i) = datetime(obj(i).Date);
%                 end
%                 [~,isort] = sort(DateVec);
%                 
%                 
%                 for i=isort
%                     
%                     var{1} = 'Date';
%                     val{1} = obj(i).Date;
%                     
%                     var{2} = obj(i).OperCondFilterSettings.Parameter1_FC1_Str;
%                     var{3} = obj(i).OperCondFilterSettings.Parameter2_FC2_Str;
%                     var{4} = obj(i).OperCondFilterSettings.Parameter3_IOC_Str;
%                     var{5} = obj(i).OperCondFilterSettings.Parameter4_WC_Str;
%                     
%                     val{2} = obj(i).OperCondFilterSettings.Parameter1_FC1_Value;
%                     val{3} = obj(i).OperCondFilterSettings.Parameter2_FC2_Value;
%                     val{4} = obj(i).OperCondFilterSettings.Parameter3_IOC_Value;
%                     val{5} = obj(i).OperCondFilterSettings.Parameter4_WC_Value;
%                     
%                     
%                     for j=1:length(obj(i).Gain)
%                         var{end+1}=obj(i).Gain(j).Name;
%                         val{end+1}=num2str(obj(i).Gain(j).Value);
%                     end
%                     
%                     [~,ia]=unique({obj(i).DesignParameter.Name});
%                     uniqueParams = obj(i).DesignParameter(ia);
%                     
%                     for j=1:length(uniqueParams)
%                         if isscalar(uniqueParams(j).Value)
%                             var{end+1}=uniqueParams(j).Name;
%                             val{end+1}=num2str(uniqueParams(j).Value);
%                         end
%                     end
%                     
%                     nvar = length(var);
%                     
%                     formatSpec = ['%-25s',repmat('%-20s',[1,nvar-1]),'\n'];
%                     
%                     vars = strjoin(strtrim(var),''',''');
%                     vals = strjoin(strtrim(val),''',''');
% 
%                     eval(['fprintf(fid,''' formatSpec ''',''' vars ''');']);
%                     eval(['fprintf(fid,''' formatSpec ''',''' vals ''');']);
%                     fprintf(fid,'\n');
%                     
%                     clear var val
%                    
%                 end
%                 
%             else
%                 fprintf(fid,'%s%s\n','% NUMBER OF DESIGN CONDITIONS',[' : 0']);
%                 fprintf(fid,'%s\n','%');
%                 fprintf(fid,'%s\n','%');
%                 fprintf(fid,'%s\n','% -------------------------- END OF FILE -----------------------------------------------');
%               
%             end
%                 
%             
%             
%             fclose(fid);
%             
% 
%         end % write2File  

        function y = eq(A,B)
            if isempty(A) || isempty(B)
                y = false;
            elseif length(A) == length(B)
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                y = false(1,length(B));
                for i = 1:length(B)
                    if A.DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end   
            elseif length(A) > 1 && length(B) == 1
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B.DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end     
            end
        end % eq
        
    end % Ordinary Methods    
       
    
    %% Methods - Protected
    methods (Access = protected)     

        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DesignOperatingCondition object
            cpObj.DesignOperatingCondition = copy(obj.DesignOperatingCondition);
            % Make a deep copy of the Gain object
            cpObj.Gain = copy(obj.Gain);
            % Make a deep copy of the SynthesisDesignParameter object
            cpObj.SynthesisDesignParameter = copy(obj.SynthesisDesignParameter);  
            % Make a deep copy of the RequirementDesignParameter object
            cpObj.RequirementDesignParameter = copy(obj.RequirementDesignParameter);    
            % Make a deep copy of the Filter object
            cpObj.Filters = copy(obj.Filters);  
        end % copyElement
        
    end
    
    %% Methods - Private
    methods ( Access = private )
        

        
    end
    
    %% Methods - Static
    methods (Static)

    end
    
    
end


