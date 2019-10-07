function varargout=mosaic(froot,dirp,diro,xver,urld,clip)
% [RDC,nprops,props,TDC]=MOSAIC(froot,dirp,diro,xver,urld,clip)
%
% Loads and mosaics RAPIDEYE satellite images together by clipping, not
% merging, regions of identified geographical overlap and with identifcal
% projections. Choices are made that might make merging rather than clipping
% preferable...
%
% INPUT:
%
% froot      Cell with filename roots [e.g. {'3260220_2019-07-01_RE1_3A'
%                                            '3260221_2019-07-01_RE1_3A'
%                                            '3260320_2019-07-01_RE1_3A'
%                                            '3260321_2019-07-01_RE1_3A'}
% dirp       Cell with directories [e.g. {'oliocru/20190701_095103_3260220_RapidEye-1'
%                                         'oliocru/20190701_095103_3260221_RapidEye-1' 
%                                         'oliocru/20190701_095100_3260320_RapidEye-1'
%                                         'oliocru/20190701_095059_3260321_RapidEye-1'}
% diro       Directory [e.g. '/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE']
% xver       1 Provides excessive verification [default]
%            0 Does not provide excessive verification
%            2 Provides a graphical test for the very beginning  
% urld       A URL a directory with a copy of the JSON file for
%            when a direct read and parsing using JSONDECODE fails
%            [e.g. 'http://geoweb.princeton.edu/people/simons/JSON']
% clip       '_clip' files come with the '_clip' extension (all or none)
%            [] no further extension extension at all [default]
%
% OUTPUT:
%
% RDC        The RAPIDEYE data post-merger
% nprops     A minimal properties structure with metadata for the mosaicked image
% props      A cell with the original complete properties structure
% TDC        The TINITALY data that correspond with them (if you want them)
%
% EXAMPLE:
%
% dirp=ls2cell('ceraudo/*RapidEye*',1); 
% for index=1:length(dirp)
%   prot=pref(ls2cell(sprintf('%s/*Analytic_clip.tif',dirp{index})),'A');
%   froot{index}=sprintf('%sA',[prot{:}]); 
% end
% [RDC,TDC,nprops]=mosaic(froot(1:2),dirp(1:2),[],2);
% figure(4); clf; imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],rapideya(RDC)); axis xy
% figure(5); clf; imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],TDC); axis xy
%
% Tested on 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 10/07/2019

% Root of the filename for three of the four files inside the directory
defval('froot',{'3260220_2019-07-01_RE1_3A' '3260221_2019-07-01_RE1_3A' ...
                '3260320_2019-07-01_RE1_3A' '3260321_2019-07-01_RE1_3A'})

% Bottom-level directory name, taken from the Rapideye download
defval('dirp',{'oliocru/20190701_095103_3260220_RapidEye-1'
               'oliocru/20190701_095103_3260221_RapidEye-1' 
               'oliocru/20190701_095100_3260320_RapidEye-1'
               'oliocru/20190701_095059_3260321_RapidEye-1'});

% Top-level directory name, where you keep the Rapideye directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/RAPIDEYE')
% I advocate checking grid parameters and file sizes for ever
defval('xver',2)
% Remote directory where I copied the JSON file from DIRP so as to use
% WEBREAD, noting that the JSON filename derives from DIRP, see
% below, and note that JSONDECODE may work, in which case this is moot
defval('urld','http://geoweb.princeton.edu/people/simons/JSON')
% Root of the filename for three of the four files inside the directory
defval('clip','_clip')

% Load the images, should perhaps make a hash with these as well
for index=1:length(froot)
  % Don't want the graphic test from RAPIDEYE 
  [RD{index},nprops{index},props{index}]=rapideye(froot{index},dirp{index},[],min(xver,1),[],clip);
  if nargout>3
    % Don't worry about making the picture from TINITALY
    TDF{index}=tinitaly(nprops{index},[],[],min(xver,1),RD{index});
  else
    TDF{index}=NaN;
  end

  % Trim the all-zero edges to get no interior seams
  % Don't reset the original image properties, only the essential propagated
  % properties, i.e. nprops and not props, and see below
  if nargout>3
    [RD{index},nprops{index},TDF{index}]=trimimage(RD{index},nprops{index},1,TDF{index});
  else
    [RD{index},nprops{index}]=trimimage(RD{index},nprops{index},1);
  end
  % Make the final grids
  [XE{index},YE{index},ZE{index}]=rapideyg(nprops{index});
