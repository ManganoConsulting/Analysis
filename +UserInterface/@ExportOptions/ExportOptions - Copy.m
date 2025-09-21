classdef ExportOptions < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)
        ButtonGroup
        Figure
        DialogParent matlab.ui.Figure = matlab.ui.Figure.empty

        All_Button
        Select_Button
        SelectPages_EB
        OK_Button
        Cancel_Button
        Range_Text

        % ADDED: checkbox handle
        Transpose_Check
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        RangeString = ''
        Range = [] % Empty = All , 0 = Cancel 

        % ADDED: user choice for transposed output
        Transpose logical = false
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
        function obj = ExportOptions(parentFigure)
            if nargin < 1
                parentFigure = [];
            end
            obj.DialogParent = Utilities.getParentFigure(parentFigure);
            createView( obj );
        end % ExportOptions
    end % Constructor

    %% Methods - View
    methods 
        function createView( obj )
            % ==== Sizing ====
            % [height, width]
            sz = [230 , 380];                      % was [200, 300]
            screensize = get(0,'ScreenSize');
            xpos = ceil((screensize(3)-sz(2))/2);
            ypos = ceil((screensize(4)-sz(1))/2);
        
            obj.Figure = figure('Name','Export Options',...
                                'Units','pixels',...
                                'Position',[xpos, ypos, sz(2), sz(1)],...
                                'Menubar','none',...
                                'Toolbar','none',...
                                'NumberTitle','off',...
                                'HandleVisibility','on',...
                                'WindowStyle','modal',...
                                'Resize','off',...
                                'Resizefcn',[],...
                                'Visible','on',...
                                'CloseRequestFcn', @obj.closeFigure_CB);
        
            % ==== Left group: All vs Specific Columns ====
            obj.ButtonGroup = uibuttongroup('Parent',obj.Figure,...
                              'Title','Options',...
                              'Visible','off',...
                              'Units','pixels',...
                              'Position',[12 , 120 , 170 , 90],...
                              'SelectionChangedFcn',@obj.selectionChg);
        
            obj.All_Button = uicontrol(obj.ButtonGroup,'Style','radiobutton',...
                              'String','All',...
                              'Position',[10 50 120 18],...
                              'HandleVisibility','off');
        
            obj.Select_Button = uicontrol(obj.ButtonGroup,'Style','radiobutton',...
                              'String','Specific Columns',...
                              'Position',[10 22 150 18],...
                              'HandleVisibility','off');
        
            % ==== Right-side buttons ====
            obj.OK_Button = uicontrol('Parent',obj.Figure,'Style','pushbutton',...
                'String','OK','FontSize',9,'FontWeight','demi',...
                'Units','pixels','Position',[280 , 150 , 80 , 30 ],...
                'Callback',@obj.okButtonPressed);
        
            obj.Cancel_Button = uicontrol('Parent',obj.Figure,'Style','pushbutton',...
                'String','CANCEL','FontSize',9,'FontWeight','demi',...
                'Units','pixels','Position',[280 , 110 , 80 , 30 ],...
                'Callback',@obj.cancelButtonPressed);
        
            % ==== Range label + edit ====
            obj.Range_Text = uicontrol('Parent',obj.Figure,'Style','text',...
                'String','Column Range: ( ex. 1-4,6,9-11 )',...
                'FontSize',10,'FontWeight','demi',...
                'Units','pixels','HorizontalAlignment','left',...
                'Position',[12 , 80 , 350 , 20]);
        
            obj.SelectPages_EB = uicontrol('Parent',obj.Figure,'Style','edit',...
                'String',obj.RangeString,'FontSize',11,'BackgroundColor',[1 1 1],...
                'Units','pixels','Enable','off',...
                'Position',[12 , 50 , 240 , 26],...
                'Callback',@obj.selectedPages_CB);
        
            % ==== Transpose checkbox (clean line, full text visible) ====
            obj.Transpose_Check = uicontrol('Parent',obj.Figure,'Style','checkbox',...
                'String','Transpose output (rows ↔ columns)',...
                'Value',logical(obj.Transpose),...
                'Units','pixels',...
                'Position',[12 , 20 , 260 , 22],...
                'Callback',@obj.transpose_CB);
        
            % Reveal group after children are created
            obj.ButtonGroup.Visible = 'on';
        end % createView
    end

    %% Methods - Private
    methods (Access = private)
        function fig = getDialogParent(obj)
            fig = obj.DialogParent;
            if isempty(fig) || ~isvalid(fig)
                fig = Utilities.getParentFigure(obj.Figure);
            end
            if isempty(fig) || ~isvalid(fig)
                error('UserInterface:ExportOptions:MissingParentFigure', ...
                    'A valid UIFigure parent must be supplied when creating ExportOptions.');
            end
        end
    end

    %% Methods - Protected Callbacks
    methods (Access = protected)
        function selectionChg( obj , ~ , eventdata )
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
                uialert(obj.getDialogParent(), 'Only numeric characters "," and "-" can be used to define a range', 'Invalid Range');
                update(obj);
            end
        end % selectedPages_CB

        % ADDED: checkbox callback
        function transpose_CB(obj, hobj, ~)
            obj.Transpose = logical(get(hobj,'Value'));
        end
        
        function okButtonPressed( obj , ~ , ~ )
            delete(obj.Figure);
        end % okButtonPressed
        
        function cancelButtonPressed( obj , ~ , ~ )
            obj.Range = 0;
            delete(obj.Figure);
        end % cancelButtonPressed
        
        function closeFigure_CB( obj , ~ , ~ )
            obj.Range = 0;
            delete(obj.Figure);
        end % closeFigure_CB
    end
    
    %% Methods - Ordinary Methods
    methods
        function update( obj )
            obj.SelectPages_EB.String = obj.RangeString;
            % ADDED: keep checkbox synced
            if isvalid(obj.Transpose_Check)
                obj.Transpose_Check.Value = logical(obj.Transpose);
            end
        end % update
    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end % copyElement
    end
end


function y = getStrRangeAsVector(x)   
    expression = '[^0-9,-]';
    matchStr = regexp(x,expression,'match');
    if ~isempty(matchStr)
        error('Only numeric characters "," and "-" can be used to define a range');
    end
    xx = strrep(x, '-', ':');
    xx1 = eval(['[',xx,']']); %#ok<EVLDIR> 
    xx2 = unique(xx1);
    y = sort(xx2);
end % getStrRangeAsVector
