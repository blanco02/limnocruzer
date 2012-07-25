classdef HydrolabSonde < handle
    %YSISONDE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetObservable)
        lastRetrieved;
    end
    
    properties
        temp;
        cond;
        ph=NaN;
        orp=NaN;
        turbid=NaN;
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
        function obj = HydrolabSonde(port)
            disp('Connecting to and configuring sonde, please wait....');
            obj.comport = serial(port,'BaudRate',19200);
            obj.comport.Terminator = 'LF';
            obj.comport.BytesAvailableFcnMode = 'terminator'; %I'll be back!
            obj.comport.BytesAvailableFcn = @newData;
            
            function newData(~,~)
                obj.handleNewBytes();
            end
            
            
            fopen(obj.comport);
            disp('Sonde connected and collecting data....');
            
        end
        function delete(obj)
            disp('Please wait as the sonde is shut down.');
%             fprintf(obj.comport,'%s',obj.esc);
%             pause(1);
%             fprintf(obj.comport,'%s',obj.esc);
%             pause(1);
%             fprintf(obj.comport,'%s',obj.esc);
%             pause(1);
%             fprintf(obj.comport,'%s',obj.esc);
%             pause(1);
%             fprintf(obj.comport,'%s','y');
%             pause(1);
            fclose(obj.comport);
            delete(obj.comport);
            pause(1);
            disp('Sonde shutdown and successfully disconnected.');
        end
    end
    
    methods(Access=private)
        function handleNewBytes(obj)
            tmp = fscanf(obj.comport);
            
            vals = regexp(tmp,'(?<time>\d+)\s+(?<wtr>\d+\.\d+)\s+(?<dosat>\d+\.\d+)\s+(?<doobs>\d+\.\d+)\s+(?<volts>\d+\.\d+)\s+(?<phyco>\d+\.\d+)\s+(?<chloro>\d+\.\d+)\s+(?<cond>\d+\.\d+)\s+','names');
            
            %vals = regexp(tmp,[char(27) '[\d+?;10H (?<wtr>\d+\.\d+) \s*' char(27) '[\d+?;17H\s*(?<dosat>\d*?\.\d*)\s*' char(27) '[\d+?;25H\s*(?<doobs>\d*?\.\d*)\s*' char(27) '[\d+?;33H\s*(?<volts>\d*?\.\d*)\s*' char(27) '[\d+?;40H\s*(?<phyco>\d*?\.\d*)\s*' char(27) '[\d+?;49H\s*(?<chloro>\d*?\.\d*)\s*' char(27) '[\d+?;58H\s*(?<cond>\d*?\.\d*)'],'names');
            
            if(isempty(vals)) %If response, didn't contain droids we're looking for
                return;
            end
            
            
            %If we're here, found the droids we're looking for
            obj.temp = str2double(vals.wtr);
            obj.cond = str2double(vals.cond);
            obj.chla = str2double(vals.chloro);
            obj.phyco = str2double(vals.phyco);
            obj.dosat = str2double(vals.dosat);
            obj.doobs = str2double(vals.doobs);
            
            obj.lastRetrieved = now;
            
        end
        
        
    end
    
end

