function [lon,lat]=ibtracs(code)
% [lon,lat]=IBTRACS(code)
%
% Downloads hurricane track data 
%
% INPUT:
%
% code      A hurricane code, e.g. '1984025S14073'
% 
% OUTPUT:
%
% lon lat   Matrices of dimensions [M x nlon] or [M x nlat]
%           because there may be M solutions for lon and lat
%
% EXAMPLE:
%
% lonlat=ibtracs('1984025S14073');
%
% Last modified by fjsimons-at-alum.mit.edu, 09/29/2017

% Specify where to get it
servername='ftp://eclipse.ncdc.noaa.gov';
directoryn='/pub/ibtracs/v03r04/ibtracs/';
extensionn='.ibtracs.v03r04.nc';
% This will also be our local filename
filename=sprintf('%s%s',code,extensionn);

% Tried WEBSAVE, tried MGET, neither worked
if exist(filename,'file')~=2
  system(sprintf('wget %s',fullfile(servername,directoryn,filename)));
end

% Load the variables
lon=ncread(filename,'lon_from_source');
lat=ncread(filename,'lat_from_source');

% Remove the -999 which clearly aren't any good
lon(lon==-999)=NaN;
lat(lat==-999)=NaN;

