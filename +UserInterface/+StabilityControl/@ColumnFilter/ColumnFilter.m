classdef ColumnFilter < matlab.mixin.Copyable & UserInterface.GraphicsObject
    
    %% Public properties - Object Handles
    properties (Transient = true)      
        SelectionPopUpContainer
                
        FilterVar1_pm
        FilterVar2_pm
        FilterVar3_pm
        FilterVar4_pm
        
        FilterValue1_pm
        FilterValue2_pm
        FilterValue3_pm
        FilterValue4_pm
        
        FilterRange1_eb
        FilterRange2_eb
        FilterRange3_eb
        FilterRange4_eb
        
        Filter1Label_tb
        Filter2Label_tb
        Filter3Label_tb
        Filter4Label_tb
        
        ColFilt1LabelComp
        ColFilt1LabelCont
        ColFilt2LabelComp
        ColFilt2LabelCont
        ColFilt3LabelComp
        ColFilt3LabelCont
        ColFilt4LabelComp
        ColFilt4LabelCont
    end
    
    %% Public properties - Observable Data Storage
    properties (SetObservable)
        ShowData
    end
    
    %% Public properties - Data Storage
    properties  
        Data
        DisplayData
        Filter1ColumnLogicalArray logical = true(3,1)
        Filter2ColumnLogicalArray logical = true(3,1)
        Filter3ColumnLogicalArray logical = true(3,1)
        Filter4ColumnLogicalArray logical = true(3,1)
        
        
        
        FilterVar1SelValue = 1
        FilterVar2SelValue = 1
        FilterVar3SelValue = 1
        FilterVar4SelValue = 1
        
        FilterVar1String = {'All'}
        FilterVar2String = {'All'}
        FilterVar3String = {'All'}
        FilterVar4String = {'All'}
        
        
        FilterValue1String = {'All'}
        FilterValue2String = {'All'}
        FilterValue3String = {'All'}
        FilterValue4String = {'All'}
        
        FilterValue1SelValue = 1
        FilterValue2SelValue = 1
        FilterValue3SelValue = 1
        FilterValue4SelValue = 1  
        
        FilterRange1String = ''
        FilterRange2String = ''
        FilterRange3String = ''
        FilterRange4String = ''
    end % Public properties
    
    %% Private properties - Data Storage
    properties  ( Access = private )
 
    end
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        ColumnLogicArray
    end % Dependant properties

    %% Constant properties
    properties (Constant) 
        TableFormatString = '%6.4g'
    end % Constant properties  
    
    %% Events
    events
        ColumnSelectedEvent
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end % Events
    
    %% Methods - Constructor
    methods      
        function obj = ColumnFilter( parent )
    
            createView( obj , parent );
        end % ColumnFilter
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.ColumnLogicArray( obj )
            y = obj.Filter1ColumnLogicalArray & ...
                    obj.Filter2ColumnLogicalArray & ...
                    obj.Filter3ColumnLogicalArray & ...
                    obj.Filter4ColumnLogicalArray;
        end % ColumnLogicArray
    end % Property access methods
   
    %% Methods - View
    methods 
            
        function createView( obj , parent )
            obj.Parent = parent;
            parentPos = getpixelposition(parent);
            obj.SelectionPopUpContainer = uicontainer('Parent',parent,'Units','Normal','Position',[ 0 , 0 , 1 , 1 ]);  
            %set(obj.SelectionPopUpContainer,'ResizeFcn',@obj.reSize);
            %sepPixels = (parentPos(4)-(27))/5;

            % Row 1
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Column Filter 1</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ColFilt1LabelComp,obj.ColFilt1LabelCont] = javacomponent(jLabelview,[], parent );
%             obj.Filter1Label_tb = uicontrol(...
%                 'Parent',parent,...
%                 'Style','text',...
%                 'String', '---------COLUMN FILTER 1------------',...
%                 'BackgroundColor', [1 1 1],...
%                 'Units','Pixels');     
            obj.FilterVar1_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterVar1String,...
                'Value',obj.FilterVar1SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterVar1_CB);
            
            obj.FilterValue1_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterValue1String,...
                'Value',obj.FilterValue1SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterValue1_CB);
            
            obj.FilterRange1_eb = uicontrol(...
                'Parent',parent,...
                'Style','edit',...
                'String', obj.FilterRange1String,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterRange1_CB);
            
            % Row 2
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Column Filter 2</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ColFilt2LabelComp,obj.ColFilt2LabelCont] = javacomponent(jLabelview,[], parent );
%             obj.Filter2Label_tb = uicontrol(...
%                 'Parent',parent,...
%                 'Style','text',...
%                 'String', '---------COLUMN FILTER 2------------',...
%                 'BackgroundColor', [1 1 1],...
%                 'Units','Pixels');
            
            obj.FilterVar2_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterVar2String,...
                'Value',obj.FilterVar2SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterVar2_CB);
            
            obj.FilterValue2_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterValue2String,...
                'Value',obj.FilterValue2SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterValue2_CB);    
            
            obj.FilterRange2_eb = uicontrol(...
                'Parent',parent,...
                'Style','edit',...
                'String', obj.FilterRange2String,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterRange2_CB);
            
            % Row 3
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Column Filter 3</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ColFilt3LabelComp,obj.ColFilt3LabelCont] = javacomponent(jLabelview,[], parent );
%             obj.Filter3Label_tb = uicontrol(...
%                 'Parent',parent,...
%                 'Style','text',...
%                 'String', '---------COLUMN FILTER 3------------',...
%                 'BackgroundColor', [1 1 1],...
%                 'Units','Pixels');
            
            obj.FilterVar3_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterVar3String,...
                'Value',obj.FilterVar3SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterVar3_CB);
            
            obj.FilterValue3_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterValue3String,...
                'Value',obj.FilterValue3SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterValue3_CB);
            
            obj.FilterRange3_eb = uicontrol(...
                'Parent',parent,...
                'Style','edit',...
                'String', obj.FilterRange3String,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterRange3_CB);
            
            % Row 4
            labelStr = '<html><font color="white" face="Courier New">&nbsp;Column Filter 4</html>';
            jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
            jLabelview.setOpaque(true);
            jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
            jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            [obj.ColFilt4LabelComp,obj.ColFilt4LabelCont] = javacomponent(jLabelview,[], parent );
