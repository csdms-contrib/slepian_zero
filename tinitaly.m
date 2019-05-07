function tinitaly(nprops,dirp,diro,xver)
% TINITALY(nprops,dirp,diro,xver)
%
% Matches a coordinate set from RAPIDEYE to a TINITALY data file
%
% INPUT:
%
% nprops     A minimal properties structure from RAPIDEYE
% dirp       Directory [e.g. 'DATA']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
%
% EXAMPLE:
%
% [alldata,nprops]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3');
% tinitaly(nprops)
%
% Last modified by fjsimons-at-alum.mit.edu, 04/29/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',1)

% Find all the hdr files inside the directory
try
  hdr=ls2cell(fullfile(fullfile(diro,dirp),'*.hdr'));
catch
  % Some checks and balances
  disp(sprintf('Looking inside %s I am finding\n',fullfile(diro,dirp)))
  ls(fullfile(diro,dirp))
  disp('which I expect to contain at least one hdr file')
end

% We know how many header lines there are, this is fixed
nhdr=6;
% We know that the TINITALY data set is using 32 (or 33?)
tzs='32N';

% Tarquini 2007 writes:
% The adopted coordinate systems for TINITALY/01 is Universal Transverse
% Mercator/World Geodetic System 1984 (UTM-WGS84): the 32 zone (for
% Western Italy) and the 33 zone (for Eastern Italy). Coordinate
% transformation from other systems to the adopted one were performed
% using the Traspunto software (Maseroli, 2002) based on the IGM95
% Italian network, Europe ETRS89 Reference System (Surace, 1997). The
% planimetric precision of this coordinate transformation is 20 cm on the
% average, with a maximum error less than 0.85 m.
% As a final step the 33 zone database, reprojected to 32 zone, was
% merged with the resident 32 zone database obtaining the thorough
% seamless TIN of Italy.

% I guess EPSG:3064 http://epsg.io/3064

%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have the headers pre-prepared this will work
for index=1:length(hdr)
  % The HDR filename
  fhdr=fullfile(diro,dirp,hdr{index});
  % Read it in
  H=textscan(fopen(fhdr),'%s %d',nhdr);
  % Shove it in
  TV{index}=H{2};
end

% Collate
TN=H{1};
TA=[TV{:}];

if xver>0
  % Plot the boxes thusly collected which are supposedly in zone 32
  % Compare to http://tinitaly.pi.ingv.it/immagini/Imm_TINITALY_DOWNLOAD_03.jpg
  clf
  [BX,BY]=deal(nan(length(hdr),2));
  for index=1:length(hdr)
    nc=TV{index}(1);
    nr=TV{index}(2);
    xl=TV{index}(3);
    yl=TV{index}(4);
    sp=TV{index}(5);
    % Plot the outer extent of the boxes, as I interpret it now
    bx=[xl xl xl xl xl]+[0 0      nc*sp nc*sp 0];
    by=[yl yl yl yl yl]+[0 nr*sp  nr*sp 0     0];
    BX(index,:)=minmax(bx);
    BY(index,:)=minmax(by);
    plot(bx,by); hold on
    text(double(bx(1)+[bx(3)-bx(1)]/2),...
	 double(by(1)+[by(2)-by(1)]/2),...
	 pref(pref(hdr{index}),'_'))
  end
  hold off
  axis image
  xel=[min(BX(:,1)) max(BX(:,2))];
  yel=[min(BY(:,1)) max(BY(:,2))];
  xlim(xel+[-1 1]*range(xel)/20)
  ylim(yel+[-1 1]*range(yel)/20)
end

% TOPOGRAPHY DATA GRID, XT and YT in the same orientation as topodata
xtopo=[xl(1)+sp/2:+sp:xl(1)+nc*sp-sp/2];
ytopo=[yl(1)+nr*sp-sp/2:-sp:yl(1)+sp/2]';
[XT,YT]=meshgrid(xtopo,ytopo);

% Transform the UTM coordinates of this image to the RAPIDEYE zone 

% Let's say that we have found the tile to be e43515, index=9
index=10;
fhdr=fullfile(diro,dirp,hdr{index});
load(pref(fhdr));
eval(sprintf('topodata=%s.topodata;',pref(hdr{index})))


% The following three statements come out right, e.g. for e42510_s10
% These examples work best in 2014 since I need to adapt ADDCB
% imagesc(e43515_s10.topodata); caxx=[-2154.5 1601.4];
% imagesc(XT(1,:),YT(:,1),e43515_s10.topodata); axis xy; colormap(sergeicol); caxis(caxx); colorbar
% imagefnan([XT(1) YT(1)],[XT(end) YT(end)],e43515_s10.topodata,'sergeicol',caxx)
% addcb('hor',caxx,caxx,'sergeicol',abs(caxx(1)))

keyboard

[alldata,nprops,props,rgbdata,alfadat]=rapideye;

% RAPIDEYE DATA GRID from the top-left corner points
xs=nprops.xs;
ys=nprops.ys;
sp=nprops.sp;
nc=nprops.nc;
nr=nprops.nr;
xeye=[xs(1)+sp/2:+sp:xs(1)+nc*sp-sp/2];
yeye=[ys(1)-sp/2:-sp:ys(1)-nr*sp+sp/2];
[XE,YE]=meshgrid(xeye,yeye);

% image(xeye,yeye,alfadat); axis xy

% Maybe it's 33?

% Convert TOPODATA to the RAPIDEYE coordinate system
utmstruct=defaultm('utm'); 
% What TOPODATA was
utmstruct.zone=tzs;  % or 33
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);
% This is essentially UTM2DEG
[LA,LO]=minvtran(utmstruct,double(XT),double(YT));

utmstruct=defaultm('utm'); 
% What TOPODATA will become
utmstruct.zone='33N'
utmstruct.geoid=wgs84Ellipsoid;
utmstruct=defaultm(utmstruct);
% This is essentially DEG2UTM
[XP,YP]=mfwdtran(utmstruct,LA,LO);

% imagesc(XP(1,:),YP(:,1),e43515_s10.topodata); axis xy; colormap(sergeicol); caxis(caxx); colorbar
