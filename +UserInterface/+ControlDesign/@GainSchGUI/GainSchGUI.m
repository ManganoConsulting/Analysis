classdef GainSchGUI < matlab.mixin.Copyable & matlab.mixin.SetGet
    % SelectedGainString - String of the selected scattered gain including
    % any expressions - is 0 if gain includes an expression
    %
    % SelectedGainIndex  - Index of the selected scattered gain in combobox
    %
    % SelectedGain  - String of the selected scattered gain only = should be the
    % same as the gain in the combobox relative the selected index
    %
    %
    %
    %
    %
    %
    %
    
    %% Transient properties - Object Handles{'1-D','2-D'}
    properties (Transient = true)   
        Parent
        Container
        GainSchAxisColl UserInterface.AxisPanelCollection
        GainSchAxisPanel
        GainSelectionPanel
        TextGainName
        IndVarText   
        TextBP1Name
        BP1Name_eb
        TextBP2Name
        TextBP2NameCont
        BP2Name_eb
        FitRangeName
        TextBP
        BP_eb 
        HCompIndVar
        HContIndVar
        HCompGainSel
        HContGainSel  
        LineH
        ExLineH
        axH
        PolyFitLineH     
        SchJButtonHComp
        SchJButtonHCont
        TextDimension
        
        HContTableDim 
        HCompScatGainFile
        HContScatGainFile
        HCompSelSchFile
        HContSelSchFileFile
        SchFileName
        ScattFileName
        BP1ValueString_eb
        ScatterLabelComp
        ScatterLabelCont
        GainSchedulePanel
        SchLabelComp
        SchLabelCont
        NewSchJButtonHComp
        NewSchJButtonHCont
        RemoveSchCollJButtonHComp
        RemoveSchCollJButtonHCont
        ExportSchJButtonHComp
        ExportSchJButtonHCont
        SchGainName
        HCompSchGainName
        HContSchGainName
        NewSchGainNameJButtonHComp
        NewSchGainNameJButtonHCont
        RemoveSchGainNameJButtonHComp
        RemoveSchGainNameJButtonHCont
        TextBPCont
        TextBP1Value
        TextBP1ValueCont
        GainFittingPanel
        GainFitLabelComp
        GainFitLabelCont
        PolyFitTable
        OptionsPanel
        OptionsLabelComp
        OptionsLabelCont
        JTable
        JTableH
        JScroll
        JHScroll
        HContainer
        RemoveRowJButtonHCont
        RemoveRowJButtonHComp
        ExportTableJButtonHComp
        ExportTableJButtonHCont
        ViewTableJButtonHComp
        ViewTableJButtonHCont
        RemoveSchJButtonHComp
        RemoveSchJButtonHCont
        TableModel
        FixColTbl
        
        Tree
        
        EditGainListButtonHComp
        EditGainListJButtonHCont
        EditIndVarListButtonHComp
        EditIndVarListJButtonHCont
        
    end % Object Handles
  
    %% Public properties - Data Storage
    properties   
        BP1ValueString  
        SelectedGain
        GainSymVarExp
        SelectedTableDimension = 2
        PolyFitData = {'1','[0,1]';'','';'','';'','';'','';}
        SelectedScheduledGain
        HContSchGainSelIndex = 1
        Title
        BorderType
        
        SelScatteredGainList = struct('Name',{},'Expression',{})
        SelIndVarsList = struct('Name',{},'Expression',{})
        TableDimList = {'1-D','2-D'}
    end % Public properties
    
    %% Private properties
    properties ( Access = private )  
        PrivateFilteredScatteredGains
        BreakPoints1TableName = ' '
        BreakPoints2TableName
        BreakPointsString
        IncludedInFit
        ScattGainFileObjArray ScatteredGain.GainFile = ScatteredGain.GainFile.empty
        SchGainFileObjArray ScheduledGain.SchGainCollection = ScheduledGain.SchGainCollection.empty
        SelScattGainObjIndex
        SelSchGainFileObjIndex
        SelectedGainIndex
        SelectedGainString 
        IndVarSelectedIndex
        IndVarString
        ScheduledGainNamesArray = {}
    end % Private properties
    
    %% Private properties GET/SET
    properties ( Access = private )  
        PrivatePosition = [0,0,1,1]
        PrivateUnits = 'Normalized'
    end % Private properties
       
    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
    end % Dependant properties
    
    %% Dependant properties Read Only
    properties ( Dependent = true, SetAccess = private )
        FittingRange
        BreakPoints
        AvaliableBP1ValueSelections
        FilteredScatteredGains
        PolyDegreeValue
        SelectedScattGainFileObj
        CurrentSchGainFileObj
        BP2Selections
        GainExpression
        IndVarExpression
        XData
        YData
        GainPlotColor
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true , SetAccess = private  )
        CurrentScheduledGainObj
        
        ParentFigure
    end % Dependant properties
    
    %% Constant Properties
    properties (Constant)
         
    end   
    
    %% Events
    events
        GainScheduleCollAdded
        GainScheduleCollRemoved
        GainSelected
%         GainAdded2SelectedCollection
        SchGainFileSelected
        ScatteredGainFileSelected
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
        AutoSaveFile
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = GainSchGUI(varargin)      
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','');
            addParameter(p,'BorderType','none');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.Parent = options.Parent;
            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;
            obj.BorderType      = options.BorderType;
            
            if any(strcmp(p.UsingDefaults,'Parent'))
               obj.Parent.MenuBar = 'None';
               obj.Parent.NumberTitle = 'off';
            end

            createView( obj , obj.Parent );
            resize( obj , [] , [] );
        end % GainSchGUI
        
    end % Constructor
    
    %% Methods - Property Access New
    methods
        
        function y = get.ParentFigure( obj )
            y = ancestor(obj.Container,'Figure','toplevel');
        end % ParentFigure
        
        function y = get.CurrentSchGainFileObj( obj )
            if isempty(obj.SchGainFileObjArray)
                y = ScheduledGain.SchGainCollection.empty;
            else
                y = obj.SchGainFileObjArray(obj.SelSchGainFileObjIndex);
            end
        end % CurrentSchGainFileObj
        
        function y = get.PolyDegreeValue( obj )
            y = [];
            strArray = obj.PolyFitData(:,1);
            for i = 1:length(strArray)
                if ~isempty(strArray{i})
                    y(end + 1) = str2num( strArray{i} ); %#ok<ST2NM>
                end
            end
            
%             if ~isempty(y)
%                 [ ~ , I ] = evalBreakpoints( obj );
%                 y = y(I);
%             end
           
        end % PolyDegreeValue
        
        function y = get.FittingRange( obj )
            
            y = {};
            strArray = obj.PolyFitData(:,2);
            for i = 1:length(strArray)
                if ~isempty(strArray{i})
                    y{end + 1} = str2num( strArray{i} ); %#ok<ST2NM>
                end
            end
            
