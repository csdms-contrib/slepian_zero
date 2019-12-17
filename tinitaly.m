function varargout=tinitaly(nprops,dirp,diro,xver,alldata)
% [TDF,F,SX,SY]=TINITALY(nprops,dirp,diro,xver,alldata)
%
% Matches a coordinate set from RAPIDEYE to a TINITALY data file
%
% INPUT:
%
% nprops     A minimal structure with properties from RAPIDEYE, OR:
%            {XE YE ZE} the way it would come out of RAPIDEYG
% dirp       Subdirectory [e.g. 'DATA'] of:
% diro       Main directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
%            3 Terminates by drawing some random profiles for checking
% alldata    A data matrix from RAPIDEYE, so that xver=2 can do some plotting
%
% OUTPUT:
%
% TDF        The topography data for the region corresponding to nprops
%            i.e. the interpolation of the corresponding TINITALY data!
% F          The interpolant used such that TDF=F(XE,YE), where [XE,YE]
%            is the RAPIDEYE grid recovered from RAPIDEYG
% SX,SY      Coordinates of rivers crossing the relevant tile
%
% EXAMPLE 1, for unclipped data, multiple images of the same "grid_cell"
%
% [alldata1,nprops1]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3',[],[],[],'_clip');
% [alldata2,nprops2]=rapideye('3357121_2018-11-09_RE1_3A','20181109_093150_3357121_RapidEye-1',[],[],[],'_clip');
% figure(1); clf; tinitaly(nprops1,[],[],[],alldata1)
% figure(2); clf; tinitaly(nprops2,[],[],[],alldata2)
% 
% EXAMPLE 2, for a rather different cell, also unclipped
%
% [alldata,nprops]=rapideye('3357911_2019-03-31_RE3_3A','20190331_094550_3357911_RapidEye-3');
% figure(2); clf; tinitaly(nprops,[],[],[],alldata)
%
% EXAMPLE 3, for a clipped cell that is part of a tile that we have in its entirety also
%
% [alldata,nprops]=rapideye('3357121_2018-09-11_RE3_3A','enotre/20180911_094536_3357121_RapidEye-3',[],1,[],'_clip');
% figure(2); clf; [TDF,F]=tinitaly(nprops,[],[],[],alldata);
%
% EXAMPLE 4, for a different clipped cell
%
% [alldata,nprops]=rapideye('3357121_2019-03-04_RE1_3A','enotre/20190304_094134_3357121_RapidEye-1',[],1,[],'_clip');
% figure(3); clf; [TDF,F]=tinitaly(nprops,[],[],[],alldata);
%
% EXAMPLE 5, for an input that isn't a struct but rather a cell
%
% load(fullfile(getenv('ITALY'),'METEOBLUE','mat','mb_pisa.mat'))
% warning off MATLAB:nargchk:deprecated
% [xe,ye,ZE]=deg2utm(mb_pisa.lat,mb_pisa.lon);
%  warning on MATLAB:nargchk:deprecated
% ZE=ZE(abs(ZE)~=32); kspan=20000; csize=10;
% XXE=xe-kspan+csize/2: csize:xe+kspan-csize/2;
% YYE=ye+kspan-csize/2:-csize:ye-kspan+csize/2;
% [XE,YE]=meshgrid(XXE,YYE);
% [TDF,F,SX,SY]=tinitaly({XE YE ZE},[],[],2);
%
% Last modified by fjsimons-at-alum.mit.edu, 12/16/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',2)

% No default data file, but provide one if you want it checked
defval('alldata',[])

if isstruct(nprops)
  %%%%%%%%%%%%%%% FIRST THE RAPIDEYE GRID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [XE,YE,ZE]=rapideyg(nprops,xver);
else
  % Let's say you get corner points and a resolution in a UTM grid and I
  % can make a new XE, YE, ZE instead.
  XE=nprops{1};
  YE=nprops{2};
  ZE=nprops{3};
  alldata=[];
end

%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only if you have the headers pre-prepared this will work, bypass box plots
[hdr,TV,~,TA,bx,by]=tinitalh(dirp,diro,xver*0);
% Get the UTM zone real quick, better match TINITALG identically, where it
% is also explicitly set to this same value, since we we know we need to
% override the Italian data which somehow claim to be 33S
ZTT='32N';

%%%%% FIND APPROPRIATE TOPODATA FILES TO MATCH RAPIDEYE %%%%%%%%%%%%%%%%%%%

