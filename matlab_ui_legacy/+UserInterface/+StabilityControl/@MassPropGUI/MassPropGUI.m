classdef MassPropGUI < matlab.mixin.Copyable & UserInterface.GraphicsObject
    
    %% Public properties - Object Handles
    properties (Transient = true)      
        AxH
        Tooltip
    end
    
    %% Public properties - Data Storage
    properties  
        MassPropObj
        XcgName = 'xCG_percent_IC' %'XCG_PCT'
        WtName  = 'weight_N_IC' %'WT'
        XData
        YData
        SelectedObjsLogical
    end % Public properties
    
    %% Private properties - Data Storage
    properties  ( Access = private )
 
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        LineH
        SelectedLineH
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
      
    end % Dependant properties

    %% Constant properties
    properties (Constant) 
      
    end % Constant properties  
    
    %% Events
    events
        MassPropertyGUIChanged
        FigureClosed
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = MassPropGUI( massProps , selected , parent )
            switch nargin
                case 1
                    obj.MassPropObj = massProps;
                    obj.SelectedObjsLogical = false(length(obj.MassPropObj),1);
                    createView( obj );
                case 2
                    if length(massProps) ~= length(selected)
                        error('Arguments 1 and 3 must have the same length.');
                    end
                    obj.MassPropObj = massProps;
                    obj.SelectedObjsLogical = selected;
                    createView( obj  );  
                case 3 
                    if length(massProps) ~= length(selected)
                        error('Arguments 1 and 3 must have the same length.');
                    end
                    obj.MassPropObj = massProps;
                    obj.SelectedObjsLogical = selected;
                    createView( obj , parent );    
            end
        end % MassPropGUI
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - View
    methods 
            
        function createView( obj , parent )
            if nargin == 1
                obj.Parent = figure('Name','Mass Properties',...
                                    'units','pixels',...
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...
                                    'CloseRequestFcn', @obj.closeFigure_CB);%'Position',[193,109,1200,738],...             
            else
                obj.Parent = parent;
            end   
            set(obj.Parent, 'WindowButtonMotionFcn',@obj.onMouseMove_Callback)
            obj.AxH = axes('Parent',obj.Parent);
            obj.AxH.XLabel.String = 'X_{cg}';
            obj.AxH.YLabel.String = 'Weight (lbs)';
            obj.AxH.XGrid = 'on';
            obj.AxH.YGrid = 'on';
            
            for i = 1:length(obj.MassPropObj)
                obj.XData(i) = obj.MassPropObj(i).get(obj.XcgName);
                obj.YData(i) = obj.MassPropObj(i).get(obj.WtName);
            end
            
            
            
            for i = 1:length(obj.MassPropObj)
                obj.LineH(i) = line(obj.XData(i),obj.YData(i),...
                    'Parent',obj.AxH,...
                    'Color',[0,0,0],...
                    'Marker','o',...
                    'MarkerSize',6,...
                    'MarkerFaceColor',getColor(i),...
                    'LineStyle','none',... 
                    'LineWidth',2);
            end
            obj.SelectedLineH = gobjects(length(obj.MassPropObj),1);
            set(obj.LineH,'ButtonDownFcn',@obj.axisButtonDown);
            
            for i = 1:length(obj.SelectedObjsLogical)
                if obj.SelectedObjsLogical(i)
                    obj.SelectedLineH(i) = line(obj.XData(i),obj.YData(i),...
                        'Parent',obj.AxH,...
                        'Color',[0,0,0],...
                        'Marker','o',...
                        'MarkerSize',14,...
                        'MarkerEdgeColor',[1,0,0],...
                        'LineStyle','none',... 
                        'LineWidth',2);
                end
            end
            validGraphicH = isgraphics(obj.SelectedLineH);
            set(obj.SelectedLineH(validGraphicH),'ButtonDownFcn',@obj.axisButtonDown);
        end % createView
        
    end
       
   %% Methods - Ordinary
    methods 
        function updateSelected( obj , selArray ) 
            obj.SelectedObjsLogical = selArray;
            for i = 1:length(obj.SelectedObjsLogical)
                if isgraphics(obj.SelectedLineH(i))
                    delete(obj.SelectedLineH(i));
                end
                if obj.SelectedObjsLogical(i)
                    obj.SelectedLineH(i) = line(obj.XData(i),obj.YData(i),...
                        'Parent',obj.AxH,...
                        'Color',[0,0,0],...
                        'Marker','o',...
                        'MarkerSize',14,...
                        'MarkerEdgeColor',[1,0,0],...
                        'LineStyle','none',... 
                        'LineWidth',2);
