function varargout=RegioTIN(region,xver)
% [Z,C11,CMN,mima,colmap,colrange]=RegioTIN(region,xver)
%
% Extracts regional Tinitaly topography
%
% INPUT:
%
% region       'Abruzzo' 'Friuli-VeneziaGiulia' 'Molise' 'Apulia' 'Lazio'
%              'Piemonte' 'Basilicata' 'Liguria' 'Calabria' 'Lombardia'
%              'Toscana' 'Campania' 'Umbria' 'Emilia-Romagna' 'Marche'
%              'Veneto' 'Tiber'
% xver         1 makes the final plot or 0 doesn't
%
% OUTPUT:
%
% Z          A tiled version of the topography (optional)
% C11        utmx,utmy coordinates of the (1,1) element
% CMN        utmx,utmy coordinates of the (M,N) element
% mima       Minimum/maximum data values      
% colmap     Color map
% colrange   Color range
% adminXu    Administrative boundaries in UTM coordinates
% adminYu    Administrative boundaries in UTM coordinates
%
% EXAMPLE:
%
% [Z,C11,CMN,mima,colmap,colrange,adminXu,adminYu]=RegioTIN;
% save('RegioTIN','-v7.3','C11','CMN','Z','colmap','colrange','mima','adminXu','adminYu')
% load RegioTIN
% imagefnan(C11,CMN,Z,colmap,colrange)
%
% SEE ALSO:
%
% CyprusSRTM, JerseySRTM, RomaSRTM, TiberSRTM, TiberTIN
%
% Last modified by fjsimons-at-alum.mit.edu, 10/28/2025

% Default values
defval('region','Basilicata')
defval('xver',0)

% Could begin by plotting WORLD map and loading coordinates...
% plotcont; axis image; xlim([5 20]); ylim([35 50]); grid on; box on
% Then load the named region...
load(region)
% ...and could begin by plotting its coordinates on top...
% hold on; p=plot(adminLO,adminLA); hold off

