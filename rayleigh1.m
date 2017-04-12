function rayleigh1
% RAYLEIGH1
%
% Plots Rayleigh-wave particle motion with depth;
% particle motion for amplitude coefficient A=1.
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2017

% Rayleigh-wave period [s]
T=50;
% Rayleigh-wave phase speed  [m/s]
c=4500; 

% Angular frequency
omega=2*pi/T;
% Wavenumber from the dispersion relation
k=omega/c;

ah(1)=subplot(131);
% AT THE SURFACE
z=0;
[ux,uz]=partmot(z,T,c);
plot(ux,uz,'k'); axis equal ; axis([-0.5 0.5 -0.75 0.75]) 
markers(ux,uz)
title('z= 0')
xlabel('u_x/(Ak)')
ylabel('u_z/(Ak)')

ah(2)=subplot(132);
% AT THE DEPTH WHERE THE PARTICLE MOTION BECOMES LINEAR
z=2*pi/k/5.3;
[ux,uz]=partmot(z,T,c);
plot(ux,uz,'k'); axis equal; axis([-0.5 0.5 -0.75 0.75]) 
markers(ux,uz)
title('z= \lambda/5.3')
xlabel('u_x/(Ak)')

ah(3)=subplot(133);
% AT TWICE THE DEPTH WHERE THE PARTICLE MOTION BECOMES LINEAR
z=2*pi/k/5.3*2;
[ux,uz]=partmot(z,T,c);
plot(ux,uz,'k');  axis equal; axis([-0.5 0.5 -0.75 0.75]) 
markers(ux,uz)
title('z= 2\lambda/5.3')
xlabel('u_x/(Ak)')

% Cosmetics
set(ah,'ydir','rev')
nolabels(ah(2:3),2)
figc
ah(4)=axes('Position',[0.3 0.2 0.4 0.04]);
markers([1:10]/10,repmat(0,1,10))
nolabels(ah(4),2)
noticks(ah(4),2)
set(ah(4),'ycolor',[1 1 1],'XTick',[1:10]/10,'xlim',[1 10]/10)
xlabel('Normalized time')
axisc
serre(ah(1:3),1/3,'across')
figc
moveh(ah(4),0.05)

% Final printing
fig2print(gcf,'landscape')

% Particle motion for a single period, see RAYLEIGH2
function [ux,uz]=partmot(z,T,c);
omega=2*pi./T;
k=omega/c;
t=0:0.1:T;
ddux=exp(-z*k*0.85)-0.58*exp(-z*k*0.39);
dduz=-0.85*exp(-z*k*0.85)+1.47*exp(-z*k*0.39);
x=0;
ux=-sin(k*x-omega.*t)*ddux;
uz=cos(k*x-omega.*t)*dduz;

% Markered plot
function markers(ux,uz)
hold on
windm=10;
wind=ceil(linspace(1,length(ux),windm));
for index=1:windm
  pm(index)=plot(ux(wind(index)),uz(wind(index)),'o');
  set(pm(index),'MarkerE','k','MarkerF',[1 1 1]*(index-1)/windm)
end
hold off

% TO FIGURE OUT c=0.92\beta
%r=0:0.001:1;
%R1=1/2.*(r.^2-2)./sqrt(1-r.^2/3);
%R2=-sqrt(1-r.^2)./(1-r.^2/2);
%plot(r,R1)
%hold on
%plot(r,R2)
%clf
%plot(r,R1-R2)
%clf

