function varargout=anatomy(fname,snumber)
% [t,d]=ANATOMY(fname,snumber)
%
% Anatomy of a proper and flexible function
%
% INPUT:
%
% fname       A MATLAB m-file name string
% snumber     Some number, e.g. pi
%
% OUTPUT:
%
% t           A timestamp as a DATETIME array
% d           A measure of file size
%
% SEE ALSO: MARK2MAT, DROP2MAT, BRINNO2MAT
% 
% EXAMPLE: 
%
% [a,b]=anatomy('demo1');
% [c,d]=anatomy(which('anatomy'),2)
%
% TESTED ON: MATLAB Version: 9.8.0.1451342 (R2020a) Update 5
% 
% Last modified by fjsimons-at-alum.mit.edu, 01/11/2022

% Do something interesting with the input
if isempty(strfind(fname,'demo'))
  % Like, find the creation time stamp of the first input
  [~,b]=system(sprintf('GetFileInfo %s',which(fname)));
  s=strfind(b,'created: ')+9;
  t=datetime(b(s:s+18),'InputFormat','MM/dd/uuuu HH:mm:ss');
  % And, find the file size, multiplied by the second input
  [~,b]=system(sprintf('ls -l %s | awk ''{print $5}''',which(fname)));
  d=str2num(b(1:length(b)-1))*snumber;
elseif strcmp(fname,'demo1')
  % Call your own example... do check out DEFVAL, RAND, etc
  [t,d]=anatomy(mfilename,1);
end

% Optional output
varns={t,d};
varargout=varns(1:nargout);
