function varargout=pomme4(L,degres,doplot,hr)
% [d,lmcosip,degres]=POMME4(L,degres,doplot,hr)
%
% Plots a lithospheric magnetic field model, POMME, which is complete from
% degree 1 and order 0 to degree 720 and order 719. Makes a map of the radial
% component of the magnetic field, and returns the data plotted if requested.
%
% INPUT:
%
% L          Truncation degree(s), default is [17 72] bandlimited, if
%            only one value supplied, turns it into [1 L]
% degres     The degree resolution in equatorial degrees
%            [default: 0.25, as a ppropriate for L=720]
% doplot     1 Actually render this [default]
%            0 Just return the data, both map and coefficients
% hr         The HALVERANGE parameter for the color rendition [default: 75], 
%            OR: two explicit axis limits for the color bar
% OUTPUT:
%
% d          The map being plotted
% lmcosip    The spherical harmonics being plotted
% degres     The degree resolution
%
% SEE ALSO: 
%
% IGRF10, IGRF
% 
% EXAMPLE:
%
% pomme4('demo') % Power-spectral density plot
%
% TESTED ON: 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 03/19/2020

% See http://www.geomag.org/models/

% Input default values
defval('L',[17 72])

% The directory with the coefficient data, which must exist
defval('ddir',fullfile(getenv('IFILES'),'EARTHMODELS','MAGNETIC','POMME-4'))

% Look at the header, the epoch is
yr=2004;

if ~isstr(L)
  defval('doplot',1)
  defval('degres',1/4)
  defval('hr',75)
  
  % If only the upper bandlimited is supplied
  if length(L)==1
    L=[1 L];
  end

  % Truncate degres to nearest hundredth
  degres=round(degres*100)/100;
  
  % Filename with expanded map to be loaded and/or saved
  fname=fullfile(ddir,...
		 sprintf('POMME-4_BrnT_%3.3i_%3.3i-%4.2f.mat',...
			 L(1),L(2),degres));
  % Extensionless filename with expansion coefficients to be loaded and/or resaved
  cname=fullfile(ddir,'pomme-4.2s-nosecular');
  
  % Labeling etc
  ztit=sprintf('POMME-4 magnetic field, year %i, degrees %i-%i',yr,L(1),L(2));
  xlab='radial component (nT)';

  if exist(fname,'file')~=2
    % Get the coefficients
    if exist(sprintf('%s.mat',cname),'file')~=2

      % Load the coefficients from the original file and resave
      t=clock;
      lmcosi=load(sprintf('%s.cof',cname));

      % Available from http://www.geomag.org/models/pomme4.html
      % noting that I stripped the header and saved the first four columns
      % only to make it all a bit lighter.

      disp(sprintf('%s loaded %s in %g s',upper(mfilename),...
		   sprintf('%s.cof',cname),etime(clock,t)))

      % File size in MATLAB8 is 75% of filesize in MATLAB9
      % and with full filepath, the period in the filename is interpreted
      % as an extension, so here you need to be sure to include .mat...
      save(sprintf('%s.mat',cname),'lmcosi')
    else
      % Load the resaved file, which is faster and more economical
      t=clock;
      load(sprintf('%s.mat',cname));
      disp(sprintf('%s loaded %s in %g s',upper(mfilename),...
		   sprintf('%s.cof',cname),etime(clock,t)))
    end
    % Prepare to select the range of interest
    missl=addmup(lmcosi(1,1)-1);
    % Select the degree range of interest
    lmcosi=lmcosi(addmup(L(1)-1)-missl+1:addmup(L(2))-missl,:);
    
    % Figure out if the dimensions are right, lowpass or bandpass
    lp=length(L)==1; bp=length(L)==2;

    % The spherical harmonic dimension
    ldim=(L(2-lp)+1)^2-bp*L(1)^2;
    % Extra redundant check
    diferm(ldim-(2*length(lmcosi)-[L(2)-L(1)]-1))
    
    % Convert to radial-component magnetic field on the reference surface
    lmcosip=plm2mag(lmcosi);

    % Then expand (and plot)
    if doplot
      clf
      [d,ch,ph]=plotplm(lmcosip,[],[],4,degres);
      if length(hr)==1
	caxis(halverange(d,hr))
      else 
	caxis(hr)
      end
      touchup(ztit,xlab)
    else
      d=plm2xyz(lmcosip,degres);
    end
    
    % Then save the expansion and the expansion coefficients
    save(fname,'d','lmcosip','degres')
  else
    load(fname)
    disp(sprintf('Loading %s',fname))
    if doplot
      clf
      imagef(d)
      plotcont; plotplates
      if length(hr)==1
	caxis(halverange(d,hr))
      else 
	caxis(hr)
      end
      touchup(ztit,xlab)
    end
  end

  % Actual printing
  fig2print(gcf,'portrait')
  figna=figdisp('POMME-4',sprintf('%i_%3.3i-%3.3i',yr,L(1),L(2)),[],2);

  % Do this if you can!
  system(sprintf('xpdf %s.pdf',figna));

  % Output if requested
  vars={d,lmcosip,degres};
  varargout=vars(1:nargout);
