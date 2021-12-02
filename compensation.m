function compensation
% COMPENSATION
%
% Illustrates the degree of isostatic compensation
% Turcotte & Schubert Eq. 3-117
%
% Last modified by fjsimons-at-alum.mit.edu, 12/01/2021

% Crustal density
rc=2650;
% Mantle density
rm=3300;
% Density contrast
drho=rm-rc;
% Gravitational acceleration
g=9.81;
% Young's modulus
young=1e11;
% Poisson's ratio
poisson=1/4;

% Reference values for effective elastic thickness
Te=[1:10:101]*1000;

% The flexural rigidities that we consider
D=Te.^3*young/12/(1-poisson^2);

% The set of wavelength of the period load that we consider
lambda=linspace(1,1000,1000)*1000;

% The combined space
[LL,DD]=meshgrid(lambda,D);

% The actual degree of compensation
C=drho./(drho+DD./g.*(2*pi./LL).^4);

% Make the figure
figure(gcf)
for index=1:length(D)
  p(index)=plot(lambda/1000,C(index,:),'k-');  
  hold on
end

hold off

set(gca,'xdir','rev')

grid on

longticks

xl(1)=xlabel('wavelength (km)');
yl(1)=ylabel('degree of compensation, w_0/w_{0\infty}');

set(p,'linew',2)

set([gca xl yl],'fonts',12)

% Boxes in the right place (as of 2009...) 
post=[936.9676    0.2500
      935.2641    0.32
      904.5997    0.36
      851.7888    0.4
      756.3884    0.4
      664.3952    0.4
      563.8842    0.4
      456.5588    0.4
      342.4191    0.4
      209.5400    0.4
      35.7751     0.4
      950         0.04];

hold on
fb=fillbox2(...
    [post(:,1)-30 post(:,1)+30 post(:,2)+0.015 post(:,2)-0.015],'w');
% Lettering etc
for index=1:length(Te)
  t(index)=text(post(index,1),post(index,2),num2str(Te(length(Te)-index+1)/1000));
end
t(index+1)=text(post(index+1,1),post(index+1,2),'Te');
set(t,'horizontala','center')
