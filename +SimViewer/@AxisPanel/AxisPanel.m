classdef AxisPanel < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties   
        Parent
        Panel
        Axis
        Title
        LabelComp
        LabelCont
    end % Public properties
  
    %% Private properties
    properties ( Access = private )      
        PrivateVisible
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private, Hidden = true )

        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        Visible
        Position
        Units
        
        HTMLTitle
    end % Dependant properties
    
    %% Events
    events
        AxisEvent
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = AxisPanel(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Title','',@ischar);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            checknumAx = @(x) any(x == [0,1,2,3,4,5,6]);
            addParameter(p,'NumOfAxis',4,checknumAx);
            orientationErrorStr = 'Value must be Horizontal, Vertical, or Grid(Default)';
            checkOrientation = @(x) assert(any(strcmp(x,{'Horizontal','Vertical','Grid'})),orientationErrorStr);
            addParameter(p,'Orientation','Grid',checkOrientation); % Horizontal,Vertical,Grid(Default)
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Title = options.Title;
            obj.Parent = options.Parent;
            obj.Panel = uipanel('Parent',obj.Parent,'Units', options.Units,'Position',options.Position,'ButtonDownFcn',@obj.buttonClickInPanel);
            set(obj.Parent,'ResizeFcn',@obj.reSize);
            
            numOfAxis = options.NumOfAxis;
            orientation = options.Orientation;
            
            addAxes(obj , numOfAxis , orientation );
            
        end % AxisPanel
    end % Constructor

    %% Methods - Property Access
    methods
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Panel,'Visible','on');
            else
                set(obj.Panel,'Visible','off');
            end            
        end % Visible - Set
        
        function y = get.Visible(obj)
            y = obj.PrivateVisible;          
        end % Visible - Get
        
        function set.Position(obj,pos)
            set(obj.Panel,'Position',pos);
        end % Position - Set
        
        function y = get.Position(obj)
            y = get(obj.Panel,'Position');
        end % Position - Get
        
        function set.Units(obj,units)
            set(obj.Panel,'Units',units);
        end % Units -Set
        
        function y = get.Units(obj)
            y = set(obj.Panel,'Units');
        end % Units -Get
        
        function y = get.HTMLTitle(obj)
            y = ['<html><font color="black" face="Courier New" size = 10 >&nbsp;',obj.Title,'</html>'];
        end % HTMLTitle
        
    end % Property access methods
   
    %% Methods - Ordinary
    methods    
      
        function setTitle( obj , title ) 
            obj.Title = title;
            obj.LabelComp.setText(obj.HTMLTitle)
        end % setTitle
        
        function reSize( obj , ~ , ~ )

        end % reSize
      
        function updateAxisPanel( obj , numOfAxis , orientation , title )
            % Clears Axis Panel first
            if nargin == 3
                title = [];
            end
            obj.Title = title;
            clearPanel(obj);
            
            addAxes(obj , numOfAxis , orientation );
            
        end % updateAxisPanel
        
        function updateKeepAxisPanel( obj , numOfAxis , orientation , title )
            % Clears Axis Panel first
            if nargin == 3
                title = [];
            end
            obj.Title = title;
        
            switch orientation
                case {'Grid'} % same as update axispanel need work
                    clearPanel(obj);
                    axisGrid( obj , numOfAxis );
                    for i = 1:length(obj.Axis)
                        addprop(handle(obj.Axis(i)),'SignalData');
                        addprop(handle(obj.Axis(i)),'PlotType');
                        addprop(handle(obj.Axis(i)),'LegendData');
                        addprop(handle(obj.Axis(i)),'SimViewerData');
                        addprop(handle(obj.Axis(i)),'UserTitle');
                        addprop(handle(obj.Axis(i)),'UserXLabel');
                        addprop(handle(obj.Axis(i)),'UserYLabel');
                        addprop(handle(obj.Axis(i)),'UserXLim');
                        addprop(handle(obj.Axis(i)),'UserYLim');
                        addprop(handle(obj.Axis(i)),'PatchData');

                        % Init props
                        set(handle(obj.Axis(i)),'SignalData',SimViewer.SignalData.empty);
                        set(handle(obj.Axis(i)),'PlotType',false); % 0 - timehistory; 1 - x vs y

                        grid(obj.Axis(i),'on');  

                    end
                case {'Horizontal'} % same as update axispanel need work
                    clearPanel(obj);
                    axisHorizontal( obj , numOfAxis );
                    for i = 1:length(obj.Axis)
                        addprop(handle(obj.Axis(i)),'SignalData');
                        addprop(handle(obj.Axis(i)),'PlotType');
                        addprop(handle(obj.Axis(i)),'LegendData');
                        addprop(handle(obj.Axis(i)),'SimViewerData');
                        addprop(handle(obj.Axis(i)),'UserTitle');
                        addprop(handle(obj.Axis(i)),'UserXLabel');
                        addprop(handle(obj.Axis(i)),'UserYLabel');
                        addprop(handle(obj.Axis(i)),'UserXLim');
                        addprop(handle(obj.Axis(i)),'UserYLim');
                        addprop(handle(obj.Axis(i)),'PatchData');

                        % Init props
                        set(handle(obj.Axis(i)),'SignalData',SimViewer.SignalData.empty);
                        set(handle(obj.Axis(i)),'PlotType',false); % 0 - timehistory; 1 - x vs y

                        grid(obj.Axis(i),'on');  

                    end
                case {'Vertical'}
                    obj.Panel.ButtonDownFcn = @obj.buttonClickInPanel;
                    if isempty(obj.Title)
                        offset = 0;
                    else
                        offset = 0.05;
                        jLabelview = javaObjectEDT('javax.swing.JLabel',obj.HTMLTitle);
                        jLabelview.setUI(VerticalLabelUI());
                        jLabelview.setOpaque(true);
                        jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                        [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[], obj.Panel );
                        set(obj.LabelCont,'Units','Normal','Position',[ 0 , 0 , offset , 1 ]);
                    end

                    currNumAx =  length(obj.Axis); % number of current axes in panel

                    axHt = 1/numOfAxis;
                    
                    if currNumAx > numOfAxis
                        delete(obj.Axis(numOfAxis+1:end));
                        obj.Axis(numOfAxis+1:end) = [];
                    end
                    for i = 1:numOfAxis
                        if i <= currNumAx
                            set(obj.Axis(i),'OuterPosition',[ offset , 1 - (axHt * i) , 1 - offset , axHt ]);      
                            
                        else
                            obj.Axis(i) = axes('Parent',obj.Panel,...
                                'Units', 'Normalized',...
                                'Visible','on',...
                                'ButtonDownFcn',@obj.buttonClickInAxis,...
                                'OuterPosition', [ offset , 1 - (axHt * i) , 1 - offset , axHt ] );  
                            addprop(handle(obj.Axis(i)),'SignalData');
                            addprop(handle(obj.Axis(i)),'PlotType');
                            addprop(handle(obj.Axis(i)),'LegendData');
                            addprop(handle(obj.Axis(i)),'SimViewerData');
                            addprop(handle(obj.Axis(i)),'UserTitle');
                            addprop(handle(obj.Axis(i)),'UserXLabel');
                            addprop(handle(obj.Axis(i)),'UserYLabel');
                            addprop(handle(obj.Axis(i)),'UserXLim');
                            addprop(handle(obj.Axis(i)),'UserYLim');
                            addprop(handle(obj.Axis(i)),'PatchData');

                            % Init props
                            set(handle(obj.Axis(i)),'SignalData',SimViewer.SignalData.empty);
                            set(handle(obj.Axis(i)),'PlotType',false); % 0 - timehistory; 1 - x vs y

                            grid(obj.Axis(i),'on');  
                        end
                    end       
            end        
        end % updateKeepAxisPanel
        
        function removeAxis( obj , axH )
            % Removes Axis

            % Get offset - May need to remove this
            if isempty(obj.Title)
                offset = 0;
            else
                offset = 0.05;
                jLabelview = javaObjectEDT('javax.swing.JLabel',obj.HTMLTitle);
                jLabelview.setUI(VerticalLabelUI());
                jLabelview.setOpaque(true);
                jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
                [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[], obj.Panel );
                set(obj.LabelCont,'Units','Normal','Position',[ 0 , 0 , offset , 1 ]);
            end
            
            % find the axis to remove
            logArray = axH == handle(obj.Axis);
            
            if ~any(logArray)
                return;
            end
            
            % Remove the Axes and variable
            delete(obj.Axis(logArray));
            obj.Axis(logArray) = [];
            

            currNumAx =  length(obj.Axis); % number of current axes in panel

            axHt = 1/currNumAx;

            for i = 1:currNumAx
                set(obj.Axis(i),'OuterPosition',[ offset , axHt * (i-1) , 1 - offset , axHt ]);       
            end       
         
        end % removeAxis
        
    end % Ordinary Methods
    
    %% Methods - Delete
    methods
        
        function clearPanel(obj)
            try %#ok<TRYNC>
                for i = 1:length(obj.Axis)
                    delete(obj.Axis);
                end
            end
            obj.Axis = [];
            obj.Title = [];
            obj.LabelComp = [];        
            if ~isempty(obj.LabelCont) && ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont, 'BeingDeleted'), 'off')
                delete(obj.LabelCont)
            end
        end % clearPanel
        
        function delete(obj)
            try %#ok<TRYNC>
                for i = 1:length(obj.Axis)
                    delete(obj.Axis);
                end
            end
            delete(obj.Panel);
            obj.Axis = [];
            obj.Title = [];
            obj.LabelComp = []; 
            try       
                if ~isempty(obj.LabelCont) && ishandle(obj.LabelCont) && strcmp(get(obj.LabelCont, 'BeingDeleted'), 'off')
                    delete(obj.LabelCont)
                end
            end
        end % delete
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update(obj)

        end % update
        
        function buttonClickInPanel( obj , hobj , eventdata )
            hcmenu = uicontextmenu;
            uimenu(hcmenu,'Label','Undock Panel','UserData',hobj,'Callback',@obj.unDockPanel);
            %uimenu(hcmenu,'Label','Change All Axis Limts','UserData',hobj,'Callback',@obj.changeAllAxisLimits);
            hobj.UIContextMenu = hcmenu;
        end % buttonClickInPanel
        

        
        function buttonClickInAxis( obj , hobj , eventdata )
            if eventdata.Button == 1
                hobj.SelectionHighlight = 'off';
                if strcmpi(hobj.Selected,'on')
                    hobj.Selected = 'off';
                    hobj.XColor = [0.15 0.15 0.15];
                    hobj.YColor = [0.15 0.15 0.15];
                    hobj.ZColor = [0.15 0.15 0.15];
                else
                    hobj.Selected = 'on';
                    hobj.XColor = [0 0 1];
                    hobj.YColor = [0 0 1];
                    hobj.ZColor = [0 0 1];
                end
            else
                hcmenu = uicontextmenu;
                uimenu(hcmenu,'Label','Add Selected Signals to plot','UserData',hobj,'Callback',@obj.addSignal2Plots);
                uimenu(hcmenu,'Label','Clear All','UserData',hobj,'Callback',@obj.clearPlot,'Separator','on');
                uimenu(hcmenu,'Label','Undock','UserData',hobj,'Callback',@obj.unDockAxis);      
                if hobj.PlotType
                    uimenu(hcmenu,'Label','X vs Y Plot','Checked','on','UserData',{hobj,true},'Callback',@obj.changePlotType);   
                else
                    uimenu(hcmenu,'Label','X vs Y Plot','Checked','off','UserData',{hobj,false},'Callback',@obj.changePlotType);  
                end 
                uimenu(hcmenu,'Label','Add/Change Plot Labels','UserData',hobj,'Callback',@obj.changeTitle); 
                uimenu(hcmenu,'Label','Axis Limits','UserData',hobj,'Callback',@obj.changeAxisLimits); 
                uimenu(hcmenu,'Label','Add Patch','UserData',hobj,'Callback',@obj.patchAdded); 
