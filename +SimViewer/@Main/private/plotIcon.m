function jImage = plotIcon()
    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    iconPath = fullfile(icon_dir,'Figure_16.png');
    im = imread(iconPath,'BackgroundColor',[1,1,1]);

    warning('off','MATLAB:im2java:functionToBeRemoved');
     jImage = im2java(im);
end
