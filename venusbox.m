function varargout=venusbox(id,iftopo)
% [ph,pm,pd,ps]=VENUSBOX(id,iftopo)
%
% Box plots masked Venus topography and radar data and provides basic global stats
%
% INPUT:
%
% id       A region id number
% iftopo   1 It is topography, or else it is radar
%
% OUTPUT:
%
% ph       Handles to the boxes
% pm       Handles to the means
% pd       Handles to the medians
% psn       Handles to the standard deviations
%
% Last modified by fjsimons-at-alum.mit.edu, 07/24/2026

defval('id',ceil(rand*77))
defval('iftopo',1)

% If you've done this before, note you always know there are 77 regions
if iftopo==1
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/plmData/plmVenus_D-5_stats.mat');
    % Should have saved that in there, but didn't yet reran VENUSTATS quickly
    pc=   [-1.2697 -0.5850 -0.1817  0.3771 2.9456]*1e3;
    percx=[ 2.5    25      50      75     97];
else
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/radarData/radVenus_D-5_stats.mat');
    % Should have saved that in there, but didn't yet reran VENUSTATS quickly
    pc=   [ 0    2.8284  3.4032  4.0180  5.6302]*1e4;
    percx=[ 2.5 25      50      75      97];
end

% Just work from what was saved, even though not quite a whole box plot
if exist(fname)
    % Make sure you don't load all the actual global data, definitely not for radar
    load(fname,'s')
else
    error('Run VENUSTATS first!')
end

% Plot the boxes
clf
ah=gca;
% Figure out some geometrics
cdown=[length(s.mean):-1:1];
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
ps(end+1)=plot([s.mean(id)-2*sqrt(s.variance(id)) ; s.mean(id)+2*sqrt(s.variance(id))],[id ; id],'b');
ph(end+1)=fillbox([s.p25(id) s.p75(id) strts(id,:)],'b');
pd(end+1)=plot([s.median(id)   ; s.median(id)],strts(id,:),'r');
pm(end+1)=plot([s.mean(id)     ; s.mean(id)  ],strts(id,:),'y');
hold off

if iftopo==1
    xlabel='elevation (m)';
else
    xlabel='radar brightness)';
end
ylabel('region number')

% Cosmetix
set(pm,'LineWidth',2)
set(ah,'YTick',1:5:77)
set(ah,'XTick',pc)
set(ah,'XTickLabel',percx)
set(ah,'XGrid','on')
longticks(ah)

% Optional output
varns={ph,pm,pd,ps};
varargout=varns(1:nargout);
