function [d,xyd]=point2seg(x0y0,x1y1x2y2)
% [d,xyd]=POINT2SEG([x0 y0],[x1 y1 x2 y2])
%
% Distance of a point to a line SEGMENT, which ends up being either to an
% endpoint or two the perpendicular projection of the point onto the
% line, whichever is closer
%
% INPUT:
%
% x0 y0         Coordinates of a (set of) points
% x1 y1 x2 y2   Coordinates of a pair of points defining a line segment
%
% OUTPUT;
%
% d             The distance(s) of the point(s) to the line segment
% xyd           The coordinates of the point(s) on the segment with respect
%               to which the distance is being measured, which is either
%               an end point of the line segment, or a perpendicular projection
%
% EXAMPLE:
%
%% The point
% x0=1; y0=-4;
%% The line segment
% x1=-2; y1=-5; x2=3; y2=6;
% [d,xyd]=point2seg([x0(:) y0(:)],[x1 y1 x2 y2]) 
%% The point whose distance to the line you sought
% plot(x0,y0,'+'); hold on; axis image ; grid on
%% The two points defining the line segment
% plot([x1 x2],[y1 y2],'k');
%% The vector pointing from the requested point to the line via the
%% shortest distance defined in this way...
% plot([xyd(1) xyd(3)],[xyd(2) xyd(4)],'g'); hold off
% 
% Last modified by fjsimons-at-alum.mit.edu, 10/12/2017

% The points ofinterest
x0=x0y0(:,1);
y0=x0y0(:,2);
% The line segment of interest
x1=x1y1x2y2(1);
y1=x1y1x2y2(2);
x2=x1y1x2y2(3);
y2=x1y1x2y2(4);

% Use POINTDIST to help us out
[d,~,xyd]=pointdist(x0,y0,[],[],[],polyfit([x1 x2],[y1 y2],1));

% If the distances obtained are greater than the distance to either end
% point, you have clearly missed the segment, and you must replace
d1=sqrt([x0-x1].^2+[y0-y1].^2);
d2=sqrt([x0-x2].^2+[y0-y2].^2);
% Replace the target points based on the distance...
rp1=d1<d;
xyd(rp1,3:4)=repmat([x1 y1],sum(rp1),1);
% before you can use the same logic to change the distance
d(rp1)=d1(rp1);
% Now again for the second possible point
rp2=d2<d;
xyd(rp2,3:4)=repmat([x2 y2],sum(rp2),1);
d(rp2)=d2(rp2);
