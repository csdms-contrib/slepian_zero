function readGEBCO(vers,npc)
% readGEBCO(vers,npc)
%
% Reads a GEBCO bathymetry grid, stored in NETCDF format, and splits it
% into manageable MAT files each containing a chunk.
%
% INPUT:
%
% vers    2014 version (30 arc seconds)
%         2008 version (30 arc seconds, deprecated)
% npc     sqrt(number) of fitting pieces to split the data into
%
% SEE ALSO:
%
% https://www.gebco.net/
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu. 01/04/2019

% Default value
defval('vers',2008)

% sqrt(number) of fitting pieces that we will split the data into
npc=10;

% Make sure you have these various directories and data files
gebcodir=fullfile(getenv('IFILES'),'TOPOGRAPHY','EARTH','GEBCO');
switch vers
 case 2014
  fname=fullfile(gebcodir,'GEBCO2014','GEBCO_2014_1D.nc');
 case 2008
  % The full path to the 'GEBCO_08\ Grid' source '20100927'
  fname=fullfile(gebcodir,'GEBCO2008','gebco_08.nc');
 otherwise
  error('Specify the proper version of the GEBCO grid')
end

% Display some info on the file itself
ncdisp(fname)

% Assign spacing, this should be 1/60/2 for 30 arc seconds
dxdy=ncread(fname,'spacing');
NxNy=ncread(fname,'dimension');
xran=ncread(fname,'x_range');
yran=ncread(fname,'y_range');

% Read the actual elevation data
z=ncread(fname,'z');

% Double-check the size
diferm(length(z)-prod(double(NxNy)))

% Split it into pieces and resave
zr=reshape(z,NxNy(:)')';

% Double-check the dimensions
diferm(size(zr,2)-NxNy(1))
diferm(size(zr,1)-NxNy(2))

% Check BLOCKISOLATE, BLOCKMEAN, BLOCKTILE, PCHAVE, etc
% but really, this here is quite efficient already...

% Across - 
rt=[0:NxNy(1)/npc:NxNy(1)];
lt=rt+1; 
rt=rt(2:end);
lt=lt(1:end-1);

% Down
dn=[0:NxNy(2)/npc:NxNy(2)];
up=dn+1;
dn=dn(2:end);
up=up(1:end-1);

% Segment patches and resave
for rindex=1:npc
  for cindex=1:npc
    zpc=zr(up(rindex):dn(rindex),lt(cindex):rt(cindex));
    % Compare with the equivalent BLOCKISOLATE call
    % zpcp=blockisolate(zr,double([NxNy(2) NxNy(1)])/npc,1);
    % Save those pieces to file
    save(sprintf('GEBCO_08_%2.2i_%2.2i',rindex,cindex),'zpc')
  end
end

