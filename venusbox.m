function varargout=venusbox(id,iftopo)
% [ph,pm,pd,ps]=VENUSBOX(id,iftopo)
%
% Box plots masked Venus topography and radar data and provides basic global stats
%
% INPUT:
%
% id       A region id number for coloring, if 0 nothing special gets colored
% iftopo   1 It is topography
%          0 It is radar
%
% OUTPUT:
%
% ph       Handles to the boxes
% pm       Handles to the means
% pd       Handles to the medians
% psn      Handles to the standard deviations
%
% Last modified by fjsimons-at-alum.mit.edu, 09/18/2026
% Last modified by olwalbert-at-princeton.edu, 09/18/2026

defval('id',ceil(rand*77))
defval('iftopo',1)

% First and last for axis limits and inner ones for tick labels
% Note that some whiskers may be cut off by this choice
percx=[1 2.5    25      50      75     97.5 99];
% If you've done this before, note you always know there are 77 regions
if iftopo==1
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/plmData/plmVenus_D-5_stats.mat');
    % The below is prctile(torareg,percx) which we didn't save in VENUSTATS
    pc=   [-1.4587 -1.2697 -0.5850 -0.1817 0.3771  2.9456 3.5843]*1e3;
elseif iftopo==0
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/radarData/radVenus_D-5_stats.mat');
    % The below is prctile(torareg,percx) which we didn't save in VENUSTATS
    pc=   [1.4032  1.7734  2.9020  3.4410 4.0472  5.6508  6.0971]*1e4;
end

% Just work from what was saved, even though not quite a whole box plot
if exist(fname)
    % Make sure you don't load all the actual global data, definitely not for radar
    % Save time by not loading torareg
    load(fname,'s')
else
    error('Run VENUSTATS first!')
end

% Plot the boxes
clf
ah=gca;
% Figure out some geometrics
cdown=[length(s.mean):-1:1];
cdown=1:length(s.mean);
% Count down, box height, top and bottom
shifs=cdown; tofs=0.3;
strts=[shifs(:)+tofs shifs(:)-tofs];
% Do the actual plotting

% Horizontal bars, e.g. plot([1 2 ; 3 4 ; 5 6  ]',[1 1 ; 2 2 ; 3 3 ]');
ps=plot([s.mean-2*sqrt(s.variance) ; s.mean+2*sqrt(s.variance)],[cdown ; cdown],'Color',grey);
hold on
ph=fillbox([s.p25(:) s.p75(:) strts],'w');
% Vertical bars, e.g. plot([1 2 3 ; 1 2 3],[1 2 ; 2 3 ; 3 4]');
pd=plot([s.median ; s.median],strts','k');
pm=plot([s.mean   ; s.mean  ],strts','b');

% Plot one more, the special one
if id>0
    ps(end+1)=plot([s.mean(id)-2*sqrt(s.variance(id)) ; s.mean(id)+2*sqrt(s.variance(id))],[id ; id],'b');
    ph(end+1)=fillbox([s.p25(id) s.p75(id) strts(id,:)],'b');
    pd(end+1)=plot([s.median(id)   ; s.median(id)],strts(id,:),'r');
    pm(end+1)=plot([s.mean(id)     ; s.mean(id)  ],strts(id,:),'y');
    hold off
end

if iftopo==1
    xlabel('elevation (m)')
    % Maxwell Mons is the odd one out
    hold on
    text(pc(end),42,'\rightarrow','horizontalalignment','right','FontWeight','bold')
    hold off
elseif iftopo==0
    xlabel('radar brightness')
    set(ah,'yaxislocation','right')
end
ylabel('region number')

% Cosmetix
axis tight
ylim([0 78])
xlim([pc(1) pc(end)])
% xlim([0 78])
set(pm,'LineWidth',1)
set(ah,'YTick',1:5:77)
set(ah,'XTick',pc(2:end-1))
set(ah,'XTickLabel',percx(2:end-1))
set(ah,'XGrid','on')
longticks(ah,2)
shrink(ah,2,1)

% Optional output
varns={ph,pm,pd,ps};
varargout=varns(1:nargout);
