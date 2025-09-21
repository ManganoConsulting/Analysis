classdef Slider < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        SliderJObj
        JSliderComp
        JSliderCont
        Parent
        Container
        MinTextField_EB
        MaxTextField_EB
        SelectedParameter_TB
        SelectedParameterValue_TB
    end % Public properties
    
    %% Public properties - Data Storage
    properties   
        Resolution = 100
        Min
        Max
        Value = 50
        
        Parameter UserInterface.ControlDesign.Parameter = UserInterface.ControlDesign.Parameter
        
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )  
        PrivatePosition
        PrivateUnits
        PrivateVisible
        
%         PrivateMin = 0
%         PrivateMax
        PrivateValue
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
        MinString
        MaxString
%         Min
%         Max
%         Value
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )
     

    end % Dependant properties
    
    %% Events
    events
        StateChangedCallback
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = Slider(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Min',0);
            addParameter(p,'Max',100);
            addParameter(p,'Value',50);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            %obj.Parent = options.Parent;
            
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Min             = options.Min;
            obj.Max             = options.Max;
            obj.Value           = options.Value;
            
            createView( obj , options.Parent );

        end % ParameterCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
        
        function set.Value( obj , value )
            if ischar(value)
                testNum = str2double(value);
                if isnan(testNum)
                    obj.Value = 0;     
                else
                    obj.Value = value;     
                end
            else
                obj.Value = value;
            end
        end % Value - Set
                
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
        
        function y = get.MinString(obj)
            y = num2str(obj.Min);          
        end % MinString - Get
        
        function y = get.MaxString(obj)
            y = num2str(obj.Max);         
        end % MaxString - Get
        
    end % Property access methods
    
    %% Methods - View
    methods     
        function createView( obj , parent )
            if nargin == 1
                obj.Parent = figure();
            else 
                obj.Parent = parent;
            end
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'resizeFcn',@obj.reSize)
            
            obj.SliderJObj = javax.swing.JSlider(javax.swing.JSlider.HORIZONTAL,0, obj.Resolution, obj.Value);
            %Turn on labels at major tick marks.
            obj.SliderJObj.setMajorTickSpacing(10);
            obj.SliderJObj.setMinorTickSpacing(1);
            obj.SliderJObj.setPaintTicks(true);
            obj.SliderJObj.setPaintLabels(false);

            sliderObjH = handle(obj.SliderJObj,'CallbackProperties');
%             set(sliderObjH, 'StateChangedCallback',@obj.changeSliderValue_CB);
            set(sliderObjH, 'MouseReleasedCallback',@obj.mouseReleased_CB);
            %set(sliderObjH, 'MouseDraggedCallback',@obj.changeSliderValue_CB);
            set(sliderObjH, 'MouseClickedCallback',@obj.mouseClicked_CB);

            [obj.JSliderComp,obj.JSliderCont] = javacomponent(obj.SliderJObj,[], obj.Container );
            obj.JSliderCont.Units = 'normal';
            obj.JSliderCont.Position = [0,0,1,1];
                
            pos = getpixelposition(obj.Container);
            
            % Min
            obj.MinTextField_EB = uicontrol(...
                'Parent',obj.Container,...
                'Style','edit',...
                'String', obj.MinString,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Units','Pixels',...
                'Position',[ 2 , (pos(4)/2) - 24 , 35 , 20 ],...
                'Callback',@obj.minSliderValue_CB);

            % Max
            obj.MaxTextField_EB = uicontrol(...
                'Parent',obj.Container,...
                'Style','edit',...
                'String', obj.MaxString,...
                'BackgroundColor', [1 1 1],...
                'Enable','on',...
                'Units','Pixels',...
                'Position',[ pos(3) - 36, (pos(4)/2) - 24 , 35 , 20 ],...
                'Callback',@obj.maxSliderValue_CB);
            
            % Parameter Name
            obj.SelectedParameter_TB = uicontrol(...
                'Parent',obj.Container,...
                'Style','text',...
                'String', obj.Parameter.Name,...
                'Enable','on',...
                'Units','Pixels',...
                'Position',[ pos(3) - 36, (pos(4)/2)  , 35 , 20 ]);
            
            % Parameter Value
            obj.SelectedParameterValue_TB = uicontrol(...
                'Parent',obj.Container,...
                'Style','text',...
                'String', obj.Parameter.DisplayString,...
                'Enable','on',...
                'Units','Pixels',...
                'Position',[ pos(3) - 36, 1  , 35 , 20 ]);
                            
        end % createView
    end
    
    %% Methods - Ordinary
    methods 
        function setMinimum( obj , min )
            obj.Min = min;
            updateSliderValue( obj );
            update( obj );
        end % setMinimum
        
        function setMaximum( obj , max )
            obj.Max = max;
            updateSliderValue( obj );
            update( obj );
        end % setMaximum
        
        function setValue( obj , value )
            obj.Value = value;
            updateSliderValue( obj );
            update( obj );
        end % setValue
        
        function setParameter( obj , param )
            obj.Parameter = param;
            obj.Visible = param.SliderEnable;
            obj.Min   = param.Min;
            obj.Max   = param.Max;
            obj.Value = param.Value;
