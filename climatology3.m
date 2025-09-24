function climatology3
% Load the data % load('mb_princeton')
load('/data1/fjsimons/IFILES/TOPOGRAPHY/ITALY/METEOBLUE/mat/mb_princeton.mat')

% Beginning and end of the years available
byear=min(year(t));
eyear=max(year(t));
% If it is not a complete year, do not bother
if month(t(end))~=12 ; eyear=eyear-1; end
zyear=byear:eyear;
zyers=length(zyear);

% Number of months in a year, indices, and name strings
zmons=12;
imons=1:zmons;
smons={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

% Define the name of the property of interest
prop='PrecipitationTotal';

% Find the total precipitation PER MONTH throughout the years

% Prepare dimension of what we'll be collecting in a matrix, with one
% row per month per year, and we will list the month and the year
% in the second and third columns
prep=zeros(zyers*zmons,3);

% Loop over the years
for yndex=1:zyers
  % Loop over the months
  for index=imons
    % Track the entries sequentially, for every month and every year
    trax=index+(yndex-1)*zmons;
    % Find the logical condition that picks out the months and the years
    lojik=month(t)==index & year(t)==zyear(yndex);
    % So here are the relevant data: we collect the monthly totals
    % over the relevant range
    prep(trax,1)=sum(d.(prop)(lojik));
    prep(trax,2)=index;
    prep(trax,3)=zyear(yndex);
  end
end

% We are going to cm now!
prep(:,1)=prep(:,1)/10;

% Now we could do some kind of a loop with logic over the months too
% but it is much simpler to use the geometry of the matrix here
preps=reshape(prep(:,1),12,[]);
% The second dimension is where the years are
minm=min(preps,[],2);
menm=mean(preps,2);
medm=median(preps,2);
maxm=max(preps,[],2);

% Straight to the boxplot
ah(1)=subplot(211);
boxplot(prep(:,1),prep(:,2),'outliersize',1)

% Now you annotate nicely
set(ah(1),'XTickLabel',smons)
set(ah,'TickDir','out','TickLength',[0.02 0.025]/2)
% Make sure this is in line with the properties selected above
yl=ylabel('Monthly Precipitation (cm)');
% Use a short form, why not
sprop='Precipitation';
tl=title(sprintf('Princeton Monthly %s %i-%i (METEOBLUE)',...
                sprop,byear,eyear));
% Move stuff around for beautification
set(ah(1),'Position',get(ah(1),'Position')-[0 0.05 0 0])
yls=ylim;
set(tl(1),'Position',get(tl(1),'Position')+[0 range(yls)/10 0])
grid on

% Let's abuse the second plot window to actually print the table
ah(2)=subplot(212);
% Compare with the lines containing the screen-printed table
for index=imons
  tx(zmons-index+1)=text(0.5,zmons-index,...
      sprintf('%3s  %5.1f %5.1f %5.1f %5.1f',...
	      smons{index},minm(index),menm(index),medm(index),maxm(index)));
end
% Use a fixed-width font so you can do a quick visual of the numbers
for index=1:length(tx)
  tx(index).FontName='Courier';
  tx(index).HorizontalAlignment='center';
end
axis tight
ylim([-1 13])
axis off

% Print command to make sure it comes out very nice
set(gcf,'Units','Inches');
pos=get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto',...
        'PaperUnits','Inches','PaperSize',[pos(3) pos(4)])
print('-dpdf','climatology3')


