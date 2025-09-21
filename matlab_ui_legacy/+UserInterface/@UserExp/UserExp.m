classdef UserExp < matlab.mixin.SetGet
    
    %% Transient properties - Object Handles
    properties (Transient = true)   

    end % Object Handles
  
    %% Public properties - Data Storage
    properties   
        OriginalString
        AccessString
        ReplacedVariable
    end % Public properties
    
    %% Private properties
    properties ( Access = private )  

    end % Private properties
    
    %% Private properties GET/SET
    properties ( Access = private )  

    end % Private properties
       
    %% Dependant properties
    properties ( Dependent = true )

    end % Dependant properties
    
    %% Dependant properties Read Only
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true , SetAccess = private  )

    end % Dependant properties
    
    %% Constant Properties
    properties (Constant)
         
    end   
    
    %% Events
    events

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = UserExp(varargin)      
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'OriginalString','',@ischar);
            addParameter(p,'AccessString','',@ischar);
            addParameter(p,'ReplacedVariable','',@ischar);

            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.OriginalString      = options.OriginalString;
            obj.AccessString        = options.AccessString;
            obj.ReplacedVariable    = options.ReplacedVariable;
            
        end % UserExp
        
    end % Constructor
    
    %% Methods - Property Access New
    methods
        
              
    end % Property access methods
        
    %% Methods - Ordinary
    methods 
        function y = getString(obj , pre )
            if nargin == 1
                pre = '';
            end
            if isempty(obj.OriginalString) || isempty(obj.ReplacedVariable) || isempty(obj.AccessString)
                y = '';
            else
                y = strrep( obj.OriginalString ,...
                    obj.ReplacedVariable,...
                    [pre,obj.AccessString]);   
            end
  
        end % getString
        
        function y = eq( A , B )
            y = false;
            if isa(A,'UserInterface.UserExp') && isa(B,'UserInterface.UserExp')
                if strcmp( A.OriginalString ,  B.OriginalString ) && ...
                       strcmp( A.AccessString ,  B.AccessString ) && ...
                       strcmp( A.ReplacedVariable ,  B.ReplacedVariable )
                    y = true;
                end
            elseif isa(A,'UserInterface.UserExp') && ischar(B)
                if strcmp( A.getString() ,  B )
                    y = true;
                end
            elseif isa(B,'UserInterface.UserExp') && ischar(A)
                if strcmp( B.getString() ,  A )
                    y = true;
                end
            end
        end % eq
        
    end % Add Listeners   
 
end
