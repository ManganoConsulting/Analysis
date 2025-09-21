function warn = suppressWarnings()
% these warning appear due to using undocumented and unsupported
% features in matalb    

    warn(1) = warning('off','MATLAB:Java:ConvertFromOpaque'); 
    warn(2) = warning('off','MATLAB:uitree:DeprecatedFunction'); 
    warn(3) = warning('off','MATLAB:uitreenode:DeprecatedFunction'); 
    warn(4) = warning('off','MATLAB:hg:JavaSetHGProperty');
    warn(5) = warning('off','MATLAB:legend:IgnoringExtraEntries');
    warn(6) = warning('off','MATLAB:class:loadError');   
    warn(7) = warning('off','MATLAB:hg:PossibleDeprecatedJavaSetHGProperty');  
    warn(8) = warning('off','MATLAB:hg:ColorSpec_None');
    warn(9) = warning('off','MATLAB:uitabgroup:OldVersion');

end % suppressWarnings