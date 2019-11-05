function treerings2(diro,fname,plotit)
% TREERINGS2(diro,fame,plotit)
%
% Analizes a tree ring scan in a reasonable manner. Good for a triplet of
% points and actually draws the line identifying the layer. 
%
% INPUT:
%
% diro       A directory name string, e.g. '.'
% fname      A filename string, e.g. 'KJ11_barkup.tif'
% plotit     0 don't make any plots [default]
%            1 save certain plots
%
% OUTPUT:
%
% None. But a text file is generated that has the prefix of the supplied
% filename and the extension .pix. In this file, the x-coordinate of the
% midpoint of the splined left boundary of every "layer" is preserved,
% and also the x and y coordinates of the line segment whose length is
% the last preserved quantity. You'll need this last number to
% characterize "treering" width, and you might need the first number to
% sort the output and verify your analysis. Another text file is
% generated after sorting on the first x location in the other file.
%
%
% NOTES from Adam Maloof:
%
% If you use a Mac, you may need to install BetterTouchTool 
% http://blog.boastr.net/?page\_id=1722 in order to emulate a 3-button mouse.
%
% Note that the output *.pix file is just a text file with 6 columns
% x1(left edge of couplet), x2, x3, y2, y3, couplet width (in pixels)
% Column 1 makes it easy to sort the couplet widths in time order.
% You'll want to convert pixels to cm using the scale on the image to
% calibrate.
%
% Last modified by fjsimons-at-alum.mit.edu, 11/04/2019

% Where are they kept? This will be different for you
defval('diro',...
       '/u/fjsimons/CLASSES/FRS-California/2008/FieldData/TreeRings/AllScans');

% Which filename is it? I supply a default - you can delete this line
defval('fname','KJ10_barkup.tif')

% Default number of segments - do not use DEFVAL for this!
ndef=12;

% Output filename modifier
try
  puid=getenv('USER');
catch
  puid='puid';
end
outfile=sprintf('%s_%s.pix',nounder(pref(fname)),puid);
defval('newr',[])
puid=input(sprintf('\nSaving output as %s, if unhappy supply username:\n',...
		outfile),'s');
if ~isempty(puid)
  outfile=sprintf('%s_%s.pix',nounder(pref(fname)),puid);
end
disp(sprintf('\nSaving output as %s\n',outfile))

% Error message
errmsg=['Collect pairs of triplets with different mouse buttons!'];

% File format
ffn=['%8i %8i %8i %8i %8i %12g\n'];

% Choices
chois='1/0/2 accept and move to next panel/3 reject and move to next panel';

% Number of x tick marks
defval('nticks',10)

% Markersize in section plots
defval('marks',6)
% Markersize in overview plot
defval('marksa',6)
% Actually make all the plots, or just pretend
defval('plotit',0)

% Read in the tree scan...
rgb=imread(fullfile(diro,fname));

keyboard

% Make sure the long side is across the screen
if size(rgb,1)>size(rgb,2)
  % Transpose...
  red=rgb(:,:,1)';
  green=rgb(:,:,2)';
  blue=rgb(:,:,3)';
  rgb=zeros([size(red) 3],'uint8');
  rgb(:,:,1)=red;
  rgb(:,:,2)=green;
  rgb(:,:,3)=blue;
else
  % Or don't...
  red=rgb(:,:,1);
  green=rgb(:,:,2);
  blue=rgb(:,:,3);
end

% These values are unsigned 16-bit integer (from 0-65535) so they require
% somewhat special attention to convert to grey scales
% If they should be unsigned 8-bit integer (from 0-255) you'd use uint8
grae=uint8([double(red)+double(green)+double(blue)]/3);

% Select the MIDPOINT on the y-axis for plotting and guides
ypoints(1)=round(size(grae,1)/2);
ypoints(2)=round(size(grae,1)/3);
ypoints(3)=round(2*size(grae,1)/3);

