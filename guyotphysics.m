function varargout=guyotphysics(num,noprint)
% lola=GUYOTPHYSICS(num,noprint)
%
% INPUT:
%
% num      1 Record from 09/03/2017 North Korean Nuclear test (no CMT code)
%          2 Record from the Delaware 11/30/2017 earthquake (no CMT code)
%          3 Record from the Maryland 01/15/2019 Ocean City earthquake
%          4 Record from the Pennsylvania 01/15/2019  earthquake
%          0 Produces the location of Guyot Hall in longitude and latitude
% noprint  0 Don't make the PDF, just display the print command
%
%
% OUTPUT: 
%
% lola      The location of Guyot Hall in decimal degrees WHGS84/ITRS
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%
% See also VIRGINIA.
% 
% Last modified by fjsimons-at-alum.mit.edu, 06/14/2019

% Default cases
defval('num',1)
defval('noprint',1)

% Location of Guyot Hall
guyot=[-74.65475 40.34585];

% Information page for the known events
urlbase='https://earthquake.usgs.gov/earthquakes/eventpage';
urltail={'us2000aert','us1000bjkn','us2000j4bf','ld60171121'};

% Here are the event locations, from those very pages
evtime={[2017 09 03 03 30 01 00],...
	[2017 11 30 21 47 31 00],...
	[2019 01 15 23 30 48 00],...
	[2019 06 13 00 30 57 00]};
evlocs={[129.030 41.332  0.0],...
	[-75.433 39.198  9.9],...
	[-73.010 37.232 10.0],...
	[-77.506 40.422 26.7]};
% Time-window opening before and after the event occurrence
defval('xlsd',[-100 100])
% Any extra? Put them in here
xlso={[0 0],[0 0],[0 0],[0 0]};
  
% Some top-level directory
ddir='/u/fjsimons/PIX/GuyotPhysics';

% Where I keep the data for convenience
fnames={'Sungjibaegam_1_2','Delaware_1_2','Maryland_1_2','Pennsylvania_1_2'};

% Load the data
switch num
  case 0
   % Location of Guyot Hall according to ME, having placed the
   % seismometer myself, sir
   varargout{1}=guyot;
   % Check out where the Guyot Hall Geodetic Station has been set to
   % http://pton.unavco-data.net/scr?cmd=2.20.10.0.0_2.20.20.0.0_2.20.30.0.0_2.20.40.0.0.A_2.30.90.0.0.A&fra0=position.html
   % which is N40°20'44.9220"  W74°39'17.0530"
   % which converts using VIT2LOC to just about -74.6547  40.3458, see
   % there ... so that is all consistent!
   return
 otherwise
  % Load the data
  [S,H]=readsac(fullfile(ddir,'SAC',sprintf('%s.sac',fnames{num})));
  % This is the beginning of the record in absolute time
  dttime=[indeks(jul2dat(H.NZYEAR,H.NZJDAY),[3 1 2]) H.NZHOUR H.NZMIN H.NZSEC H.NZMSEC];
  % So this is the event offset from that beginning in seconds
  ofset=etime(evtime{num},dttime);
  % Now figure out the great-circle distance - to Guyot Hall, the default
  [~,gcdd]=grcdist(evlocs{num}(1:2));
  % Then make the travel-time predictions, one way
  modnam='IASP91';
  [tstp,tS,tP]=tmins(gcdd,evlocs{num}(3));
  % Time window to be plotted around the P-wave
  xls=ofset+tP+xlsd+xlso{num};
end

% Do the plotting common to all cases
clf
ah=subplot(211);
axes(ah(1))
layout(ah(1),0.5,'m','y')

% Plot the traces as recorded by the seismometer
[ph,tl,xl,yl]=plotsac(S,H,'LineWidth',0.5');

yls=halverange(get(gca,'ylim'),105,NaN);
ylim(yls)
xlim(xls)
set(gca,'xtick',round(xls(1)/60)*60:30:xls(2))
if verLessThan('matlab','9.0.0')
  movev(tl,range(yls)/20)
else
  tl.Position=tl.Position+[0 range(yls)/20 0];
end

% Plot the ticks as predicted by the event location and the earth model
hold on
pp=plot(repmat([ofset+tP],2,1),ylim,'LineStyle','-','Color',grey);
hold off

% Legends, labels, titles, and other annotations
legs=legend(pp,sprintf('expected P-wave arrival (%s)',modnam),'Location','SouthWest');

% Event-specific cleanup
switch num
 case 1
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  % By the way...
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
end

% Make pretty print
figdisp([],num,[],2*noprint)

