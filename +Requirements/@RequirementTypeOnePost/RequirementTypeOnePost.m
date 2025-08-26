classdef RequirementTypeOnePost < Requirements.RequirementTypeOne 
    
    %% Public properties
    properties
        

        
    end % Public properties
   
    %% Public Observable properties
    properties  (SetObservable) 


    end % Public properties 
    
    %% Hidden Properties
    properties (Hidden = true)

    end % Hidden Properties

    %% Hidden Transient Properties
    properties (Hidden = true , Transient = true )

    end % Hidden Transient Properties
    
    %% Hidden Transient View Properties
    properties (Hidden = true , Transient = true )       


    end % Hidden Transient View Properties
    
    %% Methods - Constructor
    methods  
        function r = RequirementTypeOnePost(funName,title,model)
          if nargin == 3
             r.FunName = funName;
             r.Title = title;
             r.MdlName = model;
          end
        end % RequirementTypeOnePost 
    end % Constructor
   
    %% Methods - Property Access
    methods

        
    end % Methods - Property Access
    
    %% Methods - Ordinary
    methods
        function runDynamics( obj , axHLL , OperConds , simOut , simIn )
            import UserInterface.ControlDesign.Utilities.*
                % Plot the base plot if new objects are added
                
 
                for i = 1:length(obj) % Requirement Loop
                 
                    % Set the plot Visible to ON
                    set(axHLL.get(i-1),'Visible','on');
                    obj(i).plotBase(axHLL.get(i-1));
                    obj(i).axH = axHLL.get(i-1);
                    obj(i).deleteLines;

                end 

                    % get all the function names of current stability objects
                    funNames = arrayfun(@(x) x.FunName, obj,'UniformOutput',false);
                    % find all unique function names
                    [~, ~, uniqueInd] = unique(funNames);
                    % find the number of times to run methodes
                    ii = max(uniqueInd);
                    for i = 1:ii 

                        objArrayInd = find(uniqueInd == i);
                        funHandle = obj(objArrayInd(1)).getFunctionHandle;
                        % determine the number of output arguments
                        numOutArg = nargout(funHandle);
                        
                        if obj(objArrayInd(1)).IterativeRequierment == true
                            % Iterative Req
                            for selMdlInd = 1:length(OperConds)  
                                OperConds(selMdlInd).FlightDynLineH = [];
                                switch numOutArg
                                    case 1
                                        try
                                            newLine = funHandle( OperConds(selMdlInd) , simOut(selMdlInd) , simIn  );
                                        catch MExc
                                            error('FlightDynamics:MethodError',['There is an error in the Requierment method ',obj(objArrayInd(1)).FunName,'.']);
                                        end
                                end
                                if ~iscell(newLine)
                                    newLine = {newLine};
                                end
                                for j = 1:length(objArrayInd)
                                    if strcmp(obj(objArrayInd(j)).SelectedStatus,'selected') % Only run the selected requirements
                                        set(obj(objArrayInd(j)).axH,'color',[1 1 1]);
                                        outInd = obj(objArrayInd(j)).OutputDataIndex;
                                        % plot the cdData
                                        %obj(objArrayInd(j)).deleteLines;

                                        if numOutArg == 1


                                                % plot markers and add legend
                                                for n = 1:length(newLine{outInd}) 
                                                    if isempty(newLine{outInd}(n).Color)
                                                        color = getColor(selMdlInd);
                                                    else
                                                        color = newLine{outInd}(n).Color;
                                                    end
                                                    
                                                    obj(objArrayInd(j)).lineH(end+1) = line(...
                                                        'XData',newLine{outInd}(n).XData,...
                                                        'YData',newLine{outInd}(n).YData,...
                                                        'ZData',newLine{outInd}(n).ZData,...
                                                        'Parent',obj(objArrayInd(j)).axH,...
                                                        'Color',color,...
                                                        'Marker',newLine{outInd}(n).Marker,...
                                                        'MarkerSize',newLine{outInd}(n).MarkerSize,...
                                                        'MarkerEdgeColor',color,...%newLine{outInd}(n).MarkerEdgeColor,... 
                                                        'MarkerFaceColor',color,...%newLine{outInd}(n).MarkerFaceColor,...
                                                        'LineStyle',newLine{outInd}(n).LineStyle,... 
                                                        'LineWidth',newLine{outInd}(n).LineWidth,... 
                                                        'DisplayName',newLine{outInd}(n).DisplayName,...
                                                        'UserData',newLine{outInd}(n).UserData );
                                                    OperConds(selMdlInd).FlightDynLineH(end+1) = obj(objArrayInd(j)).lineH(end);
                                                end      
                                                if ~all(cellfun(@isempty,{newLine{outInd}.DisplayName}))
                                                    legObjH = legend(obj(objArrayInd(j)).axH,obj(objArrayInd(j)).lineH,'Location','best');
                                                    set(obj(objArrayInd(j)).axH,'UserData',legObjH);
                                                end
                                        end

                                    else
                                        set(obj(objArrayInd(j)).axH,'color','none');
                                    end
                                end
                            
                            end
                        else
                            % NonIterative Req
                            switch numOutArg
                                case 1
                                    newLine = funHandle( OperConds );
                            end
                            if ~iscell(newLine)
                                newLine = {newLine};
                            end
                            for j = 1:length(objArrayInd)
                                if strcmp(obj(objArrayInd(j)).SelectedStatus,'selected') % Only run the selected requirements
                                    set(obj(objArrayInd(j)).axH,'color',[1 1 1]);
                                    outInd = obj(objArrayInd(j)).OutputDataIndex;


                                    if numOutArg == 1

                                            ind = 0;
                                            % plot markers and add legend
                                            for n = 1:length(newLine{outInd}) 
                                                
                                                    if isempty(newLine{outInd}(n).Color)
                                                        ind = ind +1;
                                                        color = getColor(ind);
                                                    else
                                                        color = newLine{outInd}(n).Color;
                                                    end
                                                obj(objArrayInd(j)).lineH(end+1) = line(...
                                                    'XData',newLine{outInd}(n).XData,...
                                                    'YData',newLine{outInd}(n).YData,...
                                                    'ZData',newLine{outInd}(n).ZData,...
                                                    'Parent',obj(objArrayInd(j)).axH,...
                                                    'Color',color,...%newLine{outInd}(n).Color,...
                                                    'Marker',newLine{outInd}(n).Marker,...
                                                    'MarkerSize',newLine{outInd}(n).MarkerSize,...
                                                    'MarkerEdgeColor',color,...%newLine{outInd}(n).MarkerEdgeColor,... 
                                                    'MarkerFaceColor',color,...%newLine{outInd}(n).MarkerFaceColor,...
                                                    'LineStyle',newLine{outInd}(n).LineStyle,... 
                                                    'LineWidth',newLine{outInd}(n).LineWidth,... 
                                                    'DisplayName',newLine{outInd}(n).DisplayName,...
                                                    'UserData',newLine{outInd}(n).UserData );
                                                OperConds.FlightDynLineH(end+1) = obj(objArrayInd(j)).lineH(end);
                                            end   
                                            if ~all(cellfun(@isempty,{newLine{outInd}.DisplayName}))

                                                legObjH = legend(obj(objArrayInd(j)).axH,obj(objArrayInd(j)).lineH,'Location','best');
                                                set(obj(objArrayInd(j)).axH,'UserData',legObjH);
                                            end
                                    end

                                else
                                    set(obj(objArrayInd(j)).axH,'color','none');
                                end
                            end 
                        end
                    end
%                 end
        

%                 close_system({obj.MdlName},0);  

        end % runDynamics       
    end % Ordinary Methods

    %% Methods - View
    methods

    end % Methods - View
        
    %% Methods - Protected Callbacks
    methods
        

    end % Methods - Protected Callbacks
    
    %% Methods - Protected
    methods
        
        
    end % Methods - Protected
   
end

function y = getColor(ind)

color = {'b','r','g','k','m','c',[0.5,0.5,0]};
if ind <= 7
    y = color{ind};
else
    y = [rand(1),rand(1),rand(1)];
end

end % getColor





