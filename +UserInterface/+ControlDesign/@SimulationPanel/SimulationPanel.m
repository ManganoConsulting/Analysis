classdef SimulationPanel < matlab.mixin.Copyable
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        Parent
        ChooseSimPanel
        ChooseSim_pu
        InputTimePanel
        InputTimeVec_eb
        TablePanel
        SimInputTable_tb
        RunSimPanel
        RunSim_pb
        SaveData_cb
        InsertRowSim_pb
        SimDataViewerPanel
        SimDataViewer
    end % Public properties
  
    %% Public properties - Data Storage
    properties       
        SimulationInput = struct('table',{{}},'format',{{{'none'},'char'}});
        SelectedSimIndex = 1;
        InputTimeVec = '[0 1 2 3]';
    end % Public properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        

    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties
    
    %% Methods - Constructor
    methods      
        function obj = SimulationPanel(parent) 
                 
            
            createView(obj,parent)

            
        end % SimulationPanel
    end % Constructor

    %% Methods - View
    methods 

        function createView(obj,parent)
            
            if nargin == 1
                obj.Parent = figure('Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on');
            else
                obj.Parent = parent;
            end
            
            set(obj.Parent,'ResizeFcn',@obj.reSize);
            
          
            position = UserInterface.Utilities.getPosInPixels(obj.Parent);   
            
                obj.ChooseSimPanel = uipanel('Parent',obj.Parent,...
                    'Title','Selected Simulation',...
                    'Units','Normal',...
                    'Position',[0.017857      0.91211      0.33    0.078125]);
                    obj.ChooseSim_pu = uicontrol(...
                        'Parent',obj.ChooseSimPanel,...
                        'Style','popup',...
                        'BackgroundColor',[1 1 1],...
                        'String',{'None'},...
                        'Units','Normal',...
                        'Position',[0 0 1 1],...
                        'Callback',@obj.chooseSim_CB); 


                obj.InputTimePanel = uipanel('Parent',obj.Parent,...
                    'Title','Input Time Vector',...
                    'Units','Normal',...
                    'Position',[0.017857      0.82422      0.33     0.078125]);
                    obj.InputTimeVec_eb= uicontrol(...
                        'Parent',obj.InputTimePanel,...
                        'Style','edit',...
                        'BackgroundColor',[1 1 1],...
                        'String','[ 0 1 2 3 ]',...
                        'Units','Normal',...
                        'Position',[0 0 1 1],...
                        'Callback',@obj.inputTimeVec_CB);


                obj.TablePanel = uipanel('Parent',obj.Parent,...
                    'Title','Simulation Inputs',...
                    'Units','Normal',...
                    'Position',[0.017857     0.078125      0.33      0.73633]);
                    obj.SimInputTable_tb = uitable('Parent',obj.TablePanel,...
                        'ColumnName',{'Input','Signal'},...
                        'RowName',[],...
                        'ColumnEditable', [true,true],...
                        'ColumnFormat',{{'one' 'two'},'char'},...
                        'ColumnWidth',{90,150},...
                        'Data',{},...
                        'Units','Normal',...
                        'Position',[0 0 1 1],...
                        'CellEditCallback', @obj.simulationInput_ce_CB,...
                        'CellSelectionCallback', @obj.simulationInput_cs_CB);



                obj.RunSimPanel = uipanel('Parent',obj.Parent,...
                    'Units','Normal',...
                    'Position',[0.017857    0.0097656      0.33     0.058594]);
                        obj.RunSim_pb= uicontrol(...
                            'Parent',obj.RunSimPanel,...
                            'Style','push',...
                            'String','Run Sim',...
                            'Units','Normal',...
                            'Position',[0.0075758     0.083333      0.28409      0.83333],...
                            'Callback',@obj.runSim_CB);
                        obj.SaveData_cb= uicontrol(...
                            'Parent',obj.RunSimPanel,...
                            'Style','check',...
                            'Units','Normal',...
                            'Position',[0.30303     0.083333      0.39394      0.83333],...
                            'String','Save Data');
                        obj.InsertRowSim_pb = uicontrol(...
                            'Parent',obj.RunSimPanel,...
                            'Style','push',...
                            'String','Insert Row',...
                            'Units','Normal',...
                            'Position',[0.70833     0.083333      0.28409      0.83333],...
                            'Callback',@obj.insertRowSimulationInputTable_CB);          

            obj.SimDataViewerPanel = uipanel('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0.35627    0.0095785      0.63759      0.98084],...
                'Title','ACD Simulation Data Viewer');
            obj.SimDataViewer =Utilities.DataViewer('Parent',obj.SimDataViewerPanel);


            
        end
    end % View Methods 
    
    %% Methods - Property Access
    methods
   
    end % Property access methods
   
    %% Methods - Ordinary
    methods 
        
              
    end % Ordinary Methods
    
    %% Methods - Callbacks
    methods ( Access = protected )
        function simulationInput_ce_CB( obj , hobj , ~ )
            tableData = get(hobj,'Data');
            obj.SimulationInput(obj.SelectedSimIndex).table = tableData;
            updateCDInterface();
        end % simulationInput_ce_CB

        function simulationInput_cs_CB( obj , ~ , ~ )

        end % simulationInput_cs_CB

        function chooseSim_CB( obj , hobj , ~ )
            obj.DefaultSimParamList{obj.SelectedSimIndex} = obj.design.cdDataViewer.GetDefaultSignals();
            obj.SelectedSimIndex = get(hobj,'value');
            if obj.SavedSimData(obj.SelectedSimIndex,1).getLength > 0
                obj.design.cdDataViewer.AddSimulinkData(obj.SavedSimData(obj.SelectedSimIndex,:),...
                                obj.SavedSimRGB{obj.SelectedSimIndex},...
                                obj.DefaultSimParamList{obj.SelectedSimIndex});
            else
                obj.design.cdDataViewer.AddSimulinkData([],...
                                [],...
                                []);
            end

            updateCDInterface();
        end % chooseSim_CB

        function insertRowSimulationInputTable_CB( obj , ~ , ~ )
            %----------------------------------------------------------------------
            % - Callback for "obj.design.insertRow" push button
            %----------------------------------------------------------------------

                newRow = {'none',''};
                obj.SimulationInput(obj.SelectedSimIndex).table = ...
                    [obj.SimulationInput(obj.SelectedSimIndex).table;newRow ];
                updateCDInterface();

            end % insertRow_CB

        function inputTimeVec_CB( obj , hobj , ~ )
            obj.InputTimeVec = get(hobj,'String');
            updateCDInterface();
        end % .design.inputTimeVec_CB_H
        
        function runSim_CB( obj , hobj , ~ )
            %if isempty(cdData.SimObject)
            cdData.design.SavedSimData = Simulink.SimulationData.Dataset;
            %end
            for i = 1:length(cdData.SimObject) % Frequency Response Loop
                if strcmp(cdData.SimObject(i).uitreenode.getValue,'selected') % Only run the selected requirements
                    multiWaitbar( 'CloseAll' );
                    multiWaitbar( 'Running Simulation...', 0 );
                    index = cdData.design.SelectedSimIndex;
                    signals = simulation.getInputStructure(cdData.design.inputTimeVec,cdData.design.SimulationInput(index).table,cdData.SimObject(index).inputNames);

                    %------------------------------------------------------------------
                    % - UPDATE MODEL WORKSPACE WITH GAINS
                    %------------------------------------------------------------------
                    % update the SimulinkDataTable.cdData with SimulinkDataTable.table
                    updateAllParametersTableData();
                    % update frequency response object models with simulink parameters
                    updateModelParameters(cdData.SimObject(i),cdData.design.SimulinkParameterTable.data);
                    % update the SimulinkDataTable.cdData with SimulinkDataTable.table
                    %updateAllParametersTableData();

                    for j = 1:length(cdData.checkedMdls)
                        % get the function handle
                        funH = cdData.SimObject(i).getFunctionHandle;
                        % run the function
                        funH(cdData.checkedMdls(j),cdData.SimObject(i).MdlName);
                        % Run the simulation
                        multiWaitbar( 'Running Simulation...', 0.5 );
                        simOut = simModel(cdData.SimObject(i).MdlName,signals);
                        cdData.design.SavedSimData(i,j) = simOut.get('logsout');
                        multiWaitbar( 'Running Simulation...', 1.0 );
                    end
                    cdData.design.SavedSimRGB{i} = cdData.colRGB;
                    % SAVE DATA
        %                 if get(gui.design.saveData,'Value')
        %                     uisave('LinearData');
        %                     usedMdlVars = Simulink.findVars(cdData.SimObject(i).MdlName,'FindUsedVars',true);
        %                     varList = ['''',usedMdlVars(1).Name,''''];
        %                     for j = 2:length(usedMdlVars)
        %                        varList = [varList,',','''',usedMdlVars(j).Name,''''];
        %                     end
        %                     cdData.SimObject(i).ModelWorkspace.evalin(['Simulink.saveVars(''matt'',',varList,')']);
        %         %             save(filename, variables)
        %         %             save(filename, ..., '-append')
        %                 end
                end
            end
            multiWaitbar( 'Running Simulation...', 'close');
            if (cdData.design.SavedSimData(cdData.design.SelectedSimIndex,1).getLength) > 0
                %ACDSimDataViewFCTool(cdData.design.SavedSimData(cdData.design.SelectedSimIndex,:),cdData.design.SavedSimRGB{cdData.design.SelectedSimIndex} ,gui.design.simDataViewerPanel);
                %gui.ACDSimDataView = ACDSimDataViewFCTool2(cdData.design.SavedSimData(cdData.design.SelectedSimIndex,:),cdData.design.SavedSimRGB{cdData.design.SelectedSimIndex} ,cdData.design.defaultSimParamList{cdData.design.SelectedSimIndex},gui.design.simDataViewerPanel);
    %             gui.design.cdDataViewer.AddSimulinkData(cdData.design.SavedSimData(cdData.design.SelectedSimIndex,:),...
    %                                     cdData.design.SavedSimRGB{cdData.design.SelectedSimIndex},...
    %                                     cdData.design.defaultSimParamList{cdData.design.SelectedSimIndex});
                gui.design.dataViewer.AddSimulinkData(cdData.design.SavedSimData(cdData.design.SelectedSimIndex,:),...
                                        cdData.design.SavedSimRGB{cdData.design.SelectedSimIndex},...
                                        cdData.design.defaultSimParamList{cdData.design.SelectedSimIndex});
            end
            close_system({cdData.SimObject.MdlName},0);
        end % runSim_CB
    end
    
    %% Methods - Protected
    methods (Access = protected)       
        function update(obj)

        end % update
        
        function reSize( obj , ~ , ~ )
            
           posPix = getpixelposition(obj.Parent);

            
        end % reSize
        
        function cpObj = copyElement(obj)
            % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Panel object
            %cpObj.Panel = copy(obj.Panel);
        end
        
    end
    
end
