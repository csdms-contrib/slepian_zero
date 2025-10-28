function [t,R,G,B,poli]=brinno2mat(fname,xver,poli)
% [t,R,G,B,poli]=BRINNO2MAT(fname,xver,poli)
%
% Turns a Brinno TLC120 generated AVI video file into a sequence of
% properly time-tagged single images, from which you define statistics
% pertaining to subselected polygons, which it saves them to a MAT file.
% Do not save the images themselves to MAT files that is not efficient. 
%
% INPUT:
%
% fname      A complete file name string
% xver       A verification interval (0 does not verify, any other
%            integer is the spacing) between reviewed frames. 
%            Input a
%            negative number and you get to look at the polygonal data. 
% poli       [x y] a matrix with a polygon defining the area of interest
%
% OUTPUT:
%
% t          The proper time stamps
% R          The red-channel data subselected for your polygon
% G          The green-channel data
% B          The blue-channel data
% poli       [x y] a matrix with a polygon defining the area of interest
%
% Last modified by fjsimons-at-alum.mit.edu, 10/02/2020

% Prepare to save the AVI file as a MAT file
[aa,bb,cc]=fileparts(fname);
ename=sprintf('%s.mat',bb);

if exist(ename)~=2
  % Load video 
  v=VideoReader(fname);
  
  % Display first frame so you can read off the time stamp
  g=read(v,1); cg=class(g); image(g)
  
  % Ask for input
  ts=input('Input correctly formatted time stamp string [''2020-09-12 06:15:26'']: ');
  if isempty(ts); ts='2020-09-12 06:15:26'; end
  tz=input('Input correctly formatted time zone string [''America/New_York'']: ');
  if isempty(tz); tz='America/New_York'; end
  ti=input('Input correct time interval in seconds [600]: ');
  if isempty(ti); ti=600; end
  
  % Make all the time stamps
  t=datetime(ts)+seconds(ti)*[0:1:v.Duration-1];
  
  if xver>0
    % Review time stamps
    for index=1:xver:v.Duration
      % Display first frame so you can read the time stamp
      image(read(v,index))
      xlabel(char(t(index)),'FontSize',14)
      ta=input('Enter necessary addition to time stamp in seconds [0]: ' );
      if ~isempty(ta) || ~iszero(ta)
	t(index)=t(index)+seconds(ta);
	xlabel(char(t(index)),'FontSize',14)
	pause
      end
    end
  end
  
  % Mask the region of no interest
  x=1:v.Width;
  y=1:v.Height;
  [X,Y]=meshgrid(x,y);
  if ~exist('poli','var')
    % Cut of the chyron for sure
    chyron=16;
    poli=[1 1 ; 1 v.Height-chyron ; v.Width v.Height-chyron ; v.Width 1];
  end
  % Now make the mask of the stuff you do not want
  mask=~inpolygon(X,Y,poli(:,1),poli(:,2));

  % Initialize using DEFSTRUCT perhaps?

  for index=1:v.Duration
    g=read(v,index);
    % Isolate colors and apply mask
    gr=g(:,:,1);
    gg=g(:,:,2);
    gb=g(:,:,3);
    % Isolate colors and apply mask
    gr(mask)=0; 
    gg(mask)=0;
    gb(mask)=0;
    % Resassemble the image
    g(:,:,1)=gr;
    g(:,:,2)=gg;
    g(:,:,3)=gb;
    if xver~=0
      % Make a plot
      image(g)
      title(sprintf('Frame %3.3i / %3.3i',index,v.Duration))
      xlabel(char(t(index)),'FontSize',14)
      keyboard
      pause(0.2)
    end

    % Make a thing called IMAGESTATS - see REGIONPROPS
    % Now convert these polygons to actual DATA
    grm=gr(~mask);
    ggm=gg(~mask);
    gbm=gb(~mask);
    % Compile the stats
    R.mean(index)=mean(grm);
    G.mean(index)=mean(ggm);
    B.mean(index)=mean(gbm);
    
    R.median(index)=median(grm);
    G.median(index)=median(ggm);
    B.median(index)=median(gbm);
    
    R.min(index)=min(grm);
    G.min(index)=min(ggm);
    B.min(index)=min(gbm);
    
    R.max(index)=max(grm);
    G.max(index)=max(ggm);
    B.max(index)=max(gbm);
    
    R.std(index)=std(double(grm));
    G.std(index)=std(double(ggm));
    B.std(index)=std(double(gbm));
  end

  % Save - don't for sure save the whole image
  save(bb,'t','R','G','B','poli')
else 
  disp(sprintf('%s: %s existed',upper(mfilename),ename))
  load(ename)
end

