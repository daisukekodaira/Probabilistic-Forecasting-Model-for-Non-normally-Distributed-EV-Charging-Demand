function [predEnergyTrans, predSOC] = kmeansEV_Forecast(forecastData, path)
    %% Read inpudata
    building_num = num2str(forecastData(2,1)); % distribute with building number 
    % Load mat files
    load_name = '\EVmodel_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');    

    %% Prediction based on the Naive Bayes classification model
    TempArray = forecastData(~any(isnan(forecastData),2),:);         % Remove NaN from input dataset    
    labelEnergyTrans = nb_EnergyTrans.predict(TempArray(:,2:end));  % Distribute class label using attribute "predict".
    predEnergyTrans = c_EnergyTrans(labelEnergyTrans,:);    % Extract centroid as a predicted target
    
    %% Prediction
    labelSOC = nb_SOC.predict(TempArray(:,2:end));
    predSOC = c_SOC(labelSOC,:);
end
