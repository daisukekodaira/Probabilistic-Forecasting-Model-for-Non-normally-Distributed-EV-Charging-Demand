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
    %% Forecast
    XTest = table2array(forecastData).';
    net_Trans = predictAndUpdateState(net_Trans,x);
    net_SOC = predictAndUpdateState(net_SOC,x);

    numTimeStepsTest = size(XTest,2);
    for i = 1:numTimeStepsTest
         [net_Trans,predEnergyTrans(:,i)] = predictAndUpdateState(net_Trans,XTest(:,i),'ExecutionEnvironment','auto');
    end
    predEnergyTrans = sig_Trans*predEnergyTrans + mu_Trans;
    
    for i = 1:numTimeStepsTest
         [net_SOC,predSOC(:,i)] = predictAndUpdateState(net_SOC,XTest(:,i),'ExecutionEnvironment','auto');
    end
    predSOC = sig_SOC*predSOC + mu_SOC;
    

   
 
end

