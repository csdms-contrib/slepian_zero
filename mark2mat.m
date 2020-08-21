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
% EXAMPLE:
%
% mark2mat('demo1')
%
% Last modified by fjsimons-at-alum.mit.edu, 08/20/2020

fname='arable_calval_Guyot_A000510_hourly_20200424.csv';

% Open the file
fid=fopen(fname);

% Read the first few lines as a "header"
for index=1:12
  % These are all read in straight 
  h{index}=fgetl(fid);
end

% Read the rest as the "data"
fms=sprintf('%s%s',repmat('%s',1,4),repmat('%f',1,34));
a=textscan(fid,fms,'Delimiter',',');

% Convert the ISO8601 time stamps to MATLAB datetime arrays
% by removing the 'Z' and blanking the 'T' (84->32) via an anoymous
% function. Note that putting the DATETIME inside would take longer
convt=@(x) char(abs(x(1:end-1))-[zeros(1,10) 52 zeros(1,8)])
t=datetime(cellfun(convt,a{1},'UniformOutput',0));



keyboard

% Close the file
fclose(fid);

keyboard

[t,d]=mark2mat('arable_calval_Guyot_A000510_hourly_20200424.csv');
