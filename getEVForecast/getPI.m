% Generate PI
% Note:
%       - The error distributions are defined for each quater. There are 24*4 = 96 error distributions. 
%       - 

function [PImean, PImin, PImax] = getPI(predictors, determPred, err_distribution)
    for i = 1:size(predictors,1)
        hour = predictors.Hour(i)+1;   % hour 1~24 (original data is from 0 to 23, so add '1' for the matrix)
        quarter = predictors.Quarter(i)+1; % quater 1~4 (original data is from 0 to 3, so add '1' for the matrix)
        prob_prediction(hour, quarter).pred = determPred(i) + err_distribution(hour, quarter).err;
        % All elements must be bigger than zero.
        % Note: In this case, all EVs just is for only charge.
        %           (We can change this concept for another project)
        prob_prediction(hour, quarter).pred = max(prob_prediction(hour, quarter).pred, 0);    
        % Get mean value of Probabilistic load prediction
        prob_prediction(hour, quarter).mean = mean(prob_prediction(hour, quarter).pred)';
        % Get Confidence Interval
        %  - getPI_confInter: 2sigma(95%) boundaries return
        %  - getPI_sampling: please specify the percentage by yourself 
        [PImean(i,1), PImin(i,1), PImax(i,1)] = getPI_confInter(prob_prediction(hour, quarter).pred);
        % [PImean(i,1), PImin(i,1), PImax(i,1)] = getPI_sampling(prob_prediction(hour, quater).pred, );
    end
end