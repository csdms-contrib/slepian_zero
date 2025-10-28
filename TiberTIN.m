function varargout=TiberTIN
% [Z,C11,CMN,mima,colmap,colrange]=TiberTIN
%
% Tiber Tinitaly topography
%
% OUTPUT
%
% Z          A tiled version of the topography (optional)
% C11        utmx,utmy coordinates of the (1,1) element
% CMN        utmx,utmy coordinates of the (M,N) element
% mima       Minimum/maximum data values      
% colmap     Color map
% colrange   Color range
%
% EXAMPLE:
%
% [Z,C11,CMN,mima,colmap,colrange]=TiberTIN;
% save('TiberTIN','-v7.3','C11','CMN','Z','colmap','colrange','mima')
% load TiberTIN
% imagefnan(C11,CMN,Z,colmap,colrange);
% load TiberHydrobasins.mat % (RINITALY)
% utmstruct=defaultm('utm'); utmstruct.zone='32N'; utmstruct.geoid=wgs84Ellipsoid; utmstruct=defaultm(utmstruct);
% [SXu,SYu]=mfwdtran(utmstruct,SY,SX);
% save TiberHydrobasinsUTM.mat SXu SYu
% hold on; plot(SXu,SYu); hold on
%
% SEE ALSO:
%
% CyprusSRTM, JerseySRTM, RomaSRTM, TiberSRTM
%
% Last modified by fjsimons-at-alum.mit.edu, 10/27/2025

% Get all the headers and the tilings
[hdr,TV,TN,TA,bx,by]=tinitalh;
% Collect them all from the tinitaly_tiles.jpg file
tiling=[7 5];
matched={'w48565','w48570','w48575','w48580',...
         'w48065','w48070','w48075','w48080','w48085',...
         'w47565','w47570','w47575','w47580','w47585',...
         'w47065','w47070','w47075','w47080','w47085',...
         'w46565','w46570','w46575','w46580','w46585',...
                           'w46075','w46080','w46085',...
                                    'w45580','w45585'
         };
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

% Ready to combine them all with the overlap of 10? If all common size...
Zall=nan(dsize*tiling(1)-10*[tiling(1)-1],dsize*tiling(2)-10*[tiling(2)-1]);

clf
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
Zall2=nan(size(XXT));

if ~all(size(Zall)==size(Zall2))
    % Not all sizes were equal, must figure out overlap alternatively
    flag=1; Zall=Zall2; clear Zall2;
else
    flag=0; clear Zall2;
end

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
end

% Plot the final product all at once
clear Z
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
  figdisp
end

% Output if so desired
varns={Zall,C11,CMN,mima,colmap,colrange};
varargout=varns(1:nargout);
