function LSTMEV_Training(trainData, colPredictors, path)

%% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC 
  %%trainData = trainData(376:663,:); 
  trainedLSTM_EnergyTrans = LSTM_train(trainData, colPredictors, 'ChargeDischargeKwh');
  trainedLSTM_SOC = LSTM_train(trainData, colPredictors, 'SOCPercent');
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedLSTM_EnergyTrans', 'trainedLSTM_SOC');
    
end

function trainedLSTM = LSTM_train(trainData, columnPredictors, columnTarget)

 
 n_instance = size(trainData,1);        
 x = transpose(table2array(trainData(1:n_instance, columnPredictors))); % input(feature)
 t = transpose(table2array(trainData(1:n_instance, columnTarget))); % target


 numFeatures = size(x,1);
 numResponses = size(t,1);
 
    
numHiddenUnits = 100;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numResponses)
    regressionLayer];
    
maxEpochs = 20;
miniBatchSize = 800;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto',...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Plots','training-progress',...
    'Verbose',0);
    
    net = trainNetwork(x,t,layers,options);% Train the network using the data in x and t
    
    trainedLSTM = net;
    
end