%             if ~isempty(y)
%                 [ ~ , I ] = evalBreakpoints( obj );
%                 y = y(I);
%             end
            

            

        end % FittingRange
        
        function y = get.BreakPoints( obj )
            y = evalBreakpoints( obj );
        end % BreakPoints
       
        function set.Position( obj , pos )
            set(obj.Container,'Position',pos);
            obj.PrivatePosition = pos;
        end % Position - Set
        
        function y = get.Position( obj )
            y = obj.PrivatePosition;
        end % Position - Get
        
        function set.Units( obj , units )
            set(obj.Container,'Units',units);
            obj.PrivateUnits = units;
        end % Units -Set
        
        function y = get.Units( obj )
            y = obj.PrivateUnits;
        end % Units -Get
              
    end % Property access methods
        
    %% Methods - Property Access
    methods
        
        function y = get.FilteredScatteredGains( obj )
            
            if isempty(obj.PrivateFilteredScatteredGains)
                y = ScatteredGain.GainCollection.empty;
            else
                y = obj.PrivateFilteredScatteredGains;
            end
        end % FilteredScatteredGains          
        
        function y = get.SelectedScattGainFileObj( obj )
            y = obj.ScattGainFileObjArray(obj.SelScattGainObjIndex);
        end % SelectedScattGainFileObj
        
        function y = get.BP2Selections( obj )
            if ~isempty(obj.FilteredScatteredGains)
                fltCond = {'Mach','Qbar','Alt','KCAS','KTAS','KEAS'};
                massProp = {obj.FilteredScatteredGains(1).DesignOperatingCondition.MassProperties.Parameter.Name};
                y = [fltCond,massProp];
            else
                y = {''};
            end
        end % BP2Selections       
        
        function y = get.GainExpression( obj )
            
            % Update for User defined expressions
            if isempty(obj.SelectedGainString) || isempty(obj.SelScatteredGainList) || isempty(obj.SelectedGainIndex) || obj.SelectedGainIndex == 0
                y = '';
            else
                
                ExpressionTree = obj.SelScatteredGainList(obj.SelectedGainIndex).Expression;
                js = strfind(ExpressionTree,'(');
                
                if ~isempty(js)
                    ExpressionName = [ExpressionTree(1:js-1) '.get(''' obj.SelScatteredGainList(obj.SelectedGainIndex).Name ''').Value']; 
                else
                    ExpressionName = ExpressionTree;
                end
                
                y = UserInterface.UserExp('OriginalString',obj.SelectedGainString,...
                    'AccessString',ExpressionName,...
                    'ReplacedVariable',obj.SelScatteredGainList(obj.SelectedGainIndex).Name);       
            end

        end % GainExpression
        
        function y = get.IndVarExpression( obj )
            
            % Update for User defined expressions
            if isempty(obj.IndVarString) || isempty(obj.SelIndVarsList) || isempty(obj.IndVarSelectedIndex) || obj.IndVarSelectedIndex == 0
                y = '';
            else
                ExpressionTree = obj.SelIndVarsList(obj.IndVarSelectedIndex).Expression;
                js = strfind(ExpressionTree,'(');
                
                if ~isempty(js)
                    ExpressionName = [ExpressionTree(1:js-1) '.get(''' obj.SelIndVarsList(obj.IndVarSelectedIndex).Name ''').Value']; 
                else
                    ExpressionName = ExpressionTree;
                end
                
                y = UserInterface.UserExp('OriginalString',obj.IndVarString,...
                    'AccessString',ExpressionName,...
                    'ReplacedVariable',obj.SelIndVarsList(obj.IndVarSelectedIndex).Name);  
            end

        end % IndVarExpression 
     
        function y = get.XData( obj ) 
            % obj.SelIndVarsList
            % obj.IndVarSelectedIndex
            % obj.IndVarString
            
            y = [];
            if ~isempty(obj.IndVarExpression)%~isempty(obj.SelIndVarsList)
                for i = 1:length(obj.FilteredScatteredGains)
                    y(i) = eval( getString(obj.IndVarExpression,'obj.FilteredScatteredGains(i).') );
                    %y(i) = eval(['obj.FilteredScatteredGains(i).',obj.IndVarExpression]);
%                     y(ind) = eval(['obj.FilteredScatteredGains(ind).',obj.SelIndVarsList(obj.IndVarSelectedIndex).Expression]);
                end
            end
        end % XData
        
        function y = get.YData( obj )
            % obj.SelScatteredGainList
            % obj.SelectedGainIndex
            % obj.SelectedGainString
            
            
            y = [];
            if ~isempty(obj.GainExpression)%~isempty(obj.SelScatteredGainList)
                for i = 1:length(obj.FilteredScatteredGains)
                    y(i) = eval( getString(obj.GainExpression,'obj.FilteredScatteredGains(i).') );
%                     y(i) = eval(['obj.FilteredScatteredGains(i).',obj.GainExpression]);
%                     y(ind) = eval(['obj.FilteredScatteredGains(ind).',obj.SelScatteredGainList(obj.SelectedGainIndex).Expression]);
         
                end
            end
        end % YData
        
        function y = get.GainPlotColor( obj )
            y = {obj.FilteredScatteredGains.Color};
        end % GainPlotColor  

    end % Property access methods
   
    %% Methods - Add Listeners
    methods 
        
        function addListenerFilterChange( obj , srcObj )
            addlistener(srcObj,'FilteredGainsUpdated',@obj.filteredGainsUpdated);
        end % addListenerFilterChange
        
    end % Add Listeners
    
    %% Methods - Component Callbacks
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Scattered Gains Group %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Callback | Scattered Gain Object:  
        function scattGainFileSel_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                if isempty(hobj.Value)
                    obj.SelScattGainObjIndex = [];
                else
                    obj.SelScattGainObjIndex = find(strcmp(hobj.Items,hobj.Value));
                    notify(obj,'ScatteredGainFileSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedScattGainFileObj));
                end
            else
                if hobj.getSelectedIndex < 0
                    obj.SelScattGainObjIndex = [];
                else
                    obj.SelScattGainObjIndex = hobj.getSelectedIndex + 1;
                    notify(obj,'ScatteredGainFileSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedScattGainFileObj));
                end
            end
            obj.SelScatteredGainList = [];
            obj.SelIndVarsList = [];
            setGainSelectionComboBox( obj );
            setIndVarComboBox( obj );
            update( obj );
        end % scattGainFileSel_CB
       
        % Callback | Select Scattered Gain:
        function gainSel_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                val = hobj.Value;
                idx = find(strcmp(hobj.Items,val));
                if ~isempty(idx)
                    obj.SelectedGainIndex = idx;
                    obj.SelectedGainString = val;
                    obj.SelectedGain = val;
                    update( obj );
                    notify(obj,'GainSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedGain));
                else
                    if ~isempty(obj.SelectedGainIndex)
                        selItem = hobj.Items{obj.SelectedGainIndex};
                        userExp = val;
                        symvarStr = symvar(userExp);
                        if any(strcmp(selItem,symvarStr))
                            obj.SelectedGainString = userExp;
                            obj.SelectedGain = selItem;
                            update( obj );
                            notify(obj,'GainSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedGain));
                        else
                            error('GainSchedule:UnknownGain','Gain Expression must contain the selected gain.');
                        end
                    end
                end
            else
                if hobj.getSelectedIndex ~= -1
                    obj.SelectedGainIndex = hobj.getSelectedIndex + 1;
                    obj.SelectedGainString = hobj.getSelectedItem;
                    obj.SelectedGain = obj.SelectedGainString;
                    update( obj );
                    notify(obj,'GainSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedGain));
                else
                    if ~isempty(obj.SelectedGainIndex)
                        selItem = hobj.getModel.getElementAt( obj.SelectedGainIndex - 1 );
                        userExp = hobj.getSelectedItem;
                        symvarStr = symvar(userExp);
                        if any(strcmp(selItem,symvarStr))
                            obj.SelectedGainString = userExp;
                            obj.SelectedGain = selItem;
                            update( obj );
                            notify(obj,'GainSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedGain));
                        else
                            error('GainSchedule:UnknownGain','Gain Expression must contain the selected gain.');
                        end
                    end
                end
            end
        end % gainSel_CB
        
        % Callback | Independent Variable:
        function indVar_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                val = hobj.Value;
                idx = find(strcmp(hobj.Items,val));
                if ~isempty(idx)
                    obj.IndVarSelectedIndex = idx;
                    obj.IndVarString = val;
                    update( obj );
                else
                    if ~isempty(obj.IndVarSelectedIndex)
                        selItem = hobj.Items{obj.IndVarSelectedIndex};
                        userExp = val;
                        symvarStr = symvar(userExp);
                        if any(strcmp(selItem,symvarStr))
                            obj.IndVarString = userExp;
                            update( obj );
                        else
                            error('GainSchedule:UnknownIndependantVariable','Independant Variable Expression must contain the selected Independant Variable.');
                        end
                    end
                end
            else
                if hobj.getSelectedIndex ~= -1
                    obj.IndVarSelectedIndex = hobj.getSelectedIndex + 1;
                    obj.IndVarString = hobj.getSelectedItem;
                    update( obj );
                else
                    if ~isempty(obj.IndVarSelectedIndex)
                        selItem = hobj.getModel.getElementAt( obj.IndVarSelectedIndex - 1 );
                        userExp = hobj.getSelectedItem;
                        symvarStr = symvar(userExp);
                        if any(strcmp(selItem,symvarStr))
                            obj.IndVarString = userExp;
                            update( obj );
                        else
                            error('GainSchedule:UnknownIndependantVariable','Independant Variable Expression must contain the selected Independant Variable.');
                        end
                    end
                end
            end
        end % indVar_CB
        
        % Callback | Edit Scattered Gain List
        function updateSelectableScatteredGains( obj , ~ , ~ )
            if isempty(obj.SelectedScattGainFileObj)
                return;
            end
            if ~isempty(obj.SelectedScattGainFileObj.ScatteredGainCollection)
                f = userUpdatesAvailableGains( obj , 1 );
                set(f,'CloseRequestFcn', @obj.closeGainSelection);
            else
                return
            end
        end % updateSelectableScatteredGains
        
        % Callback | Edit Independant Variable List
        function updateSelectableIndependantVars( obj , ~ , ~ )
            if isempty(obj.SelectedScattGainFileObj)
                return;
            end
            if ~isempty(obj.SelectedScattGainFileObj.ScatteredGainCollection)
                f = userUpdatesAvailableGains( obj , 2 );
                set(f,'CloseRequestFcn', @obj.closeIndVarsSelection);
            else
                return;
            end
        end % updateSelectableIndependantVars
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Scheduled Gains Group %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        
        % Callback | Scheduled Gain Collection Object:
        function schGainFileSel_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                if isempty(hobj.Value)
                    obj.SelSchGainFileObjIndex = [];
                else
                    obj.SelSchGainFileObjIndex = find(strcmp(hobj.Items,hobj.Value));
                end
            else
                if hobj.getSelectedIndex < 0
                    obj.SelSchGainFileObjIndex = [];
                else
                    obj.SelSchGainFileObjIndex = hobj.getSelectedIndex + 1;
                end
            end
            setScheduledGainComboBox( obj );
            notify(obj,'SchGainFileSelected',UserInterface.ControlDesign.GainSchEventData({obj.CurrentSchGainFileObj,obj.SelectedScattGainFileObj}));
        end % schGainFileSel_CB
        
        % Callback | Add Scheduled Gain Collection Object
        function newSchedule_CB( obj , hobj , ~ )
            % Event - ControlDesignGUI newGainSourceAdd( obj , ~ , eventdata )
%             notify(obj,'GainScheduleCollAdded',UserInterface.ControlDesign.GainSchEventData([]));  
%             set(obj.ParentFigure, 'pointer', 'arrow');
            

            
            %%%%%%% Check Name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if length(obj.SchGainFileObjArray) == 1 && isempty(obj.SchGainFileObjArray.Name)
                obj.SchGainFileObjArray = ScheduledGain.SchGainCollection.empty;
            end  
            
            
            
            sizeOfGSC = length(obj.SchGainFileObjArray);
            if isempty(obj.SchGainFileObjArray)
                otherSchNames = {};
            else
                otherSchNames = {obj.SchGainFileObjArray.Name};
            end
            if isempty(obj.SelectedScattGainFileObj)
                gainSchCollName = strtrim(['GainSchColl ',num2str(sizeOfGSC + 1)]);
            else
                gainSchCollName = strtrim(['GainSchColl ',num2str(sizeOfGSC + 1)]);  %gainSchCollName = strtrim([obj.SelectedScattGainFileObj.Name,' Gain Schedule ']);
            end
            drawnow();
            answer = inputdlg('Gain Schedule Object Name:',...
                'Gain Schedule Object',...
                [1 50],...
                {gainSchCollName});
            drawnow();pause(0.5);
            
            if isempty(answer)
                return;
            elseif iscell(answer) && isempty(answer{:})
                notify(obj, 'ShowLogMessage' ,UserInterface.LogMessageEventData('Gain scheduled object name can not be empty','warn'));
                return;
            end
            if any(strcmp(strtrim(answer{:}),strtrim(otherSchNames)))
                notify(obj, 'ShowLogMessage' ,UserInterface.LogMessageEventData('Gain Schedule object name must be unique.','error'));
                return;
            else
                gainSchCollName = strtrim(answer{:});   
            end
            
            

            %%%%%%% Create New Gain Schedule Collection Object %%%%%%%%%%%%
%             if isempty(obj.SelectedScattGainFileObj) %isempty(obj.CurrentSchGainFileObj) %
                newSchGaincollObj = ScheduledGain.SchGainCollection(gainSchCollName,{}); 
%             else
%                 newSchGaincollObj = ScheduledGain.SchGainCollection(gainSchCollName,{obj.SelectedScattGainFileObj.ScatteredGainCollection(1).Gain.Name}); 
%             end
            
            setSchGainFileComboBox( obj , newSchGaincollObj);
%             setScheduledGainComboBox( obj, {} );
        end % newSchedule_CB
        
        % Callback | Remove Scheduled Gain Collection Object
        function removeSchedule_CB( obj , ~ , ~ )
            if ~isempty(obj.CurrentSchGainFileObj)
                choice = questdlg(['Would you like to remove all scheduled gain collections?'], ...%['Would you like to remove ' obj.CurrentSchGainFileObj.Name '?'], ...
                    'Remove?', ...
                    'Yes',...
                    'No','No');
                drawnow();pause(0.5);
                % Handle response
                switch choice
                    case 'Yes'
  
                        if length(obj.SchGainFileObjArray) > 1
                            obj.SchGainFileObjArray(obj.SelSchGainFileObjIndex) = [];
                            obj.SelSchGainFileObjIndex = 1;
                        elseif length(obj.SchGainFileObjArray) == 1
                            obj.SchGainFileObjArray = ScheduledGain.SchGainCollection.empty;
                            obj.SelSchGainFileObjIndex = 1;
                        end                     
                        setSchGainFileComboBox(obj);                    
                        setScheduledGainComboBox( obj );
      
                    case 'No'
                        return;
                    otherwise
                        return;
                end
                
            end
            notify(obj,'GainScheduleCollRemoved',UserInterface.ControlDesign.GainSchEventData([]));  
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % removeSchedule_CB
        
        % Callback | Export Scheduled Gain Object
        function exportSchedule_CB( obj , hobj , ~ )
            if isempty(obj.CurrentSchGainFileObj)
                return;
            end
            
            choice = questdlg('Export Format?',...
                'Export',...
                'M-File', ...
                'Mat-File', ...
                'Scheduled Gain Object',...
                'Mat-File');
            drawnow();pause(0.5);
            % Handle response
            switch choice
                case 'M-File'
                    [file,path] = uiputfile('*.m','Save File As','gains.m');
                    
                    if ~isempty(file) && ~isempty(path)
                        Utilities.writeGain2mfile( obj.CurrentSchGainFileObj , fullfile(path,file));
                    end
                case 'Mat-File'
                    [file,path] = uiputfile('*.mat','Save File As','gains.mat');
                    
                    if ~isempty(file) && ~isempty(path)
                        gainFileObj = obj.CurrentSchGainFileObj;
                        gainStruct = struct();
                        
                        for i = 1:length(gainFileObj.Gain)
                            if gainFileObj.Gain(i).Ndim == 2
                                gainStruct.(strtrim(gainFileObj.Gain(i).Name)).(strtrim(gainFileObj.Gain(i).BreakPoints1Name)) = gainFileObj.Gain(i).Breakpoints1Values;
                                gainStruct.(strtrim(gainFileObj.Gain(i).Name)).(strtrim(gainFileObj.Gain(i).BreakPoints2Name)) = gainFileObj.Gain(i).Breakpoints2Values;
                                gainStruct.(strtrim(gainFileObj.Gain(i).Name)).TableData                              = gainFileObj.Gain(i).TableData;
                            else
                                gainStruct.(strtrim(gainFileObj.Gain(i).Name)).(strtrim(gainFileObj.Gain(i).BreakPoints2Name)) = gainFileObj.Gain(i).Breakpoints2Values;
                                gainStruct.(strtrim(gainFileObj.Gain(i).Name)).TableData                              = gainFileObj.Gain(i).TableData;
                            end
                        end
                        
                        save(fullfile(path,file),'-struct','gainStruct');
                    end
                case 'Scheduled Gain Object'
                    [file,path] = uiputfile('*.mat','Save Current Gain File Object As','GainFileObj.mat');
                    if isequal(file,0) || isequal(path,0)
                        return;
                    else
                        gainFileObj = obj.CurrentSchGainFileObj; %#ok<NASGU>
                        save(fullfile(path,file),'gainFileObj');
                    end
                otherwise
                    return;
            end 
        end % exportSchedule_CB
        
        % Callback | Scheduled Gain Name:
        function schGainNameSel_CB( obj , hobj , eventdata )
            set(obj.ParentFigure, 'pointer', 'watch');

            if isprop(hobj,'Value')
                obj.SelectedScheduledGain = hobj.Value;
                obj.HContSchGainSelIndex = find(strcmp(hobj.Items,hobj.Value));
            else
                mdl = hobj.getModel;
                javaObjectEDT(mdl);
                obj.SelectedScheduledGain = char(mdl.getSelectedItem);
                obj.HContSchGainSelIndex = hobj.getSelectedIndex;
            end
            % Needs an error catch
            currentGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            
            if ~isempty(currentGain)

                % Set Dim
                obj.SelectedTableDimension  = currentGain.SchGainVec(end).NumberOfDimensions;
                updateDimCombobox( obj );
                
                
                % Set the Breakpoints Names and Values
                obj.BreakPoints1TableName = currentGain.BreakPoints1Name;
                
                if ~isempty(currentGain.Breakpoints1Values)
                    obj.BP1ValueString = mat2str(currentGain.Breakpoints1Values(end));
                else
                    obj.BP1ValueString = mat2str(currentGain.Breakpoints1Values);
                end

                obj.BreakPoints2TableName = currentGain.BreakPoints2Name;
                obj.BreakPointsString = ['{',mat2str(currentGain.Breakpoints2Values),'}'];%mat2str(currentGain.TableData(end,:));
%                 obj.BreakPointsString = currentGain.Breakpoints2ValueDisplayStr;
                % Set the PolyFit Table Data
                obj.PolyFitData = currentGain.GainFitTableData;
                
                
                resize( obj );
                update(obj);
                pause(0.1);
                % Set the Options Table Data
%                 updateTable( obj );
                notify(obj,'GainSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedGainString));
            end
            updateTable( obj );
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % schGainNameSel_CB 
        
        % Callback | Add Scheduled Gain Object
        function newSchGainName_CB( obj , hobj , ~ )
            
            if isempty(obj.CurrentSchGainFileObj) || isempty(obj.SelectedGain) || isempty(obj.IndVarString)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Select scattered gain, independent variable, and the scheduled gain collection.','warn'));
                return;
            end
            
            
            answer = inputdlg('Scheduled Gain Name:',...
                'Gain Schedule Name',...
                [1 50],...
                {[obj.SelectedGain,'Sch']});
            drawnow();pause(0.5);
            if isempty(answer)
                return;
            end
            gainName = strtrim(answer{:});   
            
            % Check for duplicates               
%             names = [obj.ScheduledGainNamesArray];
            names = {obj.CurrentSchGainFileObj.Gain.Name};
            if any(strcmp(gainName,strtrim(names)))
                notify(obj, 'ShowLogMessage' ,UserInterface.LogMessageEventData('Scheduled gain name must be unique.','error'));
                return;  
            end
            
            % Check for duplicates               
            names = {obj.CurrentSchGainFileObj.Gain.ScatteredGainName};
            if any(strcmp(obj.SelectedGain,strtrim(names)))
                notify(obj, 'ShowLogMessage' ,UserInterface.LogMessageEventData('Scheduled gain name must be scheduled with only 1 Scattered Gain. Please delete the existing scheduled gain in order to reschedule.','error'));
                return;  
            end
                 

%             % Create Scheduled Gain Vector 
            scheduledGainVector = createNewSchGainVecObj( obj );
            obj.CurrentSchGainFileObj.addNewGain( scheduledGainVector, gainName );

%             names = [obj.ScheduledGainNamesArray,gainName];
%             obj.ScheduledGainNamesArray = names;
                
            setScheduledGainComboBox( obj , gainName );           
        end % newSchGainName_CB 
        
        % Callback | Remove Scheduled Gain Object
        function rmScheduleGainName_CB( obj , ~ , ~ )
            if ~isempty(obj.SelectedScheduledGain)
                choice = questdlg(['Would you like to remove ' obj.SelectedScheduledGain '?'], ...
                    'Remove?', ...
                    'Yes',...
                    'No','No');
                drawnow();pause(0.5);
                switch choice
                    case 'Yes'
                        gain2remove = obj.SelectedScheduledGain;

                        names = obj.HCompSchGainName.Items;
                        logArray = ~strcmp(gain2remove,names);
                        names = names(logArray);
                        if ~isempty(names)
                            obj.HCompSchGainName.Items = names;
                            obj.HContSchGainSelIndex = 1;
                            obj.HCompSchGainName.Value = names{1};
                            obj.SelectedScheduledGain = names{1};
                        else
                            obj.HCompSchGainName.Items = {' '};
                            obj.HCompSchGainName.Value = ' ';
                            obj.SelectedScheduledGain = '';
                            obj.BreakPoints1TableName = '';
                            obj.BP1ValueString = '';
                            obj.BreakPoints2TableName = '';
                            obj.BreakPointsString = '';
                            obj.PolyFitData = {'1','[0,1]';'','';'','';'','';'','';};
                        end

                        lgArray = strcmp(gain2remove,{obj.CurrentSchGainFileObj.Gain.Name});
                        if any(lgArray)
                            obj.CurrentSchGainFileObj.Gain(lgArray) = [];
                        end

                        update( obj );
                        updateTable( obj );
                    case 'No'
                        return;
                    otherwise
                        return;
                end
            end
        end % rmScheduleGainName_CB
        
        % Callback | Dimension:
        function tableDim_CB( obj , hobj , ~ )

            if isprop(hobj,'Value') && ischar(hobj.Value)
                tableDimText = hobj.Value;
            else
                tableDimCell = hobj.String;
                tableDimText = tableDimCell{hobj.Value};
            end
            switch tableDimText
                case {'1-D'}
                    ndim = 1;
                case {'2-D'}
                    ndim = 2;
            end

            
            [currentGainSch,logArray] = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            
            if ~isempty(currentGainSch) && ~isempty(currentGainSch.TableData)
                if currentGainSch.Ndim ~= ndim
                    choice = questdlg(['Would you like to remove the table for ',obj.SelectedScheduledGain,' and switch dimensions?'], ...
                        'Remove?', ...
                        'Yes',...
                        'No','No');
                    drawnow();pause(0.5);
                    % Handle response
                    switch choice
                        case 'Yes'
                            obj.CurrentSchGainFileObj.Gain(logArray) = [];

                            updateTable( obj );
                        otherwise
                            switch currentGainSch.Ndim
                                case 1
                                    obj.HContTableDim.Value = '1-D';
                                case 2
                                    obj.HContTableDim.Value = '2-D';
                            end
                            pause(0.5);
                            return;
                    end
                end
            end


            obj.SelectedTableDimension = ndim;
            resize( obj , [] , [] );

            update( obj );
            %updatecurrentSchGain( obj );
        end % tableDim_CB
        
        % Callback | Break Points 1 Name:
        function bp1TableName_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                str = strtrim(hobj.Value);
            else
                str = strtrim(get(hobj,'String'));
            end
            if isvarname(str)
                obj.BreakPoints1TableName = str;
            else
                obj.BreakPoints1TableName = '';
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Breakpoints 1 Name must be a valid Matlab variable name.','warn'));
            end
            update( obj );
        end % bp1TableName_CB
        
        % Callback | Break Points 2 Name:
        function bp2TableName_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                str = strtrim(hobj.Value);
            else
                str = strtrim(get(hobj,'String'));
            end
            if isvarname(str)
                obj.BreakPoints2TableName = str;
            else
                obj.BreakPoints2TableName = '';
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Breakpoints 2 Name must be a valid Matlab variable name.','warn'));
            end
            update( obj );
        end % bp2TableName_CB
        
        % Callback | Break Points 1 Value:
        function bp1Value_CB( obj , hobj , ~ )

            if isprop(hobj,'Value')
                str = hobj.Value;
            else
                str = hobj.String;
            end
            test = str2double(str);
            if isnan(test)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Breakpoint 1 value must be convertible to a scalar number.','warn'));
                obj.BP1ValueString = [];
            else
                obj.BP1ValueString = str;
            end
            update( obj );
        end % bp1Value_CB
        
        % Callback | Break Points 2 Value:
        function bp_CB( obj , hobj , ~ )
            if isprop(hobj,'Value')
                obj.BreakPointsString = hobj.Value;
            else
                obj.BreakPointsString = get(hobj,'String');
            end
            update( obj );
        end % bp_CB
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Gain Fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Callback | Gain Fit
        function polyTable_ce_CB( obj , hobj , eventdata )
            if ~isempty(eventdata.NewData)
                temp = str2num(eventdata.NewData); %#ok<ST2NM>
                if ~isempty(temp)
                    obj.PolyFitData{eventdata.Indices(1),eventdata.Indices(2)} = eventdata.NewData;
                end
            else
                obj.PolyFitData{eventdata.Indices(1),eventdata.Indices(2)} = ''; 
            end
            update( obj );
        end % polyTable_ce_CB  
        
        function polyTable_cs_CB( obj , hobj , eventdata )
            % Working in 2017b and earlier, unknown why?
            %update( obj );
        end % polyTable_cs_CB  
        
        % Callback | Schedule
        function schedule_CB( obj , hobj , ~ )
            set(obj.ParentFigure, 'pointer', 'watch');
            
            if isempty(obj.SelectedGain)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Please select scattered gain.','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            if isempty(obj.IndVarString)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Please select independent variable.','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            
            
            % Check that all neccessary parameters exist in order for the
            % callback to run correctly. 
            fitRange = obj.FittingRange;
            invalidSort = false;
            for i = 1:length(fitRange)
                if ~issorted(fitRange{i})
                    invalidSort = true;
                end
            end
            
            if isempty(obj.SelectedScheduledGain )
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Please add a Scheduled Gain Name.','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            if invalidSort
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Fitting range must be in ascending order.','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            if obj.SelectedTableDimension == 2
                if isempty(obj.BP1ValueString)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Breakpoints 1 value is empty','warn'));
                    set(obj.ParentFigure, 'pointer', 'arrow');
                    return;
                end
            end
            if isempty( obj.CurrentSchGainFileObj)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Gain Schedule File Object is missing','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end
            if isempty(obj.BreakPoints) || isempty(obj.BreakPoints{1})
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('The number of breakpoints regions must equal the number of polynomial regions.','warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end    
            if iscell(obj.BreakPoints) && iscell(fitRange) && length(obj.BreakPoints) ~= length(fitRange) && ~isempty(fitRange)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['The number of breakpoints regions(',num2str(length(obj.BreakPoints)),') must equal the number of polynomial regions(',num2str(length(fitRange)),').'],'warn'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                return;
            end     
            
            
            if obj.SelectedTableDimension == 2
                if isempty(obj.BreakPoints1TableName) || isempty(obj.BreakPoints2TableName)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('The breakpoints names must be specified.','warn'));
                    set(obj.ParentFigure, 'pointer', 'arrow');
                    return;
                end  

            else
                if isempty(obj.BreakPoints2TableName)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('The breakpoints names must be specified.','warn'));
                    set(obj.ParentFigure, 'pointer', 'arrow');
                    return;
                end  
  
            end
            
            % Check if Selected Scattered Gain is already being scheduled
            ireturn=0;
            existingGainSch = findGain( obj.CurrentSchGainFileObj , obj.SelectedGain ); % this finds the gain based on the scattered gain name
            if ~isempty(existingGainSch)
                if length(existingGainSch) > 1 || ~strcmp(existingGainSch.Name,obj.SelectedScheduledGain) || ~strcmp(existingGainSch.ScatteredGainName,obj.SelectedGain)
                   notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData([existingGainSch.Name ' is already being scheduled with ' existingGainSch.ScatteredGainName],'error')); 
                   set(obj.ParentFigure, 'pointer', 'arrow');
                   ireturn =1;
                end
            end
            
            existingGainSch = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            if ~isempty(existingGainSch) && ~strcmp(existingGainSch.ScatteredGainName,obj.SelectedGain)
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData([existingGainSch.Name ' is already being scheduled with ' existingGainSch.ScatteredGainName],'error'));
                set(obj.ParentFigure, 'pointer', 'arrow');
                ireturn = 1;
            end
            
            if ireturn
                return
            end
           
            
            % Check if Scheduled Gain Name exists and check history of the
            % previously stored data
            if ~isempty(findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain ))
                % Check if Selected Scattered Gain Name changed
                currentGainSch = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
                
%                 % Check if table dimensions match
%                 if obj.SelectedTableDimension ~= currentGainSch(1).Ndim
%                     notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Table Dimension is not compatible with previously stored data for ' obj.SelectedScheduledGain],'error'));
%                     set(obj.ParentFigure, 'pointer', 'arrow');
%                     return;
%                 end
                
                % Check following only if table dimension is 2-D
                if obj.SelectedTableDimension ==2
%                     if (length(currentGainSch.SchGainVec)==1 && currentGainSch.SchGainVec.BreakPoints1~=str2double(obj.BP1ValueString)) || (length(currentGainSch.SchGainVec)>1)
                    if length(currentGainSch.SchGainVec)==1
                        % Check if Selected Scattered Gain Expression matches
                        if ~(currentGainSch.SchGainVec(1).ScatteredGainExpression == obj.GainExpression)%~strcmp(currentGainSch.SchGainVec(1).ScatteredGainExpression,obj.GainExpression)
                            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Scattered gain expression is not compatible with previously stored data for ' obj.SelectedScheduledGain],'error'));
                            set(obj.ParentFigure, 'pointer', 'arrow');
                            return;
                        end
                        
                        % Check if Independent variable expression matches
                        if ~(currentGainSch.SchGainVec(1).BreakPoints2Expression == obj.IndVarExpression)%~strcmp(currentGainSch.SchGainVec(1).BreakPoints2Expression,obj.IndVarExpression)
                            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Independent variable expression is not compatible with previously stored data for ' obj.SelectedScheduledGain],'error'));
                            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['',currentGainSch.SchGainVec(1).BreakPoints2Expression.OriginalString,'',' is the independant variable expression being used.'],'error'));
                            set(obj.ParentFigure, 'pointer', 'arrow');
                            return;
                        end
                        
                        % Get total of all Breakpoints in cell arrays 
                        % Fixed for different multiple regions within a 2d
                        bpCell = obj.BreakPoints;
                        bp = [];
                        for i = 1:length(bpCell)
                            bp = [bp , bpCell{i}];
                        end
                        bp = sort(bp);
                        % Check if BreakPoints 2 Values changed

                        if ~isempty(currentGainSch.SchGainVec(1).BreakPoints2)
                            if length(bp) == length(currentGainSch.SchGainVec(1).BreakPoints2) && ~all(round(bp,10,'significant') == round(currentGainSch.SchGainVec(1).BreakPoints2,10,'significant')) || ...
                                    length(bp) ~= length(currentGainSch.SchGainVec(1).BreakPoints2)
                                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Break points 2 values are not compatible with previously stored data for ' obj.SelectedScheduledGain],'error'));
                                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Current Break points 2 values are: ' num2str(currentGainSch.SchGainVec(1).BreakPoints2)],'error'));
                                set(obj.ParentFigure, 'pointer', 'arrow');
                                return;
                            end
                        end
                    end     
                end
            end
            
            if ~isempty(obj.XData) && ~isempty(obj.BreakPoints)
                
                % Create Scheduled Gain Vector 
                scheduledGainVector = createNewSchGainVecObj( obj );
                
                update(obj);

                % Poly fit also sets the scheduled gain values of the
                % gainschvec object.  Each time polyfit the gain and line
                % data gets updated.

                polyfit( scheduledGainVector , obj.FilteredScatteredGains , obj.IncludedInFit );
                
                %----------------------------------------------------------
                obj.CurrentSchGainFileObj.updateGain( scheduledGainVector );
                
                currentGain = findGain( obj.CurrentSchGainFileObj , obj.SelectedGain );     
                %----------------------------------------------------------
                
                % Save last polyfit table data
                currentGain.GainFitTableData = obj.PolyFitData;
              
                pfLineH3 = [];
                pfLineH3(end+1) = line(scheduledGainVector.Line3.XData,scheduledGainVector.Line3.YData,...
                    'Parent',obj.axH,...
                    'Color',str2num('0,114.4320,189.6960')/256,...%[1,0,0],...
                    'Marker','sq',...
                    'MarkerSize',10,...
                    'MarkerFaceColor',str2num('0,114.4320,189.6960')/256,...%[1,0,0],...
                    'MarkerEdgeColor',str2num('0,114.4320,189.6960')/256,...%[1,0,0],...
                    'LineStyle','-',... 
                    'Visible','on',...
                    'LineWidth',2); %#ok<ST2NM>
                

                % Update the Color property of all the curves
                clrCount = 1;
                for i = 1:length(currentGain.SchGainVec)
                    clrVec = defaultColors( clrCount );
                    if currentGain.SchGainVec(i).Current
                        currentGain.SchGainVec(i).Color    = '0,114.4320,189.6960';
                        currentGain.SchGainVec(i).Selected = true;
                    else
                        currentGain.SchGainVec(i).Color = [int2str(clrVec(1)),',',int2str(clrVec(2)),',',int2str(clrVec(3))]; 
                        clrCount = clrCount + 1;
                        currentGain.SchGainVec(i).Selected = false;
                    end
                end
                
                %----------------------------------------------------------
             
                obj.PolyFitLineH = [obj.PolyFitLineH,pfLineH3]; 
               

                updateTable( obj );
                
                notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Scheduling completed.'],'info'));
            end
            
            drawnow();
            %notify(obj,'AutoSaveFile');
            drawnow();
            set(obj.ParentFigure, 'pointer', 'arrow');
        end % schedule_CB 
        
        % Callback | Clear Schedule
        function removeSch_CB( obj , hobj , ~ )
            update(obj);
        end % removeSch_CB

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Callback | Option Table
        function dataUpdatedInTable( obj , src , event )
            modifiedRow = event.Indices(1);
            modifiedCol = event.Indices(2);
            newData = event.NewData;

            currentGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            rowCount = size(src.Data,1);
            if isempty(currentGain)
                return;
            end

            if rowCount == 1
                modifiedSchGainVec = currentGain.SchGainVec(1);
            else
                sortOrderBreakPoints1 = currentGain.SortOrderBreakPoints1;
                ind = sortOrderBreakPoints1(modifiedRow);
                modifiedSchGainVec = currentGain.SchGainVec(ind);
            end

            switch modifiedCol
                case 1
                    modifiedSchGainVec.Selected = newData;

                    if modifiedSchGainVec.Selected
                        pfLineH3 = line(modifiedSchGainVec.Line3.XData,modifiedSchGainVec.Line3.YData,...
                            'Parent',obj.axH,...
                            'Color',[str2num(modifiedSchGainVec.Color)/256,0.5],...
                            'Marker','o',...
                            'MarkerSize',6,...
                            'MarkerFaceColor',str2num(modifiedSchGainVec.Color)/256,...
                            'MarkerEdgeColor',str2num(modifiedSchGainVec.Color)/256,...
                            'LineStyle','-',...
                            'Visible','on',...
                            'LineWidth',2); %#ok<ST2NM>
                        modifiedSchGainVec.LineH = pfLineH3;
                        obj.PolyFitLineH = [obj.PolyFitLineH,pfLineH3];
                    else
                        try
                            delete(modifiedSchGainVec.LineH);
                        end
                    end
            end
        end % dataUpdatedInTable
        
        function mousePressedInTable( obj , hobj , eventdata) 
            
        end % mousePressedInTable
        
        % Callback | Plot Table
        function viewTable_CB( obj , hobj , eventdata) 
            currentGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            %currentGain = findGain( obj.CurrentSchGainFileObj , obj.SelectedGain );
            if isempty(currentGain)
                return;
            end
            figure;
            Z = currentGain.TableData;
            b = currentGain.Breakpoints1Values;
            c = currentGain.Breakpoints2Values;
            
            %[X,Y] = meshgrid(b,c);
            if (currentGain.SchGainVec(1).NumberOfDimensions==2 && ...
                    size(Z,1)>1)
                Z = currentGain.TableData;
                b = currentGain.Breakpoints1Values;
                c = currentGain.Breakpoints2Values;
                
                %[X,Y] = meshgrid(b,c);
                if all([length(b),length(c)] == size(Z))
                    surf(c,b,Z);
                else
                    surf(b,c,Z);
                end
                ylabel(strrep(currentGain.BreakPoints1Name,'_','\_'));
                xlabel(strrep(currentGain.BreakPoints2Name,'_','\_'));
                title(strrep(currentGain.Name,'_','\_'));
            else
                y = currentGain.TableData;
                x = currentGain.Breakpoints2Values;
                plot(x,y,'-sq','LineWidth',3);
                grid on;
                xlabel(strrep(currentGain.BreakPoints2Name,'_','\_'));
                ylabel(strrep(currentGain.Name,'_','\_'));
            end
        end % viewTable_CB
        
        % Callback | Remove
        function removeRowGainTable( obj , hobj , eventdata) 
            
            [currentGain,logArray] = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            if isempty(currentGain)
                return;
            end
            checkedGainSchVec = [currentGain.SchGainVec.Selected];
            
            if any(checkedGainSchVec)
                answer = questdlg('Do you want to remove the selected rows of the table?',...
                    'Remove?','Yes','No','No');
                drawnow();pause(0.5);
                if strcmp(answer,'Yes')
                    if all(checkedGainSchVec)
                        obj.CurrentSchGainFileObj.Gain(logArray) = [];
                    else
                        currentGain.SchGainVec(checkedGainSchVec) = [];
                    end
                elseif strcmp(answer,'No')
                    return;
                end
                
                %sortOrderBreakPoints1 = currentGain.SortOrderBreakPoints1;
                %currentGain.SchGainVec(~uncheckedGainSchVec(sortOrderBreakPoints1)) = [];
                updateTable( obj );
                update(obj);
            else
                warndlg('Please select at least one row of the table.');
                return;
            end
        end % removeRowGainTable
        
        % Callback | Export Table
        function exportTable_CB( obj , hobj , eventdata) 

            currentGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            if isempty(currentGain)
                return;
            end
            checkedGainSchVec = [currentGain.SchGainVec.Selected];
            currentGainCopy = copy( currentGain );
            currentGainCopy.SchGainVec(~checkedGainSchVec) = [];
            
%             choice = questdlg('Export Format?',...
%                 'Export',...
%                 'M-File', ...
%                 'Mat-File', ...
%                 'Simulink Block', ...
%                 'Mat-File');
            choice = questdlg('Export Format?',...
                'Export',...
                'M-File', ...
                'Mat-File', ...
                'Mat-File');
            drawnow();pause(0.5);
            % Handle response
            switch choice
                case 'M-File'
                    [file,path] = uiputfile('*.m','Save File As','gains.m');
                    
                    if ~isempty(file) && ~isempty(path)
                        Utilities.writeGain2mfile( currentGainCopy , fullfile(path,file));
                    end
                case 'Mat-File'
                    [file,path] = uiputfile('*.mat','Save File As','gains.mat');
                    
                    if ~isempty(file) && ~isempty(path)
                        gainStruct = struct();
                        
                        for i = 1:length(currentGainCopy)
                            if currentGainCopy(i).Ndim == 2
                                gainStruct.(strtrim(currentGainCopy(i).Name)).(strtrim(currentGainCopy(i).BreakPoints1Name)) = currentGainCopy(i).Breakpoints1Values;
                                gainStruct.(strtrim(currentGainCopy(i).Name)).(strtrim(currentGainCopy(i).BreakPoints2Name)) = currentGainCopy(i).Breakpoints2Values;
                                gainStruct.(strtrim(currentGainCopy(i).Name)).TableData                              = currentGainCopy(i).TableData;
                            else
                                gainStruct.(strtrim(currentGainCopy(i).Name)).(strtrim(currentGainCopy(i).BreakPoints2Name)) = currentGainCopy(i).Breakpoints2Values;
                                gainStruct.(strtrim(currentGainCopy(i).Name)).TableData                              = currentGainCopy(i).TableData;
                            end
                        end
                        
                        save(fullfile(path,file),'-struct','gainStruct');
                    end
                case 'Simulink Block' 
                    %gainSchCollObj = schNode.handle.UserData;
                    %gainSchObj = findGainScatt(gainSchCollObj,name);
                    createSimulinkBlock( currentGainCopy );
                case 'Object'
                    [file,path] = uiputfile('*.mat','Save Current Gain File Object As','GainFileObj.mat');
                    if isequal(file,0) || isequal(path,0)
                        return;
                    else
                        save(fullfile(path,file),'currentGainCopy');
                    end
                otherwise
                    return;
            end 
        end % exportTable_CB
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Axis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Callback | Line Objects
        function axisButtonDown( obj , hobj , eventData )
            Cp = get(obj.axH,'CurrentPoint');
            Xp = Cp(2,1);  % X-point
            Yp = Cp(2,2);  % Y-point 
            [~,Ip] = min((obj.XData-Xp).^2+(obj.YData-Yp).^2);
            obj.IncludedInFit(Ip) = ~obj.IncludedInFit(Ip);
            updatePlot( obj );
        end % axisButtonDown    
        
        function popUpSchedule(obj, hobj, eventdata)
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );

            
            addIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'New_16.png'));
            removeIcon  = javaObjectEDT('javax.swing.ImageIcon',fullfile(icon_dir,'StopX_16.png'));

            jmenu = javaObjectEDT('javax.swing.JPopupMenu');

            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Add',addIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',@obj.newSchedule_CB);


            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove',removeIcon);
            menuItem2h = handle(menuItem2,'CallbackProperties');
            set(menuItem2h,'ActionPerformedCallback',@obj.removeSchedule_CB); 
            
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);

            
            jmenu.show(hobj, 0 , 20 );
            jmenu.repaint;    
        end  % popUpSchedule()
        
    end
    
    %% Methods - Set ComboBoxes
    methods                 

        function setScheduledGainComboBox( obj , gainName )

            if isempty(obj.CurrentSchGainFileObj)
                if isa(obj.HCompSchGainName,'matlab.ui.control.DropDown')
                    obj.HCompSchGainName.Items = {' '};
                    obj.HCompSchGainName.Value = ' ';
                else
                    model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                    obj.HCompSchGainName.setModel(model);
                end
                obj.HContSchGainSelIndex = 0;
                obj.SelectedScheduledGain = '';
                drawnow(); pause(0.01);

            else
                if nargin == 2
                    if any(strcmp(gainName,obj.ScheduledGainNamesArray))
                        notify(obj,'ShowLogMessage' ,UserInterface.LogMessageEventData('Gain name must be unique.','error'));
                        notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Scheduling completed.'],'info'));
                        return;
                    end
                    obj.ScheduledGainNamesArray = [obj.ScheduledGainNamesArray,gainName];
                end

                if ~isempty(obj.CurrentSchGainFileObj.Gain)
                    schGainNames = {obj.CurrentSchGainFileObj.Gain.Name};
                    if isa(obj.HCompSchGainName,'matlab.ui.control.DropDown')
                        obj.HCompSchGainName.Items = schGainNames;
                        obj.HCompSchGainName.Value = schGainNames{end};
                    else
                        model = javaObjectEDT('javax.swing.DefaultComboBoxModel',schGainNames);
                        obj.HCompSchGainName.setModel(model);
                        obj.HCompSchGainName.setSelectedIndex(length(schGainNames) - 1);
                    end
                    obj.HContSchGainSelIndex = length(obj.CurrentSchGainFileObj.Gain) - 1;
                    obj.SelectedScheduledGain = schGainNames{end};
                else
                    if isa(obj.HCompSchGainName,'matlab.ui.control.DropDown')
                        obj.HCompSchGainName.Items = {' '};
                        obj.HCompSchGainName.Value = ' ';
                    else
                        model = javaObjectEDT( 'javax.swing.DefaultComboBoxModel' );
                        obj.HCompSchGainName.setModel(model);
                    end
                    obj.HContSchGainSelIndex = 0;
                    obj.SelectedScheduledGain = '';
                end
            end
            updateTable( obj );

        end % setScheduledGainComboBox
        
        function setSchGainFileComboBox( obj , schGainObjs )
            % Called from ControlDesignGUI.m when a scheduled gain
            % collection object is loaded into the tree
            if nargin == 2
                obj.SchGainFileObjArray(end +1) = schGainObjs;
            end

            if ~isempty(obj.SchGainFileObjArray)
                cellstr = {obj.SchGainFileObjArray.Name};
                if isa(obj.HCompSelSchFile,'matlab.ui.control.DropDown')
                    obj.HCompSelSchFile.Items = cellstr;
                    obj.HCompSelSchFile.Value = cellstr{end};
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',cellstr);
                    obj.HCompSelSchFile.setModel(model);
                    obj.HCompSelSchFile.setSelectedIndex(length(cellstr) - 1);
                end
                obj.SelSchGainFileObjIndex = length(cellstr);

            else
                if isa(obj.HCompSelSchFile,'matlab.ui.control.DropDown')
                    obj.HCompSelSchFile.Items = {''};
                    obj.HCompSelSchFile.Value = '';
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
                    obj.HCompSelSchFile.setModel(model);
                end
                obj.SelSchGainFileObjIndex = [];
            end
        end % setSchGainFileComboBox
        
        function setScatteredGainFileComboBox( obj )
            if ~isempty(obj.ScattGainFileObjArray)
                cellstr = {obj.ScattGainFileObjArray.Name};
                if isa(obj.HCompScatGainFile,'matlab.ui.control.DropDown')
                    obj.HCompScatGainFile.Items = cellstr;
                    obj.HCompScatGainFile.Value = cellstr{1};
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',cellstr);
                    obj.HCompScatGainFile.setModel(model);
                end
                obj.SelScattGainObjIndex = 1;
            else
                if isa(obj.HCompScatGainFile,'matlab.ui.control.DropDown')
                    obj.HCompScatGainFile.Items = {''};
                    obj.HCompScatGainFile.Value = '';
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
                    obj.HCompScatGainFile.setModel(model);
                end
                obj.SelScattGainObjIndex = [];
            end
        end % setScatteredGainFileComboBox
        
        function setScattGainFileComboBox( obj , scattGainFileObj )
            % Called from ControlDesignGUI.m when a scattered gain file
            % object is loaded into the tree

            obj.ScattGainFileObjArray = scattGainFileObj;

            cellstr = {obj.ScattGainFileObjArray.Name};
            if isa(obj.HCompScatGainFile,'matlab.ui.control.DropDown')
                obj.HCompScatGainFile.Items = cellstr;
                if ~isempty(obj.SelScattGainObjIndex)
                    obj.HCompScatGainFile.Value = cellstr{obj.SelScattGainObjIndex};
                else
                    obj.SelScattGainObjIndex = 1;
                    obj.HCompScatGainFile.Value = cellstr{1};
                end
            else
                model = javaObjectEDT('javax.swing.DefaultComboBoxModel',cellstr);
                obj.HCompScatGainFile.setModel(model);
                if ~isempty(obj.SelScattGainObjIndex)
                    obj.HCompScatGainFile.setSelectedIndex(obj.SelScattGainObjIndex -1);
                else
                    obj.SelScattGainObjIndex = 1;
                    obj.HCompScatGainFile.setSelectedIndex(obj.SelScattGainObjIndex -1);
                end
            end

            notify(obj,'ScatteredGainFileSelected',UserInterface.ControlDesign.GainSchEventData(obj.SelectedScattGainFileObj));
        end % setScattGainFileComboBox
        
        function setGainSelectionComboBox( obj )
            if ~isempty(obj.FilteredScatteredGains) && ~isempty(obj.SelScatteredGainList)
                avlGain = {obj.SelScatteredGainList.Name};
                if isa(obj.HCompGainSel,'matlab.ui.control.DropDown')
                    obj.HCompGainSel.Items = avlGain;
                    obj.HCompGainSel.Value = avlGain{1};
                    obj.SelectedGainString = avlGain{1};
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',avlGain);
                    obj.HCompGainSel.setModel(model);
                    obj.SelectedGainString = obj.HCompGainSel.getSelectedItem;
                end
                obj.SelectedGainIndex = 1;
            else
                if isa(obj.HCompGainSel,'matlab.ui.control.DropDown')
                    obj.HCompGainSel.Items = {''};
                    obj.HCompGainSel.Value = '';
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
                    obj.HCompGainSel.setModel(model);
                end
                obj.SelectedGainIndex = [];
                obj.SelectedGainString = [];
            end
            obj.SelectedGain = obj.SelectedGainString;
        end % setGainSelectionComboBox
                  
        function setIndVarComboBox( obj )
            if ~isempty(obj.FilteredScatteredGains) && ~isempty(obj.SelIndVarsList)
                inVarSel = {obj.SelIndVarsList.Name};
                if isa(obj.HCompIndVar,'matlab.ui.control.DropDown')
                    obj.HCompIndVar.Items = inVarSel;
                    obj.HCompIndVar.Value = inVarSel{1};
                    obj.IndVarString = inVarSel{1};
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',inVarSel);
                    obj.HCompIndVar.setModel(model);
                    obj.IndVarString = obj.HCompIndVar.getSelectedItem;
                end
                obj.IndVarSelectedIndex = 1;
            else
                if isa(obj.HCompIndVar,'matlab.ui.control.DropDown')
                    obj.HCompIndVar.Items = {''};
                    obj.HCompIndVar.Value = '';
                else
                    model = javaObjectEDT('javax.swing.DefaultComboBoxModel',{''});
                    obj.HCompIndVar.setModel(model);
                end
                obj.IndVarSelectedIndex = [];
                obj.IndVarString = '';
            end
        end % setIndVarComboBox
        
        function updateDimCombobox( obj )
            if isa(obj.HContTableDim,'matlab.ui.control.DropDown')
                items = obj.HContTableDim.Items;
                obj.HContTableDim.Value = items{obj.SelectedTableDimension};
            else
                obj.HContTableDim.Value = obj.SelectedTableDimension;
            end
        end % updateDimCombobox
               
    end
    
    %% Methods - Protected(Update)
    methods (Access = protected)       
   
        function filteredGainsUpdated( obj , ~ , eventData )
            % This method is called from the Gains Filter when the user
            % selects different gains
            obj.PrivateFilteredScatteredGains = eventData.Object;
            if isempty(obj.SelectedGain)
                setGainSelectionComboBox( obj );
                setIndVarComboBox( obj );
            end
            update( obj );
        end % filteredGainsUpdated
        
        function update(obj)
        
            % Set Gain Fit Table
            obj.PolyFitTable.Data = obj.PolyFitData;
            
            % Set Dimension
            switch obj.SelectedTableDimension
                case 1%
                    obj.TextBP2NameCont.Visible = 'off';
                    obj.BP1Name_eb.Visible = 'off';
                    
                    obj.TextBPCont.Visible = 'off';
                    obj.BP1ValueString_eb.Visible = 'off';
                    

                    
                case 2
                    
                    obj.TextBP2NameCont.Visible = 'on';
                    obj.BP1Name_eb.Visible = 'on';
                    
                    obj.TextBPCont.Visible = 'on';
                    obj.BP1ValueString_eb.Visible = 'on';
                    
             end
            
            % Set Breakpoints 1
%             set(obj.BP1ValueString_eb,'String',obj.BP1ValueString);
                       
            % Set Breakpoints 1 Name
            set(obj.BP1Name_eb,'Value', obj.BreakPoints1TableName);
            
            % Set Breakpoints 2 Name
            set(obj.BP2Name_eb,'Value', obj.BreakPoints2TableName);
                      
            % Set Breakpoints Values
            set(obj.BP_eb,'Value', obj.BreakPointsString);

            % Update the Plot
            obj.IncludedInFit = true(1,length(obj.FilteredScatteredGains));
            
            updatePlot( obj );

        end % update
        
        function updatecurrentSchGain(obj)
        
            if isempty(obj.SelectedScheduledGain)
                return;
            end
            currSchGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );
            
            if ~isempty(currSchGain)
                if isempty(currSchGain.BreakPoints1Name)
                    currSchGain.BreakPoints1Name   = obj.BreakPoints1TableName;
                end
                if isempty(currSchGain.Breakpoints1Values)
                    currSchGain.Breakpoints1Values = obj.BP1ValueString;  
                end
                if isempty(currSchGain.BreakPoints2Name)
                    currSchGain.BreakPoints2Name   = obj.BreakPoints2TableName;
                end
                if isempty(currSchGain.Breakpoints2Values)
                    currSchGain.Breakpoints2Values = obj.BreakPoints;
                end
            end
%                                     obj.SelectedGain ,...
%                                         obj.SelectedGainString,...
%                                         obj.GainExpression ,...
%                                         obj.SelectedScheduledGain  ,...
%                                         obj.SelectedTableDimension ,...
%                                         obj.BP1ValueString,...
%                                         obj.IndVarString,...
%                                         obj.IndVarExpression,...
%                                         obj.BreakPoints1TableName,...
%                                         obj.BreakPoints2TableName,...
%                                         'Polynomial',...
%                                         obj.FittingRange,...
%                                         obj.BreakPoints,...
%                                         obj.PolyDegreeValue,...
%                                         scatteredGainsCopy,...
%                                         obj.IncludedInFit);

        end % updatecurrentSchGain

        function updatePlot( obj )
            
            if isempty(obj.axH)
                obj.axH = obj.GainSchAxisColl.AxisHandleQueue.pop;
            end
            if ~isempty(obj.LineH) && all(ishandle(obj.LineH))
                delete(obj.LineH);
                obj.LineH = [];
            end
            if ~isempty(obj.PolyFitLineH)% && all(ishandle(obj.PolyFitLineH))
                delete(obj.PolyFitLineH(ishandle(obj.PolyFitLineH)));
                obj.PolyFitLineH = [];
            end
            
            % AutoScale Plot
            set(obj.axH,'XLimMode','auto');
            set(obj.axH,'YLimMode','auto');
            set(obj.axH,'ZLimMode','auto');

            plotXData = obj.XData;
            plotYData = obj.YData;

            if ~isempty(plotXData) && ~isempty(plotYData)
                for i = 1:length(plotXData)
                    obj.LineH(i) = line(plotXData(i),plotYData(i),...
                        'Parent',obj.axH,...
                        'Color',[0,0,0],...
                        'Marker','o',...
                        'MarkerSize',6,...
                        'MarkerFaceColor',obj.GainPlotColor{i}/255,...
                        'LineStyle','none',... 
                        'LineWidth',2);
                end
            end
            
            if ~isempty(obj.IndVarString) 
                set(get(obj.axH,'XLabel'),'String',strrep(obj.IndVarString,'_','\_'));
            end
            
            if ~isempty(obj.SelectedGainString)
                set(get(obj.axH,'YLabel'),'String',strrep(obj.SelectedGainString,'_','\_'));
            end

            set(obj.axH,'XGrid','on');
            set(obj.axH,'YGrid','on');



            if ~isempty(obj.ExLineH) && any(ishandle(obj.ExLineH))
                delete(obj.ExLineH(ishandle(obj.ExLineH)));
            end

            exPlotXData = plotXData(~obj.IncludedInFit);
            exPlotYData = plotYData(~obj.IncludedInFit);
            % Plot excluded points
            obj.ExLineH = line(exPlotXData,exPlotYData,...
                'Parent',obj.axH,...
                'Color',[0,0,0],...
                'Marker','x',...
                'MarkerSize',14,...
                'MarkerEdgeColor',[1,0,0],...
                'LineStyle','none',... 
                'LineWidth',2);
            if ~isempty(obj.ExLineH)
                set(obj.ExLineH,'ButtonDownFcn',@obj.axisButtonDown);
            end
            set(obj.LineH,'ButtonDownFcn',@obj.axisButtonDown);
            drawnow();
        end % updatePlot                      
        
        function updateTable( obj )

            % *************************************************************
            % ************ Create Options Table Data **********************
            % *************************************************************
            if ~isempty(obj.CurrentSchGainFileObj) && ~isempty(obj.SelectedScheduledGain)
                currentGain = findGainByUserName( obj.CurrentSchGainFileObj , obj.SelectedScheduledGain );

                if ~isempty(currentGain) && ~isempty(currentGain.SchGainVec(1).ScheduledGain)

                    tempOptionsTableData = [num2cell(currentGain.Breakpoints1Values)',num2cell(currentGain.TableData)];
                    tempOptionsTableData = cellfun(@(x) num2str(x), tempOptionsTableData, 'UniformOutput', false);

                    schGainVec = currentGain.SchGainVec;

                    if currentGain.Ndim == 2
                        for i = 1:length(schGainVec)
                            sortOrderBreakPoints1 = currentGain.SortOrderBreakPoints1;
                            colorSelectedCell{i,1} = schGainVec(sortOrderBreakPoints1(i)).Selected;
                            colorSelectedCell{i,2} = schGainVec(sortOrderBreakPoints1(i)).Color;
                        end
                    else
                        for i = 1:length(schGainVec)
                            sortOrderBreakPoints2 = currentGain.SortOrderBreakPoints2;
                            colorSelectedCell{i,1} = schGainVec(sortOrderBreakPoints2(i)).Selected;
                            colorSelectedCell{i,2} = schGainVec(sortOrderBreakPoints2(i)).Color;
                        end
                    end

                    if obj.SelectedTableDimension == 1 && currentGain.Ndim ~= 2
                        OptionsTableData = [colorSelectedCell,' ',tempOptionsTableData];
                    else
                        OptionsTableData = [colorSelectedCell,tempOptionsTableData];
                    end

                    tempOptionsTableHeader = num2cell(currentGain.Breakpoints2Values);
                    OptionsTableHeader = cellfun(@(x) num2str(x), tempOptionsTableHeader, 'UniformOutput', false);
                    OptionsTableHeader = [' ',{' ',' '},OptionsTableHeader];
                else
                    OptionsTableData = {true,'255,255,255',' ',' ',' ';...
                                        true,'255,255,255',' ',' ',' ';...
                                        true,'255,255,255',' ',' ',' ';...
                                        true,'255,255,255',' ',' ',' ';...
                                        true,'255,255,255',' ',' ',' '};
                    OptionsTableHeader = {' ',' ',' ',' ',' '};
                end
            else
                OptionsTableData = {true,'255,255,255',' ',' ',' ';...
                                    true,'255,255,255',' ',' ',' ';...
                                    true,'255,255,255',' ',' ',' ';...
                                    true,'255,255,255',' ',' ',' ';...
                                    true,'255,255,255',' ',' ',' '};
                OptionsTableHeader = {' ',' ',' ',' ',' '};
            end
            % **************************END********************************
            % ************ Create Options Table Data **********************
            % *************************************************************

            delete(obj.HContainer);

            obj.JTable = uitable('Parent',obj.OptionsPanel,...
                'Data',OptionsTableData,...
                'ColumnName',OptionsTableHeader,...
                'ColumnEditable',true(1,size(OptionsTableData,2)),...
                'CellEditCallback',@obj.dataUpdatedInTable,...
                'CellSelectionCallback',@obj.mousePressedInTable);
            obj.HContainer = obj.JTable;
        end % updateTable
        
        function f = userUpdatesAvailableGains( obj , callingFunctionType )
            
            scattGainColl = obj.SelectedScattGainFileObj.ScatteredGainCollection(1);

            import UserInterface.uiextras.jTree.*
            f  = figure('Name','Gain Selection',...
                                    'units','pixels',...
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...%
                                    'WindowStyle','modal',...
                                    'Resize','off');%,...
                                    %'CloseRequestFcn', @obj.closeGainSelection);
            % Resize and reposition the window
            width = 300;
            height = 465;
            pos = getpixelposition(f);
            f.Position = [ pos(1) , pos(2) , width , height ];         
                                
            tree = CheckboxTree('Parent',f);
            tree.RootVisible= false;
            obj.Tree = tree;
            tree.Visible = false;
            % Gain tree nodes
            gainNode = CheckboxTreeNode('Name','Gain','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.Gain)
                if isnumeric(scattGainColl.Gain(i).Value) && isscalar(scattGainColl.Gain(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.Gain(i).Name,'Parent',gainNode,'Value',['Gain(',int2str(i),').Value']);
                end
            end

            % SynthesisDesignParameter tree nodes
            synDesNode = CheckboxTreeNode('Name','Synthesis Design Parameters','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.SynthesisDesignParameter)
                if isnumeric(scattGainColl.SynthesisDesignParameter(i).Value) && isscalar(scattGainColl.SynthesisDesignParameter(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.SynthesisDesignParameter(i).Name,'Parent',synDesNode,'Value',['SynthesisDesignParameter(',int2str(i),').Value']);
                end
            end

            % RequirementDesignParameter tree nodes
            reqDesNode = CheckboxTreeNode('Name','Requirement Design Parameters','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.RequirementDesignParameter)
                if isnumeric(scattGainColl.RequirementDesignParameter(i).Value) && isscalar(scattGainColl.RequirementDesignParameter(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.RequirementDesignParameter(i).Name,'Parent',reqDesNode,'Value',['RequirementDesignParameter(',int2str(i),').Value']);
                end
            end


            % Filter tree nodes
            filterNode = CheckboxTreeNode('Name','Filter Parameters','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.Filters)
                filterSubNode = CheckboxTreeNode('Name',scattGainColl.Filters(i).Name,'Parent',filterNode,'Value','Root');
                if ~isempty(scattGainColl.Filters(i).CenterFrequency) && isnumeric(scattGainColl.Filters(i).CenterFrequency) && isscalar(scattGainColl.Filters(i).CenterFrequency)
                    CheckboxTreeNode('Name','CenterFrequency','Parent',filterSubNode,'Value',['Filters(',int2str(i),').CenterFrequency']);
                end
                if ~isempty(scattGainColl.Filters(i).CenterAttenuation) && isnumeric(scattGainColl.Filters(i).CenterAttenuation) && isscalar(scattGainColl.Filters(i).CenterAttenuation)
                    CheckboxTreeNode('Name','CenterAttenuation','Parent',filterSubNode,'Value',['Filters(',int2str(i),').CenterAttenuation']);
                end
                if ~isempty(scattGainColl.Filters(i).SecondFrequency) && isnumeric(scattGainColl.Filters(i).SecondFrequency) && isscalar(scattGainColl.Filters(i).SecondFrequency)
                    CheckboxTreeNode('Name','SecondFrequency','Parent',filterSubNode,'Value',['Filters(',int2str(i),').SecondFrequency']);
                end
                if ~isempty(scattGainColl.Filters(i).SecondAttenuation) && isnumeric(scattGainColl.Filters(i).SecondAttenuation) && isscalar(scattGainColl.Filters(i).SecondAttenuation)
                    CheckboxTreeNode('Name','SecondAttenuation','Parent',filterSubNode,'Value',['Filters(',int2str(i),').SecondAttenuation']);
                end
                if ~isempty(scattGainColl.Filters(i).DCGain) && isnumeric(scattGainColl.Filters(i).DCGain) && isscalar(scattGainColl.Filters(i).DCGain)
                    CheckboxTreeNode('Name','DCGain','Parent',filterSubNode,'Value',['Filters(',int2str(i),').DCGain']);
                end
                if ~isempty(scattGainColl.Filters(i).HFGain) && isnumeric(scattGainColl.Filters(i).HFGain) && isscalar(scattGainColl.Filters(i).HFGain)
                    CheckboxTreeNode('Name','HFGain','Parent',filterSubNode,'Value',['Filters(',int2str(i),').HFGain']);
                end
                if ~isempty(scattGainColl.Filters(i).Frequency) && isnumeric(scattGainColl.Filters(i).Frequency) && isscalar(scattGainColl.Filters(i).Frequency)
                    CheckboxTreeNode('Name','Frequency','Parent',filterSubNode,'Value',['Filters(',int2str(i),').Frequency']);
                end
                if ~isempty(scattGainColl.Filters(i).Phase) && isnumeric(scattGainColl.Filters(i).Phase) && isscalar(scattGainColl.Filters(i).Phase)
                    CheckboxTreeNode('Name','Phase','Parent',filterSubNode,'Value',['Filters(',int2str(i),').Phase']);
                end
                if ~isempty(scattGainColl.Filters(i).Gain) && isnumeric(scattGainColl.Filters(i).Gain) && isscalar(scattGainColl.Filters(i).Gain)
                    CheckboxTreeNode('Name','Gain','Parent',filterSubNode,'Value',['Filters(',int2str(i),').Gain']);
                end
                if ~isempty(scattGainColl.Filters(i).FrequencyAtMaxPhase) && isnumeric(scattGainColl.Filters(i).FrequencyAtMaxPhase) && isscalar(scattGainColl.Filters(i).FrequencyAtMaxPhase)
                    CheckboxTreeNode('Name','FrequencyAtMaxPhase','Parent',filterSubNode,'Value',['Filters(',int2str(i),').FrequencyAtMaxPhase']);
                end
                if ~isempty(scattGainColl.Filters(i).MaxPhase) && isnumeric(scattGainColl.Filters(i).MaxPhase) && isscalar(scattGainColl.Filters(i).MaxPhase)
                    CheckboxTreeNode('Name','MaxPhase','Parent',filterSubNode,'Value',['Filters(',int2str(i),').MaxPhase']);
                end
                if ~isempty(scattGainColl.Filters(i).FrequencyAtMaxGain) && isnumeric(scattGainColl.Filters(i).FrequencyAtMaxGain) && isscalar(scattGainColl.Filters(i).FrequencyAtMaxGain)
                    CheckboxTreeNode('Name','FrequencyAtMaxGain','Parent',filterSubNode,'Value',['Filters(',int2str(i),').FrequencyAtMaxGain']);
                end     
               
            end

            % Flight condition tree nodes
            fcNode = CheckboxTreeNode('Name','Flight Conditions','Parent',tree.Root,'Value','Root');
            CheckboxTreeNode('Name','Mach','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.Mach');
            CheckboxTreeNode('Name','Qbar','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.Qbar');
            CheckboxTreeNode('Name','Alt','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.Alt');
            CheckboxTreeNode('Name','KCAS','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.KCAS');
            CheckboxTreeNode('Name','KTAS','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.KTAS');
            CheckboxTreeNode('Name','KEAS','Parent',fcNode,'Value','DesignOperatingCondition.FlightCondition.KEAS');

            % Mass Properties tree nodes
            mpNode = CheckboxTreeNode('Name','Mass Properties','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.DesignOperatingCondition.MassProperties.Parameter)
                if isnumeric(scattGainColl.DesignOperatingCondition.MassProperties.Parameter(i).Value) && isscalar(scattGainColl.DesignOperatingCondition.MassProperties.Parameter(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.DesignOperatingCondition.MassProperties.Parameter(i).Name,'Parent',mpNode,'Value',['DesignOperatingCondition.MassProperties.Parameter(',int2str(i),').Value']);
                end
            end

            % Inputs tree nodes
            inNode = CheckboxTreeNode('Name','Model Inputs','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.DesignOperatingCondition.Inputs)
                if isnumeric(scattGainColl.DesignOperatingCondition.Inputs(i).Value) && isscalar(scattGainColl.DesignOperatingCondition.Inputs(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.DesignOperatingCondition.Inputs(i).Name,'Parent',inNode,'Value',['DesignOperatingCondition.Inputs(',int2str(i),').Value']);
                end
            end

            % Outputs tree nodes
            outNode = CheckboxTreeNode('Name','Model Outputs','Parent',tree.Root,'Value','Root');
            for i = 1:length(scattGainColl.DesignOperatingCondition.Outputs)
                if isnumeric(scattGainColl.DesignOperatingCondition.Outputs(i).Value) && isscalar(scattGainColl.DesignOperatingCondition.Outputs(i).Value)
                    CheckboxTreeNode('Name',scattGainColl.DesignOperatingCondition.Outputs(i).Name,'Parent',outNode,'Value',['DesignOperatingCondition.Outputs(',int2str(i),').Value']);
                end
            end
            
            % allow clicking text to select/deselect checkbox
            tree.ClickInCheckBoxOnly = 0;
            
            
            switch callingFunctionType
                case 1
                    if isempty(obj.SelScatteredGainList)
                        gainNode.Checked = true;
                    else
                        model = obj.Tree.getJavaObjects.jModel;
                        setNodeChecked( model, model.getRoot( ) , obj.SelScatteredGainList ); 
                    end
                case 2
                    if isempty(obj.SelIndVarsList)
                        fcNode.Checked = true;
                        mpNode.Checked = true;
                    else
                        model = obj.Tree.getJavaObjects.jModel;
                        setNodeChecked( model, model.getRoot( ) , obj.SelIndVarsList );
                    end
            end
                   
            tree.Visible = true;
            
            
        end % userUpdatesAvailableGains
                 
    end
    
    %% Methods Scattered Gains Selection
    methods
        
        function closeGainSelection( obj , hobj , ~ )
            model = obj.Tree.getJavaObjects.jModel;
            y = getTreeValue(model, model.getRoot());
            obj.SelScatteredGainList = y;

            delete(hobj);
            drawnow();
            setGainSelectionComboBox( obj );
            drawnow();
            update(obj);
        end % closeGainSelection
        
    end
    
    %% Methods Independant Variable Selection
    methods       

        function closeIndVarsSelection( obj , hobj , ~ )
            model = obj.Tree.getJavaObjects.jModel;
            y = getTreeValue(model, model.getRoot());
            obj.SelIndVarsList = y;

            delete(hobj);
            drawnow();
            setIndVarComboBox( obj );
            drawnow();
            update(obj);
        end % closeIndVarsSelection
        
        
    end
        
    %% Methods - Protected(Comomon Routines)
    methods (Access = protected) 
        
        function [ y , I ] = evalBreakpoints( obj )
            if isempty(obj.BreakPointsString)
                y = [];
                I = [];
            else
                y = eval(obj.BreakPointsString);
                if ~iscell(y)
                    y = {y};
                end
            end
            
            if ~isempty(y) && length(y)~= 1
                temp = cellfun(@(x) x(1), y(1,:));
                [ ~ , I ] = sort(temp);
                y = y(I);
            else
                I = true;
            end
        end  % evalBreakpoint                 
        
        function y = createNewSchGainVecObj( obj )
            % Create New SchGainVec Object
%             scatteredGainsCopy = obj.FilteredScatteredGains;
            scatteredGainsCopy = copy(obj.FilteredScatteredGains);

            % Remove unnessesary data, update to to large project file
            % size, this may hinder the eventual scheduled gain
            % functionality
            % DesignOperatingCondition and below
            if ~contains(obj.IndVarExpression.AccessString,'DesignOperatingCondition') && ...
                    ~contains(obj.GainExpression.AccessString,'DesignOperatingCondition')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).DesignOperatingCondition = lacm.OperatingCondition.empty;
                end
            else
                if ~contains(obj.IndVarExpression.AccessString,'States') && ...
                        ~contains(obj.GainExpression.AccessString,'States')
                        for i = 1:length(scatteredGainsCopy)
                            scatteredGainsCopy(i).DesignOperatingCondition.States = lacm.Condition.empty;
                        end
                end
                if ~contains(obj.IndVarExpression.AccessString,'Inputs') && ...
                        ~contains(obj.GainExpression.AccessString,'Inputs')
                        for i = 1:length(scatteredGainsCopy)
                            scatteredGainsCopy(i).DesignOperatingCondition.Inputs = lacm.Condition.empty;
                        end
                end
                if ~contains(obj.IndVarExpression.AccessString,'Outputs') && ...
                        ~contains(obj.GainExpression.AccessString,'Outputs')
                        for i = 1:length(scatteredGainsCopy)
                            scatteredGainsCopy(i).DesignOperatingCondition.Outputs = lacm.Condition.empty;
                        end
                end
                if ~contains(obj.IndVarExpression.AccessString,'FlightCondition') && ...
                        ~contains(obj.GainExpression.AccessString,'FlightCondition')
                        for i = 1:length(scatteredGainsCopy)
                            scatteredGainsCopy(i).DesignOperatingCondition.FlightCondition = lacm.FlightCondition.empty;
                        end
                end
                if ~contains(obj.IndVarExpression.AccessString,'MassProperties') && ...
                        ~contains(obj.GainExpression.AccessString,'MassProperties')
                        for i = 1:length(scatteredGainsCopy)
                            scatteredGainsCopy(i).DesignOperatingCondition.MassProperties = lacm.MassProperties.empty;
                        end
                end
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).DesignOperatingCondition.LinearModel = lacm.LinearModel.empty;
                    scatteredGainsCopy(i).DesignOperatingCondition.TrimSettings = lacm.TrimSettings.empty;
                    scatteredGainsCopy(i).DesignOperatingCondition.StateDerivs = lacm.Condition.empty;
                    scatteredGainsCopy(i).DesignOperatingCondition.SignalLogData = lacm.Condition.empty;
                end

            end
            % SynthesisDesignParameter and Below
            if ~contains(obj.IndVarExpression.AccessString,'SynthesisDesignParameter') && ...
                        ~contains(obj.GainExpression.AccessString,'SynthesisDesignParameter')
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).SynthesisDesignParameter = ScatteredGain.Parameter.empty;
                end
            else
                for i = 1:length(scatteredGainsCopy)
                    if contains(obj.IndVarExpression.AccessString,'SynthesisDesignParameter')
                        usedParamInVar = scatteredGainsCopy(i).SynthesisDesignParameter.get(obj.IndVarExpression.ReplacedVariable); 
                    elseif contains(obj.GainExpression.AccessString,'SynthesisDesignParameter')
                        usedParamInVar = scatteredGainsCopy(i).SynthesisDesignParameter.get(obj.GainExpression.ReplacedVariable); 
                    end
                    
                    scatteredGainsCopy(i).SynthesisDesignParameter = usedParamInVar;
                end
            end
            % RequirementDesignParameter and Below
            if ~contains(obj.IndVarExpression.AccessString,'RequirementDesignParameter') && ...
                        ~contains(obj.GainExpression.AccessString,'RequirementDesignParameter')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).RequirementDesignParameter = ScatteredGain.Parameter.empty;
                end
                
            else
                for i = 1:length(scatteredGainsCopy)
                    if contains(obj.IndVarExpression.AccessString,'RequirementDesignParameter')
                        usedParamInVar = scatteredGainsCopy(i).RequirementDesignParameter.get(obj.IndVarExpression.ReplacedVariable); 
                    elseif contains(obj.GainExpression.AccessString,'RequirementDesignParameter')
                        usedParamInVar = scatteredGainsCopy(i).RequirementDesignParameter.get(obj.GainExpression.ReplacedVariable);
                    end
                    scatteredGainsCopy(i).RequirementDesignParameter = usedParamInVar;
                end
            end 
            % Filters and below
            if ~contains(obj.IndVarExpression.AccessString,'Filters')
                
                for i = 1:length(scatteredGainsCopy)
                    scatteredGainsCopy(i).Filters = UserInterface.ControlDesign.Filter.empty;
                end
            end        

            % Breakdownn saved gains
            for i = 1:length(scatteredGainsCopy)
                currentGain = scatteredGainsCopy(i).Gain.get(obj.SelectedGainString);
                scatteredGainsCopy(i).Gain = currentGain;
                
            end

            % Test fitting range order
            if obj.SelectedTableDimension == 1
                y = ScheduledGain.SchGainVec( ...
                                            obj.SelectedGain ,...
                                            obj.SelectedGainString,...
                                            obj.GainExpression ,...
                                            obj.SelectedScheduledGain  ,...
                                            obj.SelectedTableDimension ,...
                                            '',...
                                            obj.IndVarString,...
                                            obj.IndVarExpression,...
                                            '',...
                                            obj.BreakPoints2TableName,...
                                            'Polynomial',...
                                            obj.FittingRange,...
                                            obj.BreakPoints,...
                                            obj.PolyDegreeValue,...
                                            scatteredGainsCopy,...%obj.FilteredScatteredGains,...
                                            obj.IncludedInFit,...
                                            obj.BreakPointsString);    
            else
                y = ScheduledGain.SchGainVec( ...
                                            obj.SelectedGain ,...
                                            obj.SelectedGainString,...
                                            obj.GainExpression ,...
                                            obj.SelectedScheduledGain  ,...
                                            obj.SelectedTableDimension ,...
                                            obj.BP1ValueString,...
                                            obj.IndVarString,...
                                            obj.IndVarExpression,...
                                            obj.BreakPoints1TableName,...
                                            obj.BreakPoints2TableName,...
                                            'Polynomial',...
                                            obj.FittingRange,...
                                            obj.BreakPoints,...
                                            obj.PolyDegreeValue,...
                                            scatteredGainsCopy,...%obj.FilteredScatteredGains,...
                                            obj.IncludedInFit,...
                                            obj.BreakPointsString);
            end
            ScheduledGain.SchGainVecPropListener(y);
            y.Current = true;
               
        end % createNewSchGainVecObj
   
    end
    
    %% Methods - Protected(ReSize)
    methods (Access = protected)       

         function resize( obj , ~ , ~ )
            
            posCont = getpixelposition(obj.Container);
            
            % GainSelectionPanel
            obj.GainSelectionPanel.Position = [ 1 , posCont(4) - 135 , 330 , 135 ];
            
            gsCont = getpixelposition(obj.GainSelectionPanel);
            obj.ScatterLabelCont.Position = [ 1 , gsCont(4) - 18 , 330 , 16 ]; 
            obj.ScattFileName.Position = [5 , gsCont(4) - 38 , gsCont(3) - 10 , 17];
            obj.HContScatGainFile.Position = [5 , gsCont(4) - 60 , gsCont(3) - 15 , 22];

            obj.TextGainName.Position               = [5 , gsCont(4) - 80 , 160 , 17];
            obj.HContGainSel.Position               = [5 , gsCont(4) - 102  , 150 , 22];
            obj.EditGainListJButtonHCont.Position   = [5 , gsCont(4) - 130  , 150 , 22];
            
            obj.IndVarText.Position                 = [170 , gsCont(4) - 80 , 175 , 17];
            obj.HContIndVar.Position                = [170 , gsCont(4) - 102 , 150 , 22];
            obj.EditIndVarListJButtonHCont.Position = [170 , gsCont(4) - 130 , 150 , 22];

            % GainSchedulePanel
            obj.GainSchedulePanel.Position = [ 1 , posCont(4) - 395 , 330 , 260 ];
            
            gscCont = getpixelposition(obj.GainSchedulePanel);
            obj.SchLabelCont.Position = [ 1 , gscCont(4) - 18 , 330 , 16 ]; 
            
            obj.SchFileName.Position         = [2 , gscCont(4) - 38 , 200 , 17];
            obj.HContSelSchFileFile.Position = [2 , gscCont(4) - 60 , 150 , 22];
            obj.ExportSchJButtonHCont.Position  = [200 , gscCont(4) - 40 , 75 , 22];
            
            obj.NewSchJButtonHCont.Position     = [155 , gscCont(4) - 60 , 75 , 22];
            obj.RemoveSchCollJButtonHCont.Position  = [230 , gscCont(4) - 60 , 75 , 22];
         
            obj.SchGainName.Position         = [2 , gscCont(4) - 86 , 150 , 17];
            obj.HContSchGainName.Position = [2 , gscCont(4) - 108 , 150 , 22];
            
            obj.NewSchGainNameJButtonHCont.Position     = [155 , gscCont(4) - 108 , 75 , 22];
            obj.RemoveSchGainNameJButtonHCont.Position  = [230 , gscCont(4) - 108 , 75 , 22];
            
            obj.TextDimension.Position = [2 , gscCont(4) - 130 , 150 , 17];
            obj.HContTableDim.Position = [2 , gscCont(4) - 154 , 150 , 22];
            
            obj.TextBP1Name.Position = [2 , gscCont(4) - 180 , 150 , 17];
            
            obj.TextBP2NameCont.Position = [170 , gscCont(4) - 180 , 150 , 17];
       
            obj.TextBP1ValueCont.Position  = [ 2 , gscCont(4) - 228 , 175 , 17];

            obj.TextBPCont.Position = [170 , gscCont(4) - 228 , 175 , 17];
        
            % Move Edit box for Breakpoints 2 to the postion for
            % breakpoints one and rename
            if obj.SelectedTableDimension == 2
                obj.BP1Name_eb.Position  = [2 , gscCont(4) - 202 , 150 , 22];
                obj.BP2Name_eb.Position  = [170 , gscCont(4) - 202 , 150 , 22];
                
                obj.BP1ValueString_eb.Position = [ 2 , gscCont(4) - 250 , 150 , 22];
                obj.BP_eb.Position  = [170 , gscCont(4) - 250 , 150 , 22];
            else
                obj.BP1Name_eb.Position  = [170 , gscCont(4) - 202 , 150 , 22];
                obj.BP2Name_eb.Position  = [2 , gscCont(4) - 202 , 150 , 22];
                
                obj.BP1ValueString_eb.Position = [170 , gscCont(4) - 250 , 150 , 22];
                obj.BP_eb.Position  = [ 2 , gscCont(4) - 250 , 150 , 22];
            end
            
            % Code to allow tables to expand with gui size
            top = posCont(4) - 395;
            bottom = 1;
            height = (top - bottom) / 2;
            
            % GainFittingPanel
            obj.GainFittingPanel.Position = [ 1 , top - height , 330 , height ];%[ 1 , posCont(4) - 550 , 330 , 155 ];
            
            gftCont = getpixelposition(obj.GainFittingPanel);
            obj.GainFitLabelCont.Position = [ 1 , gftCont(4) - 18 , 330 , 16 ]; 
            obj.PolyFitTable.Position     = [ 10 , 37, 302 , gftCont(4) - 65 ]; 
            obj.SchJButtonHCont.Position  = [10 , 5 , 95 , 22];
            obj.RemoveSchJButtonHCont.Position  = [115 , 5 , 115 , 22];
            
            % OptionsPanel
            obj.OptionsPanel.Position = [ 1 , 1 , 330 , height ];%[ 1 , posCont(4) - 730 , 330 , 180 ];
            
            optCont = getpixelposition(obj.OptionsPanel);
            obj.OptionsLabelCont.Position = [ 1 , optCont(4) - 18 , 330 , 16 ];  
            obj.HContainer.Position = [ 10 , 40, 310 , optCont(4) - 65  ];   
            obj.RemoveRowJButtonHCont.Position = [ 110 , 10, 90 , 22  ];  
            obj.ViewTableJButtonHCont.Position = [ 10 , 10, 90 , 22  ]; 
            obj.ExportTableJButtonHCont.Position = [ 210 , 10, 110 , 22  ]; 
                
            
            set(obj.GainSchAxisColl,'Units','Pixels','Position',[332 , 1 , posCont(3) - 332 , posCont(4)]);


        end % resize
         
    end    
    
    %% Methods - Copy Protected
    methods ( Access = protected )
        function cpObj = copyElement(obj)   
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the PrivateFilteredScatteredGains object
            cpObj.PrivateFilteredScatteredGains = copy(obj.PrivateFilteredScatteredGains);
            % Make a deep copy of the ScattGainFileObjArray object
            cpObj.ScattGainFileObjArray = copy(obj.ScattGainFileObjArray);
            % Make a deep copy of the SchGainFileObjArray object
            cpObj.SchGainFileObjArray = copy(obj.SchGainFileObjArray);
        end % copyElement  
    end  
    
    %% Methods - Delete
    methods
        function delete( obj )
            
            
        % Java Components 
        obj.TextBP2Name = [];
        obj.TextBP = [];
        obj.HCompIndVar = [];
        obj.HCompGainSel = [];
        obj.SchJButtonHComp = [];
        obj.HCompScatGainFile = [];
        obj.HCompSelSchFile = [];
        obj.ScatterLabelComp = [];
        obj.SchLabelComp = [];
        obj.NewSchJButtonHComp = [];
        obj.RemoveSchJButtonHComp = [];
        obj.ExportSchJButtonHComp = [];
        obj.HCompSchGainName = [];
        obj.NewSchGainNameJButtonHComp = [];
        obj.RemoveSchGainNameJButtonHComp = [];
        obj.TextBP1Value = [];
        obj.GainFitLabelComp = [];
        obj.OptionsLabelComp = [];
        obj.JTable = [];
        obj.JTableH = [];
        obj.JScroll = [];
        obj.JHScroll = [];
        obj.RemoveRowJButtonHComp = [];
        obj.ExportTableJButtonHComp = [];
        obj.ViewTableJButtonHComp = [];
        obj.RemoveSchCollJButtonHComp = [];
        obj.TableModel = [];
        obj.FixColTbl = [];  
        
        
        % Javawrappers
        % Check if container is already being deleted
        if ishandle(obj.TextGainName) && strcmp(get(obj.TextGainName, 'BeingDeleted'), 'off')
            delete(obj.TextGainName)
        end
        if ishandle(obj.IndVarText) && strcmp(get(obj.IndVarText, 'BeingDeleted'), 'off')
            delete(obj.IndVarText)
        end
        if ishandle(obj.TextBP1Name) && strcmp(get(obj.TextBP1Name, 'BeingDeleted'), 'off')
            delete(obj.TextBP1Name)
        end
        if ishandle(obj.TextBP2NameCont) && strcmp(get(obj.TextBP2NameCont, 'BeingDeleted'), 'off')
            delete(obj.TextBP2NameCont)
        end
        if ishandle(obj.TextBPCont) && strcmp(get(obj.TextBPCont, 'BeingDeleted'), 'off')
            delete(obj.TextBPCont)
        end
        if ishandle(obj.HContIndVar) && strcmp(get(obj.HContIndVar, 'BeingDeleted'), 'off')
            delete(obj.HContIndVar)
        end
        if ishandle(obj.HContGainSel) && strcmp(get(obj.HContGainSel, 'BeingDeleted'), 'off')
            delete(obj.HContGainSel)
        end
        if ishandle(obj.SchJButtonHCont) && strcmp(get(obj.SchJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.SchJButtonHCont)
        end
        if ishandle(obj.TextDimension) && strcmp(get(obj.TextDimension, 'BeingDeleted'), 'off')
            delete(obj.TextDimension)
        end
        if ishandle(obj.HContTableDim) && strcmp(get(obj.HContTableDim, 'BeingDeleted'), 'off')
            delete(obj.HContTableDim)
        end
        if ishandle(obj.HContScatGainFile) && strcmp(get(obj.HContScatGainFile, 'BeingDeleted'), 'off')
            delete(obj.HContScatGainFile)
        end
        if ishandle(obj.HContSelSchFileFile) && strcmp(get(obj.HContSelSchFileFile, 'BeingDeleted'), 'off')
            delete(obj.HContSelSchFileFile)
        end
        if ishandle(obj.SchFileName) && strcmp(get(obj.SchFileName, 'BeingDeleted'), 'off')
            delete(obj.SchFileName)
        end
        if ishandle(obj.ScattFileName) && strcmp(get(obj.ScattFileName, 'BeingDeleted'), 'off')
            delete(obj.ScattFileName)
        end
        if ishandle(obj.ScatterLabelCont) && strcmp(get(obj.ScatterLabelCont, 'BeingDeleted'), 'off')
            delete(obj.ScatterLabelCont)
        end
        if ishandle(obj.SchLabelCont) && strcmp(get(obj.SchLabelCont, 'BeingDeleted'), 'off')
            delete(obj.SchLabelCont)
        end
        if ishandle(obj.NewSchJButtonHCont) && strcmp(get(obj.NewSchJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.NewSchJButtonHCont)
        end
        if ishandle(obj.ExportSchJButtonHCont) && strcmp(get(obj.ExportSchJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.ExportSchJButtonHCont)
        end
        if ishandle(obj.SchGainName) && strcmp(get(obj.SchGainName, 'BeingDeleted'), 'off')
            delete(obj.SchGainName)
        end
        if ishandle(obj.HContSchGainName) && strcmp(get(obj.HContSchGainName, 'BeingDeleted'), 'off')
            delete(obj.HContSchGainName)
        end
        if ishandle(obj.NewSchGainNameJButtonHCont) && strcmp(get(obj.NewSchGainNameJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.NewSchGainNameJButtonHCont)
        end
        if ishandle(obj.RemoveSchGainNameJButtonHCont) && strcmp(get(obj.RemoveSchGainNameJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.RemoveSchGainNameJButtonHCont)
        end
        if ishandle(obj.TextBP1ValueCont) && strcmp(get(obj.TextBP1ValueCont, 'BeingDeleted'), 'off')
            delete(obj.TextBP1ValueCont)
        end
        if ishandle(obj.GainFitLabelCont) && strcmp(get(obj.GainFitLabelCont, 'BeingDeleted'), 'off')
            delete(obj.GainFitLabelCont)
        end
        if ishandle(obj.OptionsLabelCont) && strcmp(get(obj.OptionsLabelCont, 'BeingDeleted'), 'off')
            delete(obj.OptionsLabelCont)
        end
        if ishandle(obj.HContainer) && strcmp(get(obj.HContainer, 'BeingDeleted'), 'off')
            delete(obj.HContainer)
        end
        if ishandle(obj.RemoveRowJButtonHCont) && strcmp(get(obj.RemoveRowJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.RemoveRowJButtonHCont)
        end
        if ishandle(obj.ExportTableJButtonHCont) && strcmp(get(obj.ExportTableJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.ExportTableJButtonHCont)
        end
        if ishandle(obj.ViewTableJButtonHCont) && strcmp(get(obj.ViewTableJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.ViewTableJButtonHCont)
        end
        if ishandle(obj.RemoveSchJButtonHCont) && strcmp(get(obj.RemoveSchJButtonHCont, 'BeingDeleted'), 'off')
            delete(obj.RemoveSchJButtonHCont)
        end
        
        % User Defined Objects
        try %#ok<*TRYNC>             
            delete(obj.GainSchAxisColl);
        end
%         try %#ok<*TRYNC>             
%             delete(obj.ScheduledGainObj);
%         end
        try %#ok<*TRYNC>             
            delete(obj.PrivateFilteredScatteredGains);
        end
        try %#ok<*TRYNC>             
            delete(obj.ScattGainFileObjArray);
        end
        try %#ok<*TRYNC>             
            delete(obj.SchGainFileObjArray);
        end



     
%          % Matlab Components
%         obj.GainSelectionPanel
%         obj.BP1Name_eb 
%         obj.BP2Name_eb
%         obj.BP_eb 
%         obj.LineH
%         obj.ExLineH
%         obj.axH
%         obj.PolyFitLineH
%         obj.BP1ValueString_eb
%         obj.GainSchedulePanel
%         obj.GainFittingPanel
%         obj.PolyFitTable
%         obj.OptionsPanel
%         
%         % Data
%         obj.BP1ValueString
%         obj.SelectedGain
%         obj.GainSymVarExp
%         obj.SelectedTableDimension
%         obj.PolyFitData
%         obj.SelectedScheduledGain
%         obj.HContSchGainSelIndex
%         obj.BreakPoints1TableName
%         obj.BreakPoints2TableName  
%         obj.BreakPointsString
%         obj.IncludedInFit
%         obj.SelScattGainObjIndex
%         obj.SelectedGainIndex
%         obj.SelectedGainString
%         obj.IndVarSelectedIndex
%         obj.IndVarString

        end % delete
    end
 
end

function y = defaultColors( ind )
%     defaultColors{1}     = [ 0 , 114.4320 , 189.6960 ];         % blue
    defaultColors{1} = [ 217.6000 ,  83.2000 , 25.0880 ];   % red
    defaultColors{end+1} = [ 237.8240 , 177.6640 , 32.0000 ];   % lime [255 , 255 , 0];   % yellow
    defaultColors{end+1} = [ 126.4640 , 47.1040 , 142.3360 ];   % magenta
    defaultColors{end+1} = [ 119.2960 , 172.5440 , 48.1280 ];   % aqua
    defaultColors{end+1} = [ 77.0560 , 190.7200 , 238.8480 ];   %
    defaultColors{end+1} = [ 162.5600 , 19.9680 , 47.1040 ];    %

    for i=1:20000
        defaultColors{end+1} = [rand(1) , rand(1) , rand(1)] * 256 ; %#ok<*AGROW>
    end
    y = defaultColors{ind};
end

function y = getTreeValue( model, object )

    mNode = get(object,'TreeNode');
    if (~strcmp(mNode.Name,'Root') && ~strcmp(mNode.Value,'Root')) &&  mNode.Checked
        y = struct('Name',mNode.Name,'Expression',mNode.Value);
    else 
        y = struct.empty;
    end
    for i = 0:model.getChildCount(object) - 1
        y = [y,getTreeValue(model, model.getChild(object, i) )];
    end
end % getTreeValue

function y = setNodeChecked( model, object , x )

    mNode = get(object,'TreeNode');
    if (~strcmp(mNode.Name,'Root') && ~strcmp(mNode.Value,'Root')) &&  any(strcmp(mNode.Name ,{x.Name})) &&  any(strcmp(mNode.Value ,{x.Expression}))
        mNode.Checked = true;
    else 
        mNode.Checked = false;
    end
    for i = 0:model.getChildCount(object) - 1
        setNodeChecked(model, model.getChild(object, i) , x );
    end
end % setNodeChecked

function flag=isMultipleCall()
  flag = false;
  % Get the stack
  s = dbstack();
  if numel(s)<=2
    % Stack too short for a multiple call
    return
  end
  % How many calls to the calling function are in the stack?
  names = {s(:).name};
  TF = strcmp(s(2).name,names);
  count = sum(TF);
  if count>1
    % More than 1
    flag = true;
  end
end
