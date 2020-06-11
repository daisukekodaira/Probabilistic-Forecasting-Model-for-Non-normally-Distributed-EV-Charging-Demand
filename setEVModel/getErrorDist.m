% Create matrix; structure 24*4 (hour*quater)
% - Each cell (each 15min inteval) has its own error records, which form error distribution.
% - Input: Array [error, hour, quater]
% - Return: Structure 24*4

function err_distribution = getErrorDist(err)
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    %   row=24hours(1~24 in "LongTermPastData"), columns=4quarters.
    %   For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    for hour = 1:24
        for quarter = 1:4
            err_distribution(hour,quarter).err(1) = NaN;            
        end
    end
    % build the error distibution
    for k = 1:size(err,1)
        % The hour and quater in 'err' start from 0 to 23.
        % On the other hand, err matrix column and row start from 1. 
        % 'err' always require +1 to match the hour/quater with the column and row in 'err'
        if isnan(err_distribution(err(k,2)+1, err(k,3)+1).err(1)) == 1  
            % if the err_distribution is NaN -> yes -> put the error as a new element
            err_distribution(err(k,2)+1, err(k,3)+1).err(1) = err(k,1);
        else
            % if the err_distribution is NaN -> no -> append the new error to the last element. 
            err_distribution(err(k,2)+1, err(k,3)+1).err(end+1) = err(k,1);
        end
    end   
    
end