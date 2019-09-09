function varargout=puzzle(X1,Y1,X2,Y2,rim)
% [M,rim]=PUZZLE(X1,Y1,X2,Y2,rim)
%
% For non-equal-size tiles where one of them may share an overlapping rim of
% a certain fixed width with another one with identical coordinates,
% identifies it. If the rim is unknown, you can determine it first,
% possibilities up the the smallest of any of the dimensions of the
% images are considered (i.e. the shortest length of any of the four).
%
% INPUT:
%
% X1,Y1     The first data tile grid, X1 is a row, Y1 is a column
% X2,Y2     The second data tile grid, X2 is a row, Y2 is a column
% rim       The nonzero rim size of possible overlap being queried [default: 10]
%            0 in this case, will shortcut to a match table
%           -1 determines what if any rim will make a match, recursively
%           -2 determines the match, but excludes likely corner matches
%
% OUTPUT:
%
% M         The match type, read the below very carefully!
%            8 The second data tile belongs to the RIGHT of the first [Edge Case 1]
%            4 The second data tile belongs to the LEFT of the first [Edge Case 2]
%            2 The second data tile belongs to the BOTTOM of the first [Edge Case 3]
%            1 The second data tile belongs to the TOP of the first [Edge Case 4]
%            5 The second data tile belongs to the TOP LEFT of the first [Corner: Edge Cases 2 & 4]
%            6 The second data tile belongs to the BOTTOM LEFT of the first [Corner: Edge Cases 2 & 3]
%            9 The second data tile belongs to the TOP RIGHT of the first [Corner: Edge Cases 1 & 4]
%           10 The second data tile belongs to the BOTTOM RIGHT of the first [Corner: Edge Cases 1 & 3]
%           12 [Non-geometric: Edge Cases 1 & 2] Never going to happen
%            3 [Non-geometric: Edge Cases 3 & 4] Never going to happen
%            7 [Non-existent encoding] Never going to happen... 
%            14,13,11 would be for three matches, 15 for four... impossible!
% rim       The rim used, or (multiple ones) found as the case may be
%
% NOTE:
%
% Changing the order of the inputs doesn't always give symmetric results,
% as there is a directionality to the match size if the tiles are of
% unequal dimensions. Check the results thoroughly, not all cases have
% come up in otherwise thorough testing. Consider the difference between
% a "top left" match (with the same rim) and a "top and left" match (with
% different rims)... Consider what can happen with fliplr and flipdup....
%
% SEE ALSO:
%
% RIMCHECK
%
% Last modified by fjsimons-at-alum.mit.edu, 09/04/2019

defval('rim',10)

% The base for the encoding
b=2;
% The number of questions asked, the column size of the below, the number
% of edges of the tile being interrogated. First question indexed 1. 
q=4;

% Prepwork: like in CHMOD, sort of!
if rim==0
  % Maximum number of possible matches (one edge, or two edges at a corner)
  e=2;
  % Possible answers to the question with UP to e matches, and with index of
  % where they match if the answer is nonzero. In other words, all possible
  % answers to find(M), row by row, disregarding the zero. This now
  % only works for e=2, let's not overdo it. We are including the zero
  % since it gives us the entries belonging to as if only on thing were
  % matched. If e>2 we'd have to loop over the e's to get the complete set.
  n=nchoosek(0:q,e);
  % If there is only one match, find(M) gives the number of the edge, and
  % we could use that as a code. But if there are two matches, we need a
  % new numbering scheme. 
  Z=zeros(size(n,1),q);
  % Construct the matrix of possible answers
  for index=1:size(n,1)
    % Actual matches
    nn=n(index,:); nn=nn(~~nn);
    % These are the "logicals" where the matches exist
    Z(index,nn)=1;
  end
  % This would be the unique code so that you can produce the match table
  M=bcode(Z,b);

  % Output
  disp(sprintf('\nYou asked for the match table!\n'))
  disp(sprintf('\n%9s Logicals %4s  | Code |  Entries\n','',''))
  M=[Z  M n];
elseif rim<0
  % This is somewhat self-limiting, which is probably a good thing, and at
  % least defines what we mean by "rim".... The self-limitation comes from
  % the construction of M in the next block, which treats matches as
  % possible when they might not dimensionally exist. The way around it
  % would be to split the construction of M into separate X and Y blocks, or
  % maybe max/min out the indices so they don't go negative, but the first
  % trials were not of an encouraging simplicity so we'll define rim as up
  % to the shortest of any of the dimensions to be safe.
  M=zeros(min([length(X1) length(Y1) length(X2) length(Y2)]),1);
  for index=1:length(M)
    M(index)=puzzle(X1,Y1,X2,Y2,index);
  end

  % Hand off variable
  if rim==-2; tocheck=1; else tocheck=0; end

  % Return what it really wants, remember FIND wants to give rows and columns
  [rim,~,M]=find(M);

  % Discard double matches which are likely corners in this scheme
  if tocheck==1 && length(rim)==2
    % Define the corner proportionally to the length and most likely
    % non-corner match only keep it when it exceeds the 
    prp=1/3;
    % Cases require further checking
    try; M(M==8)=M(M==8)*(rim(M==8)/length(X2)<prp); end
    try; M(M==4)=M(M==4)*(rim(M==4)/length(X1)<prp); end
    try; M(M==2)=M(M==2)*(rim(M==2)/length(Y2)<prp); end
    try; M(M==1)=M(M==1)*(rim(M==1)/length(Y1)<prp); end
    % Actual output
    [Mi,~,M]=find(M); 
    rim=rim(Mi);
    if isempty(M); M=0; rim=0; end
    if length(M)==2; M=0; rim=0; end
  end
else 
  % Beware of the false prophet ~sum([]) which is logical one
  rim=abs(rim);
  % The questions: do the grids match in any way, and report if they do,
  % are on the inside of the square brackets... and that's being encoded
  % Try all sides of the second one against the first, in this order:
  % [D1   D2] is the match with overlap
  % [D2   D1] is the match with overlap
  % [D1 ; D2] is the match with overlap
  % [D2 ; D1] is the match with overlap
  M=[~sum(X1(end-rim+1:end)-X2(1:rim)) ...
     ~sum(X2(end-rim+1:end)-X1(1:rim)) ...
     ~sum(Y1(end-rim+1:end)-Y2(1:rim)) ...
     ~sum(Y2(end-rim+1:end)-Y1(1:rim))];
  % But we should nullify matches if top/bottom and left/right candidates
  % don't also share at least a bit of an edge in the other dimension
  if [any(M([1 2])) && [min(Y2)>max(Y1) || max(Y2)<min(Y1)]] || ...
	[any(M([3 4])) && [min(X2)>max(X1) || max(X2)<min(X1)]] 
    M=zeros(1,q);
  end

  % Final match encoding
  M=bcode(M,b);
end

% Output
varns={M,rim};
varargout=varns(1:nargout);

% Do the encoding
function M=bcode(Z,b)
% Encodes the logical digits in a matrix M as a base-b number 
M=Z*b.^[size(Z,2)-1:-1:0]';

% Error handling
if any(M)==12 || any(M)==3
  error('Something went very wrong here!')
end