%                 uimenu(hcmenu,'Label','...More Properties','UserData',hobj,'Callback',@obj.inspectObj);
                uimenu(hcmenu,'Label','Remove Plot','UserData',hobj,'Callback',@obj.removePlot);
                hobj.UIContextMenu = hcmenu;
            end
        end % buttonClickInAxis
       
        function inspectObj( obj , hobj , eventdata )
            inspect(hobj.UserData);
            drawnow;pause(0.01);
        end % inspectObj
        
        function unDockAxis( obj , hobj , eventdata )
            
            newfH  = figure( ...
                'Name', hobj.UserData.Title.String, ...
                'NumberTitle', 'off');

            if isempty(hobj.UserData.LegendData) || ~isvalid(hobj.UserData.LegendData)
                newAxH = copyobj(hobj.UserData,newfH);
            else
                newAxH = copyobj([hobj.UserData,hobj.UserData.LegendData],newfH);
            end
            drawnow();
            newAxH(1).Units = 'Normal';
            newAxH(1).OuterPosition = [ 0 , 0 , 1 , 1 ];
            drawnow();
            delete ( findobj ( ancestor(hobj,'figure','toplevel'), 'type','uicontextmenu' ) );
            delete ( findobj ( ancestor(newAxH(1),'figure','toplevel'), 'type','uicontextmenu' ) );
        end % unDockAxis
        
        function patchAdded( obj , hobj , eventdata )
            
            disp('This function is still under development.');
            %hobj.UserData.PatchData = answer{1}; 

            
        end % patchAdded
        
        function changeTitle( obj , hobj , eventdata )
            
            
            prompt = {'Tilte:','X Axis:','Y Axis:'};
            dlg_title = 'Plot Labels';
            num_lines = 1;
            defaultvals = {hobj.UserData.Title.String,hobj.UserData.XLabel.String,hobj.UserData.YLabel.String};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultvals); 
            drawnow;pause(0.01);
            if isempty(answer)
                return;
            end
            
            %chProps = struct('Title',[],'XLabel',[],'YLabel',[]);
            if ~isempty(answer{1})  
                if ~strcmp(strtrim(answer{1}),strtrim(defaultvals{1}))
                    hobj.UserData.Title.String = answer{1};
                    hobj.UserData.UserTitle = answer{1}; %chProps.Title = answer{1};
                end
            else
                hobj.UserData.Title.String = [];
            end
                
            if ~isempty(answer{2})   
                if ~strcmp(strtrim(answer{2}),strtrim(defaultvals{2}))
                    hobj.UserData.XLabel.String = answer{2};
                    hobj.UserData.UserXLabel = answer{2}; %chProps.XLabel = answer{2};
                end
            else
                hobj.UserData.XLabel.String = [];
            end
            
            if ~isempty(answer{3})  
                if ~strcmp(strtrim(answer{3}),strtrim(defaultvals{3}))
                    hobj.UserData.YLabel.String = answer{3};
                    hobj.UserData.UserYLabel = answer{3}; %chProps.YLabel = answer{3};
                end
            else
                hobj.UserData.YLabel.String = [];
            end            
            
        end % changeTitle
        
        function changeAxisLimits( obj , hobj , eventdata )    
            axP = SimViewer.SetAxesProperties(hobj.UserData);
            uiwait(axP.Parent);
            
            if axP.Apply2All
                 
                for i = 1:length(obj.Axis)
                    if axP.AutoScale_X
                        set(obj.Axis(i),'XLimMode','auto');
                    else
                        set(obj.Axis(i),'XLim',axP.XLim);   
                    end
                end
            else
                if axP.AutoScale_X
                    hobj.UserData.UserXLim = [];
                else
                    hobj.UserData.UserXLim = axP.XLim;
                end
                if axP.AutoScale_Y
                    hobj.UserData.UserYLim = [];
                else
                    hobj.UserData.UserYLim = axP.YLim;
                end
            end
        end % changeAxisLimits
        
        function changeAllAxisLimits( obj, hobj , eventdata)

        end % changeAllAxisLimits
        
        function clearPlot( obj , hobj , eventdata )
            notify(obj,'AxisEvent',SimViewer.AxisEventData('ClearAxis',hobj.Selected,hobj.UserData));
        end % clearPlot  
        
        function changePlotType( obj , hobj , eventdata )  
            hobj.UserData{1}.PlotType = ~hobj.UserData{2};
            pause(0.01);
            notify(obj,'AxisEvent',SimViewer.AxisEventData('PlotTypeChanged',hobj.Selected,hobj.UserData));
        end % changePlotType  
        
        function removePlot( obj , hobj , eventdata ) 
            notify(obj,'AxisEvent',SimViewer.AxisEventData('RemovePlot',[],hobj.UserData));     
        end % removePlot
        
        function unDockPanel( obj , ~ , ~ )
            notify(obj,'AxisEvent',SimViewer.AxisEventData('UndockPanel',[],handle(obj.Axis)));
        end % unDockPanel
       
	    function addSignal2Plots( obj , hobj , eventdata )
            
            notify(obj,'AxisEvent',SimViewer.AxisEventData('AddSelectedSignals',[],hobj.UserData));
            
        end % addSignal2Plots    
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function addAxes(obj , numOfAxis , orientation )
            switch orientation
                case {'Grid'}
                    axisGrid( obj , numOfAxis );
                case {'Horizontal'}
                    axisHorizontal( obj , numOfAxis );
                case {'Vertical'}
                    obj.Panel.ButtonDownFcn = @obj.buttonClickInPanel;
                    axisVertical( obj , numOfAxis );         
            end
            
            for i = 1:length(obj.Axis)
                addprop(handle(obj.Axis(i)),'SignalData');
                addprop(handle(obj.Axis(i)),'PlotType');
                addprop(handle(obj.Axis(i)),'LegendData');
                addprop(handle(obj.Axis(i)),'SimViewerData');
                addprop(handle(obj.Axis(i)),'UserTitle');
                addprop(handle(obj.Axis(i)),'UserXLabel');
                addprop(handle(obj.Axis(i)),'UserYLabel');
                addprop(handle(obj.Axis(i)),'UserXLim');
                addprop(handle(obj.Axis(i)),'UserYLim');
                addprop(handle(obj.Axis(i)),'PatchData');
                       
                % Init props
                set(handle(obj.Axis(i)),'SignalData',SimViewer.SignalData.empty);
                set(handle(obj.Axis(i)),'PlotType',false); % 0 - timehistory; 1 - x vs y

                grid(obj.Axis(i),'on');  
                
            end
        end % addAxes
        
        function axisGrid( obj , numOfAxis )
            if numOfAxis == 4
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0.5,0.5,0.5] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0.5,0.5,0.5,0.5] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0,0.5,0.5] );
                obj.Axis(4) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0.5,0,0.5,0.5] );
            elseif numOfAxis == 3
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0.5,0.5,0.5] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0.5,0.5,0.5,0.5] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0,1,0.5] );
            elseif numOfAxis == 2
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0.5,1,0.5] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0,1,0.5] );
            elseif numOfAxis == 1
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [0,0,1,1] );

            end
        end % axisGrid
        
        function axisHorizontal( obj , numOfAxis )
            if numOfAxis == 4
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0 , 0 , 0.25 , 1 ]  );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.25 , 0 , 0.25 , 1 ]);
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.5 , 0 , 0.25 , 1 ] );
                obj.Axis(4) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.75 , 0 , 0.25 , 1 ] );
            elseif numOfAxis == 3
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0 , 0 , 0.33 , 1 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.33 , 0 , 0.33 , 1 ] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.66 , 0 , 0.34 , 1 ] );
            elseif numOfAxis == 2
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0 , 0 , 0.5 , 1 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0.5 , 0 , 0.5 , 1 ] );
            elseif numOfAxis == 1
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ 0 , 0 , 1 , 1 ] );

            end
        end % axisHorizontal
        
        function axisVertical( obj , numOfAxis )
            if isempty(obj.Title)
                offset = 0;
            else
                offset = 0.05;
