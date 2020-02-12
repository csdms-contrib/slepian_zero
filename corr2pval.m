function corr2pval(N,M)
% CORR2PVAL(N,M)
% 
% INPUT:
%
% N      sample size
% M      experiment size
% 
% Last modified by fjsimons-at-alum.mit.edu, 10/23/2019

% How high does a correlation coefficient need to be to be "significant"?
% As you will find out, CORRCOEF will give you a correlation coefficient and
% a "p-value" for significance. The p-value measures the probability of how
% high, in absolute value, a correlation coefficient as the one you have
% found exists between your observed variables - or even higher - can be in
% the ABSENCE of any actual correlation between those variables. In other
% words, it measures how good it can look - or even better - even when the
% variables are completely uncorrelated. 

% To get a feel for that value, create a set of independent (thus
% uncorrelated) identically distributed random variables, of the same size
% of your sample, but over many realizations, and compute their correlation
% coefficient. Make a histogram of their distribution. The p-value then, of
% any given actual set of observations, is the area under the histogram
% starting from the observed +/- absolute(value) down to either end of the
% axis. ALL those values are possible even under the null-hypothesis of
% absolutely NO correlation, and this gives you a feel for how high the
% observed correlation coefficient needs to be, whether positive or
% negative, for you to reject the observed correlation as "significant". So,
% here goes.

% The number of variables in your sample, if this were a SCRIPT
%N=5;
% The number of fake realizations that you make, if this were a SCRIPT
%M=400;

% Create a set of completely uncorrelated random variables
% each of them completely "random" and independently generated following
% a standard normal distribution
X=randn(N,M);
Y=randn(N,M);
% Measure all of their correlation coefficients
for index=1:M
  % This gives a correlation matrix between the index-th pair
  R=corrcoef(X(:,index),Y(:,index));
  % This is the correlation coefficient between every pair of variables
  r(index)=R(2);
end

% Make the histogram, specify the bin centers with Sturges' rule
a=1.5*round(log2(M)+1);
[b,c]=hist(r,a,linspace(min(r),max(r),a));
figure(1)
clf
ah(1)=subplot(211);
br(1)=bar(c,b,1);
xlim([min(r)-1e-2 max(r)+1e-2])
% Pretty it up
ah(1).XTick=     unique(round([ah(1).XTick min(r)+10*eps max(r)-10*eps]*100)/100);
ah(1).XTickLabel=unique(round([ah(1).XTick min(r)+10*eps max(r)-10*eps]*100)/100);
ah(1).TickDir='out';
t(1)=title('Histogram of correlation coefficients of uncorrelated variables');
% All those values are easily possible if there is NO correlation - we made
% all those data up and they were completely independently distributed!

% Now let's say your produce just one more set of observations, e.g.,
% your actual data - but the variables are still UNcorrelated
x=randn(N,1);
y=randn(N,1);
% Determine their correlation coefficient, but also get out the p-value
[Rxy,Pxy]=corrcoef(x,y);
rxy=Rxy(2);
pxy=Pxy(2);
% The area under the curve starting from the observed value down to the left
% or right extreme is the p-value in this model. So... make a new histogram
% from your testing set, mark the observed value, and find the proportion
% of the data that is even more extremely correlated even when no true
% correlation exists. Use HIST but insist on just two bins separated by
% the observed value rather than on a set NUMBER of bins. Use HISTC
e=[min([r rxy])-1e-1 -abs(rxy) abs(rxy) max([r rxy])+1e-1];
b=histc(r,e);
ah(2)=subplot(212);
br(2)=bar(e,b,'histc'); delete(findobj('Marker','*'))
xlim([min(r)-1e-2 max(r)+1e-2])
% The empirical p-value
pxy_e=sum(b([1 3]))/M;

t(2)=title(sprintf(...
    'observed r %6.3f theoretical p-value %6.3f empirical p-value %6.3f',...
    rxy,pxy,pxy_e));
% Mark the "observed" value on the x-axis of this second plot
ah(2).XTick     =unique(round([min(r)+10*eps -abs(rxy) abs(rxy) max(r)-10*eps]*100)/100);
ah(2).XTickLabel=unique(round([min(r)+10*eps -abs(rxy) abs(rxy) max(r)-10*eps]*100)/100);
ah(2).TickDir='out';

% Move the damn titles
t(1).Position=t(1).Position+[0 range(ah(1).YLim)/15 0];
t(2).Position=t(2).Position+[0 range(ah(2).YLim)/15 0];

% Print and inspect
print('-dpdf','-bestfit',sprintf('corr2pval_%3.3i_%3.3i',N,M))
