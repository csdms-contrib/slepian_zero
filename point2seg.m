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
%% The points
% x0=[ 1  2  3 -1 -2 -3 -1 -2 -1 -2  3]; x0=(-1).^randi(2,10,1).*randi(10,10,1);
% y0=[-4 -5 -6  4  5  6 -7  7 -8  8  8]; y0=(-1).^randi(2,10,1).*randi(10,10,1);
%% The line segment
% x1=-2; y1=-5; x2=3; y2=6;
% [d,xyd]=point2seg([x0(:) y0(:)],[x1 y1 x2 y2]);
%% The point whose distance to the line you sought
% plot(x0,y0,'+'); hold on; grid on ;  axis equal ; axis([-11 11 -11 11]); axis manual
%% The two points defining the line segment
% plot([x1 x2],[y1 y2],'k');
%% The vector pointing from the requested point to the line via the
%% shortest distance defined in this way...
% for i=1:size(xyd,1)
%  plot([xyd(i,1) xyd(i,3)],[xyd(i,2) xyd(i,4)],'g'); 
% end
% hold off
% 
% Last modified by fjsimons-at-alum.mit.edu, 10/12/2017

% The points of interest
x0=x0y0(:,1)
y0=x0y0(:,2);
% The line segment of interest
x1=x1y1x2y2(1);
y1=x1y1x2y2(2);
x2=x1y1x2y2(3);
y2=x1y1x2y2(4);

% Use POINTDIST to help us out
[d,~,xyd]=pointdist(x0,y0,[],[],[],polyfit([x1 x2],[y1 y2],1));

% If any of the distances of the end points to the segment points are
% greater than the distance between the end points themselves, you have
% clearly missed the segment, and you need to adjust.
d12=sqrt([x2-x1].^2+[y2-y1].^2);
dt12=[sqrt([xyd(:,3)-x1].^2+[xyd(:,4)-y1].^2) ...
      sqrt([xyd(:,3)-x2].^2+[xyd(:,4)-y2].^2)];
% Where you have missed the segment, in either point
msg=dt12(:,1)>d12 | dt12(:,2)>d12;
sms=sum(msg);
if sms>0
  [mv,mi]=min(dt12,[],2);
  % Replace the target points based on the distance...
  repl=repmat(x1y1x2y2,sms,1);
  % There has to be a simpler way, but what the heck
  xyd(msg,3:4)=repl(sub2ind([sms 4],[1:sms ; 1:sms]',[-1 0]+2*mi(msg)));
  % before you can use the same logic to change the distance
  d(msg)=mv(msg);
end	

