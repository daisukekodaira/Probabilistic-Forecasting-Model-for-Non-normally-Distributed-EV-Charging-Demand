function [PImean, PImin, PImax] = getPI(DetermPred, predictors, err_distribution)

    for i = 1:size(DetermPred,1)
        hour = predictors(i,5)+1;   % hour 1~24 (original data is from 0 to 23, so add '1' for the matrix)
        quater = predictors(i,6)+1; % quater 1~4 (original data is from 0 to 3, so add '1' for the matrix)
        prob_prediction(hour, quater).pred = DetermPred(i)+err_distribution(hour, quater).err;
        % All elements must be bigger than zero. In this case, all EVs just
        % is for only charge. (We can change this concept for another project)
        prob_prediction(hour, quater).pred = max(prob_prediction(hour, quater).pred, 0);    
        % When the validation date is for only one day, generate duplicated records for mean function
        if size(prob_prediction(hour, quater).pred, 2) == 1
            prob_prediction(hour, quater).pred = [prob_prediction(hour, quater).pred prob_prediction(hour, quater).pred];
        end
        % Get mean value of Probabilistic load prediction
        prob_prediction(hour, quater).mean = mean(prob_prediction(hour, quater).pred)';
        % Get Confidence Interval
        %  - getPI_confInter: 2sigma(95%) boundaries return
        %  - getPI_sampling: please specify the percentage by yourself 
        [PImean(i,1), PImin(i,1), PImax(i,1)] = getPI_confInter(prob_prediction(hour, quater).pred);
        % [PImean(i,1), PImin(i,1), PImax(i,1)] = getPI_sampling(prob_prediction(hour, quater).pred, );
    end
end