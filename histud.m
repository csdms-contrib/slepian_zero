function histud(X,Y)
% HISTUD(X,Y)
% 
% Compares two populations by making upside-down facing histograms and
% superposing a normal distribution performing a basic goodness-of-fit
% test. Ample annotation and reasonably smart choices for many things.
%
% INPUT:
%
% X,Y   Two vectors
%
% EXAMPLE:
%
% load('17_40_BHT'); Y=X(unique(randi(length(X),1000,1)));
% histud(X,Y);
%
% Last modified by fjsimons-at-alum.mit.edu, 03/01/2023

% Make sure the data are unwrapped
X=X(:);
Y=Y(:);

% Two colors and labels
c={'r','g'};
xlabs={'global','regional'};

% Percentiles for normality calculation
perx={[2.5 97.5],[2.5 97.5]};

% Bw is the bin width 
bw=0.75;
% The nominal bin limit value
bl=12;

% Make figure
clf
ah(1)=subplot(221);
[h(1),p(1),xel(1,:),xl(1)]=...
    plotit(X,c{1},xlabs{1},0,perx{1},bw,bl);

ah(2)=subplot(223);
[h(2),p(2),xel(2,:),xl(2)]=...
    plotit(Y,c{2},xlabs{2},1,perx{2},bw,bl);

% Wholesale moving around
moveh(ah(1:2),0.25)
movev(ah(1:2),-0.075)
shrink(ah(1),0.8,1)
shrink(ah(2),0.8,1)

% X-Cleanup option 1
ah(1).XLim=[min(xel(:,1)) max(xel(:,2))];
ah(2).XLim=[min(xel(:,1)) max(xel(:,2))];
% X-Cleanup option 2
ah(1).XLim=[-1 1]*max(abs([min(xel(:,1)) max(xel(:,2))]));
ah(2).XLim=[-1 1]*max(abs([min(xel(:,1)) max(xel(:,2))]));
% Y-Cleanup
ah(1).YLim=[0 max([ah(1).YLim ah(2).YLim])];
ah(2).YLim=ah(1).YLim;

% Relative moving
ah(1).XAxisLocation='top';
ah(2).YDir='Reverse';
movev(ah(2),getpos(ah(1),2)-getpos(ah(2),2)-getpos(ah(2),4)-0.015)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,p,xel,xl]=plotit(zd,c,xlab,o,percs,bw,bl)
% The actual analysis function
%
% INPUT:
%
% zd     The data
% c      The color
% xlab   The label
% o      0 The upside
%        1 The downside
% percs  Percentiles for trimming
% bw     Bin width
% bl     Nominal bin limit

% Run it a few times and figure out common bin edges but make it
% symmetric around zero for sure, let the central bar be AT zero
% This is how the bin width and limits get turned into symmetricedges
be=[bw/2:bw:bl];
be=sort([-be be]);

% Min and max of the original data set
ma=max(zd);
mi=min(zd);

% Chi-2 goodness of fit test for normality on the whole
[H1,P1,S1]=chi2gof(zd);

% Pre-statistics to see where to trim
xel=prctile(zd,percs);

% Trim the tails according to the percentiles
selx=zd>xel(1) & zd<xel(2);
% How many are left over
nels=sum(selx);
zdx=zd(selx);
% Mean, standard deviation, max, min of what's left over
mas=max(zdx);
mis=min(zdx);
em=mean(zdx);
es= std(zdx);

% This rarely is different
[muh,sh]=normfit(zdx);
diferm(em,muh)
diferm(es,sh)

% Test the test?? this will pass and give you an idea
%% zdx=randn(size(zdx))*es+em;
%% zd=randn(size(zd))*es+em;

% Chi-2 goodness of fit test for normality on what's left over
[H2,P2,S2]=chi2gof(zdx);

% Calculate the histogram using HIST for nbins or HISTC for edges
% ... of the trimmed data? 
% a=histc(zdx,be); 
% ... of all the data
a=histc(zd,be);

% Compute normal with same moments as the trimmed data
% Could show explicitly the limits of what the calculation is based on
% That is kind of nice, if we are showing the whole histogram
xels=linspace(xel(1),xel(2),200);
% Or show the curve for all of the bins that were produced and plotted
%xels=linspace(be(1),be(end),200);
N=normpdf(xels,em,es);
% Normalize to same area
N=N*[be(2)-be(1)];

% Plot the histogram, take care to normalize to what's actually computed
h=bar(be,a/sum(a),'histc');
% Overlay the normal with the same area
hold on
p=plot(xels,N);
pt=plot(xels,N);
% Plot the mean+-stdas a cross above the highest bar
tops=max(a/sum(a))*1.075;
ps=plot(em+[-1 1]*es,[tops tops],'k-');
pm=plot(em,tops,'o',...
	'MarkerFaceColor',c,'MarkerEdgeColor','k');
hold off

xl=xlabel(xlab);

% Figure out where to put the label sequences
% Maybe start shy of the leftmost label
xtx=-bl+bl/5;
% Maybe start at tops?
ytx=tops-[0:0.02:0.10];

if o==1; ytx=fliplr(ytx); end
t(1)=text(xtx,ytx(1),sprintf('%g-%g%%',percs(1),percs(2)));
t(2)=text(xtx,ytx(2),sprintf('N = %i',nels));
t(3)=text(xtx,ytx(3),sprintf('max = %+4.1f',mas));
t(4)=text(xtx,ytx(4),sprintf('min = %+4.1f',mis));
t(5)=text(xtx,ytx(5),sprintf('m = %+4.1f',em));
t(6)=text(xtx,ytx(6),sprintf('s = %+4.1f',es));
%
msg={'normal pass','normal fail'};
tn=text(xtx,ytx(6)+[ytx(2)-ytx(1)],sprintf('%s p = %4.2f',...
					   msg{H2+1},P2));
%
t(7)=text(-xtx+0.5,ytx(1),sprintf('%s','All data '));
t(8)=text(-xtx+0.5,ytx(2),sprintf('N = %i',length(zd)));
t(9)=text(-xtx+0.5,ytx(3),sprintf('max = %+4.1f',ma));
t(10)=text(-xtx+0.5,ytx(4),sprintf('min = %+4.1f',mi));
set(t(7:10),'HorizontalAlignment','right')

% Cosmetics
set([t tn gca],'FontSize',12)
grid on
% Redfine?
xel=[min(be) max(be)];
xlim(xel)
longticks(gca)

set(h,'FaceColor',c,'EdgeColor','k')
set(p,'Color',c,'LineWidth',2)
set(pt,'Color','k','LineWidth',0.5)

