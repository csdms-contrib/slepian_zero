function varargout=curvedist(x1,y1,x2,y2,plotit,plotthat,orien)
% [d,EX,WY,ph]=CURVEDIST(x1,y1,x2,y2,plotit,plotthat,orien)
%
% Calculates the distance between two near-vertical or near-horizontal
% smooth curves, each of them splining a "layer" and returning the "layer
% thickness". The points are triplets, three points on each interface. The
% curves shouldn't cross.
%
% INPUT:
%
% x1,x2     The x points of the triplets
% y1,y2     The y points of the triplets
% plotit    1 Plots stuff [default]
% plotthat  1 Plots more stuff [default]
% orien     'vertical' [default]
%           'horizontal' [default]
%
% OUTPUT:nn
%
% d       The distance between the curves
% EX      The x points defining the distance
% WY      The y points defining the distance
% ph      The line handle
%
% EXAMPLE:
%
% Called without argument, gives an example
% 
% Last modified by fjsimons-at-alum.mit.edu, 11/11/2015

defval('plotit',1)
defval('plotthat',1)
defval('ph',[])
defval('orien','vertical')

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
switch orien
  case 'vertical'
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
   % Compute the distances
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
 case 'horizontal'
   xx=[linspace(min([x1 x2]),max([x1 x2]),100+1)];
   % Fits a spline through the pairs of three points
   yy1=spline(x1,y1,xx);
   yy2=spline(x2,y2,xx);
   % This only for testing
   if plotthat==1
     plot(x1,y1,'bo')
     hold on
     plot(x2,y2,'rs')
     plot(xx,yy1)
     plot(xx,yy2)
     hold off
   end
   % Compute the distances
   dc=zeros(length(yy1),1);
   dci=zeros(length(yy1),1);
   for index=1:length(yy1)
     % All the distances between this point and all the others; take the minimum
     [dc(index),dci(index)]=min(sqrt((yy1(index)-yy2).^2+(xx(index)-xx).^2));
     % This only for testing
     if plotthat==1
       hold on
       p=plot([xx(index) xx(dci(index))],[yy1(index) yy2(dci(index))],'g');
     end
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
switch orien
  case 'vertical'
   xd1=xx1(di(whereat(1)));
   yd1=yy(di(whereat(1)));
   xd2=xx2(dci(whereat(1)));
   yd2=yy(dci(whereat(1)));
 case 'horizontal'
   xd1=xx(di(whereat(1)));
   yd1=yy1(di(whereat(1)));
   xd2=xx(dci(whereat(1)));
   yd2=yy2(dci(whereat(1)));
end
% Check that the result is the formal median
difer(d-median(ds),[],[],NaN)

% The final distance line segment
EX=[xd1 xd2];
WY=[yd1 yd2];

if plotit==1
  hold on
  ph=plot(EX,WY,'k');
  hold off
  % Only for testing
  if plotthat==1
    axis equal tight
    switch orien
     case 'vertical'
      xlim([min([xx1 xx2]) max([xx1 xx2])])
     case 'horizontal'
      ylim([min([yy1 yy2]) max([yy1 yy2])])
    end
  end
end

% Output 
varns={d,EX,WY,ph};
varargout=varns(1:nargout);
