% Create matrix; structure 24*4 (hour*quater)
% - Each cell (each 15min inteval) has its own error records, which form error distribution.
% - Input: Array [error, hour, quater]
% - Return: Structure 24*4

function [errTableEnergy, errTableSOC, ensembledPredEnergy] = getErrorDist(data, weight)
    % Generate forecasting result based on ensembled model
    steps = size(data.Predictor, 1);
    for i = 1:steps
        hour = data.Predictor.Hour(i)+1;       % Transpose 'hours' from 0 to 23 -> from 1 to 24
        ensembledPredEnergy(i,:) = sum(weight.Energy(hour, :).*data.PredEnergy(i,:));
        ensembledPredSOC(i,:) = sum(weight.SOC(hour, :).*data.PredSOC(i, :));
    end
    % Calculate error from validation data: error[%]
    errEnergy = ensembledPredEnergy - data.TargetEnergy;
    errSOC = ensembledPredSOC - data.TargetSOC;                

    errTableEnergy = restructErrorData(data, errEnergy);
    errTableSOC = restructErrorData(data, errSOC);
end

function errTable = restructErrorData(data, err)
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    %   row=24hours(1~24 in "LongTermPastData"), columns=4quarters.
    %   For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    for hour = 1:24
        for quarter = 1:4
            errTable(hour,quarter).err(1) = NaN;            
        end
    end
    % build the error distibution
    steps = size(data.Predictor.Hour, 1);
    % The hour and quater in 'err' are composed of from 0 to 23.
    % On the other hand, err matrix column and row are compose of from 1 to 24. 
    % 'err' always require +1 to match the hour/quater with the column and row in 'err'    
    for i = 1:steps
        currentHour = data.Predictor.Hour(i)+1;
        currentQuarter = data.Predictor.Quarter(i)+1;
        if isnan(errTable(currentHour, currentQuarter).err(1)) 
            % if the err_distribution is NaN -> yes -> put the error as a new element
            errTable(currentHour, currentQuarter).err(1, :) = err(i);
        else
            % if the err_distribution is NaN -> no -> append the new error to the last element. 
            lastStep = size(errTable(currentHour, currentQuarter).err,1);
            errTable(currentHour, currentQuarter).err(lastStep+1, :) = err(i);
        end
    end
end