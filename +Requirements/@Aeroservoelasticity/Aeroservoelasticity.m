classdef Aeroservoelasticity < Requirements.RequirementTypeOne    
    methods  
        function r = Aeroservoelasticity(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % Aeroservoelasticity 
        
    end % Constructor 
end