function jImage = outputIcon()
    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    iconPath = fullfile(icon_dir,'simulink_app_16_OUT.png');
    im = imread(iconPath,'BackgroundColor',[1,1,1]);

    warning('off','MATLAB:im2java:functionToBeRemoved');
     jImage = im2java(im);
end

