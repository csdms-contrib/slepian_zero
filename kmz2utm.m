function varargout=kmz2utm(fname)
% [xe,ye,ze]=KMZ2UTM(fname)
%
% Reads a KMZ file and returns a structure with the variables in UTM
% format. Intermediary file created is a KML (deleted) and a TXT (kept)
% and, ultimately, a MAT (also kept).
%
% INPUT:
%
% fname          A filename with (so far, a single) trace. No extension
%
% OUTPUT:
%
% [xe,ye,ze]     UTM coordinates of the (so far, single) trace
%
% EXAMPLE:
%
% clear all; cd(fullfile(getenv('ITALY'),'RAPIDEYE'))
%
%% FROM A SATELLITE IMAGE IN A DIRECTORIZED STRUCTURE:
%
% figure(1); clf
% [alldata,nprops]=rapideye('3357121_2019-03-04_RE1_3A','20190304_094134_3357121_RapidEye-1','enotre',[],[],'_clip');
% imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],rapideya(alldata)); hold on
% [xe,ye,ze]=kmz2utm('enotre/SouthEnotreUrbanMesoraca'); p(1)=plot(xe,ye,'y','LineWidth',1); hold off
%
%% FROM A PRESAVED SATELLITE IMAGE STACK:
% 
% figure(2); clf
% load('enotre/ri_enotre.mat','enotre_20190304094134')
% imagesc(enotre_20190304094134.nprops.xx,enotre_20190304094134.nprops.yy,rapideya(enotre_20190304094134.alldata)); hold on
% [xe,ye,ze]=kmz2utm('enotre/SouthEnotreUrbanMesoraca'); p(1)=plot(xe,ye,'y','LineWidth',1); hold off
%
% Last modified by fjsimons-at-alum.mit.edu, 10/09/2019

% You need to be local for this
if exist(sprintf('%s.mat',pref(fname)))~=2
  if exist(sprintf('%s.txt',pref(fname)))~=2
     % Transform the file in question with UNZIP and KML2GMT (which you need!)
     system(sprintf('unzip %s.kmz',fname));
     % This to get rid of possible future timestamps
     system(sprintf('touch %s','doc.kml'));
     system(sprintf('kml2gmt  %s | awk ''NR>3 {print}'' >! %s.txt','doc.kml',pref(fname)));
     system(sprintf('rm -rf %s','doc.kml'));
  end
  % Load and convert to UTM
  data=load(sprintf('%s.txt',pref(fname)));
  warning off MATLAB:nargchk:deprecated
  [xe,ye,ze]=deg2utm(data(:,2),data(:,1));
  warning on MATLAB:nargchk:deprecated
  % Save to a MAT file
  save(sprintf('%s.mat',pref(fname)),'xe','ye','ze');
else
  % Load the mat file and return the output variables
  load(sprintf('%s.mat',pref(fname)))
end

% Only do output if you want it
varns={xe,ye,ze};
varargout=varns(1:nargout);