% Convert all the box corners to the target coordinates, no notifications
[bxp,byp,a]=utm2utm(bx,by,ZTT,ZE,0);
% Check if theres is any change?

% Determine in which box the end points of the XE,YE fall
for index=1:length(hdr)
  inb(index)=any(inpolygon(XE([1 end end 1]),YE([1 1 end end]),bxp(index,:),byp(index,:)));
end

% That gives you the indices that match nprops
indices=find(inb);

%%%%%%%%%% VISUAL CHECK TILE MATCHING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of all the metadata in your directory
if xver==2
  % This shares portions with some xver stuff in TINITALH
  % Plot ALL/SOME the boxes of the header, they are supposedly all in zone 32
  % Compare to http://tinitaly.pi.ingv.it/immagini/Imm_TINITALY_DOWNLOAD_03.jpg
  clf
  ah=gca;
  pri=plot(XE([1 end end 1 1]),YE([1 1 end end 1]),'r-');
  % This is vital to enable the switch between "some" and "all" below
  [BX,BY]=deal(nan(max(length(indices),length(hdr)),2));
  hold on
  for index=indices %1:length(hdr)
    plot(bxp(index,:),byp(index,:)); hold on
    tt(index)=text(bxp(index,1)+[bxp(index,3)-bxp(index,1)]/2,...
	 byp(index,1)+[byp(index,2)-byp(index,1)]/2,...
	 sprintf('%i %s',index,...
		 pref(pref(hdr{index}),'_')));
    BX(index,:)=minmax(bxp(index,:));
    BY(index,:)=minmax(byp(index,:));
  end
  hold off
  BX=BX(~isnan(BX(:,1)),:);
  BY=BY(~isnan(BY(:,1)),:);

  axis image
  xel=[min(BX(:,1)) max(BX(:,2))];
  yel=[min(BY(:,1)) max(BY(:,2))];
  xlim(xel+[-1 1]*range(xel)/20)
  ylim(yel+[-1 1]*range(yel)/20)
  % Annotate
  shrink(ah,1.5,1.5)
  t(1)=title(sprintf('From the headers inside\n %s',...
		     fullfile(diro,dirp)));
  movev(t(1),range(ylim)/10)
  % Set the tile matches to bold
  set(tt(indices),'FontWeight','bold')
  % Print a figure
  figdisp([],[],[],2)
  pause(1)
end

%%%%%%%%%% TOPODATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If initializing saves time, here's how to do it. For our data, it didn't
clear XT YT TD
%[XT,YT,TD]=deal(cellnan([length(indices) 1],TA(2,indices),TA(1,indices)));
for index=1:length(indices)
  [XT{index},YT{index},ZT{index},TD{index}]=...
      tinitalg(hdr,TV,indices(index),dirp,diro,xver);
end

if length(indices)>1
  % We know to look for possibly rim rows or columns of tile overlap
  rim=10;
  % Figure out all the pairwise rimmed relationships
  tp=nchoosek(indices,2); tp=[tp nan(size(tp,1),1)];
  for index=1:size(tp,1)
    disp(sprintf('Testing tiles  %2.2i and %2.2i',tp(index,1),tp(index,2)))
    % We need to also map the required tile back to the index set with which
    % it was loaded...
    frst=find(indices==tp(index,1));
    scnd=find(indices==tp(index,2));
    % Feed row/column grid of the first with the second entry in every pair
    tp(index,3)=puzzle(XT{frst}(1,:),YT{frst}(:,1),...
 		       XT{scnd}(1,:),YT{scnd}(:,1),rim);
  end

  % I THINK THAT SIMPLY COMBINING THESE LOOPS WILL PREVENT OVERTRIMMING IN
  % CASE THERE IS MORE THAN ONE PAIR MATCH. FOR TINITALY/RAPIDEYE, SO FAR,
  % WE HAVE ONLY ENCOUNTERED pairs IN THE TOPOGRAPHY MATCH. MOSAICING
  % RAPIDEYE IS THE FIRST INSTANCE OF QUARTETS... 

  % The match is up to a "slide", we just determine where the overlapping
  % side is. We need to find the edge where ALL the entries are duplicates
  % with any of the other edges, and then trim those, removing
  % redundancies. So...  sometimes the tiles don't align in the other
  % dimension than the one in which the match was determined. If the left
  % edges are aligned and the tiles are stacked on top of one another, they
  % will match according to RIMCHECK. But if the left edges don't align and
  % the tiles are still on top of each other, then RIMCHECK would fail. We
  % need to know to issue such warnings in that case, even though we would
  % still trim the results, as a third tile will pick up the remainder! So
  % here we determine the schedule of testing.
  for index=1:size(tp,1)
    disp(sprintf('%s trimming tiles %2.2i and %2.2i',upper(mfilename),...
                 tp(index,1),tp(index,2)))
    % In the end we never check the data match... but we could, and if we
    % did and we knew how to read the warnings when they shouldn't match, or
    % if we worked out how to just check the partial match, we'd be
    % fine. For now, let's not overdo it in the testing since we know very
    % well how it works, and that it works. No need to go into further
    % granularity but here is a suitable testing checklist.
    switch tp(index,3)
     case {8,4}
      % The match is in the horizontal so the Vertical won't need to match
      hm=1; vm=0; dm=0;
     case {1,2}
      % The match is in the vertical so the Horizontal won't need to match
      hm=0; vm=1; dm=0;
     otherwise
      % The match is horizontal and vertical but the Data needn't match
      hm=1; vm=1; dm=0;
    end

    % Again... don't forget the mapping
    frst=find(indices==tp(index,1));
    scnd=find(indices==tp(index,2));
 
    % Check and trim and reassign... 
    [XT{frst},XT{scnd}]=...
        rimcheck(XT{frst},XT{scnd},rim,tp(index,3),hm);
    [YT{frst},YT{scnd}]=...
        rimcheck(YT{frst},YT{scnd},rim,tp(index,3),vm);
    [TD{frst},TD{scnd}]=...
        rimcheck(TD{frst},TD{scnd},rim,tp(index,3),dm);
  end