%             obj.Filter4Label_tb = uicontrol(...
%                 'Parent',parent,...
%                 'Style','text',...
%                 'String', '---------COLUMN FILTER 4------------',...
%                 'BackgroundColor', [1 1 1],...
%                 'Units','Pixels');
%             
            obj.FilterVar4_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterVar4String,...
                'Value',obj.FilterVar4SelValue,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterVar4_CB);
            
            obj.FilterValue4_pm = uicontrol(...
                'Parent',parent,...
                'Style','popupmenu',...
                'String', obj.FilterValue4String,...
                'Value',obj.FilterValue4SelValue,...'String', {'All'},...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterValue4_CB);

            obj.FilterRange4_eb = uicontrol(...
                'Parent',parent,...
                'Style','edit',...
                'String', obj.FilterRange4String,...
                'BackgroundColor', [1 1 1],...
                'Units','Pixels',...
                'Callback',@obj.filterRange4_CB);
            
            initSize( obj );                         
        end % createView
        
    end
       
   %% Methods - Ordinary
    methods 
        
        function initialize( obj , struct ) 
            names = strcat({struct.Type},'-',{struct.Name});
            obj.FilterVar1String = ['All';names'];
            obj.FilterVar2String = ['All';names'];
            obj.FilterVar3String = ['All';names'];
            obj.FilterVar4String = ['All';names'];
            
            obj.FilterVar1SelValue = 1;
            obj.FilterVar2SelValue = 1;
            obj.FilterVar3SelValue = 1;
            obj.FilterVar4SelValue = 1;
            
            obj.FilterValue1String = {'All'};
            obj.FilterValue2String = {'All'};
            obj.FilterValue3String = {'All'};
            obj.FilterValue4String = {'All'};
        
            obj.FilterValue1SelValue = 1;
            obj.FilterValue2SelValue = 1;
            obj.FilterValue3SelValue = 1;
            obj.FilterValue4SelValue = 1;
            
            obj.FilterRange1String = [];
            obj.FilterRange2String = [];
            obj.FilterRange3String = [];
            obj.FilterRange4String = [];

            update(obj);
        end % initialize
        
        function updateAllSelectableFilterStrings( obj , displayData , data )
            obj.DisplayData = displayData;
            obj.Data = data;
            
            names = strcat(obj.DisplayData(:,1),'-',obj.DisplayData(:,2));
            
            if ismember(obj.FilterVar1String(obj.FilterVar1SelValue), names)
                resetVar1Old = obj.FilterVar1String(obj.FilterVar1SelValue);
                resetVar1 = false;
            else
                resetVar1 = true;
            end
            
            if ismember(obj.FilterVar2String(obj.FilterVar2SelValue), names)
                resetVar2Old = obj.FilterVar2String(obj.FilterVar2SelValue);
                resetVar2 = false;
            else
                resetVar2 = true;
            end
            
            if ismember(obj.FilterVar3String(obj.FilterVar3SelValue), names)
                resetVar3Old = obj.FilterVar3String(obj.FilterVar3SelValue);
                resetVar3 = false;
            else
                resetVar3 = true;
            end
            
            if ismember(obj.FilterVar4String(obj.FilterVar4SelValue), names)
                resetVar4Old = obj.FilterVar4String(obj.FilterVar4SelValue);
                resetVar4 = false;
            else
                resetVar4 = true;
            end
            
            obj.FilterVar1String = ['All';names];
            obj.FilterVar2String = ['All';names];
            obj.FilterVar3String = ['All';names];
            obj.FilterVar4String = ['All';names];
            
            if resetVar1
                obj.FilterVar1SelValue = 1;
            else
                varIdx = find(ismember(['All';names], resetVar1Old));
                obj.FilterVar1SelValue = varIdx;    
            end
            if resetVar2
                obj.FilterVar2SelValue = 1;
            else
                varIdx = find(ismember(['All';names], resetVar2Old));
                obj.FilterVar2SelValue = varIdx;    
            end
            if resetVar3
                obj.FilterVar3SelValue = 1;
            else
                varIdx = find(ismember(['All';names], resetVar3Old));
                obj.FilterVar3SelValue = varIdx;    
            end
            if resetVar4
                obj.FilterVar4SelValue = 1;
            else
                varIdx = find(ismember(['All';names], resetVar4Old));
                obj.FilterVar4SelValue = varIdx;    
            end
            
            if obj.FilterVar1SelValue == 1
                obj.FilterValue1String = {'All'};
                obj.FilterValue1SelValue = 1;
            else                      
                data = obj.DisplayData( obj.FilterVar1SelValue - 1 , 4:end);                 
                obj.FilterValue1String = createUniqueCellStringWithAll( obj, data );
            end
            
            if obj.FilterVar2SelValue == 1
                obj.FilterValue2String = {'All'};
                obj.FilterValue2SelValue = 1;
            else                      
                data = obj.DisplayData( obj.FilterVar2SelValue - 1 , 4:end);                 
                obj.FilterValue2String = createUniqueCellStringWithAll( obj, data );
            end
            
            if obj.FilterVar3SelValue == 1
                obj.FilterValue3String = {'All'};
                obj.FilterValue3SelValue = 1;
            else                      
                data = obj.DisplayData( obj.FilterVar3SelValue - 1 , 4:end);                 
                obj.FilterValue3String = createUniqueCellStringWithAll( obj, data );
            end
            
            if obj.FilterVar4SelValue == 1
                obj.FilterValue4String = {'All'};
                obj.FilterValue4SelValue = 1;
            else                      
                data = obj.DisplayData( obj.FilterVar4SelValue - 1 , 4:end);                 
                obj.FilterValue4String = createUniqueCellStringWithAll( obj, data );
            end
            
            
            if ~isnan(str2double(obj.FilterRange1String)) && (isempty(obj.FilterRange1String) || ~ismember(obj.FilterRange1String, obj.FilterValue1String))
                obj.FilterValue1SelValue = 1;
                obj.FilterRange1String = [];
            end
            
            if ~isnan(str2double(obj.FilterRange2String)) && (isempty(obj.FilterRange2String) || ~ismember(obj.FilterRange2String, obj.FilterValue2String))
                obj.FilterValue2SelValue = 1;
                obj.FilterRange2String = [];
            end
            
            if ~isnan(str2double(obj.FilterRange3String)) && (isempty(obj.FilterRange3String) || ~ismember(obj.FilterRange3String, obj.FilterValue3String))
                obj.FilterValue3SelValue = 1;
                obj.FilterRange3String = [];
            end
            
            if ~isnan(str2double(obj.FilterRange4String)) && (isempty(obj.FilterRange4String) || ~ismember(obj.FilterRange4String, obj.FilterValue4String))
                obj.FilterValue4SelValue = 1;
                obj.FilterRange4String = [];
            end
            
%             obj.FilterValue1String = {'All'};
%             obj.FilterValue2String = {'All'};
%             obj.FilterValue3String = {'All'};
%             obj.FilterValue4String = {'All'};
        
%             selVal1
%             obj.FilterValue1SelValue = 1;
%             obj.FilterValue2SelValue = 1;
%             obj.FilterValue3SelValue = 1;
%             obj.FilterValue4SelValue = 1;

%             obj.FilterRange1String = [];
%             obj.FilterRange2String = [];
%             obj.FilterRange3String = [];
%             obj.FilterRange4String = [];
            
%             trueArray = true(size(obj.Data,2),1);
%             obj.Filter1ColumnLogicalArray = trueArray;
%             obj.Filter2ColumnLogicalArray = trueArray;
%             obj.Filter3ColumnLogicalArray = trueArray;
%             obj.Filter4ColumnLogicalArray = trueArray;

            calculateFilter1ColLogicalArrayRange(obj);
            calculateFilter2ColLogicalArrayRange(obj);
            calculateFilter3ColLogicalArrayRange(obj);
            calculateFilter4ColLogicalArrayRange(obj);

            update(obj);
%             % Observable Property
%             obj.ShowData = obj.ColumnLogicArray;
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % updateAllSelectableFilterStrings
        
        function applyFilter2NewOperCond( obj , displayData , data )
            obj.DisplayData = displayData;
            obj.Data = data;
            
            trueArray = true(size(obj.Data,2),1);
            obj.Filter1ColumnLogicalArray = trueArray;
            obj.Filter2ColumnLogicalArray = trueArray;
            obj.Filter3ColumnLogicalArray = trueArray;
            obj.Filter4ColumnLogicalArray = trueArray;
            
            % Reset all Filters and Clear
            obj.FilterVar1SelValue = 1;
            obj.FilterVar2SelValue = 1;
            obj.FilterVar3SelValue = 1;
            obj.FilterVar4SelValue = 1;
        
            obj.FilterValue1SelValue = 1;
            obj.FilterValue2SelValue = 1;
            obj.FilterValue3SelValue = 1;
            obj.FilterValue4SelValue = 1;

            obj.FilterRange1String = [];
            obj.FilterRange2String = [];
            obj.FilterRange3String = [];
            obj.FilterRange4String = [];   
%             if obj.FilterVar1SelValue ~= 1
%                 if isempty(obj.FilterRange1String)
%                     calculateFilter1ColLogicalArray(obj);
%                 else
%                     calculateFilter1ColLogicalArrayRange(obj);
%                 end
%             end
%             if obj.FilterVar2SelValue ~= 1
%                 if isempty(obj.FilterRange2String)
%                     calculateFilter2ColLogicalArray(obj);
%                 else
%                     calculateFilter2ColLogicalArrayRange(obj);
%                 end
%             end
%             if obj.FilterVar3SelValue ~= 1
%                 if isempty(obj.FilterRange3String)
%                     calculateFilter3ColLogicalArray(obj);
%                 else
%                     calculateFilter3ColLogicalArrayRange(obj);
%                 end
%             end
%             if obj.FilterVar4SelValue ~= 1
%                 if isempty(obj.FilterRange4String)
%                     calculateFilter4ColLogicalArray(obj);
%                 else
%                     calculateFilter4ColLogicalArrayRange(obj);
%                 end 
%             end
            
            update(obj);
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));  
        end % applyFilter2NewOperCond
        
    end % Ordinary Methods
    
    
    methods
        
       function newFunction( obj )
           
%             filterVar1_CB( obj , obj.FilterVar1_pm , [] );
%             filterRange1_CB( obj , obj.FilterRange1_eb , [] );
%             filterVar2_CB( obj , obj.FilterVar2_pm , [] );
%             filterRange2_CB( obj , obj.FilterRange2_eb , [] );
%             filterVar3_CB( obj , obj.FilterVar3_pm , [] );
%             filterRange3_CB( obj , obj.FilterRange3_eb , [] );
%             filterVar4_CB( obj , obj.FilterVar4_pm , [] );
%             filterRange4_CB( obj , obj.FilterRange4_eb , [] );

%             if obj.FilterVar1SelValue == 1
%                 obj.FilterValue1String = {'All'};  
%             else                      
%                 data = obj.DisplayData( obj.FilterVar1SelValue - 1 , 4:end);                 
%                 obj.FilterValue1String = createUniqueCellStringWithAll( obj, data );
%             end
%             
%             if obj.FilterVar2SelValue == 1
%                 obj.FilterValue2String = {'All'};  
%             else                      
%                 data = obj.DisplayData( obj.FilterVar2SelValue - 1 , 4:end);                 
%                 obj.FilterValue2String = createUniqueCellStringWithAll( obj, data );
%             end
%             
%             if obj.FilterVar3SelValue == 1
%                 obj.FilterValue3String = {'All'};  
%             else                      
%                 data = obj.DisplayData( obj.FilterVar3SelValue - 1 , 4:end);                 
%                 obj.FilterValue3String = createUniqueCellStringWithAll( obj, data );
%             end
%             
%             if obj.FilterVar4SelValue == 1
%                 obj.FilterValue4String = {'All'};  
%             else                      
%                 data = obj.DisplayData( obj.FilterVar4SelValue - 1 , 4:end);                 
%                 obj.FilterValue4String = createUniqueCellStringWithAll( obj, data );
%             end

%             calculateFilter1ColLogicalArrayRange(obj);
%             calculateFilter2ColLogicalArrayRange(obj);
%             calculateFilter3ColLogicalArrayRange(obj);
%             calculateFilter4ColLogicalArrayRange(obj);
            obj.updateAllSelectableFilterStrings(obj.DisplayData, obj.Data);
%             update(obj);
%             notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end
    end
    
    %% Methods - Filter Callbacks Protected
    methods %(Access = protected)
        
        function filterVar1_CB( obj , hobj , ~ )
            obj.FilterVar1SelValue = get(hobj,'Value');
%             obj.FilterValue1SelValue = 1;
            setValueFilter1( obj );
            update(obj);
        end % filterVar1_CB
        
        function filterVar2_CB( obj , hobj , ~ )
            obj.FilterVar2SelValue = get(hobj,'Value');
%             obj.FilterValue2SelValue = 1;
            setValueFilter2( obj )
            update(obj);
        end % filterVar2_CB
        
        function filterVar3_CB( obj , hobj , ~ )
            obj.FilterVar3SelValue = get(hobj,'Value');
%             obj.FilterValue3SelValue = 1;
            setValueFilter3( obj )
            update(obj);
        end % filterVar3_CB
        
        function filterVar4_CB( obj , hobj , ~ )
            obj.FilterVar4SelValue = get(hobj,'Value');
%             obj.FilterValue4SelValue = 1;
            setValueFilter4( obj )
            update(obj);
        end % filterVar4_CB

        function filterValue1_CB( obj , hobj , ~ )
            obj.FilterValue1SelValue = get(hobj,'Value');  
            selStr = obj.FilterValue1String{obj.FilterValue1SelValue};
            % Reset the range filter
            obj.FilterRange1String = selStr;
            calculateFilter1ColLogicalArray( obj );   
            update(obj);
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % filterValue1_CB   
     
        function filterValue2_CB( obj , hobj , ~ )
            obj.FilterValue2SelValue = get(hobj,'Value');  
            selStr = obj.FilterValue2String{obj.FilterValue2SelValue};
            % Reset the range filter
            obj.FilterRange2String = selStr;
            calculateFilter2ColLogicalArray( obj ); 
            update(obj); 
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % filterValue2_CB   
        
        function filterValue3_CB( obj , hobj , ~ )
            obj.FilterValue3SelValue = get(hobj,'Value');  
            selStr = obj.FilterValue3String{obj.FilterValue3SelValue};
            % Reset the range filter
            obj.FilterRange3String = selStr;
            calculateFilter3ColLogicalArray( obj ); 
            update(obj);  
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % filterValue3_CB  
        
        function filterValue4_CB( obj , hobj , ~ )
            obj.FilterValue4SelValue = get(hobj,'Value');  
            selStr = obj.FilterValue4String{obj.FilterValue4SelValue};
            % Reset the range filter
            obj.FilterRange4String = selStr;
            calculateFilter4ColLogicalArray( obj ); 
            update(obj); 
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % filterValue4_CB 
        
        function filterRange1_CB( obj , hobj , ~ )
            % Reset the current filter
            obj.FilterValue1SelValue = 1;
            
            userString = get(hobj,'String'); 
            obj.FilterRange1String = userString; 
            
            calculateFilter1ColLogicalArrayRange(obj);

            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
            
            update(obj);
            
            %24.9,45-55,65
        end % filterRange1_CB        
        
        function filterRange2_CB( obj , hobj , ~ )
            % Reset the current filter
            obj.FilterValue2SelValue = 1;
            
            userString = get(hobj,'String'); 
            obj.FilterRange2String = userString; 
            
            calculateFilter2ColLogicalArrayRange(obj);

            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
            
            update(obj);
        end % filterRange2_CB   
        
        function filterRange3_CB( obj , hobj , ~ )
            % Reset the current filter
            obj.FilterValue3SelValue = 1;
            
            userString = get(hobj,'String'); 
            obj.FilterRange3String = userString;
            
            calculateFilter3ColLogicalArrayRange(obj);

            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
             
            update(obj);
        end % filterRange3_CB  
        
        function filterRange4_CB( obj , hobj , ~ )
            % Reset the current filter
            obj.FilterValue4SelValue = 1;
            
            userString = get(hobj,'String'); 
            obj.FilterRange4String = userString; 

            calculateFilter4ColLogicalArrayRange(obj);

            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
            
            update(obj);
        end % filterRange4_CB       
        
        function setValueFilter1( obj )
            if obj.FilterVar1SelValue == 1% && (isempty(obj.FilterRange1String) || strcmp(obj.FilterRange1String, 'All'))
                obj.FilterValue1String = {'All'};  
%                 obj.FilterVar1SelValue = 1;
%                 obj.FilterRange1String = [];
%                 obj.Filter1ColumnLogicalArray = true(size(obj.Data,2),1);
            else                      
                data = obj.DisplayData( obj.FilterVar1SelValue - 1 , 4:end);                 
                obj.FilterValue1String = createUniqueCellStringWithAll( obj, data );
%                 obj.calculateFilter1ColLogicalArrayRange();
            end
            
            obj.FilterRange1String = [];
            
            obj.FilterVar2SelValue = 1;
            obj.FilterValue2SelValue = 1;
            obj.FilterValue2String = {'All'};
            obj.FilterRange2String = [];

            obj.FilterVar3SelValue = 1;
            obj.FilterValue3SelValue = 1;
            obj.FilterValue3String = {'All'};
            obj.FilterRange3String = [];

            obj.FilterVar4SelValue = 1;
            obj.FilterValue4SelValue = 1;
            obj.FilterValue4String = {'All'};
            obj.FilterRange4String = [];

            obj.Filter1ColumnLogicalArray = true(size(obj.Data,2),1);
            obj.Filter2ColumnLogicalArray = true(size(obj.Data,2),1);
            obj.Filter3ColumnLogicalArray = true(size(obj.Data,2),1);
            obj.Filter4ColumnLogicalArray = true(size(obj.Data,2),1);
                
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % setValueFilter1
        
        function setValueFilter2( obj )
            if obj.FilterVar2SelValue == 1% && (isempty(obj.FilterRange2String) || strcmp(obj.FilterRange2String, 'All'))
                obj.FilterValue2String = {'All'};
                obj.FilterValue2SelValue = 1;
%                 obj.FilterRange2String = [];
%                 obj.Filter2ColumnLogicalArray = true(size(obj.Data,2),1);
            else
                data = obj.DisplayData(obj.FilterVar2SelValue - 1 , 4:end); 
                obj.FilterValue2String = createUniqueCellStringWithAll( obj, data );
%                 obj.calculateFilter2ColLogicalArrayRange();
            end
            
            obj.FilterRange2String = [];
            obj.Filter2ColumnLogicalArray = true(size(obj.Data,2),1);
%             obj.calculateFilter2ColLogicalArrayRange();
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % setValueFilter2
        
        function setValueFilter3( obj )
            if obj.FilterVar3SelValue == 1
                obj.FilterValue3String = {'All'};
                obj.FilterValue3SelValue = 1;
            else
                data = obj.DisplayData(obj.FilterVar3SelValue - 1 , 4:end); 
                obj.FilterValue3String = createUniqueCellStringWithAll( obj, data );
            end
            
            obj.FilterRange3String = [];
            obj.Filter3ColumnLogicalArray = true(size(obj.Data,2),1);
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % setValueFilter3
        
        function setValueFilter4( obj )
            if obj.FilterVar4SelValue == 1
                obj.FilterValue4String = {'All'};
                obj.FilterValue4SelValue = 1;
            else
                data = obj.DisplayData(obj.FilterVar4SelValue - 1 , 4:end);
                obj.FilterValue4String = createUniqueCellStringWithAll( obj, data );
            end
            
            obj.FilterRange4String = [];
            obj.Filter4ColumnLogicalArray = true(size(obj.Data,2),1);
            notify(obj,'ColumnSelectedEvent',UserInterface.StabilityControl.ColumnSelectedEventData(obj.ColumnLogicArray));
        end % setValueFilter4
                
    end
 
    %% Methods - Filter Callbacks Private
    methods (Access = private)
        
        function calculateFilter1ColLogicalArray( obj )
            
            selStr = obj.FilterValue1String{obj.FilterValue1SelValue};
            selectedVar = obj.DisplayData(obj.FilterVar1SelValue - 1 , 1:2);
            selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
            selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
            data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end);
            if obj.FilterValue1SelValue ~= 1                                    
                logicalArray = strcmp(selStr,cellfun(@(x) num2str(x,obj.TableFormatString),data,'UniformOutput',0));
                obj.Filter1ColumnLogicalArray = [true;true;true;logicalArray'];
            else % User selected All
                obj.Filter1ColumnLogicalArray = true(size(obj.Data,2),1);
            end 
            
        end % calculateFilter1ColLogicalArray   
        
        function calculateFilter2ColLogicalArray( obj )
            
            selStr = obj.FilterValue2String{obj.FilterValue2SelValue};
            selectedVar = obj.DisplayData(obj.FilterVar2SelValue - 1 , 1:2);
            selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
            selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
            data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end);
            if obj.FilterValue2SelValue ~= 1                                    
                logicalArray = strcmp(selStr,cellfun(@(x) num2str(x,obj.TableFormatString),data,'UniformOutput',0));
                obj.Filter2ColumnLogicalArray = [true;true;true;logicalArray'];
            else % User selected All
                obj.Filter2ColumnLogicalArray = true(size(obj.Data,2),1);
            end 
            
        end % calculateFilter2ColLogicalArray   
        
        function calculateFilter3ColLogicalArray( obj )
            
            selStr = obj.FilterValue3String{obj.FilterValue3SelValue};
            selectedVar = obj.DisplayData(obj.FilterVar3SelValue - 1 , 1:2);
            selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
            selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
            data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end);
            if obj.FilterValue3SelValue ~= 1                                    
                logicalArray = strcmp(selStr,cellfun(@(x) num2str(x,obj.TableFormatString),data,'UniformOutput',0));
                obj.Filter3ColumnLogicalArray = [true;true;true;logicalArray'];
            else % User selected All
                obj.Filter3ColumnLogicalArray = true(size(obj.Data,2),1);
            end 
            
        end % calculateFilter3ColLogicalArray   
        
        function calculateFilter4ColLogicalArray( obj )
            
            selStr = obj.FilterValue4String{obj.FilterValue4SelValue};
            selectedVar = obj.DisplayData(obj.FilterVar4SelValue - 1 , 1:2);
            selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
            selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
            data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end);
            if obj.FilterValue4SelValue ~= 1                                    
                logicalArray = strcmp(selStr,cellfun(@(x) num2str(x,obj.TableFormatString),data,'UniformOutput',0));
                obj.Filter4ColumnLogicalArray = [true;true;true;logicalArray'];
            else % User selected All
                obj.Filter4ColumnLogicalArray = true(size(obj.Data,2),1);
            end 
            
        end % calculateFilter4ColLogicalArray
        
        function calculateFilter1ColLogicalArrayRange(obj)
            
%             strCell = strsplit(obj.FilterRange1String,',');
%            
%             
%             % Check for errors
%             if obj.FilterVar1SelValue == 1
%                 update(obj);
%                 notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('You must choose a variable before adding a value range.','warn')); 
%                 return;
%             end
%             
%             
%             % Get all possible for compare
%             selectedVar = obj.DisplayData(obj.FilterVar1SelValue - 1 , 1:2);
%             selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
%             selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
%             data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end); 
%             
%             logicalArray = false(1,length(data));
%             for i = 1:length(strCell)
% 
%                 expression = '(^\-?\d+$)|^(\-?\d+)\-(\-?\d+)$';
%                 rangeTest = regexp(strCell{i},expression,'tokens');
%                 if isempty(rangeTest)
%                     notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['"',strCell{i},'" must be a numeric value or range.'],'error')); 
%                     return;
%                 end
%                 rangeTest = rangeTest{:};
%                 %rangeTest = strsplit(strCell{i},'-');
%                 
%                 
%                 if length(rangeTest) == 1
%                     if isempty( str2num(rangeTest{:}) )
%                         if ~any(strcmpi('All',rangeTest{:}))
%                             notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['"',rangeTest{:},'" must be a numeric value.'],'error')); 
%                         end
%                         update(obj);
%                         return;
%                     end
%                     dif = abs(cell2mat(data) - str2num(rangeTest{:})); %#ok<ST2NM>
%                     logicalArray = (dif == min(dif)) | logicalArray;
%                 elseif length(rangeTest) == 2
%                     if isempty( str2num(rangeTest{1}) ) || isempty( str2num(rangeTest{2}) )
%                         notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Format of range value incorrect.'],'error')); 
%                         update(obj);
%                         return;
%                     end   
%                     minValue = str2num(rangeTest{1}); %#ok<ST2NM>
%                     maxValue = str2num(rangeTest{2}); %#ok<ST2NM>
%                     tempData = cell2mat(data);
%                     logicalArray = ((tempData >= minValue) & (tempData <= maxValue)) | logicalArray;
%                     
%                 else
%                     error('Incorrect syntax for filter range.');
%                 end
%             end
%             
%             obj.Filter1ColumnLogicalArray = [true;true;true;logicalArray'];
            filter1ColumnLogicalArray = calculateFilterHelperColLogicalArrayRange(obj,obj.FilterRange1String,obj.FilterVar1SelValue);
            if ~isempty(filter1ColumnLogicalArray)
                obj.Filter1ColumnLogicalArray = filter1ColumnLogicalArray;
            end
            
        end % calculateFilter1ColLogicalArrayRange
        
        function calculateFilter2ColLogicalArrayRange(obj)            
            filter2ColumnLogicalArray = calculateFilterHelperColLogicalArrayRange(obj,obj.FilterRange2String,obj.FilterVar2SelValue);
            if ~isempty(filter2ColumnLogicalArray)
                obj.Filter2ColumnLogicalArray = filter2ColumnLogicalArray;
            end
        end % calculateFilter2ColLogicalArrayRange
        
        function calculateFilter3ColLogicalArrayRange(obj)
            filter3ColumnLogicalArray = calculateFilterHelperColLogicalArrayRange(obj,obj.FilterRange3String,obj.FilterVar3SelValue);
            if ~isempty(filter3ColumnLogicalArray)
                obj.Filter3ColumnLogicalArray = filter3ColumnLogicalArray;
            end
        end % calculateFilter3ColLogicalArrayRange
        
        function calculateFilter4ColLogicalArrayRange(obj)
            filter4ColumnLogicalArray = calculateFilterHelperColLogicalArrayRange(obj,obj.FilterRange4String,obj.FilterVar4SelValue);
            if ~isempty(filter4ColumnLogicalArray)
                obj.Filter4ColumnLogicalArray = filter4ColumnLogicalArray;
            end
        end % calculateFilter4ColLogicalArrayRange
        
        function filterColumnLogicalArray = calculateFilterHelperColLogicalArrayRange(obj,filterRangeString,filterVarSelValue)
            % calculateFilterHelperColLogicalArrayRange(obj,obj.FilterRange1String,obj.FilterVar1SelValue)
            filterColumnLogicalArray = [];
            
            % Check for errors
            if filterVarSelValue == 1 || isempty(filterRangeString) || strcmpi(filterRangeString, 'ALL')
                update(obj);
%                 notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('You must choose a variable before adding a value range.','warn')); 
                filterColumnLogicalArray = true(size(obj.Data,2),1);
                return;
            end
            
            % Get all possible for compare
            selectedVar = obj.DisplayData(filterVarSelValue - 1 , 1:2);
            selVarTypeLogArray = strcmp(selectedVar{1},obj.Data(:,1));
            selVarNameLogArray = strcmp(selectedVar{2},obj.Data(:,2));
            data = obj.Data( selVarTypeLogArray & selVarNameLogArray , 4:end); 
            
            strCell = strsplit(filterRangeString,',');
           
            logicalArray = false(1,length(data));
            for i = 1:length(strCell)

                expression = '(^\-?\d*\.?\d+$)|^(\-?\d*\.?\d+)\-(\-?\d*\.?\d+)$';%'(^\-?\d+$)|^(\-?\d+)\-(\-?\d+)$';
                rangeTest = regexp(strCell{i},expression,'tokens');
                if isempty(rangeTest)
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['"',strCell{i},'" must be a numeric value or range.'],'error')); 
                    return;
                end
                rangeTest = rangeTest{:};
                %rangeTest = strsplit(strCell{i},'-');
                
                
                if length(rangeTest) == 1
                    if isempty( str2double(rangeTest{:}) )
                        if ~any(strcmpi('All',rangeTest{:}))
                            notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['"',rangeTest{:},'" must be a numeric value.'],'error')); 
                        end
                        update(obj);
                        return;
                    end
                    dif = abs(cell2mat(data) - str2num(rangeTest{:})); %#ok<ST2NM>
                    logicalArray = (dif == min(dif)) | logicalArray;
                elseif length(rangeTest) == 2
                    if isempty( str2double(rangeTest{1}) ) || isempty( str2double(rangeTest{2}) )
                        notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Format of range value incorrect.'],'error')); 
                        update(obj);
                        return;
                    end   
                    minValue = str2num(rangeTest{1}); %#ok<ST2NM>
                    maxValue = str2num(rangeTest{2}); %#ok<ST2NM>
                    tempData = cell2mat(data);
                    logicalArray = ((tempData >= minValue) & (tempData <= maxValue)) | logicalArray;
                    
                else
                    error('Incorrect syntax for filter range.');
                end
            end
            
            filterColumnLogicalArray = [true;true;true;logicalArray'];
            
        end % calculateFilter1ColLogicalArrayRange
        
    end
    
    %% Methods - Public Update Methods
    methods 
%         function updateSelectableStrings( obj )
%             
%         end % updateSelectableStrings
% 
%         function updateSelectableValues( obj )
%             
%         end % updateSelectableValues         
    end
        
    %% Methods - Private - Private Update Methods
    methods (Access = private)
        
        function initSize( obj )

            % Row 1
            set(obj.ColFilt1LabelCont,'Units','Pixels',...
                'Position',[5   299   189    15]);
%             set(obj.Filter1Label_tb,'Units','Pixels',...
%                 'Position',[5   299   189    15]);
            
            set(obj.FilterVar1_pm,'Units','Pixels',...
                'Position',[ 5   274   189    22 ]);
            
            set(obj.FilterValue1_pm,'Units','Pixels',...
                'Position',[ 5  249   89.5   22]);
            
            set(obj.FilterRange1_eb,'Units','Pixels',...
                'Position',[ 104.5  249   89.5   22 ]);
            
            
            
            % Row 2
            set(obj.ColFilt2LabelCont,'Units','Pixels',...
                'Position',[5   219   189    15]);     
%             set(obj.Filter2Label_tb,'Units','Pixels',...
%                 'Position',[ 5   219   189    15]);
            
            set(obj.FilterVar2_pm,'Units','Pixels',...
                'Position',[ 5   194   189    22 ]);
            
            set(obj.FilterValue2_pm,'Units','Pixels',...
                'Position',[ 5.0000  169.0000   89.5000   22.0000 ]); 
            
            set(obj.FilterRange2_eb,'Units','Pixels',...
                'Position',[ 104.5000  169.0000   89.5000   22.0000 ]);
            
            % Row 3
            set(obj.ColFilt3LabelCont,'Units','Pixels',...
                'Position',[5   139   189    15]);
%             set(obj.Filter3Label_tb,'Units','Pixels',...
%                 'Position',[  5   139   189    15 ]);
          
            set(obj.FilterVar3_pm,'Units','Pixels',...
                'Position',[ 5   114   189    22 ]);
            
            set(obj.FilterValue3_pm,'Units','Pixels',...
                'Position',[5.0000   89.0000   89.5000   22.0000 ]);
            
            set(obj.FilterRange3_eb,'Units','Pixels',...
                'Position',[ 104.5000   89.0000   89.5000   22.0000 ]);
            
            % Row 4
            set(obj.ColFilt4LabelCont,'Units','Pixels',...
                'Position',[5   59   189    15]);
%             set(obj.Filter4Label_tb,'Units','Pixels',...
%                 'Position',[  5    59   189    15 ]);
          
            set(obj.FilterVar4_pm,'Units','Pixels',...
                'Position',[ 5    34   189    22 ]);
            
            set(obj.FilterValue4_pm,'Units','Pixels',...
                'Position',[ 5.0000    9.0000   89.5000   22.0000 ]);
            
            set(obj.FilterRange4_eb,'Units','Pixels',...
                'Position',[ 104.5000    9.0000   89.5000   22.0000 ]);
            
          
        end % initSize  
        
        function update(obj)
            
            set(obj.FilterVar1_pm,'String',obj.FilterVar1String);
            set(obj.FilterVar2_pm,'String',obj.FilterVar2String);
            set(obj.FilterVar3_pm,'String',obj.FilterVar3String);
            set(obj.FilterVar4_pm,'String',obj.FilterVar4String);
            
            set(obj.FilterVar1_pm,'Value',obj.FilterVar1SelValue);
            set(obj.FilterVar2_pm,'Value',obj.FilterVar2SelValue);
            set(obj.FilterVar3_pm,'Value',obj.FilterVar3SelValue);
            set(obj.FilterVar4_pm,'Value',obj.FilterVar4SelValue);       
            
            set(obj.FilterValue1_pm,'String',obj.FilterValue1String);
            set(obj.FilterValue2_pm,'String',obj.FilterValue2String);
            set(obj.FilterValue3_pm,'String',obj.FilterValue3String);
            set(obj.FilterValue4_pm,'String',obj.FilterValue4String);
            
            set(obj.FilterValue1_pm,'Value',obj.FilterValue1SelValue);
            set(obj.FilterValue2_pm,'Value',obj.FilterValue2SelValue);
            set(obj.FilterValue3_pm,'Value',obj.FilterValue3SelValue);
            set(obj.FilterValue4_pm,'Value',obj.FilterValue4SelValue);  
            
            set(obj.FilterRange1_eb,'String',obj.FilterRange1String);
            set(obj.FilterRange2_eb,'String',obj.FilterRange2String);
            set(obj.FilterRange3_eb,'String',obj.FilterRange3String);
            set(obj.FilterRange4_eb,'String',obj.FilterRange4String);

        end % update
        
        function reSize( obj , ~ , ~ )
            parentPos = getpixelposition(obj.SelectionPopUpContainer);

                        
            sepPixels = (parentPos(4)-(27))/5 ;
            groupDist = 65;
            sepDist = 15;

            % Row 1
            set(obj.ColFilt1LabelCont,'Units','Pixels',...
                'Position',[ 5 , parentPos(4) - 15 , parentPos(3) - 10 , 15 ]);
            
            set(obj.FilterVar1_pm,'Units','Pixels',...
                'Position',[ 5 , parentPos(4) - 40 , parentPos(3) - 10 , 22 ]);
            
            set(obj.FilterValue1_pm,'Units','Pixels',...
                'Position',[ 5 , parentPos(4) - 65 , ((parentPos(3)/2) - 10) , 22 ]);
            
            set(obj.FilterRange1_eb,'Units','Pixels',...
                'Position',[ ((parentPos(3)/2) + 5) , parentPos(4) - 65 , ((parentPos(3)/2) - 10) , 22 ]);
            
            
            
            % Row 2
            set(obj.ColFilt2LabelCont,'Units','Pixels',...
                'Position',[ 5 , parentPos(4) - groupDist - sepDist - 15 , parentPos(3) - 10 , 15 ]);
            
            set(obj.FilterVar2_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist - sepDist - 40), parentPos(3) - 10 , 22 ]);
            
            set(obj.FilterValue2_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist - sepDist - 65), ((parentPos(3)/2) - 10) , 22 ]); 
            
            set(obj.FilterRange2_eb,'Units','Pixels',...
                'Position',[ ((parentPos(3)/2) + 5) , (parentPos(4) - groupDist - sepDist - 65) , ((parentPos(3)/2) - 10) , 22 ]);
            
            % Row 3
            set(obj.ColFilt3LabelCont,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*2 - sepDist*2 - 15) , parentPos(3) - 10 , 15 ]);
          
            set(obj.FilterVar3_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*2 - sepDist*2 - 40) , parentPos(3) - 10 , 22 ]);
            
            set(obj.FilterValue3_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*2 - sepDist*2 - 65) , ((parentPos(3)/2) - 10) , 22 ]);
            
            set(obj.FilterRange3_eb,'Units','Pixels',...
                'Position',[ ((parentPos(3)/2) + 5) , (parentPos(4) - groupDist*2 - sepDist*2 - 65) , ((parentPos(3)/2) - 10) , 22 ]);
            
            % Row 4
            set(obj.ColFilt4LabelCont,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*3 - sepDist*3 - 15) , parentPos(3) - 10 , 15 ]);
          
            set(obj.FilterVar4_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*3 - sepDist*3 - 40) , parentPos(3) - 10 , 22 ]);
            
            set(obj.FilterValue4_pm,'Units','Pixels',...
                'Position',[ 5 , (parentPos(4) - groupDist*3 - sepDist*3 - 65) , ((parentPos(3)/2) - 10) , 22 ]);
            
            set(obj.FilterRange4_eb,'Units','Pixels',...
                'Position',[ ((parentPos(3)/2) + 5) , (parentPos(4) - groupDist*3 - sepDist*3 - 65) , ((parentPos(3)/2) - 10) , 22 ]);
            
            
