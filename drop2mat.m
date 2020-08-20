function varargout=drop2mat(fname)
% [t,d]=DROP2MAT(fname)
%
% Reads, and converts a CSV file from the Kestrel Drop instrument to a
% MATLAB file including proper date-time variables. The format of the data
% line is presumed to be (everything being given in metric SI units) as: 
% 2020-08-16 17:16:00,"24,9","61,3","24,8","16,9"
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
% EXAMPLE:
%
% [t,d]=drop2mat('export_fjsimons_2020_8_17_9_54_16.csv');
%
% Last modified by fjsimons-at-alum.mit.edu, 08/19/2020

% Open the file
fid=fopen(fname);

% Read the first few lines as a "header"
for index=1:5
  % These are all read in straight 
  h{index}=fgetl(fid);
end

% Read the rest as the "data"
a=textscan(fid,'%q%q%q%q%q','Delimiter',',');

% Convert the time stamps
t=datetime(a{1});

% Pick out the header variable names
for index=1:3
  vnames=h{index}; vnames(abs(vnames)==32)='';
  % These are simple parameter value pairs
  [v1,v2]=strread(vnames,'%s%s','delimiter',',');
  % Start the actual data structure
  d.(char(v1))=char(v2);
end

% Pick out the data variable names
vnames=h{4}; vnames(abs(vnames)==32)='';
% You'll now know there are FOUR variables of interest
[~,v1,v2,v3,v4]=strread(vnames,'%s%s%s%s%s','delimiter',',');

% Pick out the unit name strings
index=5;
vnames=h{index}; vnames(abs(vnames)==32)='';
% You'll now know there are FOUR variables of interest
[~,u1,u2,u3,u4]=strread(vnames,'%s%s%s%s%s','delimiter',',');

% Give the variables their proper place
for index=2:5
  % Don't redo the time, you've got it already
  b=char(a{index});
  % Comma goes to decimal point
  b(abs(b)==44)='.';
  % Final assignment to human-intelligible variables
  c{index}=str2num(b);
  % Hark back to the old spitout subfunction
  eval(sprintf('d.(char(v%i))=c{%i};',index-1,index))

  % Give the units their proper place
  eval(sprintf('w=strcat(char(v%i),''%s'');',index-1,'Unit'))
  eval(sprintf('d.(char(w))=char(u%i);',index-1))
end

% Close the file
fclose(fid);

% Now save all of that as a MAT file
[a,b,c]=fileparts(fname);
save(b,'t','d')

% Optional output
varns={t,d};
varargout=varns(1:nargout);
