function love2
% LOVE2
% 
% Plots Love-wave particle motion maximum absolute displacement over an
% entire period; particle motion for amplitude coefficient A=1.
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2017

% Default values for input to LOVEWAVE

% Shear-wave speed in the layer [m/s]
defval('beta1',3800)
% Shear-wave speed in the halfspace [m/s]
defval('beta2',4500)
% Density in the layer [m/s]
defval('rho1',3000)
% Density in the halfspace[m/s]
defval('rho2',3360)
% Thickness of the layer [m]
defval('h',40000)
% Periods [s]
T=[1 10:10:100 1000];
% Angular frequency
omega=2*pi./T;

% Minimization options
OPTIONS=[];

modes=[0];
for ondex=1:length(modes)
  for index=1:length(T)
    [c(ondex,index),ziro(ondex,index)]=fminbnd('lovewave',beta1,beta2,OPTIONS,...
        T(index),beta1,beta2,h,rho1,rho2,modes(ondex));
  end
end
c(ziro>0.01)=NaN;

% Wavenumber
k=omega./c;
% Wavelength
lambda=2*pi./k;
zmax=450000;

zlayer=linspace(0,h,100);
zhalf=linspace(h,zmax,100);

ln=fillbox2([0 40 0 2],[0.9 0.9 0.9]);

hold on
% Particle motion in the layer
for index=1:length(T)
  uy=partmot1(zlayer,T(index),c(index),beta1);
  pl(index)=plot(zlayer/1000,max(uy,[],1));
  hold on
  uyend(index)=uy(end);
end

% Particle motion in the halfspace
for index=1:length(T)
  uy=partmot2(zlayer,T(index),c(index),beta2);
  uy=uy/uy(1)*uyend(index);
  plh(index)=plot(zhalf/1000,max(uy,[],1));
end

yl=[0 2.1];
ylim(yl)
xlim([0 225])
ylb(1)=ylabel('Love-wave displacement magnitude');
xl(1)=xlabel('depth (km)');

% Cosmetics
fig2print(gcf,'landscape')
set([pl plh],'Linew',2,'Color','k')
post=[44.5448   0.0379
      66.       0.3980
      66.       0.8264
      66.       1.1675
      67.       1.4025
      66.       1.5693
      66.       1.6792
      66.       1.7551
      82.2616   1.7968
      101.4451  1.8271
      122.2543  1.8498
      134.9350  1.9977];
fb=fillbox2(...
    [post(:,1)-5 post(:,1)+5 post(:,2)+0.03 post(:,2)-0.03],'w');
for index=1:length(T)
  to(index)=text(post(index,1),post(index,2),...
      num2str(T(index)));
end
fb(index+1)=fillbox2([12.35-10,12.35+10,0.0796+0.03,0.0796-0.03],'w');
to(index+1)=text(12.35,0.0796,'Period (s)');
set(to,'horizontala','center')

set([gca xl ylb],'FontS',12)
longticks


% PARTICLE MOTION IN LAYER
function uy=partmot1(z,T,c,beta1);
omega=2*pi./T;
k=omega/c;
x=0;
t=linspace(0,T,50);
[ZZ,TT]=meshgrid(z,t);
uy=real(2*exp(-i*omega*(TT-x/c)).*cos(k*ZZ*sqrt((c/beta1)^2-1)));

% PARTICLE MOTION IN HALFSPACE
function uy=partmot2(z,T,c,beta2);
omega=2*pi./T;
k=omega/c;
x=0;
t=linspace(0,T,50);
[ZZ,TT]=meshgrid(z,t);
uy=real(exp(-i*omega*(TT-x/c)).*exp(-(k*ZZ*sqrt(1-(c/beta2)^2))));
