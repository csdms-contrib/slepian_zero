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
% ps       Handles to the standard deviations
%
% Last modified by fjsimons-at-alum.mit.edu, 07/24/2026

defval('id',ceil(rand*77))
defval('iftopo',1)

% If you've done this before, note you always know there are 77 regions
if iftopo==1
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/plmData/plmVenus_D-5_stats.mat');
else
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/radarData/radVenus_D-5_stats.mat');
end

% Just work from what was saved, even though not quite a whole box plot
if exist(fname)
    load(fname)
else
    error('Run VENUSTATS first!')
end

% Plot the boxes
clf
ah=gca;
% Figure out some geometrics
shifs=[77:-1:1]; tofs=0.3;
strts=[shifs(:)+tofs shifs(:)-tofs];
% Do the actual plotting
ph=fillbox([s.p25(:) s.p75(:) strts],'w');
pv=fillbox([s.pmean(:)-sqrt() s.pmean(:) strts],'w');
hold on
pd=plot([s.median ; s.median],strts','k');
pm=plot([s.mean   ; s.mean  ],strts','b');
% Plot one more, the special one
ph(end+1)=fillbox([s.p25(id) s.p75(id) strts(id,:)],'b');
pd(end+1)=plot([s.median   ; s.median  ],strts','k');
pm(end+1)=plot([s.mean(id) ; s.mean(id)],strst(id,:),'y');
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
longticks(ah)

% Optional output
varns={ph,pm};
varargout=varns(1:nargout);
