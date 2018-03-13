function [d,d00xy,dxyxy,dperp,p2,m2]=point2points(x1,y1,x2y2)
% [d,d00xy,dxyxy,dperp,p2,m2]=POIN2POINTS(x1,y1,x2y2)
%
% Distance of a set of points given as planar coordinates (x1,y1) to the
% least-squares line fit through the second set of points inside x2y2. 
% This makes the function essentially a wrapper around POINTDIST.
%
% INPUT:
%
% x1,y1     The planar coordinates of a first set of points considered
%           individually, whose distance to the second set is being computed
% x2y2      The planar coordinates of a set of points considered
%           together, whose least-squares regression line is the line to
%           which the distances of the first set of points are being computed
%
% OUTPUT:
%
% d        The distances of all (x1,y1) to the best-fite line through x2y2
% d00xy    Zero-origin direction-distance vectors from all points to line
% dxyxy    Two-point vectors from all points to the line 
% dperp    Zero-origin unit offset vector perpendicular to the line
% p2       The least-squares regression line thusly determined
% m2       The scaling that goes with that same least-squares line
%
% Last modified by fjsimons-at-alum.mit.edu, 03/12/2018

warning off MATLAB:polyfit:RepeatedPointsOrRescale
% Least-squares regression line, unscaled
p2=polyfit(x2y2(:,1),x2y2(:,2),1);
warning on MATLAB:polyfit:RepeatedPointsOrRescale

% Need to find a way to to the below with the scaled fitting, using m2 also
% Calculate the distances etc, or put in scaling?
[d,d00xy,dxyxy,dperp]=pointdist(x1,y1,[],[],[],p2);

% Least-squares regression line, properly scaled
[p2,~,m2]=polyfit(x2y2(:,1),x2y2(:,2),1);

