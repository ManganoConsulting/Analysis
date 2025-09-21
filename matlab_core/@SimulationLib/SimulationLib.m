classdef SimulationLib < handle
    
    %% Public properties - Object Handles
    properties (Transient = true)  
        MajorVersion
        MinorVersion
        BuildNumber
        
        HaspObj
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
        
         DevelopmentMode = false;
           % Demo Vendor Code       
%          VendorCode = ['AzIceaqfA1hX5wS+M8cGnYh5ceevUnOZIzJBbXFD6dgf3t',...
%              'Bkb9cvUF/Tkd/iKu2fsg9wAysYKw7RMAsVvIp4KcXle/v1RaXrLVnNBJ',...
%              '2H2DmrbUMOZbQUFXe698qmJsqNpLXRA367xpZ54i8kC5DTXwDhfxWTOZ',...
%              'rBrh5sRKHcoVLumztIQjgWh37AzmSd1bLOfUGI0xjAL9zJWO3fRaeB0N',...
%              'S2KlmoKaVT5Y04zZEc06waU2r6AU2Dc4uipJqJmObqKM+tfNKAS0rZr5',...
%              'IudRiC7pUwnmtaHRe5fgSI8M7yvypvm+13Wm4Gwd4VnYiZvSxf8ImN3Z',...
%              'OG9wEzfyMIlH2+rKPUVHI+igsqla0Wd9m7ZUR9vFotj1uYV0OzG7hX0+',...
%              'huN2E/IdgLDjbiapj1e2fKHrMmGFaIvI6xzzJIQJF9GiRZ7+0jNFLKSy',...
%              'zX/K3JAyFrIPObfwM+y+zAgE1sWcZ1YnuBhICyRHBhaJDKIZL8MywrEf',...
%              'B2yF+R3k9wFG1oN48gSLyfrfEKuB/qgNp+BeTruWUk0AwRE9XVMUuRbj',...
%              'pxa4YA67SKunFEgFGgUfHBeHJTivvUl0u4Dki1UKAT973P+nXy2O0u23',...
%              '9If/kRpNUVhMg8kpk7s8i6Arp7l/705/bLCx4kN5hHHSXIqkiG9tHdeN',...
%              'V8VYo5+72hgaCx3/uVoVLmtvxbOIvo120uTJbuLVTvT8KtsOlb3DxwUr',...
%              'wLzaEMoAQAFk6Q9bNipHxfkRQER4kR7IYTMzSoW5mxh3H9O8Ge5BqVeY',...
%              'MEW36q9wnOYfxOLNw6yQMf8f9sJN4KhZty02xm707S7VEfJJ1KNq7b5p',...
%              'P/3RjE0IKtB2gE6vAPRvRLzEohu0m7q1aUp8wAvSiqjZy7FLaTtLEApX',...
%              'YvLvz6PEJdj4TegCZugj7c8bIOEqLXmloZ6EgVnjQ7/ttys7VFITB3ma',...
%              'zzFiyQuKf4J6+b/a/Y'];
         
        VendorCode = ['DEH1pjR4cEApaAMj+Um4HKziY/CmiU4mSRkQ4OC5iqH1q+0',...
            '3nd306PHLFWfwnxNSWwf6z1Z2ev6NBZ41nQckLRwZxZnkBLAaIPYsDuq9',...
            'm7Ra5GDPAbgKByNpRQfrw8+8Lh7sKoKP5j95DpEsoaFowlo8B55842BSb',...
            'NSBVKPaoiD66oi+zvmX+oLsfdbqLsM8W9KMLiN7wyBYEeOOGYFokBYQsp',...
            'Xp8ZQ/vw7+KEGejRgKbjB4p3NHbDMxWa121LqYvRNYivllbLMjIOXrmsA',...
            'u3xgEy1Veqd4xn/JqIyPFMb8nfFuJnjbSK0E0gDjO/w/EeglnfkwMhhuz',...
            'fOUBgCtv+kmqCd7xXMjgA5PDNjOiexOjP4yb38Zzd854tZJLOuZBeNsrM',...
            'QGj5RGpudv+Jmc9KTnMs9uaprwMX9k1b2HxUJUH/cFV02nJ1caInwjc9U',...
            'egW6J+rNTz58Zt4YWnONwu7mOihHBcNCDUZ7v2ORoMoMtFl9C+NnrC0tF',...
            '/MtfttFEmiuS+OePuIu/Ol2qS8hIjTdxf45zJXo+fliY/NpI5O5WF2JUN',...
            'eyYZJ7lGROsDHSGYwBMAipBzPJEAKauIYfpEEpJkXJDCbiJLMpq+XMb5Y',...
            'fYcqeT5PV3zxBGei7LYYkz+ZZew83ij9t+iQwOfTxxmlHKLaPATpcR5Qh',...
            'Q1UsuRPu3RlGDL06QV/OHNojbCaB329AUMv67KVckcxSjVq07Y9ypYVVC',...
            '3+VKQkEIJaUBBjP64N/D9yJc7EnW5syvUyawqmFXkZVMc9OwYNZGh3feE',...
            'CBFJPPzRhxgGnb3B3yHHsSIL2Z+Z/MHEti7n/CJpre8wiBAOGx5YItd43',...
            'X6X59IBHeeuUAH/KhC7N8kyOjyYBOo1xoNRMpLPee9vZ7lvq/6A6dFwGa',...
            'avTMmdeWt6GwGa8wZtDYNoSAOyGe14zAgqdZBi0HFKIa7yhVsfbiXN/yX',...
            'iJfpTQsLqBwjD7wBz1FITDQ=='];

    end
    
    %% Events
    events

    end
    
    %% Methods - Constructor
    methods      
        
        function obj = SimulationLib( id )
            import Aladdin.*
            
            switch nargin
                case 0
                    obj.FeatureID = 0; 
                case 1
                    obj.FeatureID = id;
            end  

            hasp = Hasp(obj.FeatureID); % hasp = Hasp(Hasp.HASP_DEFAULT_FID);

            version = hasp.getVersion(obj.VendorCode);
            status = version.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    % Do Nothing
                case HaspStatus.HASP_NO_API_DYLIB
                    obj.LastError = MException('License:LogoutMissingHandle', ...
                            'The API dynamic library not found.');
                    %return;
                case HaspStatus.HASP_INV_API_DYLIB
                    obj.LastError = MException('License:APILibrary', ...
                            'The API dynamic library is corrupt.');
                    %return;
                otherwise
                    obj.LastError = MException('License:Unexpected', ...
                            'Unexpected error.');
            end
            
            obj.MajorVersion = version.majorVersion();
            obj.MinorVersion = version.minorVersion();
            obj.BuildNumber  = version.minorVersion();
            obj.HaspObj = hasp;
        
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
            import Aladdin.*
            %**** For Development Mode Only********************************
            if obj.DevelopmentMode
                y = true;
                obj.LastError = MException.empty;
                return;
            end
            %**************************************************************
            obj.HaspObj.login( obj.VendorCode);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_FEATURE_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:FeatureMissing', ...
                            'The feature is not available with this license');
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                case HaspStatus.HASP_OLD_DRIVER
                    y = false;
                    obj.LastError = MException('License:DriverOutOfDate', ...
                            'The license driver version is outdated or no driver installed');
                case HaspStatus.HASP_NO_DRIVER
                    y = false;
                    obj.LastError = MException('License:DriverMissing', ...
                            'The license driver is missing');
                case HaspStatus.HASP_INV_VCODE
                    y = false;
                    obj.LastError = MException('License:VendorCode', ...
                            'The vendor code is invalid.');
                otherwise
                    y = false;
                    obj.LastError = MException('License:LoginFailed', ...
                            'License login failed');  
            end
 
        end % login
        
        function y = logout( obj )
            import Aladdin.*
            %**** For Development Mode Only********************************
            if obj.DevelopmentMode
                y = true;
                obj.LastError = MException.empty;
                return;
            end
            %**************************************************************
            obj.HaspObj.logout();
            status = obj.HaspObj.getLastError();
            
            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = false;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                otherwise
                    y = false;
                    obj.LastError = MException('License:LogoutFailied', ...
                            'Logout failed.');
            end
 
        end % logout
        
        function y = getSessionInfo( obj )
            import Aladdin.*
            infos = obj.HaspObj.getSessionInfo(Hasp.HASP_KEYINFO);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
