function edurban(zone)
% Makes a nice map of MERMAID surfacings over the years
%
% INPUT:
%
% zone    1 Polynesia in all its glory
%         2 The South China Sea
%         3 The Mediterranean
%         4 Japan
%
% See also CASCADIA, POLYNESIA
%
% Last modified by fjsimons-at-alum.mit.edu, 3/23/2025

% Read all the MERMAID files
yrs=[2018 2019 2020 2021 2022 2023 2024 2025];
lettrs='NNNNNPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPRRRRRRRRRRRRRRRRRTTT';
floats=[01 02 03 04 05 ...
              06 07 ...
              08 09 10 11 12 13    16 17 18 19 20 21 22 23 24 25 ...
              26 27 28 29    31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 ...
              50    52 53 54 ...
              01 02 03 04 05 06 07 ...
              58 59    61    63    65    67    69    71 72 73 ...
              100 101 102];
% You could use
cols=colororder;

dat=[]; lat=[]; lon=[];
for index=1:length(lettrs)
  mname=sprintf('%s0%3.3i',lettrs(index),floats(index));
  d=reshape(webread(sprintf(...
      'https://geoweb.princeton.edu/people/simons/SOM/%s_all.txt',mname))',120,[])';
  dat=[datetime(d(:, 9:28)) ; dat];
  lat=[str2num(d(:,29:42))  ; lat];
  lon=[str2num(d(:,43:54))  ; lon];
end

% The box
switch zone
  case 1
    c11=[160   30];
    cmn=[260  -50];
  case 2
    c11=[-10 50]
    cmn=[ 15 30]
  case 3
    c11=[105 22];
    cmn=[125  5];
  case 4
    c11=[130 40];
    cmn=[160 20];
end
% A bit of a margin for the continents and plate boundaries
wlo=10;

% The offset, if any required to fake anything
[upy,upx]=deal(0);

% Initialize the plot
clf
% Plot the topography and bathymetry
polynesia(c11,cmn,[-7000 2500])
ah=gca;
%[~,c]=plotcont(c11+[-1 1]*wlo,cmn+[1 -1]*wlo);
%p=plotplates(c11+[-1 1]*wlo,cmn+[1 -1]*wlo);
%set(c,'Color',grey)
hold on

% Go by year but plot them all on the same graph this time
for index=1:length(yrs)
  dlat=lat(year(dat)==yrs(index));
  dlon=lon(year(dat)==yrs(index));
  dlat=dlat+upy;
  dlon=dlon+[dlon<0]*360+upx;
  % Wrapping of colors
  wraps = @(x,n) (1 + mod(x-1, n));
  % Plot the MERMAID markers
  py(index)=plot(dlon,dlat,'o','MarkerSize',1,...
                 'MarkerFaceColor',cols(wraps(index,size(cols,1)),:),...
                 'MarkerEdgeColor',cols(wraps(index,size(cols,1)),:));
end

% Finalize the plot
hold off
axis([c11(1) cmn(1) cmn(2) c11(2)])
% Use numbers as strings for labels
legend(py,arrayfun(@num2str,yrs,'UniformOutput',0),'Location','NorthWest')
box on
%grid on
longticks(ah,2)
xl=xlabel('latitude');
yl=ylabel('longitude');

%exportfig(gcf,mfilename)
figdisp([],zone,[],2)



