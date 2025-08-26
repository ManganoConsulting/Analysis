classdef GainCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Data Storage
    properties  
        DesignOperatingCondition lacm.OperatingCondition = lacm.OperatingCondition.empty
        Gain ScatteredGain.Gain = ScatteredGain.Gain.empty
        SynthesisDesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty 
        RequirementDesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty 
        Filters UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        OperCondFilterSettings = UserInterface.ControlDesign.OperCondFilterSettings.empty
        Date
    end % Public properties
        
%     %% Public properties - Object Handles
%     properties ( Transient = true )  
%         Gain_Parent
%         Gain_Container
%         GainTable
%         Gain_LabelComp
%         Gain_LabelCont
% 
%         Req_Parent
%         Req_Container
%         ReqTable
%         Req_LabelComp
%         Req_LabelCont
% 
%     end % Public properties
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )

    end % Read-only properties
    
    %% Hidden Properties - Design Tool
    properties (Hidden = true)
        Selected
        Color
    end % Hidden properties

    %% Dependant properties SetAccess = private
    properties (Dependent = true, SetAccess = private)
        DesignParameter ScatteredGain.Parameter = ScatteredGain.Parameter.empty  
    end % Dependant properties
    
%     %% Dependant properties
%     properties ( Dependent = true )
%         Gain_Units
%         Gain_Position  
%         Gain_Visible
%         Gain_Enable
%         GainTableData
%         
%         Req_Units
%         Req_Position  
%         Req_Visible
%         Req_Enable
%         ReqTableData
%     end % Dependant properties

        %% Private properties
    properties
        Gain_PrivatePosition = [0 0 1 1]
        Gain_PrivateUnits = 'normalized'
        Gain_PrivateVisible
        Gain_PrivateEnable
        
        Req_PrivatePosition = [0 0 1 1]
        Req_PrivateUnits = 'normalized'
        Req_PrivateVisible
        Req_PrivateEnable 
    end
    
%     %% Events
%     events
%         ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
%     end
    %% Methods - Constructor
    methods   
        
        function obj = GainCollection( varargin )
%             obj.DesignOperatingCondition = oc;
%             obj.Gain = gain;
%             obj.DesignParameter = param;
%             obj.Date = datestr(now);
            
            
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'OperatingCondition',lacm.OperatingCondition.empty);
            addParameter(p,'Gains',ScatteredGain.Gain.empty);
            addParameter(p,'SynthesisDesignParameter',ScatteredGain.Parameter.empty );
            addParameter(p,'RequirementDesignParameter',ScatteredGain.Parameter.empty );
            addParameter(p,'Filters',UserInterface.ControlDesign.Filter.empty );
            addParameter(p,'OperCondFilterSettings',UserInterface.ControlDesign.OperCondFilterSettings.empty );
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.DesignOperatingCondition = options.OperatingCondition;
            obj.Gain = options.Gains;
            %obj.DesignParameter = options.Parameters;
            obj.SynthesisDesignParameter = options.SynthesisDesignParameter;
            obj.RequirementDesignParameter = options.RequirementDesignParameter;
            obj.Filters = options.Filters;
            obj.OperCondFilterSettings = options.OperCondFilterSettings;
            
            obj.Date = datestr(now);
            
            check4RepeatedName( obj );
        end % GainCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
        function y = get.DesignParameter( obj )
            y = Utilities.rowcat(obj.SynthesisDesignParameter,obj.RequirementDesignParameter);
        end %DesignParameter
        