clf
% Plot the color image
ah(1)=subplot(2,1,1);
ob(1)=image(rgb);
yl(1)=ylabel(sprintf('color'));
tl(1)=title(nounder(fname));
set(tl,'FontSize',15)
% Plot the guide lines
pg(1:3)=plotk(xlim,ypoints);

% Plot the gray-scale image
ah(2)=subplot(2,1,2);
ob(2)=image(repmat(grae,[1 1 3]));
yl(2)=ylabel(sprintf('grey'));
% Plot the guide line
pg(4:6)=plotk(xlim,ypoints);

xels=xlim;

% Some cosmetic changes
set(ah,'ytick',[])
nolabels(ah(1),1)
longticks(ah,4)
fig2print(gcf,'landscape')
% Print figure if plotit was set to 1
figdisp(nounder(pref(fname)),[],[],plotit)

% Different symbols for the mousebuttons, upper, middle, lower
symbs={'v','o','^'};

% Pictorial overlap as a fraction of the figure
olaps=20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=input(sprintf('\nReady for analysis? [1/0/2 for quick run-through]\n'));
% Now do the analysis, default is to do it
defval('r',1)

if r>0 & r<3
  nsex=input(sprintf('\nChange %i segments to [more than one] :?\n',ndef));
  % Number of sections to display for analysis
  defval('nsex',ndef)
  
  olap=[xels(2)-xels(1)]/nsex/olaps;
  % Look at the figure segment by segment
  xells=pauli(linspace(xels(1),xels(2),nsex+1))+...
	[0 0 ; ones(nsex-1,1) zeros(nsex-1,1)];
  
  % Always load the file also
  try 
    prevs=load(outfile);
    % And plot the stuff
    for jndex=1:size(prevs,1)
      axes(ah(1)); hold on
      plot(prevs(jndex,[2 3]),prevs(jndex,[4 5]),'b-'); hold off
      axes(ah(2)); hold on
      plot(prevs(jndex,[2 3]),prevs(jndex,[4 5]),'b-'); hold off
    end
  end
  
  if r==1
    % Open the file, see the flags under FOPEN
    fid=fopen(outfile,'a+');
    
    disp(sprintf(['\nDefine two triplets of points by clicking with different' ...
		  ' mouse buttons on or near the guide lines\n']));
  end
  
  % And make the picks or simply display the data
  for index=1:nsex
    set(ah,'xlim',[max(1,xells(index,1)-olap) xells(index,2)],...
	   'xtick',...
	   round(linspace(xells(index,1),xells(index,2),nticks)))
    % Adjust title
    axes(ah(1))
    tl(1)=title(sprintf('%s section %i / %i',...
			nounder(fname),index,nsex));
    
    if r==1
      goingon=1;
      while goingon==1
	% Saves x and y coordinate, and mouse button pressed, in triplet pairs
	[xpicks,ypicks,bpicks]=ginput(6);
	
	% Note that you should be having a multiple of THREE picks!
	if length(xpicks)~=6
	  disp(sprintf('\n%s %s\n',errmsg))
          % Start over
	  continue
	end
	
	% Identify the mouse buttons
	onez=bpicks==1;
	twoz=bpicks==2;
	threez=bpicks==3;
	
	try
	  % Check again that they are indeed triplets with different buttons
	  difer(sum(onez)-sum(twoz),[],1,NaN)
	  difer(sum(twoz)-sum(threez),[],1,NaN)
	catch
	  disp(sprintf('\n%s %s\n',errmsg))
          % Start over
	  continue
	end
	
	% Turn them into indices rather than logicals
	onez=find(onez);
	twoz=find(twoz);
	threez=find(threez);
	
	axes(ah(1))
	[pp1(1),pp2(1),pp3(1)]=plotp(xpicks,ypicks,bpicks,...
				     onez,twoz,threez,symbs);
	
	axes(ah(2))
	[pp1(2),pp2(2),pp3(2)]=plotp(xpicks,ypicks,bpicks,...
				     onez,twoz,threez,symbs);
	
	% Cosmetics
	set([pp1 ; pp2 ; pp3],'MarkerF','w','MarkerE','k','MarkerS',marks)
	set([pp2(1) ; pp2(2)],'MarkerS',marks-2)
	
	% Here are the true triplets; now perform the fitting also
	xtriplet=[xpicks(onez)' ; xpicks(twoz)' ; xpicks(threez)'];
	ytriplet=[ypicks(onez)' ; ypicks(twoz)' ; ypicks(threez)'];
	
	% For each of the pairs of triplets
	for ondex=1:2
	  % Here we perform the interpolation
	  yy=ypoints(2):ypoints(3);
	  % This part can be changed at will of course
	  xx=spline(ytriplet(:,ondex),xtriplet(:,ondex),yy);
	  axes(ah(1))
	  hold on
	  ps1(ondex)=plot(xx,yy,'w-');
	  axes(ah(2))
	  hold on
	  ps2(ondex)=plot(xx,yy,'w-');
	end
	
	% Now calculate the distance between those curves and plot it
	axes(ah(1))
	[d,EX,WY,ph]=curvedist(xtriplet(:,1),ytriplet(:,1),...
			       xtriplet(:,2),ytriplet(:,2),1,0);
	set(ph,'Color','w')
	axes(ah(2))
	ph(2)=plot(EX,WY,'w');
	
	axes(ah(1)); hold off
	axes(ah(2)); hold off
	
	% Do not use DEFVAL for this
	r2=[];
	while isempty(r2)
	  r2=input(sprintf('\nAccept this measurement? %s\n',chois));
	end
	
	% We write the line segments but also the y-center point of the
	% leftmost of the splined boundaries so we can keep track and
	% resort if needed
	[ym,my]=sort(ytriplet(:,1));
	wattowrite=[round(xtriplet(my(2),1)) round(EX) round(WY) d];
	
	switch r2
	 case 1
	  % Now write this information to a file
	  a=fprintf(fid,ffn,wattowrite);
	 case 2
	  a=fprintf(fid,ffn,wattowrite);
	  goingon=0;
	 case 3
	  delete([ps1(:) ; ps2(:) ; ph(:) ; pp1(:); pp2(:) ; pp3(:)])
	  goingon=0;
	 otherwise
	  delete([ps1(:) ; ps2(:) ; ph(:) ; pp1(:); pp2(:) ; pp3(:)])
	end
	
      end
      
      % Print section figures with picks
      figdisp(nounder(pref(fname)),sprintf('%i_pix',index),[],plotit)
    end
    if r==2
      disp('Hit RETURN to continue')
      pause
    end
  end
  
  if r==1
    fclose(fid);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    r=input(sprintf('\nReady for final review? [1/0]\n'));
    if r==1
      % Change size of markers
      set(findobj('MarkerS',marks),'MarkerS',marksa)
      set(ah,'xlim',xels,'xtick',...
	     round(linspace(xels(1),xels(2),nticks)))
      axes(ah(1))
      tl(1)=title(nounder(fname));
      % Print final figure with all picks
      figdisp(nounder(pref(fname)),'pix',[],plotit)
    end
  end
end

% Always leave a sorted outfile
try 
  prevs=load(outfile);
  [p,i]=sort(prevs(:,1));
  % Open the file, see the flags under FOPEN
  fid=fopen(sprintf('%s_sorted.pix',pref(outfile)),'w');
  a=fprintf(fid,ffn,prevs(i,:)');
  fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
function pk=plotk(xlim,ypoints)
hold on
pk(1)=plot(xlim,[ypoints(1) ypoints(1)],'k');
pk(2)=plot(xlim,[ypoints(2) ypoints(2)],'k');
pk(3)=plot(xlim,[ypoints(3) ypoints(3)],'k');
hold off

function [pp1,pp2,pp3]=plotp(xpicks,ypicks,bpicks,onez,twoz,threez,symbs)
hold on
pp1=plot(xpicks(onez),ypicks(onez),symbs{1});
pp2=plot(xpicks(twoz),ypicks(twoz),symbs{2});
pp3=plot(xpicks(threez),ypicks(threez),symbs{3});
hold off

