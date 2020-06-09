% ---------------------------------------------------------------------------
% EV prediction: Foecasting algorithm 
% 6th March,2019 Updated by Daisuke Kodaira 
% Contact: daisuke.kodaira03@gmail.com
%
% function flag = demandForecast(shortTermPastData, ForecastData, ResultData)
%     flag =1 ; if operation is completed successfully
%     flag = -1; if operation fails.
%     This function depends on demandModel.mat. If these files are not found return -1.
%     The output of the function is "ResultData.csv"
% ----------------------------------------------------------------------------

function forecastResult = getEVModel(shortTermPastData, forecastData, folderpath)
    %% Load mat files
    buildingIndex = shortTermPastData(1,1);
    s(1).fname = 'EVmodel_';
    s(2).fname = 'EnergyTransErrDist_';
    s(3).fname = 'SOCErrDist_';
    s(4).fname = 'EVpsoCoeff_';
    s(5).fname = num2str(buildingIndex);    
    extention='.mat';
    for i = 1:size(s,2)-1
        name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(folderpath, [name(i).string extention]);
        load(matname);
    end

    %% Get individual prediction for test data
    % Two methods are combined
    %   1. k-menas
    %   2. Neural network
    [PredEnergyTrans_kmeans(:,1), PredSOC_kmeans(:,1)]  = kmeansEV_Forecast(forecastData, folderpath);
    %     [PredEnergyTrans_Valid(1).data(:,1), PredSOC_Valid(1).data(:,1)]  = NeuralNetwork_Forecast(predictors, path);
    PredEnergyTrans(1).data(:,1) =  PredEnergyTrans_kmeans(:,1);
    PredSOC(1).data(:,1) =  PredSOC_kmeans(:,1);
    
    %% Get combined prediction result with weight for each algorithm
    for i = 1:size(PredEnergyTrans,1)
        if i == 1
            DetermPredEnergyTrans = coeff(i).*PredEnergyTrans(i).data;
            DetermPredSOC = coeff(i).*PredSOC(i).data;
        else
            DetermPredEnergyTrans = DetermPredEnergyTrans + coeff(i).*PredEnergyTrans(i).data;
            DetermPredSOC = DetermPredSOC + coeff(i).*PredSOC(i).data;  
        end
    end
        
    % Get Prediction Interval 
    % Input: 
    %   1. Deterministic forecasting result
    %   2. Predictors
    %   3. Err distribution (24*4 matrix)
    [EnergyTransPImean, EnergyTransPImin, EnergyTransPImax] = getPI(DetermPredEnergyTrans, shortTermPastData, EnergyTransErrDist);
    [SOCPImean, SOCPImin, SOCPImax] = getPI(DetermPredSOC, shortTermPastData, SOCErrDist);
    forecastResult.Energy = [EnergyTransPImean EnergyTransPImin EnergyTransPImax];
    forecastResult.SOC = [SOCPImean SOCPImin SOCPImax];

    
    
end
