function polyplotpath(fname,fdir,thresh,rin,ifscale,nogrey,prox)
% POLYPLOTPATH(fname,fdir,thresh,rin,ifscale,nogrey,prox)
%
% Making sense of Polynesia under M25 by plotting anomalous paths
%
% INPUT:
%
% fname     Filename string
% fdir      Directory string
% thresh    Threshold level
% rin       A plot name index
% ifscale   1 uses a scaled colorbar
%           0 uses simple red and blue
% nogrey    1 do not plot the middle (grey) paths
%           0 do plot the middle (grey) paths
% prox      1 take the mean across windows and components
%           2 take the median across windows and components
%
% EXAMPLE:
%
% polyplotpath('40_100#surface_wave.sel','/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA',0.005,1,1,1,1)
% polyplotpath('40_100#body_wave.sel',[],[],2,[],[],1)
% polyplotpath('17_40.sel',[],[],3,[],[],1)
% polyplotpath('90_250.sel',[],[],4,[],[],1)
%
% Last modified by fjsimons-at-alum.mit.edu, 11/26/2024

% Prepare the files to only return numbers (could work with event/station code)
%       1         2    3    4        5          6               7       8        
% event_lat event_lon slat slon EPIC_DIST rtive_starttime rtive_endtime tau(in s)
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 40_100#surface_wave.dat > 40_100#surface_wave.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 40_100#body_wave.dat > 40_100#body_wave.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 17_40.dat > 17_40.sel
% awk 'NR>1 && $24==1 {printf "%7s %7s %7s %7s %7s %8s %8s %6s\n",$2,$3,$6,$7,$8,$9,$10,$11}' 90_250.dat > 90_250.sel

defval('fname','40_100#surface_wave.sel')
defval('fdir','/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA')
% Threshold level
defval('thresh',0.005);
% The plot index
defval('rin',1)
% Color control
defval('ifscale',1)
defval('nogrey',1)
% Which statistic
defval('prox',1)
% The saved file for later reloading
fsave=fullfile(fdir,sprintf('%s.mat',pref(fname)));

% Identify the domain, roughly
domxy=[172.2598  304.0478  -74.6030   35.1871];

% Load if you have it, make and save if you don't
if exist(fsave)==2 
    load(fsave)
else
    % Load the coordinates
    paths=load(fullfile(fdir,fname));
    % Parse the event coordinates
    elat=paths(:,1);
    elon=paths(:,2); elon=elon+(elon<0)*360;
    % Parse the station coordinates
    slat=paths(:,3);
    slon=paths(:,4); slon=slon+(slon<0)*360;
    % Pars the great-circle distances
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
    save(fsave,'lolagc','zdelta','zstat','elat','elon','slat','slon','grcd')
end

% Decide on what property to actually plot, e.g., zstat.mean or zstat.median
switch prox
  case 1
    zprops=zstat.mean;
    zprox='mean';
  case 2
    zprops=zstat.median;
    zprox='median';
end

% Will plot all the paths in order of absolute value of the property being rendered
[~,zi]=sort(abs(zprops));
% We do retain the sign of the properties, but they are sorted by absolute value
zprops=zprops(zi);
% So now THAT is the sort order... sequentially, no need to save zi
zindex=1:length(zprops);
% Convert to degrees
lolagc=lolagc(:,:,zi)*180/pi;
% Red for negative and blue for positive and grey for uninteresting
gindex=zindex(abs(zprops)<thresh);
bindex=zindex(zprops>=thresh);
rindex=zindex(zprops<=-thresh);
% The common index on the interesting ones
cindex=zindex(abs(zprops)>=thresh);
% Checks and balances
if sum(sort([gindex cindex])-zindex); error('Something does not add up'); end
if sum(sort([gindex bindex rindex])-zindex); error('Something does not add up'); end

% Prepare the path handles
pg=nan(length(gindex),1);

if ifscale
    % Make a scaled color version?
    kcol=flipud(jet); % kelicol;
    lk=size(kcol,1);
    % How far up (or mirrored down) you start the color indexing
    % This must be MORE than half the length to be able to cut out the middle
    ack=round(3.75*lk/5);
    % Set the central portions to grey
    kcol(lk-ack+2:ack-1,:)=repmat(grey,2*ack-lk-2,1);
else
    % If you want a simple red and blue
    kcol=[1 0  0 ; 0 0 1];
    % If you want a simple red and blue
    ack=lk;
end
colormap(kcol)

% The half number of bars for the center portion of the histogram
nbar=6;
% Percentiles or multiples of the threshold?
lfe=min(prctile(zprops,1),-3*thresh);
rge=max(prctile(zprops,99),3*thresh);

clf
ah(1)=subplot(121);
% Plot the plate boundaries
plotplates
hold on

% Prepare path handles
pg=nan(length(gindex),1);
if nogrey==0
    % Uninteresting gray paths
    for index=1:length(gindex)
        gi=gindex(index);
        pg(index)=plot(lolagc(:,1,gi),lolagc(:,2,gi),'Color',grey);
    end
end

% The old routine plotted the tails in order, negative first, then positive
% The new routine plotted the anomalies in order, interleaving negative and positive
defval('oldbad',0)
if oldbad==0
    % Prepare path handles
    pc=nan(length(cindex),1);
    if length(pg)+length(pc)-length(zprops); error('Something does not add up'); end
    % Interesting blue or red paths taken together and ordered by absolute value
    pc=plotem(lolagc,zprops,cindex,kcol,thresh,ack,lk);
