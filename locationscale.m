function X=locationscale(N)
% X=LOCATIONSCALE(N)
%
% Generates and plots four samples from different probability density
% distributions.
%
% INPUT:
%
% N    sample size [default: 25]
%
% SEE ALSO:
%
% FIG2PRINT, XPAND, LONGTICKS, FIGDISP, DEFVAL
%
% Last modified by fjsimons-at-alum.mit.edu, 02/03/2020

% Set the default
defval('N',25);

% Define a number of distributions
distro={'unif','norm','logn','f'};
pars={[-3 3],[0 1],[1 0.5],[10 10]};

% How many simulations?
ld=length(distro);

clf
for index=1:ld
  % If it's a three-parameter distribution scale/shape/location...
  
  % If it's a two-parameter distribution
  if length(pars{index})==2
    X(index,:)=random(distro{index},pars{index}(1),pars{index}(2),[N 1]);
  else
    % If it's a one-parameter distribution
    X(index,:)=random(distro{index},pars{index},[N 1]);
  end
  p(index)=plot(X(index,:),repmat(index,[N 1]),'kx');
  hold on
end

% Cosmetics
set(gca,'ytick',1:ld,'yticklabel',letters(1:ld,1))
set(gca,'ydir','rev')
fig2print(gcf,'portrait')
ylim(xpand(ylim))
longticks(gca,2)
figdisp([],[],[],2)
