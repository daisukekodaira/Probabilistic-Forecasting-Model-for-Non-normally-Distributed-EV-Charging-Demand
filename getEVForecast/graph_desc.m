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