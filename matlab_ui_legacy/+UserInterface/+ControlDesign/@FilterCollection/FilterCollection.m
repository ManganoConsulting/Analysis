classdef FilterCollection < matlab.mixin.Copyable & hgsetget
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        Container
        FilterContainer
        ButtonContainer
        FilterParameterContainer
        
        AddJButton
        AddButtonComp
        AddButtonCont
        RemoveJButton
        RemoveButtonComp
        RemoveButtonCont
        PlotJButton
        PlotButtonComp
        PlotButtonCont
        ExportJButton
        ExportButtonComp
        ExportButtonCont
        
        FiltScroll
        FiltTableModel
        FiltJTable
        FiltJTableH
        FiltJScroll
        FiltJHScroll
        FiltHContainer
        FiltTableComp
        FiltTableCont
        
        FiltParamScroll
        FiltParamTableModel
        FiltParamJTable
        FiltParamJTableH
        FiltParamJScroll
        FiltParamJHScroll
        FiltParamHContainer
        FiltParamTableComp
        FiltParamTableCont
        
        FiltMapScroll
        FiltMapTableModel
        FiltMapJTable
        FiltMapJTableH
        FiltMapJScroll
        FiltMapJHScroll
        FiltMapHContainer
        FiltMapTableComp
        FiltMapTableCont
        
        FiltParamTabPanel
        ParamTab
        MapTab
    end % Public properties
      
    %% Public properties - Data Storage
    properties   
        Title
        CurrentSelectedFilterRow
        CurrentSelectedFiltParamRow
        
        RowSelectedFiltParam
        RowSelectedFiltMap

        Filters UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        SelectedParameter
    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )     
        PrivatePosition
        PrivateUnits
        PrivateVisible
        PrivateEnable
    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )
        Position
        Units
        Visible
        Enable
    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )
        CurrentSelectedFilter UserInterface.ControlDesign.Filter = UserInterface.ControlDesign.Filter.empty
        FilterCollTableData
        FilterParamTableData
        FilterMapTableData
        
    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        FilterTypes = {'Lead/Lag - 1st Order',...
                        'Lead/Lag - 2nd Order',...
                        'Notch',...
                        'Complimentary 2nd Order Type 1',...
                        'Complimentary 2nd Order Type 2',...
                        'Complimentary 3rd Order Type 1',...
                        'Complimentary 3rd Order Type 2',...
                        'Complimentary 4th Order Type 1',...
                        'Complimentary 4th Order Type 2',...
                        'Complimentary 4th Order Type 3'};
    end % Constant properties  
    
    %% Events
    events
        UpdateSlider
        ParameterUpdated
        ShowLogMessage % notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(msg,sev));
    end
    
    %% Methods - Constructor
    methods      
        
        function obj = FilterCollection(varargin) 
            if nargin == 0
               return; 
            end  
            p = inputParser;
            addParameter(p,'Parent',gcf);
            addParameter(p,'Units','Normalized',@ischar);
            addParameter(p,'Position',[0,0,1,1]);
            addParameter(p,'Title','Filter');
            p.KeepUnmatched = true;
            parse(p,varargin{:});
            options = p.Results;

            obj.PrivatePosition = options.Position;
            obj.PrivateUnits    = options.Units;
            obj.Title           = options.Title;

            createView( obj , options.Parent );

        end % FilterCollection
        
    end % Constructor

    %% Methods - Property Access
    methods
             
        function y = get.CurrentSelectedFilter( obj ) 
            if isempty(obj.Filters)
                y = UserInterface.ControlDesign.Filter.empty;
            else
                if length(obj.CurrentSelectedFilterRow) == 1
                    y = obj.Filters(obj.CurrentSelectedFilterRow);
                else
                    y = UserInterface.ControlDesign.Filter.empty;
                end
            end
        end % CurrentSelectedFilter - Get
        
        function y = get.FilterCollTableData( obj ) 
            
            if isempty(obj.Filters)
                y = {};
            else
                y = [obj.Filters.displayInRow]'; 
            end
        end % FilterCollTableData - Get
        
        function y = get.FilterParamTableData( obj ) 
            selFil = obj.CurrentSelectedFilter;
            if isempty(selFil)
                y = {};
            else
                y = selFil.displayParamsInTable; 
            end
        end % FilterParamTableData - Get
        
        function y = get.FilterMapTableData( obj ) 
            selFil = obj.CurrentSelectedFilter;
            if isempty(selFil)
                y = {};
            else
                y = selFil.displayMapInTable; 
            end; 
        
        end % FilterMapTableData - Get
                
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
       
        function set.Visible(obj,value)
            obj.PrivateVisible = value;
            if value
                set(obj.Container,'Visible','on');
                set(obj.FilterContainer,'Visible','on');
                set(obj.FilterParameterContainer,'Visible','on');
            else
                set(obj.Container,'Visible','off');
                set(obj.FilterContainer,'Visible','off');
                set(obj.FilterParameterContainer,'Visible','off');
            end            
        end % Visible - Set
        
        function y = get.Visible(obj)
            y = obj.PrivateVisible;          
        end % Visible - Get
        
        function set.Enable(obj,value)
            obj.PrivateEnable = value;
            enablePanel( obj , value );          
        end % Enable - Set
        
        function y = get.Enable(obj)
            y = obj.PrivateVisible;          
        end % Enable - Get
        
    end % Property access methods
    
    %% Methods - View
    methods     
        function createView( obj , parent )
            import javax.swing.*;
            this_dir = fileparts( mfilename( 'fullpath' ) );
            icon_dir = fullfile( this_dir,'..','..','Resources' );  
            
            if nargin == 1
                obj.Parent = figure();
            else 
                obj.Parent = parent;
            end
            % Main Container
            obj.Container = uicontainer('Parent',obj.Parent,...
                'Units', obj.Units,...
                'Position',obj.Position);
            set(obj.Container,'ResizeFcn',@obj.reSize);
            
                % Filter Container
                obj.FilterContainer = uicontainer('Parent',obj.Parent);
                set(obj.FilterContainer,'ResizeFcn',@obj.reSizeFilterC);
                    updateFilterTable( obj );

                % Button Container
                obj.ButtonContainer = uicontainer('Parent',obj.Container);
                set(obj.ButtonContainer,'ResizeFcn',@obj.reSizeButtonC);
                
                    % Add Button             
                    addJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                    addJButton.setText('New   ');        
                    addJButtonH = handle(addJButton,'CallbackProperties');
                    set(addJButtonH, 'ActionPerformedCallback',@obj.addFilter)
                    myIcon = fullfile(icon_dir,'New_16.png');
                    addJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
                    addJButton.setToolTipText('Add New Filter');
                    addJButton.setFlyOverAppearance(true);
                    addJButton.setBorder([]);
                    addJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
                    addJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
                    addJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                    obj.AddJButton = addJButton;
                    [obj.AddButtonComp,obj.AddButtonCont] = javacomponent(obj.AddJButton,[ ], obj.ButtonContainer );
                    

                    % Remove Button             
                    removeJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                    removeJButton.setText('Remove');        
                    removeJButtonH = handle(removeJButton,'CallbackProperties');
                    set(removeJButtonH, 'ActionPerformedCallback',@obj.removeFilter)
                    myIcon = fullfile(icon_dir,'StopX_16.png');
                    removeJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
                    removeJButton.setToolTipText('Add New Item');
                    removeJButton.setFlyOverAppearance(true);
                    removeJButton.setBorder([]);
                    %removeJButton.setVisible(false);
                    removeJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
                    removeJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
                    removeJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                    obj.RemoveJButton = removeJButton;
                    [obj.RemoveButtonComp,obj.RemoveButtonCont] = javacomponent(obj.RemoveJButton,[ ], obj.ButtonContainer );

                    % Plot Button             
                    plotJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                    plotJButton.setText('Plot  ');        
                    plotJButtonH = handle(plotJButton,'CallbackProperties');
                    set(plotJButtonH, 'ActionPerformedCallback',@obj.plotFilter)
                    myIcon = fullfile(icon_dir,'Figure_16.png');
                    plotJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
                    plotJButton.setToolTipText('Add New Item');
                    plotJButton.setFlyOverAppearance(true);
                    plotJButton.setBorder([]);
                    %plotJButton.setVisible(false);
                    plotJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
                    plotJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
                    plotJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                    obj.PlotJButton = plotJButton;
                    [obj.PlotButtonComp,obj.PlotButtonCont] = javacomponent(obj.PlotJButton,[ ], obj.ButtonContainer );
                    
                    % Export Button             
                    exportJButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
                    exportJButton.setText('Export');        
                    exportJButtonH = handle(exportJButton,'CallbackProperties');
                    set(exportJButtonH, 'ActionPerformedCallback',@obj.exportFilter)
                    myIcon = fullfile(icon_dir,'Export_16.png');
                    exportJButton.setIcon(javaObjectEDT('javax.swing.ImageIcon',myIcon));
                    exportJButton.setToolTipText('Add New Item');
                    exportJButton.setFlyOverAppearance(true);
                    exportJButton.setBorder([]);
                    %exportJButton.setVisible(false);
                    exportJButton.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
                    exportJButton.setVerticalTextPosition(javax.swing.SwingConstants.CENTER);
                    exportJButton.setMargin(java.awt.Insets(0, 0, 0, 0));
                    obj.ExportJButton = exportJButton;
                    [obj.ExportButtonComp,obj.ExportButtonCont] = javacomponent(obj.ExportJButton,[ ], obj.ButtonContainer );
      
            
                % Filter Param Container
                obj.FilterParameterContainer = uicontainer('Parent',obj.Parent);
                set(obj.FilterParameterContainer,'ResizeFcn',@obj.reSizeFiltParamC);
                obj.FiltParamTabPanel = uitabgroup('Parent',obj.FilterParameterContainer);%,'SelectionChangedFcn',@obj.updateSelectParamTab); 
                    obj.ParamTab  = uitab('Parent',obj.FiltParamTabPanel);
                    obj.ParamTab.Title = 'Parameters';

                    obj.MapTab  = uitab('Parent',obj.FiltParamTabPanel);
                    obj.MapTab.Title = 'Mapping';
                    
                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );

         reSize( obj );
            
        end % createView

        function updateFilterTable( obj )

            % Remove Table
            if ~isempty(obj.FiltTableCont)
                delete(obj.FiltTableCont);
