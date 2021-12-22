function [predEnergyTrans, predSOC] = LSTMEV_Forecast(forecastData, path)



    %% Read Input data
    % get building number
    building_num = num2str(forecastData.BuildingIndex(1));
    % load a '.mat' file
    load_name = '\EV_trainedLSTM_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');
    
   %% Forecast 
    predEnergyTrans = LSTMforecast(trainedLSTM_EnergyTrans,forecastData,meandata(1),sigdata(1),x);
    predSOC = LSTMforecast(trainedLSTM_SOC,forecastData,meandata(2),sigdata(2),x);
   
 
end

function forecastResult = LSTMforecast(trainedNetAll,forecastData,mu,sig,x)
    
   XTest = table2array(forecastData).';
    net = predictAndUpdateState(trainedNetAll,x);

    numTimeStepsTest = size(XTest,2);
    for i = 1:numTimeStepsTest
         [net,YPred(:,i)] = predictAndUpdateState(net,XTest(:,i),'ExecutionEnvironment','auto');
    end
    YPred = sig*YPred + mu;
    
   forecastResult = YPred;
   
end