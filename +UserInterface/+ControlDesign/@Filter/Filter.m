classdef Filter < matlab.mixin.Copyable
    
    %% Public properties
    properties   
        Name
        Type = 1
        Units
        Displayed logical = false
                    
    CurrentPropertiesInUse = {}

    end % Public properties
    
    %% Notch properties
    properties   
        CenterFrequency
        CenterAttenuation
        SecondFrequency
        SecondAttenuation
        DCGain
        HFGain
        
        % Mapping
        Num
        Den

    end % Public properties
    
    %% Lead/Lag First Order properties
    properties   
        Frequency
        Phase
        Gain
        
%         % Mapping
%         Num
%         Den
    end % Public properties
    
    %% Lead/Lag Second Order properties
    properties   
        FrequencyAtMaxPhase
        MaxPhase
        %HFGain
        FrequencyAtMaxGain
        
%         % Mapping
%         Num
%         Den
    end % Public properties
    
    %% Complimentary Second Order properties
    properties
        WF
        ZF
        
        % Mapping
        A
        B
    end % Public properties
    
    %% Complimentary Third Order properties
    properties  
        %WF
        %ZF
        AF
        
        % Mapping
        %A
        %B
        C
    end % Public properties 
    
    %% Complimentary Fourth Order properties
    properties  
        WF1
        ZF1
        WF2
        ZF2
        
        % Mapping   
        %A
        %B
        %C
        D
%         X1
%         X2
%         Z1
%         Z2
    end % Public properties
    
    %% Properties - Observable AbortSet
    properties( SetObservable , AbortSet )
        
    end
  
    %% Private properties
    properties ( Access = private )  
        SelectedPropertyIndex
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties% (Hidden = true)
        Max double = 1
        Min double = 0
        CreatedFromModel logical = false
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true)
        TypeString
        DisplayString
        CurrentPropertySelected
        FilterTypes % Nathan moved here
        FilterTypesDisplay % Nathan moved here
        FilterUnits
        
    end % Dependant properties
    
    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        SliderEnable
        
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = Filter(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Name','x',@ischar);
            addParameter(p,'Type',1);
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Name = options.Name;
%             switch class(options.String)
%                 case 'struct'
%                     obj.ValueString = ['<',size(options.String,1),',',size(options.String,2),'> struct'];
%                 case 'cell'
%                     obj.ValueString = ['<',size(options.String,1),',',size(options.String,2),'> cell'];
%                 case 'char'
%                     obj.ValueString = options.String;
%                 otherwise
%                     obj.ValueString = num2str(options.String);
%             end
%             defaultMinMax( obj );
        end % Filter
        
    end % Constructor

    %% Methods - Property Access
    methods
    
        function set.CurrentPropertySelected( obj , x )
            if isnumeric(x) && isscalar(x)
                obj.SelectedPropertyIndex = x;
            else
                
            end
        end % CurrentPropertySelected - Set
        
        function y = get.CurrentPropertySelected( obj )
            if isempty(obj.SelectedPropertyIndex) || isempty(obj.CurrentPropertiesInUse)
                y = [];
            else
                y = obj.CurrentPropertiesInUse{obj.SelectedPropertyIndex};
            end
        end % CurrentPropertySelected - Get
        
        function set.DisplayString( obj , x )
            logArray = strcmp(obj.FilterTypesDisplay,x);
            if sum(logArray) == 1 
                obj.Type = find(logArray);
            end
        end % DisplayString - Set
        
        function y = get.DisplayString(obj)
            y = obj.FilterTypesDisplay{obj.Type};
        end % DisplayString
        
        function y = get.SliderEnable(obj)
            testNum = str2double(obj.ValueString);
            if isnan(testNum)
                y = false;     
            else
                y = true;     
            end
        end % Value       

        function y = get.FilterTypes(obj)
            y = {'LeadLagFirstOrder',...
                'LeadLagSecondOrder',...
                'NotchFilter'};
                % 'ComplimentaryFilterSecondOrderType1',...
                % 'ComplimentaryFilterSecondOrderType2',...
                % 'ComplimentaryFilterThirdOrderType1',...
                % 'ComplimentaryFilterThirdOrderType2',...
                % 'ComplimentaryFilterFourthOrderType1',...
                % 'ComplimentaryFilterFourthOrderType2',...
                % 'ComplimentaryFilterFourthOrderType3'};
        end

        function y = get.FilterTypesDisplay(obj)
            y = {'Lead/Lag - 1st Order',...
                'Lead/Lag - 2nd Order',...
                'Notch'};
                % 'Complimentary 2nd Order Type 1',...
                % 'Complimentary 2nd Order Type 2',...
                % 'Complimentary 3rd Order Type 1',...
                % 'Complimentary 3rd Order Type 2',...
                % 'Complimentary 4th Order Type 1',...
                % 'Complimentary 4th Order Type 2',...
                % 'Complimentary 4th Order Type 3'};
        end

        function y =get.FilterUnits(obj)
            y = {'rad/s'...
                'Hz'};
        end

    end % Property access methods
   
    %% Methods - Ordinary
    methods 

        function param = getFilterParameterValues( obj )
            param = UserInterface.ControlDesign.Parameter.empty;
            for i = 1:length(obj)
                switch obj(i).Type
                    case 1
