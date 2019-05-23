function varargout=tinitaly(nprops,dirp,diro,xver,alldata)
% TD=TINITALY(nprops,dirp,diro,xver,alldata)
%
% Matches a coordinate set from RAPIDEYE to a TINITALY data file
%
% INPUT:
%
% nprops     A minimal structure with properties from RAPIDEYE
% dirp       Subdirectory [e.g. 'DATA'] of:
% diro       Main directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
% alldata    A data matrix from RAPIDEYE, so that xver=2 can do some plotting
%
% OUTPUTL
%
% TD   The topography data for the region corresponding to nprops
%
% EXAMPLE:
%
% cd /u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY
% [alldata,nprops]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3');
% tinitaly(nprops,[],[],[],alldata)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/23/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
 
% I advocate checking grid parameters and file sizes for ever
defval('xver',2)

% No default data file, but provide one if you want it checked
defval('alldata',[])

%%%%%%%%%%%%%%% FIRST THE RAPIDEYE GRID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[XE,YE,ZE]=rapideyg(nprops,xver);

%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only if you have the headers pre-prepared this will work, bypass box plots
[hdr,TV,~,TA]=tinitalh(dirp,diro,xver*0);

%%%%% FIND APPROPRIATE TOPODATA FILES TO MATCH RAPIDEYE %%%%%%%%%%%%%%%%%%%
% Let's say that we have found the tile indices that matches nprops
indices=[1:10];

%%%%%%%%%% TOPODATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If initializing saves time, here's how to do it. For our data, it didn't
clear XT YT TD
%[XT,YT,TD]=deal(cellnan([length(indices) 1],TA(2,indices),TA(1,indices)));
for index=1:length(indices)
  [XT{index},YT{index},ZT{index},TD{index}]=...
      tinitalg(hdr,TV,indices(index),dirp,diro,xver);
end

% We know to look for possibly rim rows or columns of tile overlap
rim=10;
% Figure out all the pairwise rimmed relationships
tp=nchoosek(indices,2); tp=[tp nan(size(tp,1),1)];
for index=1:size(tp,1)
  disp(sprintf('Testing tiles %2.2i and %2.2i',tp(index,1),tp(index,2)))
  % Feed row/column grid of the first with the second entry in every pair
  tp(index,3)=puzzle(XT{tp(index,1)}(1,:),YT{tp(index,1)}(:,1),...
		     XT{tp(index,2)}(1,:),YT{tp(index,2)}(:,1),rim);
end

% This is up to a slide, we just determine where the overlapping side is
% We need to find the edge where ALL the entries are duplicates with any
% of the other edges, and then trim those, removing redundancies

keyboard

for index=1:size(tp,1)
  disp(sprintf('Testing tiles %2.2i and %2.2i',tp(index,1),tp(index,2)))

  % Check and trim and reassign... have tested extensively on ALL data
  %[XT{tp(index,1)},XT{tp(index,2)}]=
  rimcheck(XT{tp(index,1)},XT{tp(index,2)},rim,tp(index,3));
  %[YT{tp(index,1)},YT{tp(index,2)}]=
  rimcheck(YT{tp(index,1)},YT{tp(index,2)},rim,tp(index,3));
  %[TD{tp(index,1)},TD{tp(index,2)}]=
  rimcheck(TD{tp(index,1)},TD{tp(index,2)},rim,tp(index,3));
end

% Check the overlap between tiles I see a 90 m overlap in the box limits
% in my three examples, on all sides, on all sides. Now check the data
% repetition for [7 8 10], and I find
% TD{3}(end-9:end,1:5)-TD{1}(1:10,1:5)   
% TD{1}(1:11,end-9:end)-TD{2}(1:11,1:10) 
% TD{3}(end-9:end,size(TD{1},2)-9:size(TD{1},2))-TD{2}(1:10,1:10)

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
  end
  hold off
  % And attractive title, substituting the underscore with a dash
  % Only one title here, but clearly could be more tiles 
  t=title(nounder(pref(hdr{index})));
  set(t,'FontWeight','normal')
  drawnow
end

% Convert TOPODATA to the RAPIDEYE coordinate system
for index=1:length(indices)
  [XP{index},YP{index},ZP{index}]=utm2utm(XT{index},YT{index},ZT{index},ZE,xver);
end 
% Those things are NOT equally spaced

keyboard

% Limit the inputs to those that are definitely inside the
% region XE, YE, or else the interpolant takes a long time to calculate
in=inpolygon(XP,YP,XE([1 end end 1]),YE([1 1 end end]));

%%%%%%%%%% VISUAL CHECK RAPIDEYE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the alldata you have just entered
if xver>1
  % Replot the TOPODATA
  ah(2)=subplot(222);
  % The XE,YE need to be a subportion of XP,YP
  plot(XP(1:100:end,1:100:end),YP(1:100:end,1:100:end),'k.')
  hold on
  plot(XE(1:200:end,1:200:end),YE(1:200:end,1:200:end),'b.')
  % The polygon of the available data
  plot(XE([1 end end 1 1]),YE([1 1 end end 1]),'r-')
  plot(XP(in),YP(in),'y.')
  hold off
  drawnow
end

% Now I need to INTERPOLATE the XP,YP of the TOPODATA onto the XE, YE of
% the RAPIDEYE to get them both to be equally spaced
% This takes a while, so we take the output data already
Fhash=hash([XP(in) ; YP(in) ; TD(in)],'SHA-512');
Ffile=fullfile(getenv('IFILES'),'HASHES',Fhash);
if exist(sprintf('%s.mat',Ffile))~=2
  disp(sprintf('%s making %s',upper(mfilename),'savefile'))
  F=scatteredInterpolant([XP(in) YP(in)],TD(in));
  % Performs the interpolation
  TDF=F(XE,YE);
  save(Ffile,'F','TDF')
else
  disp(sprintf('%s loading %s',upper(mfilename),'savefile'))
  load(Ffile,'TDF')
end

%%%%%%%%%% VISUAL CHECK RAPIDEYE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of the alldata you have just entered
if xver>1
  % Replot the TOPODATA
  ah(3)=subplot(223);
  caxx=[-2154.5 1601.4];
  plotit(XE,YE,TDF,caxx,2)

  % Plot the RAPIDEYE data
  ah(4)=subplot(224);
  toplot=double(alldata(:,:,1));
  caxx=round(10.^prctile(log10(toplot(:)),[2 99]));
  plotit(XE,YE,toplot,caxx,2)
  
  % Plot the rivers on top
  [SX,SY,S]=rinitaly(nprops);
  axes(ah(3))
  hold on; r1=plot(SX,SY,'k'); hold off
  axes(ah(4))
  hold on; r2=plot(SX,SY,'k'); hold off
  set(r2,'LineWidth',2)
  drawnow
end

if xver>1
  disp('Hit ENTER to continue')
  pause
  clf
  % More plotting verification
  rij(1)=randi(size(XE,1));
  rij(2)=randi(size(XE,2));
  % A random row and a random column
  subplot(211)
  plot(TDF(rij(1),:),'k-'); hold on
  plot(   toplot(rij(1),:),'b-'); hold off
  title(sprintf('row %i',rij(1)))
  subplot(212)
  plot(TDF(:,rij(2)),'k-'); hold on
  plot(   toplot(:,rij(2)),'b-'); hold off
  title(sprintf('column %i',rij(2)))
end

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
  % Works best in 2014 since I need to adapt ADDCB
  addcb('hor',sax,sax,'sergeicol',abs(sax(1)))
end
