function [TC,FC,perx]=rapideya(alldata)
% [TC,FC,perx]=rapideya(alldata)
%
% RAPIDEYA Image color adjustment for plotting
%
% INPUT:
%
% alldata  A five-channel RAPIDEYE uint16 image with (refer to the documentation)
%          channel 1 BLUE
%          channel 2 GREEN
%          channel 3 RED
%          hannel 4 RED-GREEN
%          channel 5 NEAR-INFRARED
%
% OUTPUT:
%
% TC       An adjusted  TRUE COLOR image for plotting with IMAGESC, also uint16
% FC       An adjusted FALSE COLOR image for plotting with IMAGESC, also uint16
% perx     The channel percentiles corresponding to the chosen percentages
%
% SEE ALSO: RAPIDEYE, IMADJUST, TRIMIT, SCALE
%
% Last modified by maloof-at-princeton.edu, 09/13/2019
% Last modified by fjsimons-at-alum.mit.edu, 10/01/2019

% Table of channel codes for internal reference
channels={'blu' 'grn' 'red' 'rdg' 'nir'};

% Percentiles to modify to adjust contrast and saturation
% You might want to modify this based on inspecting histogram shape
percs=[6.3 98.3
       6.3 98.3
       6.3 98.3
       6.3 98.3
       6.3 98.3];

% Initialize to the same class!
if ~strcmp(class(alldata),'uint16')
  error('We are expecting uint16 but getting %s',class(alldata))
end
tfcdata=zeros(size(alldata),'uint16');

% Clip and stretch each channel
for index=1:length(channels)
  [tfcdata(:,:,index),perx(index,:)]=...
      clipit(alldata(:,:,index),percs(index,:));
end

% Reconstruct TRUE and FALSE color images
% So that is RED GRN BLU as "RGB" channels
TC=tfcdata(:,:,[3 2 1]);
% And this is NIR RED RED as "RGB" channels
FC=tfcdata(:,:,[5 3 3]);

% Subfunction to clip and stretch an individual channel
function [data,perx]=clipit(data,percs)
% Convert to double internally
data=double(data);
% Determine the percentiles, be sure to sort them
perx=sort(10.^prctile(log10(data(:)),percs));
% Saturate, clip, winsorize, by any other name
data(data<perx(1))=perx(1);
data(data>perx(2))=perx(2);
% Now scale it to the full range for IMAGESC
data=uint16([data-perx(1)]./[perx(2)-perx(1)]*double(intmax('uint16')));
% Report the percentages as rounded numbers
perx=round(perx);
