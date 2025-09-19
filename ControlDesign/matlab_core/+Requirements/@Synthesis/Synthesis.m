classdef Synthesis < Requirements.Requirement
    
    %% Public properties
    properties

    end % Public properties
    
    %% Hidden Properties   
    properties (Hidden = true)
        ScatteredGainsFileObj
    end % Hidden Properties

    %% Hidden Transient View Properties
    properties (Hidden = true , Transient = true )       
        Parent
        Container
        EditPanel
        EditGridContainer
        
        ViewMethodPB
        MethodText
        MethodEB
        ViewModelPB
        ViewModelText
        MdlNameEB
        TitleText
        TitleEB
        
        BrowseStartDir = pwd

    end % Hidden Transient View Properties
    
    %% Methods - Constructor
    methods
        function obj = Synthesis(fname,model,title)
            if nargin == 3
                obj.FunName = fname;
                obj.MdlName = model;
                obj.Title = title;
            end
        end % Synthesis
    end % Methods - Constructor

    %% Methods - Ordinary
    methods
        
        function [gainStruct,mdlParamsCellArray,uniqueMdlNames] = run( obj , designOC , params )
            % designOC = currently selected design operating conditions
            % params   = parameters that need to be assigned to the model
            import UserInterface.ControlDesign.Utilities.*
            gainStruct = cell(1,length(designOC));
            mdlParamsCellArray = {};
            uniqueMdlNames = {};
            for i = 1:length(designOC)
                % Determine the unique Simulink models defined by the selected
                % synthesis objects
                uniqueMdlNames = getUniqueModels(obj); 

                
                % Assign the evlauated user defined parameters to the unique
                % models
                for j = 1:length(uniqueMdlNames)
                    mdlParams{i} = assignParameters2Model( uniqueMdlNames{j} , params{i}, 1 ); %#ok<*AGROW>
                end 
                mdlParamsCellArray = mdlParams;
                % get the function handle
                funHandle = obj.getFunctionHandle;
                % run the user designed function
                if ~isempty(designOC)
                    gainStruct{i} = funHandle( designOC , obj.MdlName , mdlParams );
                else
                    close_system(obj.MdlName,0); 
                    error('At least one Design Condition must be selected.');
                end
                close_system(obj.MdlName,0); 
             
                
            end 
        end % run
        
        function names = getStateNames(obj)
            load_system(obj.MdlName);
            stateSignals = Simulink.BlockDiagram.getInitialState(obj.MdlName);
            names = {stateSignals.signals.stateName}; 
        end % getStateNames

        function assignGains(obj,varName,varValue)
            wrkspace = obj.modelWorkspace;
            wrkspace.assignin(varName,varValue);
        end % assignGains

        function mdlVars = getAllGainsAsMdlVars(obj)
            mdlVarsState = obj.StateGains.getAsMdlVars();
            mdlVarsGain  = obj.Gains.getAsMdlVars();
            mdlVars = [mdlVarsState,mdlVarsGain];

        end % getAllGainsAsMdlVars

        function names = getAllGainNames(obj)

            names = [{obj.StateGains.Name},{obj.Gains.Name}];

        end % getAllGainsAsMdlVars  

    end % Methods - Ordinary
    
    %% Methods - View
    methods
        
        function createView( obj , parent )
            obj.Parent = parent;
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);%,...
                set(obj.Container,'ResizeFcn',@obj.resizeFcn);
                % Edit Panel
                contPosition = getpixelposition(obj.Container);
                obj.EditPanel = uipanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[1 , contPosition(4) - 159 , contPosition(3) , 159],...%[0,0.7,1,0.3],...
                    'ResizeFcn',@obj.editPanelResize);
                
                     obj.EditGridContainer = uigridcontainer('v0','Parent',obj.EditPanel,...
                        'Units','Normal',...
                        'Position',[0,0,1,1],...
                        'GridSize',[7,3],...
                        'HorizontalWeight',[1,3,6]);
                        % Method
                        obj.ViewMethodPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewMethod);
                        obj.MethodText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Method:',...
                            'HorizontalAlignment','Right');
                        obj.MethodEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'FunName'});
                        % Model Name  
                        obj.ViewModelPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','Browse',...
                            'Callback',@obj.viewModel);
                        obj.ViewModelText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Model Name:',...
                            'HorizontalAlignment','Right');
                        obj.MdlNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'MdlName'}); 
                        % Title 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.TitleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Title:',...
                            'HorizontalAlignment','Right');
                        obj.TitleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Title'});


            update(obj);
                      
        end % createView      
        
    end % Methods - View
        
    %% Methods - Protected Callbacks
    methods
        
        function reqUpdate( obj , hobj , ~ , type )
            value = get(hobj,'String');
            testValue = str2double(value);
            if length(testValue) == 1 && isnan(testValue)
                newValue = value;
            else
                newValue = testValue;
%                 try
%                     newValue = eval(value);
%                 catch
%                     newValue = value;
%                 end
            end
            obj.(type) = newValue;

            update(obj);

        end % reqUpdate
                
        function saveReqUpdate( obj , ~ , ~ )
            
            obj.plotRefresh = 1;
            
            filename = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).objPath;
            %eval([filename(1:end-4),'=cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex);']);
            saveVarStruct.(filename(1:end-4)) = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex); %#ok<STRNU>
            filepath = which(filename);
            save(filepath, '-struct','saveVarStruct');
        end % saveReqUpdate       
        
        function viewMethod( obj , ~ , ~ )
            
            [filename, pathname] = uigetfile({'*.m'},'Select Method File:',fullfile(obj.BrowseStartDir,obj.FunName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.FunName = file;
                update(obj);
            end
            
        end % viewMethod

        function viewModel( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:',fullfile(obj.BrowseStartDir,obj.MdlName));
            drawnow();pause(0.5);
            if ~isequal(filename,0)
                obj.BrowseStartDir = pathname;
                [~,file,~] = fileparts(filename);
                obj.MdlName = file;
                update(obj);
            end
            
        end % viewModel
   
    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        function update( obj )
            obj.MethodEB.String = obj.FunName;
            obj.MdlNameEB.String = obj.MdlName;
            obj.TitleEB.String = obj.Title;
            
        end % update
            
        function editPanelResize( obj , ~ , ~ )
  
        end % editPanelResize
        
        function resizeFcn( obj , ~ , ~ )
            % get figure position
            contPosition = getpixelposition(obj.Container);

            set(obj.EditPanel,'Units','Pixels');
            set(obj.EditPanel,'Position',[1 , contPosition(4) - 159 , contPosition(3) , 159] ); 
        end % resizeFcn
        
    end % Methods - Protected
   
end

