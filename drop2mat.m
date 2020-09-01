function varargout=drop2mat(fname)
% [t,d]=DROP2MAT(fname)
%
% Reads, and converts a CSV file from Kestrel Drop instruments to a MATLAB
% file including proper date-time variables. The format of the data line is
% presumed to be (everything being given in metric SI units) as: 2020-08-16
% 17:16:00,"24,9","61,3","24,8","16,9"
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
% SEE ALSO:
%
% MARK2MAT
% 
% EXAMPLE:
%
% drop2mat('demo1')
%
% TESTED ON:
%
% MATLAB Version: 9.4.0.813654 (R2018a)
% 
% Last modified by fjsimons-at-alum.mit.edu, 08/31/2020

if isempty(strfind(fname,'demo'))
  % Prepare to save the CSV file as a MAT file
  [aa,bb,cc]=fileparts(fname);
  ename=sprintf('%s.mat',bb);
  
  if exist(ename)~=2
    % Open the file
    fid=fopen(fname);

    % Read the first few lines as a "header"
    for index=1:5
      % These are all read in straight 
      h{index}=fgetl(fid);
    end

    % Read the rest as the "data"
    % DROP 3 FIRE has two more than DROP 2 HS, they'll be empty
    a=textscan(fid,'%q%q%q%q%q%q%q','Delimiter',',');

    % Close the file
    fclose(fid);

    % Convert the time stamps
    t=datetime(a{1});

    % Pick out the header variable names
    for index=1:3
      % Replace the blanks with nothing
      vnames=h{index}; vnames(abs(vnames)==32)='';
      % These are simple parameter value pairs
      [v1,v2]=strread(vnames,'%s%s','delimiter',',');

      % Start the actual data structure
      d.(char(v1))=char(v2);
    end

    % Pick out the data variable names
    vnames=h{4}; vnames(abs(vnames)==32)='';
    % You'll now know there are FOUR to SIX variables of interest (any empties?)
    [~,v1,v2,v3,v4,v5,v6]=strread(vnames,'%s%s%s%s%s%s%s','delimiter',',');

    % Pick out the unit name strings
    index=5;
    vnames=h{index}; vnames(abs(vnames)==32)='';
    % You'll now know there are FOUR to SIX units of interest (two empties?)
    [~,u1,u2,u3,u4,u5,u6]=strread(vnames,'%s%s%s%s%s%s%s','delimiter',',');

    % For the next loop, it's a DROP 2 or a DROP 3
    maxi=5+~isempty(u5)*2;
    
    % Give the variables their proper place
    for index=2:maxi
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

    % Save
    save(bb,'t','d')
  else 
    disp(sprintf('%s: %s existed',upper(mfilename),ename))
    load(ename)
  end

elseif strcmp(fname,'demo1')
%  [t,d]=drop2mat('export_fjsimons_2020_8_21_17_36_50.csv');
  [t,d]=drop2mat('export_fjsimons_2020_8_29_11_47_33.csv');
  if nargout==0
    % Make a picture
    col={'b' 'r' 'k'};
    clf
    ah=gca;
    yyaxis left
    tz='America/New_York'; 
    t.TimeZone=tz; 
    lb=plot(t,d.Temperature,col{1}); hold on
    index=0; maxrain=0; 
    for jday=229:240
      index=index+1;
      yyaxis left
      [dd,h]=guyotweather(jday); dd.Timestamp.TimeZone=tz;
      gh(index)=plot(dd.Timestamp,dd.AirTemp_C,col{2},'LineStyle','-','Marker','none');
      yyaxis right
      pc(index)=plot(dd.Timestamp,dd.RainAcc_mm,col{3},'LineStyle','-','Marker','none');
      maxrain=max(maxrain,max(dd.RainAcc_mm));
      [mrd,tmrd]=max(dd.RainAcc_mm);
      maxrainday(index)=dd.Timestamp(tmrd);
    end

    yyaxis left
    hold off; shrink(gca,1,1.1)
    xels=[dateshift(t(1),'start','Hour') dateshift(min(t(end),max(dd.Timestamp)),'end','Hour')];
    xells=xels(1):hours(12):xels(2); 
    try
      xlabs=sprintf('Princeton %s day, time [HH:mm]\n',nounder(tz));
    catch
      xlabs=sprintf('Princeton %s day, time [HH:mm]\n',tz);
    end
    try xlim(xels) ; catch xlim(datenum(xels)); end
    grid on; longticks(gca,2)
    yyaxis left 
    yl=ylabel(sprintf('Air temperature (%sC)',str2mat(176)));
    % The 'AutoUpdate','off' pair only works on the latest versions
    leg=legend('Leabrook Lane','Guyot Hall','Location','NorthWest',...
	       'AutoUpdate','off');

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
      set(gca,'XTick',xells); 
    catch
      xlim(datenum(xels)); 
      set(gca,'XTick',datenum(xells));
    end
    xl=xlabel(xlabs); 
    movev(xl,-range(ylim)/20); 
    datetick('x','mmmdd HH:MM','keepticks','keeplimits')
    
    % Make the ylabels the same color as what's being plotted
    ah.YAxis(1).Color=col{1};
    ah.YAxis(2).Color=col{3};
    % figdisp([],[],[],2)
  end
end

% Optional output
varns={t,d};
varargout=varns(1:nargout);
