classdef SetAxesProperties < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)
        Parent
        Container
        
        LabelComp
        LabelCont
        
        TabPanel
        LimitsTab
        GridTab
            
        XLimMin_eb
        XLimMax_eb
        YLimMin_eb
        YLimMax_eb
        XLim_label
        YLim_label
        ASCBComp
        ASCBCont
        XLim_divider
        YLim_divider
        OKButton
        
        AxH
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        Title
        XLimMin
        XLimMax
        YLimMin
        YLimMax
        AutoScale = false
    end % Public properties
    
    %% Properties - Observable
    properties%(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )      
        PrivatePosition
        PrivateUnits
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
        XLim
        YLim
    end % Dependant properties
    
    %% Events
    events

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = SetAxesProperties(varargin) 
            p = inputParser;
            addRequired(p,'AxesH');
            addParameter(p,'Parent',[]);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'XLim',[0,1]);
            addParameter(p,'YLim',[0,1]);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;
            
            
            obj.AxH = options.AxesH;
            
            if strcmp(get(obj.AxH,'XLimMode'),'auto') && strcmp(get(obj.AxH,'XLimMode'),'auto')
                obj.AutoScale = true;
            end
            
            
            xLim = obj.AxH.XLim;
            yLim = obj.AxH.YLim;
            
            obj.XLimMin         = xLim(1);
            obj.XLimMax         = xLim(2);
            obj.YLimMin         = yLim(1);
            obj.YLimMax         = yLim(2);         
            

            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;


            if isempty(options.Parent)
                createView( obj );
            else
                createView( obj , options.Parent );
            end
            update(obj);
        end % SetAxesProperties
        
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
        
        function y = get.XLim(obj)
            y = [obj.XLimMin,obj.XLimMax];          
        end % XLim - Get 
        
        function y = get.YLim(obj)
            y = [obj.YLimMin,obj.YLimMax];          
        end % YLim - Get 
        
    end % Property access methods
    
    %% Methods - View
    methods   
            
        function createView( obj , parent )
            import javax.swing.*;
