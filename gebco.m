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
% EXAMPLES:
%
%% Some random locations:
% mn=randij(210); [z,lon,lat]=gebco(-180+rand(mn)*360,-90+rand(mn)*180);
%% A whole grid that should LOOK like the original data set
% [LO,LA]=meshgrid(-180:3:180,90:-3:-90);
% [z,lon,lat]=gebco(LO,LA); imagefnan([-180 90],[180 -90],z)
%% A whole grid that should BE like the original data set around somewhere
% c11=[100 -10]; cmn=[140 -40]; spc=1/10;
% [LO,LA]=meshgrid(c11(1):spc:cmn(1),c11(2):-spc*2:cmn(2));
% [z,lon,lat]=gebco(LO,LA); imagefnan(c11,cmn,z,'demmap',[-7473 5731])
%% Test it against the WMS on the GEBCO page itself! See below
%
% SEE ALSO:
%
% https://www.gebco.net/
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 01/11/2019

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

% Grid or pixel registration? See below
if strcmp(vers,'1MIN')
  flg=0; else ; flg=1;
end

% We know that the data were pixel-centered, see at the bottom of this
% function. So here are the matrix corner pixel centers of the global map.
c11=[-180+dxdy(1)/2*flg  90-dxdy(2)/2*flg];
cmn=[ 180-dxdy(1)/2*flg -90+dxdy(2)/2*flg];

% In which of the tiles have we landed? We know that the original global
% grid was quoted from -180 across in lon and from 90 down in lat..
cindep=max(1,ceil(    [lon+180]/[360/npc]));
rindep=max(1,ceil(npc-[lat+90 ]/[180/npc]));
cindex=unique(cindep);
rindex=unique(rindep);

% If you are spread across multiple tiles you're in trouble
if length(cindex)~=1 || length(rindex)~=1
  % What are the unique running tile numbers?
  wtile=sub2ind([npc npc],rindep,cindep);
  utile=unique(wtile);
  % Initialize output
  z=nan(size(lon));
  % You should recursively apply this algorithm for the unique pairs!
  for index=1:length(utile)
    % Where are those that these unique tiles refer to?
    witsj=wtile==utile(index);
    % Prepare to preserve the size of the input/output, temp array that
    % won't throw the tiles off... not a memory-saving trip...
    lonw=lon; lonw(~witsj)=mean(lonw(witsj));
    latw=lat; latw(~witsj)=mean(latw(witsj));
    % If you are doing this right, you NOW end up in unique tiles
    zz=gebco(lonw,latw,vers,npc,method,xver);
    % And then stick in the output at the right place
    z(witsj)=zz(witsj);
  end

  % And then leave, because you are finished
  % Output
  varns={z,lon,lat};
  varargout=varns(1:nargout);
  return
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

% Note that "any" needs a vector input to do this job
if any(isnan(z(:)))
  % Need a different interpolation, it's an extrapolation in a sense
  % If it's only one number, give a simple reason
  if length(lon)*length(lat)==1
    disp(sprintf('Longitude given %g to %g wanted %g',min(lonpc),max(lonpc),lon))
    disp(sprintf('Latitude given %g to %g wanted %g',min(latpc), max(latpc),lat))
  end
  % This is a bit of a pain, I suppose
  F=griddedInterpolant({flipud(latpc(:)) lonpc(:)},flipud(zpc),method);
  % Apply the interpolation for the whole set, make sure there are no surprises
  if xver==1
    zi=F(lat,lon);
    diferm(zi(~isnan(z))-z(~isnan(z)))
    z=zi;
  else
    z=F(lat,lon);
  end
end

% Output
varns={z,lon,lat};
varargout=varns(1:nargout);

% Grid documentation for 2008 and 2014 it's pixel-registered.
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
%
%
% NOTE: FOR '1MIN' it's grid registered. The complete data set gives global
% coverage, spanning 90° N, 180° W to 90° S, 180° E on a one arc-minute
% grid. The grid consists of 10,801 rows x 21,601 columns giving a total of
% 233,312,401 points. The data values are grid line registered i.e. they
% refer to elevations centred on the intersection of the grid lines.

% Check the WMS!
% c11=[-20 51] ; cmn=[-19 50];
% urlread(sprintf('http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?request=getfeatureinfo&service=wms&crs=EPSG:4326&layers=gebco_latest_2&query_layers=gebco_latest_2&BBOX=%i,%i,%i,%i&info_format=text/plain&service=wms&x=20&y=20&width=900&height=600&version=1.3.0',cmn(2),c11(1),c11(2),cmn(1)))

% http://webhelp.esri.com/arcims/9.3/general/mergedprojects/wms_connect/wms_connector/get_featureinfo.htm
% BBOX is minx,miny,maxx,maxy
% X=pixel_column X coordinate in pixels of feature measured from upper
% left corner of the map. YY=pixel_row Y coordinate in pixels of feature
% measured from upper left corner of the map. 
% http://webhelp.esri.com/arcims/9.3/general/mergedprojects/wms_connect/wms_connector/get_featureinfo.htm


% ETOPO1 vs GEBCO2014
% http://www.oceanpotential.com/pre-assessment/datasets/bathymetry/index.html
