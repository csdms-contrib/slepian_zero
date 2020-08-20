function [xi,ypi]=bin2median(x,y,M,perc)
% [xi,ypi]=BIN2MEDIAN(x,y,M,perc)
%
% INPUT:
%
% x       The independent variable, not necessarily unique or equally spaced
% y       The same-size dependent variable
% M       The median interval multiplier over which the statistics will be quoted
% perc    The percentiles [default: 5 50 95]
%
% OUTPUT:
%
% xi      New independent variables
% ypi     A matrix with columns according to the requested percentages
% 
% EXAMPLE:
% 
% x=rand(100,1);
% y=rand(100,1);
% [xi,ypi]=bin2median(x,y,5,[5 50 95]);
%
% Last modified by fjsimons-at-alum.mit.edu, 08/19/2020

% Make sure it's one-dimensional
x=x(:);
y=y(:);

keyboard

% Prepare for needing 
[xu,IA,IX]=unique(x);

% First we handle duplicate data points

% Then we go MAG2MED, GPS2MEDIAN
beg=min(x);
% Figure out the median sampling intervals
newdt=median(diff(xu));
intv=M*newdt;

% How many times will this interval - potentially - be repeated?
ntms=ceil([max(x)-beg]/intv);
% Initialize the medians vector
meds=nan(ntms,length(perc(:)));

% Snap every value to the nearest increment of newdt seconds, this is better for data drops 
newt=round(x/newdt)*newdt;

% Could consider reporting norm([x-newt]) to get a feel for the interpolation

% Interpolate the data to the median sampling intervals
yi=interp1(x,y,newt);

% Rearrange them by sets of intv at a time, or nearly so, almost all
multp=round(intv/newdt);
% Report in samples if you must
disp(sprintf('The number of samples taken together consecutively is %i',...
	     multp))
% This is roughly how many of those will find into the vector that you have
multc=floor(length(yi)/multp);
% Could have saved us the initialization. Compute the medians
meds=nanmedian(reshape(yi(1:multp*multc),multp,multc),1);
% But... there's a couple you might have missed, so add their medians also
meds=[meds nanmedian(yi(multp*multc+1:end))];
toc
% From this you can learn at which time "meds" should be quoted
tims=newt([round(multp/2):multp:multp*multc ...
           multp*multc+round([length(yi)-multp*multc]/2)])';


