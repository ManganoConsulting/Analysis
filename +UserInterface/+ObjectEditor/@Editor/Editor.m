classdef Editor < UserInterface.Collection
    %% Public properties - Graphics Handles
    properties (Transient = true)
        RibbonPanel
        MainPanel
        RibbonHtml
    end % Public properties
  
    %% Public properties - Data Storage
    properties
        CurrentObjFullName = ''
        Saved logical = true
%         LoadingSaved@logical = false 
        EditInProject logical = false 
        ShowLoadButton = true
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        CurrentReqObj
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        StartDirectory
%         SaveCancelled = false
    end % Hidden properties

    properties (Access = private, Transient = true)
        RibbonAssets = struct()
        RibbonReady (1,1) logical = false
    end % Private transient properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        Figure
        CurrentObjDirectory
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  
    
    %% Events
    events
        NewButtonPressed
        OpenButtonPressed
        SaveButtonPressed
        ObjectLoaded
        ObjectCreated
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = Editor(varargin)  

            p = inputParser;
            addParameter(p,'Parent',figure);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'BorderType','none');
            addParameter(p,'StartDirectory',pwd);
            addParameter(p,'EditInProject',false,@islogical);
            addParameter(p,'Requirement',[]);
            addParameter(p,'EditAsHandle',false,@islogical);
            addParameter(p,'FileName','Untitled');
            addParameter(p,'ShowLoadButton',true,@islogical);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj@UserInterface.Collection('Parent',options.Parent,'Units',options.Units,'Position',options.Position,'Title',options.Title,'BorderType',options.BorderType); 
            obj.EditInProject = options.EditInProject;
            obj.ShowLoadButton = options.ShowLoadButton;
            
            if options.EditAsHandle
                obj.CurrentReqObj = options.Requirement;
            else
                if ~isempty(options.Requirement)
                    obj.CurrentReqObj = copy(options.Requirement);
                end
            end
            
            if ~isempty(obj.CurrentReqObj)
                obj.CurrentObjFullName     = options.FileName;
