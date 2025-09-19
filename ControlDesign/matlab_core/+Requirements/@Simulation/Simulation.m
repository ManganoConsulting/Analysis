classdef Simulation < Requirements.RequirementTypeOne 
      
    methods  
        function r = Simulation(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % requirement 
        
    end % Constructor   
end