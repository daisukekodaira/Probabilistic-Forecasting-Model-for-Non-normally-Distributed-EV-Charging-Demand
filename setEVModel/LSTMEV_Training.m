function LSTMEV_Training(trainData, colPredictors, path)


%% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC
n_instance = size(trainData,1);  
x = transpose(table2array(trainData(1:n_instance, colPredictors))); % input(feature)
t_Trans = transpose(table2array(trainData(1:n_instance, {'ChargeDischargeKwh'}))); % target
t_SOC = transpose(table2array(trainData(1:n_instance,  'SOCPercent'))); % target
    mu_Trans = mean(t_Trans);
    sig_Trans = std(t_Trans);
    mu_SOC = mean(t_SOC);
    sig_SOC = std(t_SOC);
    mu2 = mean(x,2);
    sig2 = std(x,0,2);

    dataTrainStandardized_Trans = (t_Trans - mu_Trans) / sig_Trans;
    for i= 1:size(x,1) 
     if sig2(i,1)==0
        PredicterdataStandardized(i,:) = (x(i,:));
     else
        PredicterdataStandardized(i,:) = (x(i,:) - mu2(i,1)) / sig2(i,1);
     end
    end
    
    dataTrainStandardized_SOC = (t_SOC - mu_SOC) / sig_SOC;
    for i= 1:size(x,1) 
     if sig2(i,1)==0
        PredicterdataStandardized(i,:) = (x(i,:));
     else
        PredicterdataStandardized(i,:) = (x(i,:) - mu2(i,1)) / sig2(i,1);
     end
    end
    
    
    numFeatures = 8;
    numResponses = 1;
    
numHiddenUnits = 10;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

net_Trans = trainNetwork(x,dataTrainStandardized_Trans,layers,options);
net_SOC = trainNetwork(x,dataTrainStandardized_SOC,layers,options);

    trainedLSTM_EnergyTrans = net_Trans;
    trainedLSTM_SOC = net_SOC;
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedLSTM_EnergyTrans', 'trainedLSTM_SOC','net_Trans','net_SOC','x','mu_Trans','sig_Trans','mu_SOC','sig_SOC');
    
end
    
