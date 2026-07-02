function lola=venusregs(id)
% lola=VENUSREGS(id)
%
% Plots Venus regions data
%
% INPUT:
%
% id       A region id number
%
% OUTPUT:
%
% lola     Longitudes and latitudes
%
% Last modified by fjsimons-at-alum.mit.edu, 07/02/2026

defval('id',ceil(rand*77))

% This is a very small piece of LOADITMAKEIT within VENUSTATS
load('/data1/fjsimons/IFILES/VENUS/DATA/plmData/plmVenus_D-5.mat',...
         sprintf('V%4.4i_03',index))

% Get the regional bounding curve in global coordinates
lola=eval(sprintf('V%4.4i_03.geo.XY360',index));

