function solareclipse
% SOLARECLIPSE
%
% Last modified by fjsimons-at-alum.mit.edu, 04/09/2024

% Data files
ddir='/data1/fjsimons/CLASSES/FRS-Spain/SensorData/Arable/CronData/';
% Guyot Roof
df1='C003384_Eclipse';
% Herrontown Woods
df2='C013711_Eclipse';
% Data files
ddir2='/data1/fjsimons/CLASSES/FRS-Spain/SensorData/Arable/MetaData/';
df3='led_and_diffuser_kernels_2020_may.csv';
fls=readmatrix(fullfile(ddir2,df3));
for index=1:7
    [m,i]=max(fls(:,index+1));
    mw(index)=fls(i,1);
end

% Read in the data, READMATRIX, CSVREAD, DLMREAD, but TEXTSCAN wins
subplot(211)
pin=7;
[p1,h]=readplot(ddir,df1,pin);
hold on
[p2,h]=readplot(ddir,df2,pin);

ylim([-50 1250])
yticks([0:250:1250])
ylabel(sprintf('%s','solar radiation (W/m2)'))

legs=legend('Guyot Hall Roof','Herrontown Woods','Location','NorthEast',...
           'FontSize',7);

subplot(212)
pin=13:19;
p3=readplot(ddir,df1,pin);
ylabel(sprintf('%s','radiation (W/m2)'))
mwst=sprintf(sprintf('{%s%s}',repmat('''%i nm'',',1,length(mw)-1),'''%i nm'''),mw);
legt=legend(eval(mwst),'Location','NorthEast',...
           'FontSize',7);


% Print the figure
figdisp([],[],[],2)

function [p,h]=readplot(ddir,df,din)
% This will be a function later
fid=fopen(fullfile(ddir,df));
% This was the request made, see arable_schemas_calibrated_reformat
h=fgetl(fid); fl=sum(abs(h)==abs(','))-1;
% Format string corresponding to the above, begins and ends with a string
% and the rests are floats
fms=sprintf('%s%s%s',...
            '%s',repmat('%f',1,fl),'%s');
d=textscan(fid,fms,'Delimiter',',');
% Slightly different than in MARK2MAT due to new format
convt=@(x) char(abs(x(1:end-5))-[zeros(1,10) 52 zeros(1,8)]);
t=datetime(cellfun(convt,d{1},'UniformOutput',0),'TimeZone','UTC');
fclose(fid);

% Set to local time
t.TimeZone='America/New_York';

% Plot sun up/down (from ... Google)
xup=datetime('08-Apr-2024 06:30:00','TimeZone',t.TimeZone);
xnn=datetime('08-Apr-2024 13:00:00','TimeZone',t.TimeZone);
xbe=datetime('08-Apr-2024 14:09:19','TimeZone',t.TimeZone);
xmi=datetime('08-Apr-2024 15:24:35','TimeZone',t.TimeZone);
xnd=datetime('08-Apr-2024 16:35:43','TimeZone',t.TimeZone);
xdn=datetime('08-Apr-2024 19:31:00','TimeZone',t.TimeZone);

% Plot the various variables
for index=1:length(din)
    p(index)=plot(t,d{din(index)});
    hold on
end
%pu=plot([xup xup],ylim,'-');
%pd=plot([xdn xdn],ylim,'-');
hold off
grid on
%xlabel(sprintf('time (%s)',nounder(t.TimeZone)))
xbeg=datetime('08-Apr-2024 05:00:00','TimeZone',t.TimeZone);
xels=[xbeg xbeg+hours(16)];
%xticks([xels(1):hours(2):xels(2)])
xticks([xbeg xup xnn xbe xmi xnd xdn xbeg+hours(16)])
xlim(xels)
datetick('x','HH:MM','keepticks')
longticks(gca,2)

