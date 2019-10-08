function rapideys(diro,dupli,xver)
% RAPIDEYS(diro,dupli,xver)
%
% For a data directory containing multiple *_*_*_RapidEye-* directories
% with ONE *_Analytic_*.tif each, builds and saves an organized *.mat
% structure. This for the case where MULTIPLE directories pertain to the
% same date, which need to be mosaicked together using MOSAIC.
%
% INPUT:
%
% diro     Data directory [default: $ITALY/RAPIDEYE/ceraudo]
% duplic   Duplicity (how many tiles to consider in a mosaic)
% xver     2 halts for verification
%
% SEE ALSO:
%
% RAPIDEYM
%
% Last modified by fjsimons-at-alum.mit.edu, 10/07/2019

% Do a first loop to get unique days, then figure out multiplicity frmo
% another ls2cell then adjust the main loop

% Defaults
defval('diro',fullfile(getenv('ITALY'),'RAPIDEYE','ceraudo'))
defval('clip',[])
defval('xver',1)
% Initialize
defval('tox',[])
% Duplicity
defval('dupli',4)

% Make the save file
if isempty(suf(diro,'/'))
  fname=fullfile(diro,sprintf('ri_%s.mat',diro));
else
  fname=fullfile(diro,sprintf('ri_%s.mat',suf(diro,'/')));
end

% Get contents of this directory, both short and long forms
dirp=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),0);
dirf=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),1);

% Begin the saved file - default will be 'ceraudo'
sname=sprintf('%s',suf(diro,'/'));
if isempty(sname)
  sname=diro;
end

% See below at 'orchard' for old syntax instead of the subfunction
spitout(sname,'tox',tox); clear tox

% AT THIS POINT YOU ARE STARTING A NEW FILE!! 
% Save the variable named sname into the file named fname to initialize
if xver~=2
  % Ask for input
  disp('File will be overwritten. Type dbcont to continue')
  keyboard
  % Don't begin the overwrite in verification mode!
  savit(sname)
end

% Collect all the filenames and corresponding directories
for index=1:length(dirf)
  prot=pref(ls2cell(sprintf('%s/*Analytic_clip.tif',dirf{index})),'A');
  froot{index}=sprintf('%sA',[prot{:}]); 
end

% Here need the wherewithall to step through the dirf structure

if xver==2
  % Quick rundown of what's about to happen
  % Need parentheses and not curly braces
  more off
  for index=1:dupli:length(dirp)
    disp(sprintf(repmat('%s\n',1,dupli),dirf{index:index+dupli-1}))
    disp(' ')
  end
end

% Main loop
for index=1:dupli:length(dirp)
  % Feed it the right directories
  disp(reshape(cell2mat(dirp(index:index+dupli-1)),[],dupli)')
  % Get the images and MOSAIC them together, never request the topography
  [alldata,nprops,props]=mosaic(froot(index:index+dupli-1),...
                                dirf(index:index+dupli-1),[],xver);

  % You'll want to verify the picture
  if xver==2
    figure(4); clf
    % Two next lines are equivalent
    % imagesc(nprops.xx,nprops.yy,rapideya(alldata)); axis xy
    imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],rapideya(alldata)); axis xy
    j=axis;
    hold on
    try % If we have it
      [xe,ye,ze]=kmz2utm(fullfile(diro,sprintf('oc_%s.kmz',sname))); plot(xe,ye,'y','LineWidth',2)
    end
    hold off
    % To play with
    ah=get(2,'children');
    for ondex=1:length(ah)
      ah(ondex).XLim=j([1:2]);
      ah(ondex).YLim=j([3:4]);
    end
    keyboard
  end
    
  % Append acquisition day YYYYMMDD to sname to make vname
  acquiday=dirp{index}(1:8);
  vname=sprintf('%s_%s',sname,acquiday);
  % Update the table of contents... only every other one! So you will
  % have blank spaces in there
  tox(index,:)=sprintf('%s_%s',sname,acquiday);

  % The precision of these variables remains what they were
  spitout(vname,'alldata',alldata)
  spitout(vname,'props',props)
  spitout(vname,'nprops',nprops)

  % Add to the saved file
  savito(vname)
end

% Should I save the LARGEST EVER nprops for the TOPODATA?
% Now I work with the LAST EVER nprops from the last MOSAIC

% Add table of contents
spitout(sname,'tox',tox)

% Now add the topography and rivers for the same region
% Again don't bother with setting xver=2 after a while
% Don't bother with the rivers for now, they needed lon and lat
% Also, we'll just take the FIRST TDC like we did before (that was last then...)
%[TDF,~,SX,SY]=tinitaly(nprops,[],[],1,alldata);
TDF=tinitaly(nprops,[],[],1,alldata);
[SX,SY]=deal(NaN);

if xver==2
  figure(5); clf; 
  imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],TDC); axis xy
end

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
% snug=[nprops.xp(1) nprops.xp(2) nprops.yp(3) nprops.yp(1)];
% But those are properties I didn't adjust after trimming, so...
snug=nan;
spitout(sname,'snug',snug)
spitout(sname,'riverx',SX)
spitout(sname,'rivery',SY)

% We should put the essential props here also

try
  % Read the orchard coordinates
  [xe,ye,ze]=kmz2utm(fullfile(diro,sprintf('oc_%s.kmz',sname)));
  % Make a snugger axis
  inflet=30;
  snugger=[[min(xe) max(xe)]+[-1 1]*range(xe)*inflet/100 [min(ye) max(ye)]+[-1 1]*range(ye)*inflet/100];
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
fn=[repmat([sname '.'],size(fn,1),1) fn repmat(' ',size(fn,1),size(tox,2)-size(fn,2)-length(sname)-1)];
tox=[[sname repmat(' ',1,size(tox,2)-length(sname))] ; fn ; tox];
spitout(sname,'tox',tox)

% Add all that information to the saved file
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
