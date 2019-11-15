function drone2utm(nroot,ndir,pixi,froot,diro,clip)
% DRONE2UTM(nroot,ndir,pixi,froot,dirp,diro,clip)
%
% Converts drone GeoTiff digital elevation model ('dem') and multispectral
% image ('ortho') to in-house UTM image format that mimics the
% projection of a RAPIDEYE image file covering the same region.
%
% INPUT:
%
% nroot                    A file root name [default: 'enotrehr']
% ndir                     The directory where, e.g. enotre-dem.tif and enotre-ortho.tif exist
% pixi                     1 If you want to take a visual look at it
%                          0 If you just want to rewrite the image in a MAT stack
% froot, dirp,diro,clip    Input to load the RAPIDEYE conversion file
%
% SEE ALSO:
%
% RAPIDEYE, RAPIDEYS, RAPIDEYM
%
% Last modified by fjsimons-at-alum.mit.edu, 11/14/2019

% Where is the drone stuff?
defval('nroot','enotrehr')
defval('ndir',fullfile(getenv('ITALY'),'DRONE',nroot))
defval('pixi',1)

if strcmp(nroot(1:6),'enotre') || strcmp(nroot,'major')
  % For the corresponding embedding RAPIDEYE image
  defval('froot','3357121_2019-04-20_RE4_3A')
  defval('dirp','20190420_093020_3357121_RapidEye-4')
  defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/enotre')
  defval('clip','_clip')
elseif strcmp(nroot(1:5),'amato')
  % For a corresponding embedding RAPIDEYE image
  defval('froot','3356717_2014-08-26_RE5_3A')
  defval('dirp','20140826_103229_3356717_RapidEye-5')
  defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/sorellegarzo')
  defval('clip','_clip')
end

% Save name
sname=fullfile(ndir,sprintf('eb_%s.mat',nroot));
if exist(sname)==2
  load(sname)
else
  % Will need to project this onto the UTM grid of enotre
  rprops=geotiffinfo(fullfile(diro,dirp,sprintf('%s_Analytic%s.tif',froot,clip)));
  
  % Of course this is the largely the same, just for example
  % [alldata,nprops,rprops,rgbdata,alfadat]=rapideye(froot,dirp,diro,[],[],clip);
  
  % Load the drone dem/image files
  dfile=fullfile(ndir,sprintf('%s-dem.tif',nroot));
  ofile=fullfile(ndir,sprintf('%s-ortho.tif',nroot));

  % Create main TIFF objects with the data we really want
  warning off MATLAB:imagesci:tiffmexutils:libtiffWarning 
  warning off        imageio:tiffmexutils:libtiffWarning
  dtiffo=Tiff(dfile,'r');
  otiffo=Tiff(ofile,'r');
  warning on MATLAB:imagesci:tiffmexutils:libtiffWarning 
  warning on        imageio:tiffmexutils:libtiffWarning

  % All other properties pertaining to the image
  dprops=geotiffinfo(dfile);
  oprops=geotiffinfo(ofile);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Read the dem... note that IMREAD(dfile) would do this too, but
  % it wouldn't of course give you any of the checkable metadata
  dem=read(dtiffo);
  % Note that this is in single hence min is 
  dem(dem==[intmin('int16')+1])=NaN;

  % Convert the grid
  [XX,YY]=projectify(dprops,rprops);

  % Now save the things that you know are needed
  spitout(sprintf('%s_drone.dem',nroot),'topodata',dem);
  spitout(sprintf('%s_drone.dem',nroot),'XX',XX);
  spitout(sprintf('%s_drone.dem',nroot),'YY',YY);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Read  the multispectral image
  ortho=read(otiffo);

  % Convert the grid
  [XX,YY]=projectify(oprops,rprops);

  % Now save the things that you know are needed
  spitout(sprintf('%s_drone.ims',nroot),'specdata',ortho);
  spitout(sprintf('%s_drone.ims',nroot),'XX',XX);
  spitout(sprintf('%s_drone.ims',nroot),'YY',YY);

  % Save it all to a MAT file
  save(sname,sprintf('%s_drone',nroot),'rprops','-v7.3')
end