%                         if isempty(obj(i).Gain)
%                             [NUM,DEN] = getLLFilter1stOrder1(obj(i).Frequency,...
%                                                             obj(i).Phase,...
%                                                             'Hz');
%                         else
%                             [NUM,DEN] = getLLFilter1stOrder2(obj(i).Frequency,...
%                                                             obj(i).Phase,...
%                                                             obj(i).Gain,...
%                                                             'Hz');
%                         end
                        [NUM,DEN] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).Num) && ~isempty(obj(i).Den)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Num,'Value',NUM);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Den,'Value',DEN); %#ok<*AGROW>
                        end
                    case 2
%                         if isempty(obj(i).FrequencyAtMaxGain)    
%                             [NUM,DEN] = getLLFilter2ndOrder1(obj(i).FrequencyAtMaxPhase,...
%                                                             obj(i).MaxPhase,...
%                                                             obj(i).HFGain,...
%                                                             'Hz');
%                         else
%                             [NUM,DEN] = getLLFilter2ndOrder2(obj(i).FrequencyAtMaxPhase,...
%                                                             obj(i).MaxPhase,...
%                                                             obj(i).HFGain,...
%                                                             obj(i).FrequencyAtMaxGain,...
%                                                             'Hz');
%                         end
                        [NUM,DEN] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).Num) && ~isempty(obj(i).Den)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Num,'Value',NUM);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Den,'Value',DEN); %#ok<*AGROW>
                        end
                    case 3
