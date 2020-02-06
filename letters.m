function letcel=letters(indices,kees)
% letcel=LETTERS(indices,1)
% This last option returns upper case
%
% Gives letters of the alphabet in a cell array of strings
%
% Last modified by fjsimons-at-alum.mit.edu, June 28th, 2004

letcel=cellnan(length(indices),1,1);

defval('kees',0)

for index=1:length(indices)
  letcel{index}=letter(indices(index),kees);
end
