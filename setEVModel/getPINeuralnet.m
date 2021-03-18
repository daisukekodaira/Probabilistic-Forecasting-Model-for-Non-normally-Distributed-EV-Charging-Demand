function getPINeuralnet(data)
    % 
    trainedPINeuralnet = NeuralNet_train(data.TargetEnergy, data.errDistEnergy);
    
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
     % startDay
     % Note: 
     %  - This number indicates how many samples are utilized to costruct PI
     %  - For example, startDay=31 means past 31days (samples) are utilized to construct PI
    startDay = 31; 
    for day = startDay:days
        cutoff(day,1).data = getCutoff(err_distribution);  % extract 30 days moving window
        inputs(day,1).data = targetEnergy(1+(day-1)*96:day*96,:); % extract one day traget data coressponding to the day
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
            pd = fitdist(err_distribution(hour, quarter).err,'Kernel','Kernel','epanechnikov');
            % get cutoff value for X and edge of the PDF
            [cutoffX((hour-1)*quarters+quarter, :)] = icdf(pd, [.025, .975]);  % lower, upper
        end
    end
    % Display sample PDF and cutoff
    edgeX = icdf(pd, [.000001, .9999999]);
    % get x and y to be discribed
    x = linspace(edgeX(1), edgeX(2));
    y = pdf(pd, x);
    plot(x,y);
    % set area to be patched
    xci = [linspace(edgeX(1), cutoffX(end,1)); linspace(cutoffX(end,2), edgeX(2))]; % set X axis area
    yci = pdf(pd,xci);  % set Y axis area
    % Patch the outside of the Prediction Interval
    patch([xci(1,:) cutoffX(end, 1)], [yci(1,:) 0], [0.5 0.5 0.5])
    patch([cutoffX(end, 2) xci(2,:)], [0 yci(2,:)], [0.5 0.5 0.5])
end