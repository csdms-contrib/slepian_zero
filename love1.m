function love1
% LOVE1
%
% Makes dispersion diagrams for layer-over-a-halfspace Love waves.
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2017

% Default values for input to LOVEWAVE
defval('beta1',3800)
defval('beta2',4500)
defval('rho1',3000)
defval('rho2',3360)
defval('h',40000)
defval('n',0)
% Period [s]
defval('T',50)

% Minimization options
OPTIONS=[];

% Use beta1 and beta2 as guesses in optimization
% CALCULATE DISPERSION DIAGRAM FOR LINEARLY SPACED OMEGA
omega=linspace(0,10,100);
T=2*pi./omega;
modes=[0 1 2 3];
for ondex=1:length(modes)
  for index=1:length(T)
    [c(ondex,index),ziro(ondex,index)]=fminbnd('lovewave',beta1,beta2,OPTIONS,...
	T(index),beta1,beta2,h,rho1,rho2,modes(ondex));
  end
end
c(ziro>0.01)=NaN;
%save one_love c ziro T omega

ah(1)=subplot(121);
p1=plot(omega,c);

% CALCULATE DISPERSION DIAGRAM FOR LINEARLY SPACED PERIOD
T=linspace(0,100,100);
modes=[0 1 2 3];
% CALCULATE DISPERSION DIAGRAM
for ondex=1:length(modes)
  for index=1:length(T)
    [c(ondex,index),ziro(ondex,index)]=fminbnd('lovewave',beta1,beta2,OPTIONS,...
	T(index),beta1,beta2,h,rho1,rho2,modes(ondex));
  end
end

c(ziro>0.01)=NaN;
%save two_love c ziro T omega

ah(2)=subplot(122);
p2=plot(T,c);

% Cosmetics
set([p1 p2],'LineW',2,'Color','k')
axes(ah(1))
xl(1)=xlabel('Angular Frequency \omega (rad/s)');
yl(1)=ylabel('Phase speed c (m/s)')
axes(ah(2))
xl(2)=xlabel('Period (s)');
nolabels(ah(2),2)
fig2print(gcf,'landscape')
shrink(ah,1,2)
serre(ah,1/2,'across')
set([ah xl yl],'FontS',12)
set(ah,'xgrid','on','ygrid','on')

axes(ah(1))
post=[0.0005    3.8986
      0.0013    3.9996
      0.0019    4.0982
      0.0023    4.1993
      0.0089    4.4495]*1000;
hold on
fb=fillbox2(...
    [post(:,1)-0.3 post(:,1)+0.3 post(:,2)+25 post(:,2)-25],'w');

for index=1:length(modes)
  to(index)=text(post(index,1),post(index,2),...
      num2str(modes(index)));
end
to(index+1)=text(post(index+1,1),post(index+1,2),'n');
set(to,'horizontala','center')
longticks(ah)

axes(ah(2))
posb=[0.0426    4.2953
      0.0089    4.3989
      0.0052    4.3357
      0.0031    4.2700]*1000;
hold on
fb2=fillbox2(...
    [posb(:,1)-3 posb(:,1)+3 posb(:,2)+25 posb(:,2)-25],'w');
for index=1:length(modes)
  to2(index)=text(posb(index,1),posb(index,2),...
      num2str(modes(index)));
end


