function M=puzzle(X1,Y1,X2,Y2,rim)
% M=PUZZLE(X1,Y1,X2,Y2,rim)
%
% For non-equal-size tiles where one of them may share an overlapping rim
% of a certain width with another one, identifies it
%
% INPUT:
%
% X1,Y1     The first data tile grid, X1 is a row, Y1 is a column
% X2,Y2     The second data tile grid, X2 is a row, Y2 is a column
% rim       The nonzero rim size of possible overlap being queried
%           0 in this case, will short cut to a match table
%
% OUTPUT:
%
% M         The match type, read the below very carefully!
%            8 The second data tile belongs to the RIGHT of the first [Edge Case 1]
%            4 The second data tile belongs to the LEFT of the first [Edge Case 2]
%            2 The second data tile belongs to the BOTTOM of the first [Edge Case 3]
%            1 The second data tile belongs to the TOP of the first [Edge Case 4]
%            9 The second data tile belongs to the TOP RIGHT of the first [Corner: Edge Cases 1 & 4]
%            5 The second data tile belongs to the TOP LEFT of the first [Corner: Edge Cases 2 & 4]
%            6 The second data tile belongs to the BOTOM LEFT of the first [Corner: Edge Cases 2 & 3]
%           10 The second data tile belongs to the BOTOM RIGHT of the first [Corner: Edge Cases 1 & 3]
%           12 [Non-geometric: Edge Cases 1 & 2] Never going to happen
%            3 [Non-geometric: Edge Cases 3 & 4] Never going to happen
%
% NOTE:
%
% Check the obvious symmetries to changing the order of the inputs!
%
% Last modified by fjsimons-at-alum.mit.edu, 05/23/2019

defval('rim',10)

% The base for the encoding
b=2;
% The number of questions asked, the column size of the below, the number
% of edges of the tile being interrogated
q=4;

% Prepwork: like in CHMOD, sort of!
if rim==0
  % Maximum number of possible matches (one edge or two edges at a corner)
  e=2;
  % Possible answers to the question with UP to e matches, and with where
  % they match if the answer is nonzero. All possible answers to find(m)
  % above, row by row.
  n=nchoosek(0:q,e);
  % If there is only one match, find(m) gives the number of the edge.
  % If there are two matches matches, we need a new numbering scheme
  % This now only works for e=2, let's not overdo it 
  Z=zeros(size(n,1),q);
  % Construct the matrix of possible answers
  for index=1:size(n,1)
    % Actual matches
    nn=n(index,:); nn=nn(~~nn);
    % These are the "logicals" where the matches exist
    Z(index,nn)=1;
  end
  % That is what we need to encode in base b
  b=2;
  % This would be the unique code so that you can produce the match table
  M=Z*b.^[q-1:-1:0]';
  % Output
  disp(sprintf('\nYou asked for the match table!\n'))
  disp(sprintf('\nLogicals | Code | Entries\n'))
  M=[Z  M n]; 
else 
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
  % But we should nullify matches if top/bottom and left/right don't also
  % have the other pair in common in which case RIMCHECK will fail
  % Final match encoding
  M=M*b.^[q-1:-1:0]';

  % Error handling
  if any(M)==12 || any(M)==3
    error('Something went very wrong here!')
  end
end
