function [TC,FC,perx]=rapideya(alldata)
% [TC,FC,perx]=rapideya(alldata)
%
% RAPIDEYA Image color adjustment for plotting
%
% INPUT:
%
% alldata  A five-channel RAPIDEYE image with (refer to the documentation)
%          channel 1 BLUE
%          channel 2 GREEN
%          channel 3 RED
%          channel 4 RED-GREEN
%          channel 5 NEAR-INFRARED
%
% OUTPUT:
%
% TC       An adjusted  TRUE COLOR image for plotting with IMAGESC, same class
% FC       An adjusted FALSE COLOR image for plotting with IMAGESC, same class
% perx     The channel percentiles corresponding to the chosen percentages, double
%
% EXAMPLE:
%
% load('ri_maddie'); tox2ell(maddie.tox)
% imagesc([ims{1}.nprops.C11(1) ims{1}.nprops.CMN(1)],...
%   [ims{1}.nprops.C11(2) ims{1}.nprops.CMN(2)],rapideya(ims{1}.alldata)); axis xy
%
% SEE ALSO: RAPIDEYE, IMADJUST, TRIMIT, SCALE
%
% Last modified by maloof-at-princeton.edu, 09/13/2019
% Last modified by fjsimons-at-alum.mit.edu, 09/22/2022

% Table of channel codes for internal reference
channels={'blu' 'grn' 'red' 'rdg' 'nir'};

% Percentiles to modify to adjust contrast and saturation
% You might want to modify this based on inspecting histogram shape
percs=[6.3 98.3
       6.3 98.3
       6.3 98.3
       6.3 98.3
       6.3 98.3];

% Adjustment for 4-channel data
channels=channels{1:size(alldata,3)};
percs=percs(1:size(alldata,3),:);

% Initialize to the same integer class!

% NaNs are not a good choice for non-doubles
tfcdata=zeros(size(alldata),class(alldata));

% Clip and stretch each channel
for index=1:length(channels)
  [tfcdata(:,:,index),perx(index,:)]=...
      clipit(alldata(:,:,index),percs(index,:));
end

% Reconstruct TRUE and FALSE color images
% So that is RED GRN BLU as "RGB" channels
TC=tfcdata(:,:,[3 2 1]);

if size(alldata,3)==5
  % And this is NIR RED GREEN as "RGB" channels
  FC=tfcdata(:,:,[5 3 2]);
else
  FC=NaN;
end

% Subfunction to clip and stretch an individual channel
function [data,perx]=clipit(data,percs)
% Convert to double internally
wasclass=class(data);
data=double(data);
% Determine the percentiles, be sure to sort them
perx=sort(10.^prctile(log10(data(:)),percs));
% Saturate, clip, winsorize, by any other name
data(data<perx(1))=perx(1);
data(data>perx(2))=perx(2);
% Now scale it to the full range for IMAGESC and return to same class
% Write out the operation as a string for maximum clarity
operation='[data-perx(1)]./[perx(2)-perx(1)]';
% Write and execute the string that will stay within class
% Had this been a double then we should have used realmax... but we are
% assuming that as an image, it's an integer class...
eval(sprintf('data=%s(%s*double(intmax(wasclass)));',wasclass,operation));
% Report the percentages as rounded numbers
perx=round(perx);
