function demoSplitButton_uihtml
fig = uifigure('Name','uihtml Split Button (Ribbon Style)', ...
    'Position',[100 100 560 210], 'Color',[0.12 0.12 0.12]);  % dark app bg

h = uihtml(fig, 'HTMLSource', localHtml_Ribbon(), 'Position',[16 16 360 120]);

% JS -> MATLAB
h.DataChangedFcn = @(~,evt) handleMsg(evt.Data);

% MATLAB -> JS (example: set label & icon)
h.Data = struct('label','STAB','icon','stab');  % try: 'FR', 'fr'

    function handleMsg(d)
        if ~isstruct(d) || ~isfield(d,'type'), return; end
        switch d.type
            case 'primary'
                uialert(fig,'Primary ribbon button clicked','Ribbon');
            case 'menu'
                switch d.action
                    case 'stab',  uialert(fig,'Open "Stability Editor"','Menu');
                    case 'blae',  uialert(fig,'Open "Broken Loop Analysis Editor"','Menu');
                    case 'nyquist', uialert(fig,'Open "Nyquist"','Menu');
                end
        end
    end
end

function s = localHtml_Ribbon()
% Vanilla ribbon-styled split button with inline SVG icons; HTML <-> MATLAB bridge.
s = strjoin([
"<!doctype html>"
"<html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>"
"<style>"
"  /* ---- Ribbon look ---- */"
"  :root{"
"    --bg:#1e1e1e;           /* app background (MATLAB fig is dark) */"
"    --tile:#2b2b2b;         /* ribbon tile */"
"    --tile-h:#323232;"
"    --bd:#3d3d3d;"
"    --fg:#e8e8e8;"
"    --muted:#bdbdbd;"
"    --acc:#6aa4ff;          /* accent (selected/hover) */"
"  }"
"  html,body{margin:0;background:transparent;color:var(--fg);font:13px/1.3 Segoe UI,system-ui,Arial,sans-serif;}"
"  .ribbon{display:flex;gap:8px;padding:8px;background:transparent;}"
"  .tile{display:inline-flex;align-items:center;background:var(--tile);border:1px solid var(--bd);border-radius:8px;"
"        box-shadow:0 1px 2px rgba(0,0,0,.35) inset;}"
"  .tile:hover{background:var(--tile-h);}  "
""
"  /* Split button anatomy */"
"  .btn-main{display:flex;align-items:center;gap:8px;padding:8px 10px 8px 8px;border:none;background:transparent;"
"            color:var(--fg);cursor:pointer;border-right:1px solid var(--bd);border-top-left-radius:8px;border-bottom-left-radius:8px;}"
"  .btn-split{width:34px;display:flex;align-items:center;justify-content:center;padding:0 8px;border:none;background:transparent;"
"             color:var(--fg);cursor:pointer;border-top-right-radius:8px;border-bottom-right-radius:8px;}"
"  .btn-main:hover,.btn-split:hover{filter:brightness(1.05);} "
"  .icon{width:18px;height:18px;display:inline-block;}"
"  .label{font-weight:600;letter-spacing:.3px;}"
"  .caret{width:0;height:0;border-left:5px solid transparent;border-right:5px solid transparent;border-top:6px solid var(--fg);} "
""
"  /* Dropdown */"
"  .menu{position:absolute;display:none;min-width:220px;background:#222;border:1px solid var(--bd);border-radius:8px;"
"        box-shadow:0 10px 24px rgba(0,0,0,.45);margin-top:4px;padding:6px 0;z-index:10;}"
"  .menu.open{display:block;}"
"  .item{padding:8px 12px;color:var(--fg);text-decoration:none;display:flex;gap:10px;align-items:center;cursor:pointer;}"
"  .item:hover{background:#2e2e2e;}"
"  .bullet{width:8px;height:8px;border-radius:50%;background:var(--muted);} "
""
"  /* Hide default list bullets if any */"
"  ul{margin:0;padding:0;list-style:none;}"
"</style>"
"</head>"
"<body>"
"  <!-- SVG sprite for icons -->"
"  <svg width='0' height='0' style='position:absolute;visibility:hidden'>"
"    <symbol id='ico-stab' viewBox='0 0 24 24'>"
"      <path fill='currentColor' d='M3 5h18v2H3zM6 9h12v2H6zM4 20l6-6 4 4 6-6 2 2-8 8-4-4-4 4z'/>"
"    </symbol>"
"    <symbol id='ico-fr' viewBox='0 0 24 24'>"
"      <path fill='currentColor' d='M4 19V5h2v12h12v2H4zm3-4l3-5 3 4 2-3 3 4-2 1-1-1-2 3-3-4-2 3z'/>"
"    </symbol>"
"  </svg>"
""
"  <div class='ribbon'>"
"    <div class='tile' id='stabTile' style='position:relative;'>"
"      <button class='btn-main' id='mainBtn'>"
"        <svg class='icon' id='mainIcon'><use href='#ico-stab'></use></svg>"
"        <span class='label' id='mainLabel'>STAB</span>"
"      </button>"
"      <button class='btn-split' id='splitBtn' aria-haspopup='menu' aria-expanded='false' title='More'>"
"        <div class='caret'></div>"
"      </button>"
"      <div class='menu' id='menu' role='menu' aria-label='STAB menu'>"
"        <div class='item' data-action='stab'><span class='bullet'></span>Stability Editor</div>"
"        <div class='item' data-action='blae'><span class='bullet'></span>Broken Loop Analysis Editor</div>"
"        <div class='item' data-action='nyquist'><span class='bullet'></span>Nyquist</div>"
"      </div>"
"    </div>"
"  </div>"
""
"<script>"
"  const mainBtn  = document.getElementById('mainBtn');"
"  const splitBtn = document.getElementById('splitBtn');"
"  const menu     = document.getElementById('menu');"
"  const tile     = document.getElementById('stabTile');"
"  const mainLab  = document.getElementById('mainLabel');"
"  const mainIcon = document.getElementById('mainIcon');"
""
"  function sendToMATLAB(p){ if(window.parent){ window.parent.postMessage(p,'*'); } }"
""
"  // HTML -> MATLAB"
"  mainBtn.addEventListener('click', ()=> sendToMATLAB({type:'primary'}));"
"  splitBtn.addEventListener('click', ()=> {"
"    const open = menu.classList.toggle('open');"
"    splitBtn.setAttribute('aria-expanded', open?'true':'false');"
"  });"
"  menu.addEventListener('click', (e)=>{"
"    const el = e.target.closest('.item');"
"    if(!el) return;"
"    sendToMATLAB({type:'menu', action:el.dataset.action});"
"    menu.classList.remove('open');"
"    splitBtn.setAttribute('aria-expanded','false');"
"  });"
"  document.addEventListener('click', (e)=>{ if(!tile.contains(e.target)) { menu.classList.remove('open'); splitBtn.setAttribute('aria-expanded','false'); }});"
""
"  // MATLAB -> HTML (set label/icon)  h.Data = struct('label','FR','icon','fr')"
"  window.addEventListener('message', (event)=>{"
"    const d = event.data||{};"
"    if(d.label) mainLab.textContent = d.label;"
"    if(d.icon){"
"      const map = { stab:'#ico-stab', fr:'#ico-fr' };"
"      const href = map[d.icon] || '#ico-stab';"
"      mainIcon.innerHTML = '';"
"      mainIcon.insertAdjacentHTML('afterbegin', `<use href='${href}'></use>`);"
"    }"
"  });"
"</script>"
"</body></html>"
], newline);
end
