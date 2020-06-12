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
    validPredictorData = TableAllPastData(end-nValidData+1:end, colPredictors);    % validation Data (predictors only)
    validTargetEnergyData = TableAllPastData(end-nValidData+1:end, {'ChargeDischargeKwh'}); % trarget Data for validation (targets only)
    validTargetSOCData = TableAllPastData(end-nValidData+1:end, {'SOCPercent'}); % trarget Data for validation (targets only)
    
    %% Train each model using past load data
    kmeansEV_Training(trainData, colPredictors, path);
    neuralNetEV_Training(trainData, colPredictors, path);
    %     LSTMEV_Training();    % add LSTM here later
    
    %% Validate the performance of each model
    % Note: return shouldn't be located inside of structure. It should be sotred as matrix.
    %           This is because it makes problem after .m files is converted into java files 
    [validPredEnergyTransData(:,1), validPredSOCData(:,1)]  = kmeansEV_Forecast(validPredictorData, path);
    [validPredEnergyTransData(:,2), validPredSOCData(:,2)] = neuralNetEV_Forecast(validPredictorData, path); 
    %     [PredEnergyTrans_Valid(:,3), PredSOC_Valid(:,3)] = LSTMEV_Forecast(validData, path); % add LSTM here later
    
    %% Optimize the coefficients (weights) for the ensembled forecasting model
    weightEnergyTrans = getWeight(validPredictorData, validPredEnergyTransData, validTargetEnergyData); % table, matrix, table
    weightSOC = getWeight(validPredictorData, validPredSOCData, validTargetSOCData);
        
    %% Generate probability interval using validation result
    % Generate forecasting result based on ensembled model
    for i = 1:size(weightEnergyTrans,1)
        if i == 1
            ensembledPredEnergyTrans = weightEnergyTrans(i).*validPredEnergyTransData(i,:);
            ensembledPredSOC = weightSOC(i).*validPredSOCData(i, :);
        else
            ensembledPredEnergyTrans = ensembledPredEnergyTrans + weightEnergyTrans(i).*validPredEnergyTransData(i, :);
            ensembledPredSOC = ensembledPredSOC + weightSOC(i).*validPredSOCData(i, :);  
        end
    end
    % Calculate error from validation data: error[%]
    EnergyTrans_err = [ensembledPredEnergyTrans - validTargetEnergyData validPredictorData(:,col_hour) validPredictorData(:,col_quarter)]; 
    SOC_err = [ensembledPredSOC - validTargetSOCData validPredictorData(:,col_hour) validPredictorData(:,col_quarter)];
    % Get error distribution
    EnergyTransErrDist = getErrorDist(EnergyTrans_err);
    SOCErrDist = getErrorDist(SOC_err);
        
    %% Save .mat files
    s1 = 'EVpsoCoeff_';
    s2 = 'EnergyTransErrDist_';
    s3 = 'SOCErrDist_';
    s4 = num2str(TableAllPastData(1,1)); % Get building index to add to fine name
    name(1).string = strcat(s1,s4);
    name(2).string = strcat(s2,s4);
    name(3).string = strcat(s3,s4);
    varX(1).value = 'coeff';
    varX(2).value = 'EnergyTransErrDist';
    varX(3).value = 'SOCErrDist';
    extention='.mat';
    for i = 1:size(varX,2)
        matname = fullfile(path, [name(i).string extention]);
        save(matname, varX(i).value);
    end
    
    % for debugging --------------------------------------------------------
        getGraph(1:size(nValidData,1), ensembledPredEnergyTrans, validTargetEnergyData, [], 'EnergyTrans'); % EnergyTrans
        getGraph(1:size(nValidData,1), ensembledPredSOC, validTargetSOCData, [], 'SOC'); % SOC 
    % for debugging --------------------------------------------------------------------- 
    
    toc;
end
