function [X,Y,CXY,Z1,Z2]=fakerelation(C12,N,distro,pars)
% Creates data pairs with a particular relation
%
% INPUT:
%
%
% OUTPUT:
%
%
% Last modified by fjsimons-at-alum.mit.edu, 02/12/2020

% Number of data pairs
defval('N',25);

% Define the population covariance matrix
defval('C12',[1 0.5 ; 0.5 1])

% Define a class of distributions
defval('distro',{'norm'});
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

% Plots and Cosmetics
% plot(X,Y,'o')
% set(gca,'ytick',1:ld,'yticklabel',letters(1:ld,1))
% set(gca,'ydir','rev')
% fig2print(gcf,'portrait')
% ylim(xpand(ylim))
% longticks(gca,2)
% figdisp([],[],[],1)
