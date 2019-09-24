function [xe,ye,ze]=kmz2utm(fname)
% [xe,ye,ze]=KMZ2UTM(fname)
%
% Reads a KMZ file and returns a structure with the variables in UTM
% format. Intermediary file created is a KML (deleted) and a TXT (kept)
% and, ultimately, a MAT (also kept).
%
% INPUT:
%
% fname          A KMZ filename with (so far, a single) trace
%
% OUTPUT:
%
% [xe,ye,ze]     UTM coordinates of the (so far, single) trace
%
% Last modified by fjsimons-at-alum.mit.edu, 09/24/2019

% You need to be local for this
if exist(sprintf('%s.mat',pref(fname)))~=2
  if exist(sprintf('%s.txt',pref(fname)))~=2
     % Transform the file in question with UNZIP and KML2GMT (which you need!)
     system(sprintf('unzip %s',fname));
     % This to get rid of possible future timestamps
     system(sprintf('touch %s','doc.kml'));
     system(sprintf('kml2gmt  %s | awk ''NR>3 {print}'' >! %s.txt','doc.kml',pref(fname)));
     system(sprintf('rm -rf %s','doc.kml'));
  else
    % Load and convert to UTM
    data=load(sprintf('%s.txt',pref(fname)));
    warning off MATLAB:nargchk:deprecated
    [xe,ye,ze]=deg2utm(data(:,1),data(:,2));
    warning on MATLAB:nargchk:deprecated
  end
  % Save to a MAT file
  save(sprintf('%s.mat',pref(fname)),'xe','ye','ze');
else
  % Load the mat file and return the output variables
  load(sprintf('%s.mat',pref(fname)))
end




