function varargout=venusmle(spex,indr)
% [ah,thhats]=VENUSMLE(spex,indr)
%
% Loads and plots Venus Whittle Mater maximum-likelihood results
%
% INPUT:
%
% spex     Specific indices to plot, between 1 and 77, default: all
% indr     Specific region type to plot, between 1 and 4
%
% OUTPUT:
%
% ah       Axis handles
% thhats   The estimates
% ec       The handles to the ellipses
% p        The handles to the ellipse centers
%
% EXAMPLE:
%
% [ah,thhats]=venusmle(skip([1:77],[6 21 31 42 72 36 52 58]));
% The skips after 72 are for axis setting and could be restored
%
% Last modified by fjsimons-at-alum.mit.edu, 07/21/2026
 
%     1 Region number
%     2 degrees of freedom K
%   3-4 sigma^2 [km^2] | 1 s.d. sigma^2 [km^2]
%   5-6 nu | 1 s.d nu
%   7-8 rho [km] | 1 s.d. rho [km]
%  9-11 cov{sigma^2,nu} | cov{sigma^2,rho} | cov{nu,rho}
% 12-17 c0, c1, c2, c11, c12, c22 polynomial fit coefficients
%       c0 + c1*y + c2*x + c11*y^2 + c12*y*x + c22*x^2

defval('spex',1:77)
defval('indr',[])

% Load the data
vmle=load('vmleres_20-Jul-2026_interiors.csv');

% Turn into covariance matrix everywhere, not standard deviation
vmle(spex,[4 6 8])=vmle(spex,[4 6 8]).^2;
% Make the crosshaired crossplots
[ah,o1,o2,ec,ep,p]=mlexplos(vmle(spex,[3 5 7]),vmle(spex,[4 6 8 9 10 11]),...
                          {'variance{ } \sigma^2 [km^2]','smoothness{ } \nu','range{ } \rho [km]'});

% Cleanup
delete(o1)
delete(o2)

for index=1:length(ah)
    axes(ah(index))
    axis tight
    grid on
    box on
end

% Cosmetics
set(ah([1]),'yscale','log')
set(ah([3]),'xscale','log')

axes(ah(1))
xel=xlim;
xlim([-max(xel)/20 max(xel)])
xlim([-0.2 2])
ylim([0.25 2])
ah(1).YTick=[0.25 0.5 1 1.5 2];
ah(1).YTickLabel=[0.25 0.5 1 1.5 2];

axes(ah(2))
xel=xlim;
xlim([0 max(xel)])
xlim([-max(xel)/20 max(xel)])
xlim([-0.2 2])
ylim([-75 850])
ah(2).YTick=[0:200:800];
ah(2).YTickLabel=[0:200:800];

axes(ah(3))
ylim([-75 850])
xlim([0.25 2])
ah(3).XTick=[0.25 0.5 1 1.5 2];
ah(3).XTickLabel=[0.25 0.5 1 1.5 2];
ah(3).YTick=[0:200:800];
ah(3).YTickLabel=[0:200:800];

% Region names - all
rnames={'Aino Planitia','Akhatamar Planitia','Alma-Merghen Planitia','Alpha Regio','Ananke Tessera','Artemis Corona','Asteria Regio','Atalanta Planitia','Athena Tessera','Atla Regio','Audra Planitia','Bell Regio','Bereghinya Planitia','Beta Regio','Dione Regio','East Eistla Regio','East Helen Planitia','Fortuna Tessera','Ganiki Planitia','Gegute Tessera','Hecate Chasma','Hinemoa Planitia','Hyndla Regio','Imapinua Planitia','Imdr Regio','Ishkus Regio','Kanykey Planitia','Kawelu Planitia','Kubebe Corona','Lada Terra','Laima Tessera','Laimdota Planitia','Lakshmi Planum','Laufey Regio','Lavinia Planitia','Leda Planitia','Llorona Planitia','Louhi Planitia','Lowana Planitia','Lower Guinevere Planitia','Manatum Tessera','Maxwell Mons','Metis Mons','Mugazo Planitia','Navka Planitia','Neringa Regio','Niobe Planitia','Nsomeka Planitia','Nuptadi Planitia','Ovda Regio','Pandrosos Dorsum','Parga Chasma','Pasom-mana Tessera','Phoebe Regio','Rusalka Planitia','Salus Tessera','Sedna Planitia','Snegurochka Planitia','Sogolon Planitia','Tahmina Planitia','Tellus Regio','Tethus Regio','Themis Regio','Thetis Regio','Tilli-Hanum Planitia','Tinatin Planitia','Ulfrun Regio','Unelanuhi Dorsum','Upper Guinevere Planitia','Vellamo Planitia','Wawalag Planitia','East Aphrodite Terra','West Aphrodite Terra','West Eistla Regio','West Helen Planitia','West Ishtar Terra','Zhibek Planitia'};

