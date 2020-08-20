function [h,c11,cmn,hh,ybine]=bindens(x,y,nxbins,nybins)
% [h,c11,cmn,hh,ybine]=BINDENS(x,y,nxbins,nybins)
%
% Constructs a two-dimensional histogram
%
% INPUT:
%
% x,y              The data vectors
% nxbins, nybins   The number of bins in the x and y direction
%
% OUTPUT:
%
% h          The '2D' histogram, an auxiliary quantity
% c11,cmn    The centers of the top left and bottom right of this histogram
% hh         Globally normalized histogram, THAT is what you want to plot
% ybine      The y bin edges that are being used
%
% EXAMPLE:
%
% N=1000; x=randn(randi(N),1); y=randn(length(x),1);
% [h,c11,cmn,hh]=bindens(x,y);
% subplot(121); plot(x,y,'.'); axis image; axis([-3.5 3.5 -3.5 3.5])
% subplot(122); imagefnan(c11,cmn,hh,flipud(gray)); axis image; axis([-3.5 3.5 -3.5 3.5])
% hold on; pp=plot(x,y,'w.'); hold off
%
% SEE ALSO:
%
% ROW2STATS, BIN2STATS, (HIST2D)
%
% Last modified by fjsimons-at-alum.mit.edu, 08/20/2020

% Specify defaults
defval('nxbins',10)
defval('nybins',10)
defval('xbin',range(x)/nxbins);
defval('ybin',range(y)/nybins);

% Specify the y-bin edges, that's one more than there are bins
ybine=linspace(min(y),max(y),nybins+1);

% Sort the data in the first column
[x,I]=sort(x,1);

% And have the second column follow
y=y(I);

% Bin the x-data
ix=ceil((x-min(x))/xbin);
ix=ix+(ix==0);

% Also must put in nans for the bins that didn't happen
adix=skip(1:max(ix),unique(ix));
ix=[ix ; adix(:)];
y=[y ; nan(size(adix(:)))]; 

% Now use ROW2STATS to get the y-histograms
[g,s,h,hh]=row2stats(ix,y,ybine);

% Do not do flipud as the histogram treats the bins as one-sided to the
% right but rather find the pixel-centered coordinates of the histogram?
c11(1)=min(x)+xbin/2;
cmn(1)=max(x)-xbin/2;
c11(2)=min(y)+ybin/2;
cmn(2)=max(y)-ybin/2;