%             this_dir = fileparts( mfilename( 'fullpath' ) );
%             icon_dir = fullfile( this_dir,'..','Resources' ); 
            
            if nargin == 1
                sz = [ 250 , 200]; % figure size
                screensize = get(0,'ScreenSize');
                xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
                ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically

                obj.Parent = dialog('Name',obj.Title,...
                                    'Units','Pixels',...
                                    'Position',[xpos, ypos, sz(2), sz(1)],...
                                    'WindowStyle','normal',...
                                    'Resize','on',...
                                    'CloseRequestFcn', @obj.closeFigure_CB);
            else
                obj.Parent = parent;
            end

            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            
            % Previous Applications
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Axis Properties</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.LabelComp,obj.LabelCont] = javacomponent(jLabelview,[ ], obj.Container );
            
            
                obj.TabPanel = uitabgroup('Parent',obj.Container); 

                

                obj.LimitsTab  = uitab('Parent',obj.TabPanel);
                obj.LimitsTab.Title = 'Limits';

                obj.GridTab  = uitab('Parent',obj.TabPanel);
                obj.GridTab.Title = 'Grid';
            
        obj.XLim_label = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','text',...
            'String', 'X - Limit',...
            'Enable','on');  
        
        obj.XLimMin_eb = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','edit',...
            'String', obj.XLimMin,...
            'BackgroundColor', [1 1 1],...
            'Enable','on',...
            'Callback',@obj.xLimMin_CB);
        
        obj.XLim_divider = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','text',...
            'String', '-',...
            'HorizontalAlignment','Center',...
            'Enable','on');  
        
                
        obj.XLimMax_eb = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','edit',...
            'String', obj.XLimMax,...
            'BackgroundColor', [1 1 1],...
            'Enable','on',...
            'Callback',@obj.xLimMax_CB);
        
        obj.YLim_label = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','text',...
            'String', 'Y - Limit',...
            'Enable','on'); 
        
        obj.YLimMin_eb = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','edit',...
            'String', obj.YLimMin,...
            'BackgroundColor', [1 1 1],...
            'Enable','on',...
            'Callback',@obj.yLimMin_CB);
        
        obj.YLim_divider = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','text',...
            'String', '-',...
            'HorizontalAlignment','Center',...
            'Enable','on'); 
                
        obj.YLimMax_eb = uicontrol(...
            'Parent',obj.LimitsTab,...
            'Style','edit',...
            'String', obj.YLimMax,...
            'BackgroundColor', [1 1 1],...
            'Enable','on',...
            'Callback',@obj.yLimMax_CB);    
        
           
        autoScaleJCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
        autoScaleJCheckbox.setText('AutoScale');        
        autoScaleJCheckboxH = handle(autoScaleJCheckbox,'CallbackProperties');
        set(autoScaleJCheckboxH, 'ActionPerformedCallback',@obj.autoScaleCheckbox_CB)
        autoScaleJCheckbox.setToolTipText('Show line markers');
        autoScaleJCheckbox.setBorder([]);
        autoScaleJCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
        [obj.ASCBComp,obj.ASCBCont] = javacomponent(autoScaleJCheckbox,[], obj.LimitsTab );
        
        % Ok
        obj.OKButton = uicontrol(...
            'Parent',obj.Container,...
            'Style','push',...
            'String', 'OK',...
            'Enable','on',...
            'Callback',@obj.okButton_CB);   
        
        
        reSize( obj , [] , [] );
        end % createView
        
    end
    
    %% Methods - Protected Callbacks
    methods (Access = protected) 
        
        function xLimMin_CB( obj , hobj , eventdata )
            try %#ok<TRYNC>
                num = str2double(hobj.String);
                if ~isnan(num) 
                    if isempty(obj.XLimMax) || num < obj.XLimMax
                        obj.XLimMin = num;
                    else
                        errordlg('The value must be less than the upper limit.')
                    end
                end
            end
            update(obj);
        end % xLimMin_CB
        
        function xLimMax_CB( obj , hobj , eventdata )
            try %#ok<TRYNC>
                num = str2double(hobj.String);
                if ~isnan(num) 
                    if isempty(obj.XLimMin) || num > obj.XLimMin
                        obj.XLimMax = num;
                    else
                        errordlg('The value must be greter than the lower limit.')
                    end
                end
            end
            update(obj);
        end % xLimMax_CB
        
        function yLimMin_CB( obj , hobj , eventdata )
            try %#ok<TRYNC>
                num = str2double(hobj.String);
                if ~isnan(num) 
                    if isempty(obj.YLimMax) || num < obj.YLimMax
                        obj.YLimMin = num;
                    else
                        errordlg('The value must be less than the upper limit.')
                    end
                end
            end
            update(obj);
        end % yLimMin_CB
        
        function yLimMax_CB( obj , hobj , eventdata )
            try %#ok<TRYNC>
                num = str2double(hobj.String);
                if ~isnan(num) 
                    if isempty(obj.YLimMin) || num > obj.YLimMin
                        obj.YLimMax = num;
                    else
                        errordlg('The value must be greter than the lower limit.')
                    end
                end
            end
            update(obj);
        end % yLimMax_CB
        
        function autoScaleCheckbox_CB( obj , hobj , eventdata )
            obj.AutoScale = eventdata.getSource.isSelected;
            update(obj);
        end % autoScaleCheckbox_CB
        
        function okButton_CB( obj , hobj , eventdata )
            closeFigure_CB(obj , obj.Parent , [] );
        end % okButton_CB
        
    end
    
    %% Methods - Ordinary
    methods                
        
        function reSize( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            
            set(obj.LabelCont,'Units','Pixels','Position',[ 1 , panelPos(4) - 25 , panelPos(3) , 25 ] );  
            set(obj.TabPanel,'Units','Pixels','Position',[ 1 , 25 , panelPos(3) , panelPos(4) - 50 ] );  
            set(obj.OKButton,'Units','Pixels','Position',[ 10 , 5 , 40 , 20 ] );  
            drawnow();
            panelPos = getpixelposition(obj.LimitsTab); 
            
            set(obj.XLim_label,'Units','Pixels','Position',[ 1 ,  panelPos(4) - 30 , 60 , 15 ] );  
        
            set(obj.XLimMin_eb,'Units','Pixels','Position',[ 1 ,  panelPos(4) - 55 , 75 , 25 ] ); 
            
            set(obj.XLim_divider,'Units','Pixels','Position',[ 76  , panelPos(4) - 55 , 24 , 25 ] ); 

            set(obj.XLimMax_eb,'Units','Pixels','Position',[ 100 , panelPos(4) - 55 , 75 , 25 ] );  
            
            set(obj.YLim_label,'Units','Pixels','Position',[ 1  , panelPos(4) - 85 , 60 , 15 ] ); 

            set(obj.YLimMin_eb,'Units','Pixels','Position',[ 1  , panelPos(4) - 110 , 75 , 25 ] );  
            
            set(obj.YLim_divider,'Units','Pixels','Position',[ 76  , panelPos(4) - 110 , 24 , 25 ] ); 
                
            set(obj.YLimMax_eb,'Units','Pixels','Position',[ 100 , panelPos(4) - 110 , 75 , 25 ] ); 
            
            set(obj.ASCBCont,'Units','Pixels','Position',[ 1 , panelPos(4) - 150 , 75 , 25 ] ); 

        end %reSize
        
        function update(obj)
            
            if obj.AutoScale
                enableState = 'off';
            else
                enableState = 'on';
            end
            set(obj.XLimMin_eb,'Enable',enableState ); 
            set(obj.XLimMax_eb,'Enable',enableState);      
            set(obj.YLimMin_eb,'Enable',enableState );       
            set(obj.YLimMax_eb,'Enable',enableState ); 
            
        
            set(obj.XLimMin_eb,'String',num2str(obj.XLimMin) ); 

            set(obj.XLimMax_eb,'String',num2str(obj.XLimMax) );  
            
            set(obj.YLimMin_eb,'String',num2str(obj.YLimMin) );  
            
            set(obj.YLimMax_eb,'String',num2str(obj.YLimMax) ); 
            
            obj.ASCBComp.setSelected(obj.AutoScale ); 


            if obj.AutoScale
                set(obj.AxH,'XLimMode','auto');
                set(obj.AxH,'YLimMode','auto');
                set(obj.AxH,'ZLimMode','auto'); 
            else
                obj.AxH.XLim = obj.XLim;
                obj.AxH.YLim = obj.YLim;     
            end
        end % update        
        
        function setWaitPtr(obj)
            fig = ancestor(obj.Parent,'figure','toplevel');
            set(fig, 'pointer', 'watch');
            drawnow;
        end % setWaitPtr

        function releaseWaitPtr(obj)
            fig = ancestor(obj.Parent,'figure','toplevel');
            set(fig, 'pointer', 'arrow'); 
        end % releaseWaitPtr  
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)  
        
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
%             cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the AvaliableParameterSelection object
%             cpObj.AvaliableParameterSelection = copy(obj.AvaliableParameterSelection);
        end % copyElement
        
        function closeFigure_CB(obj , hobj , ~ )
            delete(hobj);      
        end % closeFigure_CB
        
    end
    
end


