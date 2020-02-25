function campusblast(cmp,yli,ddir)
% CAMPUSBLAST(cmp,yli,ddir)
%
% Makes a picture of the campus blasts
%
% INPUT:
%
% cmp    Component 1 for X
%                  2 for Y
%                  3 for Z
% ytli   'hard' for provided yaxis limits
%        'soft' for calculated yaxis limits
% ddir   The directory where the data files are being kept
%
% Tested on: 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 02/26/2020

% Defaul values
defval('cmp',1)
% Component identifiers
cmps={'x','y','z'};
% Soft means flexibility with the y-axis limits
defval('yli','soft');

% Directory and filenames and other sundries
defval('ddir','/u/fjsimons/PIX/GuyotPhysics/MAT');

snam={'PP.S0001.00.HHA_MC-PH1_0248_20200218_160000.mat',...
     'PP.S0001.00.HHA_MC-PH1_0248_20200221_160000.mat'};
cols={'b','r'};

% Hard axis limits, from prior experience, match
xlims=[1804.51 1808.49 ; ...
       2563.01 2566.99];
% The below is for the 'hard' option, one for each component, as many per
% components as you will be loading seismograms
if strcmp(yli,'hard')
  ylims{1}=[-1800 1800 ;
            -1800 1800];
  ylims{2}=[-1900 1900 ;
            -1900 1900];
  ylims{3}=[-2100 2100 ; 
            -2100 2100];
end

% Plotting functions
clf
[ah,ha]=krijetem(subnum(length(snam),1));
for index=1:length(ah)
  axes(ah(index))
  load(fullfile(ddir,snam{index}))
  % Picking out the right component
  ts=eval(sprintf('s%s',cmps{cmp}));
  hs=eval(sprintf('h%s',cmps{cmp}));
  % Plotting using the standard routine
  [ph(index),tl(index),xl(index),yl(index)]=plotsac(ts,hs);
  % Cosmetics and cleanup
  grid on
  set(ph(index),'Color',cols{index},'LineWidth',1)
  set(yl(index),'String',sprintf('%s displacement (nm)',upper(cmps{cmp})))
  xlim(xlims(index,:))
  
  % Do the hard limits
  switch yli
    case 'hard'
    % Apply the limits
    ylim(ylims{cmp}(index,:))
   case 'soft'
    % Prepare to apply the limits at the, e.g. 110% level
    ylims{index}=halverange(ph(index).YData,110);
  end
  % Need to recenter the title after xls change; with KEYBOARD and
  % hand-editing you NEED to switch from 'data' to 'normalized'
  shrink(ah(index),1,1.1)
  tl(index).Units='normalized';
  tlpos=tl(index).Position;
  %tl(index).Position=tlpos+[-tlpos(1)+mean(xlims(index,:)) 0 0];
  tl(index).Position=[0.55 1.1 0];
end

% Final cosmetics and cleanup
if strcmp(yli,'soft')
  % Apply the limits
  for index=1:length(ah)
    axes(ah(index))
    % This will work for nearly zero-mean signals
    ylim([min(min(cat(1,ylims{:}))) max(max(cat(1,ylims{:})))])
  end
end
delete(tl(2:end))

% Printout
figdisp([],upper(cmps{cmp}),[],2)