%                         [NUM,DEN] = getNotchFilter(obj(i).CenterFrequency,...
%                                                     obj(i).CenterAttenuation,...
%                                                     obj(i).SecondFrequency,...
%                                                     obj(i).SecondAttenuation,...
%                                                     obj(i).DCGain,...
%                                                     obj(i).HFGain,...
%                                                     'Hz');
                        [NUM,DEN] = getFilterValues( obj(i) );                        
                        if ~isempty(obj(i).Num) && ~isempty(obj(i).Den)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Num,'Value',NUM);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).Den,'Value',DEN); %#ok<*AGROW>
                        end
                    case 4
                        %[A,B] = SecondOrderCF_Type1( obj(i).WF , obj(i).ZF ); %#ok<*PROP>
                        [A,B] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                        end
                    case 5
                        %[A,B] = SecondOrderCF_Type2( obj(i).WF , obj(i).ZF );
                        [A,B] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                        end
                    case 6
                        %[A,B,C] = ThirdOrderCF_Type1( obj(i).WF , obj(i).ZF , obj(i).AF );
                        [A,B,C] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                        end
                    case 7
                        [A,B,C] = ThirdOrderCF_Type2( obj(i).WF , obj(i).ZF , obj(i).AF );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                        end
                    case 8
                        %[A,B,C,D] = FourthOrderCF_Type1( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        [A,B,C,D] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                    case 9
                        %[A,B,C,D] = FourthOrderCF_Type2( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        [A,B,C,D] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                    case 10
                        %[A,B,C,D] = FourthOrderCF_Type3( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        [A,B,C,D] = getFilterValues( obj(i) );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                end
            end
        end % getFilterParameterValues
        
        function [A,B,C,D] = getFilterValues( obj )
            A = [];
            B = [];
            C = [];
            D = [];
            for i = 1:length(obj)
                switch obj(i).Type
                    case 1
                        if isempty(obj(i).Gain)
                            [A,B] = getLLFilter1stOrder1(obj(i).Frequency,...
                                                            obj(i).Phase,...
                                                            obj(i).Units);
                        else
                            [A,B] = getLLFilter1stOrder2(obj(i).Frequency,...
                                                            obj(i).Phase,...
                                                            obj(i).Gain,...
                                                            obj(i).Units);
                        end

                    case 2
                        if isempty(obj(i).FrequencyAtMaxGain)    
                            [A,B] = getLLFilter2ndOrder1(obj(i).FrequencyAtMaxPhase,...
                                                            obj(i).MaxPhase,...
                                                            obj(i).HFGain,...
                                                            obj(i).Units);
                        else
                            [A,B] = getLLFilter2ndOrder2(obj(i).FrequencyAtMaxPhase,...
                                                            obj(i).MaxPhase,...
                                                            obj(i).HFGain,...
                                                            obj(i).FrequencyAtMaxGain,...
                                                            obj(i).Units);
                        end
                    case 3
                        [A,B] = getNotchFilter(obj(i).CenterFrequency,...
                                                    obj(i).CenterAttenuation,...
                                                    obj(i).SecondFrequency,...
                                                    obj(i).SecondAttenuation,...
                                                    obj(i).DCGain,...
                                                    obj(i).HFGain,...
                                                    obj(i).Units);
                    case 4
                        [A,B] = SecondOrderCF_Type1( obj(i).WF , obj(i).ZF ); %#ok<*PROP>
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                        end
                    case 5
                        [A,B] = SecondOrderCF_Type2( obj(i).WF , obj(i).ZF );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                        end
                    case 6
                        [A,B,C] = ThirdOrderCF_Type1( obj(i).WF , obj(i).ZF , obj(i).AF );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                        end
                    case 7
                        [A,B,C] = ThirdOrderCF_Type2( obj(i).WF , obj(i).ZF , obj(i).AF );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                        end
                    case 8
                        [A,B,C,D] = FourthOrderCF_Type1( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                    case 9
                        [A,B,C,D] = FourthOrderCF_Type2( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                    case 10
                        [A,B,C,D] = FourthOrderCF_Type3( obj(i).WF1 , obj(i).ZF1 , obj(i).WF2 , obj(i).ZF2 );
                        if ~isempty(obj(i).A) && ~isempty(obj(i).B) && ~isempty(obj(i).C) && ~isempty(obj(i).D)
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).A,'Value',A);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).B,'Value',B);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).C,'Value',C);
                            param(end+1) = UserInterface.ControlDesign.Parameter('Name',obj(i).D,'Value',D);
                        end
                end
            end
        end % getFilterValues

        function setFilterValuesNan( obj ) % Nathan added
            for i = 1:length(obj)
                switch obj(i).Type
                    case 1
                        obj(i).Frequency = nan;
                        obj(i).Phase = nan;
                        obj(i).Gain = nan;
                    case 2
                        obj(i).FrequencyAtMaxPhase = nan;
                        obj(i).MaxPhase = nan;
                        obj(i).FrequencyAtMaxGain = nan;
                    case 3
                        obj(i).CenterFrequency = nan;
                        obj(i).CenterAttenuation = nan;
                        obj(i).SecondFrequency = nan;
                        obj(i).SecondAttenuation = nan;
                        obj(i).DCGain = nan;
                        obj(i).HFGain = nan;
                end
            end
        end % getFilterValues
        
        function setMappingProperty( obj , row , value )
            switch obj.Type
                case {1,2,3}
                    if row == 1
                        obj.Num = value;
                    else
                        obj.Den = value;
                    end     
                case {4,5}
                    if row == 1
                        obj.A = value;
                    else
                        obj.B = value;
                    end
                case {6,7}
                    if row == 1
                        obj.A = value;
                    elseif row == 2
                        obj.B = value;
                    else
                        obj.C = value;
                    end
                    
                case {8,9,10}
                    switch row
                        case 1
                        obj.A = value;
                        case 2
                            obj.B = value;
                        case 3
                            obj.C = value;
                        case 4
                            obj.D = value;
                    end
