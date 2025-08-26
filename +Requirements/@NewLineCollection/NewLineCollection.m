classdef NewLineCollection < matlab.mixin.Copyable
    %% Public properties 
    properties
        NewLine Requirements.NewLine = Requirements.NewLine.empty
        XLim                                    % limit of the x-axis
        YLim                                    % limit of the y-axis
        ZLim                                    % limit of the z-axis
        PatchXData                              % x values of the patch object
        PatchYData                              % y values of the patch object
        PatchFaceColor = {[ 1,0.898,0.898 ]}    % Color associated with the face of the patch data
        PatchEdgeColor = {[ 0,0,0 ]}            % Color associated with the edge of the patch data
        XLabel                                  % label of the x axis
        YLabel                                  % label of the y axis
        yAxisLocation = 'left'                  % location of the y axis display
        GridFunction                            % method to set up a grid on the axes
        Grid          = 1                       % show grid
        XScale        = 'linear'                % x axis scaling
        YScale        = 'linear'                % y axis scaling
        ZScale        = 'linear'                % z axis scaling
        Title
        GridColor
        GridAlpha
        GridLayer
        
        AxisProperties
        PatchObject
    end % Public properties
   
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties

    %% Hidden Properties
    properties (Hidden = true)
        LineH
        axH
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Method - Constructor
    methods      
        function obj = NewLineCollection(varargin)
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addOptional(p,'NewLine',Requirements.NewLine.empty);
            addParameter(p,'AxisProperties',[]);
            addParameter(p,'PatchObject',{});
            addParameter(p,'XLim',[]);
            addParameter(p,'YLim',[]);
            addParameter(p,'ZLim',[]);
            addParameter(p,'PatchXData',{});
            addParameter(p,'PatchYData',{});
            addParameter(p,'PatchFaceColor',{[ 1,0.898,0.898 ]});
            addParameter(p,'PatchEdgeColor',{[ 0,0,0 ]} );
            addParameter(p,'XLabel','');
            addParameter(p,'YLabel','');
            addParameter(p,'Title','');
            addParameter(p,'yAxisLocation','left');
            addParameter(p,'GridFunction',[]);
            addParameter(p,'Grid',true);
            addParameter(p,'XScale','linear');
            addParameter(p,'YScale','linear');
            addParameter(p,'ZScale','linear');
            addParameter(p,'GridColor',[0.15 , 0.15 , 0.15 ]);
            addParameter(p,'GridAlpha',0.15);
            addParameter(p,'GridLayer','bottom');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.NewLine         = options.NewLine;
            obj.XLim            = options.XLim;
            obj.YLim            = options.YLim;
            obj.ZLim            = options.ZLim;
            obj.PatchXData      = options.PatchXData;
            obj.PatchYData      = options.PatchYData;
            obj.PatchFaceColor  = options.PatchFaceColor;
            obj.PatchEdgeColor  = options.PatchEdgeColor;
            obj.XLabel          = options.XLabel;
            obj.YLabel          = options.YLabel;
            obj.yAxisLocation   = options.yAxisLocation;
            obj.GridFunction    = options.GridFunction;
            obj.Grid            = options.Grid;
            obj.XScale          = options.XScale;
            obj.YScale          = options.YScale; 
            obj.ZScale          = options.ZScale;
            obj.Title           = options.Title;  
            obj.GridColor       = options.GridColor;
            obj.GridAlpha       = options.GridAlpha;
            obj.GridLayer       = options.GridLayer;
            
            obj.AxisProperties  = options.AxisProperties;
            obj.PatchObject     = options.PatchObject;
            
        end % NewLineCollection   
    end % Constructor
    
    %% Methods - Property Access
    methods
        
