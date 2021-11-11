function [predEnergyTrans, predSOC] = LSTMEV_Forecast(forecastData, path)



    %% Read Input data
    % get building number
    building_num = num2str(forecastData.BuildingIndex(1));
    % load a '.mat' file
    load_name = '\EV_trainedLSTM_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');
    
   %% Forecast 
    forecastData = table2array(forecastData).';
    predEnergyTrans = LSTMforecast(trainedLSTM_EnergyTrans,forecastData,meandata(1),sigdata(1));
    predSOC = LSTMforecast(trainedLSTM_SOC,forecastData,meandata(2),sigdata(2));
   
 
end

function forecastResult = LSTMforecast(trainedNetAll,forecastData,mu,sig)
   
    trainedNetAll = resetState(trainedNetAll);
    trainedNetAll = predictAndUpdateState(trainedNetAll,forecastData);
    numTimeStepsTest = size(forecastData,2);
    for i = 1:numTimeStepsTest
         [trainedNetAll,YPred(:,i)] = predictAndUpdateState(trainedNetAll,forecastData(:,i),'ExecutionEnvironment','auto');
    end
    
    YPred = sig*YPred + mu;
    
    forecastResult = YPred;
    
end