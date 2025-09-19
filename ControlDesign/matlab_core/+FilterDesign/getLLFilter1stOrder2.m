function [Valid,H_LL1] = getLLFilter1stOrder2(Freq,Phase,Gain,FreqUnits)
import FilterDesign.*
%--------------------------------------------------------------------------
% This is a 1st order phase lead/lag filter design script
% The user specifies at a desired frequency the gain
% amplification/attenuation factor, phase lead/lag.
%
% The 1st order lead/lag filter is represented as
%
%         1 + a*t*s      s + z
% H(s) = -----------  = -------
%         (1 + t*s)      s + p
%
% Date:    01-19-2014
% Author:  Nomaan Saeed
% Company: Aerospace Control Dynamics, LLC
%--------------------------------------------------------------------------

% Select Gain Amp/Attn (dB), Phase Lead/Lag in (deg) and corresponding frequency (rad/s)
cmdb  = Gain;
pmdeg = Phase;

if strcmp(FreqUnits,'Hz')
    wm = Freq*2*pi;
else
    wm = Freq;
end


% Convert to cm and pm
cm = 10^(cmdb/20);
pm = pmdeg*pi/180;


% Check if user supplied data leads to a lead or lag compensator
%
% Lead compensator: (1/cos(pm)) < cm
% Lag  compensator: (1/cos(pm)) < 1/cm
if pm > 0
    % Lead check
    if (1/cos(pm)) < cm
        icheck = 1;
    else
        icheck = 0;
    end
else
    % Lag check
    if (1/cos(pm)) < 1/cm
        icheck = 1;
    else
        icheck = 0;
    end
end

if icheck
    % Compute a and t
    a = cm*(cm-cos(pm))/(cm*cos(pm)-1);
    t = (cm*cos(pm)-1)/(cm*wm*sin(pm));
    
    % Create transfer function
    H_LL1 = tf([a*t 1],[t 1]);
    
    Valid = true;
else
    Valid = false;
    H_LL1 = [];
    errordlg('Lead/Lag Filter for user supplied Freq, Phase, and Gain combination is not realizable.');
end