%                 obj.ContextPane.plot(obj.FiltJScroll); %remove component from your jpanel in this case i used jpanel 
%                 obj.ContextPane.revalidate(); 
%                 obj.ContextPane.repaint();%repaint a JFrame jframe in this case 
            end

            
            obj.FiltTableModel = javax.swing.table.DefaultTableModel(obj.FilterCollTableData,{'Name','Type'});
            obj.FiltJTable = javaObjectEDT(javax.swing.JTable(obj.FiltTableModel));
            obj.FiltJTableH = handle(javaObjectEDT(obj.FiltJTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.FiltJScroll = javaObjectEDT(javax.swing.JScrollPane(obj.FiltJTable));
            [obj.FiltTableComp,obj.FiltTableCont] = javacomponent(obj.FiltJScroll,[], obj.FilterContainer );


            obj.FiltJScroll.setVerticalScrollBarPolicy(obj.FiltJScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.FiltJScroll.setHorizontalScrollBarPolicy(obj.FiltJScroll.HORIZONTAL_SCROLLBAR_NEVER);%(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            %obj.FiltJTable.setAutoResizeMode( obj.FiltJTable.AUTO_RESIZE_OFF );
            
            % Set Callbacks
            obj.FiltJTableH.MousePressedCallback = @obj.mousePressedInFilterTable;
            JModelH = handle(obj.FiltJTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = @obj.dataUpdatedInFilterTable;       


            w1 = 75; column0 = obj.FiltJTable.getColumnModel().getColumn(0);column0.setPreferredWidth(w1);column0.setMinWidth(w1);%column0.setMaxWidth(w1); 
            w2 = 180;column1 = obj.FiltJTable.getColumnModel().getColumn(1);column1.setPreferredWidth(w2);column1.setMinWidth(w2);%column1.setMaxWidth(w2); 
%             w3 = 120;column2 = obj.FiltJTable.getColumnModel().getColumn(2);column2.setPreferredWidth(w3);column2.setMinWidth(w3);column2.setMaxWidth(w3); 
%             w4 = 20; column3 = obj.FiltJTable.getColumnModel().getColumn(3);column3.setPreferredWidth(w4);column3.setMinWidth(w4);column0.setMaxWidth(w4); 

%             % Set Cell Renderer
%             obj.FiltJTable.getColumnModel.getColumn(0).setCellRenderer(com.jidesoft.grid.BooleanCheckBoxCellRenderer); 
%             obj.FiltJTable.getColumnModel.getColumn(0).setCellEditor(com.jidesoft.grid.BooleanCheckBoxCellEditor); 
% 
%             obj.FiltJTable.getColumnModel.getColumn(3).setCellRenderer(com.jidesoft.grid.BooleanCheckBoxCellRenderer); 
%             obj.FiltJTable.getColumnModel.getColumn(3).setCellEditor(com.jidesoft.grid.BooleanCheckBoxCellEditor); 

            comboBox = javax.swing.JComboBox(obj.FilterTypes);
            comboBox.setEditable(false);

            editor = javax.swing.DefaultCellEditor(comboBox);
            obj.FiltJTable.getColumnModel.getColumn(1).setCellEditor(editor); 
           % jtable.getColumnModel.getColumn(0).setCellEditor(editor);


            
% % %             % Set Column width and row colors
% % %             cr = AlignColoredFieldCellRenderer;
% % %             cr.setFgColor( java.awt.Color.black );
% % %             for j = 0:1            
% % %                 obj.FiltJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% % %                 for i = 0:2:double(obj.FiltJTable.getRowCount)
% % %                     cr.setCellBgColor( i,j,java.awt.Color.white ); 
% % %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% % %                 end
% % %                 
% % %             end     
% % %             obj.FiltJTable.setGridColor(java.awt.Color.black);    
% % %             
% % %             for j = 0:1            
% % %                 obj.FiltJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% % %                 for i = 1:2:double(obj.FiltJTable.getRowCount)
% % %                     cr.setCellBgColor( i,j,java.awt.Color( 246/255 , 243/255 , 237/255 )  ); 
% % %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% % %                 end
% % %             end  

            obj.FiltJTable.setGridColor(java.awt.Color.lightGray);

            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.FiltJTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.FiltJTable.repaint;
            obj.FiltJTable.setVisible(true);

            reSizeFilterC( obj , [] , [] );
           
        end % updateFilterTable
        
        function updateFiltParamTable( obj )

            % Remove Table
            if ~isempty(obj.FiltParamTableCont)
                delete(obj.FiltParamTableCont);
%                 obj.ContextPane.plot(obj.FiltParamJScroll); %remove component from your jpanel in this case i used jpanel 
%                 obj.ContextPane.revalidate(); 
%                 obj.ContextPane.repaint();%repaint a JFrame jframe in this case 
            end

            if ~isempty(obj.CurrentSelectedFilter)
                selFilName = obj.CurrentSelectedFilter.Name;
            else
                selFilName = ' ';
            end
            obj.FiltParamTableModel = javax.swing.table.DefaultTableModel(obj.FilterParamTableData,{selFilName,'Value'});
            obj.FiltParamJTable = javaObjectEDT(javax.swing.JTable(obj.FiltParamTableModel));
            obj.FiltParamJTableH = handle(javaObjectEDT(obj.FiltParamJTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.FiltParamJScroll = javaObjectEDT(javax.swing.JScrollPane(obj.FiltParamJTable));
            [obj.FiltParamTableComp,obj.FiltParamTableCont] = javacomponent(obj.FiltParamJScroll,[0,0,1,1], obj.ParamTab );
            set(obj.FiltParamTableCont,'Units','Normal','Position',[0,0,1,1]);

            obj.FiltParamJScroll.setVerticalScrollBarPolicy(obj.FiltParamJScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.FiltParamJScroll.setHorizontalScrollBarPolicy(obj.FiltParamJScroll.HORIZONTAL_SCROLLBAR_NEVER);%(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            %obj.FiltParamJTable.setAutoResizeMode( obj.FiltParamJTable.AUTO_RESIZE_OFF );
            
            % Set Callbacks
            obj.FiltParamJTableH.MousePressedCallback = @obj.mousePressedInFiltParamTable;
            JModelH = handle(obj.FiltParamJTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = @obj.dataUpdatedInFiltParamTable;       


            w1 = 140; column0 = obj.FiltParamJTable.getColumnModel().getColumn(0);column0.setPreferredWidth(w1);column0.setMinWidth(w1);%column0.setMaxWidth(w1); 
            w2 = 100;column1 = obj.FiltParamJTable.getColumnModel().getColumn(1);column1.setPreferredWidth(w2);column1.setMinWidth(w2);%column1.setMaxWidth(w2); 
%             w3 = 120;column2 = obj.FiltParamJTable.getColumnModel().getColumn(2);column2.setPreferredWidth(w3);column2.setMinWidth(w3);column2.setMaxWidth(w3); 
%             w4 = 20; column3 = obj.FiltParamJTable.getColumnModel().getColumn(3);column3.setPreferredWidth(w4);column3.setMinWidth(w4);column0.setMaxWidth(w4); 


            % Set Cell Renderer
            nonEditCR = javax.swing.DefaultCellEditor(javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.
            obj.FiltParamJTable.getColumnModel.getColumn(0).setCellEditor(nonEditCR); 
            

            
% %             % Set Column width and row colors
% %             cr = AlignColoredFieldCellRenderer;
% %             cr.setFgColor( java.awt.Color.black );
% %             for j = 0:1            
% %                 obj.FiltParamJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% %                 for i = 0:2:double(obj.FiltParamJTable.getRowCount)
% %                     cr.setCellBgColor( i,j,java.awt.Color.white ); 
% %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% %                 end
% %                 
% %             end     
% %             obj.FiltParamJTable.setGridColor(java.awt.Color.black);    
% %             
% %             for j = 0:1            
% %                 obj.FiltParamJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% %                 for i = 1:2:double(obj.FiltParamJTable.getRowCount)
% %                     cr.setCellBgColor( i,j,java.awt.Color( 246/255 , 243/255 , 237/255 )  ); 
% %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% %                 end
% %             end  

            obj.FiltParamJTable.setGridColor(java.awt.Color.lightGray);

            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.FiltParamJTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.FiltParamJTable.repaint;
            obj.FiltParamJTable.setVisible(true);
           
        end % updateFiltParamTable
        
        function updateFiltMapTable( obj )

            % Remove Table
            if ~isempty(obj.FiltMapTableCont)
                delete(obj.FiltMapTableCont);
%                 obj.ContextPane.plot(obj.FiltMapJScroll); %remove component from your jpanel in this case i used jpanel 
%                 obj.ContextPane.revalidate(); 
%                 obj.ContextPane.repaint();%repaint a JFrame jframe in this case 
            end

            if ~isempty(obj.CurrentSelectedFilter)
                selFilName = obj.CurrentSelectedFilter.Name;
            else
                selFilName = ' ';
            end
            obj.FiltMapTableModel = javax.swing.table.DefaultTableModel(obj.FilterMapTableData,{selFilName,'Value'});
            obj.FiltMapJTable = javaObjectEDT(javax.swing.JTable(obj.FiltMapTableModel));
            obj.FiltMapJTableH = handle(javaObjectEDT(obj.FiltMapJTable), 'CallbackProperties');  % ensure that we're using EDT
            obj.FiltMapJScroll = javaObjectEDT(javax.swing.JScrollPane(obj.FiltMapJTable));
            [obj.FiltMapTableComp,obj.FiltMapTableCont] = javacomponent(obj.FiltMapJScroll,[], obj.MapTab );
            set(obj.FiltMapTableCont,'Units','Normal','Position',[0,0,1,1]);

            obj.FiltMapJScroll.setVerticalScrollBarPolicy(obj.FiltMapJScroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            obj.FiltMapJScroll.setHorizontalScrollBarPolicy(obj.FiltMapJScroll.HORIZONTAL_SCROLLBAR_NEVER);%(obj.JScroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            %obj.FiltMapJTable.setAutoResizeMode( obj.FiltMapJTable.AUTO_RESIZE_OFF );
            
            % Set Callbacks
            obj.FiltMapJTableH.MousePressedCallback = @obj.mousePressedInFiltMapTable;
            JModelH = handle(obj.FiltMapJTable.getModel, 'CallbackProperties');
            JModelH.TableChangedCallback     = @obj.dataUpdatedInFiltMapTable;       


            w1 = 140; column0 = obj.FiltMapJTable.getColumnModel().getColumn(0);column0.setPreferredWidth(w1);column0.setMinWidth(w1);%column0.setMaxWidth(w1); 
            w2 = 100;column1 = obj.FiltMapJTable.getColumnModel().getColumn(1);column1.setPreferredWidth(w2);column1.setMinWidth(w2);%column1.setMaxWidth(w2); 
%             w3 = 120;column2 = obj.FiltMapJTable.getColumnModel().getColumn(2);column2.setPreferredWidth(w3);column2.setMinWidth(w3);column2.setMaxWidth(w3); 
%             w4 = 20; column3 = obj.FiltMapJTable.getColumnModel().getColumn(3);column3.setPreferredWidth(w4);column3.setMinWidth(w4);column0.setMaxWidth(w4); 

            % Set Cell Renderer
            nonEditCR = javax.swing.DefaultCellEditor(javax.swing.JTextField);
            nonEditCR.setClickCountToStart(intmax); % =never.
            obj.FiltMapJTable.getColumnModel.getColumn(0).setCellEditor(nonEditCR);
      

            
% %             % Set Column width and row colors
% %             cr = AlignColoredFieldCellRenderer;
% %             cr.setFgColor( java.awt.Color.black );
% %             for j = 0:1            
% %                 obj.FiltMapJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% %                 for i = 0:2:double(obj.FiltMapJTable.getRowCount)
% %                     cr.setCellBgColor( i,j,java.awt.Color.white ); 
% %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% %                 end
% %                 
% %             end     
% %             obj.FiltMapJTable.setGridColor(java.awt.Color.black);    
% %             
% %             for j = 0:1            
% %                 obj.FiltMapJTable.getColumnModel.getColumn(j).setCellRenderer(cr);
% %                 for i = 1:2:double(obj.FiltMapJTable.getRowCount)
% %                     cr.setCellBgColor( i,j,java.awt.Color( 246/255 , 243/255 , 237/255 )  ); 
% %                     %cr.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
% %                 end
% %             end  

            obj.FiltMapJTable.setGridColor(java.awt.Color.lightGray);

            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.FiltMapJTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            obj.FiltMapJTable.repaint;
            obj.FiltMapJTable.setVisible(true);
            
        end % updateFiltMapTable
        
    end
    
    %% Methods - Filter Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFilterTable( obj , hModel , hEvent )
            if ~hEvent.isMetaDown
                rowSelected = hModel.getSelectedRow + 1;
                obj.CurrentSelectedFilterRow = rowSelected;
                
                updateFiltParamTable( obj );
                updateFiltMapTable( obj );
            end
        end % mousePressedInFilterTable
        
        function dataUpdatedInFilterTable( obj , hModel , hEvent ) 

            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');

            switch modifiedCol
                case 0 
                    obj.Filters(modifiedRow + 1).Name   = hModel.getValueAt(modifiedRow,modifiedCol);
                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );
                case 1
                    obj.Filters(modifiedRow + 1).DisplayString = hModel.getValueAt(modifiedRow,modifiedCol);
                    updateFiltParamTable( obj );
                    updateFiltMapTable( obj );
            end
            
            
        end % dataUpdatedInFilterTable
    
    end
    
    %% Methods - Button Protected Callbacks
    methods (Access = protected) 
        
        function addFilter( obj , ~ , ~ )
            prompt = {'Name:'};
            dlg_title = 'New Filter';
            num_lines = 1;
            defaultans = {'filter'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,struct('WindowStyle','modal'));
            drawnow();pause(0.5);
            if ~isempty(answer)
                obj.Filters(end+1) = UserInterface.ControlDesign.Filter('Name',answer{1});           
                obj.CurrentSelectedFilterRow = length(obj.Filters);          
                updateFilterTable(obj);
                updateFiltParamTable(obj);
                updateFiltMapTable( obj );
            end
            
        end % addFilter
        
        function removeFilter( obj , ~ , ~ )
            obj.Filters(obj.CurrentSelectedFilterRow) = [];
            obj.CurrentSelectedFilterRow = 1;
            updateFilterTable(obj);
            updateFiltParamTable(obj);
            updateFiltMapTable( obj );
        end % removeFilter
        
        function plotFilter( obj , ~ , ~ )
            try
                obj.Filters(obj.CurrentSelectedFilterRow).plot(); 
            catch Mexc
               switch Mexc.identifier
                   case 'Filter:Plot:MissingValues'
                       notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('The filter you are trying to plot has empty values or empty mapping variables.' ,'error'));
                   otherwise
                       rethrow(Mexc);
               end
            end
        end % plotFilter
        
        function exportFilter( obj , ~ , ~ )
            %selectedFilter = obj.Filters(obj.CurrentSelectedFilterRow);
            
            if ~isempty(obj.Filters)
                exportFilter(obj.Filters);
            end
            
            
        end % exportFilter
        
    end
    
    %% Methods - Filter Parameter Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFiltParamTable( obj , hModel , hEvent )
            if ~hEvent.isMetaDown
                rowSelected = hModel.getSelectedRow + 1;
                obj.RowSelectedFiltParam = rowSelected;
                
                selFilter = obj.CurrentSelectedFilter;
                if isempty(selFilter)
                    selFilter.CurrentPropertySelected = [];
                else
                    selFilter.CurrentPropertySelected = rowSelected; 
                end
                
                name  = selFilter.CurrentPropertySelected;
                value = num2str(selFilter.(selFilter.CurrentPropertySelected));
                
                obj.SelectedParameter = UserInterface.ControlDesign.Parameter('Name',name','String',value);

                notify(obj,'ParameterUpdated',UserInterface.UserInterfaceEventData(obj.SelectedParameter));

            end
        end % mousePressedInFiltParamTable
        
        function dataUpdatedInFiltParamTable( obj , hModel , hEvent ) 

            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            
            
            switch modifiedCol
                case 1 
                    selFilter = obj.CurrentSelectedFilter;
                    valueStr = hModel.getValueAt(modifiedRow,modifiedCol);
                    value = str2double(valueStr);
                    if ~isnan(value)
                        selFilter.(selFilter.CurrentPropertySelected) = value;
                    else
                        selFilter.(selFilter.CurrentPropertySelected) = [];
                    end
            end
            
            
        end % dataUpdatedInFiltParamTable
        
    end
    
    %% Methods - Filter Map Table Protected Callbacks
    methods (Access = protected)         
        
        function mousePressedInFiltMapTable( obj , hModel , hEvent )
            if ~hEvent.isMetaDown
                rowSelected = hModel.getSelectedRow + 1;
                obj.RowSelectedFiltMap = rowSelected;


            end
        end % mousePressedInFiltMapTable
        
        function dataUpdatedInFiltMapTable( obj , hModel , hEvent ) 

            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            
            
            switch modifiedCol
                case 1 
                    selFilter = obj.CurrentSelectedFilter;
                    valueStr = hModel.getValueAt(modifiedRow,modifiedCol);
                    setMappingProperty( selFilter , modifiedRow + 1 , valueStr );

            end
            
            
        end % dataUpdatedInFiltMapTable
        
    end
    
    %% Methods - Resize Ordinary Methods
    methods     
                                       
        function reSize( obj , ~ , ~ ) 
            panelPos = getpixelposition(obj.Container); 
            FiltParamHeight = 155;
            set(obj.FilterContainer,'Units','Pixels','Position',[ 5 , FiltParamHeight + 30 , panelPos(3) - 10 , (panelPos(4) - (FiltParamHeight + 30)) ] );  
            set(obj.ButtonContainer,'Units','Pixels','Position',[ 5 , FiltParamHeight , panelPos(3) - 10 , 30 ] ); 
            set(obj.FilterParameterContainer,'Units','Pixels','Position',[ 5 , 1 , panelPos(3) - 10 , FiltParamHeight ] ); 
%             set(obj.FilterContainer,'Units','Pixels','Position',[ 5 , ((panelPos(4)/2) + 15) , panelPos(3) - 10 , ((panelPos(4)/2) - 15) ] );  
%             set(obj.ButtonContainer,'Units','Pixels','Position',[ 5 , ((panelPos(4)/2) - 15) , panelPos(3) - 10 , 30 ] ); 
%             set(obj.FilterParameterContainer,'Units','Pixels','Position',[ 5 , 1 , panelPos(3) - 10 , ((panelPos(4)/2) - 15)] ); 
        end %reSize
        
        function reSizeFilterC( obj , ~ , ~ )
            panelPos = getpixelposition(obj.FilterContainer); 
            set(obj.FiltTableCont,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4)] ); 
        end %reSizeFilterC
        
        function reSizeButtonC( obj , ~ , ~ )
            %panelPos = getpixelposition(obj.ButtonContainer); 
            set(obj.AddButtonCont,'Units','Pixels','Position',[ 1 , 7 , 70 , 20 ] ); 
            set(obj.RemoveButtonCont,'Units','Pixels','Position',[ 70 , 7 , 70 , 20 ] ); 
            set(obj.PlotButtonCont,'Units','Pixels','Position',[ 140 , 7 , 65 , 20 ] ); 
            set(obj.ExportButtonCont,'Units','Pixels','Position',[ 205 , 7 , 65 , 20 ] ); 
        end %reSizeButtonC
        
        function reSizeFiltParamC( obj , ~ , ~ )
            panelPos = getpixelposition(obj.FilterParameterContainer); 
            %set(obj.FiltParamTabPanel,'Units','Pixels','Position',[ panelPos(1) , panelPos(2) , panelPos(3) - 5 , panelPos(4) ] ); 
            set(obj.FiltParamTabPanel,'Units','Pixels','Position',[ 0 , 0 , panelPos(3) , panelPos(4) ] ); 
%             set(obj.FiltParamTableCont,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4) ]);
%             set(obj.FiltMapTableCont,'Units','Pixels','Position',[ 1 , 1 , panelPos(3) , panelPos(4) ]);
%             set(obj.FiltParamTableCont,'Units','Normal','Position',[ 0,0,1,1 ]);
%             set(obj.FiltMapTableCont,'Units','Normal','Position',[0,0,1,1 ]);
        end %reSizeFiltParamC
                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods  
        
        function updateCurrentSelectedParameter( obj , value )
%             if ~isempty(obj.CurrentSelectedParamter)
                % is passed as a handle to the slider so the value gets
                % updated outside of this function
%                 obj.SelectDisplayParameters(obj.CurrentSelectedRow) = obj.CurrentSelectedParamter;
                updateFiltParamTable(obj);
%             end
        end % updateCurrentSelectedParameter
                                                       
%         function  y = getValue( obj , name )
%             ind = strcmp(name,{obj.AvaliableParameterSelection.Name});
%             if any(ind)
%                 y = obj.AvaliableParameterSelection(ind).Value;
%             else 
%                 y = [];
%             end
%         end % getValue
            
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        
        function update(obj)

            updateSelectedTable( obj );
            notify(obj,'UpdateTable');

            
            if ~isempty(obj.CurrentSelectedRow)

                if ~strcmpi(obj.CurrentSelectedParamter.Name,'none')
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData(['Slider Parameter changed to: ''',obj.CurrentSelectedParamter.Name,'''.'],'info'));
                else
                    notify(obj,'ShowLogMessage',UserInterface.LogMessageEventData('Slider Not Available.','info'));
                end
            end
        end % update
    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Filters object
            cpObj.Filters = copy(obj.Filters);
            
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)
        
        function defaultMinMax( obj )
            
            testNum = str2double(obj.CurrentSelectedParamter.ValueString);
            if isnan(testNum)
                obj.CurrentSelectedParamter.Max = 1;
                obj.CurrentSelectedParamter.Min = 0;     
            else
                value = obj.CurrentSelectedParamter.Value;
                if value == 0  
                    obj.CurrentSelectedParamter.Max = 1;
                    obj.CurrentSelectedParamter.Min = -1;  
                else
                    obj.CurrentSelectedParamter.Max = value + (abs(value) * 0.5);
                    obj.CurrentSelectedParamter.Min = value - (abs(value) * 0.5);   
                end
            end
            
        end % defaultMinMax
        
        function enablePanel( obj , value )
            if value
                obj.AddButtonComp.setEnabled(true);
                obj.RemoveButtonComp.setEnabled(true);
                obj.PlotButtonComp.setEnabled(true);
                editCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
                obj.FiltParamJTable.getColumnModel.getColumn(1).setCellEditor(editCR);
                obj.FiltParamJTable.repaint; 
                obj.FiltMapJTable.getColumnModel.getColumn(1).setCellEditor(editCR);
                obj.FiltMapJTable.repaint;  
                
                comboBox = javax.swing.JComboBox(obj.FilterTypes);
                comboBox.setEditable(false);

                editor = javax.swing.DefaultCellEditor(comboBox);
                obj.FiltJTable.getColumnModel.getColumn(1).setCellEditor(editor); 
                obj.FiltJTable.repaint; 
                 
                    
            else
                obj.AddButtonComp.setEnabled(false);
                obj.RemoveButtonComp.setEnabled(false);
                obj.PlotButtonComp.setEnabled(false);
                nonEditCR = javaObjectEDT('javax.swing.DefaultCellEditor',javax.swing.JTextField);
                nonEditCR.setClickCountToStart(intmax); % =never.
                obj.FiltParamJTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR);
                obj.FiltParamJTable.repaint;
                obj.FiltMapJTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR);
                obj.FiltMapJTable.repaint;  

                obj.FiltJTable.getColumnModel.getColumn(1).setCellEditor(nonEditCR);
                obj.FiltJTable.repaint; 
            end
            
        end % enablePanel
        
    end
    
    %% Methods - Delete
    methods
        function delete_GUI_Only( obj )
            % Java Components 
            obj.AddJButton = [];
            obj.AddButtonComp = [];
            obj.RemoveJButton = [];
            obj.RemoveButtonComp = [];
            obj.PlotJButton = [];
            obj.PlotButtonComp = [];
            obj.FiltScroll = [];
            obj.FiltTableModel = [];
            obj.FiltJTable = [];
            obj.FiltJTableH = [];
            obj.FiltJScroll = [];
            obj.FiltJHScroll = [];
            obj.FiltTableComp = [];
            obj.FiltParamScroll = [];
            obj.FiltParamTableModel = [];
            obj.FiltParamJTable = [];
            obj.FiltParamJTableH = [];
            obj.FiltParamJScroll = [];
            obj.FiltParamJHScroll = [];
            obj.FiltParamTableComp = [];
            obj.FiltMapScroll = [];
            obj.FiltMapTableModel = [];
            obj.FiltMapJTable = [];       
            obj.FiltMapJTableH = [];
            obj.FiltMapJScroll = [];
            obj.FiltMapJHScroll = [];
            obj.FiltMapTableComp = [];

        
            % Javawrappers
            % Check if container is already being deleted
            if ~isempty(obj.AddButtonCont) && ishandle(obj.AddButtonCont) && strcmp(get(obj.AddButtonCont, 'BeingDeleted'), 'off')
                delete(obj.AddButtonCont)
            end
            % Check if container is already being deleted
            if ~isempty(obj.RemoveButtonCont) && ishandle(obj.RemoveButtonCont) && strcmp(get(obj.RemoveButtonCont, 'BeingDeleted'), 'off')
                delete(obj.RemoveButtonCont)
            end
            % Check if container is already being deleted
            if ~isempty(obj.PlotButtonCont) && ishandle(obj.PlotButtonCont) && strcmp(get(obj.PlotButtonCont, 'BeingDeleted'), 'off')
                delete(obj.PlotButtonCont)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltHContainer) && ishandle(obj.FiltHContainer) && strcmp(get(obj.FiltHContainer, 'BeingDeleted'), 'off')
                delete(obj.FiltHContainer)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltTableCont) && ishandle(obj.FiltTableCont) && strcmp(get(obj.FiltTableCont, 'BeingDeleted'), 'off')
                delete(obj.FiltTableCont)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltParamHContainer) && ishandle(obj.FiltParamHContainer) && strcmp(get(obj.FiltParamHContainer, 'BeingDeleted'), 'off')
                delete(obj.FiltParamHContainer)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltParamTableCont) && ishandle(obj.FiltParamTableCont) && strcmp(get(obj.FiltParamTableCont, 'BeingDeleted'), 'off')
                delete(obj.FiltParamTableCont)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltMapHContainer) && ishandle(obj.FiltMapHContainer) && strcmp(get(obj.FiltMapHContainer, 'BeingDeleted'), 'off')
                delete(obj.FiltMapHContainer)
            end
            % Check if container is already being deleted
            if ~isempty(obj.FiltMapTableCont) && ishandle(obj.FiltMapTableCont) && strcmp(get(obj.FiltMapTableCont, 'BeingDeleted'), 'off')
                delete(obj.FiltMapTableCont)
            end


            % User Defined Objects
            try %#ok<*TRYNC>             
                delete(obj.ButtonContainer);
            end


    %          % Matlab Components
            try %#ok<*TRYNC>             
                delete(obj.ButtonContainer);
            end
            try %#ok<*TRYNC>             
                delete(obj.FiltParamTabPanel);
            end
            try %#ok<*TRYNC>             
                delete(obj.ParamTab);
            end
            try %#ok<*TRYNC>             
                delete(obj.MapTab);
            end
            try %#ok<*TRYNC>             
                delete(obj.FilterParameterContainer);
            end
            try %#ok<*TRYNC>             
                delete(obj.Container);
            end
            
            try %#ok<*TRYNC>             
                delete(obj.FilterContainer);
            end
 
        
        
        
        

        
        
        
        
        
        end % delete_GUI_Only
    end
    

    
end

function exportFilter(selectedFilter)
    import FilterDesign.*


    if ~isempty(selectedFilter)

        selFilter    = selectedFilter;
        nFilter      = length(selFilter);

        % Specify filelocation
        [FILENAME, PATHNAME,FILTERINDEX] = uiputfile({'*.m'}, 'Specify *.m file');
        

        if FILTERINDEX
            varNams = cell(1,nFilter);
            for i=1:nFilter
                
                Namei = strtrim(strrep(selFilter(i).Name,' ','_'));
                
                eval([Namei '.Type = ''' selFilter(i).FilterTypesDisplay{selFilter(i).Type} ''';']);
                eval([Namei '.Type = ''' selFilter(i).FilterTypesDisplay{selFilter(i).Type} ''';']);
                
                filtParams = selFilter(i).getFilterParameterValues;
                for j = 1:length(filtParams)
                    
                    eval([Namei '.(filtParams(j).Name) = filtParams(j).Value;']);
                end
                
                varNams{i} = Namei;
                
            end
               matlab.io.saveVariablesToScript(fullfile(PATHNAME,FILENAME),varNams);

        end
    end
end
