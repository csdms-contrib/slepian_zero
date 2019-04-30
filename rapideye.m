function varargout=rapideye(froot,dirp,diro,xver,urld)
% [alldata,nprops,props,rgbdata,alfadat]=RAPIDEYE(froot,dirp,diro,xver,urld)
%
% Loads an returns a RAPIDEYE satellite image and its properties.
%
% INPUT:
%
% froot      Filename root             [e.g. '3357121_2018-09-11_RE3_3A']
% dirp       Directory [e.g. '20180911_094536_3357121_RapidEye-3']
% diro       Directory [e.g. '/u/fjsimonsIFILES/TOPOGRAPHY/ITALY/RAPIDEYE']
% xver       1 Provides excessive verification [default]
%            0 Does not provide excessive verification
%            2 Provides a graphical test for the very beginning  
% urld       A URL a directory with a copy of the JSON file for
%            when a direct read and parsing using JSONDECODE fails
%            [e.g. 'http://geoweb.princeton.edu/people/simons/JSON']
%
% OUTPUT:
%
% alldata    All data from 'froot'_Analytic.tif inside diro/dirp, UINT16
%            alldata(:,:,1) red
%            alldata(:,:,2) green
%            alldata(:,:,3) blue
%            alldata(:,:,4) red-edge
%            alldata(:,:,5) near-infra-red
% nprops     A minimal properties structure with
%            nprops.xs   The top left pixel edge in UTM easting
%            nprops.ys   The top left pixel edge in UTM northing
%            nprops.sp   The pixel resolution in m
%            nprops.lo   The four limit longitudes clockwise from NW
%            nprops.la   The four limit latitudes clockwise from NW
%            nprops.nc   The number of rows
%            nprops.nr   The number of columns
% props      The complete properties structure directly from the TIFF
% rgbdata    Just the RGB data values, UINT8
% alfadat    Just the alfa data values, UINT8
%
% EXAMPLE:
%
% Making the default inputs work, my directory
% /u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/20180911_094536_3357121_RapidEye-3
% contains the four necessary files 
%                 3357121_2018-09-11_RE3_3A_udm.tif
%                 3357121_2018-09-11_RE3_3A_Analytic.tif
%                 3357121_2018-09-11_RE3_3A_Analytic_metadata.xml
% 20180911_094536_3357121_RapidEye-3_metadata.json
% And in that case, I am able to do, without any further inputs:
% [alldata,nprops,props,rgbdata,alfadat]=rapideye;
% Most often you will be in the directory one up from 'dirp' and
% call it as follows, either of:
% [alldata,nprops,props,rgbdata,alfadat]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3','.',1);
% [alldata,nprops,props,rgbdata,alfadat]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3',pwd,1);
%
% SEE ALSO
%
% https://www.planet.com/products/planet-imagery/ 
% https://developers.planet.com/docs/api/reorthotile/
%
% Tested on 9.0.0.341360 (R2016a)
% Tested on 9.6.0.1072779 (R2019a)
%
% Last modified by fjsimons-at-alum.mit.edu, 04/29/2019

%%%%%%%%%% FILENAME AND DIRECTORY ORGANIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%

% Root of the filename for three of the four files inside the directory
defval('froot','3357121_2018-09-11_RE3_3A')
% Bottom-level directory name, taken from the Rapideye download
defval('dirp','20180911_094536_3357121_RapidEye-3')
% Top-level directory name, where you keep the Rapideye directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE')

% Remote directory where I copied the JSON file from DIRP so as to use
% WEBREAD, noting that the JSON filename derives from DIRP, see
% below, and note that JSONDECODE may work, in which case this is moot
defval('urld','http://geoweb.princeton.edu/people/simons/JSON')

% The JSON metadata local file, if it exists
file1=fullfile(diro,dirp,sprintf('%s_metadata.json'        ,dirp ));
% The UDM metadata local file, which should exist
file2=fullfile(diro,dirp,sprintf('%s_udm.tif'              ,froot));
% The XML metadata local file, which should exist
file3=fullfile(diro,dirp,sprintf('%s_Analytic_metadata.xml',froot));
% The ANALYTIC actual data local file, which should exist
file4=fullfile(diro,dirp,sprintf('%s_Analytic.tif'         ,froot));

% The JSON metadata webfile, may be a backup for the local file
file5=fullfile(     urld,sprintf('%s_metadata.json'        ,dirp ));

% I advocate checking grid parameters and file sizes for ever
defval('xver',1)

% Some checks and balances
disp(sprintf('Looking inside %s I am finding\n',fullfile(diro,dirp)))
ls(fullfile(diro,dirp))
disp('which I expect to contain two tif, one json and one xml file')


%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read the JSON file with metadata
try
  % Locally provided if you've got access to JSONDECODE
  fid=fopen(file1);
  tiffm=jsondecode(fscanf(fid,'%s'));
  fclose(fid);