end

%%%%%%%%%% VISUAL CHECK TOPODATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the topodata you have just identified
if xver>1
  % disp('Hit ENTER to continue'); pause
  % disp('Type DBCONT to continue'); keyboard
  clf
  ah(1)=subplot(221);
  % Plot the TOPODATA
  caxx=[-2154.5 1601.4];

  for index=1:length(indices)
    axes(ah(1))
    plotit(XT{index},YT{index},TD{index},caxx,2)
    hold on
    drawnow
    axis image
  end
  hold off
  % And attractive title, substituting the underscore with a dash
  % Only one title here, but clearly could be more tiles 
  t=title(sprintf(repmat('%i ',1,length(indices)),indices));
  set(t,'FontWeight','normal')
end

% Convert TOPODATA to the RAPIDEYE coordinate system
for index=1:length(indices)
  % Turn off the notifications
  [XP{index},YP{index},ZP{index}]=utm2utm(XT{index},YT{index},ZT{index},ZE,0);
end 
% Those things are NOT equally spaced
% ZP should be a unique entry, one would check that here

% NOW YOU NEED TO FLATTEN THESE THINGS ALL TOGETHER
[XPP,YPP,TDD]=deal([]);
for index=1:length(indices)
  XPP=[XPP ; XP{index}(:)];
  YPP=[YPP ; YP{index}(:)];
  TDD=[TDD ; TD{index}(:)];
end

% Its is here that I could save time and use the polygon with USABLE
% data as opposed to the one that encompasses it all
% on=inpolygon(XPP,YPP,nprops.xp,nprops.yp);
% Limit the inputs to those that are definitely inside the
% region XE, YE, or else the interpolant takes a long time to calculate
in=inpolygon(XPP,YPP,XE([1 end end 1]),YE([1 1 end end]));
% Even when the "polygon" is the same as the bounding box the equivalence
% may not be perfect due to sampling-step offset? But he "on" is more
% conservative, so this could be the one to prefer in the below.
% On the other hand, taking "on" would make the interpolant
% image-dependent, and that might offset any gains, so, no.
% You'd have to make an "on"-dependent hash

%%%%%%%%%% VISUAL CHECK RAPIDEYE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the grids you have just entered
if xver>1
  % Replot the TOPODATA
  ah(2)=subplot(222);
  % The available topography data locations
  plot(XPP(1:200:end),YPP(1:200:end),'k.')
  hold on
  % The RAPIDEYE data locations
  plot(XE(1:200:end,1:200:end),YE(1:200:end,1:200:end),'b.')
  % The subset of the topography data within the RAPIDEYE domain
  plot(XPP(in),YPP(in),'y.')
  % The subset of the topography data within the RAPIDEYE USABLE domain
  % plot(XPP(on),YPP(on),'c.')
  % A grid around as a visual
  plot(XE([1 end end 1 1]),YE([1 1 end end 1]),'r-')
  hold off
  drawnow
  axis image
