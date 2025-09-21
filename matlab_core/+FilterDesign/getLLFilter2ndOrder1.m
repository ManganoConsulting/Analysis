function [Valid,H_LL2] = getLLFilter2ndOrder1(FreqPMax,PhaseMax,HFGain,FreqUnits)
import FilterDesign.*
%--------------------------------------------------------------------------
% This is a 2nd order phase lead/lag filter design script
%
% The 2nd order lead/lag filter is represented as
%
%         s^2/wz^2 + 2*zetaz*s/wz + 1
% H(s) = ------------------------------
%         s^2/wp^2 + 2*zetap*s/wp + 1
%
% For lead/lag filter: zetac == zetaz = zetap
%
% Date:    01-18-2014
% Author:  Nomaan Saeed
% Company: Aerospace Control Dynamics, LLC
%--------------------------------------------------------------------------

% Select desired phase lead or lag, corresponding freq, and
% damping ratio (controls the width of the phase curve)
pm = PhaseMax*(pi/180);       % (rad)

if strcmp(FreqUnits,'Hz')
    wm = FreqPMax*2*pi;
else
    wm = FreqPMax;
end

% Initial guess
zetac = 0.4;

% Optimization, solves w1 (see slides)
options = optimset('Display','none');
% f  = @(wzs,zetac,pm,wm) (cos(pm)-((2*zetac*(wm/wzs))^2 - ((wm/wzs)^2 - 1)^2)/((2*zetac*(wm/wzs))^2 + ((wm/wzs)^2 - 1)^2))^2; 
[x,FVAL,EXITFLAG] = fminsearch(@(x) optLL2ndOrder(x,pm,wm,HFGain),[wm*2,zetac],options);
w1 = x(1);
zetac=x(2);
w2 = wm^2/w1;

if pm>0
    % Lead filter
    if w1 > w2
        wz = w2;
        wp = w1;
    else
        wp = w2;
        wz = w1;
    end
else
    % Lag filter
    if w1 > w2
        wz = w1;
        wp = w2;
    else
        wp = w1;
        wz = w2;
    end
end

if EXITFLAG
    H_LL2 = tf([1/wz^2 2*zetac/wz 1],[1/wp^2 2*zetac/wp 1]);
else
    H_LL2 = [];
end

Valid = EXITFLAG;