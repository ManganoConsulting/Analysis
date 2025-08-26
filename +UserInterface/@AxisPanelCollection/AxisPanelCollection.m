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
                    'Position',[parentPos(1),25,parentPos(3), parentPos(4)-25],...
                    'NumOfAxis',options.NumOfAxisPerPage,...
                    'Orientation',options.Orientation);
                addlistener(obj.Panel(i),'AxisEvent',@obj.axisEvent);                          

            end

            % Find directories
            this_dir = fileparts( mfilename( 'fullpath' ) );
            res_dir = fullfile( this_dir,'..','Resources' );
            
            % Create bottom arrows
            [image_left, ~ ] = imread(fullfile(res_dir,'leftArrow1.jpg'));
            obj.LeftArrowButton = uicontrol('Parent',obj.Container,...
                'Style','push',...
                'CData',image_left,...
                'Callback',@obj.pageSelectLeft_CB,...
                'Position',[6,6,20,15],...
                'UserData',1);
            obj.PageNumberDisplay= uicontrol('Parent',obj.Container,...
                            'Style','text',...
                            'String','1',...
                            'FontSize',10,...
                            'Position',[50,6,parentPos(3)-100,15],...
                            'HorizontalAlignment','Center'); 
            [image_right, ~ ] = imread(fullfile(res_dir,'rightArrow1.jpg'));
            obj.RightArrowButton = uicontrol('Parent',obj.Container,...
                'Style','push',...
                'CData',image_right,...
                'Callback',@obj.pageSelectRight_CB,...
                'Position',[parentPos(3)-26,6,20,15],...
                'UserData',1);
            
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
                        'Position',[parentPos(1),25,parentPos(3), parentPos(4)-25],...
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
      
            
            
%             totalNumAxis = obj.AxisHandleQueue.size;
%             numOfPages = totalNumAxis / numPP;
%             currentNumP = length( obj.Panel );
% 
%             
%             while ~isempty(obj.Panel)
%                 delete(obj.Panel(1));
%                 obj.Panel(1) = [];
%             end
%             
%             parentPos = getpixelposition(obj.Container);
%             for i = 1:numOfPages
%                 obj.Panel(i) = UserInterface.AxisPanel('Parent',obj.Container,...
%                     'Units','Pixels',...
%                     'Position',[parentPos(1),25,parentPos(3), parentPos(4)-25],...
%                     'NumOfAxis',numPP);
%             end
% 
%             % Create Queue for axis handles
%             obj.AxisHandleQueue = java.util.LinkedList();
%             for j = 1:length(obj.Panel)
%                 for i = 1:length(obj.Panel(j).Axis)
%                     obj.AxisHandleQueue.add(obj.Panel(j).Axis(i)); 
%                 end
%             end   
% 


            
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

           set(obj.LeftArrowButton,'Position',[6,6,20,15]);
           set(obj.PageNumberDisplay,'Position',[50,6,posPix(3)-100,15]); 
           set(obj.RightArrowButton,'Position',[posPix(3)-26,6,20,15]);

            for i = 1:length(obj.Panel)
                obj.Panel(i).Position = [0,25,posPix(3), posPix(4)-25];
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
 
    %% Methods - Delete
    methods
        function delete( obj )
            % Java Components 
            %obj.AxisHandleQueue = [];


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

    %         % Data
%             obj.SelectedPanel
%             obj.BorderType    
%     


        
        
        
        

        end % delete
    end
    
end