%                 [~,filename] = fileparts(obj.CurrentObjFullName);
%                 obj.CurrentReqObj.FileName = filename;
            end
            
            position = obj.Parent.Position;
            obj.Parent.Position = [ position(1) , position(2) - 200 , 487 , 615 ];
            
            createView( obj , obj.Parent );
            update(obj);
        end % Editor
    end % Editor

    %% Methods - Property Access
    methods
        
        function y = get.Figure(obj)
            if ~isempty(obj.Parent)
                y = ancestor(obj.Parent,'figure','toplevel');
            else
                y = [];
            end
        end % Figure   
        
        function y = get.CurrentObjDirectory(obj)
            if ~isempty(obj.CurrentObjFullName)
                y = fileparts(obj.CurrentObjFullName);
            else
                y = [];
            end
        end % CurrentObjDirectory  
        
        function set.CurrentReqObj( obj , newObj )
            observeProp = findAttrValue(newObj,'SetObservable',true);
            
            
            obj.CurrentReqObj = newObj;
            
            for i = 1:length(observeProp)
                addlistener(obj.CurrentReqObj,observeProp{i},'PostSet',@(src,event) obj.propertyChanged_CB(src,event));
            end
            
        end % CurrentReqObj
        
    end % Property access methods
    
    %% Methods - View
    methods
        
        function createView( obj , parent )  
            
            obj.Parent = parent;
            
            obj.Figure.MenuBar = 'None';
            obj.Figure.NumberTitle = 'off';
            
            Utilities.setMinFigureSize(obj.Figure,[487 675]);
            if ~isempty(parent)
                obj.Parent = parent;
            end
            obj.Container = uipanel('Parent',obj.Parent,...
                'BorderType',obj.BorderType,...
                'Title',obj.Title,...
                'Units', obj.Units,...
                'Position',obj.Position,...
                'Visible','on');
            %set(obj.Container,'ResizeFcn',@obj.reSize);   
            set(obj.Container,'SizeChangedFcn',@obj.reSize);  
            position = getpixelposition(obj.Container);
            % Create Tool Ribbion
            obj.RibbonPanel = uipanel('Parent',obj.Container,...
                'Units','Pixels',...
                'BorderType','none',...
                'BackgroundColor',[242 242 242]/255,...
                'Position',[ 1 , position(4)-93 , position(3), 93 ]);
            obj.RibbonPanel.SizeChangedFcn = @(~,~)obj.updateRibbonHtmlGeometry();
         
            % Create Main Container
            obj.MainPanel = uicontainer('Parent',obj.Container,...
                'Units','Pixels',...
                'Position',[1 , 1 , position(3) , position(4)-93 ]); 
            
            % Create the tool ribbon
            createToolRibbion(obj);
            
            % Create Object view if available
            if ~isempty(obj.CurrentReqObj)
                createView (obj.CurrentReqObj , obj.MainPanel );
                addlistener(obj.CurrentReqObj,'Title','PostSet',@obj.setFileTitle);
                setFileTitle( obj );
            end
            
        end % createView
        
        function createToolRibbion(obj)

            if ~isempty(obj.RibbonHtml) && isvalid(obj.RibbonHtml)
                delete(obj.RibbonHtml);
            end

            panelPos = getpixelposition(obj.RibbonPanel);
            if isempty(panelPos)
                panelPos = [0 0 300 93];
            end
            panelPos(3) = max(panelPos(3),1);
            panelPos(4) = max(panelPos(4),1);

            obj.RibbonAssets = obj.buildRibbonAssets();
            obj.RibbonReady = false;

            obj.RibbonHtml = uihtml(obj.RibbonPanel,...
                'HTMLSource',obj.buildRibbonHtml(),...
                'Position',[0 0 panelPos(3) panelPos(4)]);
            obj.RibbonHtml.DataChangedFcn = @(~,evt)obj.handleRibbonEvent(evt.Data);

            obj.updateRibbonHtmlGeometry();

        end % createToolRibbion
        
    end
   
    %% Methods - Ordinary
    methods 
     
        function loadObject( obj , newObj )
            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            obj.CurrentReqObj = newObj;
            createView (obj.CurrentReqObj , obj.MainPanel );
            
            obj.Saved = true;
            update( obj );
        end % loadObject
        
    end % Ordinary Methods
    
    %% Methods - Callbacks
    methods (Access = protected) 
        
        function newButton_CB( obj , hobj , ~ )

            childObjs = get(obj.MainPanel,'Children'); delete(childObjs);
            switch class(obj.CurrentReqObj)
                case 'Requirements.Stability'
                    obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
                case 'Requirements.FrequencyResponse'
                    obj.CurrentReqObj = Requirements.FrequencyResponse();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.FrequencyResponse);
                case 'Requirements.HandlingQualities'
                    obj.CurrentReqObj = Requirements.HandlingQualities();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.HandlingQualities);
                case 'Requirements.Aeroservoelasticity'
                    obj.CurrentReqObj = Requirements.Aeroservoelasticity();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Aeroservoelasticity);
                case 'Requirements.SimulationCollection'
                    obj.CurrentReqObj = Requirements.SimulationCollection();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.SimulationCollection);
                case 'Requirements.Synthesis'
                    obj.CurrentReqObj = Requirements.Synthesis();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Synthesis);
                case 'lacm.TrimSettings'
                    obj.CurrentReqObj = lacm.TrimSettings();
                case 'lacm.LinearModel'
                    obj.CurrentReqObj = lacm.LinearModel(); 
                case 'lacm.AnalysisTask'
                    obj.CurrentReqObj = lacm.AnalysisTask(); 
                otherwise
                    return;
                    %obj.CurrentReqObj = Requirements.Stability();
                    %UserInterface.ObjectEditor.Editor('Requirement',Requirements.Stability);
            end
            createView (obj.CurrentReqObj , obj.MainPanel );
            obj.Saved = true; 
            notify(obj,'NewButtonPressed',UserInterface.UserInterfaceEventData(hobj));
            drawnow();pause(0.1);
            update(obj);
        end % newButton_CB

        function openButton_CB( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mat'},'Select Requirement Object File:',obj.CurrentObjDirectory);
            drawnow();pause(0.5);
            if isequal(filename,0)
                return;
            end
            obj.StartDirectory = pathname;
            
            
            
            
            varStruct = load(fullfile(pathname,filename));
            varNames = fieldnames(varStruct);
                
            loadObject( obj ,varStruct.(varNames{1}));
            
        end % openButton_CB
               
        function load_CB( obj , ~  , ~ )
            % Save the tree state if it exists
            try %#ok<TRYNC>
                obj.CurrentReqObj.OutputSelector.Tree.saveTreeState
            end
            if obj.EditInProject
                notify(obj,'ObjectLoaded',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            else
                notify(obj,'ObjectCreated',UserInterface.UserInterfaceEventData(obj.CurrentReqObj));
            end
            drawnow();pause(0.1);
            obj.Saved = true;
            update(obj);
        end % load_CB
        
        function export_CB( obj , ~ , ~ )
            
            [filename, pathname] = uiputfile({'*.mat'},'Export Requirement',obj.CurrentObjFullName);
            drawnow();pause(0.1);
            if isequal(filename,0)
                return;
            end
            if isa(obj.CurrentReqObj,'Requirements.SimulationCollection')
%                 obj.CurrentReqObj.OutputSelector.Tree.saveTreeState;
%                 obj.CurrentReqObj.OutputSelector.saveTreeState;
            end
            Requirement = obj.CurrentReqObj; %#ok<NASGU>
            drawnow();pause(0.01);
            save(fullfile(pathname,filename),'Requirement');
        end % export_CB
                
        function popUpMenuCancelled( obj , ~ , ~ ) %#ok<INUSD>
            % Legacy callback retained for compatibility with existing listeners.
            % The HTML-based ribbon manages hover state visually, so no action is required.
        end % popUpMenuCancelled
        

    end
    
    %% Methods - Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ )
            obj.sendRibbonState();
            setFileTitle( obj );
        end % update
         
        function reSize( obj , ~ , ~ )
            
            % get figure position
            position = getpixelposition(obj.Container);
       
            set(obj.RibbonPanel,'Units','Pixels',...
                'Position',[ 1 , position(4)-93 , position(3), 93 ]);

            set(obj.MainPanel,'Units','Pixels',...
                'Position',[1 , 1 , position(3) , position(4)-93 ]);

            obj.updateRibbonHtmlGeometry();

        end % reSize
        
        function setFileTitle( obj , ~ , ~ )
            fig = ancestor(obj.Parent,'figure','toplevel') ;

            if isempty(obj.CurrentReqObj)
                filename = 'Untitled';
            else
                 filename = class(obj.CurrentReqObj);
            end
            
            if obj.Saved
                fig.Name = filename;
            else
                fig.Name = [filename,'*'];
            end
        end % setFileTitleNoNameNoSave  
        
        function propertyChanged_CB( obj , ~ , ~ )
            obj.Saved = false;
            update(obj);
            %disp('Prop Changed');
        end % propertyChanged_CB
           
    end
    
    %% Methods - Private
    methods (Access = private)

        function handleRibbonEvent(obj, payload)
            if ~isstruct(payload) || ~isfield(payload,'type')
                return;
            end

            msgType = lower(char(payload.type));

            switch msgType
                case 'ready'
                    obj.RibbonReady = true;
                    obj.sendRibbonConfig();
                    obj.sendRibbonState();
                case 'click'
                    if ~isfield(payload,'action')
                        return;
                    end
                    action = lower(char(payload.action));
                    switch action
                        case 'new'
                            obj.newButton_CB([],[]);
                        case 'open'
                            obj.openButton_CB([],[]);
                        case 'load'
                            if obj.ShowLoadButton
                                obj.load_CB([],[]);
                            end
                        case 'export'
                            obj.export_CB([],[]);
                    end
            end
        end % handleRibbonEvent

        function sendRibbonConfig(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml)
                return;
            end

            icons = obj.RibbonAssets;
            buttons = struct( ...
                'new',struct('label','New','tooltip','Add New Item','icon',icons.new),...
                'open',struct('label','Open','tooltip','Open existing workspace','icon',icons.open),...
                'export',struct('label','Export','tooltip','Save and Load','icon',icons.export));

            if obj.ShowLoadButton
                buttons.load = struct('label','Load','tooltip','Load','icon',icons.loadSaved);
            end

            payload = struct( ...
                'type','init', ...
                'groupLabel','FILE', ...
                'buttons',buttons, ...
                'showLoad',obj.ShowLoadButton, ...
                'saved',logical(obj.Saved), ...
                'loadIcons',struct('saved',icons.loadSaved,'unsaved',icons.loadUnsaved));

            obj.RibbonHtml.Data = payload;
        end % sendRibbonConfig

        function sendRibbonState(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml) || ~obj.RibbonReady
                return;
            end

            obj.RibbonHtml.Data = struct('type','state','saved',logical(obj.Saved));
        end % sendRibbonState

        function updateRibbonHtmlGeometry(obj)
            if isempty(obj.RibbonPanel) || ~isvalid(obj.RibbonPanel) || isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml)
                return;
            end

            panelPos = getpixelposition(obj.RibbonPanel);
            if isempty(panelPos)
                panelPos = [0 0 1 1];
            end
            width = max(panelPos(3),1);
            height = max(panelPos(4),1);
            obj.RibbonHtml.Position = [0 0 width height];
        end % updateRibbonHtmlGeometry

        function html = buildRibbonHtml(~)
            lines = {
                '<!doctype html>'
                '<html lang="en">'
                '<head>'
                '<meta charset="utf-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1">'
                '<style>'
                'html,body{margin:0;padding:0;height:100%;background:transparent;font-family:"Segoe UI",Tahoma,Arial,sans-serif;font-size:12px;color:#1f1f1f;}'
                '.ribbon-bg{position:absolute;inset:0;display:flex;align-items:flex-start;gap:12px;padding:6px 10px;background:linear-gradient(180deg,#f8f8f8 0%,#e4e4e4 100%);border-bottom:1px solid #bcbcbc;box-sizing:border-box;}'
                '.group{display:flex;flex-direction:column;justify-content:flex-start;align-items:stretch;min-width:200px;height:100%;padding:4px 10px 6px;background:rgba(255,255,255,0.88);border:1px solid #c8c8c8;border-radius:4px;box-shadow:0 1px 0 rgba(255,255,255,0.9) inset;}'
                '.button-strip{display:flex;gap:10px;flex-wrap:nowrap;}'
                '.ribbon-button{position:relative;display:flex;flex-direction:column;align-items:center;gap:4px;min-width:68px;height:72px;padding:6px 8px;border:1px solid transparent;border-radius:4px;background:linear-gradient(180deg,#ffffff 0%,#e9e9e9 100%);box-shadow:0 1px 0 rgba(255,255,255,0.7) inset;cursor:pointer;transition:border-color .12s ease,box-shadow .12s ease,background .12s ease;}'
                '.ribbon-button:hover{border-color:#8fb7df;box-shadow:0 0 0 1px rgba(151,189,232,0.45) inset,0 1px 2px rgba(0,0,0,0.15);background:linear-gradient(180deg,#fdfdfd 0%,#e7f1fb 100%);}'
                '.ribbon-button:active{border-color:#6f9bd3;background:linear-gradient(180deg,#dbeaff 0%,#c4dcf7 100%);box-shadow:0 0 0 1px rgba(111,155,211,0.6) inset;}'
                '.ribbon-button:focus-visible{outline:2px solid #0e67d2;outline-offset:1px;}'
                '.ribbon-button.hidden{display:none !important;}'
                '.icon-wrap{width:40px;height:40px;display:flex;align-items:center;justify-content:center;border-radius:6px;background:linear-gradient(180deg,#fdfdfd 0%,#ececec 100%);box-shadow:0 1px 0 rgba(255,255,255,0.7);}'
                '.ribbon-button img{width:24px;height:24px;image-rendering:-webkit-optimize-contrast;}'
                '.ribbon-button .label{text-transform:uppercase;font-size:10px;font-weight:600;letter-spacing:.6px;color:#303030;}'
                '.ribbon-button.unsaved{background:linear-gradient(180deg,#fff6e6 0%,#fbdcae 100%);border-color:#f0a23a;box-shadow:0 0 0 1px rgba(240,162,58,0.35) inset;}'
                '.group-label{margin-top:4px;text-align:center;font-size:10px;font-weight:600;letter-spacing:1.2px;color:#6b6b6b;text-transform:uppercase;}'
                '</style>'
                '</head>'
                '<body>'
                '<div class="ribbon-bg" id="ribbonRoot">'
                '  <div class="group" role="group" aria-labelledby="group-file-label">'
                '    <div class="button-strip">'
                '      <button type="button" class="ribbon-button" id="btn-new" data-action="new" title="New">'
                '        <span class="icon-wrap"><img id="icon-new" alt="New icon" /></span>'
                '        <span class="label">New</span>'
                '      </button>'
                '      <button type="button" class="ribbon-button" id="btn-open" data-action="open" title="Open">'
                '        <span class="icon-wrap"><img id="icon-open" alt="Open icon" /></span>'
                '        <span class="label">Open</span>'
                '      </button>'
                '      <button type="button" class="ribbon-button hidden" id="btn-load" data-action="load" title="Load" aria-hidden="true">'
                '        <span class="icon-wrap"><img id="icon-load" alt="Load icon" /></span>'
                '        <span class="label">Load</span>'
                '      </button>'
                '      <button type="button" class="ribbon-button" id="btn-export" data-action="export" title="Export">'
                '        <span class="icon-wrap"><img id="icon-export" alt="Export icon" /></span>'
                '        <span class="label">Export</span>'
                '      </button>'
                '    </div>'
                '    <div class="group-label" id="group-file-label">FILE</div>'
                '  </div>'
                '</div>'
                '<script>'
                '(function(){'
                '  const matlab = window.parent;'
                '  const buttons = {'
                '    new: document.getElementById("btn-new"),'
                '    open: document.getElementById("btn-open"),'
                '    load: document.getElementById("btn-load"),'
                '    export: document.getElementById("btn-export")'
                '  };'
                '  const labelEl = document.getElementById("group-file-label");'
                '  let loadIcons = {saved:"",unsaved:""};'
                '  function send(msg){'
                '    if(matlab && typeof matlab.postMessage === "function"){'
                '      matlab.postMessage(msg,"*");'
                '    }'
                '  }'
                '  function updateButton(id,cfg){'
                '    const btn = buttons[id];'
                '    if(!btn || !cfg){return;}'
                '    const label = btn.querySelector(".label");'
                '    if(label && cfg.label){label.textContent = cfg.label;}'
                '    if(cfg.tooltip){'
                '      btn.title = cfg.tooltip;'
                '      btn.setAttribute("aria-label",cfg.tooltip);'
                '    }'
                '    const img = btn.querySelector("img");'
                '    if(img && cfg.icon){img.src = cfg.icon;}'
                '  }'
                '  function toggleLoad(show){'
                '    const btn = buttons.load;'
                '    if(!btn){return;}'
                '    if(show){'
                '      btn.classList.remove("hidden");'
                '      btn.setAttribute("aria-hidden","false");'
                '    }else{'
                '      btn.classList.add("hidden");'
                '      btn.setAttribute("aria-hidden","true");'
                '    }'
                '  }'
                '  function updateLoadState(saved){'
                '    const btn = buttons.load;'
                '    if(!btn){return;}'
                '    btn.classList.toggle("unsaved", !saved);'
                '    const img = btn.querySelector("img");'
                '    if(img){'
                '      const src = saved ? loadIcons.saved : (loadIcons.unsaved || loadIcons.saved);'
                '      if(src){img.src = src;}'
                '    }'
                '  }'
                '  Object.keys(buttons).forEach(key=>{' 
                '    const btn = buttons[key];'
                '    if(!btn){return;}'
                '    btn.addEventListener("click",()=>{'
                '      const action = btn.dataset.action;'
                '      if(action){send({type:"click",action:action});}'
                '    });'
                '  });'
                '  window.addEventListener("message",(event)=>{'
                '    const data = event.data || {};'
                '    if(data.type === "init"){'
                '      if(data.groupLabel){labelEl.textContent = data.groupLabel;}'
                '      const btnCfg = data.buttons || {};'
                '      updateButton("new", btnCfg.new);'
                '      updateButton("open", btnCfg.open);'
                '      updateButton("export", btnCfg.export);'
                '      if(btnCfg.load){updateButton("load", btnCfg.load);}'
                '      loadIcons = Object.assign({saved:"",unsaved:""}, data.loadIcons || {});'
                '      const showLoad = (data.showLoad !== false) && !!btnCfg.load;'
                '      toggleLoad(showLoad);'
                '      if(typeof data.saved === "boolean"){'
                '        updateLoadState(data.saved);'
                '      }else{'
                '        updateLoadState(true);'
                '      }'
                '    }else if(data.type === "state"){'
                '      if(typeof data.saved === "boolean"){updateLoadState(data.saved);}'
                '    }'
                '  });'
                '  window.addEventListener("DOMContentLoaded",()=>{'
                '    setTimeout(()=>send({type:"ready"}),0);'
                '  });'
                '})();'
                '</script>'
                '</body>'
                '</html>'
            };

            html = strjoin(lines, newline);
        end % buildRibbonHtml

        function assets = buildRibbonAssets(obj)
            thisDir = fileparts(mfilename('fullpath'));
            iconDir = fullfile(thisDir,'..','..','Resources');

            assets = struct();
            assets.new = obj.encodeIcon(fullfile(iconDir,'New_24.png'));
            assets.open = obj.encodeIcon(fullfile(iconDir,'Open_24.png'));
            assets.loadSaved = obj.encodeIcon(fullfile(iconDir,'LoadedArrow_24.png'));
            assets.loadUnsaved = obj.encodeIcon(fullfile(iconDir,'LoadArrow_24.png'));
            assets.export = obj.encodeIcon(fullfile(iconDir,'Export_24.png'));

            if isempty(assets.loadUnsaved)
                assets.loadUnsaved = assets.loadSaved;
            end
        end % buildRibbonAssets

        function uri = encodeIcon(~, filename)
            if exist(filename,'file') ~= 2
                uri = '';
                return;
            end

            fid = fopen(filename,'rb');
            if fid < 0
                uri = '';
                return;
            end

            cleaner = onCleanup(@()fclose(fid)); %#ok<NASGU>
            data = fread(fid,'*uint8');
            if isempty(data)
                uri = '';
                return;
            end

            uri = ['data:image/png;base64,' matlab.net.base64encode(uint8(data(:)))];
        end % encodeIcon

    end
        
    %% Method - Static
    methods ( Static )
        
        
    end
        
end


function cl_out = findAttrValue(obj,attrName,varargin)
   if ischar(obj)
      mc = meta.class.fromName(obj);
   elseif isobject(obj)
      mc = metaclass(obj);
   end
   ii = 0; numb_props = length(mc.PropertyList);
   cl_array = cell(1,numb_props);
   for  c = 1:numb_props
      mp = mc.PropertyList(c);
      if isempty (findprop(mp,attrName))
         error('Not a valid attribute name')
      end
      attrValue = mp.(attrName);
      if attrValue
         if islogical(attrValue) || strcmp(varargin{1},attrValue)
            ii = ii + 1;
            cl_array(ii) = {mp.Name};
         end
      end
   end
   cl_out = cl_array(1:ii);
end


