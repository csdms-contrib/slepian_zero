function rapideym(diro)
% RAPIDEYM(diro)
%
% For a data directory containing multiple *_*_*_RapidEye-* directories
% with ONE *_Analytic_*.tif each, builds and saves an organized *.mat structure.
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
% Last modified by Last modified by fjsimons-at-alum.mit.edu, 10/02/2019

% Default
defval('diro',fullfile(getenv('ITALY'),'RAPIDEYE','enotre'))
defval('clip',[])
% Initialize
defval('tox',[])

% Make the save file
if isempty(suf(diro,'/'))
  fname=fullfile(diro,sprintf('ri_%s.mat',diro));
else
  fname=fullfile(diro,sprintf('ri_%s.mat',suf(diro,'/')));
end

% Get contents of this directory, both short and long forms
dirp=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),0);
dirf=ls2cell(fullfile(diro,'*_*_*_RapidEye-*'),1);

% Begin the saved file - default will be 'enotre'
sname=sprintf('%s',suf(diro,'/'));
if isempty(sname)
  sname=diro;
end

% See below at 'orchard' for old syntax instead of the subfunction
spitout(sname,'tox',tox); clear tox

% AT THIS POINT YOU ARE STARTING A NEW FILE!! 
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

  % BEGIN REMOVE RIMMING

  % Find the grid
  [XE,YE]=rapideyg(nprops);

  % This is where you trim the data that are ALL zeros
  % How about we remove rinds from here - zero rows/columns, that'll do it
  emptycols=sum(sum(alldata,3)==0,1)==size(alldata,1);
  emptyrows=sum(sum(alldata,3)==0,2)==size(alldata,2);

  % Assuming that they are AT the edges (no interior removal; not sure if
  % when THAT would be caught down the line)
  if sum(emptycols) || sum(emptyrows)
    disp(sprintf('Empty-border trimming'))
    XE=XE(~emptyrows,~emptycols);
    YE=YE(~emptyrows,~emptycols);
    alldata=alldata(~emptyrows,~emptycols,:);
  end

  % This is where you trim the edges if they contain ANY zeros; 
  % The mask as we define it HAS data
  mask=sum(alldata,3)~=0;
  % BEGIN IMAGE TRIMMING
  if prod(size(mask))~=size(alldata(:,:,1))
    disp(sprintf('Any-border  trimming'))
    % Collect coordinates
    mark=reshape(1:prod(size(mask)),size(mask));
    % Now we find the (largest?) rectangle that fits inside the mask
    % MASK2RECT; go around the corner, see if it works
    mark=mark(:,  min(find(mask(1,:  ))):end);
    mask=mask(:,  min(find(mask(1,:  ))):end);
    mark=mark(    min(find(mask(:,end))):end,:);
    mask=mask(    min(find(mask(:,end))):end,:);
    mark=mark(  1:max(find(mask(:,1  ))),:);
    mask=mask(  1:max(find(mask(:,1  ))),:);
    mark=mark(:,1:max(find(mask(end,:))));
    mask=mask(:,1:max(find(mask(end,:))));
    % Maybe do this again if it still has NaNs? Maybe rotate the image??
    % All permutations? This works for enotre, but need to inspect
    trimdata=zeros(size(mask),class(alldata));
    for ondex=1:size(alldata,3)
      data=alldata(:,:,ondex);
      trimdata(:,:,ondex)=reshape(data(mark),size(mask));
    end
    XE=reshape(XE(mark),size(mask));
    YE=reshape(YE(mark),size(mask));
    alldata=trimdata;
    % Now adjust the metadata like in MOSAIC of course
    nprops.nr=size(alldata,1);
    nprops.nc=size(alldata,2);
    nprops.xs=XE(1)-nprops.sp/2;
    nprops.ys=YE(1)+nprops.sp/2;
    nprops.C11=[XE(1)   YE(1)];
    nprops.CMN=[XE(end) YE(end)];
    nprops.xx=XE([1 end]); 
    nprops.yy=YE([1 end]);
  end
  % END IMAGE TRIMMING
  
  % The precision of these variables remains what they were
  spitout(vname,'alldata',alldata)
  spitout(vname,'props',props)
  spitout(vname,'nprops',nprops)
  
  % Add to the saved file
  savito(vname)
end

% Should I save the LARGEST EVER nprops for the TOPODATA

% Add table of contents
spitout(sname,'tox',tox)

% Now add the topography and rivers for the same region
% Again don't bother with setting xver=2 after a while
[TDF,~,SX,SY]=tinitaly(nprops,[],[],1,alldata);

% Get the whole grid out, always verify equal spacing
[~,~,~,xeye,yeye]=rapideyg(nprops,1);
% This is going to be a ROW vector
xeye=xeye(:)';
% This is going to be a COLUMN vector
yeye=yeye(:);

% Complete the data cube
spitout(sname,'topodata',TDF)
% The following is as I like it for IMAGEFNAN
C11=nprops.C11; 
spitout(sname,'C11',C11)
CMN=nprops.CMN; 
spitout(sname,'CMN',CMN)
% The following is more intuitive with IMAGESC
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

% Read the orchard coordinates
[xe,ye,ze]=kmz2utm(fullfile(diro,sprintf('oc_%s',sname)));

% Make a snugger axis
inflet=30;
snugger=[[min(xe) max(xe)]+[-1 1]*range(xe)*inflet/100 [min(ye) max(ye)]+[-1 1]*range(ye)*inflet/100];
spitout(sname,'snugger',snugger)

% Should convert to the same UTM zone as we had in the RAPIDEYE files

% I used to have, slightly more opaquely perhaps
% eval(sprintf('%s.orchardx=xe;',sname)), 
% eval(sprintf('%s.orchardx=xe;',sname)), and so on
spitout(sname,'orchardx',xe)
spitout(sname,'orchardy',ye)
ze=unique(ze,'rows');
spitout(sname,'orchardz',ze)

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
