function climatology2
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

% Maybe you want to just do this for the years? No more monthly breakdown
prap=zeros(zyers,2);
% Loop over the years
for yndex=1:zyers
  % Find the logical condition that picks out the months and the years
  lojik=year(t)==zyear(yndex);
  % So here are the relevant data: we collect the yearly average monthly total
  % over the relevant range
  prap(yndex,1)=sum(d.(prop)(lojik))/zmons;
  prap(yndex,2)=zyear(yndex);
end

% You can see this is the same thing! so you could have save the trouble
% sum(mean(reshape(prep(:,1),12,[]),1)-prap(:,1)')
% Think about "average monthly total" - average over months, each year?
% Think about "average monthly total" - average over years, each month?

% Plot both the monthly total for every month and every year
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
% And then plot the yearly resolved average monthly total 
p(2)=plot(dxtix,dprap,'LineWidth',1.5);
hold off
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
