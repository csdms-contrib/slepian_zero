function meteoblue(diro,xver)
% meteoblue(diro,xver)
%
% For all the METEOBLUE csv files inside of a directory, turns them into MAT
% files and resaves them there. The format of the data is presumed to be
% consistent with 2019 retrievals from the company. 
%
% INPUT:
%
% diro      A directory string name
% xver      1 Makes a plot of a variable
%           0 Just does the conversion [default]
%
% SEE ALSO: METEOBLUF
%
% Last modified by fjsimons-at-alum.mit.edu, 09/24/2020

% Defaults
defval('xver',0)
defval('diro',fullfile(getenv('ITALY'),'METEOBLUE','csv'))

% Look inside, find them all
fnames=ls2cell(fullfile(diro,'*.csv'));

% The apparent format - twenty-five including TWENTY weather variables
N=25;
% General data format
fmt=sprintf('%s%%f',repmat('%f;',[1 N-1]));

% Loop over all the csv files
for index=1:length(fnames)
  % Get file id
  fid=fopen(fullfile(diro,fnames{index}));
  % Chop the head off by variable extraction and verification
  LAT=xmt(fgetl(fid),3,N,2);
  LON=xmt(fgetl(fid),3,N,2);
  ASL=xmt(fgetl(fid),3,N,2);
  % These ones are harder to script
  CITY=fgetl(fid);
  DOMAIN=fgetl(fid);
  LEVEL=fgetl(fid);
  % These ones we parse again below
  NAME=fgetl(fid);
  UNIT=fgetl(fid);
  % This one we ignore
  AGGREGATION=fgetl(fid);
  % Making sure the UTC_OFFSET is zero
  UTC_OFFSET=xmt(fgetl(fid),10,N,1);
  % Blank line
  fgetl(fid);
  % These are the real column headers parse below
  HEADER=fgetl(fid);

  % And now come the data
  data=reshape(fscanf(fid,fmt),N,[])';
  
  % Turn them into slightly more practical variables
  dt=datetime([data(:,1:5) repmat(0,[size(data,1) 1])],'TimeZone','UTC');
  % List other choices you might have had
  % T=timezones('Europe');

  % Plot it or save it
  if xver==0
    % Change directory name
    [a,b]=fileparts(diro);
    if strcmp(b,'csv')
      diro2=fullfile(a,'mat');
    end

    % Save name for file variable
    sname=pref(suf(fnames{index},'_'));
    % On second thought, leave the mb_
    sname=pref(fnames{index});
    cname=fullfile(diro2,sprintf('%s.mat',sname));

    if exist(cname)~=2
       % Save the data as a MAT file
       var1=parse(NAME(10:end),';');
       var2=parse(UNIT(10:end),';');
       var3=parse(HEADER(1:end),';');
       % Vertical spacers
       hspc=size(var3,1)-size(var1,1);
       vsp1=str2mat(repmat(32,hspc,size(var1,2)));
       vsp2=str2mat(repmat(32,hspc,size(var2,2)));
       var1=[vsp1 ; var1];
       var2=[vsp2 ; var2];
       % Horizontal spacers
       spc1=repmat(' ',size(var1,1),2);
       % Table of contents
       toc=number([var3 spc1 var1 spc1 var2]);
       % Assign structure
       msg=sprintf('Created by fjsimons@alum.mit.edu using %s on %s',upper(mfilename),date);
       
       % The below is a way, but really no way to do this, see also RAPIDEYM 
       % eval(sprintf('%s.%s=%s;',sname,'toc','toc'))
       fields={'lon' 'lat' 'asl' 'toc' 'dt' 'data' 'msg'};
       values={LON LAT ASL toc dt data msg};
       % Use my homegrown powerhouse
       defstruct(sname,fields,values)
       % Save it
       eval(sprintf('save(''%s'',''%s'')',cname,sname))
    else
      warning(sprintf('%s already existed!',cname))
    end
  else
    % Make a plot of the ith variable
    ith=1;
    figure(gcf)
    clf
    ah=krijetem(subnum(2,1));
    % The whole data set in UTC
    axes(ah(1))
    p(1)=plot(dt,data(:,5+ith));
    datetick('x')
    title(sprintf('Whole range %s',nounder(fnames{index})))

    % The last day in LOCAL TIME
    dt.TimeZone='Europe/Rome';
    
    axes(ah(2))
    % Logical selection
    witsj=dt>[dt(end)-days(1)];
    % Index of minimum
    mindti=min(find(witsj));
    % Index of maximum
    maxdti=max(find(witsj));
    % Make the plot and return the handle
    p(2)=plot(dt(witsj),data(witsj,5+ith));
    
    % Add one hour to come to a round number on the axis
    % Newer versions of MATLAB support xlim directly in datetime
    xels=[dt(mindti) dt(maxdti)+hours(1)];
    % Prepare to set the tick marks
    xells=xels(1):hours(4):xels(2);
    % Set the axis limits
    xlim(datenum(xels))
    % Set the tickmarks
    set(ah(2),'xtick',datenum(xells))
    % Format the axis
    datetick('x','HH:MM','keeplimits','keepticks')
    % Set the title
    title(datestr(dt(mindti),1))
  end
end

% Conduct an appropriate extr-action
function [xmt,var]=xmt(str,num,N,dorf)
% You could use this to self-extract the variable if you like!
xmt=textscan(str,hmt(num,N,dorf));
var=xmt{1};
xmt=unique(cat(2,xmt{2:end}));
if length(xmt)~=1
  error(sprintf('Expecting unique if repeated header %s',var))
end
if strcmp(var,'UTC_OFFSET')
  if xmt~=0
    error(sprintf('Expecting zero %s',var))
  end
end

% Make some appropriate formatting strings
function hmt=hmt(num,N,dorf)
switch dorf
 case 1
  hmt=sprintf('%%%is;;;;;%s%%d',num,repmat('%d;',[1 N-6]));
 case 2 
  hmt=sprintf('%%%is;;;;;%s%%f',num,repmat('%f;',[1 N-6]));
end

