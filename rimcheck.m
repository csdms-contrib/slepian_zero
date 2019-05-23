function [A,B]=rimcheck(A,B,rim,M)
% [A,B]=RIMCHECK(A,B,rim,M)
%
% Uses the output of PUZZLE to check the rims of matrices
%
% INPUT:
%
% A,B      Two matrices, not necessarily the same size, some overlap
% rim      The rim size of possible overlap
% M        The PUZZLE match code
%
% OUTPUT:
%
% A,B      The two matrices where one was trimmed to avoid the overlap
%
% Last modified by fjsimons-at-alum.mit.edu, 05/23/2019

% In TINITALH, higher numbers are typically to the right or up... but I
% have preferred to spell out the cases where the individual lines are
% least different! 
switch M
 case 8
  % [D1   D2] is the match with overlap
  % Just use the case below with switched inputs
  [B,A]=rimcheck(B,A,rim,4);
  [A,B]=deal(B,A);
 case 4
  % [D2   D1] is the match with overlap
  if size(B,1)<size(A,1)
    % B has a smaller ROW size and is to the LEFT of A
    diferm(B(:,end-rim+1:end)-A(1:size(B,1),1:rim))
    % Now B gets trimmed on the right
    B=B(:,1:end-rim,:);
  else
    % B has a larger COLUMN size and is to the LEFT of A
    diferm(B(1:size(A,1),end-rim+1:end)-A(:,1:rim))
    % Now A gets trimmed from the left
    A=A(:,rim+1:end);
  end
 case 2
  % [D1 ; D2] is the match with overlap
  % Just use the case below with switched inputs
  [B,A]=rimcheck(B,A,rim,1);
  [A,B]=deal(B,A);
 case 1
  % [D2 ; D1] is the match with overlap
  if size(B,2)<size(A,2)
    % B has a smaller COLUMN size and is on TOP of A
    diferm(B(end-rim+1:end,:)-A(1:rim,1:size(B,2)))
    % Now B gets trimmed at the bottom
    B=B(1:end-rim,:);
  else
    % B has a larger COLUMN size and is on TOP of A
    diferm(B(end-rim+1:end,1:size(A,2))-A(1:rim,:))
    % Now A gets trimmed from the top
    A=A(rim+1:end,:);
  end
end

