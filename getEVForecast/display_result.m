% -----------------------------------------------------------------
% This function is only for debug
% -------------------------------------------------------------------

function [PICoverRate, MAPE] = display_result(figTitle, yLabel, PI, determPred, observed, alph)
    instances = size(determPred,1);
%     graph_desc(1:instances, yLabel, determPred, observed, PI, figTitle, alph);

    % Calculate and display cover rate of PI
    if isempty(PI) == 0
        % we have PI to be described
        count = 0;
        for i = 1:size(observed,1)
            if (PI(i,1)<=observed(i)) && (observed(i)<=PI(i,2))
                count = count+1;
            end
        end
        PICoverRate = 100*count/size(observed,1);
%         disp([figTitle, 'PI cover rate is ',num2str(PICoverRate), '[%]/', num2str(100*(1-alph)), '[%]'])
    else
        % we don't have PIs to be described
        PICoverRate = [];
    end
        
    % MAPE 
    MAPE = mean(abs(determPred - observed)*100./observed); % combined
%     disp([figTitle, 'MAPE of mean: ', num2str(MAPE), '[%]'])
end


function graph_desc(x, yLabel, y_pred, y_true, boundaries, name, ci_percentage)
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
    
    % Plot Prediction Intervals
    if isempty(boundaries) == 0
        % we have PI to be described
        plot(boundaries(:,1),'b--');
        plot(boundaries(:,2),'b--');
        CI = 100*(1-ci_percentage);
        legend('Forecasted', 'True', [num2str(CI) '% Prediction Interval']);
    else
        % we don't have PIs to be described
        legend('Forecasted', 'True');
    end
   
    % Labels of the graph
    xlabel('Time instances');
    ylabel(yLabel);
    title(name);
end