catch
  % Remotely copied if you aren't there yet but you have WEBREAD
  tiffm=webread(file5);
end

% The limit coordinates in https://epsg.io/4326
coords=tiffm.geometry.coordinates;
% The corresponding reference system
coordr=tiffm.properties.epsg_code;
% All other properties including a bigger bounding box
props=tiffm.properties;
  
% Longitudes and latitudes clockwise from NW with extra point to close box
lons=coords(:,:,1);
lats=coords(:,:,2);

% Pixel resolution in m
sp=props.pixel_resolution;


%%%%%%%%%% DATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create main TIFF object with the data we really want
warning off MATLAB:imagesci:tiffmexutils:libtiffWarning 
warning off        imageio:tiffmexutils:libtiffWarning
tiffo=Tiff(file4,'r');
warning on MATLAB:imagesci:tiffmexutils:libtiffWarning 
warning on        imageio:tiffmexutils:libtiffWarning

% Again verify and show ways to address these properties
diferm(props.columns-getTag(tiffo,'ImageWidth'))
diferm(props.rows   -getTag(tiffo,'ImageLength'))

% Read it one way... note that IMREAD(file4) would do this too, but
% it wouldn't of course give you any of the checkable metadata
alldata=read(tiffo);
% Five-dimensional
diferm(size(alldata)-[props.rows props.columns 5])

% Read it another way...
if nargout>3
  [rgbdata,alfadat]=readRGBAImage(tiffo);
  % Three-dimensional plus an extra one
  diferm(size(rgbdata)-[props.rows props.columns 3])
  diferm(size(alfadat)-[props.rows props.columns  ])
else
  [rgbdata,alfadat]=deal(NaN);
end

% Close the TIFF for good measure
close(tiffo)


%%%%%%%%%%%%% OPTIONAL OUTPUT %%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Summaries the useful properties, see the help above
nprops.xs=props.origin_x;
nprops.ys=props.origin_y;
nprops.sp=sp;
nprops.lo=lons(1:4);
nprops.la=lats(1:4);
nprops.nc=props.columns;
nprops.nr=props.rows;

% Reorder if you like, but then reorder the help above also
varns={alldata,nprops,props,rgbdata,alfadat};
varargout=varns(1:nargout);


%%%%%%%%%% EXCESSIVE METADATA CHECKING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if xver>0
  % Convert the limit coordinates to UTM using a hack function which
  % gets N and S mixed up, sometimes... but the point is that it's unique
  warning off MATLAB:nargchk:deprecated
  [xs,ys,zs]=deg2utm(lats,lons);
  warning on MATLAB:nargchk:deprecated
  % Need to round these
  xs=round(xs); ys=round(ys);
  
  % If I get this right, this should hold mutely
  diferm(props.origin_x-xs(1))
  diferm(props.origin_y-ys(1))
  % This is the most useful grid information for later understanding
  diferm(props.columns-length(xs(1)+sp/2:+sp:xs(2)))
  diferm(props.rows   -length(ys(1)-sp/2:-sp:ys(3)))
  % Two alternatives to understand the pixel center grid, knowing
  % that the colon opeator won't necessarily hit the end boundary...
  diferm(linspace(xs(1)+sp/2,xs(2)-sp/2,props.columns)-[xs(1)+sp/2:+sp:xs(2)])
  diferm(linspace(ys(1)-sp/2,ys(3)+sp/2,props.rows)   -[ys(1)-sp/2:-sp:ys(3)])
  % Need to have a unique UTM zone
  diferm(sum(zs,1)/length(zs)-zs(1,:))

  % Sidedoor access to some of the auxiliary data; the "data" in the
  % geotiff are zero but the metadata are useful. Needs mapping toolbox.
  if license('test', 'map_toolbox')
    % Pixel CENTERS are [xutm yutm] = [row col 1]*refmat
    [~,refmat,bbox]=geotiffread(file2);
    
    % The XML file has the same information but we won't bother with
    % it now since it's a thicket of attributes and children
    refxml=xml2struct(file3);

    % If I get this right, this should hold mutely
    diferm(props.origin_x        -bbox(1))
    diferm(props.origin_y        -bbox(4))
    diferm(props.pixel_resolution-refmat(2))

    if xver==2
      % Clears the current figure; does not start a new one
      clf
      % If I get this all right, this should plot nicely 
      plot(bbox([1 1 2 2 1],1),bbox([1 2 2 1 1],2),'b'); hold on
    end
  end

  if xver==2
    % If I get this all right, this should plot nicely 
    letterit(xs,ys); hold on
    plot(xs,ys,'k+');
    hold off
  end
end

%%%%%%%%%%%%% SOME PLOTTING ROUTINES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function letterit(lons,lats)
  
for in=1:length(lons)
  plot(lons(in),lats(in),'.') 
  hold on
  text(lons(in),lats(in),num2str(in)) 
end
hold off
