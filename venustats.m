function venustats(id,iftopo,xyofs,xver)
% VENUSTATS(id,iftopo,xyofs,xver)
%
% Plots Venus topography data and provides basic global stats
%
% INPUT
%
% id       A region id number
% iftopo   1 It is topography, or else it is radar
% xyofs    Tiny touch horizontal/vertical offset for colorbar if desired, in figure coordinates
% xver     1 provide extra verification
%          0 don't
%
% Last modified by fjsimons-at-alum.mit.edu, 07/01/2026

defval('id',ceil(rand*77))
defval('iftopo',1)
defval('xyofs',[0 0])
defval('xver',1)

% If you've done this before, not you always know there are 77 regions
if iftopo==1
    fname='/data1/fjsimons/IFILES/VENUS/DATA/plmData/plmVenus_D-5_stats.mat';
    colmap='kelicol';
else
    fname='/data1/fjsimons/IFILES/VENUS/DATA/radarData/radVenus_D-5_stats.mat';
    colmap='gray';
end

if exist(fname)
    % Load just the data you need
    [DxDy,lonrDx,latrDx,XYr360,toporad,in]=loaditmakeit(id,iftopo);

    % Load the prepared global stats file - and the data union of all regions
    load(fname)
    disp(sprintf('Loading global statistics and data file\n%s',fname))

    % Trust, but verify
    if xver==1
        diferm(mean(toporad(in(:)))-s.mean(id))
        diferm(std(toporad(in(:)))-sqrt(s.variance(id)))
    end

    % Use the rectangular patch statistics for the colorbars
    cax=prctile(toporad(:),[5 95]);
    csx=prctile(toporad(:),50);

    % Make the plot of the rectangle without the regional mask
    clf
    ah(1)=subplot(221);
    hi(1)=imagefnan([lonrDx(1), latrDx(2)],[lonrDx(2), latrDx(1)],...
                    toporad,colmap,roundX(cax,1),[],1);   
    hold on
    pc=twoplot(XYr360,'k');
    hold off
    grid on
    % Depends on colorbar orientation
    % ah(1).YAxisLocation='right';
    ah(1).YAxisLocation='left';
    ah(1).XAxisLocation='top';

    [cb,cbx]=addcb('hor',cax,cax,colmap,roundX(sort([cax csx]),1),1);
    movev(cb,-0.1)
    %cb.Position=[ah(1).Position(1) getpos(cb,[2 3 4])]+[xyofs 0 0];
    %cb.Position=[getpos(cb,1) getpos(ah(1),2) getpos(cb,3) getpos(ah(1),4)]
    %cb.YAxisLocation='left';
    cb.XAxisLocation='bottom';
    if iftopo==1
        cb.XLabel.String='elevation (m)';
    else
        cb.XLabel.String='radar brightness)';
    end
    
    % Mask the data for plotting purposes
    toporad(~in)=NaN;

    % Make the plot of the rectangle with the regional mask
    ah(2)=subplot(223);
    hi(2)=imagefnan([lonrDx(1), latrDx(2)],[lonrDx(2), latrDx(1)],...
                    toporad,colmap,roundX(cax,1),[],1);
    hold on
    pc=twoplot(XYr360,'k');
    hold off
    grid on
    t(2)=title(sprintf('V%4.4i',id));

    % Make the histograms

    % Use the GLOBAL dataset to interpret, oddbins
    nbins=21;
    perx=[2.5 25 50 75 97.5];
    % Calculate relevant statistics
    lc=prctile(torareg, 2.5);
    rc=prctile(torareg,97.5);
    pc=prctile(torareg,perx);
    % Only really plot the data within the limits - no extra bins
    co=torareg>=lc & torareg<=rc;
    % Bin edges
    bins=unique(round(linspace(lc,rc,nbins)));

    ah(3)=subplot(222);
    hh{1}=histit(torareg(co),bins,lc,rc,pc,perx,0,iftopo);
    set(hh{1},'FaceColor','w'),

    ah(4)=subplot(224);
    hh{2}=histit(toporad(in(:)),bins,lc,rc,pc,perx,0,iftopo);
    set(hh{2},'FaceColor','b'),
    
    % Cosmetics
    longticks(ah)

    figdisp(upper(mfilename),sprintf('%2.2i',id),[],2)
