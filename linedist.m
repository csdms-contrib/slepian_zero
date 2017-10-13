function [d,dvv]=linedist(x1,y1,p1,x2,y2,p2)
% [d,dv,dvv]=LINEDIST(x1,y1,p1,x2,y2,p1)
%
% Given two sets of coordinates that each define a PERFECT line in the
% plane, as, e.g. determined by LINESHIFT, determines the distance between
% the two lines, which needn't be parallel, as the MEDIAN of the
% perpendicular distances of all the points in one of the lines with respect
% to the other line (and vice versa), using POINTDIST..
%
% INPUT:
%
% x1,y1,p1    The coordinates (x, y, and POLYFIT) of the first line
% x2,y2,p2    The coordinates (x, y, and POLYFIT) of the second line
%
% OUTPUT:
%
% d           The best distance between these lines
% dv          The offset vector to bring line 1 to line 2
%
% SEE ALSO:
%
% CURVEDIST, POINTDIST, POINT2LINE, POINT3LINE, LINESHIFT
%
% Last modified by fjsimons-at-alum.mit.edu, 10/12/2017

% Straighten out input
x1=x1(:); y1=y1(:);
x2=x2(:); y2=y2(:);

% Figure out the point-to-line distance of line 1 onto 2
[d12,dvv12,dvvv12]=pointdist(x1,y1,p1,x2,y2,p2);
% Figure out the point-to-line distance of line 2 onto 1
[d21,dvv21,dvvv21]=pointdist(x2,y2,p2,x1,y1,p1);

% Now quote a single number as "the" distance
d=median([d12 ; d21]);
% And define the proper offset as that which best applies
[~,witsj]=min(abs([d12 ; d21]-d));
dvv=rindeks([dvv12 ; dvv21],witsj);
% But then you need to remember if this was the shift from 1 to 2 or from
% 2 to 1 so we will ALWAYS quote the offset to go from line 1 to line 2
if witsj>length(d12)
  % Then it was from 2 to 1 so we change the signs
  dvv=-dvv;
end

defval('ifpo',0)
% Make some plots to verify that it all works
if ifpo==1
  pl1=plot(x1,y1,'b'); hold on
  pl2=plot(x2,y2,'r');
  for in=1:length(dvvv12)
    p12(in)=plot(dvvv12(in,[1 3]),dvvv12(in,[2 4]),'g-'); 
  end
  for in=1:length(dvvv21)
    p21(in)=plot(dvvv21(in,[1 3]),dvvv21(in,[2 4]),'r--'); 
  end
  hold off
end
