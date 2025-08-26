classdef RunObject < handle
    
    %% Graphics Handles 
    properties (Transient = true)

    end % Graphics Handles
    
    %% Public Properties
    properties 
        StabReqObj
        FreqReqObj
        SimReqObj
        HQReqObj
        ASEReqObj
        AnalysisOperCond
        DesignOperCond 
        ReqParamColl
        FilterParamColl
        SynthesisParamColl
        AnalysisOperCondDisplayText
        Title
        ScatteredGainObj
%         SimViewerProject
    end % 
    
    %% Transient Properties
    properties( Transient = true ) 

    end % 
    
    %% Private Properties
    properties( Access = private  ) 
       
    end % 
  
    %% Constant
    properties (Constant)
        
    end % Public properties
    
    %% Abstract properties - Data Storage
    properties  

    end % Abstract properties
    
    %% Observable
    properties (SetObservable)

    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        Selected = true
        IsActive = false
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)

    end % Dependant properties
    
    %% Dependant Read-only properties
    properties ( Dependent = true, GetAccess = public, SetAccess = private )
         
    end % Read-only properties
    
    %% Constant properties
    properties (Constant) 
        
    end % Constant properties  
    
    %% Events
    events

       
    end % Events
    
    %% Methods - Constructor
    methods      
        
        function obj = RunObject(varargin)  
            
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = false;
  
            p.addParameter('AnalysisOperCond',lacm.OperatingCondition.empty);
            p.addParameter('DesignOperCond',lacm.OperatingCondition.empty);
            p.addParameter('ReqParamColl',UserInterface.ControlDesign.ParameterCollection.empty);
            p.addParameter('FilterParamColl',UserInterface.ControlDesign.FilterCollection.empty);
            p.addParameter('SynthesisParamColl',UserInterface.ControlDesign.ParameterCollection.empty);
            p.addParameter('StabReqObj',Requirements.Requirement.empty);
            p.addParameter('FreqReqObj',Requirements.Requirement.empty);
            p.addParameter('SimReqObj',Requirements.Requirement.empty);
            p.addParameter('HQReqObj',Requirements.Requirement.empty);
            p.addParameter('ASEReqObj',Requirements.Requirement.empty);
            p.addParameter('AnalysisOperCondDisplayText',{});
            p.addParameter('ScatteredGainObj',ScatteredGain.GainCollection.empty);
            
%             p.addParameter('SimViewerProject',struct('SimulationData',{},'PlotSettings',{},...
%                 'RunLabel',{},'TreeExpansionState',{},'RunSpecificColors',{}));
            p.addParameter('Title','',@ischar)
            
            p.parse(varargin{:});            
            
            paramsToSet = p.Results;
            
            obj.AnalysisOperCond   = paramsToSet.AnalysisOperCond;
            obj.DesignOperCond     = paramsToSet.DesignOperCond;
            obj.ReqParamColl       = paramsToSet.ReqParamColl;
            obj.FilterParamColl    = paramsToSet.FilterParamColl;
            obj.SynthesisParamColl = paramsToSet.SynthesisParamColl;
            obj.StabReqObj         = paramsToSet.StabReqObj;
            obj.FreqReqObj         = paramsToSet.FreqReqObj;
            obj.SimReqObj          = paramsToSet.SimReqObj;
            obj.HQReqObj           = paramsToSet.HQReqObj;
            obj.ASEReqObj          = paramsToSet.ASEReqObj;
            obj.Title              = paramsToSet.Title;
            obj.AnalysisOperCondDisplayText = paramsToSet.AnalysisOperCondDisplayText;
            obj.ScatteredGainObj   = paramsToSet.ScatteredGainObj;
%             obj.SimViewerProject   = paramsToSet.SimViewerProject;
        end % RunObject
        
    end % RunObject

    %% Methods - Property Access
    methods
        
        
    end % Property access methods
   
    %% Creation methods
    methods (Access = private)
        
    end % Creation methods
    
    %% Methods - Ordinary
    methods 
       
        function addAnalysisOperCond(obj , newOperCond ) 
            
%             logArray = setdiff(newOperCond,obj.AnalysisOperCond);
%             obj.AnalysisOperCond = [obj.AnalysisOperCond,newOperCond(~logArray)];   
            
            obj.AnalysisOperCond = [obj.AnalysisOperCond,newOperCond];
        end % addAnalysisOperCond
        
    end % Ordinary Methods
     
    %% Methods - Callbacks
    methods (Access = protected) 
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
 

    end
    
    %% Methods - Private
    methods (Access = private) 
    
    end
    
    
    %% Methods - Abstract
    methods (Abstract) 

    end  
    
    %% Method - Static
    methods ( Static )
        
        
    end
        
end
