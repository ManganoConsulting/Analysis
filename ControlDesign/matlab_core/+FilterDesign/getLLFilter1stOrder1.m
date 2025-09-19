function [Valid,H_LL1] = getLLFilter1stOrder1(Freq,Phase,FreqUnits)
import FilterDesign.*
%--------------------------------------------------------------------------
% This is a 1st order phase lead/lag filter design script
%
% The 1st order lead/lag filter is represented as
%
%         1 + a*t*s      s + z
% H(s) = -----------  = -------
%         a(1 + t*s)     s + p
%
% Date:    01-18-2014
% Author:  Nomaan Saeed
% Company: Aerospace Control Dynamics, LLC
%--------------------------------------------------------------------------
%clc; clear all; close all;

% Select Phase Lead/Lag in (rad) and corresponding frequency (rad/s)
pm = Phase*(pi/180);

if strcmp(FreqUnits,'Hz')
    wm = Freq*2*pi;
else
    wm = Freq;
end

% Compute a
a = (1+sin(pm))/(1-sin(pm));

% Compute pole and zero and K
p = wm*sqrt(a);
z = p/a;
K = a;

% Create transfer function
H_LL1 = K*tf([1 z],[1 p]);

Valid = true;

% Create bode diagram
% w = logspace(-2,2,1000);
% [mag,ph] = bode(H,w);
% magdb = 20*log10(squeeze(mag));
% phdeg = squeeze(ph);
% 
% % Plot Lead/Lag Filter
% figure(1);
% subplot(2,1,1);
% semilogx(w,magdb);
% xlabel('Frequency (rad/s)');
% ylabel('Magnitude (dB)');
% grid on;
% subplot(2,1,2);
% semilogx(w,phdeg);
% xlabel('Frequency (rad/s)');
% ylabel('Phase (deg)');
% grid on;