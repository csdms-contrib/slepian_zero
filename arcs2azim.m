function [Xa,Ya,Ra,XX,YY]=arcs2azim(X,Y,Ta)
% [Xa,Ya,Ra,XX,YY]=ARCS2AZIM(X,Y,Ta)
%
% For a series of n=1,...,N_M points belonging to m=1,...,M
% approximate circles in a coordinate system centered on the origin of
% those circles, calculates the radius of the circles in question
% along a certain azimuth. First approach is as a linear
% interpolant between any two points adjacent to the target
% azimuths. Later refinements could take more points at a time, or
% actually calculate the circle arc, etc. 
%
% INPUT:
%
% X       NxM zero-padded matrix of x-coordinates of M circle segments 
% Y       NxM zero-padded matrix of y-coordinates of M circle segments
% Ta      an azimuth, in degrees clockwise from NORTH
%
% OUTPUT:
%
% Xa,Ya    the interpolated Cartesian points corresponding to the (Ra,Ta)
% Ra       radius of each of the M presumed circles in the azimuth Ta
% XX,YY    the points bracketing the requested azimuth
%
% EXAMPLE:
%
% M=5; for index=1:M; [Xc(:,index),Yc(:,index)]=randcirc(0,0,index,0.1*index); end
% [X,Y]=deal(nan(size(Xc))); for index=1:M; pix=unique(randi(size(Xc,1),size(Xc,1),1));
%                                X(1:length(pix),index)=Xc(pix,index);
%                                Y(1:length(pix),index)=Yc(pix,index); end
% plot(Xc,Yc); hold on; plot(X,Y,'.'); axis image; axis([-1 1 -1 1]*6)
% Ta=randi(360); plot(0,0,'+')
% [Xa,Ya,Ra,XX,YY]=arcs2azim(X,Y,Ta);
% plot(XX,YY,'o'); plot(Xa,Ya,'+');
% plot([0 Xa(end)],[0 Ya(end)]); hold off; longticks(gca,2)
% t=title(sprintf('azimuth clockwise from North %i%s',Ta(1),176)); grid on
% movev(t,range(ylim)/40);
% 
% Last modified by fjsimons-at-alum.mit.edu, 11/3/2022

% Always add a row of NaNs to make sure you have one
X=[X ; nan(1,size(X,2))];
Y=[Y ; nan(1,size(Y,2))];

% Transform all Cartesian coordinates to polar ones clockwise from North
T=90-cart2pol(X,Y)/pi*180; T(T<0)=T(T<0)+360;
% Sort from N to E to S to W to N i.e. clockwise from North
[T,j]=sort(T,1); s=ro2co(size(X),j);
X=X(s);
Y=Y(s);

% Periodize by making the first equal to the last non-NaN
X=[X(ro2co(size(X),sum(~isnan(X)))) ; X];
Y=[Y(ro2co(size(Y),sum(~isnan(Y)))) ; Y];
% Recompute the azimuth but keep the minus sign
T=[90-cart2pol(X(1,:),Y(1,:))/pi*180 ; T];

% Find the azimuths T that bracket the requested azimuth Ta
% The flag takes care of cases of incomplete orbits that don't go past 270...
% I may end up removing this again
flag=T(1,:)<=Ta;
t=ro2co(size(X),sum(T<=Ta)+~flag);

% Periodize by making the first NaN equal to the now second element
X(ro2co(size(X),sum(~isnan(X))+1))=X(2,:);
Y(ro2co(size(Y),sum(~isnan(Y))+1))=Y(2,:);

% Now find the bracketing points, they never exceed what's allowable
XX=X([t ; t+1]);
YY=Y([t ; t+1]);

% Now find the interpolants as the Cartesian coordinates that form the
% intersection formed by the line formed by the bracketing points and
% the target azimuth... https://mathworld.wolfram.com/Line-LineIntersection.html

% The first point along the azimuth is (0,0)
% Find a second point along the azimuth on the unit circle, our convention
x2=sin(Ta*pi/180);
y2=cos(Ta*pi/180);
% Now apply the formula for the intersection with every pair
Xa=nan(1,size(X,2));
Ya=nan(1,size(Y,2));

for index=1:size(X,2)
    [Xa(index),Ya(index)]=intersex([0 0],[x2 y2],...
                                   [XX(1,index) YY(1,index)],...
                                   [XX(2,index) YY(2,index)]);
end
% Calculate the distance to the center of all those points
Ra=sqrt(Xa.^2+Ya.^2);
% Compute ALL the azimuths which should be the same
Tas=[90-cart2pol(Xa,Ya)/pi*180]; Tas(Tas<0)=Tas(Tas<0)+360;

if abs(sum(Tas-Ta))>1e-6
    error('Something wrong')
end

% Function to carry row selection over to columns
function s=ro2co(sX,j)
s=sub2ind(sX,j,repmat(1:size(j,2),size(j,1),1));

% Function to calculate the intersection between two lines defined by pairs of points 
function [x,y]=intersex(xy1,xy2,xy3,xy4)
x1=xy1(1); y1=xy1(2);
x2=xy2(1); y2=xy2(2);
x3=xy3(1); y3=xy3(2);
x4=xy4(1); y4=xy4(2);
d1=det([x1 y1 ; x2 y2]);
d2=det([x3 y3 ; x4 y4]);
d3=det([x1-x2 y1-y2 ; x3-x4 y3-y4]);
x=det([d1 x1-x2 ; d2 x3-x4])/d3;
y=det([d1 y1-y2 ; d2 y3-y4])/d3;

