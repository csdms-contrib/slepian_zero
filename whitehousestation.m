function whitehousestation(to,frex,CHA,STA,HOL,NTW,YYYY,DDD,HHMMSS)
% WHITEHOUSESTATION(to,frex,CHA,STA,HOL,NTW,YYYY,DDD,HHMMSS)
%
% INPUT:
%
% to           Up to three destinations (cell string),
%                 e.g. 'none', 'vel', 'acc' (see TRANSFER)
% frex         Prior filter requested, highpass lowpass [f1 f2 f3 f4]
% CHA          Up to three channels (cell string),
%                 e.g. 'HHZ', 'HHX', 'HHY', 'HNZ', 'HNX', 'HNY', etc
% STA          Up to three stations (cell string),
%                 e.g. 'S0001', 'S0002', etc
% HOL          Up to three holes (cell string),
%                 e.g. '00', '10', etc
% NTW          Up to three networks (cell string),
%                 e.g. 'PP', etc
% YYYY         Up to three years (cell string),
%                 e.g. '2024', etc
% DDD          Up to three days (cell string),
%                 e.g. '096', etc
% HHMMSS       Up to three times (cell string),
%                 e.g. '142022', etc
%
% EXAMPLE:
%
% whitehousestation
% whitehousestation({'acc','acc'},[0.03 5 25 50])
% whitehousestation({'none','none','none'},[0.03 5 15 30],...
%                   {'HHZ','HHZ','HNZ'},{'S0001','S0002','S0002'},...
%                   {'00','00','10'},{'PP','PP','PP'},...
%                   {'2024','2024','2024'},{'096','096','096'},...
%                   {'142022','142022','142022'})
%
% Last modified by fjsimons-at-alum.mit.edu, 04/11/2024

% Epicentral distance
[gcdkm,delta]=grcdist(guyotphysics(0),[-74.7540   40.6890]);

% Where do you keep the data?
ddir='/data1/fjsimons/CLASSES/GuyotPhysics/WhitehouseStationNewJersey2024/SAC';
ddir='/data1/fjsimons/CLASSES/GuyotPhysics/WestofBedminsterNewJersey2024/SAC'

% Default identification of the component etc
defval('CHA',{'HHZ','HHZ'})
defval('STA',{'S0001','S0002'})
defval('HOL',{'00','00'})
defval('NTW',{'PP','PP'})
defval('YYYY',{'2024','2024'})
defval('DDD',{'096','096'})
defval('HHMMSS',{'142022','142022'})

% Define the frequency filter
defval('frex',[0.03 2 25.00 50.00]);
% Define the converstion destination
defval('to',{'none','none'});

% Read and transfer
for index=1:length(CHA)
    % Note that I am sticking in the D but I don't remember now why that's there
    [s{index},h{index}]=transfer(sprintf('%s.%s.%s.%s.D.%s.%s.%s.SAC',...
           NTW{index},STA{index},HOL{index},CHA{index},YYYY{index},DDD{index},HHMMSS{index}),...
                                 frex,to{index});
    switch to{index}
      case 'none'
        % Unit conversion divider
        uconv=1e6;
        ystr='displacement (mm)';
      case 'vel'
        uconv=1e6;
        ystr='velocity (mm/s)';
      case 'acc'
        % Value from Wolfram Alfa
        uconv=9.80168*1e9;
        ystr='acceleration / g';
    end
    s{index}=s{index}/uconv;
end

% Fix potential timing issues
for index=2:length(CHA)
    % Fix with respect to the first on
    h{index}=fixtiming(s{1},s{index},h{index});
end


% Axis limits
xels=[150 300];
xels=[50 200]

xtix=xels(1):30:xels(2);
cols={'b','r','k'};
% Might override, no?
yels=halverange(cat(1,s{:}),110,NaN)
% For acceleration
%yels=[-14 14]/1000
% For displacement
%yels=[-1.1 1.1]/10;

for index=1:length(CHA)
    subplot(3,1,index)
    ph(index)=plotit(s{index},h{index},....
                     ystr,xels,yels,xtix,frex);
    ph(index).Color=cols{index};
end

             
% Check consistency
%plot(s2(abs(bam-1):end),s1(1:end-abs(bam+1)-1))

figdisp([],[],[],2)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ph=plotit(s,h,ystr,xels,yels,xtix,frex)
[ph,tl,xl,yl]=plotsac(s,h);
yl.String=ystr;
xlim(xels)
ylim(yels)
xticks(xtix)
grid on
legend(sprintf('%s | %s | %s\n     %g %s %g Hz',...
               deblank(h.KSTNM),deblank(h.KHOLE),deblank(h.KCMPNM),...
               frex(2),'to',frex(3)))


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fix relative timing error if there are only two
function h2=fixtiming(s1,s2,h2)
[a,b]=xcorr(s1,s2);
[am,j]=max(a); bam=b(j);
% Move UP the second one 
h2.B=h2.B-abs(bam-1)*h2.DELTA;
h2.E=h2.E-abs(bam-1)*h2.DELTA;
