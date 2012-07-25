classdef fakeGpsReceiver < handle
    %GPSReceiver Object handling interaction with a serial connected GPS
    %unit
    %   Detailed explanation goes here
    properties
        status = 'unseen';
        elevation;
        lat;
        lon;
        lastUpdate;
        datetime;
        
    end
    
    properties(Access=private)
        comport;
        indx = 1;
        d;
    end
    properties(Access=protected)

    end
    
    methods
        
        function lat = get.lat(obj)
            lat = obj.d.lat(obj.indx);
        end
        
        function lon = get.lon(obj)
            lon = obj.d.lon(obj.indx);
        end
        
        function elevation = get.elevation(obj)
            elevation = obj.d.elev(obj.indx);
            obj.indx = obj.indx + 1;
        end
        
        function datetime = get.datetime(obj)
            datetime = obj.d.dates(obj.indx);
        end
        
        function obj = fakeGpsReceiver(port)
            disp('Connecting to GPS receiver');
            obj.d = loadLSdata('exampleGPS.csv',0);
            disp('GPS Receiver connected!');
        end
        function delete(obj)
            disp('Cleaning up GPS receiver connection.');
            %fclose(obj.comport);
        end
        
    end
    
    
    
end

