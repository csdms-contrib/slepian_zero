function [lmcosi,prepar]=igrf(vrs,yr,yir)
% [lmcosi,prepar]=IGRF(vrs,yr,yir)
%
% Interface to load the International Geomagnetic Reference Field
% and pass it on to other subroutines.
% 
% INPUT:
%
% vrs       The version number: 10, 11, 12, or 13 [default: 13]
%           OR: a string with the demo number
% yr        The year of interest (out of 1900:5:2020) [default: 2020]
%           OR: the version number if the  first argument is a demo string
% yir       The year of interest if the first argument is a demo string
%
% OUTPUT:
%
% lmcosi    The tradition matrix with the ordered real coefficients
%           for the potential - however, in units of nT (nanoTesla)
% prepar    The different ordering, for verification purposes only
%
% EXAMPLE:
%
% igrf('demo1') % The radial field, in nanoTesla
% igrf('demo2') % The radial non-dipolar field, in nanoTesla
% igrf('demo3') % The radial field, only contoured, in nanoTesla
% igrf('demo4') % The radial non-dipolar field, only contoured, in nanoTesla
% igrf('demo5') % The radial non-dipolar field, also contoured
% igrf('demo6') % The secular variation
% igrf('demo7') % Code and model testing which should produce no output
%
% Only very subtle changes when an IGRF becomes a DGRF
% igrf('demo3',13,2010)
% igrf('demo3',12,2010)
% igrf('demo3',11,2010)
% igrf('demo3',13,2015)
% igrf('demo3',12,2015)
%
% SEE ALSO: 
%
% PLM2MAG, IGRF10
%
% Tested on 8.3.0.532 (R2014a)
%
% Last modified by fjsimons-at-alum.mit.edu, 03/17/2020

% Note that the inputs to PLM2XYZ are GEOCENTRIC coordinates...
% Normalize the coefficients such that they can be expanded in the 4pi basis
% lola= guyotphysics(0); 
% h=igrf(13,2020);
% Don't be missing the normalization
% h(:,3:4)=h(:,3:4)./repmat(sqrt(2*h(:,1)+1),1,2);
% Don't be missing the radial derivative
% h(:,3:4)=h(:,3:4).*repmat(h(:,1)+1,1,2);
% [r,lon,lat]=plm2xyz(h,lola(2),lola(1))
% So the results match igrf12.f and igrf13.f
% But this calculator is in geodetic coordinates... See the switch inside.
% http://www.geomag.bgs.ac.uk/data_service/models_compass/igrf_calc.html

defval('vrs',13)

if ~isstr(vrs)
  defval('yr',2005)

  % Make it a single year - perhaps fix later
  if prod(size(yr))~=1
    error('Only a single year at the time can be requested for now')
  end
  
  if vrs==10
    % Separate code since it handled a bit differently in the past
    % Calling the old routine is awkward but saves special cases in the
    % body of the current routine.
    lmcosi=igrf10(yr);
  else
    % Open file
    fname=fullfile(getenv('IFILES'),'EARTHMODELS',...
                   sprintf('IGRF-%2.2i',vrs),sprintf('igrf%2.2icoeffs.txt',vrs));
    fid=fopen(fname);
    
    % Read the first three header lines
    hdr{1}=fgetl(fid);
    hdr{2}=fgetl(fid);
    hdr{3}=fgetl(fid);
    
    % Define formats, with reference to IGRF-10
    fmt1=['%s %s %s' repmat('%n',1,22+vrs-10) '%s'];
    fmt2=['%s' repmat('%n',1,25+vrs-10)];
    
    % The maximum expansion
    lmax=[repmat(10,1,20) repmat(13,1,2+vrs-10)];
    
    % Read the third line
    d=textscan(fid,fmt1,1);
    
    % Read the rest - supply zeroes where unavailable
    e=textscan(fid,fmt2,'emptyvalue',0);
    
    % Close file
    fclose(fid);
    
    % Available years
    years=[d{4:25+vrs-10}];
    % Spherical harmonic degrees
    EL=e{2};
    % Spherical harmonic orders
    EM=e{3};
    
    % Secular variation
    SV=e{26+vrs-10};
    
    %%% This applied when the unkowns are ZEROES in the file %%%%%%%%%%
    % Now extract the data
    [C,iy]=intersect(years,yr);
    if isempty(iy)
      error(sprintf('\n%s: Musty specify valid model year',upper(mfilename)));
    end
    
    % Stick in the non-existing zeros for degree and order zero
    prepar=[zeros(1,size(e{iy+3},2)) ; e{iy+3}];
    %%% This applied when the unkowns are ZEROES in the file %%%%%%%%%%
    
    % Reordering sequence
    [dems,dels,mz,lmcosi,mzi,mzo,bigm,bigl,rinm,ronm,demin]=...
        addmon(max(lmax));
    % What we have from the file is, effectively
    % [bigl(2:end) bigm(2:end)]
    % and what we want is lmcosi with the coefficients in the right position 
    % This is the output
    lmcosi(mzo+2*size(lmcosi,1))=prepar;
    
  end
elseif strcmp(vrs,'demo1')
  % Now the version is defaulted... everything skips
  defval('yr',13)
  defval('yir',2020);
  h=igrf(yr,yir);

  % Plot and print
  plotandprint(h,vrs,yr,yir,0,0)
  
