function figH = createGUI()

figH = [];

try
    [~, result] = dos('getmac');
    [start, finish] = regexp(result, '\w*-\w*-\w*-\w*-\w*-\w*');
    macaddress = cell(1,length(start));
    for i = 1:length(start)
        macaddress{i} = result(start(i):finish(i));
    end

    allowedMACs = {'60-D8-19-FA-33-8B',...
                   '00-24-D7-77-19-3C',...
                   '00-24-D7-77-19-3D',...
                   '00-26-B9-CC-05-39',...
                   '26-39-C4-18-C9-76',...
                   '36-39-C4-18-C9-76',...
                   '44-39-C4-18-C9-76',...
                   'F0-1F-AF-5E-AC-C4',...                
                   '40-16-7E-13-27-45',...
                   'AC-7B-A1-4A-0A-FB',...
                   '00-FF-6E-66-B1-58',...
                   '4E-84-DC-78-55-49',...
                   '0C-84-DC-78-55-49',...
                   '0C-84-DC-78-55-4A'};
               
    if ~any(ismember(macaddress,allowedMACs))

       errordlg('MAC Address incorrect.  Please contact ACD.') ;
       return;

    end

catch
    errordlg('MAC Address incorrect.  Please contact ACD.') ;
    
end

%     [login,password] = Utilities.logindlg('Title','Flight Control Design');
% 
%     if isempty(login)
%         return;
%     end
% 
%     if strcmpi(login,'matthew.mangano@acd-eng.com') || ...
%             strcmpi(login,'nomaan.saeed@acd-eng.com') || ...
%             strcmpi(login,'dagfinn.gangsaas@acd-eng.com')
% 
%         if strcmp(password,'Mm*Ns*Dg*')
%             
            if verLessThan('matlab', '8.4.0')
                msgbox('You need Matlab 2014b or later to run this program.');
                return;
            else
                h = Launch();
                figH = h.Figure; 
            end
            
%         else
%             msgbox('Invalid Username or Password.');
%             return;    
%         end
%     else
%         msgbox('Invalid Username or Password.');
%         return; 
%         
%         
%     end




end