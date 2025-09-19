function jImage = signalLogIcon()
    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    iconPath = fullfile(icon_dir,'LogSignals_16.png');
    im = imread(iconPath,'BackgroundColor',[1,1,1]);

    warning('off','MATLAB:im2java:functionToBeRemoved');
     jImage = im2java(im);
end

