function [Valid,H_Notch] = getNotchFilter(CenterFreq,CenterAttn,Freq2,Attn2,DCGain,HFGain,FreqUnits)
import FilterDesign.optNotch.*

k_c = 10^((CenterAttn-DCGain)/20);
k_dc = 10^(Attn2/20);
k_hf= 10^((HFGain-DCGain)/20);
k_0 = 10^(DCGain/20);

if strcmp(FreqUnits,'Hz')
    CenterFreq1 = CenterFreq;
    Freq22 = Freq2;
else
    CenterFreq1 = CenterFreq/2/pi;
    Freq22 = Freq2/2/pi;
end

CenterFreq1 = CenterFreq1*sqrt(k_hf); %*sqrt(k_hf);

w_c = CenterFreq1*2*pi;
dw_c = abs(w_c-Freq22*2*pi);

% Set temporary parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = (1 - dw_c/w_c); % Fraction below center frequency

% Calculate coefficients a_num and a_den for the filter
% (k_hf*s^2 + a_num*w_c*s + w_c^2)/(s^2 + a_den*w_c*s + w_c^2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


a_num_2 = ((k_c/k_dc)^2*((1-c^2)/(c))^2)*(1-k_dc^2)/(1-(k_c/k_dc)^2);
a_den_2 = (1/k_dc)^2*(a_num_2 + ((1-c^2)/c)^2*(1-k_dc^2));
w_n = w_c;
%

if k_hf ~=1
    if k_c <=1
        a_num_2_temp = k_c^2*(a_den_2 + (k_hf-1)^2/k_hf);
        a_den_2_temp = a_den_2;
    end
    if k_c >1
        a_den_2_temp = a_den_2;
        a_num_2_temp = a_num_2;
    end
    a_num_2 = a_num_2_temp;
    a_den_2 = a_den_2_temp;
end

% Note that the damping of the zeros in the transferfunction is zeta_num = a_num/2
% Note that the damping of the poles in the transfer function is zeta_den = a_den/2
a_den = sqrt(a_den_2);
a_num = sqrt(a_num_2);
zeta_num0 = a_num/2;
zeta_den0 = a_den/2;

% Change center frequency name
omega_c0 = w_n; % [rad/s]

%options = optimset('Display','iter');
options = [];

if HFGain ~=DCGain
    if strcmp(FreqUnits,'Hz')
        [x,FVAL,EXITFLAG] = fminsearch(@(x) FilterDesign.optNotch(x,k_0,CenterFreq*2*pi,10^(CenterAttn/20),Freq22*2*pi,k_dc,10^(HFGain/20)),[zeta_num0,zeta_den0,omega_c0,k_hf,1],options);
    else
        [x,FVAL,EXITFLAG] = fminsearch(@(x) FilterDesign.optNotch(x,k_0,CenterFreq,10^(CenterAttn/20),Freq2,k_dc,10^(HFGain/20)),[zeta_num0,zeta_den0,omega_c0,k_hf,1],options);
    end
    zeta_num = x(1);
    zeta_den = x(2);
    omega_c  = x(3);
    anum     = x(4);
    aden     = x(5);
    
else
    EXITFLAG = 1;
    omega_c = omega_c0;
    zeta_num = zeta_num0;
    zeta_den = zeta_den0;
    anum = k_hf;
    aden = 1;
end


if EXITFLAG
    H_Notch = tf(k_0*[anum 2*zeta_num*omega_c omega_c^2],[aden 2*zeta_den*omega_c omega_c^2]);

else
    H_Notch = [];
end

Valid = EXITFLAG;


% % Filter transfer function
% 
% display('NotchSys_cont')
% 
% NotchSys_cont = zpk(tf(k_0*[anum 2*zeta_num*omega_c omega_c^2],[aden 2*zeta_den*omega_c omega_c^2]))
% 
% h_c = mag2db(abs(freqresp(NotchSys_cont,CenterFreq*2*pi)))
% h_2 = mag2db(abs(freqresp(NotchSys_cont,Freq2*2*pi)))
% 
% wRad=unique([logspace(-2,4,1000),CenterFreq*2*pi,Freq2*2*pi]);
% 
% figure(1000)
% bode(NotchSys_cont,wRad);grid on
% title('Notch filter gain and phase versus frequency rad/s')
% xlabel('Frequnecy rad/s')