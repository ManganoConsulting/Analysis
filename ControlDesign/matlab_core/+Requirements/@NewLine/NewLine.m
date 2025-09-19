classdef NewLine < matlab.mixin.Copyable
    %% Public properties 
    properties
        XData = [0,1]
        YData = [0,1]
        ZData = []
        LineStyle = '-'
        LineWidth = 0.5
        Color     %= [0,0,0]
        Marker = 'none'
        MarkerSize = 6
        MarkerEdgeColor = 'auto'
        MarkerFaceColor = 'b'
        DisplayName = ''
        UserData = []
        
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
        function obj = NewLine(varargin)
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addOptional(p,'XData',[0,1]);
            addOptional(p,'YData',[0,1]);
            addOptional(p,'ZData',[]);
            addParameter(p,'LineStyle','-');
            addParameter(p,'LineWidth',0.5);
            addParameter(p,'Marker','none');
            addParameter(p,'MarkerSize',6);
            addParameter(p,'Color',[]);
            addParameter(p,'MarkerEdgeColor','auto');
            addParameter(p,'MarkerFaceColor','b');
            addParameter(p,'DisplayName','');
            addParameter(p,'UserData',[]);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            

            obj.XData           = options.XData;
            obj.YData           = options.YData;
            obj.ZData           = options.ZData;
            obj.LineStyle       = options.LineStyle;
            obj.Marker          = options.Marker;
            obj.LineWidth       = options.LineWidth;
            obj.MarkerSize      = options.MarkerSize;
            obj.Color           = options.Color;
            obj.MarkerEdgeColor = options.MarkerEdgeColor;
            obj.MarkerFaceColor = options.MarkerFaceColor;  
            obj.DisplayName     = options.DisplayName; 
            obj.UserData        = options.UserData; 
            
        end % NewLine   
    end % Constructor
    
    %% Methods - Property Access
    methods
    
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        function plot( obj , axH , showLegend )
            if nargin == 2
                showLegend = false;
            end
            
            for i = 1:length(obj)
                obj(i).LineH = line(...
                    'XData',obj(i).XData,...
                    'YData',obj(i).YData,...
                    'ZData',obj(i).ZData,...
                    'Parent',axH,...
                    'Color',obj(i).Color,...
                    'Marker',obj(i).Marker,...
                    'MarkerSize',obj(i).MarkerSize,...
                    'MarkerEdgeColor',obj(i).MarkerEdgeColor,... 
                    'MarkerFaceColor',obj(i).MarkerFaceColor,...
                    'LineStyle',obj(i).LineStyle,... 
                    'LineWidth',obj(i).LineWidth,... 
                    'DisplayName',obj(i).DisplayName,...
                    'UserData',obj(i).UserData );
            end
            if showLegend && ~all(cellfun(@isempty,{obj.DisplayName}))
                showOnlyUnique = true;
                if showOnlyUnique
                    allLineH = [obj.LineH];                
                    [~,uniqueLegStrInd] = unique({obj.DisplayName});
                    emptyInd = find(cellfun(@isempty,{obj.DisplayName}));
                    showInd = setdiff(uniqueLegStrInd,emptyInd);
                    legObjH = legend(axH,allLineH(showInd),'Location','best');       
                else
                    legObjH = legend(axH,[obj.LineH],'Location','best');
    %                 uniqueLegStr = unique(legObjH.String);
    %                 emptyLegStr = cellfun(@isempty,uniqueLegStr);
    %                 nonEmptyUniqueLegString = uniqueLegStr(~emptyLegStr);
    %                 legObjH.String = nonEmptyUniqueLegString;
                end
                set(axH,'UserData',legObjH);
            end
            
        end
    end % Ordinary Methods

    %% Methods - Static
    methods (Static)
    end % Static Methods
    
end  

