% ---------------------------------------------------------------------------
% EV demand forecast: Prediction Model development algorithm 
% 10th June, 2020 Updated by Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
% 
% function flag =setEVModel(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function setEVModel_Bootstrap(BringtonBootstrapHour)
    tic;
    warning('off','all');   % Warning is not shown
    
    %% Get file path
    path = fileparts(BringtonBootstrapHour);     
    
    %% Load data
    if strcmp(BringtonBootstrapHour, 'NULL') == 0    % if the filename is not null
        TableAllPastData = readtable(BringtonBootstrapHour);
    else  % if the fine name is null
        flag = -1;  % return error
        return
    end 
    
    %% Devide the data into training and validation
    %Delete'Quarter'
    % Parameter
    ValidDays = 3; % it must be above 1 day. 3days might provide the best performance
    nValidData = 96*ValidDays; % 24*4*day   valid_data = longPast(end-n_valid_data+1:end, :); 
    colPredictors = {'BuildingIndex', 'Year', 'Month', 'Day', 'Hour', 'DayInWeek', 'HolidayOrNot'};
        
    % divide all past data into training and validation
    trainData = TableAllPastData(1:end-nValidData, :);     % training Data (predictors + target)
    validData.Predictor = TableAllPastData(end-nValidData+1:end, colPredictors);    % validation Data (predictors only)
    validData.TargetEnergy = table2array(TableAllPastData(end-nValidData+1:end, {'ChargeDischargeKwh'})); % trarget Data for validation (targets only)
    validData.TargetSOC = table2array(TableAllPastData(end-nValidData+1:end, {'SOCPercent'})); % trarget Data for validation (targets only)
    
    %% Train each model using past load data
    kmeansEV_Training(trainData, colPredictors, path);
    neuralNetEV_Training(trainData, colPredictors, path);
    %     LSTMEV_Training();    % add LSTM here later
    
    %% Validate the performance of each model
    % Note: return shouldn't be located inside of structure. It should be sotred as matrix.
    %           This is because it makes problem after .m files is converted into java files 
    [validData.PredEnergy(:,1), validData.PredSOC(:,1)]  = kmeansEV_Forecast(validData.Predictor, path);
    [validData.PredEnergy(:,2), validData.PredSOC(:,2)] = neuralNetEV_Forecast(validData.Predictor, path); 
    %     [PredEnergyTrans_Valid(:,3), PredSOC_Valid(:,3)] = LSTMEV_Forecast(validData, path); % add LSTM here later
    
    %% Optimize the coefficients (weights) for the ensembled forecasting model
    weight.Energy = getWeight(validData.Predictor, validData.PredEnergy, validData.TargetEnergy);
    weight.SOC = getWeight(validData.Predictor, validData.PredSOC, validData.TargetSOC);
        
    %% Generate probability interval using validation result
    % Generate forecasting result based on ensembled model
    steps = size(validData.Predictor, 1);
    for i = 1:steps
        hour = validData.Predictor.Hour(i)+1;       % Transpose 'hours' from 0 to 23 -> from 1 to 24
        ensembledPredEnergy(i,:) = sum(weight.Energy(hour, :).*validData.PredEnergy(i,:));
        ensembledPredSOC(i,:) = sum(weight.SOC(hour, :).*validData.PredSOC(i, :));
    end
    % Calculate error from validation data: error[%]
    validData.ErrEnergy = ensembledPredEnergy - validData.TargetEnergy;
    validData.ErrSOC = ensembledPredSOC - validData.TargetSOC;
                       
    % Get error distribution
    errDist.Energy = getErrorDist_Bootstrap(validData, validData.ErrEnergy);
    errDist.SOC = getErrorDist_Bootstrap(validData, validData.ErrSOC);
        
    %% Save .mat files
    filename = {'EV_weight_'; 'EV_errDist_'};
    Bnumber = num2str(TableAllPastData.BuildingIndex(1)); % Get building index to add to fine name
    varX = {'weight'; 'errDist'};
    for i = 1:size(varX,1)
        name = strcat(filename(i), Bnumber, '.mat');
        matname = fullfile(path, name);
        save(char(matname), char(varX(i)));
    end
    
%     % for debugging --------------------------------------------------------
%     % Under construction 2020 June 16th
%         display_result(1:size(nValidData,1), ensembledPredEnergy, validData.TargetEnergy, [], 'EnergyTrans'); % EnergyTrans
%         display_result(1:size(nValidData,1), ensembledPredSOC, validData.TargetSOC, [], 'SOC'); % SOC 
%     % for debugging --------------------------------------------------------------------- 
    
    toc;
end
