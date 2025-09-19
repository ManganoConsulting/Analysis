classdef LinePropertyBrowser < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Figure
        OK_Button
        Cancel_Button
        
        LineColorPicker
        LineColorPickerContainer
        LineStyle_PM
        LineWidth_EB
        
        MarkerStyle_PM
        MarkerSize_EB
        
        MarkerFaceColorPicker
        MarkerFaceColorPickerContainer
        
        MarkerEdgeColorPicker
        MarkerEdgeColorPickerContainer 
        
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        LineStyles = {'-','--','-.',':'}
        SelectedLineType = '-'
        LineWidth = '0.5'
        LineColor = java.awt.Color(0,0,1)
        MarkerFaceColor = java.awt.Color(0,0,1)
        MarkerEdgeColor = java.awt.Color(0,0,1)
        MarkerStyles = {'none','.','o','x','+','*','s','d','v','^','<','>','p','h'}
        MarkerStyles2018 = {'none','.','o','x','+','*','square','diamond','v','^','<','>','pentagram','hexagram'}
        SelectedMarkerStyle = 'none'
        MarkerSize = '6' 
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )     

    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )

    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        

    end
    
    %% Events
    events
        OK_Pressed
        Cancel_Pressed
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = LinePropertyBrowser( lineH )
            if nargin == 1
                
                obj.SelectedLineType    = lineH.LineStyle;
                obj.LineWidth           = num2str(lineH.LineWidth);
                if ischar(lineH.Color)
                    obj.LineColor       = java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                else
                    obj.LineColor       = java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                end
                obj.SelectedMarkerStyle = lineH.Marker;
                obj.MarkerSize          = num2str(lineH.MarkerSize);
                if ischar(lineH.MarkerFaceColor) && strcmpi('auto',lineH.MarkerFaceColor)
                    obj.MarkerFaceColor = 'auto';
                    %obj.MarkerFaceColor = java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                elseif ischar(lineH.MarkerFaceColor) && strcmpi('none',lineH.MarkerFaceColor)
                    obj.MarkerFaceColor = 'none';
                    %obj.MarkerFaceColor = java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                else
                    obj.MarkerFaceColor = java.awt.Color(lineH.MarkerFaceColor(1), lineH.MarkerFaceColor(2), lineH.MarkerFaceColor(3));
                end
                if ischar(lineH.MarkerEdgeColor) && strcmpi('auto',lineH.MarkerEdgeColor)
                    obj.MarkerEdgeColor =  'auto';
                    %obj.MarkerEdgeColor =  java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                elseif ischar(lineH.MarkerEdgeColor) && strcmpi('none',lineH.MarkerEdgeColor)
                    obj.MarkerEdgeColor =  'none';
                    %obj.MarkerEdgeColor =  java.awt.Color(lineH.Color(1), lineH.Color(2), lineH.Color(3) );
                else
                    obj.MarkerEdgeColor = java.awt.Color(lineH.MarkerEdgeColor(1), lineH.MarkerEdgeColor(2), lineH.MarkerEdgeColor(3));
                end
            end  
            
            createView( obj );

        
        end % LinePropertyBrowser
        
    end % Constructor

    %% Methods - Property Access
    methods
                  

        
    end % Property access methods
    
    %% Methods - View
    methods 
        function createView( obj )
            
            sz = [ 300 , 300]; % figure size
            screensize = get(0,'ScreenSize');
            xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
            ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically
            obj.Figure = figure('Name','Line Property',...%Control',...
                                'units','pixels',...
                                'Position',[xpos, ypos, sz(2), sz(1)],...%[193 , 109 , 1384 , 960],...%[193,109,1368,768],
                                'Menubar','none',...   
                                'Toolbar','none',...
                                'NumberTitle','off',...
                                'HandleVisibility', 'on',...%'WindowStyle','modal',...
                                'Resize','off',...
                                'Resizefcn',[],...
                                'Visible','on',...
                                'CloseRequestFcn', @obj.closeFigure_CB);
              
            parentPos = getpixelposition(obj.Figure);
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Line Style',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 40 , 125 , 20],...
                'HorizontalAlignment','left');             
            obj.LineStyle_PM = uicontrol(...
                'Parent',obj.Figure,...
                'Style','popupmenu',...
                'String',obj.LineStyles,...
                'FontSize',10,...
                'FontWeight','bold',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Enable','on',...
                'Position',[10, parentPos(4) - 40, 55, 25],...
                'Callback',@obj.lineStyle_CB);
            
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Line Size',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 75 , 125 , 20],...
                'HorizontalAlignment','left');             
            obj.LineWidth_EB = uicontrol(...
                'Parent',obj.Figure,...
                'Style','edit',...
                'String', obj.LineWidth,...
                'FontSize',10,...
                'FontWeight','bold',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Enable','on',...
                'Position',[10, parentPos(4) - 75, 55, 25],...
                'Callback',@obj.lineWidth_CB);
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Line Color',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 110 , 75 , 20],...
                'HorizontalAlignment','left');                 
            options = 0;  icon = 0;
            line_cp = com.mathworks.mlwidgets.graphics.ColorPicker(options,icon,'');
            [obj.LineColorPicker,obj.LineColorPickerContainer] = javacomponent(line_cp,[10, parentPos(4) - 110, 55, 25],obj.Figure );   
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Marker Style',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 145 , 125 , 20],...
                'HorizontalAlignment','left');             
            obj.MarkerStyle_PM = uicontrol(...
                'Parent',obj.Figure,...
                'Style','popupmenu',...
                'String',obj.MarkerStyles,...
                'FontSize',10,...
                'FontWeight','bold',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Enable','on',...
                'Position',[10, parentPos(4) - 145, 55, 25],...
                'Callback',@obj.markerStyle_CB);
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Marker Size',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 180 , 125 , 20],...
                'HorizontalAlignment','left');             
            obj.MarkerSize_EB = uicontrol(...
                'Parent',obj.Figure,...
                'Style','edit',...
                'String', obj.MarkerSize,...
                'FontSize',10,...
                'FontWeight','bold',...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Enable','on',...
                'Position',[10, parentPos(4) - 180, 55, 25],...
                'Callback',@obj.markerSize_CB);
            
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Marker Face Color',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 215 , 125 , 20],...
                'HorizontalAlignment','left');  
            options = 2;  icon = 0;
            line_cp = com.mathworks.mlwidgets.graphics.ColorPicker(options,icon,'');
            [obj.MarkerFaceColorPicker,obj.MarkerFaceColorPickerContainer] = javacomponent(line_cp,[10, parentPos(4) - 215, 55, 25],obj.Figure );  
            
            
            uicontrol('Parent',obj.Figure,...
                'Style','text',...
                'String', 'Marker Edge Color',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[75 , parentPos(4) - 245 , 125 , 20],...
                'HorizontalAlignment','left');  
            options = 2;  icon = 0;
            line_cp = com.mathworks.mlwidgets.graphics.ColorPicker(options,icon,'');
            [obj.MarkerEdgeColorPicker,obj.MarkerEdgeColorPickerContainer] = javacomponent(line_cp,[10, parentPos(4) - 245, 55, 25],obj.Figure );   
         
            obj.OK_Button = uicontrol(...
                'Parent',obj.Figure,...
                'Style','pushbutton',...
                'String', 'OK',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 200 , parentPos(4) - 45 , 75 , 30 ],...
                'Callback',@obj.okButtonPressed);
            
            obj.Cancel_Button = uicontrol(...
                'Parent',obj.Figure,...
                'Style','pushbutton',...
                'String', 'CANCEL',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 200 , parentPos(4) - 85 , 75 , 30 ],...
                'Callback',@obj.cancelButtonPressed);
