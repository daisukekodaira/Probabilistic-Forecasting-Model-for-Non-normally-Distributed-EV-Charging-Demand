function [PImean, PImin, PImax] = getPINeuralNet(predictors, determPred, err_distribution)

    hours = size(err_distribution,1);
    quarters = size(err_distribution,2);
    
    for hour = 1:hours
        for quarter = 1:quarters
            % get probabilisity density function object 
            pd = fitdist(err_distribution(hour, quarter).err,'Kernel','Kernel','epanechnikov');
            % get cutoff value for X and edge of the PDF
            cutoffX = icdf(pd, [.025, .975]);
            edgeX = icdf(pd, [.000001, .9999999]);
            % get x and y to be discribed
            x = linspace(edgeX(1), edgeX(2));
            y = pdf(pd, x);
            plot(x,y);
            % set area to be patched
            xci = [linspace(edgeX(1), cutoffX(1)); linspace(cutoffX(2), edgeX(2))]; % set X axis area
            yci = pdf(pd,xci);  % set Y axis area
            % Patch the outside of the Prediction Interval
            patch([xci(1,:) cutoffX(1)], [yci(1,:) 0], [0.5 0.5 0.5]);
            patch([cutoffX(2) xci(2,:)], [0 yci(2,:)], [0.5 0.5 0.5]);
        end
    end

end