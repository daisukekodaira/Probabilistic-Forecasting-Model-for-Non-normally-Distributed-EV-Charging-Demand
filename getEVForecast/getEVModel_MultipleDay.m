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

function flag = getEVModel_MultipleDay(shortTermPastData, forecastData, resultFilePath)
    tic;
    
    %% Error check and Load input datathe 
    if (strcmp(shortTermPastData, 'NULL') == 0) && (strcmp(forecastData, 'NULL') == 0)
        % if the filename is exsit
        shortTerm = readtable(shortTermPastData);
        predictorTable = readtable(forecastData);
    else
        % if the file name doesn't exsit
        flag = -1;  % return error
        return
    end   
    
    % parameters
    buildingIndex = shortTerm.BuildingIndex(1);
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1
    
    %% Load .mat files from give path of "shortTermPastData"
    path = fileparts(shortTermPastData);

    %% Error recognition: Check mat files exist
    name1 = [path, '\', 'EV_trainedKmeans_', num2str(buildingIndex), '.mat'];
    name2 = [path, '\', 'EV_trainedNeuralNet_', num2str(buildingIndex), '.mat'];
    name3 = [path, '\', 'EV_errDist_', num2str(buildingIndex), '.mat'];
    name4 = [path, '\', 'EV_weight_', num2str(buildingIndex), '.mat'];
    if exist(name1) == 0 || exist(name2) == 0 || exist(name3) == 0 || exist(name4) == 0
        flag = -1;
        return
    end
    
    %% Load mat files
    s(1).fname = 'EV_trainedKmeans_';
    s(2).fname = 'EV_trainedNeuralNet_';
    s(3).fname = 'EV_errDist_';
    s(4).fname = 'EV_weight_';
    s(5).fname = num2str(buildingIndex);    
    extention='.mat';
    for i = 1:size(s,2)-1
        name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(path, [name(i).string extention]);
        load(matname);
    end
    
    %% Get individual prediction for test data
    % Two methods are combined
    %   1. k-menas
    %   2. Neural network
    [predData.IndEnergy(:,1), predData.IndSOC(:,1)]  = kmeansEV_Forecast(predictorTable, path);
    [predData.IndEnergy(:,2), predData.IndSOC(:,2)] = neuralNetEV_Forecast(predictorTable, path);  
    
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
    [predData.EnergyPImean, predData.EnergyPImin, predData.EnergyPImax] = getPI(predictorTable, predData.EnsembleEnergy, errDist.Energy);
    [predData.SOCPImean, predData.SOCPImin, predData.SOCPImax] = getPI(predictorTable, predData.EnsembleSOC, errDist.SOC);

    %% Write  down the forecasted result in csv file
    outTable = [predictorTable, struct2table(predData)];
    writetable(outTable, resultFilePath, 'Delimiter', ',');
    
    % for debugging --------------------------------------------------------
    energyTransPI =  [predData.EnergyPImin, predData.EnergyPImax];
    socPI =  [predData.SOCPImin, predData.SOCPImax];
    observed = table2array(readtable('targetEVData.csv'));
    display_result('EV charge (ensembled)', 'Demand [kwh]', energyTransPI, predData.EnsembleEnergy, observed(:,9), ci_percentage);
    display_result('EV charge (k-means)', 'Demand [kwh]',[], predData.IndEnergy(:,1), observed(:,9), ci_percentage);
    display_result('EV charge (neural net)', 'Demand [kwh]',[], predData.IndEnergy(:,2), observed(:,9), ci_percentage);
%     display_result('SOC (ensembled)', 'SOC [%]', socPI, predData.EnsembleSOC, observed(:,10), ci_percentage);
    % for debugging --------------------------------------------------------------------- 
    
    flag = 1;
    toc;
end
