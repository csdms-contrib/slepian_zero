function [lon,lat,elev,labu,code,codu]=pathfinderlines(fname)
% [lon,lat,elev,labu,code,codu]=PATHFINDERLINES(fname)
%
% Reads a generic LINES coordinate file from GPS Pathfinder Office
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
% labu     Unique set of labels for the individual lines
% code     Numbered line codes identifying the various lines
% codu     Unique code set for the individual lines
%
% SEE ALSO:
%
% PATHFINDERPOINTS
%
% Last modified by fjsimons-at-alum.mit.edu 03/12/2018

% Download the additional codes for any functions you don't have
defval('fname','Line_generic.csv')

% Read the LINES data
l=readtable(fname);

% Line codes
code=l.Var1;
% Elevation in m (e.g. above EGM96 mean sea level)
elev=l.Var5;
% Longitude and latitude in decimal degrees (e.g. on WGS84)
lat=l.Var6;
lon=l.Var7;

% Find the unique line codes
[codu,codi]=unique(code);

% That makes these the unique labels
labu=l.Var3(codi);

