function varargout=pic2prof(mn1,mn2,A,fname,dname)
% [pxy,A,mn1,mn2]=PIC2PROF(mn1,mn2,A,fname,dname)
%
% Reads a picture, outputs values a straight-line profile 
%
% INPUT:
% 
% mn1      Row (first dimension, y if your will) and
%          column (second dimension, x if you will) number
%          of the first point of the profile
% mn2      Row and column number of the second point of the profile
% A        The image file - if you don't have, leave empty, provide:
% fname    The picture filename [defaulted]
% dname    The directory name [defaulted]
%
% OUTPUT:
%
% pxy      The profile of image values, as obtained from IMPROFILE
% A        The image loaded
% mn1,mn2  The values used   
%
% EXAMPLE:
%
% tic; [~,A]=pic2prof         ; toc
% tic;       pic2prof([],[],A); toc
%
% Written by AC on 03212019

% Specify defaults
defval('dname','C:\Users\acavoli\Desktop\jp2')
defval('fname','Around180_greyscale.jpg')

% exist(fullfile(dname,fname)) 
% ls(fullfile(dname,fname))

% Read the image, if it doesn't exist yet
defval('A',imread(fullfile(dname,fname)));

% Specify more defaults
defval('mn1',[randi(size(A,1)) randi(size(A,2))])
defval('mn2',[randi(size(A,1)) randi(size(A,2))])

% Extract the profile
pxy=improfile(A,[mn1(1) ; mn2(1)],[mn1(2) mn2(2)]);

% Provide any and all outputs
varns={pxy,A,mn1,mn2};
varargout=varns(1:nargout);
