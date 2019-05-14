function [XP,YP,ZP]=utm2utm(XT,YT,ZT,ZP)
% [XP,YP,ZP]=utm2utm(XT,YT,ZT,ZP)
%
% INPUT:
%
% XT,YT    A grid in a certain old UTM system
% ZT       The string identifying the old UTM system [default: '32N']
% ZP       The string identifying the new UTM system [default: '33S']
%
% OUTPUT:
%
% XP, YP   The grid in the new system
% ZP       The string identifying the new UTM system [default: '33S']
%
% Last modified by fjsimons-at-alum.mit.edu, 05/13/2019

% Default values
defval('ZT','32N')
defval('ZP','33S')

% Onto the projection
utmstruct=defaultm('utm'); 
utmstruct.zone=ZT; 
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);

% This is essentially UTM2DEG
[LAT,LOT]=minvtran(utmstruct,XT,YT);

clear utmstruct
utmstruct=defaultm('utm'); 
utmstruct.zone=ZP;
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);

% This is essentially DEG2UTM
[XP,YP]=mfwdtran(utmstruct,LAT,LOT);

