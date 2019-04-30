function tinitaly(nprops,dirp,diro,xver)
% TINITALY(nprops,dirp,diro,xver)
%
% Matches a coordinate set from RAPIDEYE to a TINITALY data file
%
% INPUT:
%
% nprops     A minimal properties structure from RAPIDEYE
% dirp       Directory [e.g. 'DATA']
% diro       Directory [e.g. '/home/fjsimonsIFILES/TOPOGRAPHY/ITALY/TINITALY']
% xver       1 Provides excessive verification 
%            0 Does not provide excessive verification
%            2 Provides a graphical test [default]
%
% EXAMPLE:
%
% [alldata,nprops]=rapideye('3357121_2018-09-11_RE3_3A','20180911_094536_3357121_RapidEye-3');
%
% Last modified by fjsimons-at-alum.mit.edu, 04/29/2019

% Bottom-level directory name, taken from the Tinitaly download
defval('dirp','DATA')
% Top-level directory name, where you keep the Tinitaly directory
defval('diro','/u/fjsimons/IFILES/TOPOGRAPHY/ITALY/TINITALY')

% I advocate checking grid parameters and file sizes for ever
defval('xver',1)

% Find all the hdr files inside the directory
try
  hdr=ls2cell(fullfile(fullfile(diro,dirp),'*.hdr'));
catch
  % Some checks and balances
  disp(sprintf('Looking inside %s I am finding\n',fullfile(diro,dirp)))
  ls(fullfile(diro,dirp))
  disp('which I expect to contain at least one hdr file')
end

% We know how many header lines there are, this is fixed
nhdr=6;

%%%%%%%%%% METADATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have the headers pre-prepared this will work
for index=1:length(hdr)
  % The HDR filename
  fhdr=fullfile(diro,dirp,hdr{index});
  % Read it in
  H=textscan(fopen(fhdr),'%s %d',nhdr);
  % Shove it in
  TV{index}=H{2};
end

% Collate
TN=H{1};
TA=[TV{:}];

if xver>0
  % Plot the boxes thusly collected
  % Compare to http://tinitaly.pi.ingv.it/immagini/Imm_TINITALY_DOWNLOAD_03.jpg
  clf
  [BX,BY]=deal(nan(length(hdr),2));
  for index=1:length(hdr)
    nc=TV{index}(1);
    nr=TV{index}(2);
    xl=TV{index}(3);
    yl=TV{index}(4);
    sp=TV{index}(5);
    % Plot the outer extent of the boxes, as I interpret it now
    bx=[xl xl xl xl xl]+[0 0      nc*sp nc*sp 0];
    by=[yl yl yl yl yl]+[0 nr*sp  nr*sp 0     0];
    BX(index,:)=minmax(bx);
    BY(index,:)=minmax(by);
    plot(bx,by); hold on
    text(double(bx(1)+[bx(3)-bx(1)]/2),...
	 double(by(1)+[by(2)-by(1)]/2),...
	 pref(pref(hdr{index}),'_'))
  end
  hold off
  axis image
  xel=[min(BX(:,1)) max(BX(:,2))];
  yel=[min(BY(:,1)) max(BY(:,2))];
  xlim(xel+[-1 1]*range(xel)/20)
  ylim(yel+[-1 1]*range(yel)/20)
  % UTM conversion?
  warning off MATLAB:nargchk:deprecated
  [yla,xlo] = utm2deg(double(xl),double(yl),'32 N')
  warning on MATLAB:nargchk:deprecated
  
  % Check the box, which seems right
  % plot(xlo,yla,'o')
  % plot([nprops.lo nprops.lo(1)],[nprops.la nprops.la(1)])
  keyboard
end






