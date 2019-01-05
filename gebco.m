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
[mname,up,dn,lt,rt]=readGEBCO(vers,npc);

keyboard


