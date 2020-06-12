function neuralNetEV_Training(trainData, colPredictors, path)
    % Display for user
    disp('Training the neraul network model....');
       
    %% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC
    trainedNet_EnergyTrans = NeuralNet_train(trainData, colPredictors, {'ChargeDischargeKwh'});
    trainedNet_SOC = NeuralNet_train(trainData, colPredictors, 'SOCPercent');
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedNeuralNet_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedNet_EnergyTrans', 'trainedNet_SOC');
    % Display for user
    disp('Training the neraul network model.... Done!');
end

function trainedNet = NeuralNet_train(trainData, columnPredictors, columnTarget)
    % Iterete 3 times to make average of them. (more than 3 is also acceptable)
    % The forecasting error from randomness of neural network is reduced.
    maxLoop = 3;
    % Number of instances in the training data set
    n_instance = size(trainData,1);        
    % Training
    for i = 1:maxLoop
        x = transpose(table2array(trainData(1:n_instance, columnPredictors))); % input(feature)
        t = transpose(table2array(trainData(1:n_instance, columnTarget))); % target
        % Create and display the network
        net = fitnet([20,20,20,15],'trainscg');
        net.trainParam.showWindow = false;
        net = train(net,x,t); % Train the network using the data in x and t
        trainedNet{i} = net;             % save result
    end   
end