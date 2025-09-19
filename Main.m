classdef Main < handle

    %% Properties
    properties
       ToolObj
       OperCond = lacm.OperatingCondition.empty;
    end
    
    %% Methods - Constructor
    methods
        function obj = Main()

            ProjectType = 'Control';

            % Start the Application and check licensing and tool set up.
            App = Application(2);

            if App.AccessAllowed
                warn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                % Start up the splash screen
                this_dir = fileparts( mfilename( 'fullpath' ) );
                icon_dir = fullfile( this_dir,'..','+UserInterface','Resources' );
                splash = Utilities.SplashScreen( 'Splashscreen', fullfile(icon_dir,'ACDSplash_Control.png'), ...
                    'ProgressBar', 'off');
                splash.addText( 30, 310, ['Version ',App.VersionNumber], 'FontSize', 20, 'Color', [0 0 0] );
                splash.addText( 33, 325, ['Build - ',App.InternalVersionNumber], 'FontSize', 10, 'Color', [0 0 0] );

                % Set the look and feel for the table models
                try              
                    defaults = javax.swing.UIManager.getLookAndFeelDefaults;
                    if isempty(defaults.get('Table.alternateRowColor'))
                        defaults.put('Table.alternateRowColor', java.awt.Color( 246/255 , 243/255 , 237/255 ));
                    end
                catch
                   warning('Unable to update ''Table.alternateRowColor''.');
                end

                sz = [ 960 , 1384]; % figure size
                screensize = get(0,'ScreenSize');
                xpos = ceil((screensize(3)-sz(2))/2); % center the figure on the screen horizontally
                ypos = ceil((screensize(4)-sz(1))/2); % center the figure on the screen vertically

                figH = uifigure('Name',['FLIGHT ',ProjectType,' | ',App.InternalVersionNumber],...
                                    'units','pixels',...
                                    'Position',[xpos, ypos, sz(2), sz(1)],...
                                    'Menubar','none',...   
                                    'Toolbar','none',...
                                    'NumberTitle','off',...
                                    'HandleVisibility', 'on',...
                                    'Visible','on',...
                                    'CloseRequestFcn', @obj.closeFigure_CB);


                if ~( strcmp(version('-release'),'2015b') || strcmp(version('-release'),'2016a') )
                    jFig = get(handle(figH), 'JavaFrame');
                    pause(0.1);
                    jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension( 1384 , 960 ));       
                end

                obj.ToolObj = UserInterface.ControlDesign.ControlDesignGUI(figH,App.Granola,App.VersionNumber,App.InternalVersionNumber); 
%                 addlistener(obj.ToolObj,'LoadOperCond',@obj.loadOperCond);



                drawnow();
                delete(splash);
                warning(warn);
            else
                throw(App.Granola.LastError); % Terminate Program
            end
        end

    end % Constructor
    
    %% Methods - Ordinary
    methods
        function loadOperCond(obj , hobj , eventdata )
            
            % Load the Operating Condition
            operCond2Load = eventdata.Value;
            operCond = lacm.OperatingCondition.empty; %#ok<NASGU>
            for j = 1:length(operCond2Load)
                varStruct = load(operCond2Load{j});
                varNames = fieldnames(varStruct);
                for i = 1:length(varNames)
                    obj.OperCond = [obj.OperCond,varStruct.(varNames{i})]; 
                end
            end
            
            % Update Filter Selections
            updateAvaliableSelections(obj.ToolObj.OperCondColl,{obj.OperCond(1).Inputs.Name}',{obj.OperCond(1).MassProperties.Parameter.Name}');
            
        end % loadOperCond

        function closeFigure_CB(obj , hobj , eventdata )
            delete(obj.ToolObj);
            delete(hobj);
        end % closeFigure_CB

    end % Methods - Ordinary
end




