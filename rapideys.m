function rapideys(diro,xver)
% RAPIDEYS(diro,xver)
%
% For a data directory containing multiple SINGLE-DATE satellite
% *_*_*_RapidEye-* directories with one *_Analytic_*.tif each, loads
% them using RAPIDEYE, builds and saves an organized *.mat structure.
%
% This in contrast to RAPIDEYM, which deals with duplicate dates that
% require mosaicking using MOSAIC. Run by, e.g., REMOTEOLIVE.
%
% INPUT:
%
% diro     Data directory [default: $ITALY/RAPIDEYE/enotre]
%          with entries like:
%                20170805_100927_3357121_RapidEye-4
%                20170826_101723_3357121_RapidEye-1
%                20170923_100705_3357121_RapidEye-1
% xver     2 halts for explicit verification
% 
% NOTE:
%
% After download, I used $UFILES/directorize to name everything
% YYYYMMDD_HHMMSS_GGGGGGG_RapidEye-N where GGGGGGGG is grid cell and N
% the satellite id and YYYYMMDD_HHMMSS the date acquired
%
% SEE ALSO:
%
% RAPIDEYM, RAPIDEYG, RAPIDEYE, REMOTEOLIVE
%
% Last modified by Last modified by fjsimons-at-alum.mit.edu, 11/02/2022

% Default
defval('diro',fullfile(getenv('ITALY'),'RAPIDEYE','enotre'))
defval('clip',[])
defval('tox',[])

% Make the save file
if isempty(suf(diro,'/'))
  fname=fullfile(diro,sprintf('ri_%s.mat',diro));
else
  fname=fullfile(diro,sprintf('ri_%s.mat',suf(diro,'/')));
end

% Get contents of this directory, both short and long forms
try 
  % If it's definitely RAPIDEYE
  dirp=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),0);
  dirf=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),1);
catch
  % If it's some other satellite system but still from PLANET
  dirp=ls2cell(fullfile(diro,'*_*_*'),0);
  dirf=ls2cell(fullfile(diro,'*_*_*'),1);
end

% Begin the saved file - default will be what's last in the path 
sname=sprintf('%s',suf(diro,'/'));
if isempty(sname)
  sname=diro;
end

% See below at 'orchard' for old syntax instead of the subfunction
spitout(sname,'tox',tox); clear tox

% AT THIS POINT YOU ARE STARTING A NEW FILE!! 
% Save the variable named sname into the file named fname to initializes
if xver~=2
  % Ask for input
  disp('File will be overwritten. Type dbcont to continue')
  keyboard
  % Don't begin the overwrite in verification mode!
  savit(sname)
end

% Main loop to get the images, one at a time
for index=1:length(dirp)
  % Need to still get in there to recover the root filename
  froot=ls2cell(fullfile(dirf{index},'*_Analytic*.tif'));
  % Clipped or not - pass on to RAPIDEYE
  if ~isempty(strfind(froot{1},'_clip')); clip='_clip'; end
  % There should be only one at this point
  froot=froot{1}(1:strfind(froot{1},'_Analytic')-1);

  % Now read the image, don't bother with setting xver=2 after a while
  [alldata,nprops,props,rgbdata,alfadat]=rapideye(froot,dirp{index},diro,1,[],clip);

  % Rimming and trimming
  [alldata,nprops]=trimimage(alldata,nprops,2);

  % Append acquisition time YYYYMMDDHHMMSS to sname to make vname
  acquitime=dirp{index}([1:8 10:15]);
  vname=sprintf('%s_%s',sname,acquitime);
  % Update the table of contents
  tox(index,:)=sprintf('%s_%s',sname,acquitime);

  % The precision of these variables remains what they were
  spitout(vname,'alldata',alldata)
  spitout(vname,'props',props)
  spitout(vname,'nprops',nprops)

  % Add to the saved file
  savito(vname)
end

% Should I save the LARGEST EVER nprops for the TOPODATA?
% Now I work with the LAST EVER nprops from the last RAPIDEYE

% Add table of contents
spitout(sname,'tox',tox)

% Now add the topography and rivers for the same region
% Again don't bother with setting xver=2 after a while
[TDF,~,SX,SY]=tinitaly(nprops,[],[],1,alldata);

% Get the whole grid out, always verify equal spacing
[~,~,~,xeye,yeye]=rapideyg(nprops,1);

% Complete the data cube
spitout(sname,'topodata',TDF)
% The following is as I like it for IMAGEFNAN
C11=nprops.C11; 
spitout(sname,'C11',C11)
CMN=nprops.CMN; 
spitout(sname,'CMN',CMN)
% The following is more intuitive with IMAGESC, save as ROWS
xx=xeye([1 end]); xx=xx(:)';
yy=yeye([1 end]); yy=yy(:)';
spitout(sname,'xx',xx)
spitout(sname,'yy',yy)
spitout(sname,'xeye',xeye)
spitout(sname,'yeye',yeye)
% Make a snug axis
% I first used this
snug=[nprops.xp(1) nprops.xp(2) nprops.yp(3) nprops.yp(1)];
% But those are properties I didn't adjust after trimming, so...

spitout(sname,'snug',snug)
spitout(sname,'riverx',SX)
spitout(sname,'rivery',SY)

% We should put the essential props here also

try
  % Read the orchard coordinates
  [xe,ye,ze]=kmz2utm(fullfile(diro,sprintf('oc_%s.kmz',sname)));
  % Make a snugger axis
  inflet=30;
  snugger=[[min(xe) max(xe)]+[-1 1]*range(xe)*inflet/100 [min(ye) max(ye)]...
           +[-1 1]*range(ye)*inflet/100];
catch
  [xe,ye,ze]=deal(NaN);
  snugger=nan(1,4);
end
spitout(sname,'snugger',snugger)
% I used to have, slightly more opaquely perhaps
% eval(sprintf('%s.orchardx=xe;',sname)), 
% eval(sprintf('%s.orchardx=xe;',sname)), and so on
spitout(sname,'orchardx',xe)
spitout(sname,'orchardy',ye)
ze=unique(ze,'rows');
spitout(sname,'orchardz',ze)

% Should convert to the same UTM zone as we had in the RAPIDEYE files if
% they weren't

% Finalize table of contents
fn=str2mat(eval(sprintf('fieldnames(%s)',sname)));
fn=[repmat([sname '.'],...
           size(fn,1),1) fn repmat(' ',size(fn,1),size(tox,2)-size(fn,2)-length(sname)-1)];
tox=[[sname repmat(' ',1,size(tox,2)-length(sname))] ; fn ; tox];
% Get rid of any newlines
spitout(sname,'tox',detox(tox))

% Add all that information also separately to the saved file
savito('tox')
savito(sname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a subfunction for the expanded variable assignment
function spitout(sname,vname,var)
% This is marginally clearer but last input can't be an operation
evalin('caller',sprintf('%s.%s=%s;',sname,vname,inputname(3)))

% Make a subfunction for the save commands if fname exists in caller
function savit(shame)
evalin('caller',sprintf('save(fname,''%s'')',shame))
% Make a subfunction for the save commands if fname exists in caller - append
function savito(shame)
evalin('caller',sprintf('save(fname,''%s'',''-append'')',shame))
