function weight = getWeight(predictors, forecasted, target)
    % Reconstruct matrix for PSO calculation
    %  - Uniqe coefficient is defined for each hour 
    data(i).hour = predictors(


    funcUnitB = @(weight) objectiveFunc(weight, forecasted, target);
    rng default  % For reproducibility
    nvars = 2;
    lb = [0, 0];
    ub = [1, 1];
    options = optimoptions('particleswarm', ...
                                          'MaxIterations',10^5, ...
                                          'FunctionTolerance', 10^(-8), ...
                                          'MaxStallIterations', 2000, ...
                                          'Display', 'none');
    [Z,fval,exitflag,output] = particleswarm(funcUnitB,nvars,lb,ub, options);
end


function err = objectiveFunc(weight, prediction, target)
    NofForecastingModel = size(prediction,2);
    ensembleForecast = 0;
    while i <= NofForecastingModel
        ensembleForecast = prediction(:,i)*weight(i);
        err = abs(target - prediction(:,i)*weight(i);
        i = i + 1;
    end
    

end