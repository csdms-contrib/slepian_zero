function [XP,YP,ZP]=utm2utm(XT,YT,ZT,ZP,xver)
% [XP,YP,ZP]=utm2utm(XT,YT,ZT,ZP,xver)
%
% INPUT:
%
% XT,YT    A grid in a certain old UTM system
% ZT       The string identifying the old UTM system [default: '32N']
% ZP       The string identifying the new UTM system [default: '33S']
% xver     1 Provides some on-screen diagnostics
%          0 Does not provide any diagnostics

% OUTPUT:
%
% XP, YP   The grid in the new system
% ZP       The string identifying the new UTM system [default: '33S']
%
% Last modified by fjsimons-at-alum.mit.edu, 11/01/2025

% Default values
defval('ZT','32N')
defval('ZP','33S')
defval('xver',0)

% Onto the projection
utmstruct=defaultm('utm'); 
utmstruct.zone=ZT; 
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);

% This is essentially UTM2DEG
[LAT,LOT]=minvtran(utmstruct,XT,YT);
if xver>0
  disp(sprintf('%s finished inverse transform',upper(mfilename)))
end

clear utmstruct
utmstruct=defaultm('utm'); 
utmstruct.zone=ZP;
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);

% This is essentially DEG2UTM
[XP,YP]=mfwdtran(utmstruct,LAT,LOT);

if xver>0
  disp(sprintf('%s finished forward transform',upper(mfilename)))
end


