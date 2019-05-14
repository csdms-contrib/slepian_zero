function varargout=rinitaly(nprops,froot,dirp,diro,buf,dlev,xver)
% [SX,SY,S]=RINITALY(nprops,froot,dirp,diro,buf,dlev,xver)
%
% Returns Italian river coordinates as pertaining to a specific panel only,
% and in the same UTM conventions, as a data structure from RAPIDEYE
%
% INPUT:
%
% nprops     A minimal properties structure from RAPIDEYE
% froot      Filename root [e.g. 'ITA_water_lines_dcw']
% dirp       Directory [e.g. 'DIVA-GIS']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY']
% buf        A buffer in degrees to aid the search for rivers within polygon
% dlev       A PENLIFT parameter to disentangle rivers after they've been joined
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
% 
% SX, SY     All the X and Y coordinates of all the rivers, together
% S          The proper structure, with names, etc.
%
% EXAMPLE:
%
% [alldata,nprops]=rapideye;
% imagefnan(nprops.C11,nprops.CMN,double(alldata(:,:,1)),[],[1500 15000])
% [SX,SY]=rinitaly(nprops); 
% hold on; pr=plot(SX,SY,'k'); hold off; 
% axis([nprops.C11(1) nprops.CMN(1) nprops.CMN(2) nprops.C11(2)])
%
% Last modified by fjsimons-at-alum.mit.edu, 05/13/2019

% Root of the filename the several files inside the directory
defval('froot','ITA_water_lines_dcw')
% Bottom-level directory name
defval('dirp','DIVA-GIS')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',1)
% You could rewrite the joining instead of unjoining
defval('dlev',2)
% A small buffer won't stop the rivers from flowing near the box edge
defval('buf',0.025)

% The file name root including the path name
fname=fullfile(diro,dirp,froot);
if xver>0
  % Some checks and balances
  disp(sprintf('Looking for %s I am finding\n',fullfile(diro,dirp,froot)))
  ls(fullfile(diro,dirp))
end

% Read the shape files, one way or another
if exist(sprintf('%s.mat',fname))==2
  % Now you no longer need the Mapping Toolbox
  load(fname,'S')
else
  % For this you do need the Mapping Toolbox
  S=shaperead(fname);
  save(fname,'S')
end

% Turn out all of them at the same time... could insert NaNs
SX=[S(:).X];
SY=[S(:).Y];

% How about we use the polygon to subselect the rivers within it
if buf>0
  % Let us by liberal in extending the box a bit
  [lab,lob]=bufferm(nprops.la,nprops.lo,buf);
  % But you need to get rid of the interior domain and the extra NaN
  lo=lob(length(nprops.lo)+2:end);
  la=lab(length(nprops.la)+2:end);
else
  % No buffer, that's just the original
  lo=nprops.lo; la=nprops.la;
end
in=inpolygon(SX,SY,lo,la);
SX=SX(in);
SY=SY(in);

% One has to hope it comes up with the same zone as what we thought
warning off MATLAB:nargchk:deprecated
[xSX,ySY,ZS]=deg2utm(SY,SX);
warning on MATLAB:nargchk:deprecated

% Need to have a unique UTM zone
diferm(sum(ZS,1)/length(ZS)-ZS(1,:))
% What would we want it to be in UTM, regardless of what RAPIDEYE says?
disp(sprintf('According to DEG2UTM, this is %s',ZS(1,:)))
if license('test', 'map_toolbox')
  % Another way to guess the UTM zone
  upg=utmzone(nanmean(SY),nanmean(SX));
  disp(sprintf('According to UTMZONE, this is %s',upg))
end
    
% Insert NaNs for beauty
[SX,SY]=penlift(xSX,ySY,dlev);

% Make a plot if you so desire
if xver==2
  plot(SX,SY,'b')
end

% Optional output
varns={SX,SY,S};
varargout=varns(1:nargout);
