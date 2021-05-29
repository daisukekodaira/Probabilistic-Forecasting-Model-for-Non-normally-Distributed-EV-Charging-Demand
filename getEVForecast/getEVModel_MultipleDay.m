% ---------------------------------------------------------------------------
% EV prediction: Foecasting algorithm 
% June 17th, 2020 Updated by Daisuke Kodaira 
% Contact: daisuke.kodaira03@gmail.com
%
% function flag = demandForecast(shortTermPastData, ForecastData, ResultData)
%     flag =1 ; if operation is completed successfully
%     flag = -1; if operation fails.
%     This function depends on '.mat' files. If these files are not found return -1.
%     The output of the function is "resultEVData.csv"
% ----------------------------------------------------------------------------

function [PICoverRate, MAPE, RMSE, PIWidth, outTable] = getEVModel_MultipleDay(shortTermTable, predictorTable, targetTable)  
    % parameters
    buildingIndex = shortTermTable.BuildingIndex(1);
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1
    
    %% Error recognition: Check mat files exist
    name1 = [pwd, '\', 'EV_trainedKmeans_', num2str(buildingIndex), '.mat'];
    name2 = [pwd, '\', 'EV_trainedNeuralNet_', num2str(buildingIndex), '.mat'];
    name3 = [pwd, '\', 'EV_trainingData_', num2str(buildingIndex), '.mat'];
    name4 = [pwd, '\', 'EV_weight_', num2str(buildingIndex), '.mat'];
    if exist(name1) == 0 || exist(name2) == 0 || exist(name3) == 0 || exist(name4) == 0 
        flag = -1;
        disp('There are missing .mat files from setEV');
        return
    end
    
    %% Load mat files
    s(1).fname = 'EV_trainedKmeans_';
    s(2).fname = 'EV_trainedNeuralNet_';
    s(3).fname = 'EV_trainingData_';
    s(4).fname = 'EV_weight_';
    s(5).fname = num2str(buildingIndex);    
    extention='.mat';
    for i = 1:size(s,2)-1
        name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(pwd, [name(i).string extention]);
        load(matname);
    end
    
    %% Get individual prediction for test data
    % Two methods are combined
    %   1. k-menas
    %   2. Neural network
    [predData.IndEnergy(:,1), predData.IndSOC(:,1)]  = kmeansEV_Forecast(predictorTable, pwd);
    [predData.IndEnergy(:,2), predData.IndSOC(:,2)] = neuralNetEV_Forecast(predictorTable, pwd);  
    
    %% Get combined prediction result with weight for each algorithm
    % Prepare the tables to store the deterministic forecasted result (ensemble forecasted result)
    % Note: the forecasted results are stored in an hourly basis
    predData.EnsembleEnergy = NaN(size(predictorTable, 1), 1);            
    predData.EnsembleSOC = NaN(size(predictorTable, 1), 1);            
    
    records = size(predData.IndEnergy, 1);
    % generate ensemble forecasted result
    for i = 1:records
        hour =predictorTable.Hour(i)+1;   % transpose Hour from 0~23 to 1~24
        predData.EnsembleEnergy(i) = sum(weight.Energy(hour,:).*predData.IndEnergy(i, :));
        predData.EnsembleSOC(i) = sum(weight.SOC(hour,:).*predData.IndSOC(i, :));
    end
    % Get Prediction Interval
    % 1. Confidence interval basis method
    % Note: Method1 utilizes the error distribution derived from one month
    %            validation data which is not concained in the training process
    [predData.EnergyPImean, predData.EnergyPImin, predData.EnergyPImax] = getPI(predictorTable, predData.EnsembleEnergy, allData.errDistEnergy);
    [predData.EnergyPIBootmin, predData.EnergyPIBootmax] = getPIBootstrap(predictorTable, predData.EnsembleEnergy, allData.errDistEnergy);
    [predData.SOCPImean, predData.SOCPImin, predData.SOCPImax] = getPI(predictorTable, predData.EnsembleSOC, allData.errDistSOC);
    %     % 2. Neural Network basis method
    %     % Note: Method2 utilized the error distribution deriveved from all past
    %     %           data which is utilized for trining process in ensemble forecastin model 
    %     [predData.EnergyPImean, predData.EnergyPImin, predData.EnergyPImax] = getPINeuralNet(predictorTable, predData.EnsembleEnergy,  allData.errDistEnergy);
    
    
    %% Write  down the forecasted result in csv file
    outTable = [predictorTable, struct2table(predData), targetTable];

    %% Get forecast performance summary
    energyTransPI =  [predData.EnergyPImin, predData.EnergyPImax];
    energyTransPIBoot =  [predData.EnergyPIBootmin, predData.EnergyPIBootmax];

    socPI =  [predData.SOCPImin, predData.SOCPImax];
    % Energy demand (ensembled)
    [PICoverRate.ensemble, MAPE.ensemble, RMSE.ensemble, PIWidth.ensemble] = getDailyPerformance(energyTransPI, predData.EnsembleEnergy, targetTable.EnergyDemand);
    [PICoverRate.ensembleBoot, ~, ~, PIWidth.ensembleBoot] = getDailyPerformance(energyTransPIBoot, predData.EnsembleEnergy, targetTable.EnergyDemand);

    % Energy emand (k-means)
    [~, MAPE.kmeans, RMSE.kmeans, ~] = getDailyPerformance([], predData.IndEnergy(:,1), targetTable.EnergyDemand);
    % Energy demand (Neural Network)
    [~, MAPE.neuralNet, RMSE.neuralNet, ~] = getDailyPerformance([], predData.IndEnergy(:,2), targetTable.EnergyDemand);
    % SOC   
    %     [PICoverRate.ensemble, MAPE.ensemble] = getDailyPerformance(socPI, predData.EnsembleEnergy, targetTable.EnergyDemand, ci_percentage);
    
end
