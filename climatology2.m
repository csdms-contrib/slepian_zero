function climatology2

load('mb_princeton')

% Beginning and end of the years available
byear=min(year(t));
eyear=max(year(t));
zyear=byear:eyear;
zyers=length(zyear);

% Number of months in a year, and indices
zmons=12;
imons=1:zmons;
smons={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

% Define the name of the property of interest
prop='PrecipitationTotal';

% Find the total precipitation per month through the years

% Prepare dimension of what we'll be collecting
% One row per month year, and we list the month and year in the second
% and third column
prep=zeros(zyers*zmons,3);

% Loop over the years
for yndex=1:zyers
  % Loop over the months
  for index=imons
    % Track the entries sequentially
    trax=index+(yndex-1)*zmons;
    % Find the logical condition that picks out the months and the years
    lojik=month(t)==index & year(t)==zyear(yndex);
    % So here are the relevant data: we collect the totals over the
    % relevant range
    prep(trax,1)=sum(d.(prop)(lojik));
    prep(trax,2)=index;
    prep(trax,3)=zyear(yndex);
  end
end

% Maybe you want to just do this for the years? Plot the monthly average
prap=zeros(zyers,2);
for yndex=1:length(zyear)
  % Find the logical condition that picks out the months and the years
  lojik=year(t)==zyear(yndex);
  % So here are the relevant data: we collect the totals over the
  % relevant range
  prap(yndex,1)=sum(d.(prop)(lojik))/zmons;
  prap(yndex,2)=zyear(yndex);
end

% Plot both
clf
p(1)=plot(prep(:,1),'LineWidth',1);
xtix=[1 12:12:trax-1];
set(gca,'xtick',xtix,'xticklabel',zyear)
ylabel('Monthly Precipitation (mm)')
set(gca,'TickDir','out','TickLength',[0.02 0.025]/4)
grid on
hold on

% Some preparation ; double everything
dprap=repmat(prap(:,1),1,2)'; dprap=dprap(:);
dxtix=repmat(xtix(2:end),2,1); dxtix=dxtix(:); 
% Supply end points 
dxtix=[xtix(1) ; dxtix ; trax];
p(2)=plot(dxtix,dprap,'LineWidth',1.5);
% Move that line to the back
uistack(p(1))

tl=title('Princeton Precipitation (METEOBLUE)');

yls=ylim;
set(tl(1),'Position',get(tl(1),'Position')+[0 range(yls)/15 0])

set(gca,'Position',get(gca,'Position')-[0 0 0 0.1]) 

% Print command
set(gcf,'Units','Inches');
pos=get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3) pos(4)])
print('-dpdf','climatology2')
