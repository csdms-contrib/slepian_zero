function varargout=ndbc(bnum,fname,ccode)
% [t,d,h]=NDBC(bnum,filename,ccode)
%
% Reads buoy data from the NDBC
%
% INPUT:
%
% bnum      Buoy number (default: 41049)
% dtype     Data type 
%           1 Standard meteorological
%           2 Wave spectral density
%           3 Supplemental measurements
% dyear     Data year (default: 2020)
%
% OUTPUT:
%
% t         The time variable
% d         The actual data
% h         Data header line(s)
%
% Last modified by fjsimons-at-alum.mit.edu, 06/21/2021

% Make defaults
defval('bnum',41049)
defval('dtype',1)
defval('dyear',2020)

% Make a match table... e.g. for dtype h and w...
dlet={'h',     'w',    's'};
ddir={'stdmet','swden','supl'};
% Header lengths for these data types not including newline
hlen=[177];
% Format string for this datatype
fmt1=sprintf('%s%s%s%s',repmat('%d',1,6),repmat('%f',1,5),'%d',repmat('%f',1,6));
dfmt={fmt1};

% Construct web address
url1='https://www.ndbc.noaa.gov/';
url2='view_text_file.php?';
url3=sprintf('filename=%i%s%i.txt.gz',bnum,dlet{dtype},dyear);
url4=sprintf('&dir=data/historical/%s/',ddir{dtype});
furl=sprintf('%s%s%s%s',url1,url2,url3,url4);

% Now load it
hd=webread(furl);

% And then parse it
h=hd(1:hlen(dtype));
d=textscan(hd(hlen(dtype)+1:end),dfmt{dtype});
% The time data
t=datetime(d{1},d{2},d{3},d{4},d{5},zeros(size(d{5})));
% The real data
d=d(6:end);

% Optional output
varns={t,d,h};
varargout=varns(1:nargout);