end

% Do the rivers at the end
if xver==2
  % Plot the RAPIDEYE grid outlines
  figure(1); clf
  for index=1:length(froot)
    pri(index)=plot(XE{index}([1 end end 1 1]),YE{index}([1 1 end end 1]));
    hold on
  end
  hold off
  
  % Plot the RAPIDEYE data panels
  figure(2); clf
  ah=krijetem(subnum(2,2));
  % Reordering based on prior knowledge is really impossible until after PUZZLE
  for index=1:length(froot)
    axes(ah(index))
    imagesc([nprops{index}.C11(1) nprops{index}.CMN(1)],...
	    [nprops{index}.C11(2) nprops{index}.CMN(2)],...
	    rapideya(RD{index})); axis xy image
    longticks(ah)
  end
  delete(ah(index+1:end)); ah=ah(1:index);

  % Plot the interpolated TOPOGRAPHY data panels (if you have them)
  figure(3); clf
  if ~isnan(TDF{1})
    ah=krijetem(subnum(2,2));
    for index=1:length(froot)
      axes(ah(index))
      imagesc([nprops{index}.C11(1) nprops{index}.CMN(1)],...
              [nprops{index}.C11(2) nprops{index}.CMN(2)],...
              TDF{index}); axis xy image
    end
    delete(ah(index+1:end)); ah=ah(1:index);
    seemax(ah,3)
  end
end

% Figure out all the pairwise rimmed relationships excluding corners
% Steal from TINITALY... look at the codes in PUZZLE
indices=1:length(froot);
tp=nchoosek(indices,2); tp=[tp nan(size(tp,1),2)];
for index=1:size(tp,1)
  frst=tp(index,1);
  scnd=tp(index,2);
  % Feed row/column grid of the first with the second entry in every pair
  [tp(index,3),tp(index,4)]=puzzle(XE{frst}(1,:),YE{frst}(:,1),...
                                   XE{scnd}(1,:),YE{scnd}(:,1),-2);
end

% Halt and inspect 
if xver==2
  disp(sprintf('Inside %s',upper(mfilename)))
  keyboard
end

% Work out the rules behind the corrections later
% Do not trim the same border twice in the same way...
% The RIMCHECK warnings are diagnostic for this case. Not really.
% Ad hoc taking away here until further testing reveals systematics
% Definitely take out the ones that have zero rims
% Maybe ALL of the tps have 200 overlap?
ifs=pref(dirp{1},'/');
if strcmp(ifs,'trecolonne')
  tp=tp([1 3 4 6],:)
elseif strcmp(ifs,'titone')
  tp=tp([1 2 5 6],:);
elseif strcmp(ifs,'frantoiocornoleda')
  % These are slivers that got reduced to nothing
  tp=tp(4,:);
elseif strcmp(ifs,'frantoioacri') || strcmp(ifs,'frantoioacri3') ...
      || strcmp(ifs,'frantoiodecarlo4')
  % These are slivers that got reduced to nothing
  tp=tp(end,:);
elseif strcmp(ifs,'darioratta') || strcmp(ifs,'frantoiohermes') ...
      || strcmp(ifs,'oliointini3') || strcmp(ifs,'frantoiocornoleda3') ...
      || strcmp(ifs,'sorellegarzo3') || strcmp(ifs,'darioratta3')
  tp=tp(1,:);
end

