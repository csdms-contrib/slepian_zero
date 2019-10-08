function rapideyc(indices)
% RAPIDEYC(indices)
%
% INPUT:
%
% index   A file index, by default it does them all
%         Sometimes it chokes on making large series of PDF files at once.
% 
% Checks the conversion of RAPIDEY images to *.mat structures by making a
% figure of the panels
%
% Last modified by fjsimons-at-alum.mit.edu, 10/07/2019

dirs=ls2cell(pwd);
defval('indices',1:length(dirs))

for index=indices
  % Identify the mat structure
  try 
    ris{index}=ls2cell(fullfile(dirs{index},'ri*mat'));
  catch
    error(sprintf('No ri file in %s',fullfile(dirs{index})))
  end
  % Load the table of contents
  load(cell2mat(fullfile(dirs{index},ris{index})),'tox');
  % Identify the region, which is the same as dirs{index}
  sname=suf(pref(ris{index}),'_');
  % Pick a random image
  ims=strmatch(sprintf('%s_2',sname),tox);
  imname=tox(ims(randi(length(ims))),:);
  % Load the (meta)data of that image
  eval(sprintf('load(fullfile(''%s/ri_%s.mat''),''%s'')',sname,sname,sname))
  eval(sprintf('load(fullfile(''%s/ri_%s.mat''),''%s'')',sname,sname,imname))
  % Extract some variables
  eval(sprintf('nr=%s.nprops.nr;',imname))
  eval(sprintf('nc=%s.nprops.nr;',imname))
  % And plot it nicely
  figure(1)
  clf
  eval(sprintf('image(%s.nprops.xx,%s.nprops.yy,rapideya(%s.alldata))',imname,imname,imname))
  axis image xy
  t=title(sprintf('(%ix%i) %s',nr,nc,nounder(imname)));
  t.Position=t.Position+[0 range(ylim)/20 0];
  longticks(gca)
  shrink(gca,1.1,1.1)
  hold on
  eval(sprintf('plot(%s.orchardx,%s.orchardy,''y'',''LineWidth'',1)',sname,sname))
  hold off
  drawnow
  figdisp([],imname,[],2)
  pause(0.1)
end    


