function [xe,ye,ze]=kmz2utm(fname)
% [xe,ye,ze]=KMZ2UTM(fname)
%
% Reads a KMZ file and returns a structure with the variables in UTM
% format
%
% INPUT:
%
% fname    A KMZ filename
%
% Last modified by fjsimons-at-alum.mit.edu, 09/09/2019

% Transform the file in question with UNZIP and KML2GMT
system(sprintf('unzip %s',fname));
% This to get rid of possible future timestamps
system(sprintf('touch %s','doc.kml'));
system(sprintf('kml2gmt  %s | awk ''NR>3 {print}'' >! %s.txt','doc.kml',pref(fname)));
system(sprintf('rm -rf %s','doc.kml'));

% Load and convert to UTM
data=load(sprintf('%s.txt',pref(fname)));
warning on MATLAB:nargchk:deprecated
[xe,ye,ze]=deg2utm(data(:,1),data(:,2));
warning on MATLAB:nargchk:deprecated


