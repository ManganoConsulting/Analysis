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

            for i = 1:length(fileList)
                %SelectionRange.Style = 'Heading 2';
                %SelectionRange.InsertAfter(['Figure ',int2str(i),': ',SummaryPlotFileList(i).Title]);
                %rangeEnd = SelectionRange.get('End');
                %SelectionRange.SetRange(rangeEnd,rangeEnd);
       
                %inLineShapeObj(i) = obj.ActX_word.Application.Selection.Range.InlineShapes.AddPicture(fileList(i).Filename, [], true); %#ok<AGROW>
                inLineShapeObj(i) = obj.Word_handle.Bookmarks.Item('\EndOfDoc').Range.InlineShapes.AddPicture(fileList(i).Filename, [], true);
                
                inLineShapeObj(i).Range.InsertCaption('Figure',[': ',addlCapt,fileList(i).Title],'',0,0);
                docRange = inLineShapeObj(i).Range;
                docRange.ParagraphFormat.Alignment = 1; % Center the figure
                End = docRange.get('End');
                set( obj.ActX_word.Application.Selection, 'Start', End );
                set( obj.ActX_word.Application.Selection, 'End', End+1 );
                %inLineShapeObj(2) = actx_word.Selection.Range.InlineShapes.AddPicture(SummaryPlotFileList(i).Path, [], true);
                %inLineShapeObj(2).Range.InsertCaption('Figure',[': ',SummaryPlotFileList(i).Title],'',0,0);        
            end
            % m=inlshapeObj.ConvertToShape
            % m.IncrementRotation(90)
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
            obj.ActX_word.Selection.TypeParagraph; %enter
            obj.ActX_word.Selection.TypeParagraph; %enter
        end % addReqTable
        
        function addOperCondTable( obj , operCond , header )
            % Build list of columns starting with selected flight conditions
            baseHeaders = header(2:min(3,end));
            hdrStruct = operCond(1).getHeaderStructureData();
            keyFcn = @(t,n) [t '|' n];
            keyList = arrayfun(@(s) keyFcn(s.Type,s.Name), hdrStruct, 'UniformOutput', false);
            unitMap = containers.Map(keyList,{hdrStruct.Units});
            selFields = struct('name',{},'type',{},'unit',{});
            for k = 1:numel(baseHeaders)
                if ~strcmp(baseHeaders{k},'All')
                    key = keyFcn('Flight Condition',baseHeaders{k});
                    unit = unitMap(key);
                    selFields(end+1) = struct('name',baseHeaders{k},'type','Flight Condition','unit',unit); %#ok<AGROW>
                end
            end

            if ~isempty(operCond)
                % Inputs
                inNames = {operCond(1).Inputs.Name};
                for n = 1:numel(inNames)
                    vals = arrayfun(@(oc) oc.Inputs.get(inNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        key = keyFcn('Inputs',inNames{n});
                        unit = unitMap(key);
                        selFields(end+1) = struct('name',inNames{n},'type','Inputs','unit',unit); %#ok<AGROW>
                    end
                end
                % Outputs
                outNames = {operCond(1).Outputs.Name};
                for n = 1:numel(outNames)
                    vals = arrayfun(@(oc) oc.Outputs.get(outNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        key = keyFcn('Outputs',outNames{n});
                        unit = unitMap(key);
                        selFields(end+1) = struct('name',outNames{n},'type','Outputs','unit',unit); %#ok<AGROW>
                    end
                end
                % States
                stNames = {operCond(1).States.Name};
                for n = 1:numel(stNames)
                    vals = arrayfun(@(oc) oc.States.get(stNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        key = keyFcn('States',stNames{n});
                        unit = unitMap(key);
                        selFields(end+1) = struct('name',stNames{n},'type','States','unit',unit); %#ok<AGROW>
                    end
                end
                % State derivatives
                sdNames = {operCond(1).StateDerivs.Name};
                for n = 1:numel(sdNames)
                    vals = arrayfun(@(oc) oc.StateDerivs.get(sdNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        key = keyFcn('State Derivatives',sdNames{n});
                        unit = unitMap(key);
                        selFields(end+1) = struct('name',sdNames{n},'type','State Derivatives','unit',unit); %#ok<AGROW>
                    end
                end
                % Mass properties
                mpNames = [{operCond(1).MassProperties.Parameter.Name}, 'WeightCode'];
                for n = 1:numel(mpNames)
                    vals = arrayfun(@(oc) oc.MassProperties.get(mpNames{n}), operCond, 'UniformOutput', false);
                    firstVal = vals{1};
                    if isnumeric(firstVal)
                        valsNum = cell2mat(vals);
                        if any(abs(valsNum - valsNum(1)) > 1e-6)
                            key = keyFcn('Mass Property',mpNames{n});
                            unit = unitMap(key);
                            selFields(end+1) = struct('name',mpNames{n},'type','Mass Property','unit',unit); %#ok<AGROW>
                        end
                    else
                        if ~all(strcmp(firstVal,vals))
                            key = keyFcn('Mass Property',mpNames{n});
                            unit = unitMap(key);
                            selFields(end+1) = struct('name',mpNames{n},'type','Mass Property','unit',unit); %#ok<AGROW>
                        end
                    end
                end
            end

            range = obj.ActX_word.Selection.Range;

            nr_rows = length(operCond) + 2;
            nr_cols = numel(selFields);

            rowSpacing = 4;
            spaceBefore = 6;
            spaceAfter = 4;

            % Add Table
            newTable1 = obj.ActX_word.ActiveDocument.Tables.Add(range,nr_rows,nr_cols,1,1);
            newTable1.Style = 'Table Grid';
            newTable1.AutoFitBehavior(1); % wdAutoFitContent
            newTable1.Range.Font.Size = 10;
            newTable1.Borders.InsideLineStyle = 1;  % wdLineStyleSingle
            newTable1.Borders.OutsideLineStyle = 1; % wdLineStyleSingle
            newTable1.Borders.InsideLineWidth = 2;  % wdLineWidth025pt
            newTable1.Borders.OutsideLineWidth = 2; % wdLineWidth025pt
            newTable1.Columns.PreferredWidthType = 2; % wdPreferredWidthPoints
            for c = 1:nr_cols
                newTable1.Columns.Item(c).PreferredWidth = 55;
            end

            % Header rows
            categories = unique({selFields.type},'stable');
            colorMap = containers.Map({'Flight Condition','Inputs','Outputs','States','State Derivatives','Mass Property'},...
                                      {15,7,9,11,13,14});
            col = nr_cols;
            for catIdx = numel(categories):-1:1
                cat = categories{catIdx};
                colsInCat = sum(strcmp({selFields.type},cat));
                firstCol = col - colsInCat + 1;
                lastCol = col;
                if colsInCat > 1
                    newTable1.Cell(1,firstCol).Merge(newTable1.Cell(1,lastCol));
                end
                newTable1.Cell(1,firstCol).Range.InsertAfter(cat);
                newTable1.Cell(1,firstCol).Range.Bold = 1;
                newTable1.Cell(1,firstCol).Range.ParagraphFormat.Alignment = 1;
                if isKey(colorMap,cat)
                    newTable1.Cell(1,firstCol).Shading.BackgroundPatternColorIndex = colorMap(cat);
                end
                col = firstCol - 1;
            end
            for nn = 1:newTable1.Columns.Count
                newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceBefore = spaceBefore;
                newTable1.Cell(1,nn).Range.ParagraphFormat.LineSpacing = 12;
                newTable1.Cell(1,nn).Range.ParagraphFormat.SpaceAfter = spaceAfter;
            end
            for i = 1:nr_cols
                hdrTxt = sprintf('%s (%s)',selFields(i).name,selFields(i).unit);
                newTable1.Cell(2,i).Range.InsertAfter(hdrTxt);
                newTable1.Cell(2,i).Range.Bold = 1;
                newTable1.Cell(2,i).Range.ParagraphFormat.Alignment = 1;
                newTable1.Cell(2,i).Range.ParagraphFormat.SpaceBefore = spaceBefore;
                newTable1.Cell(2,i).Range.ParagraphFormat.LineSpacing = 12;
                newTable1.Cell(2,i).Range.ParagraphFormat.SpaceAfter = spaceAfter;
            end

            % Populate rows
            for i = 1:length(operCond)
                for c = 1:numel(selFields)
                    fld = selFields(c);
                    switch fld.type
                        case 'Flight Condition'
                            val = operCond(i).FlightCondition.(fld.name);
                        case 'Inputs'
                            val = operCond(i).Inputs.get(fld.name).Value;
                        case 'Outputs'
                            val = operCond(i).Outputs.get(fld.name).Value;
                        case 'States'
                            val = operCond(i).States.get(fld.name).Value;
                        case 'State Derivatives'
                            val = operCond(i).StateDerivs.get(fld.name).Value;
                        case 'Mass Property'
                            val = operCond(i).MassProperties.get(fld.name);
                    end
                    isNum = isnumeric(val);
                    if isNum
                        valStr = sprintf('%.3f', val);
                    else
                        valStr = char(val);
                    end
                    if ~ischar(valStr) || isempty(valStr)
                        valStr = ' ';
                    end
                    newTable1.Cell(i + 2,c).Range.InsertAfter(valStr);
                    if isNum
                        newTable1.Cell(i + 2,c).Range.ParagraphFormat.Alignment = 2; % Right
                    else
                        newTable1.Cell(i + 2,c).Range.ParagraphFormat.Alignment = 0; % Left
                    end
                end
            end

            % Alternate row shading for readability
            for r = 3:nr_rows
                if mod(r,2) == 1
                    newTable1.Rows.Item(r).Shading.BackgroundPatternColorIndex = 16; % wdGray25
                end
            end

            % Set header rows
            newTable1.Rows.Item(1).HeadingFormat = -1;
            newTable1.Rows.Item(2).HeadingFormat = -1;

            % Step out of table
            set( obj.ActX_word.Selection, 'Start', newTable1.Range.get('End') );
            obj.ActX_word.Selection.TypeParagraph; %enter
            obj.ActX_word.Selection.TypeParagraph; %enter
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
