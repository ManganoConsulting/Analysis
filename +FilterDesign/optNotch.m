function f = optNotch(x,k_0,w_c,k_c,w2,k2,k_hf)
import FilterDesign.*
zeta_num = x(1);
zeta_den = x(2);
omega_c  = x(3);
anum     = x(4);
aden     = x(5);

num = k_0*[anum 2*zeta_num*omega_c omega_c^2];
den = [aden 2*zeta_den*omega_c omega_c^2];

h1 = freqresp(tf(num,den),[w2,w_c]);

dw = 1e-5;
h2 = squeeze(freqresp(tf(num,den),[w_c-dw/2,w_c+dw/2]));
h11=abs(h2(1));
h22=abs(h2(2));
dh = (h22-h11)/dw;

k_hff = k_0*anum/aden;

f = (abs(h1(1))-k2)^2 + dh^2 + (abs(h1(2))-k_c)^2 + (k_hff-k_hf)^2;% + diff(abs(h2(2))-abs(h2(1)));
