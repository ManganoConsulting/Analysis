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

            % Build list of columns starting with selected flight conditions
            baseHeaders = header(2:min(3,end));
            selFields = struct('name',{},'type',{});
            for k = 1:numel(baseHeaders)
                if ~strcmp(baseHeaders{k},'All')
                    selFields(end+1) = struct('name',baseHeaders{k},'type','FlightCondition'); %#ok<AGROW>
                end
            end

            % Determine additional varying parameters across all operating conditions
            if ~isempty(operCond)
                % Inputs
                inNames = {operCond(1).Inputs.Name};
                for n = 1:numel(inNames)
                    vals = arrayfun(@(oc) oc.Inputs.get(inNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        selFields(end+1) = struct('name',inNames{n},'type','Inputs'); %#ok<AGROW>
                    end
                end
                % Outputs
                outNames = {operCond(1).Outputs.Name};
                for n = 1:numel(outNames)
                    vals = arrayfun(@(oc) oc.Outputs.get(outNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        selFields(end+1) = struct('name',outNames{n},'type','Outputs'); %#ok<AGROW>
                    end
                end
                % States
                stNames = {operCond(1).States.Name};
                for n = 1:numel(stNames)
                    vals = arrayfun(@(oc) oc.States.get(stNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        selFields(end+1) = struct('name',stNames{n},'type','States'); %#ok<AGROW>
                    end
                end
                % State derivatives
                sdNames = {operCond(1).StateDerivs.Name};
                for n = 1:numel(sdNames)
                    vals = arrayfun(@(oc) oc.StateDerivs.get(sdNames{n}).Value, operCond);
                    if any(abs(vals - vals(1)) > 1e-6)
                        selFields(end+1) = struct('name',sdNames{n},'type','StateDerivs'); %#ok<AGROW>
                    end
                end
                % Mass properties (parameters and weight code)
                mpNames = [{operCond(1).MassProperties.Parameter.Name}, 'WeightCode'];
                for n = 1:numel(mpNames)
                    vals = arrayfun(@(oc) oc.MassProperties.get(mpNames{n}), operCond, 'UniformOutput', false);
                    firstVal = vals{1};
                    if isnumeric(firstVal)
                        valsNum = cell2mat(vals);
                        if any(abs(valsNum - valsNum(1)) > 1e-6)
                            selFields(end+1) = struct('name',mpNames{n},'type','MassProperties'); %#ok<AGROW>
                        end
                    else
                        if ~all(strcmp(firstVal,vals))
                            selFields(end+1) = struct('name',mpNames{n},'type','MassProperties'); %#ok<AGROW>
                        end
                    end
                end
            end

            % Determine units and numeric alignment flags using first operating condition
            unitsDisplay = cell(1,numel(selFields));
            isNumeric = false(1,numel(selFields));
            if ~isempty(operCond)
                for k = 1:numel(selFields)
                    fld = selFields(k);
                    switch fld.type
                        case 'FlightCondition'
                            sample = operCond(1).FlightCondition.(fld.name);
                            unit = '';
                        case 'Inputs'
                            objTmp = operCond(1).Inputs.get(fld.name);
                            sample = objTmp.Value;
                            unit = objTmp.Units;
                        case 'Outputs'
                            objTmp = operCond(1).Outputs.get(fld.name);
                            sample = objTmp.Value;
                            unit = objTmp.Units;
                        case 'States'
                            objTmp = operCond(1).States.get(fld.name);
                            sample = objTmp.Value;
                            unit = objTmp.Units;
                        case 'StateDerivs'
                            objTmp = operCond(1).StateDerivs.get(fld.name);
                            sample = objTmp.Value;
                            unit = objTmp.Units;
                        case 'MassProperties'
                            sample = operCond(1).MassProperties.get(fld.name);
                            if isobject(sample) && isprop(sample,'Units')
                                unit = sample.Units;
                                sample = sample.Value;
                            else
                                unit = '';
                            end
                    end
                    unitsDisplay{k} = unit;
                    isNumeric(k) = isnumeric(sample);
                end
            end

            range = obj.ActX_word.Selection.Range;

            nr_rows = length(operCond) + 2; % two header rows
            nr_cols = numel(selFields);

            % Add Table
            newTable1 = obj.ActX_word.ActiveDocument.Tables.Add(range,nr_rows,nr_cols,1,1);

            % ----- Header rows -----
            % Second row: variable names with units
            for i = 1:nr_cols
                hdr = selFields(i).name;
                if ~isempty(unitsDisplay{i})
                    hdr = [hdr,' (',unitsDisplay{i},')'];
                end
                newTable1.Cell(2,i).Range.InsertAfter(hdr);
                newTable1.Cell(2,i).Range.Bold = 1;
            end

            % First row: category titles spanning columns
            cats = {selFields.type};
            colorMap = struct('FlightCondition',[219 229 241], ...
                              'Inputs',[198 239 206], ...
                              'Outputs',[255 229 153], ...
                              'States',[255 242 204], ...
                              'StateDerivs',[217 210 233], ...
                              'MassProperties',[222 235 247]);
            c = nr_cols;
            while c >= 1
                endIdx = c;
                curType = cats{c};
                while c > 1 && strcmp(cats{c-1},curType)
                    c = c - 1;
                end
                startIdx = c;
                if endIdx > startIdx
                    newTable1.Cell(1,startIdx).Merge(newTable1.Cell(1,endIdx));
                end
                newTable1.Cell(1,startIdx).Range.InsertAfter(curType);
                newTable1.Cell(1,startIdx).Range.Bold = 1;
                if isfield(colorMap,curType)
                    col = Utilities.DHX(colorMap.(curType));
                else
                    col = Utilities.DHX([200 200 200]);
                end
                newTable1.Cell(1,startIdx).Shading.BackgroundPatternColor = col;
                for j = startIdx:endIdx
                    newTable1.Cell(2,j).Shading.BackgroundPatternColor = col;
                end
                c = c - 1;
            end

            % Adjust header spacing
            % Row 1 has merged cells, so iterate over existing cells only
            for nn = 1:newTable1.Rows.Item(1).Cells.Count
                newTable1.Cell(1,nn).Range.ParagraphFormat.Alignment = 1; % center
            end
            for nn = 1:nr_cols
                newTable1.Cell(2,nn).Range.ParagraphFormat.Alignment = 1; % center
            end

            % ----- Populate data rows -----
            stripeColor = Utilities.DHX([242 242 242]);
            for i = 1:length(operCond)
                if mod(i,2) == 0
                    newTable1.Rows.Item(i+2).Shading.BackgroundPatternColor = stripeColor;
                end
                for c = 1:nr_cols
                    fld = selFields(c);
                    switch fld.type
                        case 'FlightCondition'
                            val = operCond(i).FlightCondition.(fld.name);
                        case 'Inputs'
                            val = operCond(i).Inputs.get(fld.name).Value;
                        case 'Outputs'
                            val = operCond(i).Outputs.get(fld.name).Value;
                        case 'States'
                            val = operCond(i).States.get(fld.name).Value;
                        case 'StateDerivs'
                            val = operCond(i).StateDerivs.get(fld.name).Value;
                        case 'MassProperties'
                            val = operCond(i).MassProperties.get(fld.name);
                    end
                    if isnumeric(val)
                        valStr = sprintf('%.4g', val);
                    else
                        valStr = num2str(val);
                    end
                    if ~ischar(valStr) || isempty(valStr)
                        valStr = ' ';
                    end
                    newTable1.Cell(i + 2,c).Range.InsertAfter(valStr);
                    if isNumeric(c)
                        newTable1.Cell(i + 2,c).Range.ParagraphFormat.Alignment = 2; % right
                    end
                end
            end

            % Formatting
            newTable1.Rows.Item(1).set('HeadingFormat',-1);
            newTable1.Rows.Item(2).set('HeadingFormat',-1);
            try
                newTable1.Borders.InsideLineStyle = 1;
                newTable1.Borders.OutsideLineStyle = 1;
            catch
            end
            for c = 1:nr_cols
                try
                    newTable1.Columns.Item(c).SetWidth(55,0);
                catch
                end
            end

            % Step out of table
            set( obj.ActX_word.Selection, 'Start', newTable1.Range.get('End') );
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
