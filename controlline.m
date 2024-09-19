function controlline(fname,convo)
% CONTROLLINE(fname,convo)
%
% Analysis of control line data from pictures. At the base there is a series of
% *.HEIC images, processed through $UFILES/heic2jpg2gps, into a filename containing
% data of the kind
%    63.8     40  20 53.03    74  39 31.48
%   64     40  20 52.99    74  39 31.59 
%    63.9     40  20 52.76    74  39 32.20 
%
% Last modified by fjsimons-at-alum.mit.edu, 09/18/2024

% Load the file with data
defval('fname','/data1/fjsimons/Dropbox/FRS-Portal/Lab02/Data/controlline2.gps')
CL=load(fname);

% We're North, and West, folks, gotta know that, to parse the data
latsign=+1;
lonsign=-1;

altitude=CL(:,1);

latdeg=CL(:,2);
latmin=CL(:,3);
latsec=CL(:,4);

londeg=CL(:,5);
lonmin=CL(:,6);
lonsec=CL(:,7);

latitude=latsign*[latdeg+latmin/60+latsec/60/60];
longitude=lonsign*[londeg+lonmin/60+lonsec/60/60];

% Convert to UTM coordinates?
defval('convo',0)
if convo==1
    % Misuse of the name that gets fixed later
    [longitude,latitude,utmzone]=deg2utm(latitude,longitude);
    % Use something close to Nassau Hall for offset
    minE=mean(longitude);
    minN=mean(latitude);
    unxy='m';
    xlab=sprintf('easting (%s)',unxy);
    ylab=sprintf('northing (%s)',unxy);
else
    % Don't bother with the offset here
    minE=0;
    minN=0;
    unxy='degree';
    xlab=sprintf('longitude (%s)',unxy);
    ylab=sprintf('latitude (%s)',unxy);
end

% Perform a linear regression for a line
bf1=polyfit(longitude-minE,latitude-minN,1);
bf2=polyfit(latitude-minN,longitude-minE,1);
% Predict at the known points
pv1=polyval(bf1,longitude-minE);
pv2=polyval(bf2,latitude-minN);

clf
% Make a basic "map"
subplot(421)
cl1=plot(longitude-minE,latitude-minN,'o');
xlabel(xlab); ylabel(ylab)
title('measurements and regression 1')
axis image; grid on; box on
yl1=ylim;
% Plot predictions
hold on
p1=plot(longitude-minE,pv1,'b-');
hold off

% Again
subplot(423)
cl2=plot(longitude-minE,latitude-minN,'o');
xlabel(xlab); ylabel(ylab)
title('measurements and regression 2')
axis image; grid on ; box on
yl1=ylim;
% Plot predictions
hold on
p2=plot(pv2,latitude-minN,'r-');
hold off

subplot(222)
% Plot residuals
pr1=plot(pv1-(latitude-minN),'b+');
hold on
pr2=plot(pv2-(longitude-minE),'r+');
hold off
ylim(0+[-1 1]*range(yl1)/5)
grid on
xlabel('measurement index')
ylabel('residuals regression 1 and 2')

subplot(223)
h1=histogram(pv1-(latitude-minN));
h1.FaceColor='b';
xlabel(sprintf('residual 1 (%s)',unxy))
ylabel('frequency')

subplot(224)
h2=histogram(pv2-(longitude-minE));
h2.FaceColor='r';
xlabel(sprintf('residual 1 (%s)',unxy))
ylabel('frequency')

% Titles etc
set([cl1 cl2],'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',4)
set([p1 p2],'LineWidth',1)

% Export to fname_convo
exportfig(gcf,sprintf('%s_%i.eps',pref(fname),convo),'renderer','painters','color','cmyk')
