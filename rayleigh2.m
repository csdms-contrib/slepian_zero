function rayleigh2
% RAYLEIGH2
%
% Plots Rayleigh-wave particle motion maximum displacement over an entire
% period; particle motion for amplitude coefficient A=1.
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2017

% Rayleigh-wave period [s]
T=[10:10:100];
% Rayleigh-wave phase speed  [m/s]
c=4500; 

% Angular frequency
omega=2*pi./T;
% Wavenumber from the dispersion relation
k=omega/c;
% Wavelength
lambda=2*pi./k;

% Depth scale
z=linspace(0,max(lambda),100);

% One line for every period
for index=1:length(T)
  [ux,uz]=partmot(z,T(index),c);
  pl(index)=plot(z/1000,sqrt(max(ux,[],1).^2+max(uz,[],1).^2));
  hold on
end

% Cosmetics
set(pl,'linew',2,'col','k')
ylb(1)=ylabel('Rayleigh-wave displacement magnitude');
xlb(1)=xlabel('depth z (km)');
axis tight
yl=ylim;

% Some grid lines
gr=plot([lambda(:) lambda(:)]/2/1000,yl,'k:');

% Annotations
YL=repmat(yl(2),size(lambda));
fb=fillbox2(...
    [lambda(:)/2/1000-10 lambda(:)/2/1000+10 YL(:)/2+0.015+0.015 YL(:)/2+0.015-0.015],'w');
for index=1:length(T)
  to(index)=text(lambda(index)/2/1000,yl(2)/2+0.015,...
      num2str(T(index)));
end
set(to,'HorizontalAlignment','center')

% More annotations
fillbox2([385 435 0.6850 0.715],'w')
to(index+1)=text(410,0.7,'period (s)');
set(to,'horizontala','center')

% More cosmetics
longticks
set([gca xlb ylb],'fonts',12)
set(gca,'box','off')
hax=axescp(gca,1);
set(hax,'ylim',yl,'xtick',ceil(lambda(:)/2/1000),'color','none','xaxisl','top')
delete(get(hax,'xlabel'))
xl(2)=xlabel('Half Wavelength \lambda/2 (km)')
set(xl(2),'fonts',12)
set(hax,'box','off','yaxisl','r')
delete(get(hax,'ylabel'))
nolabels(hax,2)
fig2print(gcf,'landscape')

% Particle motion for multiple periods, see RAYLEIGH1
function [ux,uz]=partmot(z,T,c);
omega=2*pi./T;
k=omega/c;
t=linspace(0,T,50);
[ZZ,TT]=meshgrid(z,t);
ddux=exp(-ZZ*k*0.85)-0.58*exp(-ZZ*k*0.39);
dduz=-0.85*exp(-ZZ*k*0.85)+1.47*exp(-ZZ*k*0.39);
x=0;
ux=-sin(k*x-omega.*TT).*ddux;
uz=cos(k*x-omega.*TT).*dduz;
