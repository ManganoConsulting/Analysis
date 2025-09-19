classdef LinearModel < matlab.mixin.Copyable
    
      %% Public Observable properties
    properties  (  SetObservable ) 

        Title                       % title 
    end % Public properties  
       
    
    %% Public properties - View Graphics Handles
    properties (Transient = true)
        Parent
        MainPanel
        LabelText
        LabelEditBox
        NumOfTrimText
        NumOfTrimComboBox
        
        TablePanel
        Tab1
        Tab2

        
%         InputsText1
        Input1Table
        AddInputsPushButton1
        RemoveInputsPushButton1
        
%         OutputsText1
        Output1Table
        AddOutputsPushButton1
        RemoveOutputsPushButton1
        
%         StatesText1
        State1Table
        AddStatesPushButton1
        RemoveStatesPushButton1
        
%         AlgInputsText
        AlgInputsTable
        AddStateDerivsPushButton1
        RemoveStateDerivsPushButton1
        
%         AlgOutputsText
        AlgOutputsTable

        
        ModelText
        ModelEditBox
        ModelPushButton
    end % Public properties
  
    %% Public properties - View Data Storage
    properties
        LinMdlLabelString = char.empty
        NumOfTrimSelectionString = {'1','2'}
        NumOfTrimSelectionValue  = 1
        
        Input1TableData
        Output1TableData
        State1TableData
        StateDerivs1TableData
        
        
        ModelName
        
        StartDirectory = pwd %mfilename('fullpath')
        
        ViewInputs = UserInterface.ObjectEditor.LinMdlRow.empty
        ViewOutputs = UserInterface.ObjectEditor.LinMdlRow.empty
        ViewStates = UserInterface.ObjectEditor.LinMdlRow.empty
        ViewAlgebraicInputs = UserInterface.ObjectEditor.LinMdlRow.empty
        ViewAlgebraicOutputs = UserInterface.ObjectEditor.LinMdlRow.empty
        
        SelectedLinMdlDef
        

    end % Public properties
    
    %% Public properties - Data Storage
    properties  
        Label
        States
        Inputs
        Outputs  
        AlgebraicInput
        AlgebraicOutput   
        SimulinkModelName
        
        StatePerturbSizes
        InputPerturbSizes
        AlgebraicInputPerturbSizes
        
        StatePerturbTypes
        InputPerturbTypes
        AlgebraicInputPerturbTypes
        
        InputConstraintsArray
        InputConstraintsInfo
        
        FileName
    end % Public properties
        
    %% Read-only properties
    properties %( GetAccess = public, SetAccess = private )
        A
        B
        C
        D
  
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true , GetAccess = public, SetAccess = private )        
        Node
    end % Hidden properties

    %% Dependant properties
    properties (Dependent = true, SetAccess = private)
        
    end % Dependant properties

    % Constant properties
    properties (Hidden = true, Constant) 

    end % Constant properties 
    
    %% Methods - Constructor
    methods      
        function obj = LinearModel(varargin)
            switch nargin
                case 0
                case 1
                    if exist(varargin{:},'file')
                        import Utilities.*
                        fid = fopen(varargin{:},'r');
                        tline = {};
                        i = 1;
                        while ~feof(fid)
                            tline{i} = fgetl(fid);
                            i = i + 1;
                        end 
                        % tline = tline(~cellfun(@isempty,tline));
                        tline = deblank(tline);

                        % Get the data coresponding to the title
                        dataID = tline(find(strcmpi('ID',tline)) + 1);
                        dataType = tline(find(strcmpi('Type',tline)) + 1);
                        dataSTATES = tline(find(strcmp('STATES',tline)) + 1);
                        dataINPUTS = tline(find(strcmp('INPUTS',tline)) + 1);
                        dataOUTPUTS = tline(find(strcmp('OUTPUTS',tline)) + 1);
                        dataALGEBRAICINPUT= tline(find(strcmp('ALGEBRAIC INPUT',tline)) + 1);
                        dataALGEBRAICOUTPUT = tline(find(strcmp('ALGEBRAIC OUTPUT',tline)) + 1);

                        % Split the data into cell arrays
                        dataID = cellfun(@splitCell,dataID,'UniformOutput',0);
                        dataType = cellfun(@splitCell,dataType,'UniformOutput',0);
                        dataSTATES = cellfun(@splitCell,dataSTATES,'UniformOutput',0);
                        dataINPUTS = cellfun(@splitCell,dataINPUTS,'UniformOutput',0);
                        dataOUTPUTS = cellfun(@splitCell,dataOUTPUTS,'UniformOutput',0);
                        dataALGEBRAICINPUT = cellfun(@splitCell,dataALGEBRAICINPUT,'UniformOutput',0);
                        dataALGEBRAICOUTPUT =cellfun(@splitCell,dataALGEBRAICOUTPUT,'UniformOutput',0);

                        fclose(fid); 


                        obj(length(dataType)) = lacm.LinearModel;
                        for i = 1:length(dataType)  
                            obj(i) = lacm.LinearModel('States',dataSTATES{i},...
                                                        'Inputs',dataINPUTS{i},...
                                                        'Outputs',dataOUTPUTS{i},...
                                                        'AlgebraicInput',dataALGEBRAICINPUT{i},...
                                                        'AlgebraicOutput',dataALGEBRAICOUTPUT{i},...
                                                        'Label',dataType{i}{:});      
                            
                            
                        end
                    end
                otherwise
                    p = inputParser;
                    addParameter(p,'States',{},@iscell);
                    addParameter(p,'Inputs',{},@iscell);
                    addParameter(p,'Outputs',{},@iscell);
                    addParameter(p,'AlgebraicInput',{},@iscell);
                    addParameter(p,'AlgebraicOutput',{},@iscell);
                    addParameter(p,'Label','');
                    addParameter(p,'A',[]);
                    addParameter(p,'B',[]);
                    addParameter(p,'C',[]);
                    addParameter(p,'D',[]);

                    p.KeepUnmatched = true;
                    parse(p,varargin{:});
                    options = p.Results;
                    
                    obj.States = options.States;
                    obj.Inputs = options.Inputs;
                    obj.Outputs = options.Outputs;
                    obj.AlgebraicInput = options.AlgebraicInput;
                    obj.AlgebraicOutput = options.AlgebraicOutput;
                    obj.Label = options.Label;
                    obj.A = options.A;
                    obj.B = options.B;
                    obj.C = options.C;
                    obj.D = options.D;

            end            
        end % linearmodel
    end % Constructor

    %% Methods - Property Access
    methods

    end % Property access methods
   
    %% Methods - Ordinary
    methods 
   
        function run(obj,simsys,state_names,inport_names,outport_names,X0_trim,U0_trim,Y0_trim,CStateIDs)
            import lacm.Utilities.*
            % Get data from definition
            selX  = obj.States;
            selU  = obj.Inputs;
            selY  = obj.Outputs;

            selAU = obj.AlgebraicInput;
            selAY = obj.AlgebraicOutput;
            
            xPert = cell2mat(obj.StatePerturbSizes');
            uPert = cell2mat(obj.InputPerturbSizes');
            auPert = cell2mat(obj.AlgebraicInputPerturbSizes');
            
            xPertType = cell2mat(obj.StatePerturbTypes');
            uPertType = cell2mat(obj.InputPerturbTypes');
            auPertType= cell2mat(obj.AlgebraicInputPerturbTypes');
            
            ConstraintsArray = obj.InputConstraintsArray;


            % Get state indices for Jacobian
            no_X = zeros(1,length(selX));
            for i = 1:length(selX)
                selXi = selX{i};
                no_X(i)   = find(strcmp(selXi,state_names));
            end

            % Initialize A
            A = zeros(length(no_X),length(no_X));

            % Get input indices for Jacobian
            no_U = zeros(1,length(selU));
            for i = 1:length(selU)
                selUi = selU{i};
                no_U(i)   = find(strcmp(selUi,inport_names));
            end

            % Initialize B
            B = zeros(length(no_X),length(no_U));

            % Initialize C, D
            C = zeros(length(selY),length(no_X));
            D = zeros(length(selY),length(no_U));

            % Get output indices for Jacobian
            j=0;
            no_Cy = [];
            no_Y  = [];
            for i = 1:length(selY)
                selYi = selY{i};

                % Check if output is a state
                no_Cx = find(strcmp(selYi,selX));
                if ~isempty(no_Cx)
                    C(i,no_Cx) = 1;
                else
                    j = j+1;
                    no_Cy(j)  = i;
                    no_Y(j)   = find(strcmp(selYi,outport_names));
                end
            end

            % Get algebraic input indices for Jacobian
            no_AU = zeros(1,length(selAU));
            for i = 1:length(selAU)
                selAUi = selAU{i};
                no_AU(i)   = find(strcmp(selAUi,inport_names));
            end

            % Get algebraic output indices for Jacobian
            no_AY = zeros(1,length(selAY));
            for i = 1:length(selAY)
                selAYi = selAY{i};
                no_AY(i)   = find(strcmp(selAYi,outport_names));
            end


            
            % # states
            nStates = length(X0_trim);
            
            % Continuous States Only
            nCStates = length(find(CStateIDs));
            
            n_x = length(no_X);
            n_u = length(no_U);
            n_y = length(no_Y);
            n_ay= length(no_AY);
            n_au= length(no_AU);
            
            i_x_u= [no_X,[no_U,no_AU]+nStates]';            
            i_d_y= [no_X,[no_Y,no_AY]+nCStates]';
            
            
            % Call linearization routine
%             if ~exist('default_perturbsize', 'var')
% %                 [jaco,del_x_u] = jj_lin(simsys,[X0_trim;U0_trim],length(X0_trim),[1:length([X0_trim;U0_trim])]',...
% %                     [1:length([X0_trim;Y0_trim])]');
%                 
%                 [jaco,del_x_u] = jj_lin(simsys,[X0_trim;U0_trim],nStates,i_x_u,i_d_y);
% 
% 
%             elseif default_perturbsize == 1;
%                 %X_U = [X0_trim;U0_trim];
%                 delta_X_U = 1e-10*(1 + 1e-3*abs(X_U));
% %                 [jaco, del_x_u] = jj_lin(simsys,X_U,length(X0_trim),[1:length([X0_trim;U0_trim])]',...
% %                     [1:length([X0_trim;Y0_trim])]',delta_X_U);
%                 
%                 [jaco,del_x_u] = jj_lin(simsys,[X0_trim;U0_trim],nStates,i_x_u,i_d_y,delta_X_U);
% 
%             elseif default_perturbsize == 0;
%                 [delta_X_U] = assign_perturb(perturb_var_names, perturb_val, state_names, inport_names, X0_trim, U0_trim);
% 
% %                 X_U = [X0_trim;U0_trim];
% %                 [jaco, del_x_u] = jj_lin(simsys,X_U,length(X0_trim),[1:length([X0_trim;U0_trim])]',...
% %                     [1:length([X0_trim;Y0_trim])]',del_X_U);
%                 
%                 [jaco,del_x_u] = jj_lin(simsys,[X0_trim;U0_trim],nStates,i_x_u,i_d_y,delta_X_U);
%             end

%             delta_X = 

            delta_X   = xPert .* (1 + abs(X0_trim(no_X)));
            delta_U   = uPert .* (1 + abs(U0_trim(no_U)));
            delta_AU  = auPert .* (1 + abs(U0_trim(no_AU)));
            
            delta_Xf = zeros(length(X0_trim),1);
            delta_Xf(no_X) = delta_X;
            
            delta_Uf = zeros(length(U0_trim),1);
            delta_Uf(no_U) = delta_U;
            delta_Uf(no_AU)= delta_AU;
            
            delta_X_Type = zeros(length(X0_trim),1);
            delta_X_Type(no_X) = xPertType;
            
            delta_U_Type = zeros(length(U0_trim),1);
            delta_U_Type(no_U) = uPertType;
            delta_U_Type(no_AU) = auPertType;
            
            
            delta_X_U = [delta_Xf;delta_Uf];
            delta_X_U_Type = [delta_X_Type;delta_U_Type];


            [jaco,del_x_u] = jj_lin(simsys,[X0_trim;U0_trim],nStates,i_x_u,i_d_y,delta_X_U,delta_X_U_Type,ConstraintsArray);



            nstates=length(X0_trim);

            % Build A matrix
%             A              = jaco(no_X,no_X);
%             B              = jaco(no_X,no_U+nstates);
%             C(no_Cy,:)     = jaco(nstates+no_Y,no_X);
%             D(no_Cy,:)     = jaco(nstates+no_Y,no_U+nstates);
            
            A               = jaco(1:n_x,1:n_x);
            B               = jaco(1:n_x,n_x+1:(n_u+n_x));
            C (no_Cy,:)     = jaco(n_x+1:(n_y+n_x),1:n_x);
            D (no_Cy,:)     = jaco(n_x+1:(n_y+n_x),n_x+1:(n_u+n_x));
            

            % Append with Algebraic variables
%             BA = jaco(no_X,no_AU+nstates);
%             CA = jaco(nstates+no_AY,no_X);
%             DAY1 = jaco(nstates+no_AY,no_U+nstates);
%             DAY2 = jaco(nstates+no_Y,no_AU+nstates);
%             DAY3 = jaco(nstates+no_AY,no_AU+nstates);
            
            if ~isempty(no_AU) && ~isempty(no_AY)
                BA = jaco(1:n_x,(n_u+n_x)+1:end);
                CA = jaco((n_y+n_x)+1:end,1:n_x);
                DAY1 = jaco((n_y+n_x)+1:end,n_x+1:(n_u+n_x));
                DAY2 = jaco(n_x+1:(n_y+n_x),(n_u+n_x)+1:end);
                DAY3 = jaco((n_y+n_x)+1:end,(n_u+n_x)+1:end);
                
            else
                BA = [];
                CA = [];
                DAY1=[];
                DAY2=[];
                DAY3=[];   
            end
            
            D    = [D;DAY1];
            DA   = [DAY2;DAY3];


            % xdot = A1*x + B1*u + B2*y
            % y    = C1*x + D1*u + D2*y
            %
            % y    = (I-D2)^-1 * C1*x + (I-D2)^-1 * D1*u
            % xdot = (A1+B2*(I-D2)^-1*C1)*x +(B1+B2*(I-D2)^-1*D1)*u
            %
            % Define new A1,B1,B2,C1,D1,D2 matrices
            
            if ~isempty(BA) && ~isempty(DA)
                A1 = A;
                B1 = B;
                B2 = [zeros(size(A,1),size(C,1)),BA];
                C1 = [C;CA];
                D1 = D;
                %D2 = [zeros(size(C1,1),size(C,1)),[zeros(size(C,2),size(DA,2));DA]];
                D2 = [zeros(size(C1,1),size(C,1)),[zeros(size(C,1)-n_y,1);DA]];

                % Define final state matrices
                invI_D2 = inv(eye(size(D2,1))-D2);

                Ahat = (A1+B2*invI_D2*C1);
                Bhat = (B1+B2*invI_D2*D1);
                Chat = (invI_D2)*C1;
                Dhat = (invI_D2)*D1;
            else
                Ahat = A;
                Bhat = B;
                Chat = C;
                Dhat = D;
            end

            % Delete the algebraic variable from output vector
            Chat = Chat(1:size(C,1),:);
            Dhat = Dhat(1:size(C,1),:);


            % Define linear Model
            obj.A =Ahat;
            obj.B =Bhat;
            obj.C =Chat;
            obj.D =Dhat;   
        end % run
        
        function outObj = get(obj, label)
            switch nargin
                case 1
                    outObj = lacm.LinearModel.empty;
                case 2
                    labelLog = strcmpi(label,{obj.Label});
                    outObj= obj(labelLog);   
            end
        end % get
        
    end % Ordinary Methods

    methods %% Property Access, Nathan added
        function y = get.A(obj)
            y = double(obj.A);
        end

        function y = get.B(obj)
            y = double(obj.B);
        end

        function y = get.C(obj)
            y = double(obj.C);
        end

        function y = get.D(obj)
            y = double(obj.D);
        end
    end
    
    %% Methods - Old View
    methods 
        
        function node = treeNode( obj , tree ,userdata )
            obj.Node  = uitreenode(...
                'v0','unselected', obj.Label, [], 0);
            obj.Node.setIcon(obj.JavaImage_unchecked); 
            obj.Node.setUserObject('JavaImage_unchecked');
            obj.Node.UserData = userdata;
                statesNode  = uitreenode(...
                                'v0','', 'States', [], 0);
                tree.insertNodeInto(...
                    statesNode,...
                    obj.Node,...
                    obj.Node.getChildCount());             
                for i = 1:length(obj.States)
                    newNode  = uitreenode(...
                                    'v0','', obj.States{i}, [], 0); 
                    tree.insertNodeInto(...
                        newNode,...
                        statesNode,...
                        statesNode.getChildCount()); 
                end
                inputsNode  = uitreenode(...
                                'v0','', 'Inputs', [], 0);
                tree.insertNodeInto(...
                    inputsNode,...
                    obj.Node,...
                    obj.Node.getChildCount());          
                for i = 1:length(obj.Inputs)
                    newNode  = uitreenode(...
                                    'v0','', obj.Inputs{i}, [], 0);
                    tree.insertNodeInto(...
                        newNode,...
                        inputsNode,...
                        inputsNode.getChildCount());
                end
                outputsnode  = uitreenode(...
                                'v0','', 'Outputs', [], 0);
                tree.insertNodeInto(...
                    outputsnode,...
                    obj.Node,...
                    obj.Node.getChildCount());           
                for i = 1:length(obj.Outputs)
                    newNode  = uitreenode(...
                                    'v0','', obj.Outputs{i}, [], 0);
                    tree.insertNodeInto(...
                        newNode,...
                        outputsnode,...
                        outputsnode.getChildCount());
                end
                algInNode  = uitreenode(...
                                'v0','', 'AlgebraicInput', [], 0);
                tree.insertNodeInto(...
                    algInNode,...
                    obj.Node,...
                    obj.Node.getChildCount());           
                for i = 1:length(obj.AlgebraicInput)
                    newNode  = uitreenode(...
                                    'v0','', obj.AlgebraicInput{i}, [], 0);
                    tree.insertNodeInto(...
                        newNode,...
                        algInNode,...
                        algInNode.getChildCount());
                end
                algOutNode  = uitreenode(...
                                'v0','', 'AlgebraicOutput', [], 0);
                tree.insertNodeInto(...
                    algOutNode,...
                    obj.Node,...
                    obj.Node.getChildCount());       
                for i = 1:length(obj.AlgebraicOutput)
                    newNode  = uitreenode(...
                                    'v0','', obj.AlgebraicOutput{i}, [], 0);
                    tree.insertNodeInto(...
                        newNode,...
                        algOutNode,...
                        algOutNode.getChildCount());
                end 
            node = obj.Node;
        end % treeNode
        
    end % View Methods
    
    %% Methods - View
    methods
        
        function createView( obj , parent )  
%             createView@UserInterface.ObjectEditor.Editor( obj , parent );
            obj.Parent = parent;
%             end
            % Main Container
            obj.MainPanel = uicontainer('Parent',obj.Parent,...
                'Units','Normal',...
                'Position',[0,0,1,1]);
            
            fig = ancestor(parent,'figure','toplevel') ;
            fig.MenuBar = 'None';
            fig.NumberTitle = 'off';
            position = fig.Position;
            fig.Position = [ position(1) , position(2) - 200 , 550 , 643 ];
            
            if ~( strcmp(version('-release'),'2015b') || strcmp(version('-release'),'2016a')  || strcmp(version('-release'),'2023a')  )
                jFig = get(handle(fig), 'JavaFrame');
                pause(0.1);
                jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension( 555 , 675 ));     
            end
            obj.ModelText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Simulink Model:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.ModelEditBox = uicontrol('Parent',obj.MainPanel,...
                'Style','edit',...
                'FontSize',10,...
                'String',obj.ModelName,...
                'ForegroundColor',[0 0 0],...
                'Enable','Inactive',...
                'HorizontalAlignment','Left');  
            obj.ModelPushButton = uicontrol('Parent',obj.MainPanel,...
                'Style','push',...
                'FontSize',10,...
                'String','Browse',...
                'ForegroundColor',[0 0 0],...
                'Callback',@obj.browseModel);  
            
            obj.LabelText = uicontrol('Parent',obj.MainPanel,...
                'Style','text',...
                'FontSize',10,...
                'String','Linear Model Label:',...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left');
            obj.LabelEditBox = uicontrol('Parent',obj.MainPanel,...
                'Style','edit',...
                'FontSize',10,...
                'String',obj.LinMdlLabelString,...
                'ForegroundColor',[0 0 0],...
                'HorizontalAlignment','Left',...
                'Callback',@obj.labelTextEditBox_CB);
                        
            
            obj.TablePanel = uipanel('Parent',obj.MainPanel);

            createPanel( obj , obj.TablePanel ); 
                   
            reSize( obj );
            
            if ~isempty(obj.ModelName)
                updateMdlConditions( obj );
            end
            
            update(obj);
            updateTable( obj );
        end % createView
        
        function createPanel( obj , parent )
            
            
            
            
%             obj.InputsText1 = uicontrol('Parent',parent,...
%                 'Style','text',...
%                 'FontSize',10,...
%                 'String','Inputs',...
%                 'ForegroundColor',[0 0 0],...
%                 'HorizontalAlignment','Left'); 
            
            obj.Input1Table = uitable(parent,...
                'ColumnName',{'Input Names','Order','PerturbSize','Constraint'},...
                'RowName',[],...
                'ColumnEditable', [ false  , true, true, true],...
                'ColumnFormat',{'Char','numeric','Char','Char'},...
                'ColumnWidth',{120,60,65,72},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.inputTable1_ce_CB,...
                'CellSelectionCallback', @obj.inputTable1_cs_CB);
            
            TooltipStringInput = sprintf('Order: Positive integer\nPerturbation Size: +value (positive delta), -value (negative delta), value (both sides delta)');
            obj.Input1Table.TooltipString = TooltipStringInput;

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.OutputsText1 = uicontrol('Parent',parent,...
%                 'Style','text',...
%                 'FontSize',10,...
%                 'String','Outputs',...
%                 'ForegroundColor',[0 0 0],...
%                 'HorizontalAlignment','Left'); 
            
            obj.Output1Table = uitable(parent,...
                'ColumnName',{'Output Names','Order'},...
                'RowName',[],...
                'ColumnEditable', [ false  , true],...
                'ColumnFormat',{'Char','Numeric'},...
                'ColumnWidth',{120,60},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.outputTable1_ce_CB,...
                'CellSelectionCallback', @obj.outputTable1_cs_CB); 
            
            TooltipStringOutput = sprintf('Order: Positive integer');
            obj.Output1Table.TooltipString = TooltipStringOutput;
% 
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.StatesText1 = uicontrol('Parent',parent,...
%                 'Style','text',...
%                 'FontSize',10,...
%                 'String','States',...
%                 'ForegroundColor',[0 0 0],...
%                 'HorizontalAlignment','Left'); 
            
            obj.State1Table = uitable(parent,...
                'ColumnName',{'State Names','Order','PerturbSize'},...
                'RowName',[],...
                'ColumnEditable', [ false  , true, true],...
                'ColumnFormat',{'Char','numeric','Char'},...
                'ColumnWidth',{120,60,72},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.stateTable1_ce_CB,...
                'CellSelectionCallback', @obj.stateTable1_cs_CB);    
            
            obj.State1Table.TooltipString = TooltipStringInput;
% 
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.AlgInputsText = uicontrol('Parent',parent,...
%                 'Style','text',...
%                 'FontSize',10,...
%                 'String','Algebraic Inputs',...
%                 'ForegroundColor',[0 0 0],...
%                 'HorizontalAlignment','Left'); 
            
            obj.AlgInputsTable = uitable(parent,...
                'ColumnName',{'Algebraic Input','Order','PerturbSize'},...
                'RowName',[],...
                'ColumnEditable', [ false  , true, true],...
                'ColumnFormat',{'Char','numeric','Char'},...
                'ColumnWidth',{120,60,72},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.algInputsTable1_ce_CB,...
                'CellSelectionCallback', @obj.algInputsTable1_cs_CB); 
            
            obj.AlgInputsTable.TooltipString = TooltipStringInput;
% 
%             
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.AlgOutputsText = uicontrol('Parent',parent,...
%                 'Style','text',...
%                 'FontSize',10,...
%                 'String','Algebraic Outputs',...
%                 'ForegroundColor',[0 0 0],...
%                 'HorizontalAlignment','Left'); 
            
            obj.AlgOutputsTable = uitable(parent,...
                'ColumnName',{'Algebraic Output','Order'},...
                'RowName',[],...
                'ColumnEditable', [ false  , true],...
                'ColumnFormat',{'Char','Numeric'},...
                'ColumnWidth',{120,60},...
                'Data',[],...
                'Units','Normal',...
                'Position',[ 0 , 0 , 1 , 1 ],...
                'CellEditCallback', @obj.algOutputsTable1_ce_CB,...
                'CellSelectionCallback', @obj.algOutputsTable1_cs_CB); 
            
            obj.AlgOutputsTable.TooltipString = TooltipStringOutput;

        end % createPanel
        
        
    end
   
    %% Methods - View Ordinary
    methods 
        
        function loadExisting( obj , loadedLinMdlObj , filename )
            
            if ~isa(loadedLinMdlObj,'lacm.LinearModel')
                error('Selected File must be of class "lacm.LinearModel"');
            end  

            obj.LinMdlLabelString = loadedLinMdlObj.Label;
            obj.SelectedLinMdlDef = loadedLinMdlObj;
            obj.ModelName = loadedLinMdlObj.SimulinkModelName; 
            createDefault( obj , loadedLinMdlObj );           
        
            obj.FileName = filename;
%             obj.Saved = true;
            update( obj );
        end % loadExisting        
        
        function linMdlObj = createLinearModelObj( obj )
            
            linMdlObj = lacm.LinearModel(...
                        'States',obj.ViewStates.getSelectedNames(),...
                        'Inputs',obj.ViewInputs.getSelectedNames(),...
                        'Outputs',obj.ViewOutputs.getSelectedNames(),...
                        'AlgebraicInput',obj.ViewAlgebraicInputs.getSelectedNames(),...
                        'AlgebraicOutput',obj.ViewAlgebraicOutputs.getSelectedNames(),...
                    	'Label',obj.LinMdlLabelString);
           linMdlObj.SimulinkModelName = obj.ModelName;

        end
        
        function updateModelName( obj )
            update(obj);
            updateTable( obj );
        end % updateModelName
              
    end % Ordinary Methods
    
    
    %% Methods - View Callbacks
    methods (Access = protected) 
     
        function labelTextEditBox_CB( obj , hobj , ~ )
%             obj.LinMdlLabelString       = hobj.String;
            obj.Label       = hobj.String;
%             obj.Saved = false;
            update( obj )
        end % labelTextEditBox_CB
        
        function browseModel( obj , ~ , ~ )
            [filename, pathname] = uigetfile({'*.mdl;*.slx','Simulink Models:'},'Select Model File:',obj.StartDirectory);
            drawnow();pause(0.5);
            % load and assign objects
            if ~isequal(filename,0)
                obj.StartDirectory = pathname;
                [ ~ , mdl ] = fileparts(filename);
                obj.ModelName = mdl;
                createDefault( obj );

%                 obj.Saved = false;  
                update(obj)
            
            end
        end % browseModel
        
        function tabPanel_CB( obj , ~ , ~ )
            
        end % tabPanel_CB
        
        function addRow( obj , ~ , ~ , dataName )
            switch dataName
                case {'Input1TableData'}
                    obj.Input1TableData = [obj.Input1TableData; { [] , [] , false } ];
                case {'Output1TableData'}
                    obj.Output1TableData = [obj.Output1TableData; { [] , [] , false } ];
                case {'State1TableData'}
                    obj.State1TableData = [obj.State1TableData; { [] , [] , false } ];         
                case {'StateDerivs1TableData'}
                    obj.StateDerivs1TableData = [obj.StateDerivs1TableData; { [] , [] , false } ];    
            end
            
            update( obj );
        end % addRow
        
        function removeRow( obj , ~ , ~ )
            
        end % removeRow
        
        function inputTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    
                    try
                        
                        Order = str2double(eventData.EditData);
                        
                        if isscalar(Order) && rem(Order,1)==0 && Order > 0
                            
                            obj.ViewInputs(eventData.Indices(1)).Order = Order;
                            
                        else
                            
                            obj.ViewInputs(eventData.Indices(1)).Order = [];
                            
                        end
                        
                    catch
                        
                        obj.ViewInputs(eventData.Indices(1)).Order = [];
                        
                    end
                    
                case 3
                    
                    try 
                        eval(eventData.EditData);
                        
                        obj.ViewInputs(eventData.Indices(1)).PerturbSizeStr = eventData.EditData;
                        
                        obj.ViewInputs(eventData.Indices(1)).PerturbType = 0;
                        if contains(eventData.EditData,'+')
                            obj.ViewInputs(eventData.Indices(1)).PerturbType = 1;
                            obj.ViewInputs(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        elseif contains(eventData.EditData,'-')
                            obj.ViewInputs(eventData.Indices(1)).PerturbType = -1;
                            obj.ViewInputs(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        end
                        
                    catch
                        obj.ViewInputs(eventData.Indices(1)).PerturbSizeStr = '1e-6';
                        obj.ViewInputs(eventData.Indices(1)).PerturbSize = 1e-6;
                        obj.ViewInputs(eventData.Indices(1)).PerturbType = 1;
                                          
                    end
                    

                case 4
                    obj.ViewInputs(eventData.Indices(1)).ConstraintStr = eventData.EditData;
                    
            end
            %             obj.Saved = false;
            obj.update();
        end % inputTable1_ce_CB
        
        function inputTable1_cs_CB( obj , ~ , ~ )
            
            
        end % inputTable1_cs_CB
        
        function outputTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    try
                        
                        Order = str2double(eventData.EditData);
                        
                        if isscalar(Order) && rem(Order,1)==0 && Order > 0
                            
                            obj.ViewOutputs(eventData.Indices(1)).Order = Order;
                            
                        else
                            
                            obj.ViewOutputs(eventData.Indices(1)).Order = [];
                            
                        end
                        
                    catch
                        
                        obj.ViewOutputs(eventData.Indices(1)).Order = [];
                        
                    end
            end
            %             obj.Saved = false;
            obj.update();
        end % outputTable1_ce_CB
        
        function outputTable1_cs_CB( obj , ~ , ~ )
            
            
        end % outputTable1_cs_CB
        
        function stateTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    try
                        
                        Order = str2double(eventData.EditData);
                        
                        if isscalar(Order) && rem(Order,1)==0 && Order > 0
                            
                            obj.ViewStates(eventData.Indices(1)).Order = Order;
                            
                        else
                            
                            obj.ViewStates(eventData.Indices(1)).Order = [];
                            
                        end
                        
                    catch
                        
                        obj.ViewStates(eventData.Indices(1)).Order = [];
                        
                    end
                case 3
                    try
                        eval(eventData.EditData);
                        
                        obj.ViewStates(eventData.Indices(1)).PerturbSizeStr = eventData.EditData;
                        
                        obj.ViewStates(eventData.Indices(1)).PerturbType = 0;
                        if contains(eventData.EditData,'+')
                            obj.ViewStates(eventData.Indices(1)).PerturbType = 1;
                            obj.ViewStates(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        elseif contains(eventData.EditData,'-')
                            obj.ViewStates(eventData.Indices(1)).PerturbType = -1;
                            obj.ViewStates(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        end
                        
                    catch
                        obj.ViewStates(eventData.Indices(1)).PerturbSizeStr = '1e-6';
                        obj.ViewStates(eventData.Indices(1)).PerturbSize = 1e-6;
                        obj.ViewStates(eventData.Indices(1)).PerturbType = 1;
                        
                    end
            end
            %             obj.Saved = false;
            obj.update();
        end % stateTable1_ce_CB
        
        function stateTable1_cs_CB( obj , ~ , ~ )
            
            
        end % stateTable1_cs_CB
        
        function algInputsTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    try
                        
                        Order = str2double(eventData.EditData);
                        
                        if isscalar(Order) && rem(Order,1)==0 && Order > 0
                            
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).Order = Order;
                            
                        else
                            
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).Order = [];
                            
                        end
                        
                    catch
                        
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).Order = [];
                        
                    end
                case 3
                    try
                        eval(eventData.EditData);
                        
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbSizeStr = eventData.EditData;
                        
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbType = 0;
                        if contains(eventData.EditData,'+')
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbType = 1;
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        elseif contains(eventData.EditData,'-')
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbType = -1;
                            obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbSize = abs(str2double(eventData.EditData));
                        end
                        
                    catch
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbSizeStr = '1e-6';
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbSize = 1e-6;
                        obj.ViewAlgebraicInputs(eventData.Indices(1)).PerturbType = 1;
                        
                    end
                    
            end
            %             obj.Saved = false;
            obj.update();
        end % algInputsTable1_ce_CB
        
        function algInputsTable1_cs_CB( obj , ~ , ~ )
            
            
        end % algInputsTable1_cs_CB
        
        function algOutputsTable1_ce_CB(obj , ~ , eventData )
            switch eventData.Indices(2)
                case 2
                    
                    try
                        
                        Order = str2double(eventData.EditData);
                        
                        if isscalar(Order) && rem(Order,1)==0 && Order > 0
                            
                            obj.ViewAlgebraicOutputs(eventData.Indices(1)).Order = Order;
                            
                        else
                            
                            obj.ViewAlgebraicOutputs(eventData.Indices(1)).Order = [];
                            
                        end
                        
                    catch
                        
                        obj.ViewAlgebraicOutputs(eventData.Indices(1)).Order = [];
                        
                    end
            end
%             obj.Saved = false;
            obj.update();
        end % algOutputsTable1_ce_CB

        function algOutputsTable1_cs_CB( obj , ~ , ~ )
  

        end % algOutputsTable1_cs_CB 
   
    end
    
    %% Methods - View Protected
    methods (Access = protected) 
        
        function update( obj, ~ , ~ ) 
            obj.LabelEditBox.String = obj.Label;%obj.LabelEditBox.String = obj.LinMdlLabelString;
            
            obj.ModelEditBox.String = obj.ModelName;

%             updateTable( obj );
            
            
            [obj.States,obj.StatePerturbSizes,obj.StatePerturbTypes] = obj.ViewStates.getSelectedNames();
            [obj.Inputs,obj.InputPerturbSizes,obj.InputPerturbTypes, obj.InputConstraintsArray, obj.InputConstraintsInfo] = obj.ViewInputs.getSelectedNames();
            obj.Outputs = obj.ViewOutputs.getSelectedNames();
            [obj.AlgebraicInput,obj.AlgebraicInputPerturbSizes,obj.AlgebraicInputPerturbTypes] = obj.ViewAlgebraicInputs.getSelectedNames();
            obj.AlgebraicOutput = obj.ViewAlgebraicOutputs.getSelectedNames();
        end % update
         
        function reSize( obj , ~ , ~ )
%             reSize@UserInterface.ObjectEditor.Editor( obj );              
            % get figure position
            position = getpixelposition(obj.MainPanel);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            set(obj.ModelText,'Units','Pixels',...
                'Position',[10 , position(4) - 70 , 200 , 17]); 
            set(obj.ModelEditBox,'Units','Pixels',...
                'Position',[10 , position(4) - 95 , 200 , 25]);  
            set(obj.ModelPushButton,'Units','Pixels',...
                'Position',[220 , position(4) - 95 , 70 , 25]);  
            
            set(obj.LabelText,'Units','Pixels',...
                'Position',[10 , position(4) - 20 , 200 , 17]);  
            set(obj.LabelEditBox,'Units','Pixels',...
                'Position',[10 , position(4) - 45 , 200 , 25]); 
            set(obj.NumOfTrimText,'Units','Pixels',...
                'Position',[220 , position(4) - 20 , 100 , 17]);  
            set(obj.NumOfTrimComboBox,'Units','Pixels',...
                'Position',[220 , position(4) - 45 , 70 , 25]);  
            
            set(obj.TablePanel,'Units','Pixels',...
                'Position',[10 , 2 , position(3)-20 , position(4) - 100 ]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            positionTab = getpixelposition(obj.TablePanel);
            tableHeight = (positionTab(4) - 180)/3;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.InputsText1.Units = 'Pixels';
%             obj.InputsText1.Position = [ 10 , 3*tableHeight + 155 , 180 , 20 ];
            obj.Input1Table.Units = 'Pixels';
            obj.Input1Table.Position = [ 10 , 2*tableHeight + 120, 275 , 1.5*tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.OutputsText1.Units = 'Pixels';
%             obj.OutputsText1.Position = [ 315 , 3*tableHeight + 155 , 180 , 20 ];
            obj.Output1Table.Units = 'Pixels';
            obj.Output1Table.Position = [ 315 , 2*tableHeight + 120, 200 , 1.5*tableHeight ];
% 
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.StatesText1.Units = 'Pixels';
%             obj.StatesText1.Position = [ 10 , 2*tableHeight + 105 , 180 , 20 ];
            obj.State1Table.Units = 'Pixels';
            obj.State1Table.Position = [ 10 , tableHeight + 65, 275 , 1.5*tableHeight ];
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.AlgInputsText.Units = 'Pixels';
%             obj.AlgInputsText.Position = [ 10 , tableHeight + 50 , 180 , 20 ];
            obj.AlgInputsTable.Units = 'Pixels';
            obj.AlgInputsTable.Position = [ 10 , 10 , 275 , 1.5*tableHeight ];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             obj.AlgOutputsText.Units = 'Pixels';
%             obj.AlgOutputsText.Position = [ 315 , tableHeight + 50 , 220 , 20 ];
            obj.AlgOutputsTable.Units = 'Pixels';
            obj.AlgOutputsTable.Position = [ 315 , 10 , 200 , 1.5*tableHeight ];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        end % reSize
        
        function updateTable( obj )
            
            if ~isempty(obj.ViewInputs)
                obj.Input1Table.Data        = obj.ViewInputs.getAsTableData('input');
            else
                obj.Input1Table.Data       = [];
            end
            
            if ~isempty(obj.ViewOutputs)
                obj.Output1Table.Data       = obj.ViewOutputs.getAsTableData('output');
            else
                obj.Output1Table.Data       = [];
            end
%             
            if ~isempty(obj.ViewStates)
                obj.State1Table.Data        = obj.ViewStates.getAsTableData('state');
            else
                obj.State1Table.Data       = [];
            end
%             
            if ~isempty(obj.ViewAlgebraicInputs)
                obj.AlgInputsTable.Data     = obj.ViewAlgebraicInputs.getAsTableData('alginput');
            else
                obj.AlgInputsTable.Data       = [];
            end
%             
            if ~isempty(obj.ViewAlgebraicOutputs)
                obj.AlgOutputsTable.Data    = obj.ViewAlgebraicOutputs.getAsTableData('output');
            else
                obj.AlgOutputsTable.Data       = [];
            end
              
        end
           
    end
    
    %% Methods - View Private
    methods (Access = private)
        function [inC,outC,stC,algInC,algOutC] = privateUpdateMdlCond( obj ,inNames , outNames , stateNames )
            
             % Check if length, order, and names are identical
            inputNamesOrderSame = isequal(inNames,{obj.ViewInputs.Name});
            outputNamesOrderSame= isequal(outNames,{obj.ViewOutputs.Name});
            stateNamesOrderSame = isequal(stateNames,{obj.ViewStates.Name});
            
            if inputNamesOrderSame && outputNamesOrderSame && stateNamesOrderSame
                inC   = obj.ViewInputs;
                outC  = obj.ViewOutputs;
                stC   = obj.ViewStates;
                algInC= obj.ViewAlgebraicInputs;
                algOutC=obj.ViewAlgebraicOutputs;
                return;
            end
            
            % Check if the length is the same
            inputNamesLengthSame = length(inNames)==length({obj.ViewInputs.Name});
            outputNamesLengthSame = length(outNames)==length({obj.ViewOutputs.Name});
            stateNamesLengthSame = length(stateNames)==length({obj.ViewStates.Name});
           
            if ~inputNamesLengthSame || ~outputNamesLengthSame || ~stateNamesLengthSame
                MessageBoxStr = {};
                if ~inputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of input ports have changed.';
                end
                
                if ~outputNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of output ports have changed.';
                end
                
                if ~stateNamesLengthSame
                    MessageBoxStr{end+1} = 'The number of states have changed.';
                end
                
                if ~isempty(MessageBoxStr)
                    MessageBoxStr{end+1} = 'Do you want to update the linear model definition to match the Simulink model?';
                    choice =  questdlg(MessageBoxStr,'Linear Model Definition Editor','Yes','No','No');
                    
                    switch choice
                        case 'Yes'
                            [~,iai] = setdiff(inNames,{obj.ViewInputs.Name});
                            [~,iao] = setdiff(outNames,{obj.ViewOutputs.Name});
                            [~,ias] = setdiff(stateNames,{obj.ViewStates.Name});
                            % Update input,outputs, states
                            [inC, outC, stC, algInC, algOutC] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames, iai, iao, ias);

                        case 'No'
                            inC = obj.ViewInputs;
                            outC= obj.ViewOutputs;
                            stC = obj.ViewStates;
                            algInC= obj.ViewAlgebraicInputs;
                            algOutC=obj.ViewAlgebraicOutputs;
                    end
                end
                
                
            else 
                MessageBoxStr = {};
                % Check if the names have changed (but length is the same)
                [~,iai] = setdiff(inNames,{obj.ViewInputs.Name});
                if ~isempty(iai)
                    MessageBoxStr{end+1} = 'The number of inputs is the same but some names have changed in the model.';
                else
                    if ~inputNamesOrderSame
                         MessageBoxStr{end+1} = 'The number of inputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,iao] = setdiff(outNames,{obj.ViewOutputs.Name});
                if ~isempty(iao)
                    MessageBoxStr{end+1} = 'The number of outputs is the same but some names have changed in the model.';
                else
                    if ~outputNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of outputs and names are identical but the order has changed.';
                    end
                end
                
                % Check if the names have changed (but length is the same)
                [~,ias] = setdiff(stateNames,{obj.ViewStates.Name});
                if ~isempty(ias)
                    MessageBoxStr{end+1} = 'The number of states is the same but some names have changed in the model.';
                else
                    if ~stateNamesOrderSame
                        MessageBoxStr{end+1} = 'The number of states and names are identical but the order has changed.';
                    end
                end
                
                if isempty(iai) && isempty(iao) && isempty(ias)
                     % Update input,outputs, states, and state derivatives
                     [inC, outC, stC, algInC, algOutC] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , iai, iao, ias);
                     MessageBoxStr{end+1} = 'Linear model definition is automatically updated.';
                     MessageBoxStr{end+1} = 'Please Save updated Linear Model Definition.';
                     msgbox(MessageBoxStr,'Linear Model Definition Editor');
                else
                    if ~isempty(MessageBoxStr)
                        MessageBoxStr{end+1} = 'Do you want to update the trim definition to match the Simulink model?';
                        choice =  questdlg(MessageBoxStr,'Trim Definition Editor','Yes','No','No');
                        
                        switch choice
                            case 'Yes'
                                [~,iai] = setdiff(inNames,{obj.ViewInputs.Name});
                                [~,iao] = setdiff(outNames,{obj.ViewOutputs.Name});
                                [~,ias] = setdiff(stateNames,{obj.ViewStates.Name});
                                
                                % Update input,outputs, states, and state derivatives
                                [inC, outC, stC, algInC, algOutC] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , iai, iao, ias);
                                
                            case 'No'
                                inC = obj.ViewInputs;
                                outC= obj.ViewOutputs;
                                stC = obj.ViewStates;
                                algInC= obj.ViewAlgebraicInputs;
                                algOutC=obj.ViewAlgebraicOutputs;
                        end
                    end
                end
            end
            
        end % privateUpdateMdlCond
        
        function [inC, outC, stC, algInC, algOutC] = privateUpdateMdlCondSub( obj, inNames , outNames , stateNames , iai, iao, ias)
            
            % Input update
            inC = UserInterface.ObjectEditor.LinMdlRow.empty;
            for i = 1:length(inNames)
                if any(i == iai)
                    inC(i) = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , [], 'input' );
                else
                    logArray = strcmp(inNames{i},{obj.ViewInputs.Name});
                    inC(i) = obj.ViewInputs(find(logArray,1));
                end
            end
            
            
            % Output update
            outC = UserInterface.ObjectEditor.LinMdlRow.empty;
            for i = 1:length(outNames)
                if any(i == iao)
                    outC(i) = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , [] );
                else
                    logArray = strcmp(outNames{i},{obj.ViewOutputs.Name});
                    outC(i) = obj.ViewOutputs(find(logArray,1));
                end
            end
            
            % State update
            stC = UserInterface.ObjectEditor.LinMdlRow.empty;
            for i = 1:length(stateNames)
                if any(i == ias)
                    stC(i) = UserInterface.ObjectEditor.LinMdlRow( stateNames{i} , [], 'state');
                else
                    logArray = strcmp(stateNames{i},{obj.ViewStates.Name});
                    stC(i) = obj.ViewStates(find(logArray,1));
                end
            end
            
            % Algebraic Input
            algInC = UserInterface.ObjectEditor.LinMdlRow.empty;
            for i = 1:length(inNames)
                if any(i == iai)
                    algInC(i) = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , [], 'input' );
                else
                    logArray = strcmp(inNames{i},{obj.ViewAlgebraicInputs.Name});
                    algInC(i) = obj.ViewAlgebraicInputs(find(logArray,1));
                end
            end
            
            
            % Algebraic Output
            algOutC = UserInterface.ObjectEditor.LinMdlRow.empty;
            for i = 1:length(outNames)
                if any(i == iao)
                    algOutC(i) = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , [] );
                else
                    logArray = strcmp(outNames{i},{obj.ViewAlgebraicOutputs.Name});
                    algOutC(i) = obj.ViewAlgebraicOutputs(find(logArray,1));
                end
            end
            
            
        end % privateUpdateMdlCondSub
    end
    
    
    methods % (Access = private) 
        
        function createDefault( obj , linMdlObj )
            
            if nargin == 2
                if isa(linMdlObj,'lacm.LinearModel')
                    mdl = linMdlObj.SimulinkModelName;
                    obj.ModelName = mdl;
                else
                    mdl = linMdlObj;
                    obj.ModelName = linMdlObj;
                end
            else
                mdl = obj.ModelName;
                if isempty(mdl)
                    error('A Simulink Model must be avaliable');
                end
            end
            
            load_system(mdl);
            
            [inNames , outNames , stateNames , ~ ] = Utilities.getNamesFromModel( mdl );

            for i = 1:length(inNames)
                obj.ViewInputs(i)          = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , [], 'input');
                obj.ViewAlgebraicInputs(i) = UserInterface.ObjectEditor.LinMdlRow( inNames{i} , [], 'input');
            end

            for i = 1:length(outNames)
                obj.ViewOutputs(i)          = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , []);
                obj.ViewAlgebraicOutputs(i) = UserInterface.ObjectEditor.LinMdlRow( outNames{i} , []);
            end  

            for i = 1:length(stateNames)
                obj.ViewStates(i) = UserInterface.ObjectEditor.LinMdlRow( stateNames{i} , [], 'state');
            end
            
            if nargin == 2 && isa(linMdlObj,'lacm.LinearModel')

                for i = 1:length(linMdlObj.ViewInputs)
                    inLogArray = strcmp(linMdlObj.ViewInputs{i},{obj.ViewInputs.Name});
                    obj.ViewInputs(inLogArray).Selected = true;
                end

                for i = 1:length(linMdlObj.ViewOutputs)
                    outLogArray = strcmp(linMdlObj.ViewOutputs{i},{obj.ViewOutputs.Name});
                    obj.ViewOutputs(outLogArray).Selected = true;
                end  

                for i = 1:length(linMdlObj.ViewStates)
                    stateLogArray = strcmp(linMdlObj.ViewStates{i},{obj.ViewStates.Name});
                    obj.ViewStates(stateLogArray).Selected = true;
                end
                
                for i = 1:length(linMdlObj.AlgebraicInput)
                    algInputLogArray = strcmp(linMdlObj.AlgebraicInput{i},{obj.ViewAlgebraicInputs.Name});
                    obj.ViewAlgebraicInputs(algInputLogArray).Selected = true;
                end

                for i = 1:length(linMdlObj.AlgebraicOutput)
                    inLogArray = strcmp(linMdlObj.AlgebraicOutput{i},{obj.ViewAlgebraicOutputs.Name});
                    obj.ViewAlgebraicOutputs(inLogArray).Selected = true;
                end     
  
            end
            
            update(obj);
            updateTable( obj );
        end % createDefault
        
        function updateMdlConditions( obj , simMdlName )
            
            if nargin == 2
                obj.ModelName = simMdlName;
            end
            
            mdl = obj.ModelName;
            if isempty(mdl)
                error('A Simulink Model must be avaliable');
            end
            
            
            [inNames , outNames , stateNames , stateDerivNames , inputUnits , outputUnits , stateUnit , stateDotUnit, cStateID] = Utilities.getNamesFromModel( mdl );
            
            [inC,outC,stC,algInC,algOutC] = privateUpdateMdlCond( obj ,inNames' , outNames' , stateNames );
            
            obj.ViewInputs = inC;
            obj.ViewOutputs = outC;
            obj.ViewStates = stC;
            obj.ViewAlgebraicInputs = algInC;
            obj.ViewAlgebraicOutputs = algOutC;          
            
        end % updateMdlConditions
        

    end
    
    %% Methods - Protected
    methods (Access = protected)       

    end
    
end
