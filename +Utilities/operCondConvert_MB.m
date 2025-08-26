function allOperCond = operCondConvert_MB( dir, type, ocLabel )
% Convert Mitsubishi models to an operating condition class


    allFilesofType = Utilities.subdir(fullfile(dir,['*.',type]));

    % Initialize opercond array
    allOperCond(size(allFilesofType)) = lacm.OperatingCondition;
    

    for i = 1:length(allFilesofType)
    
        % run m file
        run(allFilesofType(i).name);
        
        allOperCond(i).Label = ocLabel;
        
        % Create linear models
        [ABARE,BBARE,CBARE,DBARE] = lin_ac_ss_lon(ET,AT,BT,Q,THT,PHI,GAM,ALP,BET,VTAS,RM,HFT,CG,YCG,ZCG);

        allOperCond(i).LinearModel = lacm.LinearModel('Label','lon','A',ABARE,'B',BBARE,'C',CBARE,'D',DBARE);

        [ABARE,BBARE,CBARE,DBARE] = lin_ac_ss_lat(EY,AY,BY,THT,PHI,ALP,BET,VTAS,CG,YCG,ZCG);

        allOperCond(i).LinearModel(end+1) = lacm.LinearModel('Label','lat','A',ABARE,'B',BBARE,'C',CBARE,'D',DBARE);

        % Create MassProperites
        if W > 34000 && CG > 20
            label = 'AH';
        elseif W > 34000 && CG <= 20
            label = 'FH';
        elseif W <= 34000 && CG > 20
            label = 'AL';
        elseif W <= 34000 && CG <= 20
            label = 'FL';
        end
        weightParameters = lacm.Condition.empty;
        weightParameters(1) = lacm.Condition('W',W);
        weightParameters(2) = lacm.Condition('CG',CG);
        weightParameters(3) = lacm.Condition('XCG',XCG);
        weightParameters(4) = lacm.Condition('ZCG',ZCG);
        weightParameters(5) = lacm.Condition('YCG',YCG);
        weightParameters(5) = lacm.Condition('IXX',7865.156);
        weightParameters(5) = lacm.Condition('IYY',21629.081);
        weightParameters(5) = lacm.Condition('IZZ',26614.525);
        weightParameters(5) = lacm.Condition('IXZ',2320.482);
        allOperCond(i).MassProperties = lacm.MassProperties('Label',label,...
                                    'WeightCode','',...
                                    'Parameter',weightParameters);
    
        % Create FlightCondition

        allOperCond(i).FlightCondition = lacm.FlightCondition('Mach',RM,...
                                    'Alt',HFT,...
                                    'Qbar',QBAR/4.8824,...
                                    'KCAS',VKCAS,...
                                    'TAS',VTAS*3.28084);
                                
        InputParameters = lacm.Condition.empty;
        InputParameters(1) = lacm.Condition('ALP',ALP);
        InputParameters(2) = lacm.Condition('BET',BET);
        InputParameters(3) = lacm.Condition('ALPH',ALPH);
        InputParameters(4) = lacm.Condition('GAM',GAM);
        InputParameters(5) = lacm.Condition('THT',THT);      
        InputParameters(6) = lacm.Condition('PHI',PHI);   
        InputParameters(7) = lacm.Condition('PSI',PSI); 
        InputParameters(8) = lacm.Condition('NX',NX); 
        InputParameters(9) = lacm.Condition('NY',NY); 
        InputParameters(10) = lacm.Condition('NZ',NZ); 
        InputParameters(11) = lacm.Condition('P',P); 
        InputParameters(12) = lacm.Condition('Q',Q); 
        InputParameters(13) = lacm.Condition('R',R); 
        InputParameters(14) = lacm.Condition('Thr_L',Thr_L); 
        InputParameters(15) = lacm.Condition('Thr_R',Thr_R); 
        InputParameters(16) = lacm.Condition('DeL',DeL); 
        InputParameters(17) = lacm.Condition('DeR',DeR); 
        InputParameters(18) = lacm.Condition('DaL',DaL); 
        InputParameters(19) = lacm.Condition('DaR',DaR); 
        InputParameters(20) = lacm.Condition('Dsp1',Dsp1); 
        InputParameters(21) = lacm.Condition('Dsp2',Dsp2); 
        InputParameters(22) = lacm.Condition('Dsp3',Dsp3); 
        InputParameters(23) = lacm.Condition('Dsp4',Dsp4); 
        InputParameters(24) = lacm.Condition('Dsp5',Dsp5); 
        InputParameters(25) = lacm.Condition('Dsp6',Dsp6); 
        InputParameters(26) = lacm.Condition('Dsp7',Dsp7); 
        InputParameters(27) = lacm.Condition('Dsp8',Dsp8); 
        InputParameters(28) = lacm.Condition('Dsp9',Dsp9); 
        InputParameters(29) = lacm.Condition('Dsp10',Dsp10); 
        InputParameters(30) = lacm.Condition('Dr',Dr); 
        InputParameters(31) = lacm.Condition('TLA_L',TLA_L); 
        InputParameters(32) = lacm.Condition('TLA_R',TLA_R); 
        InputParameters(33) = lacm.Condition('Se',Se); 
        InputParameters(34) = lacm.Condition('Sa',Sa); 
        InputParameters(35) = lacm.Condition('Sr',Sr); 
        InputParameters(36) = lacm.Condition('CNa',CNa); 
        InputParameters(37) = lacm.Condition('Cmde',Cmde); 
        InputParameters(38) = lacm.Condition('W',W); 
        InputParameters(39) = lacm.Condition('CG',CG); 
        InputParameters(40) = lacm.Condition('FLAP',FLAP); 
        InputParameters(41) = lacm.Condition('XCG',XCG); 
        InputParameters(42) = lacm.Condition('ZCG',ZCG); 
        InputParameters(43) = lacm.Condition('YCG',YCG); 
        InputParameters(44) = lacm.Condition('HFT',HFT); 
        InputParameters(45) = lacm.Condition('VKEAS',VKEAS); 
        InputParameters(46) = lacm.Condition('RM',RM); 
        InputParameters(47) = lacm.Condition('Mach',RM); 
        InputParameters(48) = lacm.Condition('Alt',HFT); 
        InputParameters(49) = lacm.Condition('Qbar',QBAR/4.8824); 
        InputParameters(50) = lacm.Condition('KCAS',VKCAS); 
        InputParameters(51) = lacm.Condition('TAS',VTAS*3.28084); 
        InputParameters(52) = lacm.Condition('IXX',7865.156); 
        InputParameters(53) = lacm.Condition('IYY',21629.081); 
        InputParameters(54) = lacm.Condition('IZZ',26614.525); 
        InputParameters(55) = lacm.Condition('IXZ',2320.482); 
                                 
        allOperCond(i).Inputs = InputParameters;
    
    end


end