% Region names - all new - verified once (categories) - verified twice (table_vroi)
rnames={'lava plain','lava plain','lava plain','tessera','tessera','corona','tessera','lava plain / mixture','tessera','volcanic rise','lava plain / mixture','volcanic rise','lava plain','volcanic rise','volcanic rise','volcanic rise / corona','lava plain','tessera','lava plain','tessera','chasma / corona','lava plain','volcanic rise / tessera','lava plain','volcanic rise','volcanic rise','lava plain','lava plain / mixture','lava plain / mixture','volcanic rise / mixture','tessera','lava plain','lava plain','volcanic rise','lava plain','lava plain','lava plain','lava plain','lava plain','lava plain / mixture','tessera','volcanic rise','volcanic rise / corona','lava plain','lava plain','volcanic rise','lava plain / tessera','lava plain / mixture','lava plain','tessera','volcanic rise / mixture','corona / chasma','tessera','tessera / mixture','lava plain','tessera','lava plain','lava plain','lava plain','lava plain','tessera','tessera','volcanic rise / mixture','tessera','lava plain','lava plain / mixture','volcanic rise / corona','lava plain','lava plain / mixture','lava plain','lava plain','corona / chasma','volcanic rise / mixture','volcanic rise','lava plain','tessera / mixture','lava plain'};

% Region names - only those plotted
rnamespex=rnames(spex);

% Feature callout - all
fcallout={'Planitia','Tessera','Regio','Corona'};
% Feature callout - allnew
fcallout={'lava plain','tessera','chasma','corona'};
% chasma/corona
% volcanicrise

% Feature color - need to streamline into arrays
cone='b';   ip=0; lp=[];
ctwo='r';   it=0; lt=[];
cthree='m'; ic=0; lc=[];
cfour='g';  ir=0; lr=[];
 
% Colors
set(p,'MarkerSize',2)
set(p,'MarkerEdgeColor',grey)
set(ec,'Color',grey)

% Need to build in failsafe in case it comes up empty
for index=1:length(spex)
    if strfind(rnamespex{index},fcallout{1})
        set(p(index,:),'Marker','s')
        set(p(index,:),'MarkerSize',3)
        set(p(index,:),'MarkerFaceColor',cone)
        set(p(index,:),'MarkerEdgeColor',cone)
        set(ec(index,:),'Color',cone)
        ip=ip+1;
        iplast=index;
        lp=[lp index];
    elseif strfind(rnamespex{index},fcallout{2})
        set(p(index,:),'Marker','v')
        set(p(index,:),'MarkerSize',3)
        set(p(index,:),'MarkerFaceColor',ctwo)
        set(p(index,:),'MarkerEdgeColor',ctwo)
        set(ec(index,:),'Color',ctwo)
        it=it+1;
        itlast=index;
        lt=[lt index];
    elseif strfind(rnamespex{index},fcallout{3})
        set(p(index,:),'Marker','^')
        set(p(index,:),'MarkerSize',3)
        set(p(index,:),'MarkerFaceColor',cfour)
        set(p(index,:),'MarkerEdgeColor',cfour)
        set(ec(index,:),'Color',cfour)
        ir=ir+1;
        irlast=index;
        lr=[lr index];
    elseif strfind(rnamespex{index},fcallout{4})
        set(p(index,:),'Marker','o')
        set(p(index,:),'MarkerSize',3)
        set(p(index,:),'MarkerFaceColor',cthree)
        set(p(index,:),'MarkerEdgeColor',cthree)
        set(ec(index,:),'Color',cthree)
        ic=ic+1;
        iclast=index;
        lc=[lc index];
    end
end

% Tinize
shrink(ah,1,2)

% Legendize in order of occurrence counts
axes(ah(3))

al=legend(p([iplast irlast itlast iclast],3),fcallout{[1 3 2 4]});

% Take off those you did NOT pick - from the proper index
if indr==1
    delete([        p(lt,:)' p(lr,:)' p(lc,:)' ...
                    ec(lt,:)' ec(lr,:)' ec(lc,:)'])
elseif indr==2
    delete([p(lp,:)'         p(lr,:)' p(lc,:)' ...
            ec(lp,:)'         ec(lr,:)' ec(lc,:)'])
elseif indr==3
    delete([p(lp,:)' p(lt,:)'         p(lc,:)'...
            ec(lp,:)' ec(lt,:)'         ec(lc,:)'])
elseif indr==4
    delete([p(lp,:)' p(lt,:)' p(lr,:)'        ...
            ec(lp,:)' ec(lt,:)' ec(lr,:)'        ])
else
    indr=0;
end


% Summarize
disp(sprintf('%2.2i planitiae\n%2.2i tesserae\n%2.2i regiones\n%2.2i coronae',ip,it,ir,ic))

% The estimates
thhats=vmle(spex,[3 5 7]);

% The figure with the index of the region
figdisp(mfilename,indr,[],2)

% Optional output
varns={ah,thhats,ec,p};
varargout=varns(1:nargout);

