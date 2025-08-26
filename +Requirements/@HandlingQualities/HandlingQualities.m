classdef HandlingQualities < Requirements.RequirementTypeOne 
       
    methods  
        function r = HandlingQualities(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % HandlingQualities 
        
    end % Constructor
   
end