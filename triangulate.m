% Illustrates "triangulation", let's call it

% Trouble is, I can't always assume I need the positive root.

% The man
a=[ 0  round(rand*4)];
% The bottom of the building
b=[round(rand*100) round(rand*10)-5];
% The top of the building
c=[b(1) round(rand*100)];

clf
% The points
t(1)=plot(a(1),a(2),'o');
hold on
t(2)=plot(b(1),b(2),'v');
t(3)=plot(c(1),c(2),'^');
t(4)=plot(0,0,'+');

% The lines
p(1)=plot(b([1 1]),[b(2) c(2)]);
p(2)=plot([a(1) b(1)],[a(2) b(2)]);
p(3)=plot([a(1) c(1)],[a(2) c(2)]);
p(4)=plot([0 a(1)],[0 a(2)]);
p(5)=plot([0 b(1)],[0 b(2)]);
p(6)=plot([a(1) b(1)],[a(2) a(2)]);

% Observed
set(p([4 5]),'Color','b','Linew',2)
% Unknown
set(p(1),'Color','r','Linew',2)
% Auxiliary
set(p([2 3 6]),'Color','k','LineS','--')

set(t(1),'MarkerFaceColor','b','MarkerEdgeC','b')
set(t(2:3),'MarkerFaceColor','r','MarkerEdgeC','r')

% The lengths etc
h=a(2);
H=c(2)-b(2);
D=sqrt(b(2)^2+b(1)^2);
% Compute the angles
alfa=atan2(c(2)-a(2),b(1));
bita=atan2(a(2)-b(2),b(1));
% Some auxiliary parameters from my diagram
A=c(2)-a(2);
B=a(2)-b(2);
L=b(1);
Dp=sqrt(B^2+L^2);
% This is the formula for Dp from the quadratic equation
% sbigD=sqrt(h^2*sin(bita)^2-(h^2-D^2));
sbigD=sqrt(D^2-h^2*cos(bita)^2);
Dpp=h*sin(bita)+sbigD;
Dpm=h*sin(bita)-sbigD;
% Take the positive root, we need to have a length
Hcomp=max(Dpp,Dpm)*(cos(bita)*tan(alfa)+sin(bita));

% Let's assume that D is bigger than h then we have slightly easier in
% always taking the plus sign here... sqrt(always positive) but if
% sqrt(tiny) may need the negative sign
Hcomp=(h*sin(bita)+sqrt(D^2-h^2*cos(bita)^2))*(cos(bita)*tan(alfa)+sin(bita));
title(sprintf('h = %3.1f ; D = %3.1f ; %s = %i ; %s = %i\n%s = %5.2f ; %s = %i',...
	      h,D,'\alpha',round(alfa*180/pi),'\beta',round(bita*180/pi),...
	      'Computed height',Hcomp,'Actual height',H))

% Check
difer(Hcomp-H)

% Cosmetics
shrink(gca,1.2,1.2)
longticks(gca,2)
xlabel('horizontal')
ylabel('vertical')
xlim(minmax([a(1) b(1) c(1)])+[-2 2])
ylim(minmax([a(2) b(2) c(2)])+[-2 2])
grid on
set(gca,'xtick',[a(1) b(1)])
set(gca,'ytick',unique([0 a(2) b(2) c(2)]))