%                     disp(['OK, Sentinel key attributes retrieved\n\n',...
%                                      'Key info:\n===============\n' , infos ,...
%                                      '\n===============']);
                    y = infos;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = 'handle not active';
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_INV_FORMAT
                    y = 'unrecognized format';
                    obj.LastError = MException('License:UnknownFormat', ...
                            'Unrecognized format');
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = 'Sentinel key not found';
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = 'hasp_get_sessioninfo failed';
                    obj.LastError = MException('License:GetSessionInfoFailied', ...
                            'getSessionInfo failed.');
            end
        
 
        end % getSessionInfo
        
        function y = getSize( obj )
            import Aladdin.*
     
            fsize = obj.HaspObj.getSize(Hasp.HASP_FILEID_RW);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = fsize;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = 0;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_INV_FILEID
                    y = 0;
                    obj.LastError = MException('License:InvalidFID', ...
                            'Invalid file id');
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = 0;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = 0;
                    obj.LastError = MException('License:UnkownError', ...
                            'Could not retrieve memory size'.');
            end
 
        end % getSize
        
        function y = readMemory( obj )
            import Aladdin.*
            import java.lang.*  %java.lang.Byte
 
            fsize = obj.HaspObj.getSize( obj );
            if fsize == 0; y = []; return; end;
            membuffer = byte(fsize);
            obj.HaspObj.read(Hasp.HASP_FILEID_RW, 0, membuffer);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = membuffer;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = [];
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_INV_FILEID
                    y = [];
                    obj.LastError = MException('License:InvalidFID', ...
                            'Invalid file id');
                case HaspStatus.HASP_MEM_RANGE
                    y = [];
                    obj.LastError = MException('License:OutOfMemoryRange', ...
                            'Beyond memory range of attached license key'.');     
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = [];
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = [];
                    obj.LastError = MException('License:UnkownError', ...
                            'Read memory failed'.');
            end
        end % readMemory
        
        function y = writeMemory( obj , membuffer )
            import Aladdin.*
            import java.lang.*  %java.lang.Byte
 

            obj.HaspObj.write(Hasp.HASP_FILEID_RW, 0, membuffer);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = false;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_INV_FILEID
                    y = false;
                    obj.LastError = MException('License:InvalidFID', ...
                            'Invalid file id');
                case HaspStatus.HASP_MEM_RANGE
                    y = false;
                    obj.LastError = MException('License:OutOfMemoryRange', ...
                            'Beyond memory range of attached license key'.');     
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = false;
                    obj.LastError = MException('License:UnkownError', ...
                            'Read memory failed'.');
            end
        end % writeMemory
        
        function y = encryptData( obj , data )
            import Aladdin.*
            import java.lang.*  %java.lang.Byte

            obj.HaspObj.encrypt(data);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = false;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_TOO_SHORT
                    y = false;
                    obj.LastError = MException('License:DataShort', ...
                            'Data length is to short. The minimum length is 16 bytes.');
                case HaspStatus.HASP_ENC_NOT_SUPP
                    y = false;
                    obj.LastError = MException('License:KeySupport', ...
                            'The attached license key does not support AES encryption'.');     
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = false;
                    obj.LastError = MException('License:UnkownError', ...
                            'Read memory failed'.');
            end
        end % encryptData
        
        function y = decryptData( obj , data )
            import Aladdin.*
            import java.lang.*  %java.lang.Byte

            obj.HaspObj.decrypt(data);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = false;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_TOO_SHORT
                    y = false;
                    obj.LastError = MException('License:DataShort', ...
                            'Data length is to short. The minimum length is 16 bytes.');
                case HaspStatus.HASP_ENC_NOT_SUPP
                    y = false;
                    obj.LastError = MException('License:KeySupport', ...
                            'The attached license key does not support AES encryption'.');     
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = false;
                    obj.LastError = MException('License:UnkownError', ...
                            'Read memory failed'.');
            end
        end % decryptData
        
        function y = getCurrentTime( obj )
            import Aladdin.*
            import java.lang.*  %java.lang.Byte
            %**** For Development Mode Only********************************
            if obj.DevelopmentMode
                y = datetime;
                obj.LastError = MException.empty;
                return;
            end
            %**************************************************************

            currdatetime = obj.HaspObj.getRealTimeClock();
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    hour  = currdatetime.getHour();
                    min   = currdatetime.getMinute();
                    sec   = currdatetime.getSecond();
                    day   = currdatetime.getDay();
                    month = currdatetime.getMonth();
                    year  = currdatetime.getYear();
                    y = datetime(year,month,day,hour,min,sec);
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_TIME
                    y = datetime.empty;
                    obj.LastError = MException('License:Time', ...
                            'Time value outside of supported range.');   
                case HaspStatus.HASP_INV_HND
                    y = datetime.empty;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_NO_TIME
                    y = datetime.empty;
                    obj.LastError = MException('License:KeySupport', ...
                            'The attached license key does not support time'.');     
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = datetime.empty;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = datetime.empty;
                    obj.LastError = MException('License:UnkownError', ...
                            'Read memory failed'.');
            end
        end % getCurrentTime
        
        function y = getInfo( obj )
            import Aladdin.*
            scope =  '<haspscope />\n';
            view = ['<haspformat root=\"my_custom_scope\">\n',...
                      '  <hasp>\n',...
                      '    <attribute name=\"id\" />\n',...
                      '    <attribute name=\"type\" />\n',...
                      '    <feature>\n',...
                      '      <attribute name=\"id\" />\n',...
                      '      <element name=\"concurrency\" />\n',...
                      '      <element name=\"license\" />\n',...
                      '      <session>\n',...
                      '        <element name=\"username\" />\n',...
                      '        <element name=\"hostname\" />\n',...
                      '        <element name=\"ip\" />\n',...
                      '        <element name=\"apiversion\" />\n',...
                      '      </session>\n',...
                      '    </feature>\n',...
                      '  </hasp>\n',...
                      '</haspformat>\n'];
            infos = obj.HaspObj.getInfo( scope , view ,obj.VendorCode );
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = infos;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_FORMAT
                    y = 'unrecognized format';
                    obj.LastError = MException('License:UnknownFormat', ...
                            'Unrecognized format');
                case HaspStatus.HASP_INV_FORMAT
                    y = 'Invalid XML info format';
                    obj.LastError = MException('License:InvalidInfoFormat', ...
                            'Format invalid.');
                otherwise
                    y = 'hasp_get_info failed';
                    obj.LastError = MException('License:GetInfoFailied', ...
                            'getInfo failed.');
            end
 
        end % getInfo
        
        function y = checkKeyStatus( obj )
            import Aladdin.*
            if obj.DevelopmentMode
                y = true;
                return;
            end
            obj.HaspObj.getSessionInfo(Hasp.HASP_KEYINFO);
            status = obj.HaspObj.getLastError();

            switch status
                case HaspStatus.HASP_STATUS_OK
                    y = true;
                    obj.LastError = MException.empty;
                case HaspStatus.HASP_INV_HND
                    y = false;
                    obj.LastError = MException('License:MissingHandle', ...
                            'The handle is not active');
                case HaspStatus.HASP_INV_FORMAT
                    y = false;
                    obj.LastError = MException('License:UnknownFormat', ...
                            'Unrecognized format');
                case HaspStatus.HASP_HASP_NOT_FOUND
                    y = false;
                    obj.LastError = MException('License:KeyMissing', ...
                            'The license key is missing.');
                otherwise
                    y = false;
                    obj.LastError = MException('License:GetSessionInfoFailied', ...
                            'getSessionInfo failed.');
            end
        
        end % checkKeyStatus
        
    end % Ordinary Methods
    
    %% Methods - Protected Update Methods
    methods (Access = protected)   
        

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

