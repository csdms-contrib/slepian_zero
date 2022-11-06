function totalleastsquares
% Sample size
N=24;
% Correlation, variance, variance

% Make some fake data, INTERCEPT then SLOPE
m=[1 2]';
% Wherever the independent variables ACTUALLY ARE
X=rand(N,1);
% Wherever the NOISY independent variables ARE
X=X+randn(length(X),1)/1;
% Make the dependent variables, NOISILY OBSERVED
Y=gmat(X)*m+randn(length(X),1)/1;

% Prediction interval
I1=minmax(X);
I2=minmax(Y);
I3=minmax([I1 I2]);

% Regress y on x
P1=polyfit(X,Y,1);
Y1=polyval(P1,I1);

% Regress x on y
P2=polyfit(Y,X,1);
Y2=polyval(P2,I2);

% Total least squares
P3=tls(X,Y);
Y3=polyval(P3,I3);

% Plot the two-parameter space
a=linspace(-3,3,100);
b=linspace(-3,3,100);
[A,B]=meshgrid(a,b);
% Plot the sum of the squares of the misfit for y on x, which is minimized
phi1=reshape(sum([gmat(X)*[A(:)' ; B(:)']-repmat(Y,1,length(A(:)))].^2),size(A));

% Plot the sum of the squares of the misfit for x on y, which is minimized
phi2=reshape(sum([gmat(Y)*[A(:)' ; B(:)']-repmat(X,1,length(A(:)))].^2),size(A));

% Plot the sum of the squares of the misfit measured perpendicular to the line
% which TLS does not actually minimize, but we will see
phi3=nan(prod(size(A)),1);
for index=1:prod(size(A))
    phi3(index)=sum(pointdist(X,Y,[],[],[],[B(index) A(index)]).^2);
end
phi3=reshape(phi3,size(A));

% Plotting
subplot(221)
plot(X,Y,'o','MarkerSize',3,'MarkerFaceColor','r','MarkerEdgeColor','r');
hold on
p1=plot(I1,Y1,'Color',grey);
p2=plot(Y2,I2,'Color',grey);
pp=plot(I3,Y3,'b-');
% The truth, a line
pt=plot(I3,m(1)+m(2)*I3,'r');
% Zero axis to read off intercept for the truth line
plot([0 0],ylim,'k:')
plot(xlim,[m(1) m(1)],'k:')
% Zero axis to read off slope of the truth line
plot([1 1],ylim,'k:')
plot(xlim,[m(1) m(1)]+[m(2) m(2)],'k:')
hold off
title(sprintf('truth %i %i | TLS %4.2f %4.2f',m(1),m(2),P3(2),P3(1)))
xlim(I1)
ylim(I2)
legend([pp pt],'TLS','truth','Location','NorthWest')

ah(2)=subplot(222);
plotphi(a,b,phi1,P1)
title(sprintf('quadratic misfit y on x | OLS1 %4.2f %4.2f',P1(2),P1(1)))
xlabel('intercept of y=a+bx')
ylabel('slope of y=a+bx')
% Plot the truth
hold on
plot(m(1),m(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
hold off
text(min(a)+range(a)/30,min(b)+range(b)/30,...
    sprintf('model misfit %4.2f',norm(P1-[m(2) m(1)])))

ah(3)=subplot(223);
plotphi(a,b,phi2,P2)
title(sprintf('quadratic misfit x on y | OLS2 %4.2f %4.2f',-P2(2)/P1(1),1/P2(1)))
xlabel('intercept of x=a+by')
ylabel('slope of x=a+by')
% Plot the truth in this space
hold on
plot(-m(1)/m(2),1/m(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
hold off
text(min(a)+range(a)/30,min(b)+range(b)/30,...
    sprintf('model misfit %4.2f',norm(P2-[1/m(2) -m(1)/m(2)])))

ah(4)=subplot(224);
plotphi(a,b,phi3,P3)
title(sprintf('quadratic misfit perpendicular | TLS %4.2f %4.2f',P3(2),P3(1)))
xlabel('intercept of y=a+bx')
ylabel('slope of y=a+bx')
% Plot the truth in this space
hold on
plot(m(1),m(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
hold off
text(min(a)+range(a)/30,min(b)+range(b)/30,...
    sprintf('model misfit %4.2f',norm(P3-[m(2) m(1)])))

% The design matrix for a line
function G=gmat(x)
G=[ones(length(x),1) x(:)];

% Plots the quadratic misfit, however defined, and one special point
function plotphi(a,b,phi,P)
contourf(a,b,phi,[0:10 20:20:100])
axis image xy
hold on
plot(P(2),P(1),'o','MarkerFaceColor','w','MarkerEdgeColor','w')
plot(xlim,[P(1) P(1)],     'Color','w')
plot(     [P(2) P(2)],ylim,'Color','w')
hold off
colorbar
