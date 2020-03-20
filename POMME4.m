function varargout=POMME4(L,degres,doplot,hr)
% [d,lmcosip,degres]=POMME4(L,degres,doplot,hr)
%
% Plots a lithospheric magnetic field model, POMME, which is complete from
% degree 1 and order 0 to degree and order 720. Makes a map of the radial
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
% TESTED ON: 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 03/19/2020

% The directory with the coefficient data, which must exist
defval('ddir',fullfile(getenv('IFILES'),'EARTHMODELS','POMME-4'))

% Input default values
defval('L',[17 72])
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

% Look at the header, the epoch is
yr=2004;

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
