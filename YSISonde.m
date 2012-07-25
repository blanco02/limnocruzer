classdef YSISonde < handle
    %YSISONDE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetObservable)
        lastRetrieved;
    end
    
    properties
        temp;
        cond;
        ph;
        orp;
        turbid;
        chla;
        phyco;
        doobs;
        dosat;
    end
    properties(Access=private)
        comport;
        crlf = [char(13) char(10)];
        esc = char(27);
    end
    methods
        function obj = YSISonde(port)
            disp('Connecting to and configuring sonde, please wait....');
            obj.comport = serial(port,'BaudRate',9800);
            obj.comport.Terminator = 'LF';
            obj.comport.BytesAvailableFcnMode = 'terminator'; %I'll be back!
            obj.comport.BytesAvailableFcn = @newData;
            
            function newData(~,~)
                obj.handleNewBytes();
            end
            
            
            fopen(obj.comport);
            disp('Connection made, setting up for discrete sampling');
            pause(1);
            %wake up the sonde, wake up!!!!
            %Takes a few tries, just like me sometimes
            fprintf(obj.comport,'%s\r\n','wake up!!!');
            pause(1);
            fprintf(obj.comport,'%s\r\n','wake up!!!');
            pause(1);
            fprintf(obj.comport,'%s\r\n','wake up!!!');
            pause(0.5);
            
            fprintf(obj.comport,'%s\r\n','menu');
            pause(1);
            %if we haven't gotten any response yet, the sonde is not there
            if(obj.comport.BytesAvailable < 2)
                error('Can not communicate with YSI sonde, check port settings and connection');
            end
            disp('Sonde menu found, setting sampling interval and starting....');
            fprintf(obj.comport,'%s','1');
            pause(2);
            fprintf(obj.comport,'%s','1');
            pause(2);
            fprintf(obj.comport,'%s','2');%set sample rate interval setting
            pause(1);
            fprintf(obj.comport,'%s\r\n','2');%Set sample rate to 2 seconds
            pause(1);
            fprintf(obj.comport,'%s','1');
            pause(5);
            
        end
        function delete(obj)
            disp('Please wait as the sonde is shut down.');
            fprintf(obj.comport,'%s',obj.esc);
            pause(1);
            fprintf(obj.comport,'%s',obj.esc);
            pause(1);
            fprintf(obj.comport,'%s',obj.esc);
            pause(1);
            fprintf(obj.comport,'%s',obj.esc);
            pause(1);
            fprintf(obj.comport,'%s','y');
            pause(1);
            fclose(obj.comport);
            disp('Sonde shutdown and successfully disconnected.');
        end
    end
    
    methods(Access=private)
        function handleNewBytes(obj)
            tmp = fscanf(obj.comport);
            
            vals = regexp(tmp,' *','split');
            
            try
                if(isempty(vals{1}))
                   return; %empty string is also invalid 
                end
                %try parsing
                datenum(vals{1},'dd/mm/yyyy');
            catch e
                %if not valid date stamp, then it must be one of those
                %other messages we can ignore.
                return;
            end
            
            %grab all the values from the serial string
            obj.temp = str2double(vals{3});
            obj.cond = str2double(vals{4});
            obj.ph = str2double(vals{7});
            obj.orp = str2double(vals{8});
            obj.turbid = str2double(vals{9});
            obj.chla = str2double(vals{10});
            obj.phyco = str2double(vals{11});
            obj.dosat = str2double(vals{12});
            obj.doobs = str2double(vals{13});
            
            obj.lastRetrieved = now;
            
        end
        
        
    end
    
end

