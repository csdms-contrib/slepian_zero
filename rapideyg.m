function [XE,YE,ZE]=rapideyg(nprops,xver)
% [XE,YE,ZE]=RAPIDEYG(nprops,xver)
%
% Returns a RAPIDEYE grid from a predetermined property structure
%
% INPUT:
%
% nprops     A minimal structure with properties from RAPIDEYE
% xver       >0 Provides excessive verification 
%            0  Does not provide excessive verification
% 
% OUTPUT:
%
% XE,YE      A complete and regular grid on which to plot the data
% ZE         The string identifying the UTM system
%
% Last modified by fjsimons-at-alum.mit.edu, 05/13/2019

% Default
defval('xver',1)

% RAPIDEYE DATA GRID from the top-left corner points wih XE and YE in the
% same orientation as topodata which is NORTH up
xeye=[nprops.xs(1)+nprops.sp/2:+nprops.sp:nprops.xs(1)+nprops.nc*nprops.sp-nprops.sp/2];
yeye=[nprops.ys(1)-nprops.sp/2:-nprops.sp:nprops.ys(1)-nprops.nr*nprops.sp+nprops.sp/2];
[XE,YE]=meshgrid(xeye,yeye);

% Those things are equally spaced!
if xver>0
  diferm(diff(XE,[],1))
  diferm(diff(YE,[],2))
end

% The UTM zone
ZE=nprops.up;