% Trimming the tiles two by two
for index=1:size(tp,1)
  disp(sprintf('%s trimming tiles %2.2i and %2.2i by %3.3i',upper(mfilename),...
               tp(index,1),tp(index,2),tp(index,4)))
  switch tp(index,3)
   case {8,4}
    % The match is in the horizontal so the Vertical won't need to match
    hm=1; vm=0; dm=0;
   case {1,2}
    % The match is in the vertical so the Horizontal won't need to match
    hm=0; vm=1; dm=0;
   otherwise
    % The match is horizontal and vertical but the Data needn't match
    hm=1; vm=1; dm=0;
  end

  % The appropriate index
  frst=tp(index,1);
  scnd=tp(index,2);
  
  % Check and trim and reassign... this is NOT a blending
  % Do the hard check first and failsafe out of it to avoid duplicate
  % checking; in other words if either of them fails don't proceed 
  % In retrospect, this is too harsh.
  try
    [XE{frst},XE{scnd}]=...
	rimcheck(XE{frst},XE{scnd},tp(index,4),tp(index,3),hm);
    [YE{frst},YE{scnd}]=...
	rimcheck(YE{frst},YE{scnd},tp(index,4),tp(index,3),vm);
  catch
    disp('Grids do not properly align')
    keyboard
  end
      
  % Trim the RAPIDEYE data (in all channels)
  clear A B
  for ondex=1:size(RD{frst},3)
    % Repeal
    [A(:,:,ondex),B(:,:,ondex)]=...
	rimcheck(RD{frst}(:,:,ondex),RD{scnd}(:,:,ondex),tp(index,4),tp(index,3),dm);
  end

  % Replace
  RD{frst}=A;
  RD{scnd}=B;
  
  if nargout>3
    % Trim the corresponding interpolated TOPO data
    [TDF{frst},TDF{scnd}]=...
        rimcheck(TDF{frst},TDF{scnd},tp(index,4),tp(index,3),dm);
  end

  % Need to adapt the nprops now also...
  nprops{frst}.nr=size(RD{frst},1);
  nprops{frst}.nc=size(RD{frst},2);
  nprops{scnd}.nr=size(RD{scnd},1);
  nprops{scnd}.nc=size(RD{scnd},2);

  % If any of them turn out to be trimmed down to zero size, would have
  % needed to remove the root file!
  if any(nprops{frst}.nr)==0 || nprops{frst}.nc==0
    error(sprintf('Remove %s from consideration',dirp{frst}))
  end
  % Steal this stuff from RAPIDEYE and RAPIDEYG, and above
  nprops{frst}.xs =XE{frst}(1)-nprops{frst}.sp/2;
  nprops{frst}.ys =YE{frst}(1)+nprops{frst}.sp/2;
  nprops{frst}.C11=[XE{frst}(1)   YE{frst}(1)];
  nprops{frst}.CMN=[XE{frst}(end) YE{frst}(end)];

  if any(nprops{scnd}.nr)==0 || nprops{scnd}.nc==0
    error(sprintf('Remove %s from consideration',dirp{scnd}))
  end
  nprops{scnd}.xs =XE{scnd}(1)-nprops{scnd}.sp/2;
  nprops{scnd}.ys =YE{scnd}(1)+nprops{scnd}.sp/2;
  nprops{scnd}.C11=[XE{scnd}(1)   YE{scnd}(1)];
  nprops{scnd}.CMN=[XE{scnd}(end) YE{scnd}(end)];
end

% Only two tiles mattered
if size(tp,1)==1
  % These are slivers that got reduced to nothing
  % So not only do they not get trimmed, we also will them away later
  froot=froot([tp(1) tp(2)]);
  nprops=nprops([tp(1) tp(2)]);
  props=props([tp(1) tp(2)]);
  RD=RD([tp(1) tp(2)]);
  XE=XE([tp(1) tp(2)]);
  YE=YE([tp(1) tp(2)]);
  ZE=ZE([tp(1) tp(2)]);
end

if xver==2
% Use RAPIDEYG to check that those grids ARE consistent and contiguous
  for index=1:length(froot)
    % Make the grids again as if you didn't already know them
    [XEP{index},YEP{index},ZEP{index}]=rapideyg(nprops{index});
    % And check they are what you think they are
    diferm(XEP{index},XE{index})
    diferm(YEP{index},YE{index})
    diferm(ZEP{index},ZE{index})
  end
