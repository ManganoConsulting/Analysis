classdef AxisPanelCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)   
        Parent
        Container
        Panel UserInterface.AxisPanel
        LeftArrowButton
        PageNumberDisplay
        RightArrowButton
        
        AxisHandleQueue
    end % Public properties
  
    %% Public properties - Data Storage
    properties       
        SelectedPanel
        BorderType
        
    end % Public properties
    
    %% Private properties
    properties ( Access = private )        
        PrivatePosition
        PrivateUnits
        
    end % Public properties

    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
    end % Dependant properties
    
    %% Events
    events
        AxisCollectionEvent
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = AxisPanelCollection(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            checknumAx = @(x) any(x == [1,2,4]);
            addParameter(p,'NumOfAxisPerPage',4,checknumAx);
            addParameter(p,'NumOfPages',4);
            addParameter(p,'BorderType','none');
            orientationErrorStr = 'Value must be Horizontal, Vertical, or Grid(Default)';
            checkOrientation = @(x) assert(any(strcmp(x,{'Horizontal','Vertical','Grid'})),orientationErrorStr);
            addParameter(p,'Orientation','Grid',checkOrientation); % Horizontal,Vertical,Grid(Default)
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            obj.BorderType = options.BorderType;
            obj.Parent = options.Parent;
            num = options.NumOfPages;
            obj.Container = uipanel('Parent',obj.Parent,'Units', options.Units,'Position',options.Position,'BorderType',obj.BorderType);
            parentPos = getpixelposition(obj.Container);
            set(obj.Parent,'ResizeFcn',@obj.reSize);        
            
            for i = 1:num

                obj.Panel(i) = UserInterface.AxisPanel('Parent',obj.Container,...
                    'Units','Pixels',...
                    'Position',[parentPos(1),30,parentPos(3), parentPos(4)-30],...
                    'NumOfAxis',options.NumOfAxisPerPage,...
                    'Orientation',options.Orientation);
                addlistener(obj.Panel(i),'AxisEvent',@obj.axisEvent);                          
                drawnow;
            end

            [leftPos, labelPos, rightPos] = obj.navigationControlPositions(parentPos(3));

            obj.LeftArrowButton = uihtml(obj.Container, ...
                'HTMLSource',obj.createNavigationButtonHtml('left'), ...
                'Position',leftPos);
            obj.LeftArrowButton.HTMLEventReceivedFcn = @(src,evt)obj.handleNavigationEvent('left',src,evt);
            obj.LeftArrowButton.UserData = 1;

            obj.PageNumberDisplay= uicontrol('Parent',obj.Container,...
                            'Style','text',...
                            'String','1',...
                            'FontSize',10,...
                            'Units','Pixels',...
                            'Position',labelPos,...
                            'HorizontalAlignment','Center');

            obj.RightArrowButton = uihtml(obj.Container, ...
                'HTMLSource',obj.createNavigationButtonHtml('right'), ...
                'Position',rightPos);
            obj.RightArrowButton.HTMLEventReceivedFcn = @(src,evt)obj.handleNavigationEvent('right',src,evt);
            obj.RightArrowButton.UserData = 1;
            
            % Create Queue for axis handles
            obj.AxisHandleQueue = javaObjectEDT('java.util.LinkedList');
            for j = 1:length(obj.Panel)
                for i = 1:length(obj.Panel(j).Axis)
                    obj.AxisHandleQueue.add(obj.Panel(j).Axis(i)); 
                end
            end
            
            obj.SelectedPanel = 1;
            obj.update();
            
            
            
        end % AxisPanelCollection
    end % Constructor

    %% Methods - Property Access
    methods
        function set.Position( obj , pos )
            set(obj.Container,'Position',pos);
            obj.PrivatePosition = pos;
        end % Position - Set
        
        function y = get.Position( obj )
            y = obj.PrivatePosition;
        end % Position - Get
        
        function set.Units( obj , units )
            set(obj.Container,'Units',units);
            obj.PrivateUnits = units;
        end % Units -Set
        
        function y = get.Units( obj )
            y = obj.PrivateUnits;
        end % Units -Get
    end % Property access methods
    
    %% Methods - Ordinary
    methods
        
        function axisEvent( obj , hobj , eventData )
            
            notify(obj,'AxisCollectionEvent',eventData);
            
        end % axisEvent
        
        function setOrientation( obj , numPP )
            currentTotalNumAxis = obj.AxisHandleQueue.size;
            currentNumPages     = length( obj.Panel );
            currentNumPerPage   = length(obj.Panel(1).Axis);
            numOfPagesNeeded    = currentTotalNumAxis / numPP;
            currentSelectedPage = obj.SelectedPanel;
            
            
            
            if currentNumPages < numOfPagesNeeded
                 % Add needed panels
                parentPos = getpixelposition(obj.Container);
                for i = (currentNumPages + 1):numOfPagesNeeded
                    obj.Panel(i) = UserInterface.AxisPanel('Parent',obj.Container,...
                        'Units','Pixels',...
                        'Position',[parentPos(1),30,parentPos(3), parentPos(4)-30],...
                        'NumOfAxis',numPP);
                end
                ind = numOfPagesNeeded;
                position = cell(numPP,1);
                for j = currentNumPages:-1:1
                    k = numPP;
                    for i = currentNumPerPage:-1:1
                        if ind > currentNumPages
                            position{k} = get(obj.Panel(ind).Axis(k),'OuterPosition');%getpixelposition(obj.Panel(ind).Axis(k));
                            delete(obj.Panel(ind).Axis(k));
                            obj.Panel(ind).Axis(k) = obj.Panel(j).Axis(i);
                            obj.Panel(j).Axis(i) = [];
                            set(obj.Panel(ind).Axis(k) ,'Parent',obj.Panel(ind).Panel,'Units','Normalized','OuterPosition',position{k});    
                        else
                            obj.Panel(ind).Axis(k) = obj.Panel(j).Axis(i);
                            if ind ~= 1
                                obj.Panel(j).Axis(i) = [];
                            end
                            set(obj.Panel(ind).Axis(k) ,'Parent',obj.Panel(ind).Panel,'Units','Normalized','OuterPosition',position{k});  
                        end
                        k = k - 1;
                        if  k == 0
                            k = numPP;
                            ind = ind - 1;
                        end
                        
                    end
                end
            else
                % Get all axis handels
                for i = 0:obj.AxisHandleQueue.size - 1
                    axH(i+1) = obj.AxisHandleQueue.get(i); %#ok<AGROW>
                end
                % Add needed panels
                if numPP == 2
                    j = 1;
                    for i = 1:2:length(axH)
                        obj.Panel(j).Axis(1) = axH(i);
                        obj.Panel(j).Axis(2) = axH(i+1);
                        set(obj.Panel(j).Axis(1) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0,0.5,1,0.5]);  
                        set(obj.Panel(j).Axis(2) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0,0,1,0.5]); 
                        j = j + 1;
                    end
                    while length(obj.Panel) > numOfPagesNeeded
                        delete(obj.Panel(end).Panel);
                        obj.Panel(end) = [];
                    end
                elseif numPP == 4
                    j = 1;
                    for i = 1:4:length(axH)
                        obj.Panel(j).Axis(1) = axH(i);
                        obj.Panel(j).Axis(2) = axH(i+1);
                        obj.Panel(j).Axis(3) = axH(i+2);
                        obj.Panel(j).Axis(4) = axH(i+3);
                        set(obj.Panel(j).Axis(1) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0,0.5,0.5,0.5]);  
                        set(obj.Panel(j).Axis(2) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0.5,0.5,0.5,0.5]);  
                        set(obj.Panel(j).Axis(3) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0,0,0.5,0.5]);  
                        set(obj.Panel(j).Axis(4) ,'Parent',obj.Panel(j).Panel,'Units','Normalized','OuterPosition',[0.5,0,0.5,0.5]);
                        j = j + 1;
                    end 
                    while length(obj.Panel) > numOfPagesNeeded
                        delete(obj.Panel(end).Panel);
                        obj.Panel(end) = [];
                    end
                end     
            end
            
            if   obj.SelectedPanel > length(obj.Panel)
                obj.SelectedPanel = 1;
            end
            obj.update();
            
        end % setOrientation
    end
   
    %% Methods - Callbacks
    methods ( Access = protected )
        
        function pageSelectLeft_CB(gui, ~ , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.design.leftArrowButton" push button
        %---------------------------------------------------------------------- 

            gui.SelectedPanel = gui.SelectedPanel-1;
            if gui.SelectedPanel < 1
                gui.SelectedPanel = 1;
            end
            gui.update();

        end % pageSelectLeft_CB

        function pageSelectRight_CB(gui, ~ , ~ )
        %----------------------------------------------------------------------
        % - Callback for "gui.design.rightArrowButton" push button
        %----------------------------------------------------------------------   

            gui.SelectedPanel = gui.SelectedPanel+1;
            if gui.SelectedPanel > length(gui.Panel)
                gui.SelectedPanel = length(gui.Panel);
            end
            gui.update();

        end % pageSelectRight_CB
              
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)  
        
        function update(obj)
            for i = 1:length(obj.Panel)
                if i == obj.SelectedPanel
                    %set(obj.Panel(i).Panel,'Visible','on'); 
                    obj.Panel(i).Visible = true;
                else
                    %set(obj.Panel(i).Panel,'Visible','off'); 
                    obj.Panel(i).Visible = false; 
                end
            end
            
            set(obj.PageNumberDisplay,'String',num2str(obj.SelectedPanel));
        end % update
        
        function reSize( obj , ~ , ~ )
            
           posPix = getpixelposition(obj.Container);

           [leftPos, labelPos, rightPos] = obj.navigationControlPositions(posPix(3));
           set(obj.LeftArrowButton,'Position',leftPos);
           set(obj.PageNumberDisplay,'Position',labelPos);
           set(obj.RightArrowButton,'Position',rightPos);

            for i = 1:length(obj.Panel)
                obj.Panel(i).Position = [0,30,posPix(3), posPix(4)-30];
            end
            
        end % reSize
        
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Panel object
            cpObj.Panel = copy(obj.Panel);
        end
        
    end
 
    %% Methods - Private helpers
    methods (Access = private)

        function handleNavigationEvent(obj, direction, src, evt)
            if nargin < 4 || isempty(evt)
                return;
            end

            eventDirection = '';

            if isprop(evt,'HTMLEventName')
                eventName = evt.HTMLEventName;
                if isa(eventName,'string')
                    if ~isscalar(eventName)
                        return;
                    end
                    eventName = char(eventName);
                end

                if ~ischar(eventName) || ~strcmpi(strtrim(eventName),'navigate')
                    return;
                end

                if isprop(evt,'HTMLEventData')
                    eventDirection = obj.parseNavigationDirection(evt.HTMLEventData);
                end
            elseif isprop(evt,'Data')
                data = evt.Data;
                if isempty(data) || ~isstruct(data)
                    return;
                end

                if ~isfield(data,'type') || ~strcmp(data.type,'nav-button')
                    return;
                end

                if isfield(data,'direction')
                    eventDirection = obj.parseNavigationDirection(data.direction);
                else
                    eventDirection = obj.parseNavigationDirection(data);
                end
            else
                return;
            end

            if isempty(eventDirection) || ~strcmpi(eventDirection,direction)
                return;
            end

            switch lower(direction)
                case 'left'
                    obj.pageSelectLeft_CB(src,evt);
                case 'right'
                    obj.pageSelectRight_CB(src,evt);
            end
        end

        function normalizedDirection = parseNavigationDirection(~, candidate)
            normalizedDirection = '';
            value = candidate;

            if isstruct(value)
                if isfield(value,'direction')
                    value = value.direction;
                else
                    value = '';
                end
            end

            if isa(value,'string')
                if isscalar(value)
                    value = char(value);
                else
                    value = '';
                end
            elseif iscell(value)
                if numel(value) == 1
                    value = value{1};
                    if isa(value,'string')
                        if isscalar(value)
                            value = char(value);
                        else
                            value = '';
                        end
                    end
                else
                    value = '';
                end
            end

            if ischar(value)
                normalizedDirection = strtrim(value);
            end
        end

        function [leftPos, labelPos, rightPos] = navigationControlPositions(~, containerWidth)
            buttonSize = 24;
            sidePadding = 8;
            bottomOffset = 3;
            spacing = 8;
            labelWidth = 70;
            labelHeight = 18;

            containerWidth = double(containerWidth);

            leftPos = [sidePadding, bottomOffset, buttonSize, buttonSize];

            rightX = containerWidth - sidePadding - buttonSize;
            if rightX < sidePadding
                rightX = sidePadding;
            end
            rightPos = [rightX, bottomOffset, buttonSize, buttonSize];

            labelLeft = (containerWidth - labelWidth)/2;
            minLabelLeft = leftPos(1) + leftPos(3) + spacing;
            maxLabelLeft = rightPos(1) - spacing - labelWidth;

            if maxLabelLeft < minLabelLeft
                labelLeft = minLabelLeft;
            else
                labelLeft = max(minLabelLeft, min(labelLeft, maxLabelLeft));
            end

            labelBottom = bottomOffset + max((buttonSize - labelHeight)/2, 0);
            labelPos = [labelLeft, labelBottom, labelWidth, labelHeight];
        end

        function html = createNavigationButtonHtml(~, direction)
            if nargin < 2 || isempty(direction)
                direction = 'left';
            end

            if strcmpi(direction,'left')
                directionValue = 'left';
                titleText = 'Previous page';
                iconEntity = '&#x276E;';
            else
                directionValue = 'right';
                titleText = 'Next page';
                iconEntity = '&#x276F;';
            end

            buttonId = sprintf('navButton-%s', directionValue);
            buttonLine = sprintf('<button type="button" id="%s" class="nav-button" title="%s" aria-label="%s">%s</button>', ...
                buttonId, titleText, titleText, iconEntity);

            directionConstLine = sprintf('  const direction = "%s";', directionValue);
            buttonQueryLine = sprintf('  const button = document.getElementById("%s");', buttonId);

            styleLines = {
                '<style>'
                'html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;}'
                'body{display:flex;align-items:center;justify-content:center;background:transparent;}'
                '.nav-button{'
                '  width:100%;'
                '  height:100%;'
                '  border-radius:50%;'
                '  border:1px solid rgba(120,130,150,0.85);'
                '  background:linear-gradient(135deg,#4b5568 0%,#1f2430 100%);'
                '  color:#f2f4f8;'
                '  font-family:"Segoe UI",sans-serif;'
                '  font-size:16px;'
                '  font-weight:600;'
                '  display:flex;'
                '  align-items:center;'
                '  justify-content:center;'
                '  cursor:pointer;'
                '  box-shadow:0 2px 4px rgba(0,0,0,0.4);'
                '  transition:background 0.15s ease,box-shadow 0.15s ease,transform 0.12s ease;'
                '}'
                '.nav-button:hover{'
                '  background:linear-gradient(135deg,#5b6780 0%,#293041 100%);'
                '  box-shadow:0 4px 8px rgba(90,130,255,0.35);'
                '}'
                '.nav-button:active{'
                '  transform:scale(0.96);'
                '}'
                '.nav-button:focus-visible{'
                '  outline:2px solid rgba(128,169,255,0.85);'
                '  outline-offset:2px;'
                '}'
                '</style>'
                };

            scriptLines = {
                '<script type="text/javascript">'
                'function setup(htmlComponent) {'
                buttonQueryLine
                '  if (!button || !htmlComponent || typeof htmlComponent.sendEventToMATLAB !== "function") {'
                '    return;'
                '  }'
                directionConstLine
                '  function sendNavigationEvent() {'
                '    htmlComponent.sendEventToMATLAB("navigate", direction);'
                '  }'
                '  button.addEventListener("click", sendNavigationEvent);'
                '  button.addEventListener("keydown", function(event) {'
                '    if (event.key === "Enter" || event.key === " " || event.key === "Spacebar" || event.key === "Space") {'
                '      event.preventDefault();'
                '      sendNavigationEvent();'
                '    }'
                '  });'
                '}'
                '</script>'
                };

            parts = [{'<!doctype html>'};
                {'<html lang="en">'};
                {'<head>'};
                {'<meta charset="utf-8">'};
                styleLines(:);
                {'</head>'};
                {'<body>'};
                {buttonLine};
                scriptLines(:);
                {'</body>'};
                {'</html>'}];

            html = strjoin(parts, newline);
        end

    end

    %% Methods - Delete
    methods
        function delete( obj )

            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.Panel);
            end



    %          % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.RightArrowButton);
            end
            try %#ok<*TRYNC>             
                delete(obj.PageNumberDisplay);
            end
            try %#ok<*TRYNC>             
                delete(obj.LeftArrowButton);
            end
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
            try %#ok<*TRYNC>             
                delete(obj.Parent);
            end      

        end % delete
    end
    
end
