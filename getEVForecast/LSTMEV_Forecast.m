function [predEnergyTrans, predSOC] = LSTMEV_Forecast(forecastData, path)

    %     % Display for user
    %     disp('Validating the Neural Network model....');


    %% Read Input data
    % get building number
    building_num = num2str(forecastData.BuildingIndex(1));
    % load a '.mat' file
    load_name = '\EV_trainedLSTM_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');
    
   %% Forecast 
   
    XTest = table2array(forecastData).';
    predEnergyTrans = predict(net_Trans,XTest,'MiniBatchSize',1);
    predSOC = predict(net_SOC,XTest,'MiniBatchSize',1);

   
 
end

