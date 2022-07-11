function r=rdist(a,b,lags)
% r=RDIST(a,b,lags)
%
% Relative mean-squared difference between two time series, the difference
% version of the multiplicative signal similarity measure XCORR.
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest zero-padded)
% lags        The lags at which the measure is to be computed
%
% OUTPUT:
%
% r           The root-mean-squared difference between the timeseries
%             shifted to the lags in question, normalized by the
%             root-mean-squared value of the first input time series
% lags        The lags at which the measure was computed [defaulted]
%
% Last modified by fjsimons-at-alum.mit.edu, 07/11/2022

% Only vectors, same length or zero-pad
a=a(:);
b=b(:);
if length(a)<length(b)
  a=[a ; zeros(length(b)-length(a),1)];
else
  b=[b ; zeros(length(a)-length(b),1)];
end
% Now they are the same
M=length(a);

% Defaults like in XCORR
maxlag=M-1;
defval('lags',-maxlag:maxlag);

% Initialize output
r=nan(size(lags))

% Do the computation, for loop might be slower but vectorization costs memory
i=0;
for l=lags
  i=i+1;
  r(i)=sum([b(1-l*[l<0]:end-l*[l>0])-a(1+l*[l>0]:end+l*[l<0])].^2)...
       /sum(a(1+l*[l>0]:end+l*[l<0]).^2);
end


