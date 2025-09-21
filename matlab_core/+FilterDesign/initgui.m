% Variables initialization
import FilterDesign.*
hdl.data.iFilterType    = 1;
hdl.data.selFilterType  = 'Notch/BandPass Filter';
hdl.data.FilterName     = [];
hdl.data.Filter         = [];
hdl.data.FilterList     = [];
hdl.data.FilterOrder    = 2;

hdl.data.FreqUnits      = 'Hz';

hdl.data.FilterInfo = 0;

hdl.data.NFSettings.CenterFreq_Max = inf;
hdl.data.NFSettings.CenterFreq_Min = 0;

hdl.data.NFSettings.CenterAttn_Max = inf;
hdl.data.NFSettings.CenterAttn_Min = -inf;

hdl.data.NFSettings.Freq2_Max = inf;
hdl.data.NFSettings.Freq2_Min = 0;

hdl.data.NFSettings.Attn2_Max = inf;
hdl.data.NFSettings.Attn2_Min = -inf;

hdl.data.NFSettings.DCGain_Max = inf;
hdl.data.NFSettings.DCGain_Min = -inf;

hdl.data.NFSettings.HFGain_Max = inf;
hdl.data.NFSettings.HFGain_Min = -inf;

hdl.data.LL1Settings.Freq_Max = inf;
hdl.data.LL1Settings.Freq_Min = 0;

hdl.data.LL1Settings.Phase_Max = inf;
hdl.data.LL1Settings.Phase_Min = -inf;

hdl.data.LL1Settings.Gain_Max = inf;
hdl.data.LL1Settings.Gain_Min = -inf;

hdl.data.LL2Settings.FreqPMax_Max = inf;
hdl.data.LL2Settings.FreqPMax_Min = 0;

hdl.data.LL2Settings.PhaseMax_Max = inf;
hdl.data.LL2Settings.PhaseMax_Min = -inf;

hdl.data.LL2Settings.HFGain_Max = inf;
hdl.data.LL2Settings.HFGain_Min = -inf;

hdl.data.LL2Settings.FreqGMax_Max = inf;
hdl.data.LL2Settings.FreqGMax_Min = 0;