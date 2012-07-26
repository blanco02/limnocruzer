function start(outFile)
%START Begin collectiong LimnoCruizer data.
%   USAGE:
%       start() connects to sonde and GPS and begins logging. It creates a
%       default output file in the local directory based on the current
%       date/time with the format 'nonameyyyy-mm-ddHHMMSS.csv'.
%
%       start(outFile) allows the user to specify the output file name and
%       location. The string passed must be a valid relative or absolute
%       file path and name. The file must either not exist or be writeable.
%       Data are appended if the file exists. 
%


if(nargin < 1)
    outFile = ['data/noname' datestr(now,'yyyy-mm-ddHHMMSS') '.csv'];
    %Create the ouptut data directory if it doesn't exist.
    if(~exist('data','dir'))
        mkdir('data');
    end
end

% we'll use this to persist data and handles through the run.
global c;

config = IniConfig();
config.ReadFile('local.ini'); %local.ini must exist

try
    
    %Use our fake GPS receiver if we're testing and inside. 
    if (strcmpi(config.GetValues('gps','testing'),'true'))
        c.gps = fakeGpsReceiver(config.GetValues('gps','port'));
    else
        c.gps = GPSReceiver(config.GetValues('gps','port'));
    end
    
    
    if (strcmpi(config.GetValues('sonde','type'),'hydrolab'))
        c.sonde = HydrolabSonde(config.GetValues('sonde','port'));
    elseif (strcmpi(config.GetValues('sonde','type'),'ysi') );
        c.sonde = YSISonde(config.GetValues('sonde','port'));
    else
        error('Sonde type options are [ YSI | Hydrolab ]. Please check your local.ini file');
    end
    
    c.outfile = fopen(outFile,'A');
    c.data = nan(1e5,13); %1e5 at 1sec is 27 hours. *Plenty* of time.
    c.count = 0;

    %Prep the shape of mendota. This of course doesn't have to be mendota
    load mendotaShape.mat;
    c.shape = [mendota.Y' mendota.X'];

    %print the header
    fprintf(c.outfile,'datetime,lat,lon,elev,wtr,cond,ph,orp,turbidity,chla,phyco,doobs,dosat\n');

    addlistener(c.sonde,'lastRetrieved','PostSet',@newData);
catch e
    %If we get an exception somewhere here, make sure to stop properly
    stop();
    rethrow(e);
end

end



function newData(~,~)
%Handles new data arriving from the sonde. Sonde data controls the rate of
%data output to file as well as figure updates.

    global c;
    global p;
    disp([num2str(c.gps.lat) ',' num2str(c.gps.lon)]);
    disp(['chla:' num2str(c.sonde.chla)]);

    g = c.gps;
    s = c.sonde;
    c.count = c.count+1;

    d = [g.datetime g.lat g.lon g.elevation s.temp s.cond s.ph s.orp s.turbid s.chla s.phyco s.doobs s.dosat];
    %keep array of data for plotting use. 
    c.data(c.count,:) = d;

    fprintf(c.outfile,'%s,%3.10g,%3.10g,%6.5g,%3.10g,%7.7g,%7.7g,%7.7g,%7.7g,%7.7g,%7.7g,%7.7g,%7.7g\n' ...
        ,datestr(d(1),'yyyy-mm-dd HH:MM:SS'),d(2:end));

    if(isempty(p))
        %Grab screen size so we know how big to make the figures
        screenSize = get(0,'screensize');
        screenW = screenSize(3);
        screenH = screenSize(4);
        
        %This is the lake shape and map figure
        p.mapF = figure('units','pixels','outerposition',[1 0.5*screenH screenW 0.5*screenH]);
        plot(c.shape(:,2),c.shape(:,1),'k');
        hold on;
        p.route = plot(c.data(:,3),c.data(:,2),'b','linewidth',3);
        hold off;

        p.data1F = figure('units','pixels','outerposition',[1 1 0.5*screenW 0.5*screenH]);
        p.fluoro = plot(c.data(:,1),c.data(:,11),'b');
        title('Phyco');


        p.data2F = figure('units','pixels'); %Wait to set screen position, some bug screws it up if here
        set(p.data2F,'outerposition',[0.5*screenW 1 0.5*screenW 0.5*screenH]);
        p.wtrDo = plot(c.data(:,1),c.data(:,5),'r',c.data(:,1),c.data(:,13),'g');
        title('DOsat');


    else
        set(p.route,'xdata',c.data(:,3),'ydata',c.data(:,2));
        set(p.fluoro,'xdata',c.data(:,1)','ydata',c.data(:,11)');
        set(p.wtrDo,'xdata',c.data(1:c.count,1)','ydata',c.data(1:c.count,13)');
        %set(p.wtrDo,'xdata',{c.data(:,1) c.data(:,1)}','ydata',{c.data(:,5) c.data(:,13)}');
    end


end