%                     obj.X1 = value;
%                     obj.X2 = value;
%                     obj.Z1 = value;
%                     obj.Z2 = value;
                    
            end  
        end % setMappingProperty
        
        function y = displayInRow( obj )
            y = {obj.Name; obj.DisplayString; obj.Units};
        end % displayInRow
        
        function y = displayParamsInTable( obj )
            switch obj.Type
                case {1}
                    if strcmp(obj.Units,'Hz')
                        y = {'Frequency (Hz)', obj.Frequency;...
                            'Phase (deg)',obj.Phase;...
                            'Gain (dB)',obj.Gain};
                        obj.CurrentPropertiesInUse = {'Frequency','Phase','Gain'};
                    else
                        y = {'Frequency (rad/s)', obj.Frequency;...
                            'Phase (deg)',obj.Phase;...
                            'Gain (dB)',obj.Gain};
                        obj.CurrentPropertiesInUse = {'Frequency','Phase','Gain'};
                    end
                case {2}
                    if strcmp(obj.Units,'Hz')
                        y = {'Frequency @ Max Phase (Hz)', obj.FrequencyAtMaxPhase;...
                            'Max Phase (deg)',obj.MaxPhase;...
                            'HF Gain (dB)',obj.HFGain;...
                            'Frequency @ Max Gain (Hz)',obj.FrequencyAtMaxGain};
                        obj.CurrentPropertiesInUse = {'FrequencyAtMaxPhase','MaxPhase','HFGain','FrequencyAtMaxGain'};
                    else
                        y = {'Frequency @ Max Phase (rad/s)', obj.FrequencyAtMaxPhase;...
                            'Max Phase (deg)',obj.MaxPhase;...
                            'HF Gain (dB)',obj.HFGain;...
                            'Frequency @ Max Gain (rad/s)',obj.FrequencyAtMaxGain};
                        obj.CurrentPropertiesInUse = {'FrequencyAtMaxPhase','MaxPhase','HFGain','FrequencyAtMaxGain'};
                    end
                case {3}
                    if strcmp(obj.Units,'Hz')
                        y = {'Center Frequency (Hz)', obj.CenterFrequency;...
                            'Center Attenuation (dB)',obj.CenterAttenuation;...
                            '2nd Frequency (Hz)',obj.SecondFrequency;...
                            '2nd Attenuation (dB)', obj.SecondAttenuation;...
                            'DC Gain (dB)',obj.DCGain;...
                            'HF Gain (dB)',obj.HFGain};
                        obj.CurrentPropertiesInUse = {'CenterFrequency','CenterAttenuation','SecondFrequency','SecondAttenuation','DCGain','HFGain'};
                    else
                        y = {'Center Frequency (rad/s)', obj.CenterFrequency;...
                            'Center Attenuation (dB)',obj.CenterAttenuation;...
                            '2nd Frequency (rad/s)',obj.SecondFrequency;...
                            '2nd Attenuation (dB)', obj.SecondAttenuation;...
                            'DC Gain (dB)',obj.DCGain;...
                            'HF Gain (dB)',obj.HFGain};
                        obj.CurrentPropertiesInUse = {'CenterFrequency','CenterAttenuation','SecondFrequency','SecondAttenuation','DCGain','HFGain'};
                    end
                case {4,5}
                    if strcmp(obj.Units,'Hz')
                        y = {'WF', obj.WF;...
                            'ZF',obj.ZF};
                        obj.CurrentPropertiesInUse = {'WF','ZF'};
                    else
                        y = {'WF', obj.WF;...
                            'ZF',obj.ZF};
                        obj.CurrentPropertiesInUse = {'WF','ZF'};
                    end
                case {6,7}
                    if strcmp(obj.Units,'Hz')
                        y = {'WF', obj.WF;...
                            'ZF',obj.ZF;...
                            'AF',obj.AF};
                        obj.CurrentPropertiesInUse = {'WF','ZF','AF'};
                    else
                        y = {'WF', obj.WF;...
                            'ZF',obj.ZF;...
                            'AF',obj.AF};
                        obj.CurrentPropertiesInUse = {'WF','ZF','AF'};
                    end
                case {8,9,10}
                    if strcmp(obj.Units,'Hz')
                        y = {'WF1', obj.WF1;...
                            'ZF1',obj.ZF1;...
                            'WF2', obj.WF2;...
                            'ZF2',obj.ZF2};
                        obj.CurrentPropertiesInUse = {'WF1','ZF1','WF2','ZF2'};
                    else
                        y = {'WF1', obj.WF1;...
                            'ZF1',obj.ZF1;...
                            'WF2', obj.WF2;...
                            'ZF2',obj.ZF2};
                        obj.CurrentPropertiesInUse = {'WF1','ZF1','WF2','ZF2'};
                    end
            end
        end % displayParamsInTable
        
        function y = displayMapInTable( obj )
            switch obj.Type
                case {1,2,3}
                    y = {'Numerator (TF)', obj.Num;...
                        'Denominator (TF)',obj.Den};       
                case {4,5}
                    y = {'A', obj.A;...
                        'B',obj.B};
                    
                case {6,7}
                    y = {'A', obj.A;...
                        'B',obj.B;...
                        'C',obj.C};
                    
                case {8,9,10}
                    y = {'A', obj.A;...
                        'B',obj.B;...
                        'C',obj.C;...
                        'D',obj.D};%;...
