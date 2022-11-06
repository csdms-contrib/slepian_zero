function constrained 
% Make some fake data
m=[1 3]';
x=rand(31,1);
G=gmat(x);
y=G*m+randn(length(x),1)/2;
% Calculate the least-squares fit line
mh=inv(G'*G)*G'*y;
% Plot the least-squares fit line
xp=[0 1];
yp=gmat(xp)*mh;
% Constrain the fit to go through a certain point
xs=0.7;
ys=2.5;
% Calculate the constrained least-squares fit line
mhc=inv([G'*G  [1 ; xs] ; [1 xs] 0])*[G'*y ; ys];
ypc=gmat(xp)*mhc(1:2);

% Plot the two-parameter space
a=linspace(0,5,100);
b=linspace(0,5,100);
[A,B]=meshgrid(a,b);
% Plot the sum of the squares of the misfit in this space
phi=reshape(sum([G*[A(:)' ; B(:)']-repmat(y,1,length(A(:)))].^2),size(A));

% Plot the linear constraints
v=reshape([1 xs]*[A(:)' ; B(:)']-ys,size(A));

% Calculate the modified misfit
phic=phi+2*mhc(3)*v;

ah(1)=subplot(221);
plot(x,y,'bo')
grid on
hold on
l(1)=plot(xp,yp,'b');
plot(xs,ys,'o','MarkerFaceColor','r','MarkerEdgeColor','r')
l(2)=plot(xp,ypc,'r');
hold off
xlabel('x')
ylabel('y=ax+b')
legend(l,{'unconstrained','constrained'},'Location','NorthWest')

ah(2)=subplot(222);
%imagesc(a,b,phi)
contourf(a,b,phi,[0:10 20:20:100])
axis image xy
hold on
plot(mh(1),mh(2),'o','MarkerFaceColor','w','MarkerEdgeColor','w')
plot(mhc(1),mhc(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
plot(xlim,[mh(2) mh(2)],'Color','w')
plot([mh(1) mh(1)],ylim,'Color','w')
hold off
colorbar
xlabel('a')
ylabel('b')
title('quadratic misfit')

ah(3)=subplot(223);
contourf(a,b,v,[-5:5])
axis image xy
hold on
[c,h]=contour(a,b,v,[0 0]);
set(h,'Color','r')
%clabel(c,h)
plot(mh(1),mh(2),'o','MarkerFaceColor','w','MarkerEdgeColor','w')
plot(mhc(1),mhc(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
hold off
colormap(parula(10))
colorbar
xlabel('a')
ylabel('b')
title('linear constraint')

ah(4)=subplot(224);
contourf(a,b,phic,[0:10 20:20:100])
axis image xy
hold on
plot(mh(1),mh(2),'o','MarkerFaceColor','w','MarkerEdgeColor','w')
plot(mhc(1),mhc(2),'o','MarkerFaceColor','r','MarkerEdgeColor','r')
plot(xlim,[mhc(2) mhc(2)],'Color','r')
plot([mhc(1) mhc(1)],ylim,'Color','r')
hold off
colormap(parula(10))
colorbar
xlabel('a')
ylabel('b')
title('modified misfit')

% Cosmetics
longticks(ah)

exportgraphics(gcf,'constrained.pdf')

function G=gmat(x)
G=[ones(length(x),1) x(:)];
