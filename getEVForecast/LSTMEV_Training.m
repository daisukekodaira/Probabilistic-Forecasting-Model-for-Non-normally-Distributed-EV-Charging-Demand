function LSTMEV_Training(trainData, colPredictors, path)


%% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC
  trainedLSTM_EnergyTrans = LSTM_train(trainData, colPredictors, {'ChargeDischargeKwh'});
  trainedLSTM_SOC = LSTM_train(trainData, colPredictors, 'SOCPercent');
    
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedLSTM_EnergyTrans', 'trainedLSTM_SOC');
    disp('LSTMforecast.... Done!');
end

function trainedLSTM = LSTM_train(trainData, columnPredictors, columnTarget)
  n_instance = size(trainData,1);  
x = transpose(table2array(trainData(1:n_instance, columnPredictors))); % input(feature)
t = transpose(table2array(trainData(1:n_instance, columnTarget))); % target

 numFeatures = size(x,1);
 numResponses = size(t,1);
    
numHiddenUnits = 200;

 layers = [ ...
        sequenceInputLayer(numFeatures) 
        lstmLayer(numHiddenUnits)   
        lstmLayer(numHiddenUnits)
        fullyConnectedLayer(numResponses)
        regressionLayer];
    options = trainingOptions('adam', ...
        'MaxEpochs',100, ...
        'GradientThreshold',1, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125, ...
        'LearnRateDropFactor',0.2, ...
        'Verbose',0);
    net = trainNetwork(x,t,layers,options);% Train the network using the data in x and t
    
    trainedLSTM = net;
    
    
    
    
end


