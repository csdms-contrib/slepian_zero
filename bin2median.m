function varargout=bin2median(x,y,multp,perc)
% [xi,ypi,x,y,mult,perc]=BIN2MEDIAN(x,y,multp,perc)
%
% INPUT:
%
% x           The independent variable, not necessarily unique or equally spaced
% y           The same-size dependent variable
% multp       The median-x-interval multiplier, the interval over which the
%             desired statistics are quoted [default a fraction of the x-range]
% perc        The percentiles [default: 5 50 95]
%
% OUTPUT:
%
% xi          New independent variables, midpoints of the requested intervals
% ypi         A matrix with columns according to the requested percentages
% x,y         Regurgitated inputs
% mult,perc   Regurgitated inputs
% 
% EXAMPLE:
% 
% bin2median('demo1')
% bin2median('demo1',N) % for N a certain integer
%
% Last modified by fjsimons-at-alum.mit.edu, 08/20/2020

% Supply some defaults for unit testing
defval('x',rand(randi(10000),1))

% Get to it, boss!

if ~isstr(x)
  defval('y',randn(length(x),1));
  % Supply some more defaults
  defval('multp',round(range(x(:))/30/median(diff(unique(x)))));
  defval('perc',[5 50 95]);

  % Make sure the input arrays are one-dimensional
  x=x(:);
  y=y(:);

  % First we handle duplicate data points
  [xu,IA]=unique(x);

  if length(xu)~=length(x)
    % Rejig a bit. In BENDERX I used ROW2STATS
    [xu,IA]=unique(x+(-1)^randi(2)*rand(length(x),1)*100000*eps);
    disp('Have had to rejig')
  end

  if length(xu)~=length(x)
    error('Still not unique')
  end

  % Reassign data
  y=y(IA);
  x=xu;

  % Then we go MAG2MED, GPS2MEDIAN
  beg=min(x);

  % Figure out the median sampling intervals
  newdt=median(diff(x));
  intv=multp*newdt;

  % How many times will this interval - potentially - be repeated?
  ntms=ceil([max(x)-beg]/intv);
  % Initialize the medians vector
  ypi=nan(ntms,length(perc(:)));

  % Snap every value to the nearest increment of newdt 
  newt=round(x/newdt)*newdt;

  % Interpolate the data to the median sampling intervals - explore
  % methods! Nearest is most appropriate when noisy data are taken
  % sometimes very closest together
  yi=interp1(x,y,newt,'nearest');

  % This is the average number of values that you'll want to take the
  % statistics over, which will end up filling an unequally spaced numbers
  % of bins through the reshaped data matrix that you are about to
  % construct; watch out for strongly nonhomogeneously distributed data
  % sets where you'll want to play with the multp parameter much
  multc=floor(length(yi)/multp);

  % Compute the desired stats in one go, over the same number of elements
  ypi=prctile(reshape(yi(1:multp*multc),multp,multc),perc)';

  % But... there's a couple you might have missed, so add their stats also
  ypi=[ypi ; prctile(yi(multp*multc+1:end),perc)];

  % From this you can learn at which time "ypi" should be quoted
  xi=newt([round(multp/2):multp:multp*multc ...
           multp*multc+round([length(yi)-multp*multc]/2)])';

  % Optional output
  varns={xi,ypi,x,y,multp,perc};
  varargout=varns(1:nargout);
elseif strcmp(x,'demo1')
  % Now the second input is the number,for the demo only
  defval('y',[]); N=y; defval('N',10000)
  x=rand(randi(N),1);
  y=randn(length(x),1);

  % Go through the motions
  [xi,ypi,x,y]=bin2median(x,y);
  plot(x,y,'b.')
  hold on
  plot(xi,ypi(:,2),'k','LineWidth',1)
  plot(xi,ypi(:,1),'r')
  plot(xi,ypi(:,3),'r')
  hold off
end


