function distromax(n,m,T,distro,parms)
% distromax(n,m,T,distro,parms)
%
% Plots histograms of sets of n samples of variables of size m, and of their n
% maxima, interpreted as yearly, to which it fits a generalized extreme value
% distribution, from which it calculates the quantity that defines the value at
% the return period 
%
%
% INPUT:
%
% n       Number of sets of samples (one set per 'year')
% m       Number of variables in each sample (however many)
% T       Return period (in 'years')
% distro  Parent distribution (e.g., 'exp')
% parms   Parameters of the parent distribution (e.g., 3)
%
% Last modified by fjsimons-at-alum.mit.edu, 12/06/2024 

% Default values
defval('n',100)
defval('m',200)
defval('T',100)
defval('distro','exp')
defval('parms',3)

% Make the sample sets
switch length(parms)
  case 1
    rv=random(distro,parms(1),n,m);
  case 2
    rv=random(distro,parms(2),n,m);
  case 3
    rv=random(distro,parms(3),n,m);
end

% Whatever the input, the line below is interpreted as an ANNUAL maximum
rm=max(rv,[],2);

% Make the histograms of the variables all together
[a,b]=hist(rv(:),round(1+2*log(n*m)/log(2)));
% Make the histograms of the maxima for the various sets
[c,d]=hist(rm(:),round(1+2*log(n)/log(2)));

% Fit the GEV distribution to to the maxima
[thhat,cint]=gevfit(rm);
% Formulate the prediction
f=linspace(0,thhat(3)+10*thhat(2));
e=gevpdf(f,thhat(1),thhat(2),thhat(3));
% Calculate return period according to Davison (2003), p280 which
% defines the (1-1/T)th quantile as the T-year "return level"
g=gevinv(1-1/T,thhat(1),thhat(2),thhat(3));

% Plot the results
clf

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s(1)=subplot(221);
h(1)=bar(b,a/sum(a)/[b(2)-b(1)],1);
t(1)=title(sprintf('%i sets of %i values',n,m));
movev(t(1),range(ylim)/20)
xl(1)=xlabel('variable');
yl(1)=ylabel('probability density');
grid on
xel=xlim;
yel=ylim;
%yel=[-(yel(2)-yel(1))/20 yel(2)]; ylim(yel)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s(2)=subplot(222);
h(2)=bar(d,c/sum(c)/[d(2)-d(1)],1,'FaceColor','g');
xlim([2*xel(1) xel(2)*2])
ylim(yel)
t(2)=title(sprintf('%i maxima over %i samples',n,m));
movev(t(2),range(ylim)/20)
xl(2)=xlabel(sprintf('yearly maximum over %i sample values',m));
yl(2)=ylabel('probability density');
hold on
x(1)=plot([g g],ylim,'r-');
hold off
l(1)=text(g+range(xlim)/30,range(ylim)/2,...,
          sprintf('exceedance\nobserved %i\nexpected %i\ntimes',...
                  sum(rm>=g),round(length(rm)/T)),...
          'HorizontalAlignment','left');
grid on

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s(3)=subplot(223);
h(3)=semilogy(b,a/sum(a)/[b(2)-b(1)],'^',...
              'MarkerEdgecolor',get(h(1),'EdgeColor'),...
              'MarkerFaceColor',get(h(1),'FaceColor'));
xl(3)=xlabel('variable');
yl(3)=ylabel('probability density');
grid on
xlim(xel)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s(4)=subplot(224);
h(4)=plot(d,c/sum(c)/[d(2)-d(1)],'v',...
          'MarkerEdgecolor',get(h(2),'EdgeColor'),...
          'MarkerFaceColor',get(h(2),'FaceColor'));
xlim([2*xel(1) xel(2)*2])
ylim(yel)
hold on
% Plot the fit
v(1)=plot(f,e,'k-');
% Plot the rain event at the return period
x(2)=plot([g g],ylim,'r-');
hold off
l(2)=text(g+range(xlim)/20,range(ylim)/2,...,
          sprintf('value %3.1f is the \n%i-year event',g,T));
xl(4)=xlabel(sprintf('yearly maximum %s %4.2f  %s %4.2f  %s %4.2f',...
                   '\kappa',thhat(1),'\sigma',thhat(2),'\mu',thhat(3)));
yl(4)=ylabel('probability density');
grid on

% Cleanup
longticks(s)

