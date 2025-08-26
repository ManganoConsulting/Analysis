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
        ASCBComp_X
        ASCBCont_X
        ASCBComp_Y
        ASCBCont_Y
        XLim_divider
        YLim_divider
        OKButton
        Apply2AllComp
        Apply2AllCont
        AxH
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        Title
        XLimMin
        XLimMax
        YLimMin
        YLimMax
        AutoScale_X = false
        AutoScale_Y = false
        Apply2All = false
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
            
            if strcmp(get(obj.AxH,'XLimMode'),'auto')
                obj.AutoScale_X = true;
            end
            
            if strcmp(get(obj.AxH,'YLimMode'),'auto')
                obj.AutoScale_Y = true;
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
        
           
        AutoScale_X_JCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
        AutoScale_X_JCheckbox.setText('Auto-X');        
        AutoScale_X_JCheckboxH = handle(AutoScale_X_JCheckbox,'CallbackProperties');
        set(AutoScale_X_JCheckboxH, 'ActionPerformedCallback',@obj.AutoScale_X_Checkbox_CB)
        AutoScale_X_JCheckbox.setToolTipText('Auto X');
        AutoScale_X_JCheckbox.setBorder([]);
        AutoScale_X_JCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
        [obj.ASCBComp_X,obj.ASCBCont_X] = javacomponent(AutoScale_X_JCheckbox,[], obj.LimitsTab );
        
        AutoScale_Y_JCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
        AutoScale_Y_JCheckbox.setText('Auto-Y');        
        AutoScale_Y_JCheckboxH = handle(AutoScale_Y_JCheckbox,'CallbackProperties');
        set(AutoScale_Y_JCheckboxH, 'ActionPerformedCallback',@obj.AutoScale_Y_Checkbox_CB)
        AutoScale_Y_JCheckbox.setToolTipText('Auto Y');
        AutoScale_Y_JCheckbox.setBorder([]);
        AutoScale_Y_JCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
        [obj.ASCBComp_Y,obj.ASCBCont_Y] = javacomponent(AutoScale_Y_JCheckbox,[], obj.LimitsTab );
        
        % Ok
        obj.OKButton = uicontrol(...
            'Parent',obj.Container,...
            'Style','push',...
            'String', 'OK',...
            'Enable','on',...
            'Callback',@obj.okButton_CB);  
        
%         obj.Apply2AllToggle = uicontrol(...
%             'Parent',obj.Container,...
%             'Style','toggle',...
%             'String', 'Apply to All',...
%             'Enable','on',...
%             'Callback',@obj.apply2All_CB); 
        
        Apply2All_JCheckbox = javaObjectEDT('com.mathworks.toolstrip.components.TSCheckBox');
        Apply2All_JCheckbox.setText('Apply to All');        
        Apply2All_JCheckboxH = handle(Apply2All_JCheckbox,'CallbackProperties');
        set(Apply2All_JCheckboxH, 'ActionPerformedCallback',@obj.apply2All_CB)
        Apply2All_JCheckbox.setToolTipText('Apply to all plots on the page');
        Apply2All_JCheckbox.setBorder([]);
        Apply2All_JCheckbox.setMargin(java.awt.Insets(0, 0, 0, 0));
        [obj.Apply2AllComp,obj.Apply2AllCont] = javacomponent(Apply2All_JCheckbox,[], obj.Container );
        
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
        
        function AutoScale_X_Checkbox_CB( obj , hobj , eventdata )
            obj.AutoScale_X = eventdata.getSource.isSelected;
            update(obj);
        end % AutoScale_X_Checkbox_CB
        
        function AutoScale_Y_Checkbox_CB( obj , hobj , eventdata )
            obj.AutoScale_Y = eventdata.getSource.isSelected;
            update(obj);
        end % AutoScale_Y_Checkbox_CB
        
        function okButton_CB( obj , hobj , eventdata )
            closeFigure_CB(obj , obj.Parent , [] );
        end % okButton_CB
        
        function apply2All_CB( obj , hobj , eventdata )
            obj.Apply2All = eventdata.getSource.isSelected;
            update(obj);    
        end % apply2All_CB
        
    end
    
    %% Methods - Ordinary
    methods                
        
        function reSize( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            
            set(obj.LabelCont,'Units','Pixels','Position',[ 1 , panelPos(4) - 25 , panelPos(3) , 25 ] );  
            set(obj.TabPanel,'Units','Pixels','Position',[ 1 , 25 , panelPos(3) , panelPos(4) - 50 ] );  
            set(obj.OKButton,'Units','Pixels','Position',[ 10 , 5 , 40 , 20 ] ); 
            set(obj.Apply2AllCont,'Units','Pixels','Position',[ 110 , 5 , 80 , 20 ] ); 
        
            
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
            
            set(obj.ASCBCont_X,'Units','Pixels','Position',[ 1 , panelPos(4) - 150 , 75 , 25 ] ); 
            
            set(obj.ASCBCont_Y,'Units','Pixels','Position',[ 100 , panelPos(4) - 150 , 75 , 25 ] ); 

        end %reSize
        
        function update(obj)
            
            if obj.AutoScale_X
                enableState_X = 'off';
            else
                enableState_X = 'on';
            end
            if obj.AutoScale_Y
                enableState_Y = 'off';
            else
                enableState_Y = 'on';
            end
            set(obj.XLimMin_eb,'Enable',enableState_X ); 
            set(obj.XLimMax_eb,'Enable',enableState_X);      
            set(obj.YLimMin_eb,'Enable',enableState_Y );       
            set(obj.YLimMax_eb,'Enable',enableState_Y ); 
            
        
            set(obj.XLimMin_eb,'String',num2str(obj.XLimMin) ); 

            set(obj.XLimMax_eb,'String',num2str(obj.XLimMax) );  
            
            set(obj.YLimMin_eb,'String',num2str(obj.YLimMin) );  
            
            set(obj.YLimMax_eb,'String',num2str(obj.YLimMax) ); 
            
            obj.ASCBComp_X.setSelected(obj.AutoScale_X ); 
            obj.ASCBComp_Y.setSelected(obj.AutoScale_Y ); 

            if obj.AutoScale_X
                set(obj.AxH,'XLimMode','auto');
            else
                obj.AxH.XLim = obj.XLim;   
            end
            
            if obj.AutoScale_Y
                set(obj.AxH,'YLimMode','auto');
            else
                obj.AxH.YLim = obj.YLim;     
            end
            
            obj.Apply2AllComp.setSelected(obj.Apply2All ); 
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


