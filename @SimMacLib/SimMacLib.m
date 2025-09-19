classdef SimMacLib < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        MajorVersion
        MinorVersion
        BuildNumber
        
        FeatureID
        
        LastError = MException.empty
    end % Public properties
      
    %% Public properties - Data Storage
    properties   

    end % Public properties
    
    %% Properties - Observable
    properties(SetObservable)

    end
    
    %% Private properties
    properties ( Access = private )     

    end % Private properties
        
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        
    end % Read-only properties
    
    %% Hidden Properties
    properties (Hidden = true)
        
    end % Hidden properties

    %% Dependant properties
    properties ( Dependent = true )

    end % Dependant properties
    
    %% Dependant properties
    properties ( Dependent = true, SetAccess = private )

    end % Dependant properties
    
    %% Constant properties
    properties (Constant) 
        
%         DevelopmentMode = true;
         
        MACs = {'60-D8-19-FA-33-8B',...
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
               'C4-8E-8F-F5-D5-0F',...
               '4E-84-DC-78-55-49',...
               '0C-84-DC-78-55-49',...
               '0C-84-DC-78-55-4A',...
               '54-94-54-46-99-0D',...
               '24-FD-52-01-0D-00',...
               '3C-A9-F4-33-AB-55',...
               '3C-A9-F4-33-AB-54',...
               '54-09-D9-99-12-18',...
               '7C-7A-91-1A-BD-68',...
               '7C-7A-91-1A-BD-64',...
               '54-EE-75-02-EC-AC',...
               '54-4C-7A-D0-A0-1C',...
               '8C-70-5A-9D-27-C1',...
               '8C-70-5A-9D-27-C0',...
               '7C-E9-D3-E1-4C-98',...
               '3C-97-0E-11-A2-48',...
               '54-CA-D7-3C-29-27',...
               '24-77-03-64-DC-E5',...
               '24-77-03-64-DC-E5',...
               '24-77-03-64-DC-E4',...
               '3C-97-0E-86-6F-CC',...
               '00-50-56-C0-00-01',...
               '00-50-56-C0-00-08',...
               '54-45-AC-0C-FD-10',...
               '4C-EB-42-E3-CB-0E',...
               '4C-EB-42-E3-CB-0A',...
               '54-EE-75-8B-41-BB',...
               '6C-0B-84-0C-24-5F',...
               '28-F1-0E-4D-E3-EA',...
               'E4-A7-A0-CF-7E-4E',...
               '18-DB-F2-09-F5-BE',...
               'E4-A7-A0-CF-7E-51',...
               'E4-A7-A0-CF-7E-4D',...
               '54-E1-AD-CE-1F-AF',...
               'E4-70-B8-51-CB-DD',...
               '10-65-30-4D-3E-48',...
               '3C-18-A0-44-ED-11',...
               '60-F2-62-B7-16-EC',...
               '62-F2-62-B7-16-EB',...
               '60-F2-62-B7-16-EF',...
               };
           
        ExpirationDate = datetime(2050,07,01);
    end
    
    %% Events
    events

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = SimMacLib( id )
            
            switch nargin
                case 0
                    obj.FeatureID = 0; 
                case 1
                    obj.FeatureID = id;
            end  
            
            obj.MajorVersion = 'Unknown';
            obj.MinorVersion = 'Unknown';
            obj.BuildNumber  = 'Unknown';
        
        end % SimulationLib
        
    end % Constructor

    %% Methods - Property Access
    methods
                  

        
    end % Property access methods
  
    %% Methods - Protected Callbacks
    methods (Access = protected)

    end
    
    %% Methods - Resize Ordinary Methods
    methods     

                            
    end % Ordinary Methods
    
    %% Methods - Ordinary Methods
    methods
        
        function y = login( obj )

            y = macAddressValidate( obj );
            
        end % login
        
        function y = logout( obj )
            
            y = true;
            obj.LastError = MException.empty;
            
        end % logout
        
        function y = getSessionInfo( obj )
            
            y = 'Key Not Being Used';
            obj.LastError = MException.empty;
            
        end % getSessionInfo       
        
        function y = getCurrentTime( obj )

                y = datetime;
                obj.LastError = MException.empty;

        end % getCurrentTime
          
        function y = checkKeyStatus( obj )
            
            y = macAddressValidate( obj );
        
        end % checkKeyStatus
        
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        
        function authorized = macAddressValidate( obj )

            authorized = false;

            try
                % Bypass login dialog for certain users.
                [~, result] = dos('getmac');
                [start, finish] = regexp(result, '\w*-\w*-\w*-\w*-\w*-\w*');
                macaddress = cell(1,length(start));
                for i = 1:length(start)
                    macaddress{i} = result(start(i):finish(i));
                end


                if ~any(ismember(macaddress,obj.MACs))
                    obj.LastError = MException('License:MACAdressNotFound', ...
                                'The computer is not licensed. Please contact ACD.');
                    authorized = false;
                else
                    if date > obj.ExpirationDate
                        obj.LastError = MException('License:TrialExpired', ...
                                'The trial has expired. Please contact ACD.');
                        authorized = false;
                    else
                        authorized = true;
                        obj.LastError = MException.empty;
                    end
                end

            catch
                obj.LastError = MException('License:UnkownError', ...
                            'The license can not be validated. Please contact ACD.');
            end
        end % macAddressValidate
        
        function status = validateUserName( obj, username )
            status = false;
            if strcmpi(username,'matthew.mangano@acd-eng.com') || ...
                    strcmpi(username,'nomaan.saeed@acd-eng.com') || ...
                    strcmpi(username,'dagfinn.gangsaas@acd-eng.com')
                status = true;

            end
        end % validateUserName

        function status = validatePassword( obj , password )
            status = false;
            if strcmp(password,'framover') 
                status = true;
            end
        end  % validatePassword

    end
    
    %% Methods - Protected Copy Method
    methods (Access = protected)   
        function cpObj = copyElement(obj)
        % Override copyElement method:    
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the Example object
%             cpObj.Example = copy(obj.Example);
        end % copyElement
    end
    
    %% Methods - Private
    methods (Access = private)

    end
    
    %% Methods - Static
    methods ( Static )
        

    end
    
end

