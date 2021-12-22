function LSTMEV_Training(trainData, colPredictors, path)

%% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC 
 
 predata = trainData{:,[9 end]};
 predata = fillmissing(predata,'previous');% Replace NaN with the previous non-missing value

meandata = mean(predata);
sigdata = std(predata); 
if sigdata(2)==0 % in case of SOC, its valus is usually 0. so it make NAN value
    sigdata(2)=1;
end
dataTrainStandardized = array2table((predata - meandata) ./ sigdata);  

 n_instance = size(trainData,1);        
 x = transpose(table2array(trainData(1:n_instance, colPredictors))); % input(feature)
 t1 = transpose(table2array(dataTrainStandardized(1:n_instance, 1 ))); % target(ChargeDischargeKwh)
 t2 = transpose(table2array(dataTrainStandardized(1:n_instance, 2 ))); % target(SOC)


  trainedLSTM_EnergyTrans = LSTM_train(x,t1);
  trainedLSTM_SOC = LSTM_train(x,t2);
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedLSTM_EnergyTrans', 'trainedLSTM_SOC','meandata','sigdata','x');
    
    
end

function trainedLSTM = LSTM_train(columnPredictors, columnTarget)
 


numFeatures = size(columnPredictors,1);
numResponses = 1;   % 1
numHiddenUnits1 = 100;
numHiddenUnits2 = 50;
numHiddenUnits3 = 25;
layers = [ ...
    sequenceInputLayer(numFeatures) 
    reluLayer
    lstmLayer(numHiddenUnits1)   
    reluLayer
    lstmLayer(numHiddenUnits2)    
    reluLayer
    lstmLayer(numHiddenUnits3)    
    reluLayer
    fullyConnectedLayer(numResponses)
    regressionLayer];
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'GradientThreshold',1.2, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0);

    net = trainNetwork(columnPredictors,columnTarget,layers,options);
    
    trainedLSTM = net;
    
end