if pixi==1
  % If it was preloaded get this out here
  eval(sprintf('dXX=%s_drone.dem.XX;',nroot))
  eval(sprintf('dYY=%s_drone.dem.YY;',nroot))
  eval(sprintf('dem=%s_drone.dem.topodata;',nroot))
  eval(sprintf('ortho=%s_drone.ims.specdata;',nroot))
  eval(sprintf('oXX=%s_drone.ims.XX;',nroot))
  eval(sprintf('oYY=%s_drone.ims.YY;',nroot))
  
  % Need to do this by hand for now
  % Load an enotre image file to check the overlay... it's why this
  % stretch is by hand, since we load it from our presaved stack
  if strcmp(nroot(1:6),'enotre') || strcmp(nroot,'major')
    load('/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/enotre/ri_enotre.mat','enotre_20190420093020')
    load('/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/enotre/ri_enotre.mat','enotre')
    rdata=enotre_20190420093020;
    rdats=enotre;
    % What color axis/scale?
    if strcmp(nroot,'enotre')
      clis=[500 630];
    elseif strcmp(nroot,'enotrehr')
      clis=[500 715];
    elseif strcmp(nroot,'major')
      clis=[210 377];
    end
    % The weather station from Trimble in the Drive spreadsheet
    warning off MATLAB:nargchk:deprecated
    [xw,yw]=deg2utm(39.09404752,16.77964366);
    [xww,yww]=projfwd(rprops,39.09404752,16.77964366);
    % Good opportunity to check projection conversion
    diferm(round(xw),round(xww))
    diferm(round(yw),round(yww))
    warning on MATLAB:nargchk:deprecated
  elseif strcmp(nroot,'amato')
    load('/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/sorellegarzo/ri_sorellegarzo.mat',...
	 'sorellegarzo_20140826')
    load('/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE/sorellegarzo/ri_sorellegarzo.mat',...
	 'sorellegarzo')
    rdata=sorellegarzo_20140826;
    rdats=sorellegarzo;
    % What color axis/scale?
    clis=[53 145];
    % No weather station
    [xw,yw]=deal(NaN);
  end

  % Make a picture to take a look
  figure(1)
  clf
  % Some RAPIDEYE IMAGE
  ah(1)=subplot(2,2,1);
  imagesc([rdata.nprops.C11(1) rdata.nprops.CMN(1)],...
	  [rdata.nprops.C11(2) rdata.nprops.CMN(2)],...
	  rapideya(rdata.alldata)); axis image xy
  cosmeto(ah(1),rdats.orchardx,rdats.orchardy,xw,yw,dXX,dYY,dem)
 
  % TINITALY TOPOGRAPHY
  ah(2)=subplot(2,2,2);
  imagesc(rdats.xx,rdats.yy,rdats.topodata); axis image xy
  cosmeto(ah(2),rdats.orchardx,rdats.orchardy,xw,yw,dXX,dYY,dem)
  caxis(clis)

  % DRONE DEM, FAKE REGULAR GRID FOR NOW
  % These are NOT yet properly interpolated - see below, but we fake it now
  ah(3)=subplot(2,2,3);
  % For the regularly gridded file
  % imagefnan(rdats_drone.dem.C11,rdats_drone.dem.CMN,...
  %    rdats_drone.dem.topodata,[],clis,[],1); axis image xy
  imagefnan([dXX(1) dYY(1)],[dXX(end) dYY(end)],dem,[],clis,[],1); axis image xy
  cosmeto(ah(3),rdats.orchardx,rdats.orchardy,xw,yw,dXX,dYY,dem)

  % DRONE IMAGERY, FAKE REGULAR GRID FOR NOW
  ah(4)=subplot(2,2,4);
  imagesc([oXX(1) oXX(end)],[oYY(1) oYY(end)],rapideya(ortho)); axis image xy
  cosmeto(ah(4),rdats.orchardx,rdats.orchardy,xw,yw,dXX,dYY,dem)
  caxis(clis)
  
  % Print it
  figdisp(nroot,'drone',[],2)        
end

% Cosmetics
function cosmeto(ah,x,y,wx,wy,XX,YY,dem)
axes(ah)
hold on
plot(x,y,'r')
plot(wx,wy,'gx')
hold off
axis([minmax(XX(~isnan(dem))) minmax(YY(~isnan(dem)))])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projects the drone regular lon/lat system onto the Rapideye projection
% which turns it into an irregularly spaced UTM. Later, check DEG2UTM
function [XX,YY]=projectify(dprops,props)
% INPUT:
%
% dprops        is what you have from the drone
% props         is what you want in the RAPIDEYE projection

% Number of rows and columns, not that getTag is also an option
nr=dprops.Height;
nc=dprops.Width;
% Spacings in x and y
spx=dprops.PixelScale(1);
spy=dprops.PixelScale(2);
% Corner coordinates
ypg=dprops.CornerCoords.Y;
xpg=dprops.CornerCoords.X;
% The grid that is implied in these image coordinates
xeye=xpg(1)+spx/2:+spx:xpg(2);
yeye=ypg(1)-spy/2:-spy:ypg(3);
diferm(nc-length(xeye))
diferm(nr-length(yeye))

% This is the complete pairwise grid of the drone, equally spaced in lon/lat
[XE,YE]=meshgrid(xeye,yeye);

% And project the dem onto it - could have done it with DEG2UTM also,
% which is not 100% the same for some reason; also it's not equally
% spaced in UTM anymore. Check DEG2UTM anecdotally now, thoroughly later
tic
[XX,YY]=projfwd(props,YE,XE);
disp(sprintf('Running PROJFWD took %4.2f s on %ix%i grid',toc,size(XE,1),size(XE,2)))
% You might now make the drone UTM grid regular, but leave it for now

% If these were all NaN they didn't need the projection! And thus could
% have kept the original. But notice it's 33S not 33N.
if [sum(~isnan(XX(:))) + sum(~isnan(YY(:)))]==0
  % Only indication that it was in UTM to begin with

  % Isn't this somehow backward... see also TINITALY etc.... UTM2UTM
  % didn't work for some strange reason...
  [LAT,LON]=projinv(dprops,XE,YE);
  [XX,YY]=projfwd(props,LAT,LON);
  % In which case we also shouldn't save the whole file but rather only
  % the axes... to be done later.
end

% Would need to make the data an input as well

% Make an equally spaced UTM grid on a reasonable grid
%mX=floor(spx*fralmanac('DegDis')*10)/10;
%mY=floor(spy*fralmanac('DegDis')*10)/10;
%ex=min(XEP(:)): mX:max(XEP(:));
%wi=max(YEP(:)):-mY:min(YEP(:));
%[EX,WI]=meshgrid(ex,wi);

% But now you want the results interpolated onto a regular grid
% for index=1:5
%   d=double(data(:,:,index));
%   % Could make a hash perhaps
%   F=scatteredInterpolant([XEP(:) YEP(:)],d(:));
%   % This takes forever
%   dataF(:,:,index)=uint16(F4(EX,WI));
% end

% Make a grid plot
%fridplot(XEP,YEP,'Color','k')
%hold on
%fridplot(EX,WI,'Color','y')
%hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a subfunction for the expanded variable assignment
function spitout(sname,vname,var)
% This is marginally clearer but last input can't be an operation
evalin('caller',sprintf('%s.%s=%s;',sname,vname,inputname(3)))
