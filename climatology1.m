clear
load('mb_princeton')

% Make a plot of all temperature
%plot(t,d.Temperature_2melevationcorrected);

% Make a plot of temperature in 2019
%plot(t(year(t)==2019),d.Temperature_2melevationcorrected(year(t)==2019));

% Beginning and end of the years available
%byear=min(year(t));
%eyear=max(year(t));

% Number of months in a year, and indices
zmons=12;
imons=1:zmons;
smons={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

% Make a plot of min, max, mean, median temperature per month
%[minm,menm,medm,maxm]=deal(zeros(1,zmons));

% Define the name of the property of interest
prop='Temperature_2melevationcorrected';

% Remember C=(F-32)/1.8;... make an anonymous function
convr=@(x) (x-32)/1.8;

% Could play with conditions...
dayt=hour(t)>=6  & hour(t)<18;
nigt=hour(t)>=18 | hour(t)<6;

% Loop over the months
for index=imons
  % Find the logical condition that picks out the months
  lojik=month(t)==index;
  % Apply the condition to all the data at once
  vals=d.(prop)(lojik);
  if strfind(prop,'Temperature')
    vals=convr(vals);
  end
  % Define the values
  minm(index)=min(vals);
  menm(index)=mean(vals);
  medm(index)=median(vals);
  maxm(index)=max(vals);
end

% Now you could plot all sorts of things as curves etc

% Or make a nice table
for index=imons
  disp(sprintf('%2i %5.1f %5.1f %5.1f %5.1f',...
	  index,minm(index),menm(index),medm(index),maxm(index)))
end

clf
% But rather make a boxplot in one go
ah(1)=subplot(211);
if strfind(prop,'Temperature')
  boxplot(convr(d.(prop)),month(t),'outliersize',1)
else
  boxplot(d.(prop),month(t))
end
set(ah(1),'XTickLabel',smons)
set(ah,'TickDir','out','TickLength',[0.02 0.025]/2)
ylabel(sprintf('Temperature (%sC)',176))
tl=title('Princeton Temperature (METEOBLUE)');
% Move stuff around for beauty
set(ah(1),'Position',get(ah(1),'Position')-[0 0.05 0 0])
yls=ylim;
set(tl(1),'Position',get(tl(1),'Position')+[0 range(yls)/10 0])
grid on

ah(2)=subplot(212);
%tx(zmons+1)=text(0.5,zmons,'MM   MIN  MEAN MEDIAN  MAX'); hold on
tx(zmons+1)=text(0.5,zmons,'MON    MIN  MEAN MEDIAN  MAX'); hold on
for index=imons
  tx(zmons-index+1)=text(0.5,zmons-index,...
      sprintf('%3s  %5.1f %5.1f %5.1f %5.1f',...
	      smons{index},minm(index),menm(index),medm(index),maxm(index)));
%      sprintf('%2i %5.1f %5.1f %5.1f %5.1f',...
%	      index,minm(index),menm(index),medm(index),maxm(index)));
end
for index=1:length(tx)
  tx(index).FontName='Courier';
  tx(index).HorizontalAlignment='center';
end
axis tight
ylim([-1 13])
%xlim([0.3 0.7])
%box on
axis off
hold off

% Print command
set(gcf,'Units','Inches');
pos=get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)])
print('-dpdf','climatology1')
