classdef SchGainCollection < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties  
        Name char
        Gain ScheduledGain.SchGain = ScheduledGain.SchGain.empty
        IncludedGains
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        
        
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)
        Gains2BeCompleted
    end % Dependant properties
    
    %% View Properties
    properties( Hidden = true , Transient = true )

    end

    %% Private Properties
    properties( Access = private )
        
    end 
    
    %% Methods - Constructor
    methods   
        
        function obj = SchGainCollection( name , gains )
            switch nargin
                case 1
                    obj.Name = name;  
                case 2
                    obj.Name = name; 
                    if iscellstr(gains)
                        obj.IncludedGains = gains;
                    elseif ischar(gains)
                        obj.IncludedGains = {gains};
                    elseif isa(gains,'ScheduledGain.SchGain')
                        obj.Gain            = gains;
                        obj.IncludedGains = {gains.Name};
                    end
            end

        end % SchGainCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function y = get.Gains2BeCompleted( obj )
            y = {};
            for i = 1:length(obj.IncludedGains)
                logArray = strcmp(obj.IncludedGains{i},{obj.Gain.Name});
                if ~any(logArray)
                    y{ end + 1 } = obj.IncludedGains{i};
                else
                    if obj.Gain(logArray).Complete
                        y{ end + 1 } = obj.Gain(logArray).Name;
                    end
                end
            end
        end % Gains2BeCompleted
        
        
    end % Property access methods

    %% Methods - Callbacks
    methods 
 
    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function [gainObj,usable] = updateGain( obj , scattGainVec )
            
            selGain = findGain(obj,scattGainVec.ScatteredGainName);
            %selGain = findGainByUserName(obj,scattGainVec.ScatteredGainName);
            
            if ~isempty(selGain);[selGain.SchGainVec.Current] = deal(false);end
            
            
            if isempty(selGain) 
            % Create New Gain  
                obj.Gain(end + 1) = ScheduledGain.SchGain( 'SchGainVec' , scattGainVec );
                gainObj = obj.Gain(end);
                usable = obj.Gain(end).Complete;
            elseif scattGainVec.NumberOfDimensions == 1
            % Overwrite Existing Gain with 1-D
                logArray = strcmp(selGain.Name,{obj.Gain.Name});
                obj.Gain(logArray) = ScheduledGain.SchGain( 'SchGainVec' , scattGainVec );
                gainObj = obj.Gain(logArray);
                usable = obj.Gain(logArray).Complete;
            else
                % Partially overwrite or add to an existing gain  
                if length(selGain.SchGainVec) == 1 && scattGainVec.NumberOfDimensions == 2
                    logArray = (selGain == scattGainVec);
                    if any(logArray)
                    % Replace existing SchGainVec
                        selGain.SchGainVec(logArray) = copy(scattGainVec);
                    else
                        selGain.SchGainVec( end + 1 ) = copy(scattGainVec);
                    end
                    gainObj = selGain;
                    usable = gainObj.Complete;
                else
                    if length(selGain.Breakpoints2Values) == length(scattGainVec.BreakPoints2) && ...
                            ~all(round(selGain.Breakpoints2Values,10,'significant') == round(scattGainVec.BreakPoints2,10,'significant')) || ...
                            length(selGain.Breakpoints2Values) ~= length(scattGainVec.BreakPoints2)
                        choice = questdlg({'The BreakPoint values have changed for the selected scheduled Gain.',...
                            'Would you like to overwrite the variable or update all the breakpoints with the new values?'}, ...
                            'BreakPoints Changed?', ...
                            'Overwrite','Update','Cancel','Cancel');
                        
                        drawnow;pause(0.1);
                        
                        % Handle response
                        switch choice
                            case 'Overwrite'
                                logArray = strcmp(selGain.Name,{obj.Gain.Name});
                                obj.Gain(logArray) = ScheduledGain.SchGain( 'SchGainVec' , scattGainVec );
                                gainObj = obj.Gain(logArray);
                                usable = obj.Gain(logArray).Complete;
                            case 'Update'
                                selGain.updateBreakpoints();
                            case 'Cancel'
                                return;
                        end 
                    else
                        logArray = (selGain == scattGainVec);
                        if any(logArray)
                        % Replace existing SchGainVec
                            selGain.SchGainVec(logArray) = copy(scattGainVec);
                        else
                            selGain.SchGainVec( end + 1 ) = copy(scattGainVec);
                        end
                        gainObj = selGain;
                        usable = gainObj.Complete;
                    end

                end
            end      
            
        end % updateGain
        
        function addNewGain( obj , scattGainVec, name)
            % Create New Gain  
                obj.Gain(end + 1) = ScheduledGain.SchGain( 'SchGainVec' , scattGainVec, 'Name', name );
        end % addNewGain
        
        function createSimulinkBlocks( obj )
            
            varname = genvarname([obj.Name,'LookupTables']);
            try
                h = new_system( varname, 'ErrorIfShadowed'); 
            catch
                button = questdlg([obj.Name,' exists on the path. Do you want to overwrite?'],...
                'Overwrite?','Yes','No','No');
                if strcmp(button,'Yes')
                   h = new_system( varname); 
                elseif strcmp(button,'No')
                   return;
                end
            end
            open_system(h);
            sysName = get_param(h,'Name');  
            
            pad = 0;
            for i = 1:length(obj.Gain) 
                switch obj.Gain(i).Ndim
                    case 1

                        lookupTableName = [sysName,'/',obj.Gain(i).Name];
                        block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                            'NumberOfTableDimensions','1',...
                                            'BreakpointsForDimension1', [obj.Gain(i).Name,'.',obj.Gain(i).BreakPoints2Name] ,...
                                            'Table','TableData',...
                                            'InterpMethod','Linear',...
                                            'ExtrapMethod','Clip',...
                                            'Position', [ 370 , 13 , 435 , 77 ]);






                    case 2

                        lookupTableName = [sysName,'/',obj.Gain(i).Name];
                        block = add_block('simulink/Lookup Tables/n-D Lookup Table', lookupTableName,...
                                            'NumberOfTableDimensions','2',...
                                            'BreakpointsForDimension1', [obj.Gain(i).Name,'.',obj.Gain(i).BreakPoints1Name],... %obj.Gain(i).BreakPoints1Name ,...
                                            'BreakpointsForDimension2', [obj.Gain(i).Name,'.',obj.Gain(i).BreakPoints2Name],... %obj.Gain(i).BreakPoints2Name ,...
                                            'Table',[obj.Gain(i).Name,'.TableData'],...%'TableData',...
                                            'InterpMethod','Linear',...
                                            'ExtrapMethod','Clip',...
                                            'Position', [ 375 , 5 - pad , 480 , 105 - pad ]);
                    
                end
                
                pad = pad + 120;
            end
            
            
        end % createSimulinkBlock
        
    end
    
    %% Methods - Ordinary
    methods 
        
        function y = getLookUpTableData( obj )
       
        end % getLookUpTableData
        
        function [y,logArray] = findGain( obj , name )
            logArray = strcmp(name,{obj.Gain.ScatteredGainName});
%             logArray = strcmp(name,{obj.Gain.Name});
            y = obj.Gain(logArray);
        end % findGain
        
        function [y,logArray] = findGainByUserName( obj , name )
            if isempty(obj)
                logArray = [];
                y = [];
            else
                logArray = strcmp(name,{obj.Gain.Name});
                y = obj.Gain(logArray);
            end
        end % findGainByUserName
        
        function y = findGainScatt( obj , name )
            logArray = strcmp(name,{obj.Gain.ScatteredGainName});
            y = obj.Gain(logArray);
        end % findGainScatt
        
    end % Ordinary Methods
    
    %% Methods - View
    methods 
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Gain object
            cpObj.Gain = copy(obj.Gain);
        end
    end
    
    %% Methods - Private - Trim Methods
    methods ( Access = private )
        
        
    end 
    
    %% Methods - Private
    methods ( Access = private )
        

        
    end
    
    %% Methods - Static
    methods (Static)

    end
end
