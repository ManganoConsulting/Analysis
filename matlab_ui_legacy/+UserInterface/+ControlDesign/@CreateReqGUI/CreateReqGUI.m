classdef CreateReqGUI < UserInterface.Collection
    
    %% Public properties - Object Handles
    properties            
        
        EditPanel
        EditGridContainer
        AxisPanel
        ViewMethodPB
        MethodText
        MethodEB
        ViewModelPB
        ViewModelText
        MdlNameEB
        TitleText
        TitleEB
        OutDataIndText
        OutDataIndEB
        XlimText
        XlimEB
        YlimText
        YlimEB
        XlabelText
        XlabelEB
        YlabelText
        YlabelEB
        XPatchText
        XPatchEB
        YPatchText
        YPatchEB
        PatchFaceColorText
        PatchFaceColorEB
        PatchEdgeColorText
        PatchEdgeColorEB
        YAxisLocText
        YAxisLocEB
        GridFuncText
        GridFuncEB
        LineStyleText
        LineStyleEB
        LineWidthText
        LineWidthEB
        MarkerText
        MarkerEB
        MarkerSizeText
        MarkerSizeEB
        GridText
        GridEB
        XScaleText
        XScaleEB
        YScaleText
        YScaleEB
        GainsText
        GainsEB
        StateGainsNameText
        StateGainsNameEB
        StateGainsControlText
        StateGainsControlEB
        StateGainsStateNamesText
        StateGainsStateNamesEB
        RootLocusGainNameText
        RootLocusGainNameEB
        RootLocusGainVarText
        RootLocusGainVarEB
        PlotAxisH
        SaveReqUpdatePB
    end % Public properties
  
    %% Public properties - Data Storage
    properties   
        CurrentSelectedReqObj
        DisplayReqObj
    end % Public properties
    
    %% Methods - Constructor
    methods      
        
        function obj = CreateReqGUI(varargin)      
            if nargin == 0
               return; 
            end  

