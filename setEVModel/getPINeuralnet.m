function getPINeuralnet(data, err_distribution)
       
    % 
    trainedPINeuralnet = NeuralNet_train(data.TargetEnergy, err_distribution);
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedNeuralNet_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedPINeuralnet');
end

function trainedNet = NeuralNet_train(targetEnergy, err_distribution)
    % get upper and lower boundary from err distribution
    days = size(err_distribution(1,1).err,1);
    lastDay = days-30;
    for day = 1:lastDay
        [cutoff(:, day)] = getCutoff(err_distribution.EnergyAll(day+((day-1)*96*30:(day*96*30))));  % extract 30 days moving window
        inputs(:,day) = targetEnergy(1+96*30+(day-1)*96:1+96*30+day*96);
    end
    
    % Iterete 3 times to make average of them. (more than 3 is also acceptable)
    % The forecasting error from randomness of neural network is reduced.
    maxLoop = 1;
    % Training
    for i = 1:maxLoop
        % Create and display the network
        net = fitnet([20,20,20,15],'trainscg');
        net.trainParam.showWindow = false;
        net = train(net,inputs, cutoff); % Train the network
        trainedNet{i} = net;             % save result
    end
end

function [cutoffX] = getCutoff(err_distribution)

    hours = size(err_distribution,1);
    quarters = size(err_distribution,2);
    % generate cutoffX based on the kernel PDF regression
    for hour = 1:hours
        for quarter = 1:quarters
            % get probabilisity density function object 
            pd = fitdist(err_distribution(hour, quarter),'Kernel','Kernel','epanechnikov');
            % get cutoff value for X and edge of the PDF
            cutoffX = icdf(pd, [.025, .975]);
        end
    end
    % Display sample PDF and cutoff
    edgeX = icdf(pd, [.000001, .9999999]);
    % get x and y to be discribed
    x = linspace(edgeX(1), edgeX(2));
    y = pdf(pd, x);v 
    plot(x,y);
    % set area to be patched
    xci = [linspace(edgeX(1), cutoffX(1)); linspace(cutoffX(2), edgeX(2))]; % set X axis area
    yci = pdf(pd,xci);  % set Y axis area
    % Patch the outside of the Prediction Interval
    patch([xci(1,:) cutoffX(1)], [yci(1,:) 0], [0.5 0.5 0.5])
    patch([cutoffX(2) xci(2,:)], [0 yci(2,:)], [0.5 0.5 0.5])
end