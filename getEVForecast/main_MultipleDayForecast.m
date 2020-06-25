clear all; clc; close all;

% Forecasting is performed on a daily basis
% - If we have 30 days to be forecasted ('days' as following), we get 30 independent results.

% Read Data
allPastData = readtable('allPastEVData.csv');

% Parameters
days = 3;  % how many days to be repeatedly forecasted
Nsteps = size(allPastData,1); 

for i = 1:days
    disp(['Processing..... ', num2str(i), '/', num2str(days)])
    % Split the data
    % If days = 30, each Table is as following;
    % short: from [end - 96*30 - 96*7] -> [end - 96*29 - 96*7]
    %            to     [end - 96*30] -> [end -96*29]
    % forecast: from [end - 96*30] -> [end - 96*29]
    %                to [end - 96*29] -> [end - 96*28]
    forecastStart = Nsteps - 96*(days-(i-1)) + 1;
    forecastEnd = forecastStart + 95;
    shortTermEnd = forecastStart - 1; 
    shortTermStart = shortTermEnd - 96*7 + 1;  
    
    shortTermTable = allPastData(shortTermStart:shortTermEnd, :); % 1 week more 
    forecastTable = allPastData(forecastStart:forecastEnd, 1:8);  % 1 day more
    targetTable = allPastData(forecastStart:forecastEnd, 9:10);    % the same as forecastTable
    
    [PICoverRate, MAPE, outTable] = getEVModel_MultipleDay(shortTermTable, forecastTable, targetTable);   
    resultSummary.PIcoverRate(i, 1) = PICoverRate.ensemble;
    resultSummary.MAPE(i, 1) = MAPE.ensemble;
    resultSummary.MAPE(i, 1) = MAPE.kmeans;
    resultSummary.MAPE(i, 1) = MAPE.neuralNet;
    
    if i == 1
        forecastedResult = outTable;
    else
        forecastedResult = [forecastedResult; outTable];
    end
end

writetable(forecastedResult, 'resultEVData.csv');
writetable(struct2table(resultSummary), 'resultSummary.csv');
