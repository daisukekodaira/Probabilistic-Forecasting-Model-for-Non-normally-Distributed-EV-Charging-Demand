% ---------------------------------------------------------------------------
% Load prediction: Model development algorithm 
% 2019/03/6 Updated by Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
% 
% function flag =setEVModel(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function flag = setEVModel(LongTermPastData)
    tic;
    warning('off','all');   % Warning is not shown
    
    %% Get file path
    path = fileparts(LongTermPastData);     
    
    %% Load data
    if strcmp(LongTermPastData, 'NULL') == 0    % if the filename is not null
        past_load = csvread(LongTermPastData,1,0);
    else  % if the fine name is null
        flag = -1;  % return error
        return
    end
    
    %% Devide the data into training and validation
    train_data = past_load;
    predictors = train_data(:,1:end-2);
    
    %% Train each model using past load data
    % Note: 0 means not true. If this function got the past data, model have to be trained
    kmeansEV_Training(train_data, path);

    %% Validate the performance of each model
    % Note: return shouldn't be located inside of structure. It should be sotred as matrix.
    %           This is because it makes problem after .m files is converted into java files 
    [PredEnergyTrans_kmeans(:,1), PredSOC_kmeans(:,1)]  = kmeansEV_Forecast(predictors, path);
    %     [PredEnergyTrans_Valid(1).data(:,1), PredSOC_Valid(1).data(:,1)]  = NeuralNetwork_Forecast(predictors, path);
    PredEnergyTrans_Valid(1).data(:,1) =  PredEnergyTrans_kmeans(:,1);  
    PredSOC_Valid(1).data(:,1) =  PredSOC_kmeans(:,1);
    
    %% Optimize the coefficients for the additive model
    % EnergyTrans(Charge/Discharge[kwh]) coefficients
    coeff = pso_main(PredEnergyTrans_Valid, train_data(:,end-1));
    EnergyTransCoeff = coeff(1:end-1);
    % SOC coefficients
    coeff = pso_main(PredSOC_Valid, train_data(:,end));
    SOCCoeff = coeff(1:end-1);
    
    %% Generate probability interval using validation result
    for i = 1:size(EnergyTransCoeff,1)
        if i == 1
            y_PredEnergyTrans = coeff(i).*PredEnergyTrans_Valid(i).data;
            y_PredSOC = coeff(i).*PredSOC_Valid(i).data;
        else
            y_PredEnergyTrans = y_PredEnergyTrans + coeff(i).*PredEnergyTrans_Valid(i).data;
            y_PredSOC = y_PredSOC + coeff(i).*PredSOC_Valid(i).data;  
        end
    end
    
    % Calculate error from validation data[%]: error[%], customerID
    EnergyTrans_err = [y_PredEnergyTrans - train_data(:, end-1) train_data(:,2)]; 
    SOC_err = [y_PredSOC - train_data(:, end) train_data(:,11)]; 
    % Get error distribution
    EnergyTransErrDist = getErrorDist(EnergyTrans_err);
    SOCErrDist = getErrorDist(SOC_err);
        
    %% Save .mat files
    s1 = 'EVpsoCoeff_';
    s2 = 'EnergyTransErrDist_';
    s3 = 'SOCErrDist_';
    s4 = num2str(past_load(1,1)); % Get building index to add to fine name
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
    
%     % for debugging --------------------------------------------------------
%         trueEnergyTrans = valid_data(:, end-1);
%         trueSOC = valid_data(:, end);
%         getGraph(1:size(valid_data,1), y_PredEnergyTrans, trueEnergyTrans, [], 'EnergyTrans'); % EnergyTrans
%         getGraph(1:size(valid_data,1), y_PredSOC, trueSOC, [], 'SOC'); % SOC 
%     % for debugging --------------------------------------------------------------------- 
    
    flag = 1;    
    toc;
end
