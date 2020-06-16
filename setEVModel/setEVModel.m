% ---------------------------------------------------------------------------
% EV demand forecast: Prediction Model development algorithm 
% 10th June, 2020 Updated by Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
% 
% function flag =setEVModel(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function setEVModel(LongTermPastData)
    tic;
    warning('off','all');   % Warning is not shown
    
    %% Get file path
    path = fileparts(LongTermPastData);     
    
    %% Load data
    if strcmp(LongTermPastData, 'NULL') == 0    % if the filename is not null
        TableAllPastData = readtable(LongTermPastData);
    else  % if the fine name is null
        flag = -1;  % return error
        return
    end 
    
    %% Devide the data into training and validation
    % Parameter
    ValidDays = 30; % it must be above 1 day. 3days might provide the best performance
    nValidData = 96*ValidDays; % 24*4*day   valid_data = longPast(end-n_valid_data+1:end, :); 
    colPredictors = {'BuildingIndex', 'Year', 'Month', 'Day', 'Hour', 'Quarter', 'DayInWeek', 'HolidayOrNot'};
    
    
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
    weightEnergy = getWeight(validData.Predictor, validData.PredEnergy, validData.TargetEnergy);
    weightSOC = getWeight(validData.Predictor, validData.PredSOC, validData.TargetSOC);
        
    %% Generate probability interval using validation result
    % Generate forecasting result based on ensembled model
    steps = size(validData.Predictor, 1);
    for i = 1:steps
        hour = validData.Predictor.Hour(i)+1;       % Transpose 'hours' from 0 to 23 -> from 1 to 24
        ensembledPredEnergy(i,:) = sum(weightEnergy(hour, :).*validData.PredEnergy(i,:));
        ensembledPredSOC(i,:) = sum(weightSOC(hour, :).*validData.PredSOC(i, :));
    end
    % Calculate error from validation data: error[%]
    validData.ErrEnergy = ensembledPredEnergy - validData.TargetEnergy;
    validData.ErrSOC = ensembledPredSOC - validData.TargetSOC;
                       
    % Get error distribution
    validData.ErrDist.Energy = getErrorDist(validData, validData.ErrEnergy);
    validData.ErrDist.SOC = getErrorDist(validData, validData.ErrSOC);
        
    %% Save .mat files
    ErrDistEnergy = {validData.ErrDist.Energy};
    ErrDistSOC = {validData.ErrDist.SOC};
    s1 = 'weightEnergy_';
    s2 = 'weightSOC_';
    s3 = 'EnergyErrDist_';
    s4 = 'SOCErrDist_';
    s5 = num2str(TableAllPastData.BuildingIndex(1)); % Get building index to add to fine name
    name(1).string = strcat(s1,s5);
    name(2).string = strcat(s2,s5);
    name(3).string = strcat(s3,s5);
    name(4).string = strcat(s4,s5);
    varX(1).value = 'weightEnergy';
    varX(2).value = 'weightSOC';
    varX(3).value = 'ErrDistEnergy';
    varX(4).value = 'ErrDistSOC';
    extention='.mat';
    for i = 1:size(varX,2)
        matname = fullfile(path, [name(i).string extention]);
        save(matname, varX(i).value);
    end
    
%     % for debugging --------------------------------------------------------
%     % Under construction 2020 June 16th
%         display_result(1:size(nValidData,1), ensembledPredEnergy, validData.TargetEnergy, [], 'EnergyTrans'); % EnergyTrans
%         display_result(1:size(nValidData,1), ensembledPredSOC, validData.TargetSOC, [], 'SOC'); % SOC 
%     % for debugging --------------------------------------------------------------------- 
    
    toc;
end