%         function set.PatchXData( obj , value )
%             if isnumeric(value)
%                 obj.PatchXData = {value};
%             elseif iscell
%                 obj.PatchXData = value;
%             else
%                 error('Must be a 1-D vector of a cell array of vectors.');
%             end            
%         end % PatchXData
        
        function set.Grid(obj,value)
            if ischar(value)
                if strcmpi(value,'on')
                    obj.Grid = true;
                elseif strcmpi(value,'off')
                    obj.Grid = false;
                else
                    error('Grid property must be 1,0,''on'', or ''off''');
                end
            end
        end % Grid
        
        function set.PatchXData(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchXData = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchXData = {value};
            end
        end % PatchXData
        
        function set.PatchYData(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchYData = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchYData = {value};
            end
        end % PatchYData
        
        function set.PatchFaceColor(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchFaceColor = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchFaceColor = {value};
            end
        end % PatchFaceColor
        
        function set.PatchEdgeColor(obj,value)
            if iscell(value)
                for i = 1:length(value)
                    if iscolumn(value{i})
                        value{i} = value{i}';
                    end
                end
                obj.PatchEdgeColor = value;
            else
                if iscolumn(value)
                    value = value';
                end
                obj.PatchEdgeColor = {value};
            end
        end % PatchEdgeColor
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
        function handle = getGridFunctionHandle(obj)
            handle = [];
            if ~isempty(obj.GridFunction)
                handle = str2func(obj.GridFunction);
            end
        end % getGridFunctionHandle

        function obj = plotLine(obj,data,rgb)
            % get handle to the function
            funHandle = obj.getFunctionHandle;
            % determine the number of output arguments
            numOutArg = nargout(funHandle);

            % call the function and return data
            switch numOutArg
                case 2
                    [Y,Y] = funHandle(data,obj.MdlName);

                case 3
                    [X,Y,mrk] = funHandle(data,obj.MdlName); 
                    % plot markers and add legend
                    for i = 1:length(mrk) 
                        obj.lineH(end+1) = line(mrk(i).x,mrk(i).y,...
                            'Parent',obj.axH,...
                            'Color',rgb,...
                            'Marker',mrk(i).Marker,...
                            'MarkerSize',mrk(i).MarkerSize,...
                            'MarkerEdgeColor',mrk(i).MarkerEdgeColor,... 
                            'MarkerFaceColor',mrk(i).MarkerFaceColor);
                    end
                    if any(arrayfun(@(x) ~isempty(x.LegendTitle),mrk))
%                         legend(obj.axH,obj.lineH,{mrk.LegendTitle},'Location','best' );
                        legObjH = legend(obj.axH,obj.lineH,{mrk.LegendTitle},'Location','best' );
                        set(obj.axH,'UserData',legObjH);
                    end
            end
            if isnumeric(X)
                X = {X};
                Y = {Y};
            end
            % plot the normal X and Y data
            for i = 1:length(X) 
                % plot the data
                obj.lineH(end+1) = line(X{i},Y{i},...
                    'Parent',obj.axH,...
                    'Color',rgb,...
                    'Marker',obj.Marker,...
                    'MarkerSize',obj.MarkerSize,...
                    'MarkerFaceColor',rgb,...
                    'LineStyle',obj.LineStyle,... 
                    'LineWidth',obj.LineWidth);
            end

        end % plotLine
        
        function setAxisProperties(obj,axisH)
            
            % Set Limits
            if isempty(obj.XLim)
                set(axisH,'XLimMode','auto');
            else
                set(axisH,'XLimMode','manual');
                set(axisH,'XLim',obj.XLim);
            end

            if isempty(obj.YLim)
                set(axisH,'YLimMode','auto');
            else
                set(axisH,'YLimMode','manual');
                set(axisH,'YLim',obj.YLim);
            end
            
            if isempty(obj.ZLim)
                set(axisH,'ZLimMode','auto');
            else
                set(axisH,'ZLimMode','manual');
                set(axisH,'ZLim',obj.ZLim);
            end
            

            % Set Scaling
            set(axisH,'XScale',obj.XScale);
            set(axisH,'YScale',obj.YScale);
            set(axisH,'ZScale',obj.ZScale);
            
            % Set Y axis location
            set(axisH,'yaxislocation',obj.yAxisLocation);
            
            % Set Labels
            set(get(axisH,'Title'),'String',obj.Title); 
            set(get(axisH,'XLabel'),'String',obj.XLabel);   
            set(get(axisH,'YLabel'),'String',obj.YLabel);

            % Set Grid Properties
            if obj.Grid
                grid(axisH,'on');
                set(axisH,'GridColor',obj.GridColor);
                set(axisH,'GridAlpha',obj.GridAlpha);
                set(axisH,'Layer',obj.GridLayer);
            else 
                grid(axisH,'off');
            end


            for i = 1:length(obj.PatchXData)
                zdata = zeros(size(obj.PatchXData{i}));
                p = patch(obj.PatchXData{i},obj.PatchYData{i},zdata,'Parent',axisH);
                set(p,'FaceColor',obj.PatchFaceColor{i});
                set(p,'EdgeColor',obj.PatchEdgeColor{i});
                set(axisH,'layer','top');
            end

            if ~isempty(obj.GridFunction)
                grid(axisH,'off');
                gridHandle = obj.getGridFunctionHandle; 
                gridHandle(axisH);
            end
            
        end % setAxisProperties
        
        function plot( obj , axH , showLegend )
            
            if nargin == 2
                showLegend = true;
            end
            
            if length(obj) == length(axH)
                for i = 1:length(obj)
                   plot( obj(i).NewLine , axH(i) ) 
                end
                if showLegend && ~all(cellfun(@isempty,{obj(i).NewLine}))
                    legObjH = legend(axH,[obj(i).NewLine.LineH],'Location','best');
                    set(axH,'UserData',legObjH);
                end
            elseif length(obj) > 1 && length(axH) == 1
                for i = 1:length(obj)
                   plot( obj(i).NewLine , axH ) 
                end
                if showLegend && ~all(cellfun(@isempty,{obj(i).NewLine}))
                    legObjH = legend(axH,[obj(i).NewLine.LineH],'Location','best');
                    set(axH,'UserData',legObjH);
                end   
            else
                error('Axis handle array must be equal to the object length');
            end
            
            
            
%             axH = handle(axH);
%             fnames = fieldnames(obj.AxisProperties);
%             for i = 1:length(fnames)
%                 try
%                 axH.(fnames{i}) = obj.AxisProperties.(fnames{i});
%                 end
%             end
%             
%             plot(obj.NewLine,axH);
%             for i = 1:length(obj.NewLine)
%             
%             end
        end % plot
        
    end % Ordinary Methods

    %% Methods - Static
    methods (Static)
    end % Static Methods
    
end  

