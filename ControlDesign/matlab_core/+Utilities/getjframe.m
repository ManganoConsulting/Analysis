function jframe = getjframe(hFig)


  try
      % Default figure = current (gcf)
      if nargin < 1 || ~all(ishghandle(hFig))
          if nargin && ~all(ishghandle(hFig))
              error('hFig must be a valid GUI handle or array of handles');
          end
          hFig = gcf;
      end

      % Require Java engine to run
      if ~usejava('jvm')
          error([mfilename ' requires Java to run.']);
      end

      % Initialize output var (needed in case hFig is empty)
      jframe = handle([]);

      % Loop over all requested figures
      for figIdx = 1 : length(hFig)

          % Get the root Java frame
          jff = getJFrame(hFig(figIdx));

          % Add the 'ListOfCallbacks' read-only property to jframe
          fields = fieldnames(get(jff));
          cb1Idx = find(~cellfun('isempty',strfind(fields,'Callback')));
          cb2Idx = find(~cellfun('isempty',strfind(fields,'CallbackData')));
          cbIdx = setdiff(cb1Idx, cb2Idx)';
          cbNames = fields(cbIdx);
          jframe(figIdx) = handle(jff,'callbackproperties');
          addReadOnlyProp(jframe(figIdx),'ListOfCallbacks',cbNames);

          % Add another read-only property for direct access to the wrapped java object
          addReadOnlyProp(jframe(figIdx),'JavaComponent',jff);

          % Add another read-only property for direct access to the original Matlab figure handle
          addReadOnlyProp(jframe(figIdx),'MatlabFigureHandle',hFig(figIdx));
      end

  % Error handling
  catch
      v = version;
      if v(1)<='6'
          err.message = lasterr;  % no lasterror function...
      else
          err = lasterror;
      end
      try
          err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = findstr(err.message,'Error using ==> ');
              stopIdx = findstr(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(findstr(mfilename,err.message))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end
  end

%% Add a read-only property to an object
function addReadOnlyProp(obj,propName,initValue)
  try
      % This will fail in R2014b+ since schema.prop is no longer supported in HG2
      sp = schema.prop(obj,propName,'mxArray');
      set(obj,propName,initValue);
      set(sp,'AccessFlags.PublicSet','off');
  catch
      % Never mind - property might already exist...
  end

%% Get the root Java frame (up to 10 tries, to wait for figure to become responsive)
function jframe = getJFrame(hFigHandle)

  % Ensure that hFig is a figure handle...
  hFig = ancestor(hFigHandle,'figure');
  if isempty(hFig)
      error(['Cannot retrieve the figure handle for handle ' num2str(hFigHandle)]);
  end

  jframe = [];
  maxTries = 10;
  while maxTries > 0
      try
          % Get the figure's underlying Java frame
          jf = get(handle(hFig),'JavaFrame');

          % Get the Java frame's root frame handle
          %jframe = jf.getFigurePanelContainer.getComponent(0).getRootPane.getParent;
          try
              jClient = jf.fFigureClient;  % This works up to R2011a
          catch
              try
                  jClient = jf.fHG1Client;  % This works from R2008b-R2014a
              catch
                  jClient = jf.fHG2Client;  % This works from R2014b and up
              end
          end
          jframe = jClient.getWindow;  % equivalent to above...
          if ~isempty(jframe)
              break;
          else
              maxTries = maxTries - 1;
              drawnow; pause(0.1);
          end
      catch
          maxTries = maxTries - 1;
          drawnow; pause(0.1);
      end
  end
  if isempty(jframe)
      error(['Cannot retrieve the java frame for handle ' num2str(hFigHandle)]);
  end