%               labelStr = '<html><font color="black" face="Courier New" size = 10 >&nbsp;Status Window</html>';
                jLabelview = javaObjectEDT('javax.swing.JLabel',obj.HTMLTitle);
%               JLabel label = new JLabel("Label");
                jLabelview.setUI(VerticalLabelUI());
                jLabelview.setOpaque(true);
%               jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
                jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
%               jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
                [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[], obj.Panel );
                set(obj.LabelCont,'Units','Normal','Position',[ 0 , 0 , offset , 1 ]);
            end
            
            if numOfAxis == 6
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.8333 , 1 - offset , 0.1667 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.6667 , 1 - offset , 0.1667 ] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.5 , 1 - offset , 0.1667 ] );
                obj.Axis(4) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.3333 , 1 - offset , 0.1667 ] );
                obj.Axis(5) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.1667 , 1 - offset , 0.1667 ] );
                obj.Axis(6) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 0.1667] );
            elseif numOfAxis == 5
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.8 , 1 - offset , 0.2 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.6 , 1 - offset , 0.2 ] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.4 , 1 - offset , 0.2 ] );
                obj.Axis(4) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.2 , 1 - offset , 0.2 ] );
                obj.Axis(5) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 0.2 ] );
            elseif numOfAxis == 4
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.75 , 1 - offset , 0.25 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.5 , 1 - offset , 0.25 ] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.25 , 1 - offset , 0.25 ] );
                obj.Axis(4) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 0.25 ] );
            elseif numOfAxis == 3
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.66 , 1 - offset , 0.33 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.33 , 1 - offset , 0.33 ] );
                obj.Axis(3) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 0.34 ] );
            elseif numOfAxis == 2
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0.5 , 1 - offset , 0.5 ] );
                obj.Axis(2) =axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 0.5 ] );
            elseif numOfAxis == 1
                obj.Axis(1) = axes('Parent',obj.Panel,...
                    'Units', 'Normalized',...
                    'Visible','on',...
                    'ButtonDownFcn',@obj.buttonClickInAxis,...
                    'OuterPosition', [ offset , 0 , 1 - offset , 1 ] );

            end
        end % axisVertical
        
    end
end
