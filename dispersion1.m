function dispersion1
% DISPERSION1
%
% Illustrates phase/group velocity
%
% Last modified by fjsimons-at-alum.mit.edu, March 30th, 2017

clf

% Time and distance
t=linspace(0,200,500);
x=linspace(0,750000,10);

% Frequency
om1=1;
om2=1.2;

% Wave speed
c1=4500;
c2=4600;

% Wave number
k1=om1/c1;
k2=om2/c2;

% Average and difference values
k0=(k1+k2)/2;
dk=(k2-k1)/2;
om0=(om1+om2)/2;
dom=(om2-om1)/2;

% Phase speed and group speed
c=om0/k0;
U=dom/dk;

[X,T]=meshgrid(x,t);

% Two different waves
u1=sin(k1*x(1)-om1*t);
u2=sin(k2*x(1)-om2*t);

% Plot two different waves
ah(1)=subplot(311);
p(1)=plot(t,u1);
hold on
p(2)=plot(t,u2,'--');

xl(1)=xlabel('Time');
yl(1)=ylabel('Amplitude');

fig2print(gcf,'portrait')

% Plot the superposition of both waves
ah(2)=subplot(212);
U12=sin(k1*X-om1*T)+sin(k2*X-om2*T);

% Plot the curves as a function of time and distance
fc=5;
for index=1:length(x)
  pp(index)=plot(t,x(index)+U12(:,index)/fc*(x(2)-x(1)));  hold on
  % Upper envelope
  pe(index)=plot(t,x(index)+cos(dk*X(:,index)-dom*T(:,index))/(fc/2)* ...
		 (x(2)-x(1)));
  % Lower envelope
  pd(index)=plot(t,x(index)-cos(dk*X(:,index)-dom*T(:,index))/(fc/2)* ...
		 (x(2)-x(1)));
  % Grid line
  pf(index)=plot(t,repmat(x(index),length(t),1),':');
end
yli=ylim;
yli=[-1 8]*1e5;

xl(2)=xlabel('Time');
yl(2)=ylabel('Distance');

set([pe pd],'Color',[0.7 0.7 0.7])

% Phase velocity curve in RED
pc=plot(t,t*c);
set(pc,'Color','r')

% Group velocity curve in GREEN
pg=plot(t,t*U,'-');
set(pg,'Color','g')

% Cosmetics
set(ah(2),'Ydir','rev','ylim',yli,'Xlim',[0 200])
set(ah(1),'Xlim',[0 50])

set([p pp pe pd pc pg],'LineW',2)
