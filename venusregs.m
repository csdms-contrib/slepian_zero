function varargout=venusregs(id,ifplot,lolav,fax,fillco)
% [lola,p,lolav]=VENUSREGS(id,ifplot,lolav,fax,fillco)
%
% Plots Venus regions data
%
% INPUT:
%
% id       A region id number
% ifplot   1 Makes simple two-dimensional lon/lat plot
%          2 Makes three-dimensional hemisphere lon/lat plot
%          3 Makes three-dimensional full-sphere lon/lat plot
%          4 Make a two-dimensional filled color patch plot
% lolav    The location of the viewing platform
% fax      Axis scaling
% fillco   The fill color
%
% OUTPUT:
%
% lola     Longitudes and latitudes of the region in question
% p        The handle to the plot object(s), to be reviewed
% lolav    Longitudes and latitudes of the viewing platform
%
% SEE ALSO:
%
% VENUSTATS, LORIS1
%
% EXAMPLE:
%
% for index=1:77; venusregs(index,1); hold on; end; axis([0 360 -90 90])
%
% Last modified by fjsimons-at-alum.mit.edu, 07/02/2026

defval('id',ceil(rand*77))
defval('ifplot',round(rand))
defval('p',NaN)
defval('fax',1)
defval('fillco',rand(1,3))
defval('dlev',30)

% This is a very small piece of LOADITMAKEIT within VENUSTATS... there is more
load('/data1/fjsimons/IFILES/VENUS/DATA/plmData/plmVenus_D-5.mat',...
         sprintf('V%4.4i_03',id))

% Get the regional bounding curve in global coordinates
lola=eval(sprintf('V%4.4i_03.geo.XY360',id));
% Get the regional bounding curve in global coordinates
defval('lolav',eval(sprintf('V%4.4i_03.geo.center360',id)))

switch ifplot
  case 1
    p=twoplot(kindeks(penlift([lola zeros(size(lola,1),1)],dlev),1:2));
  case 4
    lola=kindeks(penlift([lola zeros(size(lola,1),1)],dlev),1:2);
    % If straddling the 0 line, it needs to be become two patches
    rnan=find(isnan(lola(:,1)));
    if ~isempty(rnan)
        if id==58
            % Polar patch requires special treatment
            lola(rnan,1)=360;
            lola(rnan,2)=90;
            a=insert(lola(:,1),0,rnan)';
            b=insert(lola(:,2),90,rnan)';
            lola=[a b];
            p=fill(lola(:,1),lola(:,2),fillco);
        elseif id==49
            
        else
            % Could use SKIP and PAULIMAT or othewise one-line this maybe
            if length(rnan)==1
                news=reshape([1  indeks([rnan-1 rnan+1],'1:end') size(lola,1)],2,[])';
            else
                news=reshape([1  indeks([rnan-1 rnan+1]','1:end') size(lola,1)],2,[])';
            end
            for index=1:size(news,1)
                renj=news(index,1):news(index,2);
                p(index)=fill(lola(renj,1),lola(renj,2),fillco);
                hold on
            end
            hold off
        end
    else
        p=fill(lola(:,1),lola(:,2),fillco);
    end
  case {2,3}
    % Set view angles ahead of time as an explicit longitude and latitude
    [xv,yv,zv]=sph2cart(lolav(1)*pi/180,lolav(2)*pi/180,1);
    % Now prepare to plot the actual data
    [xr,yr,zr]=sph2cart(lola(:,1)*pi/180,lola(:,2)*pi/180,1);
    if ifplot==2
        % Plot only the visible semiglobe - look over the limb? - join with "equator"?
        yes=[xv yv zv]*[xr yr zr]'>0;
        xr=xr(yes); yr=yr(yes); zr=zr(yes);
    end
    % This protection from jumps is straight from PLOTCONT
    defval('necessary',1)
    if necessary
        d=sqrt((xr(2:end)-xr(1:end-1)).^2+...
               (yr(2:end)-yr(1:end-1)).^2+...
               (zr(2:end)-zr(1:end-1)).^2);
        % Somehow with Venus boundaries the dlev needs to be pretty high!
        pp=find(d>dlev*nanmedian(d));
        xr=insert(xr,NaN,pp+1); yr=insert(yr,NaN,pp+1); zr=insert(zr,NaN,pp+1);
    end
    % And then finally do it
    skl=0.99;
    % The next line could have been empty and then don't get to toggle hold
    p=plot3(xr(:)*skl,yr(:)*skl,zr(:)*skl,'k-');
    if ~isempty(p)
        hold on
    end
    % And now plot an entire equatorial circle also
    [xe,ye,ze]=sph2cart(linspace(0,2*pi,100),0,1);
    xyze=[rotz(-lolav(1)*pi/180)*roty(-[90-lolav(2)]*pi/180)*[xe ; ye ; repmat(ze,1,length(ye))]]';
    peq=plot3(xyze(:,1),xyze(:,2),xyze(:,3),'k');
    if isempty(p)
        hold on
    end
    % Now set (and verify the syntax) of the view 
    view([xv,yv,zv]); [AZ,EL]=view;
    disp(sprintf('Azimuth: %i ; Elevation: %i',round(AZ),round(EL)))
    pnp=plot3(xv,yv,zv,'MarkerF','k','MarkerE','k','Marker','o');
    hold off
    % Cosmetics
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
varns={lola,p,lolav};
varargout=varns(1:nargout);
