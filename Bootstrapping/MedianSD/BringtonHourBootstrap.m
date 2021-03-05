%read csv file
 %this csv data converted from Quarter to Hour
 BringtonQuarterAndHour = readtable('BringtonQuarterToHour.csv');

%Extract only hour data
BringtonHour = BringtonQuarterAndHour(:,2);

%Exclude missing values
BringtonHourRemoveNaN = rmmissing(BringtonHour);

%Line Up By Hour

        for i = 1:370
            %size of 'BringtonHourRemoveNaN' is 8882x1,
            %8882/24 = 370
Brington00(i,:) = BringtonHourRemoveNaN(24*(i) - 23,1);
Brington01(i,:) = BringtonHourRemoveNaN(24*(i) - 22,1);
Brington02(i,:) = BringtonHourRemoveNaN(24*(i) - 21,1);
Brington03(i,:) = BringtonHourRemoveNaN(24*(i) - 20,1);
Brington04(i,:) = BringtonHourRemoveNaN(24*(i) - 19,1);
Brington05(i,:) = BringtonHourRemoveNaN(24*(i) - 18,1); 
Brington06(i,:) = BringtonHourRemoveNaN(24*(i) - 17,1);
Brington07(i,:) = BringtonHourRemoveNaN(24*(i) - 16,1);
Brington08(i,:) = BringtonHourRemoveNaN(24*(i) - 15,1);
Brington09(i,:) = BringtonHourRemoveNaN(24*(i) - 14,1);
Brington10(i,:) = BringtonHourRemoveNaN(24*(i) - 13,1);
Brington11(i,:) = BringtonHourRemoveNaN(24*(i) - 12,1);
Brington12(i,:) = BringtonHourRemoveNaN(24*(i) - 11,1);
Brington13(i,:) = BringtonHourRemoveNaN(24*(i) - 10,1);
Brington14(i,:) = BringtonHourRemoveNaN(24*(i) - 9,1);
Brington15(i,:) = BringtonHourRemoveNaN(24*(i) - 8,1);
Brington16(i,:) = BringtonHourRemoveNaN(24*(i) - 7,1);
Brington17(i,:) = BringtonHourRemoveNaN(24*(i) - 6,1);
Brington18(i,:) = BringtonHourRemoveNaN(24*(i) - 5,1);
Brington19(i,:) = BringtonHourRemoveNaN(24*(i) - 4,1);
Brington20(i,:) = BringtonHourRemoveNaN(24*(i) - 3,1);
Brington21(i,:) = BringtonHourRemoveNaN(24*(i) - 2,1);
Brington22(i,:) = BringtonHourRemoveNaN(24*(i) - 1,1);
Brington23(i,:) = BringtonHourRemoveNaN(24*(i),1);
        end
        
 %Declare independent variable name
 Brington00.Properties.VariableNames{'Hour'} = 'Hour00';
 Brington01.Properties.VariableNames{'Hour'} = 'Hour01';
 Brington02.Properties.VariableNames{'Hour'} = 'Hour02';
 Brington03.Properties.VariableNames{'Hour'} = 'Hour03';
 Brington04.Properties.VariableNames{'Hour'} = 'Hour04';
 Brington05.Properties.VariableNames{'Hour'} = 'Hour05';
 Brington06.Properties.VariableNames{'Hour'} = 'Hour06';
 Brington07.Properties.VariableNames{'Hour'} = 'Hour07';
 Brington08.Properties.VariableNames{'Hour'} = 'Hour08';
 Brington09.Properties.VariableNames{'Hour'} = 'Hour09';
 Brington10.Properties.VariableNames{'Hour'} = 'Hour10';
 Brington11.Properties.VariableNames{'Hour'} = 'Hour11';
 Brington12.Properties.VariableNames{'Hour'} = 'Hour12';
 Brington13.Properties.VariableNames{'Hour'} = 'Hour13';
 Brington14.Properties.VariableNames{'Hour'} = 'Hour14';
 Brington15.Properties.VariableNames{'Hour'} = 'Hour15';
 Brington16.Properties.VariableNames{'Hour'} = 'Hour16';
 Brington17.Properties.VariableNames{'Hour'} = 'Hour17';
 Brington18.Properties.VariableNames{'Hour'} = 'Hour18';
 Brington19.Properties.VariableNames{'Hour'} = 'Hour19';
 Brington20.Properties.VariableNames{'Hour'} = 'Hour20';
 Brington21.Properties.VariableNames{'Hour'} = 'Hour21';
 Brington22.Properties.VariableNames{'Hour'} = 'Hour22';
 Brington23.Properties.VariableNames{'Hour'} = 'Hour23';
 
 
 
 %Bootstrapp every Hour table