%         function set.Gain_Position( obj , pos )
%             set(obj.Gain_Container,'Position',pos);
%             obj.Gain_PrivatePosition = pos;
%         end % Gain_Position - Set
%         
%         function y = get.Gain_Position( obj )
%             y = obj.Gain_PrivatePosition;
%         end % Gain_Position - Get
%         
%         function set.Gain_Units( obj , units )
%             set(obj.Gain_Container,'Units',units);
%             obj.Gain_PrivateUnits = units;
%         end % Gain_Units -Set
%         
%         function y = get.Gain_Units( obj )
%             y = obj.Gain_PrivateUnits;
%         end % Gain_Units -Get
%         
%         function set.Gain_Visible(obj,value)
%             obj.Gain_PrivateVisible = value;
%             if value
%                 set(obj.Gain_Container,'Visible','on');
%             else
%                 set(obj.Gain_Container,'Visible','off');
%             end            
%         end % Gain_Visible - Set
%         
%         function y = get.Gain_Visible(obj)
%             y = obj.Gain_PrivateVisible;          
%         end % Gain_Visible - Get
%         
%         function set.Gain_Enable(obj,value)
%             obj.Gain_PrivateEnable = value;
%             enablePanel( obj , value );          
%         end % Gain_Enable - Set
%         
%         function y = get.Gain_Enable(obj)
%             y = obj.Gain_PrivateVisible;          
%         end % Gain_Enable - Get 
%         
%         function y = get.GainTableData(obj)
%             y = {};
%             for i = 1:length(obj.Gain)
%                 y(i,:) = {obj.Gain(i).Name, obj.Gain(i).Value};
%             end
%             
%         end % GainTableData - Get
%         
%         function set.Req_Position( obj , pos )
%             set(obj.Req_Container,'Position',pos);
%             obj.Req_PrivatePosition = pos;
%         end % Req_Position - Set
%         
%         function y = get.Req_Position( obj )
%             y = obj.Req_PrivatePosition;
%         end % Req_Position - Get
%         
%         function set.Req_Units( obj , units )
%             set(obj.Req_Container,'Units',units);
%             obj.Req_PrivateUnits = units;
%         end % Req_Units -Set
%         
%         function y = get.Req_Units( obj )
%             y = obj.Req_PrivateUnits;
%         end % Req_Units -Get
%         
%         function set.Req_Visible(obj,value)
%             obj.Req_PrivateVisible = value;
%             if value
%                 set(obj.Req_Container,'Visible','on');
%             else
%                 set(obj.Req_Container,'Visible','off');
%             end            
%         end % Req_Visible - Set
%         
%         function y = get.Req_Visible(obj)
%             y = obj.Req_PrivateVisible;          
%         end % Req_Visible - Get
%         
%         function set.Req_Enable(obj,value)
%             obj.Req_PrivateEnable = value;
%             enablePanel( obj , value );          
%         end % Req_Enable - Set
%         
%         function y = get.Req_Enable(obj)
%             y = obj.Req_PrivateVisible;          
%         end % Req_Enable - Get 
%         
%         function y = get.ReqTableData(obj)
%             y = {};
%             for i = 1:length(obj.RequirementDesignParameter)
%                 if isscalar(obj.RequirementDesignParameter(i).Value)
%                     y(end+1,:) = {obj.RequirementDesignParameter(i).Name, obj.RequirementDesignParameter(i).Value};
%                 end
%             end
%             
%         end % ReqTableData - Get
              
    end % Property access methods
    
    %% Methods - Callbacks
    methods 

    end % Callback Methods 
    
    %% Methods - Ordinary
    methods 
        
        function check4RepeatedName( obj )
            try
                A = unique({obj.DesignParameter.Name});
                B = unique({obj.Gain.Name});
                C = intersect(A,B);
                if ~isempty(C)
                    error('GainCollection:InvalidName','The names must be unique between the gains and parameters.');
                end
            end
        end % check4RepeatedName
       
        function file = write2File( obj, ScatteredGainObjName)
            
            
            [file, path] = uiputfile(...
                {'*.txt';'*.*'},...
                'Save as');
            
            drawnow();pause(0.5);
            
            
            fid = fopen(fullfile(path,file),'w');
            
            fprintf(fid,'%s\n','% -------------------------- GENERAL INFORMATION ---------------------------------------------');
            fprintf(fid,'\n');
            fprintf(fid,'%s%s\n',' SCATTERED GAINS COLLECTION',['  : ' ScatteredGainObjName]);
            fprintf(fid,'\n');
            fprintf(fid,'%s%s\n',' DATE                      ',['  : ' datestr(now)]);
            fprintf(fid,'\n');
            
            
            % Number of design conditions
            nCond = length(obj);
            if nCond > 0
                fprintf(fid,'%s%s\n',' NUMBER OF DESIGN CONDITIONS',[' : ' num2str(nCond)]);
                fprintf(fid,'\n');
                fprintf(fid,'%s\n\n','% ---------------------------- DESIGN DATA ---------------------------------------------------');
                
                DateVec(nCond) = datetime;
                for i=1:nCond
                    DateVec(i) = datetime(obj(i).Date);
                end
                [~,isort] = sort(DateVec);
                
                
                for i=isort
                    
                    var{1} = 'Date';
                    val{1} = obj(i).Date;
                    
                    var{2} = obj(i).OperCondFilterSettings.Parameter1_FC1_Str;
                    var{3} = obj(i).OperCondFilterSettings.Parameter2_FC2_Str;
                    var{4} = obj(i).OperCondFilterSettings.Parameter3_IOC_Str;
                    var{5} = obj(i).OperCondFilterSettings.Parameter4_WC_Str;
                    
                    val{2} = obj(i).OperCondFilterSettings.Parameter1_FC1_Value;
                    val{3} = obj(i).OperCondFilterSettings.Parameter2_FC2_Value;
                    val{4} = obj(i).OperCondFilterSettings.Parameter3_IOC_Value;
                    val{5} = obj(i).OperCondFilterSettings.Parameter4_WC_Value;
                    
                    
                    for j=1:length(obj(i).Gain)
                        var{end+1}=obj(i).Gain(j).Name;
                        val{end+1}=num2str(obj(i).Gain(j).Value);
                    end
                    
                    [~,ia]=unique({obj(i).DesignParameter.Name});
                    uniqueParams = obj(i).DesignParameter(ia);
                    
                    for j=1:length(uniqueParams)
                        if isscalar(uniqueParams(j).Value)
                            var{end+1}=uniqueParams(j).Name;
                            val{end+1}=num2str(uniqueParams(j).Value);
                        end
                    end
                    
                    nvar = length(var);
                    
                    formatSpec = ['%-25s',repmat('%-20s',[1,nvar-1]),'\n'];
                    
                    vars = strjoin(strtrim(var),''',''');
                    vals = strjoin(strtrim(val),''',''');

                    eval(['fprintf(fid,''' formatSpec ''',''' vars ''');']);
                    eval(['fprintf(fid,''' formatSpec ''',''' vals ''');']);
                    fprintf(fid,'\n');
                    
                    clear var val
                   
                end
                
            else
                fprintf(fid,'%s%s\n','% NUMBER OF DESIGN CONDITIONS',[' : 0']);
                fprintf(fid,'%s\n','%');
                fprintf(fid,'%s\n','%');
                fprintf(fid,'%s\n','% -------------------------- END OF FILE -----------------------------------------------');
              
            end
                
            
            
            fclose(fid);
            
%             if nargin ==1
%             
%                 file = Utilities.write2mfile(obj.DesignOperatingCondition);
%                 
%             end
%             
% %                         for ind = 1:length(operCond)
% %                 fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
% %                 fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{1} , '= ' , labelData{ind,1} );
% %                 fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{2} , '= ' , labelData{ind,2} );
% %                 fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{3} , '= ' , labelData{ind,3} );
% %                 fprintf(fid1,'%s\t%s\t%s\t%s\n', '%' , labelHeader{4} , '= ' , labelData{ind,4} );
% %                 fprintf(fid1,'%s\n','%--------------------------------------------------------------------------');
% %                 writeOC(operCond(ind),fid1);
% %                 fprintf(fid1,'\n');
% %                 fprintf(fid1,'\n');
% %                 fprintf(fid1,'\n');
% %             end
%             
%             
%             fid = fopen(file{:},'a');
%             for i = 1:length(obj.Gain)
%                 fprintf(fid,'%s\t%s\t%s%s\n'  ,obj.Gain(i).Name,  '= ',mat2str(obj.Gain(i).Value), ';'); 
%             end
%             
%             [~,ia]=unique({obj.DesignParameter.Name});
%             uniqueParams = obj.DesignParameter(ia);
%             
%             for i = 1:length(uniqueParams)
%                 fprintf(fid,'%s\t%s\t%s%s\n'  ,uniqueParams(i).Name,  '= ',mat2str(uniqueParams(i).Value), ';');
%             end 
%             
%             fclose(fid);
        end % write2File  
        
        function y = eq(A,B)
            if isempty(A) || isempty(B)
                y = false;
            elseif length(A) == length(B)
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end
            elseif length(A) == 1 && length(B) > 1
                y = false(1,length(B));
                for i = 1:length(B)
                    if A.DesignOperatingCondition == B(i).DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end   
            elseif length(A) > 1 && length(B) == 1
                y = false(1,length(A));
                for i = 1:length(A)
                    if A(i).DesignOperatingCondition == B.DesignOperatingCondition
                        y(i) = true; 
                    else 
                        y(i) = false;
                    end
                end     
            end
        end % eq
        
    end % Ordinary Methods    
       
%     %% Methods - View
%     methods     
%         
%         function gain_createView( obj , parent )
%             if nargin == 1
%                 obj.Gain_Parent = figure();
%             else 
%                 obj.Gain_Parent = parent;
%             end
%             % Create GUI 
%             obj.Gain_Container = uicontainer('Parent',obj.Gain_Parent,...
%                 'Units',obj.Gain_Units,...
%                 'Position',obj.Gain_Position);
%             set(obj.Gain_Container,'ResizeFcn',@obj.gain_reSize);
%             
%             panelPos = getpixelposition(obj.Gain_Container);
%             
%             labelStr = '<html><font color="white" face="Courier New">&nbsp;Scattered Gains</html>';
%             jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
%             jLabelview.setOpaque(true);
%             jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
%             jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
%             jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
%             [obj.Gain_LabelComp,obj.Gain_LabelCont] = javacomponent(jLabelview,[ 1 , panelPos(4) - 16 , panelPos(3) , 16 ], obj.Gain_Container );
%             
% %             topFig = ancestor(obj.Gain_Container,'figure','toplevel');
% %             cm = uicontextmenu(topFig);
% %             m1 = uimenu(cm,'Text','Enlarge','Callback',@obj.enlargeGainColl);
%             
%             obj.GainTable = uitable('Parent',obj.Gain_Container,...
%                 'ColumnName',{'Gain','Value'},...
%                 'RowName',[],...
%                 'ColumnEditable', [false,true],...
%                 'ColumnFormat',{'char','numeric'},...
%                 'ColumnWidth',{100,150},...
%                 'Data',obj.GainTableData,...%'uicontextmenu',cm,...
%                 'CellEditCallback', @obj.gainTable_ce_CB,...
%                 'CellSelectionCallback', @obj.gainTable_cs_CB);    
%             
% %             obj.JavaGainTable = javaObjectEDT(Utilities.findjobj(obj.GainTable)); 
%             
%             
%             % Force resize
%             obj.gain_reSize();
%         end % gain_createView       
%         
%         function gain_reSize( obj , ~ , ~ )
%             panelPos = getpixelposition(obj.Gain_Container); 
% 
%             obj.Gain_LabelCont.Units = 'Pixels';
%             obj.Gain_LabelCont.Position = [ 1 , panelPos(4) - 16 , panelPos(3) , 16 ];
%             
%             set(obj.GainTable,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) - 5 , panelPos(4) - 20 ] );  
%         end   
% 
%         function gainTable_ce_CB( obj , ~ , eventData )
%             gainIndex = eventData.Indices(1);
% 
%             obj.Gain(gainIndex).Value = str2double(eventData.EditData);  
%             obj.gain_update();
%         end % gainTable_ce_CB
% 
%         function gainTable_cs_CB( obj , ~ , ~ )
%    
% 
%         end % gainTable_cs_CB
%         
%         function gain_update(obj)
%             
%             % Get the current scroll position - workaround for the uitable
%             % bug
% %             if ishandle(obj.GainTableLarge)
% %                 jscrollpane = obj.JavaGainTableLarge;
% %             else
% %                 jscrollpane = obj.JavaGainTable;
% %             end
% %             viewport    = javaObjectEDT(jscrollpane.getViewport);
% %             P = viewport.getViewPosition();
% %             jtable = javaObjectEDT( viewport.getView );
%             
%             
%             
% %             obj.GainTableData(~obj.ShowValue,2) = {'-'};
%             set(obj.GainTable,'Data',obj.GainTableData);
% %             if ishandle(obj.GainTableLarge)
% %                 set(obj.GainTableLarge,'Data',obj.GainTableData);
% %             end
%             
%             
% %             % Set the current scroll position back - workaround for the uitable
% %             % bug
% %             drawnow();
% %             viewport.setViewPosition(P);
%             
%             
%         end % gain_update
% 
%         function req_createView( obj , parent )
%             if nargin == 1
%                 obj.Req_Parent = figure();
%             else 
%                 obj.Req_Parent = parent;
%             end
%             % Create GUI 
%             obj.Req_Container = uicontainer('Parent',obj.Req_Parent,...
%                 'Units',obj.Req_Units,...
%                 'Position',obj.Req_Position);
%             set(obj.Req_Container,'ResizeFcn',@obj.gain_reSize);
%             
%             panelPos = getpixelposition(obj.Req_Container);
%             
%             labelStr = '<html><font color="white" face="Courier New">&nbsp;Scattered Parameters</html>';
%             jLabelview = javaObjectEDT('javax.swing.JLabel',labelStr);
%             jLabelview.setOpaque(true);
%             jLabelview.setBackground(java.awt.Color(int32(55),int32(96),int32(146)));
%             jLabelview.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
%             jLabelview.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
%             [obj.Req_LabelComp,obj.Req_LabelCont] = javacomponent(jLabelview,[ 1 , panelPos(4) - 16 , panelPos(3) , 16 ], obj.Req_Container );
%             
% %             topFig = ancestor(obj.Req_Container,'figure','toplevel');
% %             cm = uicontextmenu(topFig);
% %             m1 = uimenu(cm,'Text','Enlarge','Callback',@obj.enlargeGainColl);
%             
%             obj.ReqTable = uitable('Parent',obj.Req_Container,...
%                 'ColumnName',{'Parameter','Value'},...
%                 'RowName',[],...
%                 'ColumnEditable', [false,true],...
%                 'ColumnFormat',{'char','numeric'},...
%                 'ColumnWidth',{100,150},...
%                 'Data',obj.ReqTableData,...%'uicontextmenu',cm,...
%                 'CellEditCallback', @obj.reqTable_ce_CB,...
%                 'CellSelectionCallback', @obj.reqTable_cs_CB);                        
%             
%             % Force resize
%             obj.req_reSize();
%         end % gain_createView       
%         
%         function req_reSize( obj , ~ , ~ )
%             panelPos = getpixelposition(obj.Req_Container); 
% 
%             obj.Req_LabelCont.Units = 'Pixels';
%             obj.Req_LabelCont.Position = [ 1 , panelPos(4) - 16 , panelPos(3) , 16 ];
%             
%             set(obj.ReqTable,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) - 5 , panelPos(4) - 20 ] );  
%         end   
% 
%         function reqTable_ce_CB( obj , ~ , eventData )
%             reqIndex = eventData.Indices(1);
% 
%             obj.RequirementDesignParameter(reqIndex).Value = str2double(eventData.EditData);  
%             obj.req_update();
%         end % reqTable_ce_CB
% 
%         function reqTable_cs_CB( obj , ~ , ~ )
%    
% 
%         end % reqTable_cs_CB
%         
%         function req_update(obj)
%             
%             % Get the current scroll position - workaround for the uitable
%             % bug
% %             if ishandle(obj.GainTableLarge)
% %                 jscrollpane = obj.JavaGainTableLarge;
% %             else
% %                 jscrollpane = obj.JavaGainTable;
% %             end
% %             viewport    = javaObjectEDT(jscrollpane.getViewport);
% %             P = viewport.getViewPosition();
% %             jtable = javaObjectEDT( viewport.getView );
%             
%             
%             
% %             obj.GainTableData(~obj.ShowValue,2) = {'-'};
%             set(obj.GainTable,'Data',obj.GainTableData);
% %             if ishandle(obj.GainTableLarge)
% %                 set(obj.GainTableLarge,'Data',obj.GainTableData);
% %             end
%             
%             
% %             % Set the current scroll position back - workaround for the uitable
% %             % bug
% %             drawnow();
% %             viewport.setViewPosition(P);
%             
%             
%         end % req_update
%     end
    
    %% Methods - Protected
    methods (Access = protected)     

        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DesignOperatingCondition object
            cpObj.DesignOperatingCondition = copy(obj.DesignOperatingCondition);
            % Make a deep copy of the Gain object
            cpObj.Gain = copy(obj.Gain);
            % Make a deep copy of the SynthesisDesignParameter object
            cpObj.SynthesisDesignParameter = copy(obj.SynthesisDesignParameter);  
            % Make a deep copy of the RequirementDesignParameter object
            cpObj.RequirementDesignParameter = copy(obj.RequirementDesignParameter);    
            % Make a deep copy of the Filter object
            cpObj.Filters = copy(obj.Filters);  
        end % copyElement
        
    end
    
    %% Methods - Private
    methods ( Access = private )
        

        
    end
    
    %% Methods - Static
    methods (Static)

    end
    
    
end