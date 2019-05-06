function varargout=rinitaly(froot,dirp,diro,xver)
% [SX,SY,AXL,S]=RINITALY(froot,dirp,diro,xver)
%
%
% INPUT:
%
% froot      Filename root [e.g. 'ITA_water_lines_dcw']
% dirp       Directory [e.g. 'DIVA-GIS']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
% 
% SX, SY     All the X and Y coordinates of all the rivers, together
% AXL        An appropriate bounding box
% S          The proper structure, with names, etc.
%
% EXAMPLE:
%
% You will be in the directory one up from 'dirp' and you do 
% rinitaly([],[],pwd)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/06/2019

% Root of the filename the several files inside the directory
defval('froot','ITA_water_lines_dcw')
% Bottom-level directory name
defval('dirp','DIVA-GIS')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',1)

% The file name root including the path name
fname=fullfile(diro,dirp,froot);

% Read the shape files, one way or another
if exist(sprintf('%s.mat',fname))==2
  % Now you no longer need the Mapping Toolbox
  load(fname,'S')
else
  % For this you do need the Mapping Toolbox
  S=shaperead(fname);
  save(fname,'S')
end

% Turn out all of them at the same time
SX=[S(:).X];
SY=[S(:).Y];

% What's fit to show
AXL=[minmax(SX) minmax(SY)];

% Make a plot if you so desire
if xver==2
  plot(SX,SY,'b')
end

% Optional output
varns={SX,SY,AXL,S};
ppvarargout=varns(1:nargout);