%                 else
%                     if isgraphics(obj.SelectedLineH(i))
%                         delete(obj.SelectedLineH(i));
%                     end
                end
            end
            validGraphicH = isgraphics(obj.SelectedLineH);
            set(obj.SelectedLineH(validGraphicH),'ButtonDownFcn',@obj.axisButtonDown);        
            
        end % updateSelected
 
        
    end % Ordinary Methods
    
    %% Methods - Callbacks Protected
    methods (Access = protected)
        
        function closeFigure_CB( obj , ~ , ~ )
            delete(obj.Parent);
            notify(obj,'FigureClosed');
        end % closeFigure_CB   
        
        function axisButtonDown( obj , hobj , eventdata )

                % Execute for a left click    
                Cp = get(obj.AxH,'CurrentPoint');
                Xp = Cp(2,1);  % X-point
                Yp = Cp(2,2);  % Y-point 
                [~,Ip] = min((obj.XData-Xp).^2+(obj.YData-Yp).^2);
            if eventdata.Button == 1
                if obj.SelectedObjsLogical(Ip)% || isgraphics(obj.SelectedLineH(Ip)) 
                    delete(obj.SelectedLineH(Ip));
                    obj.SelectedObjsLogical(Ip) = false;
                else
                    obj.SelectedLineH(Ip) = line(obj.XData(Ip),obj.YData(Ip),...
                        'Parent',obj.AxH,...
                        'Color',[0,0,0],...
                        'Marker','o',...
                        'MarkerSize',14,...
                        'MarkerEdgeColor',[1,0,0],...
                        'LineStyle','none',... 
                        'LineWidth',2);
                    obj.SelectedObjsLogical(Ip) = true;
                end

                validGraphicH = isgraphics(obj.SelectedLineH);
                set(obj.SelectedLineH(validGraphicH),'ButtonDownFcn',@obj.axisButtonDown);
                notify(obj,'MassPropertyGUIChanged',UserInterface.UserInterfaceEventData(obj.SelectedObjsLogical));
            else
                if isgraphics(obj.Tooltip)
                    delete(obj.Tooltip);
                end
                figPos = getpixelposition(obj.Parent);
                cp = obj.Parent.CurrentPoint;
                str = mpObj2str(obj.MassPropObj(Ip)); 
                obj.Tooltip = annotation('textbox');
                set(obj.Tooltip,'String',str);
                set(obj.Tooltip,'Units','Pixels','Position',[obj.Parent.CurrentPoint,[200,200]]);
                set(obj.Tooltip,'FitBoxToText','on');
                set(obj.Tooltip,'Interpreter','none');
                set(obj.Tooltip,'BackgroundColor',[ 252/255 ,252/255 , 220/255 ]);
                drawnow();
                actualPos = get(obj.Tooltip,'Position');

                if (cp(1) + actualPos(3) > figPos(3)) && (cp(2) + actualPos(4) < figPos(4))% Box will go off right side but not over top
                    set(obj.Tooltip,'Units','Pixels','Position',[ cp(1) - actualPos(3)  , cp(2) , actualPos(3) , actualPos(4) ]);
                elseif (cp(1) + actualPos(3) > figPos(3)) && (cp(2) + actualPos(4) > figPos(4))% Box will go off right side and over top
                    set(obj.Tooltip,'Units','Pixels','Position',[ cp(1) - actualPos(3)  , cp(2) - actualPos(4) , actualPos(3) , actualPos(4) ]);
                elseif (cp(2) + actualPos(4) > figPos(4))% Box will go over top only
                    set(obj.Tooltip,'Units','Pixels','Position',[ cp(1)  , cp(2) - actualPos(4) , actualPos(3) , actualPos(4) ]);
                else
                    set(obj.Tooltip,'Units','Pixels','Position',[cp,[actualPos(3),actualPos(4)]]);
                end
            end
        end % axisButtonDown
        
        function onMouseMove_Callback( obj , ~ , ~ )
            % Check if the cursor is within the axes limits
            cp = obj.AxH.CurrentPoint;
            cx = round(cp(1,1));
            cy = round(cp(1,2));
            xlim = get(obj.AxH,'xlim');
            ylim = get(obj.AxH,'ylim');
            if (xlim(1)<cx & cx<xlim(2)) & (ylim(1)<cy & cy<ylim(2))  %#ok<AND2>
                % Keep Annotation
                
            else
                if isgraphics(obj.Tooltip)
                    delete(obj.Tooltip);
                end
            end    
        end % onMouseMove_Callback
    end
        
    %% Methods - Private - Private Update Methods
    methods (Access = private)
           
        function update(obj)
                    
            
        end
        
        function reSize( obj , ~ , ~ )

        end % reSize  
    end
    
    %% Methods - Protected -  Copy
    methods (Access = protected)            
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the MassPropObj object
            cpObj.MassPropObj = copy(obj.MassPropObj);
            
        end
        
    end
    
end

function y = getColor(ind)

    color = {'b','r','g','k','m','c',[0.5,0.5,0]};
    if ind <= 7
        y = color{ind};
    else
        y = [rand(1),rand(1),rand(1)];
    end

end  % getColor

function y = mpObj2str(obj)
    y = '';
    for i = 1:length(obj.Parameter)
        tempStr = [obj.Parameter(i).Name,' = ',obj.Parameter(i).StringValue,'\n'];
        y = [y,tempStr]; %#ok<AGROW>
    end
    
    y = sprintf([y,'WeightCode = ',obj.WeightCode]);
end % mpObj2str