function varargout=meteobluf(fname)
% [t,d]=METEOBLUE(fname)
%
% Reads, and converts a CSV file from METEOBLUE data to a MATLAB file
% including proper date-time variables. The format of the data is
% presumed to be consistent with 2020 retrievals from the company. 
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
% SEE ALSO: METEOBLUE, DROP2MAT, MARK2MAT
%
% Last modified by fjsimons-at-alum.mit.edu, 09/25/2020

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

  % The apparent format - one time string and FORTY weather variables
  N=40;
  % General data format inluding the time stamp, or numerical header format
  fmt=sprintf('%s%s%%f','%s',repmat('%f',[1 N-1]));
  % General string header format
  fmts=sprintf('%s%s%%s','%s',repmat('%s',[1 N-1]));
  % Read the rest as the "data", FSCANF won't do with the timestamp string...
  a=textscan(fid,fmt,'Delimiter',',');
  % Close the file
  fclose(fid);

  % Extract the numerical variables that are ultimately simple pairs
  % after uniqueness testing
  for index=[2 3 4]
    [v1,v2]=xmt(h{index},fmt);
    % Start the actual data structure... some versions have empties
    d.(char(v1))=v2;
  end

  % Extract the string variables that are simple pairs without testing
  % for uniqueness
  for index=[1 8 9]
    % Replace the blanks with nothing
    vnames=h{index}; vnames(abs(vnames)==32)='';
    % These are simple parameter value pairs
    [v1,v2]=strread(vnames,'%q%q','delimiter',',');
    % Start the actual data structure... some versions have empties
    d.(char(v1{1}))=char(v2{1});
  end

  % Pick out the data variable types
  vnames=h{5}; vnames(abs(vnames)==32)='';
  % The TEXTSCAN variety of where DROP2MAT used STRREAD
  y=textscan(vnames,fmts,'delimiter',',');

  % Pick out the data variable units
  vnames=h{6}; vnames(abs(vnames)==32)='';
  % The TEXTSCAN variety of where DROP2MAT used STRREAD
  u=textscan(vnames,fmts,'delimiter',',');

  % Pick out the data variable levels
  vnames=h{7}; vnames(abs(vnames)==32)='';
  % The TEXTSCAN variety of where DROP2MAT used STRREAD
  e=textscan(vnames,fmts,'delimiter',',');

  % Pick out the data variable names
  vnames=h{10}; vnames(abs(vnames)==32)=''; 
  vnames(abs(vnames)==91)='_'; vnames(abs(vnames)==93)='';
  vnames(abs(vnames)==45)='_'; 
  % The TEXTSCAN variety of where DROP2MAT used STRREAD
  v=textscan(vnames,fmts,'delimiter',',');
  for index=2:length(v)
    vc=char(v{index});
    % Remove the location name
    v{index}=vc(length(d.location)+1:end);
  end

  % Give the variables their proper place
  for index=2:1+N
      % Hark back to the old spitout subfunction
      eval(sprintf('d.(char(v{%i}))=a{%i};',index,index))
      % Give the units and levels their proper place
      eval(sprintf('w=strcat(char(v{%i}),''%s'');',index,'Unit'))
      eval(sprintf('z=strcat(char(v{%i}),''%s'');',index,'Level'))
      eval(sprintf('d.(char(w))=char(u{%i});',index))
      eval(sprintf('d.(char(z))=char(e{%i});',index))
    end

    % Convert the time stamps, see MARK2MAT
    convt=@(x) char(abs(x)-[zeros(1,8) 52 zeros(1,4)]);
    t=datetime(cellfun(convt,a{1},'UniformOutput',0),'InputFormat','yyyyMMddHHmm');

    % Save
    save(bb,'t','d')
else 
  disp(sprintf('%s: %s existed',upper(mfilename),ename))
  load(ename)
end

% Optional output
varns={t,d};
varargout=varns(1:nargout);

% Conduct an appropriate extr-action, see METEOBLUE
function [v1,v2]=xmt(str,fmt)
% You could use this to self-extract the variable if you like!
xmt=textscan(str,fmt,'Delimiter',',');
% STRREAD  might have been easier to just read the known unique parts
v1=xmt{1};
v2=unique(cat(2,xmt{2:end}));
if length(v2)~=1
  error(sprintf('Expecting unique if repeated header %s',v1))
end