%                         'X1',obj.X1;...
%                         'X2',obj.X2;...
%                         'Z1',obj.Z1;...
%                         'Z2',obj.Z2};
                    
            end
        end % displayMapInTable
        
        function defaultMinMax( obj )
            if obj.SliderEnable
                value = obj.Value;
                obj.Max = value + (abs(value) * 0.5);
                obj.Min = value - (abs(value) * 0.5);
            else
                obj.Max = 1;
                obj.Min = 0;  
            end
        end % defaultMinMax
        
        function y = sort( obj )
            [~,I] = sort({obj.Name});
            y = obj(I);
        end % sort
        
        function plot( obj , parent)

            switch obj.Type
                case {1,2,3}
                    [num,den] = getFilterValues( obj );
                    assert(~isempty(num) || ~isempty(den),'Filter:Plot:MissingValues','The filter you are trying to plot has empty values or empty mapping variables.' )
                    
                    H_Filter = tf(num,den);
                case 4

                case 5

                case 6

                case 7

                case 8

                case 9
           
                case 10

            end  
            
            if nargin == 1
                parent= figure;   
            end
            axH(1) = axes('Parent',parent,'Units','Normal','OuterPosition',[0,0.5,0.5,0.5]);
            axH(2) = axes('Parent',parent,'Units','Normal','OuterPosition',[0,0,0.5,0.5]);
            axH(3) = axes('Parent',parent,'Units','Normal','OuterPosition',[0.5,0.5,0.5,0.5]);
            axH(4) = axes('Parent',parent,'Units','Normal','OuterPosition',[0.5,0,0.5,0.5]);
            H_Final      = tf(1,1);
            
            H_Final   = H_Final * H_Filter;
            [Hst] = UserInterface.ControlDesign.Utilities.getTfString(H_Filter);
            FigureTitle = obj.Name;

            Hstf = ['$$' Hst '$$'];

            wHz  = unique(logspace(-2,2,10000));
            if strcmp(obj.Units,'Hz')
                wRad = wHz*2*pi;
            else
                wRad = wHz;
            end
            [HFR] = freqresp(H_Final,wRad);
            HFRs  = squeeze(HFR);
            magdB = 20*log10(abs(HFRs));
            phaseDeg = angle(HFRs)*(180/pi);

            % Bode
            semilogx(axH(1),wHz,magdB);
            grid(axH(1),'on');
            if strcmp(obj.Units,'Hz')
                xlabel(axH(1),['Frequency (Hz)']);
            else
                xlabel(axH(1),['Frequency (rad/s)']);
            end
            ylabel(axH(1),'Gain (dB)');

            semilogx(axH(2),wHz,phaseDeg);
            grid(axH(2),'on');
            if strcmp(obj.Units,'Hz')
                xlabel(axH(2),['Frequency (Hz)']);
                ylabel(axH(2),'Phase (deg)'); 
            else
                xlabel(axH(2),['Frequency (rad/s)']);
                ylabel(axH(2),'Phase (deg)'); 
            end

            %Nichols
            plot(axH(3),phaseDeg,magdB);

            grid(axH(3),'on');
            if strcmp(obj.Units,'Hz')
                xlabel(axH(3),'Phase (deg)');
            else
                xlabel(axH(3),'Phase (deg)');
            end
            ylabel(axH(3),'Magnutude (dB)');

            %Pz Map
            [P,Z] = pzmap(H_Final);

			line(real(P),imag(P),'Parent',axH(4),'Marker','x','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',12,'LineStyle','none','LineWidth',2);
            line(real(Z),imag(Z),'Parent',axH(4),'Marker','o','MarkerEdgeColor','b','MarkerSize',10,'LineStyle','none','LineWidth',2);
            xlabel(axH(4),'Real Part');
            ylabel(axH(4),'Imaginary Part');

            maxFreq = max(abs([P;Z]));
            xlim(axH(4),[-maxFreq-5,0]);
            ylim(axH(4),[0,maxFreq+5]);

