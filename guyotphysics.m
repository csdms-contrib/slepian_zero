function varargout=guyotphysics(num,noprint)
% lola=GUYOTPHYSICS(num,noprint)
%
% INPUT:
%
% num      1 Record from the Sungjibaegam 09/03/2017 North Korean nuclear test
%          2 Record from the Little Creek Delaware 11/30/2017 earthquake
%          3 Record from the Ocean City Maryland 01/15/2019 earthquake
%          4 Record from the Blain Pennsylvania 06/13/2019 earthquake
%          5 Record from the Princeton New Jersey 02/18/2020 campus blast
%          6 Record from the Marlboro New Jersey 09/09/2020 earthquake 
%          7 Record from the Pazarcik Turkey 02/06/2023 earthquake
%          8 Record from the Hualien Taiwan 04/02/2024 earthquake
%          9 Record from the Whitehouse Station New Jersey 04/05/2024 earthquake
%%         10 4.0 aftershock
%%         11 2.0 aftershocks Bedminster
%          0 Produces the location of Guyot Hall in longitude and latitude
% noprint  0 Don't make the PDF, just display the print command
%
% OUTPUT: 
%
% lola      The location of Guyot Hall in decimal degrees WHGS84/ITRS
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%
% See also VIRGINIA, CAMPUSBLAST, MCMS2MAT
% 
% Last modified by fjsimons-at-alum.mit.edu, 04/07/2024

% Default cases
defval('num',1)
defval('noprint',1)

% Location of Guyot Hall, an output
% According to GEOMC-PH1 actual GPS, we have
%      -74.654519 40.345780  and 39m elevation,
% but this here was set by hand from Google Maps, see below
guyot=[-74.65475 40.34585];
    
% Information page for the known events
urlbase='https://earthquake.usgs.gov/earthquakes/eventpage';
urltail={'us2000aert','us1000bjkn','us2000j4bf','ld60171121','NaN',...
         'us7000bk7f','us6000jllz','us7000m9g4','us7000ma74'};

% Here are the event times, from those very pages where available
evtime={[2017 09 03 03 30 01 00],... % Sungjibaegam North Korea
	[2017 11 30 21 47 31 00],... % Little Creek Delaware
	[2019 01 15 23 30 48 00],... % Ocean City Maryland
	[2019 06 13 00 30 57 00],... % Blain Pennsylvania
       	[2020 02 18 16 30 05 00],... % Princeton New Jersey
        [2020 09 09 02 00 13 00],... % Marlboro New Jersey
        [2023 02 06 01 17 35 00],... % Pazarcik Turkey
        [2024 04 02 23 58 11 00],... % Hualien Taiwan
        [2024 04 05 14 23 20 00]};   % Whitehouse Station
% Here are the event lon lat depth, from those very pages where available
evlocs={[129.030  41.332  0.0],...   % Sungjibaegam North Korea
	[-75.433  39.198  9.9],...   % Little Creek Delaware
	[-73.010  37.232 10.0],...   % Ocean City Maryland
	[-77.506  40.422 26.7],...   % Blain, Pennsylvania
        [-74.655  40.346  0.0],...   % Princeton New Jersey
	[-74.246  40.262  5.0],...   % Marlboro New Jersey
        [ 37.032  37.174 17.9],...   % Pazarcik Turkey
        [121.562  23.819 34.8],...   % Hualien Taiwan
        [ -74.753 40.683]};          % Whitehouse Station New Jersey
% Here are the event magnitudes, from those very pages where available
evmag=[6.3 4.1 4.6 3.4 NaN 3.1 7.8 7.4 4.8];

% Time-window opening before and after the P-wave occurrence, default
xlsd=[-100 100];
% Any extra time-window openings to update the default?
xlso={[0 0],[0 0],[0 0],[0 0],[95 -95],[0 0],[-100 5315],[-100 5400],[0 0]};
% Tick mark interval
defval('tint',30)

% Some top-level directory
ddir='/u/fjsimons/CLASSES/GuyotPhysics';

% Where I keep the data for convenience... vertical components to be sure
fnames={'Sungjibaegam_1_2','Delaware_1_2','Maryland_1_2','Pennsylvania_1_2',...
        'CampusBlast_Z','Freehold_1_2','Nurdağı_Z','Hualien_Z','WhiteHouseStation_2024_Z'};

% Load the data
switch num
  case 0
   % Location of Guyot Hall according to ME, having placed the
   % seismometer myself, sir
   varargout{1}=guyot;
   % Check out where the Guyot Hall Geodetic Station has been set to
   % http://pton.unavco-data.net/scr...
   % ?cmd=2.20.10.0.0_2.20.20.0.0_2.20.30.0.0_2.20.40.0.0.A_2.30.90.0.0.A...
   % &fra0=position.html
   % which is N40°20'44.9220"  W74°39'17.0530"
   % which converts using VIT2LOC to just about -74.6547  40.3458, see
   % there ... so that is all consistent!
   return
 otherwise
  % Load the data
  [S,H]=readsac(fullfile(ddir,'SAC',sprintf('%s.sac',fnames{num})));
  % This is the beginning of the RECORD in absolute time
  dttime=[indeks(doy2dat(H.NZYEAR,H.NZJDAY),[3 1 2]) H.NZHOUR H.NZMIN H.NZSEC H.NZMSEC];
  % So this is the EVENT OFFSET from that beginning in seconds,
  ofset=etime(evtime{num},dttime);
  % Now figure out the great-circle distance - to Guyot Hall, the default, maps back here
  [~,gcdd]=grcdist(evlocs{num}(1:2));
  % Then make the travel-time predictions, one way
  modnam='IASP91';
  % Need to recompile PARRIVAL, TTIMES, SAC etc... after system upgrade end 2022...
  % Strangely in 2024 parrival from within MATLAB appears to be working again
  [tstp,tS,tP,~,~,namP,namS]=tmins(gcdd,evlocs{num}(3));
  % Time window to be plotted, which is supposed to  contains the P-wave
  xls=ofset+tP+xlsd+xlso{num};
  if num==9
      % Some extra special x-axis limits
      xls=[127 505];
  end
