% This is a SCRIPT so let us start from no variables and no figure
clear
clf
% Load the data load('mb_princeton.mat')
load('/data1/fjsimons/IFILES/TOPOGRAPHY/ITALY/METEOBLUE/mat/mb_princeton.mat')

% TRY THIS: Make a plot of all available temperatures
% plot(t,d.Temperature_2melevationcorrected);

% What are the first and the last years available?
byear=min(year(t));
eyear=max(year(t));

% TRY THIS: Make a plot of temperature in 2021
% plot(t(year(t)==2021),d.Temperature_2melevationcorrected(year(t)==2021));

% TRY THIS: Play with more conditions... say, daytime and nighttime
% dayt=hour(t)>=6  & hour(t)<18;
% nigt=hour(t)>=18 | hour(t)<6;
% Make a grown-up logic condition
% plot(t(year(t)==2021 & dayt),...
%      d.Temperature_2melevationcorrected(year(t)==2021 & dayt));

% NOW LET US DO SOMETHING FOR REAL
% Tired of typing, just rename the one property of interest 'prop'
% and then do make sure to get the labels right down below!
prop='Temperature_2melevationcorrected';
% We will make a plot of the min, max, mean, median 'prop' per month
% So we will do some housekeeping
% Number of months in a year
zmons=12;
% Indices that will serve for cycling through the year
imons=1:zmons;
% A cell array with name strings, one for each month of the year
smons={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

% Initialize the arrays with nans so that we can fill the later
[minm,menm,medm,maxm]=deal(nan(1,zmons));

% SKIP Remember C=(F-32)/1.8;... make an anonymous function
% convr=@(x) (x-32)/1.8;

% Loop over the months
for index=imons
  % Find the logical condition that picks out the months
  lojik=month(t)==index;
  % Apply the condition to all the data at once, now you have generic 'values'
  vals=d.(prop)(lojik);
  % SKIP Since we actually did get the data in Celsius already
  % if strfind(prop,'Temperature'); vals=convr(vals); end
  % Define the various 'statistics' of the 'values' of the 'property'
  minm(index)=min(vals);
  menm(index)=mean(vals);
  medm(index)=median(vals);
  maxm(index)=max(vals);
end

% Make a nice table at the prompt
for index=imons
  disp(sprintf('%2i %5.1f %5.1f %5.1f %5.1f',...
	  index,minm(index),menm(index),medm(index),maxm(index)))
end

% Now you could plot all sorts of things as curves etc
% but we will rather make a 'box plot' in one go.
% Define an axeis handle so you can later manipulate it
ah(1)=subplot(211);
% SKIP the temperature conversion since it wasn't needed
% if strfind(prop,'Temperature')
%   boxplot(convr(d.(prop)),month(t),'outliersize',1)
% else
boxplot(d.(prop),month(t),'outliersize',1)
% end

% Now you annotate nicely
set(ah(1),'XTickLabel',smons)
set(ah,'TickDir','out','TickLength',[0.02 0.025]/2)
% Make sure this is in line with the property selected above
yl=ylabel(sprintf('Hourly Temperature (%sC)',176));
tl=title(sprintf('Princeton Hourly Temperature %i-%i (METEOBLUE)',...
                byear,eyear));
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
print('-dpdf','climatology1')
