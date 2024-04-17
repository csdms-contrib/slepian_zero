function plotcmt3(lolax,ext)
% PLOTCMT3(lolax,ext)
%
% Makes a 3D plot, on a globe, of a selection of CMT events.
%
% INPUT:
%
% lolax  Longitude and latitude of the view axis [degrees]
% ext    Extension for the named plot
%
% SEE ALSO: PLOTONEARTH, POLECIRCLE, PLOTTOPO3, PLOTGRAV3
% 
% Last modified by fjsimons-at-alum.mit.edu, 04/17/2024

% Get some plain vanille earthquake data
neq=20000;
load('/u/fjsimons/IFILES/CMT/quakes77_2013.mat')
data=QUAKES(randi(length(QUAKES),1,neq),:);
% Mnemonix
evla=data(:,3);
evlo=data(:,4);
evdp=data(:,2);

% Viewing axis
defval('lolax',[120 10])
defval('lolax',[300 10])
defval('ext',[])

% Just a blank canvas so we can rotate interactively
clf
pc=plotonearth(rand(100),1);
colormap([1 1 1])

% Plot the data on top of there
hold on
radd=1.001;
[xx,yy,zz]=sph2cart(evlo*pi/180,evla*pi/180,repmat(radd,size(evla)));
pcmt=plot3(xx,yy,zz,'o');

% Plot an equator as a "bounding box"
radx=1.01;
[xe,ye,ze]=polecircle(lolax,[0 0 0 radx],[],-1); hold on
eqx=plot3(xe,ye,ze,'k');
hold off

% Set view axis and report view angles
[xv,yv,zv]=sph2cart(lolax(1)*pi/180,lolax(2)*pi/180,1);
view([xv,yv,zv]); [AZ,EL]=view;
disp(sprintf('Azimuth: %i ; Elevation: %i',round(AZ),round(EL)))

% Cosmetics
set(pc,'linew',1)
set(eqx,'LineWidth',1)
axis off
set(pcmt,'MarkerS',2,'MarkerE','k','MarkerF',grey)
set(gca,'camerav',6)

% Print it
figdisp([],ext,[],2)
% The below will do the vector graphics
%figdisp([],ext,'-painters',2)
