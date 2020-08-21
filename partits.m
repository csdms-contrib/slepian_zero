function partits(spc,partn,figs)
% PARTITS(spc,partn,figs)
%
% Illustrates a realistic configuration whereby an irregularly spaced
% "seismic shot gather" (a discrete [t,x] plane or "data panel") is
% available, and whereby a group velocity delineates the desirable from the
% undesirable part of the data (as, e.g. required to mask surface waves). It
% calculates the periodogram of the "boxcar" windows covering the desired
% ragged-edged wedge part of the [t,x] plane. It pulls out a particular
% "seismogram" (a [t,x']) to illustrate what happens if it is approximated
% by a limited Fourier-term reconstruction, where the terms in the expansion
% are randomly chosen subsets according to a certain frequency partition,
% hence the name. It reports on the quality of the reconstruction.
%
% INPUT:
%
% spc     Approximate sparsity of the stations (in percent)
% partn   Approximate frequency completion of the partition (in percent)
% figs    1 Makes time and frequency plots of the [t,x] and [f,x] planes
%         2 Illustrates random window example and one approximation
%         3 Proceeds to optimization over possible random partitions
%         0 Makes no plots at all, just does the calculations
%
% EXAMPLE:
%
% partits([],[],figs) % where figs is 1, 2, or 3
% 
% SEE ALSO:
% 
% SURFACEWIN, PARTITA
%
% Last modified by fjsimons-at-alum.mit.edu, 08/13/2020

% Defaults
defval('spc',80);
defval('partn',60)
defval('figs',2)

% Group velocity windows and selection option
% One-sided example
u1u2=[3 Inf]; son=1;
% Note that this is virtually identical to [0 3],0  (barring intentional rounding)
% Two-sided example
% u1u2=[3 6]; son=0;

% Randomly delete the traces to the level of sparsity
skipt=indeks(shuffle(1:128),1:round(129*spc/100));
x=skip([129:256],skipt);

% Generate a seismogram section that you want to keep
[Wtx,t,x]=surfacewin([],[],x,u1u2,son,0);

% Turns the frequency percentage into an actual number of unique frequencies
partn=ceil(size(Wtx,1)/2*partn/100);
% Unique frequencies... the rest reconstructed from symmetry of real window
ufreq=floor(size(Wtx,1)/2)+1;

if figs>0
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(1)
  ah(1)=subplot(121);
  % White is not there
  imagef([1 t(1)],[length(x) t(end)],~Wtx)
  colormap(gray(2))
  xl(1)=xlabel('trace number');
  yl(1)=ylabel('time (s)');
  longticks(ah(1),2)
  set(ah(1),'Xtick',sort([1 get(ah(1),'Xtick')]))
  set(ah(1),'YDir','reverse')
  shrink(ah(1),1,1.1)
  tl(1)=title(sprintf('group velocity [%3.2f %3.2f]',u1u2));
  movev(tl(1),-2)
  moveh(tl(1),+2)

  % The goal is to find a frequency projection for every window
  Wtf=fft(Wtx,size(Wtx,1),1);

  ah(2)=subplot(122);
  imagesc(decibel(abs(Wtf(1:ufreq,:)).^2))
  shrink(ah(2),1,1.1)
  %caxis([-30 0])
  set(ah(2),'Xtick',sort([1 get(ah(2),'Xtick')]))
  set(ah(2),'YTick',sort([1 get(ah(2),'YTick')]))
  xl(2)=xlabel('trace number');
  yl(2)=ylabel('frequency index');
  tl(2)=title(sprintf('frequency support',u1u2));
  movev(tl(2),-2/2)
  moveh(tl(2),+2)

  % Cosmetics
  colormap(gray(64))
  longticks(ah(2),2)

  figdisp([],1,[],2)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if figs>1
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(2)

  % Pick a particular trace at random
  defval('win',max(1,randi(size(Wtx,2))))

  % Use partition to provide a partial reconstruction
  [Wtfix,compf,reler,partf,win]=partitf(Wtf);

  ah(1)=subplot(211);
  plot(t,Wtx(:,win),'LineWidth',1)
  ylim([-0.2 1.2])
  xlim(minmax(t))
  grid on
  longticks(ah(1),2)
  tl(3)=title(sprintf('window %i',win));
  movev(tl(3),range(ylim(ah(1)))/20)

  ah(2)=subplot(212);
  plot(t,Wtx(:,win),'k','LineWidth',1)
  hold on
  plot(t,Wtfix,'b','LineWidth',1)
  plot(partf,-1,'kx','MarkerSize',4)
  hold off
  ylim(halverange([Wtfix ; 0 ; 1],110,NaN))
  xlim(minmax(t))
  grid on
  tl(4)=title(sprintf('frequency completion %i%% ; relative error %i%%',...
		      compf,reler));
  longticks(ah(2),2)
  movev(tl(4),range(ylim(ah(2)))/20)
  nolabels(ah(1),1)
  xl(4)=xlabel('time (s)');

  figdisp([],2,[],2)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% And now for the real work: attempt to find the most orthogonal way to
% partition the frequency axis that most optimally reassembles the time axis
if figs>2 || figs==0
  % Some more subsetting to make the numbers work with the defaults
  win=1:8;
  
  % Figure out a reasonable partition parameter set, where, to test the
  % parameters, you just run PARTITA without output (watch nargout!)
  Nf=6; No=0;
  xver=1;
  keyboard
  bester=10000; 
  keepf=[];
  % Should parallelize although the early indications are not great
  for index=1:1e5
    % So now you make randomized partitions for all windows...
    % These two are the same lines as appear in the PARTITF demo
    parti=partita([ufreq-1 length(win)],Nf,No,[],0)+1;
    [Wtfix,compf,reler,partf]=partitf(Wtf,win,parti);
    
    % What to optimize? The average reconstruction error? 
    % The concentration factor? 
    if mean(reler)<bester
      bester=mean(reler);
      keepf=partf;
      keepi=parti;
      Wtfib=Wtfix;
    end
  end
  
  keyboard
  
  % Then work with the best
  if xver==1
    figure(3); clf
    plot(t,Wtx(:,win),'k','LineWidth',1)
    hold on
    plot(t,Wtfib,'b','LineWidth',1)
    plot(partf,-1,'kx','MarkerSize',4)
    hold off
    ylim(halverange([Wtfib ; 0 ; 1],110,NaN))
    xlim(minmax(t))
    grid on
    title(sprintf('frequency completion %i%% ; average relative error %i%%',...
		  compf,round(bester)));
    longticks(gca,2)
    movev(tl,range(ylim(gca))/20)
    nolabels(ah(1),1)
    xl=xlabel('time (s)');
  end
end

