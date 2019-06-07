% ----------------------------------------------------------
% y_ture: True load [MW]
% y_predict: predicted load [MW]
%-----------------------------------------------------------

function pso_out = pso_main(y_predict, y_true)

    % Declare the global variables
    global_var_declare;

    % Initialization
    days = size(y_predict(1).data, 2);
    methods = size(y_predict, 2);
    timeInsts = size(y_predict(1).data, 1);
    g_y_predict = zeros(timeInsts*days, methods);
    
    % Restructure the predicted data
    for j = 1:methods % the number of prediction methods (k-means and fitnet)
        for day = 1: days % the number of day
            g_y_predict(1+(day-1)*timeInsts:day*timeInsts,j) = y_predict(j).data(:,day); % this global variable is utilized in 'objective_func'
        end
    end
    g_y_true = y_true;

    % Essential paramerters for PSO performance
    particlesize = 200;  % number of particles default = 200
    mvden = 1000;    % Bigger value makes the search area wider default = 1000
    epoch   = 2000;  % max iterations default = 2000

    run_pso;

end














