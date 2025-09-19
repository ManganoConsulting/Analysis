function createShortcut(installPath,file2call,name,ver,intver)



% Potentially useful commands
% category = scUtils.getDefaultToolbarCategoryName; 
% scVector = scUtils.getShortcutsByCategory(category);
% scArray = scVector.toArray;  % Java array
% scUtils.editShortcut
% installPath = 'C:\Projects\ACD Tools\FLIGHT\trunk';

if verLessThan('matlab', '9.4.0')

    name = ['FLIGHT',name,' | ',ver];
    isEditable = 'false';
    category = 'ACD Tools';
    comment = ['%',name,' Ver | ',intver]; 
    path = ['addpath(''',installPath,''');'];
    cbstr = sprintf('%s\n%s\n%s%s',comment,path,file2call,';');
    iconfile = fullfile(installPath,'+UserInterface\Resources','acd_logo_only_16.png'); 
    
    
    
    scUtils = com.mathworks.mlwidgets.shortcuts.ShortcutUtils;
    scVector = scUtils.getShortcutsByCategory(category);
    
    replaceFlag = true;
    
    if isa(scVector,'java.util.Vector')
        scArray = scVector.toArray;
        
        for scIdx = 1:length(scArray)
            scCB = char(scArray(scIdx).getCallback);
            %scName = char(scArray(scIdx));
            if strcmp(scCB, cbstr)
            %if strcmp(scName, name)
                replaceFlag = false; break;
            end
        end
    end
    
    if replaceFlag
        scUtils.removeShortcut(category, name); % Try and remove shortcut if the name is the same  
        scUtils.addShortcutToBottom(name,cbstr,iconfile,category,isEditable);
    end

else
    name = ['FLIGHT',name,' | ',intver];
    isEditable = 'false';
    category = 'ACD Tools';
    comment = ['%',name,' Ver | ',intver]; 
    path = ['addpath(''',installPath,''');'];
    cbstr = sprintf('%s\n%s\n%s%s',comment,path,file2call,';');
    iconfile = fullfile(installPath,'+UserInterface\Resources','acd_logo_only_16.png');      
    
    replaceFlag = false;
    
    %% Getting all available categories
    % Newer MATLAB releases may not expose the FavoriteCommands Java API that
    % is used below.  In those cases an exception can be thrown which would
    % previously prevent the application from launching.  Wrap the calls in a
    % try/catch block so that failure to access the favorite command API only
    % results in skipping the shortcut creation rather than throwing an
    % error.
    try
        fcObj = com.mathworks.mlwidgets.favoritecommands.FavoriteCommands.getInstance();
        method = fcObj.getClass().getDeclaredMethod('getCategories', []);
        method.setAccessible(true);
        categories = method.invoke(fcObj,[]);      % returns a Java List with all categories
    catch ME
        warning('Utilities:createShortcut:Failed','Unable to create favorite command shortcut: %s', ME.message);
        return; % Gracefully exit if favorites cannot be accessed
    end
    
    % Find the ACD Tools catagory
    acdCat = [];
    for i = 0:size(categories) - 1
        cat = categories.get(i);     % returns the first category
        catLabel= cat.getLabel();
        if strcmpi(catLabel, 'ACD Tools')
            acdCat = cat;
        end
    end
    
    % Store all cuurent ACD favorites
    acdFavorites = struct('Label',{},'Code',{},'Icon',{});
    % If catagory exists check for a previous favorite
    if ~isempty(acdCat)
   
        currentToolType = strsplit(name,'|');
        acdFavs = acdCat.getChildren;
        
        for i = 0:size(acdFavs) - 1
            fav = acdFavs.get(i);
            favLabel = char(fav.getLabel);
            favlabelType = strsplit(favLabel,'|');
            favCode = char(fav.getCode);
            favIcon = fav.getIcon.getIcon;
            
            if strcmp(name, favLabel)
            	% Replace the same version with the updated path
                % Remove it and add the latest
                replaceFlag = true;
                acdFavorites(end+1) = struct('Label',name,'Code',cbstr,'Icon',iconfile);
            else
                acdFavorites(end+1) = struct('Label',favLabel,'Code',favCode,'Icon',favIcon); %#ok<*AGROW>
            end
        end
        
        % Add if none exists
        if ~any(strcmp({acdFavorites.Label},name))
            replaceFlag = true;
            acdFavorites(end+1) = struct('Label',name,'Code',cbstr,'Icon',iconfile);
        end
        
    else
        replaceFlag = true;
        acdFavorites(end+1) = struct('Label',name,'Code',cbstr,'Icon',iconfile);  
    end
    
    if replaceFlag
        % Remove the enitre Catagory
        if ~isempty(acdCat)
            uiid = acdCat.getName();
            fcObj.removeCategory(uiid);
        end

        % Add the catagory back
        acdCatagory = com.mathworks.mlwidgets.favoritecommands.FavoriteCategoryProperties();
        acdCatagory.setLabel('ACD TOOLS');
        fcObj.addCategory(acdCatagory);     % create the new category
%             jIcon = javax.swing.ImageIcon(iconfile);  % Java ImageIcon from file (inc. GIF)
%             %icon = javax.swing.Icon(jIcon);
%             acdCat.setIcon(jIcon);
            
        % Add back the favorites
        for i = 1:length(acdFavorites)
            newFavoriteCommand = com.mathworks.mlwidgets.favoritecommands.FavoriteCommandProperties();
            newFavoriteCommand.setLabel(acdFavorites(i).Label);
            newFavoriteCommand.setCategoryLabel('ACD TOOLS');    % use always upper case letters, otherwise I got problems to add furterh favorits 
            newFavoriteCommand.setCode(acdFavorites(i).Code);
            newFavoriteCommand.setIsOnQuickToolBar(false);
%             newFavoriteCommand.setIconPath(acdFavorites(i).Icon);
            % add the command to the favorite commands (the category is automatically created if it doesn't exist)
            fcObj.addCommand(newFavoriteCommand);           
        end    
        
    end

    
    
    
    
end

end