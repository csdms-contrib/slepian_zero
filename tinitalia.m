function tinitalia(dirp,diro)
% TINITALIA(dirp,diro)
%
% Converts the entire available TINITALY topography data set into mat files
%
% INPUT:
%
% dirp       Directory [e.g. 'DATA']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
%
% SEE ALSO:
%
% TINITALY, which reads individual files
%
% EXAMPLE:
%
% Making the default inputs work, my directory
% /u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY/DATA
% contains at least one necessary file
%   e43010_s10.zip
% And in that, I am able to do, without any further inputs:
% tinitalia;
%
% Last modified by fjsimons-at-alum.mit.edu, 04/29/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')

% Find all the zip files inside the directory
zpf=ls2cell(fullfile(fullfile(diro,dirp),'*.zip'));

% We know how many header lines there are, this is fixed
nhdr=6;

% Find all the headers and turn them into a structure
for index=1:length(zpf)
  % The root filename
  fpref=pref(zpf{index});

  % Prepare the full MAT filename
  fmat=fullfile(diro,dirp,sprintf('%s.mat',fpref));
  % The full HDR filename, if it exists
  fhdr=fullfile(diro,dirp,sprintf('%s.hdr',fpref));
  
  % If the MAT file doesn't exist, makes it (and the HDR file if it didn't)
  if exist(fmat)~=2
    
    %%%%%%%%%% METADATA AND DATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Now load the data and save them in the structure also
    fname=unzip(fpref);
    
    % Read the uncompressed asc file, open the asc filename
    fid=fopen(fname{1});
    
    %%%%%%%%%% METADATA (RE-)READ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read what we already knew, could have bypassed $UFILES/tinitaly
    H=textscan(fid,'%s %d',nhdr);
    
    % Make a header structure variable... overwrite what you might have had
    eval(sprintf('%s=cell2struct(mat2cell(H{2},ones(size(H{2}))),H{1},1);',...
		 fpref))
    
    %%%%%%%%%% DATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read the actual data into a structure variable
    reddit=textscan(fid,'%f');

    % Make a data structure variable
    eval(sprintf('%s.topodata=reshape(reddit{1},T{2}(1),T{2}(2));',...
		 fpref))
    fclose(fid);
    
    % Remove the uncompressed file
    system(sprintf('rm -rf %s',fname{1}));

    
    % And then save it all as a matfile
    eval(sprintf('save %s %s',fmat,fpref))
    
    % And also write the hdr file; see also $UFILES/tinitalia
    if exist(fhdr)~=2
      % See also STRUCT2ASCI 
      fidh=fopen('bla','w');
      for index=1:nhdr
	fiel=cell2mat(H{1}(index));
	fprintf(fidh,'%-13s %d\n',fiel,eval(sprintf('%s.%s',fpref,fiel)));
      end
      fclose(fidh);
    end
  end
end


