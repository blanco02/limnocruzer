d = loadLSdata('run2.csv');
d = loadLSdata('nwBloomArea.csv');
d = loadLSdata('noname2011-07-13040530.csv');
d = loadLSdata('HighLowSpeed/highSpeed.csv');
d = loadLSdata('HighLowSpeed/lowSpeed.csv',0);
load mendotaShape.mat;



lon = d.lon;
lat = d.lat;
dist = d.dist;

%[ll, I] = sortrows([lat lon],[1 2]);
%lat = ll(:,1);
%lon = ll(:,2);
data = d.data(:,7);
%data = data(I,:);

if(any(data <= 0))
    data = data + abs(min(data))+0.00001;
end
data = log(data);

[xi,yi] = meshgrid(lon,lat);

%% jordan's code:

figure;
subplot(2,1,2);

resLat = 0.0001;
XI = min(lon):resLat:max(lon);
YI = linspace(min(lat),max(lat),length(XI));

[zgrid,longrid,latgrid] = gridfit(lon,lat,data,XI,YI,'smoothness',.2);

inLake = inpoly([longrid(:) latgrid(:)],[mendota.X(1:end-1)' mendota.Y(1:end-1)']);

zgrid(~inLake) = NaN;%nan values outside of the lake

cont = contourm(latgrid,longrid,zgrid,[-2:.05:3.6],'LineWidth',2,'LineStyle','none','fill','on');
hold on;
plot(d.lon(indx),d.lat(indx),'.k','markersize',4);
hold on;
plot(mendota.X,mendota.Y,'-k','LineWidth',2);

%--- end jordan's code ---

[xi,yi,zi]=griddata(lon,lat,data,xi,yi);
contourf(xi,yi,zi,30,'LineStyle','none');
colorbar();
title('Chlorophyll');

hold on;
plot(d.lon(indx),d.lat(indx),'-k','LineWidth',2);



exLats = [min(min(yi)) max(max(yi))];
exLons = [min(min(xi)) max(max(xi))];

subplot(2,1,1);
plot(mendota.X,mendota.Y,'k');
hold on;
plot(lon,lat,'.','MarkerSize',4);
%rectangle('Position',[exLons(1) exLats(1) abs(exLons(2)-exLons(1)) abs(exLats(2)-exLats(1))],'FaceColor','k')


%% New Try with colored dots
fsize = 18;

clevels = 20;
cm = jet(clevels);

[~,bins] = hist(data,clevels);
width = median(diff(bins));


bottoms = bins - width/2;
bottoms(1) = bottoms(1) - 0.00001;
tops = bins + width/2;
tops(end) = tops(end)+0.0001;

figure;
ax(1) = axes('outerposition',[0 0.5 .925 .5],'fontsize',fsize-6);
plot(mendota.X,mendota.Y,'k');
hold(ax(1),'on');
ax(2) = axes('outerposition',[0 0 .925 .5],'fontsize',fsize-6);
hold(ax(2),'on');

for i=1:length(data)
    level = data(i) <= tops & data(i) > bottoms;
    if(sum(level) > 1)
        tmp = false(size(level));
        tmp(find(level,1)) = true;
        level = tmp;
    end
    
    plot(ax(1),lon(i),lat(i),'.','MarkerFaceColor',cm(level,:),'MarkerEdgeColor',cm(level,:));
    plot(ax(2),dist(i),data(i),'.','MarkerFaceColor',cm(level,:),'MarkerEdgeColor',cm(level,:));
    %pause(0.05);
end
ax(3) = axes('position',[0 0 1 1],'visible','off');
c = colorbar('peer',ax(3),[0.875 0.0768 0.0333333333333333 0.8837],'fontsize',fsize-6);


xlabel(ax(2),'Distance (m)','fontsize',fsize);
ylabel(ax(2),'Chlorophyll Fluorescence (RFU)','fontsize',fsize);
xlabel(ax(1),'Longitude (deg)','fontsize',fsize);
ylabel(ax(1),'Lattitude (deg)','fontsize',fsize);
set(get(c,'Ylabel'),'string','Chlorophyll Fluorescence (RFU)');
set(get(c,'Ylabel'),'fontsize',fsize);








