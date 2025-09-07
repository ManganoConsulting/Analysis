classdef Report < handle
    
    %% Graphics Handles 
    properties (Transient = true)

    end % Graphics Handles
    
    %% Public Properties
    properties 

    end % Callbacks
    
    %% Transient Properties
    properties( Transient = true ) 
        ActX_word
        Word_handle
        
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
        
        function obj = Report(varargin)  
            
            %----- Parse Inputs -----%
            p = inputParser;
            p.KeepUnmatched = false;
  
            p.addRequired('FullFileName',@ischar);
            p.addParameter('Visible',true,@islogical);
            
            p.parse(varargin{:});            
            
            paramsToSet = p.Results;
            
            obj.FullFileName = paramsToSet.FullFileName;
            obj.Visible = paramsToSet.Visible;
            % Create the document
            obj.startWord();

        end % View
        
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
            % obj.FullFileName
            obj.Word_handle.Save;
        end % save
        
        function saveAs( obj , filename )
            [~,~,ext] = fileparts(filename);
            if isempty(ext)
                obj.Word_handle.SaveAs2([filename,'.docx']);
            elseif strcmp(ext,'.docx')
                obj.Word_handle.SaveAs2(filename);
            elseif strcmp(ext,'.htm') || strcmp(ext,'.html')
                obj.ActX_word.DefaultWebOptions.UpdateLinksOnSave = false;
                obj.Word_handle.SaveAs2(filename,10); 
            elseif strcmp(ext,'.pdf')
                obj.Word_handle.SaveAs2(filename,17);
            else
                obj.Word_handle.SaveAs2(filename);
            end
        end % saveAs
        
        function addFigure( obj , fileList , addlCapt )
            
            if nargin == 2
                addlCapt = '';
            else
                addlCapt = [addlCapt,'-'];
            end

%             obj.ActX_word.Selection.TypeParagraph;
            for i = 1:length(fileList)
                obj.ActX_word.Selection.TypeParagraph; % Add a line
                obj.ActX_word.Selection.GoTo(3, 3, [], []); % Go to the previous Line

                inLineShapeObj(i) = obj.ActX_word.Application.Selection.Range.InlineShapes.AddPicture(fileList(i).Filename, [], true); %#ok<AGROW>
                inLineShapeObj(i).Range.ParagraphFormat.Alignment = 1; %#ok<AGROW> % Center the figure
                
                obj.ActX_word.Selection.GoTo(3, -1, [], []);
                if i ~= length(fileList)
                    obj.ActX_word.Selection.TypeParagraph;
                end
            end
%             obj.ActX_word.Selection.TypeParagraph;
            for i = 1:length(fileList) 
                inLineShapeObj(i).Range.InsertCaption('Figure',[': ',addlCapt,fileList(i).Title],'',1,0);
            end
            
        end % WordCreateSummaryPlots
        
        function addTOC( obj )
            upper_heading_p = 1;
            lower_heading_p = 3;
            
            obj.TOC_handle = obj.ActX_word.ActiveDocument.TablesOfContents.Add(obj.ActX_word.Selection.Range,1,...
                upper_heading_p,lower_heading_p);

            obj.ActX_word.Selection.TypeParagraph; %enter
            
            
            %actx_word.ActiveDocument.TablesOfContents(1).Update;
            %word_handle.TablesOfContents(1).Update;

%             obj.Word_handle.FormField.Item('TableOfContents')
%             obj.Word_handle.ActiveDocument.TablesOfContents.Add(word_handle.FormField.Item('TableOfContents').Range);
        end % addTOC
        
        function addReqTable( obj , reqObj , modelFileExt )
            
