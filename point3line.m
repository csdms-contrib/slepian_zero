function d=point3line(x1,x2,y1,y2,z1,z2,x0,y0,z0)
% d=POINT3LINE(x1,x2,y1,y2,z1,z2,x0,y0,z0)
%
% Calculates the perpendicular distance of a single point (x0,y0,z0) onto the
% line through the pair of coordinates (x1,y1,z1) and (x2,y2,z2). 
%
% INPUT
%
% x1,x2      Horizontal coordinates of two points on the target line
% y2,y2      Horizontal coordinates of two points on the target line
% z1,z1      Vertical coordinates of two points on the target line
% x0,y0,z0   Could be vectors denoting multiple single points
%
% SEE ALSO:
% http://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html
%
% EXAMPLE:
%
% 
% x1=1; x2=2; y1=3; y2=4; z1=3; z2 =3 ; x0= 2; y0=3.5; z0=3; 
% point2line(x1,x2, y1,y2,        x0,y0)
% point3line(x1,x2, y1,y2, z1,z2, x0,y0,z0)
%
% Last modified by fjsimons-at-alum.mit.edu, 07/6/2017

% Rename the points to vector coordinates
bx0=[x0 y0 z0]; N=size(bx0,1);
bx1=[x1 y1 z1];
bx2=[x2 y2 z2];

% Initialize
d=nan(N,1);

% The distance, will vectorize properly, later
for index=1:N
  d(index)=norm(...
      cross(bx0(index,:)-bx1,bx0(index,:)-bx2))...
	   ./norm(bx2-bx1);
end
