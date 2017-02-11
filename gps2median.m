function varargout=gps2med(fname,intvm,method,ifwrite,offsetm)
% [tims,meds,tor,mor]=GPS2MED(fname,intvm,method,ifwrite,offsetm)
%
% Converts a certain GPS position time data file, formatted as
% 40.345266,-74.655144,2015/11/25,00:54:01
% into a new file that reports medians of the ACCURACY
%
% INPUT:
%
% fname    Complete path and filename string [default: HargravsGPS_60cx]
% intvm    Desired reporting interval (in MINUTES)
% method   1 Exact mapping to incremented intervals (slow!)
%          2 Interpolation and sequential intervals (fast!)
% ifwrite  1 Writes a new file with these data in DATENUM format
%          0 Doesn't 
% offsetm  At which minute in the data set do we begin?
%
% OUTPUT:
%
% tims     The midpoint times of the intervals [in DATENUM]
%          compared to the first (potentially offset) sample
% meds     The median ACCURACY values over those intervals
% tor      The original time axis (with respect to offsetm)
% mor      The original accuracy values (with respect to offsetm)
%
% Last modified by fjsimons-at-alum.mit.edu, 02/11/2017

% This is very specifically, for Hargraves Hall, on Princeton Campus
% Suply the true location in UTM of the same zone
utme= 529286.6939;
utmn=4466132.8936;

% Daylight Saving Time ends in North America at this local time
dstend=datenum(2015,11,1,2,0,0);

% Default filename, interval, method, write-flag and offset
defval('fname','HargravesGPS_60cx')
defval('intvm',1)
defval('method',1)
defval('ifwrite',1)
defval('offsetm',0)

% Load the data, open the file first
fid=fopen(fname);

% This creates a cell array with one cell per each column of the file 
h=textscan(fid,'%f %f %s %s','Delimiter',',');

% The actual GPS readings, converted from decimal degrees to  UTM coordinates
[gpse,gpsn,utmz]=deg2utm(h{1},h{2});
% Calculate accuracy in UTM coordinates; this now is the primary variable
gpsa=sqrt([gpse-utme].^2+[gpsn-utmn].^2);
% Convert the time into DATENUM format and order chronologically
gpst=flipud(datenum(strcat(h{3},h{4}),'yyyy/mm/ddHH:MM:SS'));
% Turn into GMT as the weather station respected DST
% Check out this condition, which depends on the sampling rate and the
% precision of the representation of DATENUM and DATESTR, which isn't great
cond=min(find([gpst>((dstend-datenum(0,0,0,0,round(median(diff(gpst))*60*24),1)))]));
gpst(1:cond)=gpst(1:cond)-datenum(0,0,0,1,0,0);
% And obviously if we're into Spring again this will require adjustment
disp(sprintf('First date %s and last date %s',datestr(gpst(1)),datestr(gpst(end))))
% You must reference to the first sample (thus zero) for subdivision
gpst=[gpst-gpst(1,1)];
% Close the data file
fclose(fid);

% Define where the beginining of the data set is as a fraction of a DAY
beg=offsetm/24/60;
% Define the length interval of interest as a fraction of a DAY
intv=intvm/24/60;
% How many times will this interval - potentially - be repeated?
ntms=ceil([max(gpst)-beg]/intv);
% Initialize the medians vector
meds=nan(ntms,1);
% Initialize the medians plot line handles
medp=nan(ntms,1);

% Might as well cut the data off altogether if there is an offset
% Note that this is necessary for method 2
gpsa =gpsa(gpst>=beg);
gpst=gpst(gpst>=beg);

% Now do the actual calculation
switch method 
 case 1
  %% METHOD 1
  % The way of the "for" loop - you will see that this is very slow
  more off
  tic
  ent=beg+intv;
  
  for index=1:ntms
    % Report in minutes but only every so often
    if mod(index-1,ntms/10)==0
      disp(sprintf('Working between minutes %5.5i and %5.5i',...
		   floor(beg*60*24),ceil(ent*60*24)))
    end
    % Use nanmedian in case there are nans in the data vector
    meds(index)=nanmedian(gpsa(gpst>=beg & gpst<ent));
    % Update the beginning and the end
    beg=ent;
    ent=ent+intv; 
  end
  toc
  % Output - add the time reference and the offset back in
  meds=meds';
  tims=[intv*[1:ntms]-intv/2]+offsetm/24/60;
 case 2
  % METHOD 2
  % There has to be a quicker way!
  tic
  % Interpolate the data to the median sampling intervals
  newdt=median(diff(gpst));

  % Report in seconds if you must
  disp(sprintf('The median sampling interval in seconds is %f',...
	       newdt*60*60*24))
  % Snap every value to the nearest increment of newdt seconds, this is better for data drops 
  newt=floor(gpst/newdt)*newdt;
  gpsai=interp1(gpst,gpsa,newt);

  % Rearrange them by sets of intv at a time, or nearly so, almost all
  multp=round(intv/newdt);
  % Report in samples if you must
  disp(sprintf('The number of samples taken together consecutively is %i',...
	       multp))
  % This is roughly how many of those will find into the vector that you have
  multc=floor(length(gpsai)/multp);
  % No need for initialization!
  meds=nanmedian(reshape(gpsai(1:multp*multc),multp,multc));
  % But... there's a couple you might have missed, so add their median
  meds=[meds nanmedian(gpsai(multp*multc+1:end))];
  toc
  % From this you can learn at which time "meds" should be quoted
  tims=newt([round(multp/2):multp:multp*multc ...
           multp*multc+round([length(gpsai)-multp*multc]/2)])';
end

% Output to a new file
if ifwrite==1
  fid=fopen(sprintf('%s_%i_%i.txt',...
      strtok(fname,'.'),intvm,method),'w');
  fprintf(fid,'%9.3f %9.6f\n',[meds ; tims]);
  fclose(fid);
end

% Output, if so desired
varns={tims,meds,gpst,gpsa};
varargout=varns(1:nargout);
