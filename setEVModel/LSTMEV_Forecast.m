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
    predEnergyTrans = predict(trainedLSTM_EnergyTrans,forecastData);
    predSOC = predict(trainedLSTM_SOC,forecastData);
   
 
end