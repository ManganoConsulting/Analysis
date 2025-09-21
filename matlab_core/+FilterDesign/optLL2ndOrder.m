function f = optLL2ndOrder(x,pm,wm,HFGain)
import FilterDesign.*
% Error function
f1 = (cos(pm)-((2*x(2)*(wm/x(1)))^2 - ((wm/x(1))^2 - 1)^2)/((2*x(2)*(wm/x(1)))^2 + ((wm/x(1))^2 - 1)^2))^2;

w1 = x(1);

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

KHF = wp^2/wz^2;

KHFT = 10^(HFGain/20);

f2 = (KHF-KHFT)^2;

f = f1+f2;
