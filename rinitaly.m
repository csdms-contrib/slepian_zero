function rinitaly(froot,dirp,diro,xver)
% RINITALY(froot,dirp,diro,xver)
%
%
% INPUT:
%
% froot      Filename root [e.g. 'ITA_water_lines_dcw']
% dirp       Directory [e.g. 'DIVA-GIS']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
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



keyboard