else
    % Prepare path handles for red and blue separately
    pb=nan(length(bindex),1);
    pr=nan(length(rindex),1);
    if length(pg)+length(pb)+length(pr)-length(zprops); error('Something does not add up'); end
    % Interesting blue paths (positive anomalies)
    pb=plotem(lolagc,zprops,bindex,kcol,thresh,ack,lk);
    
    % Interesting red paths (negative anomalies)
    pr=plotem(lolagc,zprops,rindex,kcol,thresh,ack,lk);
end
cb=colorbar; longticks(cb)
% Somehow  this is one off from where the code above might suggest
cb.Ticks=[0 [lk-ack+1]/lk [ack-1]/lk 1];
cb.TickLabels={'min' sprintf('%3.1f%%',-thresh*100) sprintf('%3.1f%%',thresh*100) 'max'};

% Plot events and stations on map
p1=plot(elon,elat,'v','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',2);
p2=plot(slon,slat,'^','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',1);
hold off
axis equal
axis(domxy)
box on
longticks(ah(1),2)
xlabel('longitude')
ylabel('latitude')
tt(1)=title(sprintf('%s | %s',pref(nounder(fname)),zprox));
movev(tt(1),range(ylim)/20)

% Later plot on sphere etc
ah(2)=subplot(122);

% The greys 
[ng,eg]=histcounts(zprops(gindex),unique([linspace(-thresh,0,nbar) linspace(0,thresh,nbar)]));
gc=halfbins(eg);
% The blues
[nb,eb]=histcounts(zprops(bindex),thresh:[eg(2)-eg(1)]:rge);
bc=halfbins(eb);
% The reds
[nr,er]=histcounts(zprops(rindex),sort(-thresh:-[eg(2)-eg(1)]:lfe));
rc=halfbins(er);

% The grey, then blue, then red histograms 
gb=bar(gc*100,ng,1,'FaceColor',grey);
hold on
bb=bar(bc*100,nb,1,'FaceColor',kcol(lk-round([lk-ack]/2),:));
rb=bar(rc*100,nr,1,'FaceColor',kcol(round([lk-ack+1]/2),:));
hold off
% The entire histogram in the same colors
% [na,ea]=histcounts(zprops,unique([eb er eg]));
% ac=halfbins(ea)
% ab=bar(ac*100,na,1,'FaceColor','w')

% The axis markings and labels
%set(ah(2),'xtick',unique(100*[-thresh thresh 0 prctile(zprops,[5 25 75 95])]))
wowx=100*([-3:3]*thresh);
xlim(minmax(wowx))
xlim([lfe rge]*100)
% Or else
% wowx=100*([-3:3]*thresh);
% xlim(minmax(wowx))
set(ah(2),'xtick',wowx)
longticks(ah(2),2)
grid on
xlabel('relative travel-time anomaly \Delta T/T (%)')
% histogram title
tt(2)=title(sprintf('%i | %i | %i',length(rindex),length(cindex),length(bindex)));
movev(tt(2),range(ylim)/20)
% Somehow this next line is necessary
axes(ah(2))
% And somehow this is the way rather than absolutely setting the axis height
shrink(ah(2),1,2.8)

% Write the actual PDF file
figdisp(mfilename,sprintf('%i_%i',rin,prox),'-r600',2)

% Plots the actual paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=plotem(lolagc,zprops,cindex,kcol,thresh,ack,lk)
% INPUT
%
% lolagc    All the paths
% zprops    All the properties
% cindex    The index identifying the plotted paths and properties
% kcol      The color map
% ack       The absolute starting point of the color indexing
% kl        The length of the color map

% Selects the paths one by one and assigns the proper color to them
for index=1:length(cindex)
    % The index into the properties map
    ci=cindex(index);
    % The actual plotting using the particular index into the color map for
    % positive (blue) and/or negative (red) colors
    p(index)=plot(lolagc(:,1,ci),lolagc(:,2,ci),...
                  'Color',kcol(colorindex(thresh,zprops(ci),zprops(cindex),ack,lk),:));
    % There should be no grey here as we tested thoroughly
    % rgbplot(kcol); hold on;
    % plot(...
    %     [colorindex(thresh,zprops(ci),zprops(cindex),ack,lk) colorindex(thresh,zprops(ci),zprops(cindex),ack,lk)],...
    %     [0 1])
    if kcol(colorindex(thresh,zprops(ci),zprops(cindex),ack,lk),:)==grey; ...
            error('Reevaluate the color bar');
    end
end

% Calculates the color index %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ki=colorindex(thresh,zpropsi,zprops,ack,lk)
% Individual color control
if zpropsi>0
    ki=kindeks(     round(scale([thresh     zpropsi       max(zprops)],[ack lk])),2);
elseif zpropsi<0
    ki=kindeks(1+lk-round(scale([thresh abs(zpropsi) abs(min(zprops))],[ack lk])),2);
end

% Computes the bin centers from the bin edges %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bincenters=halfbins(binedges)
binwidth=binedges(2)-binedges(1);
bincenters=binedges(1)+binwidth/2:binwidth:binedges(end);