BringtonBoot00 = datasample(Brington00,size(Brington00,1));
BringtonBoot01 = datasample(Brington01,size(Brington01,1));
BringtonBoot02 = datasample(Brington02,size(Brington02,1));
BringtonBoot03 = datasample(Brington03,size(Brington03,1));
BringtonBoot04 = datasample(Brington04,size(Brington04,1));
BringtonBoot05 = datasample(Brington05,size(Brington05,1));
BringtonBoot06 = datasample(Brington06,size(Brington06,1));
BringtonBoot07 = datasample(Brington07,size(Brington07,1));
BringtonBoot08 = datasample(Brington08,size(Brington08,1));
BringtonBoot09 = datasample(Brington09,size(Brington09,1));
BringtonBoot10 = datasample(Brington10,size(Brington10,1));
BringtonBoot11 = datasample(Brington11,size(Brington11,1));
BringtonBoot12 = datasample(Brington12,size(Brington12,1));
BringtonBoot13 = datasample(Brington13,size(Brington13,1));
BringtonBoot14 = datasample(Brington14,size(Brington14,1));
BringtonBoot15 = datasample(Brington15,size(Brington15,1));
BringtonBoot16 = datasample(Brington16,size(Brington16,1));
BringtonBoot17 = datasample(Brington17,size(Brington17,1));
BringtonBoot18 = datasample(Brington18,size(Brington18,1));
BringtonBoot19 = datasample(Brington19,size(Brington19,1));
BringtonBoot20 = datasample(Brington20,size(Brington20,1));
BringtonBoot21 = datasample(Brington21,size(Brington21,1));
BringtonBoot22 = datasample(Brington22,size(Brington22,1));
BringtonBoot23 = datasample(Brington23,size(Brington23,1));

    
 
 %connect all Bootstrapped Hour Table
 BringtonBoot = horzcat(BringtonBoot00,BringtonBoot01,BringtonBoot02,...
     BringtonBoot03,BringtonBoot04,BringtonBoot05,BringtonBoot06,...
     BringtonBoot07,BringtonBoot08,BringtonBoot09,BringtonBoot10,BringtonBoot11,...
     BringtonBoot12,BringtonBoot13,BringtonBoot14,BringtonBoot15,BringtonBoot16,...
     BringtonBoot17,BringtonBoot18,BringtonBoot19,BringtonBoot20,BringtonBoot21,...
     BringtonBoot22,BringtonBoot23);
 
%Organize by date
BringtonBoot365Day = rows2vars(BringtonBoot);

%arrange in Time Series
%8880 = 24*370
BringtonBoot365Day(:,1) = [];
BringtonBoot365DayArray= table2array(BringtonBoot365Day);
BringtonBootTimeSeries = reshape(BringtonBoot365DayArray,[8880,1]);





%align data format about 
%'BuildingIndex' 'Year' 'Month' 'Day' 'Hour' 'DayInWeek' 'HolidayOrNot'
%'EnergyDemand' 'SOC'

%data amount and Frequency of repetition
AmountofData = size(BringtonBootTimeSeries(:,1));
HourRepeat = 24;
DayRepeat = 30;
MonthRepeat = 12;


%Make buildingIndex Table
BuildingIndex = ones(size(BringtonBootTimeSeries(:,1)));
BuildingIndexTable = array2table(BuildingIndex);

%Make DayInWeek,HolidayOrNot,SOC Table
DayInWeek = zeros(size(BringtonBootTimeSeries(:,1)));
DayInWeekTable = array2table(DayInWeek);

HolidayOrNot = zeros(size(BringtonBootTimeSeries(:,1)));
HolidayOrNotTable = array2table(HolidayOrNot);

SOC = zeros(size(BringtonBootTimeSeries(:,1)));
SOCTable = array2table(SOC); 


%Make Year Table
%from2017 to 2018
for i = 1:AmountofData
    Yearhairetu(i,1)=i;
     Year(i,1) = 2017 + idivide(uint64(Yearhairetu(i,1)),uint64(8640));
    
end
YearTable = array2table(Year);


%Make Month Table
%Rise every HourRepeat*DayRepeat cells And Return to 1 if the value over 12
%initial value is 1
for i = 1:AmountofData
    Monthhairetu (i,1) = mod(i,HourRepeat*DayRepeat*MonthRepeat);
    Month(i,1) = 1 + idivide(uint64(Monthhairetu(i,1)),uint64(HourRepeat*DayRepeat));
end
MonthTable = array2table(Month);


%Make Day Table
%Rise every HourRepeat cells And Return to 1 if the value over 30
%initial value is 1
for i = 1:AmountofData
    Dayhairetu (i,1) = mod(i,HourRepeat*DayRepeat);
    Day(i,1) = 1 + idivide(uint64(Dayhairetu(i,1)),uint64(HourRepeat));
end
DayTable = array2table(Day);


%Make Hour Table
%Rise every 1 cells And Return to 1 if the value over 12
for i = 1:AmountofData
    Hourhairetu (i,1) = mod(i,HourRepeat);
    Hour(i,1) =   idivide(uint64(Hourhairetu(i,1)),uint64(1)) ;
end
HourTable = array2table(Hour);



%array2table BringtonBootTimeSeries
BringtonBootTimeSeries = array2table(BringtonBootTimeSeries);

%connect tables for use in getEVForecast and setEVModel 
BringtonBootstrapLast = horzcat(BuildingIndexTable,YearTable,MonthTable,DayTable,HourTable,DayInWeekTable,HolidayOrNotTable,BringtonBootTimeSeries,SOCTable);
writetable(BringtonBootstrapLast,'BringtonBootstrapHour.csv')






 