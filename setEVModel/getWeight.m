function weight = getWeight(predictors, forecasted, target)
    % Reconstruct matrix for PSO calculation
    %  - Uniqe coefficient is defined for each hour 
    
    % Display for user
    disp('Optimizing the weights for ensemble model....');
        
    % Restructure the predicted data
    steps = size(forecasted,1);
    N_methods = size(forecasted,2);
    
    % Compose the structure for an hourly manner
    % set NaN as an initial occupation
    for i =1:24
        data(i).forecast = NaN(1, N_methods);
        data(i).target = NaN(1);
    end
    
    for i = 1:steps
        if isnan(data(predictors.Hour(i)+1).forecast)
            % data is not stored yet for the hour
            data(predictors.Hour(i)+1).forecast(1, :) = forecasted(i, :);
            data(predictors.Hour(i)+1).target(1) = target(i);
        else
            % there is stored
            lastStep = size(data(predictors.Hour(i)+1).forecast,1);
            data(predictors.Hour(i)+1).forecast(lastStep+1, :) = forecasted(i, :);
            data(predictors.Hour(i)+1).target(lastStep+1, 1) = target(i);
        end
    end
    
    % PSO
    for hour = 1:24
        objFunc = @(weight) objectiveFunc(weight, data(hour).forecast, data(hour).target);
        rng default  % For reproducibility
        nvars = 2;
        lb = [0, 0];
        ub = [1, 1];
        options = optimoptions('particleswarm', ...
                                              'MaxIterations',10^5, ...
                                              'FunctionTolerance', 10^(-8), ...
                                              'MaxStallIterations', 2000, ...
                                              'Display', 'none');
        [weight(hour, :),~,~,~] = particleswarm(objFunc,nvars,lb,ub, options);
    end
    
    % Display for user
    disp('Optimizing the weight for ensemble model.... Done!');
end


function err = objectiveFunc(weight, forecast, target)
    % Note: 
    %   - Here, 'forecast' and 'target' stores the classified focasted data such as Hour = 10
    %   - 'weight' also to be defined with hourly basis, so we will define 24 'weight' for every hour data.
    % objective function
    ensembleForecasted = sum(forecast.*weight, 2);  % add two methods
    err = sum(abs(target - ensembleForecasted));
    %     err = max(abs(target - ensembleForecasted));
end