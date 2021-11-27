function varargout=geotherms(Ts,qs,D,k,H)
% [Tz,z,qz]=GEOTHERMS(Ts,qs,D,k,H)
%
% Illustrates some geotherms
%
% INPUT:
%
% Ts     surface temperature [K]
% qs     surface heatflow [W/m/m]
% D      depth extent of the top medium [km]
% k1,k2  thermal conductivity [W/m/K]
% H      volumetric heat production [W/m/m/m]
%
% OUTPUT
%
% Tz    temperature as a function of depth
% z     the depth
% qz    heat flow as a function of depth
% p     plot handles
%
% Last modified by fjsimons-at-alum.mit.edu, 11/26/2021

% Surface temperature
defval('Ts',15);
% Surface heatflow
defval('qs',40e-3);
% Volumetric heat production 
defval('H',6e-7);
% Thermal conductivity
defval('k',[2 2]);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIRST CASE 

% Calculate the first temperature profile
Tz1=Ts      +qs      /k(1)*z1    -H/2/k(1)*z1.^2;
% Calculate the first heat flow profile
qz1=         qs                  -H*z1;
% Calculate the second temperature profile as a simple continuation
Tz2=Tz1(end)+qz1(end)/k(1)*(z2-D)-H/2/k(1)*(z2-D).^2;
% Calculate the second heat flow profile as a simple continuation
qz2=         qz1(end)            -H*(z2-D);

% Put them together
Tz=[Tz1(:) ; Tz2(:)];
qz=[qz1(:) ; qz2(:)];

% Reasonable offset
Tr=range(Tz)/10;

% Scaling to render qz beautiful
if length(unique(qz(:)))~=1
  qz=scale([qz ; 0],[min(Tz)+Tr max(Tz)-Tr]);
  qz=qz(1:end-1);
else
  qz=repmat(median(Tz),size(qz));
end

% Something for the axis
Trange=[-max(Tz)/20 max(Tz)+2*Tr];

axes(ah(1))
p(1)=plot(Tz,z/unf,'LineWidth',1.5,'Color','r');
hold on
p(2)=plot(qz,z/unf,'LineWidth',1.5,'Color','g');
p(3)=plot([max(Tz)+Tr max(Tz)+Tr NaN max(Tz)+Tr max(Tz)+Tr],...
	  [0 D NaN D z2(end)]/unf,'LineWidth',1.5,'Color','b');
p(4)=plot(Trange,[D D]/unf,'--','LineWidth',0.5,'Color',grey);
hold off
axis ij
ylim([0 max(z/unf)])
xlim(Trange)
set(ah(1),'xtick',round([Ts Tz1(end) round(qz(length(z1))) max(Tz)]))
xl(1)=ylabel(sprintf('depth (%s)',uni));
yl(1)=xlabel('temperature | heat flow | heat production');
tl(1)=title(sprintf(...
    '%s %i%s/km\n%s %i mW/m^3\n%s %i mW/m^3\n',...
    'surface thermal gradient',qs/k(1)*unf,176,...
    'surface heat flow',round(qs*1000),...
    'reduced heat flow',round(qz1(end)*1000)),...
      'FontWeight','normal');
%movev(tl(1),-1) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SECOND CASE

% Calculate the first temperature profile
Tz1=Ts      +qs      /k(1)*z1    -H/2/k(1)*z1.^2;
% Calculate the first heat flow profile
qz1=         qs                  -H*z1;
% Calculate the second temperature profile without any heat producers
Tz2=Tz1(end)+qz1(end)/k(1)*(z2-D)-0/2/k(1)*(z2-D).^2;
% Calculate the second heat flow profile - keep the zero for dimensions
qz2=         qz1(end)            -0*(z2-D);

% Put them together
Tz=[Tz1(:) ; Tz2(:)];
qz=[qz1(:) ; qz2(:)];

% Reasonable offset
Tr=range(Tz)/10;

% Scaling to render qz beautiful
if length(unique(qz(:)))~=1
  qz=scale([qz ; 0],[min(Tz)+Tr max(Tz)-Tr]);
  qz=qz(1:end-1);