elseif strcmp(L,'demo')
  if verLessThan('matlab','9')     
    error('Requires minor adaptions for older MATLAB releases')
  end
  
  defval('mods','POMME-4');
  defval('units','nT');
  
  % Load the model coefficients
  cname=fullfile(ddir,'pomme-4.2s-nosecular');
  load(sprintf('%s.mat',cname));

  % Rename and redo for consistency with IGRF
  h=[zeros(1,size(lmcosi,2)) ; lmcosi]; clear lmcosi;

   % The degree range of interest - should be 720
  EL=minmax(h(abs(h(:,3))>0,1));
  EL1=16;

  % Plot and print
  norma=1;
  % Spectral calculation of signal - watch the normalization
  [sdl,l,bta,lfit,logy,logpm]=plm2spec(h,norma,2,EL1+1);
  
  % The following borrowed from WATTSANDMOORE
  fig2print(gcf,'portrait')

  clf
  ah=gca;

  % The power spectral density
  a=loglog(l,sdl,'o');
  hold on
  % The loglinear fit
  b=loglog(lfit,logy,'k-');
  hold off

  % Create labels for future use
  xlabs='spherical harmonic degree';
  xxlabs='equivalent wavelength (km)';
  ylabs=sprintf('%s (%i) power spectral density [%s**2]',mods,yr,units);

  % Cosmetics
  set(a,'MarkerFaceColor','k','MarkerSize',3,'MarkerEdgeColor','k')
  
  xlim([EL(1)-0.25 EL(2)+200]);
  longticks(gca)
  shrink(gca,1.333,1.075)

  % This needs to be data-dependent
  ylim=[1e0 1e11];
  ah.YLim=ylim;

  % The reference degrees you want plotted also
  nn=[1 13 16];
  % The reference degrees you wanted as well
  hold on
  for index=1:length(nn)
    pn(index)=plot([nn(index) nn(index)],ylim,'k--');
  end
  hold off

  % Labels
  ylabel(ylabs)
  xlabel(xlabs)

  % Extra axis in equivalent wavelengths, needed to know 6371.2 from IGRF
  % model specification, but fix label precision
  nlt=[2*pi*6371.2/2 10000 3000 1000 300 100 55];
  % This only to fix the rounding
  nlti=[100*round(nlt(1:end-1)/100) nlt(end)];
	
  % With or without round, it's always going to be approximate...
  [ax,xl,yl]=xtraxis(ah,round(jeans(nlt,0,1)),nlti,xxlabs);
  longticks(ax)
  % A little fix? Should build into XTRAXIS perhaps
  hx=ax.XTickLabel;
  for index=1:size(hx,1)
    hxc{index}=deblank(hx(index,:));
  end
  ax.XTickLabel=hxc;

  % Final cosmetics
  delete(pn)
  ax.XMinorTick='off';  
  ah.XTick=[1 2 3 4 6 9 13 20 40 133 400 720];
  ah.XGrid='on';
  ah.YGrid='on';
  ah.XMinorTick='off';
  ah.MinorGridLineStyle='none';

  % Output to PDF
  figdisp('pomme4',sprintf('%s',L),[],2)
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function touchup(ztit,xlab)
% The below stolen verbatim from IGRF10
kelicol 
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
