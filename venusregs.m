function varargout=venusregs(id,ifplot,lolav,fax)
% [lola,p]=VENUSREGS(id,ifplot,lolav,fax)
%
% Plots Venus regions data
%
% INPUT:
%
% id       A region id number
% ifplot   1 Makes simple two-dimensional lon/lat plot
%          2 Makes three-dimensional hemisphere lon/lat plot
%          3 Makes three-dimensional full-sphere lon/lat plot
% lolav    The location of the viewing platform
% fax      Axis scaling
%
% OUTPUT:
%
% lola     Longitudes and latitudes of the region in question
%
% SEE ALSO:
%
% VENUSTATS, LORIS1
%
% Last modified by fjsimons-at-alum.mit.edu, 07/02/2026

defval('id',ceil(rand*77))
defval('ifplot',round(rand))
defval('p',NaN)
defval('fax',1)

% This is a very small piece of LOADITMAKEIT within VENUSTATS... there is more
load('/data1/fjsimons/IFILES/VENUS/DATA/plmData/plmVenus_D-5.mat',...
         sprintf('V%4.4i_03',id))

% Get the regional bounding curve in global coordinates
lola=eval(sprintf('V%4.4i_03.geo.XY360',id));
% Get the regional bounding curve in global coordinates
defval('lolav',eval(sprintf('V%4.4i_03.geo.center360',id)))

switch ifplot
  case 1
    twoplot(lola)
  case 2
    % Set view angles ahead of time as an explicit longitude and latitude
    [xv,yv,zv]=sph2cart(lolav(:,1)*pi/180,lolav(:,2)*pi/180,1);
    % Now prepare to plot the actual data
    [xr,yr,zr]=sph2cart(lola(:,1)*pi/180,lola(:,2)*pi/180,1);
    XYZ=[xr yr zr];
    
    % Plot only the visible semiglobe
    yes=[xv yv zv]*XYZ'>0; XYZ=XYZ(yes,1:3);
    % This protection from jumps is straight from PLOTCONT
    defval('necessary',1)
    if necessary
        d=sqrt((xr(2:end)-xr(1:end-1)).^2+...
               (yr(2:end)-yr(1:end-1)).^2+...
               (zr(2:end)-zr(1:end-1)).^2);
        % Somehow with Venus boundaries the dlev needs to be pretty high!
        dlev=30; pp=find(d>dlev*nanmedian(d));
        xr=insert(xr,NaN,pp+1); yr=insert(yr,NaN,pp+1); zr=insert(zr,NaN,pp+1);
    end
    % And then finally do it
    skl=0.99;
    pc=plot3(xr(:)*skl,yr(:)*skl,zr(:)*skl,'k-');
    hold on
    % And now plot an entire equatorial circle also
    [xe,ye,ze]=sph2cart(linspace(0,2*pi,100),0,1);
    xyze=[rotz(-lolav(1)*pi/180)*roty(-[90-lolav(2)]*pi/180)*[xe ; ye ; repmat(ze,1,length(ye))]]';
    peq=plot3(xyze(:,1),xyze(:,2),xyze(:,3),'k');
    hold off
    % Now set (and verify the syntax) of the view 
    view([xv,yv,zv]); [AZ,EL]=view;
    disp(sprintf('Azimuth: %i ; Elevation: %i',round(AZ),round(EL)))
    axis equal; axis([-1 1 -1 1 -1 1]*fax);
    xl=xlabel('x'); yl=ylabel('y'); zl=zlabel('z');
    set(gca,'xtick',[-fax 0 fax],'ytick',[-fax 0 fax],'ztick',[-fax 0 fax])
    moveh(xl,-0.55); movev(xl,0.15)
    moveh(yl,-0.2); movev(yl,0.2)
    moveh(zl,-0.1); movev(zl,0.1)
    axis off
    t=title(sprintf('V%4.4i',id));
end

% Optional output
varns={lola,p};
varargout=varns(1:nargout);
