function d = loadLSdata(fileName,speedCutoff)

if(nargin < 2)
    speedCutoff = 5; %in m/s
end


wgs84   = almanac('earth','wgs84','km'); %get earth's ellipsoid
wgs84(1)= wgs84(1)*1000; %convert to m so our distances and areas are in m

f = importdata(fileName);
d.header = f.textdata(1,4:end);
d.dates = datenum(f.textdata(2:end,1),'yyyy-mm-dd HH:MM:SS');

d.data = f.data(:,3:end);
d.lat = f.data(:,1);
d.lon = f.data(:,2);
d.elev = f.data(:,3);


distVec = distance(d.lat(1:end-1),d.lon(1:end-1),d.lat(2:end),d.lon(2:end),wgs84);
distVec = cumsum(vertcat(0,distVec));
d.dist = distVec;

indx = logical(vertcat(0,diff(d.dist) > speedCutoff)); %drop data with velocity < speedCutoff
indx(1:30) = 0; %drop at *least* the first 30 seconds.

d.dist = d.dist(indx);
d.lat = d.lat(indx);
d.lon = d.lon(indx);
d.data = d.data(indx,:);
d.dates = d.dates(indx);


end