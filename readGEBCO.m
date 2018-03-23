% Get some info
ncdisp('gebco_08.nc')

% Assign spacing
dxdy=ncread('gebco_08.nc','spacing');
NxNy=ncread('gebco_08.nc','dimension');

% Read the data
z=ncread('gebco_08.nc','z');

% Check the size
difer(length(z)-prod(double(NxNy)),[],[],NaN)

% Split it into pieces and resave
zr=reshape(z,NxNy(:)')';

% Number of pieces
npc=10;

% Across
lt=[0:size(zr,2)/npc:size(zr,2)]; 
rt=lt+1; 
lt=lt(2:end);
rt=rt(1:end-1);

% Down
up=[0:size(zr,1)/npc:size(zr,1)];
dn=up+1;
up=up(2:end);
dn=dn(1:end-1);

% Segment patches and resave
for rindex=1:npc
  for cindex=1:npc
    zpc=zr(dn(rindex):up(rindex),rt(cindex):lt(cindex));
    % Save those pieces to file
    save(sprintf('GEBCO_08_%2.2i_%2.2i',rindex,cindex),'zpc')
  end
end
