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

function flag = getEVModel(shortTermPastData, ForecastData, ResultData)
    tic;
    
    %% parameters
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1

    %% Load data
    if strcmp(shortTermPastData, 'NULL') == 0 || strcmp(ForecastData, 'NULL') == 0
        shortPast = csvread(shortTermPastData,1,0);
        predictors = csvread(ForecastData,1,0);
        Resultfile = ResultData;
        num_instances = size(predictors,1);
    else
        flag = -1;
        return
    end       

    %% Load .mat files from give path of "shortTermPastData"
    filepath = fileparts(shortTermPastData);
    buildingIndex = shortPast(1,1);
    
    %% Error recognition: Check mat files exist
    name1 = [filepath, '\', 'EVmodel_', num2str(buildingIndex), '.mat'];
    name2 = [filepath, '\', 'EnergyTransErrDist_', num2str(buildingIndex), '.mat'];
    name3 = [filepath, '\', 'SOCErrDist_', num2str(buildingIndex), '.mat'];
    name4 = [filepath, '\', 'EVpsoCoeff_', num2str(buildingIndex), '.mat'];
    if exist(name1) == 0 || exist(name2) == 0 || exist(name3) == 0 || exist(name4) == 0
        flag = -1;
        return
    end
    
    %% Load mat files
    s(1).fname = 'EVmodel_';
    s(2).fname = 'EnergyTransErrDist_';
    s(3).fname = 'SOCErrDist_';
    s(4).fname = 'EVpsoCoeff_';
    s(5).fname = num2str(buildingIndex);    
    extention='.mat';
    for i = 1:size(s,2)-1
        name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(filepath, [name(i).string extention]);
        load(matname);
    end
    
    %% Get individual prediction for test data
    % Two methods are combined
    %   1. k-menas
    %   2. Neural network
    [PredEnergyTrans_kmeans(:,1), PredSOC_kmeans(:,1)]  = kmeansEV_Forecast(predictors, filepath);
%     [PredEnergyTrans_Valid(1).data(:,1), PredSOC_Valid(1).data(:,1)]  = NeuralNetEV_Forecast(predictors, path); % Under construction
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
    
    %% Generate Result file    
    % Headers for output file
    hedder = {'BuildingIndex', 'Year', 'Month', 'Day', 'Hour', 'Quarter', 'SOC_Mean', 'SOC_PImin', 'SOC_PIMax', ...
                      'EVDemandmean', 'EVDemandPImin', 'EVDemandPImax', 'Confidence Level'};
    fid = fopen(Resultfile,'wt');
    fprintf(fid,'%s,',hedder{:});
    fprintf(fid,'\n');
    
    % Get Prediction Interval 
    % Input: 
    %   1. Deterministic forecasting result
    %   2. Predictors
    %   3. Err distribution (24*4 matrix)
    [EnergyTransPImean, EnergyTransPImin, EnergyTransPImax] = getPI(DetermPredEnergyTrans, predictors, EnergyTransErrDist);
    [SOCPImean, SOCPImin, SOCPImax] = getPI(DetermPredSOC, predictors, SOCErrDist);
      
    result = [predictors(:,1:6)  SOCPImean SOCPImin SOCPImax EnergyTransPImean EnergyTransPImin EnergyTransPImax... 
                   100*(1-ci_percentage)*ones(size(DetermPredEnergyTrans,1),1)];
    fprintf(fid,['%d,', '%04d,', '%02d,', '%02d,', '%2d,','%1d,', '%f,', '%f,', '%f,', '%f,', '%f,', '%f,','%d', '\n'], result');
    fclose(fid);
    
    % for debugging --------------------------------------------------------
    EnergyTransPI =  [EnergyTransPImin, EnergyTransPImax];
    SOCPI =  [SOCPImin, SOCPImax];
    observed = csvread('TargetEVData.csv',1,0);
    display_result('EnergyTrans', EnergyTransPI, num_instances, DetermPredEnergyTrans, observed(:,9), ci_percentage);
    display_result('SOC', SOCPI, num_instances, DetermPredSOC, observed(:,10), ci_percentage);
    % for debugging --------------------------------------------------------------------- 
    
    flag = 1;
    toc;
end
