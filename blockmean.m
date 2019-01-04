function [bm,xc,yc]=blockmean(mat,side,olap)
% [bm,xc,yc]=BLOCKMEAN(mat,[iside jside],[olapi olapj])
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
% xc,yc       The center point of the boxes
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
% GAMINI, PAULI, PCHAVE, BLOCKMEAN, ...
%
% Last modified by fjsimons-at-alum.mit.edu, 01/03/2018

% Parse the second input
[iside,jside]=deal(side(1),side(2));

% Just make default overlap zero
defval('olap',[0 0])

% Overlapping tiles, parse the third input or whatever the default was
[olapi,olapj]=deal(olap(1),olap(2));

% Non-overlapping tiles, precisely fitting
if olapi==0 && olapj==0
  if any(mod(size(mat),side))
    error('Matrix not right size for nonoverlapping tiles')
  end
  % Prepare the column space averaging
  rocs=1:size(mat,2);
  % Prepare row space averaging
  rors=1:size(mat,1);
else
  % Overlapping tiles, precisely fitting
  [ny,nx]=size(mat);
  % Number of tiles in X
  nwj=(nx-olapj)/(jside-olapj); 
  % Number of tiles in Y
  nwi=(ny-olapi)/(iside-olapi); 
  if ~all(fix([nwi nwj])==[nwi nwj])
    error('Matrix not right size for overlapping tiles')
  end  
  % Prepare the column space averaging
  rocs=pauli(1:size(mat,2),jside);
  rocs=rocs(1:jside-olapj:end,:)';
  rocs=rocs(:)';
  % Prepare row space averaging
  rors=pauli(1:size(mat,1),iside);
  rors=rors(1:iside-olapi:end,:)';
  rors=rors(:)';
end

% Perform the column-space averaging
cocs=gamini(1:length(rocs)/jside,jside);
CTcs=sparse(rocs,cocs,1);

% Perform the row-space averaging
cors=gamini(1:length(rors)/iside,iside);
CTrs=sparse(rors,cors,1)';

% Normalization at the very end
bm=CTrs*mat*CTcs/prod(side);

% Output that will only make sense for the overlap
xc=(1+(jside-1)/2):jside-olapj:size(mat,2);
yc=(1+(iside-1)/2):iside-olapi:size(mat,1);

% When working with real coordinates, of course these indices are
% pixel-centered. These then are the centers for the averaging regions; with
% the overlap, it is not possible to use them as the pixel centers for an
% image plot. See SOL2BLOCK.


