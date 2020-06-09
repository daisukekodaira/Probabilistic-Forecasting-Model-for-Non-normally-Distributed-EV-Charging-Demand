% -----------------------------------------------------------------
% This function is only for debug
% -------------------------------------------------------------------

function display_result(figTitle, PIMean, PIMin, PIMax, target, alph)
    % Set variables for graph description
    instances = size(PIMean,1);
    PI = [PIMin PIMax];    
    % Describe graph
    graph_desc(1:instances, PIMean, target, PI, figTitle, alph);
    % Calculate cover rate of prediction interval
    % - Calculate how many forecasted mean values are between the upper PI and lower PI
    count = 0;
    for i = 1:size(target,1)
        if (PI(i,1)<=target(i)) && (target(i)<=PI(i,2))
            count = count+1;
        end
    end
    PICoverRate = 100*count/size(target,1);
    MAPE = mean(abs(PIMean - target)*100./target); % combined
    % display
    disp(['PI cover rate is ',num2str(PICoverRate), '[%]/', num2str(100*(1-alph)), '[%]'])
    disp(['MAPE of mean: ', num2str(MAPE), '[%]'])
end


function graph_desc(x, y_pred, y_true, boundaries, name, ci_percentage)
    % To overcome the bug in Matlab2019; it cannot display legneds lines in figs
    opengl software 
    % Graph description for prediction result
    f = figure;
    hold on;
    plot(x, y_pred,'g');
    if isempty(y_true) == 0
        plot(y_true,'r');
    else
        plot(zeros(x,1));
    end
    % If we have CI to be described
    if isempty(boundaries) == 0
        plot(boundaries(:,1),'b--');
        plot(boundaries(:,2),'b--');
        CI = 100*(1-ci_percentage);
        legend('predicted Load', 'True', [num2str(CI) '% Prediction Interval']);
    else
        legend('predicted Load', 'True');
    end
   
    % Labels of the graph
    xlabel('Time steps in a day');
    ylabel('Load [W]');
    title(name);
end