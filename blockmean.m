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
% NOTE:
%
% When working with real coordinates, of course these indices
% are pixel-centered. These then are the centers for the averaging
% regions; with the overlap, it is not possible to use them as the pixel
% centers for an image plot. 
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
  ro=1:size(mat,2);
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
  ro=pauli(1:size(mat,2),jside);
  ro=ro(1:jside-olapj:end,:)';
  ro=ro(:)';
end

% Perform the column-space averaging
co=gamini(1:length(ro)/jside,jside);
CT=sparse(ro,co,1);
post=mat*CT;

% Non-overlapping tiles, precisely fitting
if olapi==0 && olapj==0
  % Prepare row space averaging
  ro=1:size(mat,1);
else
  % Overlapping tiles, precisely fitting
  % Prepare row space averaging
  ro=pauli(1:size(mat,1),iside);
  ro=ro(1:iside-olapi:end,:)';
  ro=ro(:)';
end

% Perform the row-space averaging
co=gamini(1:length(ro)/iside,iside);
CT=sparse(ro,co,1)';
bm=CT*post;

% Normalization at the very end
bm=bm/prod(side);

% Output that will only make sense for the overlap
xc=(1+(jside-1)/2):jside-olapj:size(mat,2);
yc=(1+(iside-1)/2):iside-olapi:size(mat,1);