end

% Do the plotting common to all cases
clf
ah=subplot(211);
axes(ah(1))
layout(ah(1),0.5,'m','y')

% Plot the traces as recorded by the seismometer
[ph,tl,xl,yl]=plotsac(S,H,'LineWidth',0.5');
yls=halverange(get(gca,'ylim'),105,NaN);
ylim(yls+[num==8]*[-1e4 0])
xlim(xls)

% Special cases
switch num
  case 5
    tint=2.5;
    set(ph,'LineWidth',0.75,'Color','b')
  case 7
    tint=500;
  case 8
    tint=500;
end

set(gca,'xtick',round(xls(1)/60)*60:tint:xls(2))
if verLessThan('matlab','9.0.0')
  % Prior to R2016a this was good enough
  movev(tl,range(yls)/20)
else
  % After R2016a the behavior changed
  tlpos=tl.Position; 
  % Need to recenter the title after xls change
  %  tl.Position=tlpos+[-tlpos(1)+mean(xls) range(yls)/5 0];
  tl.Position=tlpos+[-tlpos(1)+mean(xls) range(yls)/5 0];
end

% Plot the ticks as predicted by the event location and the earth model
hold on
% Plot the P wave
pp=plot(repmat([ofset+tP],2,1),ylim,'LineStyle','-','Color','b');
switch num
  case {7,8}
    % Also plot the S wave
    ps=plot(repmat([ofset+tS],2,1),ylim,'LineStyle','-','Color','r');
end
if num==8
    % Also plot the PKiKP wave
    pp2=plot(repmat([ofset+1115.31],2,1),ylim,'LineStyle','-','Color','g');
    % Also plot the Sdiff wave
    ps2=plot(repmat([ofset+1630.19],2,1),ylim,'LineStyle','-','Color','k');
end
hold off

% Legends, labels, titles, and other annotations
switch num
  case 7
    % If you plotted two things
    legs=legend([pp ps],{sprintf('%s-wave arrival (%s)',namP{1},modnam),...
                         sprintf('%s-wave arrival (%s)',namS{1},modnam)},...
                        'Location','SouthEast');
  case 8
    % If you plotted those four things
    legs=legend([pp pp2 ps ps2],{sprintf('%s-wave arrival (%s)',namP{1},modnam),...
                                 sprintf('%s-wave arrival (%s)','PKiKP',modnam),...
                                 sprintf('%s-wave arrival (%s)',namS{1},modnam)...
                                 sprintf('%s-wave arrival (%s)','Sdiff',modnam)},...
                                'Location','SouthEast');
  otherwise
    % If it was only one thing, check if you shouldn't call namP{1} here also
    legs=legend(pp,sprintf('P-wave arrival (%s)',modnam),'Location','SouthWest');
end
switch num
  case {7,8}
    % Annotations about earthquake information
    tl.Position=tl.Position+[450 0 0];
    tt(1)=text(6500,3.5e4,sprintf('%s = %4.1f%s','\Delta',gcdd,176));
    tt(2)=text(6500,5.5e4-[num==8]*10000,sprintf('%s = %4.1f','M',evmag(num)));
    tt(3)=text(6500,4.5e4-[num==8]*5000,sprintf('%s = %4.1f km','d',evlocs{num}(3)));
    tt(4)=text(6500,6.75e4-[num==8]*15000,sprintf('%s',urltail{num}));
    set(tt,'FontSize',6) 
    set(ph,'LineWidth',0.25)
end

% Event-specific cleanup
switch num
 case 1
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  % By the way... some other phases!
  P=806.78;
  PcP=806.92;
  PP=1037.41;
  PKiKP=1086.92;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 case 2
  % By the way... 
  modnam='PREM';
  tS=38.74;
  tP=21.61;
 case 3
   % Any comments?
 case 4
   % Any comments?
 case 7
   % Any comments?
   modnam='IASP91';
   tP=730.40;
   tS=1336.16;
   % My name
   h=id;
   movev(h,0.19)
   moveh(h,-0.03)
   h.Color=grey;
   h.FontSize=4;
  case 8
   % My name
   h=id;
   movev(h,0.19)
   moveh(h,-0.03)
   h.Color=grey(4);
   h.FontSize=4;
   longticks(gca,4)
  case 9
    delete(legs)
    grid on
    h=id;
    movev(h,0.19)
    moveh(h,-0.03)
    h.Color=grey(4);
    h.FontSize=4;
    longticks(gca,4)
end

% Make pretty print
figdisp([],num,[],2*noprint)

% AMPLITUDES
% M6.3 Sungjibaegam North Korean nuclear tests +/- 1e2
% M4.1 Little Creek Delaware earthquake +/- 3e4
% M4.6 Ocean City Maryland earthquake +/- 1e3
% M 3.4 Blain Pennsylvania earthquake +/- 750
% Princeton Campus construction blasts  +/- 3e4
% M 3.1 Marlboro earthquake +/- 4e3
% M7.8 Pazarcik Turkey 02/06/2023 earthquake
% M7.4 Hualien Taiwan 04/02/2024 earthquake
% M4.8 Whitehouse Station New Jersey 04/05/2024 earthquake 
