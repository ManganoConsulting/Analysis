function [Valid,H_LL2] = getLLFilter2ndOrder2(FreqPMax,PhaseMax,HFGain,FreqGMax,FreqUnits)

% First and second order lead lag filters

% This script calculates the filter coefficents for first and second order
% lead lag filters given a desired phase "Dph" change at a given frequency
% wph - the maximum phase change (Dph) will be at the frequency wph


% Set phase change Dph (deg) at frequency wph (rad/s)
Dph = PhaseMax*pi/180;

if strcmp(FreqUnits,'Hz')
    wph = FreqPMax*2*pi;
else
    wph = FreqPMax;
end


% High Frequency Gain
ghfdB = HFGain;

% Maximum value of k
if strcmp(FreqUnits,'Hz')
    kmax = 2*pi*FreqGMax/wph;% Sets width of the 2nd order lead lag
else
    kmax = FreqGMax/wph;
end


% Calculate zero and pole of first order filter

% Calculate numerator of second order filter of the form
% (s^2 + a*wn*s + wn^2)/(s^2 + b*wn*s + wn^2) - high and low frequency gain
% = 1 - note tha a, b and wn are the filter parameters to be determined

% Calculate filter parameters for various width of the gain and phase
% curves = using the parameter k = wn/wph where wph (deg/s) is the frequency at
% which we want a phase of Dph (deg)

% Calulate a, b, and wn for n values of k

n = 1;


% Increments of k
%dk = (kmax-1)/n;

% Set high frequency gain ghf of the lead lag
ghf = 10^(ghfdB/20);

% Set number of iteration m to converge on chf and calculate increments dghf of ghf
m = 100000;
dghf = (ghf - 1)/m;

i = 1;

k(i)= kmax;
% a*b must satisfy the equation
% a*b = (k^6 - k^4 - k^2 + 1)/(k^2*(k^2 + 1))
ab(i) =(k(i)^6-k(i)^4-k(i)^2 +1)/(k(i)^2*(k(i)^2+1));
c1(i) = ab(i);
% a-b must satisfy the equation
% (a-b) = tan(Dph)*((k^2-1)^2 + a*b*k^2)/(k^3-k))
aminb(i) = tan(Dph)*((k(i)^2-1)^2+ab(i)*k(i)^2)/(k(i)^3-k(i));
c2(i) = aminb(i);
% Calculate a
a(i) = (1/2)*(c2(i)+sqrt(c2(i)^2+4*c1(i)));
% Calculte b
b(i) = a(i)-c2(i);
% Calculate wn
wn(i) = k(i)*wph;

if ghf~=1
    for j=1:m
        g1(j) = (j)*dghf + 1;
        x1(j) = (a(i) - b(i));
        y1(j) = (a(i) - b(i)*g1(j));
        d1(j) = y1(j)/x1(j);
        z1(j) = (k(i)^6 - 3*d1(j)*k(i)^4 - 3*g1(j)*k(i)^2 + d1(j))/(k(i)^4 + d1(j)*k(i)^2);
        x2(j) = tan(Dph)*((k(i)^4 + k(i)^2*z1(j) + g1(j))/(k(i)^3 - k(i)*d1(j)));
        e1(j) = z1(j) + (g1(j) + 1);
        a(i) = (1/2)*(x2(j) + sqrt(x2(j)^2 + 4*e1(j)));
        b(i) = a(i)-x2(j);
    end
end

% Set numerator of filter (s^2 + a*wn*s + wn^2)
num2(i,:) = [ghf a(i)*wn(i) wn(i)^2];

% Set denominator of filter (s^2 + b*wn*s + wn^2)
den2(i,:) = [1 b(i)*wn(i) wn(i)^2];

% Second order filter transfer function
sys2LL(i,:) = tf(num2(i,:),den2(i,:));
NUM2LL = num2(i,:);
DEN2LL = den2(i,:);


Valid = true;
H_LL2 = tf(NUM2LL,DEN2LL);