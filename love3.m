function love3
% Plots layer-over-a-halfspace Love-wave eigenmodes
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
T=[1 2 3];
% Angular frequency
omega=2*pi./T;

% Minimization options
OPTIONS=[];

modes=[0 1 2 3];
for ondex=1:length(modes)
  for index=1:length(T)
    [c(ondex,index),ziro(ondex,index)]=fminbnd('lovewave',beta1,beta2,OPTIONS,...
        T(index),beta1,beta2,h,rho1,rho2,modes(ondex));
  end
end
c(ziro>0.01)=NaN;

zmax=450000;

zlayer=linspace(0,h,100);
zhalf=linspace(h,zmax,100);

% Make the plot
ah=krijetem(subnum(1,length(modes)));

for index=1:length(ah)
  axes(ah(index))
  ln(index)=fillbox2([0 2.1 0 40 ],[0.9 0.9 0.9]);
  hold on
end

for ondex=1:length(modes)
  for index=1:length(T)      
    uy=partmot1(zlayer,T(index),c(ondex,index),beta1);
    axes(ah(ondex))
    pl(ondex,index)=plot(max(uy,[],1),zlayer/1000);
    hold on
    uyend(ondex,index)=uy(end);
  end
end

for ondex=1:length(modes)
  for index=1:length(T)      
    uy=partmot2(zlayer,T(index),c(ondex,index),beta2);
    uy=uy/uy(1)*uyend(ondex,index);
    axes(ah(ondex))
    plh(ondex,index)=plot(max(uy,[],1),zhalf/1000);
  end
end

% Cosmetics
yl=[0 2.1];
set(ah,'xlim',yl)
set(ah,'ylim',[0 100])
set(ah,'Ydir','rev')

axes(ah(1))
ylb(1)=ylabel('Depth (km)');
for index=1:length(ah)
  axes(ah(index))
  xl(index)=xlabel('displacement');
  tl(index)=title(sprintf('n= %i',modes(index)));
end

set([pl plh],'Linew',2,'Color','k')

fig2print(gcf,'landscape')

set([gca xl ylb tl],'FontS',12)
longticks(ah)
nolabels(ah(2:4),2)


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
