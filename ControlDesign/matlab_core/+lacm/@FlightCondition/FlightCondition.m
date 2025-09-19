classdef FlightCondition < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties 

    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        Mach double
        Qbar double
        Alt double
        KCAS double
        KEAS double

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        TAS double  % ft/s
        SimulationUnits = 'English - US'
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        KTAS
    end % Dependant properties
    
    %% Hidden Dependant properties
    properties (Dependent = true, SetAccess = private, Hidden = true)
        FltCond4Sim
        SimUnitConversionFactor
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = FlightCondition(varargin)
            switch nargin
                case 0            
                case 4
                    p = inputParser;
                    errorStr = 'Value must be scalar and numeric.';
                    validationFcn = @(x) assert(isnumeric(x) && isscalar(x) ,errorStr);
                    addParameter(p,'Mach',[],validationFcn);
                    addParameter(p,'Qbar',[],validationFcn);
                    addParameter(p,'Alt',[],validationFcn);
                    addParameter(p,'KCAS',[],validationFcn);
                    addParameter(p,'KTAS',[],validationFcn);
                    addParameter(p,'KEAS',[],validationFcn);
                    
                    p.KeepUnmatched = true;
                    parse(p,varargin{:});
                    options = p.Results;
                    
                    
                    if isempty(setdiff(p.UsingDefaults,{'KCAS','Alt','KTAS','KEAS'}))
                        obj.Mach = options.Mach;
                        obj.Qbar = options.Qbar;
                        compute4MachQbar(obj);  
                    elseif isempty(setdiff(p.UsingDefaults,{'Qbar','Alt','KTAS','KEAS'}))
                        obj.Mach = options.Mach;
                        obj.KCAS = options.KCAS;
                        compute4MachKCAS(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Qbar','KCAS','KTAS','KEAS'}))
                        obj.Mach = options.Mach;
                        obj.Alt = options.Alt;
                        compute4MachAlt(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Mach','Alt','KTAS','KEAS'}))
                        obj.Qbar = options.Qbar;
                        obj.KCAS = options.KCAS;
                        compute4KCASQbar(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Mach','Qbar','KTAS','KEAS'}))
                        obj.Alt = options.Alt;
                        obj.KCAS = options.KCAS;
                        compute4KCASAlt(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Mach','KCAS','KTAS','KEAS'}))
                        obj.Qbar = options.Qbar;
                        obj.Alt = options.Alt;
                        compute4QbarAlt(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Mach','KCAS','Qbar','KEAS'}))
                        obj.TAS = options.KTAS*(463/900)/0.3048;
                        obj.Alt = options.Alt;
                        compute4KTASAlt(obj);
                        
                    elseif isempty(setdiff(p.UsingDefaults,{'Qbar','Alt','KTAS','Mach'}))
                        obj.KEAS = options.KEAS;
                        obj.KCAS = options.KCAS;
                        compute4KEASKCAS(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Qbar','KCAS','KTAS','Mach'}))
                        obj.KEAS = options.KEAS;
                        obj.Alt = options.Alt;
                        compute4KEASAlt(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'KCAS','Alt','KTAS','Qbar'}))
                        obj.KEAS = options.KEAS;
                        obj.Mach = options.Mach;
                        compute4KEASMach(obj);
                    elseif isempty(setdiff(p.UsingDefaults,{'Mach','Alt','KTAS','KCAS'}))
                        obj.KEAS = options.KEAS;
                        obj.Qbar = options.Qbar;
                        compute4KEASQbar(obj);

                    else
                        error('Incorrect input arguments.');
                    end

                case 12
                    p = inputParser;
                    errorStr = 'Value must be scalar and numeric.';
                    validationFcn = @(x) assert(isnumeric(x) && isscalar(x) ,errorStr);
                    addParameter(p,'Mach',[],validationFcn);
                    addParameter(p,'Qbar',[],validationFcn);
                    addParameter(p,'Alt',[],validationFcn);
                    addParameter(p,'KCAS',[],validationFcn);
                    addParameter(p,'TAS',[],validationFcn);
                    addParameter(p,'KEAS',[],validationFcn);
                    
                    p.KeepUnmatched = true;
                    parse(p,varargin{:});
                    options = p.Results;
                    
                    obj.Mach = options.Mach;
                    obj.Qbar = options.Qbar;
                    obj.KCAS = options.KCAS;
                    obj.KEAS = options.KEAS;
                    obj.Alt = options.Alt;
                    obj.TAS = options.TAS;
                otherwise
                    error('Incorrect number of input arguments');
            end
            
        end % FlightCondition
    end % Constructor

    %% Methods - Property Access
    methods       
        function set.SimulationUnits( obj , units )
            obj.SimulationUnits = units;
        end % SimulationUnits
        
        function y = get.FltCond4Sim(obj)
            xecef =  (20925646.3572663 + obj.Alt) * obj.SimUnitConversionFactor;
            xecefCond = lacm.Condition('xecef',xecef);
            
            alt   = obj.Alt * obj.SimUnitConversionFactor;
            altCond= lacm.Condition('alt',alt);
            
            v = obj.TAS * obj.SimUnitConversionFactor;
            vCond = lacm.Condition('V',v);
            
            y = [xecefCond,altCond,vCond];
        end % FltCond4Sim
        
        function y = get.SimUnitConversionFactor(obj)
            if strcmpi('SI',obj.SimulationUnits)
                y = 0.3048;
            else
               y = 1; 
            end
        end % SimUnitConversionFactor      
        
        function y = get.KTAS( obj )
            y = obj.TAS * (3600/(1852/0.3048));
        end % KTAS
        
        function y = get.KEAS( obj )
            if isempty(obj.KEAS)
                ps0  = 14.695949;
                a0   = 340.294124355681/0.3048;

                mach = obj.Mach;
                alt  = obj.Alt;

                [~, ~, ps, ~] = atmosisa(alt*0.3048);
                ps = (14.695949/101325)*ps;      
                y = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));
            else
                y = obj.KEAS;
            end
        end % KEAS
   
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
        function dispData = getDisplayData(obj)
            
            propNames = properties(obj);
            dispData = cell(length(propNames),2);
            for i = 1:length(propNames)
                dispData{i,1} = propNames{i};
                if isscalar(obj.(propNames{i})) 
                    if ~ischar(obj.(propNames{i}))  
                        dispData{i,2} = num2str(obj.(propNames{i}),4);
                    else
                        dispData{i,2} = obj.(propNames{i});
                    end
                else
                    dispData{i,2} = class(obj.(propNames{i}));
                end
                
            end    
        end % getDisplayData       
        
        function data = getTableData(obj)
            data = {obj.Alt;...
                    obj.KCAS;...
                    obj.KEAS;...
                    obj.KTAS;...
                    obj.Mach;...
                    obj.Qbar};
        end % getTableData
        
        function compute4MachQbar(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;

            mach = obj.Mach;
            qbar = obj.Qbar;

            alt = fminsearch(@(x) getAltCostMQ(x,mach,qbar),60000);

            [~, a, ps, ~] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            %rho = rho*(1/14.5939029372*0.3048^3);

            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));

            V=mach*a;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));

            obj.Alt  = alt;
            obj.TAS  = V;
            obj.Qbar = qbar;
            obj.KCAS = kcas;
            obj.KEAS = keas;
        end % compute4MachQbar
        
        function compute4MachKCAS(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            mach = obj.Mach;
            kcas = obj.KCAS;

            %ps  = fzero(@(ps) sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048))-kcas,10);
            ps  = fzero(@(ps) (a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048)))-kcas,10);
            
            alt = fzero(@(x) getAltCostPs(x,ps),60000);

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            
            V=mach*a;
            qbar=0.5*rho*V^2;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));

            obj.Alt  = alt;
            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.Qbar = qbar;
            obj.KEAS = keas;
        end % compute4MachKCAS

        function compute4MachAlt(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            mach = obj.Mach;
            alt  = obj.Alt;

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            V=mach*a;
            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            qbar=0.5*rho*V^2;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));

            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.Qbar = qbar;
            obj.Alt  = alt;
            obj.KEAS = keas;
        end % compute4MachAlt
        
        
        function compute4KTASAlt(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            V = obj.TAS;
            alt  = obj.Alt;

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            mach = V/a;
            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            qbar=0.5*rho*V^2;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));
            
            obj.Mach = mach;
            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.Qbar = qbar;
            obj.Alt  = alt;
            obj.KEAS = keas;

        end % compute4MachAlt

        function compute4KCASQbar(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            kcas = obj.KCAS;
            qbar = obj.Qbar;

            alt = fzero(@(x) getAltCostKQ(x,kcas,qbar,ps0,a0),60000);

            [~, a, ~, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            rho = rho*(1/14.5939029372*0.3048^3);

            V = sqrt(2*qbar/rho);
            mach = V/a;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));

            obj.Alt = alt;
            obj.TAS = V;
            obj.Mach = mach;
            obj.KEAS = keas;

        end % compute4KCASQbar
        
        function compute4KCASAlt(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            alt = obj.Alt;
            kcas= obj.KCAS;

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            %mach = fzero(@(x) sqrt((((((0.2*x.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048))-kcas,1);
            mach = fzero(@(x) (a0 * x * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*x^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*x^4) *(3600/(1852/0.3048)))-kcas,1);
            
            V=mach*a;
            qbar=0.5*rho*V^2;
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));

            obj.Alt  = alt;
            obj.Mach = mach;
            obj.TAS  = V;
            obj.Qbar = qbar;
            obj.KEAS = keas;
        end % compute4KCASAlt
        
        function compute4QbarAlt(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            alt = obj.Alt;
            qbar= obj.Qbar;

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            V = sqrt(2*qbar/rho);
            mach = V/a;
            %kcas = sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            
            keas = a0*mach*sqrt(ps/ps0)*(3600/(1852/0.3048));
            
            obj.Alt  = alt;
            obj.Mach = mach;
            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.KEAS = keas;
        end % compute4QbarAlt
        
        function compute4KEASAlt(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            veas = obj.KEAS/(3600/(1852/0.3048));
            alt  = obj.Alt;

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);
            
            mach = veas/a0/sqrt(ps/ps0);
            

            V=mach*a;
            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            qbar=0.5*rho*V^2;
            

            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.Qbar = qbar;
            obj.Mach = mach;

        end % compute4KEASAlt
        
        function compute4KEASMach(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            veas = obj.KEAS/(3600/(1852/0.3048));
            mach = obj.Mach;
            
            ps = ps0*(veas/a0/mach)^2;
            
            alt = fzero(@(x) getAltCostPs(x,ps),60000);

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            %kcas=sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
            
            V=mach*a;
            qbar=0.5*rho*V^2;
            
            
            obj.TAS  = V;
            obj.KCAS = kcas;
            obj.Qbar = qbar;
            obj.Alt = alt;
        end % compute4KEASAlt
        
        function compute4KEASKCAS(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            veas = obj.KEAS/(3600/(1852/0.3048));
            vcas = obj.KCAS/(3600/(1852/0.3048));
            
            qc = ps0*((((vcas/a0)^2)/5 + 1)^(7/2) - 1);
            
            ps = fzero(@(x) a0*sqrt(5*((qc/x + 1)^(2/7) - 1))*sqrt(x/ps0)-veas,ps0);
            
            alt = fzero(@(x) getAltCostPs(x,ps),60000);

            [~, a, ps, rho] = atmosisa(alt*0.3048);
            a = a/0.3048;
            ps = (14.695949/101325)*ps;
            rho = rho*(1/14.5939029372*0.3048^3);

            mach = sqrt(5*((qc/ps + 1)^(2/7) - 1));
            
            V=mach*a;
            qbar=0.5*rho*V^2;
            
            
            obj.TAS  = V;
            obj.Mach = mach;
            obj.Qbar = qbar;
            obj.Alt  = alt;
            
        end % compute4KEASKCAS
        
        function compute4KEASQbar(obj)
            ps0  = 14.695949;
            a0   = 340.294124355681/0.3048;
            
            veas = obj.KEAS/(3600/(1852/0.3048));
            qbar = obj.Qbar/144; % psi
            
            
            ps = fzero(@(x) qbar*(1+(1/4)*(veas/a0/(sqrt(x/ps0)))^2+(1/40)*(veas/a0/(sqrt(x/ps0)))^4+(1/80)*(veas/a0/(sqrt(x/ps0)))^8)-x*((1+0.2*(veas/a0/(sqrt(x/ps0)))^2)^(7/2)-1),ps0);
            
            
           alt = fzero(@(x) getAltCostPs(x,ps),60000);

            [~, a, ps, ~] = atmosisa(alt*0.3048);
       
            ps = (14.695949/101325)*ps;
          

            mach = sqrt(5*((qc/ps + 1)^(2/7) - 1));
            
            V=mach*a;
            
            kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
             
            
            obj.TAS  = V;
            obj.Mach = mach;
            obj.KCAS = kcas;
            obj.Alt  = alt;
            
        end % compute4KEASQbar
        
        function y = eq(A,B)
               
            if length(A) == length(B)
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).Mach == B(i).Mach && ...
                            A(i).Qbar == B(i).Qbar && ...
                            A(i).Alt == B(i).Alt && ...
                            A(i).KCAS == B(i).KCAS && ...
                            A(i).TAS == B(i).TAS && ...
                            A(i).KEAS == B(i).KEAS
                        y(i) = true;
                    else
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                y = false(1,length(B));
                for i = 1:length(B)
                    if A.Mach == B(i).Mach && ...
                        A.Qbar == B(i).Qbar && ...
                        A.Alt == B(i).Alt && ...
                        A.KCAS == B(i).KCAS && ...
                        A.TAS == B(i).TAS && ...
                        A.KEAS == B(i).KEAS
                    
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end
            elseif length(A) > 1 && length(B) == 1
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).Mach == B.Mach && ...
                        A(i).Qbar == B.Qbar && ...
                        A(i).Alt == B.Alt && ...
                        A(i).KCAS == B.KCAS && ...
                        A(i).TAS == B.TAS && ...
                        A(i).KEAS == B.KEAS
                    
                        y(i) = true;
                    else
                        y(i) = false;
                    end  
                end 
            else
                y = false;
            end
        end % eq
        
        function setUnits( obj , units )
            
        end % setUnits
        
    end % Ordinary Methods
    
    %% Methods - Protected
    methods (Access = protected)       

    end
    
        %% Methods - Static
    methods (Static)
        function data = getHeaderData()          
%             data = {'Flight Condition','Mach','-';...
%                     'Flight Condition','Qbar','psf';...
%                     'Flight Condition','Alt','ft';...
%                     'Flight Condition','KCAS','knots';...
%                     'Flight Condition','TAS','ft/s'};
            type = {'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition'};
            names = {'Mach';...
                    'Qbar';...
                    'Alt';...
                    'KCAS';...
                    'KTAS';...
                    'KEAS'};
            units = {'-';...
                    'psf';...
                    'ft';...
                    'knots';...
                    'knots';...
                    'knots'}; 
            [ names , I ] = sort(names);
            units = units(I); 
            data = [type,names,units];
             
        end % getHeaderData
                
        function data = getStructHeader()          
            type = {'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition';...
                    'Flight Condition'};
            names = {'Mach';...
                    'Qbar';...
                    'Alt';...
                    'KCAS';...
                    'KTAS';...
                    'KEAS'};
            units = {'-';...
                    'psf';...
                    'ft';...
                    'knots';...
                    'knots';...
                    'knots'};
            [ names , I ] = sort(names);
            units = units(I);
            data = struct('Type',type,'Name',names,'Units',units);
        end % getHeaderData        
    end
end

function [T, a, P, rho] = atmosisa( h )
%  ATMOSISA Use International Standard Atmosphere Model.
%   [T, A, P, RHO] = ATMOSISA(H) implements the mathematical representation
%   of the International Standard Atmosphere values for ambient temperature, 
%   pressure, density, and speed of sound for the input geopotential altitude. 
%
%   Input required by ATMOSISA is:
%   H      :a numeric array of M geopotential height in meters. 
%
%   Output calculated for the International Standard Atmosphere are: 
%   T      :a numeric array of M temperature in kelvin.
%   a      :a numeric array of M speed of sound in meters per second.
%   P      :a numeric array of M air pressure in pascal.
%   rho    :a numeric array of M air density in kilograms per meter cubed.
%
%   Limitation: 
%
%   Below the geopotential altitude of 0 km and above the geopotential
%   altitude of the tropopause, temperature and pressure values are held.
%   Density and speed of sound are calculated using a perfect gas
%   relationship.
%
%   Examples:
%
%   Calculate the International Standard Atmosphere at 1000 meters:
%      [T, a, P, rho] = atmosisa(1000)
%
%   Calculate the International Standard Atmosphere at 1000, 11000 and 20000
%   meters:
%      [T, a, P, rho] = atmosisa([1000 11000 20000])
%
%   See also ATMOSCIRA, ATMOSCOESA, ATMOSLAPSE, ATMOSNONSTD.

%   Copyright 2000-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/03/05 15:41:59 $

%   Reference:  U.S. Standard Atmosphere, 1976, U.S. Government Printing 
%   Office, Washington, D.C.

[T, a, P, rho] = atmoslapse(h, 9.80665, 1.4, 287.0531, 0.0065, 11000, 20000, ...
    1.225, 101325, 288.15 );
end % atmosisa

function [T, a, P, rho] = atmoslapse(h, g, gamma, R, L, hts, htp, rho0, P0, T0 )
%  ATMOSLAPSE Use Lapse Rate Atmosphere Model.
%   [T, A, P, RHO] = ATMOSLAPSE(H, G, GAMMA, R, L, HTS, HTP, RHO0, P0, T0) 
%   implements the mathematical representation of the lapse rate atmospheric 
%   equations for ambient temperature, pressure, density, and speed of sound 
%   for the input geopotential altitude.  This atmospheric model is customizable
%   by specifying the atmospheric properties in the function input.
%
%   Inputs required by ATMOSLAPSE are:
%   H      :a numeric array of M geopotential height in meters. 
%   G      :a scalar of acceleration due to gravity in meters per second squared.
%   GAMMA  :a scalar of specific heat ratio.
%   R      :a scalar of characteristic gas constant joules per kilogram-kelvin.
%   L      :a scalar of lapse rate in kelvin per meter.
%   HTS    :a scalar of height of troposphere in meters.
%   HTP    :a scalar of height of tropopause in meters.
%   RHO0   :a scalar of air density at mean sea level in kilograms per meter cubed.
%   P0     :a scalar of static pressure at mean sea level in pascal.
%   T0     :a scalar of absolute temperature at mean sea level in kelvin.
%
%   Outputs calculated for the lapse rate atmosphere are: 
%   T      :a numeric array of M temperature in kelvin.
%   a      :a numeric array of M speed of sound in meters per second.
%   P      :a numeric array of M air pressure in pascal.
%   rho    :a numeric array of M air density in kilograms per meter cubed.
%
%   Limitation: 
%
%   Below the geopotential altitude of 0 km and above the geopotential
%   altitude of the tropopause, temperature and pressure values are held.
%   Density and speed of sound are calculated using a perfect gas
%   relationship.
%
%   Example:
%
%   Calculate the atmosphere at 1000 meters with the International Standard 
%   Atmosphere input values:
%      [T, a, P, rho] = atmoslapse(1000, 9.80665, 1.4, 287.0531, 0.0065, ...
%          11000, 20000, 1.225, 101325, 288.15 );
%
%   See also ATMOSCIRA, ATMOSCOESA, ATMOSISA, ATMOSNONSTD.

%   Copyright 2000-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/07 18:12:50 $

%   Reference:  U.S. Standard Atmosphere, 1976, U.S. Government Printing 
%   Office, Washington, D.C.

narginchk(10,10);

if ~(isscalar(g)&&isscalar(gamma)&&isscalar(R)&&isscalar(L)&&isscalar(hts) ...
     &&isscalar(htp)&&isscalar(rho0)&&isscalar(P0)&&isscalar(T0))
    error('aero:atmoslapse:nonscalar',...
                            'All inputs other than altitude must be scalars.');
end

if ~isnumeric( h )
    error('aero:atmoslapse:notnumeric','Height input was not a numeric value.');
end

for i = length(h): -1 :1
    if ( h(i) > htp )
        h(i) = htp;
    end

    if ( h(i) <  0 )
        h(i) = 0;
    end

    if ( h(i) > hts )
        T(i) = T0 - L*hts; %#ok mlint
        expon(i) = exp(g/(R*T(i))*(hts - h(i))); %#ok mlint
    else
        T(i) = T0 - L*h(i);  %#ok mlint
        expon(i) = 1.0;  %#ok mlint
    end
end

a = sqrt(T*gamma*R);

theta = T/T0;

P = P0*theta.^(g/(L*R)).*expon;
rho = rho0*theta.^((g/(L*R))-1.0).*expon;

end % atmoslapse

function [f] = getAltCostKQ(alt,kcast,qbart,ps0,a0)
    [~, a, ps, rho] = atmosisa(alt*0.3048);
    a = a/0.3048;
    ps = (14.695949/101325)*ps;
    rho = rho*(1/14.5939029372*0.3048^3);
    V = sqrt(2*qbart/rho);
    mach = V/a;
    %kcas = sqrt((((((0.2*mach.^2+1).^3.5)-1)*ps/14.696+1)^(1/3.5)-1)*5)*(1116.267*3600/(1852/0.3048));
    kcas = a0 * mach * sqrt(ps/ps0) * (1+(1/8)*(1-ps/ps0)*mach^2 + (3/640)*(1-10*(ps/ps0)+9*(ps/ps0)^2)*mach^4) *(3600/(1852/0.3048));
    f = (kcas-kcast);
end % getAltCostKQ

function [f] = getAltCostMQ(alt,macht,qbart)
    [~, a, ~, rho] = atmosisa(alt*0.3048);
    a = a/0.3048;
    rho = rho*(1/14.5939029372*0.3048^3);
    V = sqrt(2*qbart/rho);
    mach = V/a;
    if alt >= 0
        f = (mach-macht)^2;
    else
        f = (mach-macht)^2 + alt^2;
    end
end % getAltCostMQ

function [f] = getAltCostPs(alt,pst)
    [~, ~, ps, ~] = atmosisa(alt*0.3048);
    ps = (14.695949/101325)*ps;
    f = (ps-pst);
end % getAltCostPs

