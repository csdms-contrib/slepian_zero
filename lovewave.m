function ziro=lovewave(cLT,beta1,beta2,h,rho1,rho2,n)
% ziro=LOVEWAVE(cLT,beta1,beta2,h,rho1,rho2,n)
%
% For a layer-over-a-halfspace model expresses the phase-speed relation
% of the Love wave in function of the period T. If the phase speed of the
% Love wave is a solution, then the function evaluates to zero! Used with
% FMINBND in LOVE1 and LOVE2. 
% 
% INPUT:
%
% c      Love-wave phase velocity [m/s]
% T      Love-wave period [s]
% beta1  Shear-wave speed in the layer
% beta2  Shear-wave speed in the halfspace
% h      Layer thickness [m]
% rho1   Density in the layer
% rho2   Density in the halfspace
% n      Mode/overtone/harmonic number
%
% See LOVE1 and LOVE2
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2017

% The "period equation"
mu1=beta1^2*rho1;
mu2=beta2^2*rho2;
omega=2*pi/T;
eta1=sqrt((cL/beta1).^2-1);
eta2=sqrt(1-(cL/beta2).^2);
ziro=abs(omega./cL*h.*eta1-atan(mu2*eta2/mu1./eta1)-n*pi);
