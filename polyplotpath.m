function polyplotpath(fname,fdir,thresh,rin)
% POLYPLOTPATH(fname,fdir,thresh,rin)
%
% Making sense of Polynesia under M25
%
% INPUT:
%
% fname    Filename string
% fdir     Directory string
% thresh   Threshold level
% rin      A plot name index
%
% EXAMPLE:
%
% polyplotpath('40_100#surface_wave.sel','/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA')
% polyplotpath('40_100#body_wave.sel',[],[],2)
% polyplotpath('17_40.sel',[],[],3)
% polyplotpath('90_250.sel',[],[],4)
%
% Last modified by fjsimons-at-alum.mit.edu, 11/19/2024

% Prepare the files to only return number (could work with event/station code)
%       1         2    3    4        5          6               7       8        
% event_lat event_lon slat slon EPIC_DIST rtive_starttime rtive_endtime tau(in s)
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 40_100#surface_wave.dat > 40_100#surface_wave.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 40_100#body_wave.dat > 40_100#body_wave.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 17_40.dat > 17_40.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 90_250.dat > 90_250.sel

defval('fname','40_100#surface_wave.sel')
defval('fdir','/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA')
defval('fpath',sprintf('%s.mat',pref(fname)))

% Threshold level
defval('thresh',0.005);

% Identify the domain, roughly
domxy=[172.2598  304.0478  -74.6030   35.1871];

if exist(fullfile(fdir,fpath))==2 
    load(fullfile(fdir,fpath))
else
    % Load the coordinates
    paths=load(fullfile(fdir,fname));
    % Parse the coordinates
    elat=paths(:,1);
    elon=paths(:,2); elon=elon+(elon<0)*360;
    slat=paths(:,3);
    slon=paths(:,4); slon=slon+(slon<0)*360;
    grcd=paths(:,5);
    % The travel time is taken to be the center time of the window
    T   =paths(:,6)+[paths(:,7)-paths(:,6)]/2;
    dT  =paths(:,8);
    % Try to figure out what the unique paths are
    hashs='SHA-1'; hashl=40; 
    zhash=nan(length(elon),hashl);
    for index=1:length(elon)
        % Same event and same station thus same grcd will be a unique path with multiple windows
        zhash(index,:)=hash([elat(index) elon(index) slat(index) slon(index) grcd(index)],hashs);
    end
    % Now decide what to do with the paths... here is the unique path running number
    upath=cumsum([1 ; ~~sum(abs(diff(zhash,1)),2)]);
    % And this is the order to pick out for the unique coordinates
    [uup,ui]=unique(upath);
    % Now figure out a rule to summarize the results, rather, many rules
    [~,zstat]=row2stats(upath,dT./T);
    % This better check out
    if length(zstat.mean)-length(uup) ; error ; end
    % Just save the unique paths
    elat=elat(ui);  elon=elon(ui);
    slat=slat(ui);  slon=slon(ui);
    grcd=grcd(ui);
    % Calculate all the unique great circle paths and save the results
    N=100;
    lolagc=nan(N,2,length(elon));
    zdelta=nan(length(elon),1);
    for index=1:length(elon)
        [lolagc(:,:,index),delta]=grcircle([elon(index) elat(index)]*pi/180,...
                                           [slon(index) slat(index)]*pi/180,N);
        zdelta(index)=delta(end)*180/pi;
    end
    % Could pare this down even further and just save the unique stations and events
    % with another hash
    
    % But must do that in pairs, not individually; maybe save the data as well
    save(fullfile(fdir,fpath),'lolagc','zdelta','zstat','elat','elon','slat','slon','grcd')
end

% Decide on what property to actually plot, e.g., zstat.mean or zstat.median
zprops=zstat.median;

% Will plot all the paths in order of absolute value of the property being rendered
[~,zi]=sort(abs(zprops));
% We do retain the sign of the properties, but they are sorted by absolute value
zprops=zprops(zi);
% Convert to degrees
lolagc=lolagc(:,:,zi)*180/pi;
% Pick out the right ones
zindex=1:length(zprops);
% Red for negative and blue for positive and grey for uninteresting
gindex=zindex(abs(zprops)<thresh);
bindex=zindex(zprops>=thresh);
rindex=zindex(zprops<=-thresh);

