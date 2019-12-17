function varargout=rinitaly(nprops,froot,dirp,diro,buf,dlev,xver)
% [SX,SY,S]=RINITALY(nprops,froot,dirp,diro,buf,dlev,xver)
%
% Returns Italian river coordinates as pertaining to a specific panel only,
% and in the same UTM conventions, as a data structure from RAPIDEYE
%
% INPUT:
%
% nprops     A minimal properties structure from RAPIDEYE, all you need is:
%              nprops.lo   The polygonal longitudes clockwise from NW
%              nprops.la   The polygonal latitudes clockwise from NW
% froot      Filename root [e.g. ''IT_SurfaceWaterBodyLine']
% dirp       Directory [e.g. 'WISE']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY']
% buf        A buffer in degrees to aid the search for rivers within polygon
% dlev       A PENLIFT parameter to disentangle rivers after they've been joined
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
% 
% SX, SY     All the X and Y coordinates of all the rivers, together
% S          The proper structure, with names, etc.
%
% EXAMPLE:
%
% rinitaly('demo')
%
% Last modified by fjsimons-at-alum.mit.edu, 12/17/2019

% Make some defaults

% This required a change in DEFSTRUCT! If it existed as a non-struct...
defstruct('nprops',{'la' 'lo' 'C11' 'CMN'},...
	  {[39.2380 39.2335 39.0083 39.0128 39.2380], ...
	   [16.6627 16.9523 16.9461 16.6575 16.6627], ...
	   [6.435025e+05 4.3444975e+06], ...
	   [6.684975e+05 4.3195025e+06]})

if isstruct(nprops) || [~isstruct(nprops) && ~strcmp(nprops,'demo')]
  % Root of the filename the several files inside the directory
  defval('froot','IT_SurfaceWaterBodyLine')
  % Bottom-level directory name
  defval('dirp','WISE')
  % Top-level directory name, where you keep the Tinitaly directory
  defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY')
  
  % I advocate checking grid parameters and file sizes for ever
  defval('xver',1)
  % You could rewrite the joining instead of unjoining
  defval('dlev',2)
  % A small buffer won't stop the rivers from flowing near the box edge
  defval('buf',0.025)
  
  % The file name root including the path name
  fname=fullfile(diro,dirp,froot);
  if xver>0
    % Some checks and balances
    disp(sprintf('Looking for %s I am finding\n',fullfile(diro,dirp,froot)))
    ls(fullfile(diro,dirp))
  end
  
  % Read the shape files, one way or another
  if exist(sprintf('%s.mat',fname))==2

    % Now you no longer need the Mapping Toolbox
    disp(sprintf('Loading %s.mat',fname))
    load(fname,'S')
  else
    % For this you do need the Mapping Toolbox
    disp(sprintf('Reading %s.shp',fname))
    S=shaperead(fname);
    save(fname,'S')
  end
  
  % Turn out all of them at the same time... could insert NaNs
  SX=[S(:).X];
  SY=[S(:).Y];

  % How about we use the polygon to subselect the rivers within it
  if buf>0
    % Let us be liberal in extending the box a bit
    [lab,lob]=bufferm(nprops.la,nprops.lo,buf);
    % But you need to get rid of the interior domain and the extra NaN
    lo=lob(length(nprops.lo)+2:end);
    la=lab(length(nprops.la)+2:end);
  else
    % No buffer, that's just the original
    lo=nprops.lo; la=nprops.la;
  end
  in=inpolygon(SX,SY,lo,la);

  if sum(in)~=0
    SX=SX(in);
    SY=SY(in);

    % One has to hope it comes up with the same zone as what we thought
    warning off MATLAB:nargchk:deprecated
    [xSX,ySY,ZS]=deg2utm(SY,SX);
    warning on MATLAB:nargchk:deprecated
  
    % Need to have a unique UTM zone
    diferm(sum(ZS,1)/length(ZS)-ZS(1,:))
    % What would we want it to be in UTM, regardless of what RAPIDEYE says?
    disp(sprintf('According to DEG2UTM, this is %s',ZS(1,:)))
    if license('test', 'map_toolbox')
      % Another way to guess the UTM zone
      upg=utmzone(nanmean(SY),nanmean(SX));
      disp(sprintf('According to UTMZONE, this is %s',upg))
    end
  
    % Insert NaNs for beauty
    [SX,SY]=penlift(xSX,ySY,dlev);
  else
    [SX,SY]=deal(nan);
  end

  % Make a plot if you so desire
  if xver==2
    plot(SX,SY,'b')
  end
  
  % Optional output
  varns={SX,SY,S};
  varargout=varns(1:nargout);
else
  % It's a demo!
  % Get a tile of RAPIDEYE data and plot it
  [alldata,nprops]=rapideye;
  ah=krijetem(subnum(2,2));

  for index=1:length(ah)
    axes(ah(index))
    imagefnan(nprops.C11,nprops.CMN,double(alldata(:,:,1)),[],[1500 15000])
  end

  % Different river data sets
  flib={'ITA_water_lines_dcw','eu_riv_30s','eu_riv_15s','IT_SurfaceWaterBodyLine'};
  flob={'DIVA-GIS','HYDROSHEDS','HYDROSHEDS','WISE'};

  % Plot them
  for index=1:length(flib)
    [SX,SY]=rinitaly(nprops,flib{index},flob{index}); 
    axes(ah(index))
    hold on; p(index)=plot(SX,SY,'k'); hold off; 
    axis([nprops.C11(1) nprops.CMN(1) nprops.CMN(2) nprops.C11(2)])
    t(index)=title(nounder(sprintf('%s',flib{index})));
    drawnow
    set(ah(index),'xticklabels',...
		  round([get(ah(index),'xtick')-min(get(ah(index),'xtick'))]/1000))
    set(ah(index),'yticklabels',...
		  round([get(ah(index),'ytick')-min(get(ah(index),'ytick'))]/1000))
  end

  % Pretty them
  set(p,'LineW',0.5)
  longticks(ah)
  set(t,'FontWeight','normal')

  % Print them
  figdisp([],'demo',[],2)
end
