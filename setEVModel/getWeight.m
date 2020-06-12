function weight = getWeight(predictors, forecasted, target)
    % Reconstruct matrix for PSO calculation
    %  - Uniqe coefficient is defined for each hour 
    
    % Restructure the predicted data
    steps = size(forecasted,1);
    
    % Compose the structure for an hourly manner
    for i = 1:steps
        if i == 1
            data(predictors.Hour(i)).forecast(1, :) = forecasted(i, :);
            data(predictors.Hour(i)).target(1) = target(i);
        else
            data(predictors.Hour(i)).forecast(end+1, :) = forecasted(i, :);
            data(predictors.Hour(i)).target(end+1) = target(i);
        end
    end
    
    % PSO
    for i = 1:24
        objFunc = @(weight) objectiveFunc(weight, data.forecast, data.target);
        rng default  % For reproducibility
        nvars = 2;
        lb = [0, 0];
        ub = [1, 1];
        options = optimoptions('particleswarm', ...
                                              'MaxIterations',10^5, ...
                                              'FunctionTolerance', 10^(-8), ...
                                              'MaxStallIterations', 2000, ...
                                              'Display', 'none');
        [weight,~,~,~] = particleswarm(objFunc,nvars,lb,ub, options);
    end
end


function err = objectiveFunc(weight, forecast, target)
    % Note: 
    % Here, 'forecast' and 'target' stores the classified focasted data such as Hour = 10
    % 'weight' also to be defined with hourly basis, so we will define 24 'weight' for every hour data.

    % get the number of forecasting methods (k-menas, Neural network ... and more?)
    N_forecastingModel = size(forecast,2);
    
    % objective function
    for i = 1:N_forecastingModel
        ensembleForecasted = forecast(:,i).*weight(i);
    end
    err = abs(target - ensembleForecasted);
    

end