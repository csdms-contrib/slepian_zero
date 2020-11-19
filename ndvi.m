function ndvi=ndvi(msimage)
% ndvi=NDVI(msimage)
%
% Takes a multispectral image (n x m x 5) and calculates the NDVI. 
%
% INPUT:
%
% msimage    The n by m by 5-channel image
%
% OUTPUT:
%
% ndvi       The ndvi index
%
% Last modified by fjsimons-at-alum.mit.edu, 12/05/2019

% One-stop shopping... is slower
% ndvi=[double(msimage(:,:,5))-double(msimage(:,:,3))]./[double(msimage(:,:,5))+double(msimage(:,:,3))];

% tic toc on a large image, run a few times
nir=double(msimage(:,:,5));
red=double(msimage(:,:,3));
ndvi=[nir-red]./[nir+red];

% Make sure there's nothing suspicious
if any(ndvi(:)<-1) || any(ndvi(:)>1)
  warning('Weird. Are you doing an actual image?')
end



