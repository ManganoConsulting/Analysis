function jmenu = uiMenus( obj , node )

    req_Icon = javaObjectEDT('javax.swing.ImageIcon',getIcon('workIcon_24.png'));
    req_Icon_Blue = javaObjectEDT('javax.swing.ImageIcon',getIcon('workIcon_24_Blue.png'));
    req_Icon_Red = javaObjectEDT('javax.swing.ImageIcon',getIcon('workIcon_24_Red.png'));
    req_Icon_Yellow = javaObjectEDT('javax.swing.ImageIcon',getIcon('workIcon_24_Yellow.png'));

    jmenu = javaObjectEDT('javax.swing.JPopupMenu');

    
    switch node.Value
        case 1 %{'Operating Conditions','Operating Condition'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Operating Conditions');
            menuItem1h = handle(menuItem1,'CallbackProperties');
            
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All Operating Conditions');
            menuItem2h = handle(menuItem2,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.addOperCond,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.removeAllOperCond_CB,node});
            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
        case 2 %{'Synthesis'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Synthesis Object',req_Icon);
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.Synthesis.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem4);
        case 3 %{'Scattered'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Load Scattered Gain Object');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert New Scattered Gain Object');
            
            
            
            
            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{ @obj.insertScatteredGainFileObj_CB , node });
            set(menuItem2h,'ActionPerformedCallback',{@obj.insertEmptyScatteredGainObj_CB,node,false});

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
        case 4 %{'Scheduled'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Scheduled Gain Object');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert New Scheduled Gain Object');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertSchGainCollObjFile_CB,node,[],ScheduledGain.SchGainCollection.empty});
            set(menuItem2h,'ActionPerformedCallback',@obj.insertEmptySchGainObj_CB);%@obj.insertNewSourceGainObj_CB);
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});

            % Add all menu items to the context menu
            %jmenu.add(menuItem1);  Not Working yet!
            %jmenu.add(menuItem2);  Not Working yet!
            jmenu.add(menuItem4);
        case 5 %{'Root Locus'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Root Locus Object',req_Icon);
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');

            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.RootLocus.empty});

            % Add all menu items to the context menu
            jmenu.add(menuItem5);
            jmenu.add(menuItem4); 
            
        case 6 %{'Stability'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Stability Requirement',req_Icon_Blue);
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save All');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Change "Checked" Requirement Simulations (Stability)');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.Stability.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.saveAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.changeSimulation_CB,node});

            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
        case 7 %{'FrequencyResponse'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Frequency Response Requirement',req_Icon_Red);
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save All');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Change  "Checked" Requirement Simulations (Frequency Response)');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.FrequencyResponse.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.saveAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.changeSimulation_CB,node});

            % Add all menu items to the context menu (with internal separator)
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
        case 8 %{'Simulation'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Simulation',req_Icon_Yellow);
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save All');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Change "Checked" Requirement Simulations (Simulation)');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.SimulationCollection.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.saveAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.changeSimulation_CB,node});

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
        case 9 %{'HandlingQualities'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert HQ Requirement',req_Icon_Blue);
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save All');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Change "Checked" Requirement Simulations (Handling Qualities)');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.HandlingQualities.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.saveAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.changeSimulation_CB,node});

            % Add all menu items to the context menu (with internal separator)
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
        case 10 %{'Aeroservoelasticity'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert ASE Requirement',req_Icon);
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Save All');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove All');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Change "Checked" Requirement Simulations (Aeroservoelasticity)');

            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertReqObj_CB,node,[],Requirements.Aeroservoelasticity.empty});
            set(menuItem4h,'ActionPerformedCallback',{@obj.removeAll_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.saveAll_CB,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.changeSimulation_CB,node});

            % Add all menu items to the context menu (with internal separator)
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);

    %%%%%%% Child Menus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        case 11 %{'Operating Conditions Child'}
            
            %return; % This needs to still be implemented
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove');
            menuItem1h = handle(menuItem1,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.removeOperCond_CB,node});

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
      
        case 12 %{'Stability Child'}
            if strcmp(char(node.Value),'folder')
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Requirements');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Folder');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');

                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.insertStabObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',@obj.removeFolder_CB);

                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem1); 
                jmenu.add(menuItem2);
            else
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Stability Requirement');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Stability Requirement');
                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save');
                menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Up');
                menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Down');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem4h = handle(menuItem4,'CallbackProperties');
                menuItem5h = handle(menuItem5,'CallbackProperties');
                
                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
                set(menuItem3h,'ActionPerformedCallback',{@obj.saveReqObj_CB,node});
                set(menuItem4h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'up'});
                set(menuItem5h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'down'});


                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem4);
                jmenu.add(menuItem5);
                jmenu.add(menuItem1);
                jmenu.add(menuItem2);
                jmenu.add(menuItem3);
            end
        case 13 %{'FrequencyResponse Child'}
            if strcmp(char(node.Value),'folder')
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Requirements');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Folder');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');

                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.insertFreqRespObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',@obj.removeFolder_CB);

                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem1); 
                jmenu.add(menuItem2);
            else
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Frequency Response Requirement');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Frequency Response Requirement');
                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save');
                menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Up');
                menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Down');
                
                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem4h = handle(menuItem4,'CallbackProperties');
                menuItem5h = handle(menuItem5,'CallbackProperties');

                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
                set(menuItem3h,'ActionPerformedCallback',{@obj.saveReqObj_CB,node});
                set(menuItem4h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'up'});
                set(menuItem5h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'down'});
                
                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem4);
                jmenu.add(menuItem5);
                jmenu.add(menuItem1);
                jmenu.add(menuItem2);
                jmenu.add(menuItem3);
            end
        case 14 %{'HandlingQualities Child'}
            if strcmp(char(node.Value),'folder')
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Requirements');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Folder');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');

                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.insertHQObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',@obj.removeFolder_CB);

                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem1);
                jmenu.add(menuItem2);
            else
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Handling Qualities Requirement');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Handling Qualities Requirement');
                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save');
                menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Up');
                menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Down');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem4h = handle(menuItem4,'CallbackProperties');
                menuItem5h = handle(menuItem5,'CallbackProperties');

                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
                set(menuItem3h,'ActionPerformedCallback',{@obj.saveReqObj_CB,node});
                set(menuItem4h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'up'});
                set(menuItem5h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'down'});
                
                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem4);
                jmenu.add(menuItem5);
                jmenu.add(menuItem1);
                jmenu.add(menuItem2);
                jmenu.add(menuItem3);
            end
        case 15 %{'Aeroservoelasticity Child'}
            if strcmp(char(node.Value),'folder')
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert Requirements');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Folder');
                

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                


                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.insertASEObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',@obj.removeFolder_CB);

                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem1); 
                jmenu.add(menuItem2);
            else
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Aeroservoelasticity Requirement');
                menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Aeroservoelasticity Requirement');
                menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save');
                menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Up');
                menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Down');

                menuItem1h = handle(menuItem1,'CallbackProperties');
                menuItem2h = handle(menuItem2,'CallbackProperties');
                menuItem3h = handle(menuItem3,'CallbackProperties');
                menuItem4h = handle(menuItem4,'CallbackProperties');
                menuItem5h = handle(menuItem5,'CallbackProperties');
                
                % Set the menu items' callbacks
                set(menuItem1h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
                set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
                set(menuItem3h,'ActionPerformedCallback',{@obj.saveReqObj_CB,node});
                set(menuItem4h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'up'});
                set(menuItem5h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'down'});
                
                % Add all menu items to the context menu (with internal separator)
                jmenu.add(menuItem4);
                jmenu.add(menuItem5);
                jmenu.add(menuItem1);
                jmenu.add(menuItem2);
                jmenu.add(menuItem3);
            end
        case 16 %{'Synthesis Child'}
            % Prepare the context menu (note the use of HTML labels)
            %menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Run Synthesis');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Synthesis Requirement');
            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Synthesis Requirement');

            %menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem3h = handle(menuItem3,'CallbackProperties');

            % Set the menu items' callbacks
            %set(menuItem1h,'ActionPerformedCallback',{@obj.runSynthesis_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
            set(menuItem3h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
            % Add all menu items to the context menu (with internal separator)
            %jmenu.add(menuItem1);  
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
        case 17 %{'Simulation Child'}
            % Prepare the context menu (note the use of HTML labels)
            %menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Model');
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Simulation Requirement');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Simulation Requirement');
            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Up');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Move - Down');


            menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem3h = handle(menuItem3,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');
            
            % Set the menu items' callbacks
            %set(menuItem1h,'ActionPerformedCallback',{@obj.openMdl_CB,char(node.getName)});
            set(menuItem1h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
            set(menuItem3h,'ActionPerformedCallback',{@obj.saveReqObj_CB,node});
            set(menuItem4h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'up'});
            set(menuItem5h,'ActionPerformedCallback',{@obj.mvReqNode_CB,node,'down'});

            % Add all menu items to the context menu (with internal separator)
            %jmenu.add(menuItem1);   
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
            jmenu.add(menuItem2); 
            jmenu.add(menuItem1); 
            jmenu.add(menuItem3);
        case 18 %{'Root Locus Child'}
            % Prepare the context menu (note the use of HTML labels)
            %menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Run Synthesis');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Edit Root Locus');
            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Root Locus');

            %menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem3h = handle(menuItem3,'CallbackProperties');

            % Set the menu items' callbacks
            %set(menuItem1h,'ActionPerformedCallback',{@obj.runSynthesis_CB,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.editReq_CB,node});
            set(menuItem3h,'ActionPerformedCallback',{@obj.removeReqObj_CB,node});
            % Add all menu items to the context menu (with internal separator)
            %jmenu.add(menuItem1);  
            jmenu.add(menuItem2);
            jmenu.add(menuItem3); 
        case 19
            scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Model');
            menuItem1.setIcon(scattIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',{@obj.openModel_CB,node});
            jmenu.add(menuItem1);  
        case {20,30}
            scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Method');
            menuItem1.setIcon(scattIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',{@obj.openMethod_CB,node});
            jmenu.add(menuItem1); 
                
        case 21 %{'Scattered Child'}
            % Prepare the context menu (note the use of HTML labels)
%             menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Rename');
            menuItem2 = javaObjectEDT('javax.swing.JMenuItem','<html>Remove Scattered Gain File');
            menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Save Scattered Gain File (.mat)');
            menuItem4 = javaObjectEDT('javax.swing.JMenuItem','<html>Export Scattered Gain File (.txt)');
            menuItem5 = javaObjectEDT('javax.swing.JMenuItem','<html>Clear Scattered Gain File');

%             menuItem1h = handle(menuItem1,'CallbackProperties');
            menuItem2h = handle(menuItem2,'CallbackProperties');
            menuItem3h = handle(menuItem3,'CallbackProperties');
            menuItem4h = handle(menuItem4,'CallbackProperties');
            menuItem5h = handle(menuItem5,'CallbackProperties');

            % Set the menu items' callbacks
%             set(menuItem1h,'ActionPerformedCallback',{@obj.renameScatteredGainFile,node});
            set(menuItem2h,'ActionPerformedCallback',{@obj.removeScatteredGainFile,node});
            set(menuItem3h,'ActionPerformedCallback',{@obj.saveScattGainFromNode,node});
            set(menuItem4h,'ActionPerformedCallback',{@obj.exportScattGainFromNode,node});
            set(menuItem5h,'ActionPerformedCallback',{@obj.clearScattGainFromNode,node});
            
            % Add all menu items to the context menu (with internal separator)
%             jmenu.add(menuItem1);  
            jmenu.add(menuItem2);
            jmenu.add(menuItem3);
            jmenu.add(menuItem4);
            jmenu.add(menuItem5);
        case 22
            % find all scattered gain files
            scattFileNames = {obj.GainsScattered.Children.Name};
            scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));

            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Insert New Scattered Gain Object');
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',{@obj.insertEmptyScatteredGainObj_CB,node.Parent,true});

                menuItem2 = javax.swing.JMenu('<html>Select Scattered Gain Object for Save');
                menuItem2.setIcon(scattIcon);

                for i = 1:length(scattFileNames)
                    menuItem21 = javaObjectEDT('javax.swing.JMenuItem',['<html>',scattFileNames{i}],scattIcon);
                    menuItem21h = handle(menuItem21,'CallbackProperties');
                    set(menuItem21h,'ActionPerformedCallback',{@obj.selectScatteredGainFile2Write,node.Parent,scattFileNames{i}});
                    menuItem2.add(menuItem21);
                end
%             menuItem3 = javaObjectEDT('javax.swing.JMenuItem','<html>Rename');
%             menuItem3h = handle(menuItem3,'CallbackProperties');
%             set(menuItem3h,'ActionPerformedCallback',{@obj.renameScatteredGainFile,node});

            % Add all menu items to the context menu
            jmenu.add(menuItem1);
            jmenu.add(menuItem2);
%             jmenu.add(menuItem3);  
        case 23 %{'Scheduled Child'}
            % Prepare the context menu (note the use of HTML labels)
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Save Gain Schedule');

            menuItem1h = handle(menuItem1,'CallbackProperties');

            % Set the menu items' callbacks
            set(menuItem1h,'ActionPerformedCallback',{@obj.saveGainSchFromNode,node});

            % Add all menu items to the context menu (with internal separator)
            jmenu.add(menuItem1);  
        case {'Synthesis Child Child'}
            if strcmp(char(node.Value),'ScatteredGainFile')

            elseif strcmp(char(node.Value),'Method')
                scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Method');
                menuItem1.setIcon(scattIcon);
                menuItem1h = handle(menuItem1,'CallbackProperties');
                set(menuItem1h,'ActionPerformedCallback',{@obj.openMethod_CB,node});
                jmenu.add(menuItem1);     
            elseif strcmp(char(node.Value),'RequiermentPlot')
                scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
                % Prepare the context menu (note the use of HTML labels)
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Method');
                menuItem1.setIcon(scattIcon);
                menuItem1h = handle(menuItem1,'CallbackProperties');
                set(menuItem1h,'ActionPerformedCallback',{@obj.openMethod_CB,node});
                jmenu.add(menuItem1);  
            else
                % Prepare the context menu (note the use of HTML labels)
                scattIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Layout_16.png'));
                menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Open Model');
                menuItem1.setIcon(scattIcon);
                menuItem1h = handle(menuItem1,'CallbackProperties');
                set(menuItem1h,'ActionPerformedCallback',{@obj.openModel_CB,node});
                jmenu.add(menuItem1);
            end         
        case {'Scheduled Child Child'}
            % Prepare the context menu (note the use of HTML labels)
            simIcon  = javaObjectEDT('javax.swing.ImageIcon',getIcon('Simulink_16.png'));
            menuItem1 = javaObjectEDT('javax.swing.JMenuItem','<html>Create Simulink Block');
            menuItem1.setIcon(simIcon);
            menuItem1h = handle(menuItem1,'CallbackProperties');
            set(menuItem1h,'ActionPerformedCallback',{@obj.createSimulinkBlock,node.Parent,node.getName});
            jmenu.add(menuItem1);

    end


end

function y = getIcon( imagefilename )

    this_dir = fileparts( mfilename( 'fullpath' ) );
    icon_dir = fullfile( this_dir,'..','..','Resources' );
    y = fullfile(icon_dir,imagefilename);
end % getIcon