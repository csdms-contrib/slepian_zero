function varargout=tinitaly(nprops,dirp,diro,xver,alldata)
% topodata=TINITALY(nprops,dirp,diro,xver,alldata)
%
% Matches a coordinate set from RAPIDEYE to a TINITALY data file
%
% INPUT:
%
% nprops     A minimal structure with properties from RAPIDEYE
% dirp       Subdirectory [e.g. 'DATA'] of:
% diro       Main directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
% alldata    A data matrix from RAPIDEYE, so that xver=2 can do some plotting
%
% OUTPUTL
%
% topodata   The topography data for the region corresponding to nprops
%
% EXAMPLE:
%
% [alldata,nprops]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3');
% tinitaly(nprops,[],[],[],alldata)
%
% Last modified by fjsimons-at-alum.mit.edu, 04/29/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',2)

% No default data file, but provide one if you want it checked
defval('alldata',[])

try
  % Find all the hdr files inside the directory
  hdr=ls2cell(fullfile(fullfile(diro,dirp),'*.hdr'));
catch
  % Some checks and balances
  disp(sprintf('Looking inside %s I am finding\n',fullfile(diro,dirp)))
  ls(fullfile(diro,dirp))
  disp('which I expect to contain at least one hdr file')
end

% We know how many header lines there are in each of the hdr files
nhdr=6;
% We know that the TINITALY data set is using 32 WGS84, it's in their
% Read_me.pdf and their Italia_tinitaly.jpg.aux.xml 
% I guess EPSG:3064 http://epsg.io/3064
% So we try this:
tzs='32N';

% 10.1016/j.cageo.2011.04.018
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

%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only if you have the headers pre-prepared this will work
for index=1:length(hdr)
  % The HDR filename
  fhdr=fullfile(diro,dirp,hdr{index});
  % Read it in
  H=textscan(fopen(fhdr),'%s %d',nhdr);
  % Shove the values inside a growing cell array
  TV{index}=H{2};
end

% Collate all the header information in TA and keep the names in TN
TN=H{1};
TA=[TV{:}];
% Do not get confused with whatever else you read in
clear fhdr H


%%%%%%%%%% VISUAL CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of all the metadata in your directory
if xver>1
  % Plot ALL the boxes of the header, they are supposedly all in zone 32
  % Compare to http://tinitaly.pi.ingv.it/immagini/Imm_TINITALY_DOWNLOAD_03.jpg
  clf
  ah=gca;
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
  % Annotate
  shrink(ah,1.5,1.5)
  t(1)=title(sprintf('From the headers inside\n %s',...
		     fullfile(diro,dirp)));
  movev(t(1),range(ylim)/10)
end


%%%%% FIND APPROPRIATE TOPODATA FILES TO MATCH RAPIDEYE %%%%%%%%%%%%%%%%%%%
% Let's say that we have found the tile index that matches nprops
index=10; % And 7 and 8

 %%%%%%%%%% TOPODATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Load its topography inside the array called topodata
 load(pref(fullfile(diro,dirp,hdr{index})));
 % Call the topodata generically "topodata"
 eval(sprintf('topodata=%s.topodata;',pref(hdr{index}))) 

 % Then now we assign the topodata grid properties to variables as in nprops
 nc=TV{index}(1);
 nr=TV{index}(2);
 xl=TV{index}(3);
 yl=TV{index}(4);
 sp=TV{index}(5);  

 % TOPOGRAPHY DATA GRID, wih XT and YT in the same orientation as
 % topodata which is: NORTH up
 xtopo=[xl(1)+sp/2      :+sp:xl(1)+nc*sp-sp/2] ;
 ytopo=[yl(1)+nr*sp-sp/2:-sp:yl(1)+sp/2      ]';
 [XT,YT]=meshgrid(xtopo,ytopo);

 % Now get rid of all the parameters to not get confused
 clear nc nr xl yl sp

% Check the overlap between tiles I thought they were seamless

% Transform the UTM coordinates of this image to the RAPIDEYE zone 
% I see a 90 m overlap in the box limites in my three examples, on all
% sides, on all sides. Now check the data repetition for 10 7 8
% e43515_s10.hdr e43015_s10.hdr e43020_s10.hdr
% topodata1(end-9:end,1:5)-topodata2(1:10,1:5)   
% topodata2(1:11,end-9:end)-topodata3(1:11,1:10) 
% topodata1(end-9:end,size(topodata2,2)-9:size(topodata2,2))-topodata3(1:10,1:10)   


%%%%%%%%%% VISUAL CHECK TOPODATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the topodata you have just identified
if xver>1
  disp('Hit ENTER to continue')
  pause
  clf
  ah(1)=subplot(221)
  pmeth=2;
  caxx=[-2154.5 1601.4];
  % Plot it!
  plotit(XT,YT,topodata,caxx)
end

%%%%%%%%%%%%%%% NOW THE RAPIDEYE IMAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RAPIDEYE DATA GRID from the top-left corner points
xs=nprops.xs;
ys=nprops.ys;
sp=nprops.sp;
nc=nprops.nc;
nr=nprops.nr;
% RAPIDEYE DATA GRID, wih XE and YE in the same orientation as
% topodata which is north up
xeye=[xs(1)+sp/2:+sp:xs(1)+nc*sp-sp/2];
yeye=[ys(1)-sp/2:-sp:ys(1)-nr*sp+sp/2];
[XE,YE]=meshgrid(xeye,yeye);

%%%%%%%%%% VISUAL CHECK RAPIDEYE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the alldata you have just entered
 if xver>1
  percs=[2 99];
  toplot=double(alldata(:,:,1));
  caxx=round(10.^prctile(log10(toplot(:)),percs));
  ah(2)=subplot(222);

  % Plot it!
  plotit(XE,YE,toplot,caxx)
end

keyboard

% Convert the struct with the XML inside Tinitaly and the EPSG files

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotit(XX,YY,data,sax,pmeth)

% These examples work best in 2014 since I need to adapt ADDCB
% The following three statements come out right, e.g. for e42510_s10

defval('pmeth',2)

switch pmeth 
 case 1
  % Barebones
  imagesc(data); 
 case 2
  % Better
  imagesc(XX(1,:),YY(:,1),data)
  axis xy
  colormap(sergeicol)
  caxis(sax)
  colorbar
 case 3
  % Slower and more flexible
  imagefnan([XX(1) YY(1)],[XX(end) YY(end)],data,'sergeicol',sax)
  addcb('hor',sax,sax,'sergeicol',abs(sax(1)))
end