else
  qz=repmat(median(Tz),size(Tz));
end

% Something for the axis
Trange=[-max(Tz)/20 max(Tz)+2*Tr];

axes(ah(2))
p(5)=plot(Tz,z/unf,'LineWidth',1.5,'Color','r');
hold on
p(6)=plot(qz,z/unf,'LineWidth',1.5,'Color','g');
p(7)=plot([max(Tz)+Tr max(Tz)+Tr 0 0],...
	  [0 D  D z2(end)]/unf,'LineWidth',1.5,'Color','b');
p(8)=plot(Trange,[D D]/unf,'--','LineWidth',0.5,'Color',grey);
hold off
axis ij
ylim([0 max(z/unf)])
xlim(Trange)
set(ah(2),'xtick',round([Ts Tz1(end) round(qz(length(z1))) max(Tz)]))
xl(2)=ylabel(sprintf('depth (%s)',uni));
yl(2)=xlabel('temperature | heat flow | heat production');
tl(2)=title(sprintf(...
    '%s %i%s/km\n%s %i mW/m^3\n%s %i mW/m^3\n',...
    'surface thermal gradient',qs/k(1)*unf,176,...
    'surface heat flow',round(qs*1000),...
    'reduced heat flow',round(qz1(end)*1000)),...
      'FontWeight','normal');
%movev(tl(2),-1) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THIRD CASE
% Calculate the first temperature profile
Tz1=Ts      +(qs-D*H)      /k(1)*z1    +D^2*H/k(1).*(1-exp(-z1/D));
% Calculate the first heat flow profile
qz1=          qs                       -D*H*(1-exp(-z1/D));

% Calculate the second temperature profile as a simple continuation
Tz2=Tz1(end)+(qz1(end)-D*H)/k(1)*(z2-D)+D^2*H/k(1).*(1-exp(-(z2-D)/D));
% Calculate the second heat flow profile - keep the zero for dimensions
qz2=          qz1(end)       -D*H*(1-exp(-z1/D));

% Put them together
Tz=[Tz1(:) ; Tz2(:)];
qz=[qz1(:) ; qz2(:)];

% Reasonable offset
Tr=range(Tz)/10;

% Scaling to render qz beautiful
if length(unique(qz(:)))~=1
  qz=scale([qz ; 0],[min(Tz)+Tr max(Tz)-Tr]);
  qz=qz(1:end-1);
else
  qz=repmat(median(Tz),size(qz));
end

% Something for the axis
Trange=[-max(Tz)/20 max(Tz)+2*Tr];

axes(ah(3))
p(9)=plot(Tz,z/unf,'LineWidth',1.5,'Color','r');
hold on
p(10)=plot(qz,z/unf,'LineWidth',1.5,'Color','g');
p(11)=plot([max(Tz)+Tr]*exp(-z/D),z/unf,'LineWidth',1.5,'Color','b');
p(12)=plot(Trange,[D D]/unf,'--','LineWidth',0.5,'Color',grey);
hold off
axis ij
ylim([0 max(z/unf)])
xlim(Trange)

set(ah(3),'xtick',round([Ts Tz1(end) round(qz(length(z1))) max(Tz)]))
xl(3)=ylabel(sprintf('depth (%s)',uni));
yl(3)=xlabel('temperature | heat flow | heat production');
tl(2)=title(sprintf(...
    '%s %i%s/km\n%s %i mW/m^3\n%s %i mW/m^3\n',...
    'surface thermal gradient',qs/k(1)*unf,176,...
    'surface heat flow',round(qs*1000),...
    'reduced heat flow',round([qs-D*H]*1000)),...
      'FontWeight','normal');
%    'reduced heat flow',round(qz1(end)*1000)),...
%movev(tl(3),-1) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cosmetics
set(ah,'ytick',[0:Dmul]*D/unf)
set(ah,'xgrid','on')
longticks(ah,2)
delete(ah(4:end))
movev(ah(1:3),-0.2)

%  set(ah(index),'position',get(ah(index),'position')+[0 -0.2 0 0])


% Optional output
varns={Tz,z,qz};
varargout=varns(1:nargout);


