function varargout=drop2mat(fname)
% [t,d]=DROP2MAT(fname)
%
% Reads, and converts a CSV file from the Kestrel Drop instrument to a
% MATLAB file including proper date-time variables. The format of the data
% line is presumed to be (everything being given in metric SI units) as: 
% 2020-08-16 17:16:00,"24,9","61,3","24,8","16,9"
%
% INPUT:
%
% fname       A complete file name string
%
% OUTPUT:
%
% t           The timestamp as a DATETIME array
% d           The data as a STRUCTURE array
%
% EXAMPLE:
%
% drop2mat('demo1')
%
% Last modified by fjsimons-at-alum.mit.edu, 08/20/2020

if isempty(strfind(fname,'demo'))
  % Preapre to save the CSV file as a MAT file
  [a,b,c]=fileparts(fname);
  ename=sprintf('%s.mat',b);
  
  if exist(ename)~=2 
    % Open the file
    fid=fopen(fname);

    % Read the first few lines as a "header"
    for index=1:5
      % These are all read in straight 
      h{index}=fgetl(fid);
    end

    % Read the rest as the "data"
    a=textscan(fid,'%q%q%q%q%q','Delimiter',',');

    % Convert the time stamps
    t=datetime(a{1});

    % Pick out the header variable names
    for index=1:3
      vnames=h{index}; vnames(abs(vnames)==32)='';
      % These are simple parameter value pairs
      [v1,v2]=strread(vnames,'%s%s','delimiter',',');
				% Start the actual data structure
				d.(char(v1))=char(v2);
    end

    % Pick out the data variable names
    vnames=h{4}; vnames(abs(vnames)==32)='';
    % You'll now know there are FOUR variables of interest
    [~,v1,v2,v3,v4]=strread(vnames,'%s%s%s%s%s','delimiter',',');

    % Pick out the unit name strings
    index=5;
    vnames=h{index}; vnames(abs(vnames)==32)='';
    % You'll now know there are FOUR variables of interest
    [~,u1,u2,u3,u4]=strread(vnames,'%s%s%s%s%s','delimiter',',');

    % Give the variables their proper place
    for index=2:5
      % Don't redo the time, you've got it already
      b=char(a{index});
      % Comma goes to decimal point
      b(abs(b)==44)='.';
      % Final assignment to human-intelligible variables
      c{index}=str2num(b);
      % Hark back to the old spitout subfunction
      eval(sprintf('d.(char(v%i))=c{%i};',index-1,index))

      % Give the units their proper place
      eval(sprintf('w=strcat(char(v%i),''%s'');',index-1,'Unit'))
      eval(sprintf('d.(char(w))=char(u%i);',index-1))
    end

    % Close the file
    fclose(fid);
    % Save
    save(b,'t','d')
  else 
    disp(sprintf('%s: %s existed',upper(mfilename),ename))
    load(ename)
  end

  % Optional output
  varns={t,d};
  varargout=varns(1:nargout);
elseif strcmp(fname,'demo1')
  [t,d]=drop2mat('export_fjsimons_2020_8_20_19_13_54.csv');
  col={'b' 'r' 'k'};
  clf
  ah=gca;
  yyaxis left
  tz='America/New_York'; 
  t.TimeZone=tz; 
  lb=plot(t,d.Temperature,col{1}); hold on
  index=0; maxrain=0; 
  for jday=229:232
    index=index+1;
    yyaxis left
    [dd,h]=guyotweather(jday); dd.Timestamp.TimeZone=tz;
    gh(index)=plot(dd.Timestamp,dd.AirTemp_C,col{2});
    yyaxis right
    pc(index)=plot(dd.Timestamp,dd.RainAcc_mm,col{3});
    maxrain=max(maxrain,max(dd.RainAcc_mm));
    [mrd,tmrd]=max(dd.RainAcc_mm);
    maxrainday(index)=dd.Timestamp(tmrd);
  end

  yyaxis left
  hold off; shrink(gca,1,1.1)
  xels=[dateshift(t(1),'start','Hour') dateshift(min(t(end),max(dd.Timestamp)),'end','Hour')];
  xells=xels(1):hours(12):xels(2); 
  xlabs=sprintf('Princeton %s day, time [HH:mm]\n',nounder(tz));
  try xlim(xels) ; catch xlim(datenum(xels)); end
  grid on; longticks(gca,2)
  yyaxis left 
  yl=ylabel(sprintf('Air temperature (%sC)',str2mat(176)));
  leg=legend('Leabrook Lane','Guyot Hall','Location','NorthWest');

  yyaxis right
  yl=ylabel(sprintf('Rain accumulation (mm)'));
  ylim([0 maxrain*2])
  hold on
  for index=1:length(maxrainday)
    plot([maxrainday(index) maxrainday(index)],ylim,':')
  end
  hold off
  try
    xlim(xels)
    set(gca,'XTick',xells,'XTickLabel',xells); 
  catch
    xlim(datenum(xels)); 
    set(gca,'XTick',datenum(xells),'XTickLabel',datenum(xells)); 
  end
  xl=xlabel(xlabs); 
  movev(xl,-range(ylim)/20); 
  datetick('x','mmmdd HH:MM','keepticks','keeplimits')
    
  % Make the ylabels the same color as what's being plotted
  ah.YAxis(1).Color=col{1};
  ah.YAxis(2).Color=col{3};
  figdisp([],[],[],2)
end