%             % Row 1
%             set(obj.FilterVar1_pm,'Units','Pixels',...
%                 'Position',[ 5 , parentPos(4) - (sepPixels*1) , 100 , 22 ]);
%             
%             set(obj.FilterValue1_pm,'Units','Pixels',...
%                 'Position',[ 110 , parentPos(4) - (sepPixels*1) , parentPos(3) - 115 , 22 ]);
%             
%             % Row 2
%             set(obj.FilterVar2_pm,'Units','Pixels',...
%                 'Position',[ 5 , parentPos(4) - (sepPixels*2), 100 , 22 ]);
%             
%             set(obj.FilterValue2_pm,'Units','Pixels',...
%                 'Position',[ 110 , parentPos(4) - (sepPixels*2) , parentPos(3) - 115 , 22 ]);      
%             
%             % Row 3
%             set(obj.FilterVar3_pm,'Units','Pixels',...
%                 'Position',[ 5 , parentPos(4) - (sepPixels*3) , 100 , 22 ]);
%             
%             set(obj.FilterValue3_pm,'Units','Pixels',...
%                 'Position',[ 110 , parentPos(4) - (sepPixels*3) , parentPos(3) - 115 , 22 ]);
%             
%             % Row 4
%             set(obj.FilterVar4_pm,'Units','Pixels',...
%                 'Position',[ 5 , parentPos(4) - (sepPixels*4) , 100 , 22 ]);
%             
%             set(obj.FilterValue4_pm,'Units','Pixels',...
%                 'Position',[ 110 , parentPos(4) - (sepPixels*4) , parentPos(3) - 115 , 22 ]);
        end % reSize  
        
        function y = createUniqueCellStringWithAll( obj, data )
            y = ['All';cellstr(unique(cellfun(@(x) num2str(x,obj.TableFormatString),data,'UniformOutput',0)))'];
        end 
    end
    
    %% Methods - Protected -  Copy
    methods (Access = protected)            
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
%             % Make a deep copy of the xxxx object
%             cpObj.xxxx = copy(obj.xxxx);
            
        end
        
    end
    
end

