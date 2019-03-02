function [xl,yl]=utmlabels(utmzone)
% [xl,yl]=UTMLABELS(utmzone)
%
% Plots good-looking UTM labels on the current axes
% 
% INPUT:
%
% utmzone   String with the UTM zone (e.g. from DEG2UTM)
%
% OUTPUT:
%
% xl,yl     The x and y label handles
%
%
% Last modified by fjsimons-at-alum.mit.edu, 03/02/2019

% Note: the ticks marked must be integers to begin with!
xtix=get(gca,'xtick');
xtix=xtix(1:1:end);
ytix=get(gca,'ytick');
ytix=ytix(1:1:end);
set(gca,'Xtick',xtix,...
	'XtickLabel',cellstr(reshape(sprintf('%6.6i',xtix),6,[])'))
set(gca,'Ytick',ytix,...
	'YtickLabel',cellstr(reshape(sprintf('%7.7i',ytix),7,[])'))
longticks(gca,2)
grid on
xl(1)=xlabel(sprintf('UTM zone %s easting',utmzone));
yl(1)=ylabel(sprintf('UTM zone %s northing',utmzone));
