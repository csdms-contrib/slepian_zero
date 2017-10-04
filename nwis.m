function [timstamp,parsdata]=nwis(code,params,begd,endd)
% [timstamp,parsdata]=NWIS(code,param,begd,endd)
%
% Downloads water (streamflow etc) data from USGS, through the
% intermediary of the RDB format.
%
% INPUT:
% 
% code      A station code string, e.g. '01401000' for the site
%           which is "Stony Brook at Princeton NJ"
% param     A parameter string, currently supported is:
%           '00060' Discharge (Mean) [cubic feet per second]
% begd      Begin date string, e.g. '1953-10-02'
% endd      End date string,   e.g. '2017-10-02'
% 
% OUTPUT:
%
% timstamp  The time stamp, in MATLAB DATENUM format
% parsdata  The "data" corresponding to your parameters
%
% EXAMPLE:
%
% [ts,cfs]=nwis('01401000','00060','1953-10-02','2017-10-02');
%
% Last modified by fjsimons-at-alum.mit.edu, 10/02/2017

% Specify where to get it by building the query
servername='https://nwis.waterdata.usgs.gov';
directoryn='nwis/dv?';
% Concatenate these later, for multiple codes and parameters
sites=sprintf('site_no=%s',        code)
parms=sprintf('cb_%s=on',          param);
begds=sprintf('begin_date=%s',     begd);
endds=sprintf('end_date=%s',       endd);
% Ignore or fix these for now
perd=[]; mode='sw'; form='rdb';
perss=sprintf('period=%i',         []);
modds=sprintf('referred_module=%s',mode)
forms=sprintf('format=%s',         form)

% Put the query together
qname=strcat(fullfile(servername,directoryn),...
	     sprintf('%s&%s&%s&%s&%s&%s&%s',...
		     parms,forms,sites,modds,perss,begds,endds));
% Put the target filename together
fname=strcat(sprintf('%s_%s_%s_%s_%s_%s.%s',...
		     param,code,mode,perd,begd,endd,form));

% Get the data off the web to the local filename
if exist(filename,'file')~=2
  websave(fname,qname)
end

% Now load (some of) the variables:
fid=fopen(fname,'r');
% Initialize while look
jk='#';
% Read and discard header for now
while strcmp(jk(1),'#')
  jk=fgetl(fid);
end
% One more
jk=fgetl(fid);
% Next ones are all 'data' into a cell array
thedata=textscan(fid,'%s %s %s %f %s');
% Close the file
fclose(fid);

% And now you extract what you think is useful
timstamp=datenum(thedata{3});
parsdata=thedata{4};


