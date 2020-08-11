function varargout=partita(mn,partn,olap,meth,xver)
% CT=PARTITA(mn,partn,olap,meth,xver)
%
% Finds a partition selecting somewhat overlapping subsets of the rows (in a
% randomized sense: no contiguous blocks, but some rows can be selected more
% than once according to the overlap parameter) of a tall rectangular matrix
% in a manner that results in the size of the partition being exactly equal
% to the number of columns of the matrix, i.e. if the partition is used to
% select rows of the matrix in successive columns, there are no missing
% columns. We like partitions that are large in the number of rows, and
% small in the amount of overlap. If no output is requested, a plot is made.
%
% INPUT:
%
% mn         A certain matrix size [#rows #columns]
% partn      A certain partition block length
% olap       A certain partition block overlap in samples
% meth       One of two methods, where 2 is fastest
% xver       1 is for testing only
%
% OUTPUT:
%
% CT        The partitition matrix
%
% EXAMPLE:
%
% partita([72 18],10,1)
% partita([1020 15],80,12,2,0)
% partita([1020 15],80,12,2,0)
%
% Last modified by fjsimons-at-alum.mit.edu, 08/11/2020

% Matrix size
defval('mn',[51 25])
% Number of rows
m=mn(1);
% Number of columns
n=mn(2);
% My thinking is for tall rectangular matrices, row "frequencies" column "stations"
if n>m
  warning(sprintf('%s really expecting a TALL matrix yet %i not > %i',...
		upper(mfilename),m,n))
end

% Begin with the most obvious partition size at no overlap
defval('olap',0);
% Use lower-integer, if remainder we add a partition later 
defval('partn',fix(m/n));
disp(sprintf('Obvious partition length is %i with overlap %i',fix(m/n),0))

if olap>=partn
  error(sprintf('%s overlap %i not < %i block size ',...
		upper(mfilename),olap,partn))
end

defval('meth',2); 
% disp(sprintf('Method %i',meth))

% Need it for reporting also, the number of realizable partitions
ps=fix([m-olap]/[partn-olap]);

% And now you make the partition
switch meth
 case 1
   % As in BLOCKMEAN's subfunction AVOPS
   ro=pauli(1:m,partn);
   ro=ro(1:partn-olap:end,:)';
 case 2
  % As in PCHAVE
  ro=repmat([1:partn]',1,ps)+repmat([0:(ps-1)]*[partn-olap],partn,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The shuffling is not necessary in the testing phase
defval('xver',0)
if xver==0
  shuf=shuffle(1:m);
else
  shuf=(1:m);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% So now here are the rows of the partition
ro=shuf(ro(:,1:min(n,size(ro,2))));
% And here are the columns to which they need to be applied
co=gamini(1:min(size(ro,2),n),partn);
% And this is the sparse matrix that puts this all together
CT=sparse(ro(:)',co,1,m,n);

% If there is no or only one column missing, add missing rows to the last
% column or make just one more
[romis1,comis1,romis2,comis2]=reportit(CT,m,n,ps,partn,olap);
if comis1==0 && romis1>0
  CT=CT+sparse(shuf(m-romis1+1:m),co(end),1);
  [romis1,comis1]=reportit(CT,m,n,ps,partn,olap);
end
if comis1>=1 && romis1>=0
  CT=CT+sparse(shuf(m-romis1-olap+1:m),co(end)+1,1,m,n);
  [romis1,comis1]=reportit(CT,m,n,ps,partn,olap);
  % If there STILL are missing columns, just fill them up with the olap
  if comis1>=1
    % This however is the situation you like least of all
    CT=CT+sparse(repmat(shuf(m-max(1,olap)+1:m),comis1,1)',...
		 repmat(n-comis1+1:n,max(1,olap),1),1,m,n);
    reportit(CT,m,n,ps,partn,olap);
  end
end

% Make a plot if no output
if nargout==0
  clf
  spy(CT)
  axis normal
  set(gca,'XTick',1:n,'YTick',unique([1:fix(m/5):m m]))
  set(gca,'GridLineStyle',':')
  grid on
  xlabel(sprintf('minimum/maximum row sum %i %i',...
		 minmax(sum(full(CT),2))))
  ylabel(sprintf('minimum/maximum column sum %i %i, number of degenerates %i',...
		 minmax(sum(full(CT),1)),sum(sum(full(CT),2)>=2)))
  ylim([1 m]+round(m/20)*[-1 1])
  xlim([1 n]+round(n/20)*[-1 1])
end

% Return only as much output as asked
varns={CT};
varargout=varns(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=reportit(CT,m,n,ps,partn,olap)

% Rows missed (two calculation methods)
romis1=sum(~sum(full(CT),2));
romis2=m-(ps*(partn-olap)+olap+([n-ps]<0)*(n-ps)*(partn-olap));
% Columns missed (two calculation methods)
comis1=sum(~sum(full(CT),1));
comis2=max(n-ps,0);

if nargout>2
  % Full report from the two calculation methods
  disp(sprintf('Missing rows    %2.2i %2.2i',romis1,romis2))
  disp(sprintf('Missing columns %2.2i %2.2i',comis1,comis2))
else
  % After fixing; the second calculation method is no longer valid
  disp(sprintf('Missing rows    %2.2i',romis1))
  disp(sprintf('Missing columns %2.2i',comis1))
end

varns={romis1,comis1,romis2,comis2};
varargout=varns(1:nargout);
