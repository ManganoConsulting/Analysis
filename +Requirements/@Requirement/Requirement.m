classdef Requirement < matlab.mixin.Copyable
    
    %% Public Observable properties
    properties  (SetObservable) 
        FunName       = ''              % handle to the method
        Title         = ''              % title 
        MdlName       = ''              % name of the model used by the method
%         OutputDataIndex = 1;        % output index number to use
%         
%         RequiermentPlot
%         BackgroundPlotFunc
%         
%         IterativeRequierment = true
        
        PlotData%@Requirements.NewLine
    end % Public properties
   
    %% Dependant properties
    properties (Dependent = true)
        ModelWorkspace   % a handle to the modelworkspace
    end % Dependant properties

    %% Hidden properties
    properties (Hidden = true)       
        SelectedStatus   % used only by the tool to store a string of the selected status
        FileName = 'Untitled'
    end % Hidden properties

    %% Constructor
    methods      
        function r = Requirement(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % requirement    
    end % Constructor
    
    %% Property access methods
    methods
        function wrksp = get.ModelWorkspace(obj) 
            if ~isempty(obj.MdlName)
               load_system(obj.MdlName);
               wrksp = get_param(obj.MdlName,'modelworkspace');
            else 
                wrksp = [];
            end
        end   
    end % Property access methods
    
    %% Ordinary Methods
    methods 
        function handle = getFunctionHandle(obj)
            handle = [];
            if ~isempty(obj.FunName)
                handle = str2func(obj.FunName);
            end
        end % getFunctionHandle
    
        function parameters = getModelWorspaceData(obj)
            warning('off','Simulink:Data:WksGettingDataSource')
            parameters = UserInterface.ControlDesign.Parameter.empty;
            if ~isempty(obj.MdlName)
                obj.ModelWorkspace.clear;
                if ~strcmp(obj.ModelWorkspace.DataSource,'Model File')
                    obj.ModelWorkspace.reload;
                end
                workspaceData = obj.ModelWorkspace.data;
                for k = 1:length(workspaceData)
                    parameters(k)  = UserInterface.ControlDesign.Parameter('Name',workspaceData(k).Name,'String',workspaceData(k).Value);
                end
            end
        end % getModelWorspaceData
        
        function uniqueMdlNames = getUniqueModels ( obj )
            if ~isempty(obj)
                uniqueMdlNames = unique({obj.MdlName});
                uniqueMdlNames = uniqueMdlNames(~cellfun('isempty',uniqueMdlNames));
            else
                uniqueMdlNames = {};
            end
        end % getUniqueModels
                
    end % Ordinary Methods
   
    %% Methods - Protected
    methods (Access = protected)  
        
        function updateModelParameters( obj , designOC , paramColl )
        %------------------------------------------------------------------
        % - UPDATE MODEL WORKSPACE WITH PARAMETERS
        %------------------------------------------------------------------
            wrkspace = obj.ModelWorkspace;
            if ~isempty(obj.ModelWorkspace)
                for i = 1:length(paramColl.Parameters)
                    varName = paramColl.Parameters(i).Name;
                    varName = deblank(varName);
                    newValue = evalDesignParameters( paramColl.Parameters(i) , paramColl , designOC );
                    wrkspace.assignin(varName,newValue);
                end
            end
        
        end % updateModelParameters
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            %cpObj.Tree = copy(obj.Tree);
        end 
    end
    
    %% Methods - Static
    methods(Static)
        function assign2Model(mdlName,varargin)       
            load_system(mdlName);
            wrkspace = get_param(mdlName,'modelworkspace');
            if ~isempty(wrkspace)
                for i = 1:length(varargin)    
                    wrkspace.assignin(inputname(i+1),varargin{i});
                end
            end
        end % assign2Model     

        
    end % Methods - Static
end

% function newValue = evalDesignParameters( param , paramColl , designOC )
% %--------------------------------------------------------------------------
% % - Evaluate all user defined design parameters
% %--------------------------------------------------------------------------
% 
% %find requirement associated with the user selected value
% 
% try
%     newValue = param.Value;  
% catch
%     symVars = Utilities.symVarAll(param.ValueString);
%     symValue = cell(size(symVars));
%     evalString = param.ValueString;
%     for j = 1:length(symVars)
%         % get the value from a parameter
%         nextValue = getValue(paramColl,symVars{j});
%         if isempty(nextValue)
%             % find the condtion
%             %try
%                 uniqueField = findUnigueField( designOC , symVars{j} );
%                 if ~isempty(uniqueField)  
%                     nextValue = mat2str(eval(['designOC.',uniqueField]));
%                 else
%                     nextValue = symVars{j};
%                 end
%             %catch
%               %  error('No symbolic value found in the parameter table');
%             %end 
% %                             else
% %                                 symValue(j) = nextValue;
%         else 
%             nextValue = mat2str(nextValue);
%         end
%         symValue{j} = nextValue;
%         evalString = strrep(evalString, symVars{j}, nextValue);
%     end
% 
%     newValue = eval(evalString);
% end
% 
% end % evalDesignParameters

















