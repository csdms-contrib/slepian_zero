function varargout=mark2mat(fname,hord)
% [t,d,h]=MARK2MAT(fname)
%
% Reads, and converts a CSV file from the Arable Mark 2 instrument to a
% MATLAB file including proper date-time variables. The format of the data
% line is according to our knowledge of 'daily' and 'hourly' files, with
% and without external data (wind) sensor.
% 
%
% INPUT:
%
% fname       A complete file name string
% hord        1 'hourly' data file 
%             2 'daily' data file 
%
% OUTPUT:
%
% t           The timestamp as a DATETIME array
% d           The data as a STRUCTURE array
% h           The header line CELL array
%
% SEE ALSO:
%
% DROP2MAT
% 
% EXAMPLE:
%
% mark2mat('demo1')
%
% Last modified by fjsimons-at-alum.mit.edu, 08/25/2020

if isempty(strfind(fname,'demo'))
  % Prepare to save the CSV file as a MAT file
  [aa,bb,cc]=fileparts(fname);
  ename=sprintf('%s.mat',bb);

  if exist(ename)~=2
    % Open the file
    fid=fopen(fname);

    % Read the first few lines as a "header"
    for index=1:10
      % These are all read in straight 
      h{index}=fgetl(fid);
    end
    % Take care of possible disclaimer
    if ~isempty(h{10})
      % This the empty
      h{11}=fgetl(fid);
    end
    % Force this to be the header, create extra empty
    h{12}=fgetl(fid);
    
    % Do the only one that is relevant here - Location
    vnames=h{4}; vnames(abs(vnames)==32)='';
    % Got to knnow there are double quotes in there
    [v1,v2]=strread(vnames,'%s%q','delimiter',',');
    d.(char(v1))=char(v2);

    % Other, rejected ways
    % d=struct(char(v{1}(5)),a{5})
    % d=cellstruct({a{5}},char(v{1}(5)))
    
    % Unit designations
    for index=6:9
      % Do the only one that is relevant here
      vnames=h{index}; vnames(abs(vnames)==32)='';
      vnames(abs(vnames)==47)='';
      % Got to knnow there are double quotes in there
      [v1,v2]=strread(vnames,'%s%q','delimiter',',');
      v1=strcat(v1,'Unit');
      d.(char(v1))=char(v2);
    end
    
    % Pick out the data variable names
    % Replace the underscores with nothing
    vnames=h{12}; vnames(abs(vnames)==95)='';
    % These are simple parameter value pairs, prefer TEXTSCAN over STRREAD
    v=textscan(vnames,'%s','delimiter',',');

    % Read the rest as the "data"
    sv11=size(v{1},1);
    if sv11>=38
      % Mark 1 hourly file
      fms=sprintf('%s%s%s%s%s',repmat('%s',1,4),repmat('%f',1,30),...
		  '%s',repmat('%f',1,3));
      if sv11==39
	% Mark 2 appears to have one more column (and time order switched)
	fms=[fms '%s'];
      end
    else
      if sv11==28
	% Mark 1 daily file
	fms=sprintf('%s%s%s%s%s',repmat('%s',1,4),repmat('%f',1,20),...
		  '%s',repmat('%f',1,3));
      end
      if sv11==26
	% Mark 2 daily file
	fms=sprintf('%s%s%s%s%s%s',repmat('%s',1,3),repmat('%f',1,18),...
		  '%s',repmat('%f',1,3),'%s');
      end
    end
    a=textscan(fid,fms,'Delimiter',',');

    % Close the file
    fclose(fid);

    % One of the first two is the UTC time, this could be switched
    utc=find(strcmp(v{1},'utctime'));
    if isempty(utc); utc=1; end
    
    % Note that we are going with the UTC times
    try
      % Convert the ISO8601 time stamps to MATLAB datetime arrays
      % by removing the 'Z' and blanking the 'T' (84->32) via an anoymous
      % function. Note that putting the DATETIME inside would take longer
      convt=@(x) char(abs(x(1:end-1))-[zeros(1,10) 52 zeros(1,8)]);
      t=datetime(cellfun(convt,a{utc},'UniformOutput',0));
    catch
      % A newer, simpler format
      t=datetime(a{utc});
    end

    % Sanity check
    disp(sprintf('%s records expected, %i received',...
		 h{5}(abs(h{5})>=48 & abs(h{5})<=58),length(t)))
    
    % The simple tags
    for index=3:4
      eval(sprintf('d.%s=char(a{%i}(1));',char(v{1}(index)),index))
    end
    % The geographical tags
    for index=5:6
      eval(sprintf('d.%s=a{%i};',char(v{1}(index)),index))
    end
    try
      % Need to know these variables ARE there and called 'lat' and 'long'
      try
	% Need the mapping toolbox
	[la,lo]=meanm(d.lat(~isnan(d.lat)),d.long(~isnan(d.long)));
      catch
	la=nanmean(d.lat);
	lo=nanmean(d.long);
      end
      % And I rename the longitude
      d.lat=la;
      d.lon=lo;
      d=rmfield(d,'long');
    end
    % All the rest of the data
    for index=7:sv11
      eval(sprintf('d.%s=a{%i};',char(v{1}(index)),index))
    end
    % Remove the completely empty numeric columns
    fn=fieldnames(d);
    for index=1:length(fn)
      dn=d.(fn{index});
      try
	if sum(isnan(dn))==length(dn)
	  d=rmfield(d,fn{index});
	end
      end
    end
    
    % Save
    save(bb,'t','d','h')
  else 
    disp(sprintf('%s: %s existed',upper(mfilename),ename))
    load(ename)
  end

elseif strcmp(fname,'demo1')
  % Supply an existing filename
  [t,d]=mark2mat('arable__Guyot_Roof_C003384_hourly_20200823.csv');

  if nargout==0
    % Make a picture, take your inspiration from DROP2MAT
    plot(t,Tair)
  end
end

% Optional output
varns={t,d,h};
varargout=varns(1:nargout);
