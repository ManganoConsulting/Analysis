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
                case {'click','command'}
                    % Accept both legacy 'click' and new 'command' events
                    action = '';
                    if isfield(payload,'action') && ~isempty(payload.action)
                        action = lower(char(payload.action));
                    elseif isfield(payload,'command') && ~isempty(payload.command)
                        action = lower(char(payload.command));
                    end
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
            payload = struct( ...
                'type','config', ...
                'icons',icons, ...
                'showLoad',obj.ShowLoadButton);

            obj.RibbonHtml.Data = payload;
        end % sendRibbonConfig

        function sendRibbonState(obj)
            if isempty(obj.RibbonHtml) || ~isvalid(obj.RibbonHtml) || ~obj.RibbonReady
                return;
            end

            obj.RibbonHtml.Data = struct('type','state');
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

        function html = buildRibbonHtml(obj)
            % Dark theme and non-scrollable ribbon consistent with StabilityControl
            if isempty(fieldnames(obj.RibbonAssets))
                obj.RibbonAssets = obj.buildRibbonAssets();
            end
            iconsJson = jsonencode(obj.RibbonAssets);
            iconLine = ['  const initialIcons = ' iconsJson ';'];
            lines = {
                '<!doctype html>'
                '<html lang="en">'
                '<head>'
                '<meta charset="utf-8">'
                '<meta name="viewport" content="width=device-width, initial-scale=1">'
                '<style>'
                'html,body{margin:0;padding:0;height:100%;background:transparent;font-family:"Segoe UI","Helvetica Neue",Arial,sans-serif;font-size:11px;color:#f3f5f7;overflow:hidden;-ms-overflow-style:none;scrollbar-width:none;}'
                '::-webkit-scrollbar{width:0;height:0;display:none;}'
                '.ribbon-surface{position:absolute;inset:0;display:flex;align-items:stretch;gap:0;padding:2px 6px 4px;background:linear-gradient(180deg,#3c3f45 0%,#292c33 100%);border-bottom:1px solid #14161a;box-sizing:border-box;}'
                '.group{position:relative;display:flex;flex-direction:column;align-items:stretch;gap:3px;padding:0 6px 2px;border-right:1px solid rgba(255,255,255,0.15);min-height:100%;}'
                '.group:last-of-type{border-right:none;}'
                '.group-body{display:flex;gap:4px;align-items:flex-start;flex:1 1 auto;}'
                '.button-base{display:flex;align-items:center;justify-content:center;gap:6px;border:1px solid #1f2025;border-radius:4px;background:linear-gradient(180deg,#4f535c 0%,#2f3238 100%);box-shadow:0 1px 0 rgba(255,255,255,0.12) inset,0 1px 2px rgba(0,0,0,0.6);color:#f3f5f7;cursor:pointer;padding:4px;transition:background 0.15s ease,box-shadow 0.15s ease,transform 0.15s ease;}'
                '.button-base:hover{background:linear-gradient(180deg,#5d616b 0%,#343840 100%);box-shadow:0 1px 0 rgba(255,255,255,0.18) inset,0 2px 4px rgba(0,0,0,0.55);}'
                '.button-base:active{transform:translateY(1px);}'
                '.button-base:focus-visible{outline:2px solid #0e67d2;outline-offset:1px;}'
                '.button-vertical{flex-direction:column;min-width:50px;height:64px;padding:4px 4px 16px;gap:3px;position:relative;}'
                '.label{text-transform:uppercase;font-size:9px;font-weight:600;letter-spacing:0.3px;color:#e6e8eb;text-align:center;}'
                '.icon-box{width:22px;height:22px;border-radius:4px;background:linear-gradient(180deg,#5a5f69 0%,#3a3e46 100%);display:flex;align-items:center;justify-content:center;box-shadow:0 1px 0 rgba(255,255,255,0.12) inset;}'
                '.icon-box img{width:16px;height:16px;image-rendering:-webkit-optimize-contrast;}'
                '.group-label{text-align:center;font-size:10px;font-weight:600;letter-spacing:1px;color:#cfd2d6;text-transform:uppercase;margin-top:auto;padding:1px 0;background:linear-gradient(180deg,rgba(255,255,255,0.08) 0%,rgba(0,0,0,0.25) 100%);border:1px solid rgba(0,0,0,0.6);border-radius:3px;}'
                '</style>'
                '</head>'
                '<body>'
                '<div class="ribbon-surface" id="ribbonRoot">'
                '  <div class="group" data-group="file">'
                '    <div class="group-body">'
                '      <button type="button" class="button-base button-vertical" data-role="primary" data-command="new" title="New">'
                '        <span class="icon-box"><img id="icon-new" alt="New"></span>'
                '        <span class="label">New</span>'
                '      </button>'
                '      <button type="button" class="button-base button-vertical" data-role="primary" data-command="open" title="Open">'
                '        <span class="icon-box"><img id="icon-open" alt="Open"></span>'
                '        <span class="label">Open</span>'
                '      </button>'
                '      <button type="button" class="button-base button-vertical" id="btn-load" data-role="primary" data-command="load" title="Load">'
                '        <span class="icon-box"><img id="icon-load" alt="Load"></span>'
                '        <span class="label">Load</span>'
                '      </button>'
                '      <button type="button" class="button-base button-vertical" data-role="primary" data-command="export" title="Export">'
                '        <span class="icon-box"><img id="icon-export" alt="Export"></span>'
                '        <span class="label">Export</span>'
                '      </button>'
                '    </div>'
                '    <div class="group-label">File</div>'
                '  </div>'
                '</div>'
                '<script>'
                '(function(){'
                '  let matlabComponent = null;'
                '  const pending = [];'
                '  function setup(htmlComponent){ matlabComponent = htmlComponent; while(pending.length){ const m = pending.shift(); try{ matlabComponent.Data = m; }catch(e){} } }'
                '  window.setup = setup;'
                '  function send(msg){ if(matlabComponent){ try{ matlabComponent.Data = msg; }catch(e){} } else { pending.push(msg); } }'
                '  function setIcon(id, src){ const img = document.getElementById(id); if(!img){return;} if(src){ img.src = src; img.style.visibility = "visible"; } else { img.removeAttribute("src"); img.style.visibility = "hidden"; } }'
                iconLine
'  function preloadIcons(){ try{ if(initialIcons){ setIcon("icon-new", initialIcons.new); setIcon("icon-open", initialIcons.open); setIcon("icon-load", initialIcons.load); setIcon("icon-export", initialIcons.export); } }catch(e){} }'
'  try{ preloadIcons(); }catch(e){}'
'  const root = document.getElementById("ribbonRoot");'
'  if(root){ root.addEventListener("click", (evt)=>{'
'    const btn = evt.target.closest("[data-role=primary][data-command]");'
'    if(btn){ send({type:"command", command:btn.dataset.command}); }'
'  }); }'
'  const btnLoad = document.getElementById("btn-load");'
                '  window.addEventListener("message", (event)=>{'
                '    const data = event.data || {};'
'    if(data.type === "config"){'
'      const icons = data.icons || {};'
'      setIcon("icon-new", icons.new); setIcon("icon-open", icons.open); setIcon("icon-load", icons.load); setIcon("icon-export", icons.export);'
'      if(btnLoad){ btnLoad.style.display = (data.showLoad===false)?"none":"flex"; }'
'    } else if (data.type === "state"){'
'      // no-op'
'    }'
                '  });'
                '  window.addEventListener("DOMContentLoaded", ()=>{ send({type:"ready"}); });'
                '})();'
                '</script>'
                '</body>'
                '</html>'
            };
            html = strjoin(lines, newline);
        end % buildRibbonHtml

        function assets = buildRibbonAssets(obj)
            % Use the same icon resolution strategy as StabilityControl ribbon:
            % search +UserInterface/Resources and +SimViewer/Resources and embed as data URIs.
            assets = struct();
            assets.new    = obj.encodeIconByName('New_24.png');
            assets.open   = obj.encodeIconByName('Open_24.png');
            assets.load   = obj.encodeIconByName('LoadArrow_24.png');
            if isempty(assets.load)
                assets.load = obj.encodeIconByName('LoadedArrow_24.png');
            end
            assets.export = obj.encodeIconByName('Export_24.png');
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

        function dirs = iconSearchDirs(~)
            % Mirror StabilityControl search paths so icons resolve identically
            thisDir = fileparts(mfilename('fullpath'));
            dirs = {
                fullfile(thisDir,'..','..','Resources'), ...
                fullfile(thisDir,'..','..','..','+SimViewer','Resources') ...
            };
        end

        function uri = encodeIconByName(obj, fileName)
            % Search candidate folders for an icon file and return a data URI
            candDirs = obj.iconSearchDirs();
            for i = 1:numel(candDirs)
                p = fullfile(candDirs{i}, fileName);
                if exist(p,'file') == 2
                    uri = obj.encodeIcon(p);
                    if ~isempty(uri), return; end
                end
            end
            uri = '';
        end

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