%             obj.Min
%             obj.Max
            updateSliderValue( obj );
            
            update( obj );
        end % setParameter
        
        function setSliderParameters( obj , min , max , value )
            obj.Min   = min;
            obj.Max   = max;
            obj.Value = value;
            
            updateSliderValue( obj );
            
            update( obj );
        end % setSliderParameters
        
    end % Ordinary Methods
    
    %% Methods - Callbacks Protected
    methods (Access = protected)  

        function minSliderValue_CB( obj , hobj , ~ )
            num = str2double(hobj.String);
            if ~isnan(num)
                obj.Min = num;
                updateSliderValue( obj );
            end
            update(obj);
        end % minSliderValue_CB
        
        function maxSliderValue_CB( obj , hobj , ~ )
            num = str2double(hobj.String);
            if ~isnan(num)
                obj.Max = num;
                updateSliderValue( obj );
            end
            update(obj);
        end % maxSliderValue_CB
        
%         function changeSliderValue_CB( obj , hobj , ~) 
%             obj.PrivateValue = hobj.getValue;
%             updateSliderValueGUI( obj );
%             update(obj);
%             notify(obj,'StateChangedCallback');
%         end % changeSliderValue_CB
        
        function mouseReleased_CB( obj , hobj , ~) 
            obj.PrivateValue = hobj.getValue;
            updateSliderValueGUI( obj );
            update(obj);
            notify(obj,'StateChangedCallback');
            %disp('Mouse released');
        end % mouseReleased_CB
        
        function mouseClicked_CB( obj , hobj , ~) 
            %disp('Mouse clicked');
        end % mouseClicked_CB
              
        function MouseDraggedCallback( obj , hobj , ~) 
            %disp('Mouse dragged');
        end % MouseDraggedCallback
        
    end    
    
    %% Methods - Protected
    methods (Access = protected)  
        
        function updateSliderValue( obj )
            if obj.Value < obj.Min
                obj.Min = obj.Value;
            elseif obj.Value > obj.Max
                obj.Max = obj.Value;
            elseif obj.Value == 0 %isnan(obj.Value)
                obj.Min = -1;
                obj.Max = 1;
            end         
            stepSize     = (obj.Max - obj.Min) / obj.Resolution;
            privateValue = round((obj.Value - obj.Min) / stepSize);
            obj.PrivateValue = privateValue;

            obj.Value = stepSize * obj.PrivateValue + obj.Min;
            %obj.Value
        end % updateSliderValue
        
        function updateSliderValueGUI( obj )       
            stepSize     = (obj.Max - obj.Min) / obj.Resolution;
            obj.Value = stepSize * obj.PrivateValue + obj.Min;
            %obj.Value
        end % updateSliderValueGUI
        
        function reSize( obj , ~ , ~ )
            
            pos = getpixelposition(obj.Container); 
            set(obj.MinTextField_EB,'Units','Pixels','Position',[ 2 , (pos(4)/2) - 24 , 35 , 20 ]); 
            set(obj.MaxTextField_EB,'Units','Pixels','Position',[ pos(3) - 36, (pos(4)/2) - 24 , 35 , 20 ]); 
            set(obj.SelectedParameter_TB,'Units','Pixels','Position',[ (pos(3)/2) - 100 , (pos(4) - 15) , 200 , 15 ]); 
            set(obj.SelectedParameterValue_TB,'Units','Pixels','Position',[ (pos(3)/2) - 100 , 1 , 200 , 15 ]); 
        end % reSize

        function update(obj)
            obj.SliderJObj.setMinimum(0);
            obj.SliderJObj.setMaximum(obj.Resolution);
            obj.SliderJObj.setValue(obj.PrivateValue);
            obj.MinTextField_EB.String = obj.MinString;
            obj.MaxTextField_EB.String = obj.MaxString; 
            
            
            if ~isempty(obj.Parameter) && obj.Parameter.SliderEnable
                obj.Parameter.Min         = obj.Min;
                obj.Parameter.Max         = obj.Max;
                obj.Parameter.ValueString = num2str(obj.Value);
                obj.SelectedParameter_TB.String = obj.Parameter.Name;
                obj.SelectedParameterValue_TB.String = obj.Parameter.DisplayString;
            end
        end % update
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the AvaliableParameterSelection object
            cpObj.AvaliableParameterSelection = copy(obj.AvaliableParameterSelection);
        end
        
    end
    
end


