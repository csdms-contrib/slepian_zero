function varargout=mosaic(froot,dirp,diro,xver,urld,clip)
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
% Tested on 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 09/08/2019

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
for index=1:length(froot)
  % Don't want the graphic test from RAPIDEYE 
  [RD{index},nprops{index}]=rapideye(froot{index},dirp{index},[],min(xver,1),[],clip);

  % Don't worry about making the picture from TINITALY
  TDF{index}=tinitaly(nprops{index},[],[],min(xver,1),RD{index});

  % Make the grids
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

% Maybe here go to the inner bounding box

% Figure out all the pairwise rimmed relationships excluding corners
% Steal from TINITALY...
indices=[1 2 3 4];
tp=nchoosek(indices,2); tp=[tp nan(size(tp,1),2)];
for index=1:size(tp,1)
  frst=tp(index,1);
  scnd=tp(index,2);
  % Feed row/column grid of the first with the second entry in every pair
  [tp(index,3),tp(index,4)]=puzzle(XE{frst}(1,:),YE{frst}(:,1),XE{scnd}(1,:),YE{scnd}(:,1),-2);
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
  [XE{frst},XE{scnd}]=...
      rimcheck(XE{frst},XE{scnd},tp(index,4),tp(index,3),hm);
  [YE{frst},YE{scnd}]=...
      rimcheck(YE{frst},YE{scnd},tp(index,4),tp(index,3),vm);
  % Trim the RAPIDEYE data (in all channels)
  keyboard
  for ondex=1:size(RD,3)
    % Repeal
    [A{frst}(:,:,ondex),B{scnd}(:,:,ondex)]=...
	rimcheck(RD{frst}(:,:,ondex),RD{scnd}(:,:,ondex),tp(index,4),tp(index,3),dm);
  end
  % Replace
  RD{frst}=A{frst};
  RD{scnd}=B{scnd};
  
  % Trim the corresponding interpolated TOPO data
  [TDF{frst},TDF{scnd}]=...
      rimcheck(TDF{frst},TDF{scnd},tp(index,4),tp(index,3),dm);

  % Need to adapt the nprops now also...
  nprops{index}.xs=XE{index}(1)-nprops{index}.sp/2;
  nprops{index}.ys=YE{index}(1)+nprops{index}.sp/2;
  nprops{index}.nr=size(RD{index},1);
  nprops{index}.nc=size(RD{index},2);
  nprops{index}.C11=[XE{index}(1) YE{1}(1)];
  nprops{index}.CMN=[XE{index}(end) YE{1}(end)];
  % Don't adjust the original polygons perhaps?
  %nprops{index}.lo=
  %nprops{index}.la=
  %nprops{index}.xp=
  %nprops{index}.yp= 
end

% Now need to combine the images together into one

% Including combining the nprops

% And then rerun the plots

keyboard
