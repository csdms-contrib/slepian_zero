function [data,nprops,auxdata]=trimimage(data,nprops,ts,auxdata)
% [data,nprops,auxdata]=TRIMIMAGE(data,nprops,ts,auxdata)
%
% INPUT:
%
% data       A matrix or data cube (with channels in the third dimension)
% nprops     A property structure such as coming out of RAPIDEYE
% ts         The trim style 1 only all-empty rows/columns removed
%                           2 attempt at cropping to best-fitting rectangle
% auxdata    Another same-size matrix that you want trimmed identically
%            even though its values are not being considered, i.e. zero
%            or not, such as for a topography data set that comes with
%            RAPIDEYE satellite data, as in MOSAIC
% 
% OUTPUT:
%
% data      The input with the rims and trims removed
% nprops    A property structure that has been amended and completed
%
% Last modified by fjsimons-at-alum.mit.edu, 10/03/2019

% Default is trimming which needs rimming
defval('ts',2)
defval('auxdata',[])

% Find the original grid
[XE,YE]=rapideyg(nprops);

% RIMMING: REMOVAL OF ALL-EMPTY ZERO OUTER COLUMNS AND ROWS
emptycols=sum(sum(data,3)==0,1)==size(data,1);
emptyrows=sum(sum(data,3)==0,2)==size(data,2);

% Assuming that they are AT the edges (no interior removal; not sure if or
% when THAT would be caught down the line)
if sum(emptycols) || sum(emptyrows)
  disp(sprintf('Empty-border trimming'))
  XE=XE(~emptyrows,~emptycols);
  YE=YE(~emptyrows,~emptycols);
  data=data(~emptyrows,~emptycols,:);
  % If there is a paired data set, rim that as well
  if ~isempty(auxdata)
    auxdata=auxdata(~emptyrows,~emptycols,:);
  end
end

% TRIMMING: REMOVAL OF ANY-EMPTY ZERO OUTER COLUMNS AND ROWS TO GET THE
% INSCRIBED RECTANGLE
if ts==2
  % The mask, as we define, it HAS data
  mask=sum(data,3)~=0;
  % BEGIN IMAGE TRIMMING
  if prod(size(mask))~=size(data(:,:,1))
    disp(sprintf('  Any-border trimming'))
    % Collect coordinates
    mark=reshape(1:prod(size(mask)),size(mask));
    % Now we find the (largest?) rectangle that fits inside the mask
    % MASK2RECT; go around the corner, see if it works
    mark=mark(:,  min(find(mask(1,:  ))):end);
    mask=mask(:,  min(find(mask(1,:  ))):end);
    mark=mark(    min(find(mask(:,end))):end,:);
    mask=mask(    min(find(mask(:,end))):end,:);
    mark=mark(  1:max(find(mask(:,1  ))),:);
    mask=mask(  1:max(find(mask(:,1  ))),:);
    mark=mark(:,1:max(find(mask(end,:))));
    mask=mask(:,1:max(find(mask(end,:))));
    % Maybe do this again if it still has NaNs? Maybe rotate the image??
    % All permutations? This works for enotre, but need to inspect
    trimdata=zeros(size(mask),class(data));
    for ondex=1:size(data,3)
      odata=data(:,:,ondex);
      trimdata(:,:,ondex)=reshape(odata(mark),size(mask));
    end
    data=trimdata;
    XE=reshape(XE(mark),size(mask));
    YE=reshape(YE(mark),size(mask));
    % If there is a paired data set, rim that as well
    if ~isempty(auxdata)
      auxdata=reshape(auxdata(mark),size(mask));
    end
  end
  % END IMAGE TRIMMING
end

% Now adjust the metadata, check against RAPIDEYE and RAPIDEYG 
nprops.nr=size(data,1);
nprops.nc=size(data,2);
nprops.xs=XE(1)-nprops.sp/2;
nprops.ys=YE(1)+nprops.sp/2;
nprops.C11=[XE(1)   YE(1)];
nprops.CMN=[XE(end) YE(end)];
nprops.xx=XE([1 end]); 
nprops.yy=YE([1 end]);
% This for brevity 
[~,~,~,xeye,yeye]=rapideyg(nprops,1);
% This of course is the same, I use it below
diferm(xeye([1 end])-nprops.xx)
diferm(yeye([1 end])-nprops.yy')
nprops.xeye=xeye;
nprops.yeye=yeye;
% No need to convert the polygonal information as well (lo,la,xp,yp)
% which remains an outer bounding box for usable data. If it was there
