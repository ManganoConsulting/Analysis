classdef InfoWindow < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)
        Parent
        Container
        Frame
        TextPane
        JScroll
    end % Public properties
    
    %% Public properties - Data Storage
    properties   
        
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
    properties ( Dependent = true )
        Position
        Units
        Visible
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Events
    events
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = InfoWindow(str) 
            if nargin == 0
               return; 
            end  



            createView( obj , str );

        end % ParameterCollection
        
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
        
    end % Property access methods
    
    %% Methods - View
    methods     
        function createView( obj , str )
            
            import javax.swing.*;
            
            
            obj.TextPane = javaObjectEDT('javax.swing.JTextPane');
            obj.TextPane.setEditable(false);
            obj.TextPane.setText(str);
            obj.JScroll = javaObjectEDT(javax.swing.JScrollPane(obj.TextPane));
            
            % Create the frame and fill it with the image
            obj.Frame = JFrame(  );
            %obj.Frame.setUndecorated( true );
            

            
            p = obj.Frame.getContentPane();
            p.add( obj.JScroll );
            
            % Resize and reposition the window
            pos = get(0,'MonitorPositions');
            width = 600;
            height = pos(1,4)*0.75;
            obj.Frame.setSize( width , height );
            
            x0 =  (pos(1,3) - width)/2;%pos(1,1) - (pos(1,3)-width)/2;
            y0 =  (pos(1,4)*0.25)/2;%pos(1,2) + (pos(1,4)-height)/2;
            obj.Frame.setLocation( x0, y0 );
            
            obj.Frame.setVisible(true);
            

        end % createView
    end
    
    %% Methods - Ordinary
    methods 
        

        
    end % Ordinary Methods

    %% Methods - Protected Callbacks
    methods (Access = protected) 



    end

    %% Methods - Protected
    methods (Access = protected)  

        
    end
    
end


