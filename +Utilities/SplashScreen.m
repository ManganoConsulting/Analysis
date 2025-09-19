function splash = SplashScreen(parentFigure)
%UTILITIES.SPLASHSCREEN Display the Control Design splash screen image.
%   splash = Utilities.SplashScreen(parentFigure) displays the application
%   splash screen while the user interface loads. The returned object can be
%   deleted to close the splash screen. When a parent figure is supplied,
%   it is kept hidden until the splash screen is dismissed.
%
%   Example:
%       fig = uifigure('Visible','off');
%       splash = Utilities.SplashScreen(fig);
%       % Configure application user interface here.
%       delete(splash);

    if nargin < 1
        parentFigure = [];
    end

    parentInfo = iPrepareParentFigure(parentFigure);

    imagePath = iGetSplashImagePath();
    imageSize = iGetImageSize(imagePath);
    splashPosition = iCalculateSplashPosition(parentInfo.Figure, imageSize);

    splashFigure = iCreateSplashFigure(splashPosition);
    uiimage(splashFigure, ...
        'ImageSource', imagePath, ...
        'Position', [1 1 splashPosition(3) splashPosition(4)], ...
        'ScaleMethod', 'none');

    splashFigure.Visible = 'on';
    drawnow();

    splash = Utilities.SplashScreenController(splashFigure, parentInfo);
end

function info = iPrepareParentFigure(parentFigure)
    info = struct('Figure', [], ...
                  'VisibilityOnClose', 'on');
    if isempty(parentFigure)
        return;
    end
    if ~(isscalar(parentFigure) && isgraphics(parentFigure, 'figure'))
        error('Utilities:SplashScreen:InvalidParent', ...
            'Parent figure must be a scalar figure handle.');
    end

    info.Figure = parentFigure;
    info.VisibilityOnClose = 'on';

    parentFigure.Visible = 'on';
    drawnow limitrate nocallbacks;
end

function imagePath = iGetSplashImagePath()
    utilitiesFolder = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(utilitiesFolder);
    imagePath = fullfile(projectRoot, '+UserInterface', 'Resources', 'v5_splashscreen_badge_splash.png');
    if exist(imagePath, 'file') ~= 2
        error('Utilities:SplashScreen:MissingImage', ...
            'Splash screen image ''%s'' not found.', imagePath);
    end
end

function imageSize = iGetImageSize(imagePath)
    info = imfinfo(imagePath);
    imageSize = [info.Width, info.Height];
end

function position = iCalculateSplashPosition(parentFigure, imageSize)
    width = imageSize(1);
    height = imageSize(2);
    screenSize = get(groot, 'ScreenSize');

    if ~isempty(parentFigure) && isvalid(parentFigure)
        parentPos = parentFigure.Position;
        x = parentPos(1) + (parentPos(3) - width) / 2;
        y = parentPos(2) + (parentPos(4) - height) / 2;
    else
        x = screenSize(1) + (screenSize(3) - width) / 2;
        y = screenSize(2) + (screenSize(4) - height) / 2;
    end

    left = round(x);
    bottom = round(y);

    minX = screenSize(1);
    minY = screenSize(2);
    maxX = max(minX, screenSize(1) + screenSize(3) - width);
    maxY = max(minY, screenSize(2) + screenSize(4) - height);

    if left < minX
        left = minX;
    elseif left > maxX
        left = maxX;
    end
    if bottom < minY
        bottom = minY;
    elseif bottom > maxY
        bottom = maxY;
    end

    position = [left, bottom, width, height];
end

function splashFigure = iCreateSplashFigure(position)
    splashFigure = uifigure('Visible', 'off', ...
        'Units', 'pixels', ...
        'Position', position, ...
        'Resize', 'off', ...
        'AutoResizeChildren', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Color', [0 0 0], ...
        'Tag', 'UtilitiesSplashScreen');

    try
        splashFigure.WindowStyle = 'alwaysontop';
    catch
        % Property not supported in this release; ignore.
    end

    splashFigure.CloseRequestFcn = @(~, ~)[];
end
