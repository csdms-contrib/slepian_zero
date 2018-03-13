function [lon,lat,elev,labs]=pathfinderpoints(fname)
% [lon,lat,elev,labs]=PATHFINDERPOINTS(fname)
%
% Reads a generic POINTS coordinate file from GPS Pathfinder Office
% stored with defaults in CSV format.
%
% INPUT:
%
% fname    A string with a full filename [defaulted]
%
% OUTPUT:
%
% lon      Longitudes, presumed decimal degrees on WGS84
% lat      Latitudes presumed decimal degrees on WGS84
% elev     Elevation, presumed meters above EGM96
% labs     Labels for the individual points
%
% SEE ALSO:
%
% PATHFINDERLINES
%
% Last modified by fjsimons-at-alum.mit.edu 03/12/2018

% Download the additional codes for any functions you don't have
defval('fname','Point_generic.csv')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the POINTS data
warning off MATLAB:table:ModifiedVarnames
p=readtable(fname);
warning on MATLAB:table:ModifiedVarnames

% Assign to flattened variables
lon=p.Lon;  % or p.(7)
lat=p.Lat;  % or p.(6)
elev=p.z_MSL_;
labs=p.Name;







