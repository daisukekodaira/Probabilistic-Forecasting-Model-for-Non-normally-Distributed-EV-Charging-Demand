function [predEnergyTrans, predSOC] = kmeansEV_Forecast(forecastData, path)  
       
    %% Format error check (to be modified)
%     % Check if the number of columns is the 10
%     % !!!! It would be flexible. we have to accept any number of columns later.
%     % "-1" if there is an error in the forecast_sunlight's data form, or "1"
%     [~,number_of_columns3] = size(forecastData);
%     if number_of_columns3 == 10
%         Alg_State3 = 1;
%     else
%         Alg_State3 = -1;
%     end

    %% Read inpudata
    building_num = num2str(forecastData(2,1)); % distribute with building number 
    % Load mat files
    load_name = '\EV_trainedKmeans_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');    

    %% Prediction based on the Naive Bayes classification model
    % Energy Transition
    TempArray = forecastData(~any(isnan(forecastData),2),:);         % Remove NaN from input dataset    
    labelEnergyTrans = nb_EnergyTrans.predict(TempArray(:,2:end));  % Distribute class label using attribute "predict".
    predEnergyTrans = c_EnergyTrans(labelEnergyTrans,:);    % Extract centroid as a predicted targe
    % SOC
    labelSOC = nb_SOC.predict(TempArray(:,2:end));
    predSOC = c_SOC(labelSOC,:);
end
