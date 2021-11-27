function varargout=geotherms(Ts,qs,D,k,H)
% [Tz,z,qz]=GEOTHERMS(Ts,qs,D,k,H)
%
% Illustrates the behavior of some geotherms
%
% INPUT:
%
% Ts     surface temperature [K]
% qs     surface heatflow [W/m/m]
% D      depth extent of the top medium [km]
% k      thermal conductivity [W/m/K]
% H      volumetric heat production [W/m/m/m]
%
% OUTPUT
%
% Tz    temperature as a function of depth
% z     the depth
% qz    heat flow as a function of depth
% p     plot handles
%
% Last modified by fjsimons-at-alum.mit.edu, 11/27/2021

% Surface temperature
defval('Ts',15);
% Surface heatflow
defval('qs',40e-3);
% Volumetric heat production 
defval('H',5.9e-7);
% Thermal conductivity
defval('k',2.5);
% The depth extent of the top layer
defval('D',10000)

% Output units
uni='km';
if strcmp(uni,'km')
  % The divisor that goes from input to output
  unf=1000; else unf=1;
end

% Set up the query depths
Dmul=3;
defval('z1',linspace(0,     D))
defval('z2',linspace(D,Dmul*D))
z=[z1(:); z2(:)];

% Now make the axis handles
ah=krijetem(subnum(2,3));

% An absolute reference for where the heat production will be plotted
% if left [] it will be relative to the maximum temperature reached
mTz=550;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIRST CASE 

% Calculate the first temperature profile
Tz1=Ts      +qs      /k*z1    -H/2/k*z1.^2;
% Calculate the first heat flow profile
qz1=         qs               -H*z1;
% Calculate the second temperature profile as a simple continuation
Tz2=Tz1(end)+qz1(end)/k*(z2-D)-H/2/k*(z2-D).^2;
% Calculate the second heat flow profile as a simple continuation
qz2=         qz1(end)         -H*(z2-D);

[Tz,qz,Tr,Trange,mTz]=assembly(Tz1,Tz2,qz1,qz2,mTz);

axes(ah(1))
p(1:4)=plotem(z,Tz,qz,unf,D,Trange,k,qz1);
p(5)=plot([mTz+Tr mTz+Tr NaN mTz+Tr mTz+Tr],...
	  [0 D NaN D z2(end)]/unf,'LineWidth',1.5,'Color','b');
hold off
[xl(1),yl(1),tl(1)]=...
    labeling(ah(1),z,Tz,qz,Ts,qs,H,k,z1,Tz1,qz1,uni,unf,Trange);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SECOND CASE

% Calculate the first temperature profile
Tz1=Ts      +qs      /k*z1    -H/2/k*z1.^2;
% Calculate the first heat flow profile
qz1=         qs                  -H*z1;
% Calculate the second temperature profile without any heat producers
Tz2=Tz1(end)+qz1(end)/k*(z2-D)-0/2/k*(z2-D).^2;
% Calculate the second heat flow profile - keep the zero for dimensions
qz2=         qz1(end)            -0*(z2-D);

[Tz,qz,Tr,Trange,mTz]=assembly(Tz1,Tz2,qz1,qz2,mTz);

axes(ah(2))
p(6:9)=plotem(z,Tz,qz,unf,D,Trange,k,qz1);
p(10)=plot([mTz+Tr mTz+Tr 0 0],...
	  [0 D  D z2(end)]/unf,'LineWidth',1.5,'Color','b');
hold off
[xl(2),yl(2),tl(2)]=...
    labeling(ah(2),z,Tz,qz,Ts,qs,H,k,z1,Tz1,qz1,uni,unf,Trange);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THIRD CASE
% Calculate the first temperature profile
Tz1=Ts      +(qs-D*H)      /k*z1    +D^2*H/k.*(1-exp(-z1/D));
% Calculate the first heat flow profile
qz1=          qs                       -D*H*(1-exp(-z1/D));

% Calculate the second temperature profile as a simple continuation
Tz2=Tz1(end)+(qz1(end)-D*H)/k*(z2-D)+D^2*H/k.*(1-exp(-(z2-D)/D));
% Calculate the second heat flow profile - keep the zero for dimensions
qz2=          qz1(end)       -D*H*(1-exp(-z1/D));

[Tz,qz,Tr,Trange,mTz]=assembly(Tz1,Tz2,qz1,qz2,mTz);

axes(ah(3))
p(11:14)=plotem(z,Tz,qz,unf,D,Trange,k,qz1);
p(15)=plot([mTz+Tr]*exp(-z/D),z/unf,'LineWidth',1.5,'Color','b');
hold off
[xl(3),yl(3),tl(3)]=...
    labeling(ah(3),z,Tz,qz,Ts,qs,H,k,z1,Tz1,qz1,uni,unf,Trange);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Common Cosmetics
set(ah,'ytick',[0:Dmul]*D/unf)
set(ah,'xgrid','on')
longticks(ah,2)
delete(ah(4:end)); ah=ah(1:3);
movev(ah(1:3),-0.2)
for index=1:3
  xel(index,:)=get(ah(index),'xlim');
end
set(ah,'xlim',[min(xel(:,1)) max(xel(:,2))]);
%  set(ah(index),'position',get(ah(index),'position')+[0 -0.2 0 0])

% Optional output
varns={Tz,z,qz};
varargout=varns(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Tz,qz,Tr,Trange,mTz]=assembly(Tz1,Tz2,qz1,qz2,mTz)

% Put them together
Tz=[Tz1(:) ; Tz2(:)];
qz=[qz1(:) ; qz2(:)];

% Reasonable offset
Tr=range(Tz)/10;

% Relative unless absolute input
defval('mTz',max(Tz));

% Scaling to render qz beautiful
if length(unique(qz(:)))~=1
  %  qz=scale([qz ; 0],[min(Tz)+Tr mTz-Tr]);
  qz=scale([qz ; 0],[0 mTz-Tr]);
  qz=qz(1:end-1);
else
  qz=repmat(median(Tz),size(qz));
end

% Temperature axis
Trange=[-mTz/20 mTz+2*Tr];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=plotem(z,Tz,qz,unf,D,Trange,k,qz1)
p(1)=plot(Tz,z/unf,'LineWidth',1.5,'Color','r');
hold on
p(2)=plot(qz,z/unf,'LineWidth',1.5,'Color','g');
p(3)=plot(Trange,[D D]/unf,'--','LineWidth',0.5,'Color',grey);

% Plot a tangent - not that qz was already scaled, going in
%plot([Tz(1) Tz(1)+[Tz(2)-Tz(1)]/[z(2)-z(1)]*z(end)],[0 z(end)/unf])
p(4)=plot([Tz(1) Tz(1)+qz1(1)/k*z(end)],[0 z(end)/unf],'Color',grey);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xl,yl,tl]=labeling(ah,z,Tz,qz,Ts,qs,H,k,z1,Tz1,qz1,uni,unf,Trange)
axis ij
ylim([0 max(z/unf)])
xlim(Trange)
set(ah,'xtick',sort(round([Ts Tz1(end) round(qz(length(z1))) max(Tz)])))
xl=ylabel(sprintf('depth (%s)',uni));
yl=xlabel('temperature | heat flow | heat production');
tl=title(sprintf(...
    '%s %i%s/km\n%s %i mW/m^3\n%s %i mW/m^3\n%s %3.1f%sW/m^3\n',...
    'surface thermal gradient',round(qs/k*unf),176,...
    'surface heat flow',round(qs*1000),...
    'reduced heat flow',round(qz1(end)*1000),...
    'heat production',H*1e6,'\mu'),...
      'FontWeight','normal');


