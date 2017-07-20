function varargout=lineshift(x,y,dofs,sens,scl)
% [xofs,yofs,xs,ys,yy,x,y,p]=LINESHIFT(x,y,dofs,sens,scl)
%
% Shifts a set of scattered points along their best-fitting line.
%
% INPUT:
%
% x,y        The coordinates of the points
% dofs       The distance amount to be shifted [default: 1.5]
% sens       0 if the shift is down the line (any even number)
%            1 if the shift is up the line (any odd number)
% scl        'scaled' for stability [default]
%            'unscaled' without special treatment
%
% OUTPUT:
%
% xofs,yofs  The offsets that are being applied to the points
% xs,ys      The coordinates of the shifted points
% yy         The coordinates of the line at the original x coordinates
% x,y        The original coordinates of the input points
% p          The regression parameters
%
% Last modified by fjsimons-at-alum.mit.edu, 11/14/2012

% Set default
defval('meth','scaled');
defval('dofs',1.25);

%disp(sprintf('Using offset of %i',dofs))

% Format properly
x=x(:);
y=y(:);

% Fit and plot a line to these two
switch meth
 case 'scaled'
  % Determine the best-fitting line
  [p,~,m]=polyfit(x,y,1);
  % Scale the result
  p=[p(1)/m(2) p(2)-p(1)*m(1)/m(2)];
 case 'unscaled'
  % Determine the best-fitting line without scaling
  p=polyfit(x,y,1);
end

% Calculate the best-fitting line at the input x coordinates
yy=polyval(p,x);

% This is the distance offset by the pole
% Solve for the offset vector along the line
% x^2+y^2=dofs and y=p1(1)*x
% Calculate the offset in the upgoing/downgoing sense
% xofs=dofs/sqrt(1+p(1)^2)*(-1)^mod(sens,2);
% This wasn't working, need to make sure that you shift it always INTO
% the direction in which you were actually moving
xofs=dofs/sqrt(1+p(1)^2)*sign(x(1)-x(end));
yofs=xofs*p(1);

% Apply the offsets to form the new coordinates
xs=x+xofs;
ys=y+yofs;

% Output
varns={xofs,yofs,xs,ys,yy,x,y,p};
varargout=varns(1:nargout);
