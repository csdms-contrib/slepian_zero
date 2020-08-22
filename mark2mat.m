function varargout=mark2mat(fname)
% [t,d]=MARK2MAT(fname)
%
% Reads, and converts a CSV file from the Arable Mark 2 instrument to a
% MATLAB file including proper date-time variables. The format of the data
% line is presumed to be (everything being given in metric SI units) as: 
% 
%
% INPUT:
%
% fname       A complete file name string
%
% OUTPUT:
%
% t           The timestamp as a DATETIME array
% d           The data as a STRUCTURE array
%
% SEE ALSO:
%
% DROP2MAT
% 
% EXAMPLE:
%
% mark2mat('demo1')
%
% Last modified by fjsimons-at-alum.mit.edu, 08/22/2020

if isempty(strfind(fname,'demo'))
  % Prepare to save the CSV file as a MAT file
  [a,b,c]=fileparts(fname);
  ename=sprintf('%s.mat',b);

  if exist(ename)~=2 
    % Open the file
    fid=fopen(fname);

    % Read the first few lines as a "header"
    for index=1:12
      % These are all read in straight 
      h{index}=fgetl(fid);
    end

    % Do the only one that is relevant here
    vnames=h{4}; vnames(abs(vnames)==32)='';
    % Got to knnow there are double quotes in there
    [v1,v2]=strread(h{4},'%s%q','delimiter',',');
    d.(char(v1))=char(v2);

    % Read the rest as the "data"
    fms=sprintf('%s%s',repmat('%s',1,4),repmat('%f',1,34));
    a=textscan(fid,fms,'Delimiter',',');

    % Close the file
    fclose(fid);

    % Convert the ISO8601 time stamps to MATLAB datetime arrays
    % by removing the 'Z' and blanking the 'T' (84->32) via an anoymous
    % function. Note that putting the DATETIME inside would take longer
    convt=@(x) char(abs(x(1:end-1))-[zeros(1,10) 52 zeros(1,8)]);
    t=datetime(cellfun(convt,a{1},'UniformOutput',0));

    % Pick out the data variable names
    % Replace the underscores with nothing
    vnames=h{12}; vnames(abs(vnames)==95)='';
    % These are simple parameter value pairs, prefer TEXTSCAN over STRREAD
    v=textscan(vnames,'%s','delimiter',',');

    % Put everything into a big data structure
    % d=struct(char(v{1}(5)),a{5})
    % d=cellstruct({a{5}},char(v{1}(5)))
    
    % The simple tages
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
    for index=7:38
      eval(sprintf('d.%s=a{%i};',char(v{1}(index)),index))
    end
    % Remove the completely empty columns
    fn=fieldnames(d);
    for index=1:length(fn)
      dn=d.(fn{index});
      if sum(isnan(dn))==length(dn)
	d=rmfield(d,fn{index});
      end
    end
    
    % Save
    save(b,'t','d')
  else 
    disp(sprintf('%s: %s existed',upper(mfilename),ename))
    load(ename)
  end

elseif strcmp(fname,'demo1')
  [t,d]=mark2mat('arable_calval_Guyot_A000510_hourly_20200424.csv');

  if nargout==0
    % Make a picture, take your inspiration from DROP2MAT
    keyboard
  end
end

% Optional output
varns={t,d};
varargout=varns(1:nargout);
