classdef TrimOptions < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true, Hidden = true)
        Parent
        OptionsTable
        DefaultButton
    end % Public properties
    
    %% Public properties - Data Storage
    properties   
%         TableData = {'Maximum number of iterations:', 42;...
%                         'Maximum cost function value:', 1e-9;...
%                         'Maximum Bisection counter', 10;...
%                         'State pertubation size for Jacobian:', 1e-6;...
%                         'Input pertubation size for Jacobian:', 1e-6;}
                    
        MaxInterations = 42
        MaxCostFunction = 1e-9
        MaxBisection = 10
        StatePertubationSize = 1e-6
        InputPertubationSize = 1e-6
    end % Public properties
    
    %% Properties - Observable
    properties (SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )  
        PrivateVisible
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true, Hidden = true )
        Position
        Units
        Visible
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private, Hidden = true )
        TableData
    end % Dependant properties
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = TrimOptions(show)%, MaxInterations, MaxCostFunction, MaxBisection, StatePertubationSize, InputPertubationSize) 
            if nargin == 0
               show = true; 
            end  

            
%                 MaxInterations = MaxInterations;
%                 MaxCostFunction = MaxCostFunction;
%                 MaxBisection = MaxBisection;
%                 StatePertubationSize = StatePertubationSize;
%                 InputPertubationSize = InputPertubationSize;
            
            
            
            if show
                createView( obj );
            end

        end % TrimOptions
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Container,'Visible','on');
            else
                set(obj.Container,'Visible','off');
            end            
        end % Visible - Set
        
        function y = get.Visible(obj)
            y = obj.PrivateVisible;          
        end % Visible - Get
        
        function TableData = get.TableData(obj)
            TableData = {'Maximum number of iterations:', obj.MaxInterations;...
                    'Maximum cost function value:', obj.MaxCostFunction;...
                    'Maximum Bisection counter', obj.MaxBisection;...
                    'State pertubation size for Jacobian:', obj.StatePertubationSize;...
                    'Input pertubation size for Jacobian:', obj.InputPertubationSize;};
        end
        
    end % Property access methods
    
    %% Methods - View
    methods     
        function createView( obj )
        
            % Resize and reposition the window
            pos = get(0,'MonitorPositions');
%             width = 600;
%             height = pos(1,4)*0.75;
            
            %822   553   378   163
            
            width = 378;
            height = 163;
            
            x0 =  (pos(1,3) - width)/2;%pos(1,1) - (pos(1,3)-width)/2;
            y0 =  (pos(1,4)*0.25)/2 + 300;%pos(1,2) + (pos(1,4)-height)/2;

            
            
            obj.Parent = figure('Name','Trim Algorithm Options',...
                    'units','pixels',...
                    'Position',[x0, y0, width, height],...
                    'Menubar','none',...   
                    'Toolbar','none',...
                    'NumberTitle','off',...
                    'HandleVisibility', 'on',...
                    'Visible','on',...
                    'Tag','TrimOptions',...
                    'CloseRequestFcn', @obj.closeFigure_CB);
                
                
            obj.OptionsTable = uitable(obj.Parent,...
                'ColumnName',{'Parameter','Value'},...
                'RowName',[],...
                'ColumnEditable', [ false , true],...
                'ColumnFormat',{'Char','Numeric'},...
                'ColumnWidth',{220,80},...
                'Data',obj.TableData,...
                'Units','Normal',...
                'Position',[ 0.1 , 0.2 , 0.8 , 0.7 ],...
                'CellEditCallback', @obj.table_ce_CB,...
                'CellSelectionCallback', @obj.table_cs_CB);   
            
            obj.DefaultButton = uicontrol('Parent',obj.Parent,...
                'Style','push',...
                'FontSize',8,...
                'String','Restore Defaults',...
                'ForegroundColor',[0 0 0],...
                'Units','Normal',...
                'Position',[ 0.1 , 0.05 , 0.8 , 0.15 ],...
                'Callback',@obj.defaultButton_CB); 

        end % createView
    end
    
    %% Methods - Ordinary
    methods 
        

        
    end % Ordinary Methods

    %% Methods - Protected Callbacks
    methods (Access = protected) 
        
        function table_ce_CB(obj , ~ , eventData )

            selRow = eventData.Indices(1);
            
            switch selRow
                case 1
                    obj.MaxInterations = eventData.NewData;
                case 2
                    obj.MaxCostFunction = eventData.NewData;
                case 3
                    obj.MaxBisection = eventData.NewData;
                case 4
                    obj.StatePertubationSize = eventData.NewData;
                case 5
                    obj.InputPertubationSize = eventData.NewData;                  
            end
        
        end % table_ce_CB
        
        function table_cs_CB(obj , ~ , eventData )

        end % table_cs_CB.
        
        function defaultButton_CB(obj , ~ , eventData )
            obj.MaxInterations = 42;
            obj.MaxCostFunction = 1e-9;
            obj.MaxBisection = 10;
            obj.StatePertubationSize = 1e-6;
            obj.InputPertubationSize = 1e-6;
            
            obj.OptionsTable.Data = obj.TableData;
        end % defaultButton_CB

        function closeFigure_CB( obj, hobj, ~)
            delete(hobj);
            
        end % closeFigure_CB

    end

    %% Methods - Protected
    methods (Access = protected)  

        
    end
    
    %% Method - Copy
    methods (Access = protected) 
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);

        end
    end
    
end