% 
%             % Make the uibuttongroup visible after creating child objects. 
%             obj.ButtonGroup.Visible = 'on';   
%             
            update( obj );
        end % createView
    end
  
    %% Methods - Protected Callbacks
    methods (Access = protected)

        function okButtonPressed(obj, hobj , eventdata)
            
            clr_Line = obj.LineColorPicker.getValue();
            r = clr_Line.getRed / 255;
            g = clr_Line.getGreen / 255;
            b = clr_Line.getBlue / 255;
            clrMLine = [r,g,b];
            obj.LineColor = java.awt.Color(r,g,b);
            
            clr_MFC = obj.MarkerFaceColorPicker.getValue();
            if ~ischar(clr_MFC)
                r = clr_MFC.getRed / 255;
                g = clr_MFC.getGreen / 255;
                b = clr_MFC.getBlue / 255;
                clrMMarkFace = [r,g,b];
                obj.MarkerFaceColor = java.awt.Color(r,g,b);
            else
                clrMMarkFace = clr_MFC;
                obj.MarkerFaceColor = clr_MFC;
            end
            
            clr_MEC  = obj.MarkerEdgeColorPicker.getValue();
            if ~ischar(clr_MEC)
                r = clr_MEC.getRed / 255;
                g = clr_MEC.getGreen / 255;
                b = clr_MEC.getBlue / 255;
                clrMMarkEdge = [r,g,b];
                obj.MarkerEdgeColor = java.awt.Color(r,g,b);
            else
                clrMMarkEdge = clr_MEC;
                obj.MarkerEdgeColor = clr_MEC;
            end
            
            lineProps = SimViewer.LineProps('LineStyle',obj.SelectedLineType,...
                'LineWidth',str2double(obj.LineWidth),'LineColor',clrMLine,...
                'MarkerStyle',obj.SelectedMarkerStyle,'MarkerSize',str2double(obj.MarkerSize),...
                'MarkerFaceColor',clrMMarkFace,'MarkerEdgeColor',clrMMarkEdge);
            
        
            
            notify(obj,'OK_Pressed',SimViewer.AxisEventData('LineProperties',lineProps,[]));
            %closeFigure_CB( obj , [] ,[] );
        end % okButtonPressed
    
        function cancelButtonPressed(obj, hobj , eventdata)
            notify(obj,'Cancel_Pressed');
        end % okButtonPressed
        
        function lineStyle_CB(obj, hobj , eventdata)
            val = hobj.Value;
            obj.SelectedLineType = hobj.String{val};
        end % lineStyle_CB
        
        function lineWidth_CB(obj, hobj , eventdata)
            obj.LineWidth = hobj.String;
        end % lineWidth_CB
        
        function markerStyle_CB(obj, hobj , eventdata)
            val = hobj.Value;
            obj.SelectedMarkerStyle = hobj.String{val};
        end % markerStyle_CB
        
        function markerSize_CB(obj, hobj , eventdata)
            obj.MarkerSize = hobj.String;
        end % markerSize_CB
        
        
    end
    
    %% Methods - Resize Ordinary Methods
    methods     

                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods
        function update( obj )
            ind = find(strcmp(obj.SelectedLineType , obj.LineStyles));
            set(obj.LineStyle_PM ,'Value',ind);
 
            obj.LineColorPicker.setValue(obj.LineColor);
            
            set(obj.LineWidth_EB ,'String',obj.LineWidth);

            ind = find(strcmp(obj.SelectedMarkerStyle , obj.MarkerStyles));
            if isempty(ind)
                ind = find(strcmp(obj.SelectedMarkerStyle , obj.MarkerStyles2018));
            end
            set(obj.MarkerStyle_PM ,'Value',ind);
            
            set(obj.MarkerSize_EB ,'String',obj.MarkerSize);
            
            obj.MarkerFaceColorPicker.setValue(obj.MarkerFaceColor);
            
            obj.MarkerEdgeColorPicker.setValue(obj.MarkerEdgeColor);
    
        end
        
    end % Ordinary Methods
    
    %% Methods
    methods  
        
        function closeFigure_CB( obj , ~ ,~ )
            notify(obj,'Cancel_Pressed');
            %delete(obj.Figure);
        end % closeFigure_CB
        
        function deleteFigure(obj, ~ , ~ )
            delete(obj.Figure);
        end % deleteFigure

    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Example object
%             cpObj.Example = copy(obj.Example);
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)

    end
    
    %% Methods - Static
    methods ( Static )
        

    end
    
end


