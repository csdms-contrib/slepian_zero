function varargout=venusbox(iftopo)
% [ph,pm]=VENUSBOX(iftopo)
%
% Box plots masked Venus topography and radar data and provides basic global stats
%
% INPUT:
%
% iftopo   1 It is topography, or else it is radar
%
% OUTPUT:
%
% ph       Handles to the boxes
% pm       Handles to the means    
%
% Last modified by fjsimons-at-alum.mit.edu, 07/24/2026

defval('iftopo',1)

% If you've done this before, note you always know there are 77 regions
if iftopo==1
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/plmData/plmVenus_D-5_stats.mat');
else
    fname=fullfile(getenv('IFILES'),'VENUS/DATA/radarData/radVenus_D-5_stats.mat';
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
shifs=[77:-1:1]; tofs=0.3;
ph=fillbox([s.p25(:) s.p75(:) shifs(:)+tofs shifs(:)-tofs],'w');
hold on
pm=plot([s.mean ; s.mean],[shifs(:)'+tofs ; shifs(:)'+tofs]);
hold off

if iftopo==1
    xlabel='elevation (m)';
else
    xlabel='radar brightness)';
end
ylabel('region number')

% Cosmetix
set(ah,'YTick',1:5:77)
longticks(ah)

% Optional output
varns={ph,pm};
varargout=varns(1:nargout);