end

% And then rerun the plots perhaps, under xver

% Get all the metadata required to tile
XS=getfields(nprops,'xs');
YS=getfields(nprops,'ys');
% These aren't adjusted yet here
%XX=getfields(nprops,'xx');
%YY=getfields(nprops,'yy');
SP=getfields(nprops,'sp');
C11=getfields(nprops,'C11');
CMN=getfields(nprops,'CMN');
NC=getfields(nprops,'nc');
NR=getfields(nprops,'nr');

% Find the largest possible set from the adjusted data
npropsC.xs=min(XS);
npropsC.ys=max(YS);
% These aren't adjusted yet here
%npropsC.xx=min(XX);
%npropsC.yy=min(YY);
npropsC.C11=[min(C11(:,1)) max(C11(:,2))];
npropsC.CMN=[max(CMN(:,1)) min(CMN(:,2))];
npropsC.sp=unique(SP);
% Make a supergrid and two empty tiles
xeye=[npropsC.C11(1,1):+npropsC.sp:npropsC.CMN(1,1)];
yeye=[npropsC.C11(1,2):-npropsC.sp:npropsC.CMN(1,2)];

% Now need to combine the images together into one by nearest-neighbor
% interpolation since we basically already have all the exact values

% FJS should make an interpolant and reload it as a hash...
clear A B
for index=1:length(froot)
  for ondex=1:size(RD{1},3)
    % Interpolate RAPIDEYE, keep the type
    R{index}(:,:,ondex)=uint16(interp2(XE{index},YE{index},...
                               double(RD{index}(:,:,ondex)),xeye(:)',yeye(:)));
  end
  if nargout>3
    % Interpolate TOPOGRAPHY
    T{index}=interp2(XE{index},YE{index},TDF{index},xeye(:)',yeye(:));
  end
end

% And then decide what to do with it - which we would do the same way if
% we had duplicates. My guess is the topography doesn't duplicate if I
% did it right. I checked the sparsity and seams of this using SPY
% Images are ZERO when empty
Rdupl=sum(reshape(~cell2mat(cellfun(@iszero,R,'un',0)),...
                  [size(R{1}(:,:,1)) size(R{1},3)*length(froot)]),3);
if length(minmax(Rdupl))~=2 ||  sum(minmax(Rdupl)~=[0 size(R{1},3)])
  display('There was an inexcusable overlap in the tiling of RAPIDEYE')
else
  % No duplicates so we just flatten the images
  Rup=cat(3,R{:});
  for ondex=1:size(RD{1},3)
    % The second argument to TINDEKS is skipping by the number of channels
    RDC(:,:,ondex)=uint16(sum(double(tindeks(Rup,ondex:size(R{1},3):size(Rup,3))),3));
  end
end

% Other types of data are NAN when empty
if nargout>3
  Tdupl=sum(reshape(~cell2mat(cellfun(@isnan,T,'un',0)),...
                    [size(T{1}) length(froot)]),3);
  if length(minmax(Tdupl))~=2 && minmax(Tdupl)~=[0 size(T{1},3)]
    error('There was an inexcusable overlap in the tiling of TINITALY')
  else
    % We just flatten the images
    TDC=nansum(cat(3,T{:}),3);
  end
else
  TDC=NaN;
end

% Some more metadata now, we didn't yet check there's no change
npropsC.zp=nprops{1}.zp;
npropsC.up=nprops{1}.up;
npropsC.nc=size(RDC,2);
npropsC.nr=size(RDC,1);

% SO HERE WE NEED TO ALSO RETRIM THE ANY-BORDERS, DON'T WE, AND
% SUPPLEMENT THE NPROPS
if nargout>3
  [RDC,npropsC,TDC]=trimimage(RDC,npropsC,2,TDC);
else
  [RDC,npropsC]=trimimage(RDC,npropsC,2);
end
% Output
varns={RDC,npropsC,props,TDC};
varargout=varns(1:nargout);

