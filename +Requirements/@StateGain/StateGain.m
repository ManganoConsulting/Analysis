classdef StateGain < Requirements.Gain

    %% Public properties
    properties
        StateName
        Control
    end % Public properties

    %% Methods - Constructor
    methods
        function s = StateGain(state,gain,control,value)
            switch nargin
                case 1
                    s.StateName = state{1};
                    s.Name = state{2};
                    s.Control = state{3};
                case 3
                    s.StateName = state;
                    s.Name = gain;
                    s.Control = control;
                case 4
                    s.StateName = state;
                    s.Name = gain;
                    s.Control = control;
                    s.Value = value;
            end
        end % StateGain
    end % Constructor
end