classdef Presentation < handle
    
    %% Graphics Handles 
    properties (Transient = true)

    end % Graphics Handles
    
    %% Public Properties
    properties 

    end % Callbacks
    
    %% Transient Properties
    properties( Transient = true ) 
        ActX_ppt
        PPT_handle
        
        TOC_handle
        TOF_handle
    end % Callbacks
    
    %% Private Properties
    properties( Access = private  ) 
        
        Visible = true
        FullFileName = '';
        
    end % Callbacks
  
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
       
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        FileName
        PathName
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
        
        function obj = Presentation(varargin)  
            
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = false;
  
            p.addRequired('FullFileName',@ischar);

            p.parse(varargin{:});            
            
            paramsToSet = p.Results;
            
            obj.FullFileName = paramsToSet.FullFileName;
            % Create the document
            obj.startPowerPoint();

        end % Presentation
        
    end % Level1Container

    %% Methods - Property Access
    methods
        
        function y = get.FileName( obj )
            [ ~ , name , ext ] = fileparts(obj.FullFileName);
            y = [ name , ext ];
        end % FileName
        
        function y = get.PathName( obj )
            [ y ] = fileparts(obj.FullFileName);
        end % FileName
        
    end % Property access methods
   
    %% Creation methods
    methods (Access = private)
        
    end % Creation methods
    
    %% Methods - Ordinary
    methods 
       
        function save( obj )

            obj.PPT_handle.Save;
        end % save
        
        function saveAs( obj , filename , type )
            [path,name,ext] = fileparts(filename);
            if isempty(ext)   
                obj.PPT_handle.SaveAs([filename,'.pptx']);
            else
                obj.PPT_handle.SaveAs([filename]);  
            end
        end % saveAs
        
        function addFigure( obj , fileList )
            % Get current number of slides:
            slide_count = get(obj.PPT_handle.Slides,'Count');
            
            for i = 1:length(fileList)
                % Add a new slide (with title object):
                slide_count = int32(double(slide_count)+1);
                new_slide = invoke(obj.PPT_handle.Slides,'Add',slide_count,11);

                % Insert text into the title object:
                set(new_slide.Shapes.Title.TextFrame.TextRange,'Text',fileList(i).Title);

                % align the text to center
                new_slide.Shapes.Title.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignCenter';
                
                
                % Get height and width of slide:
                slide_H = obj.PPT_handle.PageSetup.SlideHeight;
                slide_W = obj.PPT_handle.PageSetup.SlideWidth;

                % Paste the contents of the Clipboard:
                pic1 = new_slide.Shapes.AddPicture( fileList(i).Filename, false , true , 0, 0);

                % Get height and width of picture:
                pic_H = get(pic1,'Height');
                pic_W = get(pic1,'Width');
                
                % Get Height of the text box
                text_H = get(new_slide.Shapes.Title,'Height');
                text_T = get(new_slide.Shapes.Title,'Top');
                
                % Compute total height for pic
                avalHeight = slide_H - (text_H + text_T);
                bottomOfText = text_H + text_T;
                
                
                % Center picture on page (below title area):
                set(pic1,'Top',single( bottomOfText + ((avalHeight - pic_H)/2)));
                
                set(pic1,'Left',single((double(slide_W) - double(pic_W))/2));



            end
   
        end % WordCreateSummaryPlots
        
        

        
        function closePowerPoint( obj )
            
            invoke(obj.PPT_handle,'Close'); 
            invoke(obj.ActX_ppt,'Quit'); 
            
            
        end % closeWord
        
    end % Ordinary Methods
     
    %% Methods - Callbacks
    methods (Access = protected) 
        
    end
    
    %% Methods - Protected
    methods (Access = protected) 
 

    end
    
    %% Methods - Private
    methods (Access = private) 

        function startPowerPoint( obj )
            % Start an ActiveX session with Word:
            obj.ActX_ppt = actxserver('PowerPoint.Application');
            obj.ActX_ppt.Visible = obj.Visible;
%             trace(obj.ActX_ppt.Visible);  
            if ~exist(obj.FullFileName,'file')
                % Create new document:
                obj.PPT_handle = invoke(obj.ActX_ppt.Presentations,'Add');
            else
                % Open existing document:
                obj.PPT_handle = invoke(obj.ActX_ppt.Presentations,'Open',obj.FullFileName);
            end           
        end % startPowerPoint    

        
    end
    
    
    %% Methods - Abstract
    methods (Abstract) 

    end  
    
    %% Method - Static
    methods ( Static )
        
        
    end
        
end