else
    % Prepare an empty bucket
    torareg=[]; toraind=0;
    mPoly=[]; sPoly=[];

    % Look over the regions once to collect all the patches in their projections
    for index=1:77
        [DxDy,lonrDx,latrDx,XYr360,toporad,in]=loaditmakeit(index,iftopo);
        % Preserve the indices
        toraind=[toraind ; toraind(end)+1 ; toraind(end)+sum(in(:))];
        % Collect all the flattened regional data for the global stats
        torareg=[torareg ; toporad(in(:))];
        if xver==1
            % Collect, say the region means, see ROW2STATS later
            mPoly=[mPoly ; nanmean(toporad(in(:)))];
            % Collect, say the region means, see ROW2STATS later
            sPoly=[sPoly ; nanstd(toporad(in(:)))];
        end
    end
    % Cut off the initialization
    toraind=toraind(2:end);

    % Compare what you did inside to the global way
    [~,s]=row2stats(gamini(1:length(toraind)/2,indeks(diff(toraind),'1:2:end')+1),torareg);

    % Trust, but verify
    if xver==1
        for index=1:77
            diferm(mPoly(index)-s.mean(index))
            diferm(sPoly(index)-sqrt(s.variance(index)))
        end
    end

    % Save for later usage
    try
        save(fname,'s','torareg','toraind')
    catch
        save(fname,'s','torareg','toraind','-v7.3')
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hh=histit(data,bins,lc,rc,pc,perx,ifc,iftopo)
defval('ifc',0)
defval('iftopo',1)
if ifc
    % If bin CENTERS
    [hv,bc]=hist(data,bins);
    hh=bar(bc,hv/sum(hv),1);
else
    % If bin EDGES and no other stars anywhere else
    [hv,bc]=histc(data,bins);
    hh=bar(bins,hv/sum(hv),'histc'); delete(findobj('marker','*'));
end
caxis([lc rc])
xticks(round(pc))
xticklabels(perx)
if iftopo==1
    xlabel('global elevation percentile')
else
    xlabel('global radar brightness percentile')
end
yels=ylim; ylim(roundX(yels,log10(0.05)))
grid on
hold on

if ifc
    % Find the bin that most likely contains 0
    [~,fm]=min(abs(bc));
    ps=plot(0,hv(fm)/sum(hv),'o','MarkerSize',3,'MarkerFaceColor','y');
    hold off
else
    % Zero lies on a vertex, faking it a little
    [hv,bc]=hist(data,bins);
    [~,fm]=min(abs(bc));
    ps=plot(0,hv(fm)/sum(hv),'o','MarkerSize',3,'MarkerFaceColor','y');
    hold off
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DxDy,lonrDx,latrDx,XYr360,toporad,in]=loaditmakeit(index,iftopo)
defval('iftopo',1)
% Load all the regions, or rather, just the specific one from the complete set
if iftopo==1
    load('/data1/fjsimons/IFILES/VENUS/DATA/plmData/plmVenus_D-5.mat',...
         sprintf('V%4.4i_03',index))
    % disp(sprintf('Making progress on topography patch %4.4i',index))
else
    load('/data1/fjsimons/IFILES/VENUS/DATA/radarData/radVenus_D-5_c-global.mat',...
         sprintf('V%4.4i_03',index))
    % disp(sprintf('Making progress on radar patch %4.4i',index))
end

% Get the geographical grid spacing and extent of the rectangular data in pseudocoordinates
DxDy=eval(sprintf('V%4.4i_03.geo.DxDy',index));
lonrDx=eval(sprintf('V%4.4i_03.geo.lonrDx',index));
latrDx=eval(sprintf('V%4.4i_03.geo.latrDx',index));
% Get the regional bounding curve in pseudocoordinates
XYr360=eval(sprintf('V%4.4i_03.geo.XYr360',index));
% Get the rectangular data
if iftopo==1
    toporad=eval(sprintf('V%4.4i_03.dataP.dp',index));
else
    toporad=eval(sprintf('V%4.4i_03.rp',index));
end
% Save future output in a hash
fname=fullfile(getenv('IFILES'),'HASHES',hash([index iftopo],'SHA-256'));

if exist(sprintf('%s.mat',fname))==2
    load(fname)
    disp(sprintf('Loading indices of radar patch %4.4i',index))
else
    % Make the geographical grid of the rectangular data in pseudocoordinates
    [Glon,Glat]=meshgrid(lonrDx(1):DxDy:lonrDx(2),latrDx(2):-DxDy:latrDx(1));
    % Make/save/load the regional mask
    in=inpolygon(Glon,Glat,XYr360(:,1),XYr360(:,2));
    save(fname,'in')
end

