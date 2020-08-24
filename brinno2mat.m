function brinno2mat(fname)
% BRINNO2MAT(fname)
%
% Turns a Brinno TLC120 generated AVI video file into a sequence of
% properly time-tagged single images.
%
% Last modified by fjsimons-at-alum.mit.edu, 08/24/2020

% Load video 
v=VideoReader(fname);

% Display first frame so you can read the time stamp
imshow(read(v,1)); 

% Ask for input
ts=input('Input correctly formatted time stamp string, [''2020-08-18 19:05:36'']: ');
if isempty(ts); ts='2020-08-18 19:05:36'; end
tz=input('Input correctly formatted time zone string [''America/New_York'']: ');
if isempty(tz); tz='America/New_York'; end
fr=input('Input frame rate in seconds [300]: ');
if isempty(fr); fr=300; end

% Make all the time stamps
t=datetime(ts)+seconds(fr)*[0:1:v.Duration];

% Review times
for index=1:v.Duration
  % Display first frame so you can read the time stamp
  imshow(read(v,index))
  xlabel(char(t(index)),'FontSize',14)
  ta=input('Enter necessary addition to time stamp in seconds [0]: ' );
  if ~isempty(ta); 
    t(index)=t(index)+seconds(ta);
    xlabel(char(t(index)),'FontSize',14)
    pause
  end
end

keyboard