elseif strcmp(vrs,'demo2')
  defval('yr',13)
  defval('yir',2020);
  h=igrf(yr,yir);

  % Plot and print
  plotandprint(h,vrs,yr,yir,1,0,[-20000:1000:-1000],[1000:1000:20000])

elseif strcmp(vrs,'demo3')
  defval('yr',13)
  defval('yir',2020);
  h=igrf(yr,yir);
  
  % Plot and print
  plotandprint(h,vrs,yr,yir,0,1,[-65000:5000:-5000],[5000:5000:65000])

elseif strcmp(vrs,'demo4')
  defval('yr',13)
  defval('yir',2020);
  h=igrf(yr,yir);

  % Plot and print
  plotandprint(h,vrs,yr,yir,1,1)
elseif strcmp(vrs,'demo5')
  defval('yr',13)
  defval('yir',2020);
  h=igrf(yr,yir);
  
  % Plot and print
  plotandprint(h,vrs,yr,yir,1,2,[-20000:2000:-2000],[2000:2000:20000])
elseif strcmp(vrs,'demo6')
  for yir=1900:5:2005
    h=igrf10(yir);

    % Plot and print
    plotandprint(h,vrs,yr,yir,1,2,[-20000:2000:-2000],[2000:2000:20000])
  end
elseif strcmp(vrs,'demo7')
  clf
  for yir=1900:5:2005
    h=igrf10(yir);

    % Plot and print
    plotandprint(h,vrs,yr,yir,1,2,[-20000:2000:-2000],[2000:2000:20000])
  end
elseif strcmp(vrs,'demo7')
  for yr=1900:5:2005
    diferm(igrf(10,yr),igrf10(yr))
  end
  for yr=1900:5:2000
    diferm(igrf(11,yr),igrf10(yr))
    diferm(igrf(12,yr),igrf10(yr))
    diferm(igrf(13,yr),igrf10(yr))
  end
  for yr=1900:5:2005
    diferm(igrf(12,yr),igrf(11,yr))
    diferm(igrf(13,yr),igrf(11,yr))
    diferm(igrf(13,yr),igrf(12,yr))
  end
  for yr=1900:5:2010
    diferm(igrf(13,yr),igrf(12,yr))
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction to plot and print 
function plotandprint(h,vrs,yr,yir,zro,cnt,negcont,poscont)
% Zero out the degree-1 component
defval('zro',0)
% Whether contours are plotted
defval('cnt',0)

% Change Schmidt to full normalization for use in PLOTPLM
% This converts the COEFFICIENTS to be multiplied with Schmidt to the 
% COEFFICIENTS to be multiplied with 4pi-normalized harmonics, which
% are Schmidt*sqrt(2l+1), see PLM2XYZ and note the TYPO in Blakely.
h(:,3:4)=h(:,3:4)./repmat(sqrt(2*h(:,1)+1),1,2);

if zro==1
  % The nondipole field, as Blakely p170 and eq. (8.20)
  h(1:3,3:4)=0;
  xlab='non-dipolar radial component (nT)';
else
  xlab='radial component (nT)';
end

% Make sure it is the RADIAL component of this at the surface
h(:,3:4)=repmat(h(:,1)+1,1,2).*h(:,3:4);

clf
% This resolution parameter will change the quoted maxima and minima
degres=1;
d=plotplm(h,[],[],4,degres);
kelicol

% The title string
ztit=sprintf('IGRF-%2.2i magnetic field, year %i, degrees %i-%i',yr,yir,...
		     h(min(find(h(:,3))),1),max(h(~~sum(h(:,3:4),2),1)));

switch cnt
  case 0
   % Just a color plot
  axis image
  longticks(gca,2)
  t(1)=title(ztit);
  movev(t,5)
  
  cb=colorbar('hor');
  shrink(cb,2,2)
  axes(cb)
  longticks(cb,2)
  xlabel(xlab)
  movev(cb,-.1)
 case {1,2}
  % A judicious contour plot
  if cnt==1
    % No overlay
    clf
  end
  
  % Negative and positive contour intervals
  defval('negcont',[-20000:1000:-1000])
  defval('poscont',[  1000:1000:20000])
  % Geographic grid
  lons=linspace(0,360,size(d,2));
  lats=linspace(-90,90,size(d,1));

  % Don't forget to flip up down for contouring!
  [c,hh]=contour(lons,lats,flipud(d),negcont); 
  set(hh,'EdgeC','r')
  hold on
  [c,hh]=contour(lons,lats,flipud(d),poscont); 
  set(hh,'EdgeC','b')
  [c,hh]=contour(lons,lats,flipud(d),[0 0]); 
  set(hh,'EdgeC','k','LineW',2)
  % Finalize
  plotcont; axis image; ylim([-90 90])
  defval('dlat',45)
  set(gca,'ytick',[-90:dlat:90])
  set(gca,'xtick',[0:90:360])
  if cnt==1
    % Otherwise you already had them
    deggies(gca)
  end
  longticks(gca,2)
  t(1)=title(ztit);
  movev(t,5)
  xl=xlabel(sprintf('minimum %i nT ; maximum %i nT ; contour interval %i nT',...
                    round(min(d(:))),round(max(d(:))),...
                    unique([diff(negcont) diff(poscont)])));
  movev(xl,-10)
end

% Actual printing
fig2print(gcf,'portrait')
figna=figdisp('igrf',sprintf('%s-%i-%i',vrs,yr,yir),[],2);
% Maybe this...
% figna=figdisp([],sprintf('%s-%i-%i',vrs,yr,yir),'-r300',1,'jpeg');
