function [A,B]=rimcheck(A,B,rim,M,xver)
% [A,B]=RIMCHECK(A,B,rim,M,xver)
%
% Uses the output of PUZZLE to check the rims of matrices
%
% INPUT:
%
% A,B      Two matrices, not necessarily the same size, some overlap
% rim      The rim size of possible overlap
% M        The PUZZLE match code
% xver     1 issue warnings
%          0 do not issue any warnings 
%
% OUTPUT:
%
% A,B      The two matrices where one was trimmed to avoid the overlap
%
% Last modified by fjsimons-at-alum.mit.edu, 05/24/2019

% Default is to issue warnings (but no confirmation messages!)
defval('xver',1)

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
    if xver==1; diferm(B(:,end-rim+1:end)-A(1:size(B,1),1:rim)); end
    % Now B gets trimmed on the right
    B=B(:,1:end-rim,:);
  else
    % B has a larger COLUMN size and is to the LEFT of A
    if xver==1; diferm(B(1:size(A,1),end-rim+1:end)-A(:,1:rim)); end
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
    if xver==1; diferm(B(end-rim+1:end,:)-A(1:rim,1:size(B,2))); end
    % Now B gets trimmed at the bottom
    B=B(1:end-rim,:);
  else
    % B has a larger COLUMN size and is on TOP of A
    if xver==1; diferm(B(end-rim+1:end,1:size(A,2))-A(1:rim,:)); end
    % Now A gets trimmed from the top
    A=A(rim+1:end,:);
  end
end