%                     maxFreq = str2num(MaxFreqLim);
%                     xlim(axH(4),[-maxFreq,0]);
%                     ylim(axH(4),[0,maxFreq]);

            axes(axH(4));
            sgrid([0:0.1:1],[0:round(maxFreq/10):maxFreq*2]);
        end % plot
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)     
        
        function update(obj)

        end

        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Tree object
            %cpObj.Tree = copy(obj.Tree);
        end
        
    end


    %% Methods - Static
    methods(Static)
    end % Methods - Static
end % Filter

function [A,B,C,D] = FourthOrderCF_Type1( wf1 , zf1 , wf2 , zf2 )

        % Type 1 4th order CF U and UDot as inputs and Y, YD as output 
         x1 = 2*zf1*wf1; z1 = wf1^2;x2 = 2*zf2*wf2; z2 = wf2^2;
         A = (x1+x2); B = (z1+z2+x1*x2); C = (x1*z2+z1*x2); D = z1*z2;
         % Denominator transfer function = (s^2 2*zf1*wf1*s wf1^2)*(s^2 2*zf2*wf2*s wf2^2)
end % FourthOrderCF_Type1

function [A,B,C,D] = FourthOrderCF_Type2( wf1 , zf1 , wf2 , zf2 )

         % Type 2 4th order CF U and UDot as inputs and Y, YD as output 
         x1 = 2*zf1*wf1; z1 = wf1^2;x2 = 2*zf2*wf2; z2 = wf2^2;
         A = (x1+x2); B = (z1+z2+x1*x2); C = (x1*z2+z1*x2); D = z1*z2;
         % Denominator transfer function = (s^2 2*zf1*wf1*s wf1^2)*(s^2 2*zf2*wf2*s wf2^2)

end % FourthOrderCF_Type2

function [A,B,C,D] = FourthOrderCF_Type3( wf1 , zf1 , wf2 , zf2 )

         % Type 3 4th order CF U and UDot as inputs and Y, YD as output  
         x1 = 2*zf1*wf1; z1 = wf1^2;x2 = 2*zf2*wf2; z2 = wf2^2;
         A = (x1+x2); B = (z1+z2+x1*x2); C = (x1*z2+z1*x2); D = z1*z2;
         % Denominator transfer function = (s^2 2*zf1*wf1*s wf1^2)*(s^2 2*zf2*wf2*s wf2^2)
end % FourthOrderCF_Type3

function [NUM,DEN] = getLLFilter1stOrder1(Freq,Phase,FreqUnits)

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
%H_LL1 = K*tf([1 z],[1 p]);
NUM = K*[1 z];
DEN =   [1 p];
end % getLLFilter1stOrder1