end

% Now I need to INTERPOLATE the XP,YP of the TOPODATA onto the XE, YE of
% the RAPIDEYE to get them both to be equally spaced
% This takes a while, so we take the output data already
Fhash=hash([XE([1 end end 1 1]) YE([1 1 end end 1]) ],'SHA-1');
Ffile=sprintf('%s-F.mat',fullfile(getenv('IFILES'),'HASHES',sprintf('%s-%s',upper(mfilename),Fhash)));
Tfile=sprintf('%s-T.mat',fullfile(getenv('IFILES'),'HASHES',sprintf('%s-%s',upper(mfilename),Fhash)));

% The interpolated topography and/or the interpolant may already exist
if exist(Tfile)==2
  disp(sprintf('%s loading %s',upper(mfilename),Tfile))
  tic
  load(Tfile,'TDF')
  F=NaN;
  toc
  if nargout==2
    % If the interpolation exists the interpolant should exist
    load(Ffile,'F')
  end
else
  % Need to still make either or both
  if exist(Ffile)==2
    load(Ffile,'F')
  else
    disp(sprintf('%s making %s',upper(mfilename),Ffile))
    % Create the interpolant
    tic
    F=scatteredInterpolant([XPP(in) YPP(in)],TDD(in));
    toc
    % Save the interpolant
    save(Ffile,'F')
  end
  disp(sprintf('%s making %s',upper(mfilename),Tfile))
  % Performs the interpolation of the TOPODATA to the requested RAPIDEYE locations
  TDF=F(XE,YE);
  save(Tfile,'TDF')
end

%%%%%%%%%% VISUAL CHECK RAPIDEYE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the RAPIDEYE data matrix and the interpolated TINITALY data
if xver>1
  % Replot the TOPODATA
  ah(3)=subplot(223);
  caxx=[-2154.5 1601.4];
  plotit(XE,YE,TDF,caxx,2)
  axis image
  if ~isempty(alldata)
    % Plot the RAPIDEYE data
    ah(4)=subplot(224);
    toplot=double(alldata(:,:,1));
    caxx=round(10.^prctile(log10(toplot(:)),[2 99]));
    plotit(XE,YE,toplot,caxx,2)
    axis image
    % Plot the rivers on top
    [SX,SY,S]=rinitaly(nprops);
    axes(ah(3))
    hold on; r1=plot(SX,SY,'k'); hold off
    axes(ah(4))
    hold on; r2=plot(SX,SY,'k'); hold off
    set(r2,'LineWidth',2)
    drawnow
  end
end
if [nargout>2 || xver==0] && ~isempty(alldata)
  % Just get the rivers 
  [SX,SY,S]=rinitaly(nprops);
else
  [SX,SY,S]=deal(NaN);
end

% You might want to plot some random rows and columns just for fun
if xver==3
  disp('Hit ENTER to continue or CTRL-C to be done')
  pause
  clf
  % Plotting verification of RAPIDEYE and TOPOGRAPHY!
  rij(1)=randi(size(XE,1));
  rij(2)=randi(size(XE,2));
  % A random row and a random column
  subplot(211)
  plot(   TDF(rij(1),:),'k-'); hold on
  plot(toplot(rij(1),:),'b-'); hold off
  title(sprintf('row %i',rij(1)))
  subplot(212)
  plot(   TDF(:,rij(2)),'k-'); hold on
  plot(toplot(:,rij(2)),'b-'); hold off
  title(sprintf('column %i',rij(2)))
end

% Now we have what we want, namely: TDF, the interpolated TOPOGRAPHY DATA
% on the same grid as the RAPIDEYE patch... and the rivers, if you want them
varns={TDF,F,SX,SY};
varargout=varns(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotit(XX,YY,data,sax,pmeth)
% Simple plotting of data with complete regular grids and with color
% range defined and using a specific plotting method

defval('pmeth',2)

switch pmeth 
 case 1
  % Barebones
  imagesc(data); 
 case 2
  % Better
  imagesc(XX(1,:),YY(:,1),data)
  axis xy
  colormap(sergeicol)
  caxis(sax)
  colorbar
 case 3
  % Slower and more flexible
  imagefnan([XX(1) YY(1)],[XX(end) YY(end)],data,'sergeicol',sax)
  try
    % Works best in 2014 since I need to adapt ADDCB
    addcb('ver',sax,sax,'sergeicol',abs(sax(1)))
  end
end
