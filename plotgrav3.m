function plotgrav3(lolax)
% PLOTGRAV3(lolax)
%
% Makes a 3D plot, on a globe, of a crude gravity map.
%
% INPUT:
%
% lolax  Longitude and latitude of the view axis [degrees]
%
% SEE ALSO: PLOTONEARTH, POLECIRCLE, PLOTCMT3, PLOTTOPO3
% 
% Last modified by fjsimons-at-alum.mit.edu, 09/18/2017

% Get some plain vanilla gravity data
grav=fralmanac('EGM96','XYZ');

% And map on to a featureless sphere, with continents
clf
pc=plotonearth(grav,1);
colormap(kelicol)
caxis([-100 100])

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