%             obj.ActX_word.Selection.TypeText(title);
%             obj.ActX_word.Selection.Style = 'Heading 1';
%             
%             obj.ActX_word.Selection.TypeParagraph; %enter
            range = obj.ActX_word.Selection.Range;
            
            nr_rows = length(reqObj)+1;
            nr_cols = 4;

            header = {'Title','Simulink Model','Plot File','Method'};
            rowSpacing = 4;
            spaceBefore = 6;
            spaceAfter = 4;

            % Add Table
            newTable1 = obj.ActX_word.ActiveDocument.Tables.Add(range,nr_rows,nr_cols,1,1);
            
            % Populate Header
            for i = 1:length(header)
                newTable1.Cell(1,i).Range.InsertAfter(header{i});
                % Set the header to bold
                newTable1.Cell(1,i).Range.Style = 'Normal';
                newTable1.Cell(1,i).Range.Bold = 1;
            end

            % Set Header Spacing
            for nn = 1:newTable1.Columns.Count
                 newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceBefore = spaceBefore;
                 newTable1.Cell(1,nn).Range.ParagraphFormat.LineSpacing = 12;
                 newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceAfter = spaceAfter;
            end
            
            for i=1:length(reqObj)
                newTable1.Cell(i + 1,1).Range.InsertAfter(reqObj(i).Title);
                newTable1.Cell(i + 1,1).Range.Style = 'Normal';
                newTable1.Cell(i + 1,1).Range.Font.Size = 10;
                
                newTable1.Cell(i + 1,2).Range.InsertAfter(reqObj(i).MdlName);
                %obj.ActX_word.ActiveDocument.Hyperlinks.Add(newTable1.Cell(i+ 1,2).Range, ['models_report\',reqObj(i).MdlName,modelFileExt], [], 'Click Here', reqObj(i).MdlName,[]);
                newTable1.Cell(i + 1,2).Range.Style = 'Normal';
                newTable1.Cell(i + 1,2).Range.Font.Size = 10;
                try
                    newTable1.Cell(i + 1,3).Range.InsertAfter(reqObj(i).RequiermentPlot);
                    newTable1.Cell(i + 1,3).Range.Style = 'Normal';
                    newTable1.Cell(i + 1,3).Range.Font.Size = 10;
                end
                                
                newTable1.Cell(i + 1,4).Range.InsertAfter(reqObj(i).FunName);
                newTable1.Cell(i + 1,4).Range.Style = 'Normal'; 
                newTable1.Cell(i + 1,4).Range.Font.Size = 10;
            end
            
%             % Add Caption
%             newTable1.Range.InsertCaption('Table',': Summary of Test Results','',0,0);

            % Set first Row as the table header
            newTable1.Rows.Item(1).set('HeadingFormat',-1);

%             % Left Justify Table
%             newTable1.Rows.Alignment = 0;            
            
            % Step out of table
            set( obj.ActX_word.Selection, 'Start', newTable1.Range.get('End') );
%             obj.ActX_word.Selection.TypeParagraph; %enter
%             obj.ActX_word.Selection.TypeParagraph; %enter
        end % addReqTable
        
        function addOperCondTable( obj , operCond , header )
            

            header = header(2:5);
            headerLogArray = ~strcmp(header,'All');
            headerDisplay = [header(headerLogArray), ' '];
            
            range = obj.ActX_word.Selection.Range;
            
            nr_rows = length(operCond) + 1;
            nr_cols = length(headerDisplay);

            rowSpacing = 4;
            spaceBefore = 6;
            spaceAfter = 4;

            % Add Table
            newTable1 = obj.ActX_word.ActiveDocument.Tables.Add(range,nr_rows,nr_cols,1,1);
            
            % Populate Header
            for i = 1:nr_cols
                newTable1.Cell(1,i).Range.InsertAfter(headerDisplay{i});
                % Set the header to bold
                newTable1.Cell(1,i).Range.Bold = 1;
            end

            % Set Header Spacing
            for nn = 1:newTable1.Columns.Count
                 newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceBefore = spaceBefore;
                 newTable1.Cell(1,nn).Range.ParagraphFormat.LineSpacing = 12;
                 newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceAfter = spaceAfter;
            end
            
            for i=1:length(operCond)
                curRow = 1;
                if headerLogArray(1)
                    fc1 = num2str(operCond(i).FlightCondition.(header{1}));
                    if ~ischar(fc1) || isempty(fc1)
                        fc1 = ' ';
                    end
                    newTable1.Cell(i + 1,curRow).Range.InsertAfter(fc1);
    %                 newTable1.Cell(i + 1,curRow).Range.Font.Size = 10; 
                    curRow = curRow + 1;
                end
                
                if headerLogArray(2)
                    fc2 = num2str(operCond(i).FlightCondition.(header{2}));
                    if ~ischar(fc2) || isempty(fc2)
                        fc2 = ' ';
                    end
                    newTable1.Cell(i + 1,curRow).Range.InsertAfter(fc2);
    %                 newTable1.Cell(i + 1,curRow).Range.Font.Size = 10; 
                    curRow = curRow + 1;
                end
                
                if headerLogArray(3)
                    try
                        fc3 = num2str(operCond(i).Inputs.get(header{3}).Value);
                        if ~ischar(fc3) || isempty(fc3)
                            fc3 = ' ';
                        end
                        newTable1.Cell(i + 1,curRow).Range.InsertAfter(fc3);
                    catch
                        fc3 = num2str(operCond(i).Outputs.get(header{3}).Value);
                        if ~ischar(fc3) || isempty(fc3)
                            fc3 = ' ';
                        end
                        newTable1.Cell(i + 1,curRow).Range.InsertAfter(fc3);
                    end
    %                 newTable1.Cell(i + 1,curRow).Range.Font.Size = 10; 
                    curRow = curRow + 1;
                end
                
                if headerLogArray(4)
                    fc4 = operCond(i).MassProperties.get(header{4});
                    
                    if isnumeric(fc4)
                        fc4 = num2str(fc4);
                    end
                    
                    if ~ischar(fc4) || isempty(fc4)
                        fc4 = ' ';
                    end 
                    newTable1.Cell(i + 1,curRow).Range.InsertAfter(fc4);
    %                 newTable1.Cell(i + 1,curRow).Range.Font.Size = 10; 
                    curRow = curRow + 1;
                end  
                
            end
            

            % Set first Row as the table header
            newTable1.Rows.Item(1).set('HeadingFormat',-1);

%             % Left Justify Table
%             newTable1.Rows.Alignment = 0;            
            
            % Step out of table
            set( obj.ActX_word.Selection, 'Start', newTable1.Range.get('End') );
%             obj.ActX_word.Selection.TypeParagraph; %enter
%             obj.ActX_word.Selection.TypeParagraph; %enter
        end % addOperCondTable
        
        function addTOF( obj )
   
            if double(obj.ActX_word.ActiveDocument.TablesOfFigures.Count) > 0
                obj.TOF_handle = obj.ActX_word.ActiveDocument.TablesOfFigures.Item(1);
            else
                obj.TOF_handle = obj.ActX_word.ActiveDocument.TablesOfFigures.Add(obj.ActX_word.Selection.Range,true,true);
                %obj.ActX_word.Selection.InsertBreak;
                obj.ActX_word.Selection.TypeParagraph; %enter
            end

            
            
        end % addTOF     
        
        function updateTOC( obj )

            count = obj.ActX_word.ActiveDocument.TablesOfContents.Count;
            for i = 1:length(count)   
                obj.ActX_word.ActiveDocument.TablesOfContents.Item(i).UpdatePageNumbers;   
            end

        end % updateTOC
        
        function updateTOF( obj )
   
%             obj.TOF_handle.Update();
            
            count = obj.ActX_word.ActiveDocument.TablesOfFigures.Count;
            for i = 1:length(count)  
                obj.ActX_word.ActiveDocument.TablesOfFigures.Item(i).UpdatePageNumbers; 
            end
            
        end % updateTOF 
        
        function closeWord( obj )
            
            obj.Word_handle.Close(0); 
            invoke(obj.ActX_word,'Quit'); 
            
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

        function startWord( obj )
            % Start an ActiveX session with Word:
            obj.ActX_word = actxserver('Word.Application');
            obj.ActX_word.Visible = obj.Visible;
            trace(obj.ActX_word.Visible);  
            if ~exist(obj.FullFileName,'file')
                % Create new document:
                obj.Word_handle = invoke(obj.ActX_word.Documents,'Add');
            else
                % Open existing document:
                obj.Word_handle = invoke(obj.ActX_word.Documents,'Open',obj.FullFileName);
            end           
        end % startWord    
        

        


        
    end
     
    %% Methods - Abstract
    methods (Abstract) 

    end  
    
    %% Method - Static
    methods ( Static )
        
        
    end
        
end
