function z=gebco(lon,lat,vers,npc)
% z=gebco(lon,lat,vers,npc)
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
%
% OUTPUT:
%
% z        The elevation/bathymetry at the requested point
%
% SEE ALSO:
%
% https://www.gebco.net/
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 01/05/2019

% Default lon and lat, for good measure, take those from the examples of 
% https://www.gebco.net/data_and_products/gebco_web_services/web_map_service/#getmap
% for comparison with WMS GetFeatureInfo requests
defval('lon',-19.979167)
defval('lat', 50.9625)

% Default version
defval('vers',2014)
% Default tiling
defval('npc',10);

% Get information on where the data files are being kept
[mname,sname,up,dn,lt,rt,dxdy,NxNy]=readGEBCO(vers,npc);

% Now you should know that the original global grid was quoted from -180
% across in longitude and from 90 down in latitude, so that you can figure
% out which tile you are in based on the piecewise subdivision. You
% should also note that the data were pixel centered, from the
% documentation, quoted at the bottom of this function,
% https://www.bodc.ac.uk/data/documents/nodb/301801/#6_format

% In other words, here are the matrix corner pixel centers of the global map
c11=[-180+dxdy(1)/2  90-dxdy(2)/2];
cmn=[ 180-dxdy(1)/2 -90+dxdy(2)/2];

% Which tile are we in? THIS WILL NEED REVISITING
cindex=max(1,ceil([lon-c11(1)]/[360/npc]));
rindex=max(1,ceil(npc-[lat-cmn(2)]/[180/npc]));
% So which file should we be loading? The stored variable is 'zpc'
load(fullfile(mname,sprintf('%s_%2.2i_%2.2i',sname,rindex,cindex)));

% The pixel-centers of the longitudes in the global grid
lons1=linspace(c11(1),         cmn(1),NxNy(1));
lons2=         c11(1): dxdy(1):cmn(1);
% Extra verification
diferm(lons1,lons2,9)
% The pixel-centers of the latitudes in the global grid
lats1=linspace(c11(2),         cmn(2),NxNy(2));
lats2=         c11(2):-dxdy(2):cmn(2);
% Extra verification
diferm(lats1,lats2,9)

% Assign a local grid to the pieces loaded
latpc=lats(up(rindex):dn(rindex));
lonpc=lons(lt(cindex):rt(cindex);

% Then interpolate from what you've just loaded to what you want
% Make sure you use a rule that can extrapolate... if it comes out as a NaN
z=interp2(lonpc,latpc,lon,lat);
% Fix any and all of the NaN

keyboard

% Grid documentation
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