function [NUM,DEN] = getLLFilter1stOrder2(Freq,Phase,Gain,FreqUnits)
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
    %H_LL1 = tf([a*t 1],[t 1]);
    NUM = [a*t,1];
    DEN = [t,1];
    %Valid = true;
else
    %Valid = false;
    %H_LL1 = [];
    NUM = [];
    DEN = [];
    errordlg('Lead/Lag Filter for user supplied Freq, Phase, and Gain combination is not realizable.');
end

end % getLLFilter1stOrder2

function [NUM,DEN] = getLLFilter2ndOrder1(FreqPMax,PhaseMax,HFGain,FreqUnits)
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
    %H_LL2 = tf([1/wz^2 2*zetac/wz 1],[1/wp^2 2*zetac/wp 1]);
    NUM = [1/wz^2 2*zetac/wz 1];
    DEN = [1/wp^2 2*zetac/wp 1];
else
    NUM = [];
    DEN = [];
    %H_LL2 = [];
end

Valid = EXITFLAG;

end % getLLFilter2ndOrder1

function [NUM2LL,DEN2LL] = getLLFilter2ndOrder2(FreqPMax,PhaseMax,HFGain,FreqGMax,FreqUnits)

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
% sys2LL(i,:) = tf(num2(i,:),den2(i,:));
NUM2LL = num2(i,:);
DEN2LL = den2(i,:);
end % getLLFilter2ndOrder2

function [NUM,DEN] = getNotchFilter(CenterFreq,CenterAttn,Freq2,Attn2,DCGain,HFGain,FreqUnits)
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
        [x,~,EXITFLAG] = fminsearch(@(x) optNotch(x,k_0,CenterFreq*2*pi,10^(CenterAttn/20),Freq22*2*pi,k_dc,10^(HFGain/20)),[zeta_num0,zeta_den0,omega_c0,k_hf,1],options);
    else
        [x,~,EXITFLAG] = fminsearch(@(x) optNotch(x,k_0,CenterFreq,10^(CenterAttn/20),Freq2,k_dc,10^(HFGain/20)),[zeta_num0,zeta_den0,omega_c0,k_hf,1],options);
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
    %H_Notch = tf(k_0*[anum 2*zeta_num*omega_c omega_c^2],[aden 2*zeta_den*omega_c omega_c^2]);
    NUM = k_0*[anum 2*zeta_num*omega_c omega_c^2];
    DEN = [aden 2*zeta_den*omega_c omega_c^2];
else
    NUM = [];
    DEN = [];
    %H_Notch = [];
end

end % getNotchFilter

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

end % optLL2ndOrder

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
end % optNotch

function [A,B] = SecondOrderCF_Type1( wf , zf )


    % Type 1 2nd order CF U and UDDot as inputs and Y, YD as output 
    A = (2*zf*wf); B = (wf^2); 
     % Denominator transfer function = (s^2 2*zf*wf*s wf^2)
end % SecondOrderCF_Type1

function [A,B] = SecondOrderCF_Type2( wf , zf )


 % Typ 2 U 2nd order CF and UDDot as inputs and Y, YD as output 
A = (2*zf*wf); B = (wf^2); 
 % Denominator transfer function = (s^2 2*zf*wf*s wf^2)

end % SecondOrderCF_Type2

function [A,B,C] = ThirdOrderCF_Type1( wf , zf , af )

    % Type 1 3rd order CF U and UDot as inputs and Y, YD as output 
    A = (2*zf*wf+af); B = (wf^2+2*zf*wf*af); C = (af*wf^2); 
     % Denominator transfer function = (s^2 2*zf*wf*s wf^2)*(s+af)

end % ThirdOrderCF_Type1

function [A,B,C] = ThirdOrderCF_Type2( wf , zf , af )

     % Typ 2 U 3rd order CF and UDot as inputs and Y, YD as output 
    A = (2*zf*wf+af); B = (wf^2+2*zf*wf*af); C = (af*wf^2); 
     % Denominator transfer function = (s^2 2*zf*wf*s wf^2)*(s+af)
 
end % ThirdOrderCF_Type2
