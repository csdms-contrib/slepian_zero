function [bm,xc,yc,CT]=blockmean(mat,side,olap)
% [bm,xc,yc,CT]=BLOCKMEAN(mat,[iside jside],[olapi olapj])
%
% Block-averages a matrix, with or without overlap in the block tiles
% When working with real coordinates, of course these indices
% are pixel-centered. These then are the centers for the averaging
% regions; with the overlap, it is not possible to use them as the pixels
% centers for an image plot. 
%
% INPUT:
%
% mat         A certain matrix
% side        [iside jside] block size
% olap        [olapi olapj] overlap size
%
% OUTPUT:
%
% bm          The matrix of means as requested
% xc,yc       The center point of the boxes
% CT          The sparse matrix at the heart of it all
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

% Parse the second input input
[iside,jside]=deal(side(1),side(2));

% Could get rid of first if-statement and just make default overlap zero.

% Non-overlapping tiles
if nargin==2
  if any(mod(size(mat),side))
    error('Matrix not right size for nonoverlapping tiles')
  end
  % Column space averaging
  ro=1:size(mat,2);
  co=gamini(1:size(mat,2)/jside,jside);
  CT=sparse(ro,co,1);
  post=mat*CT;
  % Row space averaging
  ro=1:size(mat,1);
  co=gamini(1:size(mat,1)/iside,iside);
  CT=sparse(ro,co,1)';
  bm=CT*post;
  bm=bm/prod(side);
  [xc,yc]=deal(NaN);
else
  % Overlapping tiles, parse the third input
  [olapi,olapj]=deal(olap(1),olap(2));
  [ny,nx]=size(mat);
  % Number of windows in X
  nwj=(nx-olapj)/(jside-olapj); 
  % Number of windows in Y
  nwi=(ny-olapi)/(iside-olapi); 
  if ~all(fix([nwi nwj])==[nwi nwj])
    error('Matrix not right size for overlapping tiles')
  end  
  % Column space averaging
  ro=pauli(1:size(mat,2),jside);
  ro=ro(1:jside-olapj:end,:)';
  ro=ro(:)';
  co=gamini(1:length(ro)/jside,jside);
  CT=sparse(ro,co,1);
  post=mat*CT;
  % Row space averaging
  ro=pauli(1:size(mat,1),iside);
  ro=ro(1:iside-olapi:end,:)';
  ro=ro(:)';
  co=gamini(1:length(ro)/iside,iside);
  CT=sparse(ro,co,1)';
  bm=CT*post;
  bm=bm/prod(side);
  xc=(1+(jside-1)/2):jside-olapj:size(mat,2);
  yc=(1+(iside-1)/2):iside-olapi:size(mat,1);
end

