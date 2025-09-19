function [Param] = NotchFilterParam()
import FilterDesign.*
             %struc % Label
Param.Label= 'NF';

              % Variable         % Label          %Min %Max   
Param.Data = {'CenterFreq','Center Frequency (Hz)',     0 , 1e9
              'CenterAttn','Center Attenuation (dB)',-1e9,  1e9
              'Freq2'     ,'2nd Frequency (Hz)',        0,  1e9
              'Attn2'     ,'2nd Attenuation (dB)',   -1e9,  1e9
              'DCGain'    ,'DC Gain (dB)',           -1e9,  1e9
              'HFGain'    ,'HF Gain (dB)',           -1e9,  1e9};

Param.Function = 'getNotchFilter';