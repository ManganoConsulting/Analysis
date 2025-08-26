classdef ExportOptions < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        ButtonGroup
        Figure
        
        All_Button
        Select_Button
        SelectPages_EB
        OK_Button
        Cancel_Button
        Range_Text
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        RangeString = ''
        Range = [] % Empty = All , 0 = Cancel 
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

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = ExportOptions( )

            createView( obj );

        
        end % ExportOptions
        
    end % Constructor

    %% Methods - Property Access
    methods
                  

        
    end % Property access methods
    
    %% Methods - View
    methods 
        function createView( obj )
            
            sz = [ 200 , 300]; % figure size
            screensize = get(0,'ScreenSize');
            xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
            ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically
            obj.Figure = figure('Name','Export Options',...%Control',...
                                'units','pixels',...
                                'Position',[xpos, ypos, sz(2), sz(1)],...%[193 , 109 , 1384 , 960],...%[193,109,1368,768],
                                'Menubar','none',...   
                                'Toolbar','none',...
                                'NumberTitle','off',...
                                'HandleVisibility', 'on',...
                                'WindowStyle','modal',...
                                'Resize','off',...
                                'Resizefcn',[],...
                                'Visible','on',...
                                'CloseRequestFcn', @obj.closeFigure_CB);
            obj.ButtonGroup = uibuttongroup('Parent',obj.Figure,...
                              'Title','Options',...
                              'Visible','off',...
                              'Units','Pixels',...
                              'Position',[10 , 75 , 150 , 85],...
                              'SelectionChangedFcn',@obj.selectionChg);

            % Create three radio buttons in the button group.
            obj.All_Button = uicontrol(obj.ButtonGroup,'Style',...
                              'radiobutton',...
                              'String','All',...
                              'Position',[10 45 70 15],...
                              'HandleVisibility','off');

            obj.Select_Button = uicontrol(obj.ButtonGroup,'Style','radiobutton',...
                              'String','Specific Columns',...
                              'Position',[10 15 130 15],...
                              'HandleVisibility','off');
            obj.Range_Text =uicontrol(...
                'Parent',obj.Figure,...
                'Style','text',...
                'String', 'Column Range: ( ex. 1-4,6,9-11 )',...
                'FontSize',10,...
                'FontWeight','demi',...
                'Units','Pixels',...
                'Position',[10 , 45 , 750 , 18],...
                'HorizontalAlignment','left');          
                          
                          
            obj.SelectPages_EB = uicontrol(...
                'Parent',obj.Figure,...
                'Style','edit',...
                'String', obj.RangeString,...
                'FontSize',12,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Enable','off',...
                'Position',[ 10 , 10 , 150 , 30],...
                'Callback',@obj.selectedPages_CB);
            
            
            obj.OK_Button = uicontrol(...
                'Parent',obj.Figure,...
                'Style','pushbutton',...
                'String', 'OK',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 200 , 120 , 75 , 30 ],...
                'Callback',@obj.okButtonPressed);
            
            obj.Cancel_Button = uicontrol(...
                'Parent',obj.Figure,...
                'Style','pushbutton',...
                'String', 'CANCEL',...
                'FontSize',8,...
                'FontWeight','demi',...
                'HorizontalAlignment','left',...
                'Units','Pixels',...
                'Position',[ 200 , 80 , 75 , 30 ],...
                'Callback',@obj.cancelButtonPressed);

            % Make the uibuttongroup visible after creating child objects. 
            obj.ButtonGroup.Visible = 'on';   
            
            
        end % createView
    end
  
    %% Methods - Protected Callbacks
    methods (Access = protected)
        function selectionChg( obj , hobj , eventdata )
           
           
           switch eventdata.NewValue.String
               case 'All'
                   obj.SelectPages_EB.Enable = 'off';
                   obj.Range = [];
               otherwise
                   obj.SelectPages_EB.Enable = 'on';
           end
        end % selectionChg
        
        function selectedPages_CB( obj , hobj , eventdata )
            str = eventdata.Source.String;
            try
                obj.Range = getStrRangeAsVector(str);
            catch
                msgbox('Only numeric characters "," and "-" can be used to define a range')
                update(obj);
            end
        end % selectedPages_CB
        
        function okButtonPressed( obj , hobj , eventdata )
            delete(obj.Figure);
        end % okButtonPressed
        
        function cancelButtonPressed( obj , hobj , eventdata )
            obj.Range = 0;
            delete(obj.Figure);
        end % cancelButtonPressed
        
        function closeFigure_CB( obj , hobj ,eventdata )
            obj.Range = 0;
            delete(obj.Figure);
        end % closeFigure_CB
    end
    
    %% Methods - Resize Ordinary Methods
    methods     

                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods
        function update( obj )
            obj.SelectPages_EB.String = obj.RangeString;
            
            
        end % update
    

        
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        
  

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


function y = getStrRangeAsVector(x)   
    expression = '[^0-9,-]';
    matchStr = regexp(x,expression,'match');
    if ~isempty(matchStr)
        error('Only numeric characters "," and "-" can be used to define a range');
    end


    xx = strrep(x, '-', ':');
   xx1 = eval(['[',xx,']']);
   xx2 = unique(xx1);
   y = sort(xx2);

end % getStrRangeAsVector
