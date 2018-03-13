function d=point2line(x1,x2,y1,y2,x0,y0)
% d=POINT2LINE(x1,x2,y1,y2,x0,y0)
%
% Calculates the perpendicular distance of a SINGLE point (x0,y0) onto the
% line with the PAIR of coordinates (x1,y1) and (x2,y2) in the plane.
%
% NOTE:
% 
% This code uses the TWO points of the target line themselves, whereas
% POINTDIST uses a slope and intercept formulation. See also LINEDIST.
%
% SEE ALSO:
% http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html
%
% Last modified by fjsimons-at-alum.mit.edu, 3/12/2018

d=abs([x2-x1]*[y1-y0]-[x1-x0]*[y2-y1])/sqrt([x2-x1]^2+[y2-y1]^2);
