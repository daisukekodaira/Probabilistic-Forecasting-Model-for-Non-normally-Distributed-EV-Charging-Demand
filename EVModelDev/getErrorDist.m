% Create structure 24*4 (hour*quater)
% Each cell (each 15min inteval) has its own error records, which form error distribution.
% Input: Array [error, hour, quater]
% Return: Structure 24*4

function err_dist = getErrorDist(errArray)
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    % row=25hours(0~24 in "LongTermPastData"), columns=4quarters.
    % For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    UnqCustomerID = unique(errArray(:,2));
%     for i = 1:size(UnqCustomerID,1)
%         err_dist(i).data(1) = NaN;              
%     end
    
    % build the error distibution   
    for i = 1:size(errArray,1)
        for j = 1:size(UnqCustomerID,1)
            idx = find(errArray(:,2)==UnqCustomerID(j));
            err_dist(j).err = errArray(idx,1);
            err_dist(j).customerID = UnqCustomerID(j);
        end                
    end
    
    
end