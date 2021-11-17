function varargout=gridrth(cxcy,smn,th,r)
% [pr,pth]=GRIDRTH(cxcy,smn,th,r)
%
% Makes a polar grid
%
% INPUT:
%
% cxcy      The center (x,y) point, e.g. pixels, e.g,. from GINPUT
% smn       The size of the image for which you want a grid, e.g., from SIZE
% th        The angles at which you want as radial grid lines, in degrees
% r         The radii at which you want concentric grid circles, in
% pixels
%
% OUTPUT:
%
% pth       Handles to the azimuthal lines
% pr        Handles to the concentric circles
%
% EXAMPLE:
% 
% imshow(imread('http://geoweb.princeton.edu/people/simons/FRS161/Cookies/Maple2.tif'))
% cxcy=[2059 2115]; smn=[round(max(ylim)) round(max(xlim))]; axis xy
% th=[0:30:330]; r=[500:500:3000]; [pth,pr]=gridrth(cxcy,smn,th,r);
%
% Last modified by fjsimons-at-alum.mit.edu, 11/17/2021

% The diagonal will be ridiculously large
d=norm(smn);

% Loop over the angles 
hold on
for index=1:length(th)
  pth(index)=plot([cxcy(1) cxcy(1)+sin(th(index)*pi/180)*d],...
		  [cxcy(2) cxcy(2)+cos(th(index)*pi/180)*d]);
end
hold off

% Loop over the radii without a for loop
np=100;
theta=linspace(0,2*pi,np);
x=[r'*cos(theta)]'+cxcy(1);
y=[r'*sin(theta)]'+cxcy(2);
hold on
pr=plot(x,y);
hold off

% Optional output
varns={pth,pr};
varargout=varns(1:nargout);


