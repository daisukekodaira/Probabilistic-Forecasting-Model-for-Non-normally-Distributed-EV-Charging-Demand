function kmeansEV_Training(trainData, colPredictors, path)

    %% Read inpudata
    %     train_data = LongTermpastData(~any(isnan(LongTermpastData),2),:); % Eliminate NaN from inputdata
    %     %% Format error check (to be modified)
    %     % "-1" if there is an error in the LongpastData's data form, or "1"
    %     [~,number_of_columns1] = size(train_data);
    %     if number_of_columns1 == 12
    %         error_status = 1;
    %     else
    %         error_status = -1;
    %     end
    
    %     % Display for user
    %     disp('Training the k-menas & Baysian model....');

    %% Kmeans clustering for Charge/Discharge data
    % Extract appropriate data from inputdata for Energy transactions: pastEnegyTrans
    % Extract appropriate data from inputdata for SOC prediction: pastSOC
    PastPredictors= table2array(trainData(:, colPredictors)); % Extract predictors (Year,Month,Day,Hour,Quater,P1(Day),P2(Holiday))
    pastEnegyTrans = table2array(trainData(:, {'ChargeDischargeKwh'})); % Charge/Discharge [kwh]
    pastSOC = table2array(trainData(:, {'SOCPercent'})); % SOC[%]

    % Set K for Charge/Discharge [kwh]. 50 is experimentally chosen
    % Set K for SOC[%]. 35 is experimentally chosen
    k_EnergyTrans= 50;
    k_SOC = 35;
    
    % Train k-means clustering
    [idx_EnergyTrans, c_EnergyTrans] = kmeans(pastEnegyTrans, k_EnergyTrans);
    [idx_SOC, c_SOC] = kmeans(pastSOC, k_SOC);
    
    % Train multiclass naive Bayes model
    nb_EnergyTrans = fitcnb(PastPredictors, idx_EnergyTrans,'Distribution','kernel');
    nb_SOC = fitcnb(PastPredictors, idx_SOC,'Distribution','kernel');
        
    %% Save trained data in .mat files
    % idx_EnergyTrans: index for each Charge/Discharge records
    % idx_SOC: index for each SOC records
    % k_EnergyTrans: optimal K for Charge/Discharge (experimentally chosen)
    % k_SOC: optimal K for SOC (experimentally chosen)
    % nb_EnergyTrans: Trained Baysian model for Charge/Discharge [kwh]
    % nb_SOC: Trained Baysian model for SOC[%]
    % c_EnergyTrans: centroid for each cluster. The number of these values must correspond with k_EnergyTrans
    % c_SOC: centroid for each cluster
    building_num = num2str(trainData.BuildingIndex(1)); % building number is necessary to be distinguished from other builiding mat files
    save_name = '\EV_trainedKmeans_';
    save_name = strcat(path,save_name,building_num,'.mat');
    save(save_name, 'idx_EnergyTrans','idx_SOC', 'k_EnergyTrans','k_SOC', 'nb_EnergyTrans','nb_SOC', 'c_EnergyTrans', 'c_SOC');
    %     disp('Training the k-menas & Baysian model.... Done!');

end