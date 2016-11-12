function [M,I,IMR2,Rs,x]=imr(rhor,r,meth)
% [M,I,IMR2,Rs,x]=IMR(rhor,r,meth)
%
% Calculates mass (M), moment of inertia (I), and reduced moment of
% inertia (IMR2) of a spherically symmetric planet.
%
% INPUT:
%
% rhor     A set of N densities, e.g. [11000 3300], OR, for meth==3
%          a set of N coefficients, a_n expanding (r/Rs)^n as in POLYFIT,
%          ordered from the (N-1)st-degree polynomial to the 0th-degree one
% r        A set of N+1 radii whithin which the densties are constant,
%          e.g. [0 3480e3 6371e3], OR,
%          the single radius of the planet (internally: Rs) for meth==3
% meth     Method 0 piecewise constant via a loop
%                 1 piecewise constant without a loop 
%                 2 piecewise constant with a moment function within
%                 3 polynomial expansion for rho(r/Rs)=sum_{n=0}^N a_n (r/Rs)^n
%
% NOTE: You'll see different precisions and speeds with varying methods!
%
% OUTPUT:
%
% M        Mass of a spherically symmetry layered set of shells
% I        Moment of inertia of such a planet
% IMR2     Reduced moment of inertia, 2/5 for a homogeneous sphere 
% Rs       Planetary radius, which is obviously derived from the input
% x        Error estimate, if possible, via analytical means
%
% EXAMPLES:
%
% [M,I,IMR2,Rs,x]=imr(5515,[0 6371e3],0); % Fits Earth mass but not its MOI
% [M,I,IMR2,Rs,x]=imr(4558,[0 6371e3],0); % Fits Earth MOI BUT NOT ITS mass
% [M,I,IMR2,Rs,x]=imr(4558,6371e3,3); % Alternative calculation for the above
% [M,I,IMR2,Rs,x]=imr([12492 4150],[0 3485e3 6371e3],0) % Fits Earth MOI and mass
%
% TESTING:
%
% N=100; rhom=5515; rhostd=200;
% [M,I,IMR2,Rs]=imr(rhom+rhostd*randn(1,N),linspace(0,6371e3,N+1),1);
% N=100; rhomax=12492; rhomin=0; Rs=6371e3;
% [M,I,IMR2]=imr(linspace(rhomax,rhomin,N),linspace(0,Rs,N+1),1)
% [M,I,IMR2]=imr([-rhomax rhomax],Rs,3)
%
% Last tested on MATLAB Version: 8.3.0.532 (R2014a)
% Last modified by fjsimons-at-alum.mit.edu, 11/11/2016

% Make inputs into column vectors, sorted from small to planetary radius
% Don't do this for the polynomial expansion method! 
rhor=rhor(:); 
if length(r)>1
  % Sort the radii 
  [r,ir]=sort(r(:));
  % If the sorting flipped the order, flip the densities as well
  if ir(1)>ir(end); rhor=flipud(rhor); end
end
 
% Radius of the entire planet
Rs=r(end);

% Moment of inertia (I),  mass (M) and reduced moment (IMR2)
switch meth
 case 3
  % Now the rhor are expansion coefficients, not actually densities
  % The mass is a ZEROTH moment of the density distribution
  M=    wmoment(rhor,Rs,0);
  % The moment of INERTIA is a second moment of the density distribution
  I=2/3*wmoment(rhor,Rs,2);
 case 2
  % Piecewise constant using an internally defined function
  % The mass is a ZEROTH moment of the density distribution
  M=    pmoment(rhor,r,0);
  % The moment of INERTIA is a second moment of the density distribution
  I=2/3*pmoment(rhor,r,2);
 case 1
  % Piecewise constant without a "for" loop
  I=2/3*Rs^5/5*4*pi*rhor'*diff([r/Rs].^5);
  M=    Rs^3/3*4*pi*rhor'*diff([r/Rs].^3);
 case 0
  % Piecewise constant via a "for" loop
   I=0; M=0;
   for index=1:length(rhor)
     I=I+8/15*Rs^5*pi*rhor(index)*[(r(index+1)/Rs)^5-(r(index)/Rs)^5];
     M=M+ 4/3*Rs^3*pi*rhor(index)*[(r(index+1)/Rs)^3-(r(index)/Rs)^3];
   end
end

% Report the reduced moment also
IMR2=I/M/Rs^2;

% If we cannot do the next checks
x=NaN;

% Basic check for homogeneous model
if length(rhor)==1 && length(r)==2-(meth==3)
  x=IMR2-2/5; 
end
% Check a model with two homogeneous layers, the first half the radius
if length(rhor)==2 && length(r)==3 && isequal(r(3)/r(2),2)
  f=rhor(1)/rhor(2);
  x=IMR2-(f+31)/10/(f+7);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P=pmoment(rhor,r,p)
P=r(end)^(3+p)*4*pi*rhor'*diff([r/r(end)].^[3+p])/(3+p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P=wmoment(rhoc,Rs,p)
P=    Rs^(3+p)*4*pi*rhoc'*[1./([length(rhoc)-1:-1:0]'+3+p)];

