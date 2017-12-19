function varargout=planefit(data)
% [a,b,c,X,Y,Z]=PLANEFIT(data)
% 
% Fits a plane through a plaid data set by least-squares regression
%
% INPUT:
% 
% data       The data matrix, considered "plaid"
%
% OUTPUT:
%
% a, b, c    The coefficients of the equation a*X+b*Y+c=Z
% X,Y        A suitable domain for the data set
% Z          The best-fitting plane defined on X and Y
%
% SEE ALSO:
%
% PLANEF
%
% EXAMPLE:
%
% planefit('demo1')

% Written by FJS, September 26th 1998
% fjsimons-at-mit.edu

if ~isstr(data)

  [m,n]=size(data);
  x=1:n;
  y=1:m;

  [X,Y]=meshgrid(x,y);

  Xv=X(:);
  Yv=Y(:);
  Dv=data(:);
  
  % Find the sensitivity matrix
  jacob=[Xv Yv repmat(1,m*n,1)];

  % Find the coefficients by the generalized inverse
  abc=geninv(jacob,Dv);

  % Prepare outputs
  [a,b,c]=deal(abc(1),abc(2),abc(3));

  if nargout>=6
    Z=planef(abc,x,y,0);
  else
    Z=[];
  end

  varns={a,b,c,X,Y,Z};
  varargout=varns(1:nargout);

elseif strcmp(data,'demo1')
  % Note: in this example, the domain on which the data are
  % defined is not just the data indices. Therefore, planefit will be
  % successful in fitting the x and y slopes, but not the offset.

  % Create a domain and some random planar coefficients
  x=-23:50; y=-12:67; abc=guess(3)/10; 
  % Create data with some variance about the plane in question
  data=planef(abc,x,y,0);
  data=data+10*rand(1)*randn(size(data));
  % Find what that plane would have been through regression
  [a,b,c,X,Y,Z]=planefit(data);
  subplot(221); surf(X,Y,data); shading flat; axis tight
  zizi=zlim;
  xlabel('x');  ylabel('y'); zlabel('z')
  title(sprintf('z=%3.1fx+%3.1fy+%3.1f',abc(1),abc(2),abc(3)),...
	'FontSize',15)
  subplot(222); surf(X,Y,Z); shading flat; axis tight
  xlabel('x');  ylabel('y'); zlabel('z')
  set(gca,'ZLim',zizi)
  % Plot the plane again
  subplot(223); surf(x,y,data); shading flat; axis tight
  % Plot the residuals
  subplot(224); surf(X,Y,Z-data); shading flat; axis tight
  set(gca,'ZLim',zizi)
end
