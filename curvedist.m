function varargout=curvedist(x1,y1,x2,y2,plotit,plotthat)
% [d,EX,WY,ph]=CURVEDIST(x1,y1,x2,y2,plotit,plotthat)
%
% Calculates the distance between two smooth curves, each of them
% describing a "layer" and returning the "layer thickness". The points
% are triplets, three points on each interface. The curves shouldn't cross.
%
% INPUT:
%
% x1,x2   The x points of the triplets
% y1,y2   The y points of the triplets
%
% OUTPUT:
%
% d       The distance between the curves
% EX      The x points defining the distance
% WY      The y points defining the distance
% ph      The line handle
% 
% Last modified by fjsimons-at-alum.mit.edu, 11/09/2011

defval('plotit',1)
defval('plotthat',1)
defval('ph',[])

defval('x1',[1 23 40]+randn(1,3)*1)
defval('y1',[100 50 3]+randn(1,3)*1)
defval('x2',[5 27 47]+randn(1,3)*1)
defval('y2',[100 50 3]+randn(1,3)*1)

% Make sure the data is presented as a row vector
x1=x1(:)';
x2=x2(:)';
y1=y1(:)';
y2=y2(:)';

% Tested for both even- and odd-length arrays
%yy=[linspace(min([y1 y2]),max([y1 y2]),100+round(rand))];
yy=[linspace(min([y1 y2]),max([y1 y2]),100+1)];

% Fits a spline through the pairs of three points
xx1=spline(y1,x1,yy);
xx2=spline(y2,x2,yy);

% This only for testing
if plotthat==1
  plot(x1,y1,'bo')
  hold on
  plot(x2,y2,'rs')
  plot(xx1,yy)
  plot(xx2,yy)
  hold off
end

dc=zeros(length(xx1),1);
dci=zeros(length(xx1),1);
for index=1:length(xx1)
  % All the distances between this point and all the others; take the minimum
  [dc(index),dci(index)]=min(sqrt((xx1(index)-xx2).^2+(yy(index)-yy).^2));
  % This only for testing
  if plotthat==1
    hold on
    p=plot([xx1(index) xx2(dci(index))],[yy(index) yy(dci(index))],'g');
  end
end
% Now take the median of the minimum distances
[ds,di]=sort(dc);
% And sort the indices to the corresponding points accordingly
dci=dci(di);
if mod(length(dc),2)
  % disp('Odd')
  % For an odd-length array
  whereat=ceil(length(dc)/2);
  % The distance
  d=ds(whereat);
else
  % disp('Even')
  % For an even-length array
  whereat=length(dc)/2+[0 1];
  % The distance
  d=mean(ds(whereat));
end
% Make no difference between odd and even as what lies to the right
% or the left of the median may or may not be close to the x,y points
% Slight disadvantage of the visualization is that the median distance is
% not quoted exactly at the point where the median is reached
xd1=xx1(di(whereat(1)));
yd1=yy(di(whereat(1)));
xd2=xx2(dci(whereat(1)));
yd2=yy(dci(whereat(1)));
% Check that the result is the formal median
difer(d-median(ds),[],[],NaN)

EX=[xd1 xd2];
WY=[yd1 yd2];

if plotit==1
  hold on
  ph=plot(EX,WY,'k');
  hold off
  % Only for testing
  if plotthat==1
    axis equal tight
    xlim([min([xx1 xx2]) max([xx1 xx2])])
  end
end

% Output 
varns={d,EX,WY,ph};
varargout=varns(1:nargout);
