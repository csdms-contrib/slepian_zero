function rapideym(diro)
% RAPIDEYM(diro)
%
% For a data directory containing multiple *_*_*_RapidEye-* directories
% with one *_Analytic_*.tif each, builds and saves an organized *.mat structure.
%
% INPUT:
%
% diro     Data directory [default: $ITALY/RAPIDEYE/enotre]
%
% NOTE:
%
% After download, I used $UFILES/directorize to name everything
% YYYYMMDD_HHMMSS_GGGGGGG_RapidEye-N where GGGGGGGG is grid cell and N
% the satellite id and YYYYMMDD_HHMMSS the date acquired
%
% Last modified by Last modified by fjsimons-at-alum.mit.edu, 09/24/2019

% Default
defval('diro',fullfile(getenv('ITALY'),'RAPIDEYE','enotre'))
defval('clip',[])
% Initialize
defval('tox',[])

% Make the save file
fname=fullfile(diro,sprintf('ri_%s.mat',suf(diro,'/')));

% Get contents of this directory, both short and long forms
dirp=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),0);
dirf=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),1);

% Begin the saved file - default will be 'enotre'
sname=sprintf('%s',suf(diro,'/'));
% See below at 'orchard' for old syntax instead of the subfunction
spitout(sname,'tox',tox); clear tox
% Save the variable named sname into the file named fname to initialize
savit(sname)

% Get the images
for index=1:length(dirp)
  % Append acquisition time YYYYMMDDHHMMSS to sname to make vname
  acquitime=dirp{index}([1:8 10:15]);
  vname=sprintf('%s_%s',sname,acquitime);
  % Update the table of contents
  tox(index,:)=sprintf('%s_%s',sname,acquitime);

  % Need to still get in there to recover the root filename
  froot=ls2cell(fullfile(dirf{index},'*_Analytic_*.tif'));
  % Clipped or not - pass on to RAPIDEYE Mosaiced or not?
  if ~isempty(strfind(froot{1},'_clip')); clip='_clip'; end
  % There should be only one at this point
  froot=froot{1}(1:strfind(froot{1},'_Analytic_')-1);
  % Now read the image, don't bother with setting xver=2 after a while
  [alldata,nprops,props,rgbdata,alfadat]=rapideye(froot,dirp{index},diro,1,[],clip);
  
  % The precision of these variables remains what they were
  spitout(vname,'alldata',alldata)
  spitout(vname,'props',props)
  spitout(vname,'nprops',nprops)
  
  % Add to the saved file
  savito(vname)
end

% Add table of contents
spitout(sname,'tox',tox)

% Now add the topography and rivers for the same region
% Again don't bother with setting xver=2 after a while
[TDF,~,SX,SY]=tinitaly(nprops,[],[],1,alldata);

% Complete the data cube
spitout(sname,'topodata',TDF)
spitout(sname,'riverx',SX)
spitout(sname,'rivery',SY)

% Read the orchard coordinates
[xe,ye,ze]=kmz2utm(sprintf('oc_%s',sname));

% I used to have, slightly more opaquely perhaps
% eval(sprintf('%s.orchardx=xe;',sname)), 
% eval(sprintf('%s.orchardx=xe;',sname)), and so on
spitout(sname,'orchardx',xe)
spitout(sname,'orchardy',ye)
ze=unique(ze);
spitout(sname,'orchardz',ze)

% Finalize table of contents
fn=str2mat(eval(sprintf('fieldnames(%s)',sname)));
fn=[repmat([sname '.'],size(fn,1),1) fn repmat(' ',size(fn,1),size(tox,2)-size(fn,2)-length(sname)-1)];
tox=[[sname repmat(' ',1,size(tox,2)-length(sname))] ; fn ; tox];
spitout(sname,'tox',tox)

% Add that information to the saved file
savito(sname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a subfunction for the expanded variable assignment
function spitout(sname,vname,var)
% This is marginally clearer but last input can't be an operation
evalin('caller',sprintf('%s.%s=%s;',sname,vname,inputname(3)))

% Make a subfunction for the save commands if fname exists in caller
function savit(shame)
evalin('caller',sprintf('save(fname,''%s'')',shame))
function savito(shame)
evalin('caller',sprintf('save(fname,''%s'',''-append'')',shame))
