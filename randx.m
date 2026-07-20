function X=randx(covX,M)
% X=RANDX(covX,M)
%
% Makes a set of M Gaussian random variables related by a covariance matrix
%
% INPUT:
%
% covX    A 1xNp rolled-up covariance matrix (matrix) for
%             N=(-1+sqrt(1+4*2*NP))/2 variables, since are
%             NP=n*(n+1)/2 unique entries in an NxN symmetric matrix, see TRILOS(I)
% M       The desired sample size
%
% OUTPUT:
%
% X       The MxN matrix of random variables with the desired correlation
%
% SEE ALSO:
%
% FAKERELATION, MLEXPLOS

% Experiment size
defval('M',25);

% Population covariance matrix suitable for two variables, note: different from FAKERELATION
defval('covX',[1 1 0.5])

% Rearrange into proper symmetric full form
covX=trilosi(covX);

% Calculate the initial uncorrelated Gaussian random variables
Z=randn([M size(covX,1)]);

% Calculate the transformation matrix
L=cholcov(covX);

% Calculate the joint set
X=(L'*Z)';


