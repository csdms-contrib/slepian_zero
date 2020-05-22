function varargout=bermuda(c11,cmn,cax,mult,mapit,comap)
% [z,lon,lat]=BERMUDA(c11,cmn,cax,mult,mapit,comap)
%
% Collects data and makes a map of, well, you guessed it
%
% INPUT:
%
% c11       lon,lat of the top left of the box 
% cmn       lon,lat of the bottom right of the box 
% mult      an integer multiplicative resolution degrader [default: 10]
% mapit     a [lon lat] matrix with special points mapped [default: BIOS]
% comap     if specified, uses that colormap [default: empty; we do it for you]
%           Note that leaving it empty optimizes for the macromap
%
% OUTPUT:
% 
% z         the requested elevation
% lon       the longitudes
% lat       the latitudes
%
% EXAMPLE:
%
% Default work best for the macromap
% bermuda
% For the micromap, do this:
% bermuda([295 32],[297 31],[-5000 -4000],[],[],kelicol)
%
% TESTED ON 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/21/2020

% Should I explore Ocean Data View?

% Turns out there is a 2020 version!! https://download.gebco.net/

% This from looking about; BIOS; PU ; BATS ; OFP
defval('mapit',[295.3012168 32.3704557 ; ...
		295.8520    31.427450 ; ...
		295.8333    31.666666 ; ...
	        295.9168    31.913216]);
defval('mapat',{'BIOS ','PU    ','BATS','OFP  '})
defval('mapco',[0 1      0 ; ...
  		1 0.561  0 ; ...
		0 0      1 ; ...
		1 0      0])
defval('comap',[])

defval('c11',[294 33])
defval('cmn',[297 31])
% Get the topography parameters
defval('vers',2019); 
defval('npc',20);
[~,~,~,~,~,~,dxdy,NxNy]=readGEBCO(vers,npc);

defval('mult',1); mult=round(mult);
dxdy=dxdy*mult;

% Make the save file
defval('savefile',fullfile(getenv('IFILES'),'TOPOGRAPHY','BERMUDA',...
			   sprintf('%s.mat',hash([c11 cmn vers npc dxdy NxNy],'SHA-1'))))


% Make the grid of longitudes and latitudes
lons=c11(1):+dxdy(1):cmn(1); 
% Watch the conventions for GEBCO below
lons=lons-(lons>180)*360;
lats=c11(2):-dxdy(2):cmn(2);
[LON,LAT]=meshgrid(lons,lats);

% Get the elevation!
if exist(savefile)~=2
  z=gebco(LON,LAT,vers,npc);
  save(savefile,'z')
else
  load(savefile)
end

if ~isempty(comap)
  % Take out BIOS...
  mapit=mapit(2:end,:);
  mapat=mapat(2:end);
  mapco=mapco(2:end,:);
end

% And now make the plot if there is no output requested
if nargout==0
  % Begin with a new figure, minimize it right away
  defval('fs',6);
  % Color limits 
  % The reference global color rendition would be
  % imagefnan(c11,cmn,z,'demmap',[-7473 5731])
  % cax=[-4000 0.75*max(z(:))];
  % cax=halverange(minmax(z),75);
  defval('cax',[-6000 500]);
  % Get the relevant depths also
  for index=1:size(mapit,1)
    mappl{index}=sprintf('%s @ %im',...
			 mapat{index},...
			 round(gebco(mapit(index,1)-(mapit(index,1)>180)*360,...
			       mapit(index,2),vers,npc)));
    maplo{index}=sprintf('%s @ %10.6f %10.6f',...
			 mapat{index},...
			 mapit(index,1)-(mapit(index,1)>180)*360,...
			 mapit(index,2));
  end
  % Print instructions
  printit(z,cax,c11,cmn,fs,vers,mfilename,mult,mapit,mapat,mapco,mappl,maplo,comap)
end

% Or maybe just do output
varns={z};
varargout=varns(1:nargout);

% Subfunction for faster prototyping
function printit(z,cax,c11,cmn,fs,vers,nem,mult,mapit,mapat,mapco,mappl,maplo,comap)
% Note that the print resolution for large images is worse than the
% detail in the data themselves. One could force print with more dpi.
clf
% Color bar first...
[cb,cm]=cax2dem(cax,'hor');
% See IMAGEF for comments on pixel registration, which these are
if isempty(comap)
  imagefnan(c11,cmn,z,cm,cax)
else
  imagefnan(c11,cmn,z,comap,cax)
end
% Maybe adjust to common field of view regardless of resolution, even if
% this means cutting pixels off, for easy scrolling later on

ah=gca;

xlim([c11(1) cmn(1)])
ylim([cmn(2) c11(2)])
hold on
for index=1:size(mapit,1)
  p(index)=plot(mapit(index,1),mapit(index,2),'o');
end
hold off

% then colorbar again for adequate rendering
if isempty(comap)
  [cb,cm]=cax2dem(cax,'hor');
else
  colormap(comap)
  [cb,xcb]=addcb('hor',cax,cax,comap);
  set(cb,'FontSize',fs)
  axes(ah)
end

% Cosmetics
% plotplates(c11,cmn)
longticks(ah,2)

% Preserve the ticks ----------------
set(ah,'XTick',[c11(1):0.50:cmn(1)])
set(ah,'YTick',[cmn(2):0.25:c11(2)])
grid on
if isempty(comap)
  set(ah,'CameraViewAngle',9)
end
% Preserve the ticks ----------------

deggies(ah)
set(ah,'FontSize',fs)
xlabel('longitude')
ylabel('latitude')
cb.XLabel.String=sprintf('GEBCO %i elevation/bathymetry (m)',vers);
if isempty(comap)
  cb.XTick=unique([cb.XTick minmax(cax)]);
end
warning off MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
longticks(cb,2)
warning on MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar

if isempty(comap)
  shrink(cb,0.7,2)
  movev(cb,-0.175)
else
  shrink(cb,1,1.75)
end

% Cosmetology
set(p,'MarkerSize',3,'MarkerEdgeColor','k')
for index=1:length(p)
  set(p(index),'MarkerFaceColor',mapco(index,:))
end
l(1)=legend(p,mappl,'Location','SouthWest');

% Second legend! A bit of a pain
ax=xtraxis(ah); 
hold on
for index=1:size(mapit,1)
  px(index)=plot(mapit(index,1),mapit(index,2),'o');
  set(px(index),'MarkerFaceColor',mapco(index,:))
end
set(px,'MarkerSize',3,'MarkerEdgeColor','k')
hold off
% Should have built the next two into XTRAXIS also
if isempty(comap)
  set(ax,'CameraViewAngle',get(ah,'CameraViewAngle'))
end
set(ax,'FontSize',get(ah,'FontSize'))
l(2)=legend(ax,px,maplo,'Location','NorthEast');

movev(l(1),-0.02)
moveh(l(1),-0.01)
movev(l(2), 0.02)
moveh(l(2), 0.01)

% Print it
figdisp(nem,sprintf('%3.3i',mult),[],2)

%convert -density 300x300 bermuda_1.pdf bermuda_1.png
%convert -density 225x225 bermuda_2.pdf bermuda_2.png

