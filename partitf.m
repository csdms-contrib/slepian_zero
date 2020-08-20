function varargout=partitf(Wtf,win,parti)
% [Wtfix,compf,concf,partf,win,Wtx]=PARTITF(Wtf,win,parti)
%
% Partially reconstructs a Fourier series of a real-valued function
% (hence it assumes Hermitian symmetry) and reports on its quality.
%
% INPUT:
%
% Wtf         A complex matrix with columns Fourier sequences, rows
%             frequencies, as coming out directly from an FFT operation
%             (no shifts, redundant, and Hermitian symmetric)
% win         An index (set) indicating the column(s) of interest
% parti       A frequency partition (matrix with row numbers and as many
%             columns as available in the variable win) which only
%             specifies the (non-zero) half of the frequencies that
%             matter. Those are the frequencies selected, noting that
%             this function also picks the negative frequencies in Wtf
%             from symmetry, and always includes dc-zero also. 
%
% OUTPUT:
%
% Wtfix       The partially reconstructed time-domain signal
% compf       The frequency completion factor (in percent)
% concf       The relative reconstruction error (in percent)
% partf       The full frequency selection index matrix as applied
% win         The index (set) indicating the column(s) of interest
% Wtx         The time-domain thing against which Wtfix is compared
%
% EXAMPLE:
%
% partitf('demo1')
%
% SEE ALSO:
%
% PARTITA, PARTITS
%
% Last modified by fjsimons-at-alum.mit.edu, 08/12/2020

% By default you specify a random function, one column and some partition
defval('Wtf',fft(peaks))

if ~isstr(Wtf)
  defval('win',max(1,randi(size(Wtf,2))))

  % Unique frequencies... the rest reconstructed from symmetry of real window
  ufreq=floor(size(Wtf,1)/2)+1;

  % Specify a default partition based on a 60 percent coverage
  defval('partn',ceil(size(Wtf,1)/2*60/100))
  % Specify the partition in terms of the actual non-zero frequency indices
  % of the non-redundant part of the Fourier transform
  defval('parti',indeks(shuffle(2:ufreq),1:partn));

  % Symmetrize to pick up the hermitian part
  partf=[parti ; size(Wtf,1)-parti+2];
  % Check that you did symmetrize, error if you don't
  for ind=1:length(win)
    diferm(sum(diff(reshape(abs(Wtf(partf(:,ind),win(ind))),[],2),[],2)))
  end

  % But how about we ALWAYS add the zero frequency anyway
  partf=[ones(1,size(partf,2)) ; partf];

  % Also should come out real upon IFFT of course
  Wtfi=zeros(size(Wtf,1),length(win));

  % Assign the partitioned values
  for ind=1:length(win)
    Wtfi(partf(:,ind),ind)=Wtf(partf(:,ind),win(ind));
  end

  % See how much of the window you end up constructing this way
  Wtfix=ifft(Wtfi);
  % We had not input the complete thing in the time-domain but we'll make it
  Wtx=ifft(Wtf(:,win));

  % What is the frequency completion?
  compf=round(size(partf,1)/size(Wtfi,1)*100);
  % What the relative error?
  for ind=1:length(win)
    concf(ind)=round(norm(Wtx(:,ind)-Wtfix(:,ind))/norm(Wtx(:,ind))*100);
  end
  
  % Optional output
  varns={Wtfix,compf,concf,partf,win,Wtx};
  varargout=varns(1:nargout);
elseif strcmp(Wtf,'demo1')
  % Some vaguely realistic dataset; some of the early columns could be zero
  Wtx=kindeks(surfacewin([0 100],[1],[0:100],[3 Inf],1,0),sort(randi(101,1,12)));
  ufreq=floor(size(Wtx,1)/2)+1;
  Wtf=fft(Wtx,size(Wtx,1),1);
  % Here's an example of Nf frequencies with No overlap for testing. 
  Nf=15; No=2; 
  % Consecutive or random
  xver=0;
  % So you see that you ask for one less than needed and always add one so
  % that you never include the zero-frequency goin in
  parti=partita([ufreq-1 size(Wtf,2)],Nf,No,2,xver)+1;
  % Pick out some random windows for illustrative purposes
  win=sort(max(1,randi(size(Wtf,2),1,size(parti,2))));

  % Use this function to make the partial reconstruction
  [Wtfix,compf,concf,partf,win,Wtx]=partitf(Wtf,win,parti);
  for ind=1:length(win); 
    ah(ind)=subplot(length(win),1,ind);
    plot(Wtx(:,ind),'LineWidth',1); 
    hold on; plot(Wtfix(:,ind),'LineWidth',1)
    xlim([1 size(Wtx,1)]);  ylim([-1.25 1.25]); hold off
    xl(ind)=xlabel('time sample');
    yl(ind)=ylabel('window');
    set(ah(ind),'xtick',unique([1 get(ah(ind),'xtick')]))
    % Plot the frequencies
    hold on
    plot(parti(:,ind),-1,'kx','MarkerSize',4)
    hold off
    longticks(ah,2)
    if ind==1
      tl=title(sprintf('%i frequencies at random with overlap %i',Nf,No));
      set(tl,'FontWeight','normal')
      movev(tl,.2)
    end
  end

  % Cosmetics
  nolabels(ah(1:end-1),1)
  delete(xl(1:end-1))
  serre(ah,1/2,'down')
  figdisp([],'demo1',[],2)
end







