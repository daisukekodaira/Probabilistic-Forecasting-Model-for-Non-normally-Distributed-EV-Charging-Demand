function LSTMEV_Training(trainData, colPredictors, path)


%% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC
    
n_instance = size(trainData,1);        
x = transpose(table2array(trainData(1:n_instance, colPredictors))); % input(feature)
t_Trans = transpose(table2array(trainData(1:n_instance, {'ChargeDischargeKwh'}))); % target
t_SOC = transpose(table2array(trainData(1:n_instance,  'SOCPercent'))); % target


numFeatures = 8;
numResponses = 1;
numHiddenUnits = 200;

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

net_Trans = trainNetwork(x,t_Trans,layers,options);
net_SOC = trainNetwork(x,t_SOC,layers,options);

    trainedLSTM_EnergyTrans = net_Trans;
    trainedLSTM_SOC = net_SOC;
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedLSTM_EnergyTrans', 'trainedLSTM_SOC','net_Trans','net_SOC');
    
end
    