% Checks and balances
if sum(sort([gindex bindex rindex])-zindex); error('Something does not add up'); end
% Prepare path handles
pg=nan(length(gindex),1);
pb=nan(length(bindex),1);
pr=nan(length(rindex),1);
if length(pg)+length(pb)+length(pr)-length(zprops); error('Something does not add up'); end

% Make a scaled color version?
kcol=kelicol;
% If you want a simple red and blue
% kcol=[1 0  0 ; 0 0 1];
% Where you begin the actual coloring in absolute value
lk=size(kcol,1);
ack=round(4*lk/5);
% If you want a simple red and blue
% ack=lk;

clf
ah(1)=subplot(121);
% Plot the paths
plotplates
hold on
% Uninteresting gray paths
%for index=1:length(gindex)
%    gi=gindex(index);
%    pg(index)=plot(lolagc(:,1,gi),lolagc(:,2,gi),'Color',grey);
%end
% Interesting blue paths (positive anomalies)
for index=1:length(bindex)
    % The index into the properties map
    bi=bindex(index);
    % The index into the color map
    ci=kindeks(round(scale([thresh zprops(bi) max(zprops)],[ack lk])),2);
    pb(index)=plot(lolagc(:,1,bi),lolagc(:,2,bi),'Color',kcol(ci,:));
end
% Interesting red paths (negative anomalies)
for index=1:length(rindex)
    % The index into the properties map
    ri=rindex(index);
    % The index into the color map
    ci=kindeks(1+lk-round(scale([thresh abs(zprops(ri)) abs(min(zprops))],[ack lk])),2);
    pr(index)=plot(lolagc(:,1,ri),lolagc(:,2,ri),'Color',kcol(ci,:));
end
% Plot events and stations on map
p1=plot(elon,elat,'v','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',2);
p2=plot(slon,slat,'^','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',1);
hold off
axis equal
axis(domxy)
box on
longticks(gca,2)
xlabel('longitude')
ylabel('latitude')

% Later plot on sphere etc
ah(2)=subplot(122);
nbar=6;
% Percentiles or multiples of the threshold?
lfe=min(prctile(zprops,3),-3*thresh);
rge=max(prctile(zprops,97),3*thresh);

[ng,eg]=histcounts(zprops(gindex),unique([linspace(-thresh,0,nbar) linspace(0,thresh,nbar)]));
gc=eg(1)+[eg(2)-eg(1)]/2:[eg(2)-eg(1)]:eg(end);

[nb,eb]=histcounts(zprops(bindex),thresh:[eg(2)-eg(1)]:rge);
bc=eb(1)+[eb(2)-eb(1)]/2:[eb(2)-eb(1)]:eb(end);

[nr,er]=histcounts(zprops(rindex),sort(-thresh:-[eg(2)-eg(1)]:lfe));
rc=er(1)+[er(2)-er(1)]/2:[er(2)-er(1)]:er(end);

gb=bar(gc*100,ng,1,'FaceColor',grey);
hold on
bb=bar(bc*100,nb,1,'FaceColor','b');
rb=bar(rc*100,nr,1,'FaceColor','r');
hold off

%set(gca,'xtick',unique(100*[-thresh thresh 0 prctile(zprops,[5 25 75 95])]))
wowx=100*([-2:2]*thresh);
xlim(minmax(wowx))
xlim([lfe rge]*100)
% Or else
% wowx=100*([-3:3]*thresh);
% xlim(minmax(wowx))
set(gca,'xtick',wowx)
shrink(gca,1,2.5)
longticks(gca,2)
grid on
xlabel('relative travel-time anomaly \Delta T/T (%)')

% All
% [na,ea]=histcounts(zprops,unique([eb er eg]));
% ac=ea(1)+[ea(2)-ea(1)]/2:[ea(2)-ea(1)]:ea(end);
% ab=bar(ac*100,na,1,'FaceColor','w')

st=supertit(ah,pref(nounder(fname)));

defval('rin',1)
figdisp(mfilename,rin,'-r600',2)