% Rather get UTM headers and the tilings and (don't) plot that...
figure(1)
clf
[hdr,TV,TN,TA,bx,by,tt,tl]=tinitalh([],[],2);

% Convert the administrative boundaries to the Tinitaly UTM...
[adminXu,adminYu]=mfw(adminLO,adminLA);
hold on; pxy=plot(adminXu,adminYu); hold off; axis image
axis([minmax(adminXu) minmax(adminYu)]+[[-1 1]*range(adminXu)/5 [-1 1]*range(adminYu)/5])

% Try to find a match for the named region and plot the administrative
% boundaries on top of it to make sure that you have properly received it
% Find any and all the box corners that are inside the named region
boxes=find(any(inpolygon(bx,by,adminXu,adminYu),2));

figure(2); clf
% Plot the named boxes -  inside the SWITCH might want to redo it 
[pb,tt]=pbx(boxes,hdr,TV);
% Now do plot those administrative boundaries on top
pa=plot(adminXu,adminYu); hold off; axis image

% Collect them all from the tinitaly_tiles.jpg file
switch region
  case 'Abruzzo'
    % Find the extra boxes
    boxes=[boxes ; 115];
  case 'Friuli-VeneziaGiulia'

  case 'Molise'
    % Find the extra boxes
    boxes=[boxes ; 84 ; 85 ; 90 ; 99];
  case 'Apulia'
    % No extra boxes
  case 'Lazio'
    % No extra boxes
  case 'Piemonte'
keyboard
  case 'Basilicata'
    % Find the extra boxes
    boxes=[boxes ; 70 ; 12 ; 13];
  case 'Liguria'

  case 'Calabria'
    % No extra boxes
  case 'Lombardia'
    % Find the extra boxes
    boxes=[boxes ; 176 ; 137];
  case 'Toscana'
    % Find the extra boxes
    boxes=[boxes ; 101 ; 131];
  case 'Campania'
    % No extra boxes
  case 'Umbria'
    % Find the extra boxes
    boxes=[boxes ; 119 ; 96];
  case 'Emilia-Romagna'

  case 'Marche'
    % No extra boxes
  case 'Veneto'
    % Find the extra boxes
    boxes=[boxes ; 173];
end
switch region
  case 'Tiber'
    matched={'w48565','w48570','w48575','w48580',...
             'w48065','w48070','w48075','w48080','w48085',...
             'w47565','w47570','w47575','w47580','w47585',...
             'w47065','w47070','w47075','w47080','w47085',...
             'w46565','w46570','w46575','w46580','w46585',...
             'w46075','w46080','w46085',...
             'w45580','w45585'
            };
  otherwise
    matched=hdr(boxes);
end

% Resolution in decimal degrees, this you get from the data but is NOT standard
dsize=5010;

% You modify this also, it sets the viewable axes later
zaxis=[];

% You change this also, it sets the range of values being colored
colrange=[0 1500];

try 
  [colmap,dax,ziro]=sergeicol;
  colmap=colmap(ziro+1:end,:);
catch
  colmap=jet;
end

% Initialize
mima=[0 0];
C11=[ inf -inf];
CMN=[-inf  inf];
% Loop over the named matches
for index=1:length(matched)
    % Find the corresponding index in the hdr cell array 
    matches(index)=find(cellfun('isempty',strfind(hdr,matched{index}))-1);
    % And then extract the grid and not the data yet
    [XT,YT,ZT,Z]=tinitalg(hdr,TV,matches(index));
    % Coordinates of the NW and SE corner of the map
    c11=[XT(1)   YT(1)  ];
    cmn=[XT(end) YT(end)];
    % Evolving sense of dimension
    C11=[min(C11(1),c11(1)) max(C11(2),c11(2))];
    CMN=[max(CMN(1),cmn(1)) min(CMN(2),cmn(2))];
    % Evolving sense of scale
    mima=minmax([minmax(Z(:)') mima]);
    % Don't plot here as that simply will work without revealing whether the
    % overlap was subccessfully dealt with in the output
end

% The grid spacing, by the way, you alreay know this is 10 m resolution
dX=XT(1,2)-XT(1,1);
dY=YT(1,1)-YT(2,1);
% Make the massive grid
[XXT,YYT]=meshgrid(C11(1):dX:CMN(1),[C11(2):-dY:CMN(2)]');
% You'll take whatever you end up with
Zall=nan(size(XXT));

% Split the loops to assemble the big data set
for index=1:length(matched)
    % And then extract the grid and the data... again
    [XT,YT,ZT,Z]=tinitalg(hdr,TV,matches(index));
    % Find the elements that fit in the big matrix
    if flag==0
        % Tile these things together with the overlap
        ro=ceil(index/tiling(2));
        co=mod(index-1,tiling(2))+1;
        Zall(1+[ro-1]*[dsize-10]:dsize+[ro-1]*[dsize-10],...
             1+[co-1]*[dsize-10]:dsize+[co-1]*[dsize-10])=Z;
    else
        % Need to find the indices into XXT and YYT of XT and YT but need to
        % only work on the linear arrays as the meshgrid is redundant
        [~,IA]=intersect(YYT(:,1),YT(:,1),'stable');
        [~,JA]=intersect(XXT(1,:),XT(1,:),'stable');
        % Assign, and if there was overlap, that means, possibly reassign
        Zall(IA,JA)=Z;
    end
    clear Z
end

% Rapidly runs out of memory and leads to crashes
if xver==1
    figure(3)
    clf
    % Out of memory for this one on lemaitre
    % h=imagefnan(C11,CMN,Zall,colmap,colrange);
    % This should work instead
    h=imagesc([C11(1) CMN(1)],[C11(2) CMN(2)],Zall); axis image xy
    colmap(1,:)=[1 1 1];
    colormap(colmap)
    caxis(colrange)
    
    % Clean up if you can
    if exist('h')==1
        %  axis(zaxis)
        longticks(gca,2)
        
        fig2print(gcf,'portrait')
        % Add a custom color bar
        try
            % This was for IMAGEFNAN
            % [cb,xcb]=addcb('vert',colrange,colrange,colmap);
            % This will do for IMAGE
            cb=colorbar; xcb=cb.Label.String;
            longticks(cb,2)
            set(xcb,'string','topography (m) above WGS84/EGM96 geoid')
            moveh(cb,0.075)
            set(cb,'YaxisL','r')
        end
        % Add the administrative boundaries again
        hold on; pxyz=plot(adminXu,adminYu); hold off; axis image
        pxyz.LineWidth=3;
        figdisp
    end
end

% Output if so desired
varns={Zall,C11,CMN,mima,colmap,colrange,adminXu,adminYu};
varargout=varns(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pb,tt]=pbx(boxes,hdr,TV)
% Use the TINITALH header and information to plot labeled boxes
for bindex=1:length(boxes)
    % Extract the index...
    index=boxes(bindex);
    % ...o you can borrow this from TINITALH...
    nc=TV{index}(1); nr=TV{index}(2);
    xl=TV{index}(3); yl=TV{index}(4);
    sp=TV{index}(5);
    bbx=double([xl xl xl xl xl]+[0 0      nc*sp nc*sp 0]);
    bby=double([yl yl yl yl yl]+[0 nr*sp  nr*sp 0     0]);
    hold on
    pb(index)=plot(bbx,bby);
    tt(index)=text(bbx(1)+[bbx(3)-bbx(1)]/2,...
		   bby(1)+[bby(2)-bby(1)]/2,...
		   sprintf('%i %s',index,pref(pref(hdr{index}),'_')));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y]=mfw(lon,lat)
% Figure out later how to use PROJFWD instead
utmstruct=defaultm('utm');
% This is given by TINITALY itself
utmstruct.zone='32N';
utmstruct.geoid=wgs84Ellipsoid; utmstruct=defaultm(utmstruct);
warning('off','map:removing:mfwdtran')
% Result is UTM coordinates for the longitude and latitude input
[X,Y]=mfwdtran(utmstruct,lat,lon);
warning('on','map:removing:mfwdtran')
