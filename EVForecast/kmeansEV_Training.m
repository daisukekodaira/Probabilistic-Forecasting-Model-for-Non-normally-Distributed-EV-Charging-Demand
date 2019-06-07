function kmeansEV_Training(LongTermpastData, path)

    %% Read inpudata
    train_data = LongTermpastData(~any(isnan(LongTermpastData),2),:); % Eliminate NaN from inputdata

    %     %% Format error check (to be modified)
    %     % "-1" if there is an error in the LongpastData's data form, or "1"
    %     [~,number_of_columns1] = size(train_data);
    %     if number_of_columns1 == 12
    %         error_status = 1;
    %     else
    %         error_status = -1;
    %     end
    
    %% Kmeans clustering for Charge/Discharge data
    % Extract appropriate data from inputdata for Energy transactions: pastEnegyTrans
    % Extract appropriate data from inputdata for SOC prediction: pastSOC
    PastPredictors= train_data(:,2:9); % Extract predictors (Year,Month,Day,Hour,Quater,P1,P2,P3)
    pastEnegyTrans = train_data(:, 10); % 10 : Charge/Discharge [kwh]
    pastSOC = train_data(:,11); % 11: SOC[%]

    % Set K for Charge/Discharge [kwh]. 50 is experimentally chosen
    % Set K for SOC[%]. 35 is experimentally chosen
    k_EnergyTrans= 35;
    k_SOC = 50;
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
    building_num = num2str(LongTermpastData(2,1)); % building number is necessary to be distinguished from other builiding mat files
    save_name = '\EVmodel_';
    save_name = strcat(path,save_name,building_num,'.mat'); 
    save(save_name, 'idx_EnergyTrans','idx_SOC', 'k_EnergyTrans','k_SOC', 'nb_EnergyTrans','nb_SOC', 'c_EnergyTrans', 'c_SOC');
end