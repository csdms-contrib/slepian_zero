function [X,Y,CXY,C12,Z1,Z2]=fakerelation(C12,N,distro,ploti)
% [X,Y,CXY,C12,Z1,Z2]=fakerelation(C12,N,distro,ploti)
%
% Creates data pairs with a particular relation
%
% INPUT:
%
% C12       The three ELEMENTS of the desired population covariance matrix
%           [CXX CXY CYY] <---- watch this order!
% N         The sample size [default: 100]
% distro    The population distribution [default: 'norm']
% ploti     1 Make a little plot
%           0 Don't [default]
%
% OUTPUT:
%
% X, Y      The data sample
% CXY       The sample covariance
% C12       The population covariance MATRIX
% Z1, Z2    The uncorrelated generating variables
%
% Last modified by fjsimons-at-alum.mit.edu, 02/12/2020

% Number of data pairs
defval('N',25);

% Define the population covariance matrix
defval('C12',[1 0.5 1])
% Rearrange to make sure
C12=[C12(1) C12(2) ; C12(2) C12(3)];

% Define a class of distributions
defval('distro',{'norm'});
% You don't really want to change this, ever
defval('pars',  {[0 1]})

% Calculate the initial uncorrelated random variables
Z1=random(distro{1},pars{1}(1),pars{1}(2),[N 1]);
Z2=random(distro{1},pars{1}(1),pars{1}(2),[N 1]);

% Calculate the transformation matrix
L=cholcov(C12);

% Calculate the joint pair
XY=(L'*[Z1(:)' ; Z2(:)'])';

% Distribute over the variables
X=XY(:,1);
Y=XY(:,2);

% Report on their sample covariance
CXY=cov(X,Y);

if ploti==1
  % Plots and Cosmetics
  plot(X,Y,'o')
  % set(gca,'ytick',1:ld,'yticklabel',letters(1:ld,1))
  set(gca,'ydir','rev')
  fig2print(gcf,'portrait')
  ylim(xpand(ylim))
  % longticks(gca,2)
  figdisp([],[],[],0)
end
