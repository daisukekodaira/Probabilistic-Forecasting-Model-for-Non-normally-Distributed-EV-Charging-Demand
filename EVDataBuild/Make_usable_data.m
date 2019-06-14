clear;
clc;
%% Load data
filename1 = 'EVdataModifed_2.csv';
opts = detectImportOptions(filename1);
T = readtable(filename1,'ReadVariableNames',true,...
    'Format','%d %d %d %d %{dd/MM/yyyy}D %{HH:mm}D %{dd/MM/yyyy}D %{HH:mm}D %f %d %d %d %d');
% Erase the record in case that the EndTime is missing (still connected)
T = rmmissing(T,'DataVariables',{'EndTime'});
%% change format
information=table2array(T(:,1:4));
startdate= table2array(T(:,5));
starttime= table2array(T(:,6));
enddate =table2array(T(:,7));
endtime =table2array(T(:,8));
% totalkwh=table2array(T(:,9));
information2=table2array(T(:,9:13));
%% seperate date
%start
styear=year(startdate);
stmonth=month(startdate);
stday=day(startdate);
sthour=hour(starttime);
stminute=minute(starttime);
%end 
endyear=year(enddate);
endmonth=month(enddate);
endday=day(enddate);
endhour=hour(endtime);
endminute=minute(endtime);

data=[information styear stmonth stday sthour stminute endyear endmonth endday endhour endminute information2];
%% make csv file
csvwrite('predata.csv',data)
hedder = {'CargingEent', 'UserID', 'CPID', 'Connector', 'Startyear', 'StartMonth', 'StartDay', 'StartHour', 'StartQuarter',...
                  'EndYear', 'EndMonth', 'EndDay', 'EndHour', 'EndQuarter', 'TotalKW', 'Cost', 'Site', 'Group', 'Model'};
fid = fopen('predata.csv','wt');
fprintf(fid,'%s,',hedder{:});
fprintf(fid,'\n');
% Write data
fprintf(fid,['%d,', '%d,', '%d,', '%d,', '%d,', '%d,', '%d,', '%d,', '%d,', '%d,', '%d,',...
                     '%d,','%d,','%d,','%d,','%d,','%d,','%d,','%d,', '\n'], data');
fclose(fid);
