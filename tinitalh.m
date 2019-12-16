function varargout=tinitalh(dirp,diro,xver)
% [hdr,TV,TN,TA,bx,by]=TINITALH(dirp,diro,xver)
%
% Gets and displays all headers inside a TINITALY directory
%
% INPUT:
%
% dirp       Subdirectory [e.g. 'DATA'] of:
% diro       Main directory [e.g. '/u/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       2 Provides a graphical test [default]
%            0 Does not provide a graphical test
%
% OUTPUT:
%
% hdr        All the header name strings in a cell array
% TV         All the header variables, in a cell
% TN         The header variable names, as a matrix
% TA         All the the header variables, in a matrix
% bx,by      All the box corners, if you like
%
% EXAMPLE:
%
% tinitalh([],[],2) % will bring up the map with available tiles
%
% Last modified by fjsimons-at-alum.mit.edu, 12/16/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')
% Graphical checking of grid parameters
defval('xver',2)

% Get all the headers listed
try
  % Find all the hdr files inside the directory
  hdr=ls2cell(fullfile(fullfile(diro,dirp),'*.hdr'));
catch
  % Some checks and balances
  disp(sprintf('Looking inside %s I am finding\n',fullfile(diro,dirp)))
  ls(fullfile(diro,dirp))
  disp('which I expect to contain at least one hdr file')
end

% We know how many header lines there are in each of the hdr files
nhdr=6;

% Now read all the header variables
for index=1:length(hdr)
  % The HDR filename
  fhdr=fullfile(diro,dirp,hdr{index});
  % Read it in
  fid=fopen(fhdr);
  H=textscan(fid,'%s %d',nhdr);
  % Shove the values inside a growing cell array
  TV{index}=H{2};
  % Be sure to close the files
  fclose(fid);
end

% Collate all the header information in TA and keep the names in TN
TN=H{1};
TA=[TV{:}];

% If you want the box corners
if nargout>4
  for index=1:length(hdr)
    nc=TV{index}(1);
    nr=TV{index}(2);
    xl=TV{index}(3);
    yl=TV{index}(4);
    sp=TV{index}(5);
    % Plot the outer extent of the boxes, as I interpret it now
    bx(index,:)=double([xl xl xl xl xl]+[0 0      nc*sp nc*sp 0]);
    by(index,:)=double([yl yl yl yl yl]+[0 nr*sp  nr*sp 0     0]);
  end
else
  [bx,by]=deal(NaN);
end

%%%%%%%%%% VISUAL CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a plot of all the metadata in your directory
if xver==2
  % Plot ALL the boxes of the header, they are supposedly all in zone 32
  % Compare to http://tinitaly.pi.ingv.it/immagini/Imm_TINITALY_DOWNLOAD_03.jpg
  clf
  ah=gca;
  [BX,BY]=deal(nan(length(hdr),2));
  for index=1:length(hdr)
    nc=TV{index}(1);
    nr=TV{index}(2);
    xl=TV{index}(3);
    yl=TV{index}(4);
    sp=TV{index}(5);
    % Plot the outer extent of the boxes, as I interpret it now
    bbx=double([xl xl xl xl xl]+[0 0      nc*sp nc*sp 0]);
    bby=double([yl yl yl yl yl]+[0 nr*sp  nr*sp 0     0]);
    plot(bbx,bby); hold on
    text(bbx(1)+[bbx(3)-bbx(1)]/2,...
	 bby(1)+[bby(2)-bby(1)]/2,...
	 sprintf('%i %s',index,...
		 pref(pref(hdr{index}),'_')))
    BX(index,:)=minmax(bbx);
    BY(index,:)=minmax(bby);
  end
  hold off
  axis image
  xel=[min(BX(:,1)) max(BX(:,2))];
  yel=[min(BY(:,1)) max(BY(:,2))];
  xlim(xel+[-1 1]*range(xel)/20)
  ylim(yel+[-1 1]*range(yel)/20)
  % Annotate
  shrink(ah,1.5,1.5)
  t(1)=title(sprintf('From the headers inside\n %s',...
		     fullfile(diro,dirp)));
  movev(t(1),range(ylim)/10)
end

% All the outputs fit to print
varns={hdr,TV,TN,TA,bx,by};
varargout=varns(1:nargout);
