classdef GPSReceiver < handle
    %GPSReceiver Object handling interaction with a serial connected GPS
    %unit
    %   Detailed explanation goes here
    properties
        status = 'unseen';
        lat;
        lon;
        elevation;
        lastUpdate;
        datetime;
    end
    
    properties(Access=private)
        comport;
    end
    properties(Access=protected)

    end
    
    methods
        function obj = GPSReceiver(port)
            disp('Connecting to GPS receiver');
            obj.comport = serial(port,'BaudRate',4800);
            obj.comport.BytesAvailableFcnMode = 'terminator'; %I'll be back!
            
            function newData(~,~)
                obj.handleNewBytes();
            end
            
            obj.comport.BytesAvailableFcn = @newData;
            fopen(obj.comport);
            disp('GPS Receiver connected!');
        end
        function delete(obj)
            disp('Cleaning up GPS receiver connection.');
            fclose(obj.comport);
        end
        
    end
    
    methods(Access=private)
        function handleNewBytes(obj)
            tmp = fscanf(obj.comport);
            if(length(tmp) < 7)
                obj.status = 'sentence less than 7 chars';
                return;
            end
            
            switch tmp(1:6)
                case {'$GPGSA','$GPGSV'}
                    %do nothing
                case '$GPRMC'
                    %Just grab current date/time from this
                    tmp = regexp(tmp,',','split');
                    obj.datetime = datenum(strcat(tmp{10},'T',tmp{2}),'ddmmyyTHHMMSS.FFF');
                case '$GPGGA'
                    %parse for status/lat/lon/elevation
                    tmp = regexp(tmp,',','split');
                    
                    if(length(tmp) < 11)
                        obj.status = 'sentence error';
                        return;
                    end
                    
                    if(strcmp(tmp(7),'1'))
                        latstr = tmp{3};
                        lonstr = tmp{5};
                        obj.lat = str2double(latstr(1:2)) + str2double(latstr(3:end))/60;
                        obj.lon = str2double(lonstr(1:3)) + str2double(lonstr(4:end))/60;
                        obj.elevation = str2double(tmp{10});
                        
                        if(strcmp(tmp{4},'S'))
                            obj.lat = obj.lat * -1;
                        end
                        if(strcmp(tmp{6},'W'))
                            obj.lon = obj.lon * -1;
                        end
                        obj.lastUpdate = now;
                        obj.status = 'good';
                        
                    else
                        obj.status = 'no gps lock';
                    end
                    
                otherwise
                    obj.status = 'unrecognised sentence';
            end
        end
    end
    
    
end

