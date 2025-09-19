function DHX = DHX(MatlabColourVector,useMatlab)

if nargin == 2 && useMatlab == true
    RGB_R = round(MatlabColourVector(1) * 256);
    RGB_G = round(MatlabColourVector(2) * 256);
    RGB_B = round(MatlabColourVector(3) * 256);
else
    RGB_R = round(MatlabColourVector(1));
    RGB_G = round(MatlabColourVector(2));
    RGB_B = round(MatlabColourVector(3));
end

if RGB_R == 256; RGB_R = 255;end;
if RGB_G == 256; RGB_G = 255;end;
if RGB_B == 256; RGB_B = 255;end;


%Cannot accept 256, only 0-255.


HEX_R = dec2hex(RGB_R,2); %The 2 means I want at least 2 digits returned
HEX_G = dec2hex(RGB_G,2);
HEX_B = dec2hex(RGB_B,2);


%NB: Visual basic colour values do not follow RGB convention. They are BGR values.


DHX = hex2dec([HEX_B,HEX_G,HEX_R]);