classdef LinMdlRow < matlab.mixin.Copyable
    
    %% Public properties - Data Storage
    properties  
        Name
        Order = []
        ConstraintStr = ''
        PerturbSizeStr = ''
        PerturbSize = []
        PerturbType = 0
    end % Public properties
        
    %% Read-only properties
    properties %( GetAccess = public, SetAccess = private )
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true , GetAccess = public, SetAccess = private )

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
    end % Dependant properties

    %% Constant properties
    properties (Hidden = true, Constant) 
    end % Constant properties 
    
    %% Methods - Constructor
    methods      
        function obj = LinMdlRow( name , order, type, perturbSizeStr, ConstraintStr)
            switch nargin
                case 0
                case 1
                    obj.Name = name;
                    obj.Order = [];
                    obj.PerturbType = 0;
                    obj.PerturbSize = [];
                    obj.PerturbSizeStr = '';
                    obj.ConstraintStr = '';
                case 2
                    obj.Name = name;
                    obj.Order = order;
                    obj.PerturbType = 0;
                    obj.PerturbSize = [];
                    obj.PerturbSizeStr = '';
                    obj.ConstraintStr = '';
                case 3
                    obj.Name = name;
                    obj.Order = order;
                    
                    if strcmp(type,'input') || strcmp(type,'state')
                        obj.PerturbType = 0;
                        obj.PerturbSize = 1e-6;
                        obj.PerturbSizeStr = '1e-6';
                        obj.ConstraintStr = '';
                    else
                        obj.PerturbType = 0;
                        obj.PerturbSize = [];
                        obj.PerturbSizeStr = '';
                        obj.ConstraintStr = '';
                    end
                case 4
                    obj.Name = name;
                    obj.Order = order;
                    
                    if strcmp(type,'input') || strcmp(type,'state')
                        obj.PerturbSizeStr = perturbSizeStr;
                        obj.PerturbType = 0;
                        if contains(perturbSizeStr,'+')
                            obj.PerturbType = 1;
                            obj.PerturbSize = str2double(perturbSizeStr);
                        elseif contains(perturbSizeStr,'-')
                            obj.PerturbType = -1;
                            obj.PerturbSize = abs(str2double(perturbSizeStr));
                        end
                        
                        obj.ConstraintStr = '';
                    else
                        obj.PerturbType = 0;
                        obj.PerturbSize = [];
                        obj.PerturbSizeStr = '';
                        obj.ConstraintStr = '';
                    end
                case 5           
                    obj.Name = name;
                    obj.Order = order;
                    
                    if strcmp(type,'input') || strcmp(type,'state')
                        obj.PerturbSizeStr = perturbSizeStr;
                        obj.PerturbType = 0;
                        if contains(perturbSizeStr,'+')
                            obj.PerturbType = 1;
                            obj.PerturbSize = str2double(perturbSizeStr);
                        elseif contains(perturbSizeStr,'-')
                            obj.PerturbType = -1;
                            obj.PerturbSize = abs(str2double(perturbSizeStr));
                        end
                        obj.ConstraintStr = ConstraintStr;
                    else
                        obj.PerturbType = 0;
                        obj.PerturbSize = [];
                        obj.PerturbSizeStr = '';
                        obj.ConstraintStr = '';
                    end     
            end          
        end % LinMdlRow
    end % Constructor

    %% Methods - Property Access
    methods
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        function data = getAsTableData( obj , type)
            if isempty(obj) 
                data = [];
            else
                if strcmp(type,'input')
                    for i = 1:length(obj)
                        data(i,:) = {obj(i).Name , obj(i).Order, num2str(obj(i).PerturbSizeStr), obj(i).ConstraintStr};
                    end
                elseif strcmp(type,'state') || strcmp(type,'alginput')
                    for i = 1:length(obj)
                        data(i,:) = {obj(i).Name , obj(i).Order, num2str(obj(i).PerturbSizeStr)};
                    end
                elseif strcmp(type,'output')
                    for i = 1:length(obj)
                        data(i,:) = {obj(i).Name , obj(i).Order};
                    end
                end
            end
        end % getAsTableData
        
        function [names, varargout] = getSelectedNames( obj )
            if isempty(obj) 
                names = {};
                if nargout ==3
                    varargout{1} = [];
                    varargout{2} = [];
                elseif nargout == 5
                    varargout{1} = [];
                    varargout{2} = [];
                    varargout{3} = [];
                    varargout{4} = [];
                end       
            else
                
                k=0;
                order = [];
                sel = false(1,length(obj));
                tempnames = {};
                ConstraintsArray = [];
                ConstraintsInfo  = {};
                for i =1:length(obj)
                    orderi = obj(i).Order;
                    if ~isempty(orderi)
                        k=k+1;
                        tempnames{k}=obj(i).Name;
                        order = [order,orderi];
                        sel(i) = true;
                    end
                    
                    if ~isempty(obj(i).ConstraintStr)
                        InputIdx = i;
                        % check if there is a '-' sign
                        if contains(obj(i).ConstraintStr,'-')
                            temp = strrep(obj(i).ConstraintStr,'-','');
                            constIndex = -find(strcmp(temp,{obj.Name}));
                        else
                            temp = strrep(obj(i).ConstraintStr,'+','');
                            constIndex = find(strcmp(temp,{obj.Name}));
                        end
                        ConstraintsArray = [ConstraintsArray;[InputIdx,constIndex]];
                        
                        ConstraintsInfo{end+1}  = [obj(i).Name ' = ' obj(i).ConstraintStr];
                    end
                end
                    

                
                if ~isempty(tempnames)
                    
                    [~,orders] = sort(order);
                    
                    names = tempnames(orders);
                    
                    if nargout == 3
                        tempperturb= {obj(sel).PerturbSize};
                        tempperturbtype= {obj(sel).PerturbType};
                        
                        
                        perturbsizes = tempperturb(orders);
                        perturbtypes = tempperturbtype(orders);
                        varargout{1} = perturbsizes;
                        varargout{2} = perturbtypes;
                    elseif nargout == 5
                        tempperturb= {obj(sel).PerturbSize};
                        tempperturbtype= {obj(sel).PerturbType};
                        
                        perturbsizes = tempperturb(orders);
                        perturbtypes = tempperturbtype(orders);
                        
                        varargout{1} = perturbsizes;
                        varargout{2} = perturbtypes;
                        varargout{3} = ConstraintsArray;
                        varargout{4} = ConstraintsInfo;
                    end
                else
                    names = {};
                    varargout{1} = [];
                    varargout{2} = [];
                    
                    if nargout == 5
                        varargout{3} = [];
                        varargout{4} = {};
                    end
                end
            end
        end % getSelectedNames
    end % Ordinary Methods
    
    %% Methods - View
    methods 
         
    end % View Methods
    
    %% Methods - Protected
    methods (Access = protected)       

    end
    
end