function [bm,xyc]=blockmean(mat,side,olap)
% [bm,yxc]=BLOCKMEAN(mat,[iside jside],[olapi olapj])
%
% Block-averages a matrix, with or without overlap in the block tiles
%
% INPUT:
%
% mat         A certain matrix
% side        [iside jside] block size
% olap        [olapi olapj] overlap size (default: 0 for no overlap))
%
% OUTPUT:
%
% bm          The matrix of means as requested
% yxc         The center points of the boxes
%
% TEST EXAMPLES THAT SHOULD PRODUCE NO OUTPUT:
%
% mat=peaks(64);
% diferm(blockmean(mat,[1 1])-mat)
% diferm(blockmean(mat,size(mat))-mean(mat(:)))
% diferm(blockmean(mat,[4 4],[0 0])-blockmean(mat,[4 4]))
%
% mat=rand(120,80);
% for index=1:77
%   tile=blocktile(mat,20,50,index);
%   diferm(mean(tile(:))-indeks(blockmean(mat,[20 20],[10 10]),index))
% end
%
% SEE ALSO:
% 
% GAMINI, PAULI, PCHAVE, BLOCKTILE, ...
%
% Last modified by fjsimons-at-alum.mit.edu, 01/03/2018

% Just make default overlap zero
defval('olap',[0 0])

% Calculate the averaging operators in both dimensions
[ny,CTl,yc]=avops(1,size(mat),side,olap);
[nx,CTr,xc]=avops(2,size(mat),side,olap);

% Calculate the required averages
bm=CTl'*mat*CTr/prod(side);

% Deliver output
yxc=[yc xc];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [n,CT,c]=avops(dim,sais,side,olap)
% This function constructs an averaging operator in one dimension
% For the first dimension, it results in a transpose matrix to left-multiply...
% For the second dimension, it results in a matrix to right-multiply...
% with the matrix whose row/column averages we seek

% Calculate the number of tiles that it will be possible to generate
n=[sais(dim)-olap(dim)]/[side(dim)-olap(dim)];

% Check sizing
if fix(n)~=n
    error(sprintf('Matrix size %i not right for overlapping tiles',dim))
end

% Prepare for the averaging
if olap(dim)==0
  ro=1:sais(dim);
else
  ro=pauli(1:sais(dim),side(dim));
  ro=ro(1:side(dim)-olap(dim):end,:)';
  ro=ro(:)';
end
% Construct indexing arrays
co=gamini(1:length(ro)/side(dim),side(dim));
CT=sparse(ro,co,1);

% Center 'coordinates'
c=[1+(side(dim)-1)/2]:side(dim)-olap(dim):sais(dim);

% When working with real coordinates, of course these indices are
% pixel-centered. These then are the centers for the averaging regions; with
% the overlap, it is not possible to use them as the pixel centers for an
% image plot. See SOL2BLOCK.
