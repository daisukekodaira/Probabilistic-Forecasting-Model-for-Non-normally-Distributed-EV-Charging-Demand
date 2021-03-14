% Create matrix; structure 24*4 (hour*quater)
% - Each cell (each 15min inteval) has its own error records, which form error distribution.
% - Input: Array [error, hour, quater]
% - Return: Structure 24*4

function [errEnergyRestruct, errSOCRestruct] = getErrorDist(Data, weight)
    % Generate forecasting result based on ensembled model
    steps = size(Data.Predictor, 1);
    for i = 1:steps
        hour = Data.Predictor.Hour(i)+1;       % Transpose 'hours' from 0 to 23 -> from 1 to 24
        ensembledPredEnergy(i,:) = sum(weight.Energy(hour, :).*Data.PredEnergy(i,:));
        ensembledPredSOC(i,:) = sum(weight.SOC(hour, :).*Data.PredSOC(i, :));
    end
    % Calculate error from validation data: error[%]
    errEnergy = ensembledPredEnergy - Data.TargetEnergy;
    errSOC = ensembledPredSOC - Data.TargetSOC;                

    errEnergyRestruct = restructErrorData(errEnergy);
    errSOCRestruct = restructErrorData(errSOC);
end

function restructErrorData(err)
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    %   row=24hours(1~24 in "LongTermPastData"), columns=4quarters.
    %   For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    for hour = 1:24
        for quarter = 1:4
            err_dist(hour,quarter).err(1) = NaN;            
        end
    end
    % build the error distibution
    steps = size(validData.Predictor.Hour, 1);
    % The hour and quater in 'err' are composed of from 0 to 23.
    % On the other hand, err matrix column and row are compose of from 1 to 24. 
    % 'err' always require +1 to match the hour/quater with the column and row in 'err'    
    for i = 1:steps
        currentHour = validData.Predictor.Hour(i)+1;
        currentQuarter = validData.Predictor.Quarter(i)+1;
        if isnan(err_dist(currentHour, currentQuarter).err(1)) 
            % if the err_distribution is NaN -> yes -> put the error as a new element
            err_dist(currentHour, currentQuarter).err(1, :) = err(i);
        else
            % if the err_distribution is NaN -> no -> append the new error to the last element. 
            lastStep = size(err_dist(currentHour, currentQuarter).err,1);
            err_dist(currentHour, currentQuarter).err(lastStep+1, :) = err(i);
        end
    end
end