function varargout=newfunction(a,b,c,d)
% [aa,bb,dd,ee]=NEWFUNCTION(a,b,c,d)
%
% INPUT:
%
% a    First thing - a scalar
% b    Second thing - a string
% c    Third thing - a scalar 
% d    Fourth thing - a scalar
%
% OUTPUT:
%
% aa   First thing 
% bb   Second thing
% cc   Third thing
% ee   Fourth thing
%
% SEE ALSO:
%
% ANATOMY, EVER
% 
% Last modified by fjsimons-at-alum.mit.edu, 07/27/2009

% FIRST PART: Always 'the same'
% Define defaults
defval('a',9.81)
defval('b','bla')
defval('c',1)
defval('d',2)
defval('fnpl',sprintf('defaultfilename_%s_%i',b,round(c)))

% SECOND PART: The algorithm
% Peform the computation
aa=a+c;
bb=c+d;
cc=a+d;
switch b
 case 'bla'
  dd=sprintf('I am making something with %s',b);
 otherwise
  dd='I was expecting bla';
end
disp(dd)

if nargout>3
  ee=12;
else
  ee=NaN;
end

% For loop
for in=1:4
  disp(sprintf('Hello for the %ith time',in))
end

% Save a file
save(fnpl,'a','aa','bb','cc')

% THIRD PART: Always 'the same'
% Produce desired output
varns={aa,bb,cc,ee};
varargout=varns(1:nargout);
