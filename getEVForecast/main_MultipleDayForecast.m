clear all; clc; close all;

% Forecasting is performed on a daily basis
% - If we have 30 days to be forecasted ('days' as following), we get 30 independent results.

% Read Data
allPastData = readtable('allPastEVData.csv');

% Parameters
days = 30;  % how many days to be repeatedly forecasted

for i = 1:days
    % Split the data
    shortTermEVData = allPastData(end-(96*days+96*7), :); % 1 week more 
    forecastEVData = allPastData(end-(96*days+96*1), 1:8);  % 1 day more
    fileNameForResult = strcart(resulEVDatanum, '_', num2char(i));

    y_pred = getEVModel_MultipleDay([pwd,'\','shortTermEVData.csv'],...
                                        [pwd,'\','forecastEVData.csv'],...
                                        [pwd,'\','resultEVData.csv']);
                    
end