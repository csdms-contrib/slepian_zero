function varargout=gebco(lon,lat,vers,npc,method,xver)
% z=gebco(lon,lat,vers,npc,method,xver)
%
% Returns the GEBCO bathymetry interpolated to the requested location
%
% INPUT:
%
% lon      Requested longitude, in decimal degrees, ideally -180<=lon<180
% lat      Requested latitudes, in decimal degrees, ideally -90<=lat<=90
% vers     2014  version (30 arc seconds) [default]
%          2008  version (30 arc seconds, deprecated)
%         '1MIN' version (1 arc minute, deprecated)
% npc     sqrt(number) of split pieces [default: 10]
% method  'nearest' (default), 'linear', etc, for the interpolation
% xver    Extra verification [1] or not [0]
%
% OUTPUT:
%
% z        The elevation/bathymetry at the requested point
% lon,lat  The longitude and latitude of the requested point
%
% EXAMPLE:
%
% mn=randij(21); [z,lon,lat]=gebco(-180+rand(mn)*36,-90+rand(mn)*18);
% mn=randij(210); [z,lon,lat]=gebco(-180+rand(mn)*360,-90+rand(mn)*180);
%
% SEE ALSO:
%
% https://www.gebco.net/
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 01/06/2019

% Default lon and lat, for good measure, take those from the examples of 
% https://www.gebco.net/data_and_products/gebco_web_services/web_map_service/#getmap
% for comparison with WMS GetFeatureInfo requests
defval('lon',-19.979167)
defval('lat', 50.9625)

% Check size
if any(size(lon)~=size(lat)); error('Inconsistent input data size'); end

% Default version
defval('vers',2014)
% Default tiling
defval('npc',10);
% Default method
defval('method','nearest');

% Extra verification
defval('xver',1)

% Get information on where the data files are being kept
[mname,sname,up,dn,lt,rt,dxdy,NxNy]=readGEBCO(vers,npc);

% We know that the data were pixel-centered, see at the bottom of this
% function. So here are the matrix corner pixel centers of the global map.
c11=[-180+dxdy(1)/2  90-dxdy(2)/2];
cmn=[ 180-dxdy(1)/2 -90+dxdy(2)/2];

% In which of the tiles have we landed? We know that the original global
% grid was quoted from -180 across in lon and from 90 down in lat..
cindep=max(1,ceil(    [lon+180]/[360/npc]));
rindep=max(1,ceil(npc-[lat+90 ]/[180/npc]));
cindex=unique(cindep);
rindex=unique(rindep);

% If you are spread across multiple tiles you're in trouble
if length(cindex)~=1 || length(rindex)~=1
  % You should recursively apply this algorithm for the unique pairs!
  
  keyboard
end

% So which file should we load? By the way, The stored variable is 'zpc'.
loadit=fullfile(mname,sprintf('%s_%2.2i_%2.2i',sname,rindex,cindex));
if xver==1 ; disp(sprintf('Loading %s',loadit)) ; end
load(loadit);

% The pixel-centers of the longitudes in the global grid, alternatively:
lons =linspace(c11(1),         cmn(1),NxNy(1));
% The pixel-centers of the latitudes in the global grid, alternatively:
lats =linspace(c11(2),         cmn(2),NxNy(2));

% Being extra careful here
if xver==1
  lons2=       c11(1): dxdy(1):cmn(1);
  diferm(lons,lons2,9)
  lats2=       c11(2):-dxdy(2):cmn(2);
  diferm(lats,lats2,9)
end

% Assign a local grid to the data in the tile loaded, see readGEBCO
latpc=lats(up(rindex):dn(rindex));
lonpc=lons(lt(cindex):rt(cindex));

% Then interpolate from what you've just loaded to what you want
% Make sure you use a rule that can extrapolate... if it comes out as a NaN
z=interp2(lonpc,latpc,zpc,lon,lat,method);
% Fix any and all of the NaN

if any(isnan(z))
  % Need a different interpolation, it's an extrapolation in a sense
  disp(sprintf('Longitude given %g to %g wanted %g',min(lonpc),max(lonpc),lon))
  disp(sprintf('Latitude given %g to %g wanted %g',min(latpc),max(latpc),lat))
  % This is a bit of a pain, I suppose
  F=griddedInterpolant({flipud(latpc(:)) lonpc(:)},flipud(zpc),method);
  % Apply the interpolation for the whole set, make sure there are no surprises
  zi=F(lat,lon);
  keyboard
end

% Output
varns={z,lon,lat};
varargout=varns(1:nargout);

% Grid documentation
% https://www.bodc.ac.uk/data/documents/nodb/301801/#6_format
%
% The grid is stored as a two-dimensional array of 2-byte signed integer ...
%     values of elevation in metres, with negative values for bathymetric ...
%     depths and positive values for topographic heights.
%
% The complete data set gives global coverage, spanning 89° 59' 45''N, 179° ...
%     59' 45''W to 89° 59' 45''S, 179° 59' 45''E on a 30 arc-second grid. ...
% It consists of 21,600 rows x 43,200 columns, giving 933,120,000 data points. ...
% The netCDF storage is arranged as contiguous latitudinal bands. The data ...
%     values are pixel-centre registered i.e. they refer to elevations at ...
%     the centre of grid cells.
%
% The complete data set gives global coverage. The grid consists of 21,600 ...
%     rows x 43,200 columns, resulting in 933,120,000 data points. The data ...
%     start at the Northwest corner of the file and are arranged in latitudinal ...
%     bands of 360 degrees x 120 points per degree = 43,200 values. The data ...
%     range eastward from 179° 59' 45'' W to 179° 59' 45'' E. Thus, the first ...
%     band contains 43,200 values for 89° 59' 45'' N, then followed by a ...
%     band of 43,200 values at 89° 59' 15'' N and so on at 30 arc second ...
%     latitude intervals down to 89° 59' 45'' S. The data values are pixel ...
%     centre registered i.e. they refer to elevations at the centre of grid ...
%     cells.

