function [d,dvv,dvvv,dv]=pointdist(x1,y1,p1,x2,y2,p2)
% [d,dvv,dvvv,dv]=POINTDIST(x1,y1,p1,x2,y2,p2)
%
% Distance of a set of POINTS given as planar coordinates (x1,y1) to a LINE
% given as p2=[slope, intercept]. While the inputs p1 and (x2,y2) are
% neither needed nor used, the line p1=[slope, intercept] might be the
% least-squares best fit through (x1,y1) (e.g., through POLYFIT), and the
% given line p2 might exactly contain points (x2,y2) (e.g., through
% POLYVAL). The input slots for those unused variables are present for
% symmetry (e.g., when called by LINEDIST), and for some internal numbers
% checking, since deemed unnecessary.
% 
% INPUT:
%
% x1,y1,p1  The coordinates (x, y, and POLYFIT) of line 1
%           p1 is NOT used, but provided for symmetry
% x2,y2,p2  The coordinates (x, y, and POLYFIT) of line 2
%           x2 and y2 are NOT used, but provided for symmetry
% 
% OUTPUT:
%
% d         The distances of the points (x1,y1,~) to line p2
% dvv       Zero-origin direction-distance vectors from all (x1,y1,~) to line p2
% dvvv      Two-point vectors from all the points (x1,y1,~) to line p2
% dv        Zero-origin unit offset vector perpendicular to line p2
%
% NOTE:
%
% This code uses the slope and intercept formulation of the target line,
% whereas POINT2LINE uses its points themselves. See also LINEDIST.
%
% EXAMPLE:
%
% x0=1; x1=-2; x2=3; y0=-4; y1=-5; y2=6;
% d1=point2line(x1,x2,y1,y2,x0,y0);
% [d2,d3,d4,d5]=pointdist(x0,y0,[],x2,y2,polyfit([x1 x2],[y1 y2],1));
%% The point whose distance to the line you seek
% plot(x0,y0,'+'); hold on; axis image ; grid on
%% The two points defining the line
% plot([x1 x2],[y1 y2],'k');
%% The vector pointing from the special point to the line
% plot([d4(1) d4(3)],[d4(2) d4(4)],'g'); hold off
%
% SEE ALSO:
% http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html
%
% Last modified by fjsimons-at-alum.mit.edu, 03/11/2018

% Straighten out input
x1=x1(:); y1=y1(:);
x2=x2(:); y2=y2(:);

% Distances of all points on line 1 to line 2
d=abs(-p2(1)*x1+y1-p2(2))/sqrt(1+p2(1)^2);

% Unsigned unit direction vector from any point on line 1 to line 2
dv=[-p2(1) 1]; 
dv=dv/norm(dv);

% The actual-distance vectors from every point on line 1 to line 2
dvv=[d d].*repmat(dv,length(d),1);

% All the vectors that connect the points (x1,y1) to the line (x2,y2)
% Figure out the correct sign by making sure it goes from line 1 to line 2
% Add this with the correct sign and you should get a point on line 2
% So the results must lie on the same line as any two points on line 2 
% So the slopes of the line between the new points and the origin of line 2
% must be identical to the slope p2(2) to some reasonable amount of precision
% [[dvvv(:,4)-y2(1)]./[dvvv(:,3)-x2(1)]-p2(1),[dvvv(:,6)-y2(1)]./[dvvv(:,5)-x2(1)]-p2(1)]
% [dvvv(:,4)-polyval(p2,dvvv(:,3)) dvvv(:,6)-polyval(p2,dvvv(:,5))]
dvvv=[[x1 y1]-dvv];
tolz=1e-8;
% If the condition is satisfied keep the negative sign
cndi=abs(p2(1)*dvvv(:,1)+p2(2)-dvvv(:,2))<tolz;
dvv=(-1).^repmat(cndi,1,2).*dvv;
% The two-point vectors, one for every point in (x1,y1) are rows in dv
dvvv=[[x1 y1] [x1 y1]+dvv];


