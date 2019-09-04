function varargout=tinitalg(hdr,TV,index,dirp,diro,xver)
% [XT,YT,ZT,topodata,index]=TINITALG(hdr,TV,index,dirp,diro,xver)
%
% Gets and displays data and grid from a TINITALY directory
%
% INPUT:
%
% hdr        All the header name strings in a cell array
% TV         All the header variables, in a cell
% index      The running index for the file that you really want
% dirp       Subdirectory [e.g. 'DATA'] of:
% diro       Main directory [e.g. '/u/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       >0 Provides excessive verification 
%            0  Does not provide excessive verification
%
% OUTPUT:
%
% XT,YT      A complete and regular grid on which to plot the data
% ZT         The string identifying the UTM system
% topodata   The topography data that you requested
% index      The index that you were using
%
% EXAMPLE:
%
% [hdr,TV,TN,TA,bx,by]=tinitalh;
% [XT,YT,ZT,topodata,index]=tinitalg(hdr,TV,randi(length(hdr)),[],[],1);
% sax=[-2154.5 1601.4];
% imagefnan([XT(1),YT(1)],[XT(end) YT(end)],topodata,'sergeicol',sax)
% title(nounder(hdr{index}))
%
% Last modified by fjsimons-at-alum.mit.edu, 09/03/2019 

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
% Graphical checking of grid parameters
defval('xver',1)

% Topodata grid properties
nc=TV{index}(1);
nr=TV{index}(2);
xl=TV{index}(3);
yl=TV{index}(4);
sp=TV{index}(5);  

% TOPOGRAPHY DATA GRID, wih XT and YT in the same orientation as
% topodata which is: NORTH up
xtopo=[xl(1)+sp/2      :+sp:xl(1)+nc*sp-sp/2] ;
ytopo=[yl(1)+nr*sp-sp/2:-sp:yl(1)+sp/2      ]';
% A very complete grid!
[XT,YT]=meshgrid(double(xtopo),double(ytopo));
% Those things are equally spaced!
if xver>0
  diferm(diff(XT,[],1))
  diferm(diff(YT,[],2))
end

% We know that the TINITALY data set is using 32 WGS84, it's in their
% Read_me.pdf and their Italia_tinitaly.jpg.aux.xml 
% I guess EPSG:3064 http://epsg.io/3064
% So we try this:
ZT='32N';

% See 10.1016/j.cageo.2011.04.018 and also
% 10.4401/ag-4424 writes: The adopted coordinate systems for TINITALY/01 is
% Universal Transverse Mercator/World Geodetic System 1984 (UTM-WGS84): the
% 32 zone (for Western Italy) and the 33 zone (for Eastern
% Italy). Coordinate transformation from other systems to the adopted one 
% were performed using the Traspunto software (Maseroli, 2002) based on the
% IGM95 Italian network, Europe ETRS89 Reference System (Surace, 1997). The
% planimetric precision of this coordinate transformation is 20 cm on the
% average, with a maximum error less than 0.85 m. As a final step the 33
% zone database, reprojected to 32 zone, was merged with the resident 32
% zone database obtaining the thorough seamless TIN of Italy.
% Original file format is "ESRI ASCII Raster". Data is in Universal Transverse
% Mercator coordinate system (UTM), World Geodetic System WGS 84. Notice
% that all the DEM is projected in zone 32N, even if eastern italian
% regions are in zone 33N (in case you need to re-project portions of
% the DEM). Couresy of Simone Tarquini.

% May convert the structure with the XML inside Tinitaly and the EPSG files

if nargout>3
  % Load its topography inside the array called topodata
  load(pref(fullfile(diro,dirp,hdr{index})))
  % Call the topodata generically "topodata"
  eval(sprintf('topodata=%s.topodata;',pref(hdr{index}))) 
else
  topodata=[];
end

% All the outputs fit to print
varns={XT,YT,ZT,topodata,index};
varargout=varns(1:nargout);
