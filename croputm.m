function [lonutm,latutm,axutm,utmzone]=croputm(axlim,lon,lat)
% [lonutm,latutm,axutm,utmzone]=CROPUTM(axlim,lon,lat)
%
% Limit view and transform WGS84 geocentric degrees to UTM coordinates
%
% INPUT:
%
% axlim      The desired axis limits (degrees)
% lon,lat    The longitudes and latitudes
% 
% OUTPUT:
%
% lonutm     The UTM eastings (m)
% latutm     The UTM northings (m)
% axutm      The UTM axis limits (m)
% utmzone    String with the UTM zone name
%
% Last modified by fjsimons-at-alum.mit.edu, 11/13/2012

% Find the not-a-numbers
wrnan=[isnan(lon) | isnan(lat)];
% Find those inside the region of interest
insi=inpolygon(lon,lat,axlim([1 1 2 2]),axlim([3 4 4 3]));
lonutm=lon(insi | wrnan);
latutm=lat(insi | wrnan);
% Find the non-not-a-numbers
ntnan=[~isnan(lonutm) & ~isnan(latutm)];
% Convert from degrees to UTM coordinates
[utme,utmn,utmzone]=deg2utm(latutm(ntnan),lonutm(ntnan));
% Stick those in the original vector, leaving the nans
lonutm(ntnan)=utme;
latutm(ntnan)=utmn;
% Transform the axis limits themselves
[axe,axn]=deg2utm(axlim([3 4]),axlim([1 2]));
axutm=[axe(:)' axn(:)'];