%             obj@UserInterface.Collection(varargin{:}); 
            createView( obj , obj.Parent );
        end % CreateReqGUI
        
    end % Constructor

    %% Methods - Property Access
    methods
   
    end % Property access methods
    
    %% Methods - View
    methods 
        function createView( obj , parent )
            obj.Parent = parent;
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1],...
                'ResizeFcn',@obj.resizeFcn);
                % Edit Panel
                obj.EditPanel = uipanel('Parent',obj.Container,...
                    'Units','Normal',...
                    'Position',[0,0,0.5,1],...
                    'ResizeFcn',@obj.editPanelResize);
                
                     obj.EditGridContainer = uigridcontainer('v0','Parent',obj.EditPanel,...
                        'Units','Normal',...
                        'Position',[0,0,1,1],...
                        'GridSize',[27,3],...
                        'HorizontalWeight',[1,3,6]);
                        % Method
                        obj.ViewMethodPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','View',...
                            'Callback',@obj.viewMethod);
                        obj.MethodText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Method:',...
                            'HorizontalAlignment','Right');
                        obj.MethodEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'FunName'});
                        % Model Name  
                        obj.ViewModelPB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','push',...
                            'String','View',...
                            'Callback',@obj.viewModel);
                        obj.ViewModelText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Model Name:',...
                            'HorizontalAlignment','Right');
                        obj.MdlNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'MdlName'}); 
                        % Title 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.TitleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Title:',...
                            'HorizontalAlignment','Right');
                        obj.TitleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Title'});
                        % Output Data Index
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.OutDataIndText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Output Data Index:',...
                            'HorizontalAlignment','Right');
                        obj.OutDataIndEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'OutputDataIndex'});
                        % XLim  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.XlimText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','X axis limits:',...
                            'HorizontalAlignment','Right');
                        obj.XlimEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'XLim'});
                        % YLim   
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.YlimText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Y axis limits:',...
                            'HorizontalAlignment','Right');
                        obj.YlimEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'YLim'}); 
                        % XLabel  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.XlabelText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','X axis label:',...
                            'HorizontalAlignment','Right');
                        obj.XlabelEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'XLabel'});   
                        % yLabel
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.YlabelText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Y axis label:',...
                            'HorizontalAlignment','Right');
                        obj.YlabelEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'YLabel'});  
                        % PatchXData 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.XPatchText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Patch (x-coordinates):',...
                            'HorizontalAlignment','Right');
                        obj.XPatchEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'PatchXData'});    
                        % PatchYData 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.YPatchText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Patch (y-coordinates):',...
                            'HorizontalAlignment','Right');
                        obj.YPatchEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'PatchYData'}); 
                        % PatchFaceColor 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.PatchFaceColorText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Patch face color:',...
                            'HorizontalAlignment','Right');
                        obj.PatchFaceColorEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'PatchFaceColor'});              
                        % PatchEdgeColor 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.PatchEdgeColorText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Patch edge color:',...
                            'HorizontalAlignment','Right');
                        obj.PatchEdgeColorEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'PatchEdgeColor'});                
                        % yAxisLocation 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.YAxisLocText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Location of the Y axis:',...
                            'HorizontalAlignment','Right');
                        obj.YAxisLocEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'yAxisLocation'});  
                        % GridFunction 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.GridFuncText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Grid Function:',...
                            'HorizontalAlignment','Right');
                        obj.GridFuncEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'GridFunction'});  
                        % LineStyle 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.LineStyleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Line Style:',...
                            'HorizontalAlignment','Right');
                        obj.LineStyleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'LineStyle'});  
                        % LineWidth 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.LineWidthText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Line Width:',...
                            'HorizontalAlignment','Right');
                        obj.LineWidthEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'LineWidth'});  
                        % Marker 
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.MarkerText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Marker Symbol:',...
                            'HorizontalAlignment','Right');
                        obj.MarkerEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Marker'});  
                        % MarkerSize  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.MarkerSizeText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Marker Size:',...
                            'HorizontalAlignment','Right');
                        obj.MarkerSizeEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'MarkerSize'});  
                        % Grid  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.GridText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Grid On:',...
                            'HorizontalAlignment','Right');
                        obj.GridEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Grid'});  
                        % XScale  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.XScaleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','X axis scale:',...
                            'HorizontalAlignment','Right');
                        obj.XScaleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'XScale'});  
                        % YScale  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.YScaleText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Y axis scale:',...
                            'HorizontalAlignment','Right');
                        obj.YScaleEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'YScale'});         
                        % Gain  
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.GainsText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Gains:',...
                            'HorizontalAlignment','Right');
                        obj.GainsEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'Gains'});         
                        % StateGainName
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.StateGainsNameText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','StateGains Name:',...
                            'HorizontalAlignment','Right');
                        obj.StateGainsNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'StateGainsName'});         
                        % StateGainControl
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.StateGainsControlText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','StateGains Control:',...
                            'HorizontalAlignment','Right');
                        obj.StateGainsControlEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'StateGainsControl'});         
                        % StateGainStateName
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.StateGainsStateNamesText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','StateGains State Name:',...
                            'HorizontalAlignment','Right');
                        obj.StateGainsStateNamesEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'StateGainsStateName'});         
                        % RootLocusGainName
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.RootLocusGainNameText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Root Locus Gain Name:',...
                            'HorizontalAlignment','Right');
                        obj.RootLocusGainNameEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'GainName'}); 
                        % RootLocusGainVar
                        uicontrol('Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','');
                        obj.RootLocusGainVarText = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','text',...
                            'String','Root Locus Gain Var:',...
                            'HorizontalAlignment','Right');
                        obj.RootLocusGainVarEB = uicontrol(...
                            'Parent',obj.EditGridContainer,...
                            'Style','edit',...
                            'String','',...
                            'BackgroundColor',[1 1 1],...
                            'Callback',{@obj.reqUpdate,'GainVariation'});   
                % Axis Panel       
                obj.AxisPanel = uipanel('Parent',obj.Container,...
                    'Units','Normal',...
                    'Position',[0.5,0,0.5,1],...
                    'ResizeFcn',@obj.axisPanelResize);     
                    obj.PlotAxisH =axes('Parent',obj.AxisPanel,...
                        'Units', 'Normalized',...
                        'Visible','on',...
                        'OuterPosition', [0 0.05 1 0.95] );
                    obj.SaveReqUpdatePB = uicontrol(...
                        'Parent',obj.AxisPanel,...
                        'Units', 'Normalized',...
                        'Style','push',...
                        'String','Save',...
                        'Position', [0 0 0.1 0.05],...
                        'Callback',@obj.saveReqUpdate);
                      
        end % createView

        
    end % View Methods
   
    %% Methods - Ordinary
    methods 
        
        function setReqObj(obj)
            cla(obj.PlotAxisH,'reset')
            obj.ReqDisplayed.FunName          = obj.CurrentSelectedReqObj.FunName;
            obj.ReqDisplayed.Title            = obj.CurrentSelectedReqObj.Title;
            obj.ReqDisplayed.MdlName          = obj.CurrentSelectedReqObj.MdlName;
            obj.ReqDisplayed.OutputDataIndex  = num2str(obj.CurrentSelectedReqObj.OutputDataIndex);
            obj.ReqDisplayed.XLim             = num2str(obj.CurrentSelectedReqObj.XLim);
            obj.ReqDisplayed.YLim             = num2str(obj.CurrentSelectedReqObj.YLim);
            obj.ReqDisplayed.XLabel           = obj.CurrentSelectedReqObj.XLabel;
            obj.ReqDisplayed.YLabel           = obj.CurrentSelectedReqObj.YLabel;

            if iscell(obj.CurrentSelectedReqObj.PatchFaceColor)
                PatchFaceColor = cellfun(@(x) strcat('[',num2str(x),']; '),obj.CurrentSelectedReqObj.PatchFaceColor,'uniformoutput',0);
                PatchFaceColor = strcat('{',strcat(PatchFaceColor{:}),'}');
                obj.ReqDisplayed.PatchFaceColor = PatchFaceColor;
            else
                obj.ReqDisplayed.PatchFaceColor       = num2str(obj.CurrentSelectedReqObj.PatchFaceColor);
            end

            if iscell(obj.CurrentSelectedReqObj.PatchEdgeColor)
                PatchEdgeColor = cellfun(@(x) strcat('[',num2str(x),']; '),obj.CurrentSelectedReqObj.PatchEdgeColor,'uniformoutput',0);
                PatchEdgeColor = strcat('{',strcat(PatchEdgeColor{:}),'}');
                obj.ReqDisplayed.PatchEdgeColor = PatchEdgeColor;
            else
                obj.ReqDisplayed.PatchEdgeColor       = num2str(obj.CurrentSelectedReqObj.PatchEdgeColor);
            end

            if iscell(obj.CurrentSelectedReqObj.PatchXData)
                PatchXData = cellfun(@(x) strcat('[',num2str(x),']; '),obj.CurrentSelectedReqObj.PatchXData,'uniformoutput',0);
                PatchXData = strcat('{',strcat(PatchXData{:}),'}');
                obj.ReqDisplayed.PatchXData = PatchXData;
            else
                obj.ReqDisplayed.PatchXData       = num2str(obj.CurrentSelectedReqObj.PatchXData);
            end

            if iscell(obj.CurrentSelectedReqObj.PatchYData)
                PatchYData = cellfun(@(x) strcat('[',num2str(x),']; '),obj.CurrentSelectedReqObj.PatchYData,'uniformoutput',0);
                PatchYData = strcat('{',strcat(PatchYData{:}),'}');
                obj.ReqDisplayed.PatchYData = PatchYData;
            else
                obj.ReqDisplayed.PatchYData       = num2str(obj.CurrentSelectedReqObj.PatchYData);
            end

            obj.ReqDisplayed.yAxisLocation    = obj.CurrentSelectedReqObj.yAxisLocation;
            obj.ReqDisplayed.GridFunction     = obj.CurrentSelectedReqObj.GridFunction;
            obj.ReqDisplayed.LineStyle        = obj.CurrentSelectedReqObj.LineStyle;
            obj.ReqDisplayed.LineWidth        = num2str(obj.CurrentSelectedReqObj.LineWidth);
            obj.ReqDisplayed.Marker           = obj.CurrentSelectedReqObj.Marker;
            obj.ReqDisplayed.MarkerSize       = num2str(obj.CurrentSelectedReqObj.MarkerSize);
            obj.ReqDisplayed.Grid             = num2str(obj.CurrentSelectedReqObj.Grid);
            obj.ReqDisplayed.XScale           = obj.CurrentSelectedReqObj.XScale;
            obj.ReqDisplayed.YScale           = obj.CurrentSelectedReqObj.YScale;
            obj.ReqDisplayed.Gains            = [];
            obj.ReqDisplayed.StateGainsNames      = [];
            obj.ReqDisplayed.StateGainsControls   = [];
            obj.ReqDisplayed.StateGainsStateNames = [];
            switch class(obj.CurrentSelectedReqObj)
                case {'rootlocus'}
                obj.ReqDisplayed.RootLocusGainName    = obj.CurrentSelectedReqObj.GainName;
                obj.ReqDisplayed.RootLocusGainVariation = obj.CurrentSelectedReqObj.GainVariation;
            end
            obj.CurrentSelectedReqObj.plotBase(obj.req.PlotAxisH);   

        end % setReqObj

        function setSimReqObj(obj)
            cla(obj.req.PlotAxisH,'reset')
            obj.ReqDisplayed.FunName              = obj.CurrentSelectedReqObj.FunName;
            obj.ReqDisplayed.Title                = obj.CurrentSelectedReqObj.Title;
            obj.ReqDisplayed.MdlName              = obj.CurrentSelectedReqObj.MdlName;
            obj.ReqDisplayed.OutputDataIndex      = 1;
            obj.ReqDisplayed.XLim                 = [];
            obj.ReqDisplayed.YLim                 = [];
            obj.ReqDisplayed.XLabel               = [];
            obj.ReqDisplayed.YLabel               = [];
            obj.ReqDisplayed.PatchFaceColor       = [];
            obj.ReqDisplayed.PatchEdgeColor       = [];
            obj.ReqDisplayed.PatchXData           = [];
            obj.ReqDisplayed.PatchYData           = [];
            obj.ReqDisplayed.yAxisLocation        = [];
            obj.ReqDisplayed.GridFunction         = [];
            obj.ReqDisplayed.LineStyle            = [];
            obj.ReqDisplayed.LineWidth            = [];
            obj.ReqDisplayed.Marker               = [];
            obj.ReqDisplayed.MarkerSize           = [];
            obj.ReqDisplayed.Grid                 = [];
            obj.ReqDisplayed.XScale               = [];
            obj.ReqDisplayed.YScale               = [];
            obj.ReqDisplayed.Gains                = [];
            obj.ReqDisplayed.StateGainsNames      = [];
            obj.ReqDisplayed.StateGainsControls   = [];
            obj.ReqDisplayed.StateGainsStateNames = [];
            obj.ReqDisplayed.RootLocusGainName    = []; 
            obj.ReqDisplayed.RootLocusGainVariation = []; 
            %obj.CurrentSelectedReqObj.plotBase(obj.req.PlotAxisH);   

        end % setSimReqObj

        function setLQReqObj(obj)
            cla(obj.req.PlotAxisH,'reset')
            obj.ReqDisplayed.FunName              = obj.CurrentSelectedReqObj.FunName;
            obj.ReqDisplayed.Title                = obj.CurrentSelectedReqObj.Title;
            obj.ReqDisplayed.MdlName              = obj.CurrentSelectedReqObj.MdlName;
            obj.ReqDisplayed.OutputDataIndex      = 1;
            obj.ReqDisplayed.XLim                 = [];
            obj.ReqDisplayed.YLim                 = [];
            obj.ReqDisplayed.XLabel               = [];
            obj.ReqDisplayed.YLabel               = [];
            obj.ReqDisplayed.PatchFaceColor       = [];
            obj.ReqDisplayed.PatchEdgeColor       = [];
            obj.ReqDisplayed.PatchXData           = [];
            obj.ReqDisplayed.PatchYData           = [];
            obj.ReqDisplayed.yAxisLocation        = [];
            obj.ReqDisplayed.GridFunction         = [];
            obj.ReqDisplayed.LineStyle            = [];
            obj.ReqDisplayed.LineWidth            = [];
            obj.ReqDisplayed.Marker               = [];
            obj.ReqDisplayed.MarkerSize           = [];
            obj.ReqDisplayed.Grid                 = [];
            obj.ReqDisplayed.XScale               = [];
            obj.ReqDisplayed.YScale               = [];


            Gains = cellfun(@(x) strcat('''',num2str(x),'''; '),{obj.CurrentSelectedReqObj.Gains.Name},'uniformoutput',0);
            Gains = strcat('{',strcat(Gains{:}),'}');
            obj.ReqDisplayed.Gains = Gains;

            StateGains = cellfun(@(x) strcat('''',num2str(x),'''; '),{obj.CurrentSelectedReqObj.StateGains.Name},'uniformoutput',0);
            StateGains = strcat('{',strcat(StateGains{:}),'}');
            obj.ReqDisplayed.StateGainsNames = StateGains;

            StateGainsControl = cellfun(@(x) strcat('''',num2str(x),'''; '),{obj.CurrentSelectedReqObj.StateGains.Control},'uniformoutput',0);
            StateGainsControl = strcat('{',strcat(StateGainsControl{:}),'}');
            obj.ReqDisplayed.StateGainsControls = StateGainsControl;

            StateGainsStateNames = cellfun(@(x) strcat('''',num2str(x),'''; '),{obj.CurrentSelectedReqObj.StateGains.StateName},'uniformoutput',0);
            StateGainsStateNames = strcat('{',strcat(StateGainsStateNames{:}),'}');
            obj.ReqDisplayed.StateGainsStateNames = StateGainsStateNames;

            obj.ReqDisplayed.RootLocusGainName    = []; 
            obj.ReqDisplayed.RootLocusGainVariation = []; 
            %obj.CurrentSelectedReqObj.plotBase(obj.req.PlotAxisH);   

        end % setQReqObj

        function enableNormalEditReq(obj)
            obj.ReqEnabled.FunName= 'on';
            obj.ReqEnabled.Title = 'on';
            obj.ReqEnabled.MdlName = 'on';
            obj.ReqEnabled.OutputDataIndex = 'on';
            obj.ReqEnabled.XLim = 'on';
            obj.ReqEnabled.YLim = 'on';
            obj.ReqEnabled.XLabel = 'on';
            obj.ReqEnabled.YLabel = 'on';
            obj.ReqEnabled.PatchXData = 'on';
            obj.ReqEnabled.PatchYData = 'on';
            obj.ReqEnabled.yAxisLocation = 'on';
            obj.ReqEnabled.GridFunction = 'on';
            obj.ReqEnabled.LineStyle = 'on';
            obj.ReqEnabled.LineWidth = 'on';
            obj.ReqEnabled.Marker = 'on';
            obj.ReqEnabled.MarkerSize = 'on';
            obj.ReqEnabled.Grid = 'on';
            obj.ReqEnabled.XScale = 'on';
            obj.ReqEnabled.YScale = 'on';
            obj.ReqEnabled.PatchFaceColor = 'on';
            obj.ReqEnabled.PatchEdgeColor = 'on'; 
            obj.ReqEnabled.Gains = 'off'; 
            obj.ReqEnabled.StateGainsNames = 'off'; 
            obj.ReqEnabled.StateGainsControls = 'off';
            obj.ReqEnabled.StateGainsStateNames = 'off';
            obj.PlotAxisVisible = 'on';
        end % enableAllEditReq

        function enableSimEditReq(obj)
            obj.ReqEnabled.FunName= 'on';
            obj.ReqEnabled.Title = 'on';
            obj.ReqEnabled.MdlName = 'on';
            obj.ReqEnabled.OutputDataIndex = 'off';
            obj.ReqEnabled.XLim = 'off';
            obj.ReqEnabled.YLim = 'off';
            obj.ReqEnabled.XLabel = 'off';
            obj.ReqEnabled.YLabel = 'off';
            obj.ReqEnabled.PatchXData = 'off';
            obj.ReqEnabled.PatchYData = 'off';
            obj.ReqEnabled.yAxisLocation = 'off';
            obj.ReqEnabled.GridFunction = 'off';
            obj.ReqEnabled.LineStyle = 'off';
            obj.ReqEnabled.LineWidth = 'off';
            obj.ReqEnabled.Marker = 'off';
            obj.ReqEnabled.MarkerSize = 'off';
            obj.ReqEnabled.Grid = 'off';
            obj.ReqEnabled.XScale = 'off';
            obj.ReqEnabled.YScale = 'off';
            obj.ReqEnabled.PatchFaceColor = 'off';
            obj.ReqEnabled.PatchEdgeColor = 'off'; 
            obj.ReqEnabled.Gains = 'off'; 
            obj.ReqEnabled.StateGainsNames = 'off'; 
            obj.ReqEnabled.StateGainsControls = 'off';
            obj.ReqEnabled.StateGainsStateNames = 'off';
            obj.ReqEnabled.RootLocusGainName = 'off';
            obj.ReqEnabled.RootLocusGainVariation = 'off';
            obj.PlotAxisVisible = 'off';
        end % enableSimEditReq

        function enableRootLocusEditReq(obj)
            obj.ReqEnabled.FunName= 'on';
            obj.ReqEnabled.Title = 'on';
            obj.ReqEnabled.MdlName = 'on';
            obj.ReqEnabled.OutputDataIndex = 'on';
            obj.ReqEnabled.XLim = 'on';
            obj.ReqEnabled.YLim = 'on';
            obj.ReqEnabled.XLabel = 'on';
            obj.ReqEnabled.YLabel = 'on';
            obj.ReqEnabled.PatchXData = 'on';
            obj.ReqEnabled.PatchYData = 'on';
            obj.ReqEnabled.yAxisLocation = 'off';
            obj.ReqEnabled.GridFunction = 'on';
            obj.ReqEnabled.LineStyle = 'off';
            obj.ReqEnabled.LineWidth = 'off';
            obj.ReqEnabled.Marker = 'off';
            obj.ReqEnabled.MarkerSize = 'off';
            obj.ReqEnabled.Grid = 'off';
            obj.ReqEnabled.XScale = 'off';
            obj.ReqEnabled.YScale = 'off';
            obj.ReqEnabled.PatchFaceColor = 'off';
            obj.ReqEnabled.PatchEdgeColor = 'off'; 
            obj.ReqEnabled.Gains = 'off'; 
            obj.ReqEnabled.StateGainsNames = 'off'; 
            obj.ReqEnabled.StateGainsControls = 'off';
            obj.ReqEnabled.StateGainsStateNames = 'off';
            obj.ReqEnabled.RootLocusGainName = 'on';
            obj.ReqEnabled.RootLocusGainVariation = 'on';
            obj.PlotAxisVisible = 'on';
        end % enableSimEditReq

        function enableLQEditReq(obj)
            obj.ReqEnabled.FunName= 'on';
            obj.ReqEnabled.Title = 'on';
            obj.ReqEnabled.MdlName = 'on';
            obj.ReqEnabled.OutputDataIndex = 'off';
            obj.ReqEnabled.XLim = 'off';
            obj.ReqEnabled.YLim = 'off';
            obj.ReqEnabled.XLabel = 'off';
            obj.ReqEnabled.YLabel = 'off';
            obj.ReqEnabled.PatchXData = 'off';
            obj.ReqEnabled.PatchYData = 'off';
            obj.ReqEnabled.yAxisLocation = 'off';
            obj.ReqEnabled.GridFunction = 'off';
            obj.ReqEnabled.LineStyle = 'off';
            obj.ReqEnabled.LineWidth = 'off';
            obj.ReqEnabled.Marker = 'off';
            obj.ReqEnabled.MarkerSize = 'off';
            obj.ReqEnabled.Grid = 'off';
            obj.ReqEnabled.XScale = 'off';
            obj.ReqEnabled.YScale = 'off';
            obj.ReqEnabled.PatchFaceColor = 'off';
            obj.ReqEnabled.PatchEdgeColor = 'off'; 
            obj.ReqEnabled.Gains = 'on'; 
            obj.ReqEnabled.StateGainsNames = 'on'; 
            obj.ReqEnabled.StateGainsControls = 'on';
            obj.ReqEnabled.StateGainsStateNames = 'on';
            obj.ReqEnabled.RootLocusGainName = 'off';
            obj.ReqEnabled.RootLocusGainVariation = 'off';
            obj.PlotAxisVisible = 'off';
        end % enableLQEditReq
        
        function determineCurrReqObj( obj , node )
%             if ~node.isRoot
%                 nodeValue = node.getParent.getName;
%                 nodeIndex = node.getParent.getIndex(node) + 1; % convert from 0 based indexing
%                 obj.CurrentSelectedReqIndex = nodeIndex;
                obj.CurrentSelectedReqObj = node.handle.UserData;
                obj.DisplayReqObj = copy(obj.CurrentSelectedReqObj);
                switch class(obj.CurrentSelectedReqObj)
                    case 'Requirements.Stability'
                        %obj.CurrentSelectedReqObj = obj.StabilityObject(nodeIndex);
                        %obj.CurrentSelectedReqClass = 'StabilityObject';
                        setReqObj(obj);
                        enableNormalEditReq();
                        updateCDInterface();
                    case 'Requirements.FrequencyResponse'
                        obj.CurrentSelectedReqObj = obj.FreqRespObject(nodeIndex);
                        obj.CurrentSelectedReqClass = 'FreqRespObject';
                        setReqObj();
                        enableNormalEditReq();
                        updateCDInterface();
                    case 'Simulation'
                        obj.CurrentSelectedReqObj = obj.SimObject(nodeIndex);
                        obj.CurrentSelectedReqClass = 'SimObject';
                        setSimReqObj();
                        enableSimEditReq();
                        updateCDInterface();
                    case 'Handling Qualities'
                        obj.CurrentSelectedReqObj = HQObject(nodeIndex);
                        obj.CurrentSelectedReqClass = 'HQObject';
                        setReqObj();
                        enableNormalEditReq();
                        updateCDInterface();
                    case 'Aeroservoelasticity'
                        obj.CurrentSelectedReqObj = obj.ASEObject(nodeIndex);
                        obj.CurrentSelectedReqClass = 'ASEObject';
                        setReqObj();
                        enableNormalEditReq();
                        updateCDInterface();
                    case 'Gains'
                        obj.CurrentSelectedReqObj = obj.SynObject;
                        obj.CurrentSelectedReqClass = 'SynObject';
                        setLQReqObj();
                        enableLQEditReq();
                        updateCDInterface();
                    case 'Root Locus'
                        obj.CurrentSelectedReqObj = obj.RtLocusObject(nodeIndex);
                        obj.CurrentSelectedReqClass = 'RtLocusObject';
                        setReqObj();
                        enableRootLocusEditReq();
                        updateCDInterface();

                end
%             end   
        end

        function editReq_CB_H( ~ , ~ , node , ~ )
            determineCurrReqObj(node);
            requiermentsButton_CB( [] , [] );
        end % editReq_CB_H

        function saveReqUpdate( ~ , ~ )
            filename = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).objPath;
            %eval([filename(1:end-4),'=cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex);']);
            saveVarStruct.(filename(1:end-4)) = cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex); %#ok<STRNU>
            filepath = which(filename);
            save(filepath, '-struct','saveVarStruct');
        end % saveReqUpdate
        
        function reqUpdate( hobj , ~ , type )
            value = get(hobj,'String');
            obj.ReqDisplayed.(type) = value;


            switch class(obj.CurrentSelectedReqObj)

                case {'lq'}
                    if strcmp(type,'Gains')

                        try
                            tempCell = eval(value);
                            for i = 1:length(tempCell)
                                cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type)(i).Name = tempCell{i};
                            end
                        catch
                            error('Syntax is not correct');
                        end 
                    elseif strcmp(type,'StateGainsName')

                        try
                            tempCell = eval(value);
                            for i = 1:length(tempCell)
                                cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).StateGains(i).Name = tempCell{i};
                            end
                        catch
                            error('Syntax is not correct');
                        end 
                    elseif strcmp(type,'StateGainsControl')

                        try
                            tempCell = eval(value);
                            for i = 1:length(tempCell)
                                cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).StateGains(i).Control = tempCell{i};
                            end
                        catch
                            error('Syntax is not correct');
                        end 
                    elseif strcmp(type,'StateGainsStateName')

                        try
                            tempCell = eval(value);
                            for i = 1:length(tempCell)
                                cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).StateGains(i).StateName = tempCell{i};
                            end
                        catch
                            error('Syntax is not correct');
                        end 
                    else
                        if isnumeric(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                            cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = str2num(value);
                        elseif iscell(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                            try
                                cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = eval(value); 
                            catch
                                error('Syntax is not correct');
                            end    
                        end
                    end
                    cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).plotRefresh = 1;
                    setLQReqObj();

                case {'simulation'}
                    cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = value;
                    cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).plotRefresh = 1;
                    setSimReqObj();

                case {'rootlocus'}
                    if isnumeric(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                        cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = str2num(value);
                    elseif iscell(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                        try
                            cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = eval(value); 
                        catch
                            error('Syntax is not correct');
                        end  
                    else
                        cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = value; 
                    end
                    cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).plotRefresh = 1;
                    setReqObj();
                otherwise

                    if isnumeric(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                        cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = str2num(value);
                    elseif iscell(cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type))
                        try
                            cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = eval(value); 
                        catch
                            error('Syntax is not correct');
                        end 
                    else
                        cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).(type) = value; 
                    end
                    cdData.(obj.CurrentSelectedReqClass)(obj.CurrentSelectedReqIndex).plotRefresh = 1;
                    setReqObj();

            end

            updateCDInterface();



















        end % reqUpdate

        function viewMethod( ~ , ~ )
            if ~isempty(obj.ReqDisplayed.FunName)
                open(obj.ReqDisplayed.FunName);
            end
        end % viewMethod

        function viewModel( ~ , ~ )
            if ~isempty(obj.ReqDisplayed.MdlName)
                open_system(obj.ReqDisplayed.MdlName);
            end
        end % viewModel
        
    end % Ordinary Methods
    
    %% Methods - Ordinary
    methods 
        function reset(obj)
            cla(obj.PlotAxisH,'reset')
            obj.MethodEB              = [];
            obj.TitleEB                = [];
            obj.MdlNameEB              = [];
            obj.OutDataIndEB      = 1;
            obj.XlimEB                = [];
            obj.YlimEB                = [];
            obj.XlabelEB               = [];
            obj.YlabelEB              = [];
            obj.PatchFaceColorEB       = [];
            obj.PatchEdgeColorEB       = [];
            obj.XPatchEB           = [];
            obj.YPatchEB           = [];
            obj.YAxisLocEB        = [];
            obj.GridFuncEB        = [];
            obj.LineStyleEB            = [];
            obj.LineWidthEB            = [];
            obj.MarkerEB               = [];
            obj.MarkerSizeEB         = [];
            obj.GridEB                = [];
            obj.XScaleEB               = [];
            obj.YScaleEB              = [];
            obj.GainsEB                = [];
            obj.StateGainsNameEB      = [];
            obj.StateGainsControlEB   = [];
            obj.StateGainsStateNamesEB = [];
            obj.RootLocusGainNameEB    = []; 
            obj.RootLocusGainVarEB = []; 
        end
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       

        function resizeFcn( obj , ~ , ~ )
            % get figure position
            orgUnits = get(obj.Container,'Units');
            set(obj.Container,'Units','Pixels');
            panelPos = get(obj.Container,'Position');
            set(obj.Container,'Units',orgUnits);
            
            EditPanelRight  = 1;
            EditPanelBottom = 1;
            EditPanelWidth  = 425;
            EditPanelHeight = panelPos(4);
            set(obj.EditPanel,'Units','Pixels');
            set(obj.EditPanel,'Position',[EditPanelRight, EditPanelBottom ,EditPanelWidth, EditPanelHeight] );
            
            AxisPanelRight  = 426;
            AxisPanelBottom = 1;
            AxisPanelWidth  = panelPos(3) - AxisPanelRight;
            AxisPanelHeight = panelPos(4);
            set(obj.AxisPanel,'Units','Pixels');
            set(obj.AxisPanel,'Position',[AxisPanelRight, AxisPanelBottom ,AxisPanelWidth, AxisPanelHeight] );   
        end % resizeFcn
        
        function editPanelResize( obj , ~ , ~ )
  
        end % editPanelResize
        
        function axisPanelResize( obj , ~ , ~ )
    
            % get figure position
            orgUnits = get(obj.AxisPanel,'Units');
            set(obj.AxisPanel,'Units','Pixels');
            panelPos = get(obj.AxisPanel,'Position');
            set(obj.AxisPanel,'Units',orgUnits);
            
            plotAxisRight  = 1;
            plotAxisBottom = 26;
            plotAxisWidth  = panelPos(3);
            plotAxisHeight = panelPos(4) - 27;
            set(obj.PlotAxisH,'Units','Pixels');
            set(obj.PlotAxisH,'OuterPosition',[plotAxisRight, plotAxisBottom ,plotAxisWidth, plotAxisHeight] );
            
            saveReqUpdateRight  = 3;
            saveReqUpdateBottom = 3;
            saveReqUpdateWidth  = 60;
            saveReqUpdateHeight = 20;
            set(obj.SaveReqUpdatePB,'Units','Pixels');
            set(obj.SaveReqUpdatePB,'Position',[saveReqUpdateRight, saveReqUpdateBottom ,saveReqUpdateWidth, saveReqUpdateHeight] );            
  
        end % axisPanelResize
        
        function update(obj)

            set(obj.Parent,'SelectedChild',obj.SelectedPanel);

        end % update
        
    end
    
end
