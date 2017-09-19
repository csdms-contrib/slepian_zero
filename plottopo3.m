function plottopo3(lolax)
% PLOTTOPO3(lolax)
%
% Makes a 3D plot, on a globe, of a crude topography map.
%
% INPUT:
%
% lolax  Longitude and latitude of the view axis [degrees]
%
% SEE ALSO: PLOTONEARTH, POLECIRCLE, PLOTCMT3, PLOTGRAV3
% 
% Last modified by fjsimons-at-alum.mit.edu, 09/18/2017

% Get some plain vanilla topography data
load topo

% And map on to a featureless sphere, with continents
clf
pc=plotonearth(flipud(topo),1);
colormap('sergeicol')

% Viewing axis
defval('lolax',[120 10])

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
set(eqx,'LineWidth',2)
axis off
set(gca,'camerav',6)

% Print it
figdisp([],[],[],2)
