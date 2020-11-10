function varargout=CyprusSRTM
% [Z,C11,CMN,mima,colmap,colrange]=CyprusSRTM
%
% Cyprus SRTM topography
%
% OUTPUT
%
% Z          A tiled version of the topography (optional)
% C11        lon,lat coordinates of the (1,1) element
% CMN        lon,lat coordinates of the (M,N) element
% mima       Minimum/maximum data values      
% colmap     Color map
% colrange   Color range
%
% EXAMPLE:
%
% [Z,C11,CMN,mima,colmap,colrange]=CyprusSRTM;
% save CyprusSRTM3 C11 CMN Z colmap colrange mima
% load CyprusSRTM3
% imagefnan(C11,CMN,Z,colmap,colrange);
%
% SEE ALSO:
%
% CyprusSRTM
%
% Last modified by fjsimons-at-alum.mit.edu, 11/10/2020

% Where did I get this stuff ?
url1='http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/North_America/';
url2='http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/Eurasia/';
url3='http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/Africa/';

% Where do I keep this stuff? You modify this:
diro='/u/fjsimons/IFILES/TOPOGRAPHY/CYPRUS/SRTM3';

% You modify this also, it sets the viewable axes later
zaxis=[32.2 34.7 34.5 35.75];
% You change this also, it sets the range of values being colored
colrange=[0 2000];

% Read the files along the rows across the columns, sequentially from
% the northernmost, east to west, to the southernmost, east to west; the
% variable tiling tells you how many rows and columns
tiling=[2 3];
files={'N35E032','N35E033','N35E034',...
       'N34E032','N34E033','N34E034'};
% Resolution in decimal degrees, this you get from the data but is standard
res=3/60/60;
dsize=1201;

try
  [colmap,dax,ziro]=sergeicol;
  colmap=colmap(ziro+1:end,:);
catch
  colmap=jet;
end

% Ready to combine them all
Zall=nan(dsize*tiling(1)-[tiling(1)-1],dsize*tiling(2)-[tiling(2)-1]);

clf
% Initialize
mima=[0 0];
C11=[inf -inf];
CMN=[-inf,inf];
for index=1:length(files)
  % Open file for reading, note that you need big-endian
  fatmpt=fullfile(diro,sprintf('%s.hgt',files{index}));
  disp(sprintf('Attempting to read the file %s',fatmpt))
  fid=fopen(fatmpt,'r','b');
  try
    % Read the binary identified by the file id
    Z=fread(fid,'int16');
    % Close the file
    fclose(fid);
    % Reshape to a square and turn around a bit
    Z=[reshape(Z,sqrt(length(Z)),[])]';
    % Replace the "voids" values with not-a-numbers
    Z(Z==-32768)=NaN;
  catch
    Z=nan(dsize,dsize);
  end
  % Tile these things together with the overlap
  ro=ceil(index/tiling(2));
  co=mod(index-1,tiling(2))+1;
  Zall(1+[ro-1]*[dsize-1]:dsize+[ro-1]*[dsize-1],...
       1+[co-1]*[dsize-1]:dsize+[co-1]*[dsize-1])=Z;
  % Evolving sense of scale
  mima=minmax([minmax(Z(:)') mima]);
  % Physical length of the sides in degrees
  physl=(length(Z)-1)*res;
  % The filename coordinates refer to the SW corner, apparently
  lat=str2num(files{index}(2:3))*(1-2*[files{index}(1)=='S']);
  lon=str2num(files{index}(5:7))*(1-2*[files{index}(4)=='W']);
  % Coordinates of the NW and SE corner of the map
  c11=[lon lat+physl];
  cmn=[lon+physl lat];
  % Evolving sense of dimension
  C11=[min(C11(1),c11(1)) max(C11(2),c11(2))];
  CMN=[max(CMN(1),cmn(1)) min(CMN(2),cmn(2))];
  % Now plot it if you can
  try
    h(index)=imagefnan(c11,cmn,Z,colmap,colrange);
    hold on
  end
end

% Clean up if you can
if exist('h')==1
  hold off
  axis(zaxis)
  longticks(gca,2)
  deggies(gca)
  fig2print(gcf,'portrait')
  % Add a custom color bar
  [cb,xcb]=addcb('hor',colrange,colrange,colmap);
  longticks(cb,2)
  set(xcb,'string','topography (m) above WGS84/EGM96 geoid')
  movev(cb,-0.05)
  figdisp
end
  
% Output if so desired
varns={Zall,C11,CMN,mima,colmap,colrange};
varargout=varns(1:nargout);

