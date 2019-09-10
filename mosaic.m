function varargout=mosaic(froot,dirp,diro,xver,urld,clip)
% [RDC,TDC,nprops]=MOSAIC(froot,dirp,diro,xver,urld,clip)
%
% Loads and mosaics four RAPIDEYE satellite images together
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
% TDC        The TINITALY data that correspond with them
% nprops     A minimal properties structure with metadata
%
% EXAMPLE:
%
% [RDC,TDC,nprops]=mosaic;
% figure(4); clf; imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],double(RDC(:,:,1))); axis xy
% figure(5); clf; imagesc([nprops.C11(1) nprops.CMN(1)],[nprops.C11(2) nprops.CMN(2)],TDC); axis xy
%
% Tested on 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 09/09/2019

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

% Load the images
parfor index=1:length(froot)
  % Don't want the graphic test from RAPIDEYE 
  [RD{index},nprops{index}]=rapideye(froot{index},dirp{index},[],min(xver,1),[],clip);

  % Don't worry about making the picture from TINITALY
  TDF{index}=tinitaly(nprops{index},[],[],min(xver,1),RD{index});

  % Make the initial grids
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
  % Reorder based on prior knowledge
  ah=ah([3 4 1 2]);
  for index=1:length(froot)
    axes(ah(index))
    imagesc([nprops{index}.C11(1) nprops{index}.CMN(1)],...
	    [nprops{index}.C11(2) nprops{index}.CMN(2)],...
	    double(RD{index}(:,:,1))); axis xy
  end

  % Plot the interpolated TOPOGRAPHY data panels
  figure(3); clf
  ah=krijetem(subnum(2,2));
  % Reorder based on prior knowledge
  ah=ah([3 4 1 2]);
  for index=1:length(froot)
    axes(ah(index))
    imagesc([nprops{index}.C11(1) nprops{index}.CMN(1)],...
	    [nprops{index}.C11(2) nprops{index}.CMN(2)],...
	    TDF{index}); axis xy
  end
end

% Figure out all the pairwise rimmed relationships excluding corners
% Steal from TINITALY...
indices=1:length(froot);
tp=nchoosek(indices,2); tp=[tp nan(size(tp,1),2)];
for index=1:size(tp,1)
  frst=tp(index,1);
  scnd=tp(index,2);
  % Feed row/column grid of the first with the second entry in every pair
  [tp(index,3),tp(index,4)]=puzzle(XE{frst}(1,:),YE{frst}(:,1),XE{scnd}(1,:),YE{scnd}(:,1),-2);
end

% Halt and inspect 
tp
keyboard
% Do not trim the same border twice in the same way as in bagliopianetti
% The RIMCHECK warnings are diagnostic for this case. Not really.
% For four panels, maybe just should avoid having the same code three times?
% Ad hoc taking away here until further testing reveals systematics
if strcmp(hash(tp,'SHA-1'),'38aa438da01361704a7147555050148697b3bacc')
  tp=tp([1 2 5 6],:)
  elseif strcmp(hash(tp,'SHA-1'),'')
end
for index=1:size(tp,1)
  disp(sprintf('Trimming tiles %2.2i and %2.2i',tp(index,1),tp(index,2)))
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
    break
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
  
  % Trim the corresponding interpolated TOPO data
  [TDF{frst},TDF{scnd}]=...
      rimcheck(TDF{frst},TDF{scnd},tp(index,4),tp(index,3),dm);

  % Need to adapt the nprops now also...
  % Don't adjust the original polygons perhaps?
  nprops{frst}.nr=size(RD{frst},1);
  nprops{frst}.nc=size(RD{frst},2);
  % If any of them turn out to be trimmed down to zero size, would need
  % to remove the root file!
  if any(nprops{frst}.nr)==0 || nprops{frst}.nc==0
    error(sprintf('Remove %s from consideration',dirp{frst}))
  end
  
  nprops{frst}.xs=XE{frst}(1)-nprops{frst}.sp/2;
  nprops{frst}.ys=YE{frst}(1)+nprops{frst}.sp/2;
  nprops{frst}.C11=[XE{frst}(1) YE{frst}(1)];
  nprops{frst}.CMN=[XE{frst}(end) YE{frst}(end)];

  nprops{scnd}.nr=size(RD{scnd},1);
  nprops{scnd}.nc=size(RD{scnd},2);
  if any(nprops{scnd}.nr)==0 || nprops{scnd}.nc==0
    error(sprintf('Remove %s from consideration',dirp{scnd}))
  end
  
  nprops{scnd}.xs=XE{scnd}(1)-nprops{scnd}.sp/2;
  nprops{scnd}.ys=YE{scnd}(1)+nprops{scnd}.sp/2;
  nprops{scnd}.C11=[XE{scnd}(1) YE{scnd}(1)];
  nprops{scnd}.CMN=[XE{scnd}(end) YE{scnd}(end)];
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
  % Do the contiguous check by hand at this early stage
  % diferm(XE{1}(1,end)+nprops{1}.sp,XE{2}(1,1))
  % diferm(XE{3}(1,end)+nprops{4}.sp,XE{2}(1,1))
  % diferm(YE{3}(end,1)-nprops{1}.sp,YE{1}(1,1))
  % diferm(YE{4}(end,1)-nprops{1}.sp,YE{2}(1,1))
end

% And then rerun the plots perhaps, under xver

% Get all the metadata required to tile
XS=getfields(nprops,'xs');
YS=getfields(nprops,'ys');
SP=getfields(nprops,'sp');
C11=getfields(nprops,'C11');
CMN=getfields(nprops,'CMN');
NC=getfields(nprops,'nc');
NR=getfields(nprops,'nr');

% Find the largest possible set 
npropsC.xs=min(XS);
npropsC.ys=min(YS);
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
  for ondex=1:size(RD{frst},3)
    % Interpolate RAPIDEYE, keep the type
    R{index}(:,:,ondex)=uint16(interp2(XE{index},YE{index},double(RD{index}(:,:,ondex)),xeye(:)',yeye(:)));
  end
  % Interpolate TOPOGRAPHY
  T{index}=interp2(XE{index},YE{index},TDF{index},xeye(:)',yeye(:));
end

% And then decide what to do with it - which we would do the same way if
% we had duplicates. My guess is the topography doesn't duplicate if I
% did it right. I checked the sparsity and seams of this using SPY
Rdupl=sum(reshape(~cell2mat(cellfun(@isnan,R,'un',0)),[size(R{1}(:,:,1)) size(R{1},3)*length(froot)]),3);
Tdupl=sum(reshape(~cell2mat(cellfun(@isnan,T,'un',0)),[size(T{1}) length(froot)]),3);
if length(minmax(Rdupl))~=2 && minmax(Rdupl)~=[0 size(R{1},3)]
  error('There was an inexcusable overlap in the tiling of RAPIDEYE')
else
  % We just flatten the images
  Rup=cat(3,R{:});
  for ondex=1:size(RD{frst},3)
    RDC(:,:,ondex)=sum(tindeks(Rup,ondex:size(R{1},3):size(Rup,3)),3);
  end
end
if length(minmax(Tdupl))~=2 && minmax(Tdupl)~=[0 size(T{1},3)]
  error('There was an inexcusable overlap in the tiling of TINITALY')
else
  % We just flatten the images
  TDC=nansum(cat(3,T{:}),3);
end

% Output
varns={RDC,TDC,npropsC};
varargout=varns(1:nargout);



