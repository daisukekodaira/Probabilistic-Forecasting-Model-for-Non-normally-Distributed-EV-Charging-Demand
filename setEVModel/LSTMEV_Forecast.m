function [predEnergyTrans, predSOC] = LSTMEV_Forecast(forecastData, path)
 %% Read input data
    building_num = num2str(forecastData.BuildingIndex(1)); % distribute with building number 
    % Load mat files
    load_name = '\EV_trainedLSTM_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat'); 
    
    dataTestStandardized = (dataTest - mu) / sig;
    XTest = dataTestStandardized(1:end-1);
    
    net = predictAndUpdateState(net,XTrain);
[net,YPred] = predictAndUpdateState(net,YTrain(end));

numTimeStepsTest = numel(XTest);
for i = 2:numTimeStepsTest
    [net,YPred(:,i)] = predictAndUpdateState(net,YPred(:,i-1),'ExecutionEnvironment','cpu');
end

