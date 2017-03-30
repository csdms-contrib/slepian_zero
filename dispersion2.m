function dispersion2
% DISPERSION2
%
% Illustrates phase/group velocity
%
% Last modified by fjsimons-at-alum.mit.edu, March 30th, 2017

clf

t=linspace(0,200,500);
x=linspace(0,750000,10);

om1=1;
om2=1.2;
c1=4500;
c2=4600;
k1=om1/c1;
k2=om2/c2;

k0=(k1+k2)/2;
om0=(om1+om2)/2;
dom=(om2-om1)/2;
dk=(k2-k1)/2;
c=om0/k0;
U=dom/dk;

[X,T]=meshgrid(x,t);

% For a linear dispersion curve
TH=T-dk/dom*X;
U12=dom/2/pi*cos(k0*X-om0*T).*sin(dom/2*TH)./(dom/2*TH);

fc=2*max(U12(:));
for index=1:length(x)
  pp(index)=plot(t,x(index)+U12(:,index)/fc*(x(2)-x(1)));  hold on
  pe(index)=plot(t,x(index)+sin(dom/2*TH(:,index))./(dom/2*TH(:,index))/2*(x(2)-x(1)));
  pd(index)=plot(t,x(index)-sin(dom/2*TH(:,index))./(dom/2*TH(:,index))/2*(x(2)-x(1)));
  pf(index)=plot(t,repmat(x(index),length(t),1),':');
end
yl=ylim;

set([pe pd],'Color',[0.7 0.7 0.7])

% Phase velocity curve in RED
pc=plot(t,t*c);
set(pc,'Color','r')

% Group velocity curve in GREEN
pg=plot(t,t*U,'-');
set(pg,'Color','g')

set(gca,'Ydir','rev','ylim',yl,'Xlim',[0 200],'FontSize',15)

set([pp pe pd pc pg],'LineW',2)

xlb=xlabel('Time');
ylb=ylabel('Distance');

xlb.FontSize=15;
ylb.FontSize